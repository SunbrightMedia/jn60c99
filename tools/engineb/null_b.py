#!/usr/bin/env python3
"""null_b.py — THE ENGINE B NULL HARNESS. Nothing about engine B is trustworthy
before this file exists, and nothing about engine B is trustworthy that this file
cannot see.

WHAT IT DOES
    Renders the SAME scenario through the ORACLE (the sealed port in src/, built
    fresh) and through ENGINE B (engine_b/ substituted into that same tree),
    subtracts them in the SAMPLE DOMAIN, and gates two residuals:

        global   RMS(ref - cand) relative to RMS(ref)          <= -100 dB
        worst    the same measure over each 1024-sample block  <=  -80 dB
                 (each block normalised by its OWN level)

    Both gate. The metric functions are IMPORTED from tools/trackb/null_ab.py --
    they are already calibrated there: a 2-ULP/sample error lands at -129 dB and
    the old -90 dB gate therefore ignored errors up to ~200 ULP/sample. -100 dB
    is the engine B standard (docs/trackb/ACCURACY_STANDARD.md): every module is
    deterministic, so every module gets a sample-domain null, with no spectral or
    statistical fallback and no "analog" exemption.

    The block threshold is 20 dB looser than the global one, the same gap
    tools/trackb/null_ab.py uses (-90/-70), because one block has 1/30th the
    averaging. That gap is INHERITED, not re-measured here. It is a starting
    value and is worth exactly what --teeth proves about it.

THE TWO-PROCESS RULE
    This process builds and compares. It never loads a .so. Each side is
    rendered by a separate `--worker` subprocess that loads exactly one library
    and writes its streams to a pickle. Oracle and candidate therefore never
    share an address space, ever -- the rule that exists because a shared process
    is how an oracle and a candidate end up sharing a mistake.

    Both libraries are compiled FROM SOURCE by this run, with identical flags,
    into a temp dir. No repo libjuno.so is used, so there is no stale-artifact
    hole of the kind that produced two false greens on 2026-07-31.

--module: HOW A SINGLE MODULE IS VALIDATED BEFORE THE ENGINE EXISTS
    Engine B cannot be gated only when it is finished; by then a divergence has
    nowhere to be localised. So the unit under test is a HYBRID LIBRARY:

        sources = src/*.c                         (the port -- the oracle's code)
                  MINUS every src/<x>.c that engine_b/shim/<module>/<x>.c shadows
                  PLUS  engine_b/shim/<module>/*.c
                  PLUS  engine_b/*.c              (engine B proper)
                  PLUS  gui/juno_bridge.c         (the same juno_gui_* API both
                                                   sides, so the reference-driving
                                                   layer that caused every
                                                   historical harness failure does
                                                   not exist here)

    A shim file replaces ONE port translation unit and is free to compute its
    part with engine B code. Everything engine B has not written yet is not
    stubbed, mocked or faked: it is literally the port's own code, in the same
    process, carrying the same state. "The rest of engine B calls the oracle" is
    thus true by construction rather than by a bridge someone has to maintain.

    Consequences, which are the point:
      * `--module none` substitutes nothing, so the candidate IS the oracle and
        the residual must be EXACTLY 0. That is this harness's self-test and the
        proof it is not vacuous. It is run by default at the head of every run.
      * a module's residual is attributable: only one translation unit differs.
      * the state layout does not have to change for a module to be gated. Engine
        B's <1 KB/voice layout arrives when a module owns enough of the signal
        path to carry its own state; until then a shim may read and write the
        port's cells. The null does not care, and the null is what decides.
      * what this CANNOT see is a module that is correct only inside the port's
        surrounding code. That is why the acceptance point is `--module all`,
        and why B-vs-plugin (docs/trackb/THREE_WAY_GATE.md) -- not this file --
        is what retires a claim. This is the FAST proxy comparison. src/ is
        never the authority.

    Modules are declared by creating engine_b/shim/<name>/ . MODULES below lists
    them; `--module all` builds every shim directory at once.

IDLE-PREFIX SCENARIOS (docs/engineb/SCOPE.md item 2: "these do not exist")
    MEASURED (session brief): same patch, same note, varying ONLY the idle
    samples before the note-on -- 1, 48, 441, 4410, 44100 -- gives five different
    outputs, because DCO phases, the noise LFSR and the FX LFOs free-run and
    where they stand at note-on is part of the sound. An engine B that skips the
    STATE ADVANCE of a silent voice (rather than only its audio work) sounds
    right in every scenario that starts from a cold engine and wrong in a DAW.
    Those scenarios live in null_ab.IDLE_TAGS and are imported, not
    duplicated. They are on by default and --teeth asserts they are
    load-bearing.

USAGE
    null_b.py                       self-test + all scenarios, --module none
    null_b.py --module M4_vcf       hybrid: only that module is engine B's
    null_b.py --module all          acceptance shape: every shim at once
    null_b.py --quick               drop the 6.8 s scenario
    null_b.py --teeth               plant known errors and require the harness to
                                    CATCH them, through the real build path
    null_b.py --thresh -100 --block-thresh -80
"""
import sys, os, math, glob, pickle, shutil, tempfile, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import null_ab                      # metric functions ONLY -- imports no library
import truth

