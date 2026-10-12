#!/usr/bin/env python3
"""jp8_host_seq.py -- the SHARED drive of the JUPITER-8 host gate and its reach (all three processes import it; no
unicorn, no ctypes). One instance, booted as a DAW boots it up to the point it learns its sample rate (the host
oracle's boot_host: the template is taken there), then STEPS, each side making the same host calls:
  ('setup', rate)         the host's first setupProcessing(rate, MAXBLOCK) + setActive(1) (the oracle's setup());
                          MAXBLOCK is 512, or JP8_HOST_MAXBLOCK (above 512 the drive adds blocks of that size)
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
  ('info', what, *args)   what a DAW asks the controller when it loads the plugin (v6): 'count' (getParameterCount,
                          slot 8), 'param' i (getParameterInfo, slot 9: the 792 bytes it writes), 'midi' bus ch cc
                          (IMidiMapping::getMidiControllerAssignment), 'units' / 'unit' i / 'lists' / 'selected' /
                          'select' id (IUnitInfo: getUnitCount, getUnitInfo (268 bytes), getProgramListCount,
                          getSelectedUnit, selectUnit), 'cgetstate' key / 'csetstate' key (IEditController::getState /
                          setState: the controller's own state, kept under key) -- the IMidiMapping and IUnitInfo
                          pointers are queried once, after setup (queryInterface, slot 0)
  ('compstate', key, how) IEditController::setComponentState of the bytes kept under key, through state_variant(how):
                          a DAW hands the controller the component's state after IComponent::setState (v6)
The host's own buffers (the patch record, the strings, the infos, the stream, a new rate's setup) are one scratch area
and one stream object made after setup and reused, cleared before each use, on both sides: the host-object area does
not grow after setup (v6; before, every call took new bytes and a long session would have filled it).
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
silence), the voice count (0x0FFFC00E) at 4 and 1 (v7: and 2, 3, 5, 6, 7, 8) -- each followed by a note and the state the
plugin then writes (v7 also plays keys on MIDI channels 5 and 15 and a note-on of velocity 0). Then (v7,
JP8_HOST_SWEEP=1, the default; 0 leaves it out -- the gate's per-rate reach) THE SWEEP (sweep_steps): every panel parameter at every position
the plugin's own display strings give (jp8_param_positions.py -> jp8/gen/jp8_param_positions.json), the effect units'
types with their parameters, the arpeggiator's modes x ranges free and synced, the assign modes with legato and
portamento, KEY HOLD, host blocks of 1 .. 512 samples, the effects' long tail. Every output word, every state byte, every host call's answer, the edits the plugin hands its
component handler and the memory after are graded."""
import os
import json
import struct
HERE = os.path.dirname(os.path.abspath(__file__))
RATE = float(os.environ.get("JP8_HOST_RATE", "48000"))
MAXBLOCK = int(os.environ.get('JP8_HOST_MAXBLOCK', '512'))   # the host's maximum block (setupProcessing); above 512 the drive adds full blocks
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
# every panel parameter's POSITIONS (jp8_param_positions.py: the plugin's own display strings at k / 256)
_POS = json.load(open(os.path.join(HERE, '..', 'gen', 'jp8_param_positions.json')))
POSITIONS = {p['id']: p['positions'] for p in _POS['params']}
BYNAME = {p['title']: p['id'] for p in _CTL['params'] if p['id'] < MIDI_BASE}
SWEEP = os.environ.get('JP8_HOST_SWEEP', '1') == '1'  # v7: the sweep of every panel parameter at the drive's end (0: without)
SWEEP_PATCH = 2


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
        (512, [("on", 0, 5, 60, 0.8), ("on", 100, 0, 64, 0.0)], [], None),  # v7: another MIDI channel, velocity 0
        (512, [("off", 0, 5, 60, 0.0), ("off", 50, 0, 64, 0.0), ("on", 300, 15, 67, 0.5)], [], None),
        (512, [("off", 0, 15, 67, 0.5)], [], None),
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
            'rate1', 'rate2', 'rate3', 'rate4', 'rate5', 'rate6', 'voices4', 'voices1',
            'voices2', 'voices3', 'voices5', 'voices6', 'voices7', 'voices8', 'as is']


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


