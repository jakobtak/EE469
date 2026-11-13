`timescale 1ns/10ps

// This uses a three-bit address to choose which of eight registers can be written.
// If RegWrite is 0, none of the registers are selected.
// The larger decoder uses four copies of this module, one for each group of eight.
//
// Delay (50 ps per gate):
//   Write_Register -> Register : BUF/NOT + AND = 100 ps
//   RegWrite       -> Register : AND = 50 ps
module decoder_3by8 (Register, Write_Register, RegWrite);
    output logic [7:0] Register; // One bit for each register enable.
    input logic [2:0] Write_Register;
    input logic RegWrite;

    wire R0, R1, R2, R3, R4, R5, R6, R7;
    wire nC, nD, nE;
    wire [2:0] buffered;

    // Hazard fix: add bypass gates to match the NOT delay on each non-inverted address bit.
    // Without them, a rising address bit reached the AND gates 50ps before its inverted
    // copy, so the old and new outputs (and sometimes a third one) were 1 at the same time.
    // RegWrite is not buffered here; decoder_5by32 times it to arrive with these signals.
    buf #(50ps) buffer [2:0] (buffered, Write_Register);
    not #(50ps) nc (nC, Write_Register[2]);
    not #(50ps) nd (nD, Write_Register[1]);
    not #(50ps) ne (nE, Write_Register[0]);

    // Each AND gate checks for one address using the input bits and their opposites.
    // After the gates settle, only the matching output is 1 when RegWrite is also 1.
    and #(50ps) r0 (R0, nC, nD, nE, RegWrite);
    and #(50ps) r1 (R1, nC, nD, buffered[0], RegWrite);
    and #(50ps) r2 (R2, nC, buffered[1], nE, RegWrite);
    and #(50ps) r3 (R3, nC, buffered[1], buffered[0], RegWrite);
    and #(50ps) r4 (R4, buffered[2], nD, nE, RegWrite);
    and #(50ps) r5 (R5, buffered[2], nD, buffered[0], RegWrite);
    and #(50ps) r6 (R6, buffered[2], buffered[1], nE, RegWrite);
    and #(50ps) r7 (R7, buffered[2], buffered[1], buffered[0], RegWrite);

    assign Register[0] = R0;
    assign Register[1] = R1;
    assign Register[2] = R2;
    assign Register[3] = R3;
    assign Register[4] = R4;
    assign Register[5] = R5;
    assign Register[6] = R6;
    assign Register[7] = R7;
endmodule

// This tries all eight addresses with writing turned off, then tries them again with it on.
// In the waveforms, Register should be all zeros when writing is off.
// When writing is on, only the selected bit should be 1 after the gates have had time to update.
module decoder_3by8_testbench;
    logic [7:0] Register;
    logic [2:0] Write_Register;
    logic RegWrite;

    decoder_3by8 dut (.RegWrite, .Write_Register, .Register);

    integer i;
    integer k;

    initial begin
        for (k = 0; k < 2; k++) begin
            for (i = 0; i < 8; i++) begin
                RegWrite = k;
                #150;
                {Write_Register[2], Write_Register[1], Write_Register[0]} = i;
                #150; // Wait for the gates to update.
            end
        end
    end
endmodule
