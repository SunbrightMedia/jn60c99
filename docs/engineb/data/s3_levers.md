# The S3 ladder, measured on the user's own board

All cycle figures are from the LISTEN firmware's own sweep, single core,
44,100 Hz, voices only (no FX). Slope and intercept from a linear fit whose
increments agree to within 31 cycles.

## Where it started, and lever 1

| voices | trunk  | + wavetable DCO |
|--------|--------|-----------------|
| 0      |  2,557 |  2,815          |
| 1      |  7,573 |  6,587          |
| 2      | 12,587 | 10,361          |
| 3      | 17,609 | 14,139          |
| 4      | 22,654 | 17,919          |
| 6      |   --   | **25,499**      |

Slope 5,017 -> **3,775 cycles/voice, a 24.8 % cut** (22 % was predicted).
Intercept 2,557 -> 2,815: the at-rest wavetable advance costs more than
eb_dco_advance, and is worth it many times over.

The 6-voice point was PREDICTED at 25,465 from the 0..4 fit and MEASURED at
25,499 -- 0.1 %. The model is linear and it holds at the point that matters.

## Lever 2: the second core had never run a sample

There is no xTaskCreatePinnedToCore anywhere in the firmware. Every number
this project has ever quoted is single core, while the 10,884-cycle budget
they were compared against assumes two. That is a factor of two sitting
untouched.

eb_engine_render_range(v0, v1) renders a voice range; voice v touches only
slot v of every array, so ranges are independent. eb_engine_render_shared()
computes what both cores need first: the shared noise LFSR, voice 0's cvgate
and glide, and (under EB_LFO_SHARED) the one LFO whose input is voice 0's
glide output.

WHY THE PROLOGUE EXISTS. Without it the range holding voice 0 must finish a
whole voice before the other core can start, which serialises one voice in
six and caps the split near 1.5x. The prologue is three cheap calls, so both
cores then run three voices fully in parallel.

GATED: JUNO_EB_SPLIT_TEST=N runs both calls in order on one core so the whole
battery gates them. 36 of 36 EXACTLY 0, at every split boundary 1..5.

TEETH, after two invalid attempts that are worth recording:
  - DELETING the shared-noise publication measured EXACTLY 0. An
    uninitialised local's value is not controlled, so that case measured the
    COMPILER. Already in this repo's catalogue; walked into anyway.
  - PERTURBING it, on the firmware's own blob, still passed -- that patch's
    noise level is 0, so the path was covered by scenario luck.
  - Under the full battery: shared noise perturbed -> FAILS on DCO noise at
    -19.4 dB rel. Prologue pitch_cv perturbed -> 14 scenarios FAIL. Prologue
    LFO perturbed -> 22 scenarios FAIL.

MEASURED INERT, not assumed: voice 0's dly_env is dead inside the range under
EB_LFO_SHARED. Its only two consumers are LFO calls, and the prologue already
supplies the LFO. Perturbing it changes nothing on all 36, and that is a
property of the code rather than a weakness of the gate. It is carried for
the non-shared build, where the per-voice LFO consumes it.

## The ladder from here

Measured: 6 voices, one core, wavetable = 25,499 cyc = 2.34x over 10,884.

| step                                   | cycles | over  |
|----------------------------------------|--------|-------|
| wavetable, one core (MEASURED)         | 25,499 | 2.34x |
| + both cores with the prologue         | ~12,900| 1.19x |
| + ladder at 1x (zero-delay feedback)   | ~9,400 | 0.86x |
| + chorus (~660)                        | ~10,060| 0.92x |

The two-core row is arithmetic on a measured single-core number, not a
measurement. It is the next thing to put on silicon.
