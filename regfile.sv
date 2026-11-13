`timescale 1ns/10ps

// This holds 32 register values, with 64 bits in each one.
// The decoder picks where to write, and the two read muxes pick which values to read.
// Register 31 always reads as zero, so only the other 31 registers need storage.
//
// Delay (50 ps per gate):
//   Read:  ReadRegister -> ReadData : mux_64by32by1 select = 350 ps
//          saved value  -> ReadData : mux_64by32by1 data = 200 ps
//   Write: WriteRegister or RegWrite -> D_FF input : decoder (150 ps) + Enable (150 ps) = 300 ps
//          WriteData                 -> D_FF input : Enable = 150 ps
//   The write inputs must settle this long before the rising clock edge.
module regfile (
    ReadData1, ReadData2, WriteData,
    ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk
);
    output logic [63:0] ReadData1, ReadData2;
    input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    input logic [63:0] WriteData;
    input logic RegWrite, clk;

    // There is no reset input here, so registers 0-30 get their starting values when written.
    logic reset;
    assign reset = 0; // Keep reset off.

    // When RegWrite is 1, the decoder turns on the enable for the chosen register.
    // Every register gets WriteData, but only the chosen one saves it on a rising clock edge.
    logic [31:0] Register;
    decoder_5by32 d (Register, WriteRegister, RegWrite);

    logic [31:0][63:0] data_out;
    // The generate loop makes all 31 writable registers without copying the same connections.
    // Each register gets its own enable and output, while WriteData and clk are shared.
    // Register 31 is left out because its value is always zero.
    genvar i;
    generate
        for (i = 0; i < 31; i++) begin : reg_loop
            register m (data_out[i], Register[i], WriteData, reset, clk);
        end
    endgenerate

    // Trying to write register 31 cannot change this fixed zero value.
    assign data_out[31] = 64'b0; // Register 31 always reads zero.

    // Both read ports use the same stored values, but each can choose a different address.
    // The outputs update after the mux gates settle, without waiting for a clock edge.
    mux_64by32by1 m1 (ReadData1, ReadRegister1, data_out);
    mux_64by32by1 m2 (ReadData2, ReadRegister2, data_out);
endmodule
