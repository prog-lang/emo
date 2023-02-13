package cpu

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCPU(t *testing.T) {
	cpu := New()
	cpu.LoadProgramHex("0100000000010000000001000000000000000000")

	cpu.fetch()
	assert.True(t, cpu.ocr == 1)
	cpu.decode()
	assert.True(t, cpu.ir != nil)
	cpu.execute()

	cpu.Start()
	assert.Equal(t, MemorySizeBytes, cpu.pc)
}
