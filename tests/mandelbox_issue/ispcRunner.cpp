#include "emscripten.h"
#include "program.h"
#include <stdio.h>
#include <stdlib.h>
#include <wasm_simd128.h>
#ifdef WIN32
#include <fcntl.h>
#include <io.h>
#endif

static uint32_t bufferSize = 0;
static uint32_t inputBufferSize = 0;
static uint32_t vulkanDeviceIndex = 0;
static int32_t workSize[3] = {1, 1, 1};

extern "C" void runner_workgroup(int numWorkGroups[], int workGroupID[], ispc::inputs *input, int *output);

static void writeImage(int *idImage, int width, int height, const char *filename) {
    FILE *f = stdout;
    if (!f) {
        perror(filename);
        exit(1);
    }
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int id = idImage[y * width + x];
            fprintf(f, "%i, %i, %i, 255,", ((id >> 0) & 0xff), ((id >> 8) & 0xff), ((id >> 16) & 0xff));
        }
    }
    fputc('\n', f);
    printf("Wrote image file %s\n", filename);
}

int main(int argc, char *argv[]) {
    ispc::inputs inputs;
    float *dims = (float *)((void *)&inputs);
    dims[0] = 512;
    dims[1] = 512;
    dims[2] = 0;
    dims[3] = 0;
    dims[4] = 0;
    dims[5] = 0;
    dims[6] = 0;
    dims[7] = 0;

    bufferSize = 512 * 512 * 4;

    int *outputData = (int *)malloc(bufferSize);
    int32_t workSize[3];
    workSize[0] = 1;
    workSize[1] = 1;
    workSize[2] = 1;
    int workGroupID[3];
    workGroupID[0] = 0;
    workGroupID[1] = 0;
    workGroupID[2] = 0;
    runner_workgroup(workSize, workGroupID, &inputs, outputData);
    writeImage(outputData, 512, 512, "wavm.ppm");

    return 0;
}
