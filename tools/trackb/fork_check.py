#!/usr/bin/env python3
"""fork_check.py — has the sealed original moved out from under the fork?

native/<x>.c starts as a verbatim copy of src/<x>.c and is then rewritten. src/
stays a party to the bit-exact seal `make verify` proves against the plugin
binary; native/ is the SUBJECT of the weaker sonic-identity claim. The moment
someone fixes a real bug in src/voice_render.c, the fork silently stops
containing that fix -- and the null A/B may not notice, because a fix that no
null_ab scenario exercises produces no residual. That is a false green with a
long fuse: the candidate is measured against a reference it no longer descends
from.

So each fork records the SHA-256 of the upstream file it was taken from, in its
header:

    *   forked from : src/voice_render.c
    *   at sha256   : <64 hex>

This tool checks every native/*.c header against the current src/ file and fails
if they disagree. When they do, the fix is NOT to edit the SHA: re-read the
upstream diff, port whatever it changed into the fork by hand, re-run the full
acceptance gate (`null_ab.py --cand ... --all`), and only then record the new
SHA with `--update`.

  fork_check.py            check every fork      (exit 1 on drift)
  fork_check.py --update   re-record the SHAs after a reviewed port-across
"""
import sys, os, re, glob, hashlib

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
PAT = re.compile(r'^\s*\*\s*forked from\s*:\s*(\S+)\s*$\s*^\s*\*\s*at sha256\s*:\s*'
                 r'([0-9a-f]{64})\s*$', re.M)


def sha(path):
    with open(path, 'rb') as fh:
        return hashlib.sha256(fh.read()).hexdigest()


def main():
    update = "--update" in sys.argv
    forks = sorted(glob.glob(os.path.join(REPO, "native", "*.c")))
    if not forks:
        print("no native/*.c -- nothing forked, nothing to check")
        return 0
    bad = 0
    for f in forks:
        text = open(f).read()
        m = PAT.search(text)
        rel = os.path.relpath(f, REPO)
        if not m:
            print("  %-28s *** NO FORK PROVENANCE HEADER *** -- add 'forked from'"
                  " / 'at sha256' lines" % rel)
            bad += 1
            continue
        upstream, recorded = m.group(1), m.group(2)
        up_path = os.path.join(REPO, upstream)
        if not os.path.exists(up_path):
            print("  %-28s *** upstream %s MISSING ***" % (rel, upstream))
            bad += 1
            continue
        now = sha(up_path)
        if now == recorded:
            print("  %-28s ok   (%s unchanged since the fork)" % (rel, upstream))
            continue
        if update:
            open(f, 'w').write(text[:m.start(2)] + now + text[m.end(2):])
            print("  %-28s UPDATED to %s...  (you asserted the change is ported)"
                  % (rel, now[:16]))
            continue
        bad += 1
        print("  %-28s *** DRIFT ***  %s has changed since this fork was taken\n"
              "      recorded %s\n      current  %s\n"
              "      The fork does not contain whatever changed. Port it across by\n"
              "      hand, re-run `null_ab.py --cand ... --all`, then --update."
              % (rel, upstream, recorded[:32], now[:32]))
    print("FORK CHECK: %s" % ("PASS" if bad == 0 else "FAIL (%d fork(s))" % bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
