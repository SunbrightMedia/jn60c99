#!/usr/bin/env python3
"""delaytype_sweep.py -- WHICH cells does each DELAY TYPE value write?

DELAY TYPE (idx 875, blob 634) causes 39 of the 42 random-gate cells. This
derives its routing from the PLUGIN, by sweeping the value and recording the
cells the plugin's own recall writes for each. The port is then compared.

NOT fitted to any seed: the sweep drives the plugin's dispatch and reads its
memory. The seeds only told us WHERE to look.
"""
import os, sys, pickle, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import random_state_ab as RS
import recall_fullstate_diff as FS

DT_BB = 634
OUT = os.path.join(RS.SCRATCH, 'delaytype_sweep.pkl')

def bank_with(dt, leaves, fac):
    b = bytearray(RS.synth_bank(0, leaves, fac))     # all-factory baseline
    base = RS.HEADER + RS.BLOB_OFF
    b[base + DT_BB] = (dt >> 4) & 0xF
    b[base + DT_BB + 1] = dt & 0xF
    return bytes(b)

def ref():
    import e2e_emu as E, real_recall as R, recall_render_ab as RR
    leaves = R.leaf_table(); fac = RS.factory_leaves(leaves); offs = FS.offsets()
    out = {}
    for dt in range(16):
        e = RR.prepare_recall(0, bank_with(dt, leaves, fac), leaves, E, R, RS.SR)
        st = e.state[0]
        out[dt] = {o: struct.unpack('<I', e.uc.mem_read(st+o,4))[0] for o in offs}
        print('  DELAY TYPE %d done' % dt, flush=True)
    pickle.dump(out, open(OUT,'wb')); return 0

def port():
    import ctypes, real_recall as R
    lib = ctypes.CDLL(os.path.join(RS.ROOT,'libjuno.so'))
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes=[ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
    lib.juno_gui_peek.restype=ctypes.c_uint
    lib.juno_gui_peek.argtypes=[ctypes.c_void_p,ctypes.c_int]
    lib.juno_gui_destroy.argtypes=[ctypes.c_void_p]
    leaves=R.leaf_table(); fac=RS.factory_leaves(leaves)
    ref=pickle.load(open(OUT,'rb'))
    inert=lambda o: o<176 or o in (10759472,11022352,11022356)
    print('DELAY TYPE : differing cells (port vs plugin), all other params FACTORY')
    for dt in sorted(ref):
        ctx=lib.juno_gui_create(ctypes.c_float(RS.SR),0)
        lib.juno_gui_apply_bank(ctx, bank_with(dt,leaves,fac), RS.BANK_LEN, 0)
        bad=[o for o in ref[dt] if not inert(o) and lib.juno_gui_peek(ctx,o)!=ref[dt][o]]
        lib.juno_gui_destroy(ctx)
        print('  %2d  %3d  %s' % (dt, len(bad), sorted(bad)[:6]))
    return 0

if __name__=='__main__':
    raise SystemExit(ref() if '--ref' in sys.argv else port())
