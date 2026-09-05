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

7. **The DAW is part of the instrument: boot through the HOST PARAMETER
   ENTRY, not bare dispatch** (robustness arc, 2026-09-04). The unhosted
   clean boot sounds wrong (unstable pitch, master EFX self-poisons) and NO
   blanket "write every DB default" vector fixes it -- REFUTED on the
   oracle. What a real host does differently, all READ/PROVEN from the
   binaries:
   - Parameter writes go through the host param entry (JX: rva 0x3F9A30;
     JUNO twin: 0x3C7AE0, byte-for-byte the same idiom), which runs the
     post-write refresh a bare DISPATCH (0x3EBB00) omits (JUNO proof:
     assigner stayed POLY without it, probes/assigner/).
   - After recall, active ramps are SNAPPED to their targets and
     deactivated, and the warm-up latch cleared (JUNO e2e snap_all /
     clear_latch -- validated bit-for-bit there).
   The binary's own parameter tables (name table rva 0x9D6C00; ENGINE DB
   rva 0x9C2C10, rows {min,max,default,flags}) name every id: 20 MASTER
   TUNE, 433+ Note (default 36 -- the audit's wrong-pitch red herring),
   249/619 OCTAVE (default 3), 798 PORTAMENTO. Ids 433-484 are EVENTS
   (Note/Gate/Mute) -- a host never writes them as parameters.
   Measurement discipline paid for twice here: zero-crossing f0 lies on
   complex tones (use autocorrelation), and a knockout sweep that restores
   state IN PLACE poisons every later trial -- fresh build per trial.

8. **A pointer in a link object points at a LIVE cell, never at a value to
   copy** (2026-09-05, the FREQ-MOD divergence). The voice objects reach
   two DWORDs through `obj+40` / `obj+64` (the master: `obj+136` /
   `obj+112`). The template captured the VALUES those pointers reached at
   clean boot and the bridge pointed the objects at its own copies. Recall
   rewrites the real cells, so every patch whose DCO FREQ MOD is 2 or 3
   (35, 46, 49, 51, 19, ...) diverged from its first sound sample while FM
   0/1 patches stayed EXACTLY 0. The JUNO paid this once already
   (`juno_driver_attach_host`: "Pointer wiring ONLY -- point at the ENGINE
   cell the per-patch recall writes"). Rule: for every pointer-valued slot,
   resolve WHERE it points (unit state offset / HOST / proc) with the oracle
   (`where()` in the recon probes) and wire the port's pointer to the SAME
   live cell of its own state. A copied value is a mirror; mirrors go stale
   (playbook 86).

9. **The controller's default push is part of the instrument** (2026-09-05,
   the master-FX arc). A DAW insert runs the DLL's static initializers
   (they build the host-id map) and the controller then writes EVERY
   parameter's default through the host param entry (0x3F9A30: host id ->
   engine id, frame conversion, dispatch flag 0, assigner notify). Without
   it the plugin's master carries two boot ramps (slots 541/542) whose
   values turn NaN and poison the EFX network at idle sample 3681 -- the
   C twin reproduced that exactly, so the 64/64 gate over 1200 samples was
   green on a master that dies at sample 3681. With it (`jx_emu.host_init`,
   416 writes, 0 failures) the master stays finite and the note rides the
   effects. Rules: (a) the gate window must reach past every known birth
   (12000 samples, not 1200); (b) "no host writes at insert" was an
   assumption -- the plugin's own entry point, run with the plugin's own
   defaults, is the only faithful host; (c) one NaN the push leaves behind
   (+0xAAC6F4, the STEP SEQ assign sentinel) is hosted state, excluded
   from the census BY OFFSET with its provenance written down.

10. **The host-id space is the CONTROLLER'S, not the engine's** (2026-09-05).
   The host param entry looks incoming ids up in a map the static
   initializers build (.data 0xCE9038). Host id 2 maps to engine id 20
   (MASTER TUNE). A default push that chose values by the HOST id's DB row
   wrote MASTER TUNE = "KNOB INDICATOR's default" and detuned every note
   by -39.5 cents -- while 413 of its 416 writes silently did NOTHING
   (unmapped ids return without writing). Rules: enumerate the map
   (`jx_emu.host_map()`), write only mapped ids, take each value from the
   MAPPED engine id's DB row; and count effective writes, not calls.

11. **Snap is the hosted steady state, not a convenience** (2026-09-05).
   The master's boot ramps 541/542 (limit 0.0, still active) drive NaN into
   the EFX network at idle sample 3681. Settling every active ramp to its
   limit and deactivating it (the JUNO's snap_all law) IS the state a host
   reaches; recall then re-arms the per-patch ramps. Export templates from
   the SNAPPED boot, and give every render gate reach PAST the latest known
   birth (12000 samples, not 1200).
