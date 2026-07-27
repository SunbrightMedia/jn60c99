#!/usr/bin/env python3
"""renderstruct_ab.py -- RENDER-LOOP STRUCTURE gate (docs/RENDER_LOOP_SCOPE.md STEP 5).

WHY THIS GATE EXISTS
--------------------
Every other render gate drives the plugin and the port through ONE hand-written
loop shape: e2e_emu.render()'s (all 8 voices whole-block, then the master
per-sample) at a single block size, from a COLD engine. `src/juno_driver.c` was
written to mirror that same shape. Both sides therefore shared a blind spot: an
error in the LOOP STRUCTURE itself -- block-boundary effects, or state that only
goes wrong once the engine has been running -- could never show up.

The real per-block render was derived from the binary (rva 0x3C7400 + the pool
work item 0x3C6F00, see docs/RENDER_LOOP_LOG.md). Two consequences of that
derivation are what this gate locks down permanently:

  1. BLOCK-SIZE INVARIANCE. A real host hands the plugin 64..512 frames; our
     oracle used 600. The plugin's per-block work (buffer resize, assigner
     voice-count sync, `sub_7FF91DFB5AB0(assign,n)` = `*(assign+168) += n`)
     must not change the audio. Proven once; gated here forever.

  2. THE WARM / APPLY-ON-A-RUNNING-ENGINE LIFECYCLE. What a real host and the
     web app actually do: the engine renders continuously from instantiation,
     the preset is applied to an ALREADY-RUNNING engine, more audio is rendered,
     and only then does a note arrive. Cold gates never exercise the per-voice
     smoother runtime that has converged during the idle, nor the delta-replicated
     apply path that has to preserve it.

REFERENCE = the plugin's own recall + its own DSP under Unicorn (zero port code).
PORT      = libjuno via ctypes. TWO-PROCESS, as mandated.

  python3 tools/verify/renderstruct_ab.py --ref     # plugin  -> pickle
  python3 tools/verify/renderstruct_ab.py --port    # port, compare, verdict

Env: JUNO_RSTRUCT_PKL, JUNO_RSTRUCT_SR (default 44100).
Covenant: no capture data anywhere; ground truth is the executed binary.
"""
import sys, os, struct, pickle

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import truth

SCRATCH = os.environ.get(
    'JUNO_SCRATCH',
    '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad')
PKL = os.environ.get('JUNO_RSTRUCT_PKL', os.path.join(SCRATCH, 'renderstruct_ref.pkl'))
SR  = float(os.environ.get('JUNO_RSTRUCT_SR', '44100'))

NOTE, VEL = 60, 100

# Block sizes a real host actually uses, plus the oracle's historical 600 as the
# control. 1 is included because it is the strictest possible boundary shredder.
BLOCKS = [512, 128, 64, 1]
CTRL_BLOCK = 600

# Patch spread: a delay-active patch, a plain poly patch, a bell (long tail) and
# a bass. Non-arp only (this oracle has no transport clock, exactly as
# recall_render_ab documents).
PATCHES = [2, 0, 7, 6]

# The warm case: idle -> apply on the RUNNING engine -> idle -> note.
WARM_IDLE, WARM_GAP, WARM_N, WARM_BLK = 24000, 12000, 8000, 1024
N = 6000


