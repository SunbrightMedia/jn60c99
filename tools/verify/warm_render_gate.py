#!/usr/bin/env python3
"""warm_render_gate.py -- patch changes on a RUNNING engine: chains of recalls
with notes and renders between them, plugin vs port, audio + state (CLAIMS B1).

warm_chain_gate.py compares the object after every recall but never renders,
so it cannot see what a recall does to state that only a render reads or
writes: the reverb tank-clear counter, ring buffers, fades, ramps in flight.
This gate plays each chain: per step
    recall -> render 64 -> note on -> render 512 -> note off -> render 1024
and compares every rendered sample (L and R bits) and, at the end of every
step, the state each plugin unit RENDERS: voice v's main block, aux pair and
shared block from unit v (as note_bcast_gate.py), and the master region from
unit 8 (the unit that renders the master), against the port's one state.

MODES
  settled  plugin: recall_render_ab.apply_recall (dispatch, then the harness
           snap settles every ramp); port: juno_gui_apply_bank.
  live     plugin: the same dispatch with NO snap, so the plugin's own recall
           ramps run in the renders (CLAIMS B1: 4 ms, about 21 cells per unit);
           port: juno_gui_apply_bank_live. The first recall of every chain is a
           settled one on both sides (a cold engine; B1 is about patch CHANGES).

FAMILIES (records built by --ref and stored in the pickle; --port replays them)
  pool   4 x 8  factory patches + synthetic DELAY/EFFECT TYPE variants
  seed   4 x 8  legal seeded records (every recalled leaf random)
  revl   2 x 8  REVERB LEVEL 0/1/2/3/200 and DELAY LEVEL 0/1/2 across steps:
                the reverb on/off threshold and its tank-clear counter
  rapid  2 x 12 recalls 100 samples apart, notes held across them (live mode:
                a recall lands while the previous recall's ramps are in flight)

LIMITS, stated: the recall order and leaf set are the harness model (CLAIMS
B6); legal values only (B8); host rates 44100 / 48000 / 96001.

TWO-PROCESS RULE: --ref (Unicorn only) writes scratchpad/warm_render_<mode>.pkl;
--port (libjuno only) reads it.

TOOTH (--tooth): three assigner defects this gate found, each restored in a
copy of the tree, must turn --port settled red: unison ageing all 8 voices,
the voice flush on every load, and the note slots kept after that flush.

FP MODE: the oracle (Unicorn) honours DAZ but not FTZ, so --port runs the port
in that mode (juno_set_fp_oracle_mode, src/juno_ftz.c; playbook 120).

USAGE
    python3 tools/verify/warm_render_gate.py --ref settled|live
    python3 tools/verify/warm_render_gate.py --port settled|live [-v] [--chain N]
    python3 tools/verify/warm_render_gate.py --tooth
"""
import gc
import os
import sys
import pickle
import random
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')

HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
OBJ_END = 0xA83010
VSTRIDE, MAIN0 = 10512, 176
AUX0, AUXN = 101488, 32
SHARED = (84272, 84436)
MASTER = (84436, OBJ_END)            # unit 8's copy, minus the 8 voices' aux pairs
RATES = [44100.0, 48000.0, 96001.0]
REC_DTYPE, REC_ETYPE = 650, 634
DISP_RLEVEL, DISP_DLEVEL, DISP_ARP = 795, 796, 831
NOTES = [48, 55, 60, 64, 67, 72, 52, 59]


def ref_pkl(mode):
    return os.path.join(SCRATCH, 'warm_render_%s.pkl' % mode)


def record_bank(bank, base, sets):
    rec = bytearray(bank[HEADER + base * STRIDE: HEADER + (base + 1) * STRIDE])
    for off, v in sets.items():
        rec[off] = (v >> 4) & 0xF
        rec[off + 1] = v & 0xF
    return bytes(bank[:HEADER]) + bytes(rec)


