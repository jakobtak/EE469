`timescale 1ps/1ps

module mux32_1 (out, in, sel);
  output out;
  input [31:0] in;
  input [4:0] sel;

  wire [15:0] mux_32_to_16;
  wire [7:0] mux_16_to_8;
  wire [3:0] mux_8_to_4;
  wire [1:0] mux_4_to_2;

  // 32 inputs -> 16 outputs; explicit constant indices.
  // for (i = 0; i < 16; i++) begin: gen_16
  //   mux2_1 mux (mux_32_to_16[i], {in[2*i+1], in[2*i]}, sel[0]);
  // end
  mux2_1 mux_16_0 (mux_32_to_16[0], {in[1], in[0]}, sel[0]);
  mux2_1 mux_16_1 (mux_32_to_16[1], {in[3], in[2]}, sel[0]);
  mux2_1 mux_16_2 (mux_32_to_16[2], {in[5], in[4]}, sel[0]);
  mux2_1 mux_16_3 (mux_32_to_16[3], {in[7], in[6]}, sel[0]);
  mux2_1 mux_16_4 (mux_32_to_16[4], {in[9], in[8]}, sel[0]);
  mux2_1 mux_16_5 (mux_32_to_16[5], {in[11], in[10]}, sel[0]);
  mux2_1 mux_16_6 (mux_32_to_16[6], {in[13], in[12]}, sel[0]);
  mux2_1 mux_16_7 (mux_32_to_16[7], {in[15], in[14]}, sel[0]);
  mux2_1 mux_16_8 (mux_32_to_16[8], {in[17], in[16]}, sel[0]);
  mux2_1 mux_16_9 (mux_32_to_16[9], {in[19], in[18]}, sel[0]);
  mux2_1 mux_16_10 (mux_32_to_16[10], {in[21], in[20]}, sel[0]);
  mux2_1 mux_16_11 (mux_32_to_16[11], {in[23], in[22]}, sel[0]);
  mux2_1 mux_16_12 (mux_32_to_16[12], {in[25], in[24]}, sel[0]);
  mux2_1 mux_16_13 (mux_32_to_16[13], {in[27], in[26]}, sel[0]);
  mux2_1 mux_16_14 (mux_32_to_16[14], {in[29], in[28]}, sel[0]);
  mux2_1 mux_16_15 (mux_32_to_16[15], {in[31], in[30]}, sel[0]);

  // 16 inputs -> 8 outputs; explicit constant indices.
  // for (i = 0; i < 8; i++) begin: gen_8
  //   mux2_1 mux (mux_16_to_8[i], {mux_32_to_16[2*i+1], mux_32_to_16[2*i]}, sel[1]);
  // end
  mux2_1 mux_8_0 (mux_16_to_8[0], {mux_32_to_16[1], mux_32_to_16[0]}, sel[1]);
  mux2_1 mux_8_1 (mux_16_to_8[1], {mux_32_to_16[3], mux_32_to_16[2]}, sel[1]);
  mux2_1 mux_8_2 (mux_16_to_8[2], {mux_32_to_16[5], mux_32_to_16[4]}, sel[1]);
  mux2_1 mux_8_3 (mux_16_to_8[3], {mux_32_to_16[7], mux_32_to_16[6]}, sel[1]);
  mux2_1 mux_8_4 (mux_16_to_8[4], {mux_32_to_16[9], mux_32_to_16[8]}, sel[1]);
  mux2_1 mux_8_5 (mux_16_to_8[5], {mux_32_to_16[11], mux_32_to_16[10]}, sel[1]);
  mux2_1 mux_8_6 (mux_16_to_8[6], {mux_32_to_16[13], mux_32_to_16[12]}, sel[1]);
  mux2_1 mux_8_7 (mux_16_to_8[7], {mux_32_to_16[15], mux_32_to_16[14]}, sel[1]);

  // 8 inputs -> 4 outputs; explicit constant indices.
  // for (i = 0; i < 4; i++) begin: gen_4
  //   mux2_1 mux (mux_8_to_4[i], {mux_16_to_8[2*i+1], mux_16_to_8[2*i]}, sel[2]);
  // end
  mux2_1 mux_4_0 (mux_8_to_4[0], {mux_16_to_8[1], mux_16_to_8[0]}, sel[2]);
  mux2_1 mux_4_1 (mux_8_to_4[1], {mux_16_to_8[3], mux_16_to_8[2]}, sel[2]);
  mux2_1 mux_4_2 (mux_8_to_4[2], {mux_16_to_8[5], mux_16_to_8[4]}, sel[2]);
  mux2_1 mux_4_3 (mux_8_to_4[3], {mux_16_to_8[7], mux_16_to_8[6]}, sel[2]);

  // 4 inputs -> 2 outputs; explicit constant indices.
  // for (i = 0; i < 2; i++) begin: gen_2
  //   mux2_1 mux (mux_4_to_2[i], {mux_8_to_4[2*i+1], mux_8_to_4[2*i]}, sel[3]);
  // end
  mux2_1 mux_2_0 (mux_4_to_2[0], {mux_8_to_4[1], mux_8_to_4[0]}, sel[3]);
  mux2_1 mux_2_1 (mux_4_to_2[1], {mux_8_to_4[3], mux_8_to_4[2]}, sel[3]);

  // 2 inputs -> 1 output
  mux2_1 mux_last (out, {mux_4_to_2[1], mux_4_to_2[0]}, sel[4]);
endmodule

// synthesis translate_off
// Test sequence (check the expected values in the waveform):
// 1. Move a single 1 through all 32 input bits; for each bit, try every sel.
//    out should be 1 only when sel selects that bit (j equals i).
// 2. Set all input bits to 0; out should be 0.
// 3. Set all input bits to 1; out should be 1, then stop.
`timescale 1ns/10ps
module mux32_1_testbench;
  parameter ClockDelay = 5000;
  logic [31:0] in;
  logic [4:0] sel;
  logic out;
  integer i, j;
  logic clk;

  mux32_1 dut (.out, .in, .sel);

  initial begin
    clk <= 0;
    forever #(ClockDelay/2) clk <= ~clk;
  end

  initial begin
    // i chooses which input bit is 1; j chooses which bit the mux reads.
    for (i = 0; i < 32; i++) begin
      in <= 32'b1 << i;
      for (j = 0; j < 32; j++) begin
        sel <= j;
        @(posedge clk); // out = 1 when j equals i; otherwise out = 0.
      end
    end
    in <= 32'h00000000; @(posedge clk); // out = 0
    in <= 32'hFFFFFFFF; @(posedge clk); // out = 1
    @(negedge clk); // Let the last rising-edge update finish.
    $stop;
  end
endmodule
// synthesis translate_on
