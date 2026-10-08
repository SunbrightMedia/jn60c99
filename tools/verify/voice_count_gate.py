#!/usr/bin/env python3
"""voice_count_gate.py -- the plugin's VOICE COUNT, plugin vs port (CLAIMS B10).

The plugin as shipped plays SIX voices: its initialize queues the default state,
which sets vm.vs.voiceCount = 6 through the engine's host entry (id 0x0FFFC00E,
rva 0x3C7AE0 -> engine +0x38; EXECUTED, probes/b6/state_load_census.py). Before
every block the engine render (rva 0x3C7400) syncs each voice unit's assigner to
that count (setVoiceCount rva 0x355940: notes off, slots and priority list reset)
and renders only the units below it. The oracle harness now runs that preamble
(tools/verify/e2e_emu.py render), the port runs it in gui/juno_bridge.c
(asg_sync) and src/juno_driver.c / recall_ramp.c / juno_ftz.c.

Chains (settled recalls, notes and renders between, the count changed by the
host value at any point), compared on every rendered sample (L and R bits) and,
at every check, on the state each unit renders -- INCLUDING the units the count
switches off, whose state must stay frozen exactly as the plugin leaves it:
  default6  the shipped default: count 6 before the first note; 8 notes held
  dyn       8 -> 6 -> 4 -> 8 -> 3 while notes are held across the changes
  modes     MONO, UNISON and mode-3 patches at counts 6, 3 and 2, LEGATO+PORTA
  ramps     host VCF CUTOFF edits (ramps on every unit, CLAIMS A20) with the
            count dropping mid-ramp and rising again
  edge      counts 9 (above the assigner's clamp: it resets every block), 1, 7
            (a count <= 0 is not graded: the plugin's allocator then reads a
            note slot as a voice number, rva 0x353150)
Host rates 44100 / 48000 / 96001.

TWO-PROCESS RULE: --ref (Unicorn only) writes scratchpad/voice_count_ref.pkl;
--port (libjuno only) reads it.
TOOTH (--tooth): four defects, each restored in a copy of the tree, must turn
--port red: the render ignoring the count; the reset gating off released
voices; no assigner sync; the ramp pump stepping frozen units.

    python3 tools/verify/voice_count_gate.py --ref
    python3 tools/verify/voice_count_gate.py --port [-v]
    python3 tools/verify/voice_count_gate.py --tooth
"""
import gc
import os
import sys
import pickle
import refio

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
PKL = os.path.join(SCRATCH, 'voice_count_ref.pkl')
sys.path.insert(0, HERE)
import warm_render_gate as WR          # regions, record helper (no oracle/port import at load)

VERBOSE = '-v' in sys.argv
HEADER, STRIDE, BLOB_OFF = WR.HEADER, WR.STRIDE, WR.BLOB_OFF


