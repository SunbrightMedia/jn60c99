#!/usr/bin/env python3
"""LANE D — analog-noise block (84272..84436) policy WHILE A NOTE PLAYS.

Unicorn ONLY (no libjuno in this process; two-process rule).

Builds the plugin's own engine, drives its OWN complete recall (recall_render_ab.
prepare_recall) for a bank patch, plays notes, renders, and dumps the shared
analog-noise block from EVERY unit 0..8 to see whether the 8 voice units stay in
lockstep (which is what the port's snapshot/restore models).
"""
import sys, os, struct, json

sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RA

BANK_PATH = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
             '0e8b9cb5-Chillwave.bin')
SR   = float(os.environ.get('LD_SR', '44100'))
IDX  = int(os.environ.get('LD_IDX', '3'))
NSAMP= int(os.environ.get('LD_N', '8000'))
NOFF = 84272
NLEN = 164

CELLS = list(range(NOFF, NOFF + NLEN, 4))   # 41 dwords

def name_of(bank, i):
    HDR, STRIDE = 23, 20223
    nm = bank[HDR + i*STRIDE: HDR + i*STRIDE + 16]
    return bytes(c if 32 <= c < 127 else 32 for c in nm).decode().strip()

def blk(e, u):
    return bytes(e.uc.mem_read(e.state[u] + NOFF, NLEN))

def blkcells(e, u):
    b = blk(e, u)
    return {off: struct.unpack_from('<I', b, off - NOFF)[0] for off in CELLS}

def f32(bits):
    return struct.unpack('<f', struct.pack('<I', bits))[0]

def paramdb(e, idx):
    a = E.IB + 0x98c040 + 16*idx
    lo, hi = struct.unpack('<ii', e.uc.mem_read(a, 8))
    return lo, hi

def run(tag, notes, condition=None, nsamp=NSAMP, chunks=None):
    bank = open(BANK_PATH, 'rb').read()
    leaves = R.leaf_table()
    e = RA.prepare_recall(IDX, bank, leaves, E, R, SR)
    rec = {'tag': tag, 'notes': notes, 'condition': condition,
           'patch': name_of(bank, IDX), 'n': nsamp}
    if condition is not None:
        lo, hi = paramdb(e, 856)
        rec['cond_range'] = [lo, hi]
        R.wr_desc(e, 856, condition)
        for u in range(9):
            try: e.dispatch(u, 856, condition)
            except RuntimeError as ex: rec.setdefault('cond_err', []).append(str(ex))
        e.snap_all()
    rec['pre'] = {u: blk(e, u).hex() for u in range(9)}
    for (n, v) in notes:
        e.note_on(n, v)
    # which voice(s) got allocated: peek assigner counters is not it; just render
    marks = {}
    done = 0
    for stop in (chunks or []) + [nsamp]:
        if stop <= done: continue
        e.render(stop - done, block=600 if (stop-done) >= 600 else (stop-done))
        done = stop
        marks[stop] = {u: blk(e, u).hex() for u in range(9)}
    rec['marks'] = marks
    del e
    return rec

def cmp_units(hexmap, label, out):
    b = {u: bytes.fromhex(hexmap[u]) for u in hexmap}
    ref = b[0]
    same = [u for u in range(8) if b[u] == ref]
    diff = {}
    for u in range(1, 9):
        if b[u] == ref: continue
        d = []
        for off in CELLS:
            a = struct.unpack_from('<I', ref, off-NOFF)[0]
            c = struct.unpack_from('<I', b[u], off-NOFF)[0]
            if a != c:
                d.append((off, a, c, f32(a), f32(c)))
        diff[u] = d
    out.append("  %s: units 0..7 identical to unit0: %s (%d/8)" %
               (label, sorted(same), len(same)))
    for u in sorted(diff):
        out.append("    unit %d differs from unit 0 in %d cells:" % (u, len(diff[u])))
        for (off, a, c, fa, fc) in diff[u]:
            out.append("      off %d  u0=0x%08x (%.9g)  u%d=0x%08x (%.9g)"
                       % (off, a, fa, u, c, fc))
    return out

if __name__ == '__main__':
    scen = sys.argv[1] if len(sys.argv) > 1 else 'all'
    res = {}
    todo = []
    if scen in ('all','A'): todo.append(('A_default_1note', [(60,100)], None))
    if scen in ('all','B'): todo.append(('B_cond40_1note',  [(60,100)], 40))
    if scen in ('all','C'): todo.append(('C_cond220_1note', [(60,100)], 220))
    if scen in ('all','D'): todo.append(('D_default_4notes',[(48,100),(55,100),(60,100),(64,100)], None))
    for (tag, notes, cond) in todo:
        sys.stderr.write("=== %s ===\n" % tag); sys.stderr.flush()
        res[tag] = run(tag, notes, cond, chunks=[1, 64, 600, 601, 1200])
        sys.stderr.write("    done\n"); sys.stderr.flush()
    json.dump(res, open('/home/user/jn60c99/probes/render_loop/laneD_%s.json' % scen, 'w'))
    out = []
    for tag in res:
        r = res[tag]
        out.append("SCENARIO %s  patch '%s'  cond=%s range=%s notes=%s" %
                   (tag, r['patch'], r['condition'], r.get('cond_range'), r['notes']))
        cmp_units(r['pre'], 'PRE-note', out)
        for stop in sorted(r['marks'], key=int):
            cmp_units(r['marks'][stop], 'after %s samples' % stop, out)
        out.append("")
    print("\n".join(out))
