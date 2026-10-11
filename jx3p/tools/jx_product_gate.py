#!/usr/bin/env python3
"""jx_product_gate.py -- the JX-3P as a DAW plays it: the plugin's own IAudioProcessor::process() at the
host rate against the port's render-object path (JX-4, two processes: Unicorn here, ctypes in a child).

ORACLE  jx3p/tools/jx_host_emu.py: createInstance, initialize, setupProcessing(rate, block), setActive,
        its patch browser's load of factory patch k (before the first block: the first process() drains
        initialize's records and the patch's), then process() per host block -- the render driver, the
        render object (the 96 kHz engine and the rate converter at hosts 44100 / 48000, the engine itself
        at 96000), the engine render with its voice-count sync and output gain stage, all its own code.
PORT    jx3p/gui/jx_bridge.c: jx3p_product_init(image, bank, rate) on the 96 kHz guest image (jx3p/gen/
        jx_guest_96k.bin.gz: the plugin's heap as setActive leaves it, at its engine's rate) -- the render object
        (src/juno_conv.c, the JUNO-60's: table and vectors equal) and initialize's records QUEUED for the first
        block (JX-15b) --, jx3p_product_load_patch(k) (the patch browser's records queued after them; the
        plugin's own parameter system, lifted, applies both at the first block -- JX-11), then
        jx3p_product_block per block.

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
  queues the same load (jx3p_product_load_patch: the records the image holds, the store, the KEY HOLD
  release), after a setState of the same gap, before the block's keys, and its render driver hands them to
  the lifted host entry. Loads that land on one block queue in their order (changes in fast succession). A
  held note crosses the change; every change mutes 0.5 s and fades in (writePatch). 'rS@T': a record of seeded
  random bytes (jx_patch_gate.py record: a user's bank) -- the plugin's load of its bytes, the port's
  jx3p_product_load_record (JX-16).
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
  --ctl SEEDS (JX-12): THE MIDI CONTROLLERS as a DAW sends them -- seeded MIDI-mapping parameter points (the
  base 0x0FFFC100 + n: the CC n, 128 channel aftertouch, 129 bend, beyond that nothing): sustain (CC 64) on
  and off, all notes off (123), mod (1), expression (11), the CCs the plugin's default map assigns to
  parameters, CCs it ignores, bend and aftertouch -- with the plan's notes (best with --poly). The port: its
  process() conversion and push (jx3p_product_param: the CC map's parameter record, then the message), the
  driver's dispatch to the engine's CC and bend entries (lifted).
  --tooth-ctl: the port gets no controller points -- every --ctl run must differ.
  --ctl-only N,...: only those MIDI-mapping numbers of the --ctl sequence (1 mod, 11 expression, 64 sustain,
  123 all notes off, 128 aftertouch, 129 bend, any CC) -- to bisect a difference.
  --tempo 'BPM@T,...;...' (JX-8): per ';' group a run whose host gives process() a ProcessContext with that
  tempo (kTempoValid) from the block at or after T seconds ('x@T': no valid tempo from T; before the first
  point no context) -- the render driver's clock and the engine's tempo entry (vt+0xB0, lifted).
  --tooth-tempo: the port never hears the tempo -- every --tempo run must differ.
  --state 'SEED@T,...;...' (JX-17): per ';' group a run whose host calls IComponent::setState between two blocks
  with seeded payloads (state_loads: parameters across and past their ranges, an unknown id, CC map entries; 'rV'
  for SEED: the engine-rate setting alone, vm.vs.sampleRate = V -- JX-15);
  the port: jx3p_state_load. --tooth-state: the port misses the setState -- every run must differ.
  --set 'ID=V,...;ID=V,...' (JX-12b): per ';' group a run whose first block starts with those host parameter
  points (VST3 ids in hex, values 0..1) -- the note modes no factory patch sets: LEGATO 600062 (no patch sets
  it), ASSIGN MODE 600064, PORTAMENTO 600060, ARPEGGIO 600108 -- with the plan's notes, edits and controllers;
  'ID=V@T': that point at host time T seconds, at its own sample inside its block (e.g. ARPEGGIO switched on
  and off while keys are held).
  --rerate 'R@B,...;...' (JX-26c; the JUNO-60's host_rate_gate.py, CLAIMS A28): per ';' group a run whose host
  calls setActive(false), setupProcessing(R), setActive(true) before block B -- a host-rate change on the running
  instance (the port: jx3p_set_active / jx3p_setup_processing). --tooth-rerate: the port's setActive dropped (the
  old render object kept) -- every run must differ.
  --state 'sID=V@T': one state entry alone (hex id), e.g. the voice count s0FFFC00E=4 (JX-26c).
  --vel: the edge-velocity plan (vel_schedule) in place of the one note: velocity 0 (a note-off at 64), 1, 37,
  64, 99, 100, 101, 126, 127 of 127 and floats between, MIDI channels 1 and 10 (JX-26c; the JUNO-60's
  wrapper_velocity_gate.py, CLAIMS A23).
  --patches A-B: a range (e.g. 0-63).
The notes reach the port as process() takes them (jx3p_product_note: the float velocity, the wrapper's
rules); the patch loads' records as the patch browser queues them (jx3p_product_load_patch).
exit 0 = every block of every (rate, patch) equal, bit for bit.
"""
import atexit
import ctypes
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_voice_render.c',
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


