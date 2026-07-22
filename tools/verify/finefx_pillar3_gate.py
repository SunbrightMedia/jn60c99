"""finefx_pillar3_gate.py — Pillar-3 EXHAUSTIVE fine-FX gate (failure class 2:
wrong coefficient/law, killed by proof over the full input range).

For each fine-FX leaf, at each host rate, over its FULL record-reachable input
domain (int1x7: byte 0..255 masked &0x7F; int2x4/int8x4: value 0..255), assert
the PORT's shipping applier writes bit-identical float32 coefficients to the
plugin's OWN value-tree setter. The two sides are produced independently:

  reference  = the plugin's dispatch 0x3B9A30 + snap_all under Unicorn
               (tools/verify/finefx_cellsweep.py -> finefx_cellsweep_ref.pkl).
               The reference alone determines which cells each leaf writes; the
               port never curates its own target cells (anti-circularity).
  port        = tools/verify/finefx_port_dump (compiled from src/*.c) executed
               once per (rate, leaf), fed the reference's cell list on argv.

Any single-byte mismatch -> RED. Covenant-clean (plugin's own setter is the
reference; no capture). Two-process (the reference pkl is generated in a
separate oracle process; this gate only runs the port binary + compares).
"""
import sys, os, subprocess, pickle

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
SP = '/home/user/jn60c99/scratchpad'
REF = os.path.join(SP, 'finefx_cellsweep_ref.pkl')
DUMP = os.path.join(HERE, 'finefx_port_dump')

# leaf -> int1x7? (True => port decodes record byte with &0x7F, so reference is
# indexed at (byte & 0x7F); False => nibble-pair value, indexed directly).
RAW = {1180: True, 1181: False, 1182: False, 1183: False, 1184: False, 1185: False,
       1210: True, 1211: True, 1212: True,
       1324: True, 1325: True, 1326: True, 1327: False}
# leaf -> the plugin's OWN param-range max (from src/juno_hostparams.c). A real
# host clamps normalized->[0,1]->plain in [0,max], so a record value v > max is
# recalled as max: the gate indexes the reference at min(v,max), proving the port
# saturates to the in-range max coefficient (never comparing the setter's
# out-of-range garbage, which is state-dependent, not a pure function).
PMAX = {1180: 14, 1181: 255, 1182: 81, 1183: 10, 1184: 81, 1185: 13,
        1210: 80, 1211: 17, 1212: 14,
        1324: 17, 1325: 14, 1326: 10, 1327: 255}
NAME = {1180: 'DELAY HIGH CUT', 1181: 'DELAY DIRECT LEVEL', 1182: 'DELAY LF DAMP',
        1183: 'DELAY LF DAMP FREQ', 1184: 'DELAY HF DAMP', 1185: 'DELAY HF DAMP FREQ',
        1210: 'CHORUS PRE DELAY', 1211: 'CHORUS LOW CUT', 1212: 'CHORUS HIGH CUT',
        1324: 'REVERB LOW CUT', 1325: 'REVERB HIGH CUT', 1326: 'REVERB DENSITY',
        1327: 'REVERB DIRECT LEVEL'}

def run_port(rate, leaf, ctx, cells):
    out = subprocess.check_output(
        [DUMP, str(int(rate)), str(leaf), ctx] + [str(c) for c in cells])
    rows = {}
    for line in out.decode().strip().split('\n'):
        p = line.split()
        v = int(p[0]); rows[v] = [int(x, 16) for x in p[1:]]
    return rows

def main():
    if not os.path.exists(REF):
        print('MISSING reference %s -- run finefx_cellsweep.py first' % REF); return 1
    if not os.path.exists(DUMP):
        print('MISSING port binary %s -- build it (see Makefile finefx target)' % DUMP); return 1
    ref = pickle.load(open(REF, 'rb'))
    keys = sorted(ref.keys(), key=lambda k: (k[1], k[0], k[2]))   # (leaf, ctx, rate)
    rates = sorted({k[2] for k in keys}); ctxs = sorted({k[1] for k in keys})
    leaves = sorted({k[0] for k in keys})
    total_cmp = 0; total_mismatch = 0; bad = []
    for (leaf, ctx, rate) in keys:
        tbl = ref[(leaf, ctx, rate)]
        if not tbl:
            continue
        cells = sorted(tbl.keys())
        port = run_port(rate, leaf, ctx, cells)
        raw = RAW[leaf]; pmax = PMAX[leaf]
        n = 0; mm = 0; first = None
        for b in range(256):
            value = (b & 0x7F) if raw else b
            idx = value if value <= pmax else pmax   # host clamps to [0,max]
            for ci, c in enumerate(cells):
                exp = tbl[c][idx]; got = port[b][ci]; n += 1
                if exp != got:
                    mm += 1
                    if first is None:
                        first = (b, c, exp, got)
        total_cmp += n; total_mismatch += mm
        if mm:
            bad.append((rate, leaf, ctx, mm, first))
        print('  %-6g %-4s leaf %d %-20s cells=%d cmp=%d %s%s' % (
            rate, ctx, leaf, NAME[leaf], len(cells), n, 'OK' if mm == 0 else 'MISMATCH',
            '' if not mm else '  first b=%d cell=%d exp=%08x got=%08x' % first))
    print()
    if total_mismatch == 0:
        print('PILLAR-3 fine-FX: PROVEN  (%d comparisons, %d rates x %d contexts {%s} x %d leaves, 0 mismatch)'
              % (total_cmp, len(rates), len(ctxs), ','.join(ctxs), len(leaves)))
        return 0
    print('PILLAR-3 fine-FX: RED  (%d/%d mismatches)' % (total_mismatch, total_cmp))
    for rate, leaf, ctx, mm, first in bad:
        print('  RED %g %s leaf %d %s: %d mismatches, first %s' % (rate, ctx, leaf, NAME[leaf], mm, first))
    return 1

if __name__ == '__main__':
    sys.exit(main())
