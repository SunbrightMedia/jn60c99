#!/usr/bin/env python3
"""Read the plugin's LIVE PARAMETER ARRAY at *(unitState + 0x38) after driving a
real recall, and compare each dispatch index's stored value against the byte our
POSITION MAP decoded for it.

The array is 40-byte records; the plugin's own getter (rva 0x3C2520) does:
    rec = *(state+0x38) + 40*idx
    if (!rec) return 0; if ((unsigned)rec[0xC] > 1) return 0;
    return *(float*)rec[0x20]
If the plugin's setters populate this array during recall, then reading it back
turns the record-byte <-> parameter POSITION MAP from cross-validated into
directly observed against the plugin's own storage.

Oracle-only (Unicorn)."""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, recall_render_ab as RA, real_bank_parse as RB

BANK  = os.environ.get('JUNO_BANK',
    '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')
PATCH = int(os.environ.get('JUNO_PATCH', '3'))

bank   = open(BANK, 'rb').read()
leaves = R.leaf_table()
e = RA.prepare_recall(PATCH, bank, leaves, E, R, 44100.0)
uc = e.uc
st = e.state[0]
rdq = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
rdd = lambda a: int.from_bytes(uc.mem_read(a, 4), 'little')
rdf = lambda a: struct.unpack('<f', uc.mem_read(a, 4))[0]

arr38 = rdq(st + 0x38)
arr58 = rdq(st + 0x58)
print("unit0 state = 0x%x" % st)
print("  *(state+0x38) = 0x%x   <- 40-byte param records (plugin's own getter reads this)" % arr38)
print("  *(state+0x58) = 0x%x   <- e2e_emu.snap_all's smoother array" % arr58)

NT = E.IB + 0x9a0030
def pname(i):
    p = rdq(NT + 8*i)
    if not (E.IB <= p < E.IB + E.IMGSZ): return '?'
    b = bytearray(); a = p
    while len(b) < 96:
        c = uc.mem_read(a, 1)[0]
        if c == 0: break
        b.append(c); a += 1
    return b.decode('latin1')

def leafget(idx):
    """Reimplement the plugin's own getter 0x3C2520 exactly."""
    if not arr38: return None
    rec = arr38 + 40*idx
    try:
        gate = rdd(rec + 0xC)
        if gate > 1: return None
        vp = rdq(rec + 0x20)
        if not vp: return None
        return rdf(vp)
    except Exception:
        return None

recs = RB.parse_records(bank)
dec = {d: RB.record_value(recs[PATCH], bb) for (d, bb) in leaves}

print("\ndisp  name                       our decoded byte   plugin value-array   byte*? ")
hits = miss = 0
for (d, bb) in leaves:
    n = pname(d)
    if n.startswith('(') or n == '_NULL_': continue
    v = leafget(d)
    ours = dec[d]
    if v is None:
        print("%4d  %-26s %6d            <no record>" % (d, n, ours)); miss += 1; continue
    hits += 1
    # candidate relations
    rel = []
    if abs(v - ours) < 1e-6: rel.append('==byte')
    if ours and abs(v - ours/255.0) < 1e-6: rel.append('==byte/255')
    print("%4d  %-26s %6d          %12.6g   %s" % (d, n, ours, v, ','.join(rel) or '-'))
print("\nrecords present: %d, absent: %d" % (hits, miss))
