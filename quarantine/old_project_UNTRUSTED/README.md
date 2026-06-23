# ⚠️ UNTRUSTED — old-project files, quarantined as evidence only

**Do not use any value in this folder as a coefficient source.** These come from
the previous, failed effort and are kept solely to document provenance. See
`docs/DATA_PROVENANCE.md` for the full analysis.

- `golden_dump_20260621.txt` — **contaminated with fitted/calibrated values.**
  Its filter/LFO/master coefficients do **not** exist in the binary's static
  `.rdata` (verified), and its own annotations admit fitting ("fitted filter",
  "calibrated to 0.539x from P6 audio", "fixed 4x level deficit"). This is the
  "poison" the handoff warns against.
- `frida_chorus_coeffs.js` — a capture *script*. The golden dump notes the chorus
  was inactive during capture and the offsets may be wrong. Superseded; if a
  chorus recapture is ever needed it will use a corrected script.

The trusted sources are `dsp_dump/` (algorithm) and `init_dump/` (real values).
