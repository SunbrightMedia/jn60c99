#!/usr/bin/env python3
"""Full net-level audit of a MasterAudio kicad_sch: builds the complete
pin->net map for EVERY symbol (all lib_ids, rotation+mirror aware), then
checks every requirement the project has established. Read-only."""
import re, math, sys, collections

FN = sys.argv[1] if len(sys.argv) > 1 else "MasterAudio_v2.kicad_sch"
s = open(FN).read()

def balanced(t, i):
    d = 0
    for j in range(i, len(t)):
        if t[j] == "(":
            d += 1
        elif t[j] == ")":
            d -= 1
            if d == 0:
                return t[i:j + 1]

# ---- 1. library pin geometry per lib symbol -----------------------------
m = re.search(r'\(lib_symbols', s)
libblock = balanced(s, m.start())
libpins = {}   # libname -> {number: (x,y)}
for m in re.finditer(r'\(symbol "([^"]+)"', libblock):
    name = m.group(1)
    if ":" not in name:
        continue
    blk = balanced(libblock, m.start())
    pins = {}
    for p in re.finditer(r'\(pin \w+ \w+\s*\(at ([-\d.]+) ([-\d.]+) [\d.]+\)'
                         r'[\s\S]{0,260}?\(number "([^"]+)"', blk):
        pins[p.group(3)] = (float(p.group(1)), float(p.group(2)))
    libpins[name] = pins

# ---- 2. symbol instances ------------------------------------------------
inst = []
for m in re.finditer(r'\n\t\(symbol\n\t\t\(lib_id "([^"]+)"\)\n\t\t\(at '
                     r'([-\d.]+) ([-\d.]+) ([\d.]+)\)(\n\t\t\(mirror ([xy])\))?', s):
    blk = balanced(s, m.start() + 2)
    ref = re.search(r'\(property "Reference" "([^"]+)"', blk).group(1)
    val = re.search(r'\(property "Value" "([^"]+)"', blk).group(1)
    inst.append((ref, val, m.group(1), float(m.group(2)), float(m.group(3)),
                 float(m.group(4)), m.group(6)))

# The transform is CHOSEN BY EVIDENCE, not assumed: eight candidate
# conventions; the one under which the most pins land on wires/labels
# wins (measured over the whole sheet). A wrong sign here produced false
# "bare pin" reports on every rotated part (2026-09-08).
def _variants(rot, mir, px, py):
    a = math.radians(rot)
    c, si = math.cos(a), math.sin(a)
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
            yield (mfirst, sy), (ex, -ey)
_PINCONV = [None]
def pinpos(x, y, rot, mir, px, py):
    key = _PINCONV[0]
    for k, (dx, dy) in _variants(rot, mir, px, py):
        if k == key:
            return (round(x + dx, 2), round(y + dy, 2))
    return (round(x + px, 2), round(y - py, 2))

# ---- 3. wire graph + labels ---------------------------------------------
parent = {}
def find(a):
    r = a
    while parent.get(r, r) != r:
        r = parent[r]
    while parent.get(a, a) != a:
        parent[a], a = r, parent[a]
    return r
def union(a, b):
    parent.setdefault(a, a)
    parent.setdefault(b, b)
    parent[find(a)] = find(b)

wire_pts = []
for m in re.finditer(r'\(wire\s*\(pts\s*\(xy ([-\d.]+) ([-\d.]+)\)\s*'
                     r'\(xy ([-\d.]+) ([-\d.]+)\)', s):
    a = (round(float(m.group(1)), 2), round(float(m.group(2)), 2))
    b = (round(float(m.group(3)), 2), round(float(m.group(4)), 2))
    union(a, b)
    wire_pts.append((a, b))
# junctions merge nothing extra here (wires sharing endpoints already merge);
# also merge wire endpoints that touch the MIDDLE of another wire (T joins
# drawn without a shared endpoint but with a junction dot)
juncs = [(round(float(m.group(1)), 2), round(float(m.group(2)), 2))
         for m in re.finditer(r'\(junction\s*\(at ([-\d.]+) ([-\d.]+)', s)]
