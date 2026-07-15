#!/usr/bin/env python3
"""recall_fullstate_diff.py -- Phase-1 cornerstone gate.

Diff the port's recalled per-voice engine state against the PLUGIN'S OWN recall,
cell by cell, over the whole voice-0 block. Any nonzero diff is a recall bug --
mechanical, no judgement. This is the check that catches the DCO-RANGE / PWM /
LFO class (voice region); the effect/master region (delay feedback etc.) is a
separate pass (recall_fx_diff, TODO) because those cells live in the master unit.

TWO-PROCESS (mandatory -- mixing E2E + ctypes in one process fabricates diffs):
  process 1:  python3 recall_fullstate_diff.py --ref     # plugin recall -> pickle
  process 2:  python3 recall_fullstate_diff.py --port    # port recall, diff, report

REFERENCE = the plugin's own recall: real_recall.py drives the plugin's real
value-tree setter over the plugin's own dispatch loop (all indices 0..4965,
executed) with record values from the plugin's own parser (Phase 0). Unit 0 only
(recall broadcasts identical values to all units). PORT = juno_bank_apply via
ctypes on libjuno.so.
"""
import sys, struct, pickle

HERE = '/home/user/jn60c99/tools/verify'
sys.path.insert(0, HERE)
PKL = '/home/user/jn60c99/scratchpad/recall_ref_state.pkl'
BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
BLOCK = 10512            # per-voice main block size
STRIDE = 16              # engine cells are 16-byte slots (float in low 4 bytes)
# A spread: DCO RANGE 2/3/4/5, bass + lead + poly, delay-active.
PATCHES = [62, 5, 18, 39, 6, 14, 31, 0, 21, 53]


def as_f32(u32):
    return struct.unpack('<f', struct.pack('<I', u32))[0]


if len(sys.argv) > 1 and sys.argv[1] == '--ref':
    import e2e_emu as E
    import real_recall as R
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    out = {}
    for idx in PATCHES:
        e = E.E2E(); e.build(R.SR); e.snap_all()
        blob = E.patch_blob(bank, idx)
        for (disp, bb) in leaves:
            R.wr_desc(e, disp, R.dec(blob, bb))
        # drive the plugin's real setter over its OWN full dispatch loop (executed)
        for i in range(0, 4966):
            try:
                e.dispatch(0, i, R.rd_desc(e, i))
            except RuntimeError:
                pass
        e.snap_all()
        out[idx] = bytes(e.uc.mem_read(e.state[0], BLOCK))
        sys.stderr.write("ref patch %2d (%s) done\n" % (idx, E.patch_name(bank, idx)))
        sys.stderr.flush()
    pickle.dump(out, open(PKL, 'wb'))
    print("REF: saved %d patch states (voice block %d bytes each)" % (len(out), BLOCK))

elif len(sys.argv) > 1 and sys.argv[1] == '--port':
    import ctypes
    ref = pickle.load(open(PKL, 'rb'))
    bankbytes = open(BANK, 'rb').read()
    lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint       # raw 32-bit cell bits (juno_gui_get returns float!)
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    SR = 48000.0

    import e2e_emu as E
    bank = E.bank_bytes()
    percell = {}   # offset -> list of (patch, plugin_f32, port_f32)
    for idx, blk in ref.items():
        ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(ctx, bankbytes, len(bankbytes), idx)
        for off in range(0, BLOCK, STRIDE):
            pv = struct.unpack('<I', blk[off:off + 4])[0]     # plugin (reference)
            qv = lib.juno_gui_peek(ctx, off)                  # port
            if pv != qv:
                percell.setdefault(off, []).append((idx, as_f32(pv), as_f32(qv)))

    print("=== recall full-state diff: port vs plugin's own recall (voice block) ===")
    print("patches:", PATCHES)
    if not percell:
        print("NO DIVERGENCES in the voice block -- port recall == plugin recall for every cell.")
    else:
        print("DIVERGING CELLS: %d\n" % len(percell))
        for off in sorted(percell):
            rows = percell[off]
            ex = rows[0]
            print("cell %6d  (%d patches)  e.g. patch %d: plugin %.6g vs port %.6g" %
                  (off, len(rows), ex[0], ex[1], ex[2]))
            print("    patches:", ", ".join("%d[%.4g/%.4g]" % (p, a, b) for (p, a, b) in rows))
    print("\n(reference = plugin's own dispatch loop, executed; port = juno_bank_apply)")
else:
    print("usage: recall_fullstate_diff.py --ref | --port", file=sys.stderr)
    sys.exit(2)
