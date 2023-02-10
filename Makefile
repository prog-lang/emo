JS = ./dist/js
GOROOT = $(shell go env GOROOT)

tools:
	go install ./cmd/tools/emo-gen-instruction-set

glue:
	cp "$(GOROOT)/misc/wasm/wasm_exec.js" "$(JS)/exec.wasm.js"

gen: tools
	go generate ./...

test: gen
	go test -v ./pkg/...
    
wasm: glue gen
	GOOS=js GOARCH=wasm go build -o "$(JS)/main.wasm" ./cmd/wasm
