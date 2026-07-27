#!/usr/bin/env python3
"""The WEBAPP's actual lifecycle, A/B'd against the plugin.

Every existing gate drives COLD: create -> recall -> note -> render. The webapp
does something different and never gated end-to-end:
    create engine at the device rate
 -> ScriptProcessor renders SILENCE continuously from boot   (IDLE_N samples)
 -> user picks a bank patch  -> juno_gui_apply_bank on a RUNNING engine
 -> more idle render                                          (GAP_N samples)
 -> user presses a key -> note_on -> render
A divergence here is a real bug in the port's warm/apply path that cold gates
cannot see.

Two-process (mandatory):
  webapp_lifecycle_ab.py --ref    # plugin under Unicorn -> pickle
  webapp_lifecycle_ab.py --port   # libjuno via ctypes, compare
Env: JUNO_SR (default 44100), JUNO_IDLE, JUNO_GAP, JUNO_N, JUNO_PATCH, JUNO_BANK
"""
import sys, os, pickle, struct

SP   = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
PKL  = os.path.join(SP, 'webapp_lifecycle_ref.pkl')
SR   = float(os.environ.get('JUNO_SR', '44100'))
IDLE = int(os.environ.get('JUNO_IDLE', '72000'))
GAP  = int(os.environ.get('JUNO_GAP',  '36000'))
N    = int(os.environ.get('JUNO_N',    '24000'))
PATCH= int(os.environ.get('JUNO_PATCH','3'))
BANK = os.environ.get('JUNO_BANK',
        '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')
NOTE, VEL = 60, 100
BLK = 1024                      # the webapp's ScriptProcessor block


def ref():
    sys.path.insert(0, '/home/user/jn60c99/tools/verify')
    import e2e_emu as E, real_recall as R, recall_render_ab as RA
    bank = open(BANK, 'rb').read()
    leaves = R.leaf_table()
    # 1) cold engine, no patch: idle render (what the webapp does from boot)
    e = E.E2E(); e.build(SR); e.snap_all(); e.clear_latch(); e.set_ftz()
    if IDLE: e.render(IDLE, block=BLK)
    # 2) apply the patch to the RUNNING engine (plugin's own setters)
    blob = E.patch_blob(bank, PATCH)
    RA_leaves = leaves
    for (disp, bb) in RA_leaves: R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, rec) in RA.FX_LEAVES: R.wr_desc(e, disp, R.dec(blob, rec - 16))
    for (disp, bb) in RA.EXTRA_LEAVES: R.wr_desc(e, disp, R.dec(blob, bb))
    fx = RA._finefx_leaves(blob, R)
    for (disp, rec, raw) in fx:
        R.wr_desc(e, disp, (blob[rec-16] & 0x7F) if raw else R.dec(blob, rec-16))
    for u in range(9):
        for (disp, bb) in RA_leaves:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, rec) in RA.FX_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, bb) in RA.EXTRA_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, rec, raw) in fx:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    # 3) more idle, 4) note, 5) render
    if GAP: e.render(GAP, block=BLK)
    e.note_on(NOTE, VEL)
    L, Rr = e.render(N, block=BLK)
    pickle.dump({'L': L, 'R': Rr, 'sr': SR, 'idle': IDLE, 'gap': GAP,
                 'n': N, 'patch': PATCH}, open(PKL, 'wb'))
    print("ref: wrote %s (sr=%g idle=%d gap=%d n=%d patch=%d)" % (PKL, SR, IDLE, GAP, N, PATCH))


def port():
    import ctypes
    d = pickle.load(open(PKL, 'rb'))
    lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    bank = open(BANK, 'rb').read()
    c = lib.juno_gui_create(ctypes.c_float(SR), 0)
    buf = (ctypes.c_float * (2 * max(N, BLK)))()
    def render(n):
        done = 0
        while done < n:
            b = min(BLK, n - done)
            lib.juno_gui_render(c, buf, b); done += b
    render(IDLE)
    lib.juno_gui_apply_bank(c, bank, len(bank), PATCH)
    render(GAP)
    lib.juno_gui_note_on(c, NOTE, VEL)
    out = (ctypes.c_float * (2 * N))()
    done = 0
    while done < N:
        b = min(BLK, N - done)
        tmp = (ctypes.c_float * (2 * b))()
        lib.juno_gui_render(c, tmp, b)
        for i in range(2 * b): out[2 * done + i] = tmp[i]
        done += b
    pl = [struct.unpack('<I', struct.pack('<f', out[2*i]))[0] for i in range(N)]
    pr = [struct.unpack('<I', struct.pack('<f', out[2*i+1]))[0] for i in range(N)]
    dl = sum(1 for a, b in zip(d['L'], pl) if a != b)
    dr = sum(1 for a, b in zip(d['R'], pr) if a != b)
    first = next((i for i, (a, b) in enumerate(zip(d['L'], pl)) if a != b), None)
    print("WEBAPP-LIFECYCLE A/B  sr=%g idle=%d gap=%d n=%d patch=%d" % (SR, IDLE, GAP, N, PATCH))
    print("  L differing: %d / %d    R differing: %d    first diff @ %s" % (dl, N, dr, first))
    print("  VERDICT:", "BIT-EXACT" if dl == 0 and dr == 0 else "*** DIVERGES ***")
    return 0 if (dl == 0 and dr == 0) else 1


if __name__ == '__main__':
    sys.exit(ref() if '--ref' in sys.argv else port())
