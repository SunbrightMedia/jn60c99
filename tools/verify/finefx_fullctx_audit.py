"""W0 adversarial completeness audit: sweep EVERY fine-FX leaf in EVERY router
context it could plausibly reach, and flag any (leaf, context) that materializes
coefficient cells the port's appliers do NOT cover. This goes beyond the contexts
Fable's W0 named -- it is the skeptic's check that no context was missed:

  DELAY leaves 1180-1185  x  DELAY TYPE 0,1,2,3,4,5           (does HIGH CUT write
                                                               anything in a chorus/
                                                               reverb slot-1 routing?)
  CHORUS leaves 1210-1212 x  DELAY TYPE 0,1,2,3,4,5
  REVERB leaves 1324-1327 x  EFFECT TYPE 0,2,3,4,5 (+ the REVERB TYPE sweep already
                                                    in finefx_multictx_probe.py)

For each (leaf, ctx) it prints the changed-cell set and whether every cell is in the
PORT write set (port_writeset.pkl, regenerated from the shipping libjuno). A cell the
plugin writes that the port does not => an uncovered context (RED for the audit).

Covenant-clean (plugin setter under Unicorn). One rate (48000) decides cell coverage.
"""
import sys, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import numpy as np, e2e_emu as E

SZ = 0xA83010; NW = SZ // 4
ET, DT, RT = 873, 875, 877
SR = 48000.0
fac = E.bank_bytes(); std = E.load_leaves()
PORTWS = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/port_writeset.pkl'
try:
    port = set(pickle.load(open(PORTWS, 'rb')))
except Exception:
    port = set()

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
def build(base, dt=None, rt=None, et=None):
    e = E.E2E(); e.build(SR); e.snap_all()
    blob = E.patch_blob(fac, base); apply_std(e, blob)
    if et is not None: force(e, ET, et)
    if dt is not None: force(e, DT, dt)
    if rt is not None: force(e, RT, rt)
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(60, 105); e.render(600)
    return e
def sweep(e, disp, hi=255):
    force(e, disp, 0); e.snap_all(); a0 = rd(e); ch = np.zeros(NW, bool)
    for v in range(hi + 1):
        force(e, disp, v); e.snap_all(); ch |= (rd(e) != a0)
    return [int(w) * 4 for w in np.nonzero(ch)[0]]

revp = max(range(64), key=lambda i: nib(E.patch_blob(fac, i), 118 - 16))
dt1p = next(i for i in range(64) if E.dec(E.patch_blob(fac, i), 634) == 1)

PLANS = []
for dt in (0, 1, 2, 3, 4, 5):
    base = dt1p if dt == 1 else 2
    PLANS.append(('DELAY  DT%d' % dt, [1180, 1181, 1182, 1183, 1184, 1185], dict(dt=dt), base))
    PLANS.append(('CHORUS DT%d' % dt, [1210, 1211, 1212], dict(dt=dt), base if dt not in (2, 3) else 0))
for et in (0, 2, 3, 4, 5):
    PLANS.append(('REVERB ET%d' % et, [1324, 1325, 1326, 1327], dict(et=et), revp))

def main():
    print('revp=%d dt1p=%d  port_writeset=%d cells' % (revp, dt1p, len(port)))
    any_uncovered = False
    for name, leaves, kw, base in PLANS:
        e = build(base, **kw)
        for leaf in leaves:
            cells = sweep(e, leaf)
            unc = [c for c in cells if c not in port]
            flag = '' if not unc else '  <<< UNCOVERED %s' % unc[:8]
            if unc: any_uncovered = True
            print('  %-11s leaf %d: %2d cells %s%s' % (name, leaf, len(cells), sorted(cells)[:6], flag))
        sys.stdout.flush()
    print('AUDIT:', 'RED (uncovered contexts above)' if any_uncovered else
          'CLEAN -- every materialized fine-FX cell is in the port write set')

if __name__ == '__main__':
    main()
