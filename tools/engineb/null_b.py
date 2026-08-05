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
# THE RENDER RATE. Until 2026-08-03 this was hardwired to null_ab.SR (44,100)
# and there was NO WAY to run this gate at any other rate -- so no -100 dB null
# had ever run at 48,000 Hz, which is the rate the ESP32-S3 build ships at. The
# fast-pitch -123.6 dB and the EB_DCO_RECIP -121.1 dB results were therefore
# 44.1k-only results being quoted as if they were the shipping configuration's.
# That was hole H1 in docs/engineb/DOUBT_AUDIT.md. `--rate 48000` closes it.
#
# The rate is carried into the render WORKER as an explicit argv element rather
# than an environment variable: the worker is a separate process, and a rate
# that silently defaulted back to 44,100 on one side of the comparison would
# produce two streams of different lengths and a +999 dB residual -- loud, but
# for the wrong reason. Both sides are given the same number by construction.
SR = null_ab.SR

CFLAGS = ["-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing"]
# EB_VERIFY_GEN: build the shims so the coefficient generation counter is NOT
# trusted -- every module runs its full memcmp anyway and aborts if the counter
# ever claimed "clean" while the cells had changed. Set JUNO_EB_VERIFY_GEN=1 to
# turn it on for a run. It is how "no other writer exists" is proven by
# execution instead of by reading the call graph.
if os.environ.get("JUNO_EB_VERIFY_GEN"):
    CFLAGS = CFLAGS + ["-DEB_VERIFY_GEN"]
# EB_PITCH_FAST: build engine B's pitch with the v7 double-float path (the S3
# build). Default OFF = bit-exact double. JUNO_EB_PITCH_FAST=1 turns it on so
# the -100 dB gate can be run against the REAL integrated file, not a probe
# copy. MEASURED 2026-08-03: worst global -123.6 dB over all 30 scenarios.
if os.environ.get("JUNO_EB_PITCH_FAST"):
    # The value is a LADDER LEVEL, not a boolean (1 = v7, 2 = v8, 3 = v9 --
    # see the table in eb_pitch.c). "1" keeps the old boolean meaning.
    CFLAGS = CFLAGS + ["-DEB_PITCH_FAST=%d"
                       % int(os.environ["JUNO_EB_PITCH_FAST"])]
# EB_DCO_RECIP: replace the pulse phase's division with a multiply by a
# reciprocal. Added as an env hook 2026-08-03: its -121.1 dB result had been
# measured by hand-editing the header, so the gate that certified it was not
# reproducible by anyone reading this file. It is now driven the same way the
# pitch fast path is, and the same rule applies -- the result is only valid at
# the rate it was rendered at.
if os.environ.get("JUNO_EB_DCO_RECIP"):
    CFLAGS = CFLAGS + ["-DEB_DCO_RECIP=1"]
# EB_PITCH_CR: control-rate pitch, anchor every N samples with linear
# extrapolation between (P8 candidate C1, docs/engineb/P8_PLAN.md). Needs the
# fast path for its anchors; N=1 must reproduce the plain fast build exactly.
if os.environ.get("JUNO_EB_PITCH_CR"):
    CFLAGS = CFLAGS + ["-DEB_PITCH_CR=%d"
                       % int(os.environ["JUNO_EB_PITCH_CR"])]

# ------------------------------------------------------------- THE S3 FORK
# JUNO_EB_FORK selects the fork's numeric build (docs/engineb/
# F3_S3_FORK_DESIGN.md). Values:
#     off      : the trunk, unchanged (default)
#     flagonly : EB_FORK_S3 defined but BOTH evaluators forced OFF. This build
#                MUST null EXACTLY 0 against the trunk, and that is the point:
#                it proves the flag surface itself introduces no change, so any
#                residual in the builds below is attributable to the evaluator
#                and to nothing else. Without it, "the fork differs by X" would
#                be a claim about the whole flag, not about the substitution.
#     pitch    : + fork pitch only
#     exp      : + fork exp only
#     both     : the shipping fork numerics
_FORK = os.environ.get("JUNO_EB_FORK")
if _FORK:
    _map = {"flagonly": ["-DEB_PITCH_FORK=0", "-DEB_EXP_FORK=0"],
            "pitch":    ["-DEB_PITCH_FORK=1", "-DEB_EXP_FORK=0"],
            "exp":      ["-DEB_PITCH_FORK=0", "-DEB_EXP_FORK=1"],
            "both":     ["-DEB_PITCH_FORK=1", "-DEB_EXP_FORK=1"]}
    if _FORK not in _map:
        raise SystemExit("JUNO_EB_FORK must be one of %s" % sorted(_map))
    # -U first: eb_fork_config.h defines these under EB_FORK_S3, and a
    # command-line -D of a macro the header also defines is a redefinition
    # error, not an override. The header's #ifdef guard is the one place the
    # constants belong; these switches select AMONG them.
    CFLAGS = CFLAGS + ["-DEB_FORK_S3"] + _map[_FORK]

# JUNO_EB_LFO_SHARED=1: ONE LFO for the whole engine (the fork's global-LFO
# lever). Independent of JUNO_EB_FORK on purpose, so it can be nulled against
# the pure trunk: if the shared build is EXACTLY 0, the per-voice LFOs are
# redundant computation and the removal is proven, not argued.
if os.environ.get("JUNO_EB_LFO_SHARED"):
    CFLAGS = CFLAGS + ["-DEB_LFO_SHARED=1"]

# JUNO_EB_VCF_RES_CR=N: C2, control-rate resonance -- evaluate eb_vcf_res's
# pure tail every Nth sample and reuse the cache between. N=1 is the trunk and
# must null EXACTLY 0 (the transformation must be identity at N=1, or the
# gate at N>1 is measuring two changes at once).
if os.environ.get("JUNO_EB_VCF_RES_CR"):
    CFLAGS = CFLAGS + ["-DEB_VCF_RES_CR=%d"
                       % int(os.environ["JUNO_EB_VCF_RES_CR"])]

# JUNO_EB_VCF_GRANGE=1: write-only instrumentation that reports the RANGE of
# the VCF's G over the whole scenario set, so the half-OS cutoff guard's fire
# rate is measured rather than assumed. It changes no arithmetic.
if os.environ.get("JUNO_EB_VCF_GRANGE"):
    CFLAGS = CFLAGS + ["-DEB_VCF_GRANGE=1"]

# JUNO_EB_HALF_OS=1: half-oversample the DCO path (F5 design, O8 build). The
# residual is NOT expected to be EXACTLY 0 and NOT expected to clear -100 dB:
# the fork standard for this lever is a BAND-LIMITED null at -80/-60 through
# an 18 kHz low-pass, plus a group-delay alignment, because the 2x decimator
# is 1.87 output samples longer than the port's and a pure delay is not a
# defect. Use tools/engineb/halfos_gate.py, which applies both; running plain
# null_b here reports a number that is real but is not the gate.
if os.environ.get("JUNO_EB_HALF_OS"):
    CFLAGS = CFLAGS + ["-DEB_FORK_S3", "-DEB_HALF_OS=1"]

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

