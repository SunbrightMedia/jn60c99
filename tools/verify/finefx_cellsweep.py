"""Authoritative fine-FX cell sweep (Pillar-3 foundation + ledger reconciliation).

For each fine-FX leaf, in its correct activating FX context, dispatch EVERY byte
value 0..255 through the plugin's own value-tree engine dispatch (0x3B9A30) and
snap_all() to settle the coefficient smoother to its target. The authoritative
cell set for the leaf = the UNION over all bytes of {cells that differ from the
byte-0 baseline}. This supersedes the old 0-vs-127 diff (which MISSES any cell
whose value coincides at bytes 0 and 127 but differs at an intermediate byte,
e.g. CHORUS HIGH CUT cell 6396272).

Covenant-clean: the plugin's OWN setter + smoother, executed under Unicorn. No
capture. Two-process (oracle only; no libjuno in this process).

Output: prints, per leaf, the authoritative cell set and a diff vs the port's
current applier cell set + the COVERAGE.tsv missing_audio_cells claim. Writes
scratchpad/finefx_cellsweep.pkl {(-leaf-,rate) -> {cell -> [256 uint32]}}.
"""
import sys, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import numpy as np
import e2e_emu as E

SP = '/home/user/jn60c99/scratchpad'
SZ = 0xA83010
NW = SZ // 4                      # number of u32 words
ET, DT = 873, 875
NOTE, VEL = 60, 105
fac = E.bank_bytes()
std = E.load_leaves()

def nib(r, o):
    return ((r[o] & 0xF) << 4) | (r[o + 1] & 0xF)

# --- context builders: apply a patch's std leaves, force the FX router, warm once
def _apply_std(e, blob):
    for (p, nm, disp, bb) in std:
        for u in range(9):
            try: e.dispatch(u, disp, E.dec(blob, bb))
            except RuntimeError: pass

def _force(e, disp, v):
    for u in range(9):
        try: e.dispatch(u, disp, v)
        except RuntimeError: pass

def ctx_delay(sr):        # DELAY TYPE 0
    e = E.E2E(); e.build(sr); e.snap_all()
    blob = E.patch_blob(fac, 2)          # p2 Delicate Keys: DELAY TYPE 0
    _apply_std(e, blob); _force(e, DT, 0)
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(NOTE, VEL); e.render(600)
    return e

def ctx_chorus(sr):       # DELAY TYPE 2 (slot-1 chorus)
    e = E.E2E(); e.build(sr); e.snap_all()
    blob = E.patch_blob(fac, 0)
    _apply_std(e, blob); _force(e, DT, 2)
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(NOTE, VEL); e.render(600)
    return e

def ctx_reverb(sr):       # reverb active: max REVERB LEVEL patch
    revp = max(range(64), key=lambda i: nib(E.patch_blob(fac, i), 118 - 16))
    e = E.E2E(); e.build(sr); e.snap_all()
    blob = E.patch_blob(fac, revp)
    _apply_std(e, blob)
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(NOTE, VEL); e.render(600)
    return e

# leaf -> (context builder, human name)
LEAVES = {
    1180: (ctx_delay,  'DELAY HIGH CUT'),
    1181: (ctx_delay,  'DELAY DIRECT LEVEL'),
    1182: (ctx_delay,  'DELAY LF DAMP'),
    1183: (ctx_delay,  'DELAY LF DAMP FREQ'),
    1184: (ctx_delay,  'DELAY HF DAMP'),
    1185: (ctx_delay,  'DELAY HF DAMP FREQ'),
    1210: (ctx_chorus, 'CHORUS PRE DELAY'),
    1211: (ctx_chorus, 'CHORUS LOW CUT'),
    1212: (ctx_chorus, 'CHORUS HIGH CUT'),
    1324: (ctx_reverb, 'REVERB LOW CUT'),
    1325: (ctx_reverb, 'REVERB HIGH CUT'),
    1326: (ctx_reverb, 'REVERB DENSITY'),
    1327: (ctx_reverb, 'REVERB DIRECT LEVEL'),
}

# port applier cell sets (from src/finefx_tables.h) for cross-check
PORT_CELLS = {
    1180: [102368,102384,102400,102416,102432,102464,102496],
    1181: [],
    1182: [102640],
    1183: [102608],
    1184: [102672],
    1185: [102656],
    1210: [6396128],
    1211: [6396336,6396352],
    1212: [6396192,6396208,6396224,6396240,6396256,6396288,6396320],
    1324: [10759520,10759536,10759552],
    1325: [10759568,10759584,10759600,10759616,10759632],
    1326: [10759392],
    1327: [10759424],
}

def rd_words(e):
    return np.frombuffer(bytes(e.uc.mem_read(e.state[0], SZ)), dtype='<u4')

def sweep_leaf(e, disp, nbytes=256):
    base = e.state[0]
    # baseline at byte 0
    _force(e, disp, 0); e.snap_all(); a0 = rd_words(e)
    changed = np.zeros(NW, dtype=bool)
    per = {}                      # byte -> full word array (kept only transiently)
    # pass 1: union of changed words
    vals = {}
    for v in range(nbytes):
        _force(e, disp, v); e.snap_all(); av = rd_words(e)
        changed |= (av != a0)
        vals[v] = av
    cell_words = np.nonzero(changed)[0]
    cells = [int(w) * 4 for w in cell_words]
    # table: cell -> [nbytes] uint32
    tbl = {}
    for w, off in zip(cell_words, cells):
        tbl[off] = [int(vals[v][w]) for v in range(nbytes)]
    return cells, tbl

def main():
    rates = [44100.0, 48000.0, 88200.0, 96000.0]   # committed Pillar-3 reference
    if len(sys.argv) > 1:
        rates = [float(x) for x in sys.argv[1:]]
    out = {}
    for sr in rates:
        # one engine per context, reused across its leaves
        eng = {}
        for disp, (ctxf, name) in LEAVES.items():
            key = ctxf.__name__
            if key not in eng:
                sys.stdout.write('[build %s @ %g]\n' % (key, sr)); sys.stdout.flush()
                eng[key] = ctxf(sr)
            e = eng[key]
            cells, tbl = sweep_leaf(e, disp)
            out[(disp, sr)] = tbl
            port = set(PORT_CELLS.get(disp, []))
            got = set(cells)
            missing = sorted(got - port)      # cells the leaf writes, port doesn't
            extra = sorted(port - got)        # cells port writes, leaf doesn't
            flag = '' if not missing else '  <<< PORT MISSING %s' % missing
            sys.stdout.write('leaf %d %-20s @%g: %d cells %s%s%s\n' % (
                disp, name, sr, len(cells), sorted(cells),
                ('  extra_in_port=%s' % extra) if extra else '', flag))
            sys.stdout.flush()
    with open(SP + '/finefx_cellsweep_ref.pkl', 'wb') as f:
        pickle.dump(out, f)
    sys.stdout.write('wrote finefx_cellsweep_ref.pkl (%d rates)\n' % len(rates))

if __name__ == '__main__':
    main()
