# TB-303 (Roland Cloud TB-303 .vst3) — cost reconnaissance, NOT a port yet

Written 2026-09-28 from a chat that is being retired (the facts below existed only in that chat).
Labels: PROVEN = executed under Unicorn on the plugin's own code; READ = static disassembly; INFERRED = deduction.

## Intake (step 0) — done 2026-09-28
`tb303/truth/` holds the four files the user supplied (2026-09-18): `TB-303VST3_64bit.vst3`, `Script.xml`,
`1_Preset.bin`, `TextCodeTable.dat`, with `SHA256SUMS`. Same ZenCore family as the JX-3P and JUPITER-8
(`CWaveGen` engine class, `CPrmDSP*Plugin` processor, CRT static-init table, fm/vm/dm Script.xml layout).

## What was found (2026-09-18/19)
| fact | value | label |
|---|---|---|
| Method | JX `CWaveGen` vtable cross-mapped by RTTI class name into the TB binary; same slot offsets | READ |
| BUILD | 0x3a8b60 | READ (executed after static init) |
| SETSR | 0x3a92b0 | READ |
| RENDER (engine slot 0x38) | 0x3a9020: rcx = HOST, r9 = &{float *L, float *R}, stack arg 6 = nframes; per-sample outer loop: event dispatch -> 0x39bd50 (pre-step) -> 0x39bce0 (voice + FX DSP, rcx = CTb303Sim) -> peak meter [rsi+0x20/0x24] | READ + PROVEN (executed) |
| HOSTPARAM | 0x3a8f60; a small fixed 24-entry host-param table at 0x9c3790 (not the 5223-id map); default path -> 0x3a73e0 | READ |
| NOTEON / NOTEOFF | 0x351f30 / 0x351d80 | READ |
| Processor vtable (PROC) | 0x9a5a68 | READ |
| ALLOC / pair | 0x65a83c / 0x65a878 (JX twin 0x6ab63c) | READ |
| DISPATCH | 0x38a5a0 (plugin slot 11) | READ |
| Static init | 844 / 847 ctors run (3 skipped, the JX shape); BUILD faults (`int 0x29` fastfail) WITHOUT static init | PROVEN |
| State | ONE unit (mono): HOST+0x9b8 -> CTb303Sim, 0x14968b0 bytes (21.5 MB); HOST+0x9c8 -> CPrmDSPTb303Plugin | PROVEN |
| Internal rate | BUILD writes [rbx+0x930] = 0x17700 = 96000 (2x oversample at 48 kHz) | READ |
| CTb303Sim vtable | 17 slots; slot 0x70 (0x397040) = event queue (40-byte records), slot 0x50 (0x39bdf0) = an inner kernel (390 float ops) | READ |

## Cost measurement (PROVEN instruction counts; the S3 mapping is INFERRED)
Retired x86 instructions per output frame, linear fit over N (immune to per-block overhead), steady state +-0.3 %:

| state | x86 instr / frame | x 1.75 -> S3 cyc / frame |
|---|---|---|
| idle (no note) | 589 | 1,030 |
| note (voice active) | 2,203 | 3,855 |
| note + params (voice + drive/dist/delay/reverb) | 3,797 | 6,645 |

- 90 % of the 3,797 is floating-point kernels: 0x392ea0 (54 %), 0x38c48a (15 %), 0x3901f6 (9 %), 0x392c50 (8 %) — the ACB
  circuit-solver / VCF kernels. Op mix: zero sqrt, ~6 divides, mul+add dominated, all single precision (S3-friendly).
- Calibration 1.75 S3 cyc per x86 instr = the JUNO's 2,877 x86 instr -> 5,045 S3 cyc (INFERRED transfer).
- Verdict (INFERRED): voice + FX = 6,645 / 10,000 cyc per frame at 48 kHz = ~66 % of ONE ESP32-S3 (both cores).
  Fits the one-board rule (END_GOAL amendment 2026-09-23) with ~34 % headroom.

## NOT done — say this before quoting any number above
- **No listen proof.** The render output was exactly 0 (the VCA envelope stayed closed; no patch was recalled). The cost is
  signal-independent solver work, so the count is representative, but step 4 of PORT_PIPELINE was never passed.
- **The harness (`tb_emu.py`) was never committed** — it lived in the retired chat's scratch space and is lost. Rebuild it by
  cloning `jp8/tools/jp8_emu.py` (the newest oracle) with the constants above; follow PORT_PIPELINE steps 1-4 and the JP8
  lessons (jp8/docs/PORT_LESSONS.md: construct the HOST with the plugin's own factory; recall through HOSTPARAM; no snap).
- No ABI ledger (`abi_check`), no bank decode, no recall.

## Next (in order)
1. `tb_emu.py` from `jp8_emu.py` + the table above; the factory that builds the HOST (find the processor's call site first —
   JP8 lesson 14); boot; recall a factory patch through HOSTPARAM; listen proof (pitch tracks keys, idle silent, release decays).
2. Re-measure the cost on a SOUNDING patch; then decide the S3 plan (one board, exact or cheaper engine graded against it).
