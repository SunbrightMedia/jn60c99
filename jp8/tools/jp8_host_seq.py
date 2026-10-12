#!/usr/bin/env python3
"""jp8_host_seq.py -- the SHARED drive of the JUPITER-8 host gate and its reach (all three processes import it; no
unicorn, no ctypes). One instance, booted as a DAW boots it up to the point it learns its sample rate (the host
oracle's boot_host: the template is taken there), then STEPS, each side making the same host calls:
  ('setup', rate)         the host's first setupProcessing(rate, MAXBLOCK) + setActive(1) (the oracle's setup())
  ('patch', p)            the plugin's own patch load (a factory record's bytes after its name)
  ('block', n, ev, par, ctx)  one process() block: note events, parameter queue points, the process context
  ('getstate', key)       IComponent::getState -- the bytes are graded; kept under key on each side
  ('setstate', key, how)  IComponent::setState of the bytes kept under key, passed through state_variant(how) (each
                          side its own bytes, graded equal; the variants are byte edits, the same on both sides)
  ('rate', rate)          a host-rate change on the running instance: setActive(0), setupProcessing, setActive(1)
  ('active', on)          setActive(on) alone
  ('ctl', op, id, arg)    the edit controller's own call (op: get, set, str, plain, norm, parse -- IEditController
                          slots 14, 15, 10, 12, 13, 11); its answer, its double and the bytes it wrote are graded
  ('drain',)              the UI timer's handler (the core's vtable slot 1, rva 0x33A290): the parameter store from
                          the mapped CCs, a MIDI learn completed
  ('learn', id)           MIDI learn armed for the record of id (rva 0x326660 on core + 24, as the GUI's CC menu
                          does; an id without a record arms index 0xFFFFFFFF); ('forget', id) its other choice
                          (rva 0x324F00) -- the record index from the plugin's own lookup (rva 0x325870), read once
                          after setup by both sides
Per patch: idle, a note, a chord of ten keys on the eight voices (stealing), their release, host automation of two
of the plugin's own parameters (jp8/gen/jp8_controller.json, the controller's census) and of MASTER TUNE and an id
the plugin does not have, block sizes 480 and 32, idle again, the state. Then the MIDI controllers through process()
(the controller's IMidiMapping ids: CC n -> 0x0FFFC100 + n, aftertouch 0x0FFFC180, bend 0x0FFFC181): the mod wheel,
expression, sustain held across a key's release, aftertouch, bend down / up / back, all notes off under held keys,
a panel parameter swept; the host rates of the JUNO-60's host_rate_gate (44100, 96000 = the engine's own rate,
88200, 22050 = no converter: silence, back to the first) with a key held across each change; a setActive off / on;
then MIDI learn: a panel parameter learned from CC 3, the UI timer's drain, the CC moved, forgotten, a learn of an
id with no record; then the states: the first patch's as written, a CC assigned to a panel parameter, a CC assigned to an id the plugin
does not have, every parameter at the int32 maximum, every parameter at -5, a state cut after 20 entries, a count
of 0, an empty stream, the engine-rate setting (0x0FFFC015, the DAW state's) at 1..5 and 6 (no converter:
silence), the voice count (0x0FFFC00E) at 4 and 1 -- each followed by a note and the state the plugin then writes. Every output word, every
state byte, every host call's answer, the edits the plugin hands its component handler and the memory after are
graded."""
import os
import json
import struct
HERE = os.path.dirname(os.path.abspath(__file__))
RATE = float(os.environ.get("JP8_HOST_RATE", "48000"))
MAXBLOCK = 512
PATCHES = [int(x) for x in os.environ.get("JP8_HOST_PATCHES", "2,63,0,12").split(",")]
RATES = [44100.0, 96000.0, 88200.0, 22050.0, RATE]   # the host-rate changes after the patches
NPQ = 8                     # parameter queues the C side creates after setup (jp8_host.c NPQ)
IMG_BASE = 0x180000000; HEAP_BASE = 0x310000000; STACK_BASE = 0x200000000; STACK_SIZE = 0x2000000
COM_BASE = 0x5A0000000; COM_SIZE = 0x400000
CHORD = list(range(48, 68, 2))
TEMPO = dict(tempo=120.0, playing=True, ppq=0.0)     # a host clock for the blocks that carry one
MIDI_BASE = 0x0FFFC100                               # IMidiMapping: CC n -> MIDI_BASE + n (jp8_controller_census.py)
AFTERTOUCH, BEND = MIDI_BASE + 128, MIDI_BASE + 129
NO_SUCH_ID = 0x12345                                 # not a parameter of the plugin
RATE_SETTING, VOICE_COUNT = 0x0FFFC015, 0x0FFFC00E   # the DAW state's engine-rate setting and voice count
_CTL = json.load(open(os.path.join(HERE, '..', 'gen', 'jp8_controller.json')))
PANEL = [p['id'] for p in _CTL['params'] if p['id'] < MIDI_BASE]   # the plugin's own parameters, in its order
MASTER_TUNE = 0x2


