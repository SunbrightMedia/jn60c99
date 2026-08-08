# Voice interleaving — the design, ready to execute

## Why it is the lever, in one paragraph

The user's board measures c/i **1.56** with a **FLAT** slope: two voices cost
exactly twice one, so nothing overlaps today. The stall is structural and its
location is known — `eb_vcf_substep`'s cascade is six dependent stages deep:

    nl -> y1 -> y2 -> y3 -> y4 -> S

Each stage is a multiply and an add whose input is the previous stage's
output. On an in-order LX7 with multi-cycle FP latency the pipeline drains at
every stage. This runs **four sub-steps per voice per sample**, and the VCF is
~36 % of a voice. Two voices' cascades are completely independent, so
interleaving them lets each fill the other's stalls.

It changes **no arithmetic**. It must gate at EXACTLY 0, like the two-core
split did — not at the sonic gate.

## What to build

1. `eb_vcf_substep2(sa, ca, insa, Ga, Aa, Rka, outa,
                    sb, cb, insb, Gb, Ab, Rkb, outb)`
   The existing body, duplicated with `_a` / `_b` suffixes and the statements
   INTERLEAVED pairwise. Do not hand-transcribe it: generate it from the
   existing source so the two halves cannot drift. The saturation branch
   differs per voice, so keep each voice's branch intact and interleave only
   the straight-line cascade after it.

2. `eb_vcf_tick2(...)` — the same, for the coefficient prep and the four
   sub-step calls. The decimator stays per voice: it is a fold over a ring,
   already unrolled, and it is not the stall.

3. `eb_engine_render_range()` walks voices in PAIRS. An odd count falls back
   to the single-voice path for the last one.

## The gate, and it is not the sonic gate

    JUNO_EB_VCF_ILV=1 JUNO_EB_LFO_SHARED=1 \
      python3 tools/engineb/null_b.py --module standalone
    -> must be EXACTLY 0 on all 36. Anything else is a transcription error,
       not a design question.

TEETH: perturb one of the two interleaved halves only (e.g. `y3_b * 0.5f`).
If the battery does not FAIL, the second half is not reaching the output and
the pairing is wrong.

## What it is worth, and what it is not

If interleaving takes c/i from 1.56 to ~1.15 across the VCF only (36 % of a
voice), a voice falls from 3,775 to about **3,300**. That is NOT enough on its
own — the target is ~1,700. Extending the same treatment to the VCA, the
envelopes and the wavetable DCO is what would approach it.

STATE THIS PLAINLY when reporting: interleaving is the largest remaining
lever and it is still not obviously sufficient. Six voices with full FX on one
S3 needs per-voice at ~1,700 against 3,775 measured, and no single lever of
that size has been found. Do not quote a figure for interleaving until it is
measured on silicon.
