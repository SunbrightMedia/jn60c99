#!/usr/bin/env python3
"""THE SYSTEMATIC HOLE: every gate in this project validates against the FACTORY
bank. Any parameter that is CONSTANT across all 64 factory patches but VARIES in
the Chillwave bank has ZERO test coverage — a blind spot no gate can see.
The user reports Chillwave 3 (BS Solid) AND Chillwave 4 sound wrong; both
factory-bounce comparisons look fine. Find every such leaf."""
import sys
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, real_bank_parse as RB, truth
fac=RB.parse_records(open(truth.BANK,'rb').read())
chl=RB.parse_records(open('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin','rb').read())
e=E.E2E(); uc=e.uc; NT=E.IB+0x9a0030
def nm(i):
    p=int.from_bytes(uc.mem_read(NT+8*i,8),'little')
    if not (E.IB<=p<E.IB+E.IMGSZ): return '?'
    b=bytearray(); a=p
    while len(b)<96:
        c=uc.mem_read(a,1)[0]
        if c==0: break
        b.append(c); a+=1
    return b.decode('latin1')
leaves=R.leaf_table()
print("leaves CONSTANT across all 64 FACTORY patches but VARYING in Chillwave")
print("(= zero gate coverage; every gate uses the factory bank)\n")
print(" disp  name                          factory      chillwave range   CW3  CW4")
hits=[]
for (d,bb) in leaves:
    fv={RB.record_value(fac[p],bb) for p in range(64)}
    cv={RB.record_value(chl[p],bb) for p in range(64)}
    if len(fv)==1 and len(cv)>1:
        c3=RB.record_value(chl[3],bb); c4=RB.record_value(chl[4],bb)
        n=nm(d); hits.append((d,n,list(fv)[0],min(cv),max(cv),c3,c4))
        print("  %4d %-28s const=%-4d  %3d..%-3d      %3d  %3d%s"%(
            d,n,list(fv)[0],min(cv),max(cv),c3,c4,
            "   <== NON-ZERO on BOTH bad patches" if (c3!=list(fv)[0] and c4!=list(fv)[0]) else ""))
print("\ntotal leaves with zero factory coverage but Chillwave variation: %d"%len(hits))
both=[h for h in hits if h[5]!=h[2] and h[6]!=h[2]]
print("of those, differing from the factory constant on BOTH CW3 and CW4: %d"%len(both))
for h in both: print("   disp %4d %-28s factory-const %d -> CW3 %d, CW4 %d"%(h[0],h[1],h[2],h[5],h[6]))
