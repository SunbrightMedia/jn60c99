"""Emit scratchpad authoritative_cells.json: the TRUE cell set each borderline
COVERAGE leaf writes, from the plugin's OWN dispatch+snap full-byte sweep in the
leaf's activating context (supersedes the isolated leaf_cellmap over-attribution).
Covenant-clean (plugin setter under Unicorn). Consumed by build_coverage.py."""
import sys, json
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import numpy as np, e2e_emu as E
SZ=0xA83010; NW=SZ//4; ET,DT=873,875
fac=E.bank_bytes(); std=E.load_leaves()
def nib(r,o): return ((r[o]&0xF)<<4)|(r[o+1]&0xF)
def apply_std(e,blob):
    for (p,nm,disp,bb) in std:
        for u in range(9):
            try: e.dispatch(u,disp,E.dec(blob,bb))
            except RuntimeError: pass
def force(e,disp,v):
    for u in range(9):
        try: e.dispatch(u,disp,v)
        except RuntimeError: pass
def rd(e): return np.frombuffer(bytes(e.uc.mem_read(e.state[0],SZ)),dtype='<u4')
def ctx(sr,et,dt,base):
    e=E.E2E(); e.build(sr); e.snap_all(); blob=E.patch_blob(fac,base); apply_std(e,blob)
    if et is not None: force(e,ET,et)
    if dt is not None: force(e,DT,dt)
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(60,105); e.render(600); return e
def sweep(e,disp,hi):
    force(e,disp,0); e.snap_all(); a0=rd(e); ch=np.zeros(NW,bool)
    for v in range(hi+1): force(e,disp,v); e.snap_all(); ch |= (rd(e)!=a0)
    return sorted(int(w)*4 for w in np.nonzero(ch)[0])
revp=max(range(64),key=lambda i: nib(E.patch_blob(fac,i),118-16))
CASES=[(794,2,None,0,255),(795,5,None,revp,255),(873,None,None,0,5),(875,None,None,0,5),
       (1213,None,2,0,127),(1214,None,2,0,127),(1215,None,2,0,127),(1323,5,None,revp,100)]
out={}
for disp,et,dt,base,hi in CASES:
    e=ctx(48000.0,et,dt,base); out[str(disp)]=sweep(e,disp,hi)
    print(disp,'->',len(out[str(disp)]),'cells')
json.dump(out, open('/home/user/jn60c99/scratchpad/authoritative_cells.json','w'), indent=0)
print('wrote authoritative_cells.json')
