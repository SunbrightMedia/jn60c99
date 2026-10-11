#!/usr/bin/env python3
"""jx_patch_gate.py -- THE PATCH BROWSER'S LOAD, plugin vs port (JX-16): bank records of any bytes -- the factory
bank, records of seeded random bytes, a bank file of them -- through the plugin's own patch load (jx_host_emu.JXHost
load_patch: rva 0x335730; Unicorn) and the port's (jx3p_product_load_record / jx3p_bank_open +
jx3p_product_load_patch: jx3p/src/jx_patch_tables.h; ctypes). After every step, both sides: the records the step
queued for the engine (kind 2 (id, value); kind 0 a MIDI record's bytes -- the note-offs of a KEY HOLD at 0), the
bytes of getState (the store), and the 256 samples of a block through process() (the records applied: the port's
by the plugin's own host entry, lifted -- wild values among them; a trap would stop the port). Those samples fall
in the load's 0.5 s mute (silent on both sides: the gate prints the count); the AUDIO after a load of random bytes
is graded through process() by jx_product_gate.py --recall 'rS@T'.

Chains (host 48000, a fresh instance: jx3p_product_init, its first block):
  0 factory   the 64 factory records in turn
  1 random    24 records of seeded random bytes after the name: 12 of nibbles (what the plugin's serializer
              writes), 12 of whole bytes (every field past its range somewhere)
  2 keyhold   keys pressed through process() and drained by the UI timer, then a factory record (KEY HOLD 0: the
              release before ARPEGGIO's record), random ones, keys not drained
  3 bankfile  a bank file of 5 random records (the factory bank's header) opened, its records loaded by index
Steps: ('fac', i) / ('rnd', seed) a load; ('proc', events) one block with note events; ('drain',) the UI timer's
handler (rva 0x320000; the port's jx3p_ui_tick); ('bank', seeds) the bank file; ('bankload', i) its record i.
    python3 jx3p/tools/jx_patch_gate.py [--chains 0,1,...]
    python3 jx3p/tools/jx_patch_gate.py --tooth     the port built with JX_PATCH_TOOTH=1 (a two-nibble field's
                                                    high nibble masked to 3 bits): must be RED
exit 0 = every step's records, save and samples equal.
"""
import atexit
import ctypes
import json
import os
import random
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_bank as B                                   # noqa: E402

SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
UI_DRAIN = 0x320000
RATE, BLK = 48000.0, 256


def record(kind, n):
    """a whole bank record (its 16-byte name first): factory record n, or seeded random bytes after factory record
    0's name -- seeds below 12, 30 and 40 and above: nibbles 0..15 (the serializer's own bytes); 12..29: 0..255"""
    bank = B.bank_bytes()
    if kind == 'fac':
        return bank[B.BANK_HEADER + n * B.BANK_STRIDE:B.BANK_HEADER + (n + 1) * B.BANK_STRIDE]
    g = random.Random(0x7A7C0000 + n)
    top = 256 if 12 <= n < 30 else 16
    return bank[B.BANK_HEADER:B.BANK_HEADER + B.BANK_BLOB_OFF] + bytes(g.randrange(top)
                                                                      for _ in range(B.BANK_BLOB_OFF, B.BANK_STRIDE))


def chains():
    on = lambda k, v=0.8, off=0: ('on', off, 0, k, v)
    off_ = lambda k, off=0: ('off', off, 0, k, 0.0)
    keys = [on(60), on(64, 0.5, 9), on(67, 0.3, 100)]
    ups = [off_(60), off_(64, 3), off_(67, 50)]
    return [
        ('factory', [('fac', i) for i in range(64)]),
        ('random', [('rnd', s) for s in range(24)]),
        ('keyhold', [('proc', keys), ('drain',), ('fac', 5), ('proc', ups),
                     ('proc', keys), ('drain',), ('rnd', 30), ('proc', ups),
                     ('proc', keys), ('rnd', 31), ('drain',), ('fac', 34), ('proc', ups), ('drain',), ('fac', 0)]),
        ('bankfile', [('bank', [40, 41, 42, 43, 44]), ('bankload', 2), ('bankload', 0), ('bankload', 4),
                      ('proc', keys), ('drain',), ('bankload', 1)]),
    ]


