# JUNO-60 (JU-06A) C99 port — project memory

**Read `GOAL.md` first — it is the user's own statement of the goal and is binding.**
Short form: a bit-exact C99 port of the Roland Cloud JUNO-60 (JU-06A) VST3 DSP that
sounds EXACTLY like the original, playable in the browser (WASM), portable to a
Teensy 4.1 later. The shipped engine is plain portable C99 — emulation is an
analysis tool only; nothing emulated may be required at runtime. Recall must be
correct for ANY preset value, not just the factory bank's ("this byte is 0 in every
factory patch" is not an excuse to skip it).

## The one rule everything else serves

**The original `.vst3` is the ONLY ground truth.** The port must be SELF-PROVING:
every coefficient proven bit-exact against the plugin's own machine code, executed
under Unicorn. Never validate by ear, never ask the user to A/B — that is a
"capture" and is forbidden. "Done" = `make verify` green, i.e. zero non-PROVEN rows
in `PROVENANCE.tsv` (the status authority; it supersedes GOAL.md's pointer to
`docs/AUDIBLE_RECALL_PLAN.md` and every prose doc).

## Hard rules (violating any of these corrupts the project)

- **Ground truth = the plugin binary executed under Unicorn.** Running its machine
  code is allowed and is NOT a capture. Reading the plugin's own `Script.xml`
  (in `truth/`) is allowed plugin data.
- **NEVER open, read, or reference files named `user_patch5_ableton.json` or
  `captured_coeffs.json`** — anywhere, ever, including in subagent/workflow prompts.
  They are runtime captures; reading one risks contaminating a coefficient with a
  value not derived from the plugin. If such a file appears, delete it by name
  without reading it. (The rule stands even while no such file exists.)
- **No captures as data.** No Frida dumps or runtime snapshots feeding the port.
  A constant whose provenance is a capture is a bug to be replaced (ledger status
  CAPTURED).
- **Two-process rule:** never build a Unicorn E2E instance AND ctypes-load
  `libjuno.so` in the same Python process. Oracle and port runs are separate
  processes; they meet only through pickles.
- **Harness = plumbing only.** Emulation harnesses may set up memory, stub
  Win32/COM/CRT/ABI, hook istream reads, wire registers, and observe. They may
  NEVER reimplement plugin logic (no hand blob→param map, no hand value transform,
  no reconstructed recall table used as ground truth).
- **Label every claim** PROVEN(executed) / READ(static decomp or Script.xml) /
  INFERRED. No over-claiming, ever.

## Ground truth & paths

`truth/` holds `JUNO60.vst3`, `Script.xml`, `presetbankog1.bin`, `SHA256SUMS`
(checksum-verified). Resolve paths ONLY through `tools/verify/truth.py`
(`truth.VST3 / .SCRIPT_XML / .BANK`, `$JUNO_TRUTH` override, `verify()`/`require()`).
Never hardcode an uploads/absolute path — those die with the container.
`refs/allcode_decomp.tgz` is the full IDA decompile (provenance for RECONSTRUCTED
rows). Git history was rewritten 2026-07 to purge RE dumps — never restore them
from an old clone.

## Build & verify

- `make libjuno.so` — the engine (GUI + ctypes gates load this).
- `make test` — functional suite (unit battery: self-consistency + frozen-recording
  checks; it does NOT compare against the live plugin).
- `make verify` — the finish line: `test` + the LIVE plugin comparisons (recall_gate
  67-cell diff + full render A/B, both actually executed every run; reference
  pickles auto-regenerate from truth/ when the scratchpad is fresh) + the
  provenance ledger check + the completeness scan (every constant-bearing source
  file must be claimed by a ledger row's `sources` column — the net that catches
  MISSING rows, which is how the delay-feedback capture survived). RED while any
  gate fails or any CAPTURED/RECONSTRUCTED/UNVERIFIED row remains.
