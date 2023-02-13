package cpu

import "log"

//go:generate emo-gen-instruction-set ./instructions.go ./instruction_set.go

// Length here is specified in bytes.
const (
	InstructionLength = 5
	OpcodeLength      = 1
	OperandLength     = InstructionLength - OpcodeLength
)

type operation = func(*CPU)
type instruction = func(operand [OperandLength]uint8) operation

// It is guaranteed by the caller that slice contains at least 8 entries.
func instructionByteArray(slice []uint8) (array [InstructionLength]uint8) {
	for i := 0; i < InstructionLength; i++ {
		array[i] = slice[i]
	}
	return
}

func decodeOperation(index uint8, operand [OperandLength]uint8) operation {
	if int(index) >= len(instructionSet) {
		log.Printf("failed to get instruction at index %d", index)
		return HALT(operand)
	}
	return instructionSet[index](operand)
}