def on_seg(p, a, b):
    ax, ay = a; bx, by = b; px, py = p
    if ax == bx == px:
        return min(ay, by) <= py <= max(ay, by)
    if ay == by == py:
        return min(ax, bx) <= px <= max(ax, bx)
    return False
for j in juncs:
    parent.setdefault(j, j)
    for a, b in wire_pts:
        if on_seg(j, a, b):
            union(j, a)

# ---- calibrate the pin transform against the sheet itself ---------------
_nodes = set()
for _a, _b in wire_pts:
    _nodes.add(_a); _nodes.add(_b)
for _m in re.finditer(r'\((?:global_label|label) "[^"]+"[\s\S]{0,260}?\(at ([-\d.]+) ([-\d.]+) [\d.]+\)', s):
    _nodes.add((round(float(_m.group(1)), 2), round(float(_m.group(2)), 2)))
def _on_any(p):
    if p in _nodes: return True
    for _a, _b in wire_pts:
        if on_seg(p, _a, _b): return True
    return False
_scores = {}
for _ref, _val, _lib, _x, _y, _rot, _mir in inst:
    for _num, (_px, _py) in libpins.get(_lib, {}).items():
        for _k, (_dx, _dy) in _variants(_rot, _mir, _px, _py):
            _p = (round(_x + _dx, 2), round(_y + _dy, 2))
            if _on_any(_p):
                _scores[_k] = _scores.get(_k, 0) + 1
_PINCONV[0] = max(_scores, key=_scores.get)
print("# transform calibration:", sorted(_scores.items(), key=lambda kv: -kv[1])[:3])

# KiCad connection rules my first pass missed:
#  - two pins at the SAME coordinate connect with no wire
#  - a pin, label or wire END landing ON a wire segment connects (auto-junction)
# Crossing wire INTERIORS never connect (no endpoint there) -- preserved.
PIN_PTS = []
for _ref, _val, _lib, _x, _y, _rot, _mir in inst:
    for _num, (_px, _py) in libpins.get(_lib, {}).items():
        PIN_PTS.append(pinpos(_x, _y, _rot, _mir, _px, _py))
for _p in PIN_PTS:
    parent.setdefault(_p, _p)   # same-coordinate pins now share one node
_touch = set(PIN_PTS)
for _a, _b in wire_pts:
    _touch.add(_a); _touch.add(_b)
for _p in _touch:
    parent.setdefault(_p, _p)
    for _a, _b in wire_pts:
        if _p != _a and _p != _b and on_seg(_p, _a, _b):
            union(_p, _a)

labels = {}
for m in re.finditer(r'\((?:global_label|label) "([^"]+)"[\s\S]{0,260}?'
                     r'\(at ([-\d.]+) ([-\d.]+) [\d.]+\)', s):
    p = (round(float(m.group(2)), 2), round(float(m.group(3)), 2))
    parent.setdefault(p, p)
    labels.setdefault(p, set()).add(m.group(1))

for _p in labels:
    parent.setdefault(_p, _p)
    for _a, _b in wire_pts:
        if _p != _a and _p != _b and on_seg(_p, _a, _b):
            union(_p, _a)
netof = {}
for p, names in labels.items():
    netof.setdefault(find(p), set()).update(names)

# ---- 4. pin -> net -------------------------------------------------------
pin_net = {}      # (ref, pin) -> netname or None
net_pins = collections.defaultdict(list)
for ref, val, lib, x, y, rot, mir in inst:
    for num, (px, py) in libpins.get(lib, {}).items():
        wp = pinpos(x, y, rot, mir, px, py)
        root = find(wp) if wp in parent else None
        names = netof.get(root) if root else None
        n = "/".join(sorted(names)) if names else None
        pin_net[(ref, num)] = n
        if n:
            net_pins[n].append((ref, num))
        elif root:
            net_pins["?anon@%s" % (root,)].append((ref, num))

