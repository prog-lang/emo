package main

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"log"
	"os"
	"strings"
)

const template = `package cpu

var instructionSet = [%d]instruction{%s
}
`

var (
	instructionsFileName   = os.Args[1]
	instructionSetFileName = os.Args[2]
)

func parseInstructionNamesFromFile(name string) (names []string) {
	file, err := parser.ParseFile(
		token.NewFileSet(),
		name,
		nil,
		parser.AllErrors,
	)
	if err != nil {
		log.Fatal(err)
	}
	for _, decl := range file.Decls {
		switch x := decl.(type) {
		case *ast.FuncDecl:
			if x.Name.IsExported() {
				names = append(names, x.Name.Name)
			}
		}
	}
	return
}

func writeInstructionSetFile(name string, names []string) {
	file, err := os.Create(instructionSetFileName)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
	fmt.Fprint(file, generateInstructionSet(names))
}

func generateInstructionSet(names []string) string {
	return fmt.Sprintf(template, len(names), instructionNamesToList(names))
}

func instructionNamesToList(names []string) string {
	var buf strings.Builder
	for _, name := range names {
		buf.WriteString("\n\t" + name + ",")
	}
	return buf.String()
}

func main() {
	writeInstructionSetFile(
		instructionSetFileName,
		parseInstructionNamesFromFile(instructionsFileName),
	)
}
