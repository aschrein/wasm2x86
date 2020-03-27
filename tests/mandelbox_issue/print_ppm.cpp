#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

static void writeImage(int *idImage, int width, int height, const char *filename) {
    FILE *f = fopen(filename, "wb");
    if (!f) {
        perror(filename);
        exit(1);
    }

    fprintf(f, "P6\n%d %d\n255\n", width, height);
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            // use the bits from the object id of the hit object to make a
            // random color
            int id = idImage[y * width + x];
            fputc(((id >> 0) & 0xff), f);
            fputc(((id >> 8) & 0xff), f);
            fputc(((id >> 16) & 0xff), f);
        }
    }
    fclose(f);
    printf("Wrote image file %s\n", filename);
}

uint8_t vals[] = {
  #include "dump.txt"
};

int main(int argc, char **argv) {
  writeImage((int*)vals, 512, 512, argv[1]);
  return 0;
}