# The engine B standard. Both are overridable from the command line so a
# regression can be watched approaching a threshold rather than only after it
# crosses one.
THRESH_DB = -100.0
BLOCK_THRESH_DB = -80.0
SIG_FLOOR_DB = null_ab.SIG_FLOOR_DB          # non-vacuity: ref must make sound
SR = null_ab.SR

CFLAGS = ["-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing"]

# ---------------------------------------------------------------- scenarios
# The nine port-risk scenarios are reused verbatim from the Track B gate: they
# were not guessed, they were grown by the canary and observability probes
# (patch 32 is the only loud DCO-NOISE patch; patch 22 is the only factory patch
# that arms the DCO reset; every scenario releases its notes and renders a tail
# because a release-only error passed five of seven scenarios once already).
# The idle-prefix scenarios are also taken from there rather than duplicated
# here: the parallel scenario work added them to null_ab (tags in
# null_ab.IDLE_TAGS -- idle chorus/unison/noise at 1/48/441/4410/44100 samples,
# plus two allocate->release->idle->reallocate cases). One scenario set, one
# place to extend it. If that set ever loses its idle entries this harness fails
# loudly rather than quietly gating a cold-start-only surface.
BASE_SCEN = list(null_ab.SCEN)
IDLE_TAGS = getattr(null_ab, "IDLE_TAGS", set())
if not IDLE_TAGS:
    raise SystemExit("ABORT: tools/trackb/null_ab.py has no IDLE-PREFIX scenarios "
                     "(null_ab.IDLE_TAGS empty). Engine B cannot be gated without "
                     "them -- free-running state at note-on is audible (MEASURED).")


def scenarios(quick=False):
    s = list(BASE_SCEN)
    if quick:
        s = [x for x in s if x[2] != "long LFO+tail"]
    return s


# ---------------------------------------------------------------- build
def _copy_tree(dst):
    for d in ("src", "gui", "engine_b"):
        shutil.copytree(os.path.join(REPO, d), os.path.join(dst, d))
    return dst


def module_list():
    root = os.path.join(REPO, "engine_b", "shim")
    if not os.path.isdir(root):
        return []
    return sorted(d for d in os.listdir(root)
                  if os.path.isdir(os.path.join(root, d)))


MODULES = module_list()


