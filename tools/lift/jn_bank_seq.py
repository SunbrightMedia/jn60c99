#!/usr/bin/env python3
"""jn_bank_seq.py -- the ONE shared per-patch drive of the L5 BANK gate (docs/JUNO_LIFT.md): for every factory patch,
the plugin's own patch browser load (rva 0x335850) THEN a short play (a chord on, blocks, release, flush). The same
sequence the L1 census drove per patch (juno_lift_reach.py), so the lift covers exactly what the gate grades.

The oracle (jn_bank_ref.py) and the lifted host (jn_bank_c.py) both import this, so no path is un-censused and the two
sides are identical by construction. The patch RECORD bytes come from the bank (truth.BANK) on the oracle side and are
written to patches.bin for the C side (the two-process rule: they meet only through a file). NPATCH is 64 (every
factory patch); JUNO_BANK_PATCHES trims it for a quick check.
"""
import os

HEADER, STRIDE, NAME = 23, 20223, 16      # the bank layout (juno_lift_reach.py / bank_product_gate.py)
NPATCH = int(os.environ.get('JUNO_BANK_PATCHES', '64'))
T = dict(state=0x402, ppq=0.0, cs=0.0, ce=0.0, tempo=120.0)   # playing + tempo (K_PLAYING 0x2 | K_TEMPO 0x400)


def rec_tail(bank, idx):
    """the idx-th factory patch's record bytes after the 16-byte name -- what load_patch takes"""
    return bank[HEADER + idx * STRIDE + NAME: HEADER + (idx + 1) * STRIDE]


def patch_steps():
    """the per-patch play, after the load: a chord on, a tail block, release, a flush -- the census loop verbatim
    (on 60 / 64 / 67; off the same). Each step: dict(n, events, ctx). events: (kind, offset, channel, pitch, vel)."""
    on = [('on', 0, 0, 60, 0.8), ('on', 0, 0, 64, 0.7), ('on', 0, 0, 67, 0.9)]
    off = [('off', 0, 0, 60, 0.0), ('off', 0, 0, 64, 0.0), ('off', 0, 0, 67, 0.0)]
    return [dict(n=256, events=on, ctx=T), dict(n=256, events=[], ctx=T),
            dict(n=256, events=off, ctx=T), dict(n=128, events=[], ctx=T)]


def oracle_ctx(ctx):
    """translate a ctx dict (state/ppq/cs/ce/tempo) to host_process_emu.process's ctx kwarg (raw state flags)"""
    if ctx is None:
        return None
    return dict(state=ctx['state'], ppq=ctx['ppq'], cycle=(ctx['cs'], ctx['ce']), tempo=ctx['tempo'])
