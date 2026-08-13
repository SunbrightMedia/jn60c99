#!/usr/bin/env python3
"""approx_audit.py -- THERE ARE ZERO APPROXIMATIONS IN THE PORT, AND IT IS CHECKED.

USER-BINDING, 2026-08-13, in the user's words: "THERE SHOULD BE ABSOLUTELY ZERO
APPROXIMATIONS IN THE FIRST PORT. NONE. IT SHOULD BE BIT EXACT AND
MICROSCOPICALLY IDENTICAL."

WHY A GATE AND NOT A PROMISE. On the day that was said, the port WAS free of
approximations -- and a comment in src/delay_recall.c still claimed the delay's
tempo-sync law was unresolved and that the manual formula "lands the tap close".
That sentence had outlived the work that replaced it by months. It was read as
evidence of a live approximation and reported to the user as one.

A stale comment is a defect in both directions. It invents defects that do not
exist, and on another day it lets a real one be waved past as "that old known
thing". In a codebase whose entire method is that the comments carry the
evidence, an out-of-date comment is a broken gate.

So "zero approximations" stops being something a human asserts after reading for
ten minutes, and becomes something the build checks every run.

HOW IT WORKS. Every marker word below is banned in src/ unless the line, or a
line near it, carries an explicit justification tag:

    APPROX-OK: <reason>     this describes the PLUGIN'S own behaviour, or a
                            placeholder that proven code overwrites in the same
                            call -- NOT an approximation in our arithmetic.

The tag is deliberately ugly to type. Adding one should feel like a decision.

⚠ WHAT THIS GATE CANNOT DO, stated so nobody mistakes it for more than it is:
it reads COMMENTS. It cannot see an approximation that was never described. It
is a net for the class of defect that has actually occurred here -- a derived
law left unfinished and documented as such -- and not a proof of exactness. The
proof of exactness is the null gates and the render A/B; this only makes sure
nobody has written down that they knowingly fell short.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRC = os.path.join(REPO, 'src')

# Words that describe falling short of the plugin. Case-insensitive.
MARKERS = [
    r'approximat',
    r'\bnot exact\b',
    r'close enough',
    r'lands? .{0,20}close',
    r'until the .{0,40}(law|value|formula) is derived',
    r'\bguess(ed|ing)?\b',
    r'\bfitted\b',
    r'matches only a subset',
    r'\bTODO\b',
    r'\bFIXME\b',
    r'\bXXX\b',
    r'\bfor now\b',
    r'\bplaceholder\b',
    r'\bopen (sync )?item\b',
]
JUSTIFY = 'APPROX-OK:'
NEAR = 14         # a justification may sit within this many lines of the marker
                  # (14, not 6: these are long block comments and the tag belongs
                  # at the TOP of the paragraph it justifies, not next to the word)

# ⚠ NEGATIONS ARE NOT SHORTFALLS, and the first run of this gate proved it: 17 of
# 17 hits were sentences ASSERTING exactness -- "never guessed", "nothing is
# fitted", "no captures, no fitted curves" -- or describing a defect that was
# ALREADY FIXED ("an earlier version was an approximation"). A gate that flags
# the claim of correctness trains people to ignore it, which is worse than not
# having it. So a marker preceded on its own line by any of these is skipped.
NEGATED = re.compile(
    r'(never|\bnot\b|\bno\b|nothing|none|refuse|rather than|instead of|was an|were an|'
    r'used to|old |former|earlier|previously|stale|no-guess)', re.I)


def main():
    bad = []
    n_files = n_marks = n_ok = 0
    for fn in sorted(os.listdir(SRC)):
        if not fn.endswith(('.c', '.h')):
            continue
        n_files += 1
        path = os.path.join(SRC, fn)
        lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
        for i, line in enumerate(lines):
            low = line.lower()
            hit = next((m for m in MARKERS if re.search(m, low)), None)
            if not hit:
                continue
            # the marker's own line asserts the opposite -> not a shortfall
            m = re.search(hit, low)
            # The PREVIOUS line too: these are wrapped block comments, and
            # "derived, not" / "guessed" split across a line break is the same
            # sentence. Checking one line only reported voice_render.c's own
            # statement that its strides are derived RATHER than guessed.
            prev = lines[i - 1] if i else ''
            if (NEGATED.search(line[:m.start()]) or NEGATED.search(line)
                    or NEGATED.search(prev[-60:])):
                continue
            n_marks += 1
            lo, hi = max(0, i - NEAR), min(len(lines), i + NEAR + 1)
            if any(JUSTIFY in l for l in lines[lo:hi]):
                n_ok += 1
                continue
            bad.append((fn, i + 1, hit, line.strip()[:100]))

    print('=== APPROXIMATION AUDIT (src/) ===')
    print('files %d   markers %d   justified %d   UNJUSTIFIED %d'
          % (n_files, n_marks, n_ok, len(bad)))
    if bad:
        print('\n*** UNJUSTIFIED APPROXIMATION MARKERS ***')
        print('Each line either describes a real shortfall -- which is a DEFECT,')
        print('the user\'s standard is zero -- or is stale, which is also a defect.')
        print('Resolve it, or tag the line with "%s <reason>".\n' % JUSTIFY)
        for fn, ln, m, txt in bad:
            print('  %s:%d  [%s]' % (fn, ln, m))
            print('      %s' % txt)
        print('\nAUDIT: FAIL')
        return 1
    print('AUDIT: PASS -- no unjustified approximation marker in the port.')
    print('(This reads COMMENTS. It cannot see an approximation nobody wrote'
          ' down; the null gates and render A/B are what prove exactness.)')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