def chains(bank):
    """[(family, rate, script)]; script events: ('recall', name, bank bytes) |
    ('voices', n) | ('on', note) | ('off', note) | ('render', n) | ('check',)."""
    import real_recall as R
    leaf = dict(R.leaf_table())
    arp = leaf[WR.DISP_ARP] + BLOB_OFF

    def rec(base, sets=None):
        rb = bytearray(WR.record_bank(bank, base, sets or {}))
        rb[HEADER + arp] = 0                     # no arpeggio: the oracle has no transport
        rb[HEADER + arp + 1] = 0
        return bytes(rb)

    def play(notes, gap=300):
        out = []
        for n in notes:
            out += [('on', n), ('render', gap)]
        return out

    def release(notes, tail=1500):
        return [ev for n in notes for ev in (('off', n), ('render', 40))] + [('render', tail), ('check',)]

    out = []
    ch8 = [48, 52, 55, 59, 62, 65, 69, 72]
    # the shipped default
    sc = [('voices', 6), ('recall', 'p0', rec(0)), ('render', 64), ('check',)]
    sc += play(ch8) + [('check',)] + release(ch8)
    sc += play([60, 64, 67, 71]) + [('check',)] + release([60, 64, 67, 71])
    out.append(('default6', 44100.0, sc))
    for k, (p, rate) in enumerate(((12, 48000.0), (47, 96001.0))):
        sc = [('voices', 6), ('recall', 'p%d' % p, rec(p)), ('render', 64)]
        sc += play(ch8[::-1], 200) + [('check',)] + release(ch8[::-1], 2500)
        out.append(('default6', rate, sc))
    # counts changed while notes are held
    for k, rate in enumerate((48000.0, 44100.0)):
        p = (5, 33)[k]
        sc = [('recall', 'p%d' % p, rec(p)), ('render', 64)]
        sc += play([48, 55, 60, 64]) + [('check',)]
        sc += [('voices', 6), ('render', 200), ('check',)]
        sc += play([50, 57, 62, 65, 69, 72, 76]) + [('check',)]
        sc += [('voices', 4), ('on', 79), ('render', 300), ('check',)]       # the note dies at the sync
        sc += play([43, 47, 52, 56, 59, 63]) + [('check',)]
        sc += [('voices', 8), ('render', 100)] + play(ch8, 150) + [('check',)]
        sc += [('voices', 3)] + play([60, 62, 64, 65, 67]) + [('check',)]
        sc += release([60, 62, 64, 65, 67, 48, 52, 55, 59, 62, 65, 69, 72], 2000)
        out.append(('dyn', rate, sc))
    # assign modes: 61/63 are the bank's UNISON patches, 15 a MONO patch, 55 has
    # LEGATO 1 + PORTAMENTO (assigner_ab.py); mode 3 is in no factory patch, so
    # ASSIGN MODE (blob 56 -> record byte 16 + 2*56) is forced to 3 on patch 0
    mode3 = {16 + 2 * 56: 3}
    for k, (name, base, sets, rate) in enumerate((('unison61', 61, None, 44100.0), ('unison63', 63, None, 96001.0),
                                                   ('mono15', 15, None, 48000.0), ('mode3', 0, mode3, 44100.0),
                                                   ('legato55', 55, None, 48000.0))):
        for n in (6, 3, 2):
            sc = [('voices', n), ('recall', name, rec(base, sets)), ('render', 64)]
            sc += play([60, 64, 67], 250) + [('off', 64), ('render', 200), ('off', 67), ('render', 200), ('check',)]
            sc += play([48, 55, 62, 69, 76], 200) + [('check',)]
            sc += release([60, 48, 55, 62, 69, 76], 1500)
            out.append(('modes', rate, sc))
    # ramps in flight when the count drops: a host VCF CUTOFF edit arms a ramp on
    # every voice unit (CLAIMS A20); 40 samples later the count stops units 6/7
    # mid-ramp (their records must not step), later it lets them run again
    import host_edit_gate as HG
    cut = [k for k, nm, roff in HG.host_table() if nm == 'VCF CUTOFF FREQ'][0]
    for k, rate in enumerate((44100.0, 96001.0)):
        p = (0, 47)[k]
        sc = [('recall', 'p%d' % p, rec(p)), ('render', 64)] + play([60, 64, 67], 200)
        sc += [('host', cut, 30), ('render', 40), ('voices', 6), ('render', 200), ('check',)]
        sc += [('host', cut, 220), ('render', 20), ('voices', 8), ('render', 400), ('check',)]
        sc += release([60, 64, 67], 1000)
        out.append(('ramps', rate, sc))
    # outside the model's 2..8 the engine takes the raw value: 9 (above the
    # assigner's clamp: it resets every block) and 1 are graded; 7 for coverage.
    # NOT graded: a count <= 0, where the plugin's own POLY allocator falls
    # through to its steal branch and reads a1[a1[38] + 29] -- with an empty
    # priority list that is a note-slot word used as a voice number (READ, rva
    # 0x353150): no defined behaviour to reproduce.
    for k, n in enumerate((9, 1, 7)):
        sc = [('recall', 'p0', rec(0)), ('render', 64), ('voices', n), ('render', 64)]
        sc += play([60, 64, 67, 71], 200) + [('check',)] + release([60, 64, 67, 71], 800)
        sc += [('voices', 6), ('render', 64)] + play([62, 65], 200) + [('check',)] + release([62, 65], 600)
        out.append(('edge', (44100.0, 48000.0, 96001.0)[k], sc))
    return out


