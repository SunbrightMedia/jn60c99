# REPRODUCE.md -- every JUNO-60 C99 result, rebuilt and re-verified by one command (task #62)

The user's request (2026-10-09): "make sure ALL work, and i mean EVERYTHING Juno-60 C99 related, is
PROVEN repeatable". Proven means RUN: `tools/repro/reproduce.sh` takes a fresh clone of a commit,
rebuilds every gate reference from the plugin, runs every gate and its teeth, rebuilds every
generated table and compares it byte for byte, and checks that the products build to the same bytes.
Its exit code and its REPORT are the evidence; the run is recorded in docs/CLAIMS.md (C-section) and
CLAUDE.md.

## Run it

```
sh tools/run_job.sh repro bash tools/repro/reproduce.sh [COMMIT] [DIR]     # about 10 hours on 4 cores
sh tools/status.sh                                                         # the job; DIR.logs/REPORT
```

COMMIT defaults to HEAD, DIR to `$HOME/juno60_repro` (its logs in `DIR.logs/`). Long jobs only
through `tools/run_job.sh` (CLAUDE.md).

## Inputs (nothing else is read)

| Input | Where | Check |
|---|---|---|
| The plugin: JUNO60.vst3, its factory bank, Script.xml, the Script/ sprite sheets | `truth/` (committed) | `tools/verify/truth.py` (SHA-256 of every file) |
| The user's 11 banks | `scratchpad/userbanks/` (local only, never committed; `$JUNO_USERBANKS` to point elsewhere) | `tools/repro/userbanks.sha256` |
| The Circle library (the Pi track) | the `pi/circle` submodule at its pinned commit | git |

## Toolchain

`bash tools/repro/doctor.sh` lists every tool, its version and the line that installs it; exit 1 when
a required one is missing. Pinned: Python packages in `tools/repro/requirements.txt` (unicorn 2.1.4,
capstone 5.0.7, numpy 2.4.6, pefile 2024.8.26); Node packages in `package.json` + `package-lock.json`
(playwright-core 1.56.1; `npm ci`; the Chromium at /opt/pw-browsers); emsdk 6.0.11; gcc 13.3;
mingw-w64 13; wine 9.0; qemu-arm-static 8.2 + arm-linux-gnueabihf-gcc + arm-none-eabi-gcc (the ARM
golden); aarch64-linux-gnu-gcc/g++ + qemu-system-aarch64 (the Pi track: optional in the doctor).

## The stages and what each proves

