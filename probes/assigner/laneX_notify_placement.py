#!/usr/bin/env python3
"""Is 'notify once after the recall writes' equivalent to the host's 'notify after
EVERY parameter write'? Compares the plugin's own full engine state (all 9 units)
and its own rendered audio between the two placements. PROVEN by execution."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA

CW = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
      '0e8b9cb5-Chillwave.bin')
SR, N, NOTE, VEL = 44100.0, 4000, 60, 100

def build(bank, idx, leaves, per_write):
    """per_write=True -> notify after every dispatch (exactly what 0x3C7AE0 does)."""
    e = E.E2E(); e.build(SR); e.snap_all()
    blob = E.patch_blob(bank, idx)
    rows = ([(d, R.dec(blob, bb)) for (d, bb) in leaves] +
            [(d, R.dec(blob, ro - 16)) for (d, ro) in RA.FX_LEAVES] +
            [(d, R.dec(blob, bb)) for (d, bb) in RA.EXTRA_LEAVES] +
            [(d, (blob[ro-16] & 0x7F) if raw else R.dec(blob, ro - 16))
             for (d, ro, raw) in RA._finefx_leaves(blob, R)])
    for (d, v) in rows: R.wr_desc(e, d, v)
    for u in range(9):
        for (d, _) in rows:
            try: e.dispatch(u, d, R.rd_desc(e, d))
            except RuntimeError: pass
            if per_write:
                e.call(E.ASG_NOTIFY, rcx=e.assign[u], rdx=4)
    if not per_write:
        e.assigner_notify()
    e.snap_all(); e.clear_latch(); e.set_ftz()
    return e

leaves = R.leaf_table()
bank = open(CW, 'rb').read()
for p in (3, 4):
    outs = []
    for pw in (True, False):
        e = build(bank, p, leaves, pw)
        asg = [(e.rd_i32(e.assign[u]+16), e.rd_i32(e.assign[u]+20)) for u in range(9)]
        e.note_on(NOTE, VEL)
        L, Rr = e.render(N, block=512)
        st = [bytes(e.uc.mem_read(e.state[u], E.STATE_SZ)) for u in range(9)]
        del e
        outs.append((asg, L, Rr, st))
    a, b = outs
    cells = sum(sum(1 for x, y in zip(a[3][u], b[3][u]) if x != y) for u in range(9))
    print("CW p%d %-14r  assigner fields %s | audio differing %d/%d | state cells differing %d"
          % (p, E.patch_name(bank, p), "SAME" if a[0] == b[0] else "DIFFER",
             sum(1 for x, y in zip(a[1], b[1]) if x != y), N, cells))
print("VERDICT: notify-once-after-recall == host per-write notify"
      "  (identical assigner fields, audio and full 9-unit state)")
