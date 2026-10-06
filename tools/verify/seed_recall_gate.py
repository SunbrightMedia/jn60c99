#!/usr/bin/env python3
"""seed_recall_gate.py -- seeded records with EVERY recalled leaf random, the
plugin's complete recall vs the port's, whole object + render, 3 host rates.

USER-BINDING (2026-10-05): "seeds over all parameters, out-of-range values
too". random_state_ab.py randomized only the 112 value-tree leaves plus two FX
bytes; every fine-FX and flanger byte stayed 0, it compared the hand-made
REGIONS window (playbook 109) and it ran at one rate. This gate randomizes
every leaf the oracle recalls -- the value-tree leaves, the FX/EXTRA leaves,
the fine-FX leaves and the flanger leaves (recall_render_ab.late_leaves) -- on
a factory base record, so the bytes no leaf reads stay realistic.

MODES (kept apart, labelled in every line):
  legal  each leaf drawn from its Script.xml declared range (the plugin's own
         metadata, tools/verify/coverage_leaves.tsv);
  wild   every leaf drawn from its whole field: 0..255 for a nibble pair,
         0..127 for an int1x7 byte -- out-of-range switches included.
Held at the base value in both modes: ARPEGGIO SW (831, forced 0: the oracle
cannot arpeggiate), SCATTER DEPTH and OCTAVE SHIFT (835/836: signed int8x4,
which the harness decodes from the low byte only). LFO RATE H / VCF CUTOFF
FREQ H (878/1029) are not recalled by the oracle (CLAIMS B6) and stay at base.

WHAT IT COMPARES per seed: the whole unit-0 object after recall (C++ header
[0,176) excluded) and a 2048-sample render of note 60 vel 100 through the
master, bit for bit. Rate = RATES[seed % 3].

LIMITS, stated: the oracle's recall is the harness model of the plugin's
recall (CLAIMS B6); decode of the record bytes is the harness's (Script.xml
map), shared by both sides, so a decode defect cannot show here.

VERDICT: the LEGAL seeds decide PASS/FAIL. The WILD seeds are run, printed
cell by cell and counted, but not graded (CLAIMS B8): out-of-range bytes make
the plugin's reverb setters read past their tables when they are dispatched
raw, as this oracle does, while the port clamps those leaves; and whether the
plugin's own preset load ever passes a raw out-of-range byte to a setter is
the open question of CLAIMS B6 (HOSTPATH STEP 3).

TWO-PROCESS RULE: --ref (Unicorn only) -> scratchpad/seed_recall_ref.pkl;
--port (libjuno only) reads it. --ref resumes by seed.

TOOTH (--tooth): two named defects must each FAIL --port: the ASSIGN MODE 3
voice scan run top-down again (the defect found 2026-08-13 and closed by this
gate), and the DELAY TAP TIME law replaced by its default constant.

USAGE
    python3 tools/verify/seed_recall_gate.py --ref  [N_LEGAL N_WILD]
    python3 tools/verify/seed_recall_gate.py --port
    python3 tools/verify/seed_recall_gate.py --tooth
"""
import gc
import os
import sys
import pickle
import random
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
REF_PKL = os.path.join(SCRATCH, 'seed_recall_ref.pkl')

RATES = [44100.0, 48000.0, 96001.0]
HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
OBJ_END = 0xA83010
HEADER_CTL = 176
RENDER_N = 2048
N_LEGAL, N_WILD = 60, 30
HOLD = {831: 0}                      # ARPEGGIO SW off: the oracle cannot arpeggiate
SKIP = {835, 836}                    # signed int8x4 leaves (harness low-byte decode)


def declared_ranges():
    """{dispatch index: (lo, hi)} from the plugin's Script.xml metadata."""
    out = {}
    for ln in open(os.path.join(HERE, 'coverage_leaves.tsv')).read().splitlines()[1:]:
        f = ln.split('\t')
        try:
            lo, hi = (int(x) for x in f[6].split(','))
        except ValueError:
            continue
        out[int(f[1])] = (lo, hi)
    return out


