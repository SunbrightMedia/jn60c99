#!/usr/bin/env python3
"""state_load_gate.py -- the plugin's OWN preset paths, plugin vs port, audio +
state + ramp records, no snap (CLAIMS B6).

EXECUTED in the booted plugin (probes/b6/wrapper_emu.py): IComponent::initialize,
IComponent::setState (a DAW preset) and the patch browser's load (rva 0x335850)
all set model values; the core queues one engine event per value and the
render driver applies the queue through the host entry (rva 0x3C7AE0, flag 0)
at the start of the next block. --ref therefore has two halves:
  1. the PLUGIN makes every queue: it boots as a host boots it and runs
     initialize, setState on each test payload and its patch load on each test
     record -- the queues are the plugin's own output, never the harness's;
  2. an engine (e2e_emu, POPULATE) is fed those queues through the host entry,
     in queue order at block boundaries, with notes and renders between.
--port: juno_gui_create + juno_gui_plugin_init, then juno_gui_state_load /
juno_gui_load_patch / juno_gui_host_set on the same script.
Compares every sample, the rendered state (voice v from unit v, the master from
unit 8) and the 798 ramp records at every check (host_edit_gate.py helpers).

PAYLOADS: the plugin's getState at boot and after it loaded factory patches
(what a DAW saves), the same reversed, a partial one (MASTER TUNE, the voice
count, a few panel values), every entry at 0x12345678 / -1 / 300 (the storage
masks), unknown ids, voice counts 2..8.
RECORDS: factory patches (every one of the 64 across the chains), legal seeded
records (every panel value random in range, MASTER TUNE and the H floats
included), the same with the arp on over every TYPE and STEP, wild records
(bytes the nibble fields do not carry). ORDER payloads: entries whose order
changes the result (the fine cutoff before / after the coarse one, DELAY LEVEL
around a DELAY TYPE change), each in both orders.

LIMITS, stated: host rates 44100 / 48000 / 96001; the queue's sample offset is
0 (both paths queue at offset 0); the 79 performEdit calls a setState sends the
host are the host's business (a host that echoes them sends 79 host edits more:
host_edit_gate.py); the wrapper's own processing order is not executed (the
render driver is READ, rva 0x320B20).

TOOTH (--tooth): the patch load as the recall (the old port), the patch load
in reverse order, the record decode masked to nibbles, the state masks dropped,
the payload applied in reverse order, the voice count ignored, initialize's
defaults skipped, the arp switch flushing the notes (the old port), its
switch-off order ignoring the key-trig flag, re-playing at velocity 100, a wild
LFO KEY TRIG not sticking; reach probe: the model record taking the loaded
record's non-parameter leaves.

TWO-PROCESS RULE: --ref (Unicorn only) -> scratchpad/state_load_ref.pkl;
--port (libjuno only) reads it. FP MODE as the oracle (playbook 120).

USAGE
    python3 tools/verify/state_load_gate.py --ref
    python3 tools/verify/state_load_gate.py --port [-v] [--chain N]
    python3 tools/verify/state_load_gate.py --tooth
"""
import gc
import os
import re
import sys
import pickle
import random
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
REF_PKL = os.environ.get('STATE_LOAD_REF') or os.path.join(SCRATCH, 'state_load_ref.pkl')
TRACE = None          # --trace N: chain N alone with a check after every event (its own pickle)
HEADER, STRIDE, NAME = 23, 20223, 16
RATES = [44100.0, 48000.0, 96001.0]
APPLY_RVA, POPULATE_RVA = 0x3C7AE0, 0xAD5A0
NOTES = [48, 55, 60, 64, 67, 72, 52, 59]
VOICECOUNT_ID, MT_ID = 0x0FFFC00E, 0x2
RR_BASE = int(re.search(r'#define\s+JUNO_RR_BASE\s+(\d+)u',
                        open(os.path.join(REPO, 'src', 'juno_engine.h')).read()).group(1))


def host_rows():
    src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
    return [(m.group(1).strip(), int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5)))
            for m in re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),\s*(\d+),\s*(-?\d+),\s*(-?\d+),', src)]


def payload(state):
    n = struct.unpack('>I', state[:4])[0]
    return [list(struct.unpack('>Ii', state[4 + i:12 + i])) for i in range(0, n, 8)]


