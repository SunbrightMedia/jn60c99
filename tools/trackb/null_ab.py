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
    null_ab.py --cand /path/candidate.so            5-scenario smoke gate
    null_ab.py --cand X --all                       ACCEPTANCE gate: + all 64
        factory patches x 3 scripts x 2 rates (384 comparisons) + 24 seeded
        random polyphonic sequences WITH live parameter edits. Costs seconds --
        both sides are plain C, no emulation -- so there is no reason for the
        five-scenario gate to be the one a rewrite is accepted on.
    null_ab.py --cand X --full / --fuzz [N]         either bulk gate alone
    null_ab.py --teeth                              mutation battery: builds
        known-broken candidates (detuned DCO, wrong noise gain, killed chorus,
        slowed envelope) and asserts the gate CATCHES each IN THE EXPECTED
        NUMBER OF SCENARIOS, plus a clean rebuild that must PASS with residual
        exactly 0 — the gate is itself tested before it counts (the project
        rule bought by every past false-green).

        The per-mutation scenario count is load-bearing, not decoration: the
        noise-gain mutation is caught by 1 of 5 because four of the patches have
        DCO NOISE at zero, so "caught somewhere" would have hidden the fact that
        four scenarios are blind to that subsystem. Anything globally relevant
        (pitch, chorus, envelope) is required in all 5. See
        tools/trackb/observability.py, which measures that blindness directly.

Scenario set covers the risk surface: POLY pluck, MONO retrigger, UNISON phase
pile-up, chorus pad, delay keys, MONO glide (portamento integrator) and a 6.8 s
long-tail render for slow LFO/envelope state — plus, since 2026-08-02, 17
IDLE-PREFIX scenarios (see the block below SCEN) that render N free-running
samples BEFORE the first note, N in {1, 48, 441, 4410, 44100}, over a chorus, a
unison and a noise patch, and two allocate/release/idle/re-allocate scenarios.
Those exist because every other scenario here starts COLD, which makes the set
structurally blind to a LOCKSTEP failure — the exact failure mode engine B's
idle-voice skip risks. The "idleskip" mutation in --teeth measures that: seven
of the nine cold scenarios cannot catch it at all.
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
NFR = 30000

