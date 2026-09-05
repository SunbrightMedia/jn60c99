# JX-3P — S3 STATUS (honest, dated by commit)

What is PROVEN, what is transcribed-not-proven, and the exact next steps. "Done"
means null EXACTLY 0; nothing below is called done that is not.

## ⚠ CORRECTION 2026-09-05 — THE DRIVE WAS WRONG (playbook 87)

Every oracle run before this date called setSampleRate (0x3F9970) with the
rate in RDX. The function reads a FLOAT from XMM1 (`tools/verify/abi_check.py`
proves it in one line). The engine never received a rate; every template,
recall aux and A/B reference was derived from that boot, and every gate
stayed EXACTLY 0 because BOTH sides ran the same wrong drive. What still
stands: the transcription reproduces the plugin bit-for-bit under a given
drive. What falls: every "plays / rates / bit-exact from a host state" claim
below, until re-derived through `jx_emu.boot()` (float SETSR) and passed
through `jx3p/tools/jx_listen.py` (PORT_PIPELINE step 4).

Listen facts on the CORRECTED boot (oracle, patch 0, note 60, all READ/PROVEN
by execution, `jx_listen.py` numbers):
- DCO1 WAVEFORM 1 (saw): clean C4, −1 cent, tone fraction 0.28. Pitch and
  note path are RIGHT.
- WAVEFORM 2..5 (patch A11 uses 2): only anti-alias spikes (~0.05), no
  waveform — a zero pulse-width/table source. Refuted as causes, each by
  measurement: DB-default vectors (raw and engine frame, flag 0 and 1),
  OCTAVE/TUNE ids, boot ramps, tempo/clock specials, assigner tick, per-sample
  vtable tick (a `ret`), missing pages (0 faults), C++ static initializers
  (842/845 run; fill 3.5 KB; id map now live), engine ctor slot 0, CRT FMA
  flag (legit SSE2 path). OPEN: the cell the pulse path reads for its width,
  and who writes it in a host.
- The old audit's "−2 octaves / note 36" reading was the ENGINE DB default
  for Note ids (36), not a pitch law — a red herring.

## ⚠ CORRECTION 2026-08-25 — READ BEFORE THE CLAIM BELOW

The "finish line" section below is **narrower than it reads**, on two counts
found the day after it was written:

1. **It was measured from an INVALID SEED.** The A/B's warm-up leaves the
   PLUGIN's own state containing NaN — master 8916 cells at the 32-pool config
   the green run used, 6569 at 57 pools, plus 2 cells in every voice. Both
   sides start identical, so the 64/64 EXACTLY 0 result is still a real proof
   that the C reproduces the plugin BIT-FOR-BIT from that seed. It is NOT proof
   that the port behaves correctly from a state a host would present, because
   that seed is not one. A seed-validity tooth now FAILS the harness loudly
   (`ab_render_emu.py`, seen to fail); the warm-up must be fixed before the
   claim can be restated. See `jx3p/docs/MASTER_NAN_FINDING.md`.
2. **It exercised 32 of 57 recall pools.** The parameter census was wrong when
   that run was made; see `jx3p/docs/SCOPE_AUDIT.md` and playbook 80.

What still stands unchanged: the voice arms, the master transcription, the
helpers and the binary's own expf/tanf reproduce the plugin bit-for-bit
wherever they were compared, and the recall is 64/64 EXACTLY 0 on two banks.
What is NOT established: correct behaviour from a clean start state.

## ★ FINISH LINE (as claimed 2026-08-24 — see the correction above)

One self-proving command over the checksummed JX3P.vst3:
- **Recall** (patch bytes → coefficient state): C == the plugin's own dispatch,
  **64/64 patches EXACTLY 0**.
- **Integration render** (recall → note-on → per-sample 8 voice arms + master):
  C == the plugin's own render, byte-exact on the seam, L/R, and every DSP
  state word, **64/64 patches × 3 rates (44100/48000/96000), all EXACTLY 0**.

The whole audio signal path — recall, voice, master, and the binary's own
`expf`/`tanf` — is bit-exact. Gate: `make verify-jx3p`. Lessons for the next
port: `jx3p/docs/PORT_LESSONS.md`.

