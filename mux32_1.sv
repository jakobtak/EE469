`timescale 1ps/1ps

module mux32_1 (out, in, sel);
  output out;
  input [31:0] in;
  input [4:0] sel;

  wire [15:0] mux_32_to_16;
  wire [7:0] mux_16_to_8;
  wire [3:0] mux_8_to_4;
  wire [1:0] mux_4_to_2;

  genvar i;
  generate
    // 32 inputs -> 16 outputs
    for (i = 0; i < 16; i = i + 1) begin: gen_16
      mux2_1 mux (mux_32_to_16[i], in[2*i], in[2*i+1], sel[0]);
    end

    // 16 inputs -> 8 outputs
    for (i = 0; i < 8; i = i + 1) begin: gen_8
      mux2_1 mux (mux_16_to_8[i], mux_32_to_16[2*i], mux_32_to_16[2*i+1], sel[1]);
    end

    // 8 inputs -> 4 outputs
    for (i = 0; i < 4; i = i + 1) begin: gen_4
      mux2_1 mux (mux_8_to_4[i], mux_16_to_8[2*i], mux_16_to_8[2*i+1], sel[2]);
    end

    // 4 inputs -> 2 outputs
    for (i = 0; i < 2; i = i + 1) begin: gen_2
      mux2_1 mux (mux_4_to_2[i], mux_8_to_4[2*i], mux_8_to_4[2*i+1], sel[3]);
    end
  endgenerate
  
  // 2 inputs -> 1 output
  mux2_1 mux_last (out, mux_4_to_2[0], mux_4_to_2[1], sel[4]);
endmodule
