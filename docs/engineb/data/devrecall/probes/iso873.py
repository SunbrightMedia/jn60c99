import sys, struct, gc
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R
from warm_plugin import recall_into, build_engine
SR=44100.0
bank=E.bank_bytes(); leaves=R.leaf_table()
OFFS=[91120,91152,91168,91184]
def snap(e): return {o:struct.unpack('<I',e.uc.mem_read(e.state[8]+o,4))[0] for o in OFFS}
print("ISOLATED: fresh engine -> recall BASE -> ONE dispatch of 873 <- v")
for base,bl in ((13,'ET2 -> 91152 default'),(12,'ET3 -> 91152 mode3')):
    e0=build_engine(SR); recall_into(e0,base,bank,leaves,'enum'); b=snap(e0); del e0; gc.collect()
    print(" base %d (%s): "%(base,bl)+" ".join("%d=%08x"%(o,b[o]) for o in OFFS))
    for v in range(6):
        e=build_engine(SR); recall_into(e,base,bank,leaves,'enum')
        for u in range(9): e.dispatch(u,873,v)
        s=snap(e); del e; gc.collect()
        ch=[o for o in OFFS if s[o]!=b[o]]
        print("   873<-%d : "%v+" ".join("%d=%08x"%(o,s[o]) for o in OFFS)+"   changed=%s"%ch)
