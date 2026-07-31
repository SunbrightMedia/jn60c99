#!/usr/bin/env python3
"""freshlib.py — the stale-artifact guard (docs/ROADMAP_EMBEDDED.md P0 item 3).

Twice in one day (2026-07-31) a FALSE GREEN came from testing a stale artifact:
a prebuilt tests/ binary during a broken source pilot, and a libjuno.so left
over from a FAILED compile. The gates were right both times; the artifact under
test was old.

This module is the single choke point for port-side gates: it refuses to hand
out libjuno.so if ANY of its build inputs (src/*.c, src/*.h, gui/juno_bridge.c
— exactly the Makefile rule's prerequisites) is newer than the library.
`make verify` always rebuilds first; this guard exists for MANUALLY-run gates,
which is where the trap lives.

Paths are __file__-relative, so a git worktree gates ITS OWN libjuno.so (and
fails loudly if it was never built) instead of silently gating the main
tree's — the coldstate_ab sharp edge documented in CLAUDE.md.
"""
import os, glob, ctypes

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LIB = os.path.join(REPO, 'libjuno.so')


def check(lib=LIB):
    """Assert lib exists and is newer than every engine source; return its path."""
    if not os.path.exists(lib):
        raise SystemExit("STALE-GUARD: %s does not exist -- run `make libjuno.so` first"
                         % lib)
    lm = os.path.getmtime(lib)
    srcs = (glob.glob(os.path.join(REPO, 'src', '*.c')) +
            glob.glob(os.path.join(REPO, 'src', '*.h')) +
            [os.path.join(REPO, 'gui', 'juno_bridge.c')])
    stale = sorted(s for s in srcs if os.path.exists(s) and os.path.getmtime(s) > lm)
    if stale:
        raise SystemExit(
            "STALE-GUARD: libjuno.so is OLDER than %d engine source file(s):\n  %s\n"
            "Gating it now risks a FALSE GREEN (bit twice on 2026-07-31).\n"
            "Rebuild first: make libjuno.so" %
            (len(stale), '\n  '.join(os.path.relpath(s, REPO) for s in stale)))
    return lib


def load(lib=LIB):
    """check() then ctypes-load -- drop-in for ctypes.CDLL('<repo>/libjuno.so')."""
    return ctypes.CDLL(check(lib))