| Stage | Command | Proves |
|---|---|---|
| inputs | `truth.py`, `sha256sum -c userbanks.sha256` | the run grades the same plugin and the same user banks |
| doctor | `tools/repro/doctor.sh` | the tools are there |
| test | `make test` | the unit battery (FMA canary, rate laws, goldens, voice / FX units) |
| static | `make static` | the static gates; the ledger is well formed and 38/38 PROVEN; zero approximations; the CLAIMS CENSUS (below) with its two teeth |
| verify | `make verify` | every gate against the plugin (Unicorn), every reference rebuilt in the fresh clone; the teeth of every gate that has them, beside their gates; the early proofs (A1, A3-A6) |
| native | `make native` | JUNO-60.exe built and checked against the plugin itself (8 seeded performances, the patch window's 9 references, the CC menu), with teeth |
| webapp | `make webapp` | the WASM == native, the bundled app, the skin's checks (keyboard, CC menu, patch window) against JUNO-60.exe and the plugin, with teeth |
| engineb | `make engineb` | the engine B foundation (tools/engineb/foundation.sh) |
| regen | `tools/repro/regen_check.py` | every generated table rebuilt from the plugin (its probes first) and byte-equal to the commit |
| determinism | `tools/repro/determinism.sh` | libjuno.so, juno.dll, JUNO-60.exe and the WASM build to the same bytes twice; the committed juno.dll and WASM are what the sources build |
| pi | `pi/run_qemu.sh raspi3ap` | the bare-metal engine on the emulated Pi 3A+: every scenario's hash == the x86 reference == the plugin |
| tree | `git status` | no stage changed a committed file |

## The claims census (`tools/repro/claims_census.py`, in `make static`)

Every row of docs/CLAIMS.md names the scripts that prove it. The census finds, for each row, whether
a make target runs those scripts (named in a recipe, or in the code of a script that is run --
comments and docstrings do not count). A row whose proof moved to newer gates names them in
`tools/repro/claims_routes.tsv` (route / diagnostic / history, each with its reason); a struck row
closed "-> Axx" is as good as the rows it names. Exit 1 on any row with no re-run proof. Teeth:
`--tooth missing` (a row whose script does not exist) and `--tooth unrun` (A3's proof dropped from
the targets) -- both must fail, and `make static` checks that they do.

## What the campaign found (2026-10-09) -- all fixed or stated

| Finding | Fix |
|---|---|
| The proofs of A1, A3-A8 ran in no make target; five ran the plugin and the port in one process (the two-process rule); two could not fail (exit 0 on a divergence); A5's helper no longer ran; A8's script was deleted in July and still cited | A1, A3, A4 rewritten in two processes (param_exhaust*.py, notevel_exhaust.py), A5 and A6 in `tools/verify/script_ab.py`, all in `make verify` (EARLY PROOFS); A7 and A8 point to the gates that prove them now |
| The teeth of seven gates (A24-A33: conv, hostrate, midi, boot, switch, ccmap, state_save) ran in no target | in `make verify`, each beside its gate; two of them always exited 1 on mutants the ledger already called inert -- now named and computed (playbook 172) |
| Generators never committed (the note table, the hostparams table, the arp golden) or fed by dumps not in the repository (juno_tables.h, juno_curve.c, the translations) | the note table regenerated from the plugin (notevel_exhaust.py --check-table: IDENTICAL); the read-only-data tables re-derived from the image (`tools/repro/rdata_check.py`); the rest stated below |
| juno_tables.h juno_exp_ad3c[0] held 2^-24 where the plugin's image holds 2^-32 (never read: a zero exponent skips the multiply) | set to the image's value |
| juno.dll and JUNO-60.exe were not reproducible (a link time stamp; the DLL's automatic image base hashes the output path) | `--no-insert-timestamp`, `--disable-auto-image-base`: two builds give the same bytes |
| The Pi image no longer linked: the GUI meter's log10 (A37) pulled glibc's libm into the bare-metal link (errno), and ld crashed | `pi/kernel/bare_log10.c` (fdlibm), checked against the C library's log10 for every float the meter can see: the same step for all 83,684,754 (`tools/repro/pi_log10_check.c`, with a tooth) |
| The A38 CC tooth stopped biting on seed 1 after A39 (the play test left the modal patch window open) | the play test closes the window (playbook 179) |

## Not reproducible here (stated)

- The derivation of the transcribed sources (src/voice_render.c, master_render.c, juno_init.c,
  chorus_init.c: first passes by tools/translate_*.py from decompile dumps not in the repository,
  then finished by hand). They are not regenerated; every value they compute is graded against the
  plugin by the gates above. Likewise tests/test_apply_golden.c (a self-consistency guard) and
  tests/test_arp_pattern.c (its generator was lost; carp.c is graded against the plugin's own arp by
  arp_sched_ab.py).
- src/juno_hostparams.c: its generator chain (scratch scripts) was lost; its rows are graded by the
  host-edit, state-load and controller-census gates (A20, A22).
- The device: esp32s3/ needs ESP-IDF (doctor: optional) and the hardware -- the SIL probe and the
  bench results are the device's own logs, not repeatable in a container.
- `tools/verify/gate_parity.py` (the JUNO vs JX-3P gate-class ledger) is RED for the JX's owed gates;
  it is about the next synth, not this port, and no target runs it.