def _ref():
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RA
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    out = {'sr': SR, 'blocks': {}, 'warm': {}}

    # --- 1. block-size invariance, per patch, through the plugin's own DSP -----
    for p in PATCHES:
        for b in [CTRL_BLOCK] + BLOCKS:
            e = RA.prepare_recall(p, bank, leaves, E, R, SR)
            e.note_on(NOTE, VEL)
            L, Rr = e.render(N, block=b)
            del e
            out['blocks'][(p, b)] = (L, Rr)
        print("  ref: patch %d rendered at %s" % (p, [CTRL_BLOCK] + BLOCKS), flush=True)

    # --- 2. warm lifecycle: apply the patch to an ALREADY-RUNNING engine ------
    for p in PATCHES[:2]:
        e = E.E2E(); e.build(SR); e.snap_all(); e.clear_latch(); e.set_ftz()
        e.render(WARM_IDLE, block=WARM_BLK)          # engine runs before any preset
        blob = E.patch_blob(bank, p)
        fx = RA._finefx_leaves(blob, R)
        for (d, bb) in leaves:            R.wr_desc(e, d, R.dec(blob, bb))
        for (d, rec) in RA.FX_LEAVES:     R.wr_desc(e, d, R.dec(blob, rec - 16))
        for (d, bb) in RA.EXTRA_LEAVES:   R.wr_desc(e, d, R.dec(blob, bb))
        for (d, rec, raw) in fx:
            R.wr_desc(e, d, (blob[rec - 16] & 0x7F) if raw else R.dec(blob, rec - 16))
        for u in range(9):
            for (d, _) in leaves:
                try: e.dispatch(u, d, R.rd_desc(e, d))
                except RuntimeError: pass
            for (d, _) in RA.FX_LEAVES:
                try: e.dispatch(u, d, R.rd_desc(e, d))
                except RuntimeError: pass
            for (d, _) in RA.EXTRA_LEAVES:
                try: e.dispatch(u, d, R.rd_desc(e, d))
                except RuntimeError: pass
            for (d, _, _) in fx:
                try: e.dispatch(u, d, R.rd_desc(e, d))
                except RuntimeError: pass
        e.render(WARM_GAP, block=WARM_BLK)
        e.note_on(NOTE, VEL)
        L, Rr = e.render(WARM_N, block=WARM_BLK)
        del e
        out['warm'][p] = (L, Rr)
        print("  ref: patch %d warm lifecycle rendered" % p, flush=True)

    pickle.dump(out, open(PKL, 'wb'))
    print("renderstruct ref -> %s (sr=%g)" % (PKL, SR))
    return 0


def _port():
    import ctypes
    d = pickle.load(open(PKL, 'rb'))
    lib = ctypes.CDLL(os.path.join(os.path.dirname(HERE), '..', 'libjuno.so')
                      if False else '/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float),
                                    ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = open(truth.BANK, 'rb').read()
    bits = lambda f: struct.unpack('<I', struct.pack('<f', f))[0]

    def render_into(c, n, blk):
        L, R = [], []
        done = 0
        while done < n:
            b = min(blk, n - done)
            buf = (ctypes.c_float * (2 * b))()
            lib.juno_gui_render(c, buf, b)
            for i in range(b):
                L.append(bits(buf[2 * i])); R.append(bits(buf[2 * i + 1]))
            done += b
        return L, R

    fails = 0
    checks = 0

    # --- 1. block-size invariance --------------------------------------------
    for (p, b), (rl, rr) in sorted(d['blocks'].items()):
        c = lib.juno_gui_create(ctypes.c_float(d['sr']), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), p)
        lib.juno_gui_note_on(c, NOTE, VEL)
        pl, pr = render_into(c, len(rl), b)
        lib.juno_gui_destroy(c)
        dl = sum(1 for x, y in zip(rl, pl) if x != y)
        dr = sum(1 for x, y in zip(rr, pr) if x != y)
        checks += 1
        ok = (dl == 0 and dr == 0)
        if not ok: fails += 1
        print("  patch %2d block %4d : %s (L %d, R %d differing of %d)"
              % (p, b, "BIT-EXACT" if ok else "*** DIVERGES ***", dl, dr, len(rl)))

    # --- 2. warm lifecycle ----------------------------------------------------
    for p, (rl, rr) in sorted(d['warm'].items()):
        c = lib.juno_gui_create(ctypes.c_float(d['sr']), 0)
        render_into(c, WARM_IDLE, WARM_BLK)          # run before any preset
        lib.juno_gui_apply_bank(c, bank, len(bank), p)
        render_into(c, WARM_GAP, WARM_BLK)
        lib.juno_gui_note_on(c, NOTE, VEL)
        pl, pr = render_into(c, len(rl), WARM_BLK)
        lib.juno_gui_destroy(c)
        dl = sum(1 for x, y in zip(rl, pl) if x != y)
        dr = sum(1 for x, y in zip(rr, pr) if x != y)
        checks += 1
        ok = (dl == 0 and dr == 0)
        if not ok: fails += 1
        print("  patch %2d WARM (idle %d -> apply -> idle %d -> note) : %s (L %d, R %d of %d)"
              % (p, WARM_IDLE, WARM_GAP, "BIT-EXACT" if ok else "*** DIVERGES ***",
                 dl, dr, len(rl)))

    print("RENDERSTRUCT: %d/%d checks bit-exact -> %s"
          % (checks - fails, checks, "PASS" if fails == 0 else "FAIL"))
    return 1 if fails else 0


if __name__ == '__main__':
    truth.require()
    sys.exit(_ref() if '--ref' in sys.argv else _port())