# ---- ARM-COVERAGE SCENARIOS (added 2026-08-04, task 1b-1) ------------------
# MEASURED, and it is why these exist: the thirty inherited scenarios drive the
# master's two dispatch switches through only HALF their arms.
#
#   DELAY TYPE  (v39,  master_render.c:887)  reached 0, 1, 5   -- NOT 2, 3, 4
#   EFFECT TYPE (v551, master_render.c:2378) reached 2, 3, 5   -- NOT 0, 1, 4
#
# Every unreached arm is a different algorithm, hundreds of lines each, and a
# module written for one of them could not be gated at all: the null would be
# comparing two code paths neither of which runs. That is the standing warning
# in docs/trackb/PLAN.md -- NO MODULE MAY BE REWRITTEN BEHIND A BLIND GATE --
# arriving in the master chain.
#
# The patches below come from the REAL factory bank (measured by recalling all
# 64 and reading JUNO_PROG_DLY / JUNO_PROG_EFX), so these are the plugin's own
# configurations and not synthetic parameter edits:
#   patch 11  DELAY 2, EFFECT 3   arp off
#   patch 19  DELAY 3, EFFECT 3   arp off
#   patch  9  DELAY 1, EFFECT 1   arp ON -- and it is the ONLY patch in the
#             whole bank with EFFECT TYPE 1, so an arp scenario is the only
#             route to that arm. Both sides run the port's own arpeggiator, so
#             the comparison stays deterministic.
#
# STILL UNREACHED, and honestly so: DELAY TYPE 4 and EFFECT TYPE 0 and 4 appear
# in NO factory patch. EFFECT TYPE 4 (FLANGER) is additionally documented as
# engine-unreachable under recall (CLAUDE.md: recall leaves every effect
# object's mode at 0 and never calls the activation). Those arms need a
# synthetic-recall gate of the etmode_ab.py kind, not a scenario, and no module
# may be written for them until one exists.
# ---- SYNTHETIC-ARM SCENARIOS (task 1b-3) ---------------------------------
# DELAY TYPE 4 and EFFECT TYPE 0 appear in NO factory patch, so no scenario
# built from the bank can reach those dispatch arms and no module written for
# them could be gated. The bank is DOCTORED instead: the record's own nibble
# pair for that parameter is overwritten, exactly as tools/verify/etmode_ab.py
# already does to reach the unreachable EFFECT modes.
#
# This is the instrument's OWN recall path driven with a value a factory patch
# does not happen to carry -- not a synthetic engine state. A user preset can
# select these arms, so the trunk (which is the full instrument) needs them.
HDR_REC, STRIDE_REC = 23, 20223
ET_REC_OFF, DT_REC_OFF = 634, 650      # EFFECT TYPE / DELAY TYPE nibble pairs

DOCTOR = {
    "DELAY type 4  (synthetic)":  (DT_REC_OFF, 4),
    "EFFECT type 0 (synthetic)":  (ET_REC_OFF, 0),
    # EFFECT TYPE 4 (FLANGER) shares eb_chorus with types 2 and 3, and only 2
    # and 3 were ever driven -- so the module's mode-4 arm was carried by a
    # gate that could not reach it. tools/engineb/arm_coverage.py named it as
    # the last genuinely uncovered arm and this closes it.
    "EFFECT type 4 (synthetic)":  (ET_REC_OFF, 4),
}


def doctor_bank(bank, patch, rec_off, value):
    b = bytearray(bank)
    off = HDR_REC + patch * STRIDE_REC + rec_off
    b[off] = (value >> 4) & 0xF
    b[off + 1] = value & 0xF
    return bytes(b)


BASE_SCEN += [
    (2, [('render', 2000), ('on', 52, 100), ('on', 59, 100),
         ('render', 26000), ('off', 52), ('off', 59), ('render', 12000)],
     'DELAY type 4  (synthetic)'),
    (2, [('render', 2000), ('on', 45, 100), ('on', 57, 100),
         ('render', 26000), ('off', 45), ('off', 57), ('render', 12000)],
     'EFFECT type 0 (synthetic)'),
    (2, [('render', 2000), ('on', 48, 100), ('on', 55, 100),
         ('render', 26000), ('off', 48), ('off', 55), ('render', 12000)],
     'EFFECT type 4 (synthetic)'),
]

BASE_SCEN += [
    (11, [('render', 2000), ('on', 50, 100), ('on', 57, 100),
          ('render', 26000), ('off', 50), ('off', 57), ('render', 12000)],
     'DELAY type 2'),
    (19, [('render', 2000), ('on', 43, 100), ('on', 55, 100),
          ('render', 26000), ('off', 43), ('off', 55), ('render', 12000)],
     'DELAY type 3'),
    (9,  [('render', 2000), ('on', 48, 100), ('on', 52, 100),
          ('render', 30000), ('off', 48), ('off', 52), ('render', 12000)],
     'EFFECT type 1 (arp)'),
]
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


# The GENERATED composite (tools/engineb/merge_shims.py). It holds every
# module's shim in one set of files, which is the only way a whole-engine run
# can exist: shims are applied by file name, and six modules name the same port
# translation unit, so asking for them together is a collision by construction.
COMPOSITE = "engine_all"


def module_list(include_composite=False):
    """The individually gateable modules. The composite is EXCLUDED by default
    -- it collides with every module it is built from, and including it in a
    list meant for one-at-a-time runs is how `all` came to mean 'two of ten'."""
    root = os.path.join(REPO, "engine_b", "shim")
    if not os.path.isdir(root):
        return []
    return sorted(d for d in os.listdir(root)
                  if os.path.isdir(os.path.join(root, d))
                  and (include_composite or d != COMPOSITE))


MODULES = module_list()


def resolve_modules(mods):
    """`all` means THE COMPOSITE, not 'every shim directory at once'.

    It used to mean the latter, and because shims are applied by file name that
    silently linked whichever module sorted last -- docs/engineb/
    HARNESS_AUDIT.md F1. It now resolves to the one generated composite, which
    contains every module's code in files that do not collide.
    """
    if list(mods) == ["all"]:
        d = os.path.join(REPO, "engine_b", "shim", COMPOSITE)
        if not os.path.isdir(d):
            raise SystemExit(
                "'--module all' needs the generated composite %s, which does "
                "not exist.\n  WHAT TO DO: run tools/engineb/merge_shims.py "
                "(make engineb runs it for you)." % COMPOSITE)
        return [COMPOSITE]
    return list(mods)


def build(dst_so, modules=(), mutate=None, quiet=True):
    """Compile one library. `modules` is a list of engine_b/shim/<name> dirs to
    overlay onto src/ by filename; empty means the pure port (the oracle).

    Returns (list of shadowed src basenames, compile command).
    """
    tmp = tempfile.mkdtemp(prefix="engineb_")
    try:
        _copy_tree(tmp)
        shadowed = []
        # WHO WROTE EACH SHADOWED FILE. Two shims that name the same port
        # translation unit CANNOT both be in one build: the second copyfile
        # silently destroys the first, and the build then reports every module
        # as present while linking only the last one's code.
        #
        # THIS IS NOT HYPOTHETICAL. It was live until 2026-08-02 and it made
        # `--module all` a lie: six modules ship voice_render.c (dco, env,
        # pwm_cv, vca_hpf, vcf_cv, vcf_ladder) and three ship master_render.c
        # (chorus, delay, reverb), so an alphabetical `all` build linked
        # vcf_ladder's voice path and reverb's master path and nothing else,
        # while ENGINEB_MODULE still named all ten. MEASURED: an execution
        # counter planted in eb_dco_step counted 0 calls in an `all` build and
        # 60,989,440 in a `--module dco` build.
        #
        # The per-module gates were never affected -- one module shadows one
        # file. Only composite builds were. The guard below makes the collision
        # a hard stop instead of a silent overwrite.
        owner = {}
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
                if base in owner:
                    raise SystemExit(
                        "SHIM COLLISION: modules '%s' and '%s' both provide "
                        "src/%s.\n"
                        "  Overwriting would link only '%s' while still "
                        "reporting both, which is a green gate that is wrong.\n"
                        "  WHAT TO DO: these modules cannot be composed by "
                        "file shadowing. Either run them one at a time\n"
                        "  (--module %s), or merge them into ONE shim that "
                        "calls both engine B modules and declare that\n"
                        "  merged shim as a single module directory."
                        % (owner[base], m, base, m, owner[base]))
                owner[base] = m
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


