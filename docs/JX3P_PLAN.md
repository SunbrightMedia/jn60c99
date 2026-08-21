# THE JX-3P PLAN — port-level C99, no hiccups, as fast as the method allows

**Scope:** the JX-3P equivalent of this repo's `src/` — a bit-exact, self-proven
C99 port of the plugin's DSP and recall, `make verify` green, zero
approximations, full PROVENANCE. **Not** in scope: the ESP32 fork, device
recall, or boards. That is a later decision with its own budget numbers.

**Nominal timeline: 5 working sessions. With slack for the unknowns S1 names:
7.** The clock starts when the intake checklist below is complete. This is
also E5 — the first traversal of `docs/PIPELINE.md` — so every hole it finds
in the pipeline gets fixed *in the pipeline*, which is half the point.

---

## 0. INTAKE — what you supply, what I verify on receipt

| item | why | verified how |
|---|---|---|
| the JX-3P `.vst3`, the exact file you use | THE ONLY GROUND TRUTH | checksummed into `truth/`, resolved only via `truth.py` |
| `script.xml` | the parameter surface — names, ranges, indices | cross-checked against the binary's own parameter tables in S1; **the binary wins every disagreement** |
| the factory preset bank | recall's input and the gate battery's patch set | if it lives inside the .vst3, extracted in S1; if it is a separate file, supply it |
| one answer: **same vendor as the JUNO-60 plugin?** | same vendor = same decompiler idioms, the transformers apply directly; different vendor = S1 carries a re-scoping checkpoint | your answer, then confirmed against the binary in S1 |
| sample rates you care about | the gate matrix (JUNO certifies 44.1/48/96 k) | listed in the config file, gated at each |

**Not needed, and refused if offered:** DAW bounces, runtime captures, user
banks as reference. The diagnostic-capture covenant applies from minute one —
a capture-derived constant is a bug by definition.

---

## S0 — PIPELINE PAYDOWN (can start NOW, needs no JX-3P material)

The de-JUNO audit prints 16 carried constants in 3 item-7 tools. Every one
becomes a parameter before the JX-3P touches the tools, so no JUNO number can
leak into the new port silently.

1. **One config file per synth** — `synth.cfg` (bank geometry, state stride,
   scatter cell list, ring tables, rates, patch count). `arm_xform.py`,
   `gen_devcells.py`, `make_boot.py` read it; the JUNO's values move into
   `synth/juno60.cfg` and `make verify` must stay green after the move —
   proof the parameterisation is faithful.
2. **Repo layout decided now, not mid-port:** the JX-3P lives in this repo
   (the tools and gates are the shared asset) under `jx3p/{src,truth,docs}`,
   with `tools/*` taking `--synth`. JUNO paths stay where they are; only the
   tools learn the parameter.
3. `dejuno_audit.py` gains the rule: an item-7 tool may read a `synth.cfg`
   and nothing else. Tooth updated, seen to fail.

**Exit gate:** JUNO's `make verify` green through the config indirection;
audit clean with zero `JUNO-BOUND` markers left in manifest tools.

## S1 — INTAKE + STATIC EXTRACTION + THE GO/NO-GO CHECKPOINT

1. Phase 0 verbatim: checksum, `truth.py` entries, empty PROVENANCE.
2. Run the extractors; locate the render entry, the recall/setter layer, the
   flat state block and its size; decode the bank container.
3. **THE CHECKPOINT, criteria written here in advance.** The whole speed of
   this plan rests on the JUNO idioms holding. Confirm, from the binary:
   - flat-state addressing (`*(float *)(a1 + N)`) — the transformers' input
   - SSE2 single-precision, no FMA — the `-ffp-contract=off` reference
   - a coefficient/setter split resembling the JUNO's
   If **all three hold**: proceed, timeline stands. If any fails: STOP, write
   the delta into this plan with a revised estimate, and get your sign-off
   before spending sessions. No silent re-scoping.
4. Adapt the Unicorn harness entry points (`e2e_emu.py` — the per-plugin part
   is the entry map, not the machinery). Two-process rule from the start.

