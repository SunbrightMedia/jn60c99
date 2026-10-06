# HOSTPATH PARITY LOG

The log `HOSTPATH_PARITY_SCOPE.md` asks for: what each STEP found, with the rvas
that prove it. Newest first.

## 2026-10-06 — STEP 3 (setState), engine side: the preset path is the host entry

Labels: READ = static reading of the machine code; EXECUTED = run under Unicorn.

| Fact | Evidence |
|---|---|
| `IComponent::setState` (0x34AAA0) reads a big-endian length + payload and hands it to the wrapper queue's deserializer (queue vtable 0x9679C8 slot 6 = 0x321F20). | READ |
| The deserializer walks (id, value) pairs and writes the plugin's parameter store only (0x319AB0 lookup, 0x283DB0 set + notify), bracketed by 0x7E / 0x7F gestures; it holds no engine reference. | READ |
| The engine's only parameter writer is the host entry (CWaveGen vtable 0x9DF1D8 slot 14 = 0x3C7AE0, flag 0). Its queue (+0x1B8, mutex +0x118) is fed only by `process()` (0x31F2C0, called from 0x34A648) and consumed by 0x320B20; the other queue (+0x200, mutex +0x168, fed by setParam 0x3221F0 and the MIDI push) is consumed by 0x320120 and writes the parameter store: engine -> store. | READ |
| The all-parameter method (proc vtable 0x9C3018 slot 8 = 0x3B48A0, flag 1) reads every value through slot 13 = 0x3B6C30, `xor eax,eax; ret`, and nothing calls it directly: it is not the preset path. The engine's program-change slot (+144, 0x34B060) is `ret 0`. | READ |
| The host entry drops values outside the parameter's database range (EFFECT / DELAY / REVERB TYPE 6..255, VCF CUTOFF 256 / 1000, DELAY TAP TIME 101 / 127, LFO RATE H 0x3F800001: no setter call); HPF TYPE maps any value to (v != 0) first. | EXECUTED, scratchpad/probe_range.py |
| LFO RATE H (878) and VCF CUTOFF FREQ H (1029) are host parameters (database range = the float bits [0, 1.0f]); their host-role sets ramp the LFO-rate / cutoff cells to the value itself, and the H value becomes the cutoff object's last value. | EXECUTED, probes/host/host_census_h.py, scratchpad/probe_cutH.py |
| OCTAVE SHIFT (836) reaches its setter on all 9 units and writes no engine cell; a note through the engine's note-on sounds the same at every shift (fresh engines). MASTER TUNE is not in the engine's parameter map. | EXECUTED, scratchpad/probe_oct3.py |

Consequence: a DAW preset load reaches the engine as host-role parameter edits, which
`tools/verify/host_edit_gate.py` (CLAIMS A20) makes bit-exact edit by edit for 78 of
the 79 panel parameters. **Wall (unchanged, P112_FINDINGS.md §7):** which parameters
the controller sends after setState, and in which order, needs the wrapper
constructed; `IComponent::initialize` still faults under emulation.
