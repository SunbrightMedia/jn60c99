#!/usr/bin/env python3
"""real_recall.py -- self-driving per-patch recall reference (COMPLETE leaf set).

WHY THIS EXISTS
---------------
The oracle recall (e2e_emu.load_leaves / recall_patch) and the port (juno_apply.c)
reconstruct only value-tree leaves whose Script.xml doc index p is in
[21..73] u [90..137], dropping every other via `else: continue`. That drop is an
ARBITRARY range cut, not a schema distinction: Script.xml shows p=10..20 (DCO RANGE,
DCO PWM DEPTH/SOURCE, LFO DELAY/RATE, DCO/VCF LFO MOD, LFO KEY TRIG) are `int2x4`
leaves in the *same* SYNTH struct block and use the *same* nibble decode
(blob byte = 2*(p-2)-4) as the covered p=21..73 block. They are genuine per-patch
bytes: e.g. DCO RANGE (p=20, blob byte 32) decodes to the clean enum {2,3,4,5}
across all 64 factory patches -- a 16'/8'/4' octave control, not noise.

This module dispatches the COMPLETE record leaf set through the plugin's OWN
parameter setter (sub_7FF91E019A30, run under Unicorn via e2e_emu) in Script.xml
document order, then snapshots the engine. It is the corrected recall reference:
for DCO-RANGE=3 patches it reproduces the current (buggy) port bit-for-bit; for the
other 28 patches it additionally applies feet/PWM/LFO that the port skips.

EVIDENCE LABELS
  PROVEN(exec): every engine cell here is written by the plugin's real setter machine
                code (e2e dispatch). Verified per leaf in scratchpad/probe_skipped.py.
  READ(static): the SET of dispatched leaves = registration constructor sub_7FF91DD0D5A0
                (rva 0xad5a0) which registers exactly 134 engine params with contiguous
                dispatch ids 750..883 (tag 0x60xxxx); DCO RANGE=disp760 sits inside it,
                contiguous with PROVEN-recalled siblings PORTAMENTO(798)/ASSIGN(800)/
                TEMPO SYNC(803). disp = docpos + 740.
  NOT executed: the juce AudioProcessorValueTreeState state-restore LOOP itself (the
                thing that, on a DAW patch-load, feeds each leaf's byte to the setter)
                was NOT driven -- that it fires disp760 is INFERRED from registration
                + schema + the proven setter, not from executing replaceState.

Usage:
  python3 tools/verify/real_recall.py 62 5 18 39 6 14 31 0
  python3 tools/verify/real_recall.py all        # summary table, all 64
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

SR = 48000.0

# ---- COMPLETE leaf table (document order). The ONLY change vs e2e.load_leaves is the
# low SYNTH block start: ml>=8 (p>=10) instead of ml>=19 (p>=21). -------------------
import re
def complete_leaves():
    xml = open(E.SCRIPT_XML, encoding='utf-8', errors='replace').read()
    vals = re.findall(r'<value>(.*?)</value>', xml, re.S)
    leaves = []
    for p, v in enumerate(vals):
        nm = re.search(r'<name>(.*?)</name>', v)
        nm = nm.group(1) if nm else '?'
        ml = p - 2
        if 8 <= ml <= 71:            # SYNTH block: was 19..71 -> extended down to 8 (p10..73)
            bb = 2 * ml - 4
        elif 88 <= ml <= 135:        # extended PATCH2/PATCH3 block (unchanged)
            bb = 8 * ml - 430
        else:
            continue
        if nm.startswith('PATCH NAME'):
            continue
        leaves.append((p, nm, p + 740, bb))
    return leaves

# Key engine cells to report (voice-0 offsets; PROVEN written by the named setter).
CELLS = [
    (3840, "DCO feet (RANGE)"),   # disp760  2^(v-3)
    (4144, "DCO PWM depth"),      # disp758
    (3888, "PWM src A"),          # disp759
    (3936, "PWM src B"),          # disp759
    (1920, "LFO delay time"),     # disp751
    (1072, "LFO rate a"),         # disp752
    (1088, "LFO rate b"),         # disp752 (also disp878 LFO RATE H)
    (2064, "LFO rate c"),         # disp752
]

def f32(e, u, off):
    return struct.unpack('<f', e.uc.mem_read(e.state[u] + off, 4))[0]

def dec(blob, b):
    return ((blob[b] & 0xF) << 4) | (blob[b + 1] & 0xF)

def recall_complete(e, idx, leaves, bank, include_lfo_rate_h=False):
    """Dispatch every complete-set leaf (doc order) through the real setter, all 9 units."""
    blob = E.patch_blob(bank, idx)
    for (p, nm, disp, bb) in leaves:
        val = dec(blob, bb)
        for u in range(9):
            try: e.dispatch(u, disp, val)
            except RuntimeError: pass
    if include_lfo_rate_h:
        # p=138 LFO RATE H (disp878), ml=136 -> record byte 8*136-430=658. Lower
        # confidence (int8x4, just past the extended cutoff); off by default.
        val = dec(blob, 658)
        for u in range(9):
            try: e.dispatch(u, 878, val)
            except RuntimeError: pass

def run_patch(idx, leaves, bank, lfo_h=False):
    e = E.E2E(); e.build(SR); e.snap_all()
    recall_complete(e, idx, leaves, bank, lfo_h)
    e.snap_all()
    rng = dec(E.patch_blob(bank, idx), 32)          # DCO RANGE raw byte
    cells = {off: f32(e, 0, off) for off, _ in CELLS}
    return rng, cells

def main():
    args = sys.argv[1:] or ['62']
    bank = E.bank_bytes()
    leaves = complete_leaves()
    sys.stderr.write("complete leaf set: %d leaves (doc p=%d..%d), disp=%d..%d\n" %
                     (len(leaves), leaves[0][0], leaves[-1][0],
                      leaves[0][2], leaves[-1][2]))
    want = list(range(64)) if args == ['all'] else [int(a) for a in args]
    print("patch name              RANGE feet   PWM      PWMsrcA PWMsrcB  LFOdly   LFOrate_a LFOrate_b")
    for idx in want:
        rng, c = run_patch(idx, leaves, bank)
        nm = E.patch_name(bank, idx)
        print("%2d %-18s v=%d %6.3f %8.5f %6.2f %7.2f  %8.5f %8.5f %8.5f" % (
            idx, nm, rng, c[3840], c[4144], c[3888], c[3936],
            c[1920], c[1072], c[1088]))

if __name__ == '__main__':
    main()
