# b17 — the 52-minute run measured nothing, and what it still proved

The user ran the `EB_MSPROF=1` build for ~52 minutes. The profiler it was built
for produced no data. Three things in the log are nevertheless worth keeping.

## 1. The profiler was not connected to the clock

Every report line, for the whole run:

    MSP: in=1 delay=1 reverb=1 out=1 effect=1 cyc/sample  (n=... samples)

Five independent stages cannot all cost exactly one cycle, and they cannot stay
at exactly one while the sample count changes. That is the signature of the
host stub `(++eb_msprof_fake)`, which steps by one per read.

`juno_s3_listen.c` defined `EB_MSPROF_TICK()` to the cycle counter.
`eb_master.c` is a different translation unit and never saw it. Full account
and rules: **playbook 72**.

**b16's prediction — stage 1, ratio 1.7-2.0x on patches 5/16/21/49 — is still
UNTESTED.** Nothing in this run bears on it.

## 2. The fix, and the check that now exists

`eb_master.c` selects the clock from `__XTENSA__`, in its own file, and reads
CCOUNT with one inline `rsr.ccount` — no `<xtensa/hal.h>`, so no ESP-IDF
dependency enters `engine_b/`.

Proven in the assembly that actually ships, which was never checked before:

| build | `rsr.ccount` sites | stub references |
|---|---|---|
| target, `EB_MSPROF=1` | **6** | 0 |
| target, default (OFF) | **0** | — |

Six is exactly the six `MSP_T0` / `MSP_HIT` sites, one per boundary per sample.

Trunk gate with the profiler compiled in: `JUNO_EB_MSPROF=1 null_b.py --module
all` -> **PASS, worst global residual EXACTLY 0 everywhere**. The probes do not
move a sample.

New tooth, on the board: if every stage reads <=1 the log prints
`MSP: *** BROKEN` and says to ignore the run. The failure now announces itself.

## 3. What the run DID prove — and it is not nothing

### O3 holds over 52 minutes

    PARAM: edits=76779 builds=5133 defer=5528 unknown=0 pubretry=0
           apply=172636 applymax=302245

* `unknown=0` — no knob reached the machine that the class table cannot place,
  across 76,779 edits.
* `pubretry=0` — no build was handed to the publish contract twice.
* **15.0x coalescing** (76,779 edits -> 5,133 rebuilds), matching the 15.3x of
  the 425 s run. The rate is a property of the design, not of a short sample.
* `applymax=302245` cycles, still inside the slack the budget was sized
  against (playbook 63).

O3's silicon claim now rests on a run 7x longer than the one it was made from.

### b16's patch attribution survives the longer run

`FXP: fx=` still swings 2,4xx-4,4xx, and the peaks still land on `pat=` 5, 16,
21, 49 — the bank's only DELAY TYPE 5 patches — plus 51, which b16 already
recorded as probable boundary residue and did not claim. A 425 s run could have
caught a coincidence; 52 minutes of patch stepping does not.

⚠ These `FXP:` figures come from a build with the profiler compiled in. Under
the rule stated in b16 §3 they may be read for WHICH patches are hot and not
for HOW MUCH — the six extra reads per sample sit inside the measured region.
The clock stub does not change that: the profiler still executed, so it still
cost time; it simply reported a counter instead of cycles.

### Drift is consistent with b14

`drift=+176710` ms over the run, i.e. the engine is behind by ~177 s of audio
time. b14's reconciliation of block duration against the drift counter is
unchanged by anything here.

## 4. What is next, unchanged

Rebuild with the corrected tick, re-run the O3 gates, flash, and read the
`MSP:` line for the ratio. The judgement stated in b16 §4 stands verbatim and
is not restated here.