def blocks(p):
    """(n, events, params, ctx) per block for patch p; events (kind, offset, channel, pitch, velocity), params (id,
    offset, value), ctx None or the process context (tempo, playing, ppq)"""
    a, b = PANEL[p % len(PANEL)], PANEL[(p * 7 + 3) % len(PANEL)]
    return [
        (512, [], [], None),
        (512, [("on", 0, 0, 60, 0.8)], [], None),
        (512, [("on", 3 * i, 0, k, 0.3 + 0.06 * i) for i, k in enumerate(CHORD)], [], dict(TEMPO)),
        (512, [("off", 5 * i, 0, k, 0.5) for i, k in enumerate([60] + CHORD)], [], dict(TEMPO, ppq=1.0)),
        (512, [], [(a, 7, 0.25), (b, 300, 0.75), (MASTER_TUNE, 100, 0.55), (NO_SUCH_ID, 200, 0.5)], None),
        (480, [], [], None),
        (32, [("on", 31, 0, 72, 1.0)], [], None),
        (512, [("off", 0, 0, 72, 0.0)], [], None),
    ]


def controllers():
    """MIDI controllers through process(), a key or a chord sounding"""
    on = lambda *ks: [("on", 0, 0, k, 0.8) for k in ks]
    off = lambda *ks: [("off", 0, 0, k, 0.0) for k in ks]
    cc = lambda n: MIDI_BASE + n
    return [
        (512, on(60), [(cc(1), 0, 0.0), (cc(1), 256, 1.0)], None),          # mod wheel up
        (512, [], [(cc(1), 0, 0.0), (cc(11), 64, 0.3)], None),              # back; expression
        (512, [], [(cc(11), 0, 1.0), (cc(64), 100, 1.0)], None),            # sustain pedal down
        (512, off(60), [], None),                                           # the key released under the pedal
        (512, on(64), [(AFTERTOUCH, 0, 0.7)], None),
        (512, [], [(cc(64), 0, 0.0), (AFTERTOUCH, 10, 0.0)], None),         # the pedal up: the held note ends
        (512, [], [(BEND, 0, 0.0), (BEND, 300, 1.0)], None),                # bend down, then up
        (512, off(64), [(BEND, 0, 0.5)], None),
        (512, on(48, 52, 55), [(PANEL[2], 0, 0.0), (PANEL[2], 128, 0.33), (PANEL[2], 384, 1.0)], None),
        (512, [], [(cc(123), 200, 0.0)], None),                             # all notes off under three held keys
        (512, off(48, 52, 55), [(cc(7), 0, 0.5)], None),
    ]


def state_variant(s, how):
    """the bytes a host hands setState: a state the plugin wrote (s), edited (byte edits only -- plumbing)"""
    if how == 'as is': return s
    if how == 'empty': return b''
    if how == 'count0': return struct.pack('>I', 0)
    n = struct.unpack('>I', s[:4])[0]
    e = [list(struct.unpack('>Ii', s[4 + i:12 + i])) for i in range(0, min(n, len(s) - 4), 8)]
    pack = lambda ee: struct.pack('>I', 8 * len(ee)) + b''.join(struct.pack('>Ii', a, b & 0xFFFFFFFF if b >= 0 else b) for a, b in ee)
    if how == 'short20': return s[:4 + 8 * 20]
    if how in ('cc_assign', 'cc_invalid'):
        k = next(i for i, (a, b) in enumerate(e) if a == 0x10000000 + 1)        # the CC map's entry for CC 1
        e[k][1] = PANEL[2] if how == 'cc_assign' else 4
        return pack(e)
    if how.startswith('rate') or how.startswith('voices'):
        pid, v = (RATE_SETTING, int(how[4:])) if how.startswith('rate') else (VOICE_COUNT, int(how[6:]))
        return pack([[a, (v if a == pid else b)] for a, b in e])
    if how in ('values_max', 'values_neg'):
        v = 0x7FFFFFFF if how == 'values_max' else -5
        return pack([[a, (b if a >= 0x10000000 else v)] for a, b in e])
    raise ValueError(how)


