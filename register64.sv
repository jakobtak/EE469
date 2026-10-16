`timescale 1ps/1ps

module register64 (q, d, enable, reset, clk);
  output [63:0] q; // Stored data
  input [63:0] d;  // New data
  input enable, reset, clk;

  wire [63:0] mux_out;

  genvar i;
  generate
    for (i = 0; i < 64; i++) begin: bits_reg // One circuit per bit
      mux2_1 mux (mux_out[i], {d[i], q[i]}, enable); // 0: hold, 1: write
      D_FF ff (q[i], mux_out[i], reset, clk);     // Rising edge; reset clears
    end
  endgenerate
endmodule

// synthesis translate_off
// Test sequence (check the expected values in the waveform):
// 1. Assert reset to clear the register.
// 2. Loop through all 64 bits, writing a single 1 at each position.
// 3. After each write, disable writing and set d=0; q should retain its value.
// 4. Pulse enable between rising edges; q should keep its last value.
// 5. Assert reset with enable=1; q should clear, then stop.
`timescale 1ns/10ps
module register64_testbench;
  parameter ClockDelay = 5000;
  integer i;
  logic [63:0] q, d;
  logic enable, reset, clk;

  register64 dut (.q, .d, .enable, .reset, .clk);

  initial begin
    clk <= 0;
    forever #(ClockDelay/2) clk <= ~clk;
  end

  initial begin
    reset <= 1; enable <= 0; d <= 0;
    @(posedge clk); // Clear the register.
    reset <= 0;

    // Move a single 1 through all 64 bit positions.
    for (i = 0; i < 64; i++) begin
      enable <= 1;
      d <= 64'b1 << i;
      @(posedge clk); // Write the pattern.
      enable <= 0;
      d <= 0;
      @(posedge clk); // q should keep the pattern despite d=0.
    end

    // The last stored value is 8000000000000000, and d is now 0.
    // Pulse enable during the second half of the clock cycle.
    @(negedge clk);
    enable <= 1;
    #(ClockDelay/4); // End the pulse before the next rising edge.
    enable <= 0;
    @(posedge clk); // q should still be 8000000000000000.
    @(negedge clk); // Observe the retained value before resetting.

    reset <= 1; enable <= 1;
    @(posedge clk); // Reset should clear q even when enable=1.
    @(negedge clk); // Let the last rising-edge update finish.
    $stop;
  end
endmodule
// synthesis translate_on
