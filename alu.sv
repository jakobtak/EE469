`timescale 1ns/10ps

// 64-bit ALU: pass B, add, subtract, AND, OR, and XOR.
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
    input logic [63:0] A, B;
    input logic [2:0] cntrl;
    output wire [63:0] result;
    output wire negative, zero, overflow, carry_out;

    wire [63:0] sum, and_out, or_out, xor_out;
    wire carry_raw, overflow_raw;
    wire [7:0][63:0] data_out;

    // ADD / SUBTRACT ====================================
    // Control 010 selects A + B; 011 selects A - B.
    // cntrl[0] chooses the mode of the shared adder. Its raw flags are
    // enabled below only when the selected operation is ADD or SUBTRACT.
    add_sub add_sub_op (sum, carry_raw, overflow_raw, A, B, cntrl[0]);

    // AND ====================================
    // Control 100: each output bit is 1 when both corresponding input bits are 1.
    and #50 bit_and [63:0] (and_out, A, B);

    // OR ====================================
    // Control 101: each output bit is 1 when either corresponding input bit is 1.
    or #50 bit_or [63:0] (or_out, A, B);

    // XOR ====================================
    // Control 110: each output bit is 1 when the corresponding input bits differ.
    xor #50 bit_xor [63:0] (xor_out, A, B);

    // PASS B ====================================
    // Control 000: connect B directly to the first MUX input so it can be
    // selected unchanged, regardless of the value of A.
    assign data_out[0] = B;

    // RESULT SELECTION ====================================
    // The operations above compute concurrently. cntrl selects which result
    // reaches the output by choosing the matching index in data_out.
    // ADD and SUBTRACT share sum because cntrl[0] already sets the adder mode.
    assign data_out[1] = 64'b0; // Unused control code 001.
    assign data_out[2] = sum;
    assign data_out[3] = sum;
    assign data_out[4] = and_out;
    assign data_out[5] = or_out;
    assign data_out[6] = xor_out;
    assign data_out[7] = 64'b0; // Unused control code 111.

    mux_8by1 result_mux (result, cntrl, data_out, 1'b1);

    // NEGATIVE ====================================
    // Bit 63 is the sign bit of a 64-bit two's-complement value.
    // A sign bit of 1 means the selected result is negative.
    assign negative = result[63];

    // ZERO ====================================
    // First OR the 64 result bits into 16 groups, then OR those into 4 blocks.
    // The final NOR is 1 only when every block is 0, meaning result is zero.
    // This tree keeps every gate within the limit of four inputs.
    wire [15:0] zero_group;
    wire [3:0] zero_block;
    genvar i;
    generate
        for (i = 0; i < 16; i++) begin : zero_groups
            or #50 g (zero_group[i], result[4*i], result[4*i+1],
                      result[4*i+2], result[4*i+3]);
        end
        for (i = 0; i < 4; i++) begin : zero_blocks
            or #50 g (zero_block[i], zero_group[4*i], zero_group[4*i+1],
                      zero_group[4*i+2], zero_group[4*i+3]);
        end
    endgenerate
    nor #50 zero_gate (zero, zero_block[0], zero_block[1], zero_block[2], zero_block[3]);

    // ARITHMETIC FLAG ENABLE ====================================
    // Only control codes 010 and 011 have cntrl[2] = 0 and cntrl[1] = 1.
    // Detect these codes to enable the adder flags for ADD/SUB and make
    // overflow and carry_out zero for the other operations.
    wire not_cntrl2, arithmetic;
    not #50 n2 (not_cntrl2, cntrl[2]);
    and #50 arith (arithmetic, not_cntrl2, cntrl[1]);

    // OVERFLOW ====================================
    // Use the adder's signed-overflow result when ADD or SUBTRACT is selected.
    and #50 overflow_gate (overflow, overflow_raw, arithmetic);

    // CARRY OUT ====================================
    // Use the carry leaving bit 63 when ADD or SUBTRACT is selected.
    // Subtraction computes A + ~B + 1, so carry_out = 1 means no borrow.
    and #50 carry_gate (carry_out, carry_raw, arithmetic);
endmodule // alu


module alu_testbench;
	logic [63:0] result;
	logic negative, zero, overflow, carry_out;
	logic [63:0] A, B;
	logic [2:0] cntrl;
	logic [64:0] sum;
	logic carry_r, overflow_r;
	
	alu dut (A, B, cntrl, result, negative, zero, overflow, carry_out);
	
	parameter delay = 100000;
	
	integer i;
	initial begin
		$display("%t testing PASS_B operations", $time);
		cntrl[2] = 0;
		cntrl[1] = 0;
		cntrl[0] = 0;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			#(delay);
			if (result == B && negative == B[63] && zero == (B == '0))
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_ADD operations", $time);
		cntrl[2] = 0;
		cntrl[1] = 1;
		cntrl[0] = 0;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			sum = {1'b0, A} + {1'b0, B};
			overflow_r = (A[63] == B[63]) && (sum[63] != A[63]);
			#(delay);
			if (result == (A + B) && negative == result[63] && zero == (result == '0) && carry_out == sum[64] && overflow == overflow_r)
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_SUBTRACT operations", $time);
		cntrl[2] = 0;
		cntrl[1] = 1;
		cntrl[0] = 1;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			sum = {1'b0, A} + {1'b0, ~B} + 65'd1;
			overflow_r = (A[63] != B[63]) && (sum[63] != A[63]);
			#(delay);
			if (result == (A - B) && negative == result[63] && zero == (result == '0) && carry_out == sum[64] && overflow == overflow_r)
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_AND operations", $time);
		cntrl[2] = 1;
		cntrl[1] = 0;
		cntrl[0] = 0;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			#(delay);
			if (result == (A & B) && negative == result[63] && zero == (result == '0))
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_OR operations", $time);
		cntrl[2] = 1;
		cntrl[1] = 0;
		cntrl[0] = 1;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			#(delay);
			if (result == (A | B) && negative == result[63] && zero == (result == '0))
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_OR operations", $time);
		cntrl[2] = 1;
		cntrl[1] = 1;
		cntrl[0] = 0;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			#(delay);
			if (result == (A ^ B) && negative == result[63] && zero == (result == '0))
				$display("Pass");
			else
				$display("Fail");
		end
	end
endmodule // alu_testbench