package cpu

import (
	"encoding/hex"
	"fmt"
	"log"
)

const (
	MemorySizeBytes     int = 1e6
	MaxProgramSizeBytes int = 1e5
)

type CPU struct {
	mem [MemorySizeBytes]byte // 1MB of memory

	ok  bool      // Health status flag
	pc  int       // Program counter
	ocr byte      // Opcode register
	ir  operation // Instruction register
}

func New() (cpu *CPU) {
	cpu = new(CPU)
	cpu.Init()
	return
}

func (cpu *CPU) Init() {
	cpu.ok = true
}

func (cpu *CPU) String() string {
	return fmt.Sprintf("OK: %v", cpu.ok)
}

func (cpu *CPU) LoadProgramHex(raw string) {
	bytes, err := hex.DecodeString(raw)
	if err != nil {
		log.Println(err)
		return
	}

	length := len(bytes)
	if length%InstructionLength != 0 {
		log.Printf(
			"code byte length (%d) is not divisible by instruction length (%d)",
			length, InstructionLength,
		)
		return
	}
	if length > MaxProgramSizeBytes {
		log.Printf(
			"code byte length (%d) is longer than max program length (%d)",
			length, MaxProgramSizeBytes,
		)
		return
	}

	cpu.writeProgramToMemory(bytes)
}

func (cpu *CPU) Start() {
	for cpu.ok {
		cpu.fetch()
		cpu.decode()
		cpu.execute()
	}
}

func (cpu *CPU) fetch() {
	cpu.ocr = cpu.mem[cpu.pc]
	cpu.pc++
}

func (cpu *CPU) decode() {
	var operand [4]uint8
	for i := range operand {
		operand[i] = cpu.mem[cpu.pc]
		cpu.pc++
	}
	cpu.ir = decodeOperation(cpu.ocr, operand)
}

func (cpu *CPU) execute() {
	cpu.ir(cpu)
}

func (cpu *CPU) writeProgramToMemory(bytes []uint8) {
	cpu.pc = len(cpu.mem) - len(bytes)
	for i, b := range bytes {
		cpu.mem[cpu.pc+i] = b
	}
}
