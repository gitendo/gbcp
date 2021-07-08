// This is fixed and improved version of https://github.com/ocean1/mmx_hackpack
// Original code fails to compress cenotaph.map properly.
// Thanks to quirky nature of Capcom's tool, this one performs slightly better.
//
// tmk / https://github.com/gitendo/gbcp

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MIN_LENGTH  3           // minimum reference size
#define MAX_LENGTH  0x7F        // maximum literals / reference size
#define WINDOW_SIZE 0xFF        // sliding window size
#define FLAG_LTRLS  0           // indicates literals
#define FLAG_PAIR   0x80        // indicates length,offset pair
#define FLAG_EOF    0           // end of compressed data

// sequence of repeated bytes
typedef struct SEQ {
    int offset;
    int length;
} SEQ;


// find longest sequence of repeated bytes in window
SEQ find(unsigned char *data, int offset, size_t size)
{
    SEQ match = {.offset = 0, .length = 0};
    int length, window;

    // initialize sliding window position and loop count
    if(offset < WINDOW_SIZE)
        window = 0;
    else
        window = offset - WINDOW_SIZE;

    // scan the window
    while(window < offset) {
        // start new sequence
        length = 0;
        // if first bytes match
        if(data[window] == data[offset]) {
            length++;
            // check and count others
            while (data[window + length] == data[offset + length])
            {
                // next byte
                length++;
                // avoid match size overflow
                if(length == MAX_LENGTH)
                    break;
                // stay in bounds
                if(window + length > size)
                    break;
            }
        }
        // update if match is found and it's better then previous one
        if((length >= MIN_LENGTH) && (length > match.length)) {
            match.offset = window;
            match.length = length;
        }
        // advance to next byte in window
        window++;
    }
    return match;
}


// read input data, compress it and write to output file
void compress(FILE *fi, FILE *fo)
{
    double gain;
    size_t size;
    unsigned char *data;
    unsigned char buffer[MAX_LENGTH];
    int d = 0;  // data offset
    int b = 0;  // buffer offset
    SEQ best = {.offset = 0, .length = 0};

    // get unpacked data size
    fseek(fi, 0, SEEK_END);
    size = ftell(fi);
    fseek(fi, 0, SEEK_SET);
    // allocate memory and read unpacked data
    data = (unsigned char *) malloc(size);
    fread(data, sizeof(unsigned char), size, fi);
    printf("Original file size %zd bytes, ", size);

    // scan unpacked data
    while(d < size) {
        // find best match
        best = find(data, d, size);
        if(best.length > 0) {
            // write literals, size and buffer content if its not empty
            if(b) {
                fputc((FLAG_LTRLS | b), fo);
                fwrite(buffer, sizeof(unsigned char), b, fo);
                // reset buffer offset
                b = 0;
            }
            // write token and offset pair
            fputc((FLAG_PAIR | best.length), fo);
            // stored as negative value
            fputc((best.offset - d) & 0xFF, fo);
            // adjust data offset
            d += best.length;
        } else {
            // copy one byte to buffer
            buffer[b] = data[d];
            b++;
            d++;
            // write literals if buffer is full or end of data reached
            if(b == MAX_LENGTH || d == size) {
                fputc((FLAG_LTRLS | b), fo);
                fwrite(buffer, sizeof(unsigned char), b, fo);
                // reset buffer offset
                b = 0;
            }
        }
    }
    // mark end of compressed data
    fputc(FLAG_EOF, fo);
    // calculate and print results
    gain = (1 - ftell(fo) / (double) size) * 100;
    printf("compressed to %d bytes, gain: %0.2F%%\n", ftell(fo), gain);
    free(data);
}


// let's go
int main(int argc, char *argv[])
{
    FILE *fi, *fo;

    printf("LZSS packer compatible with Capcom's Mega Man Xtreme 1 & 2 variant.\n");
    printf("Original code: ocean1, improved by: tmk.\n");
    printf("Visit https://github.com/gitendo/gbcp for more!\n\n");

    if(argc != 3) {
        printf("Usage:\n");
        printf("\t%s unpacked.dat packed.dat\n", argv[0]);
        return 1;        
    }

    fi = fopen(argv[1],"rb");
    if(!fi) {
        printf("Can't open %s\n", argv[1]);
        return 1;
    }

    fo = fopen(argv[2],"wb");
    if(!fo) {
        printf("Can't open %s\n", argv[2]);
        fclose(fi);
        return 1;
    }

    compress(fi, fo);
 
    fclose(fo);
    fclose(fi);

    return 0;
}