#!/usr/bin/env python3
"""coldwarm_unison.py — regression guard for the COLD-START UNISON defect
(docs/COLDSTART_UNISON_FINDING.md).

WHAT WENT WRONG. The engine constructor arms every voice's DCO retrigger latch, so
a note played on a COLD engine starts all 8 DCOs exactly in phase. Harmless in POLY
(one voice sounds); in UNISON all 8 voices play the same note, so an aligned stack
sums COHERENTLY — far too loud and, because the fundamental adds x8 while the
detune-scattered upper partials do not, far too dark. Per-voice CONDITION scatter
decorrelates the voices over a few seconds of free-running. A real DAW instance
renders continuously from activation and is never played in the aligned state; the
web app was presenting exactly that state with only a 1.5 s boot warm-up.

WHY A GATE. Nothing else in `make verify` can see this. Every render gate drives one
explicit lifecycle and is bit-exact — the port and the plugin AGREE in both the cold
and the warm state (cold: recall_render_ab 57/57, assigner_ab 28/28; warm:
renderstruct_ab). The defect was never a value; it was WHICH state the user is placed
in. So this gate asserts the two things that would silently bring it back:

  1. the web app's boot warm-up is still >= the measured requirement, and
  2. the cold->warm decorrelation still actually happens (i.e. per-voice CONDITION
     scatter still detunes the unison stack). If someone neutralised the scatter, the
     voices would stay locked in phase forever and warming would stop helping.

PORT-ONLY by design: this is a property of the lifecycle the app presents, not a
port-vs-plugin comparison, and it uses only the factory bank in truth/ so it is
durable (patch 61 is the factory bank's ASSIGN MODE 2 patch).

Measured reference (probes/hostpath/warm_all_unison.py), note 60 vel 100 @ 44.1 kHz:
    factory 61 (UNISON)  peak 0.527 cold -> 0.202 warm     ratio 2.6x
    factory  0 (POLY)    peak 0.255 cold -> 0.265 warm     flat  (the control)
"""
import ctypes, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import truth

SR = 44100.0
WARM_MIN_SECONDS = 4.0          # the value docs/COLDSTART_UNISON_FINDING.md derives
UNISON_PATCH, POLY_PATCH = 61, 0
MIN_COLD_WARM_RATIO = 1.5       # measured 2.6x; fail well before it collapses to 1.0
MAX_POLY_RATIO = 1.35           # the control must stay ~flat (measured 0.96x)


def webapp_warmup_seconds():
    """Read the boot warm-up out of gui/web/index.html (the app the user plays)."""
    src = open(os.path.join(REPO, 'gui', 'web', 'index.html')).read()
    m = re.search(r'warmupFn\(ctx,\s*(.*?)\);', src)
    if not m:
        return None, "warmupFn(ctx, ...) call not found — index.html drifted"
    expr = m.group(1).strip()
    # accept (SR * N) | 0  /  (SR * N) >> k  /  SR * N
    mm = re.match(r'\(?\s*SR\s*\*\s*(\d+)\s*\)?\s*(?:\|\s*0|>>\s*(\d+))?\s*$', expr)
    if not mm:
        return None, "could not parse warm-up expression %r" % expr
    secs = float(mm.group(1))
    if mm.group(2):
        secs /= float(1 << int(mm.group(2)))
    return secs, expr


def peak(lib, bank, patch, warm_samples):
    c = lib.juno_gui_create(ctypes.c_float(SR), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), patch)
    if warm_samples:
        lib.juno_gui_warmup(c, warm_samples)
    lib.juno_gui_midi_note_on(c, 60, 100)
    n = 22050
    buf = (ctypes.c_float * (2 * n))()
    lib.juno_gui_render(c, buf, n)
    pk = max(abs(x) for x in buf)
    lib.juno_gui_destroy(c)
    return pk


def main():
    truth.require()
    fails = 0

    secs, expr = webapp_warmup_seconds()
    if secs is None:
        print("  webapp warm-up: *** %s ***" % expr); return 1
    ok = secs >= WARM_MIN_SECONDS
    fails += 0 if ok else 1
    print("  webapp boot warm-up = %.2f s  (expr %r, need >= %.1f s) : %s"
          % (secs, expr, WARM_MIN_SECONDS, "OK" if ok else "*** TOO SHORT ***"))

    import freshlib  # stale-artifact guard (ROADMAP P0.3): refuse a libjuno.so older than src
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_warmup.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_midi_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float),
                                    ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    bank = open(truth.BANK, 'rb').read()
    warm = int(WARM_MIN_SECONDS * SR)

    uc, uw = peak(lib, bank, UNISON_PATCH, 0), peak(lib, bank, UNISON_PATCH, warm)
    ratio = uc / uw if uw > 0 else float('inf')
    ok = ratio >= MIN_COLD_WARM_RATIO
    fails += 0 if ok else 1
    print("  factory %2d UNISON : cold %.3f -> warm %.3f  (ratio %.2fx, need >= %.2fx) : %s"
          % (UNISON_PATCH, uc, uw, ratio, MIN_COLD_WARM_RATIO,
             "OK" if ok else "*** DECORRELATION GONE ***"))

    pc, pw = peak(lib, bank, POLY_PATCH, 0), peak(lib, bank, POLY_PATCH, warm)
    pr = max(pc, pw) / min(pc, pw) if min(pc, pw) > 0 else float('inf')
    ok = pr <= MAX_POLY_RATIO
    fails += 0 if ok else 1
    print("  factory %2d POLY   : cold %.3f -> warm %.3f  (ratio %.2fx, need <= %.2fx) : %s"
          % (POLY_PATCH, pc, pw, pr, MAX_POLY_RATIO,
             "OK (control flat)" if ok else "*** CONTROL MOVED — effect is not unison-specific ***"))

    print("COLD/WARM UNISON: %s" % ("PASS" if fails == 0 else "FAIL"))
    return 1 if fails else 0


if __name__ == '__main__':
    sys.exit(main())
