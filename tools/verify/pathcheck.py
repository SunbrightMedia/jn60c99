#!/usr/bin/env python3
"""pathcheck.py — no gate may DEFAULT to a path outside the repository.

WHY THIS EXISTS. Two gates in `make verify` defaulted their scratch directory
to `/tmp/claude-.../<session-uuid>/scratchpad` — the scratch directory of the
session that wrote them. Sessions are ephemeral. In every later container that
directory does not exist, so `assigner_ab.py` and `renderstruct_ab.py` both
died with FileNotFoundError after doing all their work, and `make verify`
exited non-zero for a reason that had nothing to do with the port.

That is worse than a broken gate: it is a gate that LOOKS like a port failure.
Someone reading only the exit code would go hunting in the engine. CLAUDE.md had
already recorded this sharp edge for `coldstate_ab.py`; recording it did not
stop it spreading to three more files, so it is a check now.

WHAT IS AND IS NOT ALLOWED. A gate may take a path from the environment — that
is how a caller redirects scratch — and it may default to anything under the
repository. It may not DEFAULT to an absolute path outside it. The distinction
matters: `os.environ.get('JUNO_SCRATCH', <repo>/scratchpad)` is fine;
defaulting to a /tmp/claude session directory is the defect.

SCOPE (WIDENED 2026-10-05): EVERY .py under tools/, and the class is ANY
absolute /home/... or /tmp/claude-... literal, not only scratch directories.
The old scope (scripts named in the verify target, scratch paths only) let
~90 files hardcode the checkout's own absolute path: a git worktree then imported the
MAIN tree's tools, loaded the MAIN tree's libjuno.so and wrote the MAIN tree's
scratchpad. That silently broke the isolation tools/verify/mutation_gate.py
depends on (a mutated worktree build was never the library some gates
loaded) and any run on another machine or path. A gate's imported helpers are
gates too, and a "one-shot" tool is one promotion away from being run, so the
scan now covers all of them. Derive paths from __file__ (see truth.py).
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))

# The absolute-path shapes that do not survive a container. Anything under the
# repo is fine, and so is a bare /tmp/<something> a test creates itself.
BAD = re.compile(r"['\"](/tmp/claude-[^'\"]*|/home/[^'\"]*|/root/[^'\"]*)['\"]")


def gates_in_verify():
    """The scripts `make verify` runs, read from the Makefile itself so this
    check cannot drift away from the target it is protecting."""
    mk = open(os.path.join(REPO, "Makefile")).read()
    m = re.search(r"^verify:.*?(?=^\S|\Z)", mk, re.M | re.S)
    if not m:
        raise SystemExit("pathcheck: no `verify:` target in the Makefile -- "
                         "this check cannot know what to protect.")
    return sorted(set(re.findall(r"tools/verify/[a-z_0-9]+\.py", m.group(0))))


def tools_py():
    """Every Python file under tools/ (gates, their helpers, and the one-shot
    tools that can be promoted into gates)."""
    out = []
    for d, dirs, files in os.walk(os.path.join(REPO, "tools")):
        dirs[:] = [x for x in dirs if x != "__pycache__"]
        for f in files:
            if f.endswith(".py"):
                out.append(os.path.relpath(os.path.join(d, f), REPO))
    return sorted(out)


def main():
    bad = []
    gates_in_verify()                       # still refuses a Makefile without verify:
    for rel in tools_py():
        p = os.path.join(REPO, rel)
        for n, line in enumerate(open(p, encoding="utf-8", errors="replace"), 1):
            if line.lstrip().startswith("#"):
                continue
            for hit in BAD.finditer(line):
                # ANY absolute literal is the defect, including one that names
                # this very checkout: it is wrong in every other checkout.
                bad.append((rel, n, hit.group(1)))

    for rel, n, s in bad:
        print("  %s:%d defaults to a path outside the repo: %s" % (rel, n, s))
    if bad:
        print("PATHCHECK: FAIL -- %d hardcoded absolute path(s) in "
              "tools/ (gates and their helpers).\n"
              "  These die in any container but the one that wrote them, and the "
              "failure looks like a port defect.\n"
              "  WHAT TO DO: default to <repo>/scratchpad and keep the "
              "environment override." % len(bad))
        return 1
    print("PATHCHECK: OK -- no absolute path literal in any tools/ Python file")
    return 0


if __name__ == "__main__":
    sys.exit(main())
