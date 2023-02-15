package cpu

//go:generate emo-gen-instruction-set ./instructions.go ./instruction_set.go

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