# Scenario set. Each entry is (patch, script, tag); the script is the same event
# language render_script() drives:
#     ('on', note, vel) | ('off', note) | ('param', blob, byte) | ('render', n)
#
# The last two exist because the carriage sweep exposed what the first five do
# NOT cover:
#   * GLIDE. Cells 656/672/688 (glide integrator, rate, arrival flag) measured
#     NOT-CARRIED, which is false in general -- the portamento integrator plainly
#     carries. It measured that way because no scenario ever changed pitch on a
#     portamento patch, so the integrator had nothing to integrate. A subsystem
#     that never runs looks like a subsystem with no state.
#   * SLOW STATE. A 30000-frame render is 0.68 s. An LFO phase or envelope-tail
#     error too small to see there is still audible over ten seconds, so one
#     scenario renders 300000 frames (6.8 s) with a long release tail.
# Every scenario RELEASES its notes and renders a tail. The first five did not,
# and the "tailquiet" teeth mutation -- a gain error that exists only while the
# gate is released -- proved it: five of seven scenarios reported EXACTLY 0
# against it, because they never once left the sustain. The release path is where
# denormals, envelope tails and FTZ live; it cannot be the part nothing tests.
SCEN = [
    (5,  [('on', 60, 100), ('render', NFR), ('off', 60), ('render', 12000)],
                                                                    "pluck POLY"),
    (15, [('render', 4000), ('on', 45, 100), ('on', 52, 100),
          ('on', 45, 100), ('render', NFR), ('off', 45), ('off', 52),
          ('render', 12000)],                                       "MONO retrigger"),
    (61, [('render', 8000), ('on', 48, 100), ('render', NFR),
          ('off', 48), ('render', 12000)],                          "UNISON pile-up"),
    (20, [('on', 48, 100), ('on', 55, 100), ('on', 64, 100),
          ('render', NFR), ('off', 48), ('off', 55), ('off', 64),
          ('render', 12000)],                                       "chorus pad"),
    (2,  [('on', 60, 100), ('on', 67, 100), ('render', NFR),
          ('off', 60), ('off', 67), ('render', 12000)],             "delay keys"),
    (5,  [('on', 36, 100), ('render', 6000), ('on', 60, 100),
          ('render', 6000), ('off', 60), ('render', 6000),
          ('on', 72, 100), ('render', 6000), ('off', 72), ('off', 36),
          ('render', 6000)],                                        "MONO glide"),
    (55, [('on', 40, 90), ('render', 8000), ('on', 59, 90),
          ('render', 232000), ('off', 40), ('off', 59),
          ('render', 60000)],                                       "long LFO+tail"),
    # DCO NOISE. The canary found the whole Chamberlin noise SVF
    # (src/voice_render.c:1129-1140) invisible: the noise reaches the mix as
    # 6432 * 4320 * DCO NOISE LEVEL (6528), and the only scenario patches
    # carrying noise were 2 and 55 at levels 0.027 and 0.039 -- so a 0.1% error
    # inside the filter landed ~30 dB under the gate. Patch 32 runs the level at
    # 0.68, the loudest in the bank (14 of 64 patches use noise at all; the
    # census is in the commit message).
    (32, [('on', 52, 100), ('render', NFR), ('off', 52), ('render', 12000)],
                                                                    "DCO noise"),
    # DCO SYNC/RESET ARM. Targets the blind arms of M2 (src/voice_render.c:964-
    # 1021) and M3 (:1022-1075): lines 968/973/974 and 1023/1028/1029. The
    # per-oscillator reset enable lives in cells 2560 (DCO1) and 3040 (DCO2),
    # both written from record byte 554 (LFO TRIG ENV, value-tree leaf 121 --
    # src/juno_apply.c:665-668). While that byte is 0 the cells are 0, line 971
    # forces v123 = 1.0 unconditionally, and the whole gate-sign arm above it is
    # dead code. Patch 22 is the ONLY patch of the 64 in the factory bank with
    # that byte set (census over truth/presetbankog1.bin), so without it the
    # entire scenario set holds the arm switched off.
    (22, [('on', 43, 100), ('render', 10000), ('on', 55, 100),
          ('render', NFR), ('off', 43), ('off', 55), ('render', 14000)],
                                                                    "DCO reset arm"),
    # ENV1/ENV2 LFO-TRIG ARM, second drive. Targets M2 (:968, the ENV1 gate-kill
    # arm) and M3 (:1023, the ENV2 arm) -- and, with its long hold, the thin
    # peak-detector lines :985/:987 (margin only -3.2 dB). Those two arms were
    # held open by exactly ONE scenario ("DCO reset arm" above) at a 0.78 dB
    # global margin, and Option B rewrites both envelope generators, so a single
    # scenario deep is not a gate. Patch 22 again because it is the ONLY patch of
    # the 64 with record byte 554 (LFO TRIG ENV) set -- re-verified this session
    # against truth/presetbankog1.bin -- and its VCA MODE byte 490 is 1 (= ENV2),
    # so one patch reaches both arms. Redundancy therefore has to come from a
    # DIFFERENT DRIVE of patch 22, not from a second patch, and this one differs
    # in every way that moves those lines: a 20000-sample WARM prefix (the LFO
    # free-runs, so the trig phase at note-on differs from the cold scenario), a
    # 120000-sample (2.7 s) polyphonic hold that spans many LFO-trig periods so
    # the ADSRs are driven through repeated attack/release cycles instead of one,
    # a STAGGERED release, and a re-note after a full release. Every note is
    # released and a 20000-sample tail is rendered.
    (22, [('render', 20000), ('on', 31, 100), ('render', 4000),
          ('on', 43, 100), ('on', 55, 100), ('render', 120000),
          ('off', 31), ('render', 8000), ('off', 43), ('off', 55),
          ('render', 20000),
          ('on', 47, 100), ('render', 60000), ('off', 47),
          ('render', 20000)],                                       "ENV trig arm warm"),
]

COLD_TAGS = {t for _, _, t in SCEN}   # the pre-2026-08-02 set, frozen for the
                                      # teeth matrix: "which scenarios existed
                                      # before idle prefixes were added".

