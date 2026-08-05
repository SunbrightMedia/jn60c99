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
`os.environ.get('JUNO_SCRATCH', '/tmp/claude-.../scratchpad')` is the defect.

SCOPE: only the scripts `make verify` actually runs. The one-shot derivation
tools in tools/verify carry the same dead paths and are deliberately not
checked — they are not gates, they are not run by anything, and failing the
build for them would be noise. If one is ever promoted to a gate, it lands here.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))

# The absolute-path shapes that do not survive a container. Anything under the
# repo is fine, and so is a bare /tmp/<something> a test creates itself.
BAD = re.compile(r"['\"](/tmp/claude-[^'\"]*|/home/[^/'\"]+/[^'\"]*scratchpad[^'\"]*)['\"]")


def gates_in_verify():
    """The scripts `make verify` runs, read from the Makefile itself so this
    check cannot drift away from the target it is protecting."""
    mk = open(os.path.join(REPO, "Makefile")).read()
    m = re.search(r"^verify:.*?(?=^\S|\Z)", mk, re.M | re.S)
    if not m:
        raise SystemExit("pathcheck: no `verify:` target in the Makefile -- "
                         "this check cannot know what to protect.")
    return sorted(set(re.findall(r"tools/verify/[a-z_0-9]+\.py", m.group(0))))


def main():
    bad = []
    for rel in gates_in_verify():
        p = os.path.join(REPO, rel)
        if not os.path.exists(p):
            continue
        for n, line in enumerate(open(p), 1):
            if line.lstrip().startswith("#"):
                continue
            for hit in BAD.finditer(line):
                s = hit.group(1)
                if s.startswith(REPO + os.sep) or s == REPO:
                    continue        # inside the repo: fine
                bad.append((rel, n, s))

    for rel, n, s in bad:
        print("  %s:%d defaults to a path outside the repo: %s" % (rel, n, s))
    if bad:
        print("PATHCHECK: FAIL -- %d hardcoded external path(s) in gates that "
              "`make verify` runs.\n"
              "  These die in any container but the one that wrote them, and the "
              "failure looks like a port defect.\n"
              "  WHAT TO DO: default to <repo>/scratchpad and keep the "
              "environment override." % len(bad))
        return 1
    print("PATHCHECK: OK -- every gate in `make verify` defaults inside the repo")
    return 0


if __name__ == "__main__":
    sys.exit(main())
