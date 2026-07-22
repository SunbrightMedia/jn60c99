import pickle
SP='/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
L=pickle.load(open(SP+'/reverb_finefx_laws.pkl','rb'))
RATES=[44100,48000,88200,96000]
def hx(v): return "0x%08xu"%v
LC=L['REVERB LOW CUT']; HC=L['REVERB HIGH CUT']; DN=L['REVERB DENSITY']; DL=L['REVERB DIRECT LEVEL']
lc_cells=LC[44100]['cells']; hc_cells=HC[44100]['cells']
dn_cell=DN[44100]['cells'][0]; dl_cell=DL[44100]['cells'][0]
out=[]
out.append("")
out.append("/* ===== REVERB fine-FX (dispatch 1324/1325/1326/1327), derived via 0x3B9A30 +")
out.append(" * snap_all() smoother-settle at all 4 rates (tools/verify/reverb_finefx_derive.py).")
out.append(" * The master always runs the reverb tank, so these apply unconditionally. All")
out.append(" * cells are master_render-READ. LOW/HIGH CUT rate-armed; DENSITY/DIRECT rate-")
out.append(" * independent. int1x7 params indexed by the 7-bit record byte (0..127). ===== */")
# LOW CUT: 3 cells, rate-armed, 128 entries
out.append("static const int      REV_LC_CELLS[3] = {%s};"%", ".join(str(c) for c in lc_cells))
out.append("static const uint32_t REV_LC[4][128][3] = {")
for ri,r in enumerate(RATES):
    out.append("  { /* %d */"%r)
    for b in range(128):
        out.append("    {%s},"%", ".join(hx(LC[r]['tbl'][c][b]) for c in lc_cells))
    out.append("  },")
out.append("};")
# HIGH CUT: 5 cells, rate-armed, 128
out.append("static const int      REV_HC_CELLS[5] = {%s};"%", ".join(str(c) for c in hc_cells))
out.append("static const uint32_t REV_HC[4][128][5] = {")
for ri,r in enumerate(RATES):
    out.append("  { /* %d */"%r)
    for b in range(128):
        out.append("    {%s},"%", ".join(hx(HC[r]['tbl'][c][b]) for c in hc_cells))
    out.append("  },")
out.append("};")
# DENSITY: 1 cell, rate-indep, 128
out.append("static const int      REV_DENS_CELL = %d;"%dn_cell)
out.append("static const uint32_t REV_DENS[128] = {")
for i in range(0,128,8):
    out.append("  "+", ".join(hx(DN[44100]['tbl'][dn_cell][b]) for b in range(i,i+8))+",")
out.append("};")
# DIRECT LEVEL: 1 cell, rate-indep, 256
out.append("static const int      REV_DIRECT_CELL = %d;"%dl_cell)
out.append("static const uint32_t REV_DIRECT[256] = {")
for i in range(0,256,8):
    out.append("  "+", ".join(hx(DL[44100]['tbl'][dl_cell][b]) for b in range(i,i+8))+",")
out.append("};")
open('/home/user/jn60c99/src/finefx_tables.h','a').write("\n".join(out)+"\n")
print("appended reverb tables. LC cells",lc_cells,"HC",hc_cells,"DENS",dn_cell,"DIRECT",dl_cell)
# sanity: rate-indep check for DENSITY/DIRECT (should match across rates)
di=all(DN[44100]['tbl'][dn_cell]==DN[r]['tbl'][dn_cell] for r in RATES)
dl_ri=all(DL[44100]['tbl'][dl_cell]==DL[r]['tbl'][dl_cell] for r in RATES)
print("DENSITY rate-indep:",di,"| DIRECT rate-indep:",dl_ri)
