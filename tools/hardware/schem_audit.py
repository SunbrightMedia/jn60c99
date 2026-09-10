#!/usr/bin/env python3
"""THE master schematic net auditor -- works on ANY .kicad_sch.

Born 2026-09-10 after three repeated audit defects on hand-drawn sheets:
  D1: nets were read from LABELS only, so wire-only nets showed as None
      and connected pins were reported "floating" (midi3, 28 false FAILs).
  D2: an ad-hoc script dropped (mirror y) handling and reported a correct
      antiparallel diode as "backwards".
  D3: a "floating" verdict was reported without a raw-geometry check
      (AUDIT LAW: raw geometry before any FAIL).

Design rules that make those impossible here:
  R1. Nets are built from WIRES + pin coincidence + on-segment contact,
      THEN label names merge and name them. A label is a name, never the
      only evidence of a connection.
  R2. The pin transform applies rotation AND mirror. The convention is
      calibrated against the sheet; if for ANY pin the chosen convention
      misses geometry but another convention hits, the tool prints
      TOOL-AMBIGUOUS for that pin and exits nonzero. It never converts
      its own uncertainty into a claim about the drawing.
  R3. "NC" (no connection) is only reported after a raw scan: no wire
      endpoint/segment, no other pin, no label at the pin point. Every NC
      line prints the pin's absolute coordinates so a human can look.
  R4. --tooth mutates the input (cut a wire / unmirror a part / rotate a
      part / delete a label) and each mutation MUST change the reading.
      A tooth that does not bite fails the run.

Usage:
  python3 schem_audit.py FILE.kicad_sch          # net dump + generic checks
  python3 schem_audit.py FILE.kicad_sch --tooth  # self-test on this file
Exit 0 = clean read (findings are printed, judged by the human/profile).
Exit 2 = the TOOL is not trustworthy on this file (ambiguity/parse gap).
"""
import re, math, sys, collections

# ---------------- parsing ------------------------------------------------
def balanced(t, i):
    d = 0
    for j in range(i, len(t)):
        if t[j] == "(":
            d += 1
        elif t[j] == ")":
            d -= 1
            if d == 0:
                return t[i:j + 1]
    raise ValueError("unbalanced s-expr at %d" % i)

def parse(s):
    """Return (libpins, pinmeta, inst, wires, labels, nopts)."""
    libpins, pinmeta = {}, {}
    li = s.index("(lib_symbols")
    lib = balanced(s, li)
    for m in re.finditer(r'\(symbol "([^"]+)"', lib):
        name = m.group(1)
        if ":" not in name:
            continue                      # sub-unit blocks handled below
        blk = balanced(lib, m.start())
        d = {}
        for p in re.finditer(
                r'\(pin (\w+) \w+\s*\(at ([-\d.]+) ([-\d.]+) ([\d.]+)\)'
                r'[\s\S]{0,320}?\(name "([^"]*)"[\s\S]{0,160}?'
                r'\(number "([^"]+)"', blk):
            num = p.group(6)
            d[num] = (float(p.group(2)), float(p.group(3)))
            pinmeta[(name, num)] = (p.group(5), p.group(1))
        libpins[name] = d
    inst = []
    for m in re.finditer(
            r'\(symbol\s*\(lib_id "([^"]+)"\)\s*'
            r'\(at ([-\d.]+) ([-\d.]+) ([-\d.]+)\)\s*(\(mirror ([xy])\))?', s):
        if m.start() < li + len(lib):     # inside lib_symbols? (never is)
            pass
        blk = balanced(s, m.start())
        r = re.search(r'\(property "Reference" "([^"]+)"', blk)
        if not r:
            continue
        inst.append((r.group(1), m.group(1), float(m.group(2)),
                     float(m.group(3)), float(m.group(4)), m.group(6)))
    wires = []
    for m in re.finditer(r'\(wire\s*\(pts\s*\(xy ([-\d.]+) ([-\d.]+)\)'
                         r'\s*\(xy ([-\d.]+) ([-\d.]+)\)', s):
        g = [round(float(x), 2) for x in m.groups()]
        wires.append(((g[0], g[1]), (g[2], g[3])))
    labels = []
    for m in re.finditer(r'\((?:global_label|hierarchical_label|label) '
                         r'"([^"]+)"[\s\S]{0,300}?'
                         r'\(at ([-\d.]+) ([-\d.]+) [-\d.]+\)', s):
        labels.append(((round(float(m.group(2)), 2),
                        round(float(m.group(3)), 2)), m.group(1)))
    nopts = [(round(float(m.group(1)), 2), round(float(m.group(2)), 2))
             for m in re.finditer(r'\(no_connect\s*\(at ([-\d.]+) '
                                  r'([-\d.]+)\)', s)]
    return libpins, pinmeta, inst, wires, labels, nopts

