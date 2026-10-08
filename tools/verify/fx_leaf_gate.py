#!/usr/bin/env python3
"""fx_leaf_gate.py -- every byte of every leaf an FX block reads, in the context
that activates the block, at three host rates: the plugin vs the port.

effect_param_gate.py did this for EFFECT DEPTH/TONE and found three defects no
factory-patch gate could see. This is the same method as a table of SUITES, so
the next block is a few lines, not a new tool. A suite names:
  contexts : one-record banks = a factory base patch with some leaves forced
             (e.g. DELAY TYPE 4, which no factory patch uses);
  leaves   : (dispatch index, record offset, kind) -- kind 'n' = nibble pair
             (int2x4, or the low byte of an int8x4), 'r' = int1x7 raw byte;
  spot     : bytes recalled fresh in part 2.

PART 1 (single-leaf dispatch). NOT A PLUGIN PATH since 2026-10-06 (CLAIMS A20):
a host's live parameter change goes through the host entry rva 0x3C7AE0 with
flag 0, which tools/verify/host_edit_gate.py drives; this part dispatches ONE
leaf in the recall role (flag 1) + snap, which no host does. Kept for its cell
census; make verify runs --recall-only. Its DELAY LEVEL 0/1 reds under DELAY
TYPE 4 are that difference (the port's host path is bit-exact there).
The plugin's own complete recall of the context, then the
leaf dispatched at every byte (+ snap), as a host's live parameter change does;
every word ANY byte changes is graded (the plugin chooses the cells, never the
port). Port: its live path for these leaves -- the context recalled, then the
record with the leaf's byte recalled again on the same engine (what
juno_gui_host_set does). A part-1 red where part 2 is green is a LIVE-path
defect (the plugin's setter does more than a recall), not a recall defect.
PART 2 (fresh recall). For the spot bytes, a fresh complete recall of the
record that carries the byte: the WHOLE object (minus the C++ header) and a
render through the master. This is the half that sees recall-order effects.

TWO-PROCESS RULE: --ref (Unicorn only) writes scratchpad/fx_leaf_<suite>_ref.pkl;
--port (libjuno only) reads it. --ref rebuilds; --ref --resume keeps keys.

USAGE
    python3 tools/verify/fx_leaf_gate.py --ref  SUITE [--resume]
    python3 tools/verify/fx_leaf_gate.py --port SUITE [--recall-only]
        (--recall-only grades part 2 alone: the recall claim, not the live one) [--partial]
        (--partial grades only the rates the reference holds; it never passes)
    python3 tools/verify/fx_leaf_gate.py --tooth SUITE   (each named defect must FAIL the recall half)
    python3 tools/verify/fx_leaf_gate.py --list
"""
import gc
import os
import sys
import pickle
import refio
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')

HEADER, STRIDE = 23, 20223
OBJ_END = 0xA83010
HEADER_CTL = 176                 # C++ object header: pointers, control
RATES = [44100.0, 32000.0, 96001.0]
RENDER_N = 2048

