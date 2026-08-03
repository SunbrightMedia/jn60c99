#!/usr/bin/env python3
"""alloc_ab.py — engine B's voice allocator against the PORT's, on note sequences.

WHAT THIS GATES, and why it needs its own gate rather than the null harness.
engine_b/eb_alloc.c decides BINDINGS -- which voice plays which note and which
voices are gated. The null harness renders audio, and audio is a terrible
detector for an allocation defect: two allocators can put the same note on
different voices and produce output that differs only through the per-voice
CONDITION scatter and free-running DCO phase. That is precisely how the port
shipped a POLY-only allocator for months while every gate stayed green and 16
of the 64 factory patches played in the wrong mode
(docs/ASSIGNER_MODE_FINDING.md). So this gate compares the BINDINGS directly,
after EVERY event, and a single differing slot is a failure.

THE REFERENCE is gui/juno_bridge.c's allocator, which is a transcription of the
plugin's CAssignJu60 and is PROVEN 34/34 against the plugin's own assigner by
tools/verify/assigner_ab.py in `make verify`. This gate therefore inherits that
proof; it does not re-establish it, and it is not a substitute for it.

ONE PROCESS IS CORRECT HERE. The two-process rule exists to keep a Unicorn
oracle and a ctypes-loaded libjuno out of one address space. No Unicorn is
involved: both allocators are plain C in the same library, so comparing them in
one process is not the hazard that rule guards against.

A SINGLE NOTE CANNOT TELL POLY FROM MONO -- that mistake is on the record too --
so every case below is a SEQUENCE, and the mode-sensitive ones overlap notes,
release out of order, and exceed the voice count on purpose.
"""
import ctypes
import os
import random
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "tools", "engineb"))
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import null_b
import null_ab
import truth

NV = 8


class EbAlloc(ctypes.Structure):
    _fields_ = [("voice_note",  ctypes.c_int * NV),
                ("voice_gated", ctypes.c_ubyte * NV),
                ("voice_age",   ctypes.c_uint * NV),
                ("age_counter", ctypes.c_uint),
                ("held_notes",  ctypes.c_uint * 4),
                ("legato_mask", ctypes.c_uint),
                ("assign_mode", ctypes.c_int),
                ("legato",      ctypes.c_int),
                ("portamento_on", ctypes.c_int)]


class EbEv(ctypes.Structure):
    _fields_ = [("kind", ctypes.c_ubyte), ("voice", ctypes.c_byte),
                ("a", ctypes.c_short), ("b", ctypes.c_short)]


def scripts(seed_count=24):
    """(name, assign_mode-selecting patch index or None, [events])."""
    out = []
    # Deterministic sequences that separate the modes. A rising line longer
    # than the voice count forces the steal path; the interleaved release
    # exercises lowest-held fallback; the re-strike exercises the persistent
    # note->voice binding that must NOT be reaped.
    out.append(("rising 12", [("on", 60 + i, 100) for i in range(12)]))
    out.append(("chord + partial release",
                [("on", n, 100) for n in (60, 64, 67, 71)] +
                [("off", 64, 0), ("off", 60, 0)] +
                [("on", 62, 100), ("on", 65, 100)]))
    out.append(("restrike after release",
                [("on", 60, 100), ("off", 60, 0), ("on", 67, 100),
                 ("on", 60, 100), ("off", 67, 0), ("on", 60, 100)]))
    out.append(("overlapping legato line",
                [("on", 60, 100), ("on", 62, 100), ("on", 64, 100),
                 ("off", 62, 0), ("off", 60, 0), ("off", 64, 0)]))
    out.append(("out-of-order release",
                [("on", n, 100) for n in (48, 55, 60, 64, 67, 72, 76, 79)] +
                [("off", n, 0) for n in (60, 48, 79, 64)] +
                [("on", 50, 100), ("on", 53, 100)]))
    out.append(("all off then replay",
                [("on", 60, 100), ("on", 64, 100), ("off", -1, 0),
                 ("on", 60, 100), ("on", 64, 100)]))
    # Random sequences: the shape no hand-written case covers.
    for s in range(seed_count):
        rnd = random.Random(1000 + s)
        ev, held = [], []
        for _ in range(40):
            if held and rnd.random() < 0.45:
                n = rnd.choice(held); held.remove(n); ev.append(("off", n, 0))
            else:
                n = rnd.randrange(36, 90)
                if n not in held: held.append(n)
                ev.append(("on", n, rnd.randrange(1, 128)))
        out.append(("fuzz seed %d" % s, ev))
    return out


