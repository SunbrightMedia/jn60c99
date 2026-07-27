#!/usr/bin/env python3
"""INDEPENDENT check of the docpos -> dispatch-index offset (+740) in the
position map — the last unexecuted link in the chain.

Script.xml (the plugin's OWN data file) declares a <default> for every value-tree
leaf, in document order. The plugin's BINARY descriptor DB (rva 0x98c040+16*idx)
declares a default per dispatch index. If `dispatch = docpos + 740` is right,
those two must agree for EVERY leaf. They come from completely different
artefacts (an XML resource vs a compiled table), so agreement is non-circular
evidence; a wrong offset would misalign nearly all of them.
Oracle-only (image read)."""
import sys, re, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, truth

e = E.E2E(); uc = e.uc
DESC = E.IB + 0x98c040
NT = E.IB + 0x9a0030
def desc(i):
    return struct.unpack('<iii', uc.mem_read(DESC + 16*i, 12))   # min,max,default
def pname(i):
    p = int.from_bytes(uc.mem_read(NT + 8*i, 8), 'little')
    if not (E.IB <= p < E.IB + E.IMGSZ): return '?'
    b = bytearray(); a = p
    while len(b) < 96:
        c = uc.mem_read(a, 1)[0]
        if c == 0: break
        b.append(c); a += 1
    return b.decode('latin1')

xml = open(truth.SCRIPT_XML, encoding='utf-8', errors='replace').read()
vals = re.findall(r'<value>(.*?)</value>', xml, re.S)
print("Script.xml <value> leaves: %d" % len(vals))

def field(v, tag):
    m = re.search(r'<%s>(.*?)</%s>' % (tag, tag), v, re.S)
    return m.group(1).strip() if m else None

for OFF in (738, 739, 740, 741, 742):
    ok = bad = skipped = 0
    for p, v in enumerate(vals):
        nm = field(v, 'name') or '?'
        d  = field(v, 'default'); rg = field(v, 'range')
        if d is None or rg is None: skipped += 1; continue
        idx = p + OFF
        if idx > 4965: skipped += 1; continue
        try: dmin, dmax, ddef = desc(idx)
        except Exception: skipped += 1; continue
        try: xdef = int(d); xmin, xmax = [int(x) for x in rg.split(',')]
        except Exception: skipped += 1; continue
        if (xdef, xmin, xmax) == (ddef, dmin, dmax): ok += 1
        else: bad += 1
    tag = "   <=== the offset the port uses" if OFF == 740 else ""
    print("  offset %+d : %5d leaves match (default+range), %5d differ, %4d skipped%s"
          % (OFF, ok, bad, skipped, tag))

print("\n--- mismatches at the confirmed offset +740, by kind ---")
res = real = 0
rows = []
for p, v in enumerate(vals):
    nm = field(v, 'name') or '?'
    d  = field(v, 'default'); rg = field(v, 'range')
    if d is None or rg is None: continue
    idx = p + 740
    if idx > 4965: continue
    try:
        dmin, dmax, ddef = desc(idx)
        xdef = int(d); xmin, xmax = [int(x) for x in rg.split(',')]
    except Exception:
        continue
    if (xdef, xmin, xmax) == (ddef, dmin, dmax): continue
    if nm == '_reserve_' or nm.startswith('PATCH NAME'):
        res += 1; continue
    real += 1
    rows.append((p, idx, nm, pname(idx), (xmin, xmax, xdef), (dmin, dmax, ddef)))
print("  _reserve_/NAME leaves mismatching: %d (expected: unused slots)" % res)
print("  REAL named leaves mismatching   : %d" % real)
for (p, idx, nm, pn, x, dd) in rows[:40]:
    print("    docpos %3d disp %4d  xml=%-24s bin=%-24s xml(min,max,def)=%s bin=%s"
          % (p, idx, nm, pn, x, dd))
