#!/usr/bin/env python3
"""mutation_gate.py -- MEASURE THE REACH OF THE GATES (playbook 80 rule 5).

The JX-3P defect taught the lesson the hard way: a differential gate cannot
detect a dimension neither side exercises, so "all gates green" says nothing
about the dimensions the gates never touch. Reading the gates cannot tell you
what they miss. Breaking the port on purpose can.

For each mutation below we inject ONE deliberate fault into the port, rebuild,
and run a gate subset:

  KILLED   >=1 gate turns red  -> that fault class IS covered. Good.
  SURVIVED  every gate stays green -> a BLIND SPOT. The port could be wrong in
            exactly that way today and every gate would still report green.

Survivors are the output that matters. Each one is a gate that needs writing.

Runs inside a throwaway git worktree so the real tree is never mutated (the
CLAUDE.md freeze rule stays intact). freshlib.py resolves paths relative to
__file__, so the worktree gates ITS OWN libjuno.so -- the property that makes
this safe. The worktree's scratchpad is symlinked to the main one so the
ORACLE-side reference pickles are reused: they come from the plugin and are
unaffected by any port mutation.

usage: mutation_gate.py [--list] [--only NAME] [--jobs N]
"""
import argparse, os, re, shutil, subprocess, sys, time

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCRATCH = os.path.join(REPO, "scratchpad")

# Each mutation: (name, dimension it probes, file, literal-regex, occurrence)
# The chosen literal is perturbed in its last digit -- a change small enough to
# be a plausible transcription slip, large enough to be bit-visible.
MUTATIONS = [
    ("voice_const",   "voice DSP arithmetic",      "src/voice_render.c",   r"0x[0-9a-fA-F]{8}", 0),
    ("master_const",  "master chain arithmetic",   "src/master_render.c",  r"0x[0-9a-fA-F]{8}", 0),
    ("reverb_const",  "reverb coefficients",       "src/reverb_recall.c",  r"0x[0-9a-fA-F]{8}", 0),
    ("chorus_const",  "chorus recall",             "src/chorus_recall.c",  r"0x[0-9a-fA-F]{8}", 0),
    ("delay_const",   "delay recall",              "src/delay_recall.c",   r"0x[0-9a-fA-F]{8}", 0),
    ("effmode_const", "effect-mode routing",       "src/effect_modes.c",   r"0x[0-9a-fA-F]{8}", 0),
    ("ramp_const",    "parameter-smoothing ramps", "src/juno_ramp.c",      r"0x[0-9a-fA-F]{8}", 0),
    ("init_const",    "cold init / prepare",       "src/juno_init.c",      r"0x[0-9a-fA-F]{8}", 0),
    ("prepare_const", "sample-rate dependence",    "src/juno_prepare.c",   r"0x[0-9a-fA-F]{8}", 0),
    ("arp_const",     "arpeggiator",               "src/carp.c",           r"0x[0-9a-fA-F]{8}", 0),
    ("apply_const",   "recall applier",            "src/juno_apply.c",     r"0x[0-9a-fA-F]{8}", 0),
    ("note_const",    "note path",                 "src/juno_note.c",      r"0x[0-9a-fA-F]{8}", 0),
    ("hpf_const",     "HPF type table",            "src/hpf_type_lut.c",   r"0x[0-9a-fA-F]{8}", 0),
    ("finefx_const",  "fine-FX recall",            "src/finefx_recall.c",  r"0x[0-9a-fA-F]{8}", 0),
]

# Gate subset: broad coverage, each reasonably quick against a prebuilt oracle ref.
GATES = [
    ("recall",     [sys.executable, "tools/verify/recall_gate.py"]),
    ("render_ab",  [sys.executable, "tools/verify/recall_render_ab.py", "--port"]),
    ("fuzz",       [sys.executable, "tools/verify/fuzz_diff.py", "--port"]),
    ("coldstate",  [sys.executable, "tools/verify/coldstate_ab.py", "--port", "44100"]),
    ("etmode",     [sys.executable, "tools/verify/etmode_ab.py", "--port"]),
    ("arp_render", [sys.executable, "tools/verify/arp_render_ab.py", "--port"]),
    ("warm",       [sys.executable, "tools/verify/warm_recall_gate.py", "--port",
                    "--seq", "0,0", "--cells", "91232"]),
]


