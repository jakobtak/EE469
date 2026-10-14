module register64 (q, d, enable, reset, clk);
  output [63:0] q; // Stored data
  input [63:0] d;  // New data
  input enable, reset, clk;

  wire [63:0] mux_out;

  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin: bits_reg // One circuit per bit
      mux2_1 mux (mux_out[i], q[i], d[i], enable); // 0: hold, 1: write
      D_FF ff (q[i], mux_out[i], reset, clk);     // Rising edge; reset clears
    end
  endgenerate
endmodule
