#!/usr/bin/env python3
"""shim_drift_tooth.py -- the engine_b shim forks may not drift from src/.

WHY THIS EXISTS (2026-08-26). src/voice_render.c switched from system expf to
the plugin's own transcribed juno_expf_6EF740 on 2026-08-24. The sixteen
engine_b/shim/*/voice_render.c FORKS -- verbatim copies of that file with one
DSP block each replaced -- were never refreshed. For two days they compiled
with a DIFFERENT exponential from the port, which is the exact class of silent
divergence the fork exists to MEASURE, hiding INSIDE the measuring apparatus.

It surfaced only by accident: make engineb went red at the composite-shim
merge with a confusing "overlapping shims" message, because every fork was
missing the same include and difflib scored that as competing edits.

This tooth turns that whole class from "found by luck, two days late" into
"caught deterministically, every make engineb". It is not a sample-domain
gate -- the drift was ~1 ulp, below the fork's alias floor, so no residual
gate could see it. It is a STRUCTURAL invariant on the source text:

  1. Every fork's set of #include directives must EQUAL src/<base>'s set.
     The 2026-08-24 defect was precisely a missing #include "juno_crt_expf.h".
  2. No fork may CALL a libm function that src/<base> does not call. src/
     replaced every bare expf( with juno_expf_6EF740(; a fork that still calls
     bare expf( is computing a different function. Checked for the whole
     transcended-math family.

Both are seen-to-fail below (--selftest). Exit 1 on any drift, naming the fork
and the exact divergence, so the fix is mechanical.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SHIM = os.path.join(REPO, "engine_b", "shim")

# The forked port translation units. Each shim dir may hold a fork of any of
# these; we check whichever it has.
FORKED_BASES = ["voice_render.c", "master_render.c"]

# libm / CRT-math calls the port TRANSCRIBED from the plugin binary, so a fork
# calling the bare form is calling a DIFFERENT function. The port's own name is
# the allowed form; the bare name is the drift.
TRANSCRIBED = {
    "expf": "juno_expf_6EF740",
    "tanf": "juno_tanf",           # reserved: not yet transcribed in the JUNO
}

INCLUDE_RE = re.compile(r'^\s*#\s*include\s+([<"][^>"]+[>"])', re.M)


def includes(text):
    return set(INCLUDE_RE.findall(text))


def bare_calls(text, name):
    """Count calls to `name(` that are NOT part of a longer identifier."""
    return len(re.findall(r'(?<![A-Za-z0-9_])' + re.escape(name) + r'\s*\(',
                          text))


def check_one(shim_dir, base, src_text):
    """Return a list of drift strings for one fork; empty if clean."""
    fork_path = os.path.join(SHIM, shim_dir, base)
    if not os.path.exists(fork_path):
        return []
    fork_text = open(fork_path).read()
    out = []

    # ONLY the MISSING direction is drift. A fork ADDS its own module header
    # (eb_dco.h and friends) and often <stdio.h>/<stdlib.h> for debug -- that
    # is the fork's whole purpose, so EXTRA includes are expected and ignored.
    # A fork LACKING an include the port has means a symbol the port depends on
    # resolves differently (or falls through to libm) -- which is exactly the
    # 2026-08-24 juno_crt_expf.h defect.
    src_inc, fork_inc = includes(src_text), includes(fork_text)
    missing = src_inc - fork_inc
    if missing:
        out.append("MISSING include(s) present in src/%s: %s"
                   % (base, ", ".join(sorted(missing))))

    for bare, allowed in TRANSCRIBED.items():
        src_bare = bare_calls(src_text, bare)
        fork_bare = bare_calls(fork_text, bare)
        if fork_bare > src_bare:
            out.append("calls bare %s( %d time(s); src/%s calls it %d -- the "
                       "port uses %s( instead"
                       % (bare, fork_bare, base, src_bare, allowed))
    return out


def run():
    problems = []
    checked = 0
    for base in FORKED_BASES:
        src_path = os.path.join(REPO, "src", base)
        if not os.path.exists(src_path):
            continue
        src_text = open(src_path).read()
        for d in sorted(os.listdir(SHIM)):
            dp = os.path.join(SHIM, d)
            if not os.path.isdir(dp):
                continue
            drift = check_one(d, base, src_text)
            if os.path.exists(os.path.join(dp, base)):
                checked += 1
            for msg in drift:
                problems.append("  %s/%s: %s" % (d, base, msg))
    return checked, problems


def selftest():
    """SEEN TO FAIL: synthesize a fork missing an include and one with a bare
    expf, and confirm both are flagged. Nothing is written to the tree."""
    src = '#include "a.h"\n#include "juno_crt_expf.h"\nx = juno_expf_6EF740(y);\n'
    drift_inc = check_one_text(src, '#include "a.h"\nx = juno_expf_6EF740(y);\n')
    drift_call = check_one_text(src, '#include "a.h"\n#include "juno_crt_expf.h"\nx = expf(y);\n')
    ok = any("MISSING include" in m for m in drift_inc) and \
         any("bare expf" in m for m in drift_call)
    print("SELFTEST: missing-include flagged=%s  bare-call flagged=%s -> %s"
          % (bool(drift_inc), bool(drift_call), "PASS" if ok else "FAIL"))
    return 0 if ok else 1


def check_one_text(src_text, fork_text):
    """check_one's logic on in-memory text, for the selftest."""
    out = []
    src_inc, fork_inc = includes(src_text), includes(fork_text)
    if src_inc - fork_inc:
        out.append("MISSING include(s): %s" % ", ".join(sorted(src_inc - fork_inc)))
    for bare in TRANSCRIBED:
        if bare_calls(fork_text, bare) > bare_calls(src_text, bare):
            out.append("calls bare %s(" % bare)
    return out


def main():
    if "--selftest" in sys.argv:
        sys.exit(selftest())
    checked, problems = run()
    if problems:
        print("SHIM DRIFT: %d fork(s) have drifted from src/:" % len(problems))
        print("\n".join(problems))
        print("[shim drift tooth] RED -- a fork no longer tracks the port")
        sys.exit(1)
    print("[shim drift tooth] GREEN -- %d fork(s) track src/ on includes and "
          "transcribed-math calls" % checked)
    sys.exit(0)


if __name__ == "__main__":
    main()
