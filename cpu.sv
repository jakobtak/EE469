`timescale 1ns/10ps

// Single-cycle 64-bit ARM CPU.
// Every instruction is fetched, executed, and saved within one clock cycle.
// The datapath is built from gate-level modules; only control.sv uses RTL.
// Instructions: ADDI, ADDS, SUBS, B, BL, BR, B.LT, CBZ, LDUR, STUR.
//
// Delay (50 ps per gate):
//   Measured from the rising clock edge. PC, the instruction, and control have no delay.
//   Slowest path (ADDS/SUBS), to the register file D_FF inputs:
//     Reg2Loc MUX select              150 ps
//     register file read              350 ps  ->   500 ps
//     ALUSrc MUX data                 100 ps  ->   600 ps
//     ALU result                    6,550 ps  -> 7,150 ps
//     MemToReg MUX + Link MUX data    200 ps  -> 7,350 ps
//     Enable (WriteData -> din)       150 ps  -> 7,500 ps
//   Flags:   ALU zero (600 + 6,700 ps) + Enable (150 ps) = 7,450 ps
//   Next PC: UncondBr MUX (150 ps) + branch adder (6,400 ps) + two MUXes (200 ps)
//            + Enable (150 ps) = 6,900 ps
//   The clock period must be longer than 7,500 ps.
module cpu (clk, reset);
    input logic clk, reset;

    // PROGRAM COUNTER ====================================
    // The enable is tied to 1, so PC takes PC_next on every rising clock edge.
    // reset sets PC to 0, which is the address of the first instruction.
    wire [63:0] PC, PC_next;
    register pc_reg (PC, 1'b1, PC_next, reset, clk);

    // INSTRUCTION FETCH ====================================
    // Split the instruction into its fields. This is wiring only.
    logic [31:0] instruction;
    instructmem imem (PC, instruction, clk);

    wire [4:0] Rd, Rn, Rm;
    wire [11:0] Imm12;
    wire [8:0] Imm9;
    wire [18:0] Imm19;
    wire [25:0] Imm26;
    assign Rd    = instruction[4:0];
    assign Rn    = instruction[9:5];
    assign Rm    = instruction[20:16];
    assign Imm12 = instruction[21:10];
    assign Imm9  = instruction[20:12];
    assign Imm19 = instruction[23:5];
    assign Imm26 = instruction[25:0];

    // CONTROL ====================================
    logic Reg2Loc, ALUSrc, ImmSel, MemToReg, RegWrite, MemWrite, MemRead;
    logic UncondBr, BrTaken, RegBr, Link, FlagWrite;
    logic [2:0] ALUOp;
    wire negative, zero, overflow, carry_out;                     // From the ALU now.
    wire flag_negative, flag_zero, flag_overflow, flag_carry_out; // Saved by ADDS/SUBS.

    control ctrl (
        Reg2Loc, ALUSrc, ImmSel, MemToReg, RegWrite, MemWrite, MemRead,
        UncondBr, BrTaken, RegBr, Link, FlagWrite, ALUOp,
        instruction, zero, flag_negative, flag_overflow
    );

    // REGISTER FILE ====================================
    // ReadRegister2 is Rm for ADDS/SUBS, and Rd for STUR, CBZ, and BR.
    // BL writes to X30 instead of Rd.
    wire [4:0] ReadRegister2, WriteRegister;
    wire [63:0] ReadData1, ReadData2, WriteData;
    mux_2by1 #(5) reg2loc_mux (ReadRegister2, Rd, Rm, Reg2Loc);
    mux_2by1 #(5) link_reg_mux (WriteRegister, Rd, 5'd30, Link);

    regfile regs (
        ReadData1, ReadData2, WriteData,
        Rn, ReadRegister2, WriteRegister, RegWrite, clk
    );

    // IMMEDIATE ====================================
    // Imm12 is unsigned, so fill the upper bits with 0.
    // Imm9 is signed, so copy its top bit into the upper bits.
    wire [63:0] Imm12_extended, Imm9_extended, immediate;
    assign Imm12_extended = {52'b0, Imm12};
    assign Imm9_extended  = {{55{Imm9[8]}}, Imm9};
    mux_2by1 imm_mux (immediate, Imm9_extended, Imm12_extended, ImmSel);

    // ALU ====================================
    wire [63:0] ALU_B, ALU_result;
    mux_2by1 alusrc_mux (ALU_B, ReadData2, immediate, ALUSrc);
    alu main_alu (ReadData1, ALU_B, ALUOp, ALU_result, negative, zero, overflow, carry_out);

    // FLAGS ====================================
    // Each flag is saved only when FlagWrite is 1 (ADDS and SUBS).
    // B.LT reads these saved values, not the ALU outputs of its own cycle.
    Enable flag_n (flag_negative, FlagWrite, negative, reset, clk);
    Enable flag_z (flag_zero, FlagWrite, zero, reset, clk);
    Enable flag_v (flag_overflow, FlagWrite, overflow, reset, clk);
    Enable flag_c (flag_carry_out, FlagWrite, carry_out, reset, clk);

    // DATA MEMORY ====================================
    // The ALU result is the address. Every access is a full 8-byte word.
    logic [63:0] MemData;
    // Port order: address, write_enable, read_enable, write_data, clk, xfer_size, read_data.
    datamem dmem (ALU_result, MemWrite, MemRead, ReadData2, clk, 4'd8, MemData);

    // WRITE BACK ====================================
    // Choose the ALU result or memory data first, then replace it with PC + 4 for BL.
    wire [63:0] PC_plus4, result_or_mem;
    mux_2by1 memtoreg_mux (result_or_mem, ALU_result, MemData, MemToReg);
    mux_2by1 link_data_mux (WriteData, result_or_mem, PC_plus4, Link);

    // NEXT PC ====================================
    // Shift the branch offset left by 2 by adding two 0 bits, then sign-extend.
    wire [63:0] Imm19_offset, Imm26_offset, branch_offset, PC_branch, PC_plus4_or_branch;
    wire unused_c1, unused_v1, unused_c2, unused_v2;
    assign Imm19_offset = {{43{Imm19[18]}}, Imm19, 2'b00};
    assign Imm26_offset = {{36{Imm26[25]}}, Imm26, 2'b00};
    mux_2by1 uncondbr_mux (branch_offset, Imm19_offset, Imm26_offset, UncondBr);

    add_sub pc_plus4_adder (PC_plus4, unused_c1, unused_v1, PC, 64'd4, 1'b0);
    add_sub branch_adder (PC_branch, unused_c2, unused_v2, PC, branch_offset, 1'b0);

    // BR takes its target from the register file, so it is chosen last.
    mux_2by1 brtaken_mux (PC_plus4_or_branch, PC_plus4, PC_branch, BrTaken);
    mux_2by1 regbr_mux (PC_next, PC_plus4_or_branch, ReadData2, RegBr);
endmodule