# THE PER-MODULE TEETH ANCHORS.  module -> (shim file, unique marker, statement)
# The statement is inserted immediately AFTER the marker and scales exactly the
# values that module hands to the rest of the engine. It carries one "%s", the
# relative factor.
#
# Each marker is asserted to occur EXACTLY ONCE at plant time. If a shim is
# edited so a marker moves, the teeth case stops silently and says so.
_OUT_ANCHOR = {
    # THE MASTER CHAIN's first two blocks (task 1b-1). Each is perturbed where
    # its own result enters the port's remaining code: master_in at the two
    # channel signals it hands the routing switch, master_out at the final
    # stereo pair.
    "master_in": ("master_render.c",
                  "    v38 = _o38;",
                  "    v36 *= %s; v38 *= %s;"),
    "master_out": ("master_render.c",
                   "      EBMO_L = _oL; EBMO_R = _oR;",
                   "      EBMO_L *= %s; EBMO_R *= %s;"),
    # A DELAY DISPATCH ARM (task 1b-1). Perturbed at the two channel signals it
    # returns. NOTE it can only be caught by the scenarios that SELECT this arm
    # -- DELAY types 2 and 3 -- which is exactly why those scenarios had to
    # exist before the module was written.
    "delay_t23": ("master_render.c",
                  "      eb_dly23_tick(&st23, &EBD23C, v36, v38, v5, "
                  "&v176, &v177, &_c56, &_c58);",
                  "      v176 *= %s; v177 *= %s;"),
    # THE OTHER DELAY ARM. Same note as delay_t23: only the scenarios that
    # SELECT DELAY TYPE 5 can catch it.
    "delay_t5": ("master_render.c",
                 "                         &v176, &v177, &_c56, &_c58);",
                 "            v176 *= %s; v177 *= %s;"),
    # The DELAY TYPE 1 algorithm. Its v176/v177 ARE live -- type 1 does not
    # reach the shared core (:1050 is an `else`).
    "delay_t1": ("master_render.c",
                 "      eb_dly1_tick(&st1, &EBD1C, v36, v38, v5, &v176, &v177, &_c56, &_c58);",
                 "      v176 *= %s; v177 *= %s;"),
    # THE TWO REACHABLE EFFECT-TYPE ARMS. Perturbed at v593, which is the
    # value the arm hands the next sample through cell 84704 -- the effect
    # stage feeds the master input stage, so its error appears one sample on.
    # Only the scenarios selecting that EFFECT TYPE can catch either.
    "fx_e1": ("master_render.c",
              "        eb_fx_e1_tick(&stf, &EBC_, *(float *)(a1 + 84624), "
              "(float)v56, v58,\n"
              "                      &_o56, &_o58, &_o593);",
              "        _o593 *= %s;"),
    "fx_e5": ("master_render.c",
              "        eb_fx_e5_tick(&stf, &EBC_, *(float *)(a1 + 84624), "
              "(float)v56, v58,\n"
              "                      &_o56, &_o58, &_o593);",
              "        _o593 *= %s;"),
    # THE WHOLE ENGINE: voices AND master, engine B's own state throughout.
    # This is the 1b-2 standalone gate's anchor -- the point where engine B's
    # finished stereo sample leaves the driver.
    "standalone": ("juno_driver.c",
                   "    rc = eb_master_render(&MS, &MC, &RG, vbuf, outL, outR);",
                   "    *outL *= %s; *outR *= %s;"),
    # THE WHOLE VOICE CHAIN, at the point its samples enter the port's master.
    # This module is the 1b-0 voice-level gate (docs/engineb/PHASE1_ORDERS.md):
    # engine B's own render function driving its own state, with the master
    # still the port's.
    "voices": ("juno_driver.c",
               "        vbuf[v] = ebv[v];",
               "        vbuf[v] *= %s;"),
    # Four sub-samples per audio sample, all four scaled together.
    # The marker moved on 2026-08-02 when the DCO went from four eb_dco_step
    # calls to one eb_dco_step4. The uniqueness assert caught it and refused to
    # plant, which is the behaviour this anchor scheme exists for: a teeth case
    # that silently plants nothing is worse than no teeth case.
    "dco": ("voice_render.c",
            "      JF(a1, 5328) = _o[3];",
            "      JF(a1,4944)*=%s; JF(a1,5072)*=%s; "
            "JF(a1,5200)*=%s; JF(a1,5328)*=%s;"),
    "env": ("voice_render.c",
            "      JF(a1, 2752 + off) = eb_env_tick(&es, &EBC[voice][ei], gin);",
            "      JF(a1, 2752 + off) *= %s;"),
    "pwm_cv": ("voice_render.c",
               "    JF(a1, 3776) = pitch_sum;",
               "    JF(a1, 3776) *= %s;"),
    "vcf_cv": ("voice_render.c",
               "    JF(a1, 6848) = eb6848;",
               "    v227 *= %s;"),
    # ANCHOR REFRESHED 2026-08-03. It had been stale since commit ed0fd50
    # ("standalone engine step 4"), which changed this call's state argument
    # from `&ebs` to `&EBF[voice]` and split it over two lines. The anchor still
    # named the old one-line form, matched 0 times, and the uniqueness guard
    # hard-stopped the teeth battery here -- which is the guard working, but it
    # also means THE vcf_ladder TEETH CASES HAD NOT RUN SINCE THAT COMMIT.
    # vcf_ladder sorts LAST, so exactly its own two cases were lost and no
    # earlier case was affected: 32 of the 34 ran. Found by running the battery
    # at 48 kHz. Nothing was wrong with the module; the harness had gone blind
    # to it, which is this project's most repeated failure mode.
    "vcf_ladder": ("voice_render.c",
                   "      JF(a1, 9040) = eb_vcf_tick(&EBF[voice], &ebc,\n"
                   "                                 JF(a1, 6544), v241,"
                   " JF(a1, 7536));",
                   "      JF(a1, 9040) *= %s;"),
    "notecv": ("voice_render.c",
               "    JF(base, 84432) = eb_notecv_tick(&ebns, &EBTC[voice]);",
               "    JF(base, 84432) *= %s;"),
    "dcoprep": ("voice_render.c",
                "    JF(a1, 5456) = ebp5456;",
                "    _s4784 *= %s;"),
    "vcf_res": ("voice_render.c",
                "    JF(a1, 7520) = ebrs.s7520;",
                "    v241 *= %s;"),
    "noisemix": ("voice_render.c",
                 "    JF(a1, 6544) = eb_noisemix_tick(&EBXC[voice], JF(a1, 4320), JF(a1, 3536));",
                 "    JF(a1, 6544) *= %s;"),
    "glide": ("voice_render.c",
              "      JF(a1, 752) = eb752;",
              "      JF(a1, 752) *= %s;"),
    "lfo": ("voice_render.c",
            "    JF(a1, 1808) = eb1808;",
            "    JF(a1, 1792) *= %s;"),
    "vca_hpf": ("voice_render.c",
                "                                JF(a1, 6848), JF(a1, 560));",
                "    JF(a1, 10672) *= %s;"),
    "chorus": ("master_render.c",
               "      memcpy(&v593, &_ebR, 4);",
               "      { float _f = %s; _ebL *= _f; _ebR *= _f;\n"
               "        memcpy((unsigned char *)a1 + 84672, &_ebL, 4);\n"
               "        memcpy((unsigned char *)a1 + 91088, &_ebL, 4);\n"
               "        memcpy((unsigned char *)a1 + 91104, &_ebR, 4);\n"
               "        memcpy(&v593, &_ebR, 4); }"),
    "delay": ("master_render.c",
              "        *(float *)(a1 + 102336) = ebR;",
              "        *(float *)(a1 + 102320) *= %s;\n"
              "        *(float *)(a1 + 102336) *= %s;"),
    "cvgate": ("voice_render.c",
               "  v34 = v33;",
               "  v34 *= %s;"),
    "pitch": ("voice_render.c",
              "  JF(a1, 4416) = v391;",
              "  v391 *= %s; JF(a1, 4416) = v391;"),
    "noise_svf": ("voice_render.c",
                  "    JF(a1, 4320) = _n20;",
                  "    JF(a1, 4320) *= %s;"),
    "decim": ("voice_render.c",
              "  JF(a1, 3520) = v526;",
              "  JF(a1, 4928) *= %s; JF(a1, 3520) *= %s;"),
    "reverb": ("master_render.c",
               "                      (int32_t *)(a1 + 10759872), v176, v177, "
               "&v529, &v530);",
               "    { float _f = %s; v529 *= _f; v530 *= _f; }"),
}
# PER-MODULE TEETH BRACKETS.  module -> (factor that must FAIL, factor that
# must PASS). Both are relative errors on that module's own output.
#
# THESE ARE COMPUTED FROM MEASURED GAIN, NOT CHOSEN.  The first version of this
# battery used 1e-5 / 1e-6 for every module and was WRONG in a way worth
# recording, because it is the same mistake as audit finding F8 committed an
# hour after F8 was written up.
#
# A pure relative scale of 1e-5 on a module whose error reaches the output at
# unity gain produces a residual of exactly 1e-5, which is exactly -100 dB,
# which is exactly the threshold. Six of the eight modules sit at unity gain, so
# six brackets landed ON the line: they read -100.0 / -100.1 dB and passed or
# failed essentially at random (dco 1/30, delay 17/30, chorus 21/30). I then
# read "dco 1/30" as "the DCO is the weakest module in the set" and wrote that
# down. IT IS NOT TRUE. The DCO transmits its error at unity gain like the rest;
# the probe was on the threshold.
#
# MEASURED gain of each module's output error at the gate, G = residual_dB
# minus 20*log10(factor), from the 30-scenario sweep:
#
#     chorus 0.0   dco +0.2   delay 0.0   reverb 0.0   vca_hpf 0.0
#     vcf_ladder 0.0          env +18.6   vcf_cv +16.3   pwm_cv +104.5
#
# Modules that AMPLIFY (env, vcf_cv, pwm_cv) do so because their output is not
# an audio signal but a control value -- an envelope level or a cutoff -- and a
# relative error on a control moves the audio by much more than itself.
#
# Each bracket below is placed so the FAIL case lands near -90 dB and the PASS
# case near -110 dB, about 10 dB clear of the threshold on both sides. Both
# figures are re-measured and recorded in docs/engineb/HARNESS_AUDIT.md.
# ANCHOR NAME -> SHIM DIRECTORY. Almost every teeth anchor is named after the
# shim directory that carries its module, and the battery builds `(_m,)` on
# that assumption. The two EFFECT arms broke it: they are separate ANCHORS
# (each needs its own bracket and its own catch set) inside ONE shim directory,
# fx_arms -- two arms of one dispatch cannot be two shims, they edit the same
# file. Without this mapping the battery calls build() with a directory that
# does not exist and HARD-STOPS at the first fx case.
#
# FOUND IN REVIEW (Fable, F1), not by running: the full battery had been
# killed mid-run to start the EFFECT work and was never restarted, so the
# crash had simply not been reached yet. "The battery passed" had quietly
# become "the battery passed the last time it was run to completion, which
# predates five of the modules it now covers."
_ANCHOR_DIR = {"fx_e1": "fx_arms", "fx_e5": "fx_arms"}