VARIANTS = ['cc_assign', 'cc_invalid', 'values_max', 'values_neg', 'short20', 'count0', 'empty',
            'rate1', 'rate2', 'rate3', 'rate4', 'rate5', 'rate6', 'voices4', 'voices1', 'as is']


def ctl_steps():
    """the edit controller as a DAW asks it: a parameter's value, its display string, plain <-> normalized, a string
    parsed back, a value set -- on panel parameters, MASTER TUNE, a MIDI-mapped id and an id the plugin does not have,
    at values inside and outside [0, 1]"""
    out = []
    for pid in (PANEL[0], PANEL[2], PANEL[10], PANEL[-1], MASTER_TUNE, MIDI_BASE + 1, NO_SUCH_ID):
        out += [('ctl', 'get', pid, 0.0), ('ctl', 'str', pid, 0.5), ('ctl', 'plain', pid, 0.25), ('ctl', 'norm', pid, 3.0)]
        for v in (0.0, 0.75, 1.0, 1.5, -0.1):
            out += [('ctl', 'set', pid, v), ('ctl', 'get', pid, 0.0), ('ctl', 'str', pid, v)]
        out += [('ctl', 'parse', pid, '64'), ('ctl', 'parse', pid, 'xyz')]
    return out


def learn_steps():
    """MIDI learn as the GUI's CC menu makes it, the UI timer draining between"""
    cc = lambda n: MIDI_BASE + n
    blk = lambda pts, ev=(): ('block', 512, list(ev), pts, None)
    p = PANEL[5]
    return [('drain',), ('learn', p), blk([(cc(3), 0, 0.6)]), blk([(cc(20), 0, 0.5)]), ('drain',),
            blk([(cc(3), 0, 0.2)], [("on", 0, 0, 60, 0.8)]), ('drain',), ('getstate', 'learned'),
            ('forget', p), blk([(cc(3), 0, 0.9)], [("off", 0, 0, 60, 0.0)]), ('drain',),
            ('learn', 0x7FFF0000), blk([(cc(7), 0, 0.5)]), ('drain',), ('getstate', 'forgotten')]


def steps(patches=None):
    """the whole drive, in order (the reach runs the same steps over its patch list)"""
    patches = PATCHES if patches is None else patches
    out = [('setup', RATE)]
    for p in patches:
        out.append(('patch', p))
        out += [('block',) + b for b in blocks(p)]
        out.append(('getstate', 'p%d' % p))
    out += [('block',) + b for b in controllers()]
    for r in RATES:
        out += [('block', 512, [("on", 100, 0, 64, 0.7)], [], None), ('rate', r),
                ('block', 512, [], [], None), ('block', 512, [("off", 0, 0, 64, 0.0)], [], None)]
    out += [('active', 0), ('active', 1), ('block', 512, [("on", 0, 0, 55, 0.9)], [], None),
            ('block', 512, [("off", 0, 0, 55, 0.0)], [], None)]
    out += learn_steps()
    out += ctl_steps() + [('block', 512, [("on", 0, 0, 60, 0.8)], [], None), ('getstate', 'after_ctl'),
                          ('block', 512, [("off", 0, 0, 60, 0.0)], [], None)]
    for how in VARIANTS:
        out += [('setstate', 'p%d' % patches[0], how), ('block', 512, [("on", 0, 0, 62, 0.8)], [], None),
                ('block', 512, [("off", 0, 0, 62, 0.0)], [], None), ('getstate', 'after_' + how)]
    return out
