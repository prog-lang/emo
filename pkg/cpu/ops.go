package cpu

import "log"

// Length here is specified in bytes.
const (
	InstructionLength = 5
	OpcodeLength      = 1
	OperandLength     = InstructionLength - OpcodeLength
)

type (
	instruction = func(operand [OperandLength]uint8) operation
	operation   = func(*CPU)
)

func decode(index uint8, operand [OperandLength]uint8) operation {
	if int(index) >= len(instructionSet) {
		log.Printf("failed to get instruction at index %d", index)
		return HALT(operand)
	}
	return instructionSet[index](operand)
}
