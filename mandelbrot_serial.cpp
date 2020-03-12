#if 0
NAME=mandelbrot_serial && \
cd tmp && \
clang -target wasm32-unknown-unknown -O3  ../$NAME.cpp -emit-llvm -S $NAME.ll && \
llc -filetype=obj $NAME.ll -o $NAME.o && \
wasm-ld --initial-memory=655360 --import-memory  --no-entry --export-all --allow-undefined -o $NAME.wasm $NAME.o && \
wasm-dis $NAME.wasm -o $NAME.wat
exit
-emit-llvm -S
#endif

#ifndef EMSCRIPTEN
extern "C"
int memset(void * ptr, char val, int count) {
    char *origin = (char*)ptr;
    char *end = (char*)ptr + count;
    for (; origin < end; origin++) {
        origin[0] = val;
    }
    return 0;
}
#else
#include <emscripten/emscripten.h>
// #include <emscripten/bind.h>
#endif

#define __DEFAULT_FN_ATTRS __attribute__((__always_inline__, __nodebug__, __target__("simd128"), __min_vector_width__(128)))

#define __REQUIRE_CONSTANT(e) _Static_assert(__builtin_constant_p(e), "Expected constant")

#define WASM_EXPORT __attribute__((visibility("default")))

extern "C"
{
static int __DEFAULT_FN_ATTRS mandel(float c_re, float c_im, int count) {
    float z_re = c_re, z_im = c_im;
    int i;
    for (i = 0; i < count; ++i) {
        if (z_re * z_re + z_im * z_im > 4.f)
            break;

        float new_re = z_re * z_re - z_im * z_im;
        float new_im = 2.f * z_re * z_im;
        z_re = c_re + new_re;
        z_im = c_im + new_im;
    }

    return i;
}

void __DEFAULT_FN_ATTRS WASM_EXPORT mandelbrot(float x0, float y0, float x1, float y1, int width, int height, int maxIterations, int output[]) {
    float dx = (x1 - x0) / width;
    float dy = (y1 - y0) / height;

    for (int j = 0; j < height; j++) {
        for (int i = 0; i < width; ++i) {
            float x = x0 + i * dx;
            float y = y0 + j * dy;

            int index = (j * width + i);
            output[index] = mandel(x, y, maxIterations);
        }
    }
}
void __DEFAULT_FN_ATTRS WASM_EXPORT multiply_arrays(int* out, int* in_a, int* in_b, int size) {
  for (int i = 0; i < size; i++) {
    out[i] = in_a[i] * in_b[i];
  }
}

}