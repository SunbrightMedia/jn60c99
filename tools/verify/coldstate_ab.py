#!/usr/bin/env python3
"""coldstate_ab.py — COLD-STATE A/B: the port's power-on engine state vs the
plugin's OWN constructor + setSampleRate, executed under Unicorn. This is the
self-proving replacement for the init/prepare "live state dump" cross-check (a
capture): the ground truth here is the plugin's machine code (BUILD 0x3C68D0 +
setSampleRate 0x3C7A20 + snap-all), never a runtime snapshot.

WHAT IT PROVES: every cell juno_engine_init + juno_engine_prepare + juno_chorus_init
write is bit-identical to the plugin's own cold state — at EVERY host rate, which
also covers the "other host sample rates" question (44100/48000/88200/96000/192000).

SCOPE + CLASSIFICATION (honest, not swept):
  * FULL meaningful state [0, 11022352): 8 voice DSP blocks (voice v at state[v] +
    v*10512) + the shared/master/FX region (state[0] + off).
  * A diff is ACCEPTED (not a failure) only if it is one of:
      - C++ object header, off%10512 < 176: vtable/smoother pointers + object
        counters. The port legitimately does not model these; the render A/B is
        bit-exact on all 64 patches DESPITE them, which PROVES they are audio-inert.
      - CONDITION analog scatter (5520/7600/10320 + voice stride): the port applies
        the default patch's CONDITION=128 at create; the plugin's raw build+setSR
        does not recall a patch. Proven separately (test_condition_scatter + recall).
  * ANY other differing cell is a real init/prepare error and FAILS the gate.

TWO-PROCESS (mandatory): --port uses libjuno via ctypes; --ref builds the plugin
under Unicorn. They meet only through the pickle.
  python3 coldstate_ab.py --port <rate>   # port cold dump -> pickle
  python3 coldstate_ab.py --ref  <rate>   # plugin build+setSR, diff, verdict
NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, os, struct, pickle

BLOCK = 10512
NVOICE = 8
VOICE_END = NVOICE * BLOCK            # 84096
MEANINGFUL = 11022352                 # plugin per-unit object size (9x operator new(0xA83010))
PKL = '/home/user/jn60c99/scratchpad/coldstate_ab.pkl'

# CONDITION analog-scatter cells the port applies at create (per voice), excluded.
COND_LOCAL = (5520, 7600, 10320)

# FX-recall DEFAULT cells: the plugin front-loads these delay/reverb defaults at
# setSampleRate, but the PORT writes them lazily at per-patch recall (grep-confirmed:
# src/delay_recall.c writes 102544 / 10759360 / 10759472 / 10759840; the master
# block counter 11022344 is engine plumbing). They are 0 at the port's unapplied
# default, where delay+reverb are OFF (reverb send=0, delay TYPE=0 -> wet=0), so
# they are audio-inert there; once a patch engages the effect, recall writes them
# and the render A/B is bit-exact on all 64 patches. They are NOT init/prepare
# constants (this gate's subject), so they are excluded here and proven by the
# FX-render row instead.
# (11022052 — the plugin's slot-2 EFFECT-routing int, power-on 2 — was excluded
# here until 2026-07-19. That exclusion hid a REAL divergence: the port seeded its
# routing 0, idling in the Pan arm while the plugin free-runs the chorus arm from
# power-on, which broke warm/DAW-parity on every chorus patch (BS Solid report).
# juno_engine_prepare now writes the proven power-on value, so the cell is GATED.)
FX_RECALL_DEFAULT = {102544, 10759360, 10759472, 10759840, 11022344}

def rate_arg():
    return float(sys.argv[2]) if len(sys.argv) > 2 else 48000.0

if sys.argv[1:2] == ['--port']:
    import ctypes
    rate = rate_arg()
    lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_dump.restype = ctypes.c_int
    lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int,
                                  ctypes.POINTER(ctypes.c_ubyte), ctypes.c_int]
    c = lib.juno_gui_create(ctypes.c_float(rate), 0)
    buf = (ctypes.c_ubyte * MEANINGFUL)()
    n = lib.juno_gui_dump(c, 0, buf, MEANINGFUL)
    assert n == MEANINGFUL, n
    pickle.dump({'rate': rate, 'state': bytes(buf)}, open(PKL, 'wb'))
    print("PORT cold state @%g dumped (%d bytes)" % (rate, n))

    # SELF-CHECK: prove the FX_RECALL_DEFAULT cells this gate excludes are AUDIO-INERT
    # at the port's unapplied default (they are 0 there; the plugin front-loads them).
    # Render the default with those cells at 0 vs poked to a distinctive sentinel; if
    # the output is byte-identical, they cannot reach the audio path regardless of
    # value, so leaving them 0 at cold state is safe (value- and rate-independent).
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_poke.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_uint]
    def dflt_render(poke):
        cc = lib.juno_gui_create(ctypes.c_float(rate), 0)
        if poke:
            for off in FX_RECALL_DEFAULT: lib.juno_gui_poke(cc, off, 0x3f000000)
        lib.juno_gui_note_on(cc, 60, 105)
        b = (ctypes.c_float * (2 * 24000))(); lib.juno_gui_render(cc, b, 24000)
        return bytes(b)
    inert = dflt_render(False) == dflt_render(True)
    print("  FX-recall-default cells audio-inert at unapplied default:", inert)
    if not inert:
        print("  *** FX_RECALL_DEFAULT exclusion is UNSAFE — a cell reaches the output ***")
        sys.exit(1)

elif sys.argv[1:2] == ['--ref']:
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import e2e_emu as E
    try:
        import numpy as np
    except ImportError:
        np = None
    d = pickle.load(open(PKL, 'rb'))
    rate = d['rate']; port = d['state']
    e = E.E2E(); e.build(rate); e.snap_all(); e.set_ftz()
    uc = e.uc
    # Assemble the plugin's equivalent flat buffer: voice v from state[v]+v*BLOCK,
    # the shared/master/FX region from state[0].
    plug = bytearray(MEANINGFUL)
    for v in range(NVOICE):
        lo = v * BLOCK
        plug[lo:lo + BLOCK] = uc.mem_read(e.state[v] + lo, BLOCK)
    plug[VOICE_END:MEANINGFUL] = uc.mem_read(e.state[0] + VOICE_END, MEANINGFUL - VOICE_END)
    plug = bytes(plug)

    def f(u): return struct.unpack('<f', struct.pack('<I', u))[0]
    cond = set()
    for v in range(NVOICE):
        for c in COND_LOCAL:
            cond.add(v * BLOCK + c)

    # cell-wise diff (uint32)
    if np is not None:
        pa = np.frombuffer(port, dtype='<u4')
        ga = np.frombuffer(plug, dtype='<u4')
        idx = np.nonzero(pa != ga)[0]
        diffs = [(int(i) * 4, int(pa[i]), int(ga[i])) for i in idx]
    else:
        diffs = []
        for o in range(0, MEANINGFUL, 4):
            pv = struct.unpack('<I', port[o:o+4])[0]; gv = struct.unpack('<I', plug[o:o+4])[0]
            if pv != gv: diffs.append((o, pv, gv))

    n_hdr = n_cond = n_fx = 0; real = []
    for off, pv, gv in diffs:
        local = off % BLOCK
        if off < VOICE_END and local < 176:      n_hdr += 1
        elif off in cond:                          n_cond += 1
        elif off in FX_RECALL_DEFAULT:             n_fx += 1
        else:                                      real.append((off, pv, gv))
    print("=== COLD-STATE A/B  port vs plugin build+setSampleRate  @ %g Hz ===" % rate)
    print("  cells compared: %d" % (MEANINGFUL // 4))
    print("  diffs: %d total  ->  header(<176): %d   CONDITION: %d   FX-recall-default: %d   REAL: %d"
          % (len(diffs), n_hdr, n_cond, n_fx, len(real)))
    for off, pv, gv in real[:60]:
        print("    +%-9d: port %.8g (0x%08x)  plugin %.8g (0x%08x)" % (off, f(pv), pv, f(gv), gv))
    if len(real) > 60:
        print("    ... +%d more" % (len(real) - 60))
    ok = not real
    print("\nGATE:", "PASS -- init/prepare cold state bit-exact vs the plugin" if ok
          else "FAIL -- %d real init/prepare diffs" % len(real))
    sys.exit(0 if ok else 1)
else:
    print("usage: coldstate_ab.py --port <rate> | --ref <rate>", file=sys.stderr)
    sys.exit(2)
