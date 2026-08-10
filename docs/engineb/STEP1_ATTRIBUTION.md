# Step 1: per-module CYCLE attribution on silicon (ablation method)

## Why ablation, not CCOUNT probes
The per-voice chain is twelve calls in one hot loop. Bracketing each with a
cycle-counter read changes inlining, register allocation and scheduling around
every one of them. This project has been misled THREE times by measurements
that perturbed or mis-metered their subject (interleave judged on instruction
count; 903 KB of flash-resident wavetables never looked at; a cache fix that
measured zero). Ablation leaves the remaining code, its inlining and its cache
layout untouched and reads the delta off the number the board already prints.

## The baseline this must reconcile against (MEASURED, SRAM build)
  voices  mask   c0 c1   cycles   marginal
    0     0x00    0  0    1,927
    1     0x80    0  1    5,572    +3,645
    2     0xc0    0  2   10,031    +4,459
    3     0xe0    0  3   14,493    +4,462
    4     0xf0    1  3   14,220      -273   <- NOISE FLOOR ~300 cyc
    6     0xfc    3  3   14,441      +221

THREE STRUCTURAL FACTS:
 1. Six voices cost the SAME as three (14,441 vs 14,493). Both cores are
    saturated and balanced. PARALLELISM IS NOT A LEVER ANY MORE.
 2. Critical path = 3 voices + floor. (14,441-1,927)/3 = 4,171 cyc/voice.
    Real time allows (5,442-1,927)/3 = 1,172 without FX, 772 with FX.
    => per-voice arithmetic must fall 3.6x (no FX) to 5.4x (with FX).
 3. The 4-voice point measured 273 BELOW the 3-voice point with an identical
    critical path. Anything under ~300 cycles is inside the noise floor.

