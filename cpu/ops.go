package cpu

import "log"

// Length here is specified in bytes.
const (
	InstructionLength = 8
	OpcodeLength      = InstructionLength / 2
	OperandLength     = InstructionLength / 2
)

var instructionSet = [2]instruction{
	HALT,
	NOP,
}

type operation = func(*CPU)
type instruction = func(operand [OperandLength]uint8) operation

// It is guaranteed by the caller that slice contains at least 8 entries.
func instructionByteArray(slice []uint8) (array [InstructionLength]uint8) {
	for i := 0; i < InstructionLength; i++ {
		array[i] = slice[i]
	}
	return
}

func decodeOperation(index uint32, operand [OperandLength]uint8) operation {
	if int(index) >= len(instructionSet) {
		log.Printf("failed to get instruction at index %d", index)
		return HALT(operand)
	}
	return instructionSet[index](operand)
}

/*
 * INSTRUCTIONS
 */

func HALT(_ [OperandLength]uint8) operation {
	return func(cpu *CPU) {
		cpu.ok = false
	}
}

func NOP(_ [OperandLength]uint8) operation {
	return func(cpu *CPU) {
		/* DO NOTHING */
	}
}
