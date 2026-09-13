# CHAIN4 SOAK GATE — the link's acceptance test (spec, 2026-09-13)

Binding context: the LINK SAFETY DOCTRINE (CHAIN4.md). The link ships
only when this gate is green. Fixed scenarios are one axis, never the
test.

## What runs

All four boards, wired, `run_test.bat`-style capture, duration >= 1 hour
per run. Stimulus on chip 1 in three layers:

1. DETERMINISTIC ROBOT (exists: stress_step, block-counter driven,
   replays exactly from boot). Phases cover chords, program changes at
   contention, and parameter sweeps.
2. SEEDED RANDOM LAYER (BUILT 2026-09-13, stress_step phase 7): an LCG
   drives random key toggles (random slot + velocity), random patch
   jumps, random silence gaps -- one draw per block, so one seed = one
   exact replay. Seed = -DS3L_SEED (default 'JUNO'), printed at boot;
   the SEED: report line carries the live lcg state and the counted
   events. Pitches stay on the robot's 8-key table until the soak build
   adds per-slot note tracking (recorded limitation).
3. FAULT INJECTION (to build): at seeded random times, the harness
   injects the faults the repair system exists for -- a forced realign
   ('t'-tooth style), a skipped TX block (simulated stall), a control
   byte drop. Every injection is COUNTED so the log shows repairs ==
   injections + organic.

## Acceptance (all four consoles, whole run)

- un=0, miss 0/10k on every chip: the DAC never starved (INVARIANT).
- mix=OPEN duty >= 99.9% per hop after the first 60 s; every closure
  matched to a counted cause (injection or counted organic seam).
- ok= rate == chunk rate minus refused; bad= equals seams counted; no
  unexplained residue.
- pat_disc frozen after the first lock on every chip (no re-training).
- Zero torn/param/EVQ red latches except the documented robot-flood
  refusals.
- The chord-6 CRC answer key MATCHES on every chip at every patch the
  run visits.

## Replay law

A failing run's seed reruns EXACTLY. A defect is closed only when the
same seed passes and the fix carries a gate or a counter that would
have caught it (see-it-fail).