def build(dst_so, modules=(), mutate=None, quiet=True):
    """Compile one library. `modules` is a list of engine_b/shim/<name> dirs to
    overlay onto src/ by filename; empty means the pure port (the oracle).

    Returns (list of shadowed src basenames, compile command).
    """
    tmp = tempfile.mkdtemp(prefix="engineb_")
    try:
        _copy_tree(tmp)
        shadowed = []
        for m in modules:
            mdir = os.path.join(REPO, "engine_b", "shim", m)
            if not os.path.isdir(mdir):
                raise SystemExit("no such module: engine_b/shim/%s" % m)
            for f in sorted(glob.glob(os.path.join(mdir, "*.c"))):
                base = os.path.basename(f)
                target = os.path.join(tmp, "src", base)
                if not os.path.exists(target):
                    raise SystemExit(
                        "shim %s/%s shadows nothing in src/ -- a shim file must "
                        "be named after the port translation unit it replaces, or "
                        "the build silently compiles BOTH." % (m, base))
                shutil.copyfile(f, target)      # overwrite the port's copy
                shadowed.append(base)
        if mutate:
            _plant(tmp, mutate)
        # engine_b/test_*.c are STANDALONE unit tests, each with its own main().
        # They are not the engine and must not be linked into the library under
        # test: two of them in one .so is a duplicate-main link error, and one of
        # them in the .so is a main() nobody wants in a shared library.
        srcs = sorted(glob.glob(os.path.join(tmp, "src", "*.c"))) + \
            [f for f in sorted(glob.glob(os.path.join(tmp, "engine_b", "*.c")))
             if not os.path.basename(f).startswith("test_")]
        cmd = ["cc"] + CFLAGS + [
            "-DENGINEB_MODULE=\"%s\"" % (",".join(modules) or "none"),
            "-I" + os.path.join(tmp, "src"),
            "-I" + os.path.join(tmp, "engine_b"),
            "-shared", "-fPIC", "-o", dst_so,
            os.path.join(tmp, "gui", "juno_bridge.c")] + srcs + ["-lm"]
        r = subprocess.run(cmd, capture_output=True)
        if r.returncode:
            sys.stderr.write(r.stderr.decode()[-4000:])
            raise SystemExit("BUILD FAILED (%s)" % (",".join(modules) or "oracle"))
        if not quiet:
            print("  built %s: %d src + %d engine_b TU, shadowed: %s"
                  % (os.path.basename(dst_so), len(srcs),
                     len(glob.glob(os.path.join(tmp, "engine_b", "*.c"))),
                     ", ".join(shadowed) or "(none)"))
        return shadowed, cmd
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def _plant(tmp, mutate):
    """--teeth only: plant a known error in the tree that is REALLY compiled.

    These are deliberately the same anchors tools/trackb/null_ab.py uses, so the
    two harnesses fail on the same planted bugs and a teeth regression in either
    is visible against the other.
    """
    if mutate == "onelsb":
        # The smallest error this harness should still SEE: one output sample
        # scaled by 1 + 2^-23 (~1 ULP), on every sample of every voice.
        p = os.path.join(tmp, "src", "voice_render.c"); s = open(p).read()
        a = "  *outL = JF(a1, 10672);"
        assert s.count(a) == 1
        s = s.replace(a, "  JF(a1, 10672) = JF(a1, 10672) * 1.00000011920929f;\n" + a, 1)
    elif mutate == "justover":
        # The same error, scaled to sit just OVER the gate: a relative error e
        # applied to the whole output lands at about 20*log10(e) dB rel, so
        # 3e-5 ~= -90 dB. It must FAIL while "onelsb" passes.
        p = os.path.join(tmp, "src", "voice_render.c"); s = open(p).read()
        a = "  *outL = JF(a1, 10672);"
        assert s.count(a) == 1
        s = s.replace(a, "  JF(a1, 10672) = JF(a1, 10672) * 1.00003f;\n" + a, 1)
    elif mutate == "tailquiet":
        p = os.path.join(tmp, "src", "voice_render.c"); s = open(p).read()
        a = "  *outL = JF(a1, 10672);"
        assert s.count(a) == 1
        s = s.replace(a, "  if (JF(a1, 560) == 0.0f) JF(a1, 10672) = "
                         "JF(a1, 10672) * 1.001f;\n" + a, 1)
    elif mutate == "dcopitch":
        p = os.path.join(tmp, "src", "juno_init.c"); s = open(p).read()
        assert s.count("v32 = 1000568814;") == 1
        s = s.replace("v32 = 1000568814;", "v32 = 1000568914;", 1)
    elif mutate == "idleskip":
        # THE LOCKSTEP MUTATION -- engine B's own largest risk, planted. It is
        # the verbatim patch tools/trackb/null_ab.py uses, on purpose: the two
        # harnesses must fail on the same planted bug, and lockstep is the one
        # error class the ACCURACY STANDARD calls out by name (skip a silent
        # voice's AUDIO work, never its STATE ADVANCE).
        #
        # The voice's state advance is skipped until the first note the engine
        # ever sees, so free-running DCO phase, the shared noise LFSR and the
        # per-voice smoothers stand at their power-on values at note-on instead
        # of where N idle samples would have put them. A scenario that renders
        # nothing before its first note-on is BIT-IDENTICAL under it BY
        # CONSTRUCTION -- which is why "caught by the idle-prefix scenarios and
        # by no cold one" is asserted below as a matrix, not hoped for.
        p = os.path.join(tmp, "src", "voice_render.c"); s = open(p).read()
        anchor = "  v2 = JF(a1, 320);\n"
        assert s.count(anchor) == 1
        s = s.replace(anchor,
                      "  if ( JI(base, 11900000) == 0 ) {\n"
                      "    if ( JF(a1, 1856) != 0.0f ) JI(base, 11900000) = 1;\n"
                      "    else { *outL = 0.0f; *outR = 0.0f; return 0; }\n"
                      "  }\n" + anchor, 1)
    else:
        raise SystemExit("unknown mutation %s" % mutate)
    open(p, "w").write(s)