def blob(entries):
    pl = b''.join(struct.pack('>Ii', i, v) for i, v in entries)
    return struct.pack('>I', len(pl)) + pl


def seeded_record(base_rec, seed):
    """a legal patch a user could save: every panel value random in its range,
    written as the record holds it (nibble pairs; int8x4 low nibbles; the H
    floats as 8 nibbles; MASTER TUNE at 18) -- test INPUT, not plugin logic"""
    rnd = random.Random(seed)
    r = bytearray(base_rec)
    for name, roff, typ, lo, hi in host_rows():
        if typ == 3:
            v = struct.unpack('<I', struct.pack('<f', rnd.random()))[0]
            for i in range(8):
                r[roff - 6 + i] = (v >> (4 * (7 - i))) & 0xF
            continue
        v = rnd.randint(lo, hi) & 0xFF
        if name == 'ARPEGGIO SW':
            v = 0                   # the oracle cannot arpeggiate (no transport): see ARP below
        if typ == 0:
            r[roff] = v & 0x7F
        else:
            if typ == 2:
                for i in range(6):
                    r[roff - 6 + i] = 0xF if (lo < 0 and v >= 128) else 0
            r[roff] = (v >> 4) & 0xF
            r[roff + 1] = v & 0xF
    return bytes(r)


def wild_record(base_rec, mul, add):
    """bytes the nibble fields do not carry, at every offset -- but ARPEGGIO SW
    zero: switching the arp on runs its note transfer and the SCATTER refresh,
    which the gates leave to an arp chain without notes (see ARP)"""
    r = bytearray(base_rec)
    for i in range(NAME, STRIDE):
        r[i] = (i * mul + add + (i >> 8) * 17) & 0xFF
    r[292:300] = bytes(8)                     # ARPEGGIO SW (int8x4, src/juno_state_tables.h)
    return bytes(r)


# --------------------------------------------------------------------- inputs
def inputs(bank):
    """records {key: record bytes} the chains load, and the payload recipes"""
    recs = {}
    for k in range(64):
        recs['f%d' % k] = bank[HEADER + k * STRIDE: HEADER + (k + 1) * STRIDE]
    for s in range(8):
        recs['s%d' % s] = seeded_record(recs['f%d' % ((11 * s + 3) % 64)], 5100 + s)
    for k, (mul, add) in enumerate(((29, 7), (53, 101), (197, 3))):
        recs['w%d' % k] = wild_record(recs['f0'], mul, add)
    for k in range(12):                       # arp on, TYPE and STEP over their whole range
        r = bytearray(seeded_record(recs['f%d' % ((5 * k + 2) % 64)], 6300 + k))
        for off, v in ((298, 1), (306, k % 6), (314, (k * 5 + 1) % 6)):
            r[off], r[off + 1] = (v >> 4) & 0xF, v & 0xF
        recs['a%d' % k] = bytes(r)
    return recs


# ARPEGGIO SW on: the factory records 1, 9, ..., 49, the payloads made from
# them and the mask payloads (any nonzero switches it on). The oracle has no
# transport clock and cannot arpeggiate (as host_edit_gate.py), and the switch
# moves the notes held or releasing (rva 0x3C49F0), so no note sounds across
# such a load and none is played until the arp is off again.
ARP = {1, 9, 17, 25, 33, 41, 49}


def arp_key(key):
    if key.startswith(('gs:', 'rev:')):
        key = key.split(':')[1]
    if key.startswith('f'):
        return int(key[1:]) in ARP
    return key.startswith(('mask', 'a'))


