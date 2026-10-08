#!/usr/bin/env python3
"""wrapper_velocity_gate.py -- the wrapper's MIDI note intake and its velocity
switch, plugin vs port, byte for byte (CLAIMS A23).

The plugin's VST3 wrapper turns each host note event into a 3-byte MIDI
message and pushes it (rva 0x31F4E0) into the queue the render driver hands
the engine; on the way it applies its velocity switch, the byte core+572,
which initialize's core setup (rva 0x320420) takes from vm.vs.velSense
(Script.xml default 1). --ref boots the plugin as a host does
(probes/b6/wrapper_emu.py) and pushes notes through the plugin's own push in
two states: right after the boot, and after a setState whose every value
changed (the vm.vs entries flipped, the out-of-list id of velSense set to 0).
Each queued record's MIDI bytes are recorded. --port: juno_gui_create +
juno_gui_plugin_init (+ juno_gui_state_load of the same payload), then
juno_gui_wrapper_midi on the same messages; every byte must agree.

MESSAGES: note-on and note-off on channels 1 and 10, velocities 0, 1, 37, 64,
99, 100, 101, 126, 127.
LIMITS, stated: the plugin's own UI switch (vm.vs.velSense changed in its
editor) reaches the flag through the model listener (rva 0x321B30, READ:
flag = value != 0); no host call changes it, so it is not executed here.
Controller messages (CC, bend) take another path in the push and are not
graded.

TOOTH (--tooth): plugin_init leaving the switch off (the old port), the
switch inverted, a note-on at velocity 0 kept as a note-on.

TWO-PROCESS RULE: --ref (Unicorn only) -> scratchpad/wrapper_velocity_ref.pkl;
--port (libjuno only) reads it.

USAGE
    python3 tools/verify/wrapper_velocity_gate.py --ref
    python3 tools/verify/wrapper_velocity_gate.py --port
    python3 tools/verify/wrapper_velocity_gate.py --tooth
"""
import os
import pickle
import refio
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
REF_PKL = os.environ.get('WRAPPER_VELOCITY_REF', os.path.join(REPO, 'scratchpad', 'wrapper_velocity_ref.pkl'))
VELS = (0, 1, 37, 64, 99, 100, 101, 126, 127)
VELSENSE_ID = 0x0FFFC00D        # vm.vs.velSense: address 13 of the vm.vs block (Script.xml), not in the state list
PUSH = 0x31F4E0


def messages():
    return [(st | ch, 60 + ch, v) for ch in (0, 9) for st in (0x90, 0x80) for v in VELS]


def changed_payload(state):
    """every entry of the plugin's own getState changed, plus velSense's id"""
    n = struct.unpack('>I', state[:4])[0]
    ent = [list(struct.unpack('>Ii', state[4 + i:12 + i])) for i in range(0, n, 8)]
    out = []
    for pid, v in ent:
        if pid >= 0x10000000:            # the 128 MIDI-assign entries: as saved
            out.append((pid, v))
        elif pid >= 0x0FFFC000:          # vm.vs: flip the switches, step the rest
            out.append((pid, 1 - v if v in (0, 1) else v + 1))
        else:
            out.append((pid, v))
    out.append((VELSENSE_ID, 0))
    pl = b''.join(struct.pack('>Ii', a, b) for a, b in out)
    return struct.pack('>I', len(pl)) + pl


def build_ref():
    sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
    import wrapper_emu as W
    w = W.Wrapper()
    w.boot_host(log=lambda s: None)
    uc = w.uc
    buf = w.alloc_com(16)
    ref = {'_payload': None}

    def push_all():
        out = []
        for m in messages():
            uc.mem_write(buf, bytes(m))
            n0 = len(w.queue())
            w.call(W.IB + PUSH, rcx=w.core, rdx=buf, r8=0, count=50_000_000)
            q = w.queue()[n0:]
            if len(q) != 1 or q[0][0] != 0:
                raise SystemExit('push of %r queued %r' % (m, [(k, o) for k, o, r in q]))
            out.append((m, tuple(q[0][2][8:11])))
        return out
    ref['init'] = {'flag': uc.mem_read(w.core + 572, 1)[0], 'msgs': push_all()}
    pl = changed_payload(w.get_state())
    assert w.set_state(pl) == 0, 'setState failed'
    ref['_payload'] = pl
    ref['state'] = {'flag': uc.mem_read(w.core + 572, 1)[0], 'msgs': push_all()}
    for k in ('init', 'state'):
        print('ref %-5s: switch byte %d, %d messages' % (k, ref[k]['flag'], len(ref[k]['msgs'])))
    refio.dump(ref, REF_PKL)
    print('wrote', REF_PKL)
    return 0