# conflicting labels on one net
for root, names in netof.items():
    if len(names) > 1:
        print("MULTI-LABEL NET: %s" % sorted(names))

# ---- 5. slot row helper --------------------------------------------------
def row(slot, name):
    side, idx = name[0], int(name[1:])
    grp = ("A" if idx <= 11 else "B") if side == "L" else ("C" if idx <= 11 else "D")
    pin = idx if idx <= 11 else idx - 11
    return pin_net.get(("H%d%s1" % (slot, grp), str(pin)))

# ---- 6. requirement sweep ------------------------------------------------
bad = 0
def need(slot, rw, sub, why):
    global bad
    got = row(slot, rw)
    if sub is None:
        if got:
            print("FAIL slot%d %s: must be NC (%s), found %s" % (slot, rw, why, got))
            bad += 1
    elif not got or sub not in got:
        print("FAIL slot%d %s: want %s (%s), found %s" % (slot, rw, sub, why, got))
        bad += 1

for sl in (1, 2, 3, 4):
    need(sl, "R6", "CTRL_RSP", "response bus")
    need(sl, "R7", "CTRL_BC", "broadcast bus")
    need(sl, "R14", "BOOT_ESP%d" % sl, "boot")
    need(sl, "R19", "USBDP_ESP%d" % sl, "upload")
    need(sl, "R20", "USBDN_ESP%d" % sl, "upload")
    need(sl, "L1", "3V3_ESP%d" % sl, "3V3")
    need(sl, "R2", None, "console")
    need(sl, "R3", None, "console")
    need(sl, "R15", None, "IO45 strap")
    need(sl, "R16", None, "IO48 LED")
need(1, "L5", "I2S_BCK", "DAC"); need(1, "L6", "I2S_WS", "DAC"); need(1, "L7", "I2S_SD", "DAC")
need(1, "L11", "MIDI_RX", "MIDI"); need(1, "R18", "MIDI_TX", "MIDI")
need(1, "R5", "VOL_ADC", "pot")
# hop audio, receiver side direct on LINK net; transmitter side behind 330R
for sl, net in ((1, "LINK21"), (2, "LINK32"), (3, "LINK43")):
    need(sl, "L15", net + "_BCK", "hop rx"); need(sl, "L16", net + "_WS", "hop rx")
    need(sl, "L17", net + "_SD", "hop rx")
# hop control, receiver side direct
need(1, "R17", "LINK21_CTL_D", "ctl rx"); need(2, "L6", "LINK21_CTL_U", "ctl rx")
need(2, "R17", "LINK32_CTL_D", "ctl rx"); need(3, "L6", "LINK32_CTL_U", "ctl rx")
need(3, "R17", "LINK43_CTL_D", "ctl rx"); need(4, "L6", "LINK43_CTL_U", "ctl rx")

# transmitter pins must reach their net THROUGH exactly one 330R
def resistor_between(slot, rw, net):
    global bad
    start = row(slot, rw)
    if start == net:
        print("FAIL slot%d %s: connected STRAIGHT to %s -- no 330R in line"
              % (slot, rw, net)); bad += 1; return
    # the pin's anon net must contain one leg of a 330R whose other leg is net
    side, idx = rw[0], int(rw[1:])
    grp = ("A" if idx <= 11 else "B") if side == "L" else ("C" if idx <= 11 else "D")
    pin = str(idx if idx <= 11 else idx - 11)
    href = "H%d%s1" % (slot, grp)
    # find which anon net holds this pin
    holder = None
    for n, pl in net_pins.items():
        if (href, pin) in pl:
            holder = n
    if holder is None:
        print("FAIL slot%d %s: pin floats (no wire at all) toward %s" % (slot, rw, net))
        bad += 1; return
    rs = [r for r, p in net_pins.get(holder, []) if r.startswith("R") and r != href]
    okr = None
    for rref in rs:
        v = next(i[1] for i in inst if i[0] == rref)
        other = [pn for (rr, pn), nn in pin_net.items() if rr == rref]
        nets = {pin_net.get((rref, pn)) for pn in ("1", "2")}
        if net in {n for n in nets if n} and "3300" in v:
            okr = rref
    if okr:
        pass
    else:
        print("FAIL slot%d %s -> %s: no 330R (0603WAF3300T5E) bridges pin to net; stub holds %s"
              % (slot, rw, net, sorted(set(r for r, _ in net_pins.get(holder, [])))))
        bad += 1

