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

  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin: decode_out
      and #50 (out[i], enable, high[i / 4], low[i % 4]); // i/4: upper 3 bits; i%4: lower 2 bits
    end
  endgenerate
endmodule
