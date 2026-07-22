"""Authoritative fine-FX cell sweep, PER ACTIVATING CONTEXT (Pillar-3 reference).

For each fine-FX leaf, in EACH of its reachable FX-type contexts, dispatch every
byte 0..255 through the plugin's own value-tree engine dispatch (0x3B9A30) and
snap_all() to settle the coefficient smoother; the leaf's cell set = the UNION over
all bytes of {cells that differ from the byte-0 baseline}, and the reference stores
the full per-byte value table. This supersedes the old single-context sweep (which
proved each leaf in ONE context only): finefx_multictx_probe.py showed the DELAY
fine-FX are CONTEXT-DEPENDENT (TYPE 0 -> first instance 102xxx; TYPE 1 -> second
instance 4297xxx; TYPE 4 -> no cells), while CHORUS (DT2==DT3) and REVERB (RT0..RT5)
are context-independent. This reference pins every (leaf, context) the port applies.

Covenant-clean: the plugin's OWN setter + smoother under Unicorn. Two-process.
Output: scratchpad/finefx_cellsweep_ref.pkl { (leaf, ctx, rate) -> {cell: [256]} }.
"""
import sys, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import numpy as np, e2e_emu as E

SP = '/home/user/jn60c99/scratchpad'
SZ = 0xA83010; NW = SZ // 4
ET, DT, RT = 873, 875, 877
NOTE, VEL = 60, 105
fac = E.bank_bytes(); std = E.load_leaves()

def nib(r, o): return ((r[o] & 0xF) << 4) | (r[o + 1] & 0xF)
def _apply_std(e, blob):
    for (p, nm, disp, bb) in std:
        for u in range(9):
            try: e.dispatch(u, disp, E.dec(blob, bb))
            except RuntimeError: pass
def _force(e, disp, v):
    for u in range(9):
        try: e.dispatch(u, disp, v)
        except RuntimeError: pass

# reverb-active base patch (max REVERB LEVEL) + a factory DELAY-TYPE-1 patch
_revp = max(range(64), key=lambda i: nib(E.patch_blob(fac, i), 118 - 16))
_dt1p = next(i for i in range(64) if E.dec(E.patch_blob(fac, i), 634) == 1)

def build(base, dtype=None, rtype=None):
    e = E.E2E(); e.build(build.sr); e.snap_all()
    blob = E.patch_blob(fac, base); _apply_std(e, blob)
    if dtype is not None: _force(e, DT, dtype)
    if rtype is not None: _force(e, RT, rtype)
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(NOTE, VEL); e.render(600)
    return e

# ctx -> (leaves, base, dtype, rtype). DELAY is context-dependent (DT0 vs DT1);
# CHORUS DT2/DT3 and REVERB RT0/RT5 pin the context-independence the multictx probe
# proved. (DELAY TYPE 4 writes no fine-FX cell -> nothing to pin.)
# DELAY TYPE 5 (slot-1 reverb) hosts BOTH a delay-filter block (6497xxx, driven by the
# DELAY fine-FX leaves) and a chorus-filter block (10693xxx, driven by the CHORUS leaves)
# -- both with the same laws as DT0 / DT2 (proven, dt5_derive.py). _dt5p = a factory
# DELAY-TYPE-5 patch (reverb active natively).
_dt5p = next(i for i in range(64) if E.dec(E.patch_blob(fac, i), 634) == 5)
CONTEXTS = {
    'DT0': ([1180, 1181, 1182, 1183, 1184, 1185], 2, 0, None),
    'DT1': ([1180, 1181, 1182, 1183, 1184, 1185], _dt1p, 1, None),
    'DT5': ([1180, 1181, 1182, 1183, 1184, 1185, 1210, 1211, 1212], _dt5p, 5, None),
    'DT2': ([1210, 1211, 1212], 0, 2, None),
    'DT3': ([1210, 1211, 1212], 0, 3, None),
    'RT0': ([1324, 1325, 1326, 1327], _revp, None, 0),
    'RT5': ([1324, 1325, 1326, 1327], _revp, None, 5),
}

def rd_words(e):
    return np.frombuffer(bytes(e.uc.mem_read(e.state[0], SZ)), dtype='<u4')

def sweep_leaf(e, disp, nbytes=256):
    _force(e, disp, 0); e.snap_all(); a0 = rd_words(e)
    changed = np.zeros(NW, dtype=bool); vals = {}
    for v in range(nbytes):
        _force(e, disp, v); e.snap_all(); av = rd_words(e)
        changed |= (av != a0); vals[v] = av
    words = np.nonzero(changed)[0]
    return {int(w) * 4: [int(vals[v][w]) for v in range(nbytes)] for w in words}

def main():
    rates = [44100.0, 48000.0, 88200.0, 96000.0]
    if len(sys.argv) > 1:
        rates = [float(x) for x in sys.argv[1:]]
    out = {}
    for sr in rates:
        build.sr = sr
        for ctx, (leaves, base, dt, rt) in CONTEXTS.items():
            sys.stdout.write('[build %s @ %g]\n' % (ctx, sr)); sys.stdout.flush()
            e = build(base, dt, rt)
            for leaf in leaves:
                tbl = sweep_leaf(e, leaf)
                out[(leaf, ctx, sr)] = tbl
                sys.stdout.write('  leaf %d %-4s @%g: %d cells %s\n' % (
                    leaf, ctx, sr, len(tbl), sorted(tbl)[:8]))
                sys.stdout.flush()
    with open(SP + '/finefx_cellsweep_ref.pkl', 'wb') as f:
        pickle.dump(out, f)
    sys.stdout.write('wrote finefx_cellsweep_ref.pkl (%d rates x %d contexts)\n'
                     % (len(rates), len(CONTEXTS)))

if __name__ == '__main__':
    main()
