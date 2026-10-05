# probes/coverage: the plugin writes these cells only with their cold value (evidence for build_coverage.py COLD_WRITES)
# ORACLE ONLY. Cells 85152 (EFFECT TYPE) and 10693024/10693296 (DELAY TYPE): value cold, after a
# recall into the activating type, and after leaving it (warm).
import sys, struct, gc
import os; sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools', 'verify'))
import e2e_emu as E, real_recall as R, recall_render_ab as RR, effect_param_gate as G
bank = E.bank_bytes(); lt = R.leaf_table()
rd = lambda e, o: '%08x' % struct.unpack('<I', bytes(e.uc.mem_read(e.state[0] + o, 4)))[0]
CELLS = (85152, 10693024, 10693296)
e = E.E2E(); e.build(48000.0); e.snap_all()
print('cold        ', [rd(e, o) for o in CELLS])
for label, disp, seq in (('EFFECT TYPE', 873, (0, 1, 2, 5, 0, 3)), ('DELAY TYPE', 875, (5, 0, 5, 2, 4, 5, 1))):
    e = RR.prepare_recall(0, bank, lt, E, R, 48000.0)
    print('%s after p0 recall' % label, [rd(e, o) for o in CELLS])
    for v in seq:
        for u in range(9):
            try: e.dispatch(u, disp, v)
            except RuntimeError: pass
        e.snap_all()
        print('   %s := %d ->' % (label, v), [rd(e, o) for o in CELLS])
    del e; gc.collect()
