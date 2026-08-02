# ENGINE B — MODULE M-DELAY (DELAY TYPE 0): EXACT, AND CHEAP UNTIL THE LINE MOVES

2026-08-02. Files: `engine_b/eb_delay.c`, `engine_b/eb_delay.h`,
`engine_b/shim/delay/master_render.c`, `engine_b/test_delay_ref.c`.
Specification: `docs/engineb/FX_DELAY.md`. `src/` was not modified.

## 0. Headline

| claim | number | label |
|---|---|---|
| `null_b.py --module delay` | **30/30 EXACTLY 0** (0 differing samples, all 17 idle-prefix scenarios included) | MEASURED |
| offline vs the literal transcription | **14/14 configurations EXACTLY 0** | MEASURED |
| cost, S3, 44.1 kHz build (biquad in) | **235 cyc/sample**, band 149..605, **6.7%** of 3,500 | MODELED |
| cost, S3, 48 kHz build (`EB_DELAY_BIQUAD=0`) | **207 cyc/sample**, band 132..529, **5.9%** of 3,500 | MODELED |
| libm calls / softfloat calls per sample | **0 / 0** on all three targets | MEASURED-STATIC |
| internal memory | `sizeof(eb_delay_state)` = **524,400 B** at `EB_DELAY_LEN` 65536 | MEASURED |
| cost if the ring goes to PSRAM | **~567 cyc/sample** nominal (207 + 6 accesses x 60) | MODELED-UNVALIDATED |

The arithmetic fits with room to spare. **The delay's cost is its memory, and
its memory does not fit**, which is the same conclusion FX_DELAY.md reached and
the reason the first-guess 300-cycle delay budget is the wrong shape of budget.

## 1. What was built

`eb_delay.c` is the DELAY TYPE 0 stage with engine B's own state: one struct,
one compile-time ring, no 12 MB context. Every floating-point operation is kept
in the ORDER AND GROUPING of `docs/engineb/data/eb_delay_ref.c` — the literal
transcription that nulled bit-exact against the sealed engine. Nothing was
algebraically simplified.

Three cells that FX_DELAY.md measured constant (102624 and 102688 = 1.0, and the
102448/102496 crossfades taking only 0.0/1.0) are STILL multiplies. They cost
almost nothing and removing them buys nothing that was measured — see §5.

Two dead stores in the reference are not carried over and are named in the file
header so the omission is a decision, not a slip: cell 102112 and cell 102208's
duplicate latch are written and never read.

### The one place the double disappeared, and how that was proven

The sealed engine computes the tap index and its fraction in DOUBLE. The LX7 FPU
is single-precision only, so one double here is a softfloat call per sample.
Engine B does them in float. That is not an assumption: both forms were compared
over **every float32 bit pattern with |sm| <= 1e6 — 2,464,696,322 values —
with 0 mismatches** in the integer cast and 0 in the fraction (`/tmp` probe,
reproduced in one 10-second run; the scaling is by a power of two so it is
exact, and `P - trunc(P)` is a difference of neighbouring floats). Values
outside that domain set `overrun` and are refused, so the untested tail is not
reachable. The cost rig confirms the outcome: **0 softfloat helper calls** in
the compiled S3 object.

## 2. The gate

`tools/engineb/null_b.py --module delay` — **30/30 EXACTLY 0**, worst global
"EXACTLY 0 everywhere", self-test green.

The shim forks `src/master_render.c` and replaces exactly lines 1055-1264. The
module's state lives at `a1+102800`, on top of the port's own left delay ring,
which the replaced block no longer uses; it is seeded ONCE from the port's own
power-on cells so engine B starts wherever `juno_engine_prepare` left the stage.
Two things the shim CHECKS rather than assumes, because either would be a
silent, plausible-looking null:

* both port rings must be entirely zero at that first sample (they are);
* the tap must fit `EB_DELAY_LEN` (`overrun`).

Both abort. Neither has fired.

### Non-vacuity — measured, and measured by accident first

The first version of this module got the delay-time smoother wrong. The sealed
engine rotates FOUR cells at the top of every sample (102208 -> 102224 ->
102240 -> 102256); their meaning is that the glide DISTANCE is latched when the
TARGET CHANGES and held while it does not. Reading them as a 2-cell smoother
produced a plausible glide and **failed 15 of 30 scenarios, worst -33.9 dB**.

That failure is the non-vacuity evidence: 15 of the 30 scenarios demonstrably
carry this module's output to the gate. Planted deliberately afterwards, through
the real build path:

| planted error | scenarios caught | worst global |
|---|---|---|
| tap index moved one sample | **15 / 30** | -38.4 dB |
| feedback taken BEFORE the loop damping | 6 / 30 | -13.6 dB |
| mute fade not one sample late | 4 / 30 | -81.7 dB |
| 1 ULP on `wet` (DELAY LEVEL) | 0 / 30 | -146.7 dB (PASSES) |
| linear interpolation regrouped to `t1 + f*(t2-t1)` | 0 / 30 | -152.5 dB (PASSES) |
| drop BOTH the 1.0 multiplies (102624, 102688) | 0 / 30 | EXACTLY 0 |

Read the bottom three rows as the CALIBRATION they are:

* a 1-ULP coefficient error lands **47 dB below** the -100 dB gate, so this
  module has 47 dB of headroom before the gate is the thing that is wrong;
* **the "obvious" algebraic regrouping of the interpolation is NOT free** — it
  is a real -152.5 dB error. It is far under the gate, so the gate would not
  have caught it. It is not used; the reference grouping costs nothing;
