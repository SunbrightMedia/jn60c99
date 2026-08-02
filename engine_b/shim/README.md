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
