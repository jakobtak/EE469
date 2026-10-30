`timescale 1ps/1ps

// Add a, b, and carry_in to produce {carry_out, sum}.
// XOR the three inputs to get sum. Generate a carry when a and b are both 1,
// or pass carry_in onward when exactly one of a and b is 1.
// OR these two carry conditions to get carry_out.
module full_adder (sum, carry_out, a, b, carry_in);
    output wire sum, carry_out;
    input logic a, b, carry_in;

    wire a_xor_b, ab, carry_ab;

    xor #50 x1 (a_xor_b, a, b);
    xor #50 x2 (sum, a_xor_b, carry_in);
    and #50 a1 (ab, a, b);
    and #50 a2 (carry_ab, a_xor_b, carry_in);
    or #50 o1 (carry_out, ab, carry_ab);
endmodule
