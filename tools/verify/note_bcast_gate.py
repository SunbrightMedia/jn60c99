#!/usr/bin/env python3
"""note_bcast_gate.py -- every voice's WHOLE state after every note event,
plugin vs port (closes CLAIMS B3).

WHY IT EXISTS. CLAIMS B3 ledgered "broadcast flags 1856/1488/1840: the plugin
writes all 8 voices, the port writes the gated voice". The port has broadcast
cell 1856 since juno_note_broadcast_held() (src/juno_note.c), and 1840/1488 are
derived from 1856 by voice_render on every voice every sample. But no gate
compared those cells on the voices a note did NOT land on: render A/B and fuzz
compare audio, and an idle voice is enveloped to silence, so a wrong flag on it
is invisible until that voice is gated later (how the arp found it). A ledger
row that says "inert" without a gate that can see the cell is a claim, not a
proof. This gate sees it.

WHAT IT COMPARES, after EVERY event (zero-render note events included):
  for each voice v = 0..7, from the PLUGIN UNIT THAT RENDERS v (unit v; the
  plugin renders voice v at state[v] + v*10512, docs/HISTORY.md):
    main block   [176 + v*10512, 176 + (v+1)*10512)   2628 cells
    aux pair     [101488 + v*32, +32)                  8 cells: Array B
                 (+0, the note-on flag) and Array A (+16, the DCO retrigger
                 latch 101504 + v*32)
    shared block [84272, 84436)                        41 cells (unit v's copy)
  against the same offsets of the port's single state. 21,416 cells per
  checkpoint; any differing cell fails the gate.

SCENARIOS: a hand-written chord / partial-release / full-release / re-gate
sequence; a steal that leaves a key held with no voice (the 1856 law is "a voice
still gated", not "a key held": rva 0x3B1C58, the gate leaf; the two differ only
there -- the seeds below never hold more keys than voices); plus seeded random sequences
(up to 6 held notes, render chunks 1..600 samples, three rates, non-arp
patches). Seeds are reproducible; a failing seed is a regression script.

TWO-PROCESS RULE: --ref imports the Unicorn oracle only and writes
scratchpad/note_bcast_ref.pkl; --port loads libjuno only and reads it.

TOOTH (--tooth): copies the tree to a scratch directory, makes
juno_note_broadcast_held() a no-op (the pre-fix defect: only the allocated
voice gets 1856), builds THAT libjuno.so, and runs --port there against the
same reference. The gate is believed only if the tooth run FAILS.

USAGE
    python3 tools/verify/note_bcast_gate.py --ref
    python3 tools/verify/note_bcast_gate.py --port
    python3 tools/verify/note_bcast_gate.py --tooth
"""
import os
import sys
import pickle
import refio
import random
import struct
import shutil
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
REF_PKL = os.path.join(SCRATCH, 'note_bcast_ref.pkl')

STRIDE = 10512
MAIN0 = 176
AUX0, AUXN = 101488, 32      # Array B at +0, Array A (101504+v*32) at +16
SHARED0, SHAREDN = 84272, 164
ARPS = {1, 9, 17, 25, 33, 41, 49}
NONARP = [p for p in range(64) if p not in ARPS]
SEEDS = range(0, 12)


def regions(v):
    """(offset, nbytes) triples compared for voice v, in the port's layout."""
    return [(MAIN0 + v * STRIDE, STRIDE), (AUX0 + v * AUXN, AUXN),
            (SHARED0, SHAREDN)]


def hand_script():
    """The 1856 law, step by step. Zero-render checkpoints are on purpose:
    the broadcast happens at the event, not in the render."""
    ev = [('on', 60, 100), ('render', 64),
          ('on', 64, 90), ('on', 67, 80), ('render', 64),
          ('off', 64),                      # chord partly released: 1856 stays 1.0
          ('render', 64),
          ('off', 60), ('off', 67),         # last key up: 1856 -> 0.0 everywhere
          ('render', 256),
          ('on', 72, 127),                  # re-gate after a full release
          ('render', 64),
          ('on', 48, 1), ('on', 52, 64), ('on', 55, 127), ('on', 59, 30),
          ('on', 62, 99), ('render', 600),
          ('off', 48), ('off', 52), ('off', 55), ('off', 59), ('off', 62),
          ('off', 72), ('render', 1000)]
    return 44100.0, 0, ev


