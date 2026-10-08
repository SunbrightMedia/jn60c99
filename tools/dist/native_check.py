#!/usr/bin/env python3
"""native_check.py -- JUNO-60.exe (gui/win/juno60_win.c, built by make_native.py)
graded against the PROVEN build of the same sources (libjuno.so, which make verify
grades against the plugin).

The program's --render mode runs its audio thread's own path (render_block ->
the plugin's process(), in its SSE FTZ / DAZ mode) on a fixed script -- MIDI
notes, CC 1, pitch bend, aftertouch, a panel slider edit, a key click, the arp
at the host tempo, a patch change -- writes the raw float output and logs every
engine call. This checker:
  replay   runs the logged calls, in order, through libjuno.so (a separate
           process: the program runs under Wine, or natively on Windows) and
           requires the outputs EQUAL BIT FOR BIT (the Windows compiler, its C
           library, its OS against the proven build)
  glue     requires every block's host events to be the MIDI the script queued
           since the block before, in the DAW's own mapping (note on/off ->
           note events, velocity v / 127; CC n -> MIDI-mapping parameter base +
           n, value d / 127; aftertouch -> base + 128; pitch bend -> base +
           129, value (lsb | msb << 7) / 16383)
  speed    reports the render's real-time factor (the program's own clock)

usage: python3 tools/dist/native_check.py [--exe PATH] [--tooth NAME]
  --tooth replay   the replay drops the first panel edit (VCF CUTOFF): must FAIL
  --tooth glue     the expected velocity is v / 128: must FAIL
Wine: $WINE (default /usr/lib/wine/wine64) with $WINEPREFIX.
"""
import ctypes
import os
import shutil
import struct
import subprocess
import sys
import tempfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import truth  # noqa: E402

# (bank index, patch): the factory bank and two of the user's banks, arp patches included
CASES = [(0, 0), (0, 37), (2, 5), (3, 20)]


class Note(ctypes.Structure):
    _fields_ = [('offset', ctypes.c_int), ('type', ctypes.c_int), ('channel', ctypes.c_int),
                ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]


class Par(ctypes.Structure):
    _fields_ = [('id', ctypes.c_uint32), ('offset', ctypes.c_int), ('value', ctypes.c_double)]


def f32(h):
    return struct.unpack('<f', struct.pack('<I', int(h, 16)))[0]


def f64(h):
    return struct.unpack('<d', struct.pack('<Q', int(h, 16)))[0]


def bank_bytes(name):
    if name == 'Factory':
        return open(truth.BANK, 'rb').read()
    udir = os.path.join(REPO, 'scratchpad', 'userbanks')
    for f in os.listdir(udir):
        if f.lower().endswith('.bin') and os.path.splitext(f)[0].lstrip('~').strip() == name:
            return open(os.path.join(udir, f), 'rb').read()
    raise SystemExit('bank %r not found' % name)