NPARAM = _CTL['count']                               # getParameterCount (the census; an index past it makes the plugin throw)


def info_steps():
    """what a DAW asks the edit controller when it loads the plugin: the parameter count and every parameter's info,
    the MIDI mapping of every controller number (bus 0 on channels 0 and 15; channel 16, numbers 130 and 131, bus 1),
    the units, the program lists, the selected unit (and one selected), the controller's own state"""
    out = [('info', 'count')] + [('info', 'param', i) for i in range(NPARAM)]
    out += [('info', 'midi', 0, 0, k) for k in range(132)] + [('info', 'midi', 0, 15, k) for k in range(0, 132, 3)]
    out += [('info', 'midi', 0, 16, 1), ('info', 'midi', 1, 0, 1), ('info', 'midi', 0, 0, 255)]
    out += [('info', 'units'), ('info', 'unit', 0), ('info', 'unit', 1), ('info', 'lists'), ('info', 'selected'),
            ('info', 'select', 2), ('info', 'selected'), ('info', 'select', 0), ('info', 'cgetstate', 'c0')]
    return out


def values(pid, cont=(0.0, 0.25, 0.5, 0.75, 1.0)):
    """the values the sweep plays: a switch (16 positions or fewer) at the middle of each position, a continuous
    parameter at cont"""
    pos = POSITIONS[pid]
    if len(pos) > 16:
        return list(cont)
    return [(lo + hi) / 2.0 / _POS['grid'] for lo, hi, _ in pos]


FX = {'EFFECT TYPE': ('EFFECT CTRL', 'CHORUS PRE DELAY', 'CHORUS LOW CUT', 'CHORUS HIGH CUT', 'FLANGER MANUAL',
                      'FLANGER RESONANCE', 'FLANGER LOW CUT'),
      'DELAY TYPE': ('DELAY TIME', 'DELAY TAP TIME', 'DELAY FEEDBACK', 'DELAY HIGH CUT', 'DELAY HF DAMP',
                     'DELAY HF DAMP FREQ', 'DELAY LF DAMP', 'DELAY LF DAMP FREQ', 'DELAY DIRECT LEVEL'),
      'REVERB TYPE': ('REVERB TIME', 'REVERB PRE DELAY', 'REVERB LOW CUT', 'REVERB HIGH CUT', 'REVERB DENSITY',
                      'REVERB DIRECT LEVEL')}
ARP = ('ARPEGGIO SW', 'ARPEGGIO MODE', 'ARPEGGIO RANGE', 'TEMPO SYNC')
ASSIGN = ('ASSIGN MODE', 'LEGATO', 'PORTAMENTO', 'PORTA TYPE')
SWEEP_CHORD = ((48, 0.35), (55, 0.6), (60, 0.85), (64, 1.0))