def scripts():
    """[(family, rate, script)] -- events name records / payloads by key"""
    out = []
    rnd = random.Random(77)
    fac = list(range(64))
    rnd.shuffle(fac)
    # boot: the plugin as shipped (initialize's defaults: six voices)
    for c in range(3):
        sc = [('render', 64), ('check',)]
        for n in NOTES:
            sc += [('on', n), ('render', 40)]
        sc += [('render', 600), ('check',)] + [('off', n) for n in NOTES] + [('render', 1200), ('check',)]
        out.append(('boot', RATES[c], sc))
    # patch: the patch browser, every factory record, notes held across loads
    for c in range(8):
        sc = [('render', 64)]
        held = []
        for j, k in enumerate(fac[8 * c: 8 * c + 8]):
            if k in ARP:
                sc += [('off', n) for n in held] + [('patch', 'f%d' % k), ('render', 300), ('check',)]
                held = []
                continue
            n1, n2 = NOTES[j % 8], NOTES[(j + 3) % 8]
            sc += [('patch', 'f%d' % k), ('render', rnd.choice((30, 300))), ('on', n1), ('render', 200),
                   ('on', n2), ('render', rnd.choice((15, 250, 900))), ('check',)]
            held += [n1, n2]
            if j % 2:
                sc += [('off', n1), ('off', n2), ('render', 400)]
                held = [n for n in held if n not in (n1, n2)]
        sc += [('off', n) for n in NOTES] + [('render', 1500), ('check',)]
        out.append(('patch', RATES[c % 3], sc))
    # seeded + wild records (a wild record switches the arp on: no notes then)
    for c in range(4):
        sc = [('render', 64), ('patch', 'f%d' % (9 * c + 2)), ('on', 60), ('render', 300)]
        for key in ('s%d' % (2 * c), 'w%d' % (c % 3), 's%d' % (2 * c + 1)):
            if arp_key(key):
                sc += [('off', 60), ('patch', key), ('render', 400), ('check',)]
                continue
            sc += [('patch', key), ('render', rnd.choice((40, 400))), ('check',), ('on', 64), ('render', 500),
                   ('check',), ('off', 64), ('on', 60)]
        sc += [('off', 60), ('render', 1500), ('check',)]
        out.append(('seeded', RATES[c % 3], sc))
    # arp: presets that switch the arpeggiator on and off, no note sounding
    # (the switch moves held and releasing notes: ARP)
    for c in range(3):
        sc = [('render', 64), ('patch', 'f%d' % (1 + 8 * c)), ('render', 300), ('check',),
              ('state', 'gs:f%d' % (9 + 8 * c)), ('render', 300), ('check',),
              ('state', 'rev:f%d' % (17 + 8 * c)), ('render', 300), ('check',),
              ('patch', 'f%d' % (49 - 8 * c)), ('render', 200), ('check',),
              ('state', 'default'), ('render', 300), ('check',),
              ('on', 60), ('render', 500), ('check',), ('off', 60), ('render', 1000), ('check',)]
        out.append(('arp', RATES[c], sc))
    # arpnote: the arp switched on and off while keys are held (CLAIMS B11),
    # each switch checked before any render (the oracle cannot arpeggiate: no
    # render with the arp on), in both key-trig modes (the switch-off order)
    for c in range(3):
        sc = [('render', 64), ('patch', 'f%d' % (12 + c)), ('host', 'LFO KEY TRIG', c % 2), ('on', 60), ('on', 64),
              ('on', 55, 70), ('render', 300), ('off', 64), ('render', 40), ('host', 'ARPEGGIO SW', 1), ('check',),
              ('on', 72, 90), ('host', 'ARPEGGIO SW', 0), ('check',), ('render', 300), ('check',),
              ('host', 'LFO KEY TRIG', 1 - c % 2), ('on', 67), ('render', 200), ('host', 'ARPEGGIO SW', 1), ('check',),
              ('host', 'ARPEGGIO SW', 0), ('check',), ('render', 400), ('check',)]
        sc += [('off', n) for n in (55, 60, 67, 72)] + [('render', 1200), ('check',)]
        out.append(('arpnote', RATES[c], sc))
    # a wild LFO KEY TRIG (a mask payload) sticks in the key-trig byte: later
    # values cannot move it, so the switch-off order stays the press order
    sc = [('render', 64), ('patch', 'f15'), ('state', 'mask1'), ('render', 100), ('state', 'default'), ('render', 100),
          ('host', 'LFO KEY TRIG', 1), ('on', 60), ('on', 64, 80), ('on', 52, 110), ('render', 300),
          ('host', 'ARPEGGIO SW', 1), ('check',), ('host', 'ARPEGGIO SW', 0), ('check',), ('render', 300), ('check',)]
    sc += [('off', n) for n in (52, 60, 64)] + [('render', 1000), ('check',)]
    out.append(('arpnote', RATES[1], sc))
    # order: a DAW preset whose entries interact, in both orders, then the
    # edits that read what they left (a near cutoff step, a DELAY TYPE change)
    for c in range(3):
        sc = [('render', 64), ('patch', 'f%d' % (4 + c)), ('on', 62), ('render', 200)]
        for o in (2 * c, 2 * c + 1):
            sc += [('state', 'ord%d' % o), ('render', 100), ('check',),
                   ('host', 'VCF CUTOFF FREQ', (100, 140, 60)[c] + 2), ('render', 300), ('check',),
                   ('host', 'DELAY TYPE', (1, 4, 2)[c]), ('render', 300), ('check',)]
        sc += [('off', 62), ('render', 1200), ('check',)]
        out.append(('order', RATES[c], sc))
    # seeded arp: legal records with the arp on and every TYPE / STEP (no note)
    for c in range(3):
        sc = [('render', 64)]
        for j in range(4):
            sc += [('patch', 'a%d' % (4 * c + j)), ('render', 300), ('check',)]
        sc += [('state', 'default'), ('render', 300), ('check',), ('on', 60), ('render', 400), ('check',),
               ('off', 60), ('render', 800), ('check',)]
        out.append(('seedarp', RATES[c], sc))
    # state: DAW presets (the plugin's own getState after its patch loads)
    nonarp = [k for k in fac if k not in ARP]
    for c in range(6):
        ks = nonarp[7 * c + 3: 7 * c + 7]
        sc = [('render', 64)]
        held = []
        for j, k in enumerate(ks):
            if k in ARP:
                sc += [('off', n) for n in held] + [('state', 'gs:f%d' % k), ('render', 300), ('check',)]
                held = []
                continue
            sc += [('state', 'gs:f%d' % k), ('render', rnd.choice((20, 200))), ('on', NOTES[j]), ('render', 300), ('check',)]
            held.append(NOTES[j])
        sc += [('off', n) for n in held] if arp_key('gs:f%d' % ks[0]) else []
        sc += [('state', 'rev:f%d' % ks[0]), ('render', 300), ('check',),
               ('state', 'part%d' % c), ('render', 400), ('check',),
               ('state', 'vc%d' % (2 + c)), ('render', 300), ('on', 71), ('on', 74), ('render', 500), ('check',)]
        sc += [('off', n) for n in NOTES + [71, 74]] + [('render', 1500), ('check',)]
        out.append(('state', RATES[c % 3], sc))
    # edges: masks (the arp switches on: no note until the default payload),
    # unknown ids, the default payload, host edits between
    for c in range(3):
        sc = [('render', 64), ('patch', 'f%d' % (20 + c)), ('render', 200),
              ('state', 'mask%d' % c), ('render', 300), ('check',),
              ('state', 'unknown'), ('render', 200), ('check',),
              ('state', 'default'), ('render', 300), ('check',), ('on', 57), ('render', 200),
              ('host', 'VCF CUTOFF FREQ', 33), ('render', 100), ('state', 'gs:f%d' % (30 + c)), ('render', 300), ('check',),
              ('patch', 's%d' % c), ('host', 'MASTER TUNE', 150), ('render', 400), ('check',)]
        sc += [('off', 57), ('render', 1200), ('check',)]
        out.append(('edge', RATES[c], sc))
    return out