# --------------------------------------------------------------------- suites
# DELAY TYPE 4 = the flanger block (processor +7616, sCDSPSystem8DlyFlSt). Its
# leaves: DELAY LEVEL/TIME/TEMPO SYNC and the delay fine leaves (the DELAY TYPE
# setter replays all of them into the new block), and the seven flanger leaves.
FLANGER = {
    'contexts': {'p0_DT4': (0, {650: ('n', 4)}),
                 'p4_DT4': (4, {650: ('n', 4)})},
    'leaves': {'DELAY LEVEL': (796, 120, 'n'), 'DELAY TIME': (797, 122, 'n'),
               'TEMPO SYNC': (803, 134, 'n'),
               'DELAY TAP TIME': (1178, 3056, 'r'), 'DELAY FEEDBACK': (1179, 3057, 'n'),
               'DELAY HIGH CUT': (1180, 3059, 'r'), 'DELAY DIRECT': (1181, 3060, 'n'),
               'DELAY LF DAMP': (1182, 3068, 'n'), 'DELAY LF DAMP FREQ': (1183, 3076, 'n'),
               'DELAY HF DAMP': (1184, 3084, 'n'), 'DELAY HF DAMP FREQ': (1185, 3092, 'n'),
               'FLANGER MANUAL': (1242, 3502, 'n'), 'FLANGER RESONANCE': (1243, 3504, 'n'),
               'FLANGER SEPARATION': (1244, 3506, 'n'), 'FLANGER LOW CUT': (1245, 3508, 'r'),
               'FLANGER LFO SOURCE': (1246, 3509, 'r'), 'FLANGER EXT GAIN': (1247, 3510, 'n'),
               'FLANGER EXT OFFSET': (1248, 3512, 'n')},
    'spot': [0, 1, 2, 3, 17, 18, 63, 64, 127, 128, 255],
    'spot_leaves': ['DELAY LEVEL', 'DELAY TIME', 'FLANGER MANUAL', 'FLANGER RESONANCE',
                    'FLANGER LOW CUT'],
    'render_v': (1, 64, 255),
    # named defects; each must make `--port flanger --recall-only` FAIL
    'teeth': [
        ('flanger_manual_unflipped', [('src/delay_recall.c',
            'juno_curve(19, 255 - manual)', 'juno_curve(19, manual)')]),
        ('flanger_time_old_fit', [('src/delay_recall.c',
            '(1.0f - juno_curve(22, dtime)) * -12.0f', '-(12.0f - ((float)dtime * (1.0f / 255.0f)) * 12.0f)')]),
        ('flanger_lowcut_no_rate_law', [('src/delay_recall.c',
            'rl_scale96f(juno_curve(65, lowcut > 0 ? lowcut - 1 : 0), Hr)',
            'rl_scale96f(juno_curve(65, lowcut > 0 ? lowcut - 1 : 0), 48000)')]),
    ],
}
SUITES = {'flanger': FLANGER}


def ref_pkl(suite):
    return os.path.join(SCRATCH, 'fx_leaf_%s_ref.pkl' % suite)


def put(rec, off, kind, v):
    if kind == 'r':
        rec[off] = v & 0x7F
    else:
        rec[off] = (v >> 4) & 0xF
        rec[off + 1] = v & 0xF


def get(rec, off, kind):
    return (rec[off] & 0x7F) if kind == 'r' else ((rec[off] & 0xF) << 4) | (rec[off + 1] & 0xF)


def nbytes(kind):
    return 128 if kind == 'r' else 256


def context_bank(bank, S, ctx, leaf=None, v=None):
    """A one-record bank: the context's base patch with its forced leaves (and one
    leaf byte replaced, for the port and for part 2)."""
    base, sets = S['contexts'][ctx]
    rec = bytearray(bank[HEADER + base * STRIDE: HEADER + (base + 1) * STRIDE])
    for off, (kind, val) in sets.items():
        put(rec, off, kind, val)
    if leaf is not None:
        _d, off, kind = S['leaves'][leaf]
        put(rec, off, kind, v)
    return bytes(bank[:HEADER]) + bytes(rec)


