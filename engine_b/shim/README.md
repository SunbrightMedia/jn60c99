# engine_b/shim — how one engine B module is put under the null before the
# engine exists

`tools/engineb/null_b.py --module <name>` builds a HYBRID library:

    src/*.c  minus every file that engine_b/shim/<name>/ shadows by filename
    + engine_b/shim/<name>/*.c
    + engine_b/*.c
    + gui/juno_bridge.c

So a shim file replaces exactly one port translation unit, and everything engine
B has not written yet is the port's own code — not a stub, not a mock, not a
bridge anyone has to maintain. That is what "the rest of engine B calls the
oracle" means here, and it is why a divergence is attributable to one module.

Rules that the harness enforces:

* a shim file MUST be named after the `src/` file it replaces. A name that
  shadows nothing is a build error, because otherwise both files compile and the
  module under test is silently not in the build.
* `--module none` substitutes nothing and MUST null EXACTLY 0. That self-test
  runs at the head of every run; if it is not 0, no other number in the run
  means anything.
* `src/` is never edited. The overlay happens in a temp copy of the tree.

What this cannot see: a module that is only correct inside the port's
surrounding code. `--module all` is the acceptance shape, and B-vs-plugin
(docs/trackb/THREE_WAY_GATE.md) is the only comparison that retires a claim.
`src/` is a fast proxy, never the authority.

## skeleton

The only shim at this commit. It is a verbatim fork of `src/juno_driver.c` — diff
it, the only additions are two marked ENGINE B blocks — that runs the engine B
skeleton alongside the port on every sample and DISCARDS its output while
`eb_engine_process()` returns `EB_INCOMPLETE`. `null_b.py --module skeleton` is
therefore EXACTLY 0 in all 26 scenarios, and that zero is a plumbing baseline,
not a DSP result. Compile it with `-DEB_SKELETON_FORCE_HANDOVER=1` to force the
hand-over branch: the null then fails in 25/25 scenarios, which is how the
hand-over line is known to be live rather than unreachable.

## env — MODULE M7, the two ADSR envelopes (the first real DSP module)

Forks `src/voice_render.c` and replaces ONE block, lines 964-1075, with a call
into `engine_b/eb_envgen.c`. Everything else in the file is the port's own code
byte for byte, so a divergence is attributable to the envelopes and to nothing
else.

`null_b.py --module env` -> **30/30 EXACTLY 0** (re-run 2026-08-02; the set was 26 when this was written), including all 17 idle-prefix
scenarios. Non-vacuity is MEASURED, not assumed: planting the documented slew-
constant simplification in `eb_envgen.c` fails 10 of 25 scenarios at -66.9 dB,
33 dB above the gate. Full numbers, the cost measurement and one restructuring
that was measured and REJECTED: `docs/engineb/M7_ENV_RESULT.md`.

The shim keeps engine B's five state floats in the port's own state cells
(2592/2624/2640/2672/2720 and the +480 ENV2 twins), which is what
`null_b.py`'s doc sanctions, so the module inherits the port's create/destroy/
eight-voice lifecycle exactly. No cycle figure is ever taken from the shim: the
cost rig measures `eb_envgen.c` alone.

## dco — THE DCO OSCILLATOR

Forks `src/voice_render.c` and replaces ONE range, lines 1718-2136, with four
calls into `engine_b/eb_dco.c`. The brief names 1718-1830; that is sub-block ONE
of the four 4x-oversampled sub-blocks, and sub-blocks 1/2/3 are PROVEN
token-identical after renaming decompiler temporaries (only the polyphase output
cell differs) while sub-block 4 differs in three decompiler artefacts that are
the same arithmetic. So the module is one function called four times.

`null_b.py --module dco` -> **30/30 EXACTLY 0**, including all 17 idle-prefix
scenarios. Non-vacuity is MEASURED: planting the "obvious" wrap simplification
(drop the rounding `+1`/`-1` and subtract 2 directly -- algebraically identical)
fails **15 of 30** scenarios, worst global **-62.1 dB**, 38 dB above the gate.

The phase wrap is additionally PROVEN over ALL 2^32 float32 bit patterns
(`engine_b/test_dco_wrap.c`, 0 mismatches, NaN payloads included), because the
negative arm at `src/voice_render.c:1726` executes in NONE of the 30 scenarios
and comes within 0.0003 of firing -- no scenario gate can protect that margin.

**The module is ACCURATE and it is NOT AFFORDABLE.** MEASURED cost and the
options are in the commit message and in `engine_b/eb_dco.h`.

## vcf_ladder — MODULE M-VCF, the 4-pole ladder core

Forks `src/voice_render.c` and replaces ONE block, lines 1298-1515 (the input
node, the four 4x sub-steps, the four dispersion lines and the decimating FIR),
with a call into `engine_b/eb_vcf_ladder.c`. Everything else in the file is the
port's own code byte for byte.

`null_b.py --module vcf_ladder` -> **30/30 EXACTLY 0**, including all 17
idle-prefix scenarios. Non-vacuity is MEASURED: removing the saturation fails
29/29 at **-13.9 dB**, 86 dB above the gate; `x 1.00003` fails at -90.4 dB and
1 ULP passes at -128.7 dB, which brackets the threshold from both sides.

The shim keeps the module's 41 floats in the port's own cells, so it inherits
the port's lifecycle. No cycle figure is ever taken from the shim: the cost rig
measures `eb_vcf_ladder.c` alone, and it says **4,273 cyc/sample on the S3 —
1.86x the budget that remains after the envelopes**. Full numbers, the seven
planted errors, the exhaustive wrap test and the priced levers:
`docs/engineb/MVCF_LADDER_RESULT.md`.

## pwm_cv — MODULE M-MODCV, the pitch / PWM modulation CV block

Forks `src/voice_render.c` and replaces ONE range, lines 1076-1128 (the mod
router, the PITCH SUM `[3776]` and the PWM SUM `[3808]`), with a call into
`engine_b/eb_pwm_cv.c`. Everything else in the file is the port's own code byte
for byte.

`null_b.py --module pwm_cv` -> **30/30 EXACTLY 0**, including all 17
idle-prefix scenarios.

**THE GATE IS PARTLY BLIND HERE, MEASURED — read this before touching the
module.** Instrumenting the block and running the whole scenario set records
these maxima over all 30 scenarios:

    v169 (kbd/pitch CV mix)     5.00018     LIVE
    LFO arms [3712]/v176        0.9981      LIVE
    v180 (LFO -> pitch)         0.0349807   LIVE
    PWM LFO term                0.999049    LIVE
    [3936] PWM offset           1.0         LIVE
    [4144] PWM out gain         0.915       LIVE
    v182  ([3744] arm)          0           IDENTICALLY ZERO
    bend term [3760] x [3872]   0           IDENTICALLY ZERO
    env -> pitch mix            0           IDENTICALLY ZERO
    env1/env2 -> PWM            0           IDENTICALLY ZERO

So 9 of the module's 21 coefficients ([3984], [4000], [3856], [3872], [4112],
[4128], [4064], [4080], [4096] plus [3904]/[3920] and the mod source [3552])
CANNOT be seen by this gate: their terms are exactly zero in every scenario.
Two "algebraically identical regrouping" plants on those paths therefore pass at
EXACTLY 0, and that is a property of the scenarios, not of the code. The module
transcribes those lines verbatim from the port for exactly this reason; any
future SIMPLIFICATION of them is unguarded and needs new scenarios first.

Non-vacuity on the paths that ARE live is MEASURED: `x1.00003` on the pitch sum
fails **29/29** quick scenarios, worst **-8.5 dB** global (91 dB above the
gate); `x1.00003` on the PWM sum fails **22/29**.

`eb_modcv_block()` — the eight-voice shape the finished engine calls — is PROVEN
bit-identical to the gated `eb_modcv_tick()` over 16,000,000 random comparisons
(`engine_b/test_modcv_block.c`, 0 mismatches).

## delay — MODULE M-DELAY, the DELAY TYPE 0 stage

Forks `src/master_render.c` and replaces ONE range, lines 1055-1264 (the whole
`LABEL_69` delay stage), with a call into `engine_b/eb_delay.c`. Everything else
in the file is the port's own code byte for byte.

`null_b.py --module delay` -> **30/30 EXACTLY 0**, including all 17 idle-prefix
scenarios. Non-vacuity is MEASURED, not assumed, and it was measured by
accident: the FIRST version of this module got the delay-time smoother's 4-deep
cell pipeline wrong and failed **15 of 30** scenarios at **-33.9 dB**, so 15
scenarios are known to reach this module's output. Planted afterwards on
purpose: the tap index moved by one sample fails 15/30 at -38.4 dB, and the
feedback taken before the loop damping fails 6/30 at -13.6 dB.

The module's state lives at `a1+102800`, ON TOP of the port's own left delay
ring, which the replaced block no longer uses. It is seeded once from the port's
own power-on cells, and the shim ABORTS rather than continue if either port ring
is non-zero at that moment or if the tap does not fit `EB_DELAY_LEN`.

Full numbers, the 14-configuration offline test against the literal
transcription, the exhaustive double-to-float proof and the PSRAM warning:
`docs/engineb/M-DELAY_RESULT.md`.

## vca_hpf — MODULE M-VCA, the VCA + HPF output stage

Forks `src/voice_render.c` and replaces ONE block, lines 1516-1640 (the four
latches, the velocity and mute smoothers, the gate ramp, the VCA source
combine, the HPF/boost network, the DC blocker, the amp TONE crossfade and the
two final gains), with a call into `engine_b/eb_vca_hpf.c`. Everything else in
the file is the port's own code byte for byte.

`null_b.py --module vca_hpf` -> **30/30 EXACTLY 0**, including all 17
idle-prefix scenarios. Non-vacuity is MEASURED: swapping the two tone filters'
feedback taps -- the "3-tap FIR" misreading `docs/trackb/CELLMAP.md` warns about
-- fails **15 of 30** scenarios, worst global **-8.8 dB**; inflating the boost
path by 1.5x fails **13 of 30**; `x 1.00003` on the output fails **30/30** at
**-90.4 dB**. The 15 scenarios that survive the tone swap have AMP TONE
`[9584]` = 0, so the crossfade selects the dry path in both engines.

TWO GATE HOLES FOUND AND REPORTED, not worked around:
  * `[10256]` HPF SWITCH is `juno_curve(52, byte)`, which is EXECUTED over all
    256 bytes to be **0.0 at byte 0 and 1.0 at bytes 1..255 -- never
    intermediate** (and constant 1.0 for HPF TYPE=1, `src/hpf_type_lut.c`). So
    the `t*b + a*(1-t)` crossfade at :1591/:1599 is a SWITCH over the whole
    reachable parameter domain, and rewriting it as `a + t*(b-a)` nulls
    EXACTLY 0 in all 30 scenarios. The source's own form is kept anyway:
    `a + fl(b-a) == b` is not a theorem, only an observation over these signals.
  * the same undistributed rewrite of the velocity blend at :1527 also nulls
    EXACTLY 0. Both scenario sets are blind to that class of regrouping HERE;
    they are not blind to it in general (the DCO wrap plant fails 15/30).

No cycle figure is taken from the shim: the cost rig measures `eb_vca_hpf.c`
alone, and it says **1,543 cyc/sample on the S3 at 8 voices** (nominal;
MODELED band 958..4,106).
