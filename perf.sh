# Usage:
# sh perf.sh test.wat
export V8_PATH=/home/aschrein/dev/cpp/v8
export D8_PATH=$V8_PATH/out/x64.debug/d8
export DUMP_PATH=`pwd`/perf.tmp
export PATH=`pwd`/build:$PATH
export PATH=`pwd`:$PATH
export WAT_FILE=`realpath $1`
if [ -z "$1" ]
  then
    echo "No arguments supplied. Please provide the path to a valid .wat file"
    exit
fi
rm -rf $DUMP_PATH
mkdir $DUMP_PATH
cp bench_driver.js $DUMP_PATH/bench_driver.js
cd $DUMP_PATH && \
sh wat2x86.sh $WAT_FILE && \
perf record -o perf.data -k mono $D8_PATH --perf-prof \
        --experimental-wasm-simd --no-liftoff --no-debug-code --no-wasm-stack-checks \
        --turbo-stats-wasm --wasm-opt --perf-prof-annotate-wasm bench_driver.js -- tmp.wasm && \
perf inject -j -i perf.data -o perf.data.jitted && \
perf report -M intel -i perf.data.jitted
exit