#!/usr/bin/env python3
"""jx_record_gate.py -- the JX-3P model's record image, plugin vs port (JX-24; jx3p/docs/HOST_LAYER.md 3q).

PLUGIN  scratchpad/jx_record/record_census.pkl (jx_record_census.py: the booted plugin's own serializer, rva
        0x335870, after the boot, after each of 738 model sets -- every DAW-state entry at 9 values, in order --
        after 7 patch loads (factory and random bodies) and 5 setStates)
PORT    jx3p/gui/jx_bridge.c on a fresh product instance: jx3p_record after the same steps (jx3p_model_set,
        jx3p_product_load_record, jx3p_state_load), a ctypes worker (two-process rule)
Compared: all 20,207 bytes after every step. --tooth: every JX_PREC_TOOTH build must differ.
exit 0 = EQUAL (or every tooth bites).
"""
import atexit
import ctypes
import os
import pickle
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
PKL = os.path.join(REPO, 'scratchpad', 'jx_record', 'record_census.pkl')
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
TEETH = [(1, "a two-nibble leaf's nibbles swapped"), (2, "a load keeps the image, not the record's bytes")]
_TMP = []
atexit.register(lambda: [shutil.rmtree(d, ignore_errors=True) for d in _TMP])


def plugin_images(r):
    """(label, image) after every step, the set diffs applied to the boot image in order"""
    out = [('boot', r['boot'])]
    cur = bytearray(r['boot'])
    for pid, v, d in r['sets']:
        if d is None:
            continue
        for i, a, b in d:
            if cur[i] != a:
                raise SystemExit('the census is not one chain: set 0x%x at %d' % (pid, i))
            cur[i] = b
        out.append(('set 0x%x = %d' % (pid, v), bytes(cur)))
    if bytes(cur) != r['after_sets']:
        raise SystemExit('the census diffs do not rebuild its image')
    for k, body, img in r['loads']:
        out.append(('load %d' % k, img))
    for pid, v, img in r['states']:
        out.append(('setState 0x%x = %d' % (pid, v), img))
    return out


def port_worker(so, out):
    sys.path.insert(0, HERE)
    import jx_guest
    r = pickle.load(open(PKL, 'rb'))
    lib = ctypes.CDLL(so)
    lib.jx_set_fp_oracle_mode(1)    # the oracle's mode: DAZ on, FTZ off -- Unicorn never flushes a result (playbook 120)
    lib.jx3p_product_init.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int]
    lib.jx3p_model_set.argtypes = [ctypes.c_uint32, ctypes.c_int32]
    if lib.jx3p_product_init(jx_guest.path(96).encode(),
                             os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode(), 48000) < 0:
        raise SystemExit('jx3p_product_init failed')
    buf = (ctypes.c_ubyte * 32768)()
    eid, ev, ek = (ctypes.c_uint32 * 512)(), (ctypes.c_double * 512)(), (ctypes.c_int * 512)()
    pend = (ctypes.c_int * (5 * 4096))()

    def image():
        n = lib.jx3p_record(buf, 32768)
        lib.jx3p_host_edits(eid, ev, ek, 512)          # (drained: what a host receives)
        return bytes(buf)[:n]
    res = [image()]
    for pid, v, d in r['sets']:
        if d is None:
            continue
        lib.jx3p_model_set(pid, v)
        res.append(image())
        if lib.jx3p_product_pending(pend, 5 * 4096) > 3000:   # the queue of the engine's records: a block
            L = (ctypes.c_float * 256)(); R = (ctypes.c_float * 256)()     # (the image is the model's alone)
            lib.jx3p_product_block(L, R, 256, (ctypes.c_int * 1)(), 0)
    for k, body, img in r['loads']:
        rec = bytes(16) + body
        if lib.jx3p_product_load_record((ctypes.c_ubyte * len(rec)).from_buffer_copy(rec), len(rec)) < 0:
            raise SystemExit('jx3p_product_load_record refused')
        res.append(image())
    for pid, v, img in r['states']:
        payload = struct.pack('>I', 8) + struct.pack('>Ii', pid, v)
        lib.jx3p_state_load((ctypes.c_ubyte * len(payload)).from_buffer_copy(payload), len(payload))
        res.append(image())
    pickle.dump(res, open(out, 'wb'))


def run(tooth):
    d = tempfile.mkdtemp(prefix='jxrec_')
    _TMP.append(d)
    so = os.path.join(d, 'libjx_t%d.so' % tooth)
    subprocess.check_call(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                           '-DJX_PREC_TOOTH=%d' % tooth, '-o', so] + [os.path.join(REPO, s) for s in SRCS] + ['-lm'])
    out = os.path.join(d, 'port.pkl')
    subprocess.check_call([sys.executable, os.path.abspath(__file__), '--port-worker', so, out])
    return pickle.load(open(out, 'rb'))


def main():
    a = sys.argv[1:]
    if a[:1] == ['--port-worker']:
        port_worker(a[1], a[2])
        return 0
    ref = plugin_images(pickle.load(open(PKL, 'rb')))
    if '--tooth' in a:
        res = []
        for n, what in TEETH:
            got = run(n)
            bad = sum(1 for (lab, x), y in zip(ref, got) if x != y)
            print('tooth %d %-48s %s (%d steps differ)' % (n, what, 'BITES' if bad else 'DID NOT BITE', bad))
            res.append(bad)
        return 0 if all(res) else 1
    got = run(0)
    if len(got) != len(ref):
        raise SystemExit('the port made %d images, the plugin %d' % (len(got), len(ref)))
    bad = [(lab, [i for i in range(len(x)) if i >= len(y) or x[i] != y[i]][:6]) for (lab, x), y in zip(ref, got) if x != y]
    for lab, offs in bad[:8]:
        print('  FAIL after %s: bytes %s differ' % (lab, offs))
    print('jx_record_gate: %d steps (the boot, %d sets, loads, setStates), every byte of the record image: %s' % (
        len(ref), sum(1 for lab, _ in ref if lab.startswith('set ')), 'EQUAL' if not bad else '%d DIFFER' % len(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
