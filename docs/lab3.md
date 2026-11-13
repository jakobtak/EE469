# Lab 3

## Fixed

Lab 1 and Lab 2 modules were reviewed before starting the CPU. The register file and ALU already gave correct results; the fixes below remove redundant hardware and hazards.

### Redundant read MUX

`mux_64by32by1` built 64 copies of `mux_32by1` and used one bit from each. `mux_32by1` already outputs all 64 bits, so one copy is enough.

- Before: 64 copies per read port. The register file simulation did not finish.
- After: 1 copy per read port.

### Hazard

All hazards came from paths with different gate delays reaching the same gate. Each fix matches the delays.

| Module | Problem | Fix |
|---|---|---|
| `Enable` | `!Register` had no delay, so `din` dropped for 50 ps when `Register` rose. | Replaced with a 50 ps NOT gate. |
| `decoder_3by8` | Non-inverted address bits arrived 50 ps before inverted ones. Two or more outputs were 1 at once. | Added buffers on the non-inverted address bits. |
| `decoder_5by32` | The group enable arrived later than the low address bits. Unrelated register enables pulsed. | Added buffers on the address bits and `RegWrite`. |
| `full_adder` | `carry_out` dropped for 50 ps when all inputs were 1 and `a` or `b` fell. | Changed the carry to `ab + a·cin + b·cin`. |
| `alu` | `cntrl[1]` arrived 50 ps before the inverted `cntrl[2]`, so `overflow` and `carry_out` pulsed. | Added a buffer on `cntrl[1]`. |

**Result**

| Check | Before | After |
|---|---|---|
| `decoder_5by32`: address changes with more than one enable at 1 | 529 / 992 | 0 / 992 |
| `decoder_3by8`: address changes that pulse an unrelated output | 7 / 56 | 0 / 56 |
| `full_adder`: single-input changes that glitch | 2 / 24 | 0 / 24 |
| `Enable`: single-input changes that glitch `din` | 1 / 16 | 0 / 16 |
| Register file and ALU function tests | 0 errors | 0 errors |
| ALU worst-case delay | 6.75 ns | 6.70 ns |

Outputs of the ripple-carry adder still change several times while the carry propagates. This is expected and settles before the clock edge.

## Implementation

### Single-Cycle CPU

`cpu.sv` connects the register file and ALU from the earlier labs with the provided memories. Each instruction finishes in one clock cycle.

1. **Fetch.** `PC` selects the instruction. The fields `Rd`, `Rn`, `Rm`, and the immediates are split off by wiring.
2. **Decode.** `control.sv` reads the opcode and sets the control signals. The register file reads `Rn` and either `Rm` or `Rd`.
3. **Execute.** The ALU takes `ReadData1` and either `ReadData2` or an immediate.
4. **Memory.** The ALU result is the address for LDUR and STUR.
5. **Write back.** The register file saves the ALU result, the memory data, or `PC + 4`.
6. **Next PC.** `PC + 4`, `PC + offset`, or a register value is saved as the new `PC`.

New files:

| File | Purpose |
|---|---|
| `cpu.sv` | Datapath. Gate-level modules only. |
| `control.sv` | Control signals. RTL, as the lab allows. |
| `mux_2by1.sv` | 2-to-1 MUX with a `WIDTH` parameter. |
| `cpustim.sv` | Testbench. Stops when `PC` stops changing, then prints registers and memory. |

#### Control Signals

| Signal | 0 | 1 |
|---|---|---|
| `Reg2Loc` | `ReadRegister2 = Rd` | `ReadRegister2 = Rm` |
| `ALUSrc` | ALU B = `ReadData2` | ALU B = immediate |
| `ImmSel` | SignExtend(Imm9) | ZeroExtend(Imm12) |
| `MemToReg` | Write ALU result | Write memory data |
| `UncondBr` | Offset = Imm19 | Offset = Imm26 |
| `BrTaken` | `PC = PC + 4` | `PC = PC + offset` |
| `RegBr` | Use `BrTaken` | `PC = ReadData2` |
| `Link` | Normal write | `X30 = PC + 4` |

| Instruction | Reg2Loc | ALUSrc | ImmSel | MemToReg | RegWrite | MemWrite | MemRead | UncondBr | BrTaken | RegBr | Link | FlagWrite | ALUOp |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ADDI | x | 1 | 1 | 0 | 1 | 0 | 0 | x | 0 | 0 | 0 | 0 | ADD |
| ADDS | 1 | 0 | x | 0 | 1 | 0 | 0 | x | 0 | 0 | 0 | 1 | ADD |
| SUBS | 1 | 0 | x | 0 | 1 | 0 | 0 | x | 0 | 0 | 0 | 1 | SUB |
| B | x | x | x | x | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | x |
| BL | x | x | x | x | 1 | 0 | 0 | 1 | 1 | 0 | 1 | 0 | x |
| BR | 0 | x | x | x | 0 | 0 | 0 | x | x | 1 | 0 | 0 | x |
| B.LT | x | x | x | x | 0 | 0 | 0 | 0 | N != V | 0 | 0 | 0 | x |
| CBZ | 0 | 0 | x | x | 0 | 0 | 0 | 0 | zero | 0 | 0 | 0 | PASS B |
| LDUR | x | 1 | 0 | 1 | 1 | 0 | 1 | x | 0 | 0 | 0 | 0 | ADD |
| STUR | 0 | 1 | 0 | x | 0 | 1 | 0 | x | 0 | 0 | 0 | 0 | ADD |

`x` means the value does not matter. `control.sv` sets these to 0.

- **B.LT** uses the flags saved by the last ADDS or SUBS, not the ALU outputs of its own cycle.
- **CBZ** passes `Reg[Rd]` through the ALU and uses its `zero` output directly.
- **BR** reads `Rd` on `ReadData2`, the same port STUR and CBZ use.

### Results

Change the benchmark in `instructmem.sv`, then run `do runlab.do`.

| Benchmark | Cycles to halt | Result |
|---|---|---|
| `test01_AddiB` | 6 | Pass |
| `test02_AddsSubs` | 10 | Pass |
| `test03_CbzB` | 19 | Pass |
| `test04_LdurStur` | 12 | Pass |
| `test05_Blt` | 12 | Pass |
| `test06_BlBr` | 14 | Pass |
| `test10_forwarding` | 48 | Pass |
| `test11_Sort` | 598 | Pass |
| `test12_Fibonacci` | 233 | Pass |
