#!/usr/bin/env python3
"""jp8_host_c.py -- C side (process B) of the JUPITER-8 host gate: ctypes-loads a host library (jp8_host.c +
jp8_rt.c + the lifted host path) and drives only its API (jp8h.h): jp8h_init from the JP8H v2 template process A
wrote (the setup calls at the drive's first rate), then the same steps (jp8_host_seq.steps): patch loads, process()
blocks, getState / setState, host-rate changes, setActive.
  CONTROL 1  after jp8h_init: the image + heap + host-object hash == the oracle's after its setup().
  RUN        every step's result, every output word, every state byte, the performEdit calls (ids and value bits),
             the worker jobs, the bump pointer, the host-object allocator and the end hash: EXACTLY the oracle's.
No unicorn here (two-process rule), no plugin logic (plumbing only). exit 0 = EXACTLY 0.
usage: jp8_host_c.py <refdir> <lib.so>"""
import sys, os, json, struct, ctypes, hashlib, time
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import jp8_bank as B, jp8_host_seq as Q
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)
refdir, so = sys.argv[1], sys.argv[2]
meta = json.load(open(os.path.join(refdir, 'meta.json')))
ST = Q.steps()
assert meta['rate'] == Q.RATE and meta['patches'] == Q.PATCHES and meta['nsteps'] == len(ST), 'the reference is not this drive'
tm = open(os.path.join(refdir, 'jp8_host_template.bin'), 'rb').read()
assert hashlib.sha256(tm).hexdigest() == meta['template_sha256'], 'the template is not the one the references were made on'
ref = open(os.path.join(refdir, 'words.bin'), 'rb').read()
ref_states = open(os.path.join(refdir, 'states.bin'), 'rb').read()
lib = ctypes.CDLL(os.path.abspath(so))
class EV(ctypes.Structure):
    _fields_ = [('on', ctypes.c_int), ('offset', ctypes.c_int), ('channel', ctypes.c_int), ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]
class PAR(ctypes.Structure):
    _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]
class CTX(ctypes.Structure):
    _fields_ = [('state', ctypes.c_uint32), ('ppq', ctypes.c_double), ('cycle_start', ctypes.c_double), ('cycle_end', ctypes.c_double),
                ('tempo', ctypes.c_double)]
lib.jp8h_init.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_double, ctypes.c_int]
lib.jp8h_set_rate.argtypes = [ctypes.c_double]
lib.jp8h_set_active.argtypes = [ctypes.c_int]
lib.jp8h_cc_learn.argtypes = [ctypes.c_uint32]; lib.jp8h_cc_forget.argtypes = [ctypes.c_uint32]
lib.jp8h_param_string.argtypes = [ctypes.c_uint32, ctypes.c_double, ctypes.c_void_p, ctypes.POINTER(ctypes.c_uint32)]
lib.jp8h_param_parse.argtypes = [ctypes.c_uint32, ctypes.c_void_p, ctypes.POINTER(ctypes.c_double), ctypes.POINTER(ctypes.c_uint32)]
lib.jp8h_ctl_raw.argtypes = [ctypes.c_int, ctypes.c_uint32, ctypes.c_double, ctypes.POINTER(ctypes.c_uint32), ctypes.POINTER(ctypes.c_uint64)]
lib.jp8h_load_patch.argtypes = [ctypes.c_char_p, ctypes.c_size_t]
lib.jp8h_process.argtypes = [ctypes.c_int, ctypes.POINTER(EV), ctypes.c_int, ctypes.POINTER(PAR), ctypes.c_int, ctypes.POINTER(CTX),
                             ctypes.c_void_p, ctypes.c_void_p]
lib.jp8h_get_state.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.POINTER(ctypes.c_size_t)]
lib.jp8h_set_state.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.POINTER(ctypes.c_uint32)]
lib.jp8h_error.restype = ctypes.c_char_p
lib.jp8h_guest.argtypes = [ctypes.c_uint64, ctypes.c_size_t]; lib.jp8h_guest.restype = ctypes.c_void_p
for f in ('jp8h_heap_top', 'jp8h_jobs', 'jp8h_com_next'): getattr(lib, f).restype = ctypes.c_uint64
lib.jp8h_edits.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
IMGSZ = 0xDE7000
K_PLAYING, K_PPQ, K_TEMPO, K_CYCLE = 0x2, 0x200, 0x400, 0x1000      # host_process_emu's ProcessContext flags
def region(a, n):
    p = lib.jp8h_guest(a, n)
    if not p: raise SystemExit('jp8h_guest(0x%x, %d) = NULL' % (a, n))
    return ctypes.string_at(p, n)
