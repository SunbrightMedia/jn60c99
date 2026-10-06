#!/usr/bin/env python3
"""warm_chain_gate.py -- CHAINS of patch recalls through ONE engine on each
side; the whole object after EVERY step, plugin vs port (CLAIMS B1).

Every other recall gate recalls COLD (one record into a fresh engine), and
warm_recall_gate.py compares two hand-picked pairs. This gate runs chains, and
a step that is red where the same record recalled cold is green is a WARM
defect: the state the previous patch left behind.

THREE FAMILIES of chains (each chain = one engine, one host rate):
  pool  8 x 12  factory patches and synthetic type variants (factory bases
                with DELAY TYPE 0..5 or EFFECT TYPE 0/1/4 forced): every DELAY
                TYPE and EFFECT TYPE transition, which the factory bank alone
                cannot reach (it has no EFFECT TYPE 0/4, no DELAY TYPE 4).
  seed  8 x 12  legal seeded records (seed_recall_gate.seed_bank: every
                recalled leaf drawn from its declared range): warm reach over
                every leaf, not only the types.
  edge  6 x 7   DELAY LEVEL 2/1/0 across type changes: the DELAY LEVEL setter's
                on-flag hysteresis (level 1 keeps the delay on, never turns it
                on) on the block in force. Random levels reach 1 once in 256.
--ref builds the records and stores them in the pickle; --port replays the
SAME bytes (inputs, never oracle data).

WHAT IT COMPARES: the whole unit-0 object (minus the C++ header [0,176))
after every recall. Plugin side: recall_render_ab.apply_recall (the oracle's
recall into the existing engine, then snap); port side: juno_gui_apply_bank
into the same context.

LIMITS, stated: the order and set of leaves is the oracle's recall model
(CLAIMS B6); both sides settle every ramp after each recall, where a real host
could change patch with ramps in flight; no render is compared (the object
is); legal values only (out-of-range bytes are CLAIMS B8).

TOOTH (--tooth): three named defects in the B1 fix must each FAIL --port: the
old block left switched on at a DELAY TYPE change, the on-flag without
hysteresis, and the stale block's FEEDBACK taken from a constant instead of
the previous recall.

TWO-PROCESS RULE: --ref (Unicorn only) -> scratchpad/warm_chain_ref.pkl;
--port (libjuno only) reads it.

USAGE
    python3 tools/verify/warm_chain_gate.py --ref | --port | --tooth
"""
import gc
import os
import sys
import pickle
import random

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
REF_PKL = os.path.join(SCRATCH, 'warm_chain_ref.pkl')

HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
OBJ_END = 0xA83010
HEADER_CTL = 176
N_CHAINS, CHAIN_LEN = 8, 12
RATES = [44100.0, 48000.0, 96001.0]
BASES = (0, 4, 20)
REC_DTYPE, REC_ETYPE = 650, 634          # DELAY TYPE, EFFECT TYPE nibble pairs
DISP_DLEVEL = 796                        # DELAY LEVEL's dispatch index
EDGE_LEVELS = (2, 1, 0, 1, 2, 1, 0)      # on, held on, off, held off, on, held on, off


def pool():
    """(name, base patch, {record offset: value}) for every record a pool
    chain may draw: the 64 factory patches and the synthetic type variants."""
    out = [('f%d' % p, p, {}) for p in range(64)]
    for b in BASES:
        for dt in range(6):
            out.append(('b%d_DT%d' % (b, dt), b, {REC_DTYPE: dt}))
        for et in (0, 1, 4):
            out.append(('b%d_ET%d' % (b, et), b, {REC_ETYPE: et}))
    return out


def record_bank(bank, base, sets):
    rec = bytearray(bank[HEADER + base * STRIDE: HEADER + (base + 1) * STRIDE])
    for off, v in sets.items():
        rec[off] = (v >> 4) & 0xF
        rec[off + 1] = v & 0xF
    return bytes(bank[:HEADER]) + bytes(rec)


