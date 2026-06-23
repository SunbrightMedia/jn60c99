# Capture-everything-once plan

The original philosophy: extract everything we'll ever need in one pass, then work
offline. After the long piecemeal phase, here is that single front-loaded session.
Three artifacts; then I work without sending you back to IDA.

## 0. Reset the database (removes all doubt after the force-kill)
Close IDA → delete the `JUNO-60(...).i64` → reopen the original
`JUNO-60(VST3 64bit).vst3` → let it auto-analyze. We lose nothing (all our work is
scripted reads; addresses come from the binary, so a fresh DB is identical). The
`.vst3` itself was never modified by IDA.

## 1. STATIC mega-dump — `tools/extract_everything_static.py`  (safe, no debugger)
On the fresh DB: **File → Script file… →** it. Dumps, in one go:
- all **8 voice-render** functions (decompile + asm) — for polyphony;
- the voice **dispatch + lifecycle** (host glue);
- the **note/MIDI path**: ranks & dumps functions that touch the voice-trigger
  fields (gate `101504`, …) — this is how a MIDI note becomes voice params.

Output `everything_static/` → zip & upload. (This is read-only and can't hurt
anything.)

## 2. RUNTIME full-state dump — `tools/dump_full_state.py`  (one debugger session)
Instead of cherry-picking 349 offsets, dump the **entire ~11.5 MB engine state**
twice (t0/t1). Offline I can then extract any coefficient, tell coeff-vs-state by
diffing t0/t1, read per-voice values, and find the played note's pitch — without
ever returning to the debugger.
- Host: load the **patch + chorus mode** you want, **hold a sustained note**,
  audio running, settle ~1–2 s.
- IDA attached (Local Windows debugger), process suspended.
- **Run the script once** → it arms the breakpoint and resumes. *Watch IDA stop at
  the master* (disasm jumps to `sub_180363380`) — that's your proof it works. (If
  it never stops: audio engine isn't processing — CPU meter / track frozen /
  bypassed.)
- **Run it again** → it writes `state_dump/state_t0.bin`, `state_t1.bin`, `meta.txt`.
- Edit `meta.txt` to note the patch name, chorus mode, and which MIDI note you held.
- Zip `state_dump/` & upload.

Want multiple sounds later? Just reload that patch and repeat step 2 — same dump,
no new tooling.

## 3. AUDIO reference (for the A/B that proves correctness)
In Ableton, with the **same patch**, render a short MIDI clip (e.g. a held middle
C, then a couple of notes) to a **WAV**. That's the ground truth we diff our port
against — the only thing that ultimately proves "this is the plugin", not a guess.
Note the exact MIDI + sample rate.

## After upload
From these three I work entirely offline: apply the real coefficients, build the
A/B harness, do polyphony and the note mapping. No more live-debugger sessions
unless you want to capture another patch.