- `bash gui/web/build.sh` — WASM rebuild (emsdk); `node tools/verify/wasm_golden.mjs`
  proves WASM == native.
- `-ffp-contract=off` is load-bearing (reference is x86 SSE2, no FMA); the FMA
  canary test fails loudly if contraction slips in.

## Canonical gates (tools/verify/)

`truth.py` (paths/checksums) · `e2e_emu.py` (the Unicorn oracle) ·
`real_bank_parse.py`/`real_recall.py` (plugin's own parser + recall) ·
`plugin_recall_set.py` (plugin's own recall enumerator, rva 0x3B48A0) ·
`plugin_recall_ref.py` (self-proven recall reference) · `recall_gate.py`
(port vs plugin recall, 67/67 voice cells, 64 patches) · `recall_exhaustive_ref.py`
+ `recall_exhaustive_gate.py` (recall EXHAUSTED: every single-input front-panel cell
vs the plugin's setter over all 256 byte values x 3 rates; multi-input product/joint
cells deferred to recall_gate + formula tests) · `recall_render_ab.py`
(render A/B vs the plugin's own recall+render — the ONLY reliable FX gate, because
FX state is prepare/render-populated and cannot be gated from a cold apply_bank) ·
`gen_teensy_golden.py`/`wasm_golden.mjs` (Teensy/WASM reproducibility) ·
`provenance_check.py` (ledger linter) · `completeness_scan.py` (constants→ledger
attribution net; also audit-trails positive "captur*" comment mentions).

## Known open work (live list = PROVENANCE.tsv)

- **Render A/B: ALL 64 factory patches BIT-EXACT.** 57 non-arp (recall_render_ab)
  + 7 arp via two dedicated gates in `make verify` (recall_render_ab's oracle can't
  arpeggiate — no transport clock):
  - **arp SCHEDULE: PROVEN 7/7** — `arp_sched_ab.py` drives the plugin's OWN arp under
    emulation (recall + controller-method enable + transport ticks, assigner hooked)
    and diffs vs carp.c. Closed #96: the plugin's per-beat re-latch re-quantizes the
    step grid to the beat once per enable (commit 527398e).
  - **arp RENDER: PROVEN 7/7** — `arp_render_ab.py` replays the proven schedule into
    the plugin's render. The former [1,33,41] divergence's root cause (PROVEN,
    b2_statediff/b2_bcast2: the plugin's note events broadcast the "any key held"
    flag — cell 1856, = held-count>0 — to ALL 8 voices; the port set it only on the
    allocated voice, so an idle voice's free-run state diverged and the arp gating it
    inherited the seed) is FIXED by `juno_note_broadcast_held()` called from the
    assigner-level note paths (synth_note_on/off + bank-apply flush). Layout note:
    plugin voice v renders at state[v]+v*10512, NOT state[v]+0.
- **init/prepare constants: PROVEN** (`coldstate_ab.py`, LIVE GATE 6/7). The port's
  power-on state (init + prepare + chorus_init) is bit-identical to the plugin's own
  constructor + setSampleRate under Unicorn at 44100/48000/88200/96000/192000 — only
  the benign C++ header (<176, audio-inert) + 6 FX-recall-default cells (self-proved
  inert) differ. Retired the live-state-dump cross-check (the last capture). Caught +
  fixed 5 real 44100-only reconstruction bugs (102656 spurious rate-case; 4 Rev Ecf
  DPF Fc missing the 44100 arm) the single-rate live dump never exercised.
- **other host sample rates: PROVEN.** cold-state bit-exact at 88200/192000;
  recall PROVEN (exhaustive 624 + HPF 10240 exact multiply-first law — audit
  re-derived it independently and confirmed bit-exact at 60000 Hz too, 6144
  comparisons 0 mismatch); render is rate-agnostic (grep-verified: no state[16]
  read in voice/master render) and LIVE GATE 7/7 runs the full 57-patch render
  A/B at BOTH 44100 and 88200 — both BIT-EXACT 57/57 (44.1k added post-audit:
  it closed the one coverage gap, no render gate at the most common host rate).
- **PROVENANCE.tsv is 17/17 PROVEN** — zero RECONSTRUCTED/CAPTURED/UNVERIFIED. The
  binding finish line (`make verify` green = zero non-PROVEN rows) is met.
- WASM artifacts REBUILT + verified: `gui/web/build.sh` (now with `-ffp-contract=off`)
  regenerates `gui/web` + `docs` from current source; `wasm_golden.mjs` proves the
  delivered WASM is bit-exact to native (8/8) on the 44.1 kHz golden corpus. emsdk
  lives at `scratchpad/emsdk` (source `emsdk_env.sh` before building).

## Standing audit caveats (Phase-E confirmation audit, 2026-07-17)

- Commit be3f1db's "these only affected 44.1 kHz reverb" OVERSTATES audible impact:
  recall unconditionally rewrites all 5 fixed prepare cells per patch
  (juno_apply_reverb writes the 4 DPF Fc with its own independently-derived
  REV_FC44/REV_FC tables — audit-verified == the plugin's setter; delay_recall
  writes 102656), so the old bugs were recall-masked for every patch render. Their
  only reachable surface was the pre-recall power-on state at 44.1k (reverb send 0).
  The cold-state fix is still required — the plugin's cold state is the ground truth.
- Of coldstate_ab's 6 excluded FX-recall-default cells, 2 (11022052 routing int,
  11022344 master counter) are engine plumbing NEVER written by the port at all —
  earlier phrasing "written by recall when a patch engages the effect" over-claimed
  for them. All 6 audit-proven inert PER CELL (24 poke-renders, byte-identical
  output, sentinel intact after 24000 frames; none read in any render source).
- coldstate_ab.py hardcodes the main-tree libjuno.so + pickle paths — run from a
  git worktree it silently gates the MAIN tree's library (project-wide convention,
  but a sharp edge for worktree-based testing).
