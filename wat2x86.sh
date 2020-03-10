wasm-as --enable-simd $1 -o tmp.wasm && \
wasm2x86 tmp.wasm > v8dump.S && \
objdump -M intel -D -b binary -m i386:x86-64 module.bin > tmp.S