#!/usr/bin/env python3
"""DERIVE the plugin's OWN velocity -> VCF-modulation law by execution.
Recall BS Solid, then call the plugin's engine noteOn at several velocities and
read the velocity-derived voice cells. This is PROVEN ground truth (no capture).
Cells of interest: 6896 (velocity target) and 7424 (VCF velocity sens), plus a
scan for every voice cell that MOVES with velocity."""
import sys, struct
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, recall_render_ab as RA
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
bank=open(BANK,'rb').read(); leaves=R.leaf_table()
VELS=[1,32,64,80,100,110,120,127]
snaps={}
for vel in VELS:
    e=RA.prepare_recall(3,bank,leaves,E,R,44100.0)
    e.note_on(60,vel); e.snap_all()
    snaps[vel]=bytes(e.uc.mem_read(e.state[0],10512))
    del e
base=snaps[100]
moving=[]
for off in range(0,10512,4):
    vals={v:struct.unpack('<f',snaps[v][off:off+4])[0] for v in VELS}
    if len({round(x,9) for x in vals.values()})>1:
        moving.append((off,vals))
print("voice cells that MOVE with note-on velocity: %d\n"%len(moving))
for off,vals in moving[:14]:
    print("  cell %5d : "%off + "  ".join("v%d=%.6g"%(v,vals[v]) for v in VELS))
print("\n--- implied normalisation for each moving cell ---")
for off,vals in moving[:14]:
    v1,v127=vals[1],vals[127]
    if abs(v127-v1)<1e-12: continue
    # where does the value at vel=100 sit between vel=1 and vel=127?
    frac=(vals[100]-v1)/(v127-v1)
    print("  cell %5d : value@100 sits %.4f of the way from v1 to v127  (100/127=%.4f, 100/100=1.0)"%(off,frac,100/127))
