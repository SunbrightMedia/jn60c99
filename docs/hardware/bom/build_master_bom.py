#!/usr/bin/env python3
"""build_master_bom.py -- the MASTER BOM for LCSC from every board's KiCad/JLC export.
Inputs (docs/hardware/bom/): inputs/<board>_bom.csv (Designator,Footprint,Quantity,Value,LCSC Part #),
inputs/<board>_designators.csv, inputs/<board>_netlist.ipc, and board_counts.csv (how many of each board to build).
Outputs:
  MASTER_BOM_LCSC.csv  -- upload to lcsc.com -> BOM Tool. One row per LCSC part (or per MPN when a part has no LCSC #),
                          Quantity = sum over boards of (qty on the board x board count).
  BOM_BY_BOARD.csv     -- the same parts x boards matrix (per-board quantity), so board counts can change later.
  MASTER_BOM_LCSC_WITH_MISSING_JST.csv -- the master plus missing_jst_proposed.csv: the JST-XH connectors that are placed
                          but carry no LCSC field (PROPOSED: the same S#B-XH-A side-entry parts the other boards use).
  NOT_IN_ANY_BOM.csv   -- every placed part that is in NO BOM (connectors without an LCSC field, user-supplied parts),
                          with pin count + nets from the netlist, so nothing is forgotten silently.
Change board_counts.csv and run it again:  python3 build_master_bom.py"""
import csv, glob, os, re, collections
HERE = os.path.dirname(os.path.abspath(__file__)); IN = os.path.join(HERE, "inputs")
# parts that have no LCSC # in the board BOM: an MPN the LCSC BOM tool can match instead (INFERRED names, see notes)
MPN_FOR = {("4.7k", "R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal"): ("MFR0W4F4701A50", "UNI-ROYAL 1/4W 1% metal film 4.7k, axial, fits DIN0207")}
USER_SUPPLIED = {"HOLE_M3", "TestPoint", "Fader_Dual_75mm", "SW_TS_Universal"}   # in a BOM but not bought from LCSC
counts = {r["board"]: int(r["count"]) for r in csv.DictReader(open(os.path.join(HERE, "board_counts.csv")))}
parts = collections.OrderedDict()   # key -> dict(lcsc, mpn, value, footprint, per_board{board: (qty, designators)})
skipped = []
for board in counts:
    f = os.path.join(IN, board + "_bom.csv")
    if not os.path.exists(f): continue
    for r in csv.DictReader(open(f, encoding="utf-8-sig")):
        lcsc = r["LCSC Part #"].strip(); val = r["Value"].strip(); fp = r["Footprint"].strip(); q = int(r["Quantity"])
        ds = [x.strip() for x in r["Designator"].split(",")]
        mpn, note = "", ""
        if not lcsc:
            if (val, fp) in MPN_FOR: mpn, note = MPN_FOR[(val, fp)]
            else: skipped.append((board, val, fp, q, ds)); continue
        key = lcsc or "MPN:" + mpn
        p = parts.setdefault(key, dict(lcsc=lcsc, mpn=mpn, values=[], footprint=fp, note=note, per_board=collections.OrderedDict()))
        if val not in p["values"]: p["values"].append(val)
        pq, pd = p["per_board"].get(board, (0, []))
        p["per_board"][board] = (pq + q, pd + ds)
with open(os.path.join(HERE, "MASTER_BOM_LCSC.csv"), "w", newline="") as o:
    w = csv.writer(o); w.writerow(["Quantity", "LCSC Part Number", "Manufacture Part Number", "Comment", "Footprint", "Boards (qty per board)"])
    for key, p in parts.items():
        tot = sum(q * counts[b] for b, (q, _) in p["per_board"].items())
        if tot: w.writerow([tot, p["lcsc"], p["mpn"], " / ".join(p["values"]) + (" -- " + p["note"] if p["note"] else ""), p["footprint"],
                            "; ".join("%s x%d" % (b.replace("_v1.0", ""), q) for b, (q, _) in p["per_board"].items())])
extra = collections.Counter()
for r in csv.DictReader(open(os.path.join(HERE, "missing_jst_proposed.csv"))):
    extra[r["lcsc"]] += counts[r["board"]]