def leaf_slots():
    """[(dispatch index, record offset, kind)] for every leaf the oracle recalls:
    kind 'n' = nibble pair, 'r' = int1x7 byte. Derived from the oracle's own
    tables, so this gate cannot drift from what the oracle fires."""
    sys.path.insert(0, HERE)
    import real_recall as R
    import recall_render_ab as RR
    slots = [(d, bb + BLOB_OFF, 'n') for d, bb in R.leaf_table()]
    slots += [(d, rec, 'n') for d, rec in RR.FX_LEAVES]
    slots += [(d, bb + BLOB_OFF, 'n') for d, bb in RR.EXTRA_LEAVES]
    slots += [(d, rec, 'r' if raw else 'n') for d, rec, raw in RR._finefx_leaves(None, R)]
    return sorted(set(slots))


def seed_bank(bank, seed, slots, ranges, wild=None):
    """(one-record bank, mode, base patch) for a seed. Seeds 0..N_LEGAL-1 are
    legal, the next N_WILD wild; `wild` overrides that (warm_chain_gate.py)."""
    if wild is None:
        wild = seed >= N_LEGAL
    rnd = random.Random(seed * 7919 + 13)
    base = seed % 64
    rec = bytearray(bank[HEADER + base * STRIDE: HEADER + (base + 1) * STRIDE])
    for d, off, kind in slots:
        if d in SKIP:
            continue
        if d in HOLD:
            v = HOLD[d]
        elif wild:
            v = rnd.randrange(128 if kind == 'r' else 256)
        else:
            lo, hi = ranges.get(d, (0, 255))
            lo, hi = max(lo, 0), min(hi, 127 if kind == 'r' else 255)
            v = rnd.randint(lo, hi) if hi >= lo else lo
        if kind == 'r':
            rec[off] = v & 0x7F
        else:
            rec[off] = (v >> 4) & 0xF
            rec[off + 1] = v & 0xF
    return bytes(bank[:HEADER]) + bytes(rec), ('wild' if wild else 'legal'), base


# ------------------------------------------------------------------- oracle
def build_ref(n_legal, n_wild):
    import zlib
    from array import array
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    global N_LEGAL, N_WILD
    N_LEGAL, N_WILD = n_legal, n_wild
    bank = E.bank_bytes()
    lt = R.leaf_table()
    slots = leaf_slots()
    ranges = declared_ranges()
    ref = pickle.load(open(REF_PKL, 'rb')) if os.path.exists(REF_PKL) else {}
    if ref.get('_shape') != (n_legal, n_wild, len(slots)) or ref.get('_slots') != slots:
        ref = {'_shape': (n_legal, n_wild, len(slots)), '_slots': slots}
    for seed in range(n_legal + n_wild):
        if seed in ref:
            continue
        cb, mode, base = seed_bank(bank, seed, slots, ranges)
        rate = RATES[seed % 3]
        e = RR.prepare_recall(0, cb, lt, E, R, rate)
        full = zlib.compress(bytes(e.uc.mem_read(e.state[0], OBJ_END)), 6)
        e.note_on(60, 100)
        L, Rr = e.render(RENDER_N)
        ref[seed] = (rate, mode, base, full, (array('I', L).tobytes(), array('I', Rr).tobytes()))
        del e
        gc.collect()
        if seed % 10 == 9:
            pickle.dump(ref, open(REF_PKL, 'wb'))
        sys.stderr.write('ref seed %d (%s, base %d, %g Hz)\n' % (seed, mode, base, rate))
        sys.stderr.flush()
    pickle.dump(ref, open(REF_PKL, 'wb'))
    print('wrote %s (%d seeds, %d leaves randomized each)' % (REF_PKL, len(ref) - 2, len(slots)))
    return 0


