module mux2_1 (out, a, b, sel);
  output out;
  input a, b, sel;

  wire sel_n, a_out, b_out;

  not #50 (sel_n, sel);
  and #50 (a_out, a, sel_n);
  and #50 (b_out, b, sel);
  or  #50 (out, a_out, b_out);
endmodule
