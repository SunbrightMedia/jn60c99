#!/usr/bin/env python3
"""LANE A / step 3b (EXECUTED): the assigner's mode-change side effects, the POLY
legato/portamento glide block, MODE 3, the steal rule, and the ENGINE-CELL footprint
of dispatching 798/799/800 (does the port need DSP writes for these, or only
allocation changes?).  Unicorn only; never ctypes-loads libjuno."""
import sys, os, struct, collections
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,
                               UC_X86_REG_R9)

SR = 48000.0
BANKPATH = os.environ.get('JUNO_ASSIGN_BANK',
    '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')
PATCH = int(os.environ.get('JUNO_ASSIGN_PATCH', '4'))
OBJSZ = 0xB0
REFRESH = 0x3549B0

FUNCS = {0x3549B0: 'refresh', 0x3549F0: 'rdMode', 0x354A60: 'rdLegato',
         0x353150: 'POLY', 0x3535C0: 'POLYVAR', 0x3538F0: 'MONO', 0x353B60: 'UNISON',
         0x355270: 'release', 0x355460: 'glideMask', 0x355510: 'glideVoice',
         0x355590: 'f5590', 0x355690: 'setNoteGate', 0x3530B0: 'allNotesOff',
         0x354C70: 'hold', 0x355AC0: 'SET', 0x355A70: 'GET',
         0x354F10: 'f4F10', 0x354FC0: 'f4FC0'}
cnt = collections.Counter(); setlog = []; LOG = [False]; ASG = [0]


def install(e):
    def mk(rva):
        def h(uc_, addr, size, user):
            cnt[rva] += 1
            if rva == 0x355AC0 and LOG[0] and uc_.reg_read(UC_X86_REG_RCX) == ASG[0]:
                setlog.append((uc_.reg_read(UC_X86_REG_R8) & 0xffffffff,
                               uc_.reg_read(UC_X86_REG_R9) & 0xffffffff))
        return h
    for rva in FUNCS:
        e.uc.hook_add(UC_HOOK_CODE, mk(rva), begin=E.IB + rva, end=E.IB + rva)


def dump(e, u=0): return bytes(e.uc.mem_read(e.assign[u], OBJSZ))
def st(e, u=0):   return bytes(e.uc.mem_read(e.state[u], E.STATE_SZ))
def u32(e, a):    return struct.unpack('<I', e.uc.mem_read(a, 4))[0]


def odiff(a, b):
    d = [i for i in range(OBJSZ) if a[i] != b[i]]
    runs = []
    for i in d:
        if runs and i == runs[-1][1] + 1: runs[-1][1] = i
        else: runs.append([i, i])
    return '; '.join("+%d..%d %s->%s" % (r[0], r[1], a[r[0]:r[1]+1].hex(),
                     b[r[0]:r[1]+1].hex()) for r in runs) or 'NONE'


def sdiff(a, b, limit=24):
    d = [i for i in range(0, len(a), 4) if a[i:i+4] != b[i:i+4]]
    out = []
    for o in d[:limit]:
        out.append("%d:%s->%s" % (o, a[o:o+4].hex(), b[o:o+4].hex()))
    return "%d cells  %s%s" % (len(d), ' '.join(out), ' ...' if len(d) > limit else '')


def fired():
    return ' '.join("%s:%d" % (FUNCS[r], cnt[r]) for r in sorted(FUNCS) if cnt[r]) or '-'


def voices(b):
    return ' '.join("v%d:%d/%d/%d" % (v, b[96+3*v], b[97+3*v], b[98+3*v]) for v in range(8))


def lru(b):
    return [struct.unpack('<i', b[120+4*i:124+4*i])[0] for i in range(8)]


def setmode(e, mode=None, legato=None, porta=None):
    for (idx, val) in ((800, mode), (799, legato), (798, porta)):
        if val is None: continue
        R.wr_desc(e, idx, val)
        for u in range(9): e.dispatch(u, idx, val)
    for u in range(9): e.call(E.IB + REFRESH, rcx=e.assign[u], rdx=4)


def ev(e, kind, note, vel=100, base=None, tag=''):
    cnt.clear(); setlog.clear(); LOG[0] = True
    if kind == 'on': e.note_on(note, vel)
    else: e.note_off(note, vel)
    LOG[0] = False
    cur = dump(e)
    print("   %-22s obj: %s" % (tag or ("%s %d" % (kind, note)), odiff(base, cur) if base else '-'))
    print("      fired %s" % fired())
    print("      SET(id,val) %s" % (', '.join("(%d,%d)" % s for s in setlog) or '-'))
    print("      %s   LRU %s" % (voices(cur), lru(cur)))
    return cur


