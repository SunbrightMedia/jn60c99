# LAST MILE — the plan that ends this (2026-08-10)
STANDARD: AUDIBLY IDENTICAL (user-ordered, AUDIBLE_STANDARD.md).
GOAL: two chips, 6 voices + FX, 44.1 kHz. MEASURED GAP: 0xd0 = 6,723 vs
5,442 -> 640 cycles/voice.

## THE IRON RULE THAT GOVERNS EVERYTHING BELOW
No cycle number is ever stated before the board prints it, and no sonic
claim before the gate prints it. Five projection failures are named in this
repo; a sixth disqualifies the session that makes it.

## PHASE A — three UNTESTED levers, sized at the gap, gated in HOURS on host
Each is small to build, quick to gate, independent, and NONE has ever been
tested under the AUDIBLE standard -- their old rejections were NULL-gate
rejections at the -100 dB standard that no longer governs the fork:
  A1  CONTROL-RATE CV WIRING, N=2 (glide/modcv/vcf_cv/dcoprep held every
      other sample). Old evidence: -39 dB NULL fail = a BEAT-CLASS number,
      never a band-energy number. Size if it passes: ~320/voice.
  A2  CONTROL-RATE ENVELOPES, N=2 (e1/e2 held every other sample; gate
      edges still sampled every sample so attacks cannot be missed).
      Never tested at any standard. Size: ~145/voice.
  A3  DROP THE 2x DECIMATOR to a 2-tap average (the 16-tap FIR replaced by
      (h0+h1)/2 with the fitted gain folded in). Never tested. Size:
      ~180/voice.
  Pool if all three pass: ~645 = THE GAP. Procedure per lever: flag ->
  sonic gate (all 36, both rates) -> if worst band is within ~2x of the
  AUDIBLE build's own 3.17 dB, KEEP; render worst-case A/B WAVs for the
  user's ears alongside. Whatever passes goes into ONE firmware; 0xd0 is
  the only verdict sentence allowed.

## PHASE B — if Phase A lands short, the kernel closes the rest
ASM_KERNEL_WORKORDER.md, unchanged. The remaining span after ANY Phase-A
success is smaller than the measured 735/voice stall pool.

## WHAT IS ALREADY BANKED AND MUST NOT BE RE-LITIGATED
floor 1,020 (O1 delivered) · head 675 · voice 3,068 · 6v one-chip 10,004 ·
sound gated 3.17 dB worst band with user-held worst-case WAVs · every dead
lever documented in docs/engineb/data/.

## THE PROMISE DISCIPLINE FOR WHOEVER EXECUTES THIS
Say "the gate reads X" and "the board reads Y". Never "this will land at Z".
The user has been burned by Z five times. The evidence says the gap is
smaller than the untested pool for the first time in the project; that
sentence, and no stronger one, is the honest statement of hope.
