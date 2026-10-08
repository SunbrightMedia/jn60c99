#!/usr/bin/env python3
"""bank_product_gate.py -- a WHOLE BANK through the plugin's own PRODUCT
path, plugin vs port: its patch browser's load (rva 0x335850) of every one of
the 64 records, played through its own IAudioProcessor::process (rva 0x34A380)
at the DEFAULT engine-rate setting (the engine at 96000, the plugin's rate
converter, rva 0x343E30) -- what a user hears who browses the bank in a DAW.

WHY. recall_render_ab.py grades the recall MODEL (juno_gui_apply_bank, one
cold engine per patch, one note, no arp patch). The product path differs:
the patch browser's values as host edits (MASTER TUNE, the H floats, the
extended leaves), the 4 ms recall ramps of a WARM engine, voices still
releasing and a key held across each load, steals at six voices, the arp
running on the host clock, the converter. Before this gate no bank went
through that path whole, the factory bank included.

THE SCRIPT IS THE SAME FOR EVERY PATCH (the harness knows nothing about a
patch, arp included): load; three keys at sample offsets and three
velocities; hold; release; a tail in which the next key goes down; the next
load with that key held. The transport plays at 120 BPM throughout, so a
patch with its arpeggiator on arpeggiates (on the plugin's own clock) and a
patch without it ignores the clock. 8 chains x 8 patches, one fresh instance
per chain: a divergence stays inside its chain.

--ref (Unicorn only, tools/verify/host_process_emu.py) -> a pickle per rate
     (truth.scratch: per bank). --jobs N runs chains in N processes.
--port (libjuno only): juno_gui_create + juno_gui_plugin_init + the plugin's
     boot state (queue_state) + juno_gui_queue_patch + juno_gui_process.
     Every sample of both channels must agree. FP mode as the oracle
     (playbook 120). The start: a muted prelude inside the 960-sample start-up
     mute, then a settle on both sides (the unsettled start-up is CLAIMS B15).
--tooth: the port check must FAIL on: one chain loading the next record
     (harness: the wrong patch); the chain's second key one sample late
     (harness; its first key falls inside the start-up mute, where one
     sample is inaudible -- that placement made the first tooth blind); the patch load as the recall model (juno_gui_apply_bank: the
     old port, a real defect class).

The bank resolves through truth.py: the factory bank in `make verify`, a user
bank through $JUNO_TRUTH (userbank_parity.py). A bank is INPUT; the plugin is
the oracle. Its isolation control is host_process_gate.py --control (the same
process() oracle == the path every engine gate trusts), run by `make verify`.

USAGE
    python3 tools/verify/bank_product_gate.py --ref [--rates 44100,48000] [--jobs 3]
    python3 tools/verify/bank_product_gate.py --port [--rates ...]
    python3 tools/verify/bank_product_gate.py --tooth [--rates ...]
"""
import gc
import os
import pickle
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import truth  # noqa: E402

HEADER, STRIDE, NAME = 23, 20223, 16
CHAINS, PER = 8, 8
B = 512
PRELUDE = 256          # host samples inside the start-up mute at every rate here
TEMPO = 120.0


def ref_pkl(rate):
    return truth.scratch('product_bank_ref_%d.pkl' % int(rate))


def segment(p, first):
    """the steps of one patch: ('patch', p) then ('blk', n, events)"""
    on = lambda off, k, v: ('on', off, 0, k, v)
    off = lambda o, k: ('off', o, 0, k, 0.5)
    st = [('patch', p)]
    st += [('blk', B, [on(37, 60, 0.8)])]
    st += [('blk', B, [on(5, 64, 0.6), on(300, 67, 1.0)] + ([] if first else [off(200, 48)]))]
    st += [('blk', B, [])] * 14
    st += [('blk', B, [off(0, 60), off(1, 64), off(2, 67)])]
    st += [('blk', B, [])] * 3
    st += [('blk', B, [on(400, 48, 0.7)])]          # held across the next load
    return st


