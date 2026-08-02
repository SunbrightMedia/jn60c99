# MODULE M-VCA — the VCA + HPF output stage. RESULT.

`src/voice_render.c:1516-1640` -> `engine_b/eb_vca_hpf.{c,h}`,
gate `engine_b/shim/vca_hpf/`, run with
`python3 tools/engineb/null_b.py --module vca_hpf`.

Landed 2026-08-02. The module's source and shim were swept into commits
`78c2784` and `1e54baa` by `tools/autosave.sh` while a parallel workflow ran;
this file is where its measured numbers live.

## Verdict in one line

**ACCURATE — null 30/30 EXACTLY 0, no approximation anywhere. NOT AFFORDABLE —
1,543 cyc/sample on the S3, 67% of the ~2,300 that remain after the envelopes,
and the one obvious lever was implemented, measured and is dead.**

## 1. Accuracy — MEASURED

`null_b.py --module vca_hpf`: 30 scenarios, 30 PASS, residual **EXACTLY 0** in
every one, including all 17 idle-prefix scenarios (1 / 48 / 441 / 4410 / 44100
idle samples before the note, over the chorus, unison and noise patches). There
is no approximation in the module, so the standard applied is bit-equality, not
-100 dB.

| scenario | signal | residual |
|---|---|---|
| pluck POLY | -29.2 dBFS | EXACTLY 0 |
| MONO retrigger | -20.6 | EXACTLY 0 |
| UNISON pile-up | -28.6 | EXACTLY 0 |
| chorus pad | -23.1 | EXACTLY 0 |
| delay keys | -23.6 | EXACTLY 0 |
| MONO glide | -30.2 | EXACTLY 0 |
| long LFO+tail | -29.7 | EXACTLY 0 |
| DCO noise | -32.4 | EXACTLY 0 |
| DCO reset arm | -13.1 | EXACTLY 0 |
| ENV trig arm warm | -11.7 | EXACTLY 0 |
| idle chorus 1 / 48 / 441 / 4410 / 44100 | -26.5 / -26.3 / -26.3 / -26.1 / -28.8 | EXACTLY 0 (all 5) |
| idle unison 1 / 48 / 441 / 4410 / 44100 | -23.4 / -23.4 / -23.6 / -26.5 / -32.3 | EXACTLY 0 (all 5) |
| idle noise 1 / 48 / 441 / 4410 / 44100 | -31.1 / -31.1 / -30.8 / -31.4 / -35.4 | EXACTLY 0 (all 5) |
| realloc unison | -27.2 | EXACTLY 0 |
| realloc chorus | -28.1 | EXACTLY 0 |
| DCO neg pitch sweep | -30.5 | EXACTLY 0 |
| DCO neg wrap + PWM clamp | -31.7 | EXACTLY 0 |
| DCO neg warm chorus | -30.5 | EXACTLY 0 |

## 2. Non-vacuity — MEASURED, three planted errors

| plant | scenarios failed | worst global | worst block |
|---|---|---|---|
| tone filters' feedback taps swapped (the "3-tap FIR" misreading) | **15 / 30** | -8.8 dB | -3.0 dB |
| boost path x 1.5 | **13 / 30** | -- | -- |
| output x 1.00003 | **30 / 30** | -90.4 dB | -90.2 dB |

The 15 scenarios that survive the tone swap have AMP TONE `[9584]` = 0, so the
crossfade selects the dry path in both engines and the two filters are
multiplied out.

## 3. Two gate holes, found and reported rather than worked around

Two "algebraically identical" regroupings — exactly the class that cost this
project 8,388,608 wrong samples in `eb_triangle` — null **EXACTLY 0** in all 30
scenarios and are therefore INVISIBLE to this gate:

1. `y = vcf + [10256]*(boost - vcf)` in place of the source's
   `[10256]*boost + vcf*(1-[10256])` (:1591/:1599).
2. `vel = [9616] + [9600]*(sm - [9616])` in place of the source's
   `([9600]*sm - [9600]*[9616]) + [9616]` (:1527).