def chains(bank):
    """[(family, rate, script)]; script = [('recall', name, bank bytes) |
    ('on', note) | ('off', note) | ('render', n) | ('check',)]. --ref only."""
    sys.path.insert(0, HERE)
    import real_recall as R
    import seed_recall_gate as S
    import warm_chain_gate as W
    leaf = dict(R.leaf_table())
    rlev, dlev = leaf[DISP_RLEVEL] + BLOB_OFF, leaf[DISP_DLEVEL] + BLOB_OFF
    arp = leaf[DISP_ARP] + BLOB_OFF

    def noarp(rb):
        # ARPEGGIO SW off in every record: the oracle has no transport clock and
        # cannot arpeggiate (as seed_recall_gate.py HOLD); the port would
        rec = bytearray(rb)
        rec[HEADER + arp] = 0
        rec[HEADER + arp + 1] = 0
        return bytes(rec)

    def step(name, rb, k):
        rb = noarp(rb)
        n = NOTES[k % len(NOTES)]
        return [('recall', name, rb), ('render', 64), ('on', n), ('render', 512),
                ('off', n), ('render', 1024), ('check',)]

    out = []
    P = W.pool()
    for c in range(4):
        rnd = random.Random(2000 + c)
        sc = []
        for k in range(8):
            n, b, s = P[rnd.randrange(len(P))]
            sc += step(n, record_bank(bank, b, s), k)
        out.append(('pool', RATES[c % 3], sc))
    slots, ranges = S.leaf_slots(), S.declared_ranges()
    for c in range(4):
        sc = []
        for k in range(8):
            seed = 7000 + c * 8 + k
            rb, _, _ = S.seed_bank(bank, seed, slots, ranges, wild=False)
            sc += step('s%d' % seed, rb, k)
        out.append(('seed', RATES[(c + 1) % 3], sc))
    RL = (200, 0, 3, 2, 200, 1, 0, 3)
    DL = (2, 1, 0, 1, 2, 2, 0, 1)
    for c in range(2):
        sc = []
        for k in range(8):
            base = (11 * (c * 8 + k)) % 64
            sets = {rlev: RL[(k + c) % 8], dlev: DL[(k + 3 * c) % 8]}
            sc += step('r%d_R%dD%d' % (base, sets[rlev], sets[dlev]), record_bank(bank, base, sets), k)
        out.append(('revl', RATES[c % 3], sc))
    for c in range(2):
        rnd = random.Random(3000 + c)
        n, b, s = P[rnd.randrange(len(P))]
        sc = [('recall', n, noarp(record_bank(bank, b, s))), ('render', 64), ('on', 60), ('on', 64)]
        for k in range(12):
            n, b, s = P[rnd.randrange(len(P))]
            sc += [('recall', n, noarp(record_bank(bank, b, s))), ('render', 100)]
            if k % 4 == 3:
                sc += [('off', 60), ('render', 50), ('on', 60)]
            sc += [('check',)]
        sc += [('off', 60), ('off', 64), ('render', 2048), ('check',)]
        out.append(('rapid', RATES[(c + 2) % 3], sc))
    return out


# ------------------------------------------------------------------ regions
def voice_regions(v):
    return [(MAIN0 + v * VSTRIDE, MAIN0 + (v + 1) * VSTRIDE), (AUX0 + v * AUXN, AUX0 + (v + 1) * AUXN), SHARED]


def master_ranges():
    return [(MASTER[0], AUX0), (AUX0 + 8 * AUXN, MASTER[1])]


