#!/usr/bin/env python3
"""effect_param_gate.py -- EFFECT DEPTH and EFFECT TONE at every byte, in every
EFFECT TYPE, at three host rates: the plugin's own setter vs the port's recall.

WHY IT EXISTS (2026-10-05). The B4 rate sweep found cell 96352 (EFFECT TYPE 5
LFO rate) one ULP off at 96001 Hz. Sweeping the plugin's EFFECT TONE setter over
all 256 bytes then showed the port's law ("96 kHz LUT x 96000/H in double") was
wrong for 65..72 tone bytes at EVERY rate, 44.1 kHz included: the factory bank
uses a handful of tone values, recall_exhaustive_gate covers voice-0 cells only,
and finefx_pillar3_gate covers the fine-FX leaves only. No gate swept the EFFECT
leaves. This one does.

WHAT IT COMPARES. Context ETk = factory patch 0's record with EFFECT TYPE = k
(k = 0..5). Per (rate, context, leaf, byte v):
  plugin: one engine, the plugin's OWN complete recall of the context record,
          then dispatch(leaf, v) on all 9 units + snap (the recall drive every
          gate uses); after a leaf's sweep its base value is dispatched back.
  port:   juno_gui_apply_bank of the context record with the leaf's byte = v.
The cells compared are every word of the whole object that ANY byte of the
sweep changes on the PLUGIN side (anti-circularity: the port never chooses
its own cells), exactly like finefx_pillar3_gate.py.

DIRECT RECALL (part 2). Part 1 assumes "recall the context, then dispatch
the byte" equals "recall the record that carries the byte". Whether the
plugin's recall sets EFFECT TYPE before EFFECT DEPTH (the DEPTH setter
switches on the type in force) is exactly what that assumption hides. So for
SPOT bytes the plugin does a fresh COMPLETE recall of the record with the
byte in it, and the WHOLE engine object (minus the control cells: C++ header
[0,176)) is compared, plus a render through the master for RENDER_V bytes.

CONTEXTS include EFFECT TYPE 6 and 255: out of range, the plugin stores no
type (effect_modes.c), so the type in force is the power-on one.

TWO-PROCESS RULE: --ref (Unicorn only) -> scratchpad/effect_param_ref.pkl;
--port (libjuno only) reads it. --ref rebuilds from nothing (the Makefile's
staleness rule depends on that); --ref --resume keeps the keys already there.

TOOTH (--tooth): three named defects through tools/verify/tooth_tree.py, each
must FAIL --port: (a) the DEPTH law of types 0/1 replaced by the 2..5
switch (the 2026-08-25 state); (b) the EFFECT TONE -> 96352 slope one ULP off;
(c) an out-of-range type running the type-5 arms (the old clamp to 5).

USAGE
    python3 tools/verify/effect_param_gate.py --ref [--resume] | --port | --tooth
"""
import gc
import os
import sys
import pickle
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
REF_PKL = os.path.join(SCRATCH, 'effect_param_ref.pkl')

RATES = [44100.0, 32000.0, 96001.0]
CONTEXTS = [0, 1, 2, 3, 4, 5, 6, 255]      # EFFECT TYPE 0..5 + two out of range
SPOT = [0, 1, 2, 3, 31, 32, 63, 64, 65, 127, 128, 200, 254, 255]
RENDER_V = (1, 32, 63, 255)
RENDER_N = 2048
HEADER_CTL = 176                            # C++ object header: pointers, control
HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
BANK_LEN = HEADER + STRIDE
OBJ_END = 0xA83010
BASE_PATCH = 0
# leaf: (dispatch index, record offset of the nibble pair)
LEAVES = {'EFFECT DEPTH': (794, BLOB_OFF + 100), 'EFFECT TONE': (874, 642)}
TYPE_ROFF = 634                             # EFFECT TYPE nibble pair (dispatch 873)


def nib_get(rec, off):
    return ((rec[off] & 0xF) << 4) | (rec[off + 1] & 0xF)


def nib_set(rec, off, v):
    rec[off] = (v >> 4) & 0xF
    rec[off + 1] = v & 0xF


def context_bank(bank, k, leaf_off=None, v=None):
    """A one-record bank: factory patch BASE_PATCH with EFFECT TYPE = k (and one
    leaf byte replaced, for the port side)."""
    rec = bytearray(bank[HEADER + BASE_PATCH * STRIDE: HEADER + (BASE_PATCH + 1) * STRIDE])
    nib_set(rec, TYPE_ROFF, k)
    if leaf_off is not None:
        nib_set(rec, leaf_off, v)
    return bytes(bank[:HEADER]) + bytes(rec)


