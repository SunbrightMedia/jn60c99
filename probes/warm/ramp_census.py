"""Oracle-only census (CLAIMS B1): every ramp record a unit owns (record index
-> target cell), every parameter descriptor of type 1 (ramped) with its record,
every STATIC call site of the arm wrapper (rva 0x3C2920, `call rel32`) in the
image, the wrapper's time table, and whether a warm recall touches the warm-up
mute latch (state +11022344).
    python3 probes/warm/ramp_census.py      (Unicorn only)"""
import os, sys, struct
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR

WRAP = 0x3C2920
bank = E.bank_bytes()
lt = R.leaf_table()
e = RR.prepare_recall(0, bank, lt, E, R, 44100.0)
uc = e.uc
st = e.state[0]
q = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
d = lambda a: int.from_bytes(uc.mem_read(a, 4), 'little')
f = lambda a: struct.unpack('<f', bytes(uc.mem_read(a, 4)))[0]
base, desc = q(st + 0x58), q(st + 0x38)
desc_end = q(st + 0x40)
n_desc = (desc_end - desc) // 40 if desc_end > desc else 0
print('unit 0: descriptors at +0x38 (%d entries of 40 B), ramp records at +0x58' % n_desc)
ramped = []
for i in range(n_desc):
    typ = d(desc + 40 * i + 0xC)
    if typ == 1:
        ix = d(desc + 40 * i + 0x14)
        outp = q(base + 40 * ix)
        ramped.append((i, ix, outp - st if outp else None, f(base + 40 * ix + 24)))
print('type-1 (ramped) descriptors: %d' % len(ramped))
for i, ix, cell, rate in ramped:
    print('  desc %4d -> record %4d -> cell %-10s rate %g' % (i, ix, cell, rate))
# time table used by the wrapper: movss xmm2, [rip+0x61c1e9] at 0x3C2967 (7 bytes)
tbl = 0x3C2967 + 5 + 0x61c1e9 - 0   # rip-relative: next insn at 0x3C296C
tbl = 0x3C296C + 0x61c1e9 - 5 + 5 - 5
code = bytes(uc.mem_read(E.IB + 0x3C2960, 16))
disp = struct.unpack('<i', code[3:7])[0]           # lea rdx,[rip+disp] at 0x3C2960 (7 bytes)
tbl = 0x3C2967 + disp
print('time table at rva %06X: %s' % (tbl, [round(f(E.IB + tbl + 4 * k), 6) for k in range(8)]))
# static call sites of the wrapper
img = bytes(uc.mem_read(E.IB, E.IMGSZ))
sites = []
for p in range(len(img) - 5):
    if img[p] == 0xE8 and p + 5 + struct.unpack('<i', img[p + 1:p + 5])[0] == WRAP:
        sites.append(p)
print('static call sites of the arm wrapper rva %06X: %d' % (WRAP, len(sites)))
print('  ' + ' '.join('%06X' % s for s in sites))
# the warm-up latch across a warm recall
e.note_on(60, 100); e.render(1024); e.note_off(60); e.render(512)
lat0 = [d(e.state[u] + E.LATCH_OFF) for u in range(9)]
blob = E.patch_blob(bank, 7)
late = RR.late_leaves(blob, R)
for (dd, bb) in lt: R.wr_desc(e, dd, R.dec(blob, bb))
for (dd, v) in late: R.wr_desc(e, dd, v)
for u in range(9):
    for (dd, _) in lt:
        try: e.dispatch(u, dd, R.rd_desc(e, dd))
        except RuntimeError: pass
    for (dd, _) in late:
        try: e.dispatch(u, dd, R.rd_desc(e, dd))
        except RuntimeError: pass
e.assigner_notify()
lat1 = [d(e.state[u] + E.LATCH_OFF) for u in range(9)]
print('warm-up latch before/after a warm recall: %s / %s' % (lat0, lat1))
