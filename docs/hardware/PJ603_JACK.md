# J8 headphone jack (Legion/HAOYU PJ-603, LCSC C41409498) — pin map and the v1.0 fault

Source: the maker's drawing, https://datasheet.lcsc.com/datasheet/pdf/419fcba410f3701f7ab3fcab4bb673fc.pdf?productCode=C41409498
(SCHEMATIC box "PJ-603"; READ 2026-10-16). 6.35 mm stereo jack, 4 pins, no pin 1.

| pin | contact | proof |
|---|---|---|
| 2 | **sleeve** (spring 2#, at the jack mouth) | drawing; PJ-603-2/-3 boxes agree |
| 3 | switch, closed to the tip with NO plug, opens when a plug is in | drawing |
| 4 | **tip** = LEFT | drawing |
| 5 | **ring** = RIGHT | drawing |
Pad geometry in the Headphone_Dac v1.0 netlist (2→3 7.5 mm, 2→4/5 14.9 mm, 4↔5 5.0 mm) matches the
drawing's PCB layout (7.6 / 22.5−7.6 / 5): the FOOTPRINT is right; the NET-to-pin choice is wrong.

## Headphone_Dac v1.0 as fabbed (fab netlist)
| pin | net on board | contact | effect |
|---|---|---|---|
| 2 | HP_TIP (left amp, via R8) | sleeve | left amp drives the headphone common |
| 3 | GND | tip switch | open with a plug in: GND reaches nothing |
| 4 | NC | tip | left driver has no return: silent |
| 5 | HP_RING | ring | right driver hears RIGHT − LEFT |
Symptom (user, 2026-10-16, boardtest image): every sound, LEFT beep included, in the right ear only.
It matches this map exactly (INFERRED from the drawing + the circuit; boardtest writes 0 to R in its LEFT stage).

## Rework (v1.0 board)
1. Cut the HP_TIP trace at J8 pad 2 (R8 side).
2. Wire R8's jack-side pad (HP_TIP) to J8 pad 4 (tip).
3. Cut the jack's pin 3 leg between body and board (the pad stays GND copper), then wire J8 pad 2 to pad 3 (GND).
   Without the cut, a jack with no plug ties the tip — now the left amp — to GND through R8 (10 Ω).
## Next revision
J8 pin 2 = GND, pin 4 = HP_TIP (R8), pin 5 = HP_RING, pin 3 = NC (or a headphone-detect input).
