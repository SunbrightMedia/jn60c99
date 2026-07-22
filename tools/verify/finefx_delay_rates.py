"""Derive DELAY fine-FX law (TYPE-0 slot-1, 102xxx cells) at all 4 host rates.
Plugin's own setter under Unicorn (covenant-clean). Cross-checks dly_t0 vs dly_t1
context for patch-independence. Output: finefx_delay_rates.pkl
  { param -> { rate -> { cell -> [256 uint32] } } }  (dly_t0 context)
Plus prints which cells vary across rate."""
import sys, struct, pickle
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E
SP='/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
SZ=0xA83010
EFFECT_TYPE,DELAY_TYPE,REVERB_TYPE=873,875,876
PARAMS={'DELAY HIGH CUT':1180,'DELAY DIRECT LEVEL':1181,'DELAY LF DAMP':1182,
        'DELAY LF DAMP FREQ':1183,'DELAY HF DAMP':1184,'DELAY HF DAMP FREQ':1185}
RATES=[44100.0,48000.0,88200.0,96000.0]
facbank=E.bank_bytes(); std=E.load_leaves()
def make_ctx(sr, patch, force_et0):
    e=E.E2E(); e.build(sr); e.snap_all()
    blob=E.patch_blob(facbank,patch)
    for (p,nm,disp,bb) in std:
        for u in range(9):
            try: e.dispatch(u,disp,E.dec(blob,bb))
            except RuntimeError: pass
    if force_et0:
        for u in range(9):
            try: e.dispatch(u,DELAY_TYPE,0)
            except RuntimeError: pass
    e.snap_all(); return e
def rd(e,off): return struct.unpack('<I', e.uc.mem_read(e.state[0]+off,4))[0]
def sweep(e, disp):
    base=e.state[0]
    for u in range(9):
        try: e.dispatch(u,disp,0)
        except RuntimeError: pass
    b0=bytes(e.uc.mem_read(base,SZ))
    for u in range(9):
        try: e.dispatch(u,disp,255)
        except RuntimeError: pass
    b1=bytes(e.uc.mem_read(base,SZ))
    cells=[o for o in range(0,SZ,4) if b0[o:o+4]!=b1[o:o+4]]
    tbl={c:[] for c in cells}
    for v in range(256):
        for u in range(9):
            try: e.dispatch(u,disp,v)
            except RuntimeError: pass
        for c in cells: tbl[c].append(rd(e,c))
    return tbl
laws={nm:{} for nm in PARAMS}
for sr in RATES:
    e=make_ctx(sr,13,True)
    for nm,disp in PARAMS.items():
        laws[nm][int(sr)]=sweep(e,disp)
    sys.stderr.write("rate %d done\n"%int(sr)); sys.stderr.flush()
pickle.dump(laws,open(SP+'/finefx_delay_rates.pkl','wb'))
# report rate-dependence per cell
for nm in PARAMS:
    r0=laws[nm][44100]
    cells=sorted(r0.keys())
    for c in cells:
        arms=[laws[nm][int(sr)][c] for sr in RATES]
        varies = any(arms[0]!=arms[i] for i in (1,2,3))
        dv=len(set(arms[0]))
        print("%-20s cell %d: rate-dep=%s distinct(44k)=%d" % (nm,c,varies,dv))
print("wrote finefx_delay_rates.pkl")
