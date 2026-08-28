# b38 — PROLOGUE-C1 implemented (flag off = identical); host gate + measure OWED

The prologue-c1-design-verify workflow (Opus: 4 study lenses, 1 max-effort
design, 3 skeptics) returned **GO, no skeptic refuted it**, bitexact_class =
**bounded-sonic-recall-only**. Implemented per that spec.

## What it does
Moves eb_engine_render_shared (the ~717-cyc shared prologue: noise LFSR +
voice-0 cvgate/glide + shared LFO) OFF core 0's per-sample loop. Core 1 computes
each chunk's n prologues in a BATCH, ONE CHUNK AHEAD, into a double-buffered
w_shb[2][CHUNK] — exactly the S3L_FX_PIPE pattern. Core 0 then renders voices
only; the per-sample w_ready handshake is gone.

Flag `S3L_PROLOGUE_C1` (default 0). OFF = shipping build verbatim (every edit is
`#if S3L_PROLOGUE_C1`). ON requires S3L_FX_PIPE=1 and S3L_VOICE_LO>=1 (both
compile-asserted); mutually exclusive with EB_PROLOGUE_PIPE / S3L_TIME_PROLOGUE.

## Why it is correct (the verification's finding)
Bit-exact for a STEADY patch: block K-1's ahead-batch computes exactly the
per-sample prologue values block K consumes; the state chain (glide[0]/lfo[0]/
notecv/LFSR) is unbroken, only computed one chunk early. Bounded-sonic ONLY at a
recall edge: the ahead-batch used the previous block's rc, so LFO/pitch-mod/
noise/gate land one chunk (2.9 ms at CHUNK=128) skewed — the SAME class as the
FX pipe the project already ships.

The one race all four lenses flagged — a voice reading glide[0].s560/.s880 while
the ahead-batch writes it — is SOLVED by the invariant that voice 0 is never a
rendered voice (S3L_VOICE_LO>=1, compile-asserted). A race the lenses MISSED is
fixed: core 0's per-sample zero range is narrowed EB_NUM_VOICES -> SPLIT_ (core 1
self-zeroes [SPLIT_,8)).

## Edits (all in esp32s3/main/juno_s3_listen.c)
1. flag + double-buffer state (w_shb[2][CHUNK], w_shb_valid, w_shb_rc[2]) + guards.
2. compile-assert S3L_VOICE_LO>=1 before worker().
3. render_block: PRIME the read bank on the first full chunk / short blocks only.
4. render_block core-0 branch: VOICES ONLY, zero [LO_,SPLIT_), read w_shb[w_cur].
5. worker(): no per-sample wait; voices read w_shb[w_cur]; then the AHEAD batch
   into w_shb[1-w_cur] BEFORE w_done=1 (so it never overlaps the quiescent
   window's gate/aux writes).
6. S3L_APPLY_ROW: invalidate the primed bank on a LAYOUT row change.

## OWED before any flash (in order)
- **prologue_gate.py/.c (host, PRIMARY):** drive the REAL engine fns, byte-compare
  batch-render vs serial-render over [LO_,8) for LO_>=1, 0 differ, 64 patches x
  chord masks. MULTI-CHUNK (prime/flip/valid), not single-chunk. Three teeth SEEN
  TO FAIL: LO_=0 staleness, double-advance, wrong-bank.
- **device canaries:** sw_by_voice (=0), prologue_seq (==blocks*CHUNK),
  bank_read_eq_write (=0), recall_skew_blocks (moves only on program-change).
- **THE DECISIVE MEASUREMENT:** whether moving ~717 cyc onto core 1 HELPS or
  REGRESSES the worst case (delay patches 5/16/21/49, where core 1+FX is already
  critical). PROLOGUE-C1 relieves core 0; those patches are core-1-bound. The
  board decides its net value — do NOT ship it enabled until the per-patch
  per-core WHOLELOOP numbers say it helps.

Nothing here is proven on silicon yet. Flag stays OFF until the host gate is
green AND the measurement says enable it.
