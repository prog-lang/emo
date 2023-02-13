package main

import (
	"log"
	"syscall/js"

	"github.com/prog-lang/emo/pkg/cpu"
)

func main() {
	log.Println("Setting up WASM ...")

	cp := cpu.New()
	js.Global().Set("cpuState",
		js.FuncOf(func(this js.Value, args []js.Value) any {
			return cp.String()
		}))
	js.Global().Set("cpuLoadProgramHex",
		js.FuncOf(func(this js.Value, args []js.Value) any {
			cp.LoadProgramHex(args[0].String())
			return nil
		}))
	js.Global().Set("cpuStart",
		js.FuncOf(func(this js.Value, args []js.Value) any {
			cp.Start()
			return nil
		}))
	js.Global().Set("cpuReset",
		js.FuncOf(func(this js.Value, args []js.Value) any {
			cp.Init()
			return nil
		}))

	log.Println("WASM fully set up and operational")
	<-make(chan bool)
}
