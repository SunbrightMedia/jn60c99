#!/usr/bin/env python3
"""rate_sweep_gate.py -- the whole post-recall state AND a render, at EVERY host
sample rate a VST3 host can ask for, plugin vs port (closes CLAIMS B4).

WHY IT EXISTS. CLAIMS B4 ledgered "rate arms cover 4 rates": the port carries
per-rate constant arms (chorus_recall.c, delay_recall.c, effect_modes.c,
finefx_recall.c, hpf_type_lut.c, juno_apply.c) for 44100 / 48000 / 88200 and
uses the 96000 arm for every other rate. Whether the PLUGIN does the same at
22050, 32000, 192000 or 50000 had never been executed. A host may ask for any
of them; "out of contract" was a ledger line, not a measurement.

REACH. The factory bank carries no EFFECT TYPE 0 or 4 and no DELAY TYPE 4
patch, so a factory-only sweep never runs those blocks' rate laws (the first
tooth of this gate, on EFFECT TYPE 4's 91120, did not bite for exactly that
reason -- playbook 103). SYNTH adds one-record banks for them: factory patch 0
with the type replaced, and DELAY TYPE 4 (the flanger block, CLAIMS B5) with
default and with non-default flanger leaves.

WHAT IT COMPARES, per rate R in RATES, per patch P in PATCHES + SYNTH:
  1. the WHOLE engine object (all 0xA83010 bytes of unit 0, zlib-compressed,
     ~14 KB a patch) after the plugin's OWN complete recall
     (recall_render_ab.prepare_recall) vs the port's juno_gui_apply_bank.
     NOT recall_fullstate_diff.REGIONS: that list skips part of the slot-1
     chorus block (6396128..6396352), so a DELAY TYPE 2/3 rate defect was
     invisible to the first version of this gate (playbook: an incomplete
     window is a blind gate);
  2. a short render through the master (note 60 vel 100, RENDER_N samples)
     for the render subset, bit for bit.
CONTROL FIRST (charter section 7): the C++ object header [0,176) holds
pointers and the two cells at/after the object end (>= 11022352) belong to
the plugin's heap neighbour; neither is engine state. They are reported as
CONTROL and excluded. Every other differing cell fails the gate.

TWO-PROCESS RULE: --ref imports the oracle only and writes
scratchpad/rate_sweep_ref.pkl; --port loads libjuno only and reads it.

TOOTH (--tooth, tools/verify/tooth_tree.py): a scratch copy of the tree where
EFFECT TYPE 3's chorus LFO rate law (91152, chorus_recall.c) is evaluated at
44100 whatever the host rate; --port there must FAIL at the other rates.

USAGE
    python3 tools/verify/rate_sweep_gate.py --ref [--resume] [RATE ...]
        (--resume keeps the records already in the pickle; plain --ref rebuilds
         the named rates, which the Makefile's staleness rule depends on)
    python3 tools/verify/rate_sweep_gate.py --port [RATE ...]
    python3 tools/verify/rate_sweep_gate.py --tooth
"""
import gc
import os
import sys
import pickle
import struct
from array import array

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
REF_PKL = os.path.join(SCRATCH, 'rate_sweep_ref.pkl')

# Every rate a common host offers, the four the arms name, and odd rates that
# only a formula can get right (a constant arm cannot be right at 47999 AND
# 48000 unless the plugin also switches on equality).
RATES = [8000.0, 11025.0, 16000.0, 22050.0, 32000.0, 37800.0, 44100.0,
         47999.0, 48000.0, 50000.0, 64000.0, 88200.0, 96000.0, 96001.0,
         176400.0, 192000.0, 352800.0, 384000.0]
PATCHES = list(range(64))
RENDER_PATCHES = [0, 2, 5, 10, 14, 21, 36, 44, 61]   # every DELAY TYPE class + UNISON
BANK_HEADER, STRIDE = 23, 20223
# name -> (factory base patch, {record offset: value}); a plain value is a
# nibble pair (int2x4), ('r', v) an int1x7 raw byte.
SYNTH = {'ET0': (0, {634: 0}),               # EFFECT TYPE 0 (Pan): no factory patch
         'ET4': (0, {634: 4}),               # EFFECT TYPE 4 (flanger chorus row): none
         'DT4': (0, {650: 4}),               # DELAY TYPE 4 (the flanger block): none
         'DT4x': (0, {650: 4, 3502: 77, 3504: 40, 3508: ('r', 9)})}  # + MANUAL/RESONANCE/LOW CUT


def synth_bank(bank, name):
    """A one-record bank: the base patch with SYNTH[name]'s nibble pairs set."""
    base, sets = SYNTH[name]
    rec = bytearray(bank[BANK_HEADER + base * STRIDE: BANK_HEADER + (base + 1) * STRIDE])
    for off, v in sets.items():
        if isinstance(v, tuple):
            rec[off] = v[1] & 0x7F
        else:
            rec[off] = (v >> 4) & 0xF
            rec[off + 1] = v & 0xF
    return bytes(bank[:BANK_HEADER]) + bytes(rec)


def cases(bank):
    """(key, bank, index, render?) for every factory patch and every SYNTH record."""
    out = [(p, bank, p, p in RENDER_PATCHES) for p in PATCHES]
    out += [(n, synth_bank(bank, n), 0, True) for n in SYNTH]
    return out
RENDER_N = 2048
HEADER = 176
OBJ_END = 0xA83010


def control(off):
    return off < HEADER or off >= OBJ_END


