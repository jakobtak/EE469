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
