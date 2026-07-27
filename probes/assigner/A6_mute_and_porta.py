#!/usr/bin/env python3
"""LANE A / step 4b (EXECUTED): (a) is 'Mute (voice n)' (467+v -> cell 9824+10512v)
audible?  (b) the PORTAMENTO byte -> cell 624 (time) law, all 256 bytes.
(c) the UNISON detune cells 14480+10512v written by ASSIGN MODE == 2.
Unicorn only."""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA

SR = 48000.0
BANKPATH = os.environ.get('JUNO_ASSIGN_BANK',
    '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')
PATCH = int(os.environ.get('JUNO_ASSIGN_PATCH', '4'))
REFRESH = 0x3549B0


def f32(e, u, off):
    return struct.unpack('<f', e.uc.mem_read(e.state[u] + off, 4))[0]


def build_recalled():
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
    return e


def main():
    e = build_recalled()

    # (b) PORTAMENTO byte -> cells 592 (on flag) / 624 (time), all 256 values
    print("=== PORTAMENTO (idx 798) byte -> voice-0 cells 592 / 624 ===")
    rows = []
    for b in range(256):
        R.wr_desc(e, 798, b); e.dispatch(0, 798, b)
        rows.append((b, f32(e, 0, 592), f32(e, 0, 624)))
    for b in (0, 1, 2, 4, 8, 16, 32, 64, 65, 100, 128, 192, 254, 255):
        on, t = rows[b][1], rows[b][2]
        print("   byte %3d  592=%g  624=%.10g  (bits 0x%08X)"
              % (b, on, t, struct.unpack('<I', struct.pack('<f', t))[0]))
    # check monotonic + the 1/(x) shape
    print("   624 strictly decreasing in byte? %s" %
          all(rows[i][2] >= rows[i+1][2] for i in range(255)))
    print("   592 == (byte!=0) for all 256? %s" %
          all((r[1] == 1.0) == (r[0] != 0) for r in rows))

    # (c) UNISON detune: ASSIGN MODE 2 vs 0, cells 14480+10512v
    print("\n=== ASSIGN MODE 2 (UNISON) detune cells 14480+10512*v (voice-0 state) ===")
    for m in (0, 2, 1, 3, 2):
        R.wr_desc(e, 800, m); e.dispatch(0, 800, m)
        vals = [f32(e, 0, 14480 + 10512 * v) for v in range(8)]
        bits = [struct.unpack('<I', struct.pack('<f', x))[0] for x in vals]
        print("   mode %d : %s" % (m, ' '.join("%+.7g" % x for x in vals)))
        print("            %s" % ' '.join("%08X" % b for b in bits))

    # (a) Mute audibility: MONO mode uses voice 0 -> render unit 0 with mute 0/1
    print("\n=== 'Mute (voice 1)' (idx 467 -> cell 9824) audibility, MONO note on voice 0 ===")
    R.wr_desc(e, 800, 1); R.wr_desc(e, 798, 0); R.wr_desc(e, 799, 0)
    for u in range(9):
        e.dispatch(u, 800, 1); e.dispatch(u, 798, 0); e.dispatch(u, 799, 0)
        e.call(E.IB + REFRESH, rcx=e.assign[u], rdx=4)
    for mute in (0, 1):
        R.wr_desc(e, 467, mute)
        for u in range(9): e.dispatch(u, 467, mute)
        e.note_on(60, 100)
        L, Rr = e.render(2048, block=512)
        pk = max(abs(struct.unpack('<f', struct.pack('<I', x))[0]) for x in L)
        print("   Mute=%d  cell9824=%g  peak|L| over 2048 smp = %.6g"
              % (mute, f32(e, 0, 9824), pk))
        e.note_off(60, 64)
        e.render(4096, block=512)
    print("\nfaults=%d" % e.faults)


main()