# ---------------------------------------------------------------- worker
def worker(lib_path, out_path, quick):
    """Separate process: load ONE library, render every scenario, pickle it."""
    import array
    lib = null_ab.load(lib_path)
    bank = open(truth.BANK, "rb").read()
    ident = None
    try:
        import ctypes
        lib.engineb_build_id.restype = ctypes.c_char_p
        lib.engineb_modules.restype = ctypes.c_char_p
        ident = (lib.engineb_build_id().decode(), lib.engineb_modules().decode())
    except AttributeError:
        pass                      # engine_b/ not linked -- the caller checks
    out = {"ident": ident, "streams": {}}
    for patch, script, tag in scenarios(quick):
        out["streams"][tag] = array.array(
            'f', null_ab.render_script(lib, bank, SR, patch, script))
    with open(out_path, "wb") as f:
        pickle.dump(out, f, 2)


def render_side(lib_path, quick, tmpdir, tag):
    p = os.path.join(tmpdir, "%s.pkl" % tag)
    r = subprocess.run([sys.executable, os.path.abspath(__file__), "--worker",
                        lib_path, p, "1" if quick else "0"],
                       capture_output=True)
    if r.returncode:
        sys.stderr.write(r.stderr.decode()[-4000:])
        raise SystemExit("RENDER WORKER FAILED (%s)" % tag)
    with open(p, "rb") as f:
        return pickle.load(f)


# ---------------------------------------------------------------- compare
def judge(r, c):
    """(sig dBFS, global rel dB or None, block rel dB or None, ok).

    null_ab.rel_residual returns +999 dB on a LENGTH MISMATCH rather than a tiny
    residual -- a candidate that renders the wrong number of frames is a loud
    failure, never a quiet pass. Non-vacuity (ref RMS above the floor) is
    enforced by the caller, which counts a silent reference as a FAILED scenario,
    not a skipped one: a scenario that proves nothing must not look like a pass.
    """
    sig, rel = null_ab.rel_residual(r, c)
    if rel is not None and rel > 900:
        return sig, rel, None, False
    blk = None if rel is None else null_ab.block_residual(r, c, 10 ** (sig / 20.0))
    ok = (rel is None or rel <= THRESH_DB) and \
         (blk is None or blk <= BLOCK_THRESH_DB)
    return sig, rel, blk, ok


