# MASTER BOM (LCSC) -- all 14 boards, v2 (2026-09-23; README refreshed 2026-09-28)

Version v2 (2026-09-23): board counts per board_counts.csv, +15% on small passives (R, C, FB designators, rounded up), user_added.csv rows.

Inputs: `inputs/` = each board's JLC export (bom.csv, designators.csv, netlist.ipc) from the user's EVERY_PCB_FILES.zip.
Three boards have no bom.csv (KeyswitchKeybed, PotentiometerBoard, Potentiometer_3-Pack): every part on them is user-supplied
or a connector with no LCSC field. `board_counts.csv` = how many of each board to build (v2: ESP32-S3_Motherboard 3, FaderBoard 10, Headphone_Dac 2,
Multiplex16 10, every other board 5).

Run `python3 build_master_bom.py` after any change. Outputs:
- `MASTER_BOM_LCSC.csv` -- upload to lcsc.com -> BOM Tool. v2 = 905 pieces, 30 lines (board counts x per-board BOM, +15 % on
  R/C/FB designators, `user_added.csv` = 5 x C41409498 PJ-603 jack; the backordered NCD0805O1 orange LED C84262 is replaced by
  NCD0805R1 red C84256, same series). At 1 of each board the BOM was 149 pieces (checked against every board BOM). The 2 axial 4.7k (motherboard R1/R2) had no LCSC # and
  go by MPN `MFR0W4F4701A50` (INFERRED name; the BOM tool shows if it does not match).
- `MASTER_BOM_LCSC_WITH_MISSING_JST.csv` -- 1,039 pieces: the same plus the JST-XH connectors that are placed on the boards but carry no LCSC
  field (`missing_jst_proposed.csv`, per ONE of each board: 15 x 4-pin C157925, 15 x 3-pin C157928, 1 x 2-pin C157931; scaled by board_counts in the CSV). PROPOSED: assumes they use the
  same side-entry S#B-XH-A footprint as the connectors the other boards list. Check before ordering.
- `BOM_BY_BOARD.csv` -- parts x boards matrix, for changing board counts.
- `NOT_IN_ANY_BOM.csv` -- every placed part in no BOM, with pins + nets from the netlist (buttons, pots, fader, DIN jacks,
  headphone jack, solder jumpers, test points, mounting holes).
Open item: FB1 on Headphone_Dac lists `C46550600` (600R ferrite bead). The number could not be verified from here.

Ordering (boards at JLCPCB + these parts at LCSC in one shipment): `../ORDERING.md`.
