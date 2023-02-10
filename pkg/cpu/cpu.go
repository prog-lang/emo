package cpu

import (
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"log"
)

type CPU struct {
	r   [10]int32 // 10 registers
	mem [1e6]byte // 1MB of memory
	ok  bool      // Health status flag
	ir  operation // Instruction register
}

func New() *CPU {
	return new(CPU).Init()
}

func (cpu *CPU) Init() *CPU {
	cpu.ok = true
	return cpu
}

func (cpu *CPU) String() string {
	return fmt.Sprintf("OK: %v", cpu.ok)
}

func (cpu *CPU) ExecuteHexInstruction(raw string) {
	log.Println("received instruction:", raw)

	bytes, err := hex.DecodeString(raw)
	if err != nil {
		log.Println(err)
		return
	}

	if length := len(bytes); length != 8 {
		log.Printf("instruction must be 8 bytes long; got: %d", length)
		return
	}

	cpu.Decode(instructionByteArray(bytes))
	cpu.Execute()
}

func (cpu *CPU) Decode(bin [8]uint8) {
	opcode := binary.BigEndian.Uint32(bin[:4])
	operand := [4]uint8{bin[4], bin[5], bin[6], bin[7]}
	cpu.ir = decodeOperation(opcode, operand)
}

func (cpu *CPU) Execute() {
	cpu.ir(cpu)
}