for sl, net in ((2, "LINK21"), (3, "LINK32"), (4, "LINK43")):
    for rw, suf in (("L8", "_BCK"), ("L9", "_WS"), ("L10", "_SD")):
        resistor_between(sl, rw, net + suf)
resistor_between(2, "L5", "LINK21_CTL_D"); resistor_between(1, "L14", "LINK21_CTL_U")
resistor_between(3, "L5", "LINK32_CTL_D"); resistor_between(2, "L14", "LINK32_CTL_U")
resistor_between(4, "L5", "LINK43_CTL_D"); resistor_between(3, "L14", "LINK43_CTL_U")

# R63-style pullup: CTRL_RSP net must hold a 10k to 3V3A
pull = False
for ref, val, lib, *_ in inst:
    if "1002" in val:
        nets = {pin_net.get((ref, "1")), pin_net.get((ref, "2"))}
        if "CTRL_RSP" in {n for n in nets if n} and "3V3A" in {n for n in nets if n}:
            pull = True
if not pull:
    print("FAIL: no 10k between CTRL_RSP and 3V3A"); bad += 1

# 5V jumpers: L21's (unlabeled) stub must hold a 2-pin part whose other pin is +5V
def holder_of(ref, pin):
    for n, pl in net_pins.items():
        if (ref, pin) in pl:
            return n
for sl in (1, 2, 3, 4):
    got = row(sl, "L21")
    if got == "+5V":
        print("FAIL slot%d L21: straight to +5V -- no jumper inserted" % sl); bad += 1
        continue
    h = holder_of("H%dB1" % sl, "10")
    ok = False
    if h:
        for r, p in net_pins.get(h, []):
            other = "2" if p == "1" else "1"
            if r != "H%dB1" % sl and pin_net.get((r, other)) == "+5V":
                ok = True
    if not ok:
        print("FAIL slot%d L21: no path to +5V through a jumper (stub: %s)"
              % (sl, sorted(set(r for r, _ in net_pins.get(h, []))) if h else "bare pin")); bad += 1

# EN: all four L3 on ONE net with a switch to GND
en = {row(sl, "L3") for sl in (1, 2, 3, 4)}
if len(en) != 1:
    print("FAIL: EN nets not joined: %s" % sorted(n or "float" for n in en)); bad += 1
else:
    n = en.pop()
    sws = [ref for (ref, p), nn in pin_net.items() if nn == n and ref.startswith("SW")]
    if not sws:
        print("FAIL: joined EN net %s has no reset switch" % n); bad += 1

# BOOT JSTs to GND
for sl in (2, 3, 4):
    netn = "BOOT_ESP%d" % sl
    refs = {r for r, p in net_pins.get(netn, [])}
    if not any(r.startswith("J") for r in refs):
        print("FAIL: %s has no JST" % netn); bad += 1

# MUX16 chain headers (official mux pinout 2026-09-08): a 3-pin connector
# carrying exactly GND/SDA1/3V3_ESP1 and a 4-pin carrying SCL1/SEND1/2/3
def connector_with(nets):
    want = set(nets)
    byref = collections.defaultdict(set)
    for (r, p), n in pin_net.items():
        if r.startswith("J") and n:
            byref[r].add(n)
    return any(v == want for v in byref.values())
