`timescale 1ps/1ps

module mux2_1 (out, in, sel);
  output out;
  input [1:0] in;
  input sel;

  wire sel_n, in0_out, in1_out;

  not #50 (sel_n, sel);
  and #50 (in0_out, in[0], sel_n);
  and #50 (in1_out, in[1], sel);
  or  #50 (out, in0_out, in1_out);
endmodule
