function status() {
    const app = document.getElementById("app")
    app.innerHTML = cpuStatus()
}

function execute() {
    const instruction = document.getElementById("instruction")
    cpuExecHex(instruction.value)
}