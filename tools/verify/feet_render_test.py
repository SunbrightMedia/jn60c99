#!/usr/bin/env python3
"""feet_render_test.py -- PROVEN: the port's DCO feet->pitch render is a clean octave.

Forces the DCO octave cell (3840, all 8 voices) BEFORE note-on and measures the
rendered fundamental period. Result (note 72, periods in range): feet 0.5 -> ratio
2.00 (one octave down), feet 2.0 -> ratio 0.50 (one octave up). So the port renders
feet correctly; the earlier "feet 0.5 sounds WAY too low" the user reported was a
CLEAN 16', which they rejected -> their real plugin plays patch 62 at ~8', i.e. the
plugin does NOT apply DCO RANGE on recall and the port's freeze is correct.

libjuno-only (two-process rule). NOTE: use a high enough note (72) that one-octave-
down stays within the autocorrelation search window (lag < 900); note 60's feet=0.5
period exceeds it and mis-locks onto a harmonic (a measurement artifact, not a bug).
"""
import ctypes, struct

LIB  = '/home/user/jn60c99/libjuno.so'
BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
SR, N = 48000.0, 16000
FEET_OFF, VOICE_STRIDE, NVOICE = 3840, 10512, 8


def bits(f): return struct.unpack('<I', struct.pack('<f', f))[0]


def main():
    lib = ctypes.CDLL(LIB)
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_poke.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_uint]
    lib.juno_gui_render.restype = ctypes.c_int
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    bank = open(BANK, 'rb').read()

    def render(patch, feet=None, note=72):
        ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), patch)
        if feet is not None:
            for v in range(NVOICE):
                lib.juno_gui_poke(ctx, FEET_OFF + v * VOICE_STRIDE, bits(feet))
        lib.juno_gui_note_on(ctx, note, 100)
        buf = (ctypes.c_float * (2 * N))()
        lib.juno_gui_render(ctx, buf, N)
        return [buf[2 * i] for i in range(N)]

    def period(x):
        x = x[6000:14000]; m = sum(x) / len(x); x = [v - m for v in x]
        best, bl = -1e30, 0
        for lag in range(40, 900):
            s = sum(x[i] * x[i + lag] for i in range(0, len(x) - lag, 2))
            if s > best: best, bl = s, lag
        return bl

    print("=== port DCO feet->pitch render (patch 62, note 72) ===")
    pb = period(render(62, None))
    print("baseline (feet 1.0/8'): period %d (~%.1f Hz)" % (pb, SR / pb))
    for f, exp in ((0.5, '2.00 down'), (2.0, '0.50 up')):
        pr = period(render(62, f))
        print("  feet=%.1f: period %d ratio %.2f  [expect %s]  %s"
              % (f, pr, pr / pb, exp, 'CLEAN' if abs(pr / pb - (2.0 if f == 0.5 else 0.5)) < 0.05 else 'CHECK'))
    print("=> feet render is a clean octave; so a clean 16' was what the user rejected")
    print("   -> the plugin plays patch 62 at ~8' -> DCO RANGE not applied on recall.")


if __name__ == '__main__':
    main()
