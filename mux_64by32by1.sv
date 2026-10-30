`timescale 1ns/10ps

// This puts together the 64-bit read result using copies of mux_32by1.
// Each copy gets the same read address and the same register values.
// The output takes one bit from each copy to make the full ReadData value.
module mux_64by32by1 (ReadData, ReadRegister, data_out);
    output logic [63:0] ReadData;
    input logic [4:0] ReadRegister;
    input logic [31:0][63:0] data_out;

    // The generate loop makes these copies before the simulation starts.
    // Each copy has its own full_out signal inside reg_loop.
    // This saves typing the same connections, but each copy still makes a full 64-bit value.
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : reg_loop
            // Each mux gives a full 64-bit result, but this copy only uses bit i.
            logic [63:0] full_out;
            mux_32by1 m32 (full_out, ReadRegister, data_out);
            assign ReadData[i] = full_out[i]; // Take one bit from each mux.
        end
    endgenerate
endmodule

// This fills the inputs with their address values, then tries every read address.
// After each wait, check that ReadData matches the selected input in the waveform.
// These small values help check the addresses, but they do not change all 64 data bits.
module mux_64by32by1_testbench;
    logic [63:0] ReadData;
    logic [4:0] ReadRegister;
    logic [31:0][63:0] data_out;

    mux_64by32by1 dut (.ReadRegister, .data_out, .ReadData);

    integer k;

    initial begin
        for (k = 0; k < 32; k++) begin
            data_out[k] = k; // Store the address as the test value.
        end

        for (k = 0; k < 32; k++) begin
            ReadRegister = k;
            #1000;
        end
    end
endmodule
