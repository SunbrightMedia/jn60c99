# PORT_PIPELINE.md — .vst3 → playing instrument, the mechanical order

**Status: LIVING. Binding for every port after the JX-3P (mantra 4).**
One page. Each step names the tool that does it and the artifact it leaves.
A step with no artifact did not happen. The order is the order the defects
were paid in (METHOD_PLAYBOOK 85–88, PORT_LESSONS 1–9): skipping a step
re-pays its defect.

| # | Step | Tool (repo path) | Artifact / proof | Defect it prevents |
|---|------|------------------|------------------|--------------------|
| 0 | Intake: checksum the binary + Script.xml + banks + .Dat files into `<port>/truth/`; resolve paths only through a `truth.py` | `tools/verify/truth.py` pattern | `truth/SHA256SUMS` | capture-derived data creeping in |
| 1 | **Census** the binary: sections + RUNTIME-FILLED data tails, entry point + CRT initializer tables, parameter name table + ENGINE DB rows, engine vtable | `tools/verify/pe_recon.py <pe> all --json > <port>/gen/recon.json` | `recon.json` (READ) | zero-filled runtime tables mistaken for silence (JX pulse wavetables); id/name guessing |
| 2 | **ABI ledger**: for every entry the harness will call (BUILD, SETSR, NOTEON/OFF, DISPATCH, RENDER, NOTIFY, HOSTPARAM) prove which register each argument is read from | `tools/verify/abi_check.py <pe> NAME=rva ...` | ledger block at the top of `<port>_emu.py` | playbook 87 (SETSR rate in rdx; callee read xmm1 float) |
| 3 | **Oracle boot recipe** (`<port>_emu.py`): static initializers → BUILD → SETSR (per ledger) → FTZ → **the controller's default push** (`host_init()`: walk the controller's host-id map -- `host_map()`, built by the static initializers -- and write each MAPPED id's engine-DB default through the HOST PARAM ENTRY; the host-id numbering is NOT the engine numbering, host id 2 is MASTER TUNE) → SNAP ramps + clear latch (the hosted steady state; live boot ramps with limit 0 poison the master EFX) → recall + assigner notify (recall re-arms per-patch ramps). Unmapped pages are LOUD, never silent | `jx_emu.JX().boot(sr, patch, host_init=True)` | `boot()` returns; `faults == 0`; master finite over 12000 idle samples | un-booted engine proven "bit-exact" against itself; master EFX self-poisoning (NaN ramps 541/542 at idle sample 3681) |
| 4 | **Listen proof** (charter §7b): render dry AND through the master, measure — autocorrelation f0 tracks the keys by one whole number of semitones (±25 cents), harmonicity ≥ 0.80 (detune-tolerant), idle silent, release decays, no NaN over 12000 samples | `tools/verify/audio_metrics.py` (`verdict`, `spectral_peaks`, `block_profile`, `sketch`) | a PASS line per test note in `<port>/docs/S3_STATUS.md` | inharmonic mush passing green gates; zero-crossing pitch lies |
| 5 | Transcribe DSP + control plane layer by layer, each with its own seq/emu/c/gate quartet and a tooth SEEN TO FAIL | `<port>/tools/<layer>_{seq,emu,c}.py` + `<layer>_gate.sh` | EXACTLY 0 + tooth line in S3_STATUS | untested reach (charter §2) |
| 6 | Export the clean-boot template + per-patch recall aux FROM THE STEP-3 BOOT (fresh build per patch) | `<port>/tools/<port>_template_export.py`, `<port>_master_recall_export.py` | `<port>/gen/*.bin(.gz)` with NaN census 0 | playbook 86 (state bytes ≠ state; heap mirrors) |
| 7 | Full-chain gate through the SHIPPING entry path (`<port>_init` → `recall` → `note_on` → `render`) vs the oracle driving itself the same way, plus the step-4 listen verdict on the C twin | `<port>/tools/<port>_full_gate.sh` | GREEN + PASS lines | the app plays something the oracle never did |
| 8 | Web shell: emcc build (no zlib, separate wasm, ASCII page), Pages mirror, artifact page generator reading COMMITTED inputs only | `<port>/gui/web/build.sh`, `<port>/tools/<port>_artifact_page.py` | `docs/<port>/`, artifact URL in S3_STATUS | inputs in `/tmp` that die with the container |
| 9 | Legacy: playbook entry the day a defect is paid; S3_STATUS one line per track; INDEX.md row | `docs/engineb/METHOD_PLAYBOOK.md`, `<port>/docs/PORT_LESSONS.md` | dated entries | the next port re-paying this one's defects |

## Rules that the table cannot show
- Steps 1–4 come BEFORE any transcription. A port that cannot pass step 4
  on the ORACLE is not ready to be transcribed — the drive is wrong, and every
  gate built on it will be a self-consistent lie.
- A/B gates prove agreement under the same drive. They never prove the drive.
  Step 2 and step 4 are the drive's proofs.
- Every measurement in step 4 is by number. Never by ear; never ask the user
  to A/B. The user's ears are a DEFECT REPORT that starts an investigation.
- When a probe shows "no change", check the confound first: parameters latch
  at note-on (measure on a FRESH note), in-place restores poison later trials
  (fresh build per trial), and zero-crossing pitch lies (autocorrelation +
  tone fraction).

## What the JX-3P paid to write this page (2026-09-04/05)
- SETSR ABI (playbook 87): weeks of green gates on an engine with no rate.
- Bank decode 16 bytes off (playbook 88): every pool got its neighbour's
  value; the recall gate stayed green on the same wrong values. A REFUTED
  detour on the way: "runtime-filled `.data` read as zeros" — the traced
  page was a CRT global on its legitimate SSE2 path. Keep the census step
  (it is cheap) but the decode tooth (`jx_bank_census.py`) is what found it.
- Link pointers wired to template copies instead of live cells (lesson 8).
- The controller's default push missing (lesson 9): master EFX NaN at idle
  sample 3681, outside the 1200-sample gate window. Root cause split in two:
  the poison itself dies with the SNAP (the hosted steady state), and the
  default push must follow the controller's OWN id map (`host_map()`) --
  choosing values by the host id's DB row detuned the port -39.5 cents
  (host id 2 = engine MASTER TUNE). Gate reach is 12000 samples now.
- Five confounded "no change" verdicts before the fresh-note rule.
