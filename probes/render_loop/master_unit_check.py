#!/usr/bin/env python3
"""Verify the oracle's assumption that the MASTER renders from unit 8.
The real per-block render calls MASTER_WRAP(*(ENGINE+592), ptrs, out).
Compare *(ENGINE+592) against every state[i] / proc[i] / assign[i]."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
e = E.E2E(); e.build(48000.0)
uc = e.uc; H = e.HOST
rdq = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
m = rdq(H + 592)
print("MASTER state arg *(ENGINE+592) = 0x%x" % m)
for i in range(9):
    print("  state[%d]=0x%-12x %s" % (i, e.state[i], "  <== MATCH" if e.state[i] == m else ""))
print("oracle uses state[8] = 0x%x  -> %s" % (e.state[8], "CORRECT" if e.state[8] == m else "*** MISMATCH ***"))
# also: the per-voice buffer descriptor table at ENGINE+680 stride 48
print("\nbuffer descriptors @ ENGINE+680 stride 48 (entry-24, entry):")
for v in range(8):
    ent = H + 680 + 48*v
    print("  v%d: (ent-24)=0x%-12x (ent)=0x%-12x" % (v, rdq(ent-24), rdq(ent)))
