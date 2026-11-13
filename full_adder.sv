`timescale 1ns/10ps

// Add a, b, and carry_in to produce {carry_out, sum}.
// XOR the three inputs to get sum. carry_out is 1 when at least two inputs are 1,
// so AND each pair of inputs and OR the three results.
//
// Hazard fix: carry_out used to be (a AND b) OR ((a XOR b) AND carry_in).
// When all inputs were 1 and a or b dropped to 0, the first term turned off after 50ps
// but the second needed 100ps to turn on, so carry_out fell to 0 for 50ps.
// With one AND per pair, a single input change always leaves one term at 1.
//
// Delay (50 ps per gate):
//   a or b   -> sum       : XOR + XOR = 100 ps
//   carry_in -> sum       : XOR = 50 ps
//   any      -> carry_out : AND + OR = 100 ps
module full_adder (sum, carry_out, a, b, carry_in);
    output wire sum, carry_out;
    input logic a, b, carry_in;

    wire a_xor_b, ab, a_cin, b_cin;

    xor #(50ps) x1 (a_xor_b, a, b);
    xor #(50ps) x2 (sum, a_xor_b, carry_in);
    and #(50ps) a1 (ab, a, b);
    and #(50ps) a2 (a_cin, a, carry_in);
    and #(50ps) a3 (b_cin, b, carry_in);
    or #(50ps) o1 (carry_out, ab, a_cin, b_cin);
endmodule
