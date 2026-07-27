#!/usr/bin/env python3
"""LANE D step 5b: noise advance with ZERO notes held, plus VOICE_WRAP's gate
cell state+20 and the warmup latch per unit.  Unicorn only."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, recall_render_ab as RA
BANK = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
        '0e8b9cb5-Chillwave.bin')
bank = open(BANK,'rb').read(); leaves = R.leaf_table()
e = RA.prepare_recall(3, bank, leaves, E, R, 44100.0)
print("state+20 per unit:", [struct.unpack('<I', e.uc.mem_read(e.state[u]+20,4))[0] for u in range(9)])
print("latch 11022344 per unit:", [struct.unpack('<i', e.uc.mem_read(e.state[u]+11022344,4))[0] for u in range(9)])
for n in (1,64,600,601,1200,8000):
    pass
done=0
for stop in (1,64,600,601,1200,8000):
    e.render(stop-done, block=600 if stop-done>=600 else stop-done); done=stop
    blks=[bytes(e.uc.mem_read(e.state[u]+84272,164)) for u in range(9)]
    same=[u for u in range(8) if blks[u]==blks[0]]
    lf=struct.unpack('<I', blks[0][84336-84272:84336-84272+4])[0]
    print("noteless after %5d: units0-7 identical=%s  u0[84336]=0x%08x (%.9g)  u8 all-zero=%s"
          % (stop, len(same)==8, lf, struct.unpack('<f',struct.pack('<I',lf))[0],
             blks[8]==blks[8][:0]+bytes(164) if False else all(b==0 for b in blks[8][:0]) or None))
