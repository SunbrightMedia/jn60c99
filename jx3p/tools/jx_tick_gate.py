#!/usr/bin/env python3
"""jx_tick_gate.py -- the engine's clock tick and the note store's step machine (jx3p/src/jx_seq.c) against
the plugin's own code, event by event (two processes: Unicorn here, ctypes in a child).

ORACLE  tools/verify/jx_emu.py boot(44100, product=True, patch=k): the engine after the plugin's own boot and
        patch load; then the plugin's own entries: the tick (vtable +0xB8, rva 0x3F84A0, called with the
        HOST as the render driver calls it) and the note fan-outs (0x3F9150 / 0x3F90F0).
PORT    jx3p/gui/jx_bridge.c: jx3p_init + jx3p_recall(k), then jx3p_tick / jx3p_note_on / jx3p_note_off.

A seeded sequence per run: runs of ticks (to and past the 12- and 24-tick boundaries) with note-ons and
note-offs among them. After every event the 36 control objects (each unit's note manager, note store
-- its whole allocation, the pattern pointer as its offset --, assigner and parameter object) are
compared; every unit's state at checkpoints and at the end. The factory patches that play on the clock:
34 (step mode 6), 61 (mode 3); 0, 38 and 20 (mode 0) as controls.

THE STEP MODES (jx3p/docs/HOST_LAYER.md 3e). The step machine is the arpeggiator. Its step function is
one of 19 (the mode setter 0x3F1910); the apply picks it from ARPEGGIO TYPE (record 53, the template:
modes 0, 6, 3), SCATTER TYPE / DEPTH (model ids 0x600120 / 0x600128: rows 8 and 9 turn the template's
mode into 2, 5, 8 or 10) and the store's +0xDA1 (modes 15-18; nothing writes it). No product path
sends SCATTER (no patch record, no DAW-state entry, no editor control, not initialize: EXECUTED +
READ), so the PRODUCT reaches modes 0, 3, 6 (REACHABLE) and the engine's own host entry 2, 5, 8, 10
more (ENTRY). --variants loads states through the plugin's own patch load (factory records with values
changed, or a SCATTER record appended -- class ENTRY: jx_master_recall_export.variant_records; the port
gets their recall data from the same exporter). --setmode puts every mode, the 12 no entry reaches
included, into every unit's store through the plugin's own setter (the port: its transcription) after
factory patch 34's load: the step functions graded on states no input makes.

    python3 jx3p/tools/jx_tick_gate.py [--patches 34,61,0,38,20] [--variants 'S1;S2' | --no-variants]
                                       [--setmode 0-18 | --no-setmode] [--events 1500] [--variant-events 600]
                                       [--setmode-events 400] [--seed 1] [--tooth]
  --tooth: the port built with JX_SEQ_TOOTH (the note store's tick skips its step clock) -- must differ.
exit 0 = every object equal after every event, every state equal at every checkpoint, every run that
should play played, and the graded modes cover REACHABLE (product runs), ENTRY (with the SCATTER
variants) and all 19 (the setter).
"""
import ctypes
import hashlib
import json
import os
import random
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
TICK = 0x3F84A0
SIZES = (0x7A8, 0xFF0, 0xB0)
SNAP_V, STATE_END = 0x60000, 0xAAC310
CHECK = 100                                   # unit states every CHECK events and at the end
PLAYS = (34, 61)                              # factory patches whose step machine plays (EXECUTED, jx_product_gate)
SETMODE = 0x3F1910                            # the note store's mode setter (its jump table: 0x3F1A50)
REACHABLE = {0, 3, 6}                         # the modes the product reaches (docstring; HOST_LAYER.md 3e)
ENTRY = {0, 2, 3, 5, 6, 8, 10}                # ... and the engine's host entry, with SCATTER
SCATTER = ('+0x600120', '+0x600128')          # a variant appending one of these is class ENTRY
# each a mode the factory bank does not hold, or the template / range values around it (printed per run)
# (mode 0 steps only with the ARPEGGIO switch on: the factory mode-0 patches never step -- the first full
# run's coverage check refused for exactly that, job jx7_ticks)
VARIANTS = ('34:+0x600120=8;61:+0x600120=8;0:52=1,+0x600120=8;0:52=1,53=5,+0x600120=8;34:+0x600120=9;'
            '61:+0x600120=9;34:+0x600120=9,+0x600128=-6;34:53=3;34:53=4,54=5;61:54=0;0:52=1;34:53=0')


def mode_table(J):
    """the step function -> mode, read from the setter's own jump table (each case: lea rax, [rip+d])"""
    img = bytes(J.IMG)
    out = {}
    for k in range(19):
        case = struct.unpack_from('<I', img, 0x3F1A50 + 4 * k)[0]
        if img[case:case + 3] != bytes.fromhex('488d05'):
            raise SystemExit('the mode setter\'s case %d is not lea rax, [rip+d]' % k)
        out[case + 7 + struct.unpack_from('<i', img, case + 3)[0]] = k
    return out


