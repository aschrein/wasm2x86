const bytes = read(arguments[0], 'binary');
let module = new WebAssembly.Module(bytes);
let instance = new WebAssembly.Instance(module, {env:{}});
let offset = (1 << 16) * 10;
let N = 16 * (1 << 20);
// let i32view = new Int32Array(instance.exports.memory.buffer);
// for (var i = 0; i < N; i++) {
//   i32view[i + offset/4 + N] = i + 1;
//   i32view[i + offset/4 + 2 * N] = i + 1;
// }
let t0 = performance.now();
instance.exports.bench_main(offset, N);
let t1 = performance.now();
console.log("ms:" + (t1 - t0));
// console.log(i32view.slice(offset/4, offset/4 + 10));