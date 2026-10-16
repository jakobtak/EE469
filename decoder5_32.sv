`timescale 1ps/1ps

module decoder5_32 (out, addr, enable);
  output [31:0] out;
  input [4:0] addr;
  input enable;

  wire [4:0] addr_n;
  wire [3:0] low;  // Decode addr[1:0]
  wire [7:0] high; // Decode addr[4:2]

  // #50 = 50 ps delay
  // Invert all 5 address bits
  not #50 (addr_n[0], addr[0]); 
  not #50 (addr_n[1], addr[1]);
  not #50 (addr_n[2], addr[2]);
  not #50 (addr_n[3], addr[3]);
  not #50 (addr_n[4], addr[4]);

  // Select one of 4 positions using addr[1:0]
  and #50 (low[0], addr_n[1], addr_n[0]);
  and #50 (low[1], addr_n[1], addr[0]);
  and #50 (low[2], addr[1], addr_n[0]);
  and #50 (low[3], addr[1], addr[0]);

  // Select one of 8 groups using addr[4:2]
  and #50 (high[0], addr_n[4], addr_n[3], addr_n[2]);
  and #50 (high[1], addr_n[4], addr_n[3], addr[2]);
  and #50 (high[2], addr_n[4], addr[3], addr_n[2]);
  and #50 (high[3], addr_n[4], addr[3], addr[2]);
  and #50 (high[4], addr[4], addr_n[3], addr_n[2]);
  and #50 (high[5], addr[4], addr_n[3], addr[2]);
  and #50 (high[6], addr[4], addr[3], addr_n[2]);
  and #50 (high[7], addr[4], addr[3], addr[2]);

  /* Original generate loop (reference only):
  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin: decode_out
      and #50 (out[i], enable, high[i / 4], low[i % 4]); // i/4: upper 3 bits; i%4: lower 2 bits
    end
  endgenerate
  */

  // Explicit output wiring: each high group contains four low positions.
  and #50 (out[0], enable, high[0], low[0]);
  and #50 (out[1], enable, high[0], low[1]);
  and #50 (out[2], enable, high[0], low[2]);
  and #50 (out[3], enable, high[0], low[3]);
  and #50 (out[4], enable, high[1], low[0]);
  and #50 (out[5], enable, high[1], low[1]);
  and #50 (out[6], enable, high[1], low[2]);
  and #50 (out[7], enable, high[1], low[3]);
  and #50 (out[8], enable, high[2], low[0]);
  and #50 (out[9], enable, high[2], low[1]);
  and #50 (out[10], enable, high[2], low[2]);
  and #50 (out[11], enable, high[2], low[3]);
  and #50 (out[12], enable, high[3], low[0]);
  and #50 (out[13], enable, high[3], low[1]);
  and #50 (out[14], enable, high[3], low[2]);
  and #50 (out[15], enable, high[3], low[3]);
  and #50 (out[16], enable, high[4], low[0]);
  and #50 (out[17], enable, high[4], low[1]);
  and #50 (out[18], enable, high[4], low[2]);
  and #50 (out[19], enable, high[4], low[3]);
  and #50 (out[20], enable, high[5], low[0]);
  and #50 (out[21], enable, high[5], low[1]);
  and #50 (out[22], enable, high[5], low[2]);
  and #50 (out[23], enable, high[5], low[3]);
  and #50 (out[24], enable, high[6], low[0]);
  and #50 (out[25], enable, high[6], low[1]);
  and #50 (out[26], enable, high[6], low[2]);
  and #50 (out[27], enable, high[6], low[3]);
  and #50 (out[28], enable, high[7], low[0]);
  and #50 (out[29], enable, high[7], low[1]);
  and #50 (out[30], enable, high[7], low[2]);
  and #50 (out[31], enable, high[7], low[3]);
endmodule
