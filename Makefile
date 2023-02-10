JS = ./dist/js
GOROOT = $(shell go env GOROOT)

tools:
	go install ./cmd/tools/emo-gen-instruction-set

gen: tools
	go generate ./...

test: gen
	go test -v ./pkg/...

wasm-glue:
	cp "$(GOROOT)/misc/wasm/wasm_exec.js" "$(JS)/exec.wasm.js"
    
go-wasm: wasm-glue gen
	GOOS=js GOARCH=wasm go build -o "$(JS)/main.go.wasm" ./cmd/wasm

elm-dev:
	elm make --output "$(JS)/main.elm.js" ./src/Main.elm 

elm-prod:
	elm make  ./src/main.elm --optimize --output "$(JS)/main.elm.js"

all: go-wasm elm-prod