# ------------------------------------------------------------------- oracle
def build_ref(suite, resume=False):
    import zlib
    from array import array
    import numpy as np
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    S = SUITES[suite]
    bank = E.bank_bytes()
    lt = R.leaf_table()
    ref = pickle.load(open(ref_pkl(suite), 'rb')) if (resume and os.path.exists(ref_pkl(suite))) \
        else {'sweep': {}, 'direct': {}}
    for rate in RATES:
        for ctx in S['contexts']:
            if any((rate, ctx, n) not in ref['sweep'] for n in S['leaves']):
                cb = context_bank(bank, S, ctx)
                e = RR.prepare_recall(0, cb, lt, E, R, rate)
                rec = cb[HEADER:]
                for name, (disp, off, kind) in S['leaves'].items():
                    if (rate, ctx, name) in ref['sweep']:
                        continue
                    base = get(rec, off, kind)
                    hist = {}
                    a0 = None
                    for v in range(nbytes(kind)):
                        for u in range(9):
                            try: e.dispatch(u, disp, v)
                            except RuntimeError: pass
                        e.snap_all()
                        av = np.frombuffer(bytes(e.uc.mem_read(e.state[0], OBJ_END)), dtype='<u4')
                        if a0 is None:
                            a0 = av.copy()
                        for w in np.nonzero(av != a0)[0]:
                            w = int(w)
                            if w not in hist:
                                hist[w] = [int(a0[w])] * v
                        for w, h in hist.items():
                            h.append(int(av[w]))
                    ref['sweep'][(rate, ctx, name)] = {w * 4: h for w, h in sorted(hist.items())}
                    for u in range(9):            # restore the base value
                        try: e.dispatch(u, disp, base)
                        except RuntimeError: pass
                    e.snap_all()
                    sys.stderr.write('ref %g %s %-20s %d cells\n'
                                     % (rate, ctx, name, len(ref['sweep'][(rate, ctx, name)])))
                    sys.stderr.flush()
                del e
                gc.collect()
            for name in S['spot_leaves']:
                _d, off, kind = S['leaves'][name]
                for v in S['spot']:
                    if v >= nbytes(kind):
                        continue
                    key = (rate, ctx, name, v)
                    if key in ref['direct']:
                        continue
                    e = RR.prepare_recall(0, context_bank(bank, S, ctx, name, v), lt, E, R, rate)
                    full = zlib.compress(bytes(e.uc.mem_read(e.state[0], OBJ_END)), 6)
                    rend = None
                    if v in S['render_v']:
                        e.note_on(60, 100)
                        L, Rr = e.render(RENDER_N)
                        rend = (array('I', L).tobytes(), array('I', Rr).tobytes())
                    ref['direct'][key] = (full, rend)
                    del e
                    gc.collect()
                sys.stderr.write('ref %g %s %-20s direct\n' % (rate, ctx, name))
                sys.stderr.flush()
            os.makedirs(SCRATCH, exist_ok=True)
            refio.dump(ref, ref_pkl(suite))
    print('wrote %s (%d sweeps, %d direct recalls)'
          % (ref_pkl(suite), len(ref['sweep']), len(ref['direct'])))
    return 0


