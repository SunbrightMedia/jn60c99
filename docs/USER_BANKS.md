# USER BANKS -- the port against the user's own banks

LIVING. The user's banks are INPUT, never ground truth, never committed (they
live in scratchpad/userbanks/, gitignored). The plugin, executed under Unicorn,
is the oracle; a bank only chooses what it is asked.

## Why

Every factory-bank gate grades 64 patches. The user's banks are real patches a
sound designer made: they reach values and MIXES of values no factory patch
holds. The seeded gates (seed_recall_gate.py, state_load_gate.py) reach every
value, in random mixes; a bank reaches the mixes people use. The two found the
same defect in August (ASSIGN MODE 3: docs/ASSIGN_MODE_3_FINDING.md, CLAIMS A16).

## What a bank reaches -- tools/bank_census.py

A raw-byte census of the 79 host parameters' record fields, no decode. The 11
banks of 2026-10-07 (704 patches) hold **3575 raw parameter values the factory
bank never holds**, among them:

| field (raw record value) | patches |
|---|---|
| ASSIGN MODE 3 | 24 |
| DELAY TYPE 4 (the flanger) | 18 |
| EFFECT TYPE 0 / 4 | 29 / 10 |
| DCO RANGE 1 | 13 |
| DCO PWM SOURCE 5 | 5 |
| OCTAVE SHIFT 1 / 2 / 3 / -2 | 2 / 1 / 1 / 3 |
| KEY HOLD 1 | 2 |
| REVERB TIME 0 | 7 |
| DELAY FEEDBACK nibble pairs 8,5 / F,7 | 5 / 2 |
| BEND RANGE: 13 values the factory bank (one value) never holds | 13 values |

## What runs -- tools/verify/userbank_parity.py, one bank at a time

Per bank (its own truth directory: symlinks to the real plugin and Script.xml,
the bank as presetbankog1.bin, a regenerated SHA256SUMS; its own scratch names
through $JUNO_SCRATCH_TAG, truth.scratch()):

| gate | path graded | patches |
|---|---|---|
| recall_gate.py | the recall MODEL's cold state, the cells the plugin's recall enumerator writes | 64 |
| recall_render_ab.py at 44100 and 48000 | the recall MODEL (juno_gui_apply_bank: the device firmware's path), one cold engine per patch, one note | the non-arp ones |
| bank_product_gate.py at 44100 and 48000 | THE PRODUCT PATH: the plugin's patch browser (rva 0x335850) of every record, warm, through its own process() at the default engine-rate setting (96000 + its converter), keys at offsets, a key held across each load, steals at six voices, the transport at 120 BPM -- the arp patches arpeggiate | 64 |

Run: `sh tools/run_job.sh <name> python3 tools/verify/userbank_parity.py
--parallel 0 --rates 44100,48000` -- every bank at once (the user's call,
2026-10-07), one worker process each (~560 MB; 11 banks fit in 16 GB). A bank
that ends in an ERROR -- no verdict: a tool killed, e.g. out of memory, or one
that raised -- runs again with half as many banks at a time, down to one; a
FAIL is a verdict and never re-runs. One bank: `--only '<name>'` (run_job loses
quotes: put that command in a script, playbook 118).

## Results

All 11 banks at once (job ub_all2, commit 6a6cc2c7, 2026-10-08, EXIT 0; every
count below read from the per-bank logs, not only the exit codes):

| bank | recall | render 44100 | render 48000 | arp patches | product 44100 + 48000 |
|---|---|---|---|---|---|
| 2 Preset | 64/64 | 64/64 | 64/64 | 0 | 16/16 chains |
| Analog Stars | 64/64 | 53/53 | 53/53 | 11 | 16/16 chains |
| Basses Pads And Arpeggios | 64/64 | 43/43 | 43/43 | 21 | 16/16 chains |
| Brothertiger | 64/64 | 55/55 | 55/55 | 9 | 16/16 chains |
| Chillwave | 64/64 | 56/56 | 56/56 | 8 | 16/16 chains |
| CyberCity | 64/64 | 60/60 | 60/60 | 4 | 16/16 chains |
| Deep House | 64/64 | 60/60 | 60/60 | 4 | 16/16 chains |
| FutureBass | 64/64 | 64/64 | 64/64 | 0 | 16/16 chains |
| Outrun | 64/64 | 57/57 | 57/57 | 7 | 16/16 chains |
| SynthPop | 64/64 | 58/58 | 58/58 | 6 | 16/16 chains |
| Synthwave | 64/64 | 64/64 | 64/64 | 0 | 16/16 chains |
| **11 banks** | **704/704** | **634/634** | **634/634** | **70** | **176/176 chains: 704 patches x 2 rates** |
| factory (make verify) | 64/64 | -- | 57/57 (+ 7 arp: arp gates) | 7 | 16/16 chains (job upg_factory) |

Every sample of both channels bit-exact; the recall cells 0 mismatches. The 70
arp patches arpeggiate in the product gate (the transport at 120 BPM).

The first all-at-once run (job ub_all) lost five reference builds to the
container's memory limit (playbook 161); fixed, the second run needed no halving.

## Found on the way (harness)

1. JUNO_SCRATCH_TAG was set by the driver and read by no tool: a user-bank run
   replaced the factory bank's recall references (playbook 159). Fixed:
   truth.scratch(); a truth directory other than truth/ with no tag is refused.
2. recall_render_ab.py --ref loaded libjuno.so inside the oracle process to
   pick its patches (two-process rule). Fixed: the reference renders all 64.
3. bank_product_gate.py's first late-note tooth sat inside the start-up mute
   and could not bite (playbook 160). Moved after the mute: it bites.
4. Two reference builders kept every Unicorn engine alive: eleven banks at
   once were OOM-killed (playbook 161). Fixed: each instance freed and
   collected (memory flat, measured in-process).

## Scope

Not graded here: host rates other than 44100 / 48000 for the user banks (the
factory bank runs 18 rates in make verify); DAW presets (setState) made from
these patches (state_load_gate.py grades the path on factory and seeded
records); live edits on top of a user patch.
