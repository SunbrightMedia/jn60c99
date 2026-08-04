# 1b-0 — the VOICE-LEVEL gate: engine B's render function, executed at last

Date 2026-08-04 (Opus 5), executing the ruling in `PHASE1_ORDERS.md`.

## The result, first

**`null_b.py --module voices`, all 30 scenarios, EXACTLY 0 against the port, at
BOTH 44,100 and 48,000 Hz.**

`eb_engine_render_voices()` — the sixteen gated modules plus the wiring between
them, driving engine B's OWN state from an `eb_render_coefs` built by
`eb_render_coefs_build` — reproduces the port's eight per-voice samples bit for
bit, on every sample of every scenario, including the five idle-prefix lengths.

## What this is NOT

It is the WEAKER gate, and the ruling labelled it so before it was built:

* **The master chain is still the port's.** Engine B's voice samples are fed
  into `juno_master_render` exactly as the port's were. The voice summing, the
  EFFECT-TYPE routing, the gain staging, the boost/output path and the stereo
  assembly are untranscribed (the scope finding: 946 of ~1,333 executable lines
  of `master_render.c`, 540 cells). `eb_engine_render`'s own mix and FX calls
  are not reached by this gate at all.
* **Recall is still the port's.** Coefficients come from the port's recalled
  cells. `eb_patch` is a separate, later, separately gated job.
* **The at-rest shortcut is still unproven.** The shim holds every voice awake,
  so `eb_render.c`'s `atrest` branch is not exercised here.

`render_ok` therefore stays unset in the shipped engine. This gate is 1b-0; the
standalone gate is 1b-2, after the master transcription (1b-1).

## The defects it found, which is why it was ordered

Eight wrong module inputs had already been found in `eb_engine_render` by
READING it. Running it found four more, and two of them were silent.

**1. The DCO oscillator levels were cached from the wrong cells (SILENT).**
`eb_coefs.c` gathered cells 4736/4752/4768 because the dco SHIM gathers them —
correctly, for the shim, which runs inside the port at a point where they have
already been written this sample. `src/voice_render.c` WRITES all three every
sample, at :1702-1707. Cached from a power-on state they are 0, so the DCO
emitted exactly 0 on every sub-sample and the whole chain nulled at 0.0 dB rel —
silence. The real chain is same-sample and lag-free: recall cell 4192 → 4240
(:1126) → v393 (:1667) → 4736 (:1702), all before the DCO reads it. 4192/4208/
4224 have no writer in the voice function and are the coefficients.

**WHY THE EXISTING CHECK MISSED IT, and this is the transferable part.**
`eb_coefs.c`'s header claimed every cell had been checked for a writer. The
check was `grep 'JF(a1, N) ='`. All three of these cells are copied as INTS,
with `JI`. **A cell-writer audit that names only one accessor is not an audit.**
`tools/engineb/coef_audit.py` now performs it mechanically, both accessors,
scoped to the constructor.

