"""Oracle-only probe (CLAIMS B1): the state of every ramp record of unit 0
right after build + setSampleRate (before and after the snap), and after a
cold recall of patch 0 + snap, at 44100 / 48000 / 96001. For each record:
target cell, start, target, incr, accum, rate, active, subdiv, step_cnt.
Writes scratchpad/ramp_records_cold.pkl; prints the records whose stored
target differs from the cell value, and the active ones.
    python3 probes/warm/ramp_records_cold.py      (Unicorn only)"""
import os, sys, struct, pickle, gc, math
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR

OUT = os.path.join(REPO, 'scratchpad', 'ramp_records_cold.pkl')
bank = E.bank_bytes()
lt = R.leaf_table()


def records(e, u=0):
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
        f = struct.unpack('<5f', bytes(uc.mem_read(rec + 8, 20)))
        act, sub, cnt = struct.unpack('<3i', bytes(uc.mem_read(rec + 28, 12)))
        cellv = struct.unpack('<f', bytes(uc.mem_read(outp, 4)))[0] if outp else None
        out[ix] = dict(desc=i, cell=outp - st, incr=f[0], accum=f[1], start=f[2], target=f[3],
                       rate=f[4], active=act & 0xFF, subdiv=sub, step=cnt, cellv=cellv)
    return out


def same(a, b):
    return (a == b) or (isinstance(a, float) and isinstance(b, float) and math.isnan(a) and math.isnan(b))


res = {}
for sr in (44100.0, 48000.0, 96001.0):
    e = E.E2E(); e.build(sr)
    pre = records(e)
    e.snap_all()
    post = records(e)
    RR.apply_recall(e, 0, bank, lt, E, R)
    rec0 = records(e)
    res[sr] = dict(pre=pre, post=post, recall0=rec0)
    act = [ix for ix, r in pre.items() if r['active']]
    print('== %g: %d records; active after build+setSR: %d %s' % (sr, len(pre), len(act),
          [(ix, pre[ix]['cell'], pre[ix]['start'], pre[ix]['target']) for ix in act[:12]]))
    diff = [(ix, r['cell'], r['cellv'], r['target']) for ix, r in post.items() if not same(r['cellv'], r['target'])]
    print('   after snap: records whose stored target != cell value: %d %s' % (len(diff), diff[:16]))
    diff = [(ix, r['cell'], r['cellv'], r['target']) for ix, r in rec0.items() if not same(r['cellv'], r['target'])]
    print('   after cold recall p0 + snap: stored target != cell value: %d %s' % (len(diff), diff[:16]))
    rates = sorted(set(r['rate'] for r in pre.values()))
    subs = sorted(set(r['subdiv'] for r in pre.values()))
    print('   record rates %s, subdivs %s' % (rates[:6], subs[:6]))
    del e
    gc.collect()
pickle.dump(res, open(OUT, 'wb'))
print('wrote', OUT)