def chain_steps(ci):
    st = []
    for j in range(PER):
        st += segment(ci * PER + j, j == 0)
    st += [('blk', B, [('off', 0, 0, 48, 0.5)])] + [('blk', B, [])] * 6
    return st


def chain_ref(args):
    """one chain through the plugin (a worker process: Unicorn only)"""
    ci, rate = args
    import host_process_emu as H
    import e2e_emu as E
    bank = E.bank_bytes()
    h = H.HostProcess()
    h.start(rate, 4096, setting=None)
    payload = h.get_state()
    h.process(PRELUDE)                    # the engine-rate change + the initial records, muted
    h.snap_all()                          # harness settle, as host_process_gate.py (B15 aside)
    PL, PR, marks = [], [], []
    ctx = dict(tempo=TEMPO, playing=True)
    for stp in chain_steps(ci):
        if stp[0] == 'patch':
            marks.append((stp[1], len(PL)))
            rec = bank[HEADER + stp[1] * STRIDE: HEADER + (stp[1] + 1) * STRIDE]
            h.load_patch(rec[NAME:])
        else:
            l, r = h.process(stp[1], events=stp[2], ctx=ctx)
            PL += l
            PR += r
    nr = len(h.renders)
    del h
    gc.collect()          # Unicorn's native memory: free the instance now (playbook 161)
    return ci, payload, PL, PR, marks, nr


def build_ref(rates, jobs, only=None):
    for rate in rates:
        work = [(ci, rate) for ci in range(CHAINS) if only is None or ci in only]
        if jobs > 1:
            import multiprocessing as mp
            with mp.get_context('spawn').Pool(jobs) as pool:
                res = pool.map(chain_ref, work, chunksize=1)
        else:
            res = [chain_ref(w) for w in work]
        ref = {'rate': rate, 'bank': truth.BANK, 'chains': {}}
        f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
        for ci, payload, PL, PR, marks, nr in sorted(res):
            ref['chains'][ci] = (payload, PL, PR, marks)
            sys.stderr.write('ref %g chain %d: patches %s, %d samples, peak %.5f, engine renders %d\n' % (
                rate, ci, [m[0] for m in marks], len(PL), max(abs(f(x)) for x in PL + PR), nr))
        out = ref_pkl(rate)
        pickle.dump(ref, open(out + '.partial', 'wb'))     # whole or nothing (playbook 142)
        os.replace(out + '.partial', out)
        print('wrote', out)
    return 0


