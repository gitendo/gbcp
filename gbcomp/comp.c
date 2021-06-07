/* GB-Compress V1.3                                                           */

/* This algorithm tries to compress information. While I tried to optimize    */
/* it for Gamboy-GFX (font and font-map), it gives good results on text, too. */
/* I COULD implement more intelligent algorithms, but I wanted the GB-code to */
/* be small, simple and fast, and the more complex stuff would need lots of   */
/* 16-Bit arithmentics.                                                       */

/* You can use decomp.inc in your own asm-projects to decompress it.          */

/* Codes:                                                                     */
/*  00000000 - End of compressed block                                        */
/*  00  n    - copy following byte n+1 times                                  */
/*  01  n    - copy following word n+1 times                                  */
/*  10  n    - repeat the n+1 bytes from buffer                               */
/*  11  n    - copy n+1 following bytes                                       */

/* History:                                                                   */
/*  1.0 - first version                                                       */
/*  1.1 - 10% better compression !                                            */
/*  1.2 - fixed bug reported by Jeff Frohwein                                 */
/*  1.3 - Sam Nova:                                                           */
/*        Fixed several errors.                                               */
/*        If the data for 11 (copy n+1...) was longer than 64 it would create */
/*        Code was cleaned up a lot. Almost all variable names was changed for*/
/*        two/three letters to words.                                         */
/*        The compress code it self is now placed in comp.c with include file */
/*        comp.h this makes it possible to use the code from other tools.     */
/*        The old code wrote the compressed data into a file, this is NO      */
/*        supported, everything is done in buffers.                           */
/*        There is now a function called compress that compresses a memory    */
/*        buffer. It requieres an destinantion buffer, Im NOT sure how big    */
/*        this buffer should be, so I normally just allocate an buffer that   */
/*        has the double size of the source buffer.                           */
/*        Improved compression in some cases. Before 64 bytes was the max     */
/*        that could be compressed in one go, this has been improved with a   */
/*        few bytes.                                                          */
/*        Code complies fine with Visual C++ 6.0                              */
/*  1.4 - Sam Nova:                                                           */
/*        Fixed bug in the code to find strings that can be repeated. The bug */
/*        goes the whole way back to the code by Jens Ch. Restermeier.        */
/*        One side effect of fixing this bug is that it might compress better */
/*        in some cases.                                                      */
/*                                                                            */
/*                                                                            */
/*  Report problems or comments to samnova@datacomm.ch                        */

#include "comp.h"

const int MAX_STRING_SIZE = 67; // +4
const int MAX_BYTE_REPEAT = 65; // +2
const int MAX_WORD_REPEAT = 66; // +3

static int iCompressedSize;
static unsigned char *pDestData;

static void write_end()
{
  iCompressedSize++;
  *pDestData = 0;
  pDestData++;
}

static void write_byte(int len,unsigned char pSourceData)
{
  len=(len - 2) & 63; // 0 - 63 + 2 // 3 is NOT possible because then we get
                      // the code 00  = END
                      // 1 == 3
  iCompressedSize += 2;

  *pDestData = len;
  pDestData++;

  *pDestData = pSourceData;
  pDestData++;

}

static void write_word(int len,unsigned short pSourceData)
{
  len=((len - 3) & 63) | 64;

  iCompressedSize += 3;

  *pDestData = len;
  pDestData++;

  *pDestData = pSourceData & 0xff;
  pDestData++;

  *pDestData = pSourceData >> 8;
  pDestData++;
}

static void write_string(int len,unsigned int pSourceData)
{
  len= ((len - 4) & 63) | 128;      // 0 - 63 + 4

  iCompressedSize += 3;
  
  *pDestData = len;
  pDestData++;

  *pDestData = pSourceData & 0xff;
  pDestData++;

  *pDestData = pSourceData >> 8;
  pDestData++;
}

static void write_trash(int len,unsigned char *pos)
{
  unsigned char cmd;

  cmd=( (len - 1) & 63) | 192;

  iCompressedSize+= len + 1;

  *pDestData = cmd;
  pDestData++;

  while(len)
  {
    *pDestData = *pos;
    pDestData++;
    pos++;
    len--;
  }
}