_BRACKET = {
    "chorus":     ("3.16e-5", "3.16e-6"),
    "dco":        ("3.16e-5", "3.16e-6"),
    "delay":      ("3.16e-5", "3.16e-6"),
    "reverb":     ("3.16e-5", "3.16e-6"),
    "vca_hpf":    ("3.16e-5", "3.16e-6"),
    "vcf_ladder": ("3.16e-5", "3.16e-6"),
    "env":        ("3.7e-6",  "3.7e-7"),
    "decim":      ("3.16e-5", "3.16e-6"),   # measured below, unity gain
    # The first two MASTER-chain blocks (1b-1). MEASURED 2026-08-04 at 48 kHz
    # over all 30 scenarios: both FAIL at 3.16e-5 (-90.0 dB, 30/30) and PASS at
    # 3.16e-6 (-109.8 dB). They land on the same bracket as the voice chain and
    # for the same reason -- all three perturb the signal at unity gain on its
    # way out, so a relative error on them means the same thing at the output.
    "master_in":  ("3.16e-5", "3.16e-6"),
    # A DELAY ARM. MEASURED 2026-08-04 at 48 kHz: 3.16e-5 FAILS at -90.0 dB but
    # in only 2 of the 33 scenarios -- precisely the two DELAY-type-2 and -3
    # scenarios added for arm coverage. 3.16e-6 PASSES at -109.8 dB. That 2/33
    # is the proof the coverage work was a PREREQUISITE and not a nicety:
    # before those scenarios existed this module's teeth would have caught
    # NOTHING, and a green gate would have meant the arm never ran.
    "delay_t23":  ("3.16e-5", "3.16e-6"),
    "delay_t5":   ("3.16e-5", "3.16e-6"),   # measured with the others
    "delay_t1":   ("3.16e-5", "3.16e-6"),   # measured with the others
    # The two reachable EFFECT arms. MEASURED at 48 kHz: 3.16e-5 FAILS at
    # -93.2 dB (e1) and -93.6 dB (e5), each in exactly ONE scenario -- the one
    # that selects that EFFECT TYPE; 3.16e-6 PASSES at -113 dB. One scenario
    # apiece is not weak coverage, it is the whole of it: EFFECT 1 has exactly
    # one factory patch in the bank.
    "fx_e1":      ("3.16e-5", "3.16e-6"),
    "fx_e5":      ("3.16e-5", "3.16e-6"),
    "standalone": ("3.16e-5", "3.16e-6"),   # measured with the others
    "master_out": ("3.16e-5", "3.16e-6"),
    # The 1b-0 whole-voice-chain gate. MEASURED 2026-08-04 at 48 kHz over all
    # 30 scenarios: 3.16e-5 FAILS at -90.0 dB in 30/30, 3.16e-6 PASSES at
    # -109.8 dB. It sits where vca_hpf's does because it IS the same crossing
    # -- the voice's own output entering the master -- now produced by engine
    # B's render function instead of the port's voice function.
    "voices":     ("3.16e-5", "3.16e-6"),
    # The noise SVF ATTENUATES: MEASURED -12.6 dB, so its bracket is coarser by
    # that much. This is the weakest-coupled block in the engine and the one
    # whose bracket had to be derived from a measured gain rather than reused.
    "noise_svf":  ("1.35e-4", "1.35e-5"),
    # 'cvgate' is FAIL-ONLY and absent here on purpose -- see teeth(). Its
    # output is a three-way GATE SIGN in {-1, 0, +1}, a switch rather than a
    # continuous value, so a relative perturbation SATURATES: MEASURED, both
    # 3.16e-5 and 3.16e-6 give the SAME +3.3 dB residual in the same 4
    # scenarios. A bracket needs a response that varies with the factor, and
    # this one does not, so there is nothing to bracket.
    # 'pitch' is FAIL-ONLY and is absent from this table on purpose -- see
    # teeth(). Like pwm_cv it is gated finer than one ULP of 1.0f, so no pass
    # case can exist: MEASURED, 1.8e-8 gives EXACTLY 0 because
    # `1.0f + 1.8e-8f == 1.0f`, i.e. that build perturbs nothing at all.
    # MEASURED 2026-08-03 at 48 kHz over all 30 scenarios: 1e-6 FAILS at
    # -83.6 dB in 4 scenarios, 1e-7 PASSES at -105.9 dB. The LFO carries a
    # CONTROL value, so a relative error on it is amplified at the output --
    # which is why its bracket sits two decades finer than the audio modules'.
    "lfo":        ("1e-6",    "1e-7"),
    # MEASURED 2026-08-03 at 48 kHz, perturbing the NOISE output: 1e-4 fails
    # at -92.6 dB in 6 scenarios, 1e-5 passes at -112.0 dB. The bracket is
    # coarse for the same reason the noise SVF's is -- the noise is the most
    # weakly-coupled signal in the voice.
    # MEASURED 2026-08-03 at 48 kHz: 1e-5 FAILS at -87.4 dB in 17 scenarios,
    # 1e-6 PASSES at -106.9 dB.
    "vcf_res":    ("1e-5",    "1e-6"),
    # MEASURED 2026-08-03 at 48 kHz. The FAIL case is 3e-5 (-90.3 dB, 30/30)
    # and NOT the tighter 1e-5, deliberately: 1e-5 lands at -99.8 dB, which
    # clears the -100 dB gate by 0.2 dB. That is a probe sitting ON the
    # threshold -- the exact failure this harness was already caught by twice
    # (audit findings F8 and the first per-module bracket set), where a probe
    # drifts across the line and the battery reports on the probe instead of
    # on the module. The pass side stays 1e-6 (-112.4 dB).
    "noisemix":   ("3e-5",    "1e-6"),
    "notecv":     ("1e-4",    "1e-5"),
    "vcf_cv":     ("4.8e-6",  "4.8e-7"),
    # pwm_cv is fail-only; see teeth(). Its FAIL case would need a factor of
    # about 1.9e-10 to land at -90 dB, which is far below one ULP of 1.0f.
}