def sh(cmd, cwd, timeout=3600):
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, "TIMEOUT"


def perturb(text, rx, occ):
    """Change the last hex digit of the occ-th literal matching rx."""
    ms = list(re.finditer(rx, text))
    if len(ms) <= occ:
        return None, None
    m = ms[occ]
    lit = m.group(0)
    last = lit[-1]
    new_last = "0" if last.lower() in "12345678" and last != "0" else "1"
    # ensure an actual change
    if new_last == last:
        new_last = "2"
    new = lit[:-1] + new_last
    if new == lit:
        return None, None
    return text[:m.start()] + new + text[m.end():], "%s -> %s" % (lit, new)


def make_worktree(wt):
    if os.path.exists(wt):
        sh(["git", "worktree", "remove", "--force", wt], REPO)
        shutil.rmtree(wt, ignore_errors=True)
    rc, out = sh(["git", "worktree", "add", "--detach", wt, "HEAD"], REPO)
    if rc != 0:
        raise SystemExit("worktree add failed:\n" + out)
    # reuse the ORACLE-side reference pickles (plugin-derived, mutation-independent)
    link = os.path.join(wt, "scratchpad")
    if os.path.exists(link) or os.path.islink(link):
        shutil.rmtree(link, ignore_errors=True) if os.path.isdir(link) and not os.path.islink(link) else os.remove(link)
    os.symlink(SCRATCH, link)
    return wt


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--only", default=None)
    ap.add_argument("--worktree", default=os.path.join("/tmp", "juno_mut"))
    a = ap.parse_args()

    muts = [m for m in MUTATIONS if not a.only or m[0] == a.only]
    if a.list:
        for n, d, f, _, _ in muts:
            print("%-14s %-28s %s" % (n, d, f))
        return 0

    wt = make_worktree(a.worktree)
    print("[mut] worktree %s" % wt)
    results = []
    for name, dim, rel, rx, occ in muts:
        path = os.path.join(wt, rel)
        if not os.path.exists(path):
            print("%-14s SKIP (no %s)" % (name, rel)); continue
        orig = open(path).read()
        newtext, what = perturb(orig, rx, occ)
        if newtext is None:
            print("%-14s SKIP (no literal matched)" % name); continue
        open(path, "w").write(newtext)
        t0 = time.time()
        rc, out = sh(["make", "-s", "libjuno.so"], wt, timeout=1800)
        if rc != 0:
            open(path, "w").write(orig)
            print("%-14s SKIP (build failed)" % name); continue
        killers = []
        for gname, cmd in GATES:
            grc, gout = sh(cmd, wt, timeout=3600)
            if grc != 0:
                killers.append(gname)
                break          # one red gate is enough to call it KILLED
        open(path, "w").write(orig)
        verdict = "KILLED by %s" % killers[0] if killers else "*** SURVIVED ***"
        print("%-14s %-28s %-22s %s  (%.0fs)"
              % (name, dim, what, verdict, time.time() - t0))
        results.append((name, dim, bool(killers), killers))

    surv = [r for r in results if not r[2]]
    print("\n=== MUTATION REACH: %d/%d killed, %d SURVIVED ==="
          % (len(results) - len(surv), len(results), len(surv)))
    for n, d, _, _ in surv:
        print("  BLIND SPOT: %-14s %s" % (n, d))
    if surv:
        print("\nEach survivor is a fault the port could carry today with every gate green.")
    return 1 if surv else 0


if __name__ == "__main__":
    sys.exit(main())
