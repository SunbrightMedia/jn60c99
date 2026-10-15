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
| `test/browser_check.js` | drives the built page in headless Chromium: drag, rotate, all three exports |

## Rebuild and prove
```
python3 tools/hardware/plate_maker/build.py
N=<dir with node_modules: earcut@2.2.4 three@0.128.0 playwright-core@1.56.0>
cd tools/hardware/plate_maker/test
NODE_PATH=$N node make_cases.js /tmp/c && python3 check_cases.py /tmp/c                 # PASS
NODE_PATH=$N node make_cases.js /tmp/t --tooth && python3 check_cases.py /tmp/t         # must FAIL
NODE_PATH=$N node browser_check.js /tmp/w && python3 check_cases.py /tmp/w/app_plate.zip # PASS
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