# 'skeleton' is absent ON PURPOSE: its shim discards eb_engine_process()'s
# result, so no perturbation of it can reach the output. See _plant's comment.


def _plant(tmp, mutate):
    """--teeth only: plant a known error in the tree that is REALLY compiled.

    These are deliberately the same anchors tools/trackb/null_ab.py uses, so the
    two harnesses fail on the same planted bugs and a teeth regression in either
    is visible against the other.
    """
    # ------------------------------------------------------------------ #
    # PER-MODULE OUTPUT PERTURBATION.  "out:<module>:<factor>"
    #
    # WHY THIS FORM. Until 2026-08-02 only the reverb had a teeth case, so for
    # nine of the ten modules "the gate is green" had never been paired with
    # "the gate can go red" (docs/engineb/HARNESS_AUDIT.md F2). A per-module
    # case has to satisfy two things: it must be planted where that module's
    # result ENTERS the port's signal path, so the perturbation is the module's
    # own output and not something upstream; and it must be a RELATIVE scale, so
    # the factor means the same thing in a loud module and a quiet one.
    #
    # The anchors below are exactly those crossings. Each is asserted unique, so
    # a shim edit that moves one breaks the teeth loudly instead of silently
    # planting nothing -- a teeth case that cannot reach its own mutation
    # measures nothing, which this harness has already been bitten by once.
    #
    # NOT COVERED: 'skeleton'. Its shim runs eb_engine_process() and DISCARDS
    # the result (see the shim's own header), so no perturbation of it can reach
    # the output. It is un-gateable by this harness by construction and is
    # listed as such rather than given a case that would always pass.
    if mutate.startswith("out:"):
        _, mod, fac = mutate.split(":", 2)
        fname, marker, stmt = _OUT_ANCHOR[mod]
        f = os.path.join(tmp, "src", fname)
        s = open(f).read()
        if s.count(marker) != 1:
            raise SystemExit(
                "teeth anchor for module '%s' matched %d times in %s, expected "
                "exactly 1.\n  marker: %s\n  WHAT TO DO: the shim moved. Update "
                "_OUT_ANCHOR so the teeth case still reaches its own mutation; a "
                "case that cannot reach its mutation measures nothing."
                % (mod, s.count(marker), fname, marker.strip()))
        s = s.replace(marker, marker + "\n" +
                      stmt.replace("%s", "(" + fac + ")") + "\n", 1)
        open(f, "w").write(s)
        return
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
        # THE PLANTED CONSTANT MUST LIVE IN THE ARM THIS RUN ACTUALLY EXECUTES.
        # juno_init.c:314 selects one of two precomputed constant sets --
        # `if (result == 44100)` and its else -- and BOTH define v32. Until
        # 2026-08-03 this mutation planted unconditionally in the 44,100 arm,
        # so at any other host rate it modified DEAD CODE: the teeth case
        # reported "planted error produced no residual", i.e. the harness
        # silently measured nothing.
        #
        # FOUND BY RUNNING IT, on the first ever teeth battery at 48,000 Hz
        # (DOUBT_AUDIT.md H1). It is the same class as every other defect this
        # project has hit: a verification that had never been seen to fail.
        p = os.path.join(tmp, "src", "juno_init.c"); s = open(p).read()
        old, new = ("v32 = 1000568814;", "v32 = 1000568914;") \
            if SR == 44100.0 else ("v32 = 991309769;", "v32 = 991309869;")
        if s.count(old) != 1:
            raise SystemExit(
                "dcopitch: anchor %r occurs %d times in juno_init.c -- it must "
                "occur exactly once or the mutation is planting somewhere "
                "unintended." % (old, s.count(old)))
        s = s.replace(old, new, 1)
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
    elif mutate in ("reverbwet", "reverbwet10"):
        # MODULE REVERB, CALIBRATION -- where does the gate bite on the reverb
        # PATH, as opposed to on the whole output? The tank's own output gain is
        # moved by 6.25e-5 ("reverbwet") and by 6.25e-4 ("reverbwet10").
        # RE-CALIBRATED 2026-08-02, second time that day. The pass-side probe
        # was 16.001f (6.25e-5 relative) and was recorded at -100.5 dB, i.e.
        # 0.5 dB inside a -100 dB threshold. Re-running the battery after the
        # per-module cases were added measured it at -99.2 dB, so it had
        # crossed and the battery reported a TEETH FAILURE. Nothing was wrong
        # with the reverb: the probe was simply sitting on the threshold, and a
        # calibration probe that close to the line reports drift as a defect.
        #
        # The GATE WAS NOT MOVED. The PROBE was: 16.0005f (3.1e-5 relative),
        # MEASURED at -105.2 dB, 5.2 dB inside the line. 16.00025f was also
        # measured, at -111.2 dB, and was not chosen because a bracket wants to
        # be near the line, only not ON it.
        #
        # MEASURED 2026-08-02: the pass probe lands at -105.2 dB and must PASS,
        # the fail probe at -80.5 dB and must FAIL. That brackets the -100 dB
        # threshold from both sides FROM INSIDE THE REVERB, and it also fixes
        # the module's leverage: an error in the tank arrives at the gate about
        # 20 dB quieter than the same relative error on the whole output, so
        # this module is gated to roughly 6e-5 of its own signal.
        p = os.path.join(tmp, "engine_b", "eb_reverb.c"); s = open(p).read()
        a = "(((SL * c->wet) * 16.0f) * m)"
        assert s.count(a) == 1
        s = s.replace(a, "(((SL * c->wet) * %s) * m)"
                      % ("16.0005f" if mutate == "reverbwet" else "16.01f"), 1)
    elif mutate == "reverbtap":
        # MODULE REVERB, addressing. One stereo output tap reads one sample
        # earlier. The split-buffer rewrite's whole risk is addressing, so the
        # harness has to be shown catching an addressing error of the smallest
        # possible size.
        p = os.path.join(tmp, "engine_b", "eb_reverb.c"); s = open(p).read()
        a = "s->ot[k][0] = s->taps[EB_REV_OT[k][1]] - s->taps[EB_REV_OT[k][0]];"
        assert s.count(a) == 1
        s = s.replace(a, "s->ot[k][0] = s->taps[EB_REV_OT[k][1]] - "
                         "s->taps[EB_REV_OT[k][0]] + 1;", 1)
    elif mutate == "reverbskip":
        # MODULE REVERB, LOCKSTEP -- the error class docs/trackb/
        # ACCURACY_STANDARD.md names. The tank's state advance is skipped
        # whenever its input sample is INAUDIBLE, which is the "obvious" saving
        # a silent-input reverb invites and is wrong: the tank is still ringing,
        # and the pre-delay modulation is still free-running.
        #
        # The threshold is 1e-6 and not "== 0.0f". MEASURED 2026-08-02: the
        # exact-zero form produced NO residual at all -- once the tank is
        # running its input is never bit-zero, so that mutation was unreachable
        # and measured nothing. A teeth case that cannot reach its own mutation
        # is worse than no teeth case.
        p = os.path.join(tmp, "engine_b", "eb_reverb.c"); s = open(p).read()
        a = "        float v477 = c->f_in[1] * s->s0;"
        assert s.count(a) == 1
        s = s.replace(a, "        if (x > -1e-6f && x < 1e-6f) {\n"
                         "            *outA = c->dry * inB;\n"
                         "            *outB = c->dry * inA; return; }\n" + a, 1)
    elif mutate == "seedpoison":
        # FABLE'S REQUIRED CASE (F1). The standalone engine seeds its state
        # ONCE per context, from a near-cold port. A state field MISSING from
        # the seed whose post-recall value happens to be zero would therefore
        # hide forever -- the memset would supply the same zero the port has.
        # This perturbs ONE seeded field, the master input stage's one-pole
        # history, and the gate must fail. If it does not, the seed is not
        # being read at all and every "seeded correctly" claim is empty.
        p = os.path.join(tmp, "engine_b", "eb_master_coefs.c"); s = open(p).read()
        # THE FIELD MATTERS. The first version of this case perturbed
        # s->in.s84768, the master input stage's one-pole history, and MEASURED
        # a residual of EXACTLY 0 on all 33 scenarios -- the case could not
        # fail. That is not a broken test, it is a REAL measurement: 84768 is
        # multiplied by coefficient 84816, and 84816 is 0.0 in ALL SIXTY-FOUR
        # factory patches (MEASURED, not assumed), so its seeded value is inert
        # and that whole one-pole feedback path is dead for this bank. A teeth case pointed at an inert
        # field proves nothing about the seed, and would have been recorded as
        # proof that the seed is read.
        #
        # fb84704 is the EFFECT stage's feedback into the input stage's v19,
        # and it is unambiguously live: it is the R channel's whole path.
        a = "    s->fb84704 = CF(base, 84704);"
        assert s.count(a) == 1, "seedpoison anchor moved"
        s = s.replace(a, "    s->fb84704 = CF(base, 84704) + 1e-3f;", 1)
    elif mutate == "delayscratch":
        # THE COMPOSITION CASE, and it is a REAL defect this harness let through.
        # Every DELAY arm in the port ends with `v56 = 0.0; v58 = -1.0;`. It
        # reads as decompiler register scratch. It is not: the EFFECT arms that
        # follow assign v56 on ONE branch only, so on the other branch v56
        # carries the delay stage's 0.0 forward. All four delay shims dropped
        # the pair, and the omission was UNREACHABLE until an EFFECT arm with
        # that branch existed (task 1b-3, EFFECT TYPE 0).
        #
        # MEASURED when it was live: `--module delay` alone was EXACTLY 0 and
        # `--module arms_1b3` alone was EXACTLY 0, and the COMPOSITE of the two
        # failed at -11.7 dB, first differing sample 4050. Two modules that are
        # each exact compose exactly only if each also leaves behind the state
        # the other reads -- and no per-module gate can see that.
        p = os.path.join(tmp, "src", "master_render.c"); s = open(p).read()
        # THE ARM MATTERS. The EFFECT-TYPE-0 scenario plays patch 2, whose
        # DELAY TYPE is 0 -- the shared core, the 'delay' shim. A generic
        # "first v56 = 0.0 in the file" anchor lands in delay_t1's arm, which
        # no scenario in this battery selects, and the case would measure
        # NOTHING while looking planted. The anchor is therefore the delay-0
        # module's own output write.
        a = "        *(float *)(a1 + 102336) = ebR;"
        if s.count(a) != 1:
            raise SystemExit("delayscratch anchor matched %d times -- the case "
                             "cannot reach its own mutation and measures "
                             "nothing." % s.count(a))
        # SUBSTITUTE A WRONG VALUE, do not DELETE the statement. The first
        # version of this case deleted it and MEASURED a residual of EXACTLY 0
        # on all 35 scenarios -- because an uninitialised local's value is not
        # controlled, and this build's register allocation happened to leave
        # 0.0 there anyway. A teeth case whose planted error is undefined
        # measures the compiler, not the engine.
        # AND IT MUST PERTURB v58, NOT v56. MEASURED on the EFFECT-TYPE-0
        # scenario, composite build, each constant perturbed alone:
        #     v56 = 0.25   -> residual EXACTLY 0     (INERT here)
        #     v58 = -0.5   -> residual -27.8 dB rel  (CAUGHT)
        #     both dropped -> residual -16.5 dB rel  (the original defect)
        # So of the pair the port leaves behind, only v58 is read on a branch
        # any scenario reaches. v56 may still matter on some arm/branch this
        # battery does not select; that is stated, not assumed, and it is why
        # the shims restore BOTH while the teeth case can only prove one.
        i = s.index(a)
        j = s.index("        v58 = -1.0;", i)
        s = s[:j] + "        v58 = -0.5;" + s[j + len("        v58 = -1.0;"):]
    elif mutate == "voicereseed":
        # THE LOCKSTEP CASE, and it is a REAL defect this harness let through
        # once. Engine B's state lives in file statics and the render worker
        # renders every scenario in ONE process, so without a per-context
        # re-seed each scenario inherits the previous scenario's ENDING state.
        # MEASURED when it was live: scenario 1 nulled EXACTLY 0 and all 28
        # others failed from their first frame, the first differing sample
        # being 42000 -- exactly scenario 1's length. Planting it keeps the
        # harness from ever going blind to the class again.
        p = os.path.join(tmp, "src", "juno_driver.c"); s = open(p).read()
        a = "void ebsh_new_context(void) { EB_STARTED = 0; }"
        assert s.count(a) == 1, "voicereseed anchor moved"
        s = s.replace(a, "void ebsh_new_context(void) { }", 1)
    elif mutate == "voiceidleskip":
        # A GATE-CLOSED VOICE SKIPS ITS STATE ADVANCE as well as its audio work.
        # The port never skips anything, so this is wrong on every sample of
        # every voice that is not sounding -- and it is INVISIBLE to a cold
        # start, because a voice that has never sounded and is skipped from
        # sample 0 has nothing to diverge from yet. The idle-prefix scenarios
        # are what make it observable, which is why they exist.
        p = os.path.join(tmp, "engine_b", "eb_render.c"); s = open(p).read()
        a = "        vout[v] = 0.0f;\n        if (vc->atrest) {"
        assert s.count(a) == 1, "voiceidleskip anchor moved"
        s = s.replace(a, "        vout[v] = 0.0f;\n"
                         "        if (st->glide[v].s560 == 0.0f) continue;\n"
                         "        if (vc->atrest) {", 1)
    else:
        raise SystemExit("unknown mutation %s" % mutate)
    open(p, "w").write(s)