def memhash():
    m = hashlib.sha256()
    m.update(region(Q.IMG_BASE, IMGSZ)); m.update(region(Q.HEAP_BASE, lib.jp8h_heap_top() - Q.HEAP_BASE))
    m.update(region(Q.COM_BASE, lib.jp8h_com_next() - Q.COM_BASE))
    return m.hexdigest()
def ctx_of(c):
    """host_process_emu.process's context from the drive's dict (the same flags, the same zero defaults)"""
    if c is None: return None
    st = c.get('state')
    if st is None:
        st = (K_PLAYING if c.get('playing') else 0) | (K_TEMPO if 'tempo' in c else 0) | (K_PPQ if 'ppq' in c else 0) | (K_CYCLE if 'cycle' in c else 0)
    cs, ce = c.get('cycle', (0.0, 0.0))
    return CTX(st, c.get('ppq', 0.0), cs, ce, c.get('tempo', 0.0))
bad = 0
rc = lib.jp8h_init(tm, len(tm), ST[0][1], Q.MAXBLOCK)
if rc: sys.exit('jp8h_init rc %d: %s' % (rc, lib.jp8h_error().decode()))
ih = memhash()
if ih != meta['init_hash']: bad += 1; log('CONTROL 1 differs: init hash C %s oracle %s' % (ih[:16], meta['init_hash'][:16]))
else: log('CONTROL 1: the memory after jp8h_init (the setup at %g) is the oracle\'s (image + heap + host objects)' % ST[0][1])
bank = B.bank_bytes(); got = bytearray(); got_states = bytearray(); states = {}; results = []; trap = None
for i, st in enumerate(ST[1:]):
    k = st[0]
    if k == 'patch':
        blob = B.patch_blob(bank, st[1]); r = lib.jp8h_load_patch(blob, len(blob)); res = [k, st[1], 0]
    elif k == 'block':
        _, n, evs, pars, cx = st
        ev = (EV * max(1, len(evs)))(*[EV(1 if kk == 'on' else 0, off, ch, pitch, vel) for kk, off, ch, pitch, vel in evs])
        pa = (PAR * max(1, len(pars)))(*[PAR(pid, off, v) for pid, off, v in pars])
        c = ctx_of(cx)
        L = (ctypes.c_uint32 * max(1, n))(); R = (ctypes.c_uint32 * max(1, n))()
        r = lib.jp8h_process(n, ev, len(evs), pa, len(pars), ctypes.byref(c) if c is not None else None, L, R)
        if not r: got += bytes(L)[:4 * n] + bytes(R)[:4 * n]
        res = [k, n, 0]
    elif k == 'getstate':
        nb = ctypes.c_size_t(0); CAP = 1 << 20; buf = ctypes.create_string_buffer(CAP)
        r = lib.jp8h_get_state(buf, CAP, ctypes.byref(nb))          # ONE getState, as the oracle makes one
        if not r:
            if nb.value > CAP: raise SystemExit('a state of %d bytes: above the %d this driver takes' % (nb.value, CAP))
            s = buf.raw[:nb.value]; states[st[1]] = s; got_states += s
        res = [k, st[1], len(states.get(st[1], b''))]
    elif k == 'setstate':
        out_r = ctypes.c_uint32(0); s = Q.state_variant(states[st[1]], st[2])
        r = lib.jp8h_set_state(s, len(s), ctypes.byref(out_r)); res = [k, '%s/%s' % (st[1], st[2]), out_r.value]
    elif k == 'rate':
        r = lib.jp8h_set_rate(st[1]); res = [k, st[1], 0]
    elif k == 'active':
        r = lib.jp8h_set_active(st[1]); res = [k, st[1], 0]
    elif k == 'ctl':
        _, op, pid, arg = st; hr = ctypes.c_uint32(0); x0 = ctypes.c_uint64(0)
        if op == 'str':
            out = (ctypes.c_uint16 * 128)(); r = lib.jp8h_param_string(pid, arg, out, ctypes.byref(hr)); extra = bytes(out).hex()
        elif op == 'parse':
            t = (ctypes.c_uint16 * (len(arg) + 1))(*[ord(ch) for ch in arg], 0); v = ctypes.c_double(0.0)
            r = lib.jp8h_param_parse(pid, t, ctypes.byref(v), ctypes.byref(hr)); extra = bytes(v).hex()
        else:
            r = lib.jp8h_ctl_raw({'get': 14, 'set': 15, 'plain': 12, 'norm': 13}[op], pid, arg, ctypes.byref(hr), ctypes.byref(x0)); extra = ''
        res = [k, '%s/%x/%r' % (op, pid, arg), hr.value, x0.value, extra]
    elif k == 'drain':
        r = lib.jp8h_ui_tick(); res = [k, 0, 0]
    elif k == 'learn':
        r = lib.jp8h_cc_learn(st[1]); res = [k, st[1], 0]
    elif k == 'forget':
        r = lib.jp8h_cc_forget(st[1]); res = [k, st[1], 0]
    else:
        raise SystemExit('unknown step %r' % (st,))
    if r: trap = 'step %d %r: rc %d %s' % (i + 1, st[:2], r, lib.jp8h_error().decode()); break
    results.append(res)