def load_lib():
    lib = ctypes.CDLL(os.path.join(REPO, 'libjuno.so'))
    V = ctypes.c_void_p
    for n, a, r in [('juno_gui_create', [ctypes.c_float, ctypes.c_int], V),
                    ('juno_gui_plugin_init', [V], ctypes.c_int),
                    ('juno_gui_queue_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int], ctypes.c_int),
                    ('juno_gui_model_set', [V, ctypes.c_uint32, ctypes.c_int32], ctypes.c_int),
                    ('juno_gui_ui_tick', [V], None),
                    ('juno_gui_commit', [V], None),
                    ('juno_gui_keybed_write', [V, ctypes.c_int, ctypes.c_int], ctypes.c_int),
                    ('juno_gui_process_ex', [V, ctypes.POINTER(Note), ctypes.c_int, ctypes.POINTER(Par), ctypes.c_int,
                                             ctypes.c_int, ctypes.c_double, ctypes.POINTER(ctypes.c_float),
                                             ctypes.POINTER(ctypes.c_float), ctypes.c_int], ctypes.c_int),
                    ('juno_midi_base', [], ctypes.c_uint32),
                    ('juno_gui_free', [V], None)]:
        fn = getattr(lib, n, None)
        if fn is None:
            continue
        fn.argtypes, fn.restype = a, r
    return lib


def expected(midi, base, tooth):
    """the DAW's mapping of the queued MIDI to host events / parameter points"""
    ev, par = [], []
    for m in midi:
        st, ch, d1, d2 = m & 0xF0, m & 0x0F, (m >> 8) & 0x7F, (m >> 16) & 0x7F
        if st == 0x90 and d2:
            v = np.float32(d2) / np.float32(128.0 if tooth == 'glue' else 127.0)
            ev.append((0, 0, ch, d1, struct.unpack('<I', struct.pack('<f', v))[0]))
        elif st in (0x80, 0x90):
            ev.append((0, 1, ch, d1, struct.unpack('<I', struct.pack('<f', 0.5))[0]))
        elif st == 0xB0:
            par.append((base + d1, 0, d2 / 127.0))
        elif st == 0xD0:
            par.append((base + 128, 0, d1 / 127.0))
        elif st == 0xE0:
            par.append((base + 129, 0, (d1 | (d2 << 7)) / 16383.0))
    return ev, par


def replay(lib, log, tooth):
    """the logged calls through the proven build; returns (output, glue errors)"""
    c = None
    base = lib.juno_midi_base()
    out, errs, pending, blk, dropped = [], [], [], 0, False
    banks = {}
    lines = [ln.split() for ln in log.splitlines() if ln and not ln.startswith('#')]
    i = 0
    while i < len(lines):
        t = lines[i]
        i += 1
        if t[0] == 'create':
            c = lib.juno_gui_create(float(t[1]), int(t[2]))
        elif t[0] == 'plugin_init':
            lib.juno_gui_plugin_init(c)
        elif t[0] == 'queue_patch':
            name = ' '.join(t[2:])
            b = banks.setdefault(name, bank_bytes(name))
            lib.juno_gui_queue_patch(c, b, len(b), int(t[1]))
        elif t[0] == 'model_set':
            if tooth == 'replay' and blk > 0 and not dropped:
                dropped = True                            # TOOTH: the first panel edit is lost
                continue
            lib.juno_gui_model_set(c, int(t[1]), int(t[2]))
        elif t[0] == 'ui_tick':
            lib.juno_gui_ui_tick(c)
        elif t[0] == 'commit':
            lib.juno_gui_commit(c)
        elif t[0] == 'keybed':
            lib.juno_gui_keybed_write(c, int(t[1]), int(t[2]))
        elif t[0] == 'midi':
            pending.append(int(t[1], 16))
        elif t[0] == 'process':
            n, tempo, nev, npar = int(t[1]), f64(t[2]), int(t[3]), int(t[4])
            ev = (Note * max(nev, 1))()
            par = (Par * max(npar, 1))()
            got_ev, got_par = [], []
            for k in range(nev):
                e = lines[i + k]
                ev[k] = Note(int(e[1]), int(e[2]), int(e[3]), int(e[4]), f32(e[5]))
                got_ev.append((int(e[1]), int(e[2]), int(e[3]), int(e[4]), int(e[5], 16)))
            i += nev
            for k in range(npar):
                p = lines[i + k]
                par[k] = Par(int(p[1]), int(p[2]), f64(p[3]))
                got_par.append((int(p[1]), int(p[2]), f64(p[3])))
            i += npar
            want_ev, want_par = expected(pending, base, tooth)
            if got_ev != want_ev or got_par != want_par:
                errs.append('block %d: events %s params %s, expected %s %s' % (blk, got_ev, got_par, want_ev, want_par))
            pending = []
            L = (ctypes.c_float * n)()
            R = (ctypes.c_float * n)()
            lib.juno_gui_process_ex(c, ev, nev, par, npar, 1, tempo, L, R, n)
            o = np.empty(2 * n, np.float32)
            o[0::2] = np.frombuffer(L, np.float32)
            o[1::2] = np.frombuffer(R, np.float32)
            out.append(o)
            blk += 1
        else:
            raise SystemExit('log line %d: unknown call %r' % (i, t))
    if c and hasattr(lib, 'juno_gui_free'):
        lib.juno_gui_free(c)
    return np.concatenate(out), errs


def run_exe(exe, bank, patch, work):
    raw = os.path.join(work, 'r_%d_%d.raw' % (bank, patch))
    args = [exe, '--render', os.path.basename(raw), '--bank', str(bank), '--patch', str(patch)]
    if os.name != 'nt':
        args = [os.environ.get('WINE', '/usr/lib/wine/wine64')] + args
    env = dict(os.environ, WINEDEBUG='-all')
    subprocess.run(args, cwd=work, env=env, check=True, timeout=600,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    log = open(raw + '.log', newline=None).read()
    return np.fromfile(raw, np.float32), log


def main():
    exe = os.path.join(REPO, 'scratchpad', 'dist', 'JUNO-60.exe')
    if '--exe' in sys.argv:
        exe = sys.argv[sys.argv.index('--exe') + 1]
    tooth = sys.argv[sys.argv.index('--tooth') + 1] if '--tooth' in sys.argv else None
    truth.verify()
    lib = load_lib()
    work = tempfile.mkdtemp(prefix='native_check_')
    shutil.copyfile(exe, os.path.join(work, 'JUNO-60.exe'))
    fails = 0
    for bank, patch in CASES:
        got, log = run_exe(os.path.join(work, 'JUNO-60.exe'), bank, patch, work)
        ref, errs = replay(lib, log, tooth)
        same = got.shape == ref.shape and np.array_equal(got.view(np.uint32), ref.view(np.uint32))
        nz = int(np.count_nonzero(ref))
        diff = 'EXACT' if same else 'DIFFER at sample %d of %d' % (
            int(np.argmax(got.view(np.uint32) != ref.view(np.uint32))) if got.shape == ref.shape else -1, ref.size)
        speed = [ln for ln in log.splitlines() if ln.startswith('# rendered')]
        ok = same and not errs and nz > ref.size // 4
        fails += not ok
        name = [ln for ln in log.splitlines() if ln.startswith('queue_patch')][0].split(None, 2)[2]
        print('%s bank %d (%s) patch %2d: replay %s, glue %s, %d / %d samples non-zero, peak %.3f; %s' % (
            'ok  ' if ok else 'FAIL', bank, name, patch + 1, diff, 'ok' if not errs else '%d ERRORS' % len(errs),
            nz, ref.size, float(np.max(np.abs(ref))), speed[0][2:] if speed else ''))
        for e in errs[:3]:
            print('      ' + e)
    shutil.rmtree(work)
    print('native_check: %s (%d cases%s)' % ('GREEN' if not fails else 'RED', len(CASES),
                                             ', tooth ' + tooth if tooth else ''))
    return 1 if fails else 0


if __name__ == '__main__':
    sys.exit(main())
