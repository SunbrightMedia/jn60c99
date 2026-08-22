# THE ONE IDA RUN — cold boot to files in Claude's hands

You open IDA once. This is every step, and what proves it was enough.

## ⚠ Why you are running this a second time — my bug, named

The first dump was INCOMPLETE and the fault was in my extractor, not your run.
The old script discovered functions two ways — a call-graph walk and a blanket
`.rdata` function-pointer sweep — and capped the walk at 6000 functions. The
sweep pulled 275+ JUCE/Gdiplus/CRT functions into the set; the cap then crowded
the real DSP out. Result: **132 of 185 DSP methods had no decompile** — the
entire filter, envelope, amp, LFO and phaser voices were missing. My
completeness self-check caught it before a single line of port code was
written, which is exactly its job, but it cost you one extra run. Sorry.

This script is the fix. It cannot truncate the DSP, and I proved that against
the JUNO binary before asking you to open IDA again (see the contract below).

## Does one run get everything? YES — here is why this one does.

The render leaves — the per-sample voice/master/effect helpers — are reached by
**indirect dispatch**, so no call-graph walk can see them. I measured this on
the JUNO: a direct-call closure from every DSP method reaches 154 functions and
**none** of that port's four hand-found leaves.

What reaches them is an **address band**. MSVC lays a class's methods and the
helpers they dispatch to into one contiguous slab of `.text`. Every JUNO leaf
sits inside the band from the lowest DSP method to the highest parameter-class
method, ±0x10000. Proven, both binaries:

    JUNO band 0x346150..0x3CCD80 = 1282 functions — all 4 leaves + engine
              BUILD + NOTEON/NOTEOFF + the per-sample wrappers IN, 44,000
              CRT/GUI functions OUT.
    JX   band 0x3486E0..0x3FEB70 = 1291 functions — every DSP method + the
              master process the OLD dump MISSED IN.

The band is a bounded address range, not a capped graph walk, so it physically
cannot lose a DSP method. Two call-graph closures (callees down, callers up two
levels) are added only as belt-and-suspenders for any straggler outside the
slab. The `.rdata` sweep that caused the first failure is gone.

## STEP BY STEP

1. **Open the binary.** IDA Pro → File → Open → `JX3P.vst3`. Accept the PE64
   defaults. Let it auto-analyse.

2. **WAIT for auto-analysis to finish.** Bottom-left status must read
   **`AU: idle`**. On a 14 MB DLL this can take several minutes. The dump is
   only complete on a finished database — do not skip this.

3. **Run the script.** File → Script file… → select
   `jx3p/tools/ida_extract_all.py`.

4. **Watch the Output window.** It prints one line per phase:
   `phase 1 … vtables`, then the band extent and its function count,
   `phase 2b … closure`, `phase 3 … decompiling N functions (the slow phase)` —
   the minutes-long part, a counter ticks — then constants, layout, and it ends
   with the two lines that matter:

       === DONE. Zip <dir> and send it. ===
       COMPLETENESS: M/M DSP vtable methods decompiled.

5. **CHECK THE COMPLETENESS LINE before you zip.** It must read **M/M** (the
   two numbers equal) and say `ALL methods present. One run was enough.` If it
   instead says `*** INCOMPLETE`, it prints the exact missing method RVAs —
   copy that line to me and DO NOT treat the dump as final; that is the whole
   point of the check being in IDA's window, not discovered after upload.

6. **Find the output.** A folder `jx3p_dump/` next to the `.i64` database
   (same directory as the `.vst3`).

7. **Zip it.** Right-click → Send to → Compressed folder, or
   `Compress-Archive jx3p_dump jx3p_dump.zip` in PowerShell. It will be large
   (tens of MB of decompiled C — expected and good).

8. **Send `jx3p_dump.zip` to Claude.** Upload it here.

## THE COMPLETENESS CONTRACT — how one run is proven enough

The zip carries `manifest.json`. On receipt I check, before writing a line of
port code:

* **every DSP method decompiled** — `methods_decompiled == concrete_methods`
  and `methods_missing` is empty. This is the same M/M the Output window showed;
  I re-verify it against the actual `fn_*.c` files, not the report.
* **the render leaves present** — each voice/filter/env/osc/effect process
  method's callee tree bottoms out in a decompiled function, not a dangling
  address. The band guarantees the in-slab leaves; the closure covers any
  outside it.
* **the parameter registry present** — the patch-byte → coefficient appliers
  (the `CPrmDSP*` methods and their callees) are decompiled, or the port cannot
  recall a patch.
* **the constant tables have VALUES** — `03_constants.txt` shows `f32:`/`i32:`
  arrays, not just addresses.
* **the `.Dat` question answered** — if any decompiled function opens
  `Code1.Dat`/`Code8_*.Dat`, I see the call and tell you which files are needed;
  if none does, they are irrelevant and the port ignores them (the leading
  reading — the JUNO port needs no `.Dat` at all).

If — and only if — a specific, named gap survives that check, I tell you the
exact class or address missing and why, so a follow-up is surgical, not another
blind full run. The design intent, now measured on the JUNO and on the JX class
inventory, is **one run, complete.**

## If IDA's Hex-Rays is unavailable

The script still dumps disassembly (`01_closure.asm`), all constants, vtables,
and the manifest — everything except the `.c` decompile. Transcription is
slower from asm but not blocked. Send the zip regardless; I will say whether the
decompile is present and usable.
