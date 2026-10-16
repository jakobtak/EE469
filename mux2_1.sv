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

// synthesis translate_off
// Test sequence (check the expected values in the waveform):
// 1. Apply all 8 combinations of sel, in[1], and in[0], one per clock cycle.
// 2. Observe out: sel=0 selects in[0]; sel=1 selects in[1].
// 3. Stop the simulation and inspect the waveform.
`timescale 1ns/10ps
module mux2_1_testbench;
  parameter ClockDelay = 5000;
  logic [1:0] in;
  logic sel;
  logic out;
  integer i;
  logic clk;

  mux2_1 dut (.out, .in, .sel);

  initial begin
    clk <= 0;
    forever #(ClockDelay/2) clk <= ~clk;
  end

  initial begin
    // Try all 8 combinations. out should equal in[0] when sel=0, in[1] when sel=1.
    for (i = 0; i < 8; i++) begin
      {sel, in} <= i;
      @(posedge clk);
    end
    @(negedge clk); // Let the last rising-edge update finish.
    $stop;
  end
endmodule
// synthesis translate_on
