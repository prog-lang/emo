const GO_WASM_INSTANCE_READY = "GO_WASM_INSTANCE_READY";

function setupGoWebAssemblyInstance() {
  const go = new Go();
  WebAssembly.instantiateStreaming(
    fetch("wasm/main.go.wasm"),
    go.importObject
  ).then((program) => {
    go.run(program.instance);
    document.dispatchEvent(new Event(GO_WASM_INSTANCE_READY));
  });
}

function setupElm() {
  const app = Elm.Main.init({
    node: document.getElementById("app"),
  });
  app.ports.cpuState.send(cpuState());
  app.ports.cpuExecuteHexInstruction.subscribe((hex) => {
    cpuExecuteHexInstruction(hex);
    setTimeout(() => app.ports.cpuState.send(cpuState()), 10);
  });
}

(function () {
  document.addEventListener(GO_WASM_INSTANCE_READY, (_) => setupElm());
  setupGoWebAssemblyInstance();
})();
