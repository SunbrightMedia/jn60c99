# CLASSIC panel derivation — VCA TONE and ENV2 (2026-09-02)

Question: can the plugin-added controls be pinned to a neutral value so the
engine behaves as if they never existed (a 1982 JUNO-60)?

## VCA TONE — a true neutral EXISTS

- Binding: panel 49 (record roff 114), curve 24 (bipolar), cell 9584
  (src/juno_apply.c:214). Host default 128 (src/juno_hostparams.c:46).
- EXECUTED (scratchpad tone_neutral.c over the port's proven juno_curve —
  recall_exhaustive gates that curve bit-exact against the plugin's setter):
  curve24 is exactly 0.0 at bytes **127 and 128**, nonzero everywhere else.
- Voice law (engine_b/eb_vca_hpf.c:112-126, gated bit-exact vs the plugin):
  with tone == 0.0 both tone-filter mixes multiply by zero and the output is
  the unfiltered path EXACTLY. Byte 128 = bit-exact passthrough. PROVEN.
- **BUT the factory bank USES the knob**: decoded from the bank
  (eb_patch_param law, control: patch5 VCF CUTOFF == 153), VCA TONE is 128 in
  only 40 of 64 patches; 24 patches carry 85..213. Pinning 128 would CHANGE
  24 factory patches.

## ENV2 — NO neutral exists, and none must be used

- Mapping (plugin's own name table): ENV1 -> filter envelope (cells 2784..),
  ENV2 -> amp envelope (cells 3264..). Panels 40-43 and 45-48.
- MEASURED over the factory bank: **ENV2 != ENV1 in 64 of 64 patches.**
  Roland authored every factory patch with two distinct envelopes.
- Therefore ENV2 := ENV1 (the naive "one ADSR" coupling) would change the
  amp shape of EVERY factory patch. Not classic — wrong.
- There is no single fan-out host param; the plugin stores the two
  envelopes independently (src/juno_hostparams.c).

## The classic rules — USER OVERRIDE 2026-09-02 (supersedes the first draft)

The user's binding decision: every parameter without a 1982 knob is pinned to
its neutral value FOREVER, recall included, no matter what the patch stores.
The classic port is allowed to sound different from the full VST; correctness
is judged against the VST LIMITED THE SAME WAY.

Implemented as `eb_patch_classicize()` (engine_b/eb_patch.c), a byte-level
law applied inside eb_patch_install under EB_CLASSIC — the one site the
firmware and the devcrc answer-key oracle share, so the CRC tooth holds.
The full pin table is in that function's header comment. Highlights:
ENV2 := ENV1 (curves pairwise identical 35/38/50/38, so a byte copy is the
one-ADSR panel), VCA TONE := 128 (proven passthrough), EFFECT TYPE clamped
to {2,3,4} else 0, delay/reverb/glide/legato/assign/velocity/mod-wheel all
:= 0, BEND RANGE := 11 (bank-constant), chorus fine-FX := 20/2/13
(bank-constant). VCA MODE stays (the 1982 ENV/GATE switch — with ENV2==ENV1
its ENV1-vs-ENV2 split collapses to plain ENV). CONDITION stays a knob
(user decision).

Verified: classicized all 64 factory patches, every pin conforms
(scratchpad classic_check.c, 2026-09-02).

Known sound changes vs the full VST, accepted by design: 8 type-5-effect
patches lose that effect; 1 type-1 patch loses it; delay/reverb tails gone;
14 MONO + 2 UNISON patches play POLY; glide patches lose glide; 24 patches
lose their VCA TONE tilt; every patch's amp envelope becomes the panel
envelope; 10 patches lose HPF TYPE 1; velocity shaping off.

## Provenance labels

- curve24 zeros at 127/128: PROVEN (executed; the curve itself is gated
  bit-exact against the plugin over all bytes x 3 rates).
- tone==0 -> exact passthrough: READ from the gated engine-B law.
- bank statistics (ENV pairs, TONE histogram): MEASURED on the parsed bank
  (parse law control-checked against the documented patch-5 cutoff byte).
- "1982 had one ADSR feeding both": INFERRED from hardware documentation,
  NOT from the binary. The binary cannot testify about 1982.
