import sys, struct, gc
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R
from warm_plugin import recall_into, build_engine
import numpy as np
bank=E.bank_bytes(); leaves=R.leaf_table()
for SR in (44100.0,48000.0,88200.0,96000.0):
    e=build_engine(SR); recall_into(e,12,bank,leaves,'enum')   # patch 12 = EFFECT TYPE 3
    b3=struct.unpack('<I',e.uc.mem_read(e.state[8]+91152,4))[0]
    for u in range(9): e.dispatch(u,873,2)
    b2=struct.unpack('<I',e.uc.mem_read(e.state[8]+91152,4))[0]
    pre=struct.unpack('<I',struct.pack('<f',np.float32(0.96)/np.float32(SR)))[0]
    print("H=%-8g  873<-3 -> %08x   873<-2 -> %08x   0.96f/Hf = %08x   %s"%(
        SR,b3,b2,pre,"MATCH" if b2==pre else "*** DIFFERS ***"))
    del e; gc.collect()
