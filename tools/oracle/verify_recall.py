#!/usr/bin/env python3
"""verify_recall.py — regression gate: for all 64 patches, diff the plugin's own
recall output (scratchpad/oracle/patch_state2/*.json, produced by patch_oracle2.py)
against our engine's post-recall voice state (dump_ours), and report every remaining
voice-region (176..10688) mismatch aggregated by patch count.

Run patch_oracle2.py all  and  /tmp/dump_ours per patch first (build_ours()).
Exits 0 iff the only mismatches are the documented residuals.
"""
import json, struct, subprocess, os, sys
from collections import Counter, defaultdict

ROOT = '/home/user/jn60c99'
BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
ORC = ROOT + '/scratchpad/oracle/patch_state2'
REG = json.load(open('/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/unit2/registry_paramid_offset.json'))
NM = {e[0]: e[1] for e in REG}

def f(b): return struct.unpack('<f', struct.pack('<I', b & 0xffffffff))[0]

# documented, understood residuals (NOT recall bugs):
#  6736 = CUTOFF-H fine override (ours more precise than coarse dispatch)
#  1072 = host-BPM tempo-synced LFO rate (runtime state)
#  1088/2064 = coarse LFO rate; the fine H-override path (dispatch 878, float) refines it
RESIDUAL = {6736, 1072, 1088, 2064}

def dump_ours(idx):
    out = subprocess.check_output(['/tmp/dump_ours', BANK, str(idx)]).decode()
    d = {}
    for ln in out.splitlines():
        ps = ln.split(); d[int(ps[0])] = int(ps[1], 16)
    return d

def main():
    counts = Counter(); ex = defaultdict(list)
    for idx in range(64):
        orc = {int(k): v for k, v in json.load(open('%s/patch_%02d.json' % (ORC, idx)))['writes'].items()}
        ours = dump_ours(idx)
        for o, ob in orc.items():
            if not (176 <= o < 10688):
                continue
            ub = ours.get(o)
            if ub is None or ob != ub:
                counts[o] += 1
                if len(ex[o]) < 1:
                    ex[o].append((idx, ob, ub))
    real = {o: c for o, c in counts.items() if o not in RESIDUAL}
    print("=== voice-region recall mismatches (excluding documented residuals) ===")
    for o, c in sorted(real.items(), key=lambda x: -x[1]):
        i, ob, ub = ex[o][0]
        print("  %6d %-16s %2d/64  e.g. p%d oracle=%.5g ours=%s" %
              (o, NM.get(o, '?'), c, i, f(ob), '%.5g' % f(ub) if ub is not None else 'None'))
    print("\nresidual (understood, not bugs):", {o: counts[o] for o in RESIDUAL if o in counts})
    print("REAL voice mismatches:", len(real), "offsets")
    return 0 if not real else 1

if __name__ == '__main__':
    sys.exit(main())