# --------------------------------------------------------------------- port
def check_port(suite, partial=False, recall_only=False):
    import ctypes
    import zlib
    from array import array
    import numpy as np
    sys.path.insert(0, HERE)
    import freshlib
    from truth import BANK
    S = SUITES[suite]
    if not os.path.exists(ref_pkl(suite)):
        print('MISSING %s -- run --ref %s first' % (ref_pkl(suite), suite))
        return 2
    ref = pickle.load(open(ref_pkl(suite), 'rb'))
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_dump.restype = ctypes.c_int
    lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = open(BANK, 'rb').read()
    rates = RATES
    if partial:        # only the rates the reference already holds completely
        rates = [r for r in RATES if all((r, c, n) in ref['sweep']
                                         for c in S['contexts'] for n in S['leaves'])]
        print('PARTIAL: rates %s only -- not a verdict on the suite' % rates)
    want_sweeps = [(r, c, n) for r in rates for c in S['contexts'] for n in S['leaves']]
    want_direct = [(r, c, n, v) for r in rates for c in S['contexts'] for n in S['spot_leaves']
                   for v in S['spot'] if v < nbytes(S['leaves'][n][2])]
    missing = [k for k in want_sweeps if k not in ref['sweep']]
    missing += [k for k in want_direct if k not in ref['direct']]
    if missing:
        print('REF INCOMPLETE: %d keys missing, e.g. %r -- run --ref %s' % (len(missing), missing[0], suite))
        return 2
    fails = 0
    total = 0
    if recall_only:
        want_sweeps = []
        print('RECALL ONLY: part 1 (live edit) not graded')
    print('--- part 1: every byte dispatched on a recalled context (live edit) ---')
    for key in want_sweeps:
        rate, ctx, name = key
        cells = ref['sweep'][key]
        _d, off, kind = S['leaves'][name]
        bad = 0
        first = None
        base_cb = context_bank(bank, S, ctx)
        for v in range(nbytes(kind)):
            cb = context_bank(bank, S, ctx, name, v)
            c = lib.juno_gui_create(ctypes.c_float(rate), 0)
            lib.juno_gui_apply_bank(c, base_cb, len(base_cb), 0)   # the context
            lib.juno_gui_apply_bank(c, cb, len(cb), 0)             # the live edit
            for o, vals in cells.items():
                total += 1
                g = lib.juno_gui_peek(c, o)
                if g != vals[v]:
                    bad += 1
                    if first is None:
                        first = (v, o, vals[v], g)
            lib.juno_gui_destroy(c)
        if bad:
            fails += 1
            v, o, w, g = first
            print('%7g %-7s %-20s %3d cells  RED %d mismatches, first byte %d cell %d plugin %08x port %08x'
                  % (rate, ctx, name, len(cells), bad, v, o, w, g))
        else:
            print('%7g %-7s %-20s %3d cells  OK' % (rate, ctx, name, len(cells)))
    print('--- part 2: fresh complete recall of the record, whole object + render ---')
    groups = {}
    for key in want_direct:
        rate, ctx, name, v = key
        full_z, rend = ref['direct'][key]
        want = np.frombuffer(zlib.decompress(full_z), dtype='<u4')
        cb = context_bank(bank, S, ctx, name, v)
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(c, cb, len(cb), 0)
        buf = ctypes.create_string_buffer(OBJ_END)
        assert lib.juno_gui_dump(c, 0, buf, OBJ_END) == OBJ_END
        got = np.frombuffer(buf.raw, dtype='<u4')
        diff = [int(w) * 4 for w in np.nonzero(want != got)[0] if int(w) * 4 >= HEADER_CTL]
        total += len(want) - HEADER_CTL // 4
        g = groups.setdefault((rate, ctx, name), {'bad': [], 'rend': [], 'n': 0})
        g['n'] += 1
        if diff:
            o = diff[0]
            g['bad'].append((v, len(diff), o, int(want[o // 4]), int(got[o // 4]), diff[:8]))
        if rend is not None:
            lib.juno_gui_note_on(c, 60, 100)
            fb = (ctypes.c_float * (2 * RENDER_N))()
            lib.juno_gui_render(c, fb, RENDER_N)
            pg = struct.unpack('<%dI' % (2 * RENDER_N), bytes(fb))
            La = array('I')
            La.frombytes(rend[0])
            Ra = array('I')
            Ra.frombytes(rend[1])
            first = next((i for i in range(RENDER_N)
                          if La[i] != pg[2 * i] or Ra[i] != pg[2 * i + 1]), None)
            if first is not None:
                g['rend'].append((v, first))
        lib.juno_gui_destroy(c)
    for (rate, ctx, name), g in sorted(groups.items()):
        if g['bad'] or g['rend']:
            fails += 1
            msg = '%7g %-7s %-20s %2d recalls  RED' % (rate, ctx, name, g['n'])
            if g['bad']:
                v, n, o, w, p, cells = g['bad'][0]
                msg += '  %d bytes differ in state (byte %d: %d cells %s; first plugin %08x port %08x)' \
                       % (len(g['bad']), v, n, cells, w, p)
            if g['rend']:
                msg += '  renders differ at bytes %s' % [v for v, _ in g['rend']]
            print(msg)
        else:
            print('%7g %-7s %-20s %2d recalls  OK (whole object; renders %s)'
                  % (rate, ctx, name, g['n'], list(S['render_v'])))
    print('\n=== FX LEAVES [%s]: %d leaves x %d contexts x %d rates: %d comparisons, %d groups red ==='
          % (suite, len(S['leaves']), len(S['contexts']), len(RATES), total, fails))
    print('GATE: %s' % ('FAIL' if fails else 'PASS'))
    return 1 if fails else 0


def tooth(suite):
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    rcs = [run_tooth(name, edits, ['tools/verify/fx_leaf_gate.py', '--port', suite, '--recall-only'])
           for name, edits in SUITES[suite]['teeth']]
    return 0 if rcs and all(r == 0 for r in rcs) else 1


def main():
    a = sys.argv[1:]
    if a[:1] == ['--list']:
        for n, S in SUITES.items():
            print('%s: %d leaves, contexts %s' % (n, len(S['leaves']), list(S['contexts'])))
        return 0
    if len(a) >= 2 and a[1] in SUITES:
        if a[0] == '--ref':
            return build_ref(a[1], '--resume' in a)
        if a[0] == '--tooth':
            return tooth(a[1])
        if a[0] == '--port':
            rc = check_port(a[1], '--partial' in a, '--recall-only' in a)
            return 2 if ('--partial' in a and rc == 0) else rc
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