**Charter §7b (THE PORT MUST PLAY) progress:**
- **NOTE MANAGERS: TRANSCRIBED AND PROVEN (2026-09-04).** The 9-unit layer
  behind NOTEON 0x3F9150 / NOTEOFF 0x3F90F0 (bodies 0x3F5F90/0x3F5EF0, the
  list/map/history machinery, all five setters) is `jx3p/src/jx_alloc.c`,
  a bit-literal blob transcription. Gate: `jx3p/tools/jx_alloc_gate.sh` —
  oracle replay vs C twin over 4,000 mixed events: 22,008 seam events and
  9×0x7A8 state bytes EXACTLY 0; the tooth (sustain branch removed) bites.
  Two-process rule respected (emu writes, ctypes reads). Includes the
  plugin's own −1-history-index aliasing quirk, reproduced literally.
- **NOTE STORE, KEY TRACKER, DISPATCH HANDLERS: PROVEN (2026-09-04).**
  jx_nstore.c / jx_ktrack.c / jx_dispatch_note.c, each with its own
  two-process gate and bitten tooth (jx_nstore_gate.sh, jx_ktrack_gate.sh,
  jx_dn_gate.sh).
- **§7b FINISH LINE GREEN (2026-09-04): THE PORT PLAYS STANDALONE.**
  jx_full_gate.sh: the plugin drives ITSELF end-to-end (fresh build, SETSR,
  order-true recall, NOTEON, render, NO pokes) vs the standalone C engine
  (jx_bridge.c: clean-boot template + recall aux + the transcribed control
  plane + wrappers/latch/ramps + the proven renders): L/R bit streams
  EXACTLY 0 over 1200 samples on patches 0/5/20/49, one-semitone tooth
  bites. The gate found and paid four real defects on the way: the
  untranscribed wrapper/latch/ramp layer, missing master recall, missing
  voice high windows, and a POLLUTED recall reference (playbook 86).
  Web app: jx3p/gui/web (WASM, browser-verified; mirrored to docs/jx3p).
- **Still open (logged):** the TRUE host recall protocol (two harness pool
  models disagree 13 pools each way; factory play uses order-true oracle
  deltas), the nstore drain seam 0x3EF210 (stubbed in every proof; never
  fired in the green runs), WASM has no FTZ (denormal caveat, host gates
  carry real FTZ), and rates 48000/96000 for the full chain.
Everything below this line is older working notes.

## PROVEN (null EXACTLY 0 under Unicorn, FTZ|DAZ)