def sweep_steps():
    """v7: EVERY panel parameter of the controller census at every position of a switch and five values of a continuous
    one (jp8_param_positions.json), through process() as host automation, a chord sounding, the pitch bend and the mod
    wheel moving in every block -- each parameter from a fresh load of SWEEP_PATCH; then the effects: each type of
    each of the three units (EFFECT, DELAY, REVERB; the levels up) with that unit's parameters at every position /
    three values under it; the arpeggiator: every mode x range, free and synced to a running host clock; the assign
    modes x LEGATO x PORTA TYPE with overlapping keys and portamento; KEY HOLD across a release; host blocks of 17
    sizes from 1 to 512 samples; the delay's and the reverb's long tail (400 blocks)"""
    out = []
    on = [("on", i, 0, k, v) for i, (k, v) in enumerate(SWEEP_CHORD)]
    off = [("off", 400 + i, 0, k, 0.5) for i, (k, _) in enumerate(SWEEP_CHORD)]
    mods = [(BEND, 128, 0.3), (BEND, 384, 0.7), (BEND, 500, 0.5), (MIDI_BASE + 1, 0, 0.5), (MIDI_BASE + 1, 500, 0.0)]
    special = set(FX) | {n for v in FX.values() for n in v} | set(ARP) | set(ASSIGN) | {'KEY HOLD'}
    for pid in PANEL:
        if any(BYNAME.get(n) == pid for n in special):
            continue
        out.append(('patch', SWEEP_PATCH))
        vs = values(pid)
        for j, v in enumerate(vs):
            ev = (on if j == 0 else []) + (off if j == len(vs) - 1 else [])
            out.append(('block', 512, ev, [(pid, 0, v)] + mods, None))
    levels = [(BYNAME[n], 0, 1.0) for n in ('EFFECT LEVEL', 'REVERB LEVEL', 'DELAY LEVEL')]
    for unit, prm in FX.items():
        tid = BYNAME[unit]
        out.append(('patch', SWEEP_PATCH))
        for j, t in enumerate(values(tid)):
            ev = [("off", 0, 0, k, 0.5) for k, _ in SWEEP_CHORD] + [("on", 256 + i, 0, k, v) for i, (k, v) in enumerate(SWEEP_CHORD)]
            out.append(('block', 512, ev, [(tid, 0, t)] + (levels if j == 0 else []), None))
            for n in prm:
                for v in values(BYNAME[n], cont=(0.0, 0.5, 1.0)):
                    out.append(('block', 512, [], [(BYNAME[n], 0, v)], None))
        out += [('block', 512, [("off", 0, 0, k, 0.5) for k, _ in SWEEP_CHORD], [], None), ('block', 512, [], [], None)]
    sw, mode, rng, sync = (BYNAME[n] for n in ARP)
    out += [('patch', SWEEP_PATCH), ('block', 512, on, [(sw, 0, 1.0), (BYNAME['LFO RATE'], 0, 1.0)], None)]
    ppq = 0.0
    for sy in values(sync):
        for m in values(mode):
            for r in values(rng):
                for k in range(2):
                    out.append(('block', 512, [], [(sync, 0, sy), (mode, 0, m), (rng, 0, r)] if k == 0 else [],
                                dict(TEMPO, ppq=ppq)))
                    ppq += 512 / RATE * TEMPO['tempo'] / 60.0
    out += [('block', 512, [], [(sw, 0, 0.0)], None), ('block', 512, off, [], None)]
    am, leg, porta, pt = (BYNAME[n] for n in ASSIGN)
    out.append(('patch', SWEEP_PATCH))
    for a in values(am):
        for lg in values(leg):
            for t in values(pt):
                out.append(('block', 512, [("on", 0, 0, 48, 0.8), ("on", 200, 0, 52, 0.7), ("off", 300, 0, 48, 0.5),
                                           ("on", 400, 0, 55, 0.9)], [(am, 0, a), (leg, 0, lg), (pt, 0, t), (porta, 0, 0.6)], None))
                out.append(('block', 512, [("off", 0, 0, 52, 0.5), ("on", 100, 0, 60, 0.6), ("off", 300, 0, 55, 0.5),
                                           ("off", 450, 0, 60, 0.5)], [], None))
    hold = BYNAME['KEY HOLD']
    out += [('patch', SWEEP_PATCH), ('block', 512, on, [(hold, 0, 1.0)], None), ('block', 512, off, [], None),
            ('block', 512, [("on", 0, 0, 72, 0.8)], [], None), ('block', 512, [], [(hold, 100, 0.0)], None),
            ('block', 512, [("off", 0, 0, 72, 0.5)], [], None)]
    # host block sizes: a key struck and released inside blocks of every size class up to the maximum, a parameter
    # point at the block's last sample
    cut = BYNAME['VCF CUTOFF']
    out.append(('patch', SWEEP_PATCH))
    for j, n in enumerate((1, 2, 3, 7, 16, 17, 31, 64, 100, 127, 255, 256, 257, 300, 333, 511, 512)):
        ev = [("on", n // 3, 0, 60 + j % 12, 0.8), ("off", n - 1, 0, 60 + (j + 11) % 12, 0.5)]
        out.append(('block', n, ev, [(cut, n - 1, (j + 1) / 18.0)], None))
    # the effects' long tail: delay at its longest with feedback, reverb at its longest, one chord, then 400 blocks
    # (4.3 s at 48000: the 300,000-sample rings of the 96 kHz engine, 3.1 s, wrap)
    tail = [(BYNAME[n], 0, v) for n, v in (('DELAY LEVEL', 1.0), ('DELAY TIME', 1.0), ('DELAY FEEDBACK', 0.8),
                                           ('REVERB LEVEL', 1.0), ('REVERB TIME', 1.0), ('EFFECT LEVEL', 1.0))]
    out += [('patch', SWEEP_PATCH), ('block', 512, on + off, tail, None)]
    out += [('block', 512, [], [], None)] * 400
    out.append(('getstate', 'sweep'))
    return out


K_PLAYING, K_CYCLE_ACTIVE, K_PPQ, K_TEMPO, K_CYCLE = 0x2, 0x4, 0x200, 0x400, 0x1000   # VST3 ProcessContext flags


def transport():
    """v8: THE HOST TRANSPORT under a synced arpeggio (scope row 3: the states v7 left out) -- a running clock at three
    tempos, the transport stopped (the position frozen), a restart from 0, a loop (kCycleActive: the position jumps
    back at the cycle's end), a locate backwards, a block with no ProcessContext and one whose context has no tempo"""
    sw, mode, rng, sync = (BYNAME[n] for n in ARP)
    keys = (48, 55, 60, 64)
    out = []
    pos = [0.0]

    def run(n, tempo=120.0, playing=True, cyc=None, pars=(), ev=()):
        for j in range(n):
            c = dict(tempo=tempo, playing=playing, ppq=pos[0])
            if cyc:
                c = dict(state=K_PLAYING | K_TEMPO | K_PPQ | K_CYCLE | K_CYCLE_ACTIVE, tempo=tempo, ppq=pos[0], cycle=cyc)
            out.append((512, list(ev) if j == 0 else [], list(pars) if j == 0 else [], c))
            if playing:
                pos[0] += 512 / RATE * tempo / 60.0
                if cyc and pos[0] >= cyc[1]:
                    pos[0] -= cyc[1] - cyc[0]
    run(1, pars=[(sw, 0, 1.0), (sync, 0, 1.0), (mode, 0, 0.5), (rng, 0, 0.5)],
        ev=[("on", 10 * i, 0, k, 0.7) for i, k in enumerate(keys)])      # the arpeggio on, synced, a chord held
    run(3)                                                              # a running clock at 120
    run(2, tempo=90.0)                                                  # tempo changes
    run(2, tempo=172.5)
    run(3, tempo=172.5, playing=False)                                  # stopped: the position frozen
    pos[0] = 0.0
    run(2)                                                              # a restart from 0
    pos[0] = 0.05
    run(6, cyc=(0.0, 0.0625))                                           # a loop of 1/16 beat: the position jumps back
    pos[0] = 0.25
    run(1)                                                              # a locate backwards (no cycle)
    out.append((512, [], [], None))                                     # no ProcessContext
    out.append((512, [], [], dict(state=K_PLAYING | K_PPQ, ppq=pos[0]))) # a context without a tempo
    out.append((512, [("off", 0, 0, k, 0.5) for k in keys], [(sw, 0, 0.0)], dict(TEMPO, ppq=pos[0])))
    return out


MAIN_PANEL = (3940, 2004)        # the main panel's window (truth/Script.xml: its size)


def editor_steps():
    """v8 (E1): THE EDITOR OPENED -- on a machine with no screen first (GetSystemMetrics 0: the fit is negative, so the
    window computes it again at its next conversion), then the main window's zoom getter on screens that change under
    it: the first positive fit is kept for the window's life (the JUNO's rule 4), the zoom value clamped to it (rule
    1) -- and the state after, which holds the zoom"""
    w, h = MAIN_PANEL
    return [('screen', 0, 0), ('editor',), ('zoomconv', w, h), ('getstate', 'editor0'),
            ('screen', 1024, 768), ('zoomconv', w, h), ('getstate', 'editor1'),
            ('screen', 3840, 2160), ('zoomconv', w, h), ('screen', 640, 480), ('zoomconv', w, h),
            ('block', 512, [("on", 0, 0, 60, 0.8)], [], None), ('block', 512, [("off", 0, 0, 60, 0.0)], [], None),
            ('getstate', 'editor2')]


def steps(patches=None):
    """the whole drive, in order (the reach runs the same steps over its patch list)"""
    patches = PATCHES if patches is None else patches
    out = [('setup', RATE)] + info_steps()
    for p in patches:
        out.append(('patch', p))
        out += [('block',) + b for b in blocks(p)]
        out.append(('getstate', 'p%d' % p))
    out += [('block',) + b for b in controllers()]
    out += [('block',) + b for b in transport()]
    if MAXBLOCK > 512:                       # blocks of the host's maximum and one below: the render driver splits them
        cut = PANEL[(len(PANEL) // 3)]
        out += [('block', MAXBLOCK, [("on", i * 7, 0, k, 0.7) for i, k in enumerate(CHORD[:6])], [(cut, MAXBLOCK // 3, 0.4)], dict(TEMPO)),
                ('block', MAXBLOCK - 1, [], [(cut, 0, 0.6), (cut, MAXBLOCK - 2, 0.2)], dict(TEMPO, ppq=1.0)),
                ('block', MAXBLOCK, [("off", MAXBLOCK - 1 - i, 0, k, 0.5) for i, k in enumerate(CHORD[:6])], [], None),
                ('block', MAXBLOCK, [], [], None)]
    for r in RATES:
        out += [('block', 512, [("on", 100, 0, 64, 0.7)], [], None), ('rate', r),
                ('block', 512, [], [], None), ('block', 512, [("off", 0, 0, 64, 0.0)], [], None)]
    out += [('active', 0), ('active', 1), ('block', 512, [("on", 0, 0, 55, 0.9)], [], None),
            ('block', 512, [("off", 0, 0, 55, 0.0)], [], None)]
    out += learn_steps()
    out += ctl_steps() + [('block', 512, [("on", 0, 0, 60, 0.8)], [], None), ('getstate', 'after_ctl'),
                          ('block', 512, [("off", 0, 0, 60, 0.0)], [], None)]
    for how in VARIANTS:
        out += [('setstate', 'p%d' % patches[0], how), ('compstate', 'p%d' % patches[0], how),
                ('ctl', 'get', PANEL[2], 0.0), ('ctl', 'get', MASTER_TUNE, 0.0),
                ('block', 512, [("on", 0, 0, 62, 0.8)], [], None),
                ('block', 512, [("off", 0, 0, 62, 0.0)], [], None), ('getstate', 'after_' + how)]
    # a DAW's project load: the component's state, the controller's view of it, the controller's own state
    out += [('setstate', 'learned', 'as is'), ('compstate', 'learned', 'as is'), ('info', 'csetstate', 'c0'),
            ('ctl', 'get', PANEL[5], 0.0), ('block', 512, [("on", 0, 0, 60, 0.8)], [(MIDI_BASE + 3, 0, 0.4)], None),
            ('drain',), ('getstate', 'project'), ('info', 'cgetstate', 'c1')]
    out += editor_steps()
    if SWEEP:
        out += sweep_steps()
    return out
