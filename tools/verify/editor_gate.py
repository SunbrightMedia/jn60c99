#!/usr/bin/env python3
"""editor_gate.py -- THE EDITOR'S SET, plugin vs port: a panel control's value through the plugin's model (rva
0x283DB0; flag 1 a final set, 0 a step of a drag) and what follows it -- the calls the plugin's controller makes on the
host (beginEdit / performEdit / endEdit), the engine records it queues for the next block, getState -- after every
step of a chain, plugin vs port (gui/juno_bridge.c juno_gui_model_set_flag, juno_gui_host_edits,
juno_gui_queue_records, juno_gui_state_save). The JX-3P's jx_state_gate.py chains 'editor' and 'gesture' (JX-18,
jx3p/docs/HOST_LAYER.md 3n) on the JUNO-60; the routing it grades is src/juno_state_tables.h JUNO_STATE_EDIT_HOST
(tools/verify/juno_model_census.py, tools/verify/gen_state_tables.py).

Steps (each followed by the comparison):
  ('set', id, v, flag)   the model's set of id's value object (the CC map's record), flag 1 final / 0 a step
  ('rt',)                the host's round trip: each side's own performEdits since the last block sent back through
                         one 256-sample process() as parameter points at offset 0 (one queue per id, its last value),
                         as a DAW sends a controller's edits to the processor
  ('proc',)              one 256-sample block, no parameters (the queued records applied)
  ('note', pitch, vel)   one 256-sample block with a note-on at offset 0 (the key held for the rest of the chain)
  ('commit',)            the panel's commit (rva 0x285320, 0x2853C0, 0x283120); the port's juno_gui_commit
  ('patch', idx)         the plugin's patch browser load (rva 0x335850) of factory patch idx
Chains, built from the plugin's own record list: 'census' (every record at 14 values, final, a block after each
record), 'gesture' (a key held; two host parameters' drags crossing, a record entry and a patch load inside an open
edit, round trips in a drag, a plain set after a step), 'roundtrip' (a key held; seeded sets of every host parameter,
each sent back). Compared after every step: the host's calls since the last step (the port's kinds expanded: 0 begin /
perform / end, 2 begin / perform, 3 perform, 4 perform / end), the records pending for the next block (a preset path's
value: kind 2, the plugin's id taken to the port's host index through JUNO_STATE_ENT, the value), getState's bytes,
and after a block both channels' samples, bit for bit (the round trip's values through the engine, a key sounding).

  --ref       (Unicorn) scratchpad/editor_ref.pkl (.partial, then renamed)
  --port      (libjuno) every step equal
  --mutants   libjuno built with JUNO_EDSET_TOOTH 1 (performEdit = stored / max), 2 (every entry a record: the old
              model), 3 (one open edit per parameter), 4 (the engine-rate setting switches at each set, not at the
              next block: the port before 2026-10-15): each must FAIL
TWO-PROCESS RULE: --ref never loads libjuno; --port never builds a Unicorn instance.
"""
import os
import pickle
import random
import re
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
REF_PKL = os.path.join(REPO, 'scratchpad', 'editor_ref.pkl')
VALS = (0, 1, 2, 5, 127, 128, 255, 256, 300, 65535, 65536, -1, 0x7FFFFFFF, -0x80000000)
TRIO = (0x285320, 0x2853C0, 0x283120)
MODEL_SET, REC_ID, PATCH_LOAD = 0x283DB0, 0x319C50, 0x335850


def state_tables():
    """JUNO_STATE_ENT's id -> the port's host index (the record comparison's key) and the editor routing"""
    src = open(os.path.join(REPO, 'src', 'juno_state_tables.h')).read()
    ent = src[src.index('JUNO_STATE_ENT[JUNO_STATE_N] = {'):]
    ent = ent[:ent.index('};')]
    rows = re.findall(r'\{ 0x([0-9A-F]{8})u, (-?\w+), 0x[0-9A-F]+u, -?\d+ \}', ent)
    enum = {'JUNO_SE_NONE': -1, 'JUNO_SE_VOICES': -2, 'JUNO_SE_SRATE': -3}
    host = {int(a, 16): enum.get(b, None) if not re.match(r'-?\d+$', b) else int(b) for a, b in rows}
    eh = src[src.index('JUNO_STATE_EDIT_HOST[JUNO_STATE_N] = {'):]
    eh = [int(x) for x in re.findall(r'\b([01]),', eh[eh.index('\n'):eh.index('};')])]
    return host, dict(zip([int(a, 16) for a, _ in rows], eh))


