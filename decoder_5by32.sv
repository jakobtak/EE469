`timescale 1ns/10ps

// This puts four 3-to-8 decoders together to handle all 32 register addresses.
// The top two address bits pick a group of eight, and the bottom three pick a register in it.
// Using the smaller decoder keeps the same address logic from being written over and over.
module decoder_5by32 (Register, Write_Register, RegWrite);
    output logic [31:0] Register; // One bit for each register enable.
    input logic [4:0] Write_Register;
    input logic RegWrite;

    wire nA, nB;
    wire d1, d2, d3, d4;

    not #(50ps) na (nA, Write_Register[4]);
    not #(50ps) nb (nB, Write_Register[3]);

    // Bits [4:3] choose which of d1 through d4 is turned on.
    // If RegWrite is 0, all four groups stay off, so no register gets written.
    and #(50ps) D1 (d1, nA, nB, RegWrite);
    and #(50ps) D2 (d2, nA, Write_Register[3], RegWrite);
    and #(50ps) D3 (d3, Write_Register[4], nB, RegWrite);
    and #(50ps) D4 (d4, Write_Register[4], Write_Register[3], RegWrite);

    // All four decoders get the same bottom three address bits, but only one group is enabled.
    // Their outputs cover registers 0-7, 8-15, 16-23, and 24-31.
    decoder_3by8 V1 (Register[7:0], Write_Register[2:0], d1);
    decoder_3by8 V2 (Register[15:8], Write_Register[2:0], d2);
    decoder_3by8 V3 (Register[23:16], Write_Register[2:0], d3);
    decoder_3by8 V4 (Register[31:24], Write_Register[2:0], d4);
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
