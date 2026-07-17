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

- **Render A/B: 57/57 non-arp (green) + arp split into dedicated gates.** The 7 arp
  patches [1,9,17,25,33,41,49] moved out of recall_render_ab (its oracle can't
  arpeggiate — no transport clock) into two gates now in `make verify`:
  - **arp SCHEDULE: PROVEN 7/7** — `arp_sched_ab.py` drives the plugin's OWN arp under
    emulation (recall + controller-method enable + transport ticks, assigner hooked)
    and diffs vs carp.c. Closed the #96 execution-diff: found + fixed a real carp.c
    omission (the plugin's per-beat re-latch re-quantizes the step grid to the beat
    once per enable; commit 527398e).
  - **arp RENDER: 4/7** — `arp_render_ab.py` replays the (proven) schedule into the
    plugin's render. Patches [1,33,41] diverge from the first arp note-change (sample
    7000). Root cause PROVEN (b2_statediff.py, correct layout = plugin voice v at
    state[v]+v*10512): the port does NOT replicate the plugin's CROSS-VOICE note-on
    broadcast. Playing note 60 (allocated to voice 7) seeds even the NON-allocated
    ALL non-allocated voices in the plugin (skeptical all-8 sweep: at sample 6998
    voices 1-6 each = 68-cell diff, allocated voice 7 = 0-diff; the layout map is
    proven — naive state[v]+0 gives ~220-diff). The port's voice_trigger touches only
    the picked voice. When the arp gates a previously-idle voice, it inherits the
    divergent seed. Invisible for non-arp (ungated voice enveloped to silence).
    (Voice 0's 31 pre-note diffs are benign C++ object-header cells <176, only in
    voice 0's window.) FIX: replicate the plugin's per-unit note-on effect on
    non-allocated voices; verify no regression to 57/57 non-arp + voice-alloc.
    Remaining: why only [1,33,41] audibly diverge (modulation routing).
- Host rates other than 44100/48000/96000: UNVERIFIED (fall back to the 96k arm).
- Arp SCHEDULE execution-diff open; init/prepare constants are RECONSTRUCTED
  (cross-checked against a live state dump — itself a capture — so eventually
  re-prove via emulation).

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
- `gui/web/build.sh` emcc lacks `-ffp-contract=off` (pre-existing; mitigated by
  core WASM having no scalar-FMA opcode + the wasm_golden WASM==native gate).

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