# --------------------------------------------------------------------- oracle
def plugin_queues(recs, sc_all):
    """the plugin makes every queue (Unicorn: probes/b6/wrapper_emu.py)"""
    sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
    import wrapper_emu as W
    w = W.Wrapper()
    w.boot_host(log=lambda s: None)
    dec = lambda qq: [(struct.unpack_from('<I', rec, 12)[0], struct.unpack_from('<i', rec, 20)[0], k, o)
                      for k, o, rec in qq]
    init = dec(w.queue())
    out = {'init': init}
    s0 = w.get_state()
    ent0 = payload(s0)
    gs = {'default': s0}
    need = set(ev[1] for _, _, sc in sc_all for ev in sc if ev[0] in ('patch', 'state'))
    for key in sorted(k for k in need if k in recs):
        out['patch:' + key] = dec(w.load_patch(recs[key][NAME:]))
    for key in sorted(k for k in need if k.startswith(('gs:', 'rev:'))):
        rk = key.split(':')[1]
        if 'gs:' + rk not in gs:
            w.load_patch(recs[rk][NAME:])
            gs['gs:' + rk] = w.get_state()
    states = dict(gs)
    for key in [k for k in need if k.startswith('rev:')]:
        e = payload(gs['gs:' + key[4:]])
        states[key] = blob(e[:95][::-1] + e[95:])
    for c in range(6):
        e = {p: v for p, v in ent0}
        states['part%d' % c] = blob([[MT_ID, 37 + 20 * c], [VOICECOUNT_ID, 3 + c % 5], [0x60003a, 40 + 30 * c],
                                     [0x600004, 200 - 9 * c], [0xA02802, 0x3E800000 + 0x10000 * c]])
        states['vc%d' % (2 + c)] = blob([[p, (2 + c) if p == VOICECOUNT_ID else v] for p, v in ent0])
    for c, val in enumerate((0x12345678, -1, 300)):
        states['mask%d' % c] = blob([[p, val] for p, v in ent0[:95]] + ent0[95:])
    states['unknown'] = blob([[0x7777, 5], [0x10000005, 0x600004], [0x600004, 77], [0x12345678, 1]])
    # ORDER: entries whose order changes the result -- the fine cutoff after or
    # before the coarse one leaves a different last value (A20: the next
    # cutoff edit's glide is measured from it), DELAY LEVEL before or after a
    # DELAY TYPE change (the type's re-send reads the level's on-flag)
    cut, cuth, dl, dt = 0x60003a, 0xA02802, 0x60005c, 0x600268
    half = struct.unpack('<i', struct.pack('<f', 0.5))[0]
    for c, (cv, dv, tv) in enumerate(((100, 0, 3), (140, 2, 0), (60, 1, 5))):
        fwd = [[cut, cv], [dl, dv], [dt, tv], [cuth, half]]
        states['ord%d' % (2 * c)] = blob(fwd)
        states['ord%d' % (2 * c + 1)] = blob(fwd[::-1])
    for key in sorted(k for k in need if k in states):
        n0 = len(w.queue())
        w.set_state(states[key])
        out['state:' + key] = dec(w.queue()[n0:])
    del w
    gc.collect()
    return out, states