def main():
    bank = open(BANKPATH, 'rb').read()
    leaves = R.leaf_table(); blob = E.patch_blob(bank, PATCH)
    e = E.E2E(); install(e); e.build(SR); ASG[0] = e.assign[0]
    e.snap_all()
    for (disp, bb) in leaves: R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, ro) in RRA.FX_LEAVES: R.wr_desc(e, disp, R.dec(blob, ro - 16))
    for (disp, bb) in RRA.EXTRA_LEAVES: R.wr_desc(e, disp, R.dec(blob, bb))
    finefx = RRA._finefx_leaves(blob, R)
    for (disp, ro, raw) in finefx:
        R.wr_desc(e, disp, (blob[ro-16] & 0x7F) if raw else R.dec(blob, ro-16))
    for u in range(9):
        for (disp, bb) in leaves + [(d, 0) for (d, _) in RRA.FX_LEAVES] + RRA.EXTRA_LEAVES \
                          + [(d, 0) for (d, _, _) in finefx]:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    e.snap_all(); e.clear_latch(); e.set_ftz()

    # descriptor ranges
    print("=== descriptor DB rva 0x98c040+16*idx  [min,max,value] ===")
    for idx in (798, 799, 800):
        a = E.IB + 0x98c040 + 16 * idx
        mn, mx, val, fl = struct.unpack('<iiii', e.uc.mem_read(a, 16))
        print("   idx %d  min=%d max=%d value=%d flags=0x%X" % (idx, mn, mx, val, fl))

    # ---- ENGINE CELL footprint of 798/799/800 (state[0], from the recalled patch)
    print("\n=== state[0] cell deltas of the three dispatches (recalled BS Glide base) ===")
    setmode(e, mode=0, legato=0, porta=0)
    s0 = st(e)
    for (idx, val, tag) in [(798, 65, 'PORTAMENTO 0->65 (mode0,leg0)'),
                            (798, 0,  'PORTAMENTO 65->0'),
                            (799, 1,  'LEGATO 0->1 (mode 0)'),
                            (799, 0,  'LEGATO 1->0 (mode 0)'),
                            (800, 1,  'ASSIGN 0->1 (MONO)'),
                            (799, 1,  'LEGATO 0->1 (mode 1)'),
                            (798, 65, 'PORTAMENTO 0->65 (mode1,leg1)'),
                            (800, 2,  'ASSIGN 1->2 (UNISON)'),
                            (800, 0,  'ASSIGN 2->0 (POLY)')]:
        R.wr_desc(e, idx, val); e.dispatch(0, idx, val)
        s1 = st(e); print("   %-32s %s" % (tag, sdiff(s0, s1))); s0 = s1

    # ---- mode-change side effects with a note HELD
    print("\n=== mode transitions with note 60 HELD (refresh(4) side effects) ===")
    for (frm, to) in ((0, 1), (0, 2), (0, 3), (1, 0), (2, 0), (2, 1), (3, 2)):
        setmode(e, mode=frm, legato=0, porta=0)
        e.note_on(60, 100)
        b = dump(e)
        R.wr_desc(e, 800, to)
        for u in range(9): e.dispatch(u, 800, to)
        cnt.clear()
        for u in range(9): e.call(E.IB + REFRESH, rcx=e.assign[u], rdx=4)
        c = dump(e)
        print("   %d -> %d : %s" % (frm, to, odiff(b, c)))
        print("        fired %s ; %s ; held %s" % (fired(), voices(c), c[80:96].hex()))
        e.note_off(60, 64)

    # ---- POLY legato+portamento glide block
    print("\n=== MODE 0 POLY: LEGATO x PORTAMENTO glide block ===")
    for (leg, por) in ((0, 0), (1, 0), (0, 65), (1, 65)):
        setmode(e, mode=0, legato=leg, porta=por)
        print("  -- LEGATO=%d PORTAMENTO=%d  (+16=%d +20=%d)" %
              (leg, por, u32(e, e.assign[0] + 16), u32(e, e.assign[0] + 20)))
        b = dump(e)
        b = ev(e, 'on', 60, 100, b, 'on 60')
        b = ev(e, 'on', 64, 100, b, 'on 64 (overlap)')
        b = ev(e, 'on', 67, 100, b, 'on 67 (overlap)')
        b = ev(e, 'off', 67, 64, b, 'off 67')
        b = ev(e, 'off', 64, 64, b, 'off 64')
        b = ev(e, 'off', 60, 64, b, 'off 60')

    # ---- POLY steal rule (9th note) with/without portamento
    print("\n=== MODE 0 POLY steal target (9 notes) ===")
    for por in (0, 65):
        setmode(e, mode=0, legato=0, porta=por)
        for n in range(60, 68): e.note_on(n, 100)
        b = dump(e)
        print("  -- PORTAMENTO=%d  before 9th: %s LRU %s" % (por, voices(b), lru(b)))
        b = ev(e, 'on', 72, 100, b, 'on 72 (steal)')
        for n in list(range(60, 68)) + [72]: e.note_off(n, 64)

    # ---- MODE 3
    print("\n=== MODE 3 POLY-variant ===")
    setmode(e, mode=3, legato=1, porta=65)
    b = dump(e)
    b = ev(e, 'on', 60, 100, b, 'on 60')
    b = ev(e, 'on', 64, 100, b, 'on 64')
    b = ev(e, 'off', 64, 64, b, 'off 64')
    b = ev(e, 'off', 60, 64, b, 'off 60')

    # ---- MODE 1/2 note priority: press 60,64,62 then release
    print("\n=== MODE 1 MONO / MODE 2 UNISON note priority ===")
    for m in (1, 2):
        setmode(e, mode=m, legato=0, porta=65)
        print("  -- MODE %d" % m)
        b = dump(e)
        b = ev(e, 'on', 60, 100, b, 'on 60')
        b = ev(e, 'on', 64, 110, b, 'on 64')
        b = ev(e, 'on', 62, 120, b, 'on 62')
        b = ev(e, 'off', 62, 64, b, 'off 62 (last-played)')
        b = ev(e, 'off', 60, 64, b, 'off 60 (lowest held)')
        b = ev(e, 'off', 64, 64, b, 'off 64 (last one)')

    print("\nfaults=%d" % e.faults)


main()
