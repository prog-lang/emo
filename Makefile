JS = ./dist/js
GOROOT = $(shell go env GOROOT)

glue:
	cp "$(GOROOT)/misc/wasm/wasm_exec.js" "$(JS)/exec.wasm.js"
    
wasm: glue
	GOOS=js GOARCH=wasm go build -o "$(JS)/main.wasm" ./cmd/wasm
