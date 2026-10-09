#!/usr/bin/env python3
"""script_ab.py -- event-script audio A/Bs in two processes: CLAIMS A5 (a live TEMPO SYNC engage and
disengage under a held note, every factory patch) and A6 (the discrete DCO / LFO modes no factory
patch selects, on synthetic records). Task #62: their first scripts ran the plugin and the port in one
process (CLAUDE.md two-process rule), started the plugin from the enumerator-only recall (which omits
the extended cells the port recalls), and could not fail (exit 0 on a divergence).

Both sides run the same scenarios: a bank (the factory bank, or it with record bytes overwritten), a
patch, a rate, events ('on', note, vel) / ('off', note) / ('param', BINDINGS row, byte) / ('render',
n). The plugin's side starts from the proven complete recall (recall_render_ab.prepare_recall, the
start fuzz_diff.py uses) and dispatches a param to all 9 units, then snaps; the port's side starts
from juno_gui_apply_bank (arp off on the arp patches, as fuzz_diff.py) and calls juno_gui_set_param.
Every sample of both channels must be equal.

usage: script_ab.py --ref SET     the plugin's side -> scratchpad/script_ab_SET_ref.pkl (Unicorn only)
       script_ab.py --port SET    the port's side (libjuno only): exit 1 on any difference
SET: temposync (A5, 64 scenarios) | dco (A6, 210 scenarios)
"""
import os
import pickle
import struct
import sys
from array import array

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import refio                                  # noqa: E402  (the reference written whole or not at all)
from fuzz_diff import BLOBS, ARPS            # noqa: E402  (text constants: no port code is loaded)

# the factory bank's record layout (e2e_emu.HEADER / STRIDE / BLOB_OFF, asserted on the plugin's side)
HEADER, STRIDE, BLOB_OFF = 23, 20223, 16

TEMPO_SYNC_ROW = 24
DCO_BASE, DCO_NOTES = 5, (24, 36, 60, 84, 96)          # extremes force the DCO's phase-wrap branches
DISCRETE = [                                            # record byte, values (from the value tree's leaves)
    ("OSC2 WAVE", 36, (0, 1, 2, 3)), ("OSC2 RANGE", 42, (0, 1, 2, 3)), ("MIX SUB OSC TYPE", 60, (0, 1, 2, 3)),
    ("MIX NOISE TYPE", 62, (0, 1, 2, 3)), ("VCO ENV", 64, (0, 1, 2)), ("OCTAVE SHIFT", 322, (0, 1, 2, 3)),
    ("OSC3 WAVEFORM", 578, (0, 1, 2, 3)), ("LFO VARIATION", 530, (0, 1, 2)), ("LFO TRIG ENV", 538, (0, 1)),
    ("VCA MODE", 474, (0, 1, 2)), ("LFO PITCH IN", 354, (0, 1, 2)), ("LFO FILTER IN", 362, (0, 1, 2)),
    ("LFO AMP IN", 370, (0, 1, 2)),
]


def scenarios(name):
    """(label, rate, record edits [(record byte, value)], patch, events)"""
    if name == 'temposync':                 # A5: engage, then disengage, the note held across both flips
        return [('patch %2d' % p, 44100.0, (), p,
                 [('on', 60, 100), ('render', 2000), ('param', TEMPO_SYNC_ROW, 127), ('render', 8000),
                  ('param', TEMPO_SYNC_ROW, 0), ('render', 4000)]) for p in range(64)]
    if name == 'dco':                       # A6: patch 5 with one discrete record byte overwritten
        return [('%s=%d note %d' % (nm, v, n), 44100.0, ((rb, v),), DCO_BASE, [('on', n, 100), ('render', 3000)])
                for nm, rb, vals in DISCRETE for v in vals for n in DCO_NOTES]
    raise SystemExit('unknown set %r (temposync | dco)' % name)


def bank_with(base, edits, patch):
    b = bytearray(base)
    for rb, v in edits:
        off = HEADER + patch * STRIDE + BLOB_OFF + rb
        b[off] = (v >> 4) & 0xF                 # a record byte is two nibbles
        b[off + 1] = v & 0xF
    return bytes(b)


def ref_path(name):
    return os.path.join(REPO, 'scratchpad', 'script_ab_%s_ref.pkl' % name)


