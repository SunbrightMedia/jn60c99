# b27 — the VCA move measured on silicon: QEMU was wrong, VCA-only overshoots

`docs/engineb/data/b27_vca_silicon.md` — 2026-08-27

The `S3_VPROF` firmware ran on the board. The number is stable across 20 million
samples and settles the keystone.

## The measurement (RATIOS ONLY, per the build's own rule)

    VPROF vca/vcf = 0.5419   (QEMU predicted 0.3520)   VERDICT: ABOVE BAND

Per-voice relative ticks, steady all run:
`nsvf 54.0  noisemix 37.6  vcf 609.9  vca 330.5  decim 84.9`.

## The QEMU model was wrong by 54 %, and this is why we measured

QEMU counts INSTRUCTIONS; silicon counts CYCLES. b25 flagged the CPI-equality
assumption as the load-bearing risk. It did not hold: the VCA costs 0.54 of the
VCF on the board, not 0.35. On real Xtensa the VCA's work is dearer per
instruction than the ladder's — more FP dependency chains or memory stalls that
an instruction count cannot see.

The decision rule, fixed in the firmware BEFORE the run (playbook 11b), fired
by itself: **ABOVE BAND → the cut must SHRINK.**

## What this rules OUT

VCA-only would move 0.542 × 1083 = **587 cyc**, overshooting the 306–426 parity
window by 161 and making core 1 the critical core. So the simple VCA-only
keystone (b25/b26 branch A) is DEAD by measurement. The measurement stopped us
building a cut that would have moved the bottleneck instead of removing it.

## What lands in the window — and why it is not clean

The window is 306–426 cyc/voice. Only the VCA sits in the movable feed-forward
BACK half (vcf → vca → vout), and it is too big. Everything sub-426 is in the
FRONT half (decim 151, nsvf 96, noisemix 67), which feeds the VCF and so cannot
move a chunk late without dragging the VCF with it.

So there is **no clean single-module back-half cut** in the window. The three
real options, none mechanical:

1. **Move the VCA for a SUBSET of voices.** Per-sample core-0 relief scales with
   how many voices' VCA move. Moving ~2 of 3 core-0 voices' VCA lands the
   aggregate in the window. Needs the per-voice delay banks b26 already
   describes, sized for a subset.
2. **Move the VCA for ALL voices AND re-price the split.** 587 cyc off core 0
   makes core 1 critical at the current SPLIT 7; a smaller core-1 voice share
   could re-absorb it. Two coupled changes, must be measured together.
3. **Split the VCA itself** at a dataflow cut (its control half vs its audio
   half — `eb_vca_control` 41 vs `eb_vca_audio` 33 ticks in the static count),
   moving only the audio half. Unproven that the cut is clean.

## Decision owed to the user, not to this doc
The keystone is still viable — the deficit is real (quiet block 7092 µs vs
5804 µs even here, profiler-inflated but directionally the same +197 µs) and a
move can close it. But VCA-only is out, and each survivor is a DESIGN step with
its own silicon confirmation, not the quick build b26 branch A would have been.
Recommend option 1 (subset of voices): it reuses b26's machinery unchanged and
only sizes the moved set to the measured 0.542.

## Side result, same flash: delay-t5 (b16) CONFIRMED
The MSPP per-patch lines put the excess squarely in the DELAY stage, on exactly
the four DELAY TYPE 5 patches, full windows:

| patch | delay stage (cyc/sample) | vs ~660 baseline |
|---|---|---|
| 49 | 1987–2140 | +1330–1480 |
| 21 | 1765–2085 | +1105–1425 |
| 5  | 1633–2092 | +970–1430 |
| 16 | 1495–1503 | +835–843 |

b16 predicted ~1,500 in stage 1; measured ~1,000–1,480, same stage, same four
patches, NOT spread and NOT in reverb. So the master-chain split stays dead and
the t5 delay ARITHMETIC (b20/b21) is the worst-case lever, as decided.

## Health note (do not quote as shipping)
This build runs BOTH profilers (~11 CCOUNT reads/sample inside the loop), so its
deadline misses, climbing `drift` and `B5 deficit` are profiler overhead, not
the engine. `un=0` throughout. The RATIOS are the only valid output, and they
are what this flash was for.
