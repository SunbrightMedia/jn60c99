#!/usr/bin/env python3
"""patch_roundtrip.py — GATE THE COMPACT PRESET FORMAT AT THE OUTPUT, not at a
state hash.

WHY THIS EXISTS. docs/preset/COMPACT_FORMAT.md derives its 118-byte set by
flipping record bytes and hashing a probe set of AUDIO CELLS. That method is only
as complete as the probe, and MEASURED (2026-08-02) it was not complete: the
arpeggiator writes no audio cell without a transport clock, so ARPEGGIO SW, TYPE
and STEP were invisible to the scan and are not in the 118 bytes. Seven of the 64
factory patches -- 1, 9, 17, 25, 33, 41, 49, the arp patches -- therefore do NOT
reproduce, by between -3.3 dB and +2.6 dB relative. That is not a rounding
question; it is a different sound.

So this gate asks the question at the only place it cannot be dodged: RENDER the
original record and RENDER the reconstruction, and require the samples to be
IDENTICAL. Bit-exact, not close.

METHOD
    for each patch:
        take patch 0's whole 20,223-byte record as the template
        copy in only the compact bytes of patch p
        render both banks through the oracle and compare sample by sample

The template is the same one firmware would bake in, so this measures exactly
what a device storing 127 bytes per patch would play.

It also runs the NEGATIVE control that the 118-byte set fails, so the gate is
demonstrated to have teeth on the very defect it was written for rather than
being trusted.

    python3 tools/engineb/patch_roundtrip.py            # gate engine B's set
    python3 tools/engineb/patch_roundtrip.py --teeth    # + the 118-byte control
"""
import os, sys, math, ctypes, subprocess, re

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import truth

REC = 20223
HDR = 23
BLOB = 16
NPATCH = 64
SR = 48000.0
NFRAMES = 8000


def engine_b_offsets():
    """Read the offset table out of engine_b/eb_patch.c, so this gate tests the
    set the ENGINE actually uses and cannot drift away from it."""
    src = open(os.path.join(REPO, "engine_b", "eb_patch.c")).read()
    m = re.search(r"eb_patch_offsets\[EB_PATCH_BYTES\]\s*=\s*\{(.*?)\};", src, re.S)
    if not m:
        raise SystemExit("cannot find eb_patch_offsets in engine_b/eb_patch.c")
    return sorted(int(x) for x in re.findall(r"\d+", m.group(1)))


def doc_offsets():
    import json
    return sorted(json.load(open(os.path.join(REPO, "docs", "preset",
                                              "compact_bytes.json"))))


def load_lib():
    so = os.path.join(REPO, "libjuno.so")
    subprocess.run(["make", "-s", "libjuno.so"], cwd=REPO, check=True)
    lib = ctypes.CDLL(so)
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                    ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    return lib


def render(lib, bank, patch, n=NFRAMES):
    c = lib.juno_gui_create(SR, 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), patch)
    lib.juno_gui_note_on(c, 60, 100)
    buf = (ctypes.c_float * (2 * n))()
    lib.juno_gui_render(c, buf, n)
    lib.juno_gui_destroy(c)
    return list(buf)


def reconstruct(bank, patch, offsets):
    b = bytearray(bank)
    src = HDR + REC * patch
    b[src:src + REC] = bank[HDR:HDR + REC]          # patch 0 as the template
    for o in offsets:
        b[src + BLOB + o] = bank[src + BLOB + o]
    return bytes(b)


def rms(x):
    return math.sqrt(sum(v * v for v in x) / len(x)) if x else 0.0


def run(lib, bank, offsets, label):
    bad = []
    for p in range(NPATCH):
        a = render(lib, bank, p)
        b = render(lib, reconstruct(bank, p, offsets), p)
        d = [x - y for x, y in zip(a, b)]
        rd, ra = rms(d), rms(a)
        if rd != 0.0:
            bad.append((p, 20 * math.log10(rd / ra) if ra else float("inf")))
    print("%-34s %d bytes/patch  ->  %d/%d patches BIT-EXACT"
          % (label, len(offsets), NPATCH - len(bad), NPATCH))
    for p, db in bad:
        print("    patch %2d  residual %+.1f dB rel" % (p, db))
    return bad


def main():
    truth.require()
    lib = load_lib()
    bank = open(truth.BANK, "rb").read()
    print("=== COMPACT PRESET FORMAT, gated at the OUTPUT ===")
    print("48 kHz, note 60 vel 100, %d frames, patch 0's record as the template\n"
          % NFRAMES)

    eb = engine_b_offsets()
    bad = run(lib, bank, eb, "engine B (engine_b/eb_patch.c)")

    if "--teeth" in sys.argv:
        print()
        doc = doc_offsets()
        ctl = run(lib, bank, doc, "CONTROL: docs 118-byte set")
        # The control must FAIL, or this gate proves nothing about its own
        # sensitivity: it would pass any byte set that happened to be handed to it.
        if not ctl:
            print("*** TEETH FAILURE: the 118-byte set passed. This gate cannot "
                  "see the defect it was written for. ***")
            return 2
        print("    teeth OK: the documented set fails on %d patch(es), so this "
              "gate is sensitive to a dropped parameter." % len(ctl))
        print("    added by engine B: %s" % sorted(set(eb) - set(doc)))

    print("\nVERDICT: %s" % ("PASS" if not bad else "FAIL (%d patch(es))" % len(bad)))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