with open(os.path.join(HERE, "MASTER_BOM_LCSC_WITH_MISSING_JST.csv"), "w", newline="") as o:
    w = csv.writer(o); w.writerow(["Quantity", "LCSC Part Number", "Manufacture Part Number", "Comment", "Footprint", "Boards (qty per board)"])
    for key, p in parts.items():
        tot = sum(q * counts[b] for b, (q, _) in p["per_board"].items()) + extra.pop(p["lcsc"], 0) if p["lcsc"] else sum(q * counts[b] for b, (q, _) in p["per_board"].items())
        if tot: w.writerow([tot, p["lcsc"], p["mpn"], " / ".join(p["values"])[:60], p["footprint"], "see BOM_BY_BOARD.csv + missing_jst_proposed.csv"])
    for lcsc, n in extra.items(): w.writerow([n, lcsc, "", "JST-XH (proposed)", "", "missing_jst_proposed.csv"])
boards = list(counts)
with open(os.path.join(HERE, "BOM_BY_BOARD.csv"), "w", newline="") as o:
    w = csv.writer(o); w.writerow(["LCSC Part Number", "Manufacture Part Number", "Comment"] + [b.replace("_v1.0", "") + " (x%d)" % counts[b] for b in boards] + ["TOTAL"])
    for key, p in parts.items():
        row = [p["per_board"].get(b, (0, []))[0] for b in boards]
        w.writerow([p["lcsc"], p["mpn"], " / ".join(p["values"])] + row + [sum(q * counts[b] for q, b in zip(row, boards))])
    w.writerow([]); w.writerow(["BOARD COUNT", "", ""] + [counts[b] for b in boards])
# placed parts that are in NO BOM, identified from the netlist (IPC-356 truncates reference designators to 6 characters)
def netpins(board):
    pins = collections.defaultdict(dict); f = os.path.join(IN, board + "_netlist.ipc")
    for l in open(f, encoding="utf-8", errors="replace"):
        if l[:3] in ("317", "327") and len(l) > 30:
            ref = l[20:26].strip(); pin = l[27:31].strip().lstrip("-")
            if ref and ref != "VIA": pins[ref][pin] = l[3:17].strip()
    return pins
with open(os.path.join(HERE, "NOT_IN_ANY_BOM.csv"), "w", newline="") as o:
    w = csv.writer(o); w.writerow(["Board", "Designator", "Pins (netlist)", "Nets", "What it probably is"])
    for board in counts:
        des = [l.strip().rsplit(":", 1)[0] for l in open(os.path.join(IN, board + "_designators.csv"), encoding="utf-8-sig") if l.strip()]
        inbom = set()
        f = os.path.join(IN, board + "_bom.csv")
        if os.path.exists(f):
            for r in csv.DictReader(open(f, encoding="utf-8-sig")): inbom |= {x.strip() for x in r["Designator"].split(",")}
        pins = netpins(board); short = collections.Counter(d.replace(" ", "")[:6] for d in des)
        for d in des:
            if d in inbom or re.fullmatch(r"H\d+", d): continue
            k = d.replace(" ", "")[:6]; p = pins.get(k, {})
            n = len(p) if short[k] == 1 else "?"   # two designators share a 6-char prefix: count unknown
            nets = " ".join(sorted(set(p.values()))) if short[k] == 1 else ""
            guess = ("keyswitch/button (user-supplied?)" if d.startswith("SW") else "potentiometer (user-supplied)" if d.startswith("RV")
                     else "solder jumper (no part)" if d.startswith("JP") else "5-pin DIN jack?" if board.startswith("MIDICON") and d.startswith("U")
                     else "headphone jack" if (board.startswith("Headphone") and d == "J8") else "JST-XH connector, %s pins" % n)
            w.writerow([board.replace("_v1.0", ""), d, n, nets, guess])
    for board, val, fp, q, ds in skipped:
        w.writerow([board.replace("_v1.0", ""), ", ".join(ds), "", "", "in the BOM without an LCSC #: %s [%s] -- not ordered" % (val, fp)])
print("parts:", len(parts), "| rows written: MASTER_BOM_LCSC.csv, BOM_BY_BOARD.csv, NOT_IN_ANY_BOM.csv")