# ---------------------------------------------------------------- teeth
# Each entry is a NAMED, REAL allocator error -- one of the four rules
# eb_alloc.h says are most likely to be "tidied" wrong, plus the historic
# POLY-only bug that cost 16 factory patches. The gate must catch every one.
# A gate that has never been seen to fail is not a verification.
TEETH = {
    "scan_bottom_up": (
        "for (w = NV - 1; w >= 0; --w)          /* TOP-DOWN -- load-bearing */",
        "for (w = 0; w < NV; ++w)               /* PLANTED: bottom-up */"),
    "reap_binding": (
            "            emit(ev, n, EB_EV_NOTE_OFF, v, 0, 0);\n"
            "            a->voice_gated[v] = 0;      /* stays ASSIGNED -- rule 2 */",
            "            emit(ev, n, EB_EV_NOTE_OFF, v, 0, 0);\n"
            "            a->voice_gated[v] = 0; a->voice_note[v] = -1; /* PLANTED reap */"),
    "always_poly": (
        "        case 1:  mono_note_on(a, midi_note, velocity, ev, &n);      break;",
        "        case 1:  poly_note_on(a, midi_note, velocity, 0, ev, &n);   break;"),
    "highest_held": (
        "                if (a->held_notes[w] & (1u << b)) return (w << 5) | b;",
        "                if (a->held_notes[w] & (1u << (31-b))) return (w << 5) | (31-b);"),
}


def teeth():
    """Plant each known allocator error and require this gate to catch it."""
    import shutil
    print("=== ALLOCATOR GATE TEETH ===")
    bad = 0
    for name, (old, new) in sorted(TEETH.items()):
        def _plant(tmp, mutate, _o=old, _n=new):
            f = os.path.join(tmp, "engine_b", "eb_alloc.c")
            t = open(f).read()
            if t.count(_o) != 1:
                raise SystemExit("teeth anchor for '%s' matched %d times in "
                                 "eb_alloc.c, expected 1. The module moved; a "
                                 "case that cannot reach its own mutation "
                                 "measures nothing." % (mutate, t.count(_o)))
            open(f, "w").write(t.replace(_o, _n, 1))
        orig = null_b._plant
        null_b._plant = _plant
        try:
            rc = run_gate(mutate=name, quiet=True)
        finally:
            null_b._plant = orig
        ok = (rc != 0)
        if not ok:
            bad += 1
        print("  planted %-16s -> %s" % (name, "CAUGHT" if ok else
                                         "*** NOT CAUGHT -- the gate is blind ***"))
    print("TEETH: %s" % ("PASS" if bad == 0 else
                         "FAIL -- blind in %d case(s)" % bad))
    return 1 if bad else 0


def main():
    truth.require()
    if "--teeth" in sys.argv[1:]:
        return teeth()
    return run_gate(mutate=None, quiet="--verbose" not in sys.argv[1:])


