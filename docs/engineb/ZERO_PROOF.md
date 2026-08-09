# Structurally-zero coefficients: the evidence, and what it is not
2026-08-09. Tool: `tools/engineb/zero_proof.c`. Reading pass: this document.

## Why the old number could not be used
PLAN_REALTIME.md item 2 records "audit found 39 candidates". The list itself
was never written down, and the scan behind it (`/tmp/zeroscan.c`) read the
FIRMWARE's coefficient blob -- ONE patch, across notes, gates and voices. One
patch cannot separate a slot that is zero BY CONSTRUCTION from one that is
zero because that patch does not use it, and GOAL.md forbids settling that
question with a bank measurement.

## The sweep, five stages, with a non-vacuity witness

  STAGE 1  64 factory patches x 8 voices    52 of 304 zero   moved   1,850
  STAGE 2  31,744 BINDINGS sweeps (31)      52 of 304 zero   moved  25,704
  STAGE 3  4,000 random BINDINGS presets    52 of 304 zero   moved 125,683
  STAGE 4  49,632 record sweeps (79)        52 of 304 zero   moved  31,046
  STAGE 5  3,000 random RECORD presets      52 of 304 zero   moved   4,385

The `moved` column exists because the first run reported "stage 2 and 3 killed
NOTHING", and a zero kill count has two readings that the count alone cannot
separate: the survivors are structural, or the stage perturbed nothing. The
witness settles it -- the stages moved 188,668 slot-values between them and
still could not make any of the 52 nonzero once. Two interfaces are swept, the
31-entry BINDINGS table AND the 79 host parameters that write the patch record
and go through the FULL recall, because recall applies 129 leaves and either
interface alone reaches only a fraction of them.

## THE READING PASS -- AND THE FLAW IT FOUND IN THE SWEEP

**16 of the 52 are NEVER WRITTEN by `eb_render_coefs_build` at all.** They are
PER-SAMPLE scratch fields that happen to live in the coefficient struct.
`eb_dco.h` says so in its own words: "inc/g/pw/pwm1/pwp1 move every sample
(they are modulated)". They read zero because nothing sets them at recall
time, not because any preset leaves them zero -- and **no stage of the sweep
could ever have caught this**, because a field nothing writes is zero under
every preset by definition. Deleting them would break the oscillator.

  NOT CANDIDATES (never written at recall):
    dco      inc, g, pw, pwm1, pwp1
    modcv    pwmarm_b, env1_pitch, env2_pitch, envmix_pitch, pitch_off1,
             bend, bend_pitch
    vcf_cv   termA, v226, c7024x6640
    glide    d_exp

## THE POSITIVE CONTROL, unplanned and the strongest evidence here
Three of the survivors are `vcf c9072`, `c9088` and `c9536` -- EXACTLY the set
`EB_VCF_DEADCOEF` already deletes, proven dead by hand months earlier (the
12 dB and 18 dB ladder taps and the S-1 feedback tap). The method
rediscovered them independently, without being told. That is what makes the
other candidates worth reading rather than merely worth listing.

## THE REAL CANDIDATE LIST: 36 written-and-always-zero, 33 of them new

  lfo      k1856 k1904 k1968 k1984 k2000 k2016 k2032 k2048 k2096 k2112
           k2304 k2336 k2496 k2512                                   (14)
  vcf_cv   k6864 k7008 k7024 k7136 k7216 k7312 k7376                  (7)
  vca      c9552 c9680 c10224 c10368                                  (4)
  vcf      c9536 c9072 c9088          <- ALREADY EXPLOITED             (3)
  dco      sat_in k3 k5               <- INDEX MAP UNRELIABLE          (3)
  glide    k912 k1040                                                  (2)
  nsvf     k84 · vcf_res k7616 · dcoprep k6320                         (3)

The three `dco` entries are held back: the header parser recovered 23 fields
where `sizeof` says 26, so those slot indices may be off by up to three and
the NAMES are not trustworthy. They need an offsetof-based map before anyone
reads them. Saying which three cells they are would be a guess.

## Worth, and the standard still owed
33 new slots, each a load and a multiply-add per voice per sample. Against the
measured 3,394-cycle voice that is plausibly 60-130 cycles, 2-4 %. Unlike
every other lever left, it costs nothing sonically.

It is still NOT A PROOF. Each cell needs its writer traced in the port and the
mechanism stated -- "no interface I drove can reach it" and "no preset can set
it" are different claims, and only the second licenses deletion.
