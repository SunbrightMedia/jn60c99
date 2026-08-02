#!/usr/bin/env python3
"""plugin_check.py -- THE AUTHORITY GATE. Candidate vs the PLUGIN BINARY itself,
executed under Unicorn, compared in the sample domain.

WHY THIS FILE EXISTS (docs/trackb/THREE_WAY_GATE.md)
    tools/engineb/null_b.py gates engine B against `src/`, the port. That is the
    FAST comparison and it is a PROXY. If the port has a hole, engine B inherits
    it and null_b stays green -- which is not a hypothetical: the assigner never
    learned KEY ASSIGN, so the Unicorn oracle and the port sat in the SAME wrong
    state and every render A/B compared two copies of one mistake for weeks. The
    port also has NAMED holes today (8 DEFERRED-CONTROLLER rows incl. every
    FLANGER leaf, DELAY TAP TIME 1178, the unexecuted record-byte position map).

    So: `src/` is a fast proxy. The plugin is the AUTHORITY. This is the tool
    that consults the authority. Every report it prints names which side is
    authoritative, on every line, so no future reader can mistake a port
    comparison for a plugin comparison.

WHAT IT COMPARES
    REFERENCE (authority) = the plugin's OWN recall + render under Unicorn, with
        ZERO port code in the path. It is literally
        tools/verify/recall_render_ab.prepare_recall (the proven-complete recall
        that `make verify` uses) followed by the plugin's own note entries and
        its own per-block render. Nothing here reimplements plugin logic.
    CANDIDATE = a .so exposing the juno_gui_* API: either the port built fresh
        from src/ (--check-port) or an engine B build (--module ...). Driven by
        tools/trackb/null_ab.render_script -- the SAME event script, event for
        event, that the reference is driven with.
    METRICS = imported from tools/trackb/null_ab.py (rel_residual /
        block_residual / db). They are NOT rewritten here. Global RMS residual
        and worst-1024-block residual, both relative, both reported.

    NOTE ON THRESHOLDS: this file reports numbers and applies the null_b
    thresholds (-100 dB global / -80 dB block) only when --strict is given. The
    default verdict band is null_ab's (-90 / -70). Read the dB, not the word.

--check-port -- THE MOST VALUABLE PATH
    Compares src/ against the plugin. src/ is claimed BIT-EXACT against this
    same oracle on the factory bank (recall_render_ab, 57/57), so on the cold
    factory scenarios the expected result is EXACTLY 0.0 residual, and anything
    else is a NEW PORT BUG -- the single most valuable thing this tool can find.
    That expectation also makes --check-port this harness's own self-test: a
    non-zero residual on a plain cold scenario means the HARNESS is wrong before
    it means the port is.

THE TWO-PROCESS RULE, ABSOLUTELY
    The driver process compiles and compares and loads NOTHING. `--ref` is a
    subprocess that imports Unicorn/e2e_emu and never touches ctypes. `--cand`
    is a subprocess that ctypes-loads exactly one .so and never imports
    e2e_emu. They meet only through pickles.

COST -- MEASURED, not guessed
    The Unicorn oracle runs at ~0.5 ms per output sample on this container
    (MEASURED 2026-08-02: 2000 samples in 1.0 s), plus ~4.5 s to build and
    recall one patch. So one 20,000-frame scenario costs ~14 s of reference
    time. The default 6-scenario set is therefore ~1.5-2 minutes of oracle
    time per run; `--quick` (2 scenarios) is ~30 s.

    THIS IS DESIGNED FOR A SMALL NUMBER OF AUTHORITATIVE COMPARISONS, NOT A
    SWEEP. The scenario scripts below are DELIBERATELY SHORTER than the ones in
    null_ab.py (a null_ab long-tail scenario is 292,000 frames = ~2.5 minutes of
    emulation on its own). Bulk coverage belongs on the fast proxy; this gate
    confirms the authority agrees at a handful of load-bearing points.

CURRENT RESULT (MEASURED 2026-08-02, after the UNISON fix and after the
idle-prefix variants were added) -- `--check-port`, 11 scenarios, 44100 Hz:
    ALL 11 BIT-EXACT, including `UNISON pile` and `UNISON 1-idle`, the two rows
    that were red before the fix. The divergence recorded below was a REAL PORT
    BUG, found by this tool, and it is closed: the bridge never armed the
    per-voice DCO retrigger latch on any voice, and `juno_init` arms it at
    BUILD, so a cold note matched by accident. Fixed in gui/juno_bridge.c.
    Signal levels this run: -18.7 to -35.7 dBFS.

HISTORY (MEASURED 2026-08-02, first run of this file) -- THE PORT DIVERGENCE
THIS TOOL WAS BUILT TO FIND. Retained because it is the evidence that the
idle-prefix variants earn their runtime.
    `--check-port`, 6 scenarios, 44100 Hz, 98 s wall:
        pluck POLY   BIT-EXACT      chorus pad  BIT-EXACT
        MONO retrig  BIT-EXACT      delay keys  BIT-EXACT
        DCO noise    BIT-EXACT      UNISON pile  -34.6 dB global / -16.3 block
    Narrowed (same two-process pattern, patch 61, note 48, varying ONLY the
    number of idle frames rendered BEFORE the note-on):
        0 idle (cold)  BIT-EXACT      441 idle   -33.4 dB
        1 idle         -58.1 dB      3000 idle   -32.6 dB
        48 idle        -57.2 dB
    and the same idle prefix on patch 5 (POLY) is BIT-EXACT, as is the 2000-frame
    idle prefix on patch 15 (MONO) in the scenario set above.
    So: `src/` matches the plugin on UNISON only when the note arrives on the
    very first sample -- ONE free-running idle sample is enough to diverge. This
    is exactly the class recall_render_ab cannot see: all 57 of its patches are
    driven COLD. Root cause NOT yet established, and a harness defect is not
    fully excluded -- but the same harness path is bit-exact on POLY and MONO
    with idle prefixes, which is evidence against that. [RESOLVED: it was a port bug,
    not a harness defect. See CURRENT RESULT above.]

USAGE
    plugin_check.py --check-port [--quick] [--scen TAG ...]
    plugin_check.py --module all [--quick]          # engine B vs the plugin
    plugin_check.py --cand /path/to/lib.so [--quick]
    plugin_check.py --list                          # scenario inventory
  (internal: --ref OUT.pkl [tags...] / --cand-worker LIB OUT.pkl [tags...])
"""
import sys, os, subprocess, pickle, tempfile, struct, argparse

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))

