#!/usr/bin/env python3
"""Our recall dispatches EVERY value-tree leaf, including ones the plugin's own
name table marks as JU-06A-only (parenthesised, e.g. "(FILTER LPF TYPE)",
"(OSC2 ...)"). A real JUNO-60-mode instance may never drive those. If BS Solid's
record carries NON-ZERO bytes at those positions and dispatching them writes
filter/voice cells, we are configuring the filter in a way the real plugin does
not — which would show up exactly as an attack/filter-character difference.
Oracle-only (Unicorn); plugin's own name table + own setters."""
import sys, struct
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, real_bank_parse as RB
from unicorn import UC_HOOK_MEM_WRITE

BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
bank=open(BANK,'rb').read(); recs=RB.parse_records(bank); rec=recs[3]
e=E.E2E(); e.build(48000.0); e.snap_all()
uc=e.uc; NT=E.IB+0x9a0030; base=e.state[0]; SZ=0xA83010
def pname(i):
    p=int.from_bytes(uc.mem_read(NT+8*i,8),'little')
    if not (E.IB<=p<E.IB+E.IMGSZ): return '?'
    b=bytearray(); a=p
    while len(b)<96:
        ch=uc.mem_read(a,1)[0]
        if ch==0: break
        b.append(ch); a+=1
    return b.decode('latin1')
def writes(idx,val):
    w={}
    def hk(u,acc,addr,size,value,x):
        off=addr-base
        if 0<=off<SZ: w[off]=value
    h=uc.hook_add(UC_HOOK_MEM_WRITE,hk)
    try: e.dispatch(0,idx,val)
    except RuntimeError: pass
    uc.hook_del(h); return w

leaves=R.leaf_table()
print("JU-06A-only / parenthesised leaves in OUR applied map, with BS Solid's byte:\n")
print(" disp  recb  BSSolid  name                          cells written (val 0 vs patch value)")
hot=[]
for (d,bb) in leaves:
    nm=pname(d)
    if not (nm.startswith('(') or nm=='_NULL_'): continue
    v=RB.record_value(rec,bb)
    w0=writes(d,0); wv=writes(d,v)
    cells=sorted(set(w0)|set(wv))
    moved=[c for c in cells if w0.get(c)!=wv.get(c)]
    flag=''
    if v!=0 and moved:
        flag='   <== NON-ZERO on BS Solid AND moves cells'
        hot.append((d,nm,v,moved))
    print(" %4d %5d  %7d  %-28s %s%s"%(d,bb,v,nm,moved[:6] if moved else '(none)',flag))
print("\nSUSPECTS (non-zero on BS Solid and cell-moving): %d"%len(hot))
for d,nm,v,moved in hot:
    print("   disp %4d %-26s value %3d -> cells %s"%(d,nm,v,moved[:10]))
