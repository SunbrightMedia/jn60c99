#!/usr/bin/env python3
"""SCOPE Q3 — is the plugin's render output INVARIANT to host block size?

The real per-block render (rva 0x3C7400) does per-BLOCK work before the voices:
buffer resize, assigner voice-count sync, and sub_7FF91DFB5AB0(assign,n) which is
`*(assign+168) += n` (a sample counter read elsewhere as counter/96). If any DSP
depends on where block boundaries fall, a real host (64..512 frames) diverges from
our oracle's block=600 — and the port, which is sample-by-sample, can only match
one of them. The port is bit-exact vs oracle@600 today.

Renders the SAME patch/note at several block sizes through the plugin's own DSP
and compares bit-exactly. Oracle-only (Unicorn); no libjuno in this process.
Covenant-clean: plugin's own code, observed.

Usage: blocksize_invariance.py [patch] [--sr 44100] [--n 12000]
"""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RA

def getarg(flag, dflt):
    return type(dflt)(sys.argv[sys.argv.index(flag)+1]) if flag in sys.argv else dflt

PATCH = int([a for a in sys.argv[1:] if a.isdigit()][0]) if [a for a in sys.argv[1:] if a.isdigit()] else 2
SR    = getarg('--sr', 44100.0)
N     = getarg('--n', 12000)
BLOCKS = [600, 512, 256, 128, 64, 1]

bank   = E.bank_bytes()
leaves = R.leaf_table()

ref = None
print("patch %d  sr=%g  n=%d" % (PATCH, SR, N), flush=True)
for b in BLOCKS:
    e = RA.prepare_recall(PATCH, bank, leaves, E, R, SR)
    e.note_on(60, 100)
    L, Rr = e.render(N, block=b)
    del e
    if ref is None:
        ref = (L, Rr); print("  block %4d : REFERENCE" % b, flush=True); continue
    dl = sum(1 for x, y in zip(ref[0], L) if x != y)
    dr = sum(1 for x, y in zip(ref[1], Rr) if x != y)
    first = next((i for i,(x,y) in enumerate(zip(ref[0], L)) if x != y), None)
    print("  block %4d : L-diff %6d / %d   R-diff %6d   first@%s   %s"
          % (b, dl, len(L), dr, first, "BIT-EXACT" if dl==0 and dr==0 else "*** DIVERGES ***"),
          flush=True)
