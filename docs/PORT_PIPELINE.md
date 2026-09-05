# PORT_PIPELINE.md — .vst3 → playing instrument, the mechanical order

**Status: LIVING. Binding for every port after the JX-3P (mantra 4).**
One page. Each step names the tool that does it and the artifact it leaves.
A step with no artifact did not happen. The order is the order the defects
were paid in (METHOD_PLAYBOOK 85–87, PORT_LESSONS 1–7): skipping a step
re-pays its defect.

| # | Step | Tool (repo path) | Artifact / proof | Defect it prevents |
|---|------|------------------|------------------|--------------------|
| 0 | Intake: checksum the binary + Script.xml + banks + .Dat files into `<port>/truth/`; resolve paths only through a `truth.py` | `tools/verify/truth.py` pattern | `truth/SHA256SUMS` | capture-derived data creeping in |
| 1 | **Census** the binary: sections + RUNTIME-FILLED data tails, entry point + CRT initializer tables, parameter name table + ENGINE DB rows, engine vtable | `tools/verify/pe_recon.py <pe> all --json > <port>/gen/recon.json` | `recon.json` (READ) | zero-filled runtime tables mistaken for silence (JX pulse wavetables); id/name guessing |
| 2 | **ABI ledger**: for every entry the harness will call (BUILD, SETSR, NOTEON/OFF, DISPATCH, RENDER, NOTIFY, HOSTPARAM) prove which register each argument is read from | `tools/verify/abi_check.py <pe> NAME=rva ...` | ledger block at the top of `<port>_emu.py` | playbook 87 (SETSR rate in rdx; callee read xmm1 float) |
| 3 | **Oracle boot recipe** (`<port>_emu.py`): static initializers → BUILD → SETSR (per ledger) → FTZ → recall + assigner notify → snap ramps + clear latch. Unmapped pages are LOUD, never silent | `jx_emu.JX().boot(sr, patch, static_init=True)` | `boot()` returns; `faults == 0`; `bss_fill()` reported | un-booted engine proven "bit-exact" against itself |
| 4 | **Listen proof** (charter §7b): render dry, measure — autocorrelation f0 at ±25 cents of the note, tone fraction ≥ 0.10, idle silent, release decays, no NaN over 10 s | `tools/verify/audio_metrics.py` (`verdict`, `spectral_peaks`, `block_profile`, `sketch`) | a PASS line per test note in `<port>/docs/S3_STATUS.md` | inharmonic mush passing green gates; zero-crossing pitch lies |
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
- Runtime-filled `.data` tail read as zeros: pulse/square waveforms streamed
  a zero table; only saw/triangle synthesized. Found by tracing reads of the
  sounding voice (pe_recon `sections` → `runtime_filled`).
- Five confounded "no change" verdicts before the fresh-note rule.
