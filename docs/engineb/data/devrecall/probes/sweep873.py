import sys, struct, gc
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R
from warm_plugin import recall_into, build_engine
SR=44100.0
bank=E.bank_bytes(); leaves=R.leaf_table()
OFFS=[91120,91152,91168,91184,91200,91216,91232]
def snap(e): return {o:struct.unpack('<I',e.uc.mem_read(e.state[8]+o,4))[0] for o in OFFS}
def f(u): return struct.unpack('<f',struct.pack('<I',u))[0]
for base in (12,13,7):   # ET 3, ET 2, ET 5
    e=build_engine(SR); recall_into(e,base,bank,leaves,'enum')
    print("base patch %d  (ET from bank)"%base)
    for v in range(6):
        for u in range(9): e.dispatch(u,873,v)
        s=snap(e)
        print("   873<-%d : "%v + " ".join("%d=%.8g(%08x)"%(o,f(s[o]),s[o]) for o in OFFS))
    del e; gc.collect()
