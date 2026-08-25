# NaN semantics: what is a defect, and what is only an inaccuracy

Both ports transcribe x86 float comparisons, and x86 disagrees with C on NaN
(playbook 81). This note records WHERE that matters, measured, so the effort
goes to the reachable case and not to a theoretical one.

## The rule
`comiss`/`ucomiss` set CF=ZF=PF=1 on unordered, so `ja`/`jae` are NOT taken on
NaN while C's `<=`/`>=` are false. Hex-Rays writes `x <= y`; the asm falls
through into the clamp. The two forms agree on EVERY ordered input, so no gate
built from ordinary states can tell them apart.

## JX-3P: NaN IS reachable -> this was a REAL defect, and it is FIXED
The plugin's own chorus delay line carries NaN words as ordinary ring data
(measured: 3497 of 65536 entries in a normally recalled, warmed state; the
plugin shuffles them with integer `mov` and clamps them at the output). Two of
the four chorus taps read NaN on a real factory patch. The port skipped the
clamp and emitted NaN where the plugin emitted 0.9902894.

FIXED in `jx_master_render.c` (rva 0x39E341/0x39E35C, written `!(x > 0.0f)`).
Integration A/B, all 57 recall pools, N=64: 5/5 patches EXACTLY 0, was 0/5.

## JUNO-60: NaN is NOT reachable in normal operation -> latent, not a defect
Measured over patches 0, 5, 20, 50 and 63, 4000 frames each, full 11 MB state:
**zero NaN cells**. `nan_ab.py` finds divergence only when a NaN is INJECTED
artificially (2 of 8 injected cells diverge).

So the JUNO carries the same inaccuracy at some of its 57 at-risk sites, but no
measured state reaches it. The decision, recorded rather than taken silently:

* **DO NOT mass-rewrite the sites.** `nan_ab.py` cannot say WHICH site is wrong
  — a NaN travels through integer ring copies before reaching a compare — and
  flipping sites by guesswork would trade an unreachable inaccuracy for
  reachable new bugs. A one-at-a-time flip search was run and changed nothing.
* **DO keep `nan_ab.py` and `unordered_audit.py`.** If a future change, a user
  bank, or a denormal path ever makes NaN reachable, the gate turns red and the
  audit says where to look.
* **DO fix a site the moment a NaN becomes reachable at it** — that is exactly
  how the JX defect was found and fixed.

## The honest bound
"Not reachable" here means: not in 5 factory patches x 4000 frames at 44100 Hz.
It is NOT a proof that no input can produce a NaN. It is the measured basis for
prioritising, and nothing more.
