# Module Plate Maker (LIVING, 2026-10-15)

A one-page web app: place the fabbed boards on a 19 in rack panel (21 mm grid, the boards' own
hole grid), then download the base plate as STL pieces that fit the Bambu Lab A1 mini (180 mm
bed), joined by dovetails. Spec and board data: `docs/hardware/outlines/README.md`.

| file | role |
|---|---|
| `plate_geom.js` | ALL geometry (placement, cut plan, joints, meshes, STL, ZIP). No DOM. |
| `app.html` | the page (UI only; calls plate_geom.js) |
| `build.py` | inlines plate_geom.js + the board outlines/silk into `plate_maker.html` |
| `plate_maker.html` | the built page (open it in any browser; needs network for earcut + three.js + fonts) |
| `test/make_cases.js` | builds plates for 1U / 3U / 7U (rotated boards) / MAX with plate_geom.js |
| `test/check_cases.py` | the INDEPENDENT checker (trimesh + shapely + hole positions recomputed from the KiCad JSON) |
| `test/browser_check.js` | drives the built page in headless Chromium: drag, rotate, all three exports, cutouts as drawn |
| `test/check_cutouts.py` | the cutout ORACLE: pcbnew finds each panel part in the KiCad files, own placement code, 0.01 mm |

## Rebuild and prove
```
python3 tools/hardware/plate_maker/build.py
N=<dir with node_modules: earcut@2.2.4 three@0.128.0 playwright-core@1.56.0>
cd tools/hardware/plate_maker/test
NODE_PATH=$N node make_cases.js /tmp/c && python3 check_cases.py /tmp/c                 # PASS
NODE_PATH=$N node make_cases.js /tmp/t --tooth && python3 check_cases.py /tmp/t         # must FAIL
NODE_PATH=$N node browser_check.js /tmp/w && python3 check_cases.py /tmp/w/app_plate.zip # PASS
python3 check_cutouts.py /tmp/w/cutouts_drawn.json                                     # PASS (separate process: pcbnew)
```
Python needs trimesh, shapely, scipy, networkx. The checker grades: every piece watertight,
one body, outward winding, within the bed limit; every board hole has exactly one pillar at the
right place (0.01 mm); every pillar foot clear of the piece edge; no two pieces overlap; every
joint gap = the clearance; the pieces cover the whole plate. Teeth seen to fail 2026-10-15: a
piece with zero clearance (gap 0.075 != 0.15) and a board turned 90 degrees (pillars missing).

## Geometry decisions (change them here, not in the page)
- Grid: 21 cells x 21 mm centred between the rack ears (15.875 mm each); rows centred in the depth.
- Boards are placed by their holes (hole 4.25 mm from its cell corner), so KeyswitchKeybed's
  overhanging edge is handled.
- Pillar = one surface of revolution joined to the plate (one watertight body per piece):
  foot flare -> shoulder (board rests on it, `shoulderH` above the plate TOP) -> pin with a
  0.5 mm tip chamfer.
- Cuts: rows first (straight across, never within `shoulderD/2 + footFlare + 1 + clearance` of a
  pillar), then columns per row; tabs point down / right; each piece + its tabs <= `maxPiece`.
- Joint clearance = total gap; each mating edge moves clearance/2 into its own piece.
- Downloads: through the artifact `downloads` capability (zip / svg / json only), or a plain
  browser download when the file is opened directly.

## Panel cutouts (2026-10-15)
The "Panel cutouts" layer shows only what is cut in the metal front panel. Part centres and angles
come from the board files (`pcb_outline.py` -> `panel_parts` in each outline JSON); sizes and their
sources live in `plate_geom.js` `CUTOUTS` and are editable in the page.

