`timescale 1ns/10ps

// This picks one of eight 64-bit values using ReadRegister.
// When muxx is 0, the output becomes zero after the gates have time to update.
// The larger 32-to-1 mux uses four copies of this module to cover all 32 registers.
//
// Delay (50 ps per gate):
//   ReadRegister -> ReadData : BUF/NOT + AND + AND + OR + OR = 250 ps
//   muxx         -> ReadData : AND + AND + OR + OR = 200 ps
//   data_out     -> ReadData : AND + OR + OR = 150 ps
module mux_8by1 (ReadData, ReadRegister, data_out, muxx);
    output logic [63:0] ReadData;
    input logic [2:0] ReadRegister;
    input logic [7:0][63:0] data_out;
    input logic muxx; // Turns this group on or off.

    wire sel2, sel1, sel0, out0, out1, out2, out3, out4, out5, out6, out7;
    wire [2:0] buffered;
    wire [63:0] o0, o1, o2, o3, o4, o5, o6, o7, OR1, OR2, ORFINAL;

    // add by pass gate to match the NOT delay on each non-inverted address bit.
    buf #(50ps) buffer [2:0] (buffered, ReadRegister);
    not #(50ps) Sel2 (sel2, ReadRegister[2]);
    not #(50ps) Sel1 (sel1, ReadRegister[1]);
    not #(50ps) Sel0 (sel0, ReadRegister[0]);

    // These AND gates work out which input matches ReadRegister.
    // Putting muxx in every gate lets the larger mux turn this whole group on or off.
    and #(50ps) Out0 (out0, sel2, sel1, sel0, muxx);
    and #(50ps) Out1 (out1, sel2, sel1, buffered[0], muxx);
    and #(50ps) Out2 (out2, sel2, buffered[1], sel0, muxx);
    and #(50ps) Out3 (out3, sel2, buffered[1], buffered[0], muxx);
    and #(50ps) Out4 (out4, buffered[2], sel1, sel0, muxx);
    and #(50ps) Out5 (out5, buffered[2], sel1, buffered[0], muxx);
    and #(50ps) Out6 (out6, buffered[2], buffered[1], sel0, muxx);
    and #(50ps) Out7 (out7, buffered[2], buffered[1], buffered[0], muxx);

    // Repeating each select bit 64 times lets it control the whole input value.
    // The AND gates keep the chosen value and turn the other values into zeros.
    and #(50ps) O0 [63:0] (o0, {64{out0}}, data_out[0]);
    and #(50ps) O1 [63:0] (o1, {64{out1}}, data_out[1]);
    and #(50ps) O2 [63:0] (o2, {64{out2}}, data_out[2]);
    and #(50ps) O3 [63:0] (o3, {64{out3}}, data_out[3]);
    and #(50ps) O4 [63:0] (o4, {64{out4}}, data_out[4]);
    and #(50ps) O5 [63:0] (o5, {64{out5}}, data_out[5]);
    and #(50ps) O6 [63:0] (o6, {64{out6}}, data_out[6]);
    and #(50ps) O7 [63:0] (o7, {64{out7}}, data_out[7]);

    // The first two OR gates combine four values each, and the last one combines those results.
    // Once the gates settle, only the chosen input adds anything to the output.
    or #(50ps) or1 [63:0] (OR1, o0, o1, o2, o3);
    or #(50ps) or2 [63:0] (OR2, o4, o5, o6, o7);
    or #(50ps) orfinal [63:0] (ORFINAL, OR1, OR2);

    assign ReadData[63:0] = ORFINAL;
endmodule

// This gives each input its index as a value and tries the addresses with muxx off and on.
// The idea is to look for zero when muxx is off and the selected value when it is on.
// The results need to be checked in the waveforms; the test does not report pass or fail.
module mux_8by1_testbench;
    logic [63:0] ReadData;
    logic [2:0] ReadRegister;
    logic [7:0][63:0] data_out;
    logic muxx;

    mux_8by1 dut (.ReadRegister, .data_out, .muxx, .ReadData);

    integer i;
    integer k;

    // There are no waits inside these loops, so all inputs change at the same simulation time.
    // That means the waveform cannot show a settled result for each address separately here.
    initial begin
        for (i = 0; i < 2; i++) begin
            muxx = i;

            for (k = 0; k < 8; k++) begin
                data_out[k] = k; // Store the address as the test value.
            end

            for (k = 0; k < 8; k++) begin
                ReadRegister = k;
            end
        end
    end
endmodule
