package main

import (
	"log"
	"syscall/js"

	"github.com/prog-lang/emo/pkg/cpu"
)

func main() {
	log.Println("Setting up WASM ...")

	machine := cpu.New()
	js.Global().Set("cpuState",
		js.FuncOf(func(this js.Value, args []js.Value) any {
			return machine.String()
		}))
	js.Global().Set("cpuExecuteHexInstruction",
		js.FuncOf(func(this js.Value, args []js.Value) any {
			machine.ExecuteHexInstruction(args[0].String())
			return nil
		}))

	log.Println("WASM fully set up and operational")
	<-make(chan bool)
}