# ------------------------------------------------------ IDLE-PREFIX SCENARIOS
# WHY. Every scenario above starts from a COLD engine — juno_gui_create, then
# apply_bank, then straight into notes. Two of them (MONO retrigger, UNISON
# pile-up) happen to carry a leading ('render', 4000/8000), but that is a fixed
# incidental prefix, not a swept one, and seven of the nine have none at all.
#
# That makes the whole set structurally incapable of catching a LOCKSTEP
# failure. MEASURED (docs/trackb/ACCURACY_STANDARD.md): the same patch and the
# same note sound DIFFERENT after 1, 48, 441, 4410 and 44100 idle samples,
# because the DCO phases, the noise LFSR and the FX LFOs free-run and where they
# stand at note-on is part of the sound. Engine B's single largest optimisation
# — skip the AUDIO work for a silent voice — is one mistake away from also
# skipping that voice's STATE ADVANCE, and a wrong skip is invisible to a gate
# that never idles. This is the same shape as the warm chorus-arm divergence and
# the MONO retrigger latch: both were invisible to every cold gate.
#
# THE SWEEP. Three patches x five idle lengths, chosen for what free-runs:
#   * patch 20 CHORUS — the chorus LFO free-runs from power-on and the EFFECT
#     routing default v551=2 arms it before any note exists.
#   * patch 61 UNISON — all 8 DCOs boot phase-aligned and take seconds of DSP to
#     decorrelate (docs/COLDSTART_UNISON_FINDING.md: peak 0.527 cold -> 0.202
#     after 4 s, centroid 830 -> 1488 Hz on this very patch). Phase alignment is
#     where idle state is loudest.
#   * patch 32 DCO NOISE at 0.68, the loudest noise level in the bank, so the
#     shared LFSR's position at note-on actually reaches the output.
# The five N values are the ones the standard measured, 1 included: one sample of
# idling already changes every sample of the note that follows.
#
# RE-ALLOCATION AFTER IDLE. The last entries play a note, release it, idle, then
# play again. The port's own warm bug lived exactly there — a warm note lands on
# a rotation voice, not voice 0, and that voice's free-running smoother state is
# voice-distinct — so "allocate, release, idle, allocate" is its own case and not
# covered by prefixing a single note.
IDLE_N = [1, 48, 441, 4410, 44100]

_IDLE_BASE = [
    (20, [('on', 48, 100), ('on', 55, 100), ('render', 20000),
          ('off', 48), ('off', 55), ('render', 10000)],             "idle chorus"),
    (61, [('on', 48, 100), ('render', 20000),
          ('off', 48), ('render', 10000)],                          "idle unison"),
    (32, [('on', 52, 100), ('render', 20000),
          ('off', 52), ('render', 10000)],                          "idle noise"),
]
for _p, _s, _t in _IDLE_BASE:
    for _n in IDLE_N:
        SCEN.append((_p, [('render', _n)] + _s, "%s %d" % (_t, _n)))

# allocate -> release -> IDLE -> allocate again, on a unison and a chorus patch.
SCEN += [
    (61, [('on', 45, 100), ('render', 12000), ('off', 45), ('render', 6000),
          ('render', 44100),                       # the idle between the notes
          ('on', 52, 100), ('render', 20000), ('off', 52), ('render', 10000)],
                                                                    "realloc unison"),
    (20, [('on', 43, 100), ('render', 12000), ('off', 43), ('render', 6000),
          ('render', 4410),
          ('on', 59, 100), ('render', 20000), ('off', 59), ('render', 10000)],
                                                                    "realloc chorus"),
]

IDLE_TAGS = {t for _, _, t in SCEN} - COLD_TAGS


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
    lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_set_param.restype = ctypes.c_float
    lib.juno_gui_set_param.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    return lib


def render(lib, bank, patch, script, _unused=None):
    """Render one scenario. (Thin alias for render_script at the gate rate.)"""
    return render_script(lib, bank, SR, patch, script)


def render_script(lib, bank, sr, patch, events):
    """Drive an arbitrary event script; return the interleaved stereo stream.

    ('on', note, vel) | ('off', note) | ('param', blob_idx, byte) |
    ('render', nframes)
    """
    c = lib.juno_gui_create(ctypes.c_float(sr), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), patch)
    out = []
    for ev in events:
        if ev[0] == 'on':      lib.juno_gui_note_on(c, ev[1], ev[2])
        elif ev[0] == 'off':   lib.juno_gui_note_off(c, ev[1])
        elif ev[0] == 'param': lib.juno_gui_set_param(c, ev[1], ev[2])
        else:
            n = ev[1]
            buf = (ctypes.c_float * (2 * n))()
            lib.juno_gui_render(c, buf, n)
            out += list(buf)
    lib.juno_gui_destroy(c)
    return out


def db(x): return 20.0 * math.log10(max(x, 1e-30))


BLOCK = 1024                  # ~23 ms at 44.1 kHz: a click, a bad note-on edge
BLOCK_THRESH_DB = -70.0       # looser than the global gate; see block_residual()


def block_residual(r, c, sig_global):
    """Worst per-block residual, relative to what is PLAYING in that block.

    The global RMS is dominated by the loud part of a render, so an error
    confined to a release tail or to thirty samples at note-on contributes almost
    nothing to it. This measures each 1024-sample block against its OWN level,
    floored at 1e-3 of the global RMS so digital silence cannot divide by zero
    and turn a rounding difference into a -0 dB "failure".

    The threshold is looser than the global one on purpose: a single block has
    1/30th the averaging, so its noise floor is higher. It is a starting value,
    and like every other threshold here it is only worth what --teeth proves.
    """
    floor = sig_global * 1e-3
    worst = None
    for i in range(0, len(r) - BLOCK + 1, BLOCK):
        rb, cb = r[i:i + BLOCK], c[i:i + BLOCK]
        res = math.sqrt(sum((a - b) ** 2 for a, b in zip(rb, cb)) / BLOCK)
        if res == 0.0:
            continue
        loc = max(math.sqrt(sum(v * v for v in rb) / BLOCK), floor)
        rel = db(res) - db(loc)
        if worst is None or rel > worst:
            worst = rel
    return worst