**2. Cell 5456 was cached too (LATENT).** Found by that new audit, not by ear
and not by the null. It is `eb_dcoprep`'s third output — `fmaxf(0, (cell3776 +
k6304) * k6320 + k6288)`, derived from the modulated pitch sum — and the
decimator's per-sample feedback term. `eb_render.c` discarded it as
`(void)pwm_out` while the decimator read a cached copy. MEASURED: fixing it
changed no sample of any scenario, so it was latent, not active — cell 5456 does
not move in the thirty scenarios. **The decim SHIM caches it behind the
generation guard too, and its null is EXACTLY 0, so that gate is blind to this
cell by scenario coverage rather than by construction.** `k5456` is now a
per-sample ARGUMENT to `eb_decim_tick`, so the type system refuses the mistake.

**3. The retrigger one-shot belonged to nobody.** Port cell 101504+v*32 is read
at :589 and cleared at :2178 — both OUTSIDE every module boundary. When armed it
forces that sample's cell-320 read to 0.0. No module claimed it, so a standalone
engine would silently never retrigger: the MONO-retrigger defect (e611f7d) all
over again, and invisible to every cold scenario. It is now `aux_edge` in
`eb_render_state`, consumed in the voice loop.

**4. THE LOCKSTEP DEFECT, and it is the one worth remembering.** Engine B's
state lives in file statics; the render worker creates one context per scenario
and renders all thirty IN ONE PROCESS. Without a per-context re-seed, scenario 1
seeded engine B and scenarios 2..30 inherited scenario 1's ENDING state.
MEASURED while it was live: **scenario 1 nulled EXACTLY 0 and all 28 others
failed from their very first frame, the first differing sample being 42000 —
exactly scenario 1's length.** It looks precisely like a broken DSP chain and is
nothing of the kind. Re-seeding is keyed on a marker in the unused tail of the
12 MB state block, not on the state POINTER: a freed block's address is readily
reused. `juno_driver_attach_host` is also called on re-init and on a chorus-mode
change, and those must NOT re-seed — re-seeding free-run state mid-scenario is
exactly what would mask a lockstep defect.

## Teeth

MEASURED at 48 kHz over all 30 scenarios.

| case | result |
|---|---|
| `out:voices:(1+3.16e-5)` | FAIL, −90.0 dB, 30/30 scenarios |
| `out:voices:(1+3.16e-6)` | PASS, −109.8 dB |
| `voicereseed` (lockstep: never re-seed a new context) | must FAIL |
| `voiceidleskip` (a gate-closed voice skips its state advance) | must FAIL |

`voicereseed` plants defect 4 above. A defect this harness actually let through
once is now a case it must catch every run.

**A THIRD "teeth case that could not reach its own mutation."** The output
anchor's perturbation is inserted on the line after the assignment, and the
crossing loop had no braces — so the statement landed outside the loop with
`v == JUNO_NUM_VOICES`, wrote one past the end of `vbuf`, and perturbed nothing.
MEASURED in that state: both bracket factors gave a residual of EXACTLY 0. The
uniqueness assert passed, because the anchor DID match once. **Matching is not
reaching.** The braces are now load-bearing and commented as such.

## Files

* `engine_b/eb_render.{h,c}` — `eb_engine_render_voices()` split out; the aux
  one-shot; `eb_engine_render` is now that plus the mix and the FX.
* `engine_b/eb_coefs.{h,c}` — the two cell corrections and
  `eb_render_events_mirror()`.
* `engine_b/eb_decim.{h,c}` — `k5456` promoted to a per-sample argument.
* `engine_b/shim/voices/juno_driver.c` — the shim, with its own scope note and a
  live differential tap (`-DEB_VOICES_DEBUG`) that runs the port's voice
  function alongside engine B's and reports the first differing (sample, voice).
  That tap is what isolated defect 4; it always emits ENGINE B's samples, so no
  build of it can pass vacuously.
* `tools/engineb/coef_audit.py` — the constructor's cell-writer audit.
* `tools/engineb/merge_shims.py` — whole-chain shims are excluded from the
  composite by name, with the reason.

## Groundwork for 1b-1 (measured, not yet transcribed)

The first master block was chosen the way every voice module's boundary was
chosen — by a live-variable analysis, not by eye.

**`src/master_render.c:826-886` — the MASTER INPUT STAGE: ZERO live-in, three
live-out (`v36`, `v38`, `v5`), 40 cells touched, 26 written.**

That is the same shape that made `eb_lfo` lift (four live-in, zero live-out).
It is the voice summing, the per-pair gain staging and the two channel signals
(cells 101104 and 101120) that the DELAY routing switch at :887 consumes.
`juno_host_sel(a1, 136)` at :887 is the natural end of the block: it is the
EFFECT/DELAY-TYPE routing read, and the routing switch belongs to the next
block, not this one.

The 26 written cells still need the read-before-write classification and the
FOUR LIES check before any of them may be called a coefficient — and the DCO
oscillator-level defect above is the standing reason to run
`coef_audit.py`-style checking on BOTH accessors, since `master_render.c`
copies with `_DWORD` as freely as `voice_render.c` copies with `JI`.
