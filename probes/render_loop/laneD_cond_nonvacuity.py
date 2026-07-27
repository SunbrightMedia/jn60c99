#!/usr/bin/env python3
"""LANE D support: (a) prove the CONDITION dispatch (idx 856) is NON-VACUOUS,
(b) measure whether the plugin's recall makes voice slot v of unit v differ from
voice slot 0 of unit 0 (per-voice CONDITION scatter).  Unicorn only."""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, recall_render_ab as RA

BANK = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
        '0e8b9cb5-Chillwave.bin')
SR, IDX = 44100.0, 3
STRIDE, VBASE = 10512, 176
STATE_SZ = 0xA83010

def read_state(e, u, lo, hi):
    out = bytearray()
    a = lo
    while a < hi:
        n = min(1 << 20, hi - a)
        out += e.uc.mem_read(e.state[u] + a, n)
        a += n
    return bytes(out)

def diff(a, b, base=0, limit=40):
    d = []
    for i in range(0, min(len(a), len(b)), 4):
        x = struct.unpack_from('<I', a, i)[0]; y = struct.unpack_from('<I', b, i)[0]
        if x != y: d.append((base + i, x, y))
    return d

bank = open(BANK, 'rb').read()
leaves = R.leaf_table()
e = RA.prepare_recall(IDX, bank, leaves, E, R, SR)

# --- (b) per-voice scatter after the patch's OWN condition byte
slots = {v: read_state(e, v, VBASE + v*STRIDE, VBASE + (v+1)*STRIDE) for v in range(8)}
print("=== per-voice scatter AFTER recall (patch's own CONDITION byte) ===")
for v in range(1, 8):
    d = diff(slots[v], slots[0], base=0)
    print("  unit%d.voice%d vs unit0.voice0 : %d differing dwords%s"
          % (v, v, len(d), ("  first: " + ", ".join("+%d 0x%08x/0x%08x" % t for t in d[:6])) if d else ""))

before = read_state(e, 0, 0, STATE_SZ)
lo, hi = struct.unpack('<ii', e.uc.mem_read(E.IB + 0x98c040 + 16*856, 8))
print("\nparamDB[856] = {min %d, max %d}" % (lo, hi))
print("descriptor[856].value before = %d" % R.rd_desc(e, 856))

R.wr_desc(e, 856, 40)
for u in range(9):
    e.dispatch(u, 856, 40)
e.snap_all()
after = read_state(e, 0, 0, STATE_SZ)
d = diff(before, after)
print("\n=== unit0 full-state diff caused by dispatch 856 = 40 ===")
print("  changed dwords: %d" % len(d))
for t in d[:60]:
    print("    off %d  0x%08x -> 0x%08x   (%.9g -> %.9g)"
          % (t[0], t[1], t[2],
             struct.unpack('<f', struct.pack('<I', t[1]))[0],
             struct.unpack('<f', struct.pack('<I', t[2]))[0]))
inblk = [t for t in d if 84272 <= t[0] < 84436]
print("  of which inside the noise block [84272,84436): %d" % len(inblk))

slots2 = {v: read_state(e, v, VBASE + v*STRIDE, VBASE + (v+1)*STRIDE) for v in range(8)}
print("\n=== per-voice scatter AFTER CONDITION=40 ===")
for v in range(1, 8):
    dd = diff(slots2[v], slots2[0])
    print("  unit%d.voice%d vs unit0.voice0 : %d differing dwords%s"
          % (v, v, len(dd), ("  first: " + ", ".join("+%d 0x%08x/0x%08x" % t for t in dd[:6])) if dd else ""))
