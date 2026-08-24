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
import argparse, hashlib, os, re, shutil, subprocess, sys, time

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


def _sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


def sh(cmd, cwd, timeout=3600):
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, "TIMEOUT"


# Literal forms that actually occur in this port, in priority order. A mutation
# must land on CODE: comment text is masked out first (a CRC32 noted in a file
# header once produced a bogus "SURVIVED" -- the build was byte-identical).
LIT_PATTERNS = [
    r"0x[0-9a-fA-F]{4,}",                     # packed float bits / masks
    r"\b\d+\.\d+(?:[eE][-+]?\d+)?f?\b",       # decimal float constants
    r"\b\d{3,}\b",                            # state offsets / table indices
]


def _mask_comments(text):
    """Replace comment bodies with spaces, preserving offsets, so literal
    searches can never land inside a comment."""
    out = list(text)
    i, n = 0, len(text)
    while i < n:
        if text.startswith("/*", i):
            j = text.find("*/", i + 2)
            j = n if j < 0 else j + 2
            for k in range(i, j):
                if out[k] != "\n":
                    out[k] = " "
            i = j
        elif text.startswith("//", i):
            j = text.find("\n", i)
            j = n if j < 0 else j
            for k in range(i, j):
                out[k] = " "
            i = j
        else:
            i += 1
    return "".join(out)


def candidates(text, limit=6):
    """Distinct code literals worth mutating, in priority order."""
    masked = _mask_comments(text)
    seen, out = set(), []
    for rx in LIT_PATTERNS:
        for m in re.finditer(rx, masked):
            lit = m.group(0)
            if lit in seen:
                continue
            seen.add(lit)
            out.append((m.start(), m.end(), lit))
            if len(out) >= limit:
                return out
    return out


def perturb_at(text, span):
    """Apply a LARGE, unambiguous change to one literal. Large on purpose: if
    even this is invisible to every gate, the blind spot is not arguable."""
    s, e, lit = span
    if lit.startswith("0x"):
        new = lit[:-1] + ("1" if lit[-1].lower() != "1" else "2")
    elif "." in lit:
        head, _, tail = lit.rpartition(".")
        suf = "f" if tail.endswith("f") else ""
        digits = tail[:-1] if suf else tail
        bumped = str((int(digits or "0") + 5) % (10 ** max(1, len(digits))))
        bumped = bumped.rjust(len(digits) or 1, "0")
        new = "%s.%s%s" % (head, bumped, suf)
    else:
        new = str(int(lit) + 1)
    if new == lit:
        return None, None
    return text[:s] + new + text[e:], "%s -> %s" % (lit, new)


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

    # Baseline build: its hash is how we tell a REAL mutation from a no-op.
    rc, out = sh(["make", "-s", "libjuno.so"], wt, timeout=1800)
    if rc != 0:
        raise SystemExit("baseline build failed:\n" + out[-2000:])
    base_hash = _sha(os.path.join(wt, "libjuno.so"))
    print("[mut] baseline libjuno.so %s" % base_hash[:12])

    results = []
    for name, dim, rel, _rx, _occ in muts:
        path = os.path.join(wt, rel)
        if not os.path.exists(path):
            print("%-14s SKIP (no %s)" % (name, rel)); continue
        orig = open(path).read()
        cands = candidates(orig)
        if not cands:
            print("%-14s SKIP (no code literal found)" % name); continue

        t0, tried, killers, ineffective = time.time(), [], [], 0
        for span in cands:
            newtext, what = perturb_at(orig, span)
            if newtext is None:
                continue
            open(path, "w").write(newtext)
            rc, _ = sh(["make", "-s", "libjuno.so"], wt, timeout=1800)
            if rc != 0:
                open(path, "w").write(orig)
                continue                      # mutation did not compile; try next
            if _sha(os.path.join(wt, "libjuno.so")) == base_hash:
                open(path, "w").write(orig)
                ineffective += 1              # no-op (dead code / folded away)
                continue
            tried.append(what)
            for gname, cmd in GATES:
                grc, _ = sh(cmd, wt, timeout=3600)
                if grc != 0:
                    killers.append((gname, what)); break
            open(path, "w").write(orig)
            if killers or len(tried) >= 3:
                break

        open(path, "w").write(orig)
        if not tried:
            print("%-14s SKIP (no EFFECTIVE mutation; %d no-ops)" % (name, ineffective))
            continue
        if killers:
            verdict = "KILLED by %s" % killers[0][0]
        else:
            verdict = "*** SURVIVED %d effective mutation(s) ***" % len(tried)
        print("%-14s %-28s %-24s %s  (%.0fs)"
              % (name, dim, tried[-1][:24], verdict, time.time() - t0))
        results.append((name, dim, bool(killers), tried))

    surv = [r for r in results if not r[2]]
    print("\n=== MUTATION REACH: %d/%d killed, %d SURVIVED ==="
          % (len(results) - len(surv), len(results), len(surv)))
    for n, d, _, tried in surv:
        print("  BLIND SPOT: %-14s %-28s (tried: %s)" % (n, d, "; ".join(tried)))
    if surv:
        print("\nEach survivor is a fault the port could carry TODAY with every gate green.")
        print("A survivor is only believable because the build hash CHANGED: no-op")
        print("mutations are reported as SKIP, never as SURVIVED.")
    return 1 if surv else 0


if __name__ == "__main__":
    sys.exit(main())
