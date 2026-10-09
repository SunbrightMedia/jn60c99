#!/usr/bin/env python3
"""notevel_exhaust.py -- CLAIMS A3: all 128 notes x 127 velocities through the plugin's own note-on,
state-level, against the port -- in two processes (CLAUDE.md two-process rule: the plugin's side
writes a reference, the port's side reads it; the first version ran both in one process).

For each (note, vel), vel 1..127 (vel 0 is a note-off on both sides): the plugin's note-on -> the one
voice whose cells changed -> its M.CV (304), VCF velocity (6864) and VCA velocity (9680) bits; the
port's juno_note_pitch(note), juno_curve(56, vel) and juno_curve(57, vel) must be the same bits. The
exhaustion is also the proof that no note x velocity cross term exists. 16256 events.

It is also the generator of the port's note table (src/juno_note.c juno_mcv_bits, task #62: its
first generator, a scratch probe, was never committed): --table prints the table from the
reference (every velocity of a note must give the same bits), --check-table compares it with the
source.

usage: notevel_exhaust.py --ref           the plugin's side -> scratchpad/notevel_ref.pkl (Unicorn only)
       notevel_exhaust.py                 the port's side (libjuno only): exit 1 on any difference
       notevel_exhaust.py --table         the C table, from the reference
       notevel_exhaust.py --check-table   exit 1 if src/juno_note.c's table differs from the reference
"""
import os
import pickle
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
REF = os.path.join(REPO, 'scratchpad', 'notevel_ref.pkl')
OFFS = (304, 6864, 9680)          # M.CV, VCF velocity, VCA velocity (per voice: + v * 10512)


def build_ref():
    sys.path.insert(0, HERE)
    import e2e_emu as E
    e = E.E2E()
    e.build(48000.0)
    e.snap_all()
    e.clear_latch()
    e.set_ftz()

    def cells():           # note-on broadcasts the voice cells to every unit: unit 0's state holds all 8
        st = e.state[0]
        return [tuple(e.rd_u32(st + o + v * 10512) for o in OFFS) for v in range(8)]

    out = {}
    prev = cells()
    for note in range(128):
        for vel in range(1, 128):
            e.note_on(note, vel)
            cur = cells()
            ch = [v for v in range(8) if cur[v] != prev[v]]
            out[(note, vel)] = (ch[0],) + cur[ch[0]] if len(ch) == 1 else ('voices', tuple(ch))
            e.note_off(note)
            prev = cells()
        if note % 16 == 15:
            print('  plugin: notes 0..%d' % note, flush=True)
    os.makedirs(os.path.dirname(REF), exist_ok=True)
    pickle.dump({'fmt': 1, 'events': out}, open(REF + '.partial', 'wb'))
    os.replace(REF + '.partial', REF)
    print('wrote %s: %d events' % (os.path.relpath(REF, REPO), len(out)))
    return 0


def load_ref():
    if not os.path.exists(REF):
        raise SystemExit('no reference: run notevel_exhaust.py --ref first')
    return pickle.load(open(REF, 'rb'))['events']


def mcv_table(ev):
    """note -> the M.CV bits every velocity of the note gave (refuses when they differ)"""
    tab = []
    for note in range(128):
        got = {ev[(note, vel)][1] for vel in range(1, 128) if ev[(note, vel)][0] != 'voices'}
        if len(got) != 1:
            raise SystemExit('note %d: the plugin gave %d different M.CV values over the velocities' % (note, len(got)))
        tab.append(got.pop())
    return tab


def table_text(tab):
    rows = ['    ' + ', '.join('0x%08xu' % b for b in tab[i:i + 6]) + ',' for i in range(0, 128, 6)]
    return 'static const unsigned int juno_mcv_bits[128] = {\n' + '\n'.join(rows) + '\n};'


def check_table(tab):
    s = open(os.path.join(REPO, 'src', 'juno_note.c')).read()
    a = s.index('juno_mcv_bits[128] = {')
    src = [int(x, 16) for x in re.findall(r'0x([0-9a-fA-F]{8})u', s[a:s.index('};', a)])]
    bad = [n for n in range(128) if n >= len(src) or src[n] != tab[n]]
    print('src/juno_note.c juno_mcv_bits: %s' % ('IDENTICAL to the plugin\'s note-on (128 notes)' if not bad and len(src) == 128
                                              else 'DIFFERS at notes %s' % bad[:10]))
    return 1 if bad or len(src) != 128 else 0


def port_side(ev):
    import ctypes
    lib = ctypes.CDLL(os.path.join(REPO, 'libjuno.so'))
    lib.juno_note_pitch.restype = ctypes.c_float
    lib.juno_note_pitch.argtypes = [ctypes.c_int]
    lib.juno_curve.restype = ctypes.c_float
    lib.juno_curve.argtypes = [ctypes.c_int, ctypes.c_int]
    bits = lambda x: struct.unpack('<I', struct.pack('<f', x))[0]
    bad = 0
    for note in range(128):
        mcv = bits(lib.juno_note_pitch(note))
        for vel in range(1, 128):
            r = ev[(note, vel)]
            if r[0] == 'voices':
                print('note %d vel %d: %d voices changed in the plugin (expect 1): %s' % (note, vel, len(r[1]), r[1]))
                bad += 1
                continue
            want = (mcv, bits(lib.juno_curve(56, vel)), bits(lib.juno_curve(57, vel)))
            if r[1:] != want:
                if bad < 20:
                    print('note %d vel %d voice %d: plugin %s port %s' % (note, vel, r[0], ['%08x' % x for x in r[1:]],
                                                                      ['%08x' % x for x in want]))
                bad += 1
    n = len(ev)
    print('NOTE x VELOCITY EXHAUSTION: %d identical / %d mismatched of %d' % (n - bad, bad, n))
    return 1 if bad else 0


def main():
    if '--ref' in sys.argv:
        return build_ref()
    ev = load_ref()
    if '--table' in sys.argv:
        print(table_text(mcv_table(ev)))
        return 0
    if '--check-table' in sys.argv:
        return check_table(mcv_table(ev))
    return port_side(ev)


if __name__ == '__main__':
    sys.exit(main())