# split-aware since the RC went in (2026-09-08): the header's SIG pin sits
# on the HEADER side of the 1k; SDA1 stays on the slot-1 L12 side.
def mux_a_ok():
    byref = collections.defaultdict(dict)
    for (r, p), n in pin_net.items():
        byref[r][p] = n
    for r, v, l, *_ in inst:
        if not r.startswith("J") or len(libpins.get(l, {})) != 3:
            continue
        nets = byref[r]
        if set(n for n in nets.values() if n) != {"GND", "3V3_ESP1"}:
            continue
        sigp = next(p for p, n in nets.items() if not n)
        h = next((nn for nn, pl in net_pins.items() if (r, sigp) in pl), None)
        if not h:
            continue
        for rr, pp in net_pins.get(h, []):
            other = "2" if pp == "1" else "1"
            vv = next(i[1] for i in inst if i[0] == rr)
            if rr.startswith("R") and "1001" in vv and pin_net.get((rr, other)) == "SDA1":
                return True
    return False
if not mux_a_ok():
    print("FAIL: mux SIG path broken: need 3-pin header (GND/SIG/3V3_ESP1) "
          "with SIG through a 1k to SDA1"); bad += 1
cap_ok = any(v for r, v, l, *_ in inst
             if "BB103" in v and {pin_net.get((r, "1")), pin_net.get((r, "2"))} == {"SDA1", "GND"})
if not cap_ok:
    print("FAIL: no 10nF (BB103) between SDA1 and GND at the ADC end"); bad += 1
if not connector_with(("SCL1", "SEND1", "SEND2", "SEND3")):
    print("FAIL: no 4-pin mux header (SCL1/SEND1..3) -- J_MUX_D missing"); bad += 1

# slot-4 listen header (decided 2026-09-08): L15-L17 on LISTEN1..3, and a
# connector must carry all three plus GND
for i, rw in enumerate(("L15", "L16", "L17")):
    pass  # rows checked via LINK sweep only on slots 1-3; slot 4 is LISTEN
_l4 = [row(4, r) for r in ("L15", "L16", "L17")]
if _l4 != ["LISTEN1", "LISTEN2", "LISTEN3"]:
    print("FAIL: slot4 L15-L17 must be LISTEN1..3, found %s" % _l4); bad += 1
else:
    _byref = collections.defaultdict(set)
    for (r, p), n in pin_net.items():
        if r.startswith("J") and n:
            _byref[r].add(n)
    if not any(v >= {"LISTEN1", "LISTEN2", "LISTEN3", "GND"} for v in _byref.values()):
        print("FAIL: no connector carries LISTEN1..3 + GND (slot-4 listen JST)"); bad += 1

# THE 595 ENABLE CHAIN (decided 2026-09-08): two SN74HC595DR, 3 GPIOs,
# 16 EN JSTs. Checked pin by pin; the chain link and every Q->JST->GND.
_u595 = [r for r, v, *_ in inst if v == "SN74HC595DR"]
if len(_u595) != 2:
    print("FAIL: expected two SN74HC595DR, found %s" % _u595); bad += 1
else:
    def _net(r, p): return pin_net.get((r, str(p)))
    def _holder(r, p):
        for nn, pl in net_pins.items():
            if (r, str(p)) in pl: return nn
    # identify chip A (its DS pin 14 reaches EXT_2)
    A = next((r for r in _u595 if _net(r, 14) == "EXT_2"), None)
    if A is None:
        print("FAIL: no 595 has DS(14) on EXT_2 -- chip A missing"); bad += 1
    else:
        B = next(r for r in _u595 if r != A)
        for r in (A, B):
            for p, want in ((8, "GND"), (13, "GND"), (10, "3V3_ESP1"),
                            (16, "3V3_ESP1"), (11, "EXT_3"), (12, "EXT_4")):
                if _net(r, p) != want:
                    print("FAIL: 595 %s pin %d must be %s, found %s"
                          % (r, p, want, _net(r, p))); bad += 1
        if _holder(A, 9) != _holder(B, 14) or _holder(A, 9) is None:
            print("FAIL: chain link broken: %s pin9 and %s pin14 not one net"
                  % (A, B)); bad += 1
        _en = 0
        for r in (A, B):
            for p in (15, 1, 2, 3, 4, 5, 6, 7):
                h = _holder(r, p)
                ok = False
                for rr, pp in net_pins.get(h or "", []):
                    other = "2" if pp == "1" else "1"
                    if rr.startswith("J") and pin_net.get((rr, other)) == "GND":
                        ok = True
                _en += ok
        if _en != 16:
            print("FAIL: only %d of 16 Q outputs reach a JST whose other "
                  "pin is GND" % _en); bad += 1
    _c595 = sum(1 for r, v, *_ in inst if "BB104" in v
                and {pin_net.get((r, "1")), pin_net.get((r, "2"))} == {"3V3_ESP1", "GND"})
    if _c595 < 2:
        print("WARN: fewer than two spare 100nF on 3V3_ESP1 (595 decoupling "
              "shares the count with J15's C65)")