def build_chains(ids, ranges):
    """ids: the plugin's records in order; ranges: id -> (min, max) for the host parameters"""
    host, route = state_tables()
    H = [i for i in ids if route.get(i) == 1]
    R = [i for i in ids if route.get(i) == 0 and host.get(i, -1) >= 0] or [i for i in ids if route.get(i) == 0]
    out = []
    st = []
    for pid in ids:
        st += [('set', pid, v, 1) for v in VALS] + [('proc',)]
    out.append(('census', st))
    h1, h2, r1 = H[0], H[1], R[0]
    st = [('note', 60, 0.8), ('set', h1, 1, 1),
          ('set', h1, 2, 0), ('set', h1, 3, 0), ('set', h1, 3, 1),
          ('set', h1, 3, 0), ('set', h1, 3, 1),
          ('set', h1, 0, 0), ('set', h2, 40, 1), ('set', h2, 41, 0), ('set', h1, 2, 1), ('set', h2, 42, 1),
          ('set', h1, 1, 0), ('set', r1, 1, 1), ('set', h1, 2, 1),
          ('set', h1, 1, 0), ('set', r1, 0, 0), ('set', h2, 43, 1),
          ('set', h1, 1, 0), ('patch', 3), ('set', h2, 44, 1),
          ('set', h1, 3, 0), ('rt',), ('set', h1, 0, 1), ('rt',),
          ('set', h2, 45, 1), ('set', h2, 46, 0), ('set', h2, 47, 1), ('commit',), ('proc',)]
    out.append(('gesture', st))
    rnd = random.Random(1)
    st = [('note', 60, 0.8)]
    for pid in H:
        mn, mx = ranges[pid]
        for _ in range(2):
            st.append(('set', pid, rnd.randint(mn, mx), 1))
            st.append(('rt',))
    st.append(('proc',))
    out.append(('roundtrip', st))
    return out


def rec_of(kind, r):
    """a plugin queue record: kind 2 -> (2, id, value); others as (kind,)"""
    if kind == 2:
        return (2, struct.unpack_from('<I', r, 12)[0], struct.unpack_from('<i', r, 20)[0])
    return (kind,)


