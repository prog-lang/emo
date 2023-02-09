GOROOT = $(shell go env GOROOT)

glue:
	cp "$(GOROOT)/misc/wasm/wasm_exec.js" ./dist/exec.wasm.js
    
wasm: glue
	GOOS=js GOARCH=wasm go build -o ./dist/main.wasm ./cmd/wasm

dist: wasm
	rm ./dist/.gitignore