def compare(ref, cand, quick, label):
    """Print per-scenario dB (always -- a regression must be visible BEFORE it
    crosses the threshold) and return (fails, worst_global, caught tags)."""
    print("--- %s ---" % label)
    fails = 0; worst = None; caught = set()
    for patch, script, tag in scenarios(quick):
        r = ref["streams"][tag]; c = cand["streams"][tag]
        sig, rel, blk, ok = judge(r, c)
        if len(r) != len(c):
            print("  %-16s *** LENGTH MISMATCH %d vs %d -> FAIL ***"
                  % (tag, len(r), len(c)))
            fails += 1; caught.add(tag); continue
        if sig < SIG_FLOOR_DB:
            print("  %-16s VACUOUS (ref RMS %.1f dBFS < %.0f) -> scenario INVALID"
                  % (tag, sig, SIG_FLOOR_DB))
            fails += 1; caught.add(tag); continue
        if rel is not None:
            worst = rel if worst is None else max(worst, rel)
        if not ok:
            fails += 1; caught.add(tag)
        print("  %-16s sig %6.1f dBFS   residual %-14s worst block %-12s -> %s"
              % (tag, sig,
                 "EXACTLY 0" if rel is None else "%.1f dB rel" % rel,
                 "--" if blk is None else "%.1f dB rel" % blk,
                 "PASS" if ok else "FAIL"))
    print("  %s: %s (worst global %s)"
          % (label, "PASS" if fails == 0 else "FAIL (%d scenario(s))" % fails,
             "EXACTLY 0 everywhere" if worst is None else "%.1f dB rel" % worst))
    return fails, worst, caught


def build_and_render(modules, quick, mutate, tmp, tag, verbose):
    so = os.path.join(tmp, "%s.so" % tag)
    build(so, modules, mutate=mutate, quiet=not verbose)
    return render_side(so, quick, tmp, tag)


def run(modules, quick, mutate=None, label=None, verbose=True, ref=None):
    """Build both sides, render each in its own process, compare.

    `ref` lets a caller reuse an oracle render: the oracle does not depend on
    the module or the mutation, so re-rendering it per case would only cost
    time. It is still produced by the same code path, in its own process.
    """
    tmp = tempfile.mkdtemp(prefix="engineb_run_")
    try:
        if ref is None:
            ref = build_and_render((), quick, None, tmp, "ref", verbose)
        cnd = build_and_render(modules, quick, mutate, tmp, "cand", verbose)
        if cnd["ident"] is None:
            raise SystemExit("engine_b/ was not linked into the candidate -- a "
                             "passthrough build that dropped engine B would "
                             "score a perfect and meaningless 0.")
        if verbose:
            print("engine B build: %s   modules=%s"
                  % (cnd["ident"][0], cnd["ident"][1]))
        return compare(ref, cnd, quick,
                       label or ("engine B [%s]" % (",".join(modules) or "none")))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def oracle_render(quick):
    tmp = tempfile.mkdtemp(prefix="engineb_ref_")
    try:
        return build_and_render((), quick, None, tmp, "ref", False)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


