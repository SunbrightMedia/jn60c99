# Switch footprints (2026-09-22)
- `SW_Slide_Daier_TS-22E01_TS-23E01_Universal_v3.kicad_mod` — the universal slot: the EasyEDA user footprint
  "TS-23E01AT15 - DP3T TOGGLE" (uuid 049d1afee5f74202a17ce9fccec31389, contributor Nick Graham; `truth_TS-23E01AT15.json`
  is the user's export = GROUND TRUTH) converted 1:1 by `ee2kicad.py` (12 pads checked, worst deviation 0.00005 mm, three
  teeth bite) plus pads 4A/4B at y = -2.5 mm for the Daier TS-22E01 (2-pos, pins -2.5/0/+2.5). Preview: `fp_v3_preview.png`.
- Import: copy the .kicad_mod into a `*.pretty` folder, add it in Preferences -> Manage Footprint Libraries.
- Legs are numbered MP (unnumbered in the source). Signal pad annular ring is 0.25 mm (source's choice).
- `SW_Slide_Daier_TS-22E01_TS-23E01_Universal_v4.kicad_mod` (2026-09-22, CURRENT) — v3 with ONLY the four leg pads changed: centre
  ±5.31 across (compromise of the user's caliper measurement 5.12 / datasheet ~5.25 / EasyEDA 5.50; leg 0.6 x 1.06 measured),
  slot 1.2 x 1.7, pad 2 x 3. Every candidate leg position fits with >= 0.11 mm. Pictures: `fp_v3_vs_v4.png`, `fp_v4_leg_zoom.png`.
  Caliper data (official switches): across, outer 10.8 / inner 9.68; along, outer 21.1 / inner 18.96 -> centres 10.24 x 20.03.
