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
tools/dev/v8gen.py x64.debug -- v8_monolithic=true is_component_build=false v8_use_external_startup_data=false use_custom_libcxx=false
ninja -C out.gn/x64.debug v8_monolith -j10

## Generate compiler_commands.json
cd out.gn/x64.debug && ninja -t compdb cxx cc > compile_commands.json

## build this project
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DV8_PATH=/home/aschrein/dev/cpp/v8 .. && make -j10 && ./main test.wasm
```

----------