def rel_residual(r, c):
    """(signal dBFS, residual dB relative to signal or None if bit-identical)."""
    if len(r) != len(c):
        # Scored as a loud failure, never as "silent". Returning a tiny signal
        # here would have routed a candidate that renders the WRONG NUMBER OF
        # FRAMES into the non-vacuity skip -- a hard defect reported as "nothing
        # to see". +999 dB cannot be mistaken for a pass by any caller.
        return 0.0, 999.0
    sig = math.sqrt(sum(v * v for v in r) / len(r))
    res = math.sqrt(sum((a - b) ** 2 for a, b in zip(r, c)) / len(r))
    return db(sig), (None if res == 0.0 else db(res) - db(sig))


def judge(r, c):
    """(sig_dBFS, global_rel or None, block_rel or None, ok). Both metrics gate."""
    sig, rel = rel_residual(r, c)
    if rel is not None and rel > 900:            # length mismatch sentinel
        return sig, rel, None, False
    blk = None if rel is None else block_residual(r, c, 10 ** (sig / 20.0))
    ok = (rel is None or rel <= THRESH_DB) and (blk is None or blk <= BLOCK_THRESH_DB)
    return sig, rel, blk, ok


def compare(ref_lib, cand_lib, bank):
    worst = -1e9; fails = 0; caught = set()
    for patch, script, tag in SCEN:
        r = render_script(ref_lib, bank, SR, patch, script)
        cnd = render_script(cand_lib, bank, SR, patch, script)
        sig, rel, blk, ok = judge(r, cnd)
        if len(r) != len(cnd):
            print("  %-16s *** LENGTH MISMATCH %d vs %d -> FAIL ***"
                  % (tag, len(r), len(cnd)))
            fails += 1; caught.add(tag); continue
        if sig < SIG_FLOOR_DB:
            print("  %-16s VACUOUS (ref RMS %.1f dBFS < %.0f) -> scenario invalid"
                  % (tag, sig, SIG_FLOOR_DB))
            fails += 1; caught.add(tag); continue
        if rel is not None: worst = max(worst, rel)
        if not ok: fails += 1; caught.add(tag)
        print("  %-16s sig %6.1f dBFS   residual %-14s worst block %-12s -> %s"
              % (tag, sig,
                 ("EXACTLY 0" if rel is None else "%.1f dB rel" % rel),
                 ("--" if blk is None else "%.1f dB rel" % blk),
                 "PASS" if ok else "FAIL"))
    return fails, worst, caught



# ---------------------------------------------------------------- bulk gates
# WHY THESE EXIST. The five scenarios above are a fast smoke test over five
# patches. The bit-exact seal they are replacing covered all 64 factory patches,
# every parameter byte and 24 random polyphonic sequences -- so gating a rewrite
# on five patches would be a large, silent reduction in coverage at exactly the
# moment coverage matters most. Unlike the seal's gates, these cost nothing: both
# sides are plain C, no Unicorn, so the full bank runs in seconds. There is no
# excuse for the smaller gate to be the acceptance gate.

FULL_SCRIPTS = {
    'hold':    [('on', 60, 100), ('render', 20000), ('off', 60), ('render', 12000)],
    'overlap': [('on', 48, 100), ('render', 3000), ('on', 55, 90), ('render', 3000),
                ('off', 48), ('render', 3000), ('on', 67, 120), ('render', 4000),
                ('off', 55), ('off', 67), ('render', 9000)],
    'warmpad': [('render', 8000), ('on', 43, 70), ('on', 50, 70), ('on', 59, 70),
                ('render', 14000), ('off', 50), ('render', 10000)],
}
FULL_RATES = [44100.0, 48000.0]