def state_parts(read):
    parts = []
    for v in range(8):
        for a, b in WR.voice_regions(v):
            parts.append(read(v, a, b))
    for a, b in WR.master_ranges():
        parts.append(read(8, a, b))
    return b''.join(parts)


def build_ref():
    import zlib
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    from array import array
    bank = E.bank_bytes()
    lt = R.leaf_table()
    ch = chains(bank)
    ref = {'_chains': []}
    import host_edit_gate as HG
    import seed_recall_gate as S
    params = None
    for ci, (fam, rate, sc) in enumerate(ch):
        e = RR.build_engine(E, rate)
        e.call(E.IB + HG.POPULATE_RVA, count=200_000_000)      # the parameter map (host edits)
        if params is None:
            params = HG.oracle_params(e, E, S)
        outs = []
        for ev in sc:
            if ev[0] == 'recall':
                RR.apply_recall(e, 0, ev[2], lt, E, R)
            elif ev[0] == 'host':
                _, d, pid, lo, hi = params[ev[1]]
                e.call(E.IB + HG.APPLY_RVA, rcx=e.HOST, rdx=pid, r8=ev[2] & 0xFFFFFFFF, count=60_000_000)
            elif ev[0] == 'voices':
                e.call(E.IB + 0x3C7AE0, rcx=e.HOST, rdx=E.VOICECOUNT_ID, r8=ev[1] & 0xFFFFFFFF, count=60_000_000)
            elif ev[0] == 'on':
                e.note_on(ev[1], 100)
            elif ev[0] == 'off':
                e.note_off(ev[1])
            elif ev[0] == 'render':
                L, Rr = e.render(ev[1])
                outs.append(zlib.compress(array('I', L).tobytes() + array('I', Rr).tobytes(), 6))
            elif ev[0] == 'check':
                outs.append(zlib.compress(state_parts(
                    lambda u, a, b: bytes(e.uc.mem_read(e.state[u] + a, b - a))), 6))
        ref['_chains'].append((fam, rate, [(ev[0], ev[1], zlib.compress(ev[2], 6)) if ev[0] == 'recall' else ev
                                           for ev in sc]))
        ref[ci] = outs
        del e
        gc.collect()
        sys.stderr.write('ref chain %d %s (%g Hz): %d events\n' % (ci, fam, rate, len(sc)))
        sys.stderr.flush()
    refio.dump(ref, PKL)
    print('wrote %s (%d chains)' % (PKL, len(ch)))
    return 0


def where(w):
    k = int(w) * 4
    for v in range(8):
        for a, b in WR.voice_regions(v):
            if k < b - a:
                return 'v%d:%d' % (v, a + k)
            k -= b - a
    for a, b in WR.master_ranges():
        if k < b - a:
            return 'm:%d' % (a + k)
        k -= b - a
    return '?'


