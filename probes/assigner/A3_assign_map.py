#!/usr/bin/env python3
"""LANE A / steps 1-3 (EXECUTED): map CAssignJu60/CAssignB at runtime.

Single process, Unicorn only (never ctypes-loads libjuno).
  python3 A3_assign_map.py            # full run on Chillwave patch 4 'BS Glide'
Env: JUNO_ASSIGN_PATCH (default 4), JUNO_ASSIGN_BANK (default the Chillwave bin).
"""
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

# rva -> label  (assigner + its collaborators)
FUNCS = {
    0x354E00: 'A.vt+0x00  init -> own vt+0x78(this,N)',
    0x3549B0: 'A.vt+0x08  REFRESH(cat16) [cat==4 -> re-read 800 then 799]',
    0x355780: 'A.vt+0x10  noteOff(note)',
    0x355820: 'A.vt+0x18  noteOn(note,vel)',
    0x354A90: 'A.vt+0x20  midiChannelMsg(cc,val)',
    0x355870: 'A.vt+0x30  pitchBend -> set(2,493)',
    0x355AC0: 'A.vt+0x48  SETTER  -> proc_vt+0x58 = 0x3B9A30(proc,id,0,val)',
    0x355A70: 'A.vt+0x50  GETTER  -> proc_vt+0x60 = 0x3B6C40(proc,0,id,&out)',
    0x353E80: 'A.vt+0x68  (big 0x77B)',
    0x354D30: 'A.vt+0x78  setVoiceCount',
    0x355940: 'A.vt+0x80  PREPARE(sr) [holdoff+allnotesoff+refresh 800/799]',
    0x355A60: 'A.vt+0x88  getVoiceCount',
    0x3549F0: '   refreshAssignMode(800) -> +16',
    0x354A60: '   refreshLegato(799)     -> +20',
    0x353870: '   mode0/3 entry (reads 798 fresh -> a4)',
    0x353150: '   ALLOC MODE0 POLY',
    0x3535C0: '   ALLOC MODE3 POLYVAR',
    0x3538F0: '   ALLOC MODE1 MONO',
    0x353B60: '   ALLOC MODE2 UNISON',
    0x353B00: '   MODE2 noteOn gate',
    0x355270: '   release(mask)',
    0x355460: '   glideMask(mask,note)',
    0x355510: '   glideVoice(v,note)',
    0x355590: '   (5590)',
    0x355690: '   setVoiceNoteGate(v,note,vel)',
    0x354C70: '   hold/sustain(v)',
    0x3530B0: '   allNotesOff',
    0x354F10: '   (4F10 reset)',
    0x354FC0: '   (4FC0 reset)',
}

cnt = collections.Counter()
setlog = []
LOGSET = [False]


def install(e, asg0):
    uc = e.uc
    def mk(rva):
        def h(uc_, addr, size, user):
            cnt[rva] += 1
            if rva == 0x355AC0 and LOGSET[0]:
                setlog.append((uc_.reg_read(UC_X86_REG_RCX) == asg0[0],
                               uc_.reg_read(UC_X86_REG_RDX) & 0xffffffff,
                               uc_.reg_read(UC_X86_REG_R8) & 0xffffffff,
                               uc_.reg_read(UC_X86_REG_R9) & 0xffffffff))
        return h
    for rva in FUNCS:
        uc.hook_add(UC_HOOK_CODE, mk(rva), begin=E.IB + rva, end=E.IB + rva)


def dump(e, u=0):
    return bytes(e.uc.mem_read(e.assign[u], OBJSZ))


def show(b, tag):
    print("--- %s ---" % tag)
    for off in range(0, OBJSZ, 16):
        row = b[off:off + 16]
        print("  +%3d  %s" % (off, ' '.join('%02X' % c for c in row)))


def diff(a, b, tag):
    d = [i for i in range(OBJSZ) if a[i] != b[i]]
    if not d:
        print("  %-46s NO CHANGE" % tag)
        return
    # group into runs
    runs = []
    for i in d:
        if runs and i == runs[-1][1] + 1:
            runs[-1][1] = i
        else:
            runs.append([i, i])
    s = '; '.join("+%d..+%d %s -> %s" % (r[0], r[1],
                  a[r[0]:r[1] + 1].hex(), b[r[0]:r[1] + 1].hex()) for r in runs)
    print("  %-46s %s" % (tag, s))


