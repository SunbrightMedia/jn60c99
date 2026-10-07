#!/usr/bin/env python3
"""steal_gate.py -- voice STEALING: more notes than voices, plugin vs port,
audio AND every voice's whole state (closes CLAIMS B2).

WHY IT EXISTS. CLAIMS B2 ledgered "a steal with >= 9 SOUNDING voices differs by
~1-2 ULP (the plugin's arp/steal path splices a worker-thread render)". That
was measured in Phase 2, when the oracle drove notes through the leaf bus. The
oracle now drives the plugin's OWN assigner (e2e_emu.note_on -> 0x3C7330 ->
CAssignJu60), and fuzz_diff still caps held notes at 6 so it never steals a
sounding voice on purpose. No gate in make verify forces a steal. This one does.

SCENARIOS (seeded, reproducible): up to 12 held notes at once (8 voices, so
every 9th..12th note steals), a random non-arp factory patch per seed (POLY,
MONO and UNISON ones alike), render chunks from 1 to 600 samples (so a steal
can land one sample after a release, while released voices still sound),
three rates.

COMPARES after every event: every voice's whole state (the note_bcast_gate
cell set, from the plugin unit that renders that voice) AND the stereo output
of every render, bit for bit.

TWO-PROCESS RULE: --ref (Unicorn only) -> scratchpad/steal_ref.pkl;
--port (libjuno only) reads it.

TOOTH (--tooth): a scratch copy where the POLY allocator's steal choice is
perturbed (the port's pick_oldest steals the NEWEST assigned voice instead);
--port there must FAIL.

USAGE
    python3 tools/verify/steal_gate.py --ref | --port | --tooth
"""
import os
import sys
import pickle
import random
import struct
import shutil
import subprocess
from array import array

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
REF_PKL = os.path.join(SCRATCH, 'steal_ref.pkl')
sys.path.insert(0, HERE)
import note_bcast_gate as NB          # noqa: E402  regions() / the cell set

ARPS = {1, 9, 17, 25, 33, 41, 49}
SEEDS = range(0, 16)
MAX_HELD = 12


def script(seed):
    rng = random.Random(0xB2B2 + seed)
    rate = [44100.0, 48000.0, 96000.0][seed % 3]
    patch = [p for p in range(64) if p not in ARPS][rng.randrange(57)]
    ev, held = [], []
    for _ in range(rng.randrange(40, 71)):
        kinds = ['render']
        if len(held) < MAX_HELD:
            kinds += ['on'] * 3                     # bias toward MORE notes than voices
        if held:
            kinds += ['off']
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
            ev.append(('render', rng.choice([1, 2, 5, 64, 200, 600])))
    for n in held:
        ev.append(('off', n))
    ev.append(('render', 2000))
    return rate, patch, ev


def build_ref():
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    ref = {}
    for s in SEEDS:
        rate, patch, ev = script(s)
        e = RR.prepare_recall(patch, bank, leaves, E, R, rate)
        cps = [NB.snap_plugin(e)]
        aud = []
        for x in ev:
            if x[0] == 'on':
                e.note_on(x[1], x[2])
            elif x[0] == 'off':
                e.note_off(x[1])
            else:
                L, Rr = e.render(x[1])
                aud.append((array('I', L).tobytes(), array('I', Rr).tobytes()))
            cps.append(NB.snap_plugin(e))
        ref[s] = (rate, patch, ev, cps, aud)
        sys.stderr.write('ref seed %d: rate=%d patch=%d events=%d\n'
                         % (s, int(rate), patch, len(ev)))
        sys.stderr.flush()
    os.makedirs(SCRATCH, exist_ok=True)
    pickle.dump(ref, open(REF_PKL, 'wb'))
    print('wrote %s (%d seeds)' % (REF_PKL, len(ref)))
    return 0


