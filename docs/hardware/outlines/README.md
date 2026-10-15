# outlines — board edge, screw holes, silkscreen per fabbed board (LIVING, 2026-10-15)

Input of the case / plate maker (the web app that places boards on a grid and exports STL).
Made by `tools/hardware/pcb_outline.py` from the user's own `.kicad_pcb` files. KiCad does
all the geometry: pcbnew's API (outline, holes), kicad-cli's SVG plot (silkscreen).

## Run it
```
python3 tools/hardware/pcb_outline.py <projects.zip | folder | file.kicad_pcb ...> -o docs/hardware/outlines
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
- Boards are designed to fit a **21 mm grid** (42 = 2 cells) with a small fixed margin per side
  (the user thinks 0.25 mm; MEASURE it from `grid.*.margin_per_side_mm`, do not assume).
  Measured so far: AudioBreakout 83.5 x 63.0 -> x margin 0.25, y margin 0.00 (an exception or a
  different rule; check against the other boards).
- The only holes on each board are the mounting holes.
- Printer: Bambu Lab A1 mini, bed 180 x 180 mm -> the plate is cut into pieces that fit, with
  joints that fit together exactly.
- ONE plate for the WHOLE control surface (the user, 2026-10-15). The cuts exist ONLY because the
  bed is too small. NEVER one piece per board, NEVER a piece the size of a board's footprint (that
  is flimsy). Each piece carries as many boards as fit on it; the cut lines follow the bed limit,
  not the board edges.
