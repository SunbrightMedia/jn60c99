#!/usr/bin/env python3
"""cold_regress.py — cache plugin cold streams once; usable to compare any libjuno.so.
Usage:
  python3 cold_regress.py plugin      # compute + pickle plugin cold streams
  python3 cold_regress.py port <tag>  # compare current libjuno.so vs cached plugin
"""
import sys, struct, pickle, ctypes
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
PKL = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/cold_regress.pkl'
BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"
PATCHES = [13, 0, 22]
NOTE, VEL, N = 60, 105, 8000

def cmp(la, ra, lb, rb):
    n = min(len(la), len(lb)); first = None; nd = 0
    for i in range(n):
        if la[i] != lb[i] or ra[i] != rb[i]:
            nd += 1
            if first is None: first = i
    return n, nd, first

if sys.argv[1] == 'plugin':
    import e2e_emu as E
    out = {}
    for p in PATCHES:
        e = E.E2E(); e.build(48000); e.snap_all(); E.recall_patch(e, p); e.snap_all(); e.clear_latch(); e.set_ftz()
        e.note_on(NOTE, VEL); L, R = e.render(N)
        out[p] = (L, R)
        print(f"plugin patch {p}: rendered {len(L)} frames")
    pickle.dump(out, open(PKL, 'wb'))
    print("saved", PKL)
else:
    tag = sys.argv[2] if len(sys.argv) > 2 else '?'
    ref = pickle.load(open(PKL, 'rb'))
    bank = open(BANK, 'rb').read()
    lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    print(f"=== port [{tag}] vs cached plugin cold ===")
    for p in PATCHES:
        c = lib.juno_gui_create(ctypes.c_float(48000.0), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), p)
        lib.juno_gui_note_on(c, NOTE, VEL)
        buf = (ctypes.c_float * (2*N))(); lib.juno_gui_render(c, buf, N)
        inter = struct.unpack("<%dI" % (2*N), bytes(buf))
        L = list(inter[0::2]); R = list(inter[1::2])
        la, ra = ref[p]
        n, nd, first = cmp(la, ra, L, R)
        print(f"  patch {p:2d}: {n} frames diffs={nd}  {'BIT-EXACT' if nd==0 else 'FIRST@'+str(first)}")
