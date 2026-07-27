#!/usr/bin/env python3
"""Is the EFFECT-TYPE ACTIVATION second stage a real recall gap for BS Solid?

Task #134 is still open: "wire the EFFECT-TYPE activation second stage
(11022056 + 6396xxx block) into recall". BS Solid is EFFECT TYPE 2 (chorus), so
if activation leaves cells our recall never writes, EVERY gate is blind to it
(the oracle and the port both skip it identically).

TEST: do a full recall of BS Solid, snapshot the entire state of all 9 units,
then call the plugin's OWN effect activation (rva 0x3B93E0) on each unit's proc
and snapshot again. Any cell that changes is a cell the real plugin has and our
recall does not. Oracle-only (Unicorn)."""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, recall_render_ab as RA

BANK = os.environ.get('JUNO_BANK',
    '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')
PATCH = int(os.environ.get('JUNO_PATCH', '3'))
ACT = E.IB + 0x3B93E0
SZ  = 0xA83010

bank = open(BANK, 'rb').read()
leaves = R.leaf_table()
e = RA.prepare_recall(PATCH, bank, leaves, E, R, 44100.0)
before = [bytes(e.uc.mem_read(e.state[u], SZ)) for u in range(9)]
print("recalled patch %d; calling plugin's own activation 0x3B93E0 on all 9 procs" % PATCH, flush=True)

for u in range(9):
    try:
        e.call(ACT, rcx=e.proc[u], count=50_000_000)
    except Exception as ex:
        print("  unit %d activation raised: %s" % (u, ex))
e.snap_all()
after = [bytes(e.uc.mem_read(e.state[u], SZ)) for u in range(9)]

tot = 0
for u in range(9):
    a, b = before[u], after[u]
    if a == b:
        print("unit %d: activation changed NOTHING" % u, flush=True); continue
    diffs = [o for o in range(0, SZ, 4) if a[o:o+4] != b[o:o+4]]
    tot += len(diffs)
    print("unit %d: activation changed %d cells" % (u, len(diffs)), flush=True)
    for o in diffs[:25]:
        fa = struct.unpack('<f', a[o:o+4])[0]; fb = struct.unpack('<f', b[o:o+4])[0]
        print("    cell %9d  before=%-14.7g after=%-14.7g" % (o, fa, fb))
    if len(diffs) > 25: print("    ... %d more" % (len(diffs) - 25))
print("\nTOTAL cells the activation second stage would change: %d" % tot)
print("VERDICT:", "NO GAP — recall already leaves the engine in the activated state"
      if tot == 0 else "*** GAP: activation writes cells our recall never does ***")
