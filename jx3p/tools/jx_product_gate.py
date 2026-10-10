#!/usr/bin/env python3
"""jx_product_gate.py -- the JX-3P as a DAW plays it: the plugin's own IAudioProcessor::process() at the
host rate against the port's render-object path (JX-4, two processes: Unicorn here, ctypes in a child).

ORACLE  jx3p/tools/jx_host_emu.py: createInstance, initialize, setupProcessing(rate, block), setActive,
        its patch browser's load of factory patch k (before the first block: the first process() drains
        initialize's records and the patch's), then process() per host block -- the render driver, the
        render object (the 96 kHz engine and the rate converter at hosts 44100 / 48000, the engine itself
        at 96000), the engine render with its voice-count sync and output gain stage, all its own code.
PORT    jx3p/gui/jx_bridge.c: jx3p_init on the 96 kHz data (jx3p/gen/jx_template_96k.bin.gz,
        jx_master_recall_96k.bin.gz: the plugin's boot and patch load at its engine's rate), jx3p_recall(k),
        jx3p_product_open(rate) (src/juno_conv.c, the JUNO-60's render object: table and vectors equal),
        jx3p_product_process per block.

The events: a note-on at --on seconds (velocity as process() converts it, (int)(float)(v x 127.0) &
0x7F), its note-off at --off seconds, --secs in all: the defaults play the note after the 0.5 s start
mute (engine samples; the same time at every host rate). By default each event reaches both sides at
offset 0 of the first block from its time; --exact puts it at its own sample, inside its block (the
render driver's split of the block at the record: jx3p_product_block, JX-7).

    python3 jx3p/tools/jx_product_gate.py [--rates 44100,48000,96000] [--patches 0,34] [--block 512]
                                          [--on 0.6] [--off 1.2] [--secs 1.5] [--exact] [--tooth | --tooth-clock]
  --tooth: the port runs the 44.1 kHz data with no render object (the engine at the host rate, the web
  app's path before JX-4) -- every rate must differ.
  --tooth-clock: the port built with JX_DRV_TOOTH (the render driver's first key does not restart the
  clock) -- every run must differ; give it the patches that play on the clock (34, 61).
exit 0 = every block of every (rate, patch) equal, bit for bit.
"""
import ctypes
import json
import os
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
NOTE, VEL = 60, 0.8


def vel7(v):
    """the velocity as process() converts it (the JUNO's wrapper as ported: gui/juno_bridge.c
    juno_gui_process_ex; the JX's process() is the same code, jx3p/tools/fw_map.py): float x 127.0 in
    double, to float, truncated, 7 bits"""
    f = struct.unpack('<f', struct.pack('<f', v * 127.0))[0]
    return int(f) & 0x7F