def gate_full(ref_lib, cand_lib, bank, verbose=False):
    """All 64 factory patches x 3 scripts x 2 rates = 384 comparisons."""
    fails = vac = 0; worst = None; n = 0
    for sr in FULL_RATES:
        for patch in range(64):
            for name, script in sorted(FULL_SCRIPTS.items()):
                r = render_script(ref_lib, bank, sr, patch, script)
                c = render_script(cand_lib, bank, sr, patch, script)
                n += 1
                if len(r) != len(c):
                    fails += 1
                    print("  FAIL sr %g patch %2d %-8s  LENGTH %d vs %d"
                          % (sr, patch, name, len(r), len(c)))
                    continue
                sig, rel, blk, ok = judge(r, c)
                if sig < SIG_FLOOR_DB:
                    vac += 1                      # patch silent under this script
                    continue
                if rel is not None:
                    worst = rel if worst is None else max(worst, rel)
                if not ok:
                    fails += 1
                    print("  FAIL sr %g patch %2d %-8s  sig %.1f dBFS  residual "
                          "%.1f dB rel  worst block %s"
                          % (sr, patch, name, sig, rel,
                             "--" if blk is None else "%.1f dB rel" % blk))
                elif verbose and rel is not None:
                    print("  ok   sr %g patch %2d %-8s  residual %.1f dB rel"
                          % (sr, patch, name, rel))
    print("FULL BANK: %d comparisons, %d over threshold, %d skipped as silent, "
          "worst %s" % (n, fails, vac,
                        "EXACTLY 0 everywhere" if worst is None else
                        "%.1f dB rel" % worst))
    if vac > n // 3:
        print("  *** %d of %d cases were SILENT and proved nothing. Check the "
              "scripts before trusting this. ***" % (vac, n))
    return fails


def gate_fuzz(ref_lib, cand_lib, bank, nseeds, verbose=False):
    """Seeded random polyphonic sequences, reusing the sealed fuzz generator.

    Live parameter edits are INCLUDED here, unlike tools/verify/fuzz_diff.py.
    That gate excludes them because the plugin-vs-port comparison has a known
    ~1-ULP warm-smoother interaction class; between two builds of the SAME C
    engine there is no such excuse, and a param edit landing on an in-flight
    smoother is exactly the kind of state a rewritten kernel could get wrong.
    FUZZ_PARAMS is set BEFORE the import because fuzz_diff reads it at module
    level -- setting it afterwards would silently do nothing.
    """
    os.environ['FUZZ_PARAMS'] = '1'
    sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
    import fuzz_diff as F                          # module import only: no Unicorn
    if not F.INCLUDE_PARAMS:
        raise SystemExit("ABORT: fuzz_diff was imported without FUZZ_PARAMS, so "
                         "this run would silently drop live parameter edits and "
                         "report a weaker gate as the stronger one.")
    fails = nsil = 0; worst = None
    for seed in range(nseeds):
        rate, patch, ev, total = F.gen_script(seed)
        r = render_script(ref_lib, bank, rate, patch, ev)
        c = render_script(cand_lib, bank, rate, patch, ev)
        if not r:
            continue
        if len(r) != len(c):
            fails += 1
            print("  FAIL seed %2d: LENGTH %d vs %d" % (seed, len(r), len(c)))
            continue
        sig, rel, blk, ok = judge(r, c)
        if sig < SIG_FLOOR_DB:
            nsil += 1
            if verbose:
                print("  seed %2d: silent (%.1f dBFS) -- proves nothing" % (seed, sig))
            continue
        if rel is not None:
            worst = rel if worst is None else max(worst, rel)
        if not ok:
            fails += 1
            print("  FAIL seed %2d rate %g patch %2d (%d events, %d frames): "
                  "residual %.1f dB rel  worst block %s"
                  % (seed, rate, patch, len(ev), total, rel,
                     "--" if blk is None else "%.1f dB rel" % blk))
    print("FUZZ: %d seeds (%d silent), %d over threshold, worst %s"
          % (nseeds, nsil, fails,
             "EXACTLY 0 everywhere" if worst is None else "%.1f dB rel" % worst))
    return fails


def _mut_target(tmp, name):
    """Path of the file that will ACTUALLY be compiled for src/<name>.

    If native/<name> shadows it, the mutation has to go there -- otherwise the
    battery patches a file the candidate build never sees, every mutant comes out
    identical to the reference, and --teeth reports the gate as blind when in
    fact the experiment never happened. Mutating the compiled file also means the
    battery exercises the same substitution path a real candidate uses.
    """
    nat = os.path.join(tmp, "native", name)
    return nat if os.path.exists(nat) else os.path.join(tmp, "src", name)