# ------------------------------------------------------------------ the plugin (Unicorn only)
def build_ref():
    import host_process_emu as H
    import midi_ctl_gate as G
    import truth
    bank = open(truth.BANK, 'rb').read()
    h = H.HostProcess()
    h.start(48000.0, 512)
    h.process(256)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    vb, ve = q(h.core + 24), q(h.core + 32)
    recs = [(h.call(H.IB + REC_ID, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF, q(vb + 24 * i)) for i in range((ve - vb) // 24)]
    obj = dict(recs)
    ids = [pid for pid, _ in recs]
    msrc = open(os.path.join(REPO, 'src', 'midi_tables.h')).read()
    ranges = {int(a, 16): (int(b), int(c)) for a, b, c in
              re.findall(r'\{ 0x([0-9A-F]{8})u, (-?\d+), (-?\d+), \d+, -?\d+ \}', msrc)}
    model = q(q(h.core + 8))
    chains = build_chains(ids, ranges)
    ref = {'_chains': chains}
    for ci, (name, steps) in enumerate(chains):
        if ci:                                           # every chain on a fresh boot
            del h
            h = H.HostProcess()
            h.start(48000.0, 512)
            h.process(256)
            uc = h.uc
            model = q(q(h.core + 8))
        e0, sent, out = len(h.edits), 0, []
        for stp in steps:
            k, audio = stp[0], None
            if k == 'set':
                h.call(H.IB + MODEL_SET, rcx=model, rdx=obj[stp[1]], r8=stp[2] & 0xFFFFFFFF, r9=stp[3],
                       count=500_000_000)
            elif k == 'rt':
                last = {}
                for e in h.edits[sent:]:
                    if e[0] == 'performEdit':
                        last[e[1]] = e[2]
                sent = len(h.edits)
                audio = h.process(256, params=[(pid, 0, v) for pid, v in last.items()],
                                  ctx=dict(tempo=120.0, playing=True))
            elif k == 'proc':
                audio = h.process(256, ctx=dict(tempo=120.0, playing=True))
            elif k == 'note':
                audio = h.process(256, events=[('on', 0, 0, stp[1], stp[2])], ctx=dict(tempo=120.0, playing=True))
            elif k == 'commit':
                for rva in TRIO:
                    h.call(H.IB + rva, rcx=model, count=500_000_000)
            elif k == 'patch':
                rec = bank[G.HEADER + stp[1] * G.STRIDE: G.HEADER + (stp[1] + 1) * G.STRIDE]
                h.load_patch(rec[G.NAME:])
            else:
                raise SystemExit('step %r' % (stp,))
            calls = [tuple(e) for e in h.edits[e0:] if e[0] in ('beginEdit', 'performEdit', 'endEdit')]
            e0 = len(h.edits)
            if audio is not None:
                audio = struct.pack('<%dI' % (2 * len(audio[0])), *(list(audio[0]) + list(audio[1])))
            out.append((calls, [rec_of(kd, r) for kd, _, r in h.queue()], h.get_state(), audio))
        ref[ci] = out
        sys.stderr.write('ref chain %d %s: %d steps\n' % (ci, name, len(out)))
        sys.stderr.flush()
    os.makedirs(os.path.dirname(REF_PKL), exist_ok=True)
    pickle.dump(ref, open(REF_PKL + '.partial', 'wb'))
    os.replace(REF_PKL + '.partial', REF_PKL)
    print('wrote', REF_PKL)
    return 0


# ------------------------------------------------------------------ the port (libjuno only)
def check_port(lib_path=None, quiet=False):
    import ctypes
    import freshlib
    import midi_ctl_gate as G
    import truth
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    lib = ctypes.CDLL(lib_path) if lib_path else freshlib.load()
    V = ctypes.c_void_p

    class Param(ctypes.Structure):
        _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]

    class Note(ctypes.Structure):
        _fields_ = [('offset', ctypes.c_int), ('type', ctypes.c_int), ('channel', ctypes.c_int),
                    ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    for fn, at in (('juno_gui_plugin_init', [V]), ('juno_gui_destroy', [V]), ('juno_gui_commit', [V]),
                   ('juno_gui_model_set_flag', [V, ctypes.c_uint32, ctypes.c_int32, ctypes.c_int]),
                   ('juno_gui_host_edits', [V, ctypes.POINTER(ctypes.c_uint32), ctypes.POINTER(ctypes.c_double),
                                            ctypes.POINTER(ctypes.c_int), ctypes.c_int]),
                   ('juno_gui_queue_records', [V, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int),
                                               ctypes.POINTER(ctypes.c_int32), ctypes.POINTER(ctypes.c_uint32),
                                               ctypes.c_int]),
                   ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                   ('juno_gui_state_save', [V, ctypes.c_char_p, ctypes.c_int]),
                   ('juno_gui_process_ex', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.POINTER(Param), ctypes.c_int,
                                            ctypes.c_int, ctypes.c_double, ctypes.POINTER(ctypes.c_float),
                                            ctypes.POINTER(ctypes.c_float), ctypes.c_int])):
        getattr(lib, fn).argtypes = at
    lib.juno_set_fp_oracle_mode.argtypes = [ctypes.c_int]
    host, _ = state_tables()
    bankb = open(truth.BANK, 'rb').read()
    buf = ctypes.create_string_buffer(4096)
    ids_a, vals_a, kinds_a = (ctypes.c_uint32 * 512)(), (ctypes.c_double * 512)(), (ctypes.c_int * 512)()
    qk, qh, qv, qi = ((ctypes.c_int * 512)(), (ctypes.c_int * 512)(), (ctypes.c_int32 * 512)(), (ctypes.c_uint32 * 512)())
    L, R = (ctypes.c_float * 256)(), (ctypes.c_float * 256)()
    bad = 0
    nsteps = nedits = nblocks = loud = 0
    for ci, (name, steps) in enumerate(ref['_chains']):
        c = lib.juno_gui_create(ctypes.c_float(48000.0), 0)
        lib.juno_set_fp_oracle_mode(1)
        lib.juno_gui_plugin_init(c)
        lib.juno_gui_process_ex(c, None, 0, None, 0, 1, 120.0, L, R, 256)
        pend, first = [], None

        def block(par, notes=()):
            pa = (Param * max(1, len(par)))()
            for i, (pid, v) in enumerate(par):
                pa[i] = Param(pid, 0, v)
            na = (Note * max(1, len(notes)))()
            for i, (pitch, vel) in enumerate(notes):
                na[i] = Note(0, 0, 0, pitch, vel)
            lib.juno_gui_process_ex(c, na, len(notes), pa, len(par), 1, 120.0, L, R, 256)
            return struct.pack('<512f', *(list(L) + list(R)))
        for si, stp in enumerate(steps):
            k, audio = stp[0], None
            if k == 'set':
                lib.juno_gui_model_set_flag(c, stp[1], stp[2], stp[3])
            elif k == 'rt':
                last = {}
                for pid, v in pend:
                    last[pid] = v
                pend = []
                audio = block(list(last.items()))
            elif k == 'proc':
                audio = block([])
            elif k == 'note':
                audio = block([], [(stp[1], stp[2])])
            elif k == 'commit':
                lib.juno_gui_commit(c)
            elif k == 'patch':
                lib.juno_gui_queue_patch(c, bankb, len(bankb), stp[1])
            n = lib.juno_gui_host_edits(c, ids_a, vals_a, kinds_a, 512)
            calls = []
            for i in range(n):
                pid, v, kd = ids_a[i], vals_a[i], kinds_a[i]
                calls += ([('beginEdit', pid, None)] if kd in (0, 2) else []) + [('performEdit', pid, v)] + \
                         ([('endEdit', pid, None)] if kd in (0, 4) else [])
                pend.append((pid, v))
            nq = lib.juno_gui_queue_records(c, qk, qh, qv, qi, 512)
            recs = [(2, qh[i], qv[i]) if qk[i] == 2 else (qk[i],) for i in range(nq)]
            ns = lib.juno_gui_state_save(c, buf, 4096)
            save = buf.raw[:ns] if ns > 0 else b''
            w_calls, w_recs, w_save, w_audio = ref[ci][si]
            w_recs = [(2, host.get(r[1], -99), r[2]) if r[0] == 2 else r for r in w_recs]
            nsteps += 1
            nedits += len(w_calls)
            nblocks += audio is not None
            loud += audio is not None and any(struct.unpack('<512I', audio))
            if (calls, recs, save, audio) != (list(w_calls), w_recs, w_save, w_audio) and first is None:
                what = []
                if calls != list(w_calls):
                    what.append('host calls: the plugin %s, the port %s' % (list(w_calls)[:3], calls[:3]))
                if recs != w_recs:
                    what.append('records: the plugin %s, the port %s' % (w_recs[:3], recs[:3]))
                if save != w_save:
                    what.append('getState differs')
                if audio != w_audio:
                    what.append('the block\'s samples differ' if audio and w_audio else 'a block on one side only')
                first = (si, stp, '; '.join(what))
        lib.juno_gui_destroy(c)
        if first:
            bad += 1
            if not quiet:
                print('chain %d %-9s: RED at step %d %r -- %s' % (ci, name, first[0], first[1], first[2]))
        elif not quiet:
            print('chain %d %-9s: %d steps EQUAL' % (ci, name, len(steps)))
    if not quiet:
        print('editor_gate: %s -- %d steps, %d host calls of the plugin and %d blocks (%d not silent) compared'
              % ('GREEN' if not bad else 'RED', nsteps, nedits, nblocks, loud))
    return bad


def mutants():
    tmp = tempfile.mkdtemp(prefix='editor_teeth_')
    ok = True
    try:
        srcs = [os.path.join(REPO, 'gui', 'juno_bridge.c'), os.path.join(REPO, 'gui', 'juno_pm.c')] + \
            sorted(os.path.join(REPO, 'src', f) for f in os.listdir(os.path.join(REPO, 'src')) if f.endswith('.c'))
        for n, what in ((1, 'performEdit = stored / max'), (2, 'every entry a record (the old model)'),
                        (3, 'one open edit per parameter'), (4, 'the engine-rate setting switches at each set')):
            so = os.path.join(tmp, 'libjuno_%d.so' % n)
            subprocess.check_call(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-frounding-math', '-fsignaling-nans',
                                   '-fno-strict-aliasing', '-shared', '-fPIC', '-DJUNO_EDSET_TOOTH=%d' % n, '-o', so]
                                  + srcs + ['-lm'])
            r = subprocess.run([sys.executable, __file__, '--port-lib', so], capture_output=True, text=True)
            bites = r.returncode == 1
            ok &= bites
            print('editor_gate mutant %d (%s): %s' % (n, what, 'BITES' if bites else 'DID NOT BITE (rc %d)' % r.returncode))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return 0 if ok else 1


def main():
    a = sys.argv[1:]
    if a[:1] == ['--ref']:
        return build_ref()
    if a[:1] == ['--port']:
        return 1 if check_port() else 0
    if a[:1] == ['--port-lib']:                          # a mutant's run (its own process: libjuno only)
        return 1 if check_port(a[1], quiet=True) else 0
    if a[:1] == ['--mutants']:
        return mutants()
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