if trap: bad += 1; log('TRAP: %s' % trap)
if results != meta['results'][:len(results)] or len(results) != len(meta['results']):
    bad += 1; j = next((x for x in range(min(len(results), len(meta['results']))) if results[x] != meta['results'][x]), min(len(results), len(meta['results'])))
    log('step results differ from step %d: C %r oracle %r' % (j + 1, results[j] if j < len(results) else None,
        meta['results'][j] if j < len(meta['results']) else None))
nw = min(len(ref), len(got)) // 4
diffs = [i for i in range(nw) if ref[4 * i:4 * i + 4] != got[4 * i:4 * i + 4]]
if len(ref) != len(got): bad += 1; log('%d words, oracle %d' % (len(got) // 4, len(ref) // 4))
if diffs:
    bad += len(diffs)
    pos = 0; where = []
    for x, st in enumerate(ST[1:]):
        if st[0] == 'block': where.append((pos, x + 1, st[1])); pos += 2 * st[1]
    for i in diffs[:6]:
        for start, sn, n in where:
            if start <= i < start + 2 * n:
                kk = i - start; log('word %d: step %d, block of %d, %s sample %d: oracle %08x C %08x' % (
                    i, sn, n, 'L' if kk < n else 'R', kk % n, struct.unpack('<I', ref[4 * i:4 * i + 4])[0], struct.unpack('<I', got[4 * i:4 * i + 4])[0]))
                break
if got_states != ref_states:
    bad += 1; j = next((x for x in range(min(len(got_states), len(ref_states))) if got_states[x] != ref_states[x]), min(len(got_states), len(ref_states)))
    log('state bytes differ: C %d bytes, oracle %d, first at byte %d' % (len(got_states), len(ref_states), j))
ne = lib.jp8h_edits(None, None, 0)
ids = (ctypes.c_uint32 * max(1, ne))(); vals = (ctypes.c_double * max(1, ne))()
lib.jp8h_edits(ids, vals, ne)
mine = [[ids[i], struct.unpack('<Q', struct.pack('<d', vals[i]))[0]] for i in range(ne)]
if mine != meta['edits']:
    bad += 1; kk = next((i for i in range(min(len(mine), len(meta['edits']))) if mine[i] != meta['edits'][i]), min(len(mine), len(meta['edits'])))
    log('performEdit calls differ: C %d, oracle %d, first at %d' % (len(mine), len(meta['edits']), kk))
if lib.jp8h_jobs() != meta['jobs']: bad += 1; log('worker jobs C %d oracle %d' % (lib.jp8h_jobs(), meta['jobs']))
if lib.jp8h_heap_top() != meta['heap_end']: bad += 1; log('bump pointer C 0x%x oracle 0x%x' % (lib.jp8h_heap_top(), meta['heap_end']))
if lib.jp8h_com_next() != meta['com_next_end']: bad += 1; log('host-object allocator C 0x%x oracle 0x%x' % (lib.jp8h_com_next(), meta['com_next_end']))
eh = memhash()
if not trap and eh != meta['end_hash']: bad += 1; log('END hash differs: C %s oracle %s' % (eh[:16], meta['end_hash'][:16]))
sh = hashlib.sha256(region(Q.STACK_BASE, Q.STACK_SIZE)).hexdigest()
log('%d steps, %d words (%d differ), %d state bytes, %d performEdits, %d worker jobs, end %s, stack %s (reported)' % (
    len(results) + 1, nw, len(diffs), len(got_states), len(mine), lib.jp8h_jobs(), 'EXACT' if eh == meta['end_hash'] else 'DIFFERS',
    'EXACT' if sh == meta['stack_hash'] else 'differs'))
print('JP8 HOST PATH (process(), patch load, setup, rate changes, state; %g Hz, patches %s): %s' % (Q.RATE, Q.PATCHES,
      'EXACTLY 0 -- every step, word, state byte, edit, job and the memory after' if not bad else '%d differences -- NOT bit-exact' % bad))
sys.exit(0 if not bad else 1)
