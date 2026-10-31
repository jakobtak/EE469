`timescale 1ns/10ps

// Share 64 full adders for addition and subtraction.
// sub = 0 keeps B and starts with carry 0 to compute A + B.
// sub = 1 inverts B and starts with carry 1 to compute A + ~B + 1 = A - B.
// Each bit passes its carry to the next bit; the final carry becomes carry_out.
// XOR the carries entering and leaving the sign bit to detect signed overflow.
module add_sub (sum, carry_out, overflow, A, B, sub);
    output wire [63:0] sum;
    output wire carry_out, overflow;
    input logic [63:0] A, B;
    input logic sub;

    wire [63:0] b_add;
    wire [64:0] carry;

    xor #50 invert_b [63:0] (b_add, B, {64{sub}});
    assign carry[0] = sub;

    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : add_bits
            full_adder fa (sum[i], carry[i+1], A[i], b_add[i], carry[i]);
        end
    endgenerate

    assign carry_out = carry[64];
    xor #50 ov (overflow, carry[63], carry[64]);
endmodule