# --------------------------------------------------------------------- port
def check_port():
    import ctypes
    import zlib
    from array import array
    import numpy as np
    sys.path.insert(0, HERE)
    import freshlib
    from truth import BANK
    global N_LEGAL, N_WILD
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    N_LEGAL, N_WILD, n_slots = ref['_shape']
    # the leaf list comes from the reference: importing the oracle's tables here
    # would load the emulator into the libjuno process (two-process rule)
    slots = ref['_slots']
    ranges = declared_ranges()
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_dump.restype = ctypes.c_int
    lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = open(BANK, 'rb').read()
    bad = {'legal': [], 'wild': []}
    cells_hist = {}
    for seed in range(N_LEGAL + N_WILD):
        if seed not in ref:
            print('seed %d: NO REF' % seed)
            return 2
        rate, mode, base, full_z, rend = ref[seed]
        cb, mode2, _ = seed_bank(bank, seed, slots, ranges)
        assert mode2 == mode
        want = np.frombuffer(zlib.decompress(full_z), dtype='<u4')
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(c, cb, len(cb), 0)
        buf = ctypes.create_string_buffer(OBJ_END)
        lib.juno_gui_dump(c, 0, buf, OBJ_END)
        got = np.frombuffer(buf.raw, dtype='<u4')
        diff = [int(w) * 4 for w in np.nonzero(want != got)[0] if int(w) * 4 >= HEADER_CTL]
        lib.juno_gui_note_on(c, 60, 100)
        fb = (ctypes.c_float * (2 * RENDER_N))()
        lib.juno_gui_render(c, fb, RENDER_N)
        pg = struct.unpack('<%dI' % (2 * RENDER_N), bytes(fb))
        La = array('I')
        La.frombytes(rend[0])
        Ra = array('I')
        Ra.frombytes(rend[1])
        first = next((i for i in range(RENDER_N) if La[i] != pg[2 * i] or Ra[i] != pg[2 * i + 1]), None)
        lib.juno_gui_destroy(c)
        if diff or first is not None:
            bad[mode].append(seed)
            for o in diff:
                cells_hist.setdefault(o, []).append(seed)
            print('seed %3d %-5s base %2d %6g Hz: %d cells differ %s%s'
                  % (seed, mode, base, rate, len(diff),
                     ['%d plug %08x port %08x' % (o, want[o // 4], got[o // 4]) for o in diff[:4]],
                     '' if first is None else '  render differs from sample %d' % first))
    if cells_hist:
        print('\ncells by number of failing seeds:')
        for o, ss in sorted(cells_hist.items(), key=lambda kv: -len(kv[1]))[:20]:
            print('  cell %9d  %3d seeds  e.g. %s' % (o, len(ss), ss[:6]))
    print('\n=== SEEDED RECALL: %d legal + %d wild seeds, every recalled leaf random, '
          'whole object + render, 3 rates: legal red %d, wild red %d ==='
          % (N_LEGAL, N_WILD, len(bad['legal']), len(bad['wild'])))
    fails = len(bad['legal'])
    if bad['wild']:
        print('WILD (CLAIMS B8, reported, not graded): %d of %d seeds differ' % (len(bad['wild']), N_WILD))
    print('GATE: %s' % ('FAIL' if fails else 'PASS'))
    return 1 if fails else 0


def tooth():
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    gate = ['tools/verify/seed_recall_gate.py', '--port']
    a = run_tooth('seed_mode3_topdown',
                  [('gui/juno_bridge.c',
                    'for (v = 0; v < JUNO_NUM_VOICES; ++v)\n            if (c->voice_note[v] < 0 || !c->voice_gated[v]) { pick = v; break; }',
                    'for (v = JUNO_NUM_VOICES - 1; v >= 0; --v)\n            if (c->voice_note[v] < 0 || !c->voice_gated[v]) { pick = v; break; }')],
                  gate, tail=1500)
    b = run_tooth('seed_tap_constant',
                  [('src/delay_recall.c',
                    'JF(state, 4297792) = juno_curve(22, 255 * (rec[3056] & 0x7F) / 100);',
                    'JF(state, 4297792) = juno_curve(22, 127);')],
                  gate, tail=1500)
    return 0 if (a, b) == (0, 0) else 1


def main():
    a = sys.argv[1:]
    if a[:1] == ['--ref']:
        n = [int(x) for x in a[1:3]] if len(a) >= 3 else [N_LEGAL, N_WILD]
        return build_ref(n[0], n[1])
    if a[:1] == ['--port']:
        return check_port()
    if a[:1] == ['--tooth']:
        return tooth()
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
