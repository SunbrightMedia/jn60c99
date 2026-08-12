import sys
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX
SETTER=E.IB+0x3B9A30; ENUM=E.IB+0x3B48A0
e=E.E2E(); uc=e.uc; hits=[]; rcx0=[]
def hook(uc,a,s,u):
    if a!=SETTER: return
    if not rcx0: rcx0.append(uc.reg_read(UC_X86_REG_RCX))
    hits.append(uc.reg_read(UC_X86_REG_RDX))
uc.hook_add(UC_HOOK_CODE,hook,begin=SETTER,end=SETTER)
e.build(48000.0); proc=rcx0[0]; hits.clear()
e.call(ENUM,rcx=proc,rdx=1,count=200_000_000)
print("enumerator fires %d dispatches, %d distinct"%(len(hits),len(set(hits))))
print("CALL ORDER:",hits)
lt=R.leaf_table()
bb={d:b for (d,b) in lt}
print("\nDELAY TYPE (record 650, bb 634) dispatch index:",[d for d,b in lt if b==634])
print("EFFECT TYPE (record 634, bb 618) dispatch index:",[d for d,b in lt if b==618])
# where do they land in the enumerator order?
for name,b in (("DELAY TYPE",634),("EFFECT TYPE",618)):
    ds=[d for d,x in lt if x==b]
    for d in ds:
        print("  %s idx %d at enumerator position %s of %d"%(name,d,[i for i,h in enumerate(hits) if h==d],len(hits)))
# and my own loop order position
mine=[d for d,_ in lt]
for name,b in (("DELAY TYPE",634),("EFFECT TYPE",618)):
    for d in [x for x,y in lt if y==b]:
        print("  %s idx %d at MY loop position %d of %d"%(name,d,mine.index(d),len(mine)))
