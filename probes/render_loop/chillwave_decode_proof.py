#!/usr/bin/env python3
"""Prove the CHILLWAVE bank's byte->record decode by executing the PLUGIN'S OWN
per-record parser (sub_7FF91DF90ED0) on it, exactly as real_bank_parse.verify()
does for the factory bank. BS Solid (the user-reported patch) is Chillwave #3.

WHY THIS MATTERS: BS Solid lives in a THIRD-PARTY bank. Every gate (render A/B,
full-state diff) feeds BOTH sides the same decoded values, so a decode error for
a non-factory bank would be structurally invisible while making every value
wrong. This closes that hole by execution. Oracle-only (Unicorn)."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import real_bank_parse as RB
import real_recall as RR

BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
bank = open(BANK, 'rb').read()
print("bank: %s (%d bytes)" % (BANK, len(bank)))
print("magic+model: %r" % bank[:23])

leaves = RR.leaf_table()
recs = RB.parse_records(bank)
verbatim, body_bad, leaf_bad = 0, [], []
for idx in range(64):
    base = RB.HEADER + idx*RB.STRIDE
    body = bank[base+RB.BLOB_OFF: base+RB.BLOB_OFF+RB.BODY_N]
    rec = recs[idx]
    if rec == body:
        verbatim += 1
    else:
        body_bad.append((idx, [i for i in range(RB.BODY_N) if rec[i] != body[i]][:8]))
    for (disp, bb) in leaves:
        if RB.record_value(rec, bb) != RR.dec(body, bb):
            leaf_bad.append((idx, disp, bb, RR.dec(body, bb), RB.record_value(rec, bb)))

print("plugin parser executed on 64/64 Chillwave patches")
print("record == input body byte-for-byte: %d/64" % verbatim)
print("body mismatches:", body_bad if body_bad else "NONE")
print("leaf-level mismatches (plugin record vs our dec): %d over %d leaves x 64 patches"
      % (len(leaf_bad), len(leaves)))
for m in leaf_bad[:40]:
    print("   patch %d disp %d bb %d ours=%d plugin=%d" % m)

# BS Solid specifics
idx = 3
base = RB.HEADER + idx*RB.STRIDE
body = bank[base+RB.BLOB_OFF: base+RB.BLOB_OFF+RB.BODY_N]
nm = ''.join(chr(c) if 32 <= c < 127 else ' ' for c in bank[base:base+16])
print("\nBS Solid (Chillwave #%d, name %r) key leaves, plugin-parsed:" % (idx, nm))
NAMED = {773:'DCO NOISE LEVEL', 779:'VCF CUTOFF', 781:'VCF RESONANCE', 782:'HPF CUTOFF',
         771:'DCO SUB LEVEL', 770:'DCO SAW LEVEL', 772:'DCO PULSE LEVEL', 856:'CONDITION',
         780:'VCF ENV MOD', 758:'DCO PWM DEPTH', 760:'DCO RANGE'}
for (disp, bb) in leaves:
    if disp in NAMED:
        print("   disp %-5d %-16s rec byte %-5d value=%d" % (disp, NAMED[disp], bb, RB.record_value(recs[idx], bb)))
ok = (verbatim == 64 and not leaf_bad)
print("\nVERDICT:", "CHILLWAVE decode PROVEN(executed) identical to the plugin's own parser"
      if ok else "*** MISMATCH — decode bug found ***")
sys.exit(0 if ok else 1)
