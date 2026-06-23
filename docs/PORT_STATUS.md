# Port status & the chorus/driver boundary

Honest accounting of what is ported exactly, what remains, and what is **not in
our extracted data**. The user asked for hard truth over guesses; this records it.

## Ported — exact, compiling, tested
| Piece | Source | Notes |
|-------|--------|-------|
| `juno_wrap24`, `juno_triangle` | 0x368D60/0x368FC0 | leaf helpers, self-checked |
| `juno_voice_render` | 0x180369070 | full synth voice (DCO, 4-pole VCF, ADSR×2, VCA, unison bank); all helper args from asm |
| `juno_engine_init` | 0x1803990C0 | 2293-store coefficient init, sample-rate aware |
| lookup tables | .rdata | exponent + pitch tables, exact |

This is the synth core — the part the previous attempt got wrong. It is done.

## Multi-voice instantiation — solvable from our data
The 8 voice renders are one routine at different bases. Per-voice region strides
(verified by diffing voice 0 vs voice 1 offsets):
- main voice block (≈ offsets 320–10672): **+10512 per voice**
- shared/global block (84272–84432): **+0** (all voices read the same)
- aux array (101504): **+32 per voice**
So one parameterised `voice_render` (or 8 generated copies) can serve all voices.
No extra data needed.

## NOT in our extracted data (do not fabricate)

### 1. The chorus DSP
The "chorus cluster" (0x3C52E0, 0x3C8120, 0x3C8390, 0x3C86A0, 0x3C87E0, 0x3C6F00)
is **entirely threading / task-queue plumbing** — zero float DSP (verified by
scanning all 129 closure functions: the only heavy float-math functions are the
8 voice renders). The audio worker loop `0x3C6F00` dispatches downstream work
through an **indirect vtable call** `(*(...+104))(...)` taken when `a2==0`; the
static call-graph walk in extract_dsp.py cannot follow indirect calls, so the
stereo BBD chorus routine was never captured. **Its code is not in `dsp_dump`.**

To port the chorus we must first locate it. Options:
- **Frida**: hook the indirect call site in `0x3C6F00` (or the process callback)
  to log the target function address at runtime, then one targeted IDA dump of
  that function (+ its coefficient init). Small and precise.
- **Static**: resolve the vtable at `*(obj+8)`, method `+104` — needs the class
  identity; harder without runtime.

### 2. Voice mix / output / note-trigger
`voice_render` writes a mono sample (overwrite) per voice; the summation of the 8
voices, the stereo output routing, and the MIDI-note → pitch/gate field mapping
live in the host/threading layer **above** our closure (the same indirect-call
boundary). A plain sum of voice outputs is the standard and almost-certainly
-correct behaviour, but it is an assumption, not transcribed. The note-on gate is
`*(state+101504)==1.0`; the pitch-field mapping is not in our data.

## Recommendation
The exact DSP core is complete. Reaching a *playable, chorused* engine needs the
chorus code located (one targeted Frida-assisted extraction) and the host glue
(mix/note-trigger) decided. Both are bounded; neither affects the already-exact
voice core. Decision for the user: locate the chorus now, or proceed to wire a
standard-sum driver around the exact voice core first.