* dropping the two 1.0 multiplies really is EXACTLY 0, so that simplification is
  free whenever it is wanted.

### The branches the factory bank does not reach

The 30 scenarios play factory patches, and a factory patch never sets HIGH CUT
byte 14, never sets DELAY LEVEL below 2, never mutes, never moves DELAY TIME
while the line runs and never changes the effect routing. Those are branches of
this module, so `engine_b/test_delay_ref.c` drives them directly against the
same literal transcription:

    nominal, mixA=0 (the 48 kHz topology), HIGH CUT byte 14 (bypass),
    OFF gate (LEVEL<2), MUTE, FEEDBACK max, FEEDBACK 0, shortest time,
    longest time (800 ms), time MOVES up, time MOVES down, routing change,
    wet 0, damping extremes
    -> 14/14 EXACTLY 0

Built with `-DEB_DELAY_BIQUAD=0` the SAME test fails 8 of 14 and passes exactly
the 6 cases where the DF-I branch cannot reach the output (mixA=0, HIGH CUT
bypass, OFF gate, MUTE, wet 0, longest time). That is the honest boundary of the
48 kHz reduction: it is legal only where cell 102448 was MEASURED 0.0, i.e. at
every host rate except 44,100.

## 3. Cost — MODELED, `tools/engineb/cost.py measure ... --calls eb_delay_process=1`

| target | 44.1 kHz build | 48 kHz build (`EB_DELAY_BIQUAD=0`) |
|---|---|---|
| host x86-64 | 65 (42..206) | 57 (38..182) |
| Cortex-M7, TCM | 218 (113..692) | 190 (98..604) |
| **ESP32-S3, internal SRAM** | **235 (149..605)** | **207 (132..529)** |

S3 static counts, 48 kHz build: 220 instructions, 61 FP arithmetic, 66 FP
memory, 38 integer ALU, 14 branches, 82 register-list-weighted memory accesses,
**0 libm, 0 softfloat**.

**Share of the 3,500 cyc/sample engine budget: 5.9% nominal, 3.8%..15.1% across
the band.** Against the first-guess per-module allowance of 300 the nominal
fits (0.69x) and the top of the band does not (1.76x). The band is the honest
answer; no S3 silicon exists.

## 4. Memory — this is the finding that matters

MEASURED with `sizeof`:

| `EB_DELAY_LEN` | ring | struct total | covers |
|---|---|---|---|
| 65,536 (default) | 524,288 B | **524,400 B** | manual mode at 44.1 and 48 kHz (max 38,398 samples) |
| 131,072 | 1,048,576 B | 1,048,688 B | tempo sync 1/1 at 128 BPM (90,000 samples) |
| 524,288 | 4,194,304 B | 4,194,416 B | the plugin's own allocation |

`sizeof(eb_delay_cfg)` = 108 B. Scalar state = 112 B.

The 200 KB internal budget on a 512 KB part is exceeded by the DEFAULT ring
alone, 2.6x, before the chorus and the reverb are counted. `EB_DELAY_LEN` is a
compile-time constant and `ring` is the LAST member of the struct precisely so
the array can be moved to external memory without touching the DSP, which is
what `docs/engineb/SCOPE.md` requires.

**The trade, stated so it is a decision and not a surprise.** Per sample this
module makes exactly **6 ring accesses**: two reads and one write per channel.
With the ring in internal SRAM the module costs 207 cyc/sample. With the ring in
PSRAM, at the rig's MODELED-UNVALIDATED s3_psram extra latency of 30/60/120
cycles per access, those 6 accesses add 180 / 360 / 720 cycles:

    ring in internal SRAM   207 cyc/sample     [MODELED]
    ring in PSRAM         ~ 387 / 567 / 927    [MODELED-UNVALIDATED]

At the nominal that is **16% of the whole 3,500 engine budget for the delay
alone**, and at the pessimistic end 26%. This is the same warning FX_DELAY.md
gave with a Daisy SDRAM number (472 cyc/sample) and it survives the target
change. **The PSRAM latency is a guess this project has never measured — it is
the single largest unknown in the delay and it must be measured on an S3 before
any budget built on it is believed.** The two reads are adjacent, so a burst or
a cache line covers both and the access count could fall from 6 to 4; that is
also unmeasured.

Do NOT shorten the line to make it fit: `docs/trackb/CONSTRAINTS.md` forbids
degrading the FX, and 250 ms (the old `EB_DELAY_LEN` 12,000) is a 3.2x cut of
the manual maximum.

## 5. What this module does NOT do

* **DELAY TYPES 1..5.** Only TYPE 0 is written and gated. TYPE 1 (dual delay) is
  a different block of `src/master_render.c` (line 888) and TYPES 2/3/5 route
  through the slot-1 chorus and reverb. `EB_HAVE_DELAY` is set to 1 with that
  restriction written next to it.
* **Tempo sync.** The default ring is 3.2x too short for 1/1 at 128 BPM. The
  shim aborts rather than wrap; nothing silently truncates.
* **DELAY TAP TIME.** MEASURED to move no cell (FX_DELAY.md §7); nothing here
  depends on it.
* **The cheap formulation** in `docs/engineb/data/eb_delay_cheap.c` is now
  superseded and should not be used: it is off by one sample in the feedback tap
  (it writes the CURRENT loop output into the ring where the sealed engine
  writes the PREVIOUS one), it regroups the interpolation in the way measured
  above at -152.5 dB, and it reads the delay-time smoother as a 2-cell smoother
  — the -33.9 dB error. `eb_delay.c` is the version that nulls.