# --------------------------------------------------------------------- oracle
def build_ref(mode):
    import zlib
    sys.path.insert(0, HERE)
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    from array import array
    bank = E.bank_bytes()
    lt = R.leaf_table()
    ch = chains(bank)
    ref = {'_mode': mode, '_chains': []}
    for ci, (fam, rate, sc) in enumerate(ch):
        e = RR.build_engine(E, rate)
        first = True
        outs = []
        active = []
        for ev in sc:
            if ev[0] == 'recall':
                # ramps already running when this recall lands (a snap would settle them too)
                active.append(sum(e.active_smoothers(u) for u in range(9)))
                if first or mode == 'settled':
                    RR.apply_recall(e, 0, ev[2], lt, E, R)
                    first = False
                else:
                    blob = E.patch_blob(ev[2], 0)
                    late = RR.late_leaves(blob, R)
                    for (d, bb) in lt:
                        R.wr_desc(e, d, R.dec(blob, bb))
                    for (d, v) in late:
                        R.wr_desc(e, d, v)
                    for u in range(9):
                        for (d, _) in lt:
                            try: e.dispatch(u, d, R.rd_desc(e, d))
                            except RuntimeError: pass
                        for (d, _) in late:
                            try: e.dispatch(u, d, R.rd_desc(e, d))
                            except RuntimeError: pass
                    e.assigner_notify()
            elif ev[0] == 'on':
                e.note_on(ev[1], 100)
            elif ev[0] == 'off':
                e.note_off(ev[1])
            elif ev[0] == 'render':
                L, Rr = e.render(ev[1])
                outs.append(zlib.compress(array('I', L).tobytes() + array('I', Rr).tobytes(), 6))
            elif ev[0] == 'check':
                parts = []
                for v in range(8):
                    for a, b in voice_regions(v):
                        parts.append(bytes(e.uc.mem_read(e.state[v] + a, b - a)))
                for a, b in master_ranges():
                    parts.append(bytes(e.uc.mem_read(e.state[8] + a, b - a)))
                outs.append(zlib.compress(b''.join(parts), 6))
        ref['_chains'].append((fam, rate, [(ev[0], ev[1], zlib.compress(ev[2], 6)) if ev[0] == 'recall' else ev
                                           for ev in sc]))
        ref[ci] = outs
        ref.setdefault('_active', {})[ci] = active
        del e
        gc.collect()
        sys.stderr.write('ref %s chain %d %s (%g Hz): %d events\n' % (mode, ci, fam, rate, len(sc)))
        sys.stderr.flush()
    pickle.dump(ref, open(ref_pkl(mode), 'wb'))
    print('wrote %s (%d chains)' % (ref_pkl(mode), len(ch)))
    return 0