- HPF 10240 law precision (audit re-trace): the divisor is cvtdq2ps of an INTEGER
  rate dword (== f32(H) for every integer host rate; port mirrors the int
  semantics), and the plugin SKIPS the mul/div at exactly 96000 (port does too via
  the table arm). T96 fetch lives in helper rva 0x3563BE.., store via 0x3C2763.

## Standing audit caveats (B1 confirmation audit, 2026-07-16)

- `delay_fb_sweep.py` is one-shot EVIDENCE, not a recurring gate: it always exits 0
  and is not in `make verify`. Ongoing enforcement of the delay law = exhaustive
  recall + render A/B + test_delay_recall (mutation-tested: both catch a wrong
  constant at exact coordinates).
- Commit 603f927's "no previously-passing patch changed" was argued too broadly:
  12 other TYPE-0 delay patches DID get new feedback coefficients; the gates
  confirm they still pass, but the diff alone didn't prove it.
- The feedback OFF-gate (102560 → 0 when DELAY LEVEL < 2) rests on captured OFF
  states; render-equivalent either way (wet=0), but re-prove via emulation when
  convenient.
- `gui/web/build.sh` now passes `-ffp-contract=off` (matches the native build); the
  wasm_golden WASM==native gate remains the standing safety net (8/8 bit-exact).

## Git

- Branch `claude/c99-gui-fable5-yfhak1`. `git push -u origin <branch>`, retry on
  network errors (2s/4s/8s/16s backoff). No PRs unless explicitly asked. Never put
  a model ID in commits, code, or any pushed artifact.
- Commit trailer (verbatim, every commit):
  `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`
  `Claude-Session: https://claude.ai/code/session_012SxLAY1bDPn2jACwFDPupA`

## Working style

Simplest fix that holds; reuse proven `juno_curve` tables and existing gates before
adding machinery. One reversible commit per fix; a change isn't done until its gate
is green. Proceed autonomously on reversible work; stop only for destructive or
scope-changing decisions.
