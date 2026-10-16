#!/usr/bin/env python3
"""jn_surf_seq.py -- the ONE shared plan of the L5 SURFACES gate (docs/JUNO_LIFT.md): every product surface of the
JUNO host that the init / process / bank / state / editor gates do not drive -- the voice-count setting, the engine-rate
setting, host-rate changes (the rate converter AND the 96 kHz identity render object), the UI timer, MIDI learn /
forget, the panel's commit, a DAW state round trip -- as ops. The oracle (jn_surf_ref.py) and the lifted host
(jn_surf_c.py) both replay this list; after EVERY op each side records a digest of its end-state memory (image + heap
+ host arena), the heap and arena tops, and any output words, so the first divergence names its op.
Each op is a tuple:
  ('proc', n, events, params)   one block through process() with the playing context (T); events (kind, off, ch,
                                pitch, vel); params (id, offset, value)
  ('rate', hz)                  a host-rate change: setActive(0), setupProcessing(hz), setActive(1)
  ('uitick',)                   the plugin's UI timer (rva 0x320120)
  ('learn', i) / ('forget', i)  the CC menu's Learn / Forget on record i's parameter id (looked up as junoh does)
  ('commit',)                   the panel's commit (rva 0x285320, 0x2853C0, 0x283120)
  ('getset',)                   getState, then setState of those bytes
"""
SAMPLERATE, VOICES = 0x0FFFC015, 0x0FFFC00E
T = dict(state=0x402, ppq=0.0, cs=0.0, ce=0.0, tempo=120.0)       # playing + tempo


def on(p, v=0.8):
    return ('on', 0, 0, p, v)


def off(p):
    return ('off', 0, 0, p, 0.0)


def plan(rates=True):
    ops = [('proc', 512, [], []), ('proc', 512, [], [])]           # past the 960-sample start mute
    # the voice-count setting (vm.vs.voiceCount) while a chord sounds
    ops += [('proc', 256, [on(60), on(64)], [(VOICES, 0, 6)]), ('proc', 256, [], [(VOICES, 0, 1)]),
            ('proc', 256, [], []), ('proc', 256, [on(67)], [(VOICES, 0, 6)]), ('proc', 256, [off(60), off(64), off(67)], [])]
    # the engine-rate setting (vm.vs.sampleRate): the engine is rebuilt at the next block
    for v in (2, 3, 0, 5):
        ops += [('proc', 256, [], [(SAMPLERATE, 0, v)]), ('proc', 256, [on(62)], []), ('proc', 256, [off(62)], [])]
    ops += [('uitick',)]
    for i in (0, 1, 2, 3):
        ops += [('learn', i), ('forget', i)]
    ops += [('commit',), ('proc', 256, [on(65)], []), ('getset',), ('proc', 256, [off(65)], []), ('uitick',)]
    if rates:                                                      # last: the 96 kHz identity path needs its census
        for hz in (44100.0, 96000.0, 48000.0):
            ops += [('rate', hz), ('proc', 256, [on(60)], []), ('proc', 256, [off(60)], [])]
    return ops


def oracle_ctx():
    return dict(state=T['state'], ppq=T['ppq'], cycle=(T['cs'], T['ce']), tempo=T['tempo'])
