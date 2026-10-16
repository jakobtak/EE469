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
  // for (i = 0; i < 16; i = i + 1) begin: gen_16
  //   mux2_1 mux (mux_32_to_16[i], in[2*i], in[2*i+1], sel[0]);
  // end
  mux2_1 mux_16_0 (mux_32_to_16[0], in[0], in[1], sel[0]);
  mux2_1 mux_16_1 (mux_32_to_16[1], in[2], in[3], sel[0]);
  mux2_1 mux_16_2 (mux_32_to_16[2], in[4], in[5], sel[0]);
  mux2_1 mux_16_3 (mux_32_to_16[3], in[6], in[7], sel[0]);
  mux2_1 mux_16_4 (mux_32_to_16[4], in[8], in[9], sel[0]);
  mux2_1 mux_16_5 (mux_32_to_16[5], in[10], in[11], sel[0]);
  mux2_1 mux_16_6 (mux_32_to_16[6], in[12], in[13], sel[0]);
  mux2_1 mux_16_7 (mux_32_to_16[7], in[14], in[15], sel[0]);
  mux2_1 mux_16_8 (mux_32_to_16[8], in[16], in[17], sel[0]);
  mux2_1 mux_16_9 (mux_32_to_16[9], in[18], in[19], sel[0]);
  mux2_1 mux_16_10 (mux_32_to_16[10], in[20], in[21], sel[0]);
  mux2_1 mux_16_11 (mux_32_to_16[11], in[22], in[23], sel[0]);
  mux2_1 mux_16_12 (mux_32_to_16[12], in[24], in[25], sel[0]);
  mux2_1 mux_16_13 (mux_32_to_16[13], in[26], in[27], sel[0]);
  mux2_1 mux_16_14 (mux_32_to_16[14], in[28], in[29], sel[0]);
  mux2_1 mux_16_15 (mux_32_to_16[15], in[30], in[31], sel[0]);

  // 16 inputs -> 8 outputs; explicit constant indices.
  // for (i = 0; i < 8; i = i + 1) begin: gen_8
  //   mux2_1 mux (mux_16_to_8[i], mux_32_to_16[2*i], mux_32_to_16[2*i+1], sel[1]);
  // end
  mux2_1 mux_8_0 (mux_16_to_8[0], mux_32_to_16[0], mux_32_to_16[1], sel[1]);
  mux2_1 mux_8_1 (mux_16_to_8[1], mux_32_to_16[2], mux_32_to_16[3], sel[1]);
  mux2_1 mux_8_2 (mux_16_to_8[2], mux_32_to_16[4], mux_32_to_16[5], sel[1]);
  mux2_1 mux_8_3 (mux_16_to_8[3], mux_32_to_16[6], mux_32_to_16[7], sel[1]);
  mux2_1 mux_8_4 (mux_16_to_8[4], mux_32_to_16[8], mux_32_to_16[9], sel[1]);
  mux2_1 mux_8_5 (mux_16_to_8[5], mux_32_to_16[10], mux_32_to_16[11], sel[1]);
  mux2_1 mux_8_6 (mux_16_to_8[6], mux_32_to_16[12], mux_32_to_16[13], sel[1]);
  mux2_1 mux_8_7 (mux_16_to_8[7], mux_32_to_16[14], mux_32_to_16[15], sel[1]);

  // 8 inputs -> 4 outputs; explicit constant indices.
  // for (i = 0; i < 4; i = i + 1) begin: gen_4
  //   mux2_1 mux (mux_8_to_4[i], mux_16_to_8[2*i], mux_16_to_8[2*i+1], sel[2]);
  // end
  mux2_1 mux_4_0 (mux_8_to_4[0], mux_16_to_8[0], mux_16_to_8[1], sel[2]);
  mux2_1 mux_4_1 (mux_8_to_4[1], mux_16_to_8[2], mux_16_to_8[3], sel[2]);
  mux2_1 mux_4_2 (mux_8_to_4[2], mux_16_to_8[4], mux_16_to_8[5], sel[2]);
  mux2_1 mux_4_3 (mux_8_to_4[3], mux_16_to_8[6], mux_16_to_8[7], sel[2]);

  // 4 inputs -> 2 outputs; explicit constant indices.
  // for (i = 0; i < 2; i = i + 1) begin: gen_2
  //   mux2_1 mux (mux_4_to_2[i], mux_8_to_4[2*i], mux_8_to_4[2*i+1], sel[3]);
  // end
  mux2_1 mux_2_0 (mux_4_to_2[0], mux_8_to_4[0], mux_8_to_4[1], sel[3]);
  mux2_1 mux_2_1 (mux_4_to_2[1], mux_8_to_4[2], mux_8_to_4[3], sel[3]);

  // 2 inputs -> 1 output
  mux2_1 mux_last (out, mux_4_to_2[0], mux_4_to_2[1], sel[4]);
endmodule