def build_ref():
    import zlib
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import recall_render_ab as RR
    import host_edit_gate as HG
    from array import array
    bank = E.bank_bytes()
    recs = inputs(bank)
    ch = scripts()
    if TRACE is not None:
        fam, rate, sc = ch[TRACE]
        dense = []
        for ev in sc:
            if ev[0] == 'render' and ev[1] > 8:
                dense += [('render', ev[1] - 8), ('check',)] + [('render', 1), ('check',)] * 8
            else:
                dense += [ev, ('check',)]
        ch = [(fam, rate, dense)]
    queues, states = plugin_queues(recs, ch)
    if any(k != 2 or o != 0 for q in queues.values() for _, _, k, o in q):
        raise SystemExit('a queue holds an event that is not kind 2 at offset 0')
    rows = host_rows()
    hpid = {}
    ref = {'_chains': [], '_queues': {k: [(p, v) for p, v, _, _ in q] for k, q in queues.items()},
           '_states': states, '_recs': {k: v for k, v in recs.items()}}
    for ci, (fam, rate, sc) in enumerate(ch):
        e = RR.build_engine(E, rate)
        e.call(E.IB + POPULATE_RVA, count=200_000_000)
        e.set_ftz()          # the plugin renders in SSE FTZ|DAZ (the emulator has DAZ only: playbook 120)
        if not hpid:
            for k, (name, d, pid, lo, hi) in HG.oracle_params(e, E, __import__('seed_recall_gate')).items():
                hpid[name] = (k, pid)
        rmap = HG.ramp_map(e, E)

        def feed(q):
            for pid, v, _, _ in q:
                e.call(E.IB + APPLY_RVA, rcx=e.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=60_000_000)
        feed(queues['init'])
        outs, recsl = [], []
        for ev in sc:
            if ev[0] == 'patch':
                feed(queues['patch:' + ev[1]])
            elif ev[0] == 'state':
                feed(queues['state:' + ev[1]])
            elif ev[0] == 'host':
                e.call(E.IB + APPLY_RVA, rcx=e.HOST, rdx=hpid[ev[1]][1], r8=ev[2] & 0xFFFFFFFF, count=60_000_000)
            elif ev[0] == 'on':
                e.note_on(ev[1], ev[2] if len(ev) > 2 else 100)
            elif ev[0] == 'off':
                e.note_off(ev[1])
            elif ev[0] == 'render':
                L, Rr = e.render(ev[1])
                outs.append(zlib.compress(array('I', L).tobytes() + array('I', Rr).tobytes(), 6))
            elif ev[0] == 'check':
                parts = []
                for v in range(8):
                    for a, b in HG.voice_regions(v):
                        parts.append(bytes(e.uc.mem_read(e.state[v] + a, b - a)))
                for a, b in HG.master_ranges():
                    parts.append(bytes(e.uc.mem_read(e.state[8] + a, b - a)))
                outs.append(zlib.compress(b''.join(parts), 6))
                recsl.append(HG.oracle_records(e, rmap))
        ref[ci] = outs
        ref.setdefault('_rrec', {})[ci] = zlib.compress(pickle.dumps(recsl), 6)
        ref['_rcells'] = sorted(rmap)
        ref['_chains'].append((fam, rate, sc))
        del e
        gc.collect()
        sys.stderr.write('ref chain %d %s (%g Hz): %d events\n' % (ci, fam, rate, len(sc)))
        sys.stderr.flush()
    ref['_hpid'] = hpid
    out = REF_PKL if TRACE is None else REF_PKL.replace('.pkl', '_trace%d.pkl' % TRACE)
    pickle.dump(ref, open(out, 'wb'))
    print('wrote %s (%d chains, %d queues)' % (out, len(ch), len(queues)))
    return 0


