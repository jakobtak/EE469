`timescale 1ns/10ps

// This lets a D_FF either save new data or keep what it already has.
// When Register is 1, it uses WriteData. When Register is 0, it keeps data_out.
// The 64-bit register uses one copy of this module for each bit.
module Enable (data_out, Register, WriteData, reset, clk);
    output logic data_out;
    input logic WriteData;
    input logic Register, reset, clk; // Register turns writing on or off.

    wire change, hold, din, buffered, not_register;

    // One AND gate passes the new data, and the other passes the old data back in.
    // The OR gate sends the chosen value to din, which needs to settle before the clock edge.
    not #(50ps) n (not_register, Register);
    and #(50ps) c (change, WriteData, Register); // Use the new data.
    and #(50ps) h (hold, data_out, not_register);  // Keep the old data.
    // The buffer matches the NOT delay on the hold path so both paths reach the OR together.
    buf #(50ps) buffer (buffered, change);
    or #(50ps) new_data (din, buffered, hold);
    D_FF ff (data_out, din, reset, clk);
endmodule

`timescale 1ns/10ps

// This starts with reset, then tries 0 and 1 with writing turned off and on.
// The waveforms show whether data_out saves new data or keeps the old value.
// The gates take time to update, so the clock timing matters here.
module Enable_testbench;
    logic data_out;
    logic WriteData;
    logic Register, reset, clk;

    parameter period = 100;

    Enable dut (.Register, .WriteData, .reset, .clk, .data_out);

    initial begin
        clk <= 0;
        forever #(period / 2) clk <= ~clk;
    end

    integer i;
    integer k;

    initial begin
        reset = 1;
        Register = 0;
        WriteData = 0;

        @(posedge clk);
        reset = 0;
        @(posedge clk);

        // When Register is 0, changing WriteData should leave the saved bit alone.
        // When Register is 1, the next rising edge saves the input if the gates have settled.
        for (k = 0; k < 2; k++) begin
            for (i = 0; i < 2; i++) begin
                Register = k;
                @(posedge clk);
                WriteData = i;
                @(posedge clk);
            end
        end

        #10;
        $stop;
    end
endmodule
