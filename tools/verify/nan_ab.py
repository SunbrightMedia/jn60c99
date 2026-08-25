#!/usr/bin/env python3
"""nan_ab.py -- NaN-REACHABILITY GATE (playbook 81).

x86 comiss/ucomiss set CF=ZF=PF=1 on unordered, so `ja`/`jae` are NOT taken on
NaN while C's `<=`/`>=` ARE false -- the two agree on every ordered input and
differ only on NaN. unordered_audit.py counts the sites where that matters:
104 in the JX master, 57 in the JUNO master. Hand-rewriting them would trade one
proven defect for an unknown number of new ones.

This gate settles the question by EXPERIMENT instead. It puts a NaN into one DSP
state cell on BOTH sides, renders, and compares bit-exact. If the port and the
plugin disagree, some comparison downstream of that cell handles NaN
differently -- exactly the defect class, found without guessing which site.

A difference here is a REAL defect: both engines start from identical state and
identical input, so nothing else can explain a divergence.

usage: nan_ab.py [--patch N] [--frames N] [--cells N] [--seed N]
"""
import argparse, ctypes, os, random, struct, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
NAN_BITS = 0xffc00000


def port_render(lib, bank, patch, rate, frames, inject):
    ctx = lib.juno_gui_create(ctypes.c_float(float(rate)), 0)
    lib.juno_gui_apply_bank(ctx, bank, len(bank), patch)
    lib.juno_gui_note_on(ctx, 60, 105)
    for off, bits in inject:
        lib.juno_gui_poke(ctx, off, bits)
    buf = (ctypes.c_float * (2 * frames))()
    lib.juno_gui_render(ctx, buf, frames)
    # e2e_emu.render returns UINT32 BIT PATTERNS, so the port must be read the
    # same way. Packing the oracle's ints as floats made the CONTROL diverge on
    # every word and would have reported the whole port as NaN-broken.
    inter = struct.unpack("<%dI" % (2 * frames), bytes(buf))
    lib.juno_gui_destroy(ctx)
    return list(inter[0::2]), list(inter[1::2])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--patch", type=int, default=5)
    ap.add_argument("--frames", type=int, default=64)
    ap.add_argument("--cells", type=int, default=24)
    ap.add_argument("--seed", type=int, default=1)
    a = ap.parse_args()

    import e2e_emu as E, real_recall as R, recall_render_ab as RA, freshlib
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_poke.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_uint]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                    ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]

    bank = E.bank_bytes()
    leaves = R.leaf_table()
    rate, frames = RA.SR, a.frames

    # Choose target cells: DSP cells the render actually MOVES, so the NaN we
    # plant is reachable. Found by rendering once and diffing the state.
    e = RA.prepare_recall(a.patch, bank, leaves, E, R, rate)
    e.note_on(60, 105)
    before = bytes(e.uc.mem_read(e.state[0], 84096))
    e.render(frames)
    after = bytes(e.uc.mem_read(e.state[0], 84096))
    moved = [o for o in range(0, 84096, 4) if before[o:o + 4] != after[o:o + 4]]
    random.seed(a.seed)
    targets = sorted(random.sample(moved, min(a.cells, len(moved))))
    print("patch %d: %d cells move during render; injecting NaN into %d of them"
          % (a.patch, len(moved), len(targets)))

    # ---- CONTROL FIRST (mandatory). If the baseline diverges, the harness is
    # wrong and every NaN result below is meaningless. Learned the hard way:
    # the first version of this gate packed the oracle's uint32 bit patterns as
    # floats and reported 8/8 cells 'divergent'. ----
    e = RA.prepare_recall(a.patch, bank, leaves, E, R, rate)
    e.note_on(60, 105)
    cL, cR = e.render(frames)
    pL, pR = port_render(lib, bank, a.patch, rate, frames, [])
    ctrl = sum(1 for i in range(min(len(cL), len(pL)))
               if cL[i] != pL[i] or cR[i] != pR[i])
    print("CONTROL (no injection): %d/%d frames differ" % (ctrl, frames))
    if ctrl:
        print("GATE: ABORT -- the baseline already diverges, so this harness "
              "cannot judge NaN behaviour. Fix the pairing first.")
        return 2

    bad = []
    for off in targets:
        # ---- oracle: same recall, same note, NaN planted, then render ----
        e = RA.prepare_recall(a.patch, bank, leaves, E, R, rate)
        e.note_on(60, 105)
        e.uc.mem_write(e.state[0] + off, struct.pack('<I', NAN_BITS))
        oL, oR = e.render(frames)
        # ---- port: identical ----
        pL, pR = port_render(lib, bank, a.patch, rate, frames, [(off, NAN_BITS)])
        if (pL, pR) != (oL, oR):
            n = sum(1 for i in range(min(len(pL), len(oL)))
                    if pL[i] != oL[i] or pR[i] != oR[i])
            bad.append((off, n))
            print("   cell %6d : %d/%d output frames differ" % (off, n, frames))
    print("\ncells tested: %d, divergent: %d" % (len(targets), len(bad)))
    if bad:
        print("GATE: FAIL -- the port handles NaN differently from the plugin at")
        print("these cells. Cross-reference unordered_audit.py: a ja/jae site")
        print("downstream is transcribed with C's <=/>= instead of the negated form.")
        return 1
    print("GATE: PASS -- NaN planted in %d reachable DSP cells reproduces the" % len(targets))
    print("plugin bit-exactly, so no unordered-compare mistranscription is")
    print("reachable from them.")
    return 0


if __name__ == '__main__':
    sys.exit(main())