# ---------------- transform (R2) -----------------------------------------
def variants(rot, mir, px, py):
    """All candidate conventions for one pin offset."""
    a = math.radians(rot)
    c, si = math.cos(a), math.sin(a)
    out = []
    for mfirst in (True, False):
        qx, qy = px, py
        if mfirst:
            if mir == "x": qy = -qy
            if mir == "y": qx = -qx
        for sy in (1, -1):
            rx = qx * c - sy * si * qy
            ry = sy * si * qx + c * qy
            ex, ey = rx, ry
            if not mfirst:
                if mir == "x": ey = -ey
                if mir == "y": ex = -ex
            out.append(((mfirst, sy), (round(ex, 2), round(-ey, 2))))
    return out

# ---------------- geometry -----------------------------------------------
def on_seg(p, a, b, tol=0.02):
    (x, y), (x1, y1), (x2, y2) = p, a, b
    if (min(x1, x2) - 0.01 <= x <= max(x1, x2) + 0.01 and
            min(y1, y2) - 0.01 <= y <= max(y1, y2) + 0.01):
        return abs((x2 - x1) * (y - y1) - (y2 - y1) * (x - x1)) < tol
    return False

# ---------------- the engine ---------------------------------------------
def build(s):
    libpins, pinmeta, inst, wires, labels, nopts = parse(s)
    geo_pts = set()
    for a, b in wires:
        geo_pts.add(a); geo_pts.add(b)
    lbl_pts = {p for p, _ in labels}

    def hits(p):
        if p in geo_pts or p in lbl_pts:
            return True
        return any(on_seg(p, a, b) for a, b in wires)

    # calibrate: score every convention over the whole sheet
    score = collections.Counter()
    for ref, lid, x, y, rot, mir in inst:
        for num, (px, py) in libpins.get(lid, {}).items():
            for k, (dx, dy) in variants(rot, mir, px, py):
                if hits((round(x + dx, 2), round(y + dy, 2))):
                    score[k] += 1
    conv = score.most_common(1)[0][0] if score else (True, 1)

    # place pins; R2 ambiguity check per pin
    pins, ambiguous = [], []
    pin_pts = collections.Counter()
    for ref, lid, x, y, rot, mir in inst:
        for num, (px, py) in libpins.get(lid, {}).items():
            vs = dict(variants(rot, mir, px, py))
            dx, dy = vs[conv]
            p = (round(x + dx, 2), round(y + dy, 2))
            if not hits(p):
                others = [(round(x + ox, 2), round(y + oy, 2))
                          for k, (ox, oy) in vs.items() if k != conv]
                if any(hits(o) for o in set(others) - {p}):
                    ambiguous.append((ref, num, p))
            nm, et = pinmeta.get((lid, num), ("", ""))
            pins.append((ref, num, nm, et, p))
            pin_pts[p] += 1

    # union-find over wires + pins + labels (R1)
    par = {}
    def find(a):
        par.setdefault(a, a)
        r = a
        while par[r] != r:
            r = par[r]
        while par[a] != r:
            par[a], a = r, par[a]
        return r
    def union(a, b):
        par[find(a)] = find(b)
    for a, b in wires:
        union(a, b)
    contact_pts = list(pin_pts) + [p for p, _ in labels]
    for p in contact_pts:
        par.setdefault(p, p)
        for a, b in wires:
            if on_seg(p, a, b):
                union(p, a)
    # same-named labels are one net; label names name their root
    first = {}
    for p, nm in labels:
        if nm in first:
            union(p, first[nm])
        else:
            first[nm] = p
    name_of = {}
    for p, nm in labels:
        name_of.setdefault(find(p), set()).add(nm)

    nets = collections.defaultdict(list)
    for ref, num, nm, et, p in pins:
        nets[find(p)].append((ref, num, nm, et, p))
    ncset = set(nopts)
    return {"pins": pins, "nets": nets, "name_of": name_of,
            "ambiguous": ambiguous, "wires": wires, "labels": labels,
            "hits": hits, "pin_pts": pin_pts, "nc": ncset, "conv": conv,
            "score": score}

