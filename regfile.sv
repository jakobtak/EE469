`timescale 1ps/1ps

// EE 469 Lab 1: 32 x 64-bit ARM register file.
// Two combinational read ports; one rising-edge write port.
// RegWrite enables writing WriteData to the selected register.
// X31 always reads zero and ignores writes.
// Built from DFF registers, a write decoder, and read muxes.
module regfile (ReadData1, 
                ReadData2, 
                WriteData,
                ReadRegister1, 
                ReadRegister2, 
                WriteRegister, 
                RegWrite, 
                clk);
                
  output [63:0] ReadData1, ReadData2;
  input [63:0] WriteData;
  input [4:0] ReadRegister1, ReadRegister2, WriteRegister;
  input RegWrite, clk;

  wire [31:0] write_enable;
  wire [63:0] registers [0:31];

  decoder5_32 write_decoder (write_enable, WriteRegister, RegWrite);
  assign registers[31] = 64'b0; // X31 is always zero

  // xi: register index, bi: bit index
  genvar xi, bi;
  generate
    // Store X0 through X30
    for (xi = 0; xi < 31; xi++) begin
      register64 reg64 (registers[xi], WriteData, write_enable[xi], 1'b0, clk); // Reset held low
    end

    // Two read muxes per bit
    for (bi = 0; bi < 64; bi++) begin
      wire [31:0] mux_in;

      for (xi = 0; xi < 32; xi++) begin
        assign mux_in[xi] = registers[xi][bi]; // Same bit from all registers
      end

      mux32_1 read_mux1 (ReadData1[bi], mux_in, ReadRegister1);
      mux32_1 read_mux2 (ReadData2[bi], mux_in, ReadRegister2);
    end
  endgenerate
endmodule