# ---------------------------------------------------------------- worker
def worker(lib_path, out_path, quick, sr):
    """Separate process: load ONE library, render every scenario, pickle it."""
    import array
    global SR
    SR = sr
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
    out = {"ident": ident, "sr": SR, "streams": {}}
    for patch, script, tag in scenarios(quick):
        bnk = bank
        if tag in DOCTOR:
            bnk = doctor_bank(bank, patch, *DOCTOR[tag])
        out["streams"][tag] = array.array(
            'f', null_ab.render_script(lib, bnk, SR, patch, script))
    with open(out_path, "wb") as f:
        pickle.dump(out, f, 2)


def render_side(lib_path, quick, tmpdir, tag):
    p = os.path.join(tmpdir, "%s.pkl" % tag)
    r = subprocess.run([sys.executable, os.path.abspath(__file__), "--worker",
                        lib_path, p, "1" if quick else "0", repr(SR)],
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
        # THE TWO SIDES MUST HAVE BEEN RENDERED AT THE SAME RATE. `ref` is
        # reusable across a whole teeth battery, and a reused oracle is exactly
        # the object that could outlive a rate change and be compared against a
        # candidate rendered at a different one. That would null at +999 dB (a
        # length mismatch) and look like a catastrophic engine defect. Checked,
        # not assumed.
        if ref.get("sr") != cnd.get("sr"):
            raise SystemExit("RATE MISMATCH: oracle rendered at %r, candidate "
                             "at %r. These streams are not comparable."
                             % (ref.get("sr"), cnd.get("sr")))
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
def _coef_audit_teeth():
    """THE COEFFICIENT AUDIT, run here so it cannot go stale.

    tools/engineb/coef_audit.py refuses any cell that eb_coefs.c caches as a
    coefficient while src/voice_render.c writes it every sample. It was written
    after exactly that defect shipped -- the three DCO oscillator levels, cached
    from cells the port rewrites at :1702-1707, which made the DCO emit silence
    (docs/engineb/data/voice_gate.md). A check that only ever runs by hand is a
    check that goes stale, and this harness has already been bitten by a stale
    anchor once, so the audit runs in the battery and gets teeth of its own: a
    tree in which eb_coefs.c reads the bad cell again, on which the audit MUST
    fail. An audit never seen to fail is not an audit.
    """
    import re as _re
    print("--- coefficient audit (static; both accessors) ---")
    bad = 0
    aud = os.path.join(HERE, "coef_audit.py")
    r = subprocess.run([sys.executable, aud], capture_output=True)
    print("  clean tree: %s" % r.stdout.decode().strip().split("\n")[0])
    if r.returncode != 0:
        print("  *** the audit FAILS on the clean tree ***")
        bad += 1
    # planted: put the per-sample cell back and require a refusal.
    tmp = tempfile.mkdtemp(prefix="coefaudit_")
    try:
        for d in ("src", "engine_b"):
            shutil.copytree(os.path.join(REPO, d), os.path.join(tmp, d))
        shutil.copyfile(aud, os.path.join(tmp, "coef_audit.py"))
        f = os.path.join(tmp, "engine_b", "eb_coefs.c")
        t = open(f).read()
        a = "q->lvl_saw   = CF(a1, 4192);"
        if t.count(a) != 1:
            print("  *** planted-case anchor moved; the audit teeth planted "
                  "NOTHING and measured nothing ***")
            return bad + 1
        open(f, "w").write(t.replace(a, "q->lvl_saw   = CF(a1, 4736);", 1))
        # the script derives REPO from its own path: <repo>/tools/engineb/x.py
        stage = os.path.join(tmp, "tools", "engineb")
        os.makedirs(stage)
        shutil.move(os.path.join(tmp, "coef_audit.py"),
                    os.path.join(stage, "coef_audit.py"))
        r2 = subprocess.run([sys.executable,
                             os.path.join(stage, "coef_audit.py")],
                            capture_output=True)
        out = r2.stdout.decode().strip().split("\n")[0]
        if r2.returncode == 0:
            print("  planted 4736: *** NOT REFUSED -- the audit is blind ***")
            bad += 1
        else:
            print("  planted 4736: refused, as required (%s)" % out)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return bad


def teeth(quick):
    """The harness is tested before it is used. Each planted error is built
    through the REAL engine B build path and must be caught in the recorded set
    of scenarios; the clean control must be EXACTLY 0."""
    print("=== ENGINE B NULL HARNESS TEETH (thresh %.0f / block %.0f dB) ==="
          % (THRESH_DB, BLOCK_THRESH_DB))
    # The brackets below were MEASURED at 44,100 Hz. Run at another rate they
    # remain a valid catch/miss test of the harness, but the recorded dB figures
    # in the table are not re-derived, and a bracket could in principle move.
    print("teeth render rate: %.0f Hz%s" % (
        SR, "" if SR == null_ab.SR else
        "   (NOTE: the recorded brackets were measured at %.0f)" % null_ab.SR))
    bad = 0
    # (mutation, must the gate FAIL on it?). Two of these are CALIBRATION, not
    # bug-catching: "onelsb" must PASS and "justover" must FAIL, which brackets
    # the -100 dB threshold from both sides and proves it bites where it claims
    # to. A teeth battery of only catchable bugs measures nothing about where
    # the floor is.
    #
    # A case also carries the MODULES to build with. The port-side mutations use
    # none; a mutation planted inside an engine B module is only compiled into
    # the signal path when that module's shim is in the build, and a case that
    # cannot reach its own mutation is a teeth case that measures nothing.
    cases = [(None, (), False), ("onelsb", (), False), ("justover", (), True),
             ("tailquiet", (), True), ("dcopitch", (), True),
             ("idleskip", (), True),
             (None, ("reverb",), False), ("reverbwet", ("reverb",), False),
             ("reverbwet10", ("reverb",), True),
             ("reverbtap", ("reverb",), True), ("reverbskip", ("reverb",), True),
             (None, ("voices",), False),
             ("voicereseed", ("voices",), True),
             ("voiceidleskip", ("voices",), True),
             (None, ("standalone",), False),
             ("seedpoison", ("standalone",), True),
             (None, ("engine_all",), False),
             ("delayscratch", ("engine_all",), True)]

    # ---- PER-MODULE OUTPUT TEETH (added 2026-08-02, audit finding F2) -------
    # Until this battery existed, nine of the ten modules had never been shown
    # to be catchable at all: only the reverb had a planted error. "Green" for
    # those nine meant nothing, because nobody had made them go red.
    #
    # Each module gets a BRACKET: the smallest relative error on its own output
    # that the gate CATCHES, and the next one down that it lets through. A
    # battery of catchable errors alone measures nothing about where the floor
    # is; the pass half is what fixes it.
    #
    # The factors are MEASURED, not chosen. Worst global residual over the full
    # 30-scenario set, and how many scenarios reacted:
    #
    #   module      1e-5 error              1e-6 error
    #   chorus      -100.0 dB  21/30 FAIL   -120.1 dB  pass
    #   dco          -99.8 dB   1/30 FAIL   -115.5 dB  pass
    #   delay       -100.0 dB  17/30 FAIL   -120.4 dB  pass
    #   env          -81.4 dB  30/30 FAIL   -101.8 dB  pass
    #   reverb      -100.0 dB  30/30 FAIL   -120.4 dB  pass
    #   vca_hpf     -100.0 dB  30/30 FAIL   -119.9 dB  pass
    #   vcf_cv       -83.7 dB  17/30 FAIL   -104.0 dB  pass
    #   vcf_ladder  -100.0 dB  30/30 FAIL   -119.7 dB  pass
    #
    # TWO RESULTS WORTH READING BEFORE TRUSTING THIS BATTERY:
    #
    # 1. THE DCO IS THE WEAKEST MODULE IN THE SET. A 1e-5 error on it lands at
    #    -99.8 dB -- it clears the -100 dB threshold by 0.2 dB -- and only ONE
    #    of the thirty scenarios reacts. The DCO is also the module most likely
    #    to be rewritten for speed. A scenario that leans harder on it is owed.
    #
    # 2. pwm_cv HAS NO PASS CASE AND CANNOT HAVE ONE. Its bracket was measured
    #    separately: 1e-7 fails at -35.5 dB in 22/30 scenarios, and 1e-8 gives a
    #    residual of EXACTLY 0 because `1.0f + 1e-8f == 1.0f` -- that build
    #    perturbs nothing and would be a vacuous pass case. Since 1e-7 IS one
    #    ULP of the scale factor, pwm_cv is gated at the finest error a float
    #    can carry: every representable error in its output is caught. It gets
    #    the FAIL half only, and this note instead of a fake pass.
    #
    # NOT IN THIS BATTERY: 'skeleton'. Its shim discards eb_engine_process()'s
    # result, so it cannot be perturbed into the output at all. It is
    # un-gateable by this harness by construction -- see _OUT_ANCHOR.
    for _m in sorted(_OUT_ANCHOR):
        if _m in ("pwm_cv", "pitch", "cvgate", "glide", "dcoprep"):
            # Both carry a CONTROL value -- a cutoff and a pitch -- so a
            # relative error on them is amplified enormously at the output, and
            # both are gated finer than one ULP of 1.0f. A pass case is
            # impossible, not merely absent: MEASURED, pwm_cv at 1e-8 and pitch
            # at 1.8e-8 both give EXACTLY 0, because those factors round to
            # 1.0f and the build perturbs nothing. At one ULP, 1e-7, pwm_cv
            # fails at -35.5 dB in 22/30 and pitch at -35.6 dB in 20/30.
            #
            # 'glide' joins them for the same reason as 'pitch': its output
            # IS the final pitch CV, so an error on it integrates in the DCO
            # phase. MEASURED at 48 kHz: 1e-7 fails at -38.4/-56.5 dB in 30/19
            # scenarios, and 1e-8 gives EXACTLY 0 because 1.0f + 1e-8f == 1.0f
            # -- that build perturbs nothing, so a pass case is impossible
            # rather than merely absent.
            #
            # 'dcoprep' is fail-only for the same reason as 'glide' and
            # 'pitch': its output IS the DCO phase increment, so an error on it
            # integrates. MEASURED at 48 kHz: 1e-6 fails at -49.7 dB in 23
            # scenarios and 1e-7 still fails at -64.7 dB in 16; the next step
            # down, 1e-8, is below one ULP of 1.0f and perturbs nothing.
            #
            # 'cvgate' is here for a DIFFERENT reason, and the distinction
            # matters: its output is a three-way gate sign, a SWITCH, so a
            # relative perturbation saturates instead of scaling. MEASURED,
            # 3.16e-5 and 3.16e-6 give the identical +3.3 dB in the identical 4
            # scenarios. There is no bracket to draw because the response does
            # not vary with the factor.
            cases.append(("out:%s:(1.0f + 1e-7f)" % _m,
                          (_ANCHOR_DIR.get(_m, _m),), True))
            continue
        _fail, _pass = _BRACKET[_m]
        cases.append(("out:%s:(1.0f + %sf)" % (_m, _fail),
                      (_ANCHOR_DIR.get(_m, _m),), True))
        cases.append(("out:%s:(1.0f + %sf)" % (_m, _pass),
                      (_ANCHOR_DIR.get(_m, _m),), False))
    # ONE reference render, reused by every mutant: the mutations are planted in
    # the CANDIDATE build, so the oracle side is invariant across the battery.
    # This line was missing until 2026-08-02 -- `run(..., ref=ref, ...)` raised
    # NameError before any work, so this battery had NEVER EXECUTED despite the
    # docstring and two documents claiming "teeth proven". Found by running it.
    ref = oracle_render(quick)
    for mut, mods, want_fail in cases:
        fails, worst, caught = run(mods, quick, mutate=mut, ref=ref,
                                   label="planted: %s%s"
                                   % (mut or "CLEAN CONTROL",
                                      " [%s]" % ",".join(mods) if mods else ""),
                                   verbose=False)
        got = fails > 0
        ok = (got == want_fail) and (mut is not None or worst is None)
        if mut in ("onelsb", "justover", "reverbwet", "reverbwet10",
                   "reverbtap", "reverbskip") and worst is None:
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
    bad += _coef_audit_teeth()
    print("TEETH: %s" % ("PASS" if bad == 0 else
                         "FAIL -- the harness is blind in %d case(s); it must "
                         "not be used" % bad))
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if a and a[0] == "--worker":
        worker(a[1], a[2], a[3] == "1", float(a[4]))
        return 0
    truth.require()
    global THRESH_DB, BLOCK_THRESH_DB, SR
    if "--rate" in a:
        SR = float(a[a.index("--rate") + 1])
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
        mods = tuple(resolve_modules(["all"])) if m == "all" \
            else () if m == "none" else (m,)
    print("=== ENGINE B NULL: oracle (src/, built fresh) vs engine B ===")
    print("render rate: %.0f Hz%s" % (SR, "" if SR != 48000.0 else
                                      "   (the ESP32-S3 shipping rate)"))
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