def events(seed, n, chord=False):
    """('t',) a tick; ('on', note, vel); ('off', note). chord: three keys down first (the variant and setter
    runs, whose step machine must step: a run of ticks with no key held grades nothing)"""
    r = random.Random(seed)
    held, out = [], []
    if chord:
        for note in (48, 55, 60):
            out.append(('on', note, r.randrange(1, 128)))
            held.append(note)
    while len(out) < n:
        k = r.random()
        if k < 0.55:
            out += [('t',)] * r.choice((1, 1, 2, 3, 6, 11, 12, 13, 24))
        elif k < 0.8 and len(held) < 10:
            note = r.randrange(36, 85)
            out.append(('on', note, r.randrange(1, 128)))
            if note not in held:
                held.append(note)
        elif held:
            note = held.pop(r.randrange(len(held)))
            out.append(('off', note))
    return out[:n]


def digest(b):
    return hashlib.sha256(b).hexdigest()[:16]


def states_digest(blobs):
    out = []
    for u, b in enumerate(blobs):
        b = bytearray(b)
        b[136:144] = bytes(8)
        b[0x78:0x80] = bytes(8)
        if u == 8:
            b[0xAAC308:0xAAC30C] = bytes(4)
        out.append(digest(bytes(b)))
    return out


def oracle_load(load):
    """the plugin after the load: {'patch': k} its patch browser's load of factory patch k; {'variant': spec}
    a variant's records through its host entry; 'setmode': m then its setter on every unit's store"""
    sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
    sys.path.insert(0, HERE)
    import jx_emu as J
    if 'variant' in load:
        import jx_master_recall_export as X
        jx = J.JX().boot(44100.0, snap=False, product=True)
        jx.host_records(X.variant_records(load['variant']))
    else:
        jx = J.JX().boot(44100.0, snap=False, product=True, patch=load['patch'])
    rq = lambda a: int.from_bytes(jx.uc.mem_read(a, 8), 'little')
    stores = [rq(rq(jx.HOST + 0x78 + 0x40 * u) + 0x518) for u in range(9)]
    if 'setmode' in load:
        for a in stores:
            jx.call(J.IB + SETMODE, rcx=a, rdx=load['setmode'], count=1_000_000)
    tab = mode_table(J)
    modes = [tab.get(rq(a + 0xD98) - J.IB, -1) for a in stores]
    return J, jx, modes


def oracle(load, evs):
    import jx_template_export as T
    J, jx, modes = oracle_load(load)
    uc = jx.uc
    res = []
    for i, e in enumerate(evs):
        if e[0] == 't':
            jx.call(J.IB + TICK, rcx=jx.HOST, count=50_000_000)
        elif e[0] == 'on':
            jx.note_on(e[1], e[2])
        else:
            jx.note_off(e[1])
        row = {'ctl': [digest(b) for b in T.control_blobs(jx)]}
        if (i + 1) % CHECK == 0 or i + 1 == len(evs):
            row['st'] = states_digest([bytes(uc.mem_read(jx.state[u], SNAP_V if u < 8 else STATE_END))
                                       for u in range(9)])
        res.append(row)
    res[0]['modes'] = modes
    return res


def port(so, load, evs, want_raw=None):
    lib = ctypes.CDLL(so)
    for f in ('jx3p_vstate', 'jx3p_mstate', 'jx3p_ctl'):
        getattr(lib, f).restype = ctypes.c_void_p
    lib.jx3p_bad_hook.restype = ctypes.c_ulonglong
    g = lambda p: os.path.join(REPO, 'jx3p', p).encode()
    aux = load['aux'].encode() if 'variant' in load else g('gen/jx_master_recall.bin')
    if not lib.jx3p_init(g('gen/jx_template.bin'), g('truth/preset_bank_1.bin'), aux):
        raise SystemExit('jx3p_init failed')
    lib.jx3p_recall(load['index'] if 'variant' in load else load['patch'])
    if 'setmode' in load:
        lib.jx3p_seq_set_mode(load['setmode'])
    res = []
    for i, e in enumerate(evs):
        if e[0] == 't':
            lib.jx3p_tick()
        elif e[0] == 'on':
            lib.jx3p_note_on(e[1], e[2])
        else:
            lib.jx3p_note_off(e[1])
        ctl = [ctypes.string_at(lib.jx3p_ctl(w, u), SIZES[w]) for u in range(9) for w in range(3)]
        ctl += [ctypes.string_at(lib.jx3p_ctl(3, u), 0x700) for u in range(9)]
        row = {'ctl': [digest(b) for b in ctl]}
        if (i + 1) % CHECK == 0 or i + 1 == len(evs):
            row['st'] = states_digest([ctypes.string_at(lib.jx3p_vstate(u), SNAP_V) if u < 8 else
                                       ctypes.string_at(lib.jx3p_mstate(), STATE_END) for u in range(9)])
        if want_raw is not None and i == want_raw:
            row['raw'] = [b.hex() for b in ctl]
        res.append(row)
        if i + 1 == len(evs):
            st = (ctypes.c_ulong * 3)(); lib.jx3p_seq_stats(st)
            md = (ctypes.c_ulong * 19)(); lib.jx3p_seq_modes(md)
            row['reach'], row['mode_calls'] = list(st), list(md)
        if lib.jx3p_bad_hook():
            res[-1]['bad_hook'] = '%X' % lib.jx3p_bad_hook()
            break
    return res