def bits(a):
    return list(struct.unpack('<%dI' % len(a), struct.pack('<%df' % len(a), *a)))


def oracle(ci):
    sys.path.insert(0, HERE)
    import jx_host_emu as X
    name, steps = chains()[ci]
    h = X.JXHost()
    h.start(RATE, 512)
    h.process(BLK)                             # the first block: initialize's queue applied
    bankrecs, res = [], []
    for stp in steps:
        k = stp[0]
        n0 = len(h.queue())
        ev = []
        if k in ('fac', 'rnd'):
            h.load_patch(record(k, stp[1])[B.BANK_BLOB_OFF:])
        elif k == 'bank':
            bankrecs = [record('rnd', s) for s in stp[1]]
        elif k == 'bankload':
            h.load_patch(bankrecs[stp[1]][B.BANK_BLOB_OFF:])
        elif k == 'drain':
            h.call(X.IB + UI_DRAIN, rcx=h.core, count=2_000_000_000)
        elif k == 'proc':
            ev = stp[1]
        new = [] if k == 'proc' else [(0, o, r[8], r[9], r[10]) if kind == 0 else
                                      (kind, o, struct.unpack_from('<I', r, 12)[0], struct.unpack_from('<i', r, 20)[0])
                                      for kind, o, r in h.queue()[n0:]]
        L, R = h.process(BLK, events=ev)
        res.append(dict(queue=new, save=h.get_state().hex(), audio=bits(L) + bits(R)))
    return res