def build(dst, mutate=None):
    """Build a candidate .so the way `make juno_cand.so` does (native/ shadows
    src/ by filename), optionally with a named mutation applied to whichever
    copy of the file is really compiled."""
    tmp = tempfile.mkdtemp(prefix="trackb_")
    for d in ("src", "gui"):
        shutil.copytree(os.path.join(REPO, d), os.path.join(tmp, d))
    if os.path.isdir(os.path.join(REPO, "native")):
        shutil.copytree(os.path.join(REPO, "native"), os.path.join(tmp, "native"))
    if mutate == "noisegain":
        # The NOISE generator's 2^-24 output scale, off by 0.1% (voice_render.c
        # :640 -- the shared LFSR block at base+84272..84436, not a DCO cell).
        # It is caught by ONE scenario, not five, and that is the correct answer:
        # the other four patches have DCO NOISE at zero, so the value is
        # multiplied out downstream. Kept in the battery precisely BECAUSE it is
        # scenario-specific -- it is the case that proved "the line executed" and
        # "the error is observable" are different questions (see
        # tools/trackb/observability.py). It was mislabelled "detune" until
        # 2026-07-31; it never had anything to do with pitch.
        p = _mut_target(tmp, "voice_render.c"); s = open(p).read()
        s = s.replace("* 0.000000059604645", "* 0.000000059664245", 1)
        assert "0.000000059664245" in s; open(p, "w").write(s)
    elif mutate == "dcopitch":
        # A REAL detune: the Hz -> phase-increment scale (cell 5536 = 220/44100
        # at 44.1 kHz, juno_init.c:592), moved by 100 ULP ~= 6e-6 relative, about
        # 0.01 cent. Every patch with an oscillator must hear it, so unlike
        # noisegain this one is expected in ALL scenarios -- the battery's check
        # that a globally-relevant error is globally caught.
        p = _mut_target(tmp, "juno_init.c"); s = open(p).read()
        assert s.count("v32 = 1000568814;") == 1
        s = s.replace("v32 = 1000568814;", "v32 = 1000568914;", 1)
        open(p, "w").write(s)
    elif mutate == "nochorus":  # slot-2 select forced to Pan arm: chorus dead
        p = _mut_target(tmp, "master_render.c"); s = open(p).read()
        s = s.replace("v551 = juno_host_sel(a1, 112);", "v551 = 0;", 1)
        assert "v551 = 0;" in s; open(p, "w").write(s)
    elif mutate == "envslow":   # one envelope coefficient nudged 1%
        p = _mut_target(tmp, "voice_render.c"); s = open(p).read()
        s = s.replace("(float)(v236 * v236) * 0.25", "(float)(v236 * v236) * 0.2525", 1)
        assert "0.2525" in s; open(p, "w").write(s)
    elif mutate == "tailquiet":
        # A 0.1% gain error that exists ONLY while the gate is released -- i.e.
        # only in the quiet part of the render. This is the mutation the whole-
        # render RMS is designed to miss: the global metric normalises by the
        # loud sustained portion, where the candidate is exact. It exists to
        # answer "is the block metric earning its place, or is it decoration?"
        p = _mut_target(tmp, "voice_render.c"); s = open(p).read()
        anchor = "  *outL = JF(a1, 10672);"
        assert s.count(anchor) == 1
        s = s.replace(anchor,
                      "  if (JF(a1, 560) == 0.0f) JF(a1, 10672) = "
                      "JF(a1, 10672) * 1.001f;\n" + anchor, 1)
        open(p, "w").write(s)
    elif mutate == "idleskip":
        # THE LOCKSTEP MUTATION. Engine B's largest optimisation is "do not do
        # the audio work for a silent voice". This is that optimisation done
        # WRONG: the voice's STATE ADVANCE is skipped too, until the first note
        # the engine ever sees. Free-running DCO phase, the shared noise LFSR and
        # every per-voice smoother therefore stand where they stood at power-on
        # when the first note arrives, instead of where N samples of free-running
        # would have put them.
        #
        # It is deliberately the SUBTLE version — it stops at the first note-on
        # and never fires again — because the loud version (freeze whenever no
        # key is held) also fires in every release tail, which the old cold
        # scenarios do exercise. Restricting it to the pre-first-note window is
        # what isolates the surface the old set cannot reach: a scenario that
        # renders nothing before its first note-on is BIT-IDENTICAL under it, by
        # construction, and no threshold can change that.
        #
        # The "has any note ever been played" latch lives at byte offset 11900000
        # of the 12 MB state array: past the highest cell any engine source
        # touches (~11,022,xxx) and calloc-zeroed by juno_gui_create, so it is a
        # per-context flag with no aliasing and no leakage between scenarios.
        # 1856 is the plugin's own broadcast "any key held" flag (src/juno_note.c
        # :204-225), so the latch is set by the plugin's own note bookkeeping.
        p = _mut_target(tmp, "voice_render.c"); s = open(p).read()
        anchor = "  v2 = JF(a1, 320);\n"
        assert s.count(anchor) == 1
        s = s.replace(anchor,
                      "  if ( JI(base, 11900000) == 0 ) {\n"
                      "    if ( JF(a1, 1856) != 0.0f ) JI(base, 11900000) = 1;\n"
                      "    else { *outL = 0.0f; *outR = 0.0f; return 0; }\n"
                      "  }\n" + anchor, 1)
        open(p, "w").write(s)
    elif mutate == "gapskip":
        # The MID-RUN half of the same failure: the voice's state advance is
        # skipped whenever no key is held. Needed because "idleskip" cannot test
        # the re-allocation scenarios (their first event is a note-on, so its
        # pre-first-note window is empty and they are bit-identical under it).
        # This one fires in every gap and every release tail, so plenty of cold
        # scenarios catch it as well — that is expected and is not the claim.
        # The claim it supports is narrow: the realloc-after-idle scenarios are
        # not decoration, they do detect a state advance that stops in a gap.
        p = _mut_target(tmp, "voice_render.c"); s = open(p).read()
        anchor = "  v2 = JF(a1, 320);\n"
        assert s.count(anchor) == 1
        s = s.replace(anchor,
                      "  if ( JF(a1, 1856) == 0.0f ) { *outL = 0.0f; "
                      "*outR = 0.0f; return 0; }\n" + anchor, 1)
        open(p, "w").write(s)
    elif mutate is not None:
        raise SystemExit("unknown mutation %s" % mutate)
    glob = __import__("glob")
    native = sorted(glob.glob(os.path.join(tmp, "native", "*.c")))
    shadow = {os.path.join(tmp, "src", os.path.basename(n)) for n in native}
    srcs = [x for x in sorted(glob.glob(os.path.join(tmp, "src", "*.c")))
            if x not in shadow] + native
    cmd = ["cc", "-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing",
           "-I" + os.path.join(tmp, "src"), "-shared", "-fPIC", "-o", dst,
           os.path.join(tmp, "gui", "juno_bridge.c")] + srcs + ["-lm"]
    subprocess.run(cmd, check=True, capture_output=True)
    shutil.rmtree(tmp)