# ----------------------------------------------------------------------- port
def check_port(mode):
    import ctypes
    import zlib
    import numpy as np
    sys.path.insert(0, HERE)
    import freshlib
    p = ref_pkl(mode)
    if not os.path.exists(p):
        print('MISSING %s -- run --ref %s first' % (p, mode))
        return 2
    ref = pickle.load(open(p, 'rb'))
    lib = freshlib.load()
    V, I, F, C = ctypes.c_void_p, ctypes.c_int, ctypes.c_float, ctypes.c_char_p
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [F, I]
    lib.juno_gui_apply_bank.argtypes = [V, C, I, I]
    live = None
    if mode == 'live':
        if not hasattr(lib, 'juno_gui_apply_bank_live'):
            print('libjuno has no juno_gui_apply_bank_live -- the live recall is not ported (CLAIMS B1)')
            print('GATE: FAIL')
            return 1
        live = lib.juno_gui_apply_bank_live
        live.argtypes = [V, C, I, I]
    lib.juno_gui_state.restype = V
    lib.juno_gui_state.argtypes = [V]
    lib.juno_gui_note_on.argtypes = [V, I, I]
    lib.juno_gui_note_off.argtypes = [V, I]
    lib.juno_gui_render.argtypes = [V, ctypes.POINTER(F), I]
    lib.juno_gui_destroy.argtypes = [V]
    lib.juno_set_fp_oracle_mode.argtypes = [I]
    red = {}
    total = {}
    for ci, (fam, rate, sc) in enumerate(ref['_chains']):
        if ONLY is not None and ci != ONLY:
            continue
        c = lib.juno_gui_create(F(rate), 0)
        # the oracle stores denormal results (no FTZ) and reads them as 0 (DAZ):
        # compare the port in that same mode (src/juno_ftz.c, playbook 120)
        lib.juno_set_fp_oracle_mode(1)
        outs = ref[ci]
        oi = 0
        first = True
        bad = None
        last = None
        for ev in sc:
            if ev[0] == 'recall':
                rb = zlib.decompress(ev[2])
                (lib.juno_gui_apply_bank if (first or mode == 'settled') else live)(c, rb, len(rb), 0)
                first = False
                last = ev[1]
            elif ev[0] == 'on':
                lib.juno_gui_note_on(c, ev[1], 100)
            elif ev[0] == 'off':
                lib.juno_gui_note_off(c, ev[1])
            elif ev[0] == 'render':
                n = ev[1]
                buf = (F * (2 * n))()
                lib.juno_gui_render(c, buf, n)
                got = np.frombuffer(bytes(buf), dtype='<u4')
                want = np.frombuffer(zlib.decompress(outs[oi]), dtype='<u4')
                oi += 1
                gl, gr = got[0::2], got[1::2]
                wl, wr = want[:n], want[n:]
                d = np.nonzero((gl != wl) | (gr != wr))[0]
                if len(d) and bad is None:
                    bad = 'after recall %s: render of %d differs from sample %d (%d samples)' % (last, n, int(d[0]), len(d))
                if len(d) and VERBOSE:
                    print('    [%s] render %d: first diff %d, %d samples; plug %08x port %08x'
                          % (last, n, int(d[0]), len(d), int(wl[d[0]]), int(gl[d[0]])))
            elif ev[0] == 'check':
                st = lib.juno_gui_state(c)
                parts = []
                for v in range(8):
                    for a, b in voice_regions(v):
                        parts.append(ctypes.string_at(st + a, b - a))
                for a, b in master_ranges():
                    parts.append(ctypes.string_at(st + a, b - a))
                got = np.frombuffer(b''.join(parts), dtype='<u4')
                want = np.frombuffer(zlib.decompress(outs[oi]), dtype='<u4')
                oi += 1
                d = np.nonzero(got != want)[0]
                if len(d) and (bad is None or VERBOSE):
                    offs = []
                    for w in d[:6]:
                        k = int(w) * 4
                        for v in range(8):
                            for a, b in voice_regions(v):
                                if k < b - a:
                                    offs.append('v%d:%d' % (v, a + k)); k = None; break
                                k -= b - a
                            if k is None:
                                break
                        if k is not None:
                            for a, b in master_ranges():
                                if k < b - a:
                                    offs.append('m:%d' % (a + k)); k = None; break
                                k -= b - a
                    if bad is None:
                        bad = 'after recall %s: %d state cells differ %s' % (last, len(d), offs)
                    if VERBOSE:
                        print('    [%s] check: %d cells differ %s  plug %s port %s'
                              % (last, len(d), offs, ['%08x' % int(want[w]) for w in d[:6]],
                                 ['%08x' % int(got[w]) for w in d[:6]]))
        lib.juno_gui_destroy(c)
        total[fam] = total.get(fam, 0) + 1
        if bad:
            red[fam] = red.get(fam, 0) + 1
            print('%s %s chain %d (%g Hz): %s' % (mode, fam, ci, rate, bad))
            print('    plugin ramps active at each recall: %s' % (ref.get('_active', {}).get(ci),))
    n_red = sum(red.values())
    print('\n=== WARM RENDER (%s, CLAIMS B1): audio + rendered state, red chains per family: %s ==='
          % (mode, ', '.join('%s %d/%d' % (f, red.get(f, 0), total[f]) for f in total)))
    print('GATE: %s' % ('FAIL' if n_red else 'PASS'))
    return 1 if n_red else 0


VERBOSE = '-v' in sys.argv
ONLY = None


def tooth():
    """Three named defects the gate found and the port fixed (2026-10-06); each
    must turn the SETTLED gate red."""
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    gate = ['tools/verify/warm_render_gate.py', '--port', 'settled']
    a = run_tooth('wr_unison_ages_all',
                  [('gui/juno_bridge.c', '            if (v) c->voice_age[v] = keep_age;           /* only voice 0 moves */\n',
                    '\n')],
                  gate, tail=800)
    b = run_tooth('wr_flush_every_load',
                  [('gui/juno_bridge.c', '    if (c->assign_mode != old_mode) {', '    if (flush || c->assign_mode != old_mode) {')],
                  gate, tail=800)
    c = run_tooth('wr_keep_note_slots',
                  [('gui/juno_bridge.c', 'c->voice_gated[v] = 0; c->voice_note[v] = -1; }', 'c->voice_gated[v] = 0; }')],
                  gate, tail=800)
    return 0 if (a, b, c) == (0, 0, 0) else 1


def main():
    global ONLY
    a = [x for x in sys.argv[1:] if x != '-v']
    if a[:1] == ['--tooth']:
        return tooth()
    if '--chain' in a:
        i = a.index('--chain')
        ONLY = int(a[i + 1])
        del a[i:i + 2]
    if len(a) == 2 and a[0] in ('--ref', '--port') and a[1] in ('settled', 'live'):
        return build_ref(a[1]) if a[0] == '--ref' else check_port(a[1])
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
