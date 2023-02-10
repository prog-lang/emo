package cpu

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
