"""Oracle-only probe (CLAIMS B7): every ramp record of EVERY unit after build +
setSampleRate + snap, at several host rates, mapped onto the port's one state
(voice v's cells from unit v, the master from unit 8, as warm_render_gate.py
compares). For each type-1 descriptor cell of the composite: the record's
stored target and the cell value. Prints the cells whose stored target is not
the cell value (the records the build never armed after its last immediate
write) and whether that target depends on the rate.
Writes scratchpad/ramp_records_units.pkl.
    python3 probes/host/ramp_records_units.py      (Unicorn only)"""
import os, sys, struct, pickle, gc, math
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E

OUT = os.path.join(REPO, 'scratchpad', 'ramp_records_units.pkl')
VSTRIDE, MAIN0, AUX0, AUXN = 10512, 176, 101488, 32
SHARED = (84272, 84436)


def owner(c):
    """the unit whose copy of cell c the port's one state holds"""
    if MAIN0 <= c < MAIN0 + 8 * VSTRIDE:
        return (c - MAIN0) // VSTRIDE
    if AUX0 <= c < AUX0 + 8 * AUXN:
        return (c - AUX0) // AUXN
    if SHARED[0] <= c < SHARED[1]:
        return 'shared'
    return 8


def records(e, u):
    uc = e.uc
    st = e.state[u]
    q = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
    desc, desc_end, base = q(st + 0x38), q(st + 0x40), q(st + 0x58)
    out = {}
    for i in range((desc_end - desc) // 40):
        if int.from_bytes(uc.mem_read(desc + 40 * i + 0xC, 4), 'little') != 1:
            continue
        ix = int.from_bytes(uc.mem_read(desc + 40 * i + 0x14, 4), 'little')
        rec = base + 40 * ix
        outp = q(rec)
        raw = bytes(uc.mem_read(rec + 8, 32))
        cellv = int.from_bytes(uc.mem_read(outp, 4), 'little')
        out[outp - st] = dict(desc=i, ix=ix, raw=raw, target=int.from_bytes(raw[12:16], 'little'),
                              cellv=cellv, active=raw[20])
    return out


res = {}
for sr in (44100.0, 48000.0, 96001.0, 22050.0, 192000.0):
    e = E.E2E(); e.build(sr); e.snap_all()
    per = {u: records(e, u) for u in range(9)}
    comp = {}
    bad_shared = []
    for c in per[0]:
        o = owner(c)
        if o == 'shared':
            vals = set((per[u][c]['target'], per[u][c]['cellv']) for u in range(9))
            if len(vals) > 1:
                bad_shared.append((c, vals))
            comp[c] = per[0][c]
        else:
            comp[c] = per[o][c]
    diff = {c: (r['target'], r['cellv']) for c, r in comp.items() if r['target'] != r['cellv']}
    act = [c for c, r in comp.items() if r['active']]
    res[sr] = dict(comp={c: (r['target'], r['cellv'], r['desc'], r['ix']) for c, r in comp.items()}, diff=diff)
    print('== %g: %d composite records, %d target != cell, %d active, shared disagreements %d'
          % (sr, len(comp), len(diff), len(act), len(bad_shared)))
    del e; gc.collect()
rs = list(res)
d0 = res[rs[0]]['diff']
for sr in rs[1:]:
    d = res[sr]['diff']
    only0 = sorted(set(d0) - set(d)); only1 = sorted(set(d) - set(d0))
    tgt = [c for c in set(d0) & set(d) if d0[c][0] != d[c][0]]
    print('%g vs %g: diff-set only first %s, only second %s, targets differ at %d cells %s'
          % (rs[0], sr, only0, only1, len(tgt), sorted(tgt)[:8]))
f32 = lambda x: struct.unpack('<f', struct.pack('<I', x))[0]
print('targets of the build-stale records (44100):')
print(sorted(set('%08x' % t for t, v in d0.values())))
pickle.dump(res, open(OUT, 'wb'))
print('wrote', OUT)
