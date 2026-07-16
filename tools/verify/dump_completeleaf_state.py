#!/usr/bin/env python3
"""dump_completeleaf_state.py -- plugin complete-leaf recall STATE (voice-0), the
exact state recall_render_ab.py --ref renders from, so a diverging render can be
traced to the diverging engine cell. E2E/Unicorn only (process 1).

NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R

SR = 48000.0
FX_LEAVES = [(1179, 3057), (1181, 3060)]
OUT = '/home/user/jn60c99/scratchpad/completeleaf_state.pkl'
BLOCK = 10512


def state_of(idx, bank, leaves):
    e = E.E2E(); e.build(SR); e.snap_all()
    blob = E.patch_blob(bank, idx)
    for (disp, bb) in leaves:
        R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, recoff) in FX_LEAVES:
        R.wr_desc(e, disp, R.dec(blob, recoff - 16))
    for u in range(9):
        for (disp, bb) in leaves:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff) in FX_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    e.snap_all()
    return bytes(e.uc.mem_read(e.state[0], BLOCK))


def main():
    patches = [int(a) for a in sys.argv[1:]] or [18, 50]
    bank = E.bank_bytes(); leaves = R.leaf_table()
    out = {p: state_of(p, bank, leaves) for p in patches}
    pickle.dump(out, open(OUT, 'wb'))
    print("saved complete-leaf plugin voice-0 state for %s -> %s" % (patches, OUT))


if __name__ == '__main__':
    main()