For (1) the reason is now EXECUTED rather than guessed: `[10256]` is
`juno_curve(52, byte)`, and running that curve over all 256 bytes gives **0.0 at
byte 0 and 1.0 at bytes 1..255 — never an intermediate value**; `src/hpf_type_lut.c`
independently states it is constant 1.0 for HPF TYPE=1. So the HPF SWITCH is a
switch over the WHOLE reachable parameter domain, not a crossfade. Instrumenting
the module confirmed both 0.0 and 1.0 occur across the 30 scenarios.

**Both source forms are kept anyway.** With t = 1 the two expressions differ by
whether `a + fl(b-a) == b`, which is an observation over these signals and not a
theorem. Keeping the port's own parenthesisation costs nothing and removes the
question.

## 4. Cost — MODELED (`cost.py measure ... --calls eb_vca_tick=8`)

| target | static instr (tick) | cyc/call | cyc/sample (8 voices) | band |
|---|---|---|---|---|
| host x86-64 | 215 | 54 | **435** | 285 .. 1,366 |
| M7 (Daisy) | 188 | 203 | **1,634** | 827 .. 5,350 |
| **S3 (TARGET)** | 207 | 193 | **1,543** | 958 .. 4,106 |

Against the **~2,300 cyc/sample that remain after the two ADSR envelopes**, the
S3 nominal is **67%**. Against the whole 3,500 budget it is 44.1%.

## 5. The lever, priced — and it is DEAD

Split measurement (same arithmetic, two functions, `cost.py`, S3):

| half | contents | cyc/sample |
|---|---|---|
| control | velocity + mute smoothers, gate ramp, VCA source combine, level | **831** |
| audio | HPF/boost, output gain, DC block, tone crossfade, final gains | **680** |

54% of the module is the control half, which carries no audio bandwidth — the
obvious lever is to run it at 1/N rate and hold the results. **IMPLEMENTED AND
MEASURED at N = 16: 30 of 30 scenarios FAIL, worst global +3.9 dB rel, worst
block +8.9 dB rel** — the error is LOUDER than the signal. The gate ramp and the
level multiply the audio every sample and both move fast; they are not control
rate. Best case in the sweep was `idle chorus 44100` at -60.9 dB global, still
39 dB above the standard, and its worst block was -26.0 dB.

No cheaper option with an acceptable measured error was found. The residual
levers not yet priced are small and exact: three coefficient-only products
(`[9600]*[9616]`, `[10224]*[9552]`, `1-[10256]`) could be folded at recall,
which removes 3 of the tick's 96 FP-arithmetic instructions.

## 6. What velocity actually does here (the task asked)

`[9680]` is written ONLY at note-on, as `juno_curve(57, velocity)`
(`src/juno_note.c:195`). It is smoothed one-pole by `[9744]`, blended against
the FIXED-velocity level `[9616]` by the VEL SENS amount `[9600]`, smoothed
AGAIN by `[9808]` and clamped at 0 to become the first output gain `[9776]`.
So velocity is a per-note SCALAR into a two-stage smoother and nothing else in
this range — with VEL SENS = 0 the played velocity has no effect at all. The
wrapper's default (Kbd Vel SW OFF -> every note forced to velocity 100) only
fixes the value fed to curve 57; it changes nothing about this module's shape.

## 7. Saturation / clipping

There is **none** in this range. The only clamps are `max(0, ...)` on the two
output gains and on the VCA level, and a `clamp(-1, +1)` that limits a RATE
inside the gate ramp, not the audio. `[10672]` may exceed +/-1.0 and engine B
does not clamp it.

## 8. State size

`eb_vca_state` is **40 bytes** (10 floats) per voice, against the port's 71
cells (1,136 bytes) for the same information. Four latches (:1516-1520) are
aliases and not delays — they are read LATER IN THE SAME SAMPLE; 19 cells are
write-only shadows; the DC blocker's three cells are one recurrence; and the
tone shift chain is three named floats.

## 9. Blueprint

`docs/trackb/CELLMAP.md` §§ V..AB and "V..AA. VCA + output" AGREE with the
oracle on this range, including both traps it flags (the tone stage is
recursive, not an FIR; the HPF mix really does form the (1-t) complement while
every other blend in the range is distributed). **No blueprint correction is
owed for lines 1516-1640.**

## 10. Owed

A `docs/trackb/EQUIVALENCE.tsv` row via `tools/engineb/ledger.py`. Not added
here because a parallel workflow held uncommitted edits to `ledger.py` for the
whole session and committing it would have swept their work.