# ----------------------------------------------------------------------- port
def check_port():
    import ctypes
    import zlib
    import numpy as np
    sys.path.insert(0, HERE)
    import freshlib
    import host_edit_gate as HG
    pk = REF_PKL if TRACE is None else REF_PKL.replace('.pkl', '_trace%d.pkl' % TRACE)
    if not os.path.exists(pk):
        print('MISSING %s -- run --ref first' % pk)
        return 2
    ref = pickle.load(open(pk, 'rb'))
    lib = freshlib.load()
    V, I, F, C = ctypes.c_void_p, ctypes.c_int, ctypes.c_float, ctypes.c_char_p
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [F, I]
    for fn, at in (('juno_gui_plugin_init', [V]), ('juno_gui_state_load', [V, C, I]),
                   ('juno_gui_load_patch', [V, C, I, I]), ('juno_gui_host_set', [V, I, I]),
                   ('juno_gui_note_on', [V, I, I]), ('juno_gui_note_off', [V, I]),
                   ('juno_gui_render', [V, ctypes.POINTER(F), I]), ('juno_gui_destroy', [V]),
                   ('juno_set_fp_oracle_mode', [I]), ('juno_gui_state', [V])):
        getattr(lib, fn).argtypes = at
    lib.juno_gui_state.restype = V
    lib.juno_gui_unit_noise.restype = V
    lib.juno_gui_unit_noise.argtypes = [V, I]
    import warm_render_gate as WR
    hdr = open(__import__('truth').BANK, 'rb').read()[:HEADER]
    red, total = {}, {}
    for ci, (fam, rate, sc) in enumerate(ref['_chains']):
        if ONLY is not None and ci != ONLY:
            continue
        c = lib.juno_gui_create(F(rate), 0)
        lib.juno_set_fp_oracle_mode(1)
        lib.juno_gui_plugin_init(c)
        outs = ref[ci]
        recs_want = pickle.loads(zlib.decompress(ref['_rrec'][ci]))
        oi = ck = 0
        bad = last = None
        for evi, ev in enumerate(sc):
            if ev[0] == 'patch':
                b = hdr + ref['_recs'][ev[1]]
                lib.juno_gui_load_patch(c, b, len(b), 0)
                last = '#%d patch %s' % (evi, ev[1])
            elif ev[0] == 'state':
                st = ref['_states'][ev[1]]
                lib.juno_gui_state_load(c, st, len(st))
                last = '#%d state %s' % (evi, ev[1])
            elif ev[0] == 'host':
                lib.juno_gui_host_set(c, ref['_hpid'][ev[1]][0], ev[2])
                last = '#%d host %s=%d' % (evi, ev[1], ev[2])
            elif ev[0] == 'on':
                lib.juno_gui_note_on(c, ev[1], ev[2] if len(ev) > 2 else 100)
            elif ev[0] == 'off':
                lib.juno_gui_note_off(c, ev[1])
            elif ev[0] == 'render':
                n = ev[1]
                buf = (F * (2 * n))()
                lib.juno_gui_render(c, buf, n)
                if TRACE is not None:
                    last = '#%d render %d' % (evi, n)
                got = np.frombuffer(bytes(buf), dtype='<u4')
                want = np.frombuffer(zlib.decompress(outs[oi]), dtype='<u4')
                oi += 1
                dd = np.nonzero((got[0::2] != want[:n]) | (got[1::2] != want[n:]))[0]
                if len(dd) and bad is None:
                    bad = 'after %s: render of %d differs from sample %d (%d samples)' % (last, n, int(dd[0]), len(dd))
            elif ev[0] == 'check':
                stp = lib.juno_gui_state(c)
                parts = []
                for v in range(8):
                    for a, b in HG.voice_regions(v):
                        # each plugin unit owns its noise block; the port keeps
                        # per-voice copies once a count below 8 ran (A21)
                        parts.append(ctypes.string_at(lib.juno_gui_unit_noise(c, v), b - a) if (a, b) == WR.SHARED
                                     else ctypes.string_at(stp + a, b - a))
                for a, b in HG.master_ranges():
                    parts.append(ctypes.string_at(stp + a, b - a))
                got = np.frombuffer(b''.join(parts), dtype='<u4')
                want = np.frombuffer(zlib.decompress(outs[oi]), dtype='<u4')
                oi += 1
                dd = np.nonzero(got != want)[0]
                if len(dd) and bad is None:
                    bad = 'after %s (check %d): %d state words differ: %s' % (
                        last, ck, len(dd), ' '.join('%s plug %08x port %08x' % (where(int(x)), int(want[x]), int(got[x])) for x in dd[:4]))
                rw = recs_want[ck]
                ck += 1
                rdiff = []
                for k, cell in enumerate(ref['_rcells']):
                    incr, accum, start, target, active, step = struct.unpack('<4Iii', ctypes.string_at(stp + RR_BASE + 32 + 32 * k, 24))
                    pw = (rw[k][0], 1 if rw[k][1] else 0) + tuple(rw[k][2:])
                    pg = (target, 1 if active else 0, start, incr, accum, step)
                    if pw[:2] != pg[:2] or (pw[1] and pw[2:] != pg[2:]):
                        rdiff.append((cell, pw, pg))
                if rdiff and bad is None:
                    bad = 'after %s: %d ramp records differ, first cell %d (target active start incr accum step) plug %s port %s' % (
                        last, len(rdiff), rdiff[0][0], ['%x' % x for x in rdiff[0][1]], ['%x' % x for x in rdiff[0][2]])
                if VERBOSE and (len(dd) or rdiff):
                    print('    [%s] check: %d state words, %d records differ' % (last, len(dd), len(rdiff)))
        lib.juno_gui_destroy(c)
        total[fam] = total.get(fam, 0) + 1
        if bad:
            red[fam] = red.get(fam, 0) + 1
            print('%s chain %d (%g Hz): %s' % (fam, ci, rate, bad))
    n_red = sum(red.values())
    print('\n=== PLUGIN PRESET PATHS (CLAIMS B6): initialize / setState / patch load, red chains per family: %s ==='
          % ', '.join('%s %d/%d' % (f, red.get(f, 0), total[f]) for f in total))
    print('GATE: %s' % ('FAIL' if n_red else 'PASS'))
    return 1 if n_red else 0


