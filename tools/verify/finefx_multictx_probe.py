"""W0 discovery: does each fine-FX leaf write the SAME cells with the SAME per-byte
law across ALL its activating FX-type contexts, or is the law context-dependent?

The Pillar-3 gate proved each leaf in ONE context (delay: DELAY TYPE 0; chorus:
DELAY TYPE 2; reverb: default REVERB TYPE 0). This probe sweeps every leaf in its
OTHER reachable contexts and reports, vs the baseline context:
  - NEW cells   : the leaf writes here but not in baseline (port may be missing them)
  - GONE cells  : written in baseline but not here
  - DIFF cells  : written in both but the per-byte VALUE table differs (context law)
  - SAME        : identical cell set AND identical per-byte values (context-independent)

Covenant-clean (plugin's own setter under Unicorn, dispatch+snap). One rate (48000)
is enough to decide cell-set / law context-dependence; rate arms follow the family.
Output: scratchpad/finefx_multictx.json { "leaf|ctx": {cell: [256 vals]} } + report.
"""
import sys, json
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import numpy as np, e2e_emu as E

SP = '/home/user/jn60c99/scratchpad'
SZ = 0xA83010; NW = SZ // 4
ET, DT, RT = 873, 875, 877          # EFFECT TYPE / DELAY TYPE / REVERB TYPE dispatch
SR = 48000.0
fac = E.bank_bytes(); std = E.load_leaves()

def nib(r, o): return ((r[o] & 0xF) << 4) | (r[o + 1] & 0xF)
def apply_std(e, blob):
    for (p, nm, disp, bb) in std:
        for u in range(9):
            try: e.dispatch(u, disp, E.dec(blob, bb))
            except RuntimeError: pass
def force(e, disp, v):
    for u in range(9):
        try: e.dispatch(u, disp, v)
        except RuntimeError: pass
def rd(e): return np.frombuffer(bytes(e.uc.mem_read(e.state[0], SZ)), dtype='<u4')

def build(base, dtype=None, rtype=None):
    e = E.E2E(); e.build(SR); e.snap_all()
    blob = E.patch_blob(fac, base); apply_std(e, blob)
    if dtype is not None: force(e, DT, dtype)
    if rtype is not None: force(e, RT, rtype)
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(60, 105); e.render(600)
    return e

def sweep(e, disp, hi=255):
    force(e, disp, 0); e.snap_all(); a0 = rd(e)
    changed = np.zeros(NW, dtype=bool); vals = {}
    for v in range(hi + 1):
        force(e, disp, v); e.snap_all(); av = rd(e)
        changed |= (av != a0); vals[v] = av
    words = np.nonzero(changed)[0]
    return {int(w) * 4: [int(vals[v][w]) for v in range(hi + 1)] for w in words}

# revp = the max-REVERB-LEVEL patch (reverb definitely active)
revp = max(range(64), key=lambda i: nib(E.patch_blob(fac, i), 118 - 16))
# a factory DELAY-TYPE-1 patch for a realistic TYPE-1 slot-1 setup
dt1p = next(i for i in range(64) if E.dec(E.patch_blob(fac, i), 634) == 1)

# (family, leaves, [ (ctxname, base, dtype, rtype) ...], baseline_ctxname)
PLANS = [
    ('DELAY', [1180, 1181, 1182, 1183, 1184, 1185],
     [('DT0', 2, 0, None), ('DT1', dt1p, 1, None), ('DT4', 2, 4, None)], 'DT0'),
    ('CHORUS', [1210, 1211, 1212],
     [('DT2', 0, 2, None), ('DT3', 0, 3, None)], 'DT2'),
    ('REVERB', [1324, 1325, 1326, 1327],
     [('RT0', revp, None, 0), ('RT1', revp, None, 1), ('RT2', revp, None, 2),
      ('RT3', revp, None, 3), ('RT4', revp, None, 4), ('RT5', revp, None, 5)], 'RT0'),
]

def main():
    out = {}
    engines = {}
    print('dt1 patch =', dt1p, ' revp =', revp)
    for fam, leaves, ctxs, baseline in PLANS:
        # build one engine per ctx, reuse across the family's leaves
        for (cname, base, dt, rt) in ctxs:
            key = '%s:%s' % (fam, cname)
            if key not in engines:
                sys.stdout.write('[build %s]\n' % key); sys.stdout.flush()
                engines[key] = build(base, dt, rt)
        for leaf in leaves:
            tabs = {}
            for (cname, base, dt, rt) in ctxs:
                tabs[cname] = sweep(engines['%s:%s' % (fam, cname)], leaf)
                out['%d|%s' % (leaf, cname)] = tabs[cname]
            b = tabs[baseline]; bcells = set(b)
            for (cname, base, dt, rt) in ctxs:
                if cname == baseline:
                    continue
                t = tabs[cname]; cells = set(t)
                new = sorted(cells - bcells); gone = sorted(bcells - cells)
                diff = sorted(c for c in (cells & bcells) if t[c] != b[c])
                tag = 'SAME' if not (new or gone or diff) else 'DIFFERS'
                print('leaf %d %-4s vs %-4s: %s  new=%s gone=%s diff_law=%s' % (
                    leaf, cname, baseline, tag, new[:8], gone[:8], diff[:8]))
            sys.stdout.flush()
    json.dump({k: {str(c): v for c, v in d.items()} for k, d in out.items()},
              open(SP + '/finefx_multictx.json', 'w'))
    print('wrote finefx_multictx.json')

if __name__ == '__main__':
    main()
