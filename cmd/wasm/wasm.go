package main

import (
	"log"
	"reflect"
	"runtime/debug"
	"syscall/js"

	"github.com/iancoleman/strcase"
)

type javaScriptObjectBuilder struct {
	object  any
	methods map[string]any
}

func ObjectOf(object any) js.Value {
	return new(javaScriptObjectBuilder).
		init(object).
		populateMethods().
		value()
}

func (b *javaScriptObjectBuilder) init(object any) *javaScriptObjectBuilder {
	b.object = object
	b.methods = make(map[string]any)
	return b
}

func (b *javaScriptObjectBuilder) populateMethods() *javaScriptObjectBuilder {
	value := reflect.ValueOf(b.object)
	type_ := reflect.TypeOf(b.object)
	for i := 0; i < value.NumMethod(); i++ {
		if methodInfo := type_.Method(i); methodInfo.IsExported() {
			methodName := strcase.ToLowerCamel(methodInfo.Name)
			methodFunc := value.Method(i)
			b.methods[methodName] = b.function(methodFunc)
		}
	}
	return b
}

func (b *javaScriptObjectBuilder) value() js.Value {
	return js.ValueOf(b.methods)
}

func (b *javaScriptObjectBuilder) function(fn reflect.Value) js.Func {
	return js.FuncOf(func(_ js.Value, args []js.Value) any {
		defer recovery()
		returnValues := fn.Call(mapArgs(args))
		if len(returnValues) == 0 {
			return nil
		}
		return js.ValueOf(returnValues[0].Interface())
	})
}

func mapArgs(jsArgs []js.Value) (args []reflect.Value) {
	args = make([]reflect.Value, len(jsArgs))
	for i, jsArg := range jsArgs {
		switch jsArg.Type() {
		case js.TypeUndefined, js.TypeNull:
			args[i] = reflect.ValueOf(nil)
		case js.TypeBoolean:
			args[i] = reflect.ValueOf(jsArg.Bool())
		case js.TypeNumber:
			args[i] = reflect.ValueOf(jsArg.Float())
		case js.TypeString:
			args[i] = reflect.ValueOf(jsArg.String())
		}
	}
	return
}

func recovery() {
	if err := recover(); err != nil {
		log.Printf("panic in function call to WASM: %v\n%s",
			err,
			debug.Stack(),
		)
	}
}
