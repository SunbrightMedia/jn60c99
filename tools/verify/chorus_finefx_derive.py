"""Derive the SLOT-1 chorus fine-FX laws (the DELAY TYPE 2/3 chorus filters, NOT
the slot-2 EFFECT-TYPE chorus which has no fine filters): CHORUS HIGH CUT (1212),
LOW CUT (1211), PRE DELAY (1210), via dispatch 0x3B9A30 + snap_all, in a DELAY
TYPE 2 context, all 4 rates. Cells: HIGH CUT 6396192.. (7), LOW CUT 6396336/352
(2), PRE DELAY 6396128 (1). Reuse ONE engine. Output: chorus_finefx_laws.pkl."""
import sys, struct, pickle
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E
SP='/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
SZ=0xA83010; ET,DT=873,875
PARAMS=[('CHORUS PRE DELAY',1210),('CHORUS LOW CUT',1211),('CHORUS HIGH CUT',1212)]
RATES=[44100.0,48000.0,88200.0,96000.0]
fac=E.bank_bytes(); std=E.load_leaves()
def rd(e,off): return struct.unpack('<I',e.uc.mem_read(e.state[0]+off,4))[0]
def disp_snap(e,disp,v):
    for u in range(9):
        try: e.dispatch(u,disp,v)
        except RuntimeError: pass
    e.snap_all()
def make(sr):
    e=E.E2E(); e.build(sr); e.snap_all()
    blob=E.patch_blob(fac,0)
    for (p,nm,disp,bb) in std:
        for u in range(9):
            try: e.dispatch(u,disp,E.dec(blob,bb))
            except RuntimeError: pass
    for u in range(9):                       # force slot-1 chorus (DELAY TYPE 2)
        try: e.dispatch(u,DT,2)
        except RuntimeError: pass
    e.snap_all(); return e
laws={nm:{} for nm,_ in PARAMS}
for sr in RATES:
    e=make(sr); base=e.state[0]
    for nm,disp in PARAMS:
        disp_snap(e,disp,0);   a=bytes(e.uc.mem_read(base,SZ))
        disp_snap(e,disp,127); b=bytes(e.uc.mem_read(base,SZ))
        cells=[o for o in range(0,SZ,4) if a[o:o+4]!=b[o:o+4]]
        tbl={c:[] for c in cells}
        for v in range(128):
            disp_snap(e,disp,v)
            for c in cells: tbl[c].append(rd(e,c))
        laws[nm][int(sr)]={'cells':cells,'tbl':tbl}
    sys.stderr.write("rate %d done\n"%int(sr)); sys.stderr.flush()
pickle.dump(laws,open(SP+'/chorus_finefx_laws.pkl','wb'))
for nm,_ in PARAMS:
    cells=laws[nm][44100]['cells']
    rdep=any(laws[nm][44100]['tbl'][c]!=laws[nm][int(sr)]['tbl'][c] for c in cells for sr in RATES) if cells else False
    print("%-18s cells=%s rate-dep=%s"%(nm,cells,rdep))
print("wrote chorus_finefx_laws.pkl (slot-1 chorus, DELAY TYPE 2 ctx)")