# single-pin nets (a label used once = usually a typo)
for n, pl in sorted(net_pins.items()):
    if n.startswith("?"):
        continue
    if len(pl) == 1 and not n.startswith(("EXT_", "LISTEN")):
        print("WARN single-pin net: %s -> %s" % (n, pl))

print("AUDIT:", "GREEN" if not bad else "%d FAILURES" % bad)

# ---- 7. THE TEETH (--tooth): the tracer must be SEEN TO FAIL -------------
# Three mutations of the real file; each must change what the tracer reads.
# A tracer that reports the same nets after a deleted wire, a rotated part,
# or a broken pin-to-pin contact is not reading the schematic at all.
if "--tooth" in sys.argv:
    import subprocess, tempfile, os
    fails = 0
    base = s0 = open(FN).read()
    # remove the CHECKED connection at slot 1 DAC row L5 (its label sits on
    # the pin): the report must then show a new FAIL. Anything unchecked or
    # redundant proves nothing.
    tgt = None
    for r_, v_, l_, x_, y_, rot_, mir_ in inst:
        if r_ == "H1A1":
            tgt = pinpos(x_, y_, rot_, mir_, *libpins[l_]["5"])
    hit = None
    for lm in re.finditer(r'\n\t\(global_label "[^"]+"[\s\S]*?\n\t\)', s0):
        am = re.search(r'\(at ([-\d.]+) ([-\d.]+)', lm.group(0))
        if abs(float(am.group(1)) - tgt[0]) < 0.05 and abs(float(am.group(2)) - tgt[1]) < 0.05:
            hit = lm.group(0)
    if hit is None:
        print("TOOTH SETUP FAIL: no label at slot1 L5"); sys.exit(1)
    muts = [("checked label deleted", s0.replace(hit, "", 1))]
    # rotate the first 330R instance
    rm = re.search(r'(\n\t\(symbol\n\t\t\(lib_id "A_lcsc:0603WAF3300T5E"\)\n\t\t\(at [-\d.]+ [-\d.]+ )(\d+)\)', s0)
    if rm:
        muts.append(("330R rotated", s0[:rm.start(2)] + str((int(rm.group(2)) + 90) % 360) + s0[rm.end(2):]))
    # shift the first 330R by one grid step (breaks pin-to-pin contact)
    if rm:
        at = re.search(r'\(at ([-\d.]+) ', rm.group(1))
        old = rm.group(1)
        newx = "%.2f" % (float(at.group(1)) + 2.54)
        muts.append(("330R shifted", s0.replace(old, old.replace("(at " + at.group(1) + " ", "(at " + newx + " ", 1), 1)))
    def run(txt):
        with tempfile.NamedTemporaryFile("w", suffix=".kicad_sch", delete=False) as f:
            f.write(txt); p = f.name
        r = subprocess.run([sys.executable, os.path.abspath(sys.argv[0]), p],
                           capture_output=True, text=True)
        os.unlink(p)
        return r.stdout
    ref = run(s0)
    for name, txt in muts:
        if run(txt) == ref:
            print("TOOTH DID NOT BITE: %s changed nothing" % name); fails += 1
        else:
            print("tooth bites: %s changed the reading" % name)
    print("NET-AUDIT TEETH:", "GREEN" if not fails else "%d FAILURES" % fails)
    sys.exit(1 if fails else 0)