VEL_PLAN = (0.0, 1 / 127, 37 / 127, 64 / 127, 99 / 127, 100 / 127, 101 / 127, 126 / 127, 1.0, 0.5, 1e-9, 0.99999)
VEL_ON = -1000000                              # the 'on' that asks for the --vel plan


def vel_schedule(nblk, blk, start):
    """--vel (JX-26c; the JUNO-60's wrapper_velocity_gate, CLAIMS A23): note-ons at the edge velocities -- 0 (the
    wrapper makes it a note-off at 64), 1, 37, 64, 99, 100, 101, 126, 127 of 127 and floats between --, on MIDI
    channels 1 and 10 by turns, each released 300 samples later at velocity 0, 0.5 or 1"""
    out = [[] for _ in range(nblk)]
    for k, v in enumerate(VEL_PLAN):
        s, ch, pitch = start + 700 * k, 9 * (k & 1), 40 + 3 * k
        for t, e in ((s, ('on', ch, pitch, v)), (s + 300, ('off', ch, pitch, (0.0, 0.5, 1.0)[k % 3]))):
            if t // blk < nblk:
                out[t // blk].append((e[0], t % blk) + e[1:])
    return out


def schedule(nblk, blk, on, off):
    """on / off: host samples; per block its events at their offsets; on < 0: the --poly sequence of
    seed -on - 1 from host sample off; on == VEL_ON: the --vel plan from host sample off"""
    if on == VEL_ON:
        return vel_schedule(nblk, blk, off)
    if on < 0:
        return poly_schedule(nblk, blk, off, -on - 1)
    out = [[] for _ in range(nblk)]
    for s, e in ((on, ('on', NOTE, VEL)), (off, ('off', NOTE, 0.0))):
        if s // blk < nblk:
            out[s // blk].append((e[0], s % blk, 0, e[1], e[2]))
    return out


def recall_map(spec, rate, blk):
    """--recall 'P@T,...': factory patch P loaded at host time T seconds -> {block: [patch, ...]}, the block that
    starts at or after T (a patch load is queued between two blocks; loads that land on one block queue in
    their order: changes in fast succession)"""
    out = {}
    for item in filter(None, spec.split(',')):
        p, _, t = item.partition('@')
        out.setdefault(-(-int(float(t) * rate) // blk), []).append(('r', int(p[1:])) if p[0] == 'r' else int(p))
    return out


def rec_bytes(p):
    """('r', seed): a bank record of seeded random bytes (jx_patch_gate.record: a user's bank as the patch browser
    reads it -- JX-16); the whole record, its name first"""
    sys.path.insert(0, HERE)
    import jx_patch_gate
    return jx_patch_gate.record('rnd', p[1])


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


def midi_base():
    import re
    return int(re.search(r'#define JX_MIDI_BASE 0x([0-9A-F]+)u', open(os.path.join(REPO, 'jx3p', 'src',
                                                                               'jx_midi_tables.h')).read()).group(1), 16)


def ctl_schedule(nblk, blk, start, seed):
    """the --ctl sequence: per block its MIDI-mapping points (base + n, offset, value) in sample order, from host
    sample `start` to the last block"""
    import random
    import re
    src = open(os.path.join(REPO, 'jx3p', 'src', 'jx_midi_tables.h')).read()
    blk_map = src[src.index('JX_CC_MAP[128]'):]
    cmap = [int(x) for x in re.findall(r'-?\d+', blk_map[blk_map.index('{'):blk_map.index('}')])]
    mapped = [cc for cc in range(128) if cmap[cc] >= 0]
    base = midi_base()
    r = random.Random(104729 * seed + 7)
    out = [[] for _ in range(nblk)]
    s, end = start, nblk * blk
    while True:
        s += r.choice((0, 0, 1, 7, 64, 300, 1000, 2500, 6000))
        if s >= end:
            break
        u = r.random()
        if u < 0.22:
            n, v = 64, r.choice((0.0, 1.0, 0.5, 0.003, 0.0, 1.0))         # sustain off / on (0.003 x 127 rounds to 0)
        elif u < 0.30:
            n, v = 123, r.choice((0.0, 1.0, r.random()))                  # all notes off
        elif u < 0.42:
            n, v = 1, r.choice((0.0, 1.0, r.random(), r.random(), 1.2))   # mod (data 152 > 127: ignored)
        elif u < 0.50:
            n, v = 11, r.choice((0.0, 1.0, r.random(), r.random()))       # expression
        elif u < 0.66:
            n, v = 129, r.choice((0.5, 0.0, 1.0, r.random(), r.random()))  # bend
        elif u < 0.70:
            n, v = 128, r.random()                                         # channel aftertouch: an empty entry
        elif u < 0.92:
            n, v = r.choice(mapped), r.choice((0.0, 1.0, r.random(), r.random(), -0.1))   # a mapped CC
        else:
            n, v = r.choice((10, 2, 3, 120, 127, 130, 200)), r.random()    # ignored CCs, beyond 129: nothing
        out[s // blk].append((base + n, s % blk, v))
    return out


def points(nblk, blk, on, off, es):
    """the run's host parameter points per block: es '-1' none, 'e<seed>' --edits, 'c<seed>' --ctl, 'c<seed>:n,n'
    --ctl with --ctl-only (only those MIDI-mapping numbers kept: a bisection of a difference); a '|ID=V,...' tail
    (--set): those points first, at offset 0 of block 0"""
    es, _, sets = es.partition('|')
    sets = sets.split('|')[0]
    start = on if on >= 0 else off
    if es.startswith('e'):
        sched = edit_schedule(nblk, blk, start, int(es[1:]))
    elif es.startswith('c'):
        seed, _, only = es[1:].partition(':')
        sched = ctl_schedule(nblk, blk, start, int(seed))
        if only:
            keep, base = {int(x) for x in only.split(',')}, midi_base()
            sched = [[p for p in b if p[0] - base in keep] for b in sched]
    else:
        sched = [[] for _ in range(nblk)]
    if sets:                                  # 'ID=V' at offset 0 of block 0; 'ID=V@S' at host sample S (its block,
        first = [[] for _ in range(nblk)]     # its offset) -- each block's set points before its seeded ones
        for x in sets.split(','):
            k, _, v = x.partition('=')
            v, at, smp = v.partition('@')
            b, o = divmod(int(smp), blk) if at else (0, 0)
            if b < nblk:
                first[b].append((int(k, 16), o, float(v)))
        sched = [first[b] + sched[b] for b in range(nblk)]
    return sched


def timed(group, rate):
    """a --set group with its 'ID=V@T' points (T in seconds) given as 'ID=V@S' (S the host sample at the rate)"""
    out = []
    for x in group.split(','):
        k, _, v = x.partition('=')
        v, at, t = v.partition('@')
        out.append('%s=%s' % (k, v) + ('@%d' % int(float(t) * rate) if at else ''))
    return ','.join(out)


def tempo_blocks(spec, rate, blk, nblk):
    """--tempo group 'BPM@T,...' -> per block (valid, bpm): from the block that starts at or after T seconds the host's
    ProcessContext carries that tempo with kTempoValid ('x@T': a context without a valid tempo from T); before the
    first point no context. A host gives one context per process() call."""
    out = [(0, 120.0)] * nblk
    for item in filter(None, spec.split(',')):
        v, _, t = item.partition('@')
        b0 = -(-int(float(t or 0) * rate) // blk)
        for b in range(b0, nblk):
            out[b] = (0, 120.0) if v == 'x' else (1, float(v))
    return out


def rerates(spec):
    """--rerate group 'R@B,...' -> {block: host rate}: before block B the host calls setActive(false),
    setupProcessing(R), setActive(true) on the running instance (JX-26c; the JUNO-60's host_rate_gate.py)"""
    out = {}
    for item in filter(None, spec.split(',')):
        r, _, b = item.partition('@')
        out[int(b)] = int(r)
    return out


def field(es, i):
    """field i of the run's spec 'code|sets|tempo|state|rerate' ('' when absent)"""
    f = es.split('|')
    return f[i] if len(f) > i else ''


def state_loads(spec, rate, blk, nblk):
    """--state 'SEED@T,...' (JX-17) -> {block: payload bytes}: at the block that starts at or after T seconds the host
    calls IComponent::setState with a seeded payload -- 24 of the state parameters at values across and past their
    ranges, an unknown id, CC map entries (assigned, freed) -- in a seeded order (jx3p/src/jx_state_tables.h)"""
    import random
    import re
    src = open(os.path.join(REPO, 'jx3p', 'src', 'jx_state_tables.h')).read()
    ids = [int(x, 16) for x in re.findall(r'\{ 0x([0-9A-F]{8})u, 0x[0-9A-F]+u, -?\d+ \}', src)]
    out = {}
    for item in filter(None, spec.split(',')):
        sd, _, t = item.partition('@')
        if sd.startswith('r'):               # 'rV@T': the engine-rate setting alone (vm.vs.sampleRate = V, JX-15)
            pl = struct.pack('>Ii', 0x0FFFC015, int(sd[1:]))
            out[-(-int(float(t or 0) * rate) // blk)] = struct.pack('>I', len(pl)) + pl
            continue
        if sd.startswith('s'):               # 'sID=V@T': one entry alone (JX-26c: the voice count 0FFFC00E, the
            k, _, v = sd[1:].partition('=')  # velocity switch 0FFFC00D -- not in the state list: ignored --, ...)
            pl = struct.pack('>Ii', int(k, 16), int(v))
            out[-(-int(float(t or 0) * rate) // blk)] = struct.pack('>I', len(pl)) + pl
            continue
        r = random.Random(7307 * int(sd) + 11)
        ent = [(pid, r.choice((0, 1, 64, 127, 128, 200, 255, 256, 300, -1, r.randrange(256))))
               for pid in r.sample(ids, 24)]
        ent += [(0x7777, 5), (0x10000000 + 3, 0x0060003E), (0x10000000 + 9, -1), (0x10000000 + 116, 0x00600062)]
        r.shuffle(ent)
        pl = b''.join(struct.pack('>Ii', a, v) for a, v in ent)
        out[-(-int(float(t or 0) * rate) // blk)] = struct.pack('>I', len(pl)) + pl
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


def oracle(rate, patch, nblk, blk, on, off, recalls='', edits='-1'):
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
    par = points(nblk, blk, on, off, edits)
    tmp = tempo_blocks(field(edits, 2), rate, blk, nblk)
    sts = state_loads(field(edits, 3), rate, blk, nblk)
    rr = rerates(field(edits, 4))
    for b, ev in enumerate(schedule(nblk, blk, on, off)):
        if b in rr:                           # a host-rate change on the running instance (JX-26c)
            h.set_active(0)
            h.setup_processing(float(rr[b]), blk)
            h.set_active(1)
        if b in sts:                          # the host's setState between two blocks (JX-17)
            if h.set_state(sts[b]) not in (0, 1):
                raise SystemExit('setState refused')
        for p in rmap.get(b, ()):            # the plugin's patch browser, between two blocks (WARM: JX-11)
            if isinstance(p, tuple):          # a user's record (JX-16)
                h.load_patch(rec_bytes(p)[B.BANK_BLOB_OFF:])
                continue
            h.load_patch(bank[B.BANK_HEADER + p * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (p + 1) * B.BANK_STRIDE])
        valid, bpm = tmp[b]                   # the ProcessContext: a valid tempo, or none (JX-8)
        L, R = h.process(blk, events=ev, params=par[b], ctx={'tempo': bpm} if valid else None)
        out.append([list(L), list(R)])
    return out


def guest96(tmp):
    """the 96 kHz engine's guest image: the committed .gz (jx_guest_export.py --rate 96000), inflated into tmp"""
    sys.path.insert(0, HERE)
    import jx_guest
    return jx_guest.path(96, tmp)


def port(so, rate, patch, nblk, blk, on, off, tooth, img96, recalls='', edits='-1'):
    lib = ctypes.CDLL(so)
    lib.jx_enable_hw_ftz()
    lib.jx3p_lift_error.restype = ctypes.c_char_p
    g = lambda p: os.path.join(REPO, 'jx3p', p).encode()
    sys.path.insert(0, HERE)
    import jx_guest
    if tooth:                                 # the old path: the 44.1 kHz engine booted and the patch applied at once
        if not lib.jx3p_init(jx_guest.path(44).encode(), g('truth/preset_bank_1.bin'), None):
            raise SystemExit('jx3p_init failed: %s' % lib.jx3p_lift_error().decode())
        lib.jx3p_recall(patch)
        lib.jx3p_host_stage(1)
    else:                                     # a fresh instance (JX-15b): initialize's records and the patch browser's
        lib.jx3p_product_init.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int]     # load QUEUED, as
        kind = lib.jx3p_product_init(img96.encode(), g('truth/preset_bank_1.bin'), rate)     # the oracle's are
        if kind < 0:
            raise SystemExit('jx3p_product_init(%d) -> %d' % (rate, kind))
        lib.jx3p_product_load_patch(patch)
    if lib.jx3p_lift_error():
        raise SystemExit('the lifted parameter system trapped: %s' % lib.jx3p_lift_error().decode())
    out = []
    rmap = recall_map(recalls, rate, blk)
    par = points(nblk, blk, on, off, edits)
    tmp = tempo_blocks(field(edits, 2), rate, blk, nblk)
    sts = state_loads(field(edits, 3), rate, blk, nblk)
    rr = rerates(field(edits, 4))
    lib.jx3p_product_param.argtypes = [ctypes.c_uint, ctypes.c_int, ctypes.c_double]
    lib.jx3p_product_tempo.argtypes = [ctypes.c_int, ctypes.c_double]
    lib.jx3p_product_note.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float]
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
            if b in rr and os.environ.get('JX_RERATE_TOOTH') != '1':     # TOOTH: setActive dropped (the old object)
                lib.jx3p_set_active(0)
                lib.jx3p_setup_processing(rr[b])
                lib.jx3p_set_active(1)
            if b in sts and os.environ.get('JX_STATE_TOOTH_RUN') != '1':     # TOOTH: the port misses the setState
                d = sts[b]
                lib.jx3p_state_load((ctypes.c_ubyte * len(d)).from_buffer_copy(d), len(d))
            for q in rmap.get(b, ()):         # the patch browser's loads, queued before process() runs, after a
                if isinstance(q, tuple):      # setState of the same gap (as the oracle's); a user's record (JX-16)
                    r = rec_bytes(q if os.environ.get('JX_RECALL_TOOTH') != '1' else ('r', q[1] + 1))
                    if lib.jx3p_product_load_record((ctypes.c_ubyte * len(r)).from_buffer_copy(r), len(r)) < 0:
                        raise SystemExit('jx3p_product_load_record refused')
                    continue
                if os.environ.get('JX_RECALL_TOOTH') == '1':
                    q = (q + 1) % 64                                  # TOOTH: the wrong patch
                lib.jx3p_product_load_patch(q)
            recs, nev = [], 0
            for e in ev:                      # process(): the host's note events, as the oracle gets them
                if lib.jx3p_product_note(0 if e[0] == 'on' else 1, e[1], e[2], e[3], e[4]) != 0:
                    raise SystemExit('jx3p_product_note refused')
            if os.environ.get('JX_EDIT_TOOTH') != '1':         # TOOTH: no host parameter points
                for pid, off, v in queues(par[b]):             # process(): then one record per queue
                    if lib.jx3p_product_param(pid, off, v) != 0:
                        raise SystemExit('jx3p_product_param(0x%x) refused' % pid)
            arr = (ctypes.c_int * max(1, len(recs)))(*recs)
            if os.environ.get('JX_TEMPO_TOOTH') != '1':        # TOOTH: the port never hears the host tempo
                lib.jx3p_product_tempo(*tmp[b])
            lib.jx3p_product_block(Lb, Rb, blk, arr, nev)
        out.append([list(struct.unpack('<%dI' % blk, bytes(Lb))), list(struct.unpack('<%dI' % blk, bytes(Rb)))])
    if lib.jx3p_lift_error():                 # a trap in a mid-run record list: never a silent pass
        raise SystemExit('the lifted parameter system trapped during the run: %s' % lib.jx3p_lift_error().decode())
    return out


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        json.dump(oracle(*[int(x) for x in a[1:7]], recalls=a[7], edits=a[8]), sys.stdout)
        return 0
    if a[:1] == ['--port']:
        json.dump(port(a[1], *[int(x) for x in a[2:8]], a[8] == '1', a[9], a[10], a[11]), sys.stdout)
        return 0
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    rates = [int(x) for x in opt('--rates', '44100,48000,96000').split(',')]
    patches = [y for x in opt('--patches', '0,34').split(',') for y in
               (range(int(x.split('-')[0]), int(x.split('-')[1]) + 1) if '-' in x else [int(x)])]
    blk = int(opt('--block', '512'))
    t_on, t_off, secs = float(opt('--on', '0.6')), float(opt('--off', '1.2')), float(opt('--secs', '1.5'))
    tooth, tclock, tvc, exact = '--tooth' in a, '--tooth-clock' in a, '--tooth-voices' in a, '--exact' in a
    trec = '--tooth-recall' in a
    if trec:
        os.environ['JX_RECALL_TOOTH'] = '1'
    tedit = '--tooth-edits' in a or '--tooth-ctl' in a
    if tedit:
        os.environ['JX_EDIT_TOOTH'] = '1'
    tlaw = '--tooth-law' in a
    only = opt('--ctl-only', '')                 # e.g. 64,123: only these MIDI-mapping numbers of --ctl (bisection)
    eseeds = ['e%d' % int(x) for x in opt('--edits', '').split(',') if x] + \
        ['c%d%s' % (int(x), ':' + only if only else '') for x in opt('--ctl', '').split(',') if x]
    silent = '--expect-silent' in a
    seeds = [int(x) for x in opt('--poly', '').split(',') if x]
    recalls = opt('--recall', '')               # 'P@T,...': warm patch loads (the plugin's patch browser)
    sets = [x for x in opt('--set', '').split(';') if x]     # host parameter points at the start, one run per group
    tempos = [x for x in opt('--tempo', '').split(';') if x]   # the host's tempo per block, one run per group (JX-8)
    states = [x for x in opt('--state', '').split(';') if x]   # setState loads, one run per group (JX-17)
    rrs = [x for x in opt('--rerate', '').split(';') if x]     # host-rate changes, one run per group (JX-26c)
    if '--tooth-rerate' in a:
        os.environ['JX_RERATE_TOOTH'] = '1'
    velplan = '--vel' in a
    if '--tooth-state' in a:
        os.environ['JX_STATE_TOOTH_RUN'] = '1'
    ttempo = '--tooth-tempo' in a
    if ttempo:
        os.environ['JX_TEMPO_TOOTH'] = '1'
    tmp = tempfile.mkdtemp()
    atexit.register(shutil.rmtree, tmp, True)     # its builds and inflated images: never left behind
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
        plans = [(-sd - 1, int(t_on * rate), '-1') for sd in seeds] if seeds else \
            [(VEL_ON, int(t_on * rate), '-1')] if velplan else [(on, off, '-1')]
        if eseeds:                            # host automation / controllers: each seed on the plan's notes
            plans = [(pon, poff, es) for (pon, poff, _) in plans for es in eseeds]
        if sets:                              # host points at the start (or at '@T'): each group on every plan
            plans = [(pon, poff, es + '|' + timed(st, rate)) for (pon, poff, es) in plans for st in sets]
        if tempos:                            # the host tempo: each group on every plan
            plans = [(pon, poff, es + ('' if '|' in es else '|') + '|' + tg) for (pon, poff, es) in plans for tg in tempos]
        if states:                            # setState loads: each group on every plan
            plans = [(pon, poff, '|'.join((es.split('|') + ['', '', ''])[:3]) + '|' + sg)
                     for (pon, poff, es) in plans for sg in states]
        if rrs:                               # host-rate changes: each group on every plan
            plans = [(pon, poff, '|'.join((es.split('|') + ['', '', '', ''])[:4]) + '|' + rg)
                     for (pon, poff, es) in plans for rg in rrs]
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
            what = 'patch %d' % patch + (' velocity plan' if on == VEL_ON else ' poly seed %d' % (-on - 1) if on < 0 else '')
            if on < 0:
                nev = sum(len(e) for e in schedule(nblk, blk, on, off))
                what += ' (%d events)' % nev
            code, st, tg, sg = field(es, 0), field(es, 1), field(es, 2), field(es, 3)
            if code != '-1':
                sched = points(nblk, blk, on, off, code)
                what += ' %s seed %s (%d points, %d records)' % ('edits' if code[0] == 'e' else 'controllers', code[1:],
                                                                   sum(len(x) for x in sched),
                                                                   sum(len(queues(x)) for x in sched))
            if st:
                what += ' set %s' % st
            if tg:
                what += ' tempo %s' % tg
            if sg:
                what += ' setState %s' % sg
            if field(es, 4):
                what += ' host rate changes %s' % field(es, 4)
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
    n = len(rates) * len(patches) * max(1, len(seeds)) * max(1, len(eseeds)) * max(1, len(sets)) * max(1, len(tempos)) \
        * max(1, len(states)) * max(1, len(rrs))
    if '--tooth-rerate' in a:
        print('jx_product_gate --tooth-rerate: %s' % ('BITES (%d of %d differ)' % (bad, n) if bad == n else
                                                        'DID NOT BITE on %d of %d' % (n - bad, n)))
        return 0 if bad == n else 1
    if '--tooth-state' in a:
        print('jx_product_gate --tooth-state: %s' % ('BITES (%d of %d differ)' % (bad, n) if bad == n else
                                                       'DID NOT BITE on %d of %d' % (n - bad, n)))
        return 0 if bad == n else 1
    if ttempo:
        print('jx_product_gate --tooth-tempo: %s' % ('BITES (%d of %d differ)' % (bad, n) if bad == n else
                                                       'DID NOT BITE on %d of %d' % (n - bad, n)))
        return 0 if bad == n else 1
    if tooth or tclock or tvc or trec or tedit or tlaw:
        print('jx_product_gate %s: %s' % ('--tooth' if tooth else '--tooth-clock' if tclock else '--tooth-voices'
                                          if tvc else '--tooth-recall' if trec else ('--tooth-ctl' if '--tooth-ctl' in a
                                          else '--tooth-edits') if tedit else '--tooth-law',
                                          'BITES (%d of %d differ)' % (bad, n) if bad == n else
                                          'DID NOT BITE on %d of %d' % (n - bad, n)))
        return 0 if bad == n else 1
    print('jx_product_gate: %d of %d (host rate, patch) runs equal to the plugin\'s process(): %s' % (
        n - bad, n, 'GREEN' if not bad else 'RED'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