def check_port(rates, tooth=None, verbose=False):
    import ctypes
    import freshlib
    lib = freshlib.load()
    V = ctypes.c_void_p

    class Note(ctypes.Structure):
        _fields_ = [('offset', ctypes.c_int), ('type', ctypes.c_int), ('channel', ctypes.c_int),
                    ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_state.restype = V
    lib.juno_gui_state.argtypes = [V]
    lib.juno_rr_settle.argtypes = [V]
    for fn, at in (('juno_gui_plugin_init', [V]), ('juno_gui_destroy', [V]),
                   ('juno_gui_queue_state', [V, ctypes.c_char_p, ctypes.c_int]),
                   ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                   ('juno_gui_apply_bank', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                   ('juno_gui_process', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.c_int, ctypes.c_double,
                                         ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float), ctypes.c_int])):
        getattr(lib, fn).argtypes = at
    lib.juno_set_fp_oracle_mode.argtypes = [ctypes.c_int]
    bank = open(truth.BANK, 'rb').read()
    f = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]
    bad = 0
    for rate in rates:
        pk = ref_pkl(rate)
        if not os.path.exists(pk):
            print('MISSING %s -- run --ref first' % pk)
            return 2
        ref = pickle.load(open(pk, 'rb'))
        if os.path.realpath(ref['bank']) != os.path.realpath(truth.BANK):
            print('STALE %s: made from %s, the bank in force is %s' % (pk, ref['bank'], truth.BANK))
            return 2
        for ci in sorted(ref['chains']):
            payload, RL, RR, marks = ref['chains'][ci]
            c = lib.juno_gui_create(ctypes.c_float(rate), 0)
            lib.juno_set_fp_oracle_mode(1)        # after create, which sets the production FTZ
            lib.juno_gui_plugin_init(c)
            lib.juno_gui_queue_state(c, payload, len(payload))
            L0, R0 = (ctypes.c_float * PRELUDE)(), (ctypes.c_float * PRELUDE)()
            lib.juno_gui_process(c, (Note * 1)(), 0, 0, TEMPO, L0, R0, PRELUDE)
            lib.juno_rr_settle(lib.juno_gui_state(c))
            PL, PR = [], []
            nblk = 0
            for stp in chain_steps(ci):
                if stp[0] == 'patch':
                    p = stp[1]
                    if tooth == 'wrong_patch' and ci == 0 and p == 3:
                        p = 4
                    if tooth == 'recall_model':
                        lib.juno_gui_apply_bank(c, bank, len(bank), p)
                    else:
                        lib.juno_gui_queue_patch(c, bank, len(bank), p)
                    continue
                _, n, evs = stp
                nblk += 1
                if tooth == 'late_note' and ci == 0 and nblk == 2:
                    # the second key one sample late (the first one falls inside
                    # the start-up mute, where a sample's shift is inaudible)
                    k_, o_, ch_, p_, v_ = evs[0]
                    evs = [(k_, o_ + 1, ch_, p_, v_)] + list(evs[1:])
                arr = (Note * max(1, len(evs)))()
                for i, (k, o, ch, pch, vel) in enumerate(evs):
                    arr[i] = Note(o, 0 if k == 'on' else 1, ch, pch, vel)
                L, R = (ctypes.c_float * n)(), (ctypes.c_float * n)()
                lib.juno_gui_process(c, arr, len(evs), 1, TEMPO, L, R, n)
                PL += list(struct.unpack('<%dI' % n, bytes(L)))
                PR += list(struct.unpack('<%dI' % n, bytes(R)))
            lib.juno_gui_destroy(c)
            diff = [i for i in range(len(RL)) if RL[i] != PL[i] or RR[i] != PR[i]]
            ends = [m[1] for m in marks[1:]] + [len(RL)]
            seg = []
            for (p, s0), s1 in zip(marks, ends):
                d = [i for i in diff if s0 <= i < s1]
                seg.append((p, d))
            if diff:
                bad += 1
                p0 = next(p for p, d in seg if d)
                i0 = diff[0]
                print('%-6g chain %d %7d samples: %d differ, first at %d in patch %d (plugin %.6g, port %.6g)' % (
                    rate, ci, len(RL), len(diff), i0, p0, f(RL[i0]), f(PL[i0])))
            else:
                print('%-6g chain %d %7d samples: BIT-EXACT  patches %s' % (rate, ci, len(RL), [m[0] for m in marks]))
            if verbose and diff:
                for p, d in seg:
                    print('      patch %2d: %s' % (p, 'exact' if not d else '%d differ from %d' % (len(d), d[0])))
    if tooth:
        return bad
    print('\n=== BANK THROUGH THE PRODUCT PATH: the plugin\'s patch browser + its own process(), %s ===' % truth.BANK)
    print('GATE: %s' % ('FAIL' if bad else 'PASS'))
    return 1 if bad else 0


def main():
    argv = sys.argv[1:]
    rates = [44100.0, 48000.0]
    if '--rates' in argv:
        rates = [float(x) for x in argv[argv.index('--rates') + 1].split(',')]
    jobs = int(argv[argv.index('--jobs') + 1]) if '--jobs' in argv else 1
    mode = argv[0] if argv else ''
    only = None
    if '--chains' in argv:
        only = [int(x) for x in argv[argv.index('--chains') + 1].split(',')]
    if mode == '--ref':
        return build_ref(rates, jobs, only)
    if mode == '--port':
        return check_port(rates, verbose='-v' in argv)
    if mode == '--tooth':
        res = {t: check_port(rates, tooth=t) for t in ('wrong_patch', 'late_note', 'recall_model')}
        print()
        for t, b in res.items():
            print('%-13s %s (%d chains differ)' % (t, 'BITES' if b else 'DID NOT BITE', b))
        return 0 if all(res.values()) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
