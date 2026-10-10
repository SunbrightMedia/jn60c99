#!/usr/bin/env python3
"""jx_recall_data_gate.py -- the JX port's recall (jx3p_recall: the template + the recall aux) against the
plugin's own patch load, all 64 factory patches (two processes: Unicorn here, ctypes in a child).

ORACLE  tools/verify/jx_emu.py boot(44100, product=True, patch=k): static init, BUILD on the factory
        HOST, SETSR, initialize's records and patch k's patch-browser records through the engine's own
        host entry -- word for word the engine the plugin holds after its own patch load
        (jx3p/tools/jx_recall_product_check.py).
PORT    jx3p/gui/jx_bridge.c: jx3p_init (jx3p/gen/jx_template.bin, jx_master_recall.bin) + jx3p_recall(k).

Compared per patch, the windows the exporters ship: each voice unit's state [0, 0x60000) (its object
pointer at +136 excluded: the port links its own), its window [0xA60000, 0xAAD000), the master unit's
state [0, 0xAAD000) (+136 excluded), the 9 wrapper + ramp records in the exporter's form, the 36
control objects (note managers, note stores, assigners, parameter objects) and the engine HOST record
(the voice count, the output gain stage, the engine rate).

    python3 jx3p/tools/jx_recall_data_gate.py [--patches 0,5,20] [--tooth]
  --tooth: the port reads patch k+1's data for patch k (one off) -- must be seen (exit 0 = bites)
exit 0 = every window of every patch equal.
"""
import ctypes
import hashlib
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SNAP_V, SNAP_M, HI_LO, HI_SZ = 0x60000, 0xAAD000, 0xA60000, 0x4D000
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']


def digest(b):
    return hashlib.sha256(b).hexdigest()[:24]


def windows(lows, highs, master, wraps, ctl=(), host=None):
    out = {}
    for i, b in enumerate(ctl):                  # the 36 control objects (template regions 8..43)
        out['c%02d' % i] = digest(b)
    if host is not None:
        out['host'] = host.hex()
    for v in range(8):
        lo = bytearray(lows[v]); lo[136:144] = bytes(8)
        out['v%d' % v] = digest(bytes(lo))
        out['h%d' % v] = digest(highs[v])
    m = bytearray(master); m[136:144] = bytes(8)
    out['m'] = digest(bytes(m))
    for u in range(9):
        out['w%d' % u] = digest(wraps[u])
    return out


def oracle(patches):
    sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
    sys.path.insert(0, HERE)
    import jx_emu as J
    import jx_master_recall_export as X
    import jx_template_export as T
    res = {}
    for k in patches:
        jx = J.JX().boot(44100.0, snap=False, product=True, patch=k)
        uc = jx.uc
        lows = [bytes(uc.mem_read(jx.state[v], SNAP_V)) for v in range(8)]
        highs = [bytes(uc.mem_read(jx.state[v] + HI_LO, HI_SZ)) for v in range(8)]
        master = bytes(uc.mem_read(jx.state[8], SNAP_M))
        wraps = [X.wrap_record(jx, uc, u) for u in range(9)]
        q = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
        for i in range(9):                       # the assigner the render syncs IS the note manager's +0x520
            assert q(q(jx.HOST + 0x78 + 0x40 * i) + 0x520) == jx.assign[i], 'unit %d: two assigners' % i
        res[str(k)] = windows(lows, highs, master, wraps, T.control_blobs(jx), T.host_record(jx))
        print('oracle patch %d' % k, file=sys.stderr, flush=True)
    return res


def port(so, patches, shift):
    lib = ctypes.CDLL(so)
    for f in ('jx3p_vstate', 'jx3p_mstate', 'jx3p_vhigh', 'jx3p_ctl'):
        getattr(lib, f).restype = ctypes.c_void_p
    g = lambda p: os.path.join(REPO, 'jx3p', p)
    if not lib.jx3p_init(g('gen/jx_template.bin').encode(), g('truth/preset_bank_1.bin').encode(),
                         g('gen/jx_master_recall.bin').encode()):
        raise SystemExit('jx3p_init failed')
    buf = ctypes.create_string_buffer(1 << 20)
    res = {}
    for k in patches:
        lib.jx3p_recall(min(k + shift, 63))
        lows = [ctypes.string_at(lib.jx3p_vstate(v), SNAP_V) for v in range(8)]
        highs = [ctypes.string_at(lib.jx3p_vhigh(v), HI_SZ) for v in range(8)]
        master = ctypes.string_at(lib.jx3p_mstate(), SNAP_M)
        wraps = []
        for u in range(9):
            n = lib.jx3p_wrap_dump(u, buf, len(buf))
            if n < 0:
                raise SystemExit('wrap record %d too long' % u)
            wraps.append(buf.raw[:n])
        sizes = (0x7A8, 0xFF0, 0xB0)
        ctl = [ctypes.string_at(lib.jx3p_ctl(w, i), sizes[w]) for i in range(9) for w in range(3)]
        ctl += [ctypes.string_at(lib.jx3p_ctl(3, i), 0x700) for i in range(9)]
        hb = ctypes.create_string_buffer(28)
        if not lib.jx3p_host(hb):
            raise SystemExit('the port holds no engine HOST record (an old template?)')
        res[str(k)] = windows(lows, highs, master, wraps, ctl, hb.raw)
    return res


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle([int(x) for x in a[1].split(',')]), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], [int(x) for x in a[2].split(',')], int(a[3])), sys.stdout)
        return 0
    patches = [int(x) for x in a[a.index('--patches') + 1].split(',')] if '--patches' in a else list(range(64))
    tooth = '--tooth' in a
    tmp = tempfile.mkdtemp()
    so = os.path.join(tmp, 'libjx3p.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] +
                   [os.path.join(REPO, s) for s in SRCS] + ['-lm'], check=True)
    pl = ','.join(map(str, patches))
    o = subprocess.run([sys.executable, __file__, '--oracle', pl], capture_output=True, text=True)
    if o.returncode:
        raise SystemExit('oracle failed: ' + o.stderr[-800:])
    p = subprocess.run([sys.executable, __file__, '--port', so, pl, '1' if tooth else '0'], capture_output=True, text=True)
    if p.returncode:
        raise SystemExit('port failed: ' + p.stderr[-800:])
    ro, rp = json.loads(o.stdout), json.loads(p.stdout)
    bad = []
    for k in patches:
        diff = sorted(w for w in ro[str(k)] if ro[str(k)][w] != rp[str(k)][w])
        if diff:
            bad.append((k, diff))
    for k, diff in bad[:8]:
        print('  patch %d: windows differ: %s' % (k, ' '.join(diff)))
    if tooth:
        print('jx_recall_data_gate --tooth: %s' % ('BITES (%d patches differ)' % len(bad) if bad else 'DID NOT BITE'))
        return 0 if bad else 1
    print('jx_recall_data_gate: %d/%d patches, every window equal to the plugin\'s patch load: %s' % (
        len(patches) - len(bad), len(patches), 'GREEN' if not bad else 'RED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