def chains(bank):
    """[(family, rate, [(name, one-record bank)])]. --ref only: the seed and
    edge families read the oracle's leaf tables."""
    sys.path.insert(0, HERE)
    import real_recall as R
    import seed_recall_gate as S
    out = []
    P = pool()
    for c in range(N_CHAINS):
        rnd = random.Random(1000 + c)
        picks = [P[rnd.randrange(len(P))] for _ in range(CHAIN_LEN)]
        out.append(('pool', RATES[c % 2], [(n, record_bank(bank, b, s)) for n, b, s in picks]))
    slots, ranges = S.leaf_slots(), S.declared_ranges()
    for c in range(N_CHAINS):
        steps = []
        for i in range(CHAIN_LEN):
            seed = 5000 + c * CHAIN_LEN + i
            rb, _, _ = S.seed_bank(bank, seed, slots, ranges, wild=False)
            steps.append(('s%d' % seed, rb))
        out.append(('seed', RATES[c % 3], steps))
    lvl = dict(R.leaf_table())[DISP_DLEVEL] + BLOB_OFF
    for t in range(6):
        steps = []
        for i, L in enumerate(EDGE_LEVELS):
            # even steps on type t, odd steps on another type: each level-1
            # step lands on the block the step before left in force
            dt = t if i % 2 == 0 else (t + 1 + i // 2) % 6
            base = (7 * (t * len(EDGE_LEVELS) + i)) % 64    # FEEDBACK / RESO vary
            steps.append(('e%d_DT%dL%d' % (i, dt, L), record_bank(bank, base, {REC_DTYPE: dt, lvl: L})))
        out.append(('edge', RATES[t % 3], steps))
    return out


def build_ref():
    import zlib
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    bank = E.bank_bytes()
    lt = R.leaf_table()
    ch = chains(bank)
    ref = {'_chains': [(fam, rate, [(n, zlib.compress(rb, 6)) for n, rb in steps])
                       for fam, rate, steps in ch]}
    for ci, (fam, rate, steps) in enumerate(ch):
        e = RR.build_engine(E, rate)
        states = []
        for name, rb in steps:
            RR.apply_recall(e, 0, rb, lt, E, R)
            states.append(zlib.compress(bytes(e.uc.mem_read(e.state[0], OBJ_END)), 6))
        ref[ci] = states
        del e
        gc.collect()
        sys.stderr.write('ref chain %d %s (%g Hz): %s\n' % (ci, fam, rate, ' '.join(n for n, _ in steps)))
        sys.stderr.flush()
    pickle.dump(ref, open(REF_PKL, 'wb'))
    print('wrote %s (%d chains)' % (REF_PKL, len(ch)))
    return 0


def check_port():
    import ctypes
    import zlib
    import numpy as np
    sys.path.insert(0, HERE)
    import freshlib
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    if '_chains' not in ref:
        print('STALE %s (no stored records) -- run --ref' % REF_PKL)
        return 2
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_dump.restype = ctypes.c_int
    lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    red = {}
    total = {}
    for ci, (fam, rate, steps) in enumerate(ref['_chains']):
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        prev = None
        for si, (name, zrb) in enumerate(steps):
            rb = zlib.decompress(zrb)
            lib.juno_gui_apply_bank(c, rb, len(rb), 0)
            buf = ctypes.create_string_buffer(OBJ_END)
            lib.juno_gui_dump(c, 0, buf, OBJ_END)
            got = np.frombuffer(buf.raw, dtype='<u4')
            want = np.frombuffer(zlib.decompress(ref[ci][si]), dtype='<u4')
            diff = [int(w) * 4 for w in np.nonzero(want != got)[0] if int(w) * 4 >= HEADER_CTL]
            total[fam] = total.get(fam, 0) + 1
            if diff:
                red[fam] = red.get(fam, 0) + 1
                print('%s chain %d step %2d %-12s <- %-12s %g Hz: %3d cells %s'
                      % (fam, ci, si, name, prev, rate, len(diff),
                         ['%d plug %08x port %08x' % (o, want[o // 4], got[o // 4]) for o in diff[:4]]))
            prev = name
        lib.juno_gui_destroy(c)
    n_red = sum(red.values())
    print('\n=== WARM CHAINS (CLAIMS B1): whole object after every step; red steps per family: %s ==='
          % ', '.join('%s %d/%d' % (f, red.get(f, 0), total[f]) for f in total))
    print('GATE: %s' % ('FAIL' if n_red else 'PASS'))
    return 1 if n_red else 0


def tooth():
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    gate = ['tools/verify/warm_chain_gate.py', '--port']
    a = run_tooth('warm_old_block_on',
                  [('src/delay_recall.c', '        slot1_off(state, prev, Hr);\n',
                    '        if (0) slot1_off(state, prev, Hr);\n')],
                  gate, tail=1200)
    b = run_tooth('warm_no_hysteresis',
                  [('src/delay_recall.c',
                    'int on = JI(state, JUNO_DLY_ON) ? (level >= 1) : (level >= 2);',
                    'int on = (level >= 2);')],
                  gate, tail=1200)
    c = run_tooth('warm_fb_constant',
                  [('src/delay_recall.c', 'int pfb = (int)JI(state, JUNO_PREV_FB);', 'int pfb = 120;')],
                  gate, tail=1200)
    return 0 if (a, b, c) == (0, 0, 0) else 1


def main():
    a = sys.argv[1:]
    if a[:1] == ['--ref']:
        return build_ref()
    if a[:1] == ['--port']:
        return check_port()
    if a[:1] == ['--tooth']:
        return tooth()
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