**Exit gate:** the plugin's own code recalls patch 0 and renders one block
under Unicorn; the state dump is stable across two runs.

## S2 — THE ORACLE OWNS EVERY CONSTANT

1. Recall each factory patch under the emulator; dump coefficients; derive
   every recall constant BY EXECUTION; PROVENANCE row per constant.
2. Enumerate parameter leaves; reconcile against `script.xml`; **exhaustive
   256-value sweeps per leaf, never sampled** — the JUNO had a parameter live
   at exactly 1 value of 256 and sampling missed it (paid twice).
3. Multi-patch corroboration for every binding: a binding derived from one
   patch that another refutes is the standard failure (playbook: probe
   defects 1–3). Randomised bases are ADDITIONAL, never substitutes.

**Exit gate:** all factory patches recalled with zero INFERRED coefficient
rows; the leaf map complete against both the xml and the binary.

## S3 — MECHANICAL TRANSCRIPTION

1. `translate_voice/master/init` + `arm_xform` over the render code, driven by
   the S2 cell classification. Hand transcription remains banned.
2. The two known transformer lies checked on every arm: multi-line accesses
   (joined-text pass) and compiles-but-wrong output (the null decides).
3. The null gate: port vs oracle **EXACTLY 0**, every factory patch, every
   configured rate, multiple block sizes. Not small — zero.

**Exit gate:** null EXACTLY 0 across the full matrix. Any nonzero patch stops
the session until attributed; "close" is a defect, not progress.

## S4 — RECALL IN C, AND `make verify` FOR THE JX-3P

1. Bank decode + derived bindings become the C recall layer; the recall-time
   stash pattern (the JUNO's cell-592 lesson) checked for equivalents.
2. Gates cloned through the config: recall parity, recall-then-render A/B,
   approx audit (ZERO approximations), provenance scan — one `make verify`
   target per synth, both green side by side.
3. Every new detector SEEN TO FAIL before it is believed. No exceptions for
   gates "just like the JUNO's".

**Exit gate:** `make verify SYNTH=jx3p` green: zero non-PROVEN rows, null
EXACTLY 0, recall parity total. **This is the deliverable you asked for.**

## S5 — CLOSURE (the slack absorber)

Edge cases the JUNO paid for, re-checked here: rate-dependent recall, latch
cells that settle, order-independence of parameter application, the delay/
chorus arms' double-precision hoists. Playbook entries for anything new the
JX-3P taught. PIPELINE.md amended with every E5 finding. Final audit run.

---

## THE RISK REGISTER — every known hiccup, pre-empted

| risk | pre-emption |
|---|---|
| different vendor / different idioms | S1 checkpoint with written criteria; stop-and-resize, never silent re-scope |
| a constant that was never executed | PROVENANCE discipline from S1; INFERRED rows block the exit gates |
| parameters live at few values | exhaustive sweeps are mandatory, sampling is banned (probe defect 3) |
| transformer output that compiles and lies | the null decides; joined-text pass for multi-line accesses |
| captures contaminating the port | covenant restated at intake; such files are deleted unread |
| instruments that don't reach their subject | playbooks 67/69/70/72/73/75 as checklist: verify the artifact, never the report; every tooth seen to fail |
| gate-planted edits swept into commits | playbook 74: no `git add -A` ever; stage by path; verify tooth targets against a known-good commit |
| JUNO constants leaking via shared tools | S0 closes this class before S1 opens |
| FMA/precision drift | `-ffp-contract=off` load-bearing everywhere; confirmed against the binary's own instruction set in S1 |
| scope creep toward fork/boards | out of scope by this document; a separate plan with its own budget when you ask |

## DECISION RULES, WRITTEN BEFORE THE WORK

1. The binary outranks `script.xml`, the manual, and memory of the hardware.
2. Zero is the only passing null. A patch that nulls to 1 ulp is a stop.
3. Any S1 criterion failing = pause + re-estimate + your sign-off.
4. A session ends with its exit gate green or with a written stop-reason —
   never with "mostly done".
