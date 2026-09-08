# SCHEMATIC AUDIT LAW (user-binding, 2026-09-08)

Paid for twice on one day (a counts-only audit added redundant caps; a
label-blind tracer reported wired pins as bare):

1. **Net level, always.** No claim about the schematic from part counts,
   from documentation, or from memory. Only from a traced net list.
2. **The ONE tool**: `tools/hardware/net_audit.py <file>`. It models the
   real KiCad rules: pin-to-pin contact, pin/label/wire-end on a wire
   segment, rotation and mirror (transform CALIBRATED against the sheet,
   never assumed). An unlabeled stub through a resistor or jumper is a
   CONNECTION, not a float.
3. **Teeth before trust**: `net_audit.py <file> --tooth` mutates the real
   file (checked label deleted, part rotated, contact broken) and every
   mutation MUST change the reading. Run it before quoting any audit.
4. **A FAIL is reported only after a raw-geometry dump of that location
   confirms it** (the wires within 10 mm, printed, no interpretation).
5. The requirement sweep inside the tool is the CURRENT list (hop audio +
   control, resistors at TX, pullup, jumpers, BOOT, EN_ALL, strapping
   rows). New requirements go INTO the tool, not into prose.

6. **A hand probe never overrides the tool.** (Paid 2026-09-08, R58: a
   probe printed "net: None" for a correct unlabeled TX stub and prose
   turned it into "dangles" while the tool's own check for that exact
   line was GREEN.) "No label" is NOT "no connection". Only the tool's
   sweep, whose teeth have bitten, may declare a FAIL — and only with
   its raw-geometry dump attached.

7. **Status lists come from the LATEST run only.** (Paid 2026-09-08: an
   "open items" list repeated a fixed defect one turn after the tool's
   output had already registered the fix.) Never carry a checklist item
   forward from memory; re-derive it from the current output or drop it.

8. **Connector rule (2026-09-08): pin 1 = GND on every JST that carries
   GND.** Enforced by the sweep; DIN-5 and TRS jacks exempt (their pins
   are fixed by their standards). Current J12: GND/3V3_ESP1/SDA1/SCL1;
   J13: GND/SEND1/SEND2/SEND3 — any doc quoting the old order is stale.