# ------------------------------------------------------------------- oracle
def build_ref(rates, resume=False):
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    import zlib
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    ref = pickle.load(open(REF_PKL, 'rb')) if os.path.exists(REF_PKL) else {}
    for rate in rates:
        per = dict(ref.get(rate, {})) if resume else {}
        for key, bk, idx, do_render in cases(bank):
            if key in per:
                continue
            e = RR.prepare_recall(idx, bk, leaves, E, R, rate)
            full = zlib.compress(bytes(e.uc.mem_read(e.state[0], OBJ_END)), 6)
            rend = None
            if do_render:
                e.note_on(60, 100)
                L, Rr = e.render(RENDER_N)
                rend = (array('I', L).tobytes(), array('I', Rr).tobytes())
            per[key] = (full, rend)
            # free the emulator NOW: Unicorn's native memory is invisible to
            # Python's GC thresholds, and 64 live instances per rate OOM-killed
            # the first run (exit 137)
            del e
            gc.collect()
        ref[rate] = per
        pickle.dump(ref, open(REF_PKL, 'wb'))
        sys.stderr.write('ref rate %g: %d records\n' % (rate, len(per)))
        sys.stderr.flush()
    print('wrote %s (%d rates)' % (REF_PKL, len(ref)))
    return 0


# --------------------------------------------------------------------- port
def check_port(rates):
    import ctypes
    sys.path.insert(0, HERE)
    import freshlib
    import zlib
    import numpy as np
    from truth import BANK
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_dump.restype = ctypes.c_int
    lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int,
                                  ctypes.c_char_p, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                    ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = open(BANK, 'rb').read()
    rates = rates or sorted(ref)
    fails = 0
    for rate in rates:
        if rate not in ref:
            print('rate %8g: NO REF' % rate)
            fails += 1
            continue
        bad_cells = {}
        ctl = set()
        bad_render = []
        n_render = 0
        want_keys = [k for k, _, _, _ in cases(bank)]
        missing = [k for k in want_keys if k not in ref[rate]]
        if missing:
            print('rate %8g: REF INCOMPLETE, missing %s -- run --ref' % (rate, missing))
            fails += 1
            continue
        for key, bk, idx, _ in cases(bank):
            full_z, rend = ref[rate][key]
            p = key
            want = np.frombuffer(zlib.decompress(full_z), dtype='<u4')
            c = lib.juno_gui_create(ctypes.c_float(rate), 0)
            lib.juno_gui_apply_bank(c, bk, len(bk), idx)
            buf = ctypes.create_string_buffer(OBJ_END)
            assert lib.juno_gui_dump(c, 0, buf, OBJ_END) == OBJ_END
            got = np.frombuffer(buf.raw, dtype='<u4')
            for w4 in np.nonzero(want != got)[0]:
                o = int(w4) * 4
                if control(o):
                    ctl.add(o)
                else:
                    bad_cells.setdefault(o, []).append((p, int(want[w4]), int(got[w4])))
            if rend is not None:
                n_render += 1
                lib.juno_gui_note_on(c, 60, 100)
                buf = (ctypes.c_float * (2 * RENDER_N))()
                lib.juno_gui_render(c, buf, RENDER_N)
                got = struct.unpack('<%dI' % (2 * RENDER_N), bytes(buf))
                La = array('I')
                La.frombytes(rend[0])
                Ra = array('I')
                Ra.frombytes(rend[1])
                first = next((i for i in range(RENDER_N)
                              if La[i] != got[2 * i] or Ra[i] != got[2 * i + 1]),
                             None)
                if first is not None:
                    bad_render.append((p, first))
            lib.juno_gui_destroy(c)
        ok = not bad_cells and not bad_render
        fails += 0 if ok else 1
        print('rate %8g: %s  cells differing %d (in %d records)  renders differing %d/%d'
              '  [control cells %d]'
              % (rate, 'OK  ' if ok else 'FAIL', len(bad_cells),
                 len({p for v in bad_cells.values() for p, _, _ in v}),
                 len(bad_render), n_render, len(ctl)))
        for o in sorted(bad_cells)[:12]:
            p, w, g = bad_cells[o][0]
            fw = struct.unpack('<f', struct.pack('<I', w))[0]
            fg = struct.unpack('<f', struct.pack('<I', g))[0]
            print('      cell %9d  e.g. record %-4s plugin %08x (%+.9g) port %08x (%+.9g)  [%d records]'
                  % (o, p, w, fw, g, fg, len(bad_cells[o])))
        if len(bad_cells) > 12:
            print('      ... %d more cells' % (len(bad_cells) - 12))
        for p, first in bad_render[:4]:
            print('      render record %-4s first differs at sample %d' % (p, first))
    print('\n=== RATE SWEEP (CLAIMS B4): %d rates, %d failed ===' % (len(rates), fails))
    print('GATE: %s' % ('FAIL' if fails else 'PASS'))
    return 1 if fails else 0


# -------------------------------------------------------------------- tooth
def tooth():
    """The 44100 value of a rate law applied at EVERY rate (the old 4-arm
    defect class, in law form): EFFECT TYPE 3's chorus LFO rate 91152 (22
    factory patches) computed for 44100 whatever the host rate. --port must
    FAIL at the other rates. (The first tooth mutated EFFECT TYPE 4's 91120,
    which no factory patch reaches, and did not bite: playbook 103.)"""
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    return run_tooth('rate_sweep_44100_everywhere',
                     [('src/chorus_recall.c',
                       'JF(state, 91152) = rl_chorus_mode_rate(1, Hr);',
                       'JF(state, 91152) = rl_chorus_mode_rate(1, 44100);')],
                     ['tools/verify/rate_sweep_gate.py', '--port'], tail=4000)


def main():
    a = sys.argv[1:]
    rates = [float(x) for x in a[1:] if x != '--resume']
    if a[:1] == ['--ref']:
        return build_ref(rates or RATES, '--resume' in a)
    if a[:1] == ['--port']:
        return check_port(rates)
    if a[:1] == ['--tooth']:
        return tooth()
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
