`timescale 1ns/10ps

// This puts four 3-to-8 decoders together to handle all 32 register addresses.
// The top two address bits pick a group of eight, and the bottom three pick a register in it.
// Using the smaller decoder keeps the same address logic from being written over and over.
//
// Delay (50 ps per gate):
//   Write_Register[4:3] -> Register : BUF/NOT + AND + AND (in decoder_3by8) = 150 ps
//   Write_Register[2:0] -> Register : BUF + decoder_3by8 (100 ps) = 150 ps
//   RegWrite            -> Register : BUF + AND + AND (in decoder_3by8) = 150 ps
module decoder_5by32 (Register, Write_Register, RegWrite);
    output logic [31:0] Register; // One bit for each register enable.
    input logic [4:0] Write_Register;
    input logic RegWrite;

    wire nA, nB;
    wire d1, d2, d3, d4;
    wire [4:0] buffered;
    wire rw_buffered;

    // Hazard fix: add bypass gates to match the NOT delay on the address bits and RegWrite.
    // Every input now takes 50ps to reach the group AND gates, so d1-d4 change at 100ps.
    // The bottom three bits also reach 100ps inside decoder_3by8 (this buffer plus its own
    // buffer or NOT), so the group enable and the address arrive at the last AND together.
    // Before this, the enables of several registers could be 1 at once for a short time.
    buf #(50ps) buffer [4:0] (buffered, Write_Register);
    buf #(50ps) rw_buffer (rw_buffered, RegWrite);
    not #(50ps) na (nA, Write_Register[4]);
    not #(50ps) nb (nB, Write_Register[3]);

    // Bits [4:3] choose which of d1 through d4 is turned on.
    // If RegWrite is 0, all four groups stay off, so no register gets written.
    and #(50ps) D1 (d1, nA, nB, rw_buffered);
    and #(50ps) D2 (d2, nA, buffered[3], rw_buffered);
    and #(50ps) D3 (d3, buffered[4], nB, rw_buffered);
    and #(50ps) D4 (d4, buffered[4], buffered[3], rw_buffered);

    // All four decoders get the same bottom three address bits, but only one group is enabled.
    // Their outputs cover registers 0-7, 8-15, 16-23, and 24-31.
    decoder_3by8 V1 (Register[7:0], buffered[2:0], d1);
    decoder_3by8 V2 (Register[15:8], buffered[2:0], d2);
    decoder_3by8 V3 (Register[23:16], buffered[2:0], d3);
    decoder_3by8 V4 (Register[31:24], buffered[2:0], d4);
endmodule

// This goes through all 32 addresses with writing off, then repeats with writing on.
// The waveforms should show only the selected bit as 1, even when moving to the next group.
// Each address stays in place for 1000 time units so the gates have time to update.
module decoder_5by32_testbench;
    logic [31:0] Register;
    logic [4:0] Write_Register;
    logic RegWrite;

    decoder_5by32 dut (.RegWrite, .Write_Register, .Register);

    integer i;
    integer k;

    initial begin
        for (k = 0; k < 2; k++) begin
            for (i = 0; i < 32; i++) begin
                RegWrite = k;
                Write_Register = i;
                #1000; // Wait for the gates to update.
            end
        end
    end
endmodule
