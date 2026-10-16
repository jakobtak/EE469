`timescale 1ps/1ps

// Empty board top for future labs.
module DE1_SoC (CLOCK_50, reset, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, V_GPIO);
  input CLOCK_50, reset;
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  output [9:0] LEDR;
  inout [35:0] V_GPIO;

  assign HEX0 = 7'b1111111; // Displays off
  assign HEX1 = 7'b1111111;
  assign HEX2 = 7'b1111111;
  assign HEX3 = 7'b1111111;
  assign HEX4 = 7'b1111111;
  assign HEX5 = 7'b1111111;
  assign LEDR = 10'b0;     // LEDs off
  assign V_GPIO = 36'bz;   // GPIO undriven
endmodule
