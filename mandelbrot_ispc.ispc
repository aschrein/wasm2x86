#if 0
NAME=mandelbrot_ispc && \
cd tmp && \
ispc ../$NAME.ispc -O3 --opt=fast-masked-vload --opt=fast-math --opt=force-aligned-memory  --target=wasm-i32x4 --nostdlib --emit-llvm-text -o $NAME.ll && \
ispc ../$NAME.ispc -O3 --opt=fast-masked-vload --opt=fast-math --opt=force-aligned-memory  --target=sse2-i32x4 --nostdlib --emit-llvm-text -o $NAME.sse2.ll && \
llc -O3 -filetype=obj $NAME.ll -o $NAME.o && \
llc -O3 --asm-show-inst --asm-verbose $NAME.ll -o $NAME.S && \
wasm-ld -S --lto-O3 --import-memory --no-entry --export-all --allow-undefined -o $NAME.wasm $NAME.o && \
wasm-dis $NAME.wasm -o $NAME.wat && \

exit

--opt=fast-masked-vload --opt=fast-math --opt=force-aligned-memory
ispc ../$NAME.ispc --opt=fast-masked-vload --opt=fast-math --opt=force-aligned-memory -O3 --target=sse2-i32x4 --nostdlib --emit-llvm-text -o $NAME.sse2.ll && \
opt -dot-cfg $NAME.ll && \
dot -Tpdf -o $NAME.pdf .mandelbrot.dot
-S --lto-O3

llvm-as $NAME.ll -o $NAME.bc && \
opt --loop-fusion --gvn --loop-simplifycfg -O3 $NAME.bc -o $NAME.opt.bc && \
llvm-dis $NAME.opt.bc -o $NAME.opt.ll && \

--wasm-profile
wasm-as --enable-simd --enable-bulk-memory mandelbrot_ispc.wat -o mandelbrot_ispc.wasm
#endif
// export uniform int width() { return programCount; }



// void foo(float a[]) {
//     a[5] = 0;
// }

// export void f_fu(uniform float RET[], uniform float aFOO[], uniform float b) {
//     float a = aFOO[programIndex];
//     float x[10];
//     uniform int i;
//     for (i = 0; i < 10; ++i)
//         x[i] = a*b;
//     if (a >= 2)
//         foo(x);
//     RET[programIndex] = x[b] + x[9];
// }

// export void result(uniform float RET[]) { 
//     RET[programIndex] = 5 * (programIndex+1);
//     RET[0] = RET[1] = 10;
// }


static inline int mandel(float c_re, float c_im, int count) {
    float z_re = c_re, z_im = c_im;
    int i;
    for (i = 0; i < count; ++i) {
        if (z_re * z_re + z_im * z_im > 4.)
            break;

        float new_re = z_re*z_re - z_im*z_im;
        float new_im = 2.f * z_re * z_im;
        unmasked {
            z_re = c_re + new_re;
            z_im = c_im + new_im;
        }
    }

    return i;
}

export void mandelbrot(uniform float x0, uniform float y0,
                            uniform float x1, uniform float y1,
                            uniform int width, uniform int height,
                            uniform int maxIterations,
                            uniform int output[])
{
    float dx = (x1 - x0) / width;
    float dy = (y1 - y0) / height;

    for (uniform int j = 0; j < height; j++) {
        // Note that we'll be doing programCount computations in parallel,
        // so increment i by that much.  This assumes that width evenly
        // divides programCount.
        foreach (i = 0 ... width) {
            // Figure out the position on the complex plane to compute the
            // number of iterations at.  Note that the x values are
            // different across different program instances, since its
            // initializer incorporates the value of the programIndex
            // variable.
            float x = x0 + i * dx;
            float y = y0 + j * dy;

            int index = j * width + i;
            output[index] = mandel(x, y, maxIterations);
        }
    }
}

export void test(uniform int width,
                    uniform int maxIterations,
                    uniform float data[])
{

    foreach (i = 0 ... width) {
        float a = data[i];
        if (a > 0.5f) {
            data[i] = a * 0.5f;
        }
        // float b = a / 1000.0f;
        // int j;
        // for (j = 0; j < maxIterations; j++) {
        //     b = a + a * b;
        //     if (b > a)
        //         break;
        // }
        // data[i] = j;
    }
}

/*
Instrumentation:
(import "env" "__wasm_bb_begin" (func $fimport$1 (param i32 i32)))
...
(call $fimport$1 (i32.const 1) (i32.const 1))
*/

// cmake ../ -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS=-DLLVM_ENABLE_DUMP -DCMAKE_CXX_FLAGS=-DLLVM_ENABLE_DUMP -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;ldd;lldb"