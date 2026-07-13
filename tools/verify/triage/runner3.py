#!/usr/bin/env python3
"""Seed-70 RESIDUAL triage (round 3): same run conventions as fuzz_diff.run_seed
VERBATIM. Constant render horizon 19451 (end of the render containing the
residual divergence frame 16873 -- never below 16873). Event-prefix bisection
keeps the FULL render schedule and only drops trailing non-render events.
"""
import sys, struct, ctypes, os
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import fuzz_diff as F
import e2e_emu as E

lib = F.lib
BLOBS = F.BLOBS
HORIZON = 19451          # 2110+204+1570+2242+905+2144+3363+3138+3775

def seed70_events():
    rate, patch, ev, total = F.gen_script(70)
    assert (rate, patch) == (48000.0, 15)
    ev = ev[:31]         # everything at frames <= 19451; drops events after horizon
    tot = sum(x[1] for x in ev if x[0] == 'render')
    assert tot == HORIZON, tot
    return rate, patch, ev

def prefix(ev, m):
    """All renders kept (constant horizon); only first m non-render events kept."""
    nr = [i for i, x in enumerate(ev) if x[0] != 'render']
    keep = set(nr[:m])
    return [x for i, x in enumerate(ev) if x[0] == 'render' or i in keep], nr

def run_ev(rate, patch, ev, want=False):
    # plugin  (verbatim from fuzz_diff.run_seed)
    e = E.E2E(); e.build(rate); e.snap_all(); E.recall_patch(e, patch)
    e.snap_all(); e.clear_latch(); e.set_ftz()
    La, Ra = [], []
    for x in ev:
        if x[0] == 'on': e.note_on(x[1], x[2])
        elif x[0] == 'off': e.note_off(x[1])
        elif x[0] == 'param':
            for u in range(9):
                try: e.dispatch(u, BLOBS[x[1]] + 744, x[2])
                except RuntimeError: pass
            e.snap_all()
        else:
            l, r = e.render(x[1]); La += l; Ra += r
    # port  (verbatim from fuzz_diff.run_seed)
    bank = open(F.BANK, 'rb').read()
    c = lib.juno_gui_create(ctypes.c_float(rate), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), patch)
    if patch in F.ARPS: lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)
    Lb, Rb = [], []
    for x in ev:
        if x[0] == 'on': lib.juno_gui_note_on(c, x[1], x[2])
        elif x[0] == 'off': lib.juno_gui_note_off(c, x[1])
        elif x[0] == 'param': lib.juno_gui_set_param(c, x[1], x[2])
        else:
            n = x[1]; buf = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, buf, n)
            inter = struct.unpack("<%dI" % (2*n), bytes(buf))
            Lb += inter[0::2]; Rb += inter[1::2]
    n = min(len(La), len(Lb))
    first = next((i for i in range(n) if La[i] != Lb[i] or Ra[i] != Rb[i]), None)
    if want:
        return first, (La, Ra, Lb, Rb), e, c
    del e
    if first is None:
        return None
    return (first, La[first], Lb[first], Ra[first], Rb[first])

def report(tag, r, n_frames=HORIZON):
    if r is None:
        print(f"{tag}: OK frames={n_frames}", flush=True)
    else:
        print(f"{tag}: DIVERGE @frame {r[0]} plugL={r[1]:08x} portL={r[2]:08x} "
              f"plugR={r[3]:08x} portR={r[4]:08x}", flush=True)

if __name__ == '__main__':
    rate, patch, EV = seed70_events()
    mode = sys.argv[1]
    if mode == 'full':
        report('full-to-horizon', run_ev(rate, patch, EV))
    elif mode == 'prefix':
        for a in sys.argv[2:]:
            m = int(a)
            pev, nr = prefix(EV, m)
            dropped = [EV[i] for i in nr[m:]]
            report(f"m={m} (dropped {dropped})", run_ev(rate, patch, pev))