## The builds
Each replaces ONE module's work with a cheap constant; everything else is
untouched. The audio is deliberately wrong -- these measure COST ONLY and are
refused by the gates (#error against EB_GATED_BUILD). Ablation OFF is
re-verified EXACTLY 0 on all 36 scenarios.

  abl_vcf.bin     EB_ABL_VCF     vcfo = nmixo            (the 4x ladder)
  abl_vcfres.bin  EB_ABL_VCF_RES reso = cut              (resonance shaper)
  abl_vca.bin     EB_ABL_VCA     vout = vcfo*e1          (VCA+HPF stage)
  abl_env.bin     EB_ABL_ENV     e1,e2 = gate            (both envelopes)
  abl_dco.bin     EB_ABL_DCO     q[0] = 0                (wavetable DCO)
  abl_pitch.bin   EB_ABL_PITCH   cv = off+pit            (pitch evaluator)

CONFOUND, RECORDED: abl_dco.bin is 900 KB smaller than the others -- ablating
the DCO lets the linker drop the wavetables entirely. Its delta therefore
includes the tables' memory pressure, not just the tick's arithmetic. That is
useful (it bounds "DCO + its tables") but it is NOT the tick alone.

## Procedure
Flash each, run ~45 s, record ONE number: wake=0xfc at t=41s.
  delta = 14,441 - (that build's 0xfc)
Divide by 3 for cycles per critical-path voice. Reject anything under 300.

## What the answer decides
The largest delta names the module to redesign first, by the method that
already worked once: the wavetable DCO replaced the port's TOPOLOGY with a
cheaper structure whose RESPONSE passes the 1.0 dB sonic gate (2,864 -> 1,090
host instr, PASS at 0.40 dB). The VCF, VCA, envelope and CV chains have never
had that treatment and still run the plugin's desktop topology verbatim.

## RESULT (2026-08-09, MEASURED on the user's own S3, 240 MHz, 44,100 Hz)

Baseline: floor (wake=0x00) 1,927 · 6 voices (wake=0xfc) 14,441.
Per critical-path voice = (14,441 - 1,927) / 3 = **4,171 cycles**.
(6 voices occupy 3 slots on the longer core, so the divisor is 3, not 6.)

  module          floor    6v      voice cost   share
  ------------------------------------------------------
  VCF ladder      1,645   10,909     1,083      26.0 %
  VCF res shaper  1,804   11,182     1,045      25.1 %
  PITCH eval      1,935   13,257       397       9.5 %
  VCA + HPF       1,835   13,211       379       9.1 %
  DCO wavetable   1,927   13,456       328       7.9 %
  ENV x2          1,904   13,546       291       7.0 %
  ------------------------------------------------------
  attributed                          3,523      84.5 %
  unattributed                          648      15.5 %

Each cost = 4,171 - (that build's 6v - that build's floor) / 3.

**THE HEADLINE: the VCF complex (ladder + resonance shaper) is 2,128 cycles =
51 % of a voice.** Nothing else is above 10 %. Any plan that does not cut the
VCF complex cannot reach real time, and any plan that halves it gains more
than removing the DCO, the pitch evaluator and both envelopes together.

The unattributed 648 is notecv, glide, noisemix, dcoprep, the per-sample
wiring and the loop itself. It is real but it is not a target.

### Two facts the floors carry
1. **The floor MOVES with the ablation** (1,645 .. 1,935). At-rest voices
   still tick their filters, so ablating the ladder makes the 0-voice floor
   cheaper too. This is why the cost is a DIFFERENCE OF DIFFERENCES and not
   `baseline_6v - build_6v`; the naive form over-charges the VCF by ~94
   cycles/voice.
2. **THE FLASH-CONTENTION THEORY IS DEAD.** `abl_dco.bin` is 900 KB smaller
   (the linker drops the wavetables), yet its floor is 1,927 -- IDENTICAL to
   the baseline floor to the cycle. Flash-resident constant tables cost this
   engine nothing measurable. Do not re-open it.

### Distance to the goal
Target 5,442 cycles/sample wall clock. Present 14,441 = **2.65x over**.
Budget per critical-path voice: 1,172 without FX, 772 with FX.
Present 4,171. The VCF complex alone (2,128) is 2.75x the whole with-FX
per-voice budget.

### STEP 2, named by the measurement
Redesign `eb_vcf_res` (1,045 cycles, 25 %) by the wavetable DCO's method:
its input is slowly varying, its output is memorylessly consumed (the bias
law permits ~1e-5 there), and its cost is one `expf`, a 14-term polynomial
and two divides -- all tabulatable. The ladder itself (1,083) is NOT reopened
by this: 2x half-rate measured 3.17 dB and all three ADAA orders failed, both
recorded closed.

## STEP 2 RESULT (2026-08-09) -- THE RESONANCE TABLE SHIPS

MEASURED on the user's S3, `EB_VCF_RES_LUT=256`:

  floor 1,927 -> 1,867 · 6 voices 14,441 -> 11,353
  per critical-path voice 4,171 -> 3,162, a saving of **1,009 cycles**
  6 voices vs the 5,442-cycle budget: **2.65x -> 2.09x over**

The predicted shaper cost was 1,045; the table recovers 1,009 of it, 97 %.
The remaining ~36 is the load pair, the lerp and the range test.

SONIC GATE, with its non-vacuity control:

  no table (control)   0.40 dB      table 512    0.40 dB
  table 2,048          0.40 dB      table 256    0.40 dB
  table 128            0.39 dB      table  64    0.41 dB
  table  32            0.96 dB   <- the control

All 36 scenarios PASS at every size. The 0.40 dB is the wavetable DCO's own
residual, unchanged by the table. The 32-entry row is what makes the other
rows mean anything: six identical numbers are equally consistent with the
flag never reaching the build, and this project has been caught by exactly
that. It degrades, so the gate is live.

**256 ENTRIES, NOT 2,048.** The per-sample cost is one load pair and a lerp
at ANY size, so size buys only accuracy, and accuracy stops improving at 256.
1 KB per voice instead of 8 KB: DIRAM free 38 KB -> 95 KB. The FX still have
to fit, so that headroom is not decoration.

## THE LADDER SPLIT (EB_ABLATE=9)

  floor 1,765 · 6 voices 13,568 · decimator = **237 cycles/voice**

So the ladder's 1,083 is **846 in the four sub-steps and 237 in the 32-tap
decimator**. The decimator is 5.6 % of a voice -- too small to be worth the
response risk of redesigning it. The sub-steps are the ladder.

## THE MAP AS IT NOW STANDS (voice = 3,162)

  four VCF sub-steps      846   26.8 %
  the per-sample wiring   648   20.5 %   <- now the SECOND largest item
  pitch eval              397   12.6 %
  VCA + HPF               379   12.0 %
  DCO wavetable           328   10.4 %
  ENV x2                  291    9.2 %
  VCF decimator           237    7.5 %
  res shaper (residual)    36    1.1 %

And the FLOOR is now 1,867 cycles = **34 % of the whole budget with no voice
sounding**. It is not overhead: ablations move it, so it is the eight AT-REST
voices ticking their full chains. On the 6-voice case core 0 carries two of
them, ~740 cycles that produce silence. The at-rest shortcut has been listed
as unexercised since Phase 1; it is now a named target with a number on it.

## THE THREE-WAY AUDIO CHECK (2026-08-09), against the PLUGIN BINARY

Rendered at MIDI note 48 (C3), velocity 100, 2 s held, 44,100 Hz. "VST" is the
plugin's own machine code executed under Unicorn -- not the port standing in
for it.

  patch                    VST vs PORT          VST vs S3 FORK (worst band)
  ---------------------------------------------------------------------------
   0 SY Poly Synth         0 of 88,200 differ   0.01 dB
   2 KY Delicate Keys      0 differ             0.07 dB
   5 LD Classic Lead       0 differ             0.07 dB
  61 LD Perc Lead          0 differ             0.04 dB
   1 SQ Dynamic ARPG       0 differ *           0.08 / 0.10 dB

**A TRAP WORTH RECORDING, because it looked exactly like a port defect.** The
first render of patch 1 read 88,198 of 88,200 samples differing. It is a
HARNESS limit, not a defect: e2e_emu drives the engine directly and has NO
TRANSPORT CLOCK, so the plugin's arpeggiator never steps and it holds ONE
note while the port arpeggiates. MEASURED, rather than argued from the
docstring: the plugin side's 50 ms envelope decays monotonically to 0.002 and
never retriggers, while the port's keeps making fresh attacks to 0.297.
recall_render_ab.py excludes patches 1/9/17/25/33/41/49 for this reason.

* The patch-1 row is rendered THROUGH THE ARP GATE's driving -- the same
33-event schedule replayed into the plugin at real note offsets -- which is
what makes it a comparison at all. The schedule is the PORT's, and that is
sound only because arp_sched_ab.py separately proves it 7/7 against the
plugin's own arpeggiator. That is a proof CITED here, not re-run.

ALSO TRUE AND NOT VISIBLE IN THE FILES: engine B has no arpeggiator
(eb_patch.h: with no transport clock it writes none). The arpeggio in the
fork's render comes from the host harness, so the S3 firmware could not play
that performance today. It is a missing feature, not an inaccuracy, and it is
not yet on the plan.

## TWO LADDER IDEAS KILLED BY COUNTING, BEFORE ANY BUILD (2026-08-09)

The four VCF sub-steps are 846 cycles/voice, the largest item left. Two
candidates were checked against the source and both die on arithmetic alone.
Recorded so they are not proposed again.

1. **TABULATE THE SATURATOR. A LOSS, NOT A WIN.** The curve is
   `nl = x + ((((x*x)*x)*x) * (x*c9184))` -- FIVE flops after a two-compare
   clip. A table costs a scale, a truncation, TWO LOADS, a subtract, a
   multiply and an add. The wavetable DCO and the resonance table both won
   because they replaced an `expf`, a 13- or 14-term polynomial and divides.
   A quintic is already cheaper than its own lookup. **The method is not
   general: it pays only where the thing replaced is expensive.**

2. **`S` IS NOT DEAD ARITHMETIC.** The zero-input response computed one
   sub-step ahead looked like a candidate, because EB_VCF_DEADCOEF already
   proved its SECOND tap (c9536) dead in all 128 sets. It is not: `st->s1` is
   read at the top of the next sub-step as `x = ins - ((st->s1 * c9520) * Rk)`
   -- it IS the resonance feedback, and c9520 is 1.0, not 0. Deleting it would
   remove the resonance.

WHAT THIS LEAVES. The sub-step is ~30 flops of live filter arithmetic in a
serial chain (y1 -> t -> y2 -> y3 -> y4 -> S), running at ~7 cycles per flop
because an in-order FPU stalls on that chain. The fix for a stall is
independent work, which is voice interleaving, which is CLOSED by the
16-register wall. **No cheap lever remains inside the ladder, and saying so is
more useful than proposing a fifth one.**

## STEP123 ON SILICON (2026-08-10) -- THE FUSION REGRESSED, MEASURED

  wake        RESLUT baseline   STEP123    delta
  0x00 floor        1,867        1,961      +94
  0xe0 (3v)        10,888       11,286     +398   -> sounding voice 3,394 -> ~3,527
  0xfc (6v)        11,353       11,133     -220

ATREST delivered (~450 recovered where at-rest voices sit on the critical
core). THE VCA FUSION COST ~130 CYCLES PER SOUNDING VOICE: the three control
values must live across the whole ladder call, so they spill to the stack and
reload -- the 16-REGISTER WALL, THIRD APPEARANCE (voice interleave, the pitch
hoist's inlining, now this). The EXACTLY-0 gate was the right correctness
instrument and structurally could not price it: spills are bit-exact.
LESSON, stated once: on this chip, "give the scheduler independent work" only
pays if the values do not have to cross a call boundary; anything that
lengthens live ranges across the ladder LOSES.

Decomposition binary: juno_s3_STEP13.bin = ATREST + zerocoef, fusion OFF.

## STEP13 ON SILICON + THE SLOPE CORRECTION (2026-08-10)

  wake      baseline   STEP123    STEP13
  0x00         1,867     1,961     1,856
  0x80         4,388        --     4,760
  0xc0         7,634        --     8,058
  0xe0        10,888    11,286    11,372
  0xfc        11,353    11,133   *10,965*   <- best of the campaign, -388

The fusion's cost in isolation: STEP123 - STEP13 = **+168 cycles**.

**THE DECOMPOSITION WAS WRONG, AND THE SLOPE FIXES IT.** Consecutive wake
masks add exactly ONE sounding voice on core 1, so the DIFFERENCE is the
voice cost with no assumption about what the floor contains:

                 voice      prologue    2-voice core      1-voice core
  baseline       3,250       1,138      7,638 = 1.40x     4,388 = 0.81x
  STEP13         3,306       1,454      8,066 = 1.48x     4,760 = 0.87x

Both models predict their own 0xe0 point TO THE CYCLE. The earlier figures
(voice 3,394, shared 704) came from dividing the 0xfc-minus-floor difference,
which mixes the at-rest change into the voice cost and understates the
prologue by ~2x.

CONSEQUENCE: the kernel's target is not 673 cycles/voice but ~1,210 (a 37 %
cut) against a hand-scheduling ceiling of roughly 18 %. **The asm kernel
alone cannot reach 6 voices on two chips.**

## THE LEVER THE PLAN NEVER CONSIDERED: the prologue is a SERIAL HEAD
Core 1 waits for the prologue every sample, so the loop is
`prologue + max(core0, core1)` -- 1,300 cycles charged in full while a whole
core idles. The prologue depends on note events and its own state, never on
the current sample's voice output, so computing sample i+1's prologue AFTER
core 0's voices for sample i makes the loop
`max(core0_voices + prologue, core1_voices)`.

BIT-EXACT BY CONSTRUCTION: prologue[i], voices[i], prologue[i+1] is exactly
the order the serial version already runs. Only core 1's release point moves,
and core 1 touches none of the state the prologue advances.

  2 chips, 6 voices, 3 per chip:
    serial, 2/1 split          7,860 = 1.44x
    pipelined, 1/2 split       6,560 = 1.21x
    pipelined + kernel ceiling ~5,400 vs 5,442  -- fits, ~1 % margin

**THE PROBE MASK 0xd0 IS PART OF THE MEASUREMENT.** The gain is INVISIBLE at
every existing sweep point: it only appears when the prologue-bearing core
carries fewer voices. 0xd0 wakes voice 4 (core 0) and voices 6,7 (core 1).
Any symmetric mask hides the difference entirely.

## LFOCUT ON SILICON (2026-08-10): NO CHANGE -- AND THE REASON REWRITES THE MAP
  0x80: 4,740 (was 4,736)   0xfc: 10,970 (was 10,965)   -- flat.

**THE SWEEP NEVER RUNS THE LFO.** Every wake mask fills from voice 7 DOWN, so
voice 0 is AT REST in all seven phases -- and eb_engine_render_shared
early-returns after notecv when voice 0 rests, BEFORE cvgate/glide/LFO. The
memo and the 13 deletions are correct (EXACTLY 0) and cost nothing, but their
cycles only exist when voice 0 SOUNDS (7-8 note play). Both head theories die
together: Opus's 752-instruction prologue count included an LFO that never
executes in this sweep (the c/i 1.93 match was coincidence), and the whole
"LFO is two-thirds of the head" plan attacked code the measurement never ran.

**WHAT THE 1,454 HEAD ACTUALLY IS: the at-rest voices' advance BODIES.** The
old ablation priced an at-rest voice at 232 cycles; 6-7 of them is ~1,500.
EB_ATREST_BLOCK hoisted the per-sample CALL (set_pitch, primed test); the
128-iteration loop body (4 wraps + sub counter + ring write, per voice, per
sample) still runs in full.

**THE REAL LEVER, named for the next session:** a closed-form block advance.
Phase after n steps is wrap(phase + 4n*inc4) -- O(1); the sub counter's
crossings over n steps are floor arithmetic -- O(1); the residual ring is all
zeros after RES_LEN samples -- one memset. NOT bit-exact (float rounding
differs from 128 sequential wraps), so it takes the SONIC gate -- and the
error it introduces is phase-at-wake, which is the charter's already-relaxed
"which beat" question (the -46 dB null collapse). Worth ~1,400 of the head
plus most of the 1,904 floor. With it and the asm kernel (~600/voice of the
measured stall pool), the two-chip core lands ~5,4xx vs 5,442.

## SESSION HANDOFF (2026-08-10, session limit)
EB_ATREST_O1 (closed-form at-rest advance) PASSED the sonic gate at 0.40 dB
-- the unchanged fork's own figure -- with the closed form FORCED onto every
sample (EB_ATREST_O1_MIN=1 in the gate build; shipping threshold 8). Firmware
juno_s3_O1.bin: full stack (O1 + ATREST_BLOCK + ZEROCOEF + EXP_MEMO +
RES_LUT + DEADCOEF). Flash it, run the 7-phase sweep (~4 min), read 0x00 and
0xfc. If the floor (1,904) collapses, the head diagnosis is confirmed and
~1,400-1,800 comes off every mask -> 6 voices ~9,300, two-chip board ~6,300,
kernel (~600/voice, ASM_KERNEL_WORKORDER.md) is the last span. If the floor
is flat, record it as dead end six and the kernel carries the rest.
State: 10,970 banked bit-exact at 6 voices; sound bit-exact to the plugin;
all negatives documented in docs/engineb/data/.

## AUDIBLE BUILD ON SILICON (2026-08-10) -- THE HONEST FINAL TABLE OF THE DAY
  0x00 floor  1,020   (was 1,904 -- EB_ATREST_O1 DELIVERED, head 1,450->675)
  0x80        3,743   0xc0 6,804   0xe0 9,879
  0xfc       10,004   (6 voices, one chip; day started at 11,353)
  0xd0        6,723   <- the two-chip workload, vs 5,442 = 1.24x OVER

Slope: voice = 3,068. HALF_OS delivered ~212/voice, NOT the ~500 projected.
THE PROJECTION ERROR WAS A MIS-CITATION, and the correction was already in
the record: engine_price.py's own comment says the half-OS decimator saving
"measured zero -- the fifth such result", so only the two sub-steps were ever
real (~160 insns). The 5,560 landing and the "nothing outside 2%" claim were
wrong; the miss is 24%.

REMAINING GAP: 1,281/chip = ~640/voice. The measured FPU stall pool in
ladder+VCA is ~735/voice (c/i ~1.9 still). For the first time the LAST span
is SMALLER than the single remaining lever's measured pool:
**ASM_KERNEL_WORKORDER.md is now correctly sized to finish this.** No
standard change remains, none is needed. Sound: gated 3.17 dB worst band,
user holds the worst-case WAVs.

## LAST MILE PHASE A — GATED ON HOST (2026-08-10)
Full result: `docs/engineb/data/lastmile_result.md`. Four control-rate holds,
each measured under the AUDIBLE standard for the first time (their old
rejections were NULL numbers at -100 dB, a different question).

  control (the build on the user's board)                    3.17 dB
  pitch + modcv held 4, cutoff CV held 2                     4.23 dB
  + envelopes held 2, rate compensated  <- SHIPPED           5.79 dB
  2-tap decimator                                    DEAD,  10.07 dB

TWO CORRECTIONS TURNED DEAD LEVERS LIVE. (1) A held control is a STAIRCASE
and the VCA multiplies by it, so every plain hold failed in the 10,240 Hz band
-- envelopes at 40.43 dB. Interpolating the held samples removes the edges.
(2) Interpolation is PER GROUP: on the pitch chain it measured 17.96 against
the stepped 3.21, because eb_dcoprep's increment and edge gain are an exact
reciprocal pair that independent interpolation breaks. INTERPOLATE WHAT
MULTIPLIES THE AUDIO, STEP WHAT DESCRIBES IT. The envelope needed both
corrections and neither alone (40.43 / 41.89 / 22.47 / 5.51).

Firmware `juno_s3_LASTMILE.bin` carries the shipped set. NO CYCLE NUMBER IS
CLAIMED HERE. 0xd0 is the verdict and only the board prints it.

## LASTMILE ON SILICON (2026-08-10) -- PHASE A CLOSED BY THE BOARD
Two firmwares, one lesson each:

LASTMILE (holds at the struct TAIL): 0xfc 12,182 -- every sounding voice
~700 cycles WORSE. The listen firmware keeps only the prefix up to
offsetof(eb_render_state, chorus) in internal RAM; the fourteen hold slots
were after the FX states, in PSRAM, hit per voice per sample. PLACEMENT IS
PART OF THE DESIGN. Fixed by moving the slots into the prefix (8,024 ->
8,488 bytes).

LASTMILE2 (slots in internal RAM):
  0x00 1,130 · 0x80 3,710 · 0xc0 6,716 · 0xe0 9,744 · 0xf0 9,705
  0xfc 10,051 · **0xd0 6,681 vs 5,442 = 1.23x OVER**
Against the AUDIBLE build: 0x80 -33, 0xc0 -88, 0xfc +47, 0xd0 -42.

**THE MEASUREMENT: the control-rate holds save ~60 cycles/voice on this
chip, not the several hundred the host attribution priced.** The held path
still loads the slots, runs the lerp and takes the branch -- and the voice
loop is STALL-BOUND (c/i ~1.9): removing arithmetic from a pipeline that was
waiting removes almost nothing. The stalls were the cost; the modules were
partly free. This is the same fact as the interleave and fusion negatives,
finally measured head-on.

CONSEQUENCES:
1. THE CR LEVERS SHIP OFF. ~60 cycles for 2.6 dB of sound is a bad trade at
   any price. The shipping fork build stays the AUDIBLE set (3.17 dB, the
   user approved its WAVs BY EAR on the four worst gate scenarios).
2. THE GAP IS ~620/voice AND IT IS MADE OF STALLS -- Phase A just proved
   that by elimination. The ladder+VCA stall pool is measured ~735/voice.
   ASM_KERNEL_WORKORDER.md is the only lever that attacks the measured
   cause, and it is sized to cover the span. It is the head pointer.

## FAST3 ON SILICON (2026-08-10) — HALF THE GAP CLOSED, AND MY MODEL CORRECTED
NOLIBM + VCF_MAPFAST + FPDIV, voices only, user's S3:

  wake     AUDIBLE   FAST3    delta
  0x00       1,020    1,038      +18
  0x80       3,743    3,394     -349
  0xc0       6,804    6,120     -684
  0xe0       9,879    8,855   -1,024
  0xf0       9,705    8,796     -909
  0xfc      10,004    9,100     -904
  **0xd0     6,723    6,062     -661**

VOICE SLOPE 3,068 -> **2,730** (-338). Two independent slopes agree: 2,726
and 2,735.

**GAP 1,281 -> 620. Fifty-two percent of it closed in one night, and at ZERO
sonic cost** -- two of the three levers are bit-exact and the third measures
the control's own 3.17 dB.

### ★ MY OWN MODEL WAS WRONG AND THE BOARD CORRECTED IT
I derived "the voice must reach 2,721" from `0xd0 = 2 voices`. The voice
reached 2,730 -- on target within noise -- and 0xd0 is STILL 620 over,
because:

    2 voices at the measured slope   5,461
    measured 0xd0                    6,062
    UNMODELLED REMAINDER               601   <- head + at-rest + sync

**That 601 is now almost exactly the whole remaining gap (620).** The voice is
no longer the binding constraint; the SERIAL HEAD and the at-rest floor are.
Stating the requirement as a per-voice number was an over-simplification of my
own making, and it is retired here.

### CONSEQUENCE: THE NEXT LEVER IS THE PROLOGUE, NOT THE VOICE
Core 1 waits for the prologue every sample. `EB_PROLOGUE_PIPE` computes
sample i+1's prologue AFTER core 0's voices for sample i, making the loop
`max(core0_voices + prologue, core1_voices)` -- BIT-EXACT BY CONSTRUCTION,
since it is the same order the serial version already runs.

It measured -54 and was recorded dead. **THAT MEASUREMENT WAS TAKEN ON MASKS
THAT HIDE IT.** This file already says so: "the gain is INVISIBLE at every
existing sweep point; it only appears when the prologue-bearing core carries
fewer voices." 0xd0 is exactly that mask, and PIPE has never been measured
there. The lever is UNDECIDED, not dead -- the same status the ILV pair had.
