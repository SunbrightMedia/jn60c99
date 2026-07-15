#!/usr/bin/env python3
"""port_render.py -- the PORT side of the audio A/B.

Renders the port's stereo output for a set of (patch, note, velocity) scenarios
so it can be compared, sample by sample, against the plugin's OWN render after a
plugin-native (host-mediated) recall. Touches ONLY libjuno via ctypes -- imports
nothing from e2e_emu (two-process rule).

The plugin reference side (plugin real recall -> real process() render) is the
current work (docs/CLAIMS.md section E); once it exists, diff the two pickles.

Output: pickle {(patch,note,vel): (L[list], R[list])}.

Usage:
  python3 tools/verify/port_render.py                 # default scenario set
  python3 tools/verify/port_render.py 62 60 100 24000 # one scenario: patch note vel nframes
"""
import sys, struct, pickle, ctypes

LIB  = '/home/user/jn60c99/libjuno.so'
BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
PKL  = '/home/user/jn60c99/scratchpad/port_render.pkl'
SR   = 48000.0

# A spread across DCO-RANGE values (2/3/4/5), bass/lead/pad, to expose octave/level
# divergences if the plugin recalls DCO RANGE and the port does not.
DEFAULT = [
    (62, 60, 100, 24000),   # BS Juno Grime   (DCO RANGE 2 -> feet 0.5 if recalled)
    (61, 60, 100, 24000),   # LD Perc Lead    (DCO RANGE 4 -> feet 2.0)
    (63, 60, 100, 24000),   # (DCO RANGE 3 -> feet 1.0, default)
    (39, 60, 100, 24000),   # BL Fairytale    (DCO RANGE 5 -> feet 4.0)
    (4,  48, 100, 24000),   # PD Classic Pad  (DCO RANGE 2)
    (18, 72, 100, 24000),   # KY Classik Dekay(DCO RANGE 4)
]


def load_lib():
    lib = ctypes.CDLL(LIB)
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_render.restype = ctypes.c_int
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    return lib


def render_one(lib, bank, patch, note, vel, nframes):
    ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
    lib.juno_gui_apply_bank(ctx, bank, len(bank), patch)
    lib.juno_gui_note_on(ctx, note, vel)
    buf = (ctypes.c_float * (2 * nframes))()
    lib.juno_gui_render(ctx, buf, nframes)
    L = [buf[2 * i] for i in range(nframes)]
    R = [buf[2 * i + 1] for i in range(nframes)]
    return L, R


def rms(xs):
    return (sum(x * x for x in xs) / len(xs)) ** 0.5 if xs else 0.0


def main():
    lib = load_lib()
    bank = open(BANK, 'rb').read()
    if len(sys.argv) >= 5:
        scen = [(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]))]
    else:
        scen = DEFAULT
    out = {}
    print("=== PORT render (patch, note, vel) -> stereo RMS ===")
    for (p, n, v, nf) in scen:
        L, R = render_one(lib, bank, p, n, v, nf)
        out[(p, n, v)] = (L, R)
        print("  patch %2d note %3d vel %3d : %d frames  L-rms=%.5f R-rms=%.5f" %
              (p, n, v, nf, rms(L), rms(R)))
    pickle.dump(out, open(PKL, 'wb'))
    print("saved -> %s" % PKL)
    print("(reference side = plugin real recall + real process() render; diff is a separate step)")


if __name__ == '__main__':
    main()