def steal_script():
    """A key left held with NO voice (2026-10-07): eight keys fill the voices, a
    ninth steals the newest one and goes up, then the voiced keys go up -- one
    key is still held but no voice is gated. The plugin's gate leaf writes 1856 as
    "a voice still gated" (rva 0x3B1C58), so it falls to 0.0 here; a "key held"
    law keeps 1.0. Then a new key (the 0 -> 1 rise) and the last key up."""
    ev = [('on', n, 100) for n in (40, 43, 47, 50, 53, 57, 60, 62)] + [('render', 64)]
    ev += [('on', 64, 100), ('render', 64), ('off', 64), ('render', 64)]
    ev += [('off', n) for n in (40, 43, 47, 50, 53, 57, 60)] + [('render', 600)]
    ev += [('on', 67, 90), ('render', 333), ('off', 67), ('render', 64), ('off', 62), ('render', 600)]
    return 48000.0, 0, ev


def seed_script(seed):
    rng = random.Random(0xB3B3 + seed)
    rate = [44100.0, 48000.0, 96000.0][seed % 3]
    patch = NONARP[rng.randrange(len(NONARP))]
    ev, held = [], []
    for _ in range(rng.randrange(20, 41)):
        kinds = ['render']
        if len(held) < 6:
            kinds += ['on', 'on']
        if held:
            kinds += ['off', 'off']
        k = rng.choice(kinds)
        if k == 'on':
            n = rng.randrange(24, 97)
            if n in held:
                continue
            held.append(n)
            ev.append(('on', n, rng.randrange(1, 128)))
        elif k == 'off':
            ev.append(('off', held.pop(rng.randrange(len(held)))))
        else:
            ev.append(('render', rng.choice([1, 2, 7, 64, 333, 600])))
    for n in held:
        ev.append(('off', n))
    ev.append(('render', 600))
    return rate, patch, ev


def scenarios():
    out = [('hand', hand_script()), ('steal', steal_script())]
    for s in SEEDS:
        out.append(('seed%d' % s, seed_script(s)))
    return out


# ------------------------------------------------------------------- oracle
def snap_plugin(e):
    snap = []
    for v in range(8):
        st = e.state[v]                     # the unit that RENDERS voice v
        snap.append(b''.join(bytes(e.uc.mem_read(st + off, n))
                             for off, n in regions(v)))
    return snap


def build_ref():
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    ref = {}
    for name, (rate, patch, ev) in scenarios():
        e = RR.prepare_recall(patch, bank, leaves, E, R, rate)
        cps = [snap_plugin(e)]
        for x in ev:
            if x[0] == 'on':
                e.note_on(x[1], x[2])
            elif x[0] == 'off':
                e.note_off(x[1])
            else:
                e.render(x[1])
            cps.append(snap_plugin(e))
        ref[name] = (rate, patch, ev, cps)
        sys.stderr.write('ref %s: rate=%d patch=%d events=%d\n'
                         % (name, int(rate), patch, len(ev)))
        sys.stderr.flush()
    os.makedirs(SCRATCH, exist_ok=True)
    refio.dump(ref, REF_PKL)
    print('wrote %s (%d scenarios)' % (REF_PKL, len(ref)))
    return 0


