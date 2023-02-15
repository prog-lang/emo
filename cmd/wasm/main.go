package main

import (
	"log"
	"syscall/js"

	"github.com/prog-lang/emo/pkg/cpu"
)

func main() {
	log.Println("Setting up WASM ...")

	js.Global().Set("cpu", ObjectOf(cpu.New()))

	log.Println("WASM fully set up and operational")
	select {}
}