# ---------------------------------------------------------------- teeth
def teeth(quick):
    """The harness is tested before it is used. Each planted error is built
    through the REAL engine B build path and must be caught in the recorded set
    of scenarios; the clean control must be EXACTLY 0."""
    print("=== ENGINE B NULL HARNESS TEETH (thresh %.0f / block %.0f dB) ==="
          % (THRESH_DB, BLOCK_THRESH_DB))
    bad = 0
    # (mutation, must the gate FAIL on it?). Two of these are CALIBRATION, not
    # bug-catching: "onelsb" must PASS and "justover" must FAIL, which brackets
    # the -100 dB threshold from both sides and proves it bites where it claims
    # to. A teeth battery of only catchable bugs measures nothing about where
    # the floor is.
    cases = [(None, False), ("onelsb", False), ("justover", True),
             ("tailquiet", True), ("dcopitch", True), ("idleskip", True)]
    for mut, want_fail in cases:
        fails, worst, caught = run((), quick, mutate=mut, ref=ref,
                                   label="planted: %s" % (mut or "CLEAN CONTROL"),
                                   verbose=False)
        got = fails > 0
        ok = (got == want_fail) and (mut is not None or worst is None)
        if mut in ("onelsb", "justover") and worst is None:
            print("    *** the planted error produced NO residual at all -- the "
                  "mutation did not take, so this case measured nothing ***")
            ok = False
        if mut == "idleskip":
            # CATCH MATRIX, DERIVED FROM THE SCRIPTS, not from tag names.
            # The planted skip latches OFF at the first note-on the engine ever
            # sees, so it can only be observable in a scenario that RENDERS
            # BEFORE ITS FIRST NOTE-ON. That set is computed here from the event
            # scripts, and the catch set must equal it exactly -- every prefixed
            # scenario catches it, no unprefixed one can.
            #
            # MEASURED 2026-08-02, and it corrects a partition by tag name: the
            # set is NOT null_ab.IDLE_TAGS. Two scenarios that predate the idle
            # work ("MONO retrigger", "UNISON pile-up") open with a render and DO
            # catch it, and the two "realloc" scenarios, though tagged idle, open
            # with a note-on and CANNOT. Prefix structure decides, not naming.
            want = {t for _, sc, t in scenarios(quick) if sc and sc[0][0] == 'render'}
            miss, extra = sorted(want - caught), sorted(caught - want)
            print("    CATCH MATRIX: %d/%d scenarios that render before their "
                  "first note-on" % (len(caught & want), len(want)))
            if miss or extra:
                print("    *** MATRIX MISMATCH: missed %s; unexpectedly caught "
                      "by unprefixed %s ***" % (miss or "none", extra or "none"))
                ok = False
        if not ok:
            bad += 1
        print("  -> %s   caught %d scenario(s)\n"
              % ("OK" if ok else "*** TEETH FAILURE ***", len(caught)))
    print("TEETH: %s" % ("PASS" if bad == 0 else
                         "FAIL -- the harness is blind in %d case(s); it must "
                         "not be used" % bad))
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if a and a[0] == "--worker":
        worker(a[1], a[2], a[3] == "1")
        return 0
    truth.require()
    global THRESH_DB, BLOCK_THRESH_DB
    if "--thresh" in a:
        THRESH_DB = float(a[a.index("--thresh") + 1])
    if "--block-thresh" in a:
        BLOCK_THRESH_DB = float(a[a.index("--block-thresh") + 1])
    quick = "--quick" in a
    if "--teeth" in a:
        return teeth(quick)

    mods = ()
    if "--module" in a:
        m = a[a.index("--module") + 1]
        mods = tuple(MODULES) if m == "all" else () if m == "none" else (m,)
    print("=== ENGINE B NULL: oracle (src/, built fresh) vs engine B ===")
    print("gates: global <= %.0f dB rel, worst-1024-block <= %.0f dB rel; "
          "non-vacuity: ref RMS >= %.0f dBFS" % (THRESH_DB, BLOCK_THRESH_DB,
                                                 SIG_FLOOR_DB))
    print("modules available: %s" % (", ".join(MODULES) or "(none written yet)"))

    # SELF-TEST FIRST, ALWAYS. Substituting nothing must null EXACTLY 0; if it
    # does not, the two sides differ for a reason that has nothing to do with
    # engine B and no engine B number from this run means anything.
    f0, w0, _ = run((), quick, label="SELF-TEST: no module substituted "
                                     "(must be EXACTLY 0)")
    if f0 or w0 is not None:
        print("\nVERDICT: HARNESS INVALID -- the passthrough build is not "
              "identical to the oracle. Fix that before reading any other "
              "number here.")
        return 2
    if not mods:
        print("\nVERDICT: PASS (self-test only -- no module substituted, so this "
              "run says nothing about engine B's DSP)")
        return 0
    fails, _, _ = run(mods, quick)
    print("\nVERDICT: %s" % ("PASS" if fails == 0 else "FAIL (%d case(s))" % fails))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