def check_port():
    import ctypes
    sys.path.insert(0, HERE)
    import freshlib
    if not os.path.exists(REF_PKL):
        print('MISSING %s -- run --ref first' % REF_PKL)
        return 2
    ref = pickle.load(open(REF_PKL, 'rb'))
    lib = freshlib.load()
    V = ctypes.c_void_p
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    for fn, at in (('juno_gui_plugin_init', [V]), ('juno_gui_state_load', [V, ctypes.c_char_p, ctypes.c_int]),
                   ('juno_gui_wrapper_midi', [V, ctypes.c_char_p]), ('juno_gui_destroy', [V])):
        getattr(lib, fn).argtypes = at
    bad = 0
    for k in ('init', 'state'):
        c = lib.juno_gui_create(ctypes.c_float(48000.0), 0)
        lib.juno_gui_plugin_init(c)
        if k == 'state':
            pl = ref['_payload']
            lib.juno_gui_state_load(c, pl, len(pl))
        diff = []
        for m, want in ref[k]['msgs']:
            b = ctypes.create_string_buffer(bytes(m), 3)
            lib.juno_gui_wrapper_midi(c, b)
            got = tuple(b.raw[:3])
            if got != want:
                diff.append((m, want, got))
        lib.juno_gui_destroy(c)
        print('%-5s (plugin switch byte %d): %d/%d messages agree%s' % (
            k, ref[k]['flag'], len(ref[k]['msgs']) - len(diff), len(ref[k]['msgs']),
            '' if not diff else '; first: in %s plugin %s port %s' % tuple(
                ' '.join('%02x' % x for x in t) for t in diff[0])))
        bad += bool(diff)
    print('\n=== WRAPPER VELOCITY (CLAIMS A23): the MIDI note intake, plugin vs port, byte for byte ===')
    print('GATE: %s' % ('FAIL' if bad else 'PASS'))
    return 1 if bad else 0


def tooth():
    sys.path.insert(0, HERE)
    from tooth_tree import run_tooth
    gate = ['tools/verify/wrapper_velocity_gate.py', '--port']
    T = [
        ('wv_default_off', 'plugin_init leaves the velocity switch off (the old port: every note at 100)',
         [('gui/juno_bridge.c', '    c->kbd_velocity_sw = 1;\n    return JUNO_STATE_N;', '    return JUNO_STATE_N;')]),
        ('wv_inverted', 'the switch inverted: velocity forced while it is on',
         [('gui/juno_bridge.c', '    int sw = c && c->kbd_velocity_sw;', '    int sw = !(c && c->kbd_velocity_sw);')]),
        ('wv_zero_kept', 'a note-on at velocity 0 stays a note-on',
         [('gui/juno_bridge.c', '        if (!m[2]) { m[0] = (unsigned char)((m[0] & 0x0F) | 0x80); m[2] = 64; }\n', '')]),
    ]
    res = {}
    for name, what, edits in T:
        res[name] = run_tooth(name, edits, gate, tail=600)
    print()
    for name, what, edits in T:
        print('%-16s %-12s %s' % (name, {0: 'BITES', 1: 'DID NOT BITE', 2: 'NO VERDICT'}[res[name]], what))
    return 0 if all(v == 0 for v in res.values()) else 1


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return build_ref()
    if a == ['--port']:
        return check_port()
    if a == ['--tooth']:
        return tooth()
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