def load_ref():
    if not os.path.exists(REF_PKL):
        return {'sweep': {}, 'direct': {}}
    ref = pickle.load(open(REF_PKL, 'rb'))
    if 'sweep' not in ref:                  # the first version stored the sweeps flat
        ref = {'sweep': ref, 'direct': {}}
    return ref


def build_ref(resume=False):
    import zlib
    from array import array
    import numpy as np
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    bank = E.bank_bytes()
    leaves_tab = R.leaf_table()
    ref = load_ref() if resume else {'sweep': {}, 'direct': {}}
    for rate in RATES:
        for k in CONTEXTS:
            # part 1: one engine per context, every byte dispatched
            if any((rate, k, n) not in ref['sweep'] for n in LEAVES):
                cb = context_bank(bank, k)
                e = RR.prepare_recall(0, cb, leaves_tab, E, R, rate)
                rec = cb[HEADER:]
                for name, (disp, roff) in LEAVES.items():
                    base = nib_get(rec, roff)
                    hist = {}
                    a0 = None
                    for v in range(256):
                        e.dispatch_all(disp, v)
                        e.snap_all()
                        av = np.frombuffer(bytes(e.uc.mem_read(e.state[0], OBJ_END)), dtype='<u4')
                        if a0 is None:
                            a0 = av.copy()
                        # keep only words that change; a word first seen changing at
                        # byte v held a0's value for every earlier byte
                        for w in np.nonzero(av != a0)[0]:
                            w = int(w)
                            if w not in hist:
                                hist[w] = [int(a0[w])] * v
                        for w, h in hist.items():
                            h.append(int(av[w]))
                    ref['sweep'][(rate, k, name)] = {w * 4: h for w, h in sorted(hist.items())}
                    e.dispatch_all(disp, base)        # restore the base value
                    e.snap_all()
                    sys.stderr.write('ref %g ET%d %-12s %d cells\n'
                                     % (rate, k, name, len(ref['sweep'][(rate, k, name)])))
                    sys.stderr.flush()
                del e
                gc.collect()
            # part 2: a fresh complete recall per (leaf, spot byte)
            for name, (disp, roff) in LEAVES.items():
                for v in SPOT:
                    key = (rate, k, name, v)
                    if key in ref['direct']:
                        continue
                    e = RR.prepare_recall(0, context_bank(bank, k, roff, v), leaves_tab, E, R, rate)
                    full = zlib.compress(bytes(e.uc.mem_read(e.state[0], OBJ_END)), 6)
                    rend = None
                    if v in RENDER_V:
                        e.note_on(60, 100)
                        L, Rr = e.render(RENDER_N)
                        rend = (array('I', L).tobytes(), array('I', Rr).tobytes())
                    ref['direct'][key] = (full, rend)
                    del e
                    gc.collect()
                sys.stderr.write('ref %g ET%d %-12s direct %d bytes\n' % (rate, k, name, len(SPOT)))
                sys.stderr.flush()
            os.makedirs(SCRATCH, exist_ok=True)
            pickle.dump(ref, open(REF_PKL, 'wb'))
    print('wrote %s (%d sweeps, %d direct recalls)'
          % (REF_PKL, len(ref['sweep']), len(ref['direct'])))
    return 0