def where(w):
    """a compared word -> 'v<unit>:<offset>' / 'm:<offset>'"""
    import host_edit_gate as HG
    k = w * 4
    for v in range(8):
        for a, b in HG.voice_regions(v):
            if k < b - a:
                return 'v%d:%d' % (v, a + k)
            k -= b - a
    for a, b in HG.master_ranges():
        if k < b - a:
            return 'm:%d' % (a + k)
        k -= b - a
    return '?'


VERBOSE = '-v' in sys.argv
ONLY = None


def tooth():
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    gate = ['tools/verify/state_load_gate.py', '--port']
    T = [
        ('sl_patch_as_recall', 'the patch load is the recall the gates model (the old port)',
         [('gui/juno_bridge.c', '    for (k = 0; k < JUNO_PATCH_EV_N; ++k)\n        apply_event(c, JUNO_PATCH_EV[k].host, rec_value(r, &JUNO_PATCH_EV[k]));\n',
           '    (void)k; (void)r; juno_gui_apply_bank_live(c, bank, len, idx);\n')]),
        ('sl_patch_reversed', 'the patch load sets its values in reverse order',
         [('gui/juno_bridge.c', '    for (k = 0; k < JUNO_PATCH_EV_N; ++k)\n        apply_event(c, JUNO_PATCH_EV[k].host, rec_value(r, &JUNO_PATCH_EV[k]));\n',
           '    for (k = JUNO_PATCH_EV_N - 1; k >= 0; --k)\n        apply_event(c, JUNO_PATCH_EV[k].host, rec_value(r, &JUNO_PATCH_EV[k]));\n')]),
        ('sl_decode_masked', 'the record decode keeps the nibbles only',
         [('gui/juno_bridge.c', '    case JUNO_DEC_INT2X4: return (r[e->roff] << 4) | r[e->roff + 1];',
           '    case JUNO_DEC_INT2X4: return ((r[e->roff] & 15) << 4) | (r[e->roff + 1] & 15);')]),
        ('sl_no_state_mask', 'setState applies the payload value without the storage mask',
         [('gui/juno_bridge.c', '        if (JUNO_STATE_ENT[k].mask) v = (int32_t)((uint32_t)v & JUNO_STATE_ENT[k].mask);\n', '')]),
        ('sl_payload_reversed', 'setState applies its entries in reverse payload order',
         [('gui/juno_bridge.c', '    for (off = 0; off + 2 * w <= n; off += 2 * w) {',
           '    for (uint32_t rk = n / (2 * w); rk-- > 0 && ((off = rk * 2 * w), 1); ) {')]),
        ('sl_no_voices', 'the voice count entry is ignored',
         [('gui/juno_bridge.c', '    else if (host == JUNO_SE_VOICES) juno_gui_set_voice_count(c, v);\n', '')]),
        ('sl_no_init', 'initialize\'s defaults are not applied (the engine after BUILD)',
         [('gui/juno_bridge.c', '    for (k = 0; k < JUNO_STATE_N; ++k)\n        apply_event(c, JUNO_STATE_ENT[k].host, JUNO_STATE_ENT[k].dflt);\n', '')]),
    ]
    T += [
        ('sl_arp_flush', 'the arp switch flushes every note (the old port) instead of moving the keys',
         [('gui/juno_bridge.c', '    if (was != c->arp_on && c->host_role) {', '    if (was != c->arp_on && 0) {')]),
        ('sl_arp_order', 'the switch-off ignores the key-trig flag (always the press order)',
         [('gui/juno_bridge.c', '        } else if (c->kb_flag8 == 1 || c->kb_flag8 == 2) {', '        } else if (0) {')]),
        ('sl_arp_vel100', 'the switch-off re-plays at velocity 100, not the key\'s own',
         [('gui/juno_bridge.c', 'synth_note_on(c, key, c->kb_vel[key]); }', 'synth_note_on(c, key, 100); }')]),
        ('sl_keytrig_unsticky', 'a wild LFO KEY TRIG does not stick in the key-trig byte',
         [('gui/juno_bridge.c', '        c->kb_trig_mode <= 2 && (int)(signed char)c->kb_trig_mode != v) {',
           '        (int)(signed char)c->kb_trig_mode != v) {')]),
    ]
    R = [
        ('sl_model_nonparam', 'the model record takes the loaded record\'s non-parameter leaves',
         [('gui/juno_bridge.c', '    memcpy(c->bank + 23, r, 16);          /* the patch\'s name: display only */',
           '    memcpy(c->bank + 23, r, JUNO_REC_BYTES);')]),
    ]
    res = {}
    for name, what, edits in T + R:
        res[name] = run_tooth(name, edits, gate, tail=400)
    print()
    for name, what, edits in T:
        print('%-22s %-12s %s' % (name, {0: 'BITES', 1: 'DID NOT BITE', 2: 'NO VERDICT'}[res[name]], what))
    for name, what, edits in R:
        print('%-22s %-12s %s (reach probe)' % (name, {0: 'BITES', 1: 'NOT SEEN', 2: 'NO VERDICT'}[res[name]], what))
    return 0 if all(res[n] == 0 for n, w, e in T) else 1


def main():
    global ONLY, TRACE
    a = [x for x in sys.argv[1:] if x != '-v']
    if '--trace' in a:
        i = a.index('--trace')
        TRACE = int(a[i + 1])
        del a[i:i + 2]
    if '--chain' in a:
        i = a.index('--chain')
        ONLY = int(a[i + 1])
        del a[i:i + 2]
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
