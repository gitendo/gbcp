/* GBComp V1.0                                                              */
/* Written by Samuel S. Nova  samnova@datacomm.ch                           */

/* This code just reads a file and compresses it with compressData, see     */
/* comp.h and comp.c for that code.                                         */


#include <stdio.h>
#include <stdlib.h>
#include "comp.h"

int main(int argc,char *argv[])
{
  FILE *fp;
  unsigned int inSize, outSize;
  char *inBuffer, *outBuffer;

  printf("GBComp V1.0. Using GB-Compress 1.4\n");
  printf("Written by Samuel S. Nova     samnova@datacomm.ch\n"
   "Based on compression code by Jens Ch. Restermeier\n");

  if (argc != 3)
  {
    printf(  "\nUsage:\n"
     "GBComp infile outfile\n"
     "\n\n"
     "It WILL overwrite any existing outfiles\n"
     );
    return 1;
  }

  printf("Reading %s\n", argv[1]);

  // Open the source file
  fp = fopen(argv[1], "rb");
  if (fp == NULL)
  {
    printf("Could not open input file :%s\n", argv[1]);
    return 1;
  }

  // Get size of input file
  fseek(fp, 0, SEEK_END);
  inSize = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  // Allocate buffer for input file
  inBuffer = malloc(inSize);
  if (inBuffer == NULL)
  {
    printf("Not enough memory for buffer for source file.\n");
    return 1;
  }

  // Read input file
  if (fread(inBuffer, 1, inSize, fp) != inSize)
  {
    printf("Error reading file\n");
    return 1;
  }
  
  fclose(fp);

  // Allocate memory for destinantion buffer
  outBuffer = malloc(inSize * 2);
  if (outBuffer == NULL)
  {
    printf("Not enough memory for buffer for destinantion file.\n");
    return 1;
  }

  // Okay, all memory okay, lets compress the stuff

  outSize = compressData(inBuffer, outBuffer, inSize);

  // Lets write the file

  printf("Writing %s\n", argv[2]);
  fp = fopen(argv[2], "wb");
  if (fp == NULL)
  {
    printf("Could not create output file %s\n", argv[2]);
    return 1;
  }

  fwrite(outBuffer, 1, outSize, fp);
  fclose(fp);

  printf("%d bytes compressed down to %d. Saved %d bytes = %1.2f%%\n", inSize, outSize,
    inSize - outSize, (double)(inSize - outSize) / inSize);

  return 0;

}
