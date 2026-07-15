#!/usr/bin/env python3
"""recall_fx_diff.py -- Phase-2 cornerstone: MASTER/EFFECT-region full-state recall
diff. Diff the port's recalled MASTER unit (the effect cells >= 100000) against the
PLUGIN'S OWN recall (unit 8), cell by cell. Any nonzero diff is a candidate recall
bug; classify real-vs-benign with the RENDER A/B (recall_render_ab.py), never the
state diff alone.

REFERENCE = the plugin's complete value-tree leaf recall (real_recall.leaf_table,
disp<=877 -- includes DELAY/REVERB/EFFECT TYPE + the effect-type routing) PLUS the
effect-parameter leaves at disp>877 (FX_LEAVES below), dispatched to all 9 units.
The effect-type setter (disp 875 DELAY TYPE, 873 EFFECT TYPE, ...) reconfigures the
slot engine blocks under emulation (dual-delay 4297584.., chorus 6395312.., reverb
6497168..) -- proven by probe_dualdelay.py -- so the leaf recall DOES populate them.
Read UNIT 8 (master) effect region only (>=FX_LO): the master's voice-region cells
are unused and don't correspond to the port's single-state voice cells.

PORT = juno_gui_apply_bank -> juno_gui_peek over the same effect region.

TWO-PROCESS (mandatory):
  process 1:  python3 recall_fx_diff.py --ref   [patches...]   # plugin -> pickle
  process 2:  python3 recall_fx_diff.py --port  [patches...]   # port, diff, report
"""
import sys, struct, pickle

HERE = '/home/user/jn60c99/tools/verify'
sys.path.insert(0, HERE)
PKL = '/home/user/jn60c99/scratchpad/recall_fx_ref.pkl'
BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
SR = 48000.0
FX_LO = 100000                 # effect cells live at/above this in the master unit
FX_HI = 11022352               # master-unit state size (0xA83010)
STRIDE = 16

# effect-parameter value-tree leaves at dispatch idx > 877 (beyond leaf_table's voice
# range). (dispatch idx, RECORD byte). Record bytes from the Script.xml value-tree
# serialization walk, anchored + validated at DELAY FEEDBACK 3057 / DIRECT 3060.
# The delay block (1178..1185) is contiguous with those two validated anchors.
FX_LEAVES = [
    (1178, 3056),   # DELAY TAP TIME
    (1179, 3057),   # DELAY FEEDBACK      (validated: port bit-exact TYPE-0)
    (1180, 3059),   # DELAY HIGH CUT
    (1181, 3060),   # DELAY DIRECT LEVEL  (validated)
    (1182, 3062),   # DELAY LF DAMP
    (1183, 3070),   # DELAY LF DAMP FREQ
    (1184, 3078),   # DELAY HF DAMP
    (1185, 3086),   # DELAY HF DAMP FREQ
]

# spread: dual-delay (41), TYPE-0 delay (53,50,12,45), chorus, reverb, no-fx controls
PATCHES = [41, 53, 50, 12, 45, 0, 13, 22, 5, 62]


def parse(argv):
    ps = [int(a) for a in argv if a.lstrip('-').isdigit()]
    return ps or PATCHES


def as_f32(u):
    return struct.unpack('<f', struct.pack('<I', u))[0]


if len(sys.argv) > 1 and sys.argv[1] == '--ref':
    import e2e_emu as E
    import real_recall as R
    patches = parse(sys.argv[2:])
    bank = E.bank_bytes(); leaves = R.leaf_table()
    out = {}
    for idx in patches:
        e = E.E2E(); e.build(SR); e.snap_all()
        blob = E.patch_blob(bank, idx)
        for (disp, bb) in leaves:
            R.wr_desc(e, disp, R.dec(blob, bb))
        for (disp, ro) in FX_LEAVES:
            R.wr_desc(e, disp, R.dec(blob, ro - 16))
        for u in range(9):
            for (disp, bb) in leaves:
                try: e.dispatch(u, disp, R.rd_desc(e, disp))
                except RuntimeError: pass
            for (disp, ro) in FX_LEAVES:
                try: e.dispatch(u, disp, R.rd_desc(e, disp))
                except RuntimeError: pass
        e.snap_all()
        blk = bytes(e.uc.mem_read(e.state[8] + FX_LO, FX_HI - FX_LO))
        out[idx] = blk
        sys.stderr.write("ref patch %2d (%s) master fx region captured\n" % (idx, E.patch_name(bank, idx)))
        sys.stderr.flush()
    pickle.dump(out, open(PKL, 'wb'))
    print("REF: saved %d patch master-fx regions [%d..%d)" % (len(out), FX_LO, FX_HI))

elif len(sys.argv) > 1 and sys.argv[1] == '--port':
    import ctypes
    ref = pickle.load(open(PKL, 'rb'))
    bankbytes = open(BANK, 'rb').read()
    lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    import e2e_emu as E
    bank = E.bank_bytes()
    print("=== recall MASTER/EFFECT-region diff: port vs plugin's own recall ===")
    print("region [%d..%d), stride %d\n" % (FX_LO, FX_HI, STRIDE))
    for idx in sorted(ref):
        blk = ref[idx]
        ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(ctx, bankbytes, len(bankbytes), idx)
        divs = []
        for off in range(FX_LO, FX_HI, STRIDE):
            pv = struct.unpack('<I', blk[off - FX_LO:off - FX_LO + 4])[0]
            qv = lib.juno_gui_peek(ctx, off)
            if pv != qv:
                divs.append((off, pv, qv))
        lib.juno_gui_destroy(ctx)
        tag = "CLEAN" if not divs else "%d diverging cells" % len(divs)
        print("patch %2d %-18s %s" % (idx, E.patch_name(bank, idx), tag))
        for (off, pv, qv) in divs:
            print("    cell %8d  plugin %.7g (%08x)  vs port %.7g (%08x)" %
                  (off, as_f32(pv), pv, as_f32(qv), qv))
else:
    print("usage: recall_fx_diff.py --ref | --port  [patches...]", file=sys.stderr)
    sys.exit(2)
