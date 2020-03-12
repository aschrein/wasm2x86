export ISPC_PATH=/home/aschrein/dev/cpp/ispc/build/bin
export LLVM_PATH=/home/aschrein/dev/llvm/build/bin
export SCRIPT=`realpath $0`
export SCRIPTPATH=`dirname $SCRIPT`
export PATH=$SCRIPTPATH:$PATH
export PATH=$ISPC_PATH:$PATH
export PATH=$LLVM_PATH:$PATH
export DUMP_PATH=`pwd`/ispc.perf.cmp
if [ -z "$1" ]
  then
    echo "No arguments supplied. Please provide the path to a valid .ispc file"
    exit
fi
export ISPC_FILE=`realpath $1`
rm -rf $DUMP_PATH
mkdir $DUMP_PATH
cd $DUMP_PATH && \
NAME=tmp && \
ispc $ISPC_FILE -O3 --opt=fast-masked-vload --opt=fast-math --opt=force-aligned-memory --target=wasm-i32x4 --nostdlib --emit-llvm-text -o $NAME.ll && \
llc -O3 -filetype=obj $NAME.ll -o $NAME.o && \
wasm-ld --lto-O3 --initial-memory=268435456 --max-memory=268435456 --no-entry --export=bench_main --allow-undefined -o $NAME.wasm $NAME.o && \
wasm-dis $NAME.wasm -o $NAME.wat && \
sh $SCRIPTPATH/wat_perf.sh $NAME.wat && \
sh $SCRIPTPATH/ispc_perf.sh $ISPC_FILE
exit

