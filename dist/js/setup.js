const go = new Go();
WebAssembly.instantiateStreaming(
    fetch("js/main.wasm"),
    go.importObject
).then((result) => {
    go.run(result.instance);
});