int compressData(void *source,void *dest, int size)
{
  int bytePointer,trashBytes;
  unsigned char *pSourceData = (unsigned char *)source;
  int iSourceSize = size;

  pDestData = (unsigned char *)dest;
  iCompressedSize=0;

  bytePointer = trashBytes = 0;

  while (bytePointer<iSourceSize)
  {
    unsigned char x;
    unsigned short y;
    int repeatByteSource,bestRepeatStringSource,repeatLength;
    int repeatBytesLen,repeatWordsLen,bestRepeatStringLen;

    // Find length of byte repeat
    x= *(pSourceData + bytePointer);
    repeatBytesLen = 1;

    while ((*(pSourceData + bytePointer + repeatBytesLen) == x) &&
      ((bytePointer + repeatBytesLen) < iSourceSize) && (repeatBytesLen < MAX_BYTE_REPEAT) )
      repeatBytesLen++;

    // Find length of word repeat
    y=*((unsigned short *)&(*(pSourceData+bytePointer)));
    repeatWordsLen = 1;

    while ((*((unsigned short *)&(*(pSourceData + bytePointer + repeatWordsLen * 2))) == y) &&
      ((bytePointer + (repeatWordsLen * 2) + 1) < iSourceSize) && (repeatWordsLen < MAX_WORD_REPEAT))
      repeatWordsLen++;

    // Find best string repeat
    repeatByteSource = bestRepeatStringSource = bestRepeatStringLen = 0;

    while (repeatByteSource < bytePointer)
    {
      repeatLength  =0;

      while ((*(pSourceData + repeatByteSource + repeatLength) ==
        *(pSourceData + bytePointer + repeatLength)) &&
        ((bytePointer + repeatLength + 1) < iSourceSize ) && (repeatLength < MAX_STRING_SIZE))

        repeatLength++;

      if (repeatLength > bestRepeatStringLen)
      {
        bestRepeatStringSource = repeatByteSource - bytePointer;
        bestRepeatStringLen = repeatLength;
      }
      repeatByteSource++;
    }

    // Lets find out what to output
    if ((repeatBytesLen > 2) &&
      (repeatBytesLen > repeatWordsLen) &&
      (repeatBytesLen > bestRepeatStringLen))
    {
      // The winner is the repeat bytes...
      if (trashBytes>0) 
        write_trash(trashBytes,pSourceData + bytePointer - trashBytes);

      trashBytes=0;
      write_byte(repeatBytesLen,x);
      bytePointer += repeatBytesLen;
    } else 
    {
      // Well it is not going to be repeated bytes..

      if ((repeatWordsLen > 2)&&
       ((repeatWordsLen * 2) > bestRepeatStringLen)) 
      {
        // No the winer is repeated words
        if (trashBytes>0) 
          write_trash(trashBytes,pSourceData+bytePointer-trashBytes);

        trashBytes=0;
        write_word(repeatWordsLen,y);

        bytePointer += repeatWordsLen * 2;
      } else 
      {
        // No repeated words
        if (bestRepeatStringLen > 3) 
        {
          // No it is a string :)
          if (trashBytes>0) 
            write_trash(trashBytes,pSourceData+bytePointer-trashBytes);

          trashBytes = 0;
          
          write_string(bestRepeatStringLen, bestRepeatStringSource);
          bytePointer += bestRepeatStringLen;

        } else 
        {
          // Nah, nothing here..lets just add it as a trash byte...

          if (trashBytes >= 64)
          {
            write_trash(trashBytes, pSourceData + bytePointer - trashBytes);
            trashBytes = 0;
          }
          trashBytes++;
          bytePointer++;
        }
      }
    }
  }

  // We are done..if there are any trash bytes left then output then...
  if (trashBytes>0) 
    write_trash(trashBytes,pSourceData+bytePointer-trashBytes);

  // Mark it as all over...
  write_end();
  
  return iCompressedSize;
}
