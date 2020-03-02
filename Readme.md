## Build
```console
## fetch V8 and compile v8_monolith
## Also see https://github.com/danbev/learning-v8#building-v8
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$PATH:/path/to/depot_tools
fetch v8
cd v8
gclient sync
./build/install-build-deps.sh
tools/dev/v8gen.py x64.release.sample -- v8_enable_disassembler=true
## build this project
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DV8_PATH=/home/aschrein/dev/cpp/v8 .. && make -j10 && ./main test.wasm
```

----------
