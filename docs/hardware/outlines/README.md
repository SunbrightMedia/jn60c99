# outlines — board edge, screw holes, silkscreen per fabbed board (LIVING, 2026-10-15)

Input of the case / plate maker (the web app that places boards on a grid and exports STL).
Made by `tools/hardware/pcb_outline.py` from the user's own `.kicad_pcb` files. KiCad does
all the geometry: pcbnew's API (outline, holes), kicad-cli's SVG plot (silkscreen).

Source: the 15 boards the user had fabbed, uploaded 2026-10-15 as three zips (files dated 2026-09-22/24),
kept as `docs/hardware/user_boards/pcb_2026-09-22/` (.kicad_pcb + .kicad_pro only; `.history/` skipped).

## Run it
```
python3 tools/hardware/pcb_outline.py docs/hardware/user_boards/pcb_2026-09-22 -o docs/hardware/outlines
python3 tools/hardware/pcb_outline.py <same input> -o /tmp/x --tooth   # must FAIL (self-check seen to fail)
```
Needs KiCad 10 (the user's files are version 20260206 / KiCad 10; KiCad 9 cannot load them).
Container install (Ubuntu 24.04, ~2 min; add-apt-repository is broken here, so by hand):
```
mkdir -p /etc/apt/keyrings
curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x245D5502FAD7A805" | gpg --dearmor > /etc/apt/keyrings/kicad.gpg
echo "deb [signed-by=/etc/apt/keyrings/kicad.gpg] https://ppa.launchpadcontent.net/kicad/kicad-10.0-releases/ubuntu noble main" > /etc/apt/sources.list.d/kicad10.list
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends kicad
```
The `assert "m_choices.GetCount() > 0"` lines on stderr are KiCad noise.

## Outputs (per board NAME)
- `NAME.svg` — 1:1 in mm (`width="..mm"`), four Inkscape layers: `silk_back` (50 % opacity,
  NOT mirrored = where it sits under the board), `silk_front`, `edge`, `holes`.
- `NAME.json` — the exact numbers: `width`, `height`, `holes[]` (x, y, diameter, plated),
  `edge_primitives[]` (lines / arcs with centre + radius, exact), `outline_polygon` (arcs
  flattened by KiCad), `grid` fit, `thickness`, `notes` (anything odd, e.g. not 4 holes).
- `index.json` — all boards, short form.

Frame everywhere: mm, origin = board bounding-box top-left, +x right, +y DOWN, seen from the front.

## Self-check
The kicad-cli Edge.Cuts plot and pcbnew's outline must give the same box to 0.002 mm (two
independent paths). `--tooth` shifts one by 0.01 mm: the run must then stop with SELF-CHECK FAILED
(seen to fail 2026-10-15 on AudioBreakout).

## The plate spec (the user's words, 2026-10-15) — for the next step
- Each board sits on 4 pillars that go THROUGH its 4 screw holes, fairly snug (sizes tuned later).
- Below the board each pillar is wider; the board rests on that shoulder **6.5 mm above the plate
  base** (JST-XH headers are soldered on the back side).
- Boards are designed to fit a **21 mm grid** (42 = 2 cells). MEASURED on all 15 fabbed boards:
  edge margin 0.25 mm per side (board = cells*21 - 0.5), every hole 3.2 mm (M3), every hole
  centre **4.25 mm from its grid-cell corner** (hole spacing = cells*21 - 8.5).
  Exception: KeyswitchKeybed is 112.0 x 62.5 -- its EDGE is off the grid (overhangs its 5-cell
  span by 3.38 mm left, 3.62 mm right) but its HOLES are on it. So: **place every board by its
  holes** (`hole_grid.*.cells`, `hole_grid.*.board_origin_in_cell_mm`), check overlap with the
  real outline. The tool notes any board whose holes break the rule (tooth seen to fail).
  (The older AudioBreakout snapshot, 83.5 x 63.0, is not one of the fabbed boards.)
- The only holes on each board are the mounting holes.
- Printer: Bambu Lab A1 mini, bed 180 x 180 mm -> the plate is cut into pieces that fit, with
  joints that fit together exactly.
- The surface size (the user, 2026-10-15): **max 19 in wide x 13 in deep (482.6 x 330.2 mm)** --
  the user's printer, and so the screen-printing screen for the front-panel labels, is 13 x 19 in.
  The depth is selectable: rack sizes 1U .. 7U, or MAX = exactly 13 in. 1U = 1.75 in = 44.45 mm
  (7U = 311.15 mm nominal; a real EIA panel is N*44.45 - 0.79 mm). The 19 in width is the rack
  panel width incl. the ears (rail holes at 465.1 mm centres, ~450 mm clear between rails).
  Boards stay OUT of the two rack-ear zones (the user, 2026-10-15): 15.875 mm each side
  ((482.6 - 450.85) / 2; 450.85 mm = 17.75 in, the clear width between rails).
- ONE plate for the WHOLE control surface (the user, 2026-10-15). The cuts exist ONLY because the
  bed is too small. NEVER one piece per board, NEVER a piece the size of a board's footprint (that
  is flimsy). Each piece carries as many boards as fit on it; the cut lines follow the bed limit,
  not the board edges.
