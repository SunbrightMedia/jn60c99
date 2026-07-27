#!/usr/bin/env python3
"""The user reports Chillwave 3 AND 4 both sound wrong; factory patches are fine.
Find every parameter where BOTH CW3 and CW4 sit OUTSIDE the range the factory
bank ever reaches — i.e. value territory no gate has ever tested (all gates use
the factory bank)."""
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
print("CW3 (BS Solid) and CW4 vs the FACTORY value range per parameter\n")
print(" disp  name                         factory min..max   CW3   CW4   flag")
outside=[]
for (d,bb) in leaves:
    n=nm(d)
    if n.startswith('(') or n=='_NULL_': continue
    fv=[RB.record_value(fac[p],bb) for p in range(64)]
    c3=RB.record_value(chl[3],bb); c4=RB.record_value(chl[4],bb)
    lo,hi=min(fv),max(fv)
    o3=not(lo<=c3<=hi); o4=not(lo<=c4<=hi)
    flag=""
    if o3 and o4: flag="  <== BOTH outside factory range"; outside.append((d,n,lo,hi,c3,c4))
    elif o3: flag="  (CW3 outside)"
    elif o4: flag="  (CW4 outside)"
    if flag:
        print("  %4d %-28s %4d..%-4d  %4d  %4d%s"%(d,n,lo,hi,c3,c4,flag))
print("\nparameters where BOTH bad patches are outside all factory coverage: %d"%len(outside))
for d,n,lo,hi,c3,c4 in outside:
    print("   disp %4d %-28s factory %d..%d  ->  CW3 %d, CW4 %d"%(d,n,lo,hi,c3,c4))
print("\nCW4 name: %r"%''.join(chr(c) if 32<=c<127 else ' ' for c in
    open('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin','rb').read()[23+4*20223:23+4*20223+16]))
