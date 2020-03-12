# Usage:
# sh perf.sh test.wat
# chromium --v8-options="--no-liftoff --no-debug-code --no-wasm-stack-checks --no-wasm-bound-checks --wasm-opt"
export V8_PATH=/home/aschrein/dev/cpp/v8
export D8_PATH=$V8_PATH/out/x64.release/d8
export DUMP_PATH=`pwd`/perf.wat
export SCRIPT=`realpath $0`
export SCRIPTPATH=`dirname $SCRIPT`
export PATH=$SCRIPTPATH/build:$PATH
export PATH=$SCRIPTPATH:$PATH
if [ -z "$1" ]
  then
    echo "No arguments supplied. Please provide the path to a valid .wat file"
    exit
fi
export WAT_FILE=`realpath $1`
rm -rf $DUMP_PATH
mkdir $DUMP_PATH
cd $DUMP_PATH && \
sh $SCRIPTPATH/wat2x86.sh $WAT_FILE && \
$D8_PATH --perf-prof \
        --experimental-wasm-simd --no-liftoff --no-debug-code --no-wasm-stack-checks \
        --wasm-opt --perf-prof-annotate-wasm $SCRIPTPATH/bench_driver.js -- tmp.wasm && \
# perf record -o perf.data -k mono $D8_PATH --perf-prof \
#         --experimental-wasm-simd --no-liftoff --no-debug-code --no-wasm-stack-checks \
#         --wasm-opt --perf-prof-annotate-wasm $SCRIPTPATH/bench_driver.js -- tmp.wasm && \
# perf inject -j -i perf.data -o perf.data.jitted && \
# perf report -M intel -i perf.data.jitted
exit