SR = 44100.0                     # null_ab.SR; the rate both sides are built at

# ---------------------------------------------------------------------------
# SCENARIOS. Same event language as null_ab.render_script:
#     ('on', note, vel) | ('off', note) | ('render', nframes)
# ('param', ...) is NOT supported here on purpose: a live parameter edit on the
# plugin side would need the host parameter entry, a different (and separately
# gated) surface. Driving it as a bare dispatch would make this gate a
# comparison of two different things while looking like a comparison of one.
#
# Each scenario is chosen for a distinct risk surface and every one RELEASES its
# notes and renders a tail (the release path is where denormals, envelope tails
# and FTZ live). Frame counts are ~1/3 of null_ab's because every frame here
# costs ~0.5 ms of emulation.
#
# Patch choices follow null_ab.SCEN so a divergence here is comparable to a
# divergence there: 5 POLY pluck, 15 MONO retrigger (the patch the MONO
# retrigger latch bug was found on), 61 UNISON pile-up, 20 chorus pad, 2 delay
# keys, 32 the loudest DCO-NOISE patch in the bank.
# ---------------------------------------------------------------------------
SCEN = [
    ("pluck POLY", 5,
     [('on', 60, 100), ('render', 10000), ('off', 60), ('render', 4000)]),
    ("MONO retrig", 15,
     [('render', 2000), ('on', 45, 100), ('on', 52, 100), ('on', 45, 100),
      ('render', 10000), ('off', 45), ('off', 52), ('render', 4000)]),
    ("UNISON pile", 61,
     [('render', 3000), ('on', 48, 100), ('render', 10000), ('off', 48),
      ('render', 4000)]),
    ("chorus pad", 20,
     [('on', 48, 100), ('on', 55, 100), ('on', 64, 100), ('render', 10000),
      ('off', 48), ('off', 55), ('off', 64), ('render', 4000)]),
    ("delay keys", 2,
     [('on', 60, 100), ('on', 67, 100), ('render', 10000), ('off', 60),
      ('off', 67), ('render', 4000)]),
    ("DCO noise", 32,
     [('on', 52, 100), ('render', 10000), ('off', 52), ('render', 4000)]),

    # ---- IDLE-PREFIX VARIANTS (added 2026-08-02) ----------------------------
    # WHY THESE EXIST. The UNISON divergence recorded above was a REAL PORT BUG
    # (the per-voice DCO retrigger latch was armed on no voice by the bridge;
    # fixed in gui/juno_bridge.c). It was invisible to every cold gate because
    # juno_init arms the latch at BUILD, so a note on the very first sample
    # matches by accident. ONE idle sample was enough to expose it.
    #
    # The four scenarios above other than MONO retrig and UNISON pile were
    # COLD, which is the same structural blind spot inside the tool built to
    # catch it. These variants re-run them with a free-running idle prefix.
    # The prefix lengths are deliberately unequal and not multiples of each
    # other: the chorus LFO, the noise LFSR and the DCO phase all free-run at
    # different periods, and an aligned prefix can be silently harmless.
    ("pluck POLY idle", 5,
     [('render', 1777), ('on', 60, 100), ('render', 10000), ('off', 60),
      ('render', 4000)]),
    ("chorus pad idle", 20,
     [('render', 6113), ('on', 48, 100), ('on', 55, 100), ('on', 64, 100),
      ('render', 10000), ('off', 48), ('off', 55), ('off', 64),
      ('render', 4000)]),
    ("delay keys idle", 2,
     [('render', 4391), ('on', 60, 100), ('on', 67, 100), ('render', 10000),
      ('off', 60), ('off', 67), ('render', 4000)]),
    ("DCO noise idle", 32,
     [('render', 953), ('on', 52, 100), ('render', 10000), ('off', 52),
      ('render', 4000)]),
    # A one-sample prefix on the patch the bug was found on. This is the
    # cheapest scenario in the set and it is the one that failed before the
    # fix, so it is the regression guard: if the retrigger arming is ever lost
    # again, THIS row goes red first.
    ("UNISON 1-idle", 61,
     [('render', 1), ('on', 48, 100), ('render', 6000), ('off', 48),
      ('render', 2000)]),
]
QUICK_TAGS = ["pluck POLY", "chorus pad", "UNISON 1-idle"]

