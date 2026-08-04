# 1b-2 / O3 — THE STANDALONE GATE: engine B renders the whole instrument

Date 2026-08-04 (Opus 5), executing Fable's F1 ruling.

## The result

**`null_b.py --module standalone`, all 33 scenarios, EXACTLY 0 against the port,
at BOTH 44,100 and 48,000 Hz.**
**`plugin_check.py --module standalone`, 11/11 BIT-EXACT vs the PLUGIN, at BOTH
rates.**

Engine B produces every sample — the voice chain AND the master chain — from its
own state. `juno_voice_render` and `juno_master_render` are still linked and are
never called. The port supplies recalled coefficients and nothing else.

Teeth, MEASURED at 48 kHz: `out:standalone` 3.16e-5 FAILS at −90.0 dB in 33/33,
3.16e-6 PASSES at −109.8 dB; `seedpoison` FAILS in 21/33 at −85.2 dB.

## The order that is easy to get wrong

**The EFFECT stage runs AFTER the output is already formed.** The port writes
its output cells at :2367/:2375 and only then dispatches the effect arms at
:2378; the final samples are 2× those cells. An effect arm contributes NOTHING
to the sample it runs in — it writes cells 84672/84704, which the INPUT stage
reads on the NEXT sample. **The effect send is a one-sample feedback loop, not
an insert.** `eb_engine_render`'s previous master was a model that treated it as
an insert, and had no DELAY or EFFECT type dispatch at all.

## The five defects, and how each was found

1. **The delay CORE's outputs are crossed AND gained outside the module** —
   `v176 = v418*ebR`, `v177 = v418*ebL`. Passing them straight through swapped
   the stereo image. MEASURED as `portL == ebR` exactly, which is what made it
   unmistakable.
2. **The core's output gain (cell 101744) was never gathered.** A generator edit
   silently did not match its anchor, so the gain was 0 and the core emitted
   silence. Caught because the previous symptom (a clean swap) turned into a
   constant.
3. **The core needs a real 25-field seed, not a `memset`.**
   `juno_engine_prepare` leaves most of those cells non-zero. Seeding to zero
   made every DELAY-TYPE-0 patch fail at ~0 dB while type-5 patches drifted only
   in the last bits. **Two failure magnitudes in one gate meant two distinct
   causes**, and that split is what located it.
4. **The ring WRITE INDICES were missing from that seed** — masked loads, which
   the extraction regex did not recognise. Signature: the LEFT channel stayed
   EXACT and the RIGHT drifted starting at sample ~7,430, which is the delay tap
   depth. **A seed defect can wait a sixth of a second before it shows.**
5. **`rev_pending[33]` was ONE SHORT.** `EB_REV_NTAP` is **34**, so
   `eb_reverb_process` read one past the end and the last tap latched garbage.
   Invisible to reasoning: the reverb's A output stayed exact, only B drifted in
   the last bits. Found by exporting the PORT's own intermediates and comparing
   stage by stage (v530 diverged first), then comparing the two
   `eb_reverb_state`s BYTE FOR BYTE — first differing byte 196, which
   `offsetof` places inside `taps[33]`. **`eb_render.h` carried the identical
   off-by-one**; both are fixed.

## ★ The seed-poison case failed to fire, and that was a real measurement

Fable's F1 ruling required a teeth case that perturbs ONE seeded state field,
because the standalone engine seeds ONCE from a near-cold port and a missing
seed field whose post-recall value is zero would hide forever.

The first version perturbed `s->in.s84768`, the master input stage's one-pole
history, and **measured a residual of EXACTLY 0 on all 33 scenarios**. That is
not a broken test. Cell 84768 is multiplied by coefficient 84816, and **84816 is
0.0 in ALL SIXTY-FOUR factory patches (MEASURED)** — so its seeded value is
inert and that whole feedback path is dead for this bank. A teeth case pointed
at an inert field proves nothing, and would have been recorded as proof that the
seed is read. Re-pointed at `fb84704`, which carries the R channel, it fails
21/33.

## Memory, and one portability debt

**MEASURED over all 64 factory patches: the master chain's six delay rings need
6.10 MB** — three of 524,288 floats (2 MB each), three smaller, one of 1,024.
`eb_master_rings` is therefore CALLER-OWNED rather than a struct member: no
target this project aims at can afford that silently, and a member would let it
look affordable.

**⚠ `eb_delay_t23` and `eb_delay_t5` call `juno_pitch_poly` and `juno_triangle`,
which live in `src/juno_dsp.c` — the PORT.** Engine B cannot build for a target
without them. Found by LINKING the chain outside the harness for the first time;
the null gates link the whole port and would never have surfaced it.

## What is still refused

`eb_master_render` returns `EB_MASTER_UNSUPPORTED_ARM` for **DELAY TYPE 4** and
the **EFFECT LABEL_164 core** (EFFECT 0 and ≥ 6). No factory patch selects
either, so no scenario can gate them. Refusing loudly is the only honest option:
silence would be indistinguishable from a working effect nobody tested. That is
task **1b-3**, which needs a synthetic-recall gate first.

## The three residuals F1 ordered resolved inside 1b-2

Fable's ruling listed three things the standalone null was expected to settle.
Two are settled BY MEASUREMENT; the third is not reachable by this gate and
saying otherwise would be the over-claim this file exists to avoid.

**1. The `:1665-1671` delayed copies — RESOLVED.** Engine B does not model that
range. The standalone gate reproduces every sample of all 33 scenarios EXACTLY
at both rates, so those copies are either dead or already equivalent. A gate
that reproduces the whole output bit for bit has answered the question.

**2. The `dco_live` coefficient-copy equivalence — RESOLVED.** Same argument,
and this one is now actually EXERCISED: the standalone engine seeds `dco_live`
from the recall coefficients and drives it per sample, and the output is
EXACTLY 0 against the port. It was "believed, not gated" for months.

**3. The allocator's RETRIG / PORTA_GATE events — NOT RESOLVED, and this gate
cannot resolve them.** `eb_alloc` emits those events, and no CV module consumes
them yet. Under the standalone gate notes are still driven into the PORT by
`gui/juno_bridge.c`, and engine B mirrors the resulting cells (320 and the aux
one-shot) at generation bumps — so engine B's own note path never runs and the
events are never delivered. They belong to engine B's own recall and note
handling, which is task **O4 (`eb_patch`)**. Recorded as open rather than
counted as done.