def port(so, ci, tmp):
    lib = ctypes.CDLL(so)
    lib.jx_enable_hw_ftz()
    lib.jx3p_lift_error.restype = ctypes.c_char_p
    lib.jx3p_product_init.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int]
    lib.jx3p_product_note.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float]
    lib.jx3p_bank_open.argtypes = [ctypes.c_char_p]
    sys.path.insert(0, HERE)
    import jx_guest
    name, steps = chains()[ci]
    if lib.jx3p_product_init(jx_guest.path(96).encode(), os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(),
                             int(RATE)) < 0:
        raise SystemExit('jx3p_product_init failed')
    L = (ctypes.c_float * BLK)(); R = (ctypes.c_float * BLK)()
    lib.jx3p_product_block(L, R, BLK, (ctypes.c_int * 1)(), 0)
    buf = (ctypes.c_ubyte * 4096)()
    pend = (ctypes.c_int * (5 * 512))()
    res = []
    for stp in steps:
        k = stp[0]
        n0 = lib.jx3p_product_pending(pend, 5 * 512)
        if k in ('fac', 'rnd'):
            r = record(k, stp[1])
            if lib.jx3p_product_load_record((ctypes.c_ubyte * len(r)).from_buffer_copy(r), len(r)) < 0:
                raise SystemExit('jx3p_product_load_record refused')
        elif k == 'bank':
            path = os.path.join(tmp, 'bank_%d.bin' % ci)
            open(path, 'wb').write(B.bank_bytes()[:B.BANK_HEADER] + b''.join(record('rnd', s) for s in stp[1]))
            if lib.jx3p_bank_open(path.encode()) != len(stp[1]):
                raise SystemExit('jx3p_bank_open refused')
        elif k == 'bankload':
            if lib.jx3p_product_load_patch(stp[1]) < 0:
                raise SystemExit('jx3p_product_load_patch(%d) refused' % stp[1])
        elif k == 'drain':
            lib.jx3p_ui_tick()
        elif k == 'proc':
            for e in stp[1]:
                lib.jx3p_product_note(0 if e[0] == 'on' else 1, e[1], e[2], e[3], e[4])
        n1 = lib.jx3p_product_pending(pend, 5 * 512)
        flat = list(pend)
        new = [] if k == 'proc' else [(0, q[1], q[2] & 0xFF, q[3] & 0xFF, q[4] & 0xFF) if q[0] == 0 else
                                      (q[0], q[1], q[3] & 0xFFFFFFFF, q[4]) for q in
                                      (flat[5 * i:5 * i + 5] for i in range(n0, n1))]
        lib.jx3p_product_block(L, R, BLK, (ctypes.c_int * 1)(), 0)
        n = lib.jx3p_state_save(buf, 4096)
        res.append(dict(queue=new, save=bytes(buf)[:n].hex(), audio=bits(list(L)) + bits(list(R))))
    if lib.jx3p_lift_error():
        raise SystemExit('the lifted code trapped: %s' % lib.jx3p_lift_error().decode())
    return res


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle(int(a[1])), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], int(a[2]), a[3]), sys.stdout)
        return 0
    tooth = '--tooth' in a
    sel = [int(x) for x in a[a.index('--chains') + 1].split(',')] if '--chains' in a else list(range(len(chains())))
    tmp = tempfile.mkdtemp()
    atexit.register(shutil.rmtree, tmp, True)     # its builds and inflated images: never left behind
    so = os.path.join(tmp, 'libjx3p.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] +
                   (['-DJX_PATCH_TOOTH=1'] if tooth else []) + [os.path.join(REPO, s) for s in SRCS] + ['-lm'],
                   check=True)
    bad, nsteps, nrec = 0, 0, 0
    for ci in sel:
        name, steps = chains()[ci]
        o = subprocess.run([sys.executable, __file__, '--oracle', str(ci)], capture_output=True, text=True)
        if o.returncode:
            raise SystemExit('oracle failed (%s): %s' % (name, o.stderr[-1500:]))
        p = subprocess.run([sys.executable, __file__, '--port', so, str(ci), tmp], capture_output=True, text=True)
        if p.returncode:
            raise SystemExit('port failed (%s): %s' % (name, p.stderr[-1500:]))
        ro, rp = json.loads(o.stdout), json.loads(p.stdout)
        nsteps += len(ro)
        nrec += sum(len(x['queue']) for x in ro)
        first = next((i for i, (x, y) in enumerate(zip(ro, rp))
                      if x['save'] != y['save'] or x['audio'] != y['audio'] or
                      [list(q) for q in x['queue']] != [list(q) for q in y['queue']]), None)
        loud = sum(1 for x in ro for s in x['audio'] if s & 0x7FFFFFFF)
        if first is None and len(ro) == len(rp):
            print('  chain %d %s: %d steps -- every queued record, save and sample equal (%d records, %d MIDI; %d '
                  'nonzero samples)' % (ci, name, len(steps), sum(len(x['queue']) for x in ro),
                                        sum(1 for x in ro for q in x['queue'] if q[0] == 0), loud), flush=True)
            continue
        bad += 1
        x, y = ro[first], rp[first]
        what = repr(steps[first])[:80]
        if [list(q) for q in x['queue']] != [list(q) for q in y['queue']]:
            d = next(i for i, (u, v) in enumerate(zip(x['queue'] + [None], y['queue'] + [None])) if u != v)
            print('  chain %d %s: step %d (%s): queued record %d differs: plugin %s port %s' % (
                ci, name, first, what, d, x['queue'][d:d + 2], y['queue'][d:d + 2]), flush=True)
        elif x['save'] != y['save']:
            print('  chain %d %s: step %d (%s): the save differs' % (ci, name, first, what), flush=True)
        else:
            s = next(i for i, (u, v) in enumerate(zip(x['audio'], y['audio'])) if u != v)
            print('  chain %d %s: step %d (%s): sample %d differs' % (ci, name, first, what, s), flush=True)
    if tooth:
        print('jx_patch_gate --tooth: %s' % ('BITES (%d of %d chains)' % (bad, len(sel)) if bad else 'DID NOT BITE'))
        return 0 if bad else 1
    print('jx_patch_gate: %d of %d chains equal (%d loads and blocks, %d records): %s' % (
        len(sel) - bad, len(sel), nsteps, nrec, 'GREEN' if not bad else 'RED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
