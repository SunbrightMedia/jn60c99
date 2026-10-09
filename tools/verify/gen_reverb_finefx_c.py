import os as _os_jrepo; _JREPO = _os_jrepo.path.dirname(_os_jrepo.path.dirname(_os_jrepo.path.dirname(_os_jrepo.path.abspath(__file__))))  # repo root from this file; never hardcode it (tools/verify/pathcheck.py)
"""gen_reverb_finefx_c.py -- the REVERB fine-FX tables of src/finefx_tables.h (appended after the delay
section, before the chorus section; tools/repro/regen_check.py runs the three generators in that order).

The source is the pillar-3 gate's own reference: tools/verify/finefx_cellsweep.py (the plugin's setter
0x3B9A30 + snap_all, every byte, context RT0; $JUNO_FINEFX_REF_PKL selects the file, at least the four
table rates). Only the bytes the port reads are written: src/finefx_recall.c clamps LOW CUT to 0..17,
HIGH CUT to 0..14 and DENSITY to 0..10 (the plugin's parameter ranges); above them the setter's cells are
state-dependent, so no run can reproduce them, and no host reaches them. (Until 2026-10-09 the tables held
128 bytes each, the bytes above the range a July capture's state; that derivation, reverb_finefx_derive.py,
could not rebuild them -- task #62.)
"""
import os
import pickle

SP = _JREPO + '/scratchpad'
REF = os.environ.get('JUNO_FINEFX_REF_PKL') or (SP + '/finefx_cellsweep_ref.pkl')
R = pickle.load(open(REF, 'rb'))
RATES = [44100.0, 48000.0, 88200.0, 96000.0]
CTX = 'RT0'
LC_MAX, HC_MAX, DN_MAX = 17, 14, 10          # src/finefx_recall.c's clamps (the parameter ranges)


def hx(v):
    return "0x%08xu" % v


def law(leaf, rate):
    return R[(leaf, CTX, rate)]


lc_cells = sorted(law(1324, 44100.0)); hc_cells = sorted(law(1325, 44100.0))
dn_cells = sorted(law(1326, 44100.0)); dl_cells = sorted(law(1327, 44100.0))
assert (len(lc_cells), len(hc_cells), len(dn_cells), len(dl_cells)) == (3, 5, 1, 1), (lc_cells, hc_cells, dn_cells, dl_cells)
for leaf, cells in ((1324, lc_cells), (1325, hc_cells), (1326, dn_cells), (1327, dl_cells)):
    for r in RATES:
        assert sorted(law(leaf, r)) == cells, (leaf, r)
dn_cell, dl_cell = dn_cells[0], dl_cells[0]
# DENSITY and DIRECT LEVEL are rate-independent (one table): checked, not assumed
assert all(law(1326, r)[dn_cell][:DN_MAX + 1] == law(1326, 44100.0)[dn_cell][:DN_MAX + 1] for r in RATES)
assert all(law(1327, r)[dl_cell] == law(1327, 44100.0)[dl_cell] for r in RATES)

out = []
out.append("")
out.append("/* ===== REVERB fine-FX (dispatch 1324/1325/1326/1327): the plugin's setter 0x3B9A30 +")
out.append(" * snap_all() at the 4 table rates (tools/verify/finefx_cellsweep.py, the pillar-3 gate's")
out.append(" * reference; tools/verify/gen_reverb_finefx_c.py). The master always runs the reverb tank,")
out.append(" * so these apply unconditionally. All cells are master_render-READ. LOW/HIGH CUT rate-armed;")
out.append(" * DENSITY/DIRECT rate-independent. int1x7 params indexed by the 7-bit record byte, clamped")
out.append(" * to the parameter range (finefx_recall.c): only those bytes are held. ===== */")
out.append("static const int      REV_LC_CELLS[3] = {%s};" % ", ".join(str(c) for c in lc_cells))
out.append("static const uint32_t REV_LC[4][%d][3] = {" % (LC_MAX + 1))
for r in RATES:
    out.append("  { /* %d */" % r)
    for b in range(LC_MAX + 1):
        out.append("    {%s}," % ", ".join(hx(law(1324, r)[c][b]) for c in lc_cells))
    out.append("  },")
out.append("};")
out.append("static const int      REV_HC_CELLS[5] = {%s};" % ", ".join(str(c) for c in hc_cells))
out.append("static const uint32_t REV_HC[4][%d][5] = {" % (HC_MAX + 1))
for r in RATES:
    out.append("  { /* %d */" % r)
    for b in range(HC_MAX + 1):
        out.append("    {%s}," % ", ".join(hx(law(1325, r)[c][b]) for c in hc_cells))
    out.append("  },")
out.append("};")
out.append("static const int      REV_DENS_CELL = %d;" % dn_cell)
out.append("static const uint32_t REV_DENS[%d] = {" % (DN_MAX + 1))
dn = [hx(law(1326, 44100.0)[dn_cell][b]) for b in range(DN_MAX + 1)]
for i in range(0, len(dn), 8):
    out.append("  " + ", ".join(dn[i:i + 8]) + ",")
out.append("};")
out.append("static const int      REV_DIRECT_CELL = %d;" % dl_cell)
out.append("static const uint32_t REV_DIRECT[256] = {")
for i in range(0, 256, 8):
    out.append("  " + ", ".join(hx(law(1327, 44100.0)[dl_cell][b]) for b in range(i, i + 8)) + ",")
out.append("};")
open(_JREPO + '/src/finefx_tables.h', 'a').write("\n".join(out) + "\n")
print("appended reverb tables from %s: LC cells %s, HC %s, DENS %d, DIRECT %d" % (REF, lc_cells, hc_cells, dn_cell, dl_cell))
