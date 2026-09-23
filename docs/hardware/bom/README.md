# MASTER BOM (LCSC) -- all 14 boards, v1.0 (2026-09-23)

Version v2 (2026-09-23): board counts per board_counts.csv, +15% on small passives (R, C, FB designators, rounded up), user_added.csv rows.

Inputs: `inputs/` = each board's JLC export (bom.csv, designators.csv, netlist.ipc) from the user's EVERY_PCB_FILES.zip.
Three boards have no bom.csv (KeyswitchKeybed, PotentiometerBoard, Potentiometer_3-Pack): every part on them is user-supplied
or a connector with no LCSC field. `board_counts.csv` = how many of each board to build (all 1 today).

Run `python3 build_master_bom.py` after any change. Outputs:
- `MASTER_BOM_LCSC.csv` -- upload to lcsc.com -> BOM Tool. Exactly the parts in the board BOMs (149 pieces at 1 of each board;
  checked: equals the sum of every board BOM's orderable quantities). The 2 axial 4.7k (motherboard R1/R2) had no LCSC # and
  go by MPN `MFR0W4F4701A50` (INFERRED name; the BOM tool shows if it does not match).
- `MASTER_BOM_LCSC_WITH_MISSING_JST.csv` -- the same plus 31 JST-XH connectors that are placed on the boards but carry no LCSC
  field (`missing_jst_proposed.csv`: 15 x 4-pin C157925, 15 x 3-pin C157928, 1 x 2-pin C157931). PROPOSED: assumes they use the
  same side-entry S#B-XH-A footprint as the connectors the other boards list. Check before ordering.
- `BOM_BY_BOARD.csv` -- parts x boards matrix, for changing board counts.
- `NOT_IN_ANY_BOM.csv` -- every placed part in no BOM, with pins + nets from the netlist (buttons, pots, fader, DIN jacks,
  headphone jack, solder jumpers, test points, mounting holes).
Open item: FB1 on Headphone_Dac lists `C46550600` (600R ferrite bead). The number could not be verified from here.
