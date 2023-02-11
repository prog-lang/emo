WASM = ./dist/wasm
JS = ./dist/js
GOROOT = $(shell go env GOROOT)

tools:
	go install ./cmd/tools/emo-gen-instruction-set

gen: tools
	go generate ./...

test: gen
	go test -v ./pkg/...

go-wasm-glue:
	cp "$(GOROOT)/misc/wasm/wasm_exec.js" "$(JS)/exec.go.wasm.js"
    
go-wasm: go-wasm-glue gen
	GOOS=js GOARCH=wasm go build -o "$(WASM)/main.go.wasm" ./cmd/wasm

elm-dev:
	elm make --output "$(JS)/main.elm.js" ./src/Main.elm 

elm-prod:
	elm make --optimize --output "$(JS)/main.elm.js" ./src/Main.elm

all: go-wasm elm-prod
