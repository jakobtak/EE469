`timescale 1ns/10ps

// This picks one of two values. sel = 0 gives in0, and sel = 1 gives in1.
// WIDTH sets how many bits each value has, so the same module works for
// 64-bit data and 5-bit register numbers.
//
// Delay (50 ps per gate):
//   sel        -> out : BUF/NOT + AND + OR = 150 ps
//   in0 or in1 -> out : AND + OR = 100 ps
module mux_2by1 #(parameter WIDTH = 64) (out, in0, in1, sel);
    output wire [WIDTH-1:0] out;
    input logic [WIDTH-1:0] in0, in1;
    input logic sel;

    wire sel_buffered, sel_inverted;
    wire [WIDTH-1:0] keep0, keep1;

    // Add a bypass gate to match the NOT delay, so both AND groups switch together.
    buf #(50ps) b (sel_buffered, sel);
    not #(50ps) n (sel_inverted, sel);

    // The AND gates keep the chosen value and turn the other one into zeros.
    and #(50ps) a0 [WIDTH-1:0] (keep0, in0, {WIDTH{sel_inverted}});
    and #(50ps) a1 [WIDTH-1:0] (keep1, in1, {WIDTH{sel_buffered}});
    or #(50ps) o [WIDTH-1:0] (out, keep0, keep1);
endmodule

// This tries both select values with a few input pairs.
// In the waveforms, out should match in0 when sel is 0 and in1 when sel is 1.
// The last step uses all ones on both inputs, so out should not drop when sel changes.
module mux_2by1_testbench;
    logic [63:0] out, in0, in1;
    logic sel;

    mux_2by1 dut (.in0, .in1, .sel, .out);

    integer i;

    initial begin
        for (i = 0; i < 8; i++) begin
            in0 = i;      // Small values make the chosen input easy to see.
            in1 = i + 100;
            sel = 0;
            #1000;
            sel = 1;
            #1000; // Wait for the gates to update.
        end

        in0 = '1;
        in1 = '1;
        sel = 0;
        #1000;
        sel = 1;
        #1000;
    end
endmodule