# Scenarios whose patch is ARP-enabled would be meaningless: this oracle has no
# transport clock and cannot arpeggiate (see recall_render_ab). Guard it.
_ARP_PATCHES = {1, 9, 17, 25, 33, 41, 49}
for _t, _p, _s in SCEN:
    assert _p not in _ARP_PATCHES, "arp patch %d cannot be gated here" % _p


def pick(tags, quick):
    want = set(tags) if tags else (set(QUICK_TAGS) if quick else None)
    sel = [s for s in SCEN if want is None or s[0] in want]
    if want and len(sel) != len(want):
        raise SystemExit("unknown scenario tag(s): %s" %
                         (want - {s[0] for s in sel}))
    return sel


# ---------------------------------------------------------------------------
# PROCESS 1: the AUTHORITY. Unicorn only. Never loads a .so.
# ---------------------------------------------------------------------------
def ref_main(out_path, tags, quick):
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as AB
    if AB.SR != SR:
        # recall_render_ab reads JUNO_RENDER_SR; the driver sets it. If it did
        # not take, the reference would be built at a different rate than the
        # candidate and every scenario would diverge for a non-engine reason.
        raise SystemExit("ABORT: reference SR %g != gate SR %g" % (AB.SR, SR))
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    out = {"streams": {}, "sr": SR}
    for tag, patch, script in pick(tags, quick):
        e = AB.prepare_recall(patch, bank, leaves, E, R, SR)
        inter = []
        for ev in script:
            if ev[0] == 'on':
                e.note_on(ev[1], ev[2])
            elif ev[0] == 'off':
                e.note_off(ev[1])
            elif ev[0] == 'render':
                L, Rr = e.render(ev[1])
                for lb, rb in zip(L, Rr):
                    inter.append(struct.unpack("<f", struct.pack("<I", lb))[0])
                    inter.append(struct.unpack("<f", struct.pack("<I", rb))[0])
            else:
                raise SystemExit("event %r is not supported against the plugin"
                                 % (ev,))
        out["streams"][tag] = inter
        sys.stderr.write("  [AUTHORITY=plugin] %-13s patch %2d (%s): %d frames\n"
                         % (tag, patch, E.patch_name(bank, patch),
                            len(inter) // 2))
        sys.stderr.flush()
    with open(out_path, "wb") as f:
        pickle.dump(out, f, 2)


# ---------------------------------------------------------------------------
# PROCESS 2: the CANDIDATE. ctypes only. Never imports e2e_emu.
# ---------------------------------------------------------------------------
def cand_main(lib_path, out_path, tags, quick):
    import null_ab
    import truth
    lib = null_ab.load(lib_path)
    bank = open(truth.BANK, "rb").read()
    out = {"streams": {}, "sr": SR}
    for tag, patch, script in pick(tags, quick):
        out["streams"][tag] = null_ab.render_script(lib, bank, SR, patch, script)
    with open(out_path, "wb") as f:
        pickle.dump(out, f, 2)


# ---------------------------------------------------------------------------
# DRIVER: compiles and compares. Loads nothing.
# ---------------------------------------------------------------------------
def compare(ref, cand, label, strict):
    import null_ab
    gthr = -100.0 if strict else null_ab.THRESH_DB
    bthr = -80.0 if strict else null_ab.BLOCK_THRESH_DB
    print("=== PLUGIN CROSS-CHECK ===")
    print("  AUTHORITATIVE SIDE : the JUNO60.vst3 binary, executed under Unicorn")
    print("                       (its own recall + its own render; no port code)")
    print("  CANDIDATE SIDE     : %s" % label)
    print("  metrics            : tools/trackb/null_ab.py (imported, not rewritten)")
    print("  thresholds         : global %.0f dB / block %.0f dB%s"
          % (gthr, bthr, "  [--strict]" if strict else ""))
    print("  rate               : %g Hz\n" % SR)
    print("  %-13s %9s %11s %11s  %s"
          % ("scenario", "sig dBFS", "global dB", "block dB", "verdict"))
    nfail = 0
    for tag in [t for t, _, _ in SCEN if t in ref["streams"]]:
        r = ref["streams"][tag]
        c = cand["streams"].get(tag)
        if c is None:
            print("  %-13s MISSING on candidate side -> FAIL" % tag); nfail += 1
            continue
        sig, rel = null_ab.rel_residual(list(r), list(c))
        if rel is not None and rel > 900:
            print("  %-13s *** LENGTH MISMATCH %d vs %d -> FAIL ***"
                  % (tag, len(r), len(c)))
            nfail += 1
            continue
        blk = (None if rel is None else
               null_ab.block_residual(list(r), list(c), 10 ** (sig / 20.0)))
        # NON-VACUITY: the authority must actually be making sound, or
        # silence==silence would pass as identity.
        if sig < null_ab.SIG_FLOOR_DB:
            print("  %-13s %9.1f  *** REFERENCE SILENT (< %.0f dBFS) -> VACUOUS,"
                  " FAIL ***" % (tag, sig, null_ab.SIG_FLOOR_DB))
            nfail += 1
            continue
        ok = (rel is None or rel <= gthr) and (blk is None or blk <= bthr)
        if not ok:
            nfail += 1
        print("  %-13s %9.1f %11s %11s  %s"
              % (tag, sig,
                 "BIT-EXACT" if rel is None else "%.1f" % rel,
                 "-" if blk is None else "%.1f" % blk,
                 "ok" if ok else "FAIL"))
    print("\n  %d/%d agree with the PLUGIN (authority)."
          % (len(ref["streams"]) - nfail, len(ref["streams"])))
    return nfail


def run_side(argv, tmp, name):
    p = os.path.join(tmp, name + ".pkl")
    env = dict(os.environ, JUNO_RENDER_SR=("%g" % SR))
    r = subprocess.run([sys.executable, os.path.abspath(__file__)] + argv + [p],
                       env=env)
    if r.returncode:
        raise SystemExit("%s side failed (exit %d)" % (name, r.returncode))
    return pickle.load(open(p, "rb"))


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--check-port", action="store_true",
                    help="candidate = src/ built fresh. Expect EXACTLY 0.")
    ap.add_argument("--module", nargs="*", default=None,
                    help="engine B shim module(s), or 'all'")
    ap.add_argument("--cand", default=None, help="prebuilt candidate .so")
    ap.add_argument("--quick", action="store_true")
    ap.add_argument("--strict", action="store_true",
                    help="apply the engine B band (-100/-80) instead of -90/-70")
    ap.add_argument("--scen", nargs="*", default=None)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--teeth", action="store_true",
                    help="mutation battery: the gate is tested before it counts")
    a = ap.parse_args()

    if a.list:
        for t, p, s in SCEN:
            n = sum(e[1] for e in s if e[0] == 'render')
            print("  %-13s patch %2d  %6d frames  ~%.0f s of oracle time"
                  % (t, p, n, 4.5 + n * 5e-4))
        return 0

    tags = a.scen or []
    sel = pick(tags, a.quick)
    tagargs = [t for t, _, _ in sel]

    import null_b                       # compiles only; loads no library
    tmp = tempfile.mkdtemp(prefix="plugcheck_")
    try:
        if a.teeth:
            # The ONE reference render is reused across every mutant: the
            # authority does not change, only the candidate does. That is what
            # makes a mutation battery affordable against an emulated oracle.
            sys.stderr.write("teeth: rendering the AUTHORITY once, reused by "
                             "every mutant\n")
            ref = run_side(["--ref", "--scen"] + tagargs + ["--out"], tmp, "ref")
            # (mutation, must_fail). clean MUST be bit-exact -- it is the
            # non-vacuity proof; justover (~3e-5 rel, ~ -90 dB) MUST fail;
            # onelsb (~1 ULP, ~ -138 dB) MUST pass, so the gate is shown to
            # have a floor and not to be failing everything.
            plan = [(None, False), ("justover", True), ("onelsb", False)]
            bad = 0
            # MEASURED 2026-08-02, scenario "pluck POLY": clean = BIT-EXACT,
            # justover = -90.4 dB global / -90.4 dB block, onelsb = -133.1 /
            # -128.7. So the battery is run in the ENGINE B band (-100/-80),
            # not the default -90/-70: justover lands 0.4 dB INSIDE the -90
            # band and would be reported as a pass there. That is a real,
            # measured property of the default band and is why engine B's
            # standard is -100 -- it is not a threshold chosen to make this
            # battery green.
            a.strict = True
            for mut, must_fail in plan:
                lib = os.path.join(tmp, "m.so")
                null_b.build(lib, [], mutate=mut, quiet=True)
                cand = run_side(["--cand-worker", lib, "--scen"] + tagargs +
                                ["--out"], tmp, "cand")
                nf = compare(ref, cand, "src/ + mutation=%s" % (mut or "NONE"),
                             a.strict)
                got = "FAIL" if nf else "pass"
                exp = "FAIL" if must_fail else "pass"
                ok = (nf > 0) == must_fail
                if not ok:
                    bad += 1
                print("  TEETH %-10s expected %-4s got %-4s  %s\n"
                      % (mut or "clean", exp, got, "OK" if ok else "*** GATE "
                         "DEFECT ***"))
            print("TEETH: %s" % ("all mutations behaved as required"
                                 if not bad else "%d GATE DEFECT(S)" % bad))
            return 1 if bad else 0
        if a.cand:
            lib, label = os.path.abspath(a.cand), "prebuilt %s" % a.cand
        else:
            mods = [] if a.check_port else (a.module or [])
            if mods == ["all"]:
                mods = null_b.module_list()
            lib = os.path.join(tmp, "cand.so")
            null_b.build(lib, mods, quiet=False)
            label = ("src/ (THE PORT, built fresh)" if not mods
                     else "engine B, modules: %s" % ",".join(mods))
        if a.check_port and (a.module or a.cand):
            raise SystemExit("--check-port is exclusive with --module/--cand")

        sys.stderr.write("rendering the AUTHORITY (plugin under Unicorn) -- "
                         "%d scenario(s), expect ~%.0f s\n"
                         % (len(sel),
                            sum(4.5 + sum(e[1] for e in s if e[0] == 'render')
                                * 5e-4 for _, _, s in sel)))
        ref = run_side(["--ref"] + ["--scen"] + tagargs + ["--out"], tmp, "ref")
        cand = run_side(["--cand-worker", lib, "--scen"] + tagargs + ["--out"],
                        tmp, "cand")
        nfail = compare(ref, cand, label, a.strict)
        if a.check_port:
            print("\n  --check-port: src/ is claimed BIT-EXACT against this same")
            print("  oracle on the factory bank. Any non-zero residual above is a")
            print("  NEW PORT BUG (or a defect in THIS harness) and must be triaged")
            print("  before any engine B result is believed.")
        return 1 if nfail else 0
    finally:
        import shutil
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    # Sub-process entry points. The argument shape is fixed by run_side():
    #   --ref        --scen TAG... --out OUT.pkl
    #   --cand-worker LIB --scen TAG... --out OUT.pkl
    if len(sys.argv) > 1 and sys.argv[1] in ("--ref", "--cand-worker"):
        argv = sys.argv[1:]
        out = argv[-1]
        assert argv[-2] == "--out"
        body = argv[:-2]
        if body[0] == "--ref":
            tags = body[body.index("--scen") + 1:] if "--scen" in body else []
            ref_main(out, tags, False)
        else:
            libp = body[1]
            tags = body[body.index("--scen") + 1:] if "--scen" in body else []
            cand_main(libp, out, tags, False)
        sys.exit(0)
    sys.exit(main())
