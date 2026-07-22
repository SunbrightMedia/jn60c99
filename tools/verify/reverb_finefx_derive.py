"""Derive the REVERB fine-FX laws (PRE DELAY 1323, LOW CUT 1324, HIGH CUT 1325,
DENSITY 1326, DIRECT LEVEL 1327) via the plugin's OWN dispatch 0x3B9A30 executed
under Unicorn. These FX setters forward into the engine's FX sub-object; the
coefficient CELL materializes when the reverb ticks, so we dispatch byte v ->
render one block -> read the changed cells (proven static + byte-determined,
scratchpad/rev_fast_probe.py). Reuse ONE engine per rate. Output:
reverb_finefx_laws.pkl { param -> {rate -> {cell -> [256 uint32]}} }.
Covenant-clean (plugin's own setter + tick under Unicorn). Two-process (oracle)."""
import sys, struct, pickle
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E
SP='/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
SZ=0xA83010
PARAMS={'REVERB PRE DELAY':1323,'REVERB LOW CUT':1324,'REVERB HIGH CUT':1325,
        'REVERB DENSITY':1326,'REVERB DIRECT LEVEL':1327}
RATES=[44100.0,48000.0,88200.0,96000.0]
NOTE,VEL=60,105
fac=E.bank_bytes(); std=E.load_leaves()
def nib(r,o): return ((r[o]&0xF)<<4)|(r[o+1]&0xF)
# reverb-active patch: max REVERB LEVEL (record 118) with REVERB TYPE 2
revp=max(range(64), key=lambda i: nib(E.patch_blob(fac,i),118-16))
def rd(e,off): return struct.unpack('<I',e.uc.mem_read(e.state[0]+off,4))[0]
def make(sr):
    e=E.E2E(); e.build(sr); e.snap_all()
    blob=E.patch_blob(fac,revp)
    for (p,nm,disp,bb) in std:
        for u in range(9):
            try: e.dispatch(u,disp,E.dec(blob,bb))
            except RuntimeError: pass
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(NOTE,VEL)
    e.render(600)   # warm the reverb once so the FX sub-object is live
    return e
def cells_for(e, disp):
    # dispatch 0 vs 255 with a materializing render between -> changed cells
    for u in range(9):
        try: e.dispatch(u,disp,0)
        except RuntimeError: pass
    e.render(600); b0=bytes(e.uc.mem_read(e.state[0],SZ))
    for u in range(9):
        try: e.dispatch(u,disp,255)
        except RuntimeError: pass
    e.render(600); b1=bytes(e.uc.mem_read(e.state[0],SZ))
    return [o for o in range(0,SZ,4) if b0[o:o+4]!=b1[o:o+4]]
laws={nm:{} for nm in PARAMS}
for sr in RATES:
    e=make(sr)
    for nm,disp in PARAMS.items():
        cells=cells_for(e,disp)
        tbl={c:[] for c in cells}
        for v in range(256):
            for u in range(9):
                try: e.dispatch(u,disp,v)
                except RuntimeError: pass
            e.render(600)
            for c in cells: tbl[c].append(rd(e,c))
        laws[nm][int(sr)]=tbl
        sys.stderr.write("rate %d %s -> %d cells\n"%(int(sr),nm,len(cells))); sys.stderr.flush()
pickle.dump(laws,open(SP+'/reverb_finefx_laws.pkl','wb'))
for nm in PARAMS:
    cells=sorted(laws[nm][44100].keys())
    rd_=any(laws[nm][44100][c]!=laws[nm][int(sr)][c] for c in cells for sr in RATES) if cells else False
    print("%-20s cells=%d rate-dep=%s"%(nm,len(cells),rd_))
print("reverb patch",revp,"wrote reverb_finefx_laws.pkl")