def check_port():
    import ctypes
    import zlib
    from array import array
    import numpy as np
    sys.path.insert(0, HERE)
    import freshlib
    from truth import BANK
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = load_ref()
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_dump.restype = ctypes.c_int
    lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int,
                                  ctypes.c_char_p, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                    ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = open(BANK, 'rb').read()
    fails = 0
    total = 0
    missing = [(r, k, n) for r in RATES for k in CONTEXTS for n in LEAVES
               if (r, k, n) not in ref['sweep']]
    missing += [(r, k, n, v) for r in RATES for k in CONTEXTS for n in LEAVES for v in SPOT
                if (r, k, n, v) not in ref['direct']]
    if missing:
        print('REF INCOMPLETE: %d keys missing, e.g. %r -- run --ref' % (len(missing), missing[0]))
        return 2
    print('--- part 1: every byte dispatched on a recalled context ---')
    for (rate, k, name), cells in sorted(ref['sweep'].items()):
        disp, roff = LEAVES[name]
        bad = 0
        first = None
        for v in range(256):
            cb = context_bank(bank, k, roff, v)
            c = lib.juno_gui_create(ctypes.c_float(rate), 0)
            lib.juno_gui_apply_bank(c, cb, len(cb), 0)
            for off, vals in cells.items():
                total += 1
                g = lib.juno_gui_peek(c, off)
                if g != vals[v]:
                    bad += 1
                    if first is None:
                        first = (v, off, vals[v], g)
            lib.juno_gui_destroy(c)
        if bad:
            fails += 1
            v, off, w, g = first
            print('%7g ET%-3d %-12s %3d cells  RED %d mismatches, first byte %d cell %d plugin %08x port %08x'
                  % (rate, k, name, len(cells), bad, v, off, w, g))
        else:
            print('%7g ET%-3d %-12s %3d cells  OK' % (rate, k, name, len(cells)))
    print('--- part 2: fresh complete recall of the record, whole object + render ---')
    groups = {}
    for (rate, k, name, v), (full_z, rend) in sorted(ref['direct'].items()):
        disp, roff = LEAVES[name]
        want = np.frombuffer(zlib.decompress(full_z), dtype='<u4')
        cb = context_bank(bank, k, roff, v)
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(c, cb, len(cb), 0)
        buf = ctypes.create_string_buffer(OBJ_END)
        assert lib.juno_gui_dump(c, 0, buf, OBJ_END) == OBJ_END
        got = np.frombuffer(buf.raw, dtype='<u4')
        diff = [int(w) * 4 for w in np.nonzero(want != got)[0] if int(w) * 4 >= HEADER_CTL]
        total += len(want) - HEADER_CTL // 4
        g = groups.setdefault((rate, k, name), {'bad': [], 'rend': [], 'n': 0})
        g['n'] += 1
        if diff:
            o = diff[0]
            g['bad'].append((v, len(diff), o, int(want[o // 4]), int(got[o // 4])))
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
    for (rate, k, name), g in sorted(groups.items()):
        if g['bad'] or g['rend']:
            fails += 1
            msg = '%7g ET%-3d %-12s %2d recalls  RED' % (rate, k, name, g['n'])
            if g['bad']:
                v, n, o, w, p = g['bad'][0]
                msg += '  %d bytes differ in state (byte %d: %d cells, first %d plugin %08x port %08x)' \
                       % (len(g['bad']), v, n, o, w, p)
            if g['rend']:
                msg += '  renders differ at bytes %s' % [v for v, _ in g['rend']]
            print(msg)
        else:
            print('%7g ET%-3d %-12s %2d recalls  OK (whole object; renders %s)'
                  % (rate, k, name, g['n'], list(RENDER_V)))
    print('\n=== EFFECT PARAMS (DEPTH, TONE) x EFFECT TYPE %s x %d rates: '
          '%d comparisons, %d groups red ===' % (CONTEXTS, len(RATES), total, fails))
    print('GATE: %s' % ('FAIL' if fails else 'PASS'))
    return 1 if fails else 0


def tooth():
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    gate = ['tools/verify/effect_param_gate.py', '--port']
    # (a) types 0/1 take the 2..5 switch (the 2026-08-25 state of 84544)
    a = run_tooth('effect_depth_switch',
                  [('src/effect_modes.c', '    if (t <= 1) {\n        JF(state, 84544)',
                    '    if (t < 0) {\n        JF(state, 84544)')], gate)
    # (b) the EFFECT TONE -> 96352 slope one ULP off
    b = run_tooth('effect_tone_ulp',
                  [('src/effect_modes.c', 'efx_bits(0x3ffbbcd3u)', 'efx_bits(0x3ffbbcd4u)')], gate)
    # (c) an out-of-range type runs the type-5 arms (the old clamp)
    c = run_tooth('effect_type_clamp',
                  [('src/effect_modes.c', '    if (etype > 5)\n        return;',
                    '    if (etype > 5)\n        etype = 5;')], gate)
    return 0 if (a, b, c) == (0, 0, 0) else 1


def main():
    a = sys.argv[1:]
    if a[:1] == ['--ref']:
        return build_ref(resume='--resume' in a)
    if a[:1] == ['--port']:
        return check_port()
    if a[:1] == ['--tooth']:
        return tooth()
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