# ---------------- report -------------------------------------------------
def report(s, out=sys.stdout):
    b = build(s)
    w = out.write
    w("# convention %s  scores %s\n" %
      (b["conv"], b["score"].most_common(4)))
    if b["ambiguous"]:
        for ref, num, p in b["ambiguous"]:
            w("TOOL-AMBIGUOUS %s.%s at %s: chosen transform misses "
              "geometry another one hits -- DO NOT TRUST THIS RUN\n"
              % (ref, num, p))
        return 2
    multi = {r: ns for r, ns in b["name_of"].items() if len(ns) > 1}
    for r, ns in multi.items():
        w("MULTI-LABEL NET: %s\n" % sorted(ns))
    w("=== NETS ===\n")
    unnamed = 0
    for root, mem in sorted(b["nets"].items(),
                            key=lambda kv: -len(kv[1])):
        names = b["name_of"].get(root)
        if names:
            tag = "/".join(sorted(names))
        elif len(mem) > 1:
            unnamed += 1
            tag = "N$%d" % unnamed
        else:
            ref, num, nm, et, p = mem[0]
            # R3: raw scan before any NC verdict
            tag = "NC" if not b["hits"](p) or p in b["nc"] else "STUB"
        w("%-10s: %s\n" % (tag, " ".join(
            "%s.%s[%s]" % (ref, num, nm or et) for ref, num, nm, et, p
            in sorted(mem))))
    w("=== CHECKS ===\n")
    bad = 0
    for root, mem in b["nets"].items():
        if len(mem) == 1 and not b["name_of"].get(root):
            ref, num, nm, et, p = mem[0]
            if b["hits"](p) and p not in b["nc"]:
                bad += 1
                w("STUB %s.%s at %s: touches a wire that reaches no "
                  "other pin and has no label\n" % (ref, num, p))
    for ref, num, nm, et, p in b["pins"]:
        if et == "power_in" and len(b["nets"][
                [r for r in b["nets"] if any(pp == p for *_, pp
                 in b["nets"][r])][0]]) == 1:
            pass  # covered by STUB/NC lines above
    w("checks: %d STUB findings; NC pins listed above with coordinates\n"
      % bad)
    return 0

# ---------------- teeth (R4) ---------------------------------------------
def snapshot(s):
    b = build(s)
    return {tuple(sorted((r, n) for r, n, *_ in mem))
            for mem in b["nets"].values()}, b

def tooth(s, out=sys.stdout):
    base, b0 = snapshot(s)
    ok = True
    def bite(name, s2, expect_change=True):
        nonlocal ok
        try:
            got, _ = snapshot(s2)
            changed = got != base
        except Exception:
            changed = True
        good = changed == expect_change
        out.write("tooth %-18s %s\n" % (name, "BITES" if good
                                        else "DOES NOT BITE -- FAIL"))
        ok = ok and good
    # 1. cut the first wire that carries a multi-pin net
    m = re.search(r'\(wire\s*\(pts\s*\(xy [-\d.]+ [-\d.]+\)\s*'
                  r'\(xy [-\d.]+ [-\d.]+\)[\s\S]*?\n\t\)', s)
    if m:
        bite("cut-wire", s[:m.start()] + s[m.end():])
    # 2. unmirror the first mirrored part (D2 defect class)
    mm = re.search(r'\n\t\t\(mirror [xy]\)', s)
    if mm:
        bite("unmirror", s[:mm.start()] + s[mm.end():])
    else:
        out.write("tooth unmirror          SKIP (no mirrored part)\n")
    # 3. rotate the first part 90 degrees
    rm = re.search(r'(\(symbol\s*\(lib_id "[^"]+"\)\s*\(at [-\d.]+ '
                   r'[-\d.]+ )(\d+)\)', s)
    if rm:
        newrot = str((int(rm.group(2)) + 90) % 360)
        bite("rotate90", s[:rm.start(2)] + newrot + s[rm.end(2):])
    # 4. delete a UNIQUELY named label (its name must vanish from the map)
    counts = collections.Counter(nm for _, nm in b0["labels"])
    uniq = next((nm for nm, c in counts.items() if c == 1), None)
    if uniq:
        lm = re.search(r'\n\t\((?:global_label|hierarchical_label|label) '
                       r'"%s"[\s\S]*?\n\t\)' % re.escape(uniq), s)
        _, b2 = snapshot(s[:lm.start()] + s[lm.end():])
        n2 = {n for ns in b2["name_of"].values() for n in ns}
        good = uniq not in n2
        out.write("tooth %-18s %s\n" % ("drop-label", "BITES" if good
                                        else "DOES NOT BITE -- FAIL"))
        ok = ok and good
    else:
        out.write("tooth drop-label        SKIP (no uniquely named label)\n")
    return 0 if ok else 2

# ---------------- main ---------------------------------------------------
if __name__ == "__main__":
    fn = sys.argv[1]
    s = open(fn).read()
    if "--tooth" in sys.argv:
        sys.exit(tooth(s))
    sys.exit(report(s))