def check_port():
    import ctypes
    import zlib
    import numpy as np
    import freshlib
    if not os.path.exists(PKL):
        print('MISSING %s -- run --ref first' % PKL)
        return 2
    ref = pickle.load(open(PKL, 'rb'))
    lib = freshlib.load()
    V, I, F, C = ctypes.c_void_p, ctypes.c_int, ctypes.c_float, ctypes.c_char_p
    if not hasattr(lib, 'juno_gui_set_voice_count'):
        print('libjuno has no juno_gui_set_voice_count -- the voice count is not ported (CLAIMS B10)')
        print('GATE: FAIL')
        return 1
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [F, I]
    lib.juno_gui_apply_bank.argtypes = [V, C, I, I]
    lib.juno_gui_set_voice_count.argtypes = [V, I]
    lib.juno_gui_host_set.argtypes = [V, I, I]
    lib.juno_gui_state.restype = V
    lib.juno_gui_state.argtypes = [V]
    lib.juno_gui_note_on.argtypes = [V, I, I]
    lib.juno_gui_note_off.argtypes = [V, I]
    lib.juno_gui_render.argtypes = [V, ctypes.POINTER(F), I]
    lib.juno_gui_destroy.argtypes = [V]
    lib.juno_set_fp_oracle_mode.argtypes = [I]
    lib.juno_gui_unit_noise.restype = V
    lib.juno_gui_unit_noise.argtypes = [V, I]
    red, total = {}, {}
    for ci, (fam, rate, sc) in enumerate(ref['_chains']):
        c = lib.juno_gui_create(F(rate), 0)
        lib.juno_set_fp_oracle_mode(1)          # the oracle's FP mode (playbook 120)
        outs, oi, bad, step = ref[ci], 0, None, 0
        for ev in sc:
            step += 1
            if ev[0] == 'recall':
                rb = zlib.decompress(ev[2])
                lib.juno_gui_apply_bank(c, rb, len(rb), 0)
            elif ev[0] == 'voices':
                lib.juno_gui_set_voice_count(c, ev[1])
            elif ev[0] == 'host':
                lib.juno_gui_host_set(c, ev[1], ev[2])
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
                d = np.nonzero((got[0::2] != want[:n]) | (got[1::2] != want[n:]))[0]
                if len(d) and bad is None:
                    bad = 'event %d: render of %d differs from sample %d (%d samples)' % (step, n, int(d[0]), len(d))
                if len(d) and VERBOSE:
                    print('    event %d render %d: first diff %d, %d samples' % (step, n, int(d[0]), len(d)))
            elif ev[0] == 'check':
                st = lib.juno_gui_state(c)

                def rd(u, a, b):
                    # voice u's own noise block: each plugin unit owns one (the
                    # port keeps per-voice copies once a count below 8 ran)
                    if (a, b) == WR.SHARED and u < 8:
                        return ctypes.string_at(lib.juno_gui_unit_noise(c, u), b - a)
                    return ctypes.string_at(st + a, b - a)
                got = np.frombuffer(state_parts(rd), dtype='<u4')
                want = np.frombuffer(zlib.decompress(outs[oi]), dtype='<u4')
                oi += 1
                d = np.nonzero(got != want)[0]
                if len(d) and (bad is None or VERBOSE):
                    msg = 'event %d: %d state cells differ %s' % (step, len(d), [where(w) for w in d[:6]])
                    if bad is None:
                        bad = msg
                    if VERBOSE:
                        print('    ' + msg)
        lib.juno_gui_destroy(c)
        total[fam] = total.get(fam, 0) + 1
        if bad:
            red[fam] = red.get(fam, 0) + 1
            print('%s chain %d (%g Hz): %s' % (fam, ci, rate, bad))
    n_red = sum(red.values())
    print('\n=== VOICE COUNT (CLAIMS B10): audio + rendered state, red chains per family: %s ==='
          % ', '.join('%s %d/%d' % (f, red.get(f, 0), total[f]) for f in total))
    print('GATE: %s' % ('FAIL' if n_red else 'PASS'))
    return 1 if n_red else 0


def tooth():
    from tooth_tree import run_tooth
    gate = ['tools/verify/voice_count_gate.py', '--port']
    res = {}
    res['render_all_8'] = run_tooth('vc_render_all',
        [('src/juno_driver.c', '        if (v >= nv) continue;\n', '')], gate, tail=600)
    res['reset_released_too'] = run_tooth('vc_reset_released',
        [('gui/juno_bridge.c', '        if (c->voice_gated[v]) juno_note_off(c->st, v);\n    c->asg_count',
          '        if (c->voice_note[v] >= 0) juno_note_off(c->st, v);\n    c->asg_count')], gate, tail=600)
    res['no_assigner_sync'] = run_tooth('vc_no_sync',
        [('gui/juno_bridge.c', '    if (c->asg_count != nv) asg_set_count(c, nv);', '    (void)nv;')], gate, tail=600)
    res['pump_frozen_units'] = run_tooth('vc_pump_frozen',
        [('src/recall_ramp.c', '        if (u < 8 && u >= nv) { ++k; continue; }', '        (void)u;')], gate, tail=600)
    for k, v in res.items():
        print('tooth %-20s %s' % (k, 'BITES' if v == 0 else 'DOES NOT BITE'))
    return 0 if all(v == 0 for v in res.values()) else 1


if __name__ == '__main__':
    if '--ref' in sys.argv:
        sys.exit(build_ref())
    if '--port' in sys.argv:
        sys.exit(check_port())
    if '--tooth' in sys.argv:
        sys.exit(tooth())
    print(__doc__)
    sys.exit(2)
