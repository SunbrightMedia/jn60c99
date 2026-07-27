#!/usr/bin/env python3
"""Dispatch Boost Mode (21) / Output Gain (22) through the plugin's own setter
0x3B9A30 under BOTH roles on a recalled BS Solid engine; full-state diff all 9
units; render RMS before/after. Per P112 s8: write DB value first, in-range."""
import sys, struct, math
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA
CW = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
      '0e8b9cb5-Chillwave.bin')
bank = open(CW, 'rb').read(); leaves = R.leaf_table()
def f32(b): return struct.unpack('<f', struct.pack('<I', b))[0]
def rms(L):
    v = [f32(x) for x in L]; return math.sqrt(sum(x*x for x in v)/len(v))

def run(mutate):
    e = RA.prepare_recall(3, bank, leaves, E, R, 44100.0)
    if mutate: mutate(e)
    e.note_on(60, 100)
    L, _ = e.render(8000, block=512)
    st = [bytes(e.uc.mem_read(e.state[u], E.STATE_SZ)) for u in range(9)]
    del e
    return rms(L), st

base_rms, base_st = run(None)
print("baseline BS Solid rms=%.5f" % base_rms)
for (idx, val, fl) in ((21, 1, 1), (21, 1, 0), (22, 12, 1), (22, 12, 0), (22, -12, 0)):
    def m(e, idx=idx, val=val, fl=fl):
        R.wr_desc(e, idx, val)
        for u in range(9):
            e.dispatch(u, idx, val, flag=fl)
    r, st = run(m)
    cells = sum(sum(1 for i in range(0, E.STATE_SZ, 4)
                    if base_st[u][i:i+4] != st[u][i:i+4]) for u in range(9))
    print("idx %2d = %3d flag=%d : rms %.5f (%+.2f dB)  state cells changed %d"
          % (idx, val, fl, r, 20*math.log10(r/base_rms) if r > 0 else -99, cells))
