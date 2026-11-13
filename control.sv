`timescale 1ns/10ps

// This reads the opcode and sets the control signals for the datapath.
// The lab allows RTL for control logic, so this uses always_comb.
// An unknown instruction turns every signal off, so nothing is written.
//
// Signal      0                    1
// Reg2Loc     ReadRegister2 = Rd   ReadRegister2 = Rm
// ALUSrc      ALU B = ReadData2    ALU B = immediate
// ImmSel      SignExtend(Imm9)     ZeroExtend(Imm12)
// MemToReg    write ALU result     write memory data
// UncondBr    offset = Imm19       offset = Imm26
// BrTaken     PC = PC + 4          PC = PC + offset
// RegBr       use the line above   PC = ReadData2 (BR)
// Link        normal write         X30 = PC + 4 (BL)
//
// Delay (50 ps per gate):
//   None. This is RTL with no gate delays, so the outputs change with the inputs.
module control (
    Reg2Loc, ALUSrc, ImmSel, MemToReg, RegWrite, MemWrite, MemRead,
    UncondBr, BrTaken, RegBr, Link, FlagWrite, ALUOp,
    instruction, zero, flag_negative, flag_overflow
);
    output logic Reg2Loc, ALUSrc, ImmSel, MemToReg, RegWrite, MemWrite, MemRead;
    output logic UncondBr, BrTaken, RegBr, Link, FlagWrite;
    output logic [2:0] ALUOp;
    input logic [31:0] instruction;
    input logic zero;                         // From the ALU, used by CBZ.
    input logic flag_negative, flag_overflow; // Saved flags, used by B.LT.

    parameter ALU_PASS_B = 3'b000, ALU_ADD = 3'b010, ALU_SUBTRACT = 3'b011;
    parameter COND_LT = 5'b01011;

    always_comb begin
        // Start with everything off. Each instruction turns on only what it needs.
        Reg2Loc   = 0;
        ALUSrc    = 0;
        ImmSel    = 0;
        MemToReg  = 0;
        RegWrite  = 0;
        MemWrite  = 0;
        MemRead   = 0;
        UncondBr  = 0;
        BrTaken   = 0;
        RegBr     = 0;
        Link      = 0;
        FlagWrite = 0;
        ALUOp     = ALU_PASS_B;

        casez (instruction[31:21])
            // ADDI: Reg[Rd] = Reg[Rn] + ZeroExtend(Imm12)
            11'b1001000100?: begin
                ALUSrc   = 1;
                ImmSel   = 1;
                RegWrite = 1;
                ALUOp    = ALU_ADD;
            end

            // ADDS: Reg[Rd] = Reg[Rn] + Reg[Rm], set flags
            11'b10101011000: begin
                Reg2Loc   = 1;
                RegWrite  = 1;
                FlagWrite = 1;
                ALUOp     = ALU_ADD;
            end

            // SUBS: Reg[Rd] = Reg[Rn] - Reg[Rm], set flags
            11'b11101011000: begin
                Reg2Loc   = 1;
                RegWrite  = 1;
                FlagWrite = 1;
                ALUOp     = ALU_SUBTRACT;
            end

            // B: PC = PC + SignExtend(Imm26 << 2)
            11'b000101?????: begin
                UncondBr = 1;
                BrTaken  = 1;
            end

            // BL: X30 = PC + 4, PC = PC + SignExtend(Imm26 << 2)
            11'b100101?????: begin
                UncondBr = 1;
                BrTaken  = 1;
                Link     = 1;
                RegWrite = 1;
            end

            // B.LT: branch when the saved flags have negative != overflow
            11'b01010100???: begin
                if (instruction[4:0] == COND_LT)
                    BrTaken = flag_negative ^ flag_overflow;
            end

            // CBZ: branch when Reg[Rd] is zero. The ALU passes Reg[Rd] to set zero.
            11'b10110100???: begin
                ALUOp   = ALU_PASS_B;
                BrTaken = zero;
            end

            // BR: PC = Reg[Rd]
            11'b11010110000: begin
                RegBr = 1;
            end

            // LDUR: Reg[Rd] = Mem[Reg[Rn] + SignExtend(Imm9)]
            11'b11111000010: begin
                ALUSrc   = 1;
                MemToReg = 1;
                RegWrite = 1;
                MemRead  = 1;
                ALUOp    = ALU_ADD;
            end

            // STUR: Mem[Reg[Rn] + SignExtend(Imm9)] = Reg[Rd]
            11'b11111000000: begin
                ALUSrc   = 1;
                MemWrite = 1;
                ALUOp    = ALU_ADD;
            end

            default: ; // Unknown instruction: keep everything off.
        endcase
    end
endmodule
