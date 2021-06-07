#include <stdio.h>
#include <stdlib.h>

typedef unsigned char uint8_t;

typedef struct {
  uint8_t length;
  uint8_t delta;
} Match;

Match* find_longest_match(uint8_t* buffer, int buffer_size, int i);
void write_flag_byte(uint8_t flag_byte, FILE* out, int last_flag_pos);

int main(int argc, char** argv) {
  FILE* in;
  FILE* out;

  uint8_t* buffer;
  int buffer_size;

  uint8_t flag_byte;
  int i;
  int command_cnt;

  int last_flag_pos;

  Match* longest_match;

  /* check usage */
  if (argc != 3) {
    fprintf(stderr, "No arguments given\n");
    return -1;
  }

  /* open input file */
  in = fopen(argv[1], "rb");
  if (!in) {
    fprintf(stderr, "Could not load infile %s\n", argv[1]);
    return -2;
  }

  /* get size of input file */
  fseek(in, 0, SEEK_END);
  buffer_size = ftell(in);
  rewind(in);

  /* load input file into buffer */
  buffer = malloc(buffer_size);
  fread(buffer, 1, buffer_size, in);
  fclose(in);

  /* open up output file */
  out = fopen(argv[2], "wb");
  if (!out) {
    fprintf(stderr, "Could not load outfile %s\n", argv[2]);
    return -3;
  }

  flag_byte = 0;
  last_flag_pos = -1;
  for (i = command_cnt = 0; i < buffer_size;) {
    /* check if we need to reserve a flag byte */
    if (command_cnt % 8 == 0) {
      last_flag_pos = ftell(out);
      /* just write a garbage byte to reserve a slot for the flags */
      fputc(0xAA, out);
      flag_byte = 0;
      command_cnt = 0;
    }

    /* write out the next command */
    longest_match = find_longest_match(buffer, buffer_size, i);
    if (longest_match) {
      fputc(longest_match->length, out);
      fputc(-longest_match->delta, out);
      i += longest_match->length;
      free(longest_match);
    } else {
      fputc(buffer[i], out);
      i++;
      /* raise the literal flag */
      flag_byte = (uint8_t)(flag_byte | (1 << command_cnt));
    }

    /* check if we need to write a flag byte */
    command_cnt++;
    if (command_cnt == 8) {
      write_flag_byte(flag_byte, out, last_flag_pos);
    }
  }
  /* if we just wrote a flag byte, we need to write another one */
  if (command_cnt % 8 == 0) {
    fputc(0, out);
  } else {
    /* otherwise we need to write this one properly */
    write_flag_byte(flag_byte, out, last_flag_pos);
  }

  /* write an EOF marker */
  fputc(0, out);

  fclose(out);
  return 0;
}

Match* find_longest_match(uint8_t* buffer, int buffer_size, int i) {
  Match* longest_match = NULL;
  uint8_t match_len;
  uint8_t j;

  /* walk backwards from the read head */
  for (j = 1; i - j >= 0; j++) {

    /* find the biggest match from this starting point */
    for(match_len = 0;
        i + match_len < buffer_size &&
        buffer[i + match_len] == buffer[i + match_len - j];
        match_len++) {
      if (match_len == 255) {
        break;
      }
    }

    /* update it if this is the best */
    if ((longest_match && match_len > longest_match->length) ||
        (!longest_match && match_len > 2)) {
      if (!longest_match) {
        longest_match = malloc(sizeof(Match));
      }
      longest_match->delta = j; 
      longest_match->length = match_len;
    }

    if (j == 255) {
      break;
    }
  }

  return longest_match;
}

void write_flag_byte(uint8_t flag_byte, FILE* out, int last_flag_pos) {
  int current_write_pos;

  /* backup the write position */
  current_write_pos = ftell(out);

  fseek(out, last_flag_pos, SEEK_SET);
  fputc(flag_byte, out);

  /* return to the write position */
  fseek(out, current_write_pos, SEEK_SET);
}