# --------------------------------------------------------------------- port
def check_port():
    import ctypes
    sys.path.insert(0, HERE)
    import freshlib
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
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                    ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_dump.restype = ctypes.c_int
    lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int,
                                  ctypes.c_char_p, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = open(BANK, 'rb').read()

    def snap_port(c):
        snap = []
        for v in range(8):
            parts = []
            for off, n in regions(v):
                buf = ctypes.create_string_buffer(n)
                assert lib.juno_gui_dump(c, off, buf, n) == n
                parts.append(buf.raw)
            snap.append(b''.join(parts))
        return snap

    def cell_name(v, i):
        """byte index i inside voice v's snapshot -> (port offset, label)."""
        for off, n in regions(v):
            if i < n:
                o = off + i
                if off == MAIN0 + v * STRIDE:
                    return o, 'voice %d cell +%d' % (v, o - v * STRIDE)
                if off == AUX0 + v * AUXN:
                    return o, 'voice %d aux +%d' % (v, i)
                return o, 'shared %d (unit %d copy)' % (o, v)
            i -= n
        return -1, '?'

    fails = 0
    cells = 0
    for name, (rate, patch, ev, cps) in sorted(ref.items()):
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), patch)
        got = [snap_port(c)]
        for x in ev:
            if x[0] == 'on':
                lib.juno_gui_note_on(c, x[1], x[2])
            elif x[0] == 'off':
                lib.juno_gui_note_off(c, x[1])
            else:
                buf = (ctypes.c_float * (2 * x[1]))()
                lib.juno_gui_render(c, buf, x[1])
            got.append(snap_port(c))
        lib.juno_gui_destroy(c)
        first = None
        ndiff = 0
        for k, (a, b) in enumerate(zip(cps, got)):
            for v in range(8):
                cells += len(a[v]) // 4
                if a[v] == b[v]:
                    continue
                for i in range(0, len(a[v]), 4):
                    if a[v][i:i + 4] != b[v][i:i + 4]:
                        ndiff += 1
                        if first is None:
                            first = (k, v, i, a[v][i:i + 4], b[v][i:i + 4])
        if first is None:
            print('%-7s OK    rate=%d patch=%2d checkpoints=%d'
                  % (name, int(rate), patch, len(cps)))
            continue
        fails += 1
        k, v, i, pa, pb = first
        _, label = cell_name(v, i)
        what = 'start' if k == 0 else 'after event %d %r' % (k - 1, ev[k - 1])
        fa = struct.unpack('<f', pa)[0]
        fb = struct.unpack('<f', pb)[0]
        print('%-7s FAIL  rate=%d patch=%2d  %d differing cells; first: %s, '
              '%s: plugin %08x (%+.9g) port %08x (%+.9g)'
              % (name, int(rate), patch, ndiff, what, label,
                 struct.unpack('<I', pa)[0], fa, struct.unpack('<I', pb)[0], fb))
    print('\n=== NOTE BROADCAST / ALL-VOICE STATE (CLAIMS B3): %d scenarios, '
          '%d cells compared, %d failed ===' % (len(ref), cells, fails))
    print('GATE: %s' % ('FAIL' if fails else 'PASS'))
    return 1 if fails else 0


# -------------------------------------------------------------------- tooth
TOOTH_FILE = 'src/juno_note.c'
TOOTH_FROM = '        JF(st, VBASE(v) + 1856) = f;\n'
TOOTH_TO = '        (void)f; (void)v; /* TOOTH: broadcast removed */\n'


def tooth():
    d = os.path.join(SCRATCH, 'tooth_note_bcast')
    if os.path.exists(d):
        shutil.rmtree(d)
    os.makedirs(d)
    for sub in ('src', 'gui', 'tools', 'truth'):
        shutil.copytree(os.path.join(REPO, sub), os.path.join(d, sub),
                        symlinks=True)
    shutil.copy(os.path.join(REPO, 'Makefile'), d)
    os.symlink(SCRATCH, os.path.join(d, 'scratchpad'))
    p = os.path.join(d, TOOTH_FILE)
    s = open(p).read()
    assert s.count(TOOTH_FROM) == 1, 'tooth anchor not unique: the gate is stale'
    open(p, 'w').write(s.replace(TOOTH_FROM, TOOTH_TO))
    r = subprocess.run(['make', '-s', 'libjuno.so'], cwd=d,
                       capture_output=True, text=True)
    if r.returncode:
        print(r.stdout + r.stderr)
        print('TOOTH BUILD FAILED -- no verdict')
        return 2
    r = subprocess.run([sys.executable, 'tools/verify/note_bcast_gate.py',
                        '--port'], cwd=d, capture_output=True, text=True)
    print(r.stdout[-3000:])
    shutil.rmtree(d)
    if r.returncode == 1:
        print('TOOTH: BITES (the gate fails on the pre-fix broadcast defect)')
        return 0
    print('TOOTH: DID NOT BITE (exit %d) -- the gate is NOT believed'
          % r.returncode)
    return 1


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
