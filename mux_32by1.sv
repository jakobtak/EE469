`timescale 1ns/10ps

// This uses four mux_8by1 modules to choose one of the 32 register values.
// ReadRegister[4:3] picks a group of eight, and ReadRegister[2:0] picks a value inside it.
// Splitting it up this way lets the larger mux reuse the smaller one.
//
// Delay (50 ps per gate):
//   ReadRegister[2:0] -> ReadData : BUF + mux_8by1 select (250 ps) + OR = 350 ps
//   ReadRegister[4:3] -> ReadData : BUF/NOT + AND + mux_8by1 muxx (200 ps) + OR = 350 ps
//   data_out          -> ReadData : mux_8by1 data (150 ps) + OR = 200 ps
module mux_32by1 (ReadData, ReadRegister, data_out);
    output wire [63:0] ReadData;
    input logic [4:0] ReadRegister;
    input logic [31:0][63:0] data_out; // 32 words, 64 bits each.

    wire inverted4, inverted3, mux1, mux2, mux3, mux4;
    wire [4:0] buffered;
    logic [63:0] y1, y2, y3, y4;

    // add by pass gate to match the NOT delay on each non-inverted address bit.
    buf #(50ps) buffer [4:0] (buffered, ReadRegister);
    not #(50ps) Inverted4 (inverted4, ReadRegister[4]);
    not #(50ps) Inverted3 (inverted3, ReadRegister[3]);

    // The top two address bits turn on one of the four groups.
    // After the gates settle, only that group is allowed to send out data.
    and #(50ps) mux_1 (mux1, inverted4, inverted3);
    and #(50ps) mux_2 (mux2, inverted4, buffered[3]);
    and #(50ps) mux_3 (mux3, buffered[4], inverted3);
    and #(50ps) mux_4 (mux4, buffered[4], buffered[3]);

    // Each small mux looks at the same position in a different group of eight values.
    // Only the enabled group passes its value through; the other groups send out zero.
    mux_8by1 m1 (y1, buffered[2:0], data_out[7:0], mux1);
    mux_8by1 m2 (y2, buffered[2:0], data_out[15:8], mux2);
    mux_8by1 m3 (y3, buffered[2:0], data_out[23:16], mux3);
    mux_8by1 m4 (y4, buffered[2:0], data_out[31:24], mux4);

    // The OR gates put the four outputs together, one bit at a time.
    // Since the other groups send out zero, the result is just the value from the selected group.
    or #(50ps) orout [63:0] (ReadData, y1, y2, y3, y4);
endmodule

// This gives each input its address as a value, then reads all 32 addresses.
// After each wait, ReadData should match the address shown in the waveform.
// Moving from 7 to 8, 15 to 16, and 23 to 24 also checks the switch between groups.
module mux_32by1_testbench;
    logic [63:0] ReadData;
    logic [4:0] ReadRegister;
    logic [31:0][63:0] data_out;

    mux_32by1 dut (.ReadRegister, .data_out, .ReadData);

    integer k;

    initial begin
        for (k = 0; k < 32; k++) begin
            data_out[k] = k; // Store the address as the test value.
        end

        for (k = 0; k < 32; k++) begin
            ReadRegister = k;
            #1000;
        end
    end
endmodule