def u32(e, a): return struct.unpack('<I', e.uc.mem_read(a, 4))[0]
def u64(e, a): return struct.unpack('<Q', e.uc.mem_read(a, 8))[0]


def main():
    bank = open(BANKPATH, 'rb').read()
    leaves = R.leaf_table()
    blob = E.patch_blob(bank, PATCH)
    print("BANK %s  patch %d = %r" % (os.path.basename(BANKPATH), PATCH,
                                      E.patch_name(bank, PATCH)))
    print("  PORTAMENTO(798,bb108)=%d  LEGATO(799,bb110)=%d  ASSIGN MODE(800,bb112)=%d"
          % (R.dec(blob, 108), R.dec(blob, 110), R.dec(blob, 112)))

    e = E.E2E()
    asg0 = [0]
    install(e, asg0)
    e.build(SR)
    asg0[0] = e.assign[0]
    print("\nHOST=0x%X  state0=0x%X proc0=0x%X assign0=0x%X noteobj0=0x%X"
          % (e.HOST, e.state[0], e.proc[0], e.assign[0], e.noteobj[0]))
    vptr = u64(e, e.assign[0])
    print("assign0 vptr rva = 0x%X  (0x9696A8=CAssignJu60, 0x969740=CAssignB)"
          % (vptr - E.IB))
    parent = u64(e, e.assign[0] + 160)
    print("assign0+160 (parent) = 0x%X   proc0 = 0x%X   MATCH=%s"
          % (parent, e.proc[0], parent == e.proc[0]))
    print("noteobj0+1312 = 0x%X   == assign0 ? %s"
          % (u64(e, e.noteobj[0] + 1312), u64(e, e.noteobj[0] + 1312) == e.assign[0]))
    print("\nBUILD hook counts (whole 9-unit build + setSampleRate):")
    for rva in sorted(FUNCS):
        if cnt[rva]:
            print("   0x%06X x%-6d %s" % (rva, cnt[rva], FUNCS[rva]))
    b_cold = dump(e)
    show(b_cold, "COLD assigner unit0 (after BUILD + setSampleRate %g)" % SR)
    print("  parsed: N=+8:%d mask=+12:0x%X MODE=+16:%d LEGATO=+20:%d HOLD=+24:%d"
          % (u32(e, e.assign[0] + 8), u32(e, e.assign[0] + 12),
             u32(e, e.assign[0] + 16), u32(e, e.assign[0] + 20),
             u32(e, e.assign[0] + 24)))
    print("  proc0[336..338] = PORTA %d  LEGATO %d  ASSIGN %d   (byte 1344/1348/1352)"
          % (u32(e, e.proc[0] + 1344), u32(e, e.proc[0] + 1348), u32(e, e.proc[0] + 1352)))
    print("  proc0[403]=%d proc0[404]=%d  childA[0..]=%s"
          % (u32(e, e.proc[0] + 1612), u32(e, e.proc[0] + 1616),
             [hex(u64(e, e.proc[0] + 272 + 16 * i)) for i in range(3)]))

    # ---------------- full recall (same body as recall_render_ab.prepare_recall)
    cnt.clear()
    e.snap_all()
    for (disp, bb) in leaves:
        R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, recoff) in RRA.FX_LEAVES:
        R.wr_desc(e, disp, R.dec(blob, recoff - 16))
    for (disp, bb) in RRA.EXTRA_LEAVES:
        R.wr_desc(e, disp, R.dec(blob, bb))
    finefx = RRA._finefx_leaves(blob, R)
    for (disp, recoff, raw) in finefx:
        v = (blob[recoff - 16] & 0x7F) if raw else R.dec(blob, recoff - 16)
        R.wr_desc(e, disp, v)
    for u in range(9):
        for (disp, bb) in leaves:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff) in RRA.FX_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, bb) in RRA.EXTRA_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff, raw) in finefx:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    e.snap_all(); e.clear_latch(); e.set_ftz()
    print("\nRECALL hook counts (the FULL prepare_recall dispatch set, 9 units):")
    any_ = False
    for rva in sorted(FUNCS):
        if cnt[rva]:
            print("   0x%06X x%-6d %s" % (rva, cnt[rva], FUNCS[rva])); any_ = True
    if not any_:
        print("   (NONE — recall never touches the assigner object)")
    b_rec = dump(e)
    diff(b_cold, b_rec, "COLD -> after FULL RECALL")
    print("  MODE=+16:%d LEGATO=+20:%d   proc0[336/337/338]=%d/%d/%d"
          % (u32(e, e.assign[0] + 16), u32(e, e.assign[0] + 20),
             u32(e, e.proc[0] + 1344), u32(e, e.proc[0] + 1348),
             u32(e, e.proc[0] + 1352)))

    # ---------------- per-index dispatch experiments
    print("\n=== per-index dispatch -> assigner byte deltas (unit 0 only) ===")
    prev = dump(e)
    for (idx, val) in [(800, 0), (800, 1), (800, 2), (800, 3),
                       (799, 1), (799, 0), (798, 0), (798, 65), (798, 200)]:
        cnt.clear()
        R.wr_desc(e, idx, val)
        e.dispatch(0, idx, val)
        cur = dump(e)
        diff(prev, cur, "dispatch(unit0, %d, %d)" % (idx, val))
        fired = ' '.join("0x%06X:%d" % (r, cnt[r]) for r in sorted(FUNCS) if cnt[r])
        print("      proc[336/337/338]=%d/%d/%d  fired: %s"
              % (u32(e, e.proc[0] + 1344), u32(e, e.proc[0] + 1348),
                 u32(e, e.proc[0] + 1352), fired or '-'))
        prev = cur

    # ---------------- the manual refresh
    print("\n=== manual refresh: call A.vt+0x08 (0x3549B0)(assign0, cat) ===")
    for cat in (2, 4):
        cnt.clear()
        e.call(E.IB + 0x3549B0, rcx=e.assign[0], rdx=cat)
        cur = dump(e)
        diff(prev, cur, "refresh(cat=%d)" % cat)
        print("      MODE=+16:%d LEGATO=+20:%d  fired: %s"
              % (u32(e, e.assign[0] + 16), u32(e, e.assign[0] + 20),
                 ' '.join("0x%06X:%d" % (r, cnt[r]) for r in sorted(FUNCS) if cnt[r])))
        prev = cur

    # ---------------- note lifecycle in each ASSIGN MODE
    for mode, porta in ((0, 65), (1, 65), (2, 65), (2, 0)):
        print("\n=== NOTE LIFECYCLE  ASSIGN MODE=%d PORTAMENTO=%d ===" % (mode, porta))
        R.wr_desc(e, 800, mode); R.wr_desc(e, 798, porta)
        for u in range(9):
            e.dispatch(u, 800, mode); e.dispatch(u, 798, porta)
        for u in range(9):
            e.call(E.IB + 0x3549B0, rcx=e.assign[u], rdx=4)
        base = dump(e)
        print("   after mode set+refresh: MODE=+16:%d LEGATO=+20:%d"
              % (u32(e, e.assign[0] + 16), u32(e, e.assign[0] + 20)))
        for (kind, note, vel) in (('on', 60, 100), ('on', 64, 100), ('off', 64, 64),
                                  ('off', 60, 64)):
            cnt.clear(); setlog.clear(); LOGSET[0] = True
            if kind == 'on': e.note_on(note, vel)
            else:            e.note_off(note, vel)
            LOGSET[0] = False
            cur = dump(e)
            diff(base, cur, "%s %d vel %d" % (kind, note, vel))
            print("      fired: %s" % ' '.join(
                "0x%06X:%d" % (r, cnt[r]) for r in sorted(FUNCS) if cnt[r]))
            u0 = [s for s in setlog if s[0]]
            print("      unit0 assigner SETTER calls (cat,id,val): %s"
                  % (', '.join("(%d,%d,%d)" % (c, i, v) for (_, c, i, v) in u0) or '-'))
            print("      voices note/gate/rel: %s" % ' '.join(
                "v%d:%d/%d/%d" % (v, cur[96 + 3 * v], cur[97 + 3 * v], cur[98 + 3 * v])
                for v in range(8)))
            print("      LRU %s  heldmask %s" % (
                [struct.unpack('<i', cur[120 + 4 * i:124 + 4 * i])[0] for i in range(8)],
                cur[80:96].hex()))
            base = cur
        prev = base

    print("\nfaults=%d" % e.faults)


main()
