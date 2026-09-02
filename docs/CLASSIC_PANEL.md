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

## The classic rules that follow (binding for any CLASSIC interface)

1. RECALL IS SACRED. Stored ENV2 / VCA TONE / CONDITION values are part of
   the patch's sound. The classic build recalls them untouched (it already
   does — recall is not modified by EB_CLASSIC).
2. The classic PANEL simply does not show them. Removing the knob, not the
   value.
3. LIVE EDITS in classic mode: the one ENV section writes THE SAME byte to
   ENV1 and ENV2 (one knob set feeding both circuits, as the 1982 signal
   path did). Label: INFERRED from the 1982 architecture, not provable from
   the plugin binary. A NEW patch initialises VCA TONE = 128 (the proven
   passthrough) and ENV2 = ENV1.
4. CONDITION stays a knob (user decision 2026-09-02).

## Provenance labels

- curve24 zeros at 127/128: PROVEN (executed; the curve itself is gated
  bit-exact against the plugin over all bytes x 3 rates).
- tone==0 -> exact passthrough: READ from the gated engine-B law.
- bank statistics (ENV pairs, TONE histogram): MEASURED on the parsed bank
  (parse law control-checked against the documented patch-5 cutoff byte).
- "1982 had one ADSR feeding both": INFERRED from hardware documentation,
  NOT from the binary. The binary cannot testify about 1982.
