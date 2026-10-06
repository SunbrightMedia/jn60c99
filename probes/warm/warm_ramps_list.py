"""Oracle-only probe (CLAIMS B1): list the ramp records a recall arms on a
RUNNING engine (note played and released, tail sounding), before any snap:
for unit 0 the target cell (offset in the unit object), start, target, incr,
subdiv and the sample by which each record is done; for unit 1 the cell list.
MEASURED 2026-10-05: 40-46 records per unit, about 21 change value, all 4 ms
in steps of 10 samples (done by 184 at 44.1 kHz, 392 at 96 kHz). Every gate
that snaps after a recall (e2e_emu.snap_all) is blind to them.
    python3 probes/warm/warm_ramps_list.py      (Unicorn only, ~1 min)"""
import os, sys, struct
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
bank = E.bank_bytes()
lt = R.leaf_table()

def dispatch_only(e, idx):
    blob = E.patch_blob(bank, idx)
    late = RR.late_leaves(blob, R)
    for (d, bb) in lt: R.wr_desc(e, d, R.dec(blob, bb))
    for (d, v) in late: R.wr_desc(e, d, v)
    for u in range(9):
        for (d, _) in lt:
            try: e.dispatch(u, d, R.rd_desc(e, d))
            except RuntimeError: pass
        for (d, _) in late:
            try: e.dispatch(u, d, R.rd_desc(e, d))
            except RuntimeError: pass
    e.assigner_notify()

def ramps(e, u):
    uc = e.uc; st = e.state[u]
    base = int.from_bytes(uc.mem_read(st + 88, 8), 'little')
    a = int.from_bytes(uc.mem_read(st + 112, 8), 'little')
    b = int.from_bytes(uc.mem_read(st + 120, 8), 'little')
    n = (b - a) // 4
    idxs = struct.unpack('<%di' % n, uc.mem_read(a, 4 * n)) if n > 0 else []
    out = {}
    for ix in idxs:
        rec = base + 40 * ix
        outp = int.from_bytes(uc.mem_read(rec, 8), 'little')
        incr, acc, start, tgt, rate = struct.unpack('<5f', uc.mem_read(rec + 8, 20))
        act, sub, cnt = struct.unpack('<3i', uc.mem_read(rec + 28, 12))
        rel = outp - st if outp else None
        out[ix] = (rel, start, tgt, incr, sub, cnt, act)
    return out

for a, b, sr in ((0, 7, 44100.0), (39, 40, 44100.0), (2, 6, 96000.0)):
    e = RR.prepare_recall(a, bank, lt, E, R, sr)
    e.note_on(60, 100); e.render(1024); e.note_off(60); e.render(512)
    dispatch_only(e, b)
    r0 = ramps(e, 0)
    r1 = ramps(e, 1)
    print('== p%d -> p%d @%g: unit0 %d ramps, unit1 %d ramps' % (a, b, sr, len(r0), len(r1)))
    life = {ix: None for ix in r0}
    t = 0
    while t < 512 and any(v is None for v in life.values()):
        e.render(8, block=8); t += 8
        now = ramps(e, 0)
        for ix in life:
            if life[ix] is None and ix not in now:
                life[ix] = t
    for ix, (rel, start, tgt, incr, sub, cnt, act) in sorted(r0.items(), key=lambda kv: (kv[1][0] or 0)):
        print('  rec %4d cell %-10s start %-12.6g target %-12.6g incr %-12.6g subdiv %3d  done by %s'
              % (ix, rel, start, tgt, incr, sub, life[ix]))
    print('  unit1 cells:', sorted(v[0] for v in r1.values() if v[0] is not None)[:60], flush=True)
    del e
