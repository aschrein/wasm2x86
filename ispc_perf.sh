export ISPC_PATH=/home/aschrein/dev/cpp/ispc/build/bin
export LLVM_PATH=/home/aschrein/dev/llvm/build/bin
export SCRIPT=`realpath $0`
export SCRIPTPATH=`dirname $SCRIPT`
export PATH=$SCRIPTPATH:$PATH
export PATH=$ISPC_PATH:$PATH
export PATH=$LLVM_PATH:$PATH
export DUMP_PATH=`pwd`/ispc.perf.sse4
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
ispc $ISPC_FILE -O3 --opt=fast-masked-vload --opt=fast-math --opt=force-aligned-memory --target=sse4-i32x4 --nostdlib -o $NAME.o && \
gcc $SCRIPTPATH/bench_driver.c $NAME.o && \
objdump -D -M intel $NAME.o > $NAME.S && \
./a.out && \
# perf record -o perf.data -k mono ./a.out && \
# perf report -M intel -i perf.data
exit