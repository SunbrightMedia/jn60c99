#!/usr/bin/env python3
"""reinit_check.py -- juno_gui_reinit must leave a context equal to a fresh juno_gui_create
(its contract: "the exact COLD state of a fresh juno_gui_create"). Compared: the state save
(getState: the parameter store and the CC map, CLAIMS A31 / A32), the CC each parameter's
control shows, the keyboard's note value (CLAIMS A36), a render of a patch with a key and a
mapped CC after both, then a MIDI learn armed, a CC and a drain: the CC learned and the state
save; then a panel keyboard write and a drain: the note value. The used context is first driven through a patch load, notes, mapped CCs, a setState that
empties the CC map, a MIDI learn armed and a UI-timer drain. Its teeth (each seen to fail,
2026-10-08): the reinit without the CC map's boot, without the store's defaults, with the
learn's waiting CC left at 0 (the memset's) -- the three lines juno_gui_reinit lacked -- and
without the keyboard note value's reset (a drain would then write 0 over every key).
Port against port: juno_gui_create is the side the plugin grades (coldstate_ab, boot_gate,
state_save_gate, ccmap_state_gate).
usage: reinit_check.py [LIB]   (default: the tree's libjuno.so, through the stale guard)"""
import ctypes
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import truth  # noqa: E402

V = ctypes.c_void_p


class Note(ctypes.Structure):
    _fields_ = [('offset', ctypes.c_int), ('type', ctypes.c_int), ('channel', ctypes.c_int),
                ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]


class Par(ctypes.Structure):
    _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]


def main():
    if len(sys.argv) > 1:
        lib = ctypes.CDLL(sys.argv[1])
    else:
        import freshlib
        lib = freshlib.load()
    for fn, at, rt in (('juno_gui_create', [ctypes.c_float, ctypes.c_int], V), ('juno_gui_plugin_init', [V], ctypes.c_int),
                       ('juno_gui_reinit', [V, ctypes.c_float, ctypes.c_int], None), ('juno_gui_destroy', [V], None),
                       ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_queue_state', [V, ctypes.c_char_p, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_state_save', [V, ctypes.c_char_p, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_cc_of', [V, ctypes.c_uint32], ctypes.c_int), ('juno_gui_cc_learn', [V, ctypes.c_uint32], ctypes.c_int),
                       ('juno_gui_ui_tick', [V], None), ('juno_gui_keybed_state', [V, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_keybed_write', [V, ctypes.c_int, ctypes.c_int], ctypes.c_int),
                       ('juno_gui_process_ex', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.POINTER(Par), ctypes.c_int,
                                                ctypes.c_int, ctypes.c_double, ctypes.POINTER(ctypes.c_float),
                                                ctypes.POINTER(ctypes.c_float), ctypes.c_int], ctypes.c_int)):
        f = getattr(lib, fn, None)
        if f is None:
            if fn in ('juno_gui_keybed_state', 'juno_gui_keybed_write'):
                continue
            raise SystemExit('missing ' + fn)
        f.argtypes = at
        f.restype = rt
    bank = open(truth.BANK, 'rb').read()
    base = 0x0FFFC100

    def block(c, notes=(), pars=()):
        ev = (Note * max(1, len(notes)))(*notes)
        pa = (Par * max(1, len(pars)))(*pars)
        L, R = (ctypes.c_float * 256)(), (ctypes.c_float * 256)()
        lib.juno_gui_process_ex(c, ev, len(notes), pa, len(pars), 1, 120.0, L, R, 256)
        return bytes(L) + bytes(R)

    def observe(c):
        buf = ctypes.create_string_buffer(4096)
        n = lib.juno_gui_state_save(c, buf, 4096)
        save = buf.raw[:n]
        ccs = tuple(lib.juno_gui_cc_of(c, 0x00600000 + k) for k in range(0, 0x300, 2))
        kb = tuple(lib.juno_gui_keybed_state(c, k) for k in range(128)) if hasattr(lib, 'juno_gui_keybed_state') else ()
        lib.juno_gui_plugin_init(c)
        lib.juno_gui_queue_patch(c, bank, len(bank), 5)
        audio = b''.join(block(c, [Note(0, 0, 0, 60, 0.8)], [Par(base + 74, 0, 0.3)]) for _ in range(20))
        lib.juno_gui_cc_learn(c, 0x0060003A)          # a learn armed: the next drain's first CC
        block(c, pars=[Par(base + 21, 0, 0.5)])
        lib.juno_gui_ui_tick(c)
        n2 = lib.juno_gui_state_save(c, buf, 4096)
        return save, ccs, kb, audio, (lib.juno_gui_cc_of(c, 0x0060003A), buf.raw[:n2])

    def observe_kb(c):
        """a panel keyboard write, then the first drain: the drain must not undo it (nothing pending)"""
        lib.juno_gui_keybed_write(c, 60, 90)
        lib.juno_gui_ui_tick(c)
        return (tuple(lib.juno_gui_keybed_state(c, k) for k in range(128)),)

    def pair():
        """a fresh context, and a used one reset by juno_gui_reinit"""
        fresh = lib.juno_gui_create(48000.0, 0)
        used = lib.juno_gui_create(48000.0, 0)
        lib.juno_gui_plugin_init(used)
        lib.juno_gui_queue_patch(used, bank, len(bank), 12)
        block(used, [Note(0, 0, 0, 64, 0.7), Note(0, 0, 3, 67, 0.6)], [Par(base + 74, 0, 0.9), Par(base + 71, 0, 0.2)])
        pl = struct.pack('>II', 0x0060003A, 9)
        lib.juno_gui_queue_state(used, struct.pack('>I', len(pl)) + pl, 4 + len(pl))
        lib.juno_gui_cc_learn(used, 0x0060003E)
        lib.juno_gui_ui_tick(used)
        block(used, [Note(0, 1, 0, 64, 0.5), Note(0, 0, 0, 72, 0.9)])
        lib.juno_gui_reinit(used, 48000.0, 0)
        return fresh, used

    runs = [(observe, ('the state save', 'the controls\' CCs', 'the keyboard note value', 'the render after both',
                       'a learn after both'))]
    if hasattr(lib, 'juno_gui_keybed_write'):
        runs.append((observe_kb, ('a keyboard write + drain',)))
    bad = 0
    for obs, names in runs:
        fresh, used = pair()
        a, b = obs(fresh), obs(used)
        for nm, x, y in zip(names, a, b):
            ok = x == y
            bad += not ok
            print('%-26s %s' % (nm, 'EQUAL' if ok else 'DIFFER'))
        lib.juno_gui_destroy(fresh)
        lib.juno_gui_destroy(used)
    print('reinit_check: %s' % ('PASS' if not bad else 'FAIL'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
