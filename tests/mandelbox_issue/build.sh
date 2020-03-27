export PATH=/home/aschrein/dev/cpp/ispc/build/bin:$PATH
export PATH=/home/aschrein/dev/llvm/build/Release/bin:$PATH
which ispc
which clang
mkdir -p build && cd build
ispc ../runner.ispc -O3 --target=wasm-i32x4 --emit-llvm -o ispc.bc && \
llvm-dis ispc.bc -o ispc.ll && \
llc -filetype=obj ispc.bc -o ispc.o && \
emcc -O3 ../ispcRunner.cpp  ispc.o -s ASSERTIONS=0 \
  -s TOTAL_MEMORY=268435456 -o index.html -msimd128 -s SIMD=1 \
  -s EMIT_EMSCRIPTEN_METADATA=1 \
  -s INVOKE_RUN=1 \
  -s STANDALONE_WASM=1 \
  -s EXPORTED_FUNCTIONS='["_main", "_malloc"]' && \
~/dev/cpp/v8/out/x64.release/d8 --experimental-wasm-simd index.js > dump.txt && \
head -n -1 dump.txt > temp.txt ; mv temp.txt dump.txt && \
g++ ../print_ppm.cpp -I./ && ./a.out "d8.ppm" && \
~/dev/cpp/WAVM/build/bin/wavm run --enable all --abi=wasi index.wasm > dump.txt && \
head -n -2 dump.txt > temp.txt ; mv temp.txt dump.txt && \
g++ ../print_ppm.cpp -I./ && ./a.out "wavm.ppm" && \
exit 0
exit 1
