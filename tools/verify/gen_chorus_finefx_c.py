import pickle
SP='/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
L=pickle.load(open(SP+'/chorus_finefx_laws.pkl','rb'))
RATES=[44100,48000,88200,96000]
def hx(v): return "0x%08xu"%v
HC=L['CHORUS HIGH CUT']; LC=L['CHORUS LOW CUT']; PD=L['CHORUS PRE DELAY']
hc_cells=HC[44100]['cells']; lc_cells=LC[44100]['cells']; pd_cell=PD[44100]['cells'][0]
out=[]
out.append("")
out.append("/* ===== SLOT-1 CHORUS fine-FX (DELAY TYPE 2/3): CHORUS HIGH CUT (1212) /")
out.append(" * LOW CUT (1211) / PRE DELAY (1210). The slot-2 EFFECT-TYPE chorus has NO fine")
out.append(" * filters (0 cells); these apply ONLY to the DELAY-TYPE-2/3 slot-1 chorus")
out.append(" * (cells 6396xxx). Derived via 0x3B9A30 + snap_all at all 4 rates")
out.append(" * (tools/verify/chorus_finefx_derive.py). HIGH CUT rate-indep; LOW CUT/PRE")
out.append(" * DELAY rate-armed. int1x7 record bytes (HIGH 3288/LOW 3287/PRE 3286). ===== */")
# HIGH CUT: 7 cells, rate-indep, 128
out.append("static const int      CHO1_HC_CELLS[7] = {%s};"%", ".join(str(c) for c in hc_cells))
out.append("static const uint32_t CHO1_HC[128][7] = {")
for b in range(128):
    out.append("  {%s},"%", ".join(hx(HC[44100]['tbl'][c][b]) for c in hc_cells))
out.append("};")
# LOW CUT: 2 cells, rate-armed, 128
out.append("static const int      CHO1_LC_CELLS[2] = {%s};"%", ".join(str(c) for c in lc_cells))
out.append("static const uint32_t CHO1_LC[4][128][2] = {")
for r in RATES:
    out.append("  { /* %d */"%r)
    for b in range(128):
        out.append("    {%s},"%", ".join(hx(LC[r]['tbl'][c][b]) for c in lc_cells))
    out.append("  },")
out.append("};")
# PRE DELAY: 1 cell, rate-armed, 128
out.append("static const int      CHO1_PD_CELL = %d;"%pd_cell)
out.append("static const uint32_t CHO1_PD[4][128] = {")
for r in RATES:
    out.append("  {"+", ".join(hx(PD[r]['tbl'][pd_cell][b]) for b in range(128))+"},")
out.append("};")
open('/home/user/jn60c99/src/finefx_tables.h','a').write("\n".join(out)+"\n")
print("appended chorus (slot-1) tables. HC",hc_cells,"LC",lc_cells,"PD",pd_cell)
# defaults: HIGH CUT=13 LOW CUT=2 PRE DELAY=20
print("HIGH CUT byte13:", ["%08x"%HC[44100]['tbl'][c][13] for c in hc_cells])
print("LOW CUT byte2 @44100:", ["%08x"%LC[44100]['tbl'][c][2] for c in lc_cells])
print("PRE DELAY byte20 @44100:", "%08x"%PD[44100]['tbl'][pd_cell][20])
