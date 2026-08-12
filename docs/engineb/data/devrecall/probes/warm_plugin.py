#!/usr/bin/env python3
"""warm_plugin.py -- DOES THE PLUGIN'S OWN RECALL DEPEND ON WHAT WAS LOADED BEFORE?

  cold(B) = fresh engine -> recall B
  warm(A->B) = fresh engine -> recall A -> recall B

Diff the two over the WHOLE 9-unit engine state (9 x 0xA83010 bytes), not the
first 10512.  Recall driving = recall_render_ab.prepare_recall's body verbatim
(the proven-complete recall the port reproduces bit-exactly, 57/57 render A/B),
factored so it can run TWICE in one engine.

Two variants:
  --variant enum  : ONLY the leaves the plugin's own recall enumerator (0x3B48A0)
                    fires -- leaf_table + FX_LEAVES + EXTRA_LEAVES.  Patch-
                    INDEPENDENT index set; only the values change per patch.
  --variant full  : enum + the fine-FX leaves a real host's controller path adds
                    (DELAY/CHORUS/REVERB filter leaves).  This is what
                    prepare_recall does and what the port's juno_bank_apply does.
                    The fine-FX leaf SET is patch-dependent (gated on DELAY TYPE).

NO ctypes anywhere in this process (two-process rule).
"""
import sys, os, zlib, pickle, struct, gc, time, argparse

HERE = '/home/user/jn60c99/tools/verify'
sys.path.insert(0, HERE)
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR

NUNITS = 9


def recall_into(e, idx, bank, leaves, variant):
    """prepare_recall's body, minus the build.  Runs on an ALREADY-BUILT engine so
    it can be called twice (warm).  Verbatim from recall_render_ab.prepare_recall
    lines 145-180 apart from the build/snap prologue."""
    blob = E.patch_blob(bank, idx)
    for (disp, bb) in leaves:
        R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, recoff) in RR.FX_LEAVES:
        R.wr_desc(e, disp, R.dec(blob, recoff - 16))
    for (disp, bb) in RR.EXTRA_LEAVES:
        R.wr_desc(e, disp, R.dec(blob, bb))
    if variant == 'full':
        finefx = RR._finefx_leaves(blob, R)
    elif variant == 'allfx':
        # The plugin's OWN recall enumerator (0x3B48A0) fires 1180-1185, 1210-1215
        # and 1323-1327 UNCONDITIONALLY, after 873/875 (order captured by
        # enumorder.py).  This variant removes the harness's DELAY-TYPE gating.
        finefx = RR.DELAY_FILT_LEAVES + RR.CHORUS_FINEFX_LEAVES + RR.REVERB_FINEFX_LEAVES
    else:
        finefx = []
    for (disp, recoff, raw) in finefx:
        v = (blob[recoff - 16] & 0x7F) if raw else R.dec(blob, recoff - 16)
        R.wr_desc(e, disp, v)
    for u in range(NUNITS):
        for (disp, bb) in leaves:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff) in RR.FX_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, bb) in RR.EXTRA_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff, raw) in finefx:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    e.assigner_notify()
    e.snap_all()


def snapshot(e):
    return [bytes(e.uc.mem_read(e.state[u], E.STATE_SZ)) for u in range(NUNITS)]


def build_engine(sr):
    e = E.E2E(); e.build(sr); e.snap_all()
    return e


def diff_units(cold, warm):
    """-> (total differing bytes, {unit: [(start,end,coldf,warmf), ...]})"""
    tot = 0; per = {}
    for u in range(NUNITS):
        c, w = cold[u], warm[u]
        if c == w:
            continue
        runs = []
        i = 0; n = len(c)
        # fast scan: compare in 64 KiB slabs first
        SL = 65536
        for s0 in range(0, n, SL):
            cs = c[s0:s0+SL]; ws = w[s0:s0+SL]
            if cs == ws: continue
            i = 0
            while i < len(cs):
                if cs[i] != ws[i]:
                    st = i
                    while i < len(cs) and cs[i] != ws[i]: i += 1
                    a = s0 + st; b = s0 + i
                    tot += (b - a)
                    cf = struct.unpack('<f', c[(a & ~3):(a & ~3)+4])[0]
                    wf = struct.unpack('<f', w[(a & ~3):(a & ~3)+4])[0]
                    runs.append((a, b, cf, wf))
                else:
                    i += 1
        per[u] = runs
    return tot, per


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rate', type=float, default=44100.0)
    ap.add_argument('--variant', default='full', choices=['full', 'enum', 'allfx'])
    ap.add_argument('--pairs', default='all')
    ap.add_argument('--out', default='/tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad/warmab')
    a = ap.parse_args()

    bank = E.bank_bytes(); leaves = R.leaf_table()
    if a.pairs == 'all':
        pairs = [(p, (p + 1) % 64) for p in range(64)]
    else:
        pairs = [tuple(int(x) for x in s.split('-')) for s in a.pairs.split(',')]

    tag = '%s_%d' % (a.variant, int(a.rate))
    cdir = os.path.join(a.out, 'cold_' + tag); os.makedirs(cdir, exist_ok=True)

    need = sorted({b for (_, b) in pairs})
    t0 = time.time()
    for p in need:
        fp = os.path.join(cdir, 'c%02d.z' % p)
        if os.path.exists(fp): continue
        e = build_engine(a.rate); recall_into(e, p, bank, leaves, a.variant)
        snap = snapshot(e)
        open(fp, 'wb').write(zlib.compress(pickle.dumps(snap), 1))
        del e, snap; gc.collect()
        sys.stderr.write('cold %2d  %.0fs\n' % (p, time.time() - t0)); sys.stderr.flush()

    results = {}
    for (x, y) in pairs:
        cold = pickle.loads(zlib.decompress(open(os.path.join(cdir, 'c%02d.z' % y), 'rb').read()))
        e = build_engine(a.rate)
        recall_into(e, x, bank, leaves, a.variant)
        recall_into(e, y, bank, leaves, a.variant)
        warm = snapshot(e)
        del e; gc.collect()
        tot, per = diff_units(cold, warm)
        results[(x, y)] = (tot, per)
        print('PAIR %2d -> %2d : %6d differing bytes  units=%s' %
              (x, y, tot, sorted(per.keys())))
        for u in sorted(per):
            for (s, t, cf, wf) in per[u][:8]:
                print('      u%d [%d..%d) cell %d  cold=%g warm=%g' % (u, s, t, (s // 16) * 16, cf, wf))
            if len(per[u]) > 8:
                print('      u%d ... %d more runs' % (u, len(per[u]) - 8))
        sys.stdout.flush()
        del cold, warm; gc.collect()

    pickle.dump({str(k): v for k, v in results.items()},
                open(os.path.join(a.out, 'plugin_%s.pkl' % tag), 'wb'))
    nd = sum(1 for v in results.values() if v[0])
    print('\n=== PLUGIN warm-vs-cold, variant=%s rate=%g, %d pairs ===' % (a.variant, a.rate, len(pairs)))
    print('    pairs with ANY differing byte over the whole 9x0xA83010 state : %d of %d' % (nd, len(pairs)))
    if nd:
        print('    worst %d bytes' % max(v[0] for v in results.values()))


if __name__ == '__main__':
    main()