def oracle_raw(load, evs, upto):
    import jx_template_export as T
    J, jx, _ = oracle_load(load)
    for e in evs[:upto + 1]:
        if e[0] == 't':
            jx.call(J.IB + TICK, rcx=jx.HOST, count=50_000_000)
        elif e[0] == 'on':
            jx.note_on(e[1], e[2])
        else:
            jx.note_off(e[1])
    return [b.hex() for b in T.control_blobs(jx)]


NAMES = ['%s%d' % (w, u) for u in range(9) for w in ('mgr', 'ns', 'asg')] + ['proc%d' % u for u in range(9)]


def modes_arg(x):
    """'0-18' or '1,4,7'"""
    out = []
    for part in filter(None, x.split(',')):
        lo, _, hi = part.partition('-')
        out += list(range(int(lo), int(hi or lo) + 1))
    return out


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle(json.loads(a[1]), json.loads(open(a[2]).read())), sys.stdout)
        return 0
    if a[:1] == ['--oracle-raw']:
        json.dump(oracle_raw(json.loads(a[1]), json.loads(open(a[2]).read()), int(a[3])), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], json.loads(a[2]), json.loads(open(a[3]).read()), int(a[4]) if len(a) > 4 else None),
                  sys.stdout)
        return 0
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    patches = [int(x) for x in opt('--patches', '34,61,0,38,20').split(',') if x]
    variants = [] if '--no-variants' in a else [v for v in opt('--variants', VARIANTS).split(';') if v]
    setmodes = [] if '--no-setmode' in a else modes_arg(opt('--setmode', '0-18'))
    nev, nvar, nset = int(opt('--events', '1500')), int(opt('--variant-events', '600')), int(opt('--setmode-events', '400'))
    seed, tooth = int(opt('--seed', '1')), '--tooth' in a
    full = not any(k in a for k in ('--patches', '--variants', '--no-variants', '--setmode', '--no-setmode'))
    tmp = tempfile.mkdtemp()
    so = os.path.join(tmp, 'libjx3p.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] +
                   (['-DJX_SEQ_TOOTH=1'] if tooth else []) + [os.path.join(REPO, s) for s in SRCS] + ['-lm'], check=True)
    # (label, load, events, seed, must play)
    runs = [('patch %d' % k, {'patch': k}, nev, seed * 1000 + k, k in PLAYS) for k in patches]
    if variants:
        aux = os.path.join(tmp, 'variants.bin')
        x = subprocess.run([sys.executable, os.path.join(HERE, 'jx_master_recall_export.py'), '--variants',
                            ';'.join(variants), '--out', aux], capture_output=True, text=True)
        if x.returncode:
            raise SystemExit('variant export failed: ' + x.stderr[-1500:])
        runs += [('variant %s' % sp, {'variant': sp, 'index': i, 'aux': aux}, nvar, seed * 1000 + 200 + i, True)
                 for i, sp in enumerate(variants)]
    runs += [('mode %d (the setter, after patch 34)' % m, {'patch': 34, 'setmode': m}, nset, seed * 1000 + 300 + m, True)
             for m in setmodes]
    bad, bitten, graded, graded_entry, graded_set = 0, 0, set(), set(), set()
    for label, load, n, sd, must in runs:
        evs = events(sd, n, chord='patch' not in load or 'setmode' in load)
        ef = os.path.join(tmp, 'ev%d.json' % sd)
        open(ef, 'w').write(json.dumps(evs))
        lj = json.dumps(load)
        o = subprocess.run([sys.executable, __file__, '--oracle', lj, ef], capture_output=True, text=True)
        if o.returncode:
            raise SystemExit('oracle failed (%s): %s' % (label, o.stderr[-1500:]))
        p = subprocess.run([sys.executable, __file__, '--port', so, lj, ef], capture_output=True, text=True)
        if p.returncode:
            raise SystemExit('port failed (%s): %s' % (label, p.stderr[-1500:]))
        ro, rp = json.loads(o.stdout), json.loads(p.stdout)
        modes = ro[0]['modes']
        mtxt = 'mode %d' % modes[0] if len(set(modes)) == 1 else 'modes %s' % modes
        first = next((i for i in range(min(len(ro), len(rp))) if ro[i]['ctl'] != rp[i]['ctl'] or
                      ('st' in ro[i] and ro[i].get('st') != rp[i].get('st'))), None)
        nticks = sum(1 for e in evs if e[0] == 't')
        if rp and 'bad_hook' in rp[-1]:
            print('  %s (%s): the port met a step function it does not hold: rva %s (event %d)' % (
                label, mtxt, rp[-1]['bad_hook'], len(rp) - 1))
            bad += 1
            continue
        if first is None and len(ro) == len(rp):
            reach, calls = rp[-1].get('reach', [0, 0, 0]), rp[-1].get('mode_calls', [0] * 19)
            ran = [m for m in range(19) if calls[m]]
            print('  %s (%s): %d events (%d ticks) -- every object equal after every event, the states at %d '
                  'checkpoints; the step machine chose %d times (modes %s), played %d notes, released %d' % (
                      label, mtxt, len(evs), nticks, sum(1 for r in ro if 'st' in r), reach[0],
                      ','.join(map(str, ran)) or '-', reach[1], reach[2]), flush=True)
            if must and not (reach[0] and all(calls[m] for m in set(modes) if 0 <= m < 19)):
                print('  REFUSE: %s should step in %s, but its step function did not run -- no reach' % (
                    label, mtxt))
                bad += 1
                continue
            if 'setmode' in load:
                graded_set.update(ran)
            elif any(x in load.get('variant', '') for x in SCATTER):
                graded_entry.update(ran)
            else:
                graded.update(ran)
            continue
        bad += 1
        bitten += 1
        if first is None:
            print('  %s (%s): the runs differ in length (%d / %d events)' % (label, mtxt, len(ro), len(rp)))
            continue
        which = [NAMES[j] for j in range(36) if ro[first]['ctl'][j] != rp[first]['ctl'][j]]
        sts = [u for u in range(9) if 'st' in ro[first] and ro[first]['st'][u] != rp[first]['st'][u]]
        print('  %s (%s): first difference after event %d %s: objects %s states %s' % (
            label, mtxt, first, evs[first], ' '.join(which), sts), flush=True)
        if which and not tooth:
            oraw = json.loads(subprocess.run([sys.executable, __file__, '--oracle-raw', lj, ef, str(first)],
                                             capture_output=True, text=True, check=True).stdout)
            praw = [r for r in json.loads(subprocess.run([sys.executable, __file__, '--port', so, lj, ef, str(first)],
                                                         capture_output=True, text=True, check=True).stdout)
                    if r.get('raw')][0]['raw']
            for j in [NAMES.index(w) for w in which][:3]:
                x, y = bytes.fromhex(oraw[j]), bytes.fromhex(praw[j])
                d = [k for k in range(0, len(x), 4) if x[k:k + 4] != y[k:k + 4]]
                print('    %s: %d words: %s' % (NAMES[j], len(d), ' '.join('+0x%x(o %08x p %08x)' % (
                    k, struct.unpack_from('<I', x, k)[0], struct.unpack_from('<I', y, k)[0]) for k in d[:8])))
    if tooth:
        print('jx_tick_gate --tooth: %s' % ('BITES (%d of %d)' % (bitten, len(runs)) if bitten == len(runs) else
                                            'DID NOT BITE on %d of %d' % (len(runs) - bitten, len(runs))))
        return 0 if bitten == len(runs) else 1
    txt = lambda m: ','.join(map(str, sorted(m))) or '-'
    print('  graded through product patch loads: modes %s; with SCATTER through the engine\'s entry: modes %s; '
          'through the setter: modes %s' % (txt(graded), txt(graded_entry), txt(graded_set)))
    if full and not bad:
        if not REACHABLE <= graded:
            print('  REFUSE: the product reaches modes %s, the patch loads graded %s' % (sorted(REACHABLE), sorted(graded)))
            bad += 1
        if not ENTRY <= graded | graded_entry:
            print('  REFUSE: the engine\'s entry reaches modes %s, the variants graded %s' % (
                sorted(ENTRY), sorted(graded | graded_entry)))
            bad += 1
        if set(range(19)) - graded_set:
            print('  REFUSE: the setter runs left modes %s ungraded' % sorted(set(range(19)) - graded_set))
            bad += 1
    print('jx_tick_gate: %d of %d runs equal event by event: %s' % (len(runs) - bad, len(runs),
                                                                    'GREEN' if not bad else 'RED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
