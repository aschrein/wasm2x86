const bytes = read(arguments[0], 'binary');
let module = new WebAssembly.Module(bytes);
let instance = new WebAssembly.Instance(module, {env:{}});
let offset = (1 << 16) * 10;
let N = 1000000;
// let i32view = new Int32Array(instance.exports.memory.buffer);
// for (var i = 0; i < N; i++) {
//   i32view[i + offset/4 + N] = i + 1;
//   i32view[i + offset/4 + 2 * N] = i + 1;
// }
instance.exports.bench_main(offset,
                      offset + N * 4,
                      offset + 2 * N * 4,
                      N);
// console.log(i32view.slice(offset/4, offset/4 + 10));