def main():
    truth.require()
    bank = open(truth.BANK, "rb").read()
    sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
    import freshlib          # the reference must not be a stale build either:
    freshlib.check()         # a null against yesterday's libjuno proves nothing
    ref = load(os.path.join(REPO, "libjuno.so"))

    if "--teeth" in sys.argv:
        print("=== TRACK B GATE TEETH TEST: the gate must catch planted bugs ===")
        bad = 0
        # EXPECTED CATCH SETS, MEASURED, not assumed.
        #
        # The first version of this required "all scenarios" for any mutation
        # thought to be globally relevant. That rule is unsound: patches
        # legitimately differ, and adding the DCO-noise scenario immediately
        # produced two failures that were not gate weakness. What IS sound is to
        # record the set of scenarios measured to catch each mutation and require
        # it never to SHRINK -- a scenario that used to see a bug and stops is a
        # regression in the gate; a new scenario that does not see it is a fact to
        # record, not a failure to paper over.
        #
        # "DCO noise" (patch 32) does not catch nochorus or tailquiet. UNEXPLAINED:
        # patch 32 carries EFX routing 2, the same as patch 5, which does catch
        # nochorus -- so the obvious explanation is wrong and no substitute has
        # been established. Recorded as a measured fact and flagged, rather than
        # given a plausible story. Do not remove this note by guessing.
        ALL = COLD_TAGS | IDLE_TAGS
        PREFIXED = {t for _, sc, t in SCEN if sc and sc[0][0] == 'render'}
        NOISE_IDLE = {t for t in IDLE_TAGS if t.startswith("idle noise")}
        REALLOC = {t for t in IDLE_TAGS if t.startswith("realloc")}
        EXPECT = {
            # MEASURED 2026-08-02 over the 26-scenario set (9 cold + 17 idle).
            "noisegain": {"delay keys", "long LFO+tail", "DCO noise"} | NOISE_IDLE,
            "dcopitch":  set(ALL),
            # "DCO reset arm" (patch 22) does NOT catch nochorus. It was listed
            # as expected by the previous all-minus-DCO-noise formula, which was
            # written before that scenario existed and was never re-measured
            # against it. Recorded here as the measured fact. UNEXPLAINED, like
            # the patch-32 case below it; do not replace either with a guess.
            "nochorus":  ALL - {"DCO noise", "DCO reset arm"} - NOISE_IDLE,
            "envslow":   set(ALL),
            "tailquiet": ALL - {"DCO noise"},
            # LOCKSTEP, and the SHAPE of this set is the whole point: 15 of the
            # 17 idle-prefix scenarios catch it, and of the 9 cold scenarios only
            # the two that happen to carry a leading ('render', N) do. The seven
            # genuinely cold ones are blind by construction, not by threshold.
            # The two realloc scenarios are also blind to THIS mutation by
            # construction — their first event is a note-on, so its
            # pre-first-note window is empty. "gapskip" is the mutation that
            # tests them.
            "idleskip":  PREFIXED,
            "gapskip":   set(ALL),
        }
        # A scenario whose first event is a note-on CANNOT catch idleskip. Making
        # that an assertion, split cold vs idle, is what proves the new scenarios
        # are load-bearing rather than redundant with the cold ones.
        # STRUCTURAL, not by tag. A scenario can catch idleskip if and only if it
        # RENDERS BEFORE ITS FIRST NOTE-ON -- the mutation's window closes at the
        # first note the engine ever sees. Deriving that from the scripts rather
        # than from tag names removes a whole class of bookkeeping bug: the
        # "ENV trig arm warm" scenario was declared above the line that freezes
        # COLD_TAGS, so it was tagged cold while opening with ('render', 20000),
        # and a name-based expectation would have called its correct catch a
        # matrix mismatch. Two scenarios tagged idle (the realloc pair) likewise
        # CANNOT catch it, because their idle sits between notes.
        PREFIXED = {t for _, sc, t in SCEN if sc and sc[0][0] == 'render'}
        IDLE_EXPECT = {
            "idleskip": (PREFIXED & IDLE_TAGS, PREFIXED & COLD_TAGS),
            "gapskip":  (set(IDLE_TAGS), set(COLD_TAGS)),
        }
        for mut, expect_fail in ((None, False), ("noisegain", True),
                                 ("dcopitch", True), ("nochorus", True),
                                 ("envslow", True), ("tailquiet", True),
                                 ("idleskip", True), ("gapskip", True)):
            dst = "/tmp/trackb_%s.so" % (mut or "clean")
            build(dst, mut)
            print("candidate: %s" % (mut or "clean rebuild (control)"))
            fails, worst, caught_set = compare(ref, load(dst), bank)
            caught = fails > 0
            want = EXPECT.get(mut, set())
            missing = sorted(want - caught_set)
            extra = sorted(caught_set - want)
            ok = (caught == expect_fail) and not missing
            if mut in IDLE_EXPECT:
                want_idle, want_cold = IDLE_EXPECT[mut]
                got_idle = caught_set & IDLE_TAGS
                got_cold = caught_set & COLD_TAGS
                print("  CATCH MATRIX: idle-prefix %d/%d caught, cold %d/%d caught"
                      % (len(got_idle), len(IDLE_TAGS), len(got_cold), len(COLD_TAGS)))
                if got_idle != want_idle or got_cold != want_cold:
                    print("    *** MATRIX MISMATCH: idle missing %s; cold "
                          "unexpectedly catching %s ***"
                          % (sorted(want_idle - got_idle) or "none",
                             sorted(got_cold - want_cold) or "none"))
                    ok = False
            if not ok: bad += 1
            print("  -> %s (%d/%d caught%s%s)\n"
                  % ("OK" if ok else "*** TEETH FAILURE ***",
                     len(caught_set), len(SCEN),
                     "" if not missing else
                     "; *** LOST: %s -- these caught it before ***" % ", ".join(missing),
                     "" if not extra else "; newly catching: %s" % ", ".join(extra)))
        print("TEETH: %s" % ("PASS — the gate catches every planted bug and "
                             "passes the clean control" if bad == 0
                             else "FAIL — the gate is BLIND to %d case(s); "
                                  "it must not be used" % bad))
        return 1 if bad else 0

    if "--cand" not in sys.argv:
        raise SystemExit(__doc__)
    cand = load(sys.argv[sys.argv.index("--cand") + 1])
    verbose = "-v" in sys.argv
    print("=== TRACK B NULL A/B: candidate vs sealed reference (thresh %.0f dB rel) ==="
          % THRESH_DB)
    fails, worst, _ = compare(ref, cand, bank)
    print("SCENARIOS: %s (worst residual %s)"
          % ("PASS" if fails == 0 else "FAIL (%d scenario(s))" % fails,
             "0" if worst == -1e9 else "%.1f dB rel" % worst))

    if "--full" in sys.argv or "--all" in sys.argv:
        print("\n--- FULL BANK: 64 patches x %d scripts x %d rates ---"
              % (len(FULL_SCRIPTS), len(FULL_RATES)))
        fails += gate_full(ref, cand, bank, verbose)
    if "--fuzz" in sys.argv or "--all" in sys.argv:
        n = 24
        if "--fuzz" in sys.argv:
            i = sys.argv.index("--fuzz") + 1
            if i < len(sys.argv) and sys.argv[i].isdigit(): n = int(sys.argv[i])
        print("\n--- RANDOM SEQUENCES: %d seeds, live param edits included ---" % n)
        fails += gate_fuzz(ref, cand, bank, n, verbose)

    print("\nVERDICT: %s" % ("PASS" if fails == 0 else "FAIL (%d case(s))" % fails))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
