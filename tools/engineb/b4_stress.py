#!/usr/bin/env python3
"""b4_stress.py -- BUILD the B4 worst-case stress scenario, and say honestly
which half of B4 it can and cannot decide.

WHAT B4 REQUIRES (FINAL_GUIDE.md:87-91, verbatim):
    "all 64 patches x worst-case polyphony x a program change on every
     boundary x every parameter changing every block, with a hard
     block-overrun counter that must read 0"

THE COUNTER IS NOT HERE, AND CANNOT BE. A block overrun is a real-time event
on the device; no host run has a deadline to miss. The counter was ADDED to
the firmware in this same commit (esp32s3/main/juno_s3_listen.c, rpt_ovr_*),
because it did not exist -- `underrun` counts an I2S timeout, which needs an
EMPTY DMA queue, and a LATE block produces the opposite state. So B4's verdict
comes from the board, and this file's job is to decide WHAT the board should
run, not to pre-empt what it will say.

WHAT THIS FILE CAN DECIDE, AND WHY IT IS TRUSTWORTHY
The worst case here is a DISCRETE ARM SELECTION, not a gradient. Which delay
arm a patch selects is readable from the bank with no timing model at all
(juno_bank_delay_modes, src/juno_apply.c:918). docs/engineb/data/
patch_dependent_fx.md, from the board: "Every expensive patch is DELAY TYPE
2, 3 or 5. Every cheap one is 0 or 1. No exception in the 24 patches the run
covered." That is a statement about CODE PATHS, and code paths do not change
between host and target.

WHAT THIS FILE REFUSES TO DECIDE, AND WHY
A fine ranking BY COST across patches. MEASURED c/i differs by subsystem --
1.56 for the voice chain, 2.36 for the FX chain (docs/engineb/data/
fx_chain_price.md:9-12, sourced from board data). Two candidates whose
instruction totals sit within 1.51x of each other can therefore invert on
silicon. The repo has already recorded exactly this: docs/engineb/data/
layout_sweep.md rows 1/2 and 7/9 were host-side TIES that silicon separated by
37 and 921 cycles. So this file reports the arm CLASS and the ordering rule,
and leaves the ordering to the board (plan step M2).

USAGE
    b4_stress.py                 # the stress plan: classes, scenario, verdict
    b4_stress.py --scenarios     # emit scenarios in null_b's own tuple format
    b4_stress.py --teeth         # prove the classifier can fail (see below)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))

# The expensive arm class, from the board (patch_dependent_fx.md). TYPE 4 is
# NOT in it: no factory patch reaches it, and the synthetic scenarios that do
# are doctored records rather than the instrument.
EXPENSIVE = (2, 3, 5)

# Worst-case polyphony. The DEVICE build ships S3L_VOICES=2 today
# (esp32s3/main/juno_s3_listen.c) while the END GOAL is 6 across two chips, so
# the stress must be expressible at both and the report must say which.
POLY_DEVICE_TODAY = 2
POLY_GOAL = 6

# A chord that forces distinct voices rather than one note retriggered. Spread
# so unison/detune cannot collapse them onto one allocator slot.
CHORD = (40, 47, 52, 59, 64, 71)


def bank_bytes():
    import e2e_emu as E
    return E.bank_bytes()


def delay_types(bank):
    """(patch index -> DELAY TYPE) for every patch, through the PORT's own
    reader. No timing model, no capture: this is the code path the engine will
    take, read from the same bytes the engine reads."""
    import ctypes
    import freshlib
    lib = freshlib.load()
    lib.juno_bank_num_patches.argtypes = [ctypes.c_char_p, ctypes.c_ulong]
    lib.juno_bank_delay_modes.argtypes = [
        ctypes.c_char_p, ctypes.c_int,
        ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int)]
    n = lib.juno_bank_num_patches(bank, len(bank))
    out = {}
    for p in range(n):
        t = ctypes.c_int(-1)
        if lib.juno_bank_delay_modes(bank, p, None, None, ctypes.byref(t)):
            out[p] = t.value
    return out


def scenario_for(idx, poly, blocks, param_storm=True):
    """ONE patch under the full stress, in null_b's own event language
    (tools/trackb/null_ab.py:61-63): ('on',n,v) | ('off',n) |
    ('param',blob_idx,byte) | ('render',n).

    Every scenario releases every note and renders a tail -- null_ab.py:75-79
    records that a release-only error once passed 5 of 7 scenarios because the
    tail was missing. That rule is obeyed here rather than restated."""
    CHUNK = 256                      # the device's block, so "every block"
    ev = [('on', n, 100) for n in CHORD[:poly]]
    for b in range(blocks):
        if param_storm:
            # EVERY BLOCK, a different byte: the storm is the point. Byte 52 is
            # DELAY LEVEL, the parameter whose law this project has already been
            # bitten by twice (playbook 50/52), so it is the honest one to sweep.
            ev.append(('param', 52, (b * 37) % 256))
        ev.append(('render', CHUNK))
    ev += [('off', n) for n in CHORD[:poly]]
    ev.append(('render', 4 * CHUNK))
    return (idx, ev, 'B4 p%d poly%d' % (idx, poly))


def build_plan(bank, poly, blocks):
    dt = delay_types(bank)
    exp = sorted(p for p, t in dt.items() if t in EXPENSIVE)
    cheap = sorted(p for p, t in dt.items() if t not in EXPENSIVE)
    return dt, exp, cheap, [scenario_for(p, poly, blocks) for p in sorted(dt)]


def main():
    a = sys.argv[1:]
    bank = bank_bytes()
    poly = POLY_GOAL
    blocks = 8
    dt, exp, cheap, scen = build_plan(bank, poly, blocks)

    if "--teeth" in a:
        # SEEN TO FAIL, and the plant goes through the REAL READER.
        #
        # A first version of this tooth filtered a Python dict of forced zeros
        # and reported OK. That proves the set comprehension works and NOTHING
        # about juno_bank_delay_modes -- exactly the shape of the two defects
        # this project paid for on 2026-08-17 (a tooth that asserted instead of
        # biting, and an audit that scanned an empty region and passed). So the
        # plant is now different BYTES fed to the same C function.
        print("=== B4 CLASSIFIER TEETH ===")
        bad = 0

        # 1. CROSS-CHECK against board data recorded independently of this
        #    tool: patch_dependent_fx.md gives 5 -> TYPE 5, 11 -> 2, 19 -> 3.
        known = {5: 5, 11: 2, 19: 3}
        for p, want in sorted(known.items()):
            got = dt.get(p)
            mark = "ok" if got == want else "*** MISMATCH ***"
            if got != want:
                bad += 1
            print("  patch %-2d expect TYPE %d  read TYPE %s  %s"
                  % (p, want, got, mark))

        # 2. THE PLANT: zero the bank and read it again through the same C
        #    entry point. If the expensive set does not collapse, the reader is
        #    not reading these bytes and every list this tool prints is
        #    decoration.
        live = len(exp)
        try:
            zeroed = delay_types(b"\0" * len(bank))
            z_exp = [p for p, t in zeroed.items() if t in EXPENSIVE]
        except Exception as e:                       # a refusal is also a pass
            z_exp, note = [], "reader refused the zeroed bank (%s)" % type(e).__name__
        else:
            note = "read %d patches" % len(zeroed)
        print("  live bank    : %d expensive of %d" % (live, len(dt)))
        print("  ZEROED bank  : %d expensive   (%s)" % (len(z_exp), note))
        if live <= 0 or len(z_exp) >= live:
            bad += 1
            print("  *** BLIND: the plant did not change the answer ***")

        print("  -> %s" % ("OK -- the classifier follows the BYTES"
                           if bad == 0 else "*** TEETH FAILURE ***"))
        return 0 if bad == 0 else 1

    if "--scenarios" in a:
        for s in scen:
            print(repr(s))
        return 0

    print("=== B4 WORST-CASE STRESS PLAN ===")
    print("patches read: %d" % len(dt))
    hist = {}
    for t in dt.values():
        hist[t] = hist.get(t, 0) + 1
    print("DELAY TYPE histogram: %s"
          % "  ".join("t%d=%d" % (k, hist[k]) for k in sorted(hist)))
    print()
    print("EXPENSIVE ARM CLASS (TYPE 2/3/5) -- %d patches:" % len(exp))
    print("  %s" % ", ".join(str(p) for p in exp))
    print("CHEAP (TYPE 0/1) -- %d patches" % len(cheap))
    print()
    print("Stress per patch: poly %d, program change at every boundary,"
          % poly)
    print("  a parameter write EVERY block (%d blocks of 256 frames),"
          % blocks)
    print("  every note released and a tail rendered.")
    print("  Scenarios emitted: %d  (--scenarios to print them)" % len(scen))
    print()
    print("WHAT THIS DECIDES:  the CLASS. The %d patches above are the ones"
          % len(exp))
    print("  that select eb_delay_t23/eb_delay_t5. That is a code path, so it")
    print("  transfers to the device unchanged.")
    print("WHAT IT DOES NOT DECIDE:  which single patch is worst. c/i is 1.56")
    print("  for voices and 2.36 for the FX chain (board data), so any two")
    print("  candidates within 1.51x invert freely. layout_sweep.md already")
    print("  records silicon separating two host-side ties by 37 and 921 cyc.")
    print("  The worst patch is measured ON THE BOARD -- plan step M2.")
    print()
    print("THE VERDICT B4 NEEDS is the firmware's own counter, added with this")
    print("  file: 'B4: ovr=<late>/<miss> hn=<n>'. miss MUST read 0.")
    print("  Build S3L_B4_TOOTH=200 FIRST and see miss climb; a B4 run whose")
    print("  tooth build never went red has proved nothing.")
    print()
    print("⚑ BLOCKED, and it is a real gap: the DEVICE has no per-parameter")
    print("  write API. engine_b/dev/eb_devseq.h exposes install/recall/notes")
    print("  and nothing per-parameter, so 'every parameter changing every")
    print("  block' CANNOT run on the board until C11's event API exists.")
    print("  The param-storm dimension is expressible HERE and not THERE.")
    print("  B4 is therefore not completable today, and the missing piece is")
    print("  C11 -- which FINAL_GUIDE already lists as the next C item.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
