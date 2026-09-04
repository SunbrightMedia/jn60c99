# JX-3P PORT LESSONS — the legacy for the NEXT .vst3 port

Written as it was earned. Read this BEFORE starting synth #3; each item is a
trap that cost real time here and is now a one-line check. The method itself
(dump → Unicorn oracle → transcribe → null EXACTLY 0) is unchanged; these are
the sharp edges inside it.

## The repeatable recipe (proven twice: JUNO, then JX-3P)
1. Stand up the oracle: `jx_emu.py` is a twin of the JUNO emulator — same
   BUILD/ALLOC/DISPATCH/WRAP entry pattern, FTZ|DAZ MXCSR, import stubs. Re-point
   the RVAs; the machinery is reused whole.
2. Transcribe each DSP method; null it EXACTLY 0 vs the oracle over dense inputs.
3. Recall is SEPARABLE: per-pool byte→coefficient LUTs + a few read-modify
   setters. Prove 64/64 patches bit-exact against the plugin's own dispatch.
4. Integration A/B: oracle recall + oracle note-on seed the state, then the C
   render (voice arms + master) is compared byte-exact vs the plugin's own
   render, over 64 patches × rates × long blocks. Green = `make verify-jx3p`.

## Traps, each seen to fail before it was believed

1. **The reinterpret trap.** A helper that returns `__m128` and is consumed as
   `.m128_f32[0]` must be fed a lane-0 BIT reinterpret, not a numeric `double`
   convert. Fed wrong, it silently corrupts. Baked into the translate tools now.

2. **Statically-linked CRT math (playbook 79).** `expf`/`tanf` are NOT in the
   import table — they live in the binary (expf @0x722EA0, tanf @0x725150,
   byte-identical to JUNO's copies), each opening with a CPU-feature dispatch on
   a .data flag that is 0 in a fresh image. The ORACLE runs the fresh image, so
   the NON-FMA path is ground truth. Calling host libm instead differs by 1 ulp
   on a few patches (here: 6 of 64, all voice-state, all LSB). CHECK THE IMPORT
   TABLE; if the math name is not imported, transcribe it from the binary.

3. **"Voice render" = arm + a TAIL step.** The plugin's per-voice call is a
   wrapper (0x377080) that dispatches to the arm (0x3A22C0) AND tail-calls
   0x3F40E0. That tail is the note-EXPIRY garbage collector (walks the note
   array at obj+0x58, compacts it, decrements the list pointers at +0x70/+0x78),
   NOT audio. Disassemble the WRAPPER, not just the arm, so you know what else
   runs each sample and whether it is DSP.

4. **Pointer-valued header slots never match across address spaces.** The C++
   object header holds live oracle addresses: vtable @+0x88, note-list base
   @+0x58, begin/end @+0x70/+0x78. Exclude them from state compares BY PROOF
   (disassemble the writer, confirm it is a pointer), never by guessing an
   offset range. A short block hides these (no note has expired yet); a long
   block exposes them — always null over a block long enough to cross note
   expiry, LFO wrap, and envelope segment edges.

5. **The 1-ulp signature is diagnostic.** Few patches, deep state words, LSB
   only, output often still bit-exact → a math kernel or a pointer field, NOT a
   logic defect. Do not go hunting the DSP; check imports (#2) and the wrapper
   tail (#3/#4) first.

## What is NOT yet carried (bounded, sized)
- The note-on / voice ALLOCATOR (sub_1803F9150 fan-out + per-object
  sub_1803F5F90, ~136 instr; the expiry GC 0x3F40E0). The integration A/B uses
  the oracle's note-on as a deterministic control-plane seed; the DSP it feeds
  is proven bit-exact. A device-standalone C engine still needs this allocator
  transcribed — the last mile, same method as everything above.

6. **A port that cannot PLAY from a clean boot is not a port** (charter §7b,
   user-found 2026-09-04). "DSP proven bit-exact" stopped this port one stage
   short: no allocator, no clean-construct, no shell hookup -- so no
   standalone sound. The stage is now mandatory and comes BEFORE any finish
   line claim. The allocator work below is that stage, not an appendix.
