wasm-as --enable-simd $1 -o tmp.wasm && \
wasm2x86 tmp.wasm && \
objdump -M intel -D -b binary -m i386:x86-64 module.bin > tmp.S