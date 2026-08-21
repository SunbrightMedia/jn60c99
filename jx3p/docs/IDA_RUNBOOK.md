# THE ONE IDA RUN — cold boot to files in Claude's hands

You open IDA once. This is every step, and what proves it was enough.

## Does `extract_dsp.py` get everything? NO — that is why this exists.

The JUNO port needed EIGHT separate IDA scripts, discovered one gap at a time
(`extract_dsp`, `_tables`, `_init`, `_param_setter`, `_param_meta`,
`_master_deps`, `_everything_static`, `_host_layer`). One of them is literally
named "everything_static … so we never come back" — and they came back anyway.

`jx3p/tools/ida_extract_all.py` is the union of all eight PLUS the two gaps that
caused the repeat visits, in one pass. Validated against the JUNO binary: its
two discovery mechanisms together reach all four of that port's known-critical
targets (voice render, master, parameter registry, chorus-coefficient
generator) — the first two by call-graph, the last two by the `.rdata`
function-pointer sweep a plain call-graph misses.

## STEP BY STEP

1. **Open the binary.** IDA Pro → File → Open → `JX3P.vst3`. Accept the PE64
   defaults. Let it auto-analyse.

2. **WAIT for auto-analysis to finish.** Bottom-left status must read
   **`AU: idle`**. On a 14 MB DLL this can take several minutes. The dump is
   only complete on a finished database — do not skip this.

3. **Run the script.** File → Script file… → select
   `jx3p/tools/ida_extract_all.py`.

4. **Watch the Output window.** It prints one line per phase:
   `phase 1 … vtables`, `phase 2 … closure`, `phase 2b … function pointers`,
   `phase 3 … decompiling N functions (the slow phase)` — this is the minutes-
   long part, a progress counter ticks — then phases 4–6, ending with:

       === DONE. Zip <dir> and send it. ===
       N decompiled functions, M constant tables, K classes.

   Note those three numbers; step 7 checks them.

5. **Find the output.** A folder `jx3p_dump/` next to the `.i64` database
   (same directory as the `.vst3`).

6. **Zip it.** Right-click → Send to → Compressed folder, or
   `Compress-Archive jx3p_dump jx3p_dump.zip` in PowerShell. It will be large
   (tens of MB of decompiled C — that is expected and good).

7. **Send `jx3p_dump.zip` to Claude.** Upload it here.

## THE COMPLETENESS CONTRACT — how Claude proves one run was enough

The zip contains `manifest.json`. On receipt Claude checks, before writing a
line of port code:

* **every DSP class present** — all `CDSPJx3p*` from `00_vtables.txt` appear
  with a decompiled `fn_*.c`. The JUNO had ~19 concrete DSP classes; the JX
  inventory is already known (S1), so a missing one is caught immediately.
* **the render leaves present** — each voice/filter/env/osc process method's
  callee tree bottoms out in a decompiled function, not a dangling address.
* **the parameter registry present** — the patch-byte → coefficient appliers
  (phase 5) are decompiled, or the port cannot recall a patch.
* **the constant tables have VALUES** — `03_constants.txt` shows `f32:`/`i32:`
  arrays, not just addresses.
* **the `.Dat` question answered** — if any closure function opens
  `Code1.Dat`/`Code8_*.Dat`, Claude sees the call and tells you which files are
  needed; if none does, they are irrelevant and the port ignores them.

If — and only if — a specific, named gap survives that check, Claude tells you
the exact class or address missing and why, so a follow-up would be surgical,
not another blind full run. The design intent and the validated expectation is
**one run, complete.**

## If IDA's Hex-Rays is unavailable

The script still dumps disassembly (`01_closure.asm`), all constants, vtables,
and the manifest — everything except the `.c` decompile. Transcription is
slower from asm but not blocked. Send the zip regardless; Claude will say
whether the decompile is present and usable.
