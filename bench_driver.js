const bytes = read(arguments[0], 'binary');
let module = new WebAssembly.Module(bytes);
let instance = new WebAssembly.Instance(module, {env:{}});
instance.exports.main(1000);