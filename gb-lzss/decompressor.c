#include <stdint.h>
#include <stdio.h>

int decompress(FILE* in, FILE* out);

int main(int argc, char** argv) {
  FILE* in;
  FILE* out;
  int error_code;

  error_code = 0;

  if (argc != 3) {
    fprintf(stderr, "Needs two arguments\n");
    return -1;
  }

  in = fopen(argv[1], "rb");
  if (!in) {
    fprintf(stderr, "Could not open %s for reading\n", argv[1]);
    return -2;
  }

  out = fopen(argv[2], "wb+");
  if (!out) {
    fprintf(stderr, "Could not open %s for writing\n", argv[2]);
    error_code = -3;
    goto cleanup_out_fail;
  }

  if(decompress(in, out) == -1) {
    fprintf(stderr, "WARNING: missing EOF marker\n");
    error_code = 1;
  }

  fclose(out);

 cleanup_out_fail:
  fclose(in);

  return error_code;
}

int decompress(FILE* in, FILE* out) {
  uint8_t flag_byte;
  int i;
  int j;
  uint8_t len;
  int8_t delta_byte;
  int delta;
  uint8_t c;

  while(!feof(in)) {
    flag_byte = fgetc(in);
    for(i = 0; i < 8; i++, flag_byte >>= 1) {
      if (flag_byte & 1) {
        fputc(fgetc(in), out);
      } else {
        if ((len = fgetc(in)) == 0) {
          return 0;
        } else {
          delta_byte = fgetc(in);
          delta = delta_byte > 0 ? -127 - (129 - delta_byte) : delta_byte;
          for (j = 0; j < len; j++) {
            fseek(out, delta, SEEK_CUR);
            c = fgetc(out);
            fseek(out, -delta-1, SEEK_CUR);
            fputc(c, out);
          }
        }
      }
    }
  }

  return -1;
}
