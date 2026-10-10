#!/usr/bin/env python3
"""jx_engine_render_check.py -- the engine-level oracle's render (tools/verify/jx_emu.py render_engine: the
plugin's own engine render on the engine alone, booted with the plugin's own records) against the plugin
as a DAW runs it (jx3p/tools/jx_host_emu.py: its own process()), sample for sample. Unicorn only.

At host 96000 the plugin's default setting runs the engine at 96000 and its render object is the
identity: process() hands the host block to the engine render, after the render driver applied the
queued records (initialize's, then the patch browser's load of patch k) at the first block's start.
The model: jx_emu.boot(96000, product=True, patch=k) -- the same records through the same host entry
(jx_recall_product_check.py: the engines are equal word for word there) -- then render_engine.
A note-on (60, velocity 0.8 / 102) at the start of block 2, a note-off at block 110; 120 blocks of 512
(the first 48,000 samples are the plugin's start mute: a check that compares only them compares
silence -- the check refuses a run with fewer than 4,096 non-zero samples after the mute).

    python3 -u jx3p/tools/jx_engine_render_check.py [patch=0] [--tooth]
  --tooth: the model recalls patch k+1 -- must differ (exit 0 = bites)
exit 0 = every sample of both channels equal.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_bank as B                                    # noqa: E402

BLOCK, NBLK, ON, OFF = 512, 120, 2, 110       # 61,440 samples: past the 0.5 s start mute (48,000 + 960)


def product(k):
    import jx_host_emu as X
    h = X.JXHost()
    h.start(96000.0, BLOCK)
    bank = B.bank_bytes()
    h.load_patch(bank[B.BANK_HEADER + k * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (k + 1) * B.BANK_STRIDE])
    L, R = [], []
    for b in range(NBLK):
        ev = [('on', 0, 0, 60, 0.8)] if b == ON else [('off', 0, 0, 60, 0.0)] if b == OFF else []
        l, r = h.process(BLOCK, events=ev)
        L += l; R += r
    return L, R, h


def model(k):
    import jx_emu as J
    jx = J.JX().boot(96000.0, snap=False, product=True, patch=k)
    L, R = [], []
    for b in range(NBLK):
        if b == ON:
            jx.note_on(60, 102)                       # VST3 velocity 0.8 -> the driver's MIDI 102 (the JUNO's
        if b == OFF:                                  # wrapper: round(0.8 x 127)); checked by the comparison
            jx.note_off(60, 0)
        l, r = jx.render_engine(BLOCK, BLOCK)
        L += l; R += r
    return L, R, jx


def main():
    a = sys.argv[1:]
    k = int(next((x for x in a if x.isdigit()), '0'))
    tooth = '--tooth' in a
    pl, pr, h = product(k)
    ml, mr, jx = model(min(k + 1, 63) if tooth else k)
    d = next((i for i in range(len(pl)) if pl[i] != ml[i] or pr[i] != mr[i]), None)
    nz = next((i for i, x in enumerate(pl) if x & 0x7FFFFFFF), None)
    loud = sum(1 for x in pl if x & 0x7FFFFFFF)
    print('patch %d: %d samples, first non-zero product sample %s, %d non-zero; product render sizes %s; '
          'first differing sample %s' % (k, len(pl), nz, loud, sorted({n for _, n in h.jobs})[:12], d))
    if loud < 4096 and not tooth:
        print('jx_engine_render_check: REFUSED -- the product output is silent; nothing was compared')
        return 1
    if tooth:
        print('jx_engine_render_check --tooth: %s' % ('BITES' if d is not None else 'DID NOT BITE'))
        return 0 if d is not None else 1
    print('jx_engine_render_check: %s' % ('GREEN -- the engine-level oracle renders as the plugin does'
                                         if d is None else 'RED'))
    return 0 if d is None else 1


if __name__ == '__main__':
    sys.exit(main())