| kind | cutout | status | source |
|---|---|---|---|
| keyswitch (Kailh CPG1511F01S04) | 14.0 x 14.0 on the centre post | READ | Kailh drawing RHA-PG1511F-004EN (LCSC C400226): housing 13.95 below the panel |
| pot (Alps RK09K1130A70) | dia 7.0 on the legs' line | READ | Alps RK09K catalogue, drawing 7 (LCSC C351173): knurled shaft dia 6 |
| slide switch (Daier TS-22E01 / TS-23E01) | 5 x 15 stadium | READ | footprint F.Fab lever slot (EasyEDA ground truth) |
| PB86-A1 | 13.0 x 17.6 | READ | FVWIN: cap 12.4 x 17.0 (= footprint silk 12.35 x 17.0) + 0.3 per side |
| fader 75 mm B103 dual (Taiss and others) | (60 + 4.0 + 2 x 0.4) x (1.2 + 2 x 0.4) = 64.8 x 2.0 stadium | INFERRED | sellers of this exact part: stroke 60, "4x15 mm shaft"; lever 4.0 x 1.2 as on the Bourns PTA drawing (the PTA pinout does NOT match this footprint, so it is not a PTA clone); centred on the body -- check the lever stops 30 mm each side of the body centre |

Found on the way: the PB86-A1 packs put caps 12.4 wide at a 12.5 mm pitch, so separate holes leave
no metal; the page warns below `minWeb` (1.0 mm). The user's call (2026-10-15): one long slot there --
`mergeSlots` (default on) joins same-kind cutouts on one board closer than `minWeb` into their bounding box.
Oracle teeth for this step, seen to fail: merge off on a merged drawing; fader travel 58 instead of 60. Seen to fail: 13.0 -> 0.00, 12.0 -> 0.50, 11.0 -> clean.
The cutout oracle was seen to fail on a stale drawing (boards turned without a recompute).

## Panel view and caps (2026-10-15)
"Panel" (view switch above the drawing) shows only the front panel: grey plate, black cutouts, the
boards' edges as faint thin white lines, and the caps. Caps are PLACEHOLDERS (sizes in the page,
`plate_geom.js` `CAPS` / `capShapes`), translucent, and move with the mouse per placed board:
fader caps slide over the travel, knobs turn over 280 degrees (Alps RK09K) and stop at their ends,
keycaps and PB86-A1 caps press (the PB86-A1 cap is drawn from the Adafruit / Hongju PB-86 photos:
LED shelf with the 3 mm LED at the footprint's -y end, step, flat face, side bevels, front chamfer; its LED
lights while pressed), switch levers click through 3 positions. Positions are saved in the
layout (`boards[].caps`). Browser checks: caps at rest sit on their (oracle-checked) cutouts to
0.01 mm, a fader cap's two ends are exactly the travel apart, a knob turned past its stop stays at
it, press / release, switch cycle, caps saved. The page warns when caps overlap over their whole
movement: with 18 mm MX keycaps the KeyswitchBoard / KeyswitchKeybed keys (~16 mm pitch) overlap.

## Selection, rotation, labels (2026-10-15)
- Box select: drag on an empty part of the panel (Shift adds); Shift-click toggles one board. A drag,
  the arrow keys, R, Delete and Duplicate act on the whole selection; a group turns about its centre.
- Rotation no longer drifts: the exact centre is kept between turns, so 4 turns return every board to
  its start cell. Moves are clamped so every hole stays on the grid (a board can never be lost).
  Seen to fail on the old build: buttonpack3 (5 x 2 cells, an odd difference) moved
  (0,4) -> (2,6) -> (4,7) -> (6,7) over 12 turns; the new build: 40 turns, back every 4.
- Panel view checkboxes: Board edges, Labels. Labels: "CNTRL" in Helvetica (Arial where the system
  has no Helvetica), `labelSize` 5 mm; the letters are centred halfway between the top edge of the
  part's board and the top of the fader's slot / the knob / the switch slot / a button pack's row of
  caps (one per pack); under each PB86-A1 cap its number 1..n (left to right), centred between the
  cap's bottom and the board's bottom edge (the user, 2026-10-15); also a "Labels"
  layer in the Layout SVG export. The browser check recomputes each spot from the cutouts and the
  knob caps (seen to fail with a wrong cap-height constant, and with the numbers measured from the
  wrong board edge: 12 of 12 wrong).
- Fader caps 6 x 10 (half the first placeholder); saved layouts that still hold the old default follow
  the new one (`OLD_DEFAULTS` in app.html).
