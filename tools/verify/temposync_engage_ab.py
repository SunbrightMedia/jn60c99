#!/usr/bin/env python3
"""temposync_engage_ab.py — adversarial closure for the seed-51 residual.

Seed 51 proved the live TEMPO SYNC engage (blob 59) path bit-exact for ONE
patch (31). The engage also flips the per-voice LFO tempo-sync switch (cell
1056); voice3's LFO oscillator state (1472/1504/1520) was seen to differ
transiently in synced mode but was audio-inert for patch 31. This test closes
the latent-risk question by driving a live TEMPO SYNC engage on EVERY factory
patch with a sustained note held across the flip, and A/B-ing full audio
against the running binary. Any patch whose LFO is audibly routed AND whose
synced-LFO oscillator diverges would show here.

Sequence (both sides, per patch): cold recall -> note_on(60,100) ->
render(PRE) -> param(TEMPO SYNC row 24 = 127) to all 9 units + snap_all ->
render(POST). Report first audio-diverging frame, or BIT-EXACT.

Ground truth = the plugin's own machine code under Unicorn (e2e_emu.py).
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
sys.path.insert(0, '/home/user/jn60c99/tools/verify/triage')
from ft3 import PluginRun, PortRun, first_div

RATE = 44100.0        # Teensy-native; the rate seed 51 diverged at
PRE, POST = 2000, 8000
TEMPO_SYNC_ROW = 24
ENGAGE_BYTE = 127

def run(patch):
    P = PluginRun(RATE, patch); Q = PortRun(RATE, patch)
    for side in (P, Q):
        side.do(('on', 60, 100))
        side.do(('render', PRE))
        side.do(('param', TEMPO_SYNC_ROW, ENGAGE_BYTE))
        side.do(('render', POST))
    d = first_div(P.L, P.R, Q.L, Q.R)
    n = min(len(P.L), len(Q.L))
    bits = None if d is None else (P.L[d], Q.L[d], P.R[d], Q.R[d])
    Q.close()
    return d, n, bits

def main():
    lo = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    hi = int(sys.argv[2]) if len(sys.argv) > 2 else 63
    bad = 0
    for patch in range(lo, hi + 1):
        d, n, bits = run(patch)
        if d is None:
            print(f"patch {patch:2d}: BIT-EXACT {n} frames", flush=True)
        else:
            bad += 1
            print(f"patch {patch:2d}: DIVERGE @ {d}  "
                  f"plugL={bits[0]:08x} portL={bits[1]:08x} "
                  f"plugR={bits[2]:08x} portR={bits[3]:08x}", flush=True)
    print(f"=== {bad} divergent / {hi-lo+1} patches ===", flush=True)

if __name__ == '__main__':
    main()
