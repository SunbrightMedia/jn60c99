#!/usr/bin/env python3
"""LANE A / step 4 (EXECUTED): the engine cells behind the assigner's three per-voice
param families (NOTE CV 433+v, GATE 450+v, GLIDE-ARM 467+v) and the plugin's own
names for 798/799/800/433/450/467. Unicorn only."""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA

SR = 48000.0
BANKPATH = os.environ.get('JUNO_ASSIGN_BANK',
    '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')
PATCH = int(os.environ.get('JUNO_ASSIGN_PATCH', '4'))
NAMETAB = 0x9a0030


def st(e, u=0): return bytes(e.uc.mem_read(e.state[u], E.STATE_SZ))


def sdiff(a, b, limit=20):
    d = [i for i in range(0, len(a), 4) if a[i:i+4] != b[i:i+4]]
    out = ["%d:%s->%s" % (o, a[o:o+4].hex(), b[o:o+4].hex()) for o in d[:limit]]
    return "%d cells  %s%s" % (len(d), ' '.join(out), ' ...' if len(d) > limit else '')


def name(e, idx):
    try:
        p = struct.unpack('<Q', e.uc.mem_read(E.IB + NAMETAB + 8 * idx, 8))[0]
        if not (E.IB <= p < E.IB + 0x1000000): return '?'
        s = bytes(e.uc.mem_read(p, 64)); s = s[:s.find(b'\0')]
        return s.decode('latin1')
    except Exception:
        return '?'


def desc(e, idx):
    a = E.IB + 0x98c040 + 16 * idx
    return struct.unpack('<iiii', e.uc.mem_read(a, 16))


def main():
    bank = open(BANKPATH, 'rb').read()
    leaves = R.leaf_table(); blob = E.patch_blob(bank, PATCH)
    e = E.E2E(); e.build(SR); e.snap_all()
    for (disp, bb) in leaves: R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, ro) in RRA.FX_LEAVES: R.wr_desc(e, disp, R.dec(blob, ro - 16))
    for (disp, bb) in RRA.EXTRA_LEAVES: R.wr_desc(e, disp, R.dec(blob, bb))
    finefx = RRA._finefx_leaves(blob, R)
    for (disp, ro, raw) in finefx:
        R.wr_desc(e, disp, (blob[ro-16] & 0x7F) if raw else R.dec(blob, ro-16))
    allidx = [d for (d, _) in leaves] + [d for (d, _) in RRA.FX_LEAVES] \
             + [d for (d, _) in RRA.EXTRA_LEAVES] + [d for (d, _, _) in finefx]
    for u in range(9):
        for disp in allidx:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    e.snap_all(); e.clear_latch(); e.set_ftz()

    print("=== plugin name table rva 0x%X + 8*idx ===" % NAMETAB)
    for i in (312, 433, 434, 440, 450, 451, 457, 467, 468, 474, 798, 799, 800, 801):
        mn, mx, val, fl = desc(e, i)
        print("   idx %4d  %-42s  [min %d max %d val %d]" % (i, name(e, i), mn, mx, val))

    print("\n=== state[0] cells written by the per-voice assigner params (unit 0) ===")
    base = st(e)
    seq = [(433, 60), (433, 72), (450, 100), (450, 0), (467, 1), (467, 0),
           (434, 72), (451, 100), (468, 1),
           (440, 72), (457, 100), (474, 1)]
    for (idx, val) in seq:
        R.wr_desc(e, idx, val)
        try:
            e.dispatch(0, idx, val)
        except RuntimeError as ex:
            print("   %-14s DISPATCH FAULT %s" % ("%d=%d" % (idx, val), ex)); continue
        cur = st(e)
        print("   %-14s %s" % ("%d = %d" % (idx, val), sdiff(base, cur)))
        base = cur
    print("\nfaults=%d" % e.faults)


main()