def run_gate(mutate=None, quiet=True):
    import tempfile
    tmp = tempfile.mkdtemp(prefix="alloc_ab_")
    so = os.path.join(tmp, "libjuno_alloc.so")
    if not quiet or mutate is None:
        print("building the library (port bridge + engine B, identical flags) ...")
    null_b.build(so, modules=(), mutate=mutate)
    lib = ctypes.CDLL(so)

    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_debug_voices.argtypes = [ctypes.c_void_p,
                                          ctypes.POINTER(ctypes.c_int),
                                          ctypes.POINTER(ctypes.c_ubyte)]
    lib.eb_alloc_init.argtypes = [ctypes.POINTER(EbAlloc)]
    lib.eb_alloc_note_on.argtypes = [ctypes.POINTER(EbAlloc), ctypes.c_int,
                                     ctypes.c_int, ctypes.POINTER(EbEv)]
    lib.eb_alloc_note_off.argtypes = [ctypes.POINTER(EbAlloc), ctypes.c_int,
                                      ctypes.POINTER(EbEv)]

    bank = open(truth.BANK, "rb").read()
    # Cover every assign mode the bank actually contains, by patch, so the
    # configuration comes from the instrument's own recall and not from a
    # number typed here.
    lib.juno_bank_voice_modes.argtypes = [ctypes.c_char_p, ctypes.c_int,
                                          ctypes.POINTER(ctypes.c_int),
                                          ctypes.POINTER(ctypes.c_int),
                                          ctypes.POINTER(ctypes.c_int)]
    # THE ARPEGGIATOR MUST BE OFF, and how that is achieved matters.
    # juno_gui_note_on routes to carp_add_key instead of the allocator when the
    # patch has the arp on, so the port's voice table stays empty and every
    # comparison "diverges" for a reason that has nothing to do with
    # allocation. The bank's first (0,0,False) patch is patch 1, which is an arp
    # patch, so 30 of 270 sequences reported FAIL on a gate defect.
    #
    # SKIPPING arp patches fixes that and costs too much: it drops the
    # configuration count from 9 to 4 and takes UNISON and every LEGATO
    # configuration with it -- a silent coverage hole in a gate whose whole
    # purpose is catching a mode the port once got wrong on 16 patches. So the
    # patch's own recalled assign configuration is kept and the ARP alone is
    # switched off afterwards, and get_arp() is ASSERTED zero before any
    # sequence runs.
    lib.juno_gui_get_arp.argtypes = [ctypes.c_void_p]
    lib.juno_gui_arp_config.argtypes = [ctypes.c_void_p, ctypes.c_int,
                                        ctypes.c_int, ctypes.c_int,
                                        ctypes.c_float, ctypes.c_float]
    by_mode = {}
    for idx in range(64):
        lg, am, po = ctypes.c_int(), ctypes.c_int(), ctypes.c_int()
        lib.juno_bank_voice_modes(bank, idx, ctypes.byref(lg),
                                  ctypes.byref(am), ctypes.byref(po))
        by_mode.setdefault((am.value, lg.value, po.value != 0), idx)
    print("assign configurations present in the factory bank "
          "(mode, legato, porta) -> first patch: %s"
          % {k: v for k, v in sorted(by_mode.items())})

    cases = scripts()
    bad = total = 0
    for cfg, patch in sorted(by_mode.items()):
        mode, legato, porta = cfg
        for name, ev in cases:
            total += 1
            c = ctypes.c_void_p(lib.juno_gui_create())
            lib.juno_gui_apply_bank(c, bank, len(bank), patch)
            lib.juno_gui_arp_config(c, 0, 0, 0, ctypes.c_float(120.0),
                                    ctypes.c_float(0.5))
            if lib.juno_gui_get_arp(c) != 0:
                raise SystemExit("patch %d still reports the ARPEGGIATOR on "
                                 "after being told to switch it off; its "
                                 "note-ons would never reach the allocator and "
                                 "this comparison would measure nothing."
                                 % patch)
            a = EbAlloc()
            lib.eb_alloc_init(ctypes.byref(a))
            a.assign_mode = mode
            a.legato = legato
            a.portamento_on = 1 if porta else 0
            evbuf = (EbEv * 40)()
            notes = (ctypes.c_int * NV)()
            gated = (ctypes.c_ubyte * NV)()
            diff = None
            for step, (kind, n, vel) in enumerate(ev):
                if kind == "on":
                    lib.juno_gui_note_on(c, n, vel)
                    lib.eb_alloc_note_on(ctypes.byref(a), n, vel, evbuf)
                else:
                    lib.juno_gui_note_off(c, n)
                    lib.eb_alloc_note_off(ctypes.byref(a), n, evbuf)
                lib.juno_gui_debug_voices(c, notes, gated)
                pn = [notes[i] for i in range(NV)]
                pg = [gated[i] for i in range(NV)]
                en = [a.voice_note[i] for i in range(NV)]
                eg = [a.voice_gated[i] for i in range(NV)]
                if pn != en or pg != eg:
                    diff = (step, kind, n, pn, pg, en, eg)
                    break
            lib.juno_gui_destroy(c)
            if diff:
                bad += 1
                if quiet and mutate is not None:
                    continue
                step, kind, n, pn, pg, en, eg = diff
                if mutate is not None:
                    continue
                print("  *** mode=%d legato=%d porta=%d  '%s'  DIVERGED at "
                      "event %d (%s %d)" % (mode, legato, porta, name,
                                            step, kind, n))
                print("        port  notes=%s gated=%s" % (pn, pg))
                print("        eng B notes=%s gated=%s" % (en, eg))
            elif not quiet:
                print("  ok  mode=%d '%s'" % (mode, name))
    if mutate is None:
        print("\n%d/%d sequences agree with the port's allocator, over every "
              "assign configuration in the bank." % (total - bad, total))
        print("VERDICT: %s" % ("PASS" if bad == 0 else "FAIL (%d)" % bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