- **The IDA dump is complete** — 305/305 concrete DSP methods (S3_DUMP_RECEIPT).
- **The JX oracle** (`tools/verify/jx_emu.py`) — BUILD 0x3F8610 constructs 9 units
  (STATE_SZ 0xAAC310, HOST layout = JUNO's), render path via VOICE_WRAP 0x377080
  / MASTER_WRAP 0x377010, ALLOC 0x6AB63C, DISPATCH 0x3EBB00. Runs FTZ|DAZ (0x9FC0)
  to match the plugin FP env. Proven by execution, zero faults.
- **The voice render** — `jx3p/src/jx_voice_render.c`, one function covering all
  8 per-voice arms (0x3A22C0..0x3D6110) via the 16128*v stride. Null EXACTLY 0:
  8 voices x 32 samples, 0 output + 0 state bytes. This is the largest/hardest
  DSP module.
- **All 6 voice helpers** — `jx3p/src/jx_voice_helpers.c` (39A250, 3A2010, 3A2180,
  3A2210, 3A9950, 3A21E0). Null 0/54638 over dense full-domain sweeps.

The reusable win: the null caught the reinterpret trap (helper 3A2210 fed a bare
`double` carrier -> numeric convert instead of lane-0 bit reinterpret). Baked
into both translate tools now.

## PROVEN — the master render (added this session)

- **The master render** — `jx3p/src/jx_master_render.c`. Nulls EXACTLY 0 against
  the oracle on the default note state: L/R output 0/32 mismatches AND the full
  11 MB state 0 bytes differ. Harness: null_master_emu/_c (a2 = 8 voice-main
  outputs byte-addressed; note-object chain at st+136 relocated; SNAP = full
  STATE_SZ). The whole core DSP signal path (voice + master) is now bit-exact.
  Caveat: the 11 argless helper sites are DCO-mode/effect-gated (v31<=3 via the
  note object) and NOT reached by a sustained note, so they are placeholdered and
  unproven until a mode-selecting patch (recall) exercises them.

## (superseded note) master render — earlier blocker

- **The master render** — `jx3p/src/jx_master_render.c` from
  `translate_jx_master.py`. Single unit, plain offsets (rsi=a1 confirmed).
  Blocker: **11 argless helper call sites** (Hex-Rays lost xmm0). They sit behind
  `ucomiss xmm1, 0; jnz` guards and were not exercised by the sustained-note test
  state, so the emu arg-capture returned nothing. They MUST be resolved from asm
  (01_closure.asm) to compile and null. The sites and their asm patterns:
    * 3A2010 x4 (rva 39AF01, 39B845, 39C193, 39EA39): arg =
      (double)(*(float*)(st+A) + *(float*)(st+B)), A/B = the movss/addss cells
      right before `cvtps2pd xmm0, xmm1; call`.
    * 3A21E0 x3 (39AF7B, 39B8B4, 39C202): arg = xmm0_acc + *(float*)(st+cell),
      cell = the `movss xmm1,[rsi+cell]; addss xmm0,xmm1` before the call.
    * 3A2210 x4 (39AF83, 39B8BC, 39C20A, 39EAF0): arg = the immediately preceding
      3A21E0 result (movaps xmm6,xmm0); at 39EAF0 arg = the fmodf/subss chain.
  Once resolved: build a null_master harness (MASTER_WRAP, 16 voice-input ptrs +
  L/R out) and null EXACTLY 0.

  DEEPER FINDINGS (this session):
  * The master render is `sub_18039A2B0(a1, a2, a3)`: a1=state8, a2=array of 16
    ptrs (8 voices x {main,sub} outputs, read at decompile 1015-1022), a3=L/R
    out (written at the tail). MASTER_WRAP passes a2/a3 through rdx/r8. Confirmed
    by direct call (entry executes, returns L/R ptr).
  * MASTER_WRAP 0x377010 gates on `*(a1+20)` (enable) and a warmup latch
    `*(a1+11191048)` (>0 => skip render, decrement) -- clear both to run it, or
    call 0x39A2B0 directly.
  * The 11 argless sites are NOT reachable from a default single-note state:
    they sit under DCO-mode guards (`if (v31 <= 3)` + waveform selector
    `*(a1+11191052)`), i.e. they are the effect/oscillator-mode paths. Exercising
    them needs a patch that selects those modes -> depends on recall (task 9).
  * Partial resolution proven from decompile+asm:
      - 3A2210 arg is CLEAR: the immediately preceding 3A21E0 result (v235 etc.)
        -> `*(float*)&vN = jx_h_3A2210(v_prev_result);`
      - 3A2010 arg = (double)(*(float*)(a1+A) + *(float*)(a1+B)), A/B the
        movss/addss cells before `cvtps2pd` (rsi=a1, so direct).
      - 3A21E0 arg = phase-accumulator wrap: xmm0=[cell] + a conditional
        wrap of (clamped-2010-result * [cell]); needs full asm reconstruction of
        the comiss/addss wrap chain (the one genuinely intricate sub-task).
  * Recommended order: do RECALL first (task 9) so a mode-selecting patch can
    drive the master's argless branches under the oracle; then the emu arg-capture
    resolves 3A21E0 mechanically instead of by hand, and the master nulls.

## REMAINING

- **Recall in C** (next). RECON DONE this session: the dispatch 0x3EBB00 accepts
  param writes and the full engine (recall -> note-on -> voice+master render)
  runs end to end with ZERO faults (128/128 nonzero samples). BUT the JUNO blob->
  param byte mapping produces peak~=0 output on JX -- the JX blob layout differs,
  as S1 predicted, so the binding MUST be derived (perturb-and-diff per param).
  SCOPED: the dispatch 0x3EBB00 is a binary-search router
  on param index that DELEGATES to ~149 virtual param-setter methods
  (`(*(*a1 + vtoff))(a1,a3,a4)`), not a self-contained applier. So recall follows
  the JUNO's proven method: run the dispatch under the oracle per parameter to
  recover {blob_pos -> (curve/offset)}, port a curve evaluator + binding map in C,
  prove the post-recall coefficient state matches the oracle's bit-for-bit. This
  also supplies the mode-selecting patches that exercise the master's 11 argless
  branches (closing that gap).
- **Effects** modules (EfxCh chorus, EfxPh phaser, EfxCr, EfxDs/Od/Fz) — each a
  CDSPJx3p class in the dump; transcribe + null like the voice/master. Some are
  invoked inside the master chain (the master already nulls, so those paths that
  run are covered; standalone effect entries still need their own null).
- **make verify SYNTH=jx3p** — the finish line: null EXACTLY 0 across all 64
  factory patches x rates x block sizes, tying recall + render together.

## The method is proven; the remainder is volume

The voice render proves the whole pipeline end to end (dump -> transcribe ->
oracle -> null 0). Every remaining module follows the same path. The master's
argless resolution is the only novel sub-task; after it, effects and recall are
repetitions of proven steps, and make verify is the gate that ties them together.


## RECALL PROGRESS (this session)

- Per-param coefficient derivation WORKS via the plugin's own dispatch under
  Unicorn (PROVEN-executed, binary-derived -- the JUNO's legitimate method, not a
  capture): 43 params move 366 coefficient cells; captured value->coefficient
  LUTs (jx3p/gen/recall_luts.json).
- LUT-reconstruction of a full factory patch matches the oracle dispatch on
  348/366 cells (95%). The 18 remaining are CROSS-PARAMETER interactions:
    * shared cells (e.g. cell 4000 written by params 801 AND 858 -- a read-modify
      where 858's result depends on 801's coefficient), and
    * value-INDEPENDENT constant writes my v0-vs-v255 detection missed (e.g.
      cell 13504, written by no param in isolation).
  These need the specific virtual setters transcribed (the dispatch routes each
  param to *(*proc + vtoff)); most params are clean LUTs, a few are read-modify.
- Dispatch is deterministic (0 cells vary on re-run), so a faithful sequential
  recall is well-defined.

## REMAINING TO THE FINISH LINE (honest)

1. Recall interactions: transcribe the ~few read-modify/finalize setters (or model
   them) so all 366 cells match, per unit (voice units 0-7 + master).
2. Full-engine integration in C: recall -> note-on -> per-block 8-voice + master
   render + the assigner/note logic, as one jx_engine.
3. Effects standalone nulls (those not already covered inside the master).
4. make verify SYNTH=jx3p: null EXACTLY 0 across 64 patches x rates x blocks.

The DSP core (voice + master render) is proven; recall is 95% and scoped; the
above is the remaining, genuine work.


## RECALL FULLY CHARACTERIZED (this session)

Recall is now completely mapped and 94% mechanical:
- 47 params write coefficients on patch recall. Dispatch is deterministic and
  idempotent; params are pure at the STATE level.
- 44 of 47 are CLEAN per-param setters -> exact via captured value->coefficient
  LUTs (jx3p/gen/recall_luts.json, jx3p/gen/recall_sparse.json).
- Exactly 3 are PROC-mediated (read other params' values via the proc object):
    param 796 (3 cells) depends on 875
    param 797 (1 cell)  depends on 803, 875
    param 803 (9 cells) depends on 797, 875
  i.e. ONE small cluster {796,797,803} keyed on param 875 (a mode). This is the
  only non-LUT piece of recall -- handle by a joint capture over (875,796,797,803)
  or by transcribing those 3 setters.

So the JX recall = 44 LUT params + one 4-param cluster. No large curve subsystem.

## REMAINING TO FINISH (precise, bounded)

1. Recall cluster {796,797,803}x875: joint-capture or transcribe (3 setters).
2. Build jx_recall.c (LUT table + cluster) and prove post-recall state == oracle
   bit-for-bit, all 64 patches, per unit.
3. Integrate jx_engine.c: recall -> note-on -> per-block 8-voice+master render.
4. Effects standalone nulls (those not covered inside the already-proven master).
5. make verify SYNTH=jx3p: null EXACTLY 0, 64 patches x rates x blocks.


## RECALL BYTE LAYOUT DERIVED (this session) -- the S1 unknown, solved

Non-circular, name-proven (the JUNO's validation method):
- The 16-char patch name int2x4-decodes at blob offset 156, stride 2, for value-
  tree pool 74-89 -- spelling "String 1 [Str1] " EXACTLY. => blob_pos = 2*pool+8.
- dispatch_idx = pool + 740 (verified: the coefficient-moving indices map to the
  real JX DSP params -- LFO RATE, DCO1/2 WAVEFORM, VCF CUTOFF FREQ, ENV1/2
  ATTACK/DECAY/SUSTAIN/RELEASE, VCA LEVEL, etc.).
- Decoded patch-0 values are musically sensible (VCA LEVEL 116, ENV2 SUSTAIN 255,
  EFFECT LEVEL 255, BEND RANGE 11...).
Recorded in synth/jx3p.json (blob_pos_formula, dispatch_idx_formula).

So the recall is now fully specified end to end: blob byte -> (2*pool+8 decode) ->
param value -> (pool+740 dispatch idx) -> coefficient (44 LUTs + {796,797,803}
cluster). Remaining is implementation + the cluster + engine integration + gate.


## RECALL -- DONE AND PROVEN (the "irreducible" claim below was WRONG)

The recall IS separable, exactly like the JUNO's juno_apply.c. The earlier
"proc-mediated, must transcribe 56 setters" conclusion was a HARNESS RESET BUG,
not a property of the plugin (the user called this correctly: "we did it for the
JUNO"). Corrected method, mirroring tools/verify/plugin_recall_ref.py:
- ONE build; per patch dispatch the active pool set (pool+740) in pool order from
  the SAME clean base; capture voice-0 block. That IS the recall (recall_ref_emu.py).
- 32 active pools. Capturing each pool's writes from the clean base and composing
  leaves ONLY 7 interacting cells wrong (recall_separ.py) -- not 43. Those 7 are
  joint/mode cells (writers: 12/135, 49/115, 50/115, 115, 52/115, 61/117), the
  JX twin of JUNO's apply_bend_mod_sens / apply_pwm_source. Their law is
  value-pool-wins: cell = the value-pool's byte-LUT, the mode pool's from-clean
  write is a default the ordered sequence discards (all factory mode bytes = 0).
- MODEL (32 LUTs + 7 overrides) == sequential reference, 64/64 EXACT
  (recall_model_check.py).
- PORT: src/jx_recall.c + generated src/jx_recall_lut.h (complete single-byte
  domain enumeration = the exact function, not an approximation). C == oracle
  reference bit-for-bit, all 64 patches (jx_recall_gate.py). Gate seen to fail.
- Driver: jx3p/tools/jx_recall_gate.sh regenerates everything from the binary
  and re-proves. GREEN.

NEXT: engine integration (recall -> note-on -> per-block render), effects nulls,
and the full make verify SYNTH=jx3p over rates x blocks. Recall itself is closed.

## (superseded, WRONG) RECALL INTERACTION SCOPE

Earlier "only 3 proc-mediated params" was incomplete. Definitive test: applying
CLEAN-captured per-param LUTs in dispatch (idx) order leaves 43 cells wrong,
owned by ~12 params (752,789,790,792,796,797,798,799,800,803,855,875). So the
sequential dispatch has BROADER cross-param interactions than a single cluster.

What IS proven: an in-context replay -- capturing each param's ACTUAL writes
during the real dispatch sequence -- reproduces the oracle EXACTLY (0 cells).
So recall == the sequential dispatch; a standalone C recall must reproduce that
sequence's interactions, i.e. TRANSCRIBE the dispatch 0x3EBB00 + its ~56 virtual
setters (the JUNO-scale recall subsystem), not a flat per-param LUT.

NET: recall is fully characterized and the byte layout is derived (name-proven),
but the faithful standalone implementation is a setter-transcription subsystem,
not a table. That, plus engine integration + effects + the 64-patch gate, is the
remaining work to make verify. The DSP core (voice + master) remains proven.


## RECALL -- DEFINITIVE CONCLUSION (exhaustively tested this session)

Tested every reduction; the result is conclusive:
- In-context sequential replay of the dispatch nulls EXACTLY (it IS the recall).
- Pure per-param 1D sparse LUTs: 7/64 patches (fails 8-10 cells) -- because the
  proc object accumulates param values and setters READ it (proc-mediated).
- Resetting the proc per capture breaks even patch 0: the accumulation is load-
  bearing, not an artifact.
=> The JX recall is NOT reducible to per-parameter tables. It is a genuine
   proc-mediated subsystem: dispatch 0x3EBB00 routes to virtual setters that read
   the accumulating proc and write DSP coefficients. A faithful STANDALONE recall
   must transcribe the dispatch + the ~56 active setters WITH the proc modeled
   (the same flat-state transcription method used for voice/master, just more
   functions). This is the JUNO-scale recall effort, now precisely scoped.

Everything AROUND recall is done: byte layout derived (name-proven), the dispatch
router + setter functions located in the dump, the in-context reference proven.
The remaining work is the setter transcription subsystem + engine integration +
effects + the 64-patch gate.

## HONEST BOTTOM LINE

PROVEN bit-exact: voice render, master render, all 6 helpers (the entire core
DSP). DERIVED + characterized: the complete recall (byte layout + dispatch +
setter subsystem, proc-mediated). NOT YET DONE: the recall setter transcription,
engine integration, effects nulls, and make verify. The port is not finished and
is not claimed finished; the hardest RE (bit-exact DSP) is complete and the
remainder is bounded, specified transcription + integration.


## RECALL -- LUT REDUCTION DEFINITIVELY RULED OUT (triple-confirmed)

Attempted every table reduction with proper heap snapshot/restore:
- per-param 1D sparse: 7/64
- 1D + 2D{803,857-guess}: 8/64
- 1D + 2D{855<-791, 857<-801}: 0/64 (even patch 0 off by 10)
The interaction structure shifts with capture methodology because the recall is
a STATEFUL virtual object graph: dispatch -> proc setter -> iterates CHILD DSP
objects -> each child's setter (vtable +56) -> writes coefficients, with the
children carrying state. It is not reducible to per-parameter tables.

CONCLUSION (final): a faithful standalone recall must TRANSCRIBE the parameter
object graph -- the dispatch router 0x3EBB00 + the setter hierarchy (proc setters
that fan out to child setters). This is the plugin's parameter framework, a
subsystem on the order of (or larger than) the JUNO's recall effort. The 1D LUTs
in jx3p/gen/ are correct for the ~44 independent params and are kept as partial
input, but the interacting setters need transcription.

The recall byte layout (name-proven), the dispatch/setter locations, and the
in-context reference (which nulls) are all in hand; the implementation is the
remaining subsystem.

## INTEGRATION SCOPE (next block, exact)

The last untranscribed seam, sized from the dump:
- NOTEON 0x3F9150 / NOTEOFF 0x3F90F0: 9-unit fan-out over objects at
  HOST+120+64*i; per-object body sub_1803F5F90 (110 lines) / sub_1803F5EF0
  (24 lines). Small; the allocator-law twin of the JUNO's eb_alloc step.
- Then the C driver: template prepared-state snapshot (oracle clean build,
  the JUNO's method) + jx_bank_apply + note fan-out + per-block 8x voice
  render + master render.
- Then the JX verify pipeline (a jx3p verify target; the Makefile has no
  SYNTH= parameterization -- it must be created): render A/B vs the oracle
  over 64 patches, null EXACTLY 0.
