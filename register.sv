`timescale 1ns/10ps

// This puts 64 Enable modules together to make one 64-bit register.
// They all use the same enable, reset, and clock, so the bits are controlled together.
// Using the one-bit module keeps the save-or-hold logic in one place.
module register (data_out, Register, WriteData, reset, clk);
    output logic [63:0] data_out;
    input logic [63:0] WriteData;
    input logic Register, reset, clk;

    // The generate loop makes one Enable module for each of the 64 bits.
    // Each copy connects WriteData[i] to data_out[i] and saves that one bit.
    // The reg_loop name makes the copies easier to find when looking at the waveforms.
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : reg_loop
            Enable ff (data_out[i], Register, WriteData[i], reset, clk); // One bit.
        end
    endgenerate
endmodule

`timescale 1ns/10ps

// This changes each input bit between 0 and 1, first with writing on and then with it off.
// Use the waveforms to see whether the register saves the input or keeps the old value.
// The test does not print a pass or fail result, so the output needs to be checked by hand.
module register_testbench;
    logic [63:0] data_out;
    logic [63:0] WriteData;
    logic Register, reset, clk;

    parameter period = 100;

    register dut (.Register, .WriteData, .reset, .clk, .data_out);

    initial begin
        clk <= 1;
        forever #(period / 2) clk <= ~clk;
    end

    integer i;
    integer k;

    initial begin
        reset = 1;
        Register = 0;
        WriteData = 0;

        reset = 0;
        @(posedge clk);
        Register = 1; // Enable writes.
        @(posedge clk);

        for (k = 0; k < 64; k++) begin
            for (i = 0; i < 2; i++) begin
                WriteData[k] = i;
                @(posedge clk);
            end
        end

        // Now the input bits change again, but writing is turned off.
        // Once the enable change reaches the gates, the register should keep its old value.
        Register = 0; // Keep the saved value.
        @(posedge clk);

        for (k = 0; k < 64; k++) begin
            for (i = 0; i < 2; i++) begin
                WriteData[k] = i;
                @(posedge clk);
            end
        end
    end
endmodule
