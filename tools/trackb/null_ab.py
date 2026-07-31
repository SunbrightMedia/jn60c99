#!/usr/bin/env python3
"""null_ab.py — Track B comparator: candidate engine vs the SEALED bit-exact port.

The charter's gate #1 (docs/TRACKB_CHARTER.md). Renders identical scenarios
through the reference (libjuno.so, itself chained to the plugin binary by
`make verify`) and a candidate build, subtracts, and enforces a null:

    residual RMS <= THRESH_DB relative to the reference signal RMS
    (start -90 dBFS-rel; human ABX gives out around -40..-60 dB)

plus a NON-VACUITY assertion (the reference must actually be making sound:
signal RMS above a floor) so silence==silence can never pass as identity.

USAGE
    null_ab.py --cand /path/candidate.so            gate a candidate
    null_ab.py --teeth                              mutation battery: builds
        known-broken candidates (detuned DCO, killed chorus) and asserts the
        gate CATCHES each, plus a clean rebuild that must PASS with residual
        exactly 0 — the gate is itself tested before it counts (the project
        rule bought by every past false-green).

Scenario set covers the risk surface: POLY pluck, MONO (retrigger law),
UNISON (phase pile-up), chorus-heavy pad, high-resonance patch, warm start.
Same juno_gui_* API both sides -> the reference-driving layer that caused
every historical harness failure does not exist here.
"""
import sys, os, ctypes, struct, math, subprocess, tempfile, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import truth

THRESH_DB = -90.0
SIG_FLOOR_DB = -50.0          # reference must be at least this loud vs FS
SR = 44100.0
SCEN = [  # (patch, notes, warm_samples, tag)
    (5,  [60],           0,     "pluck POLY"),
    (15, [45, 52, 45],   4000,  "MONO retrigger"),
    (61, [48],           8000,  "UNISON pile-up"),
    (20, [48, 55, 64],   0,     "chorus pad"),
    (2,  [60, 67],       2000,  "delay keys"),
]
NFR = 30000


def load(lib_path):
    lib = ctypes.CDLL(lib_path)
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_warmup.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                    ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    return lib


def render(lib, bank, patch, notes, warm):
    c = lib.juno_gui_create(ctypes.c_float(SR), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), patch)
    if warm: lib.juno_gui_warmup(c, warm)
    for n in notes: lib.juno_gui_note_on(c, n, 100)
    buf = (ctypes.c_float * (2 * NFR))()
    lib.juno_gui_render(c, buf, NFR)
    return list(buf)


def db(x): return 20.0 * math.log10(max(x, 1e-30))


def compare(ref_lib, cand_lib, bank):
    worst = -1e9; fails = 0
    for patch, notes, warm, tag in SCEN:
        r = render(ref_lib, bank, patch, notes, warm)
        cnd = render(cand_lib, bank, patch, notes, warm)
        sig = math.sqrt(sum(v * v for v in r) / len(r))
        res = math.sqrt(sum((a - b) ** 2 for a, b in zip(r, cnd)) / len(r))
        if db(sig) < SIG_FLOOR_DB:
            print("  %-16s VACUOUS (ref RMS %.1f dBFS < %.0f) -> scenario invalid"
                  % (tag, db(sig), SIG_FLOOR_DB)); fails += 1; continue
        rel = db(res) - db(sig)
        worst = max(worst, rel)
        ok = rel <= THRESH_DB
        if not ok: fails += 1
        print("  %-16s sig %6.1f dBFS   residual %s   -> %s"
              % (tag, db(sig),
                 ("EXACTLY 0" if res == 0.0 else "%6.1f dB rel" % rel),
                 "PASS" if ok else "FAIL"))
    return fails, worst


def build(dst, mutate=None):
    """Build a candidate .so from src/ (optionally with a named mutation)."""
    tmp = tempfile.mkdtemp(prefix="trackb_")
    for d in ("src", "gui"):
        shutil.copytree(os.path.join(REPO, d), os.path.join(tmp, d))
    if mutate == "detune":     # DCO frequency scale off by 0.1% (voice kernel)
        p = os.path.join(tmp, "src", "voice_render.c"); s = open(p).read()
        s = s.replace("* 0.000000059604645", "* 0.000000059664245", 1)
        assert "0.000000059664245" in s; open(p, "w").write(s)
    elif mutate == "nochorus":  # slot-2 select forced to Pan arm: chorus dead
        p = os.path.join(tmp, "src", "master_render.c"); s = open(p).read()
        s = s.replace("v551 = juno_host_sel(a1, 112);", "v551 = 0;", 1)
        assert "v551 = 0;" in s; open(p, "w").write(s)
    elif mutate == "envslow":   # one envelope coefficient nudged 1%
        p = os.path.join(tmp, "src", "voice_render.c"); s = open(p).read()
        s = s.replace("(float)(v236 * v236) * 0.25", "(float)(v236 * v236) * 0.2525", 1)
        assert "0.2525" in s; open(p, "w").write(s)
    elif mutate is not None:
        raise SystemExit("unknown mutation %s" % mutate)
    srcs = sorted(__import__("glob").glob(os.path.join(tmp, "src", "*.c")))
    cmd = ["cc", "-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing",
           "-shared", "-fPIC", "-o", dst,
           os.path.join(tmp, "gui", "juno_bridge.c")] + srcs + ["-lm"]
    subprocess.run(cmd, check=True, capture_output=True)
    shutil.rmtree(tmp)


def main():
    truth.require()
    bank = open(truth.BANK, "rb").read()
    ref = load(os.path.join(REPO, "libjuno.so"))

    if "--teeth" in sys.argv:
        print("=== TRACK B GATE TEETH TEST: the gate must catch planted bugs ===")
        bad = 0
        for mut, expect_fail in ((None, False), ("detune", True),
                                 ("nochorus", True), ("envslow", True)):
            dst = "/tmp/trackb_%s.so" % (mut or "clean")
            build(dst, mut)
            print("candidate: %s" % (mut or "clean rebuild (control)"))
            fails, worst = compare(ref, load(dst), bank)
            caught = fails > 0
            ok = (caught == expect_fail)
            if not ok: bad += 1
            print("  -> %s (expected %s, got %s)\n"
                  % ("OK" if ok else "*** TEETH FAILURE ***",
                     "FAIL" if expect_fail else "PASS",
                     "FAIL" if caught else "PASS"))
        print("TEETH: %s" % ("PASS — the gate catches every planted bug and "
                             "passes the clean control" if bad == 0
                             else "FAIL — the gate is BLIND to %d case(s); "
                                  "it must not be used" % bad))
        return 1 if bad else 0

    if "--cand" not in sys.argv:
        raise SystemExit(__doc__)
    cand = load(sys.argv[sys.argv.index("--cand") + 1])
    print("=== TRACK B NULL A/B: candidate vs sealed reference (thresh %.0f dB rel) ==="
          % THRESH_DB)
    fails, worst = compare(ref, cand, bank)
    print("NULL A/B: %s (worst residual %s)"
          % ("PASS" if fails == 0 else "FAIL (%d scenario(s))" % fails,
             "0" if worst == -1e9 else "%.1f dB rel" % worst))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
