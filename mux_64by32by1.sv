`timescale 1ns/10ps

// Select one of 32 64-bit words using a single mux_32by1.
// mux_32by1 already produces the complete 64-bit read result.
module mux_64by32by1 (ReadData, ReadRegister, data_out);
    output logic [63:0] ReadData;
    input logic [4:0] ReadRegister;
    input logic [31:0][63:0] data_out;

    mux_32by1 m32 (ReadData, ReadRegister, data_out);
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
