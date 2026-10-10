#!/usr/bin/env python3
"""jx_product_gate.py -- the JX-3P as a DAW plays it: the plugin's own IAudioProcessor::process() at the
host rate against the port's render-object path (JX-4, two processes: Unicorn here, ctypes in a child).

ORACLE  jx3p/tools/jx_host_emu.py: createInstance, initialize, setupProcessing(rate, block), setActive,
        its patch browser's load of factory patch k (before the first block: the first process() drains
        initialize's records and the patch's), then process() per host block -- the render driver, the
        render object (the 96 kHz engine and the rate converter at hosts 44100 / 48000, the engine itself
        at 96000), the engine render with its voice-count sync and output gain stage, all its own code.
PORT    jx3p/gui/jx_bridge.c: jx3p_init on the 96 kHz guest image (jx3p/gen/jx_guest_96k.bin.gz: the plugin's
        heap after its boot at its engine's rate), jx3p_recall(k) (the patch's records through the plugin's own
        parameter system, lifted -- JX-11),
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
  --tooth-voices: the port built with JX_VC_TOOTH (all eight voice units play, the HOST's count of six
  ignored) -- every --poly run must differ.
  --expect-silent: for host rates outside the render object's table (32000: EXECUTED, the plugin's
  process() returns silence there) -- a run passes when both outputs are equal AND silent.
  --poly SEEDS (e.g. 1,2,3): instead of the one note, a seeded polyphonic sequence per seed from --on to
  --secs: chords, up to 10 keys held (more than the six voices: the render's voice-count sync and the
  allocator's steals), re-struck keys, note-offs, every event at its own sample, several at one sample
  (a note-off and a note-on of one key at one sample included), velocities across the range.
  --recall 'P@T,...' (JX-11): WARM patch changes -- at the first block from T seconds the plugin's patch
  browser loads factory patch P on the running engine (its 75 records queued between two blocks); the port
  gets the same records (jx3p/gen/jx_patch_records.json) at offset 0 of that block, before its keys, and
  its render driver hands them to the lifted host entry. A held note crosses the change; every change
  mutes 0.5 s and fades in (writePatch).
  --tooth-recall: the port loads patch P+1 where the plugin loads P -- every --recall run must differ.
  --edits SEEDS (e.g. 1,2): HOST AUTOMATION -- per seed a run whose blocks, from the note-on on, carry
  seeded host parameter points (VST3 parameter queues) through the plugin's process(): ids from the id map
  its render driver searches (jx3p/src/jx_midi_tables.h, generated from the booted plugin) and ids the map
  lacks, values 0..1, the ends, a few beyond them, several points of one id in a block (process() reads the
  last), several ids at one sample. The port takes each queue's last point (jx3p_product_param: the value as
  a float, a kind-1 record after the block's notes; the driver's id map and value law, the lifted host
  entry).
  --tooth-edits: the port gets no host parameter points -- every --edits run must differ.
  --tooth-law: the port built with JX_LAW_TOOTH (the value law truncates, rva 0x31A820 rounds) -- every
  --edits run must differ.
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


def poly_schedule(nblk, blk, start, seed):
    """the --poly sequence: (kind, offset, channel, pitch, velocity) per block, in sample order (the
    order a host's event list has), from host sample `start` to the last block"""
    import random
    r = random.Random(seed)
    out = [[] for _ in range(nblk)]
    held, s, end = [], start, (nblk - 1) * blk
    while True:
        s += r.choice((0, 0, 1, 5, 64, 300, 1000, 2500, 5000, 9000))
        if s >= end:
            break
        if r.random() < 0.6 and len(held) < 10:
            for _ in range(r.choice((1, 1, 1, 2, 3, 4))):
                note = r.choice(held) if held and r.random() < 0.12 else r.randrange(36, 97)
                vel = r.choice((0.05, 0.3, 0.5, 0.8, 1.0, max(0.05, r.random())))
                out[s // blk].append(('on', s % blk, 0, note, vel))
                if note not in held:
                    held.append(note)
        elif held:
            for _ in range(r.choice((1, 1, 2))):
                if not held:
                    break
                note = held.pop(r.randrange(len(held)))
                out[s // blk].append(('off', s % blk, 0, note, 0.0))
                if r.random() < 0.15:                         # the same key struck again at the same sample
                    out[s // blk].append(('on', s % blk, 0, note, 0.7))
                    held.append(note)
    return out


def schedule(nblk, blk, on, off):
    """on / off: host samples; per block its events at their offsets; on < 0: the --poly sequence of
    seed -on - 1 from host sample off"""
    if on < 0:
        return poly_schedule(nblk, blk, off, -on - 1)
    out = [[] for _ in range(nblk)]
    for s, e in ((on, ('on', NOTE, VEL)), (off, ('off', NOTE, 0.0))):
        if s // blk < nblk:
            out[s // blk].append((e[0], s % blk, 0, e[1], e[2]))
    return out


def recall_map(spec, rate, blk):
    """--recall 'P@T,...': factory patch P loaded at host time T seconds -> {block: patch}, the block that
    starts at or after T (a patch load is queued between two blocks)"""
    out = {}
    for item in filter(None, spec.split(',')):
        p, _, t = item.partition('@')
        out[-(-int(float(t) * rate) // blk)] = int(p)
    return out


def edit_ids():
    """the VST3 parameter ids the render driver's id map holds (jx3p/src/jx_midi_tables.h, generated from the
    booted plugin by jx_gen_midi_tables.py) and, apart, ids below the MIDI-mapping base that it lacks"""
    import re
    src = open(os.path.join(REPO, 'jx3p', 'src', 'jx_midi_tables.h')).read()
    ids = sorted(int(m, 16) for m in re.findall(r'\{ 0x([0-9A-F]{8})u, -?\d+ \}',
                                                   src[src.index('JX_MIDI_IDMAP[JX_MIDI_IDMAP_N]'):]))
    lack = [x for x in (0x0, 0x1, 0x00600001, 0x00600200, 0x0FFFC001, 0x0FFFC0FF, 0x80000000) if x not in ids]
    return ids, lack


def edit_schedule(nblk, blk, start, seed):
    """the --edits sequence: per block its host parameter points (id, offset, value) in sample order, from host
    sample `start` to the last block"""
    import random
    ids, lack = edit_ids()
    r = random.Random(7919 * seed + 1)
    out = [[] for _ in range(nblk)]
    s, end = start, nblk * blk
    while True:
        s += r.choice((0, 0, 1, 7, 64, 300, 1000, 2500, 6000))
        if s >= end:
            break
        pid = r.choice(ids) if r.random() < 0.92 else r.choice(lack)
        v = r.choice((0.0, 1.0, 0.5, r.random(), r.random(), r.random(), r.random(), -0.25, 1.25, 1e-9))
        out[s // blk].append((pid, s % blk, v))
    return out


def queues(points):
    """the block's points as process() reads them: one record per parameter queue (first appearance order), its
    last point"""
    last, order = {}, []
    for pid, off, v in points:
        if pid not in last:
            order.append(pid)
        last[pid] = (off, v)
    return [(pid,) + last[pid] for pid in order]


def oracle(rate, patch, nblk, blk, on, off, recalls='', edits=-1):
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
    rmap = recall_map(recalls, rate, blk)
    par = edit_schedule(nblk, blk, on if on >= 0 else off, edits) if edits >= 0 else [[] for _ in range(nblk)]
    for b, ev in enumerate(schedule(nblk, blk, on, off)):
        if b in rmap:                         # the plugin's patch browser, between two blocks (WARM: JX-11)
            p = rmap[b]
            h.load_patch(bank[B.BANK_HEADER + p * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (p + 1) * B.BANK_STRIDE])
        L, R = h.process(blk, events=ev, params=par[b])
        out.append([list(L), list(R)])
    return out


def guest96(tmp):
    """the 96 kHz engine's guest image: the committed .gz (jx_guest_export.py --rate 96000), inflated into tmp"""
    import gzip
    raw = os.path.join(REPO, 'jx3p', 'gen', 'jx_guest_96k.bin')
    if not os.path.exists(raw):
        raw = os.path.join(tmp, 'jx_guest_96k.bin')
        with gzip.open(os.path.join(REPO, 'jx3p', 'gen', 'jx_guest_96k.bin.gz'), 'rb') as f:
            open(raw, 'wb').write(f.read())
    return raw


def port(so, rate, patch, nblk, blk, on, off, tooth, img96, recalls='', edits=-1):
    lib = ctypes.CDLL(so)
    lib.jx_enable_hw_ftz()
    lib.jx3p_lift_error.restype = ctypes.c_char_p
    g = lambda p: os.path.join(REPO, 'jx3p', p).encode()
    if not lib.jx3p_init(g('gen/jx_guest_44k.bin') if tooth else img96.encode(), g('truth/preset_bank_1.bin'), None):
        raise SystemExit('jx3p_init failed')
    lib.jx3p_recall(patch)
    if lib.jx3p_lift_error():
        raise SystemExit('the lifted parameter system trapped: %s' % lib.jx3p_lift_error().decode())
    if tooth:
        lib.jx3p_host_stage(1)
    else:
        kind = lib.jx3p_product_open(rate)
        if kind < 0:
            raise SystemExit('jx3p_product_open(%d) -> %d' % (rate, kind))
    out = []
    rmap = recall_map(recalls, rate, blk)
    par = edit_schedule(nblk, blk, on if on >= 0 else off, edits) if edits >= 0 else [[] for _ in range(nblk)]
    lib.jx3p_product_param.argtypes = [ctypes.c_uint, ctypes.c_int, ctypes.c_double]
    sys.path.insert(0, HERE)
    import jx_records
    JX_RECORDS = jx_records.records()
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
            nev = len(ev)
            if b in rmap:                     # the patch load's records, queued before the block's keys
                q = rmap[b] + (1 if os.environ.get('JX_RECALL_TOOTH') == '1' else 0)     # TOOTH: the wrong patch
                pr = [(pid, v) for kind, pid, v in JX_RECORDS['patches'][q % 64] if kind == 2]
                recs = [x for pid, v in pr for x in (0, 2, pid, v - (1 << 32) if v >= 1 << 31 else v)] + recs
                nev += len(pr)
            if os.environ.get('JX_EDIT_TOOTH') != '1':         # TOOTH: no host parameter points
                for pid, off, v in queues(par[b]):
                    if lib.jx3p_product_param(pid, off, v) != 0:
                        raise SystemExit('jx3p_product_param(0x%x) refused' % pid)
            arr = (ctypes.c_int * max(1, len(recs)))(*recs)
            lib.jx3p_product_block(Lb, Rb, blk, arr, nev)
        out.append([list(struct.unpack('<%dI' % blk, bytes(Lb))), list(struct.unpack('<%dI' % blk, bytes(Rb)))])
    if lib.jx3p_lift_error():                 # a trap in a mid-run record list: never a silent pass
        raise SystemExit('the lifted parameter system trapped during the run: %s' % lib.jx3p_lift_error().decode())
    return out


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle(*[int(x) for x in a[1:7]], recalls=a[7], edits=int(a[8])), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], *[int(x) for x in a[2:8]], a[8] == '1', a[9], a[10], int(a[11])), sys.stdout)
        return 0
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    rates = [int(x) for x in opt('--rates', '44100,48000,96000').split(',')]
    patches = [int(x) for x in opt('--patches', '0,34').split(',')]
    blk = int(opt('--block', '512'))
    t_on, t_off, secs = float(opt('--on', '0.6')), float(opt('--off', '1.2')), float(opt('--secs', '1.5'))
    tooth, tclock, tvc, exact = '--tooth' in a, '--tooth-clock' in a, '--tooth-voices' in a, '--exact' in a
    trec = '--tooth-recall' in a
    if trec:
        os.environ['JX_RECALL_TOOTH'] = '1'
    tedit = '--tooth-edits' in a
    if tedit:
        os.environ['JX_EDIT_TOOTH'] = '1'
    tlaw = '--tooth-law' in a
    eseeds = [int(x) for x in opt('--edits', '').split(',') if x]
    silent = '--expect-silent' in a
    seeds = [int(x) for x in opt('--poly', '').split(',') if x]
    recalls = opt('--recall', '')               # 'P@T,...': warm patch loads (the plugin's patch browser)
    tmp = tempfile.mkdtemp()
    so = os.path.join(tmp, 'libjx3p.so')
    subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so] +
                   (['-DJX_DRV_TOOTH=1'] if tclock else []) + (['-DJX_VC_TOOTH=1'] if tvc else []) +
                   (['-DJX_LAW_TOOTH=1'] if tlaw else []) +
                   [os.path.join(REPO, s) for s in SRCS] + ['-lm'],
                   check=True)
    img96 = guest96(tmp)
    bad = 0
    for rate in rates:
        nblk = -(-int(secs * rate) // blk)
        if exact:                             # the event's own sample
            on, off = int(t_on * rate), int(t_off * rate)
        else:                                 # offset 0 of the first block from it
            on, off = (-(-int(t * rate) // blk) * blk for t in (t_on, t_off))
        # (on, off) per run: the one note, or per --poly seed (-seed - 1, the sequence's first sample)
        plans = [(-sd - 1, int(t_on * rate), -1) for sd in seeds] if seeds else [(on, off, -1)]
        if eseeds:                            # host automation: each seed on the plan's notes
            plans = [(pon, poff, es) for (pon, poff, _) in plans for es in eseeds]
        for patch, (on, off, es) in [(p, pl) for p in patches for pl in plans]:
            args = [str(x) for x in (rate, patch, nblk, blk, on, off)]
            o = subprocess.run([sys.executable, __file__, '--oracle'] + args + [recalls, str(es)], capture_output=True,
                               text=True)
            if o.returncode:
                raise SystemExit('oracle failed: ' + o.stderr[-1500:])
            p = subprocess.run([sys.executable, __file__, '--port', so] + args +
                               ['1' if tooth else '0', img96, recalls, str(es)], capture_output=True, text=True)
            if p.returncode:
                raise SystemExit('port failed: ' + p.stderr[-1500:])
            ro, rp = json.loads(o.stdout), json.loads(p.stdout)
            first = next(((b, s) for b in range(nblk) for s in range(blk)
                          if ro[b][0][s] != rp[b][0][s] or ro[b][1][s] != rp[b][1][s]), None)
            loud = sum(1 for b in range(nblk) for x in ro[b][0] if x & 0x7FFFFFFF)
            what = 'patch %d' % patch + (' poly seed %d' % (-on - 1) if on < 0 else '')
            if on < 0:
                nev = sum(len(e) for e in schedule(nblk, blk, on, off))
                what += ' (%d events)' % nev
            if es >= 0:
                sched = edit_schedule(nblk, blk, on if on >= 0 else off, es)
                what += ' edits seed %d (%d points, %d records)' % (es, sum(len(x) for x in sched),
                                                                     sum(len(queues(x)) for x in sched))
            if first is None:
                print('  host %d %s: %d blocks of %d EQUAL (%d nonzero L samples in the plugin\'s output)' % (
                    rate, what, nblk, blk, loud), flush=True)
            else:
                bad += 1
                b, s = first
                f = lambda x: struct.unpack('<f', struct.pack('<I', x))[0]
                print('  host %d %s: first difference block %d sample %d (host sample %d): plugin L %r port L %r' % (
                    rate, what, b, s, b * blk + s, f(ro[b][0][s]), f(rp[b][0][s])), flush=True)
            if silent:
                if loud:
                    print('  REFUSE: --expect-silent, but the plugin sounds at host %d' % rate); bad += 1
            elif not loud:
                print('  REFUSE: the plugin\'s output is silent -- this run graded nothing'); bad += 1
    n = len(rates) * len(patches) * max(1, len(seeds)) * max(1, len(eseeds))
    if tooth or tclock or tvc or trec or tedit or tlaw:
        print('jx_product_gate %s: %s' % ('--tooth' if tooth else '--tooth-clock' if tclock else '--tooth-voices'
                                          if tvc else '--tooth-recall' if trec else '--tooth-edits' if tedit
                                          else '--tooth-law',
                                          'BITES (%d of %d differ)' % (bad, n) if bad == n else
                                          'DID NOT BITE on %d of %d' % (n - bad, n)))
        return 0 if bad == n else 1
    print('jx_product_gate: %d of %d (host rate, patch) runs equal to the plugin\'s process(): %s' % (
        n - bad, n, 'GREEN' if not bad else 'RED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