def build_ref(name):
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    assert (E.HEADER, E.STRIDE, E.BLOB_OFF) == (HEADER, STRIDE, BLOB_OFF)
    base, leaves = E.bank_bytes(), R.leaf_table()
    out = {}
    for label, rate, edits, patch, ev in scenarios(name):
        e = RR.prepare_recall(patch, bank_with(base, edits, patch), leaves, E, R, rate)
        L, Rr = [], []
        for x in ev:
            if x[0] == 'on':
                e.note_on(x[1], x[2])
            elif x[0] == 'off':
                e.note_off(x[1])
            elif x[0] == 'param':
                for u in range(9):
                    try:
                        e.dispatch(u, BLOBS[x[1]] + 744, x[2])
                    except RuntimeError:
                        pass
                e.snap_all()
            else:
                lb, rb = e.render(x[1])
                L += lb
                Rr += rb
        out[label] = (array('I', L).tobytes(), array('I', Rr).tobytes())
        del e
        print('  plugin: %s' % label, flush=True)
    refio.dump({'fmt': 1, 'set': name, 'runs': out}, ref_path(name))
    print('wrote %s: %d scenarios' % (os.path.relpath(ref_path(name), REPO), len(out)))
    return 0


def port_side(name):
    import ctypes
    import freshlib
    from truth import BANK
    p = ref_path(name)
    if not os.path.exists(p):
        raise SystemExit('no reference: run script_ab.py --ref %s first' % name)
    ref = pickle.load(open(p, 'rb'))['runs']
    lib = freshlib.load()
    for fn, rt, at in [
            ('juno_gui_create', ctypes.c_void_p, [ctypes.c_float, ctypes.c_int]),
            ('juno_gui_destroy', None, [ctypes.c_void_p]),
            ('juno_gui_apply_bank', None, [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
            ('juno_gui_arp_config', None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float, ctypes.c_float]),
            ('juno_gui_note_on', None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
            ('juno_gui_note_off', None, [ctypes.c_void_p, ctypes.c_int]),
            ('juno_gui_set_param', ctypes.c_float, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
            ('juno_gui_render', ctypes.c_int, [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int])]:
        getattr(lib, fn).restype = rt
        getattr(lib, fn).argtypes = at
    base = open(BANK, 'rb').read()
    bad = n = 0
    for label, rate, edits, patch, ev in scenarios(name):
        bank = bank_with(base, edits, patch)
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), patch)
        if patch in ARPS:
            lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)      # the port's arp off, as the engine-only oracle
        L, Rr = [], []
        for x in ev:
            if x[0] == 'on':
                lib.juno_gui_note_on(c, x[1], x[2])
            elif x[0] == 'off':
                lib.juno_gui_note_off(c, x[1])
            elif x[0] == 'param':
                lib.juno_gui_set_param(c, x[1], x[2])
            else:
                buf = (ctypes.c_float * (2 * x[1]))()
                lib.juno_gui_render(c, buf, x[1])
                inter = struct.unpack('<%dI' % (2 * x[1]), bytes(buf))
                L += inter[0::2]
                Rr += inter[1::2]
        lib.juno_gui_destroy(c)
        pl, pr = array('I'), array('I')
        pl.frombytes(ref[label][0])
        pr.frombytes(ref[label][1])
        n += 1
        first = next((i for i in range(min(len(pl), len(L))) if pl[i] != L[i] or pr[i] != Rr[i]), None)
        if len(pl) != len(L) or first is not None:
            bad += 1
            if first is None:
                print('DIFFER %s: length plugin %d port %d' % (label, len(pl), len(L)))
            else:
                print('DIFFER %s @ frame %d: plugin L %08x R %08x, port L %08x R %08x' % (
                    label, first, pl[first], pr[first], L[first], Rr[first]))
    print('script_ab %s: %d of %d scenarios bit-exact%s' % (name, n - bad, n, '' if not bad else ' -- %d DIFFER' % bad))
    return 1 if bad else 0


if __name__ == '__main__':
    a = sys.argv[1:]
    if len(a) == 2 and a[0] == '--ref':
        sys.exit(build_ref(a[1]))
    if len(a) == 2 and a[0] == '--port':
        sys.exit(port_side(a[1]))
    raise SystemExit(__doc__)
