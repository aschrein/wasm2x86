export V8_PATH=/home/aschrein/dev/cpp/v8
export D8_PATH=$V8_PATH/out/x64.debug/d8
export DUMP_PATH=`pwd`/tmp
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
        --wasm-opt $SCRIPTPATH/bench_driver.js -- tmp.wasm
exit