def schedule(nblk, blk, on, off):
    """on / off: host samples; per block its events at their offsets"""
    out = [[] for _ in range(nblk)]
    for s, e in ((on, ('on', NOTE, VEL)), (off, ('off', NOTE, 0.0))):
        if s // blk < nblk:
            out[s // blk].append((e[0], s % blk, 0, e[1], e[2]))
    return out


def oracle(rate, patch, nblk, blk, on, off):
    sys.path.insert(0, HERE)
    sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
    import jx_bank as B
    import jx_host_emu as X
    bank = open(os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin'), 'rb').read()
    h = X.JXHost()
    h.start(float(rate), blk)
    tail = bank[B.BANK_HEADER + patch * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (patch + 1) * B.BANK_STRIDE]
    h.load_patch(tail)
    out = []
    for ev in schedule(nblk, blk, on, off):
        L, R = h.process(blk, events=ev)
        out.append([list(L), list(R)])
    return out


def data96(tmp):
    """the 96 kHz engine's data: the committed .gz (jx_template_export.py 96000 --out, jx_master_recall_export.py
    --rate 96000), inflated into tmp"""
    import gzip
    out = []
    for name in ('jx_template_96k.bin', 'jx_master_recall_96k.bin'):
        raw = os.path.join(REPO, 'jx3p', 'gen', name)
        if not os.path.exists(raw):
            raw = os.path.join(tmp, name)
            with gzip.open(os.path.join(REPO, 'jx3p', 'gen', name + '.gz'), 'rb') as f:
                open(raw, 'wb').write(f.read())
        out.append(raw)
    return out


def port(so, rate, patch, nblk, blk, on, off, tooth, tmpl96, aux96):
    lib = ctypes.CDLL(so)
    lib.jx_enable_hw_ftz()
    g = lambda p: os.path.join(REPO, 'jx3p', p).encode()
    t, x = (g('gen/jx_template.bin'), g('gen/jx_master_recall.bin')) if tooth else (tmpl96.encode(), aux96.encode())
    if not lib.jx3p_init(t, g('truth/preset_bank_1.bin'), x):
        raise SystemExit('jx3p_init failed')
    lib.jx3p_recall(patch)
    if tooth:
        lib.jx3p_host_stage(1)
    else:
        kind = lib.jx3p_product_open(rate)
        if kind < 0:
            raise SystemExit('jx3p_product_open(%d) -> %d' % (rate, kind))
    out = []
    Lb = (ctypes.c_float * blk)(); Rb = (ctypes.c_float * blk)()
    for b, ev in enumerate(schedule(nblk, blk, on, off)):
        if tooth:
            for e in ev:
                if e[0] == 'on':
                    lib.jx3p_note_on(e[3], vel7(e[4]))
                else:
                    lib.jx3p_note_off(e[3])
            lib.jx3p_render(Lb, Rb, blk)
        else:                                 # the render driver: the records at their offsets, the clock
            recs = [x for e in ev for x in (e[1], 0 if e[0] == 'on' else 1, e[3], vel7(e[4]))]
            arr = (ctypes.c_int * max(1, len(recs)))(*recs)
            lib.jx3p_product_block(Lb, Rb, blk, arr, len(ev))
        out.append([list(struct.unpack('<%dI' % blk, bytes(Lb))), list(struct.unpack('<%dI' % blk, bytes(Rb)))])
    return out


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle(*[int(x) for x in a[1:7]]), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], *[int(x) for x in a[2:8]], a[8] == '1', a[9], a[10]), sys.stdout)
        return 0
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    rates = [int(x) for x in opt('--rates', '44100,48000,96000').split(',')]
    patches = [int(x) for x in opt('--patches', '0,34').split(',')]
    blk = int(opt('--block', '512'))
    t_on, t_off, secs = float(opt('--on', '0.6')), float(opt('--off', '1.2')), float(opt('--secs', '1.5'))
    tooth, tclock, exact = '--tooth' in a, '--tooth-clock' in a, '--exact' in a
    tmp = tempfile.mkdtemp()
    so = os.path.join(tmp, 'libjx3p.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] +
                   (['-DJX_DRV_TOOTH=1'] if tclock else []) + [os.path.join(REPO, s) for s in SRCS] + ['-lm'],
                   check=True)
    tmpl96, aux96 = data96(tmp)
    bad = 0
    for rate in rates:
        nblk = -(-int(secs * rate) // blk)
        if exact:                             # the event's own sample
            on, off = int(t_on * rate), int(t_off * rate)
        else:                                 # offset 0 of the first block from it
            on, off = (-(-int(t * rate) // blk) * blk for t in (t_on, t_off))
        for patch in patches:
            args = [str(x) for x in (rate, patch, nblk, blk, on, off)]
            o = subprocess.run([sys.executable, __file__, '--oracle'] + args, capture_output=True, text=True)
            if o.returncode:
                raise SystemExit('oracle failed: ' + o.stderr[-1500:])
            p = subprocess.run([sys.executable, __file__, '--port', so] + args + ['1' if tooth else '0', tmpl96, aux96],
                               capture_output=True, text=True)
            if p.returncode:
                raise SystemExit('port failed: ' + p.stderr[-1500:])
            ro, rp = json.loads(o.stdout), json.loads(p.stdout)
            first = next(((b, s) for b in range(nblk) for s in range(blk)
                          if ro[b][0][s] != rp[b][0][s] or ro[b][1][s] != rp[b][1][s]), None)
            loud = sum(1 for b in range(nblk) for x in ro[b][0] if x & 0x7FFFFFFF)
            if first is None:
                print('  host %d patch %d: %d blocks of %d EQUAL (%d nonzero L samples in the plugin\'s output)' % (
                    rate, patch, nblk, blk, loud), flush=True)
            else:
                bad += 1
                b, s = first
                f = lambda x: struct.unpack('<f', struct.pack('<I', x))[0]
                print('  host %d patch %d: first difference block %d sample %d (host sample %d): plugin L %r port L %r' % (
                    rate, patch, b, s, b * blk + s, f(ro[b][0][s]), f(rp[b][0][s])), flush=True)
            if not loud:
                print('  REFUSE: the plugin\'s output is silent -- this run graded nothing'); bad += 1
    n = len(rates) * len(patches)
    if tooth or tclock:
        print('jx_product_gate %s: %s' % ('--tooth' if tooth else '--tooth-clock', 'BITES (%d of %d differ)' % (
            bad, n) if bad == n else 'DID NOT BITE on %d of %d' % (n - bad, n)))
        return 0 if bad == n else 1
    print('jx_product_gate: %d of %d (host rate, patch) runs equal to the plugin\'s process(): %s' % (
        n - bad, n, 'GREEN' if not bad else 'RED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
