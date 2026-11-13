// Test bench for the single-cycle CPU
`timescale 1ns/10ps

// This resets the CPU, then runs the program chosen in instructmem.sv.
// Every benchmark ends with a branch to itself, so the test stops a few
// cycles after PC stops changing and prints the registers and memory.
// Compare the printed values with the expected results in the benchmark file.
module cpustim();

	// The slowest path (register read, 64-bit ripple add, write back) takes
	// 7.5 ns (see cpu.sv), so one 100 ns cycle leaves plenty of time to settle.
	parameter ClockDelay = 100;
	parameter MaxCycles = 2000;

	logic clk, reset;

	cpu dut (.clk, .reset);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	integer i, cycles, halted;
	logic [63:0] last_PC;

	initial begin
		reset <= 1;
		@(posedge clk);
		@(posedge clk);
		reset <= 0;

		// Run until PC stays the same for three cycles in a row.
		cycles = 0;
		halted = 0;
		while (halted < 3 && cycles < MaxCycles) begin
			last_PC = dut.PC;
			@(posedge clk);
			#1;
			cycles++;
			if (dut.PC === last_PC)
				halted++;
			else
				halted = 0;
		end

		if (cycles >= MaxCycles)
			$display("%t Stopped: reached MaxCycles before the program halted.", $time);
		$display("%t Halted at PC = %0d after %0d cycles", $time, dut.PC, cycles);
		$display("Flags: negative = %b, zero = %b, overflow = %b, carry-out = %b",
			dut.flag_negative, dut.flag_zero, dut.flag_overflow, dut.flag_carry_out);

		// Registers that were never written still show x.
		for (i = 0; i < 32; i++)
			$display("X%0d = %0d (0x%h)", i,
				$signed(dut.regs.data_out[i]), dut.regs.data_out[i]);

		// Print each 8-byte word of data memory that has been written.
		for (i = 0; i < 1024; i = i + 8)
			if (dut.dmem.mem[i] !== 8'bx)
				$display("Mem[%0d] = %0d", i, $signed({
					dut.dmem.mem[i+7], dut.dmem.mem[i+6], dut.dmem.mem[i+5], dut.dmem.mem[i+4],
					dut.dmem.mem[i+3], dut.dmem.mem[i+2], dut.dmem.mem[i+1], dut.dmem.mem[i]}));
		$stop;
	end
endmodule