def check_port():
    import ctypes
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

    def snap(c):
        out = []
        for v in range(8):
            parts = []
            for off, n in NB.regions(v):
                buf = ctypes.create_string_buffer(n)
                assert lib.juno_gui_dump(c, off, buf, n) == n
                parts.append(buf.raw)
            out.append(b''.join(parts))
        return out

    fails = 0
    steals_total = 0
    for s, (rate, patch, ev, cps, aud) in sorted(ref.items()):
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), patch)
        got = [snap(c)]
        gaud = []
        held = 0
        steals = 0
        for x in ev:
            if x[0] == 'on':
                held += 1
                steals += held > 8
                lib.juno_gui_note_on(c, x[1], x[2])
            elif x[0] == 'off':
                held -= 1
                lib.juno_gui_note_off(c, x[1])
            else:
                buf = (ctypes.c_float * (2 * x[1]))()
                lib.juno_gui_render(c, buf, x[1])
                w = struct.unpack('<%dI' % (2 * x[1]), bytes(buf))
                gaud.append((w[0::2], w[1::2]))
            got.append(snap(c))
        lib.juno_gui_destroy(c)
        steals_total += steals
        first = None
        for k, (a, b) in enumerate(zip(cps, got)):
            if a != b:
                v = next(v for v in range(8) if a[v] != b[v])
                i = next(i for i in range(0, len(a[v]), 4)
                         if a[v][i:i + 4] != b[v][i:i + 4])
                first = ('state', k, v, i)
                break
        if first is None:
            for j, ((la, ra), (lb, rb)) in enumerate(zip(aud, gaud)):
                La = array('I'); La.frombytes(la)
                Ra = array('I'); Ra.frombytes(ra)
                if list(La) != list(lb) or list(Ra) != list(rb):
                    i = next(i for i in range(len(La)) if La[i] != lb[i] or Ra[i] != rb[i])
                    first = ('audio', j, i)
                    break
        if first is None:
            print('seed %2d OK    rate=%d patch=%2d events=%d forced steals=%d'
                  % (s, int(rate), patch, len(ev), steals))
            continue
        fails += 1
        if first[0] == 'state':
            _, k, v, i = first
            what = 'start' if k == 0 else 'after event %d %r' % (k - 1, ev[k - 1])
            print('seed %2d FAIL  rate=%d patch=%2d  state: %s, voice %d byte %d'
                  % (s, int(rate), patch, what, v, i))
        else:
            print('seed %2d FAIL  rate=%d patch=%2d  audio: render %d sample %d'
                  % (s, int(rate), patch, first[1], first[2]))
    print('\n=== VOICE STEAL (CLAIMS B2): %d seeds, %d forced steals, %d failed ==='
          % (len(ref), steals_total, fails))
    print('GATE: %s' % ('FAIL' if fails else 'PASS'))
    return 1 if fails else 0


TOOTH_FILE = 'gui/juno_bridge.c'


def tooth():
    d = os.path.join(SCRATCH, 'tooth_steal')
    if os.path.exists(d):
        shutil.rmtree(d)
    os.makedirs(d)
    for sub in ('src', 'gui', 'tools', 'truth'):
        shutil.copytree(os.path.join(REPO, sub), os.path.join(d, sub), symlinks=True)
    shutil.copy(os.path.join(REPO, 'Makefile'), d)
    os.symlink(SCRATCH, os.path.join(d, 'scratchpad'))
    p = os.path.join(d, TOOTH_FILE)
    s = open(p).read()
    a = 'static int pick_oldest(juno_ctx *c, int want_assigned, int want_gated)\n{'
    assert s.count(a) == 1, 'tooth anchor not unique: the gate is stale'
    s = s.replace(a, a + '\n    return pick_newest(c, want_assigned, want_gated);  /* TOOTH */')
    s = s.replace('static int pick_oldest(juno_ctx *c, int want_assigned, int want_gated);', '')
    # pick_newest is defined after pick_oldest: declare it first
    s = s.replace(a, 'static int pick_newest(juno_ctx *c, int want_assigned, int want_gated);\n' + a, 1)
    open(p, 'w').write(s)
    r = subprocess.run(['make', '-s', 'libjuno.so'], cwd=d, capture_output=True, text=True)
    if r.returncode:
        print(r.stdout + r.stderr)
        print('TOOTH BUILD FAILED -- no verdict')
        return 2
    r = subprocess.run([sys.executable, 'tools/verify/steal_gate.py', '--port'],
                       cwd=d, capture_output=True, text=True)
    print(r.stdout[-3000:])
    shutil.rmtree(d)
    if r.returncode == 1:
        print('TOOTH: BITES (a wrong steal choice fails the gate)')
        return 0
    print('TOOTH: DID NOT BITE (exit %d) -- the gate is NOT believed' % r.returncode)
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
