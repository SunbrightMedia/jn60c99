"""Oracle-only probe (CLAIMS B6): a patch load through the plugin's HOST entry
(rva 0x3C7AE0, flag 0, every recalled leaf the parameter map holds, no snap),
in three orders (ascending dispatch index, descending, shuffled), vs the
harness recall (flag 1 + snap). After each load: 9000 samples of silence (the
longest ramp is 96 ms), then the state every unit renders (warm_render_gate's
regions). Question 1: does the order change the settled state? Question 2:
does the host-path load settle to the harness recall's state?
Writes scratchpad/b6_load_order.pkl.
    python3 probes/b6/load_order.py      (Unicorn only)"""
import os, sys, struct, pickle, random, zlib
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
import seed_recall_gate as S
import warm_render_gate as WR

SR = 44100.0
SETTLE = 9000
bank = E.bank_bytes(); lt = R.leaf_table()
HEADER, STRIDE = 23, 20223


def grab(e):
    parts = []
    for v in range(8):
        for a, b in WR.voice_regions(v):
            parts.append(bytes(e.uc.mem_read(e.state[v] + a, b - a)))
    for a, b in WR.master_ranges():
        parts.append(bytes(e.uc.mem_read(e.state[8] + a, b - a)))
    return b''.join(parts)


def pid_map(e):
    uc = e.uc
    q = lambda x: int.from_bytes(uc.mem_read(x, 8), 'little')
    out, seen = {}, set()

    def walk(n):
        if not n or n in seen or uc.mem_read(n + 25, 1)[0]:
            return
        seen.add(n); walk(q(n))
        pid, idx = struct.unpack('<II', uc.mem_read(n + 28, 8)); out[idx] = pid
        walk(q(n + 16))
    walk(q(q(E.IB + 0xCB0E18) + 8))
    return out


def leaves_of(rb):
    blob = E.patch_blob(rb, 0)
    vals = [(d, R.dec(blob, bb)) for d, bb in lt] + list(RR.late_leaves(blob, R))
    return sorted(dict(vals).items())


def engine():
    e = RR.build_engine(E, SR)
    e.call(E.IB + 0xAD5A0, count=200_000_000)
    return e


def host_load(e, rb, order, pids, rnd):
    lv = [(d, v) for d, v in leaves_of(rb) if d in pids]
    if order == 'desc':
        lv = lv[::-1]
    elif order == 'shuf':
        rnd.shuffle(lv)
    for d, v in lv:
        e.call(E.IB + 0x3C7AE0, rcx=e.HOST, rdx=pids[d], r8=v & 0xFFFFFFFF, count=60_000_000)
    return len(lv)


def record(p, sets=None):
    rec = bytearray(bank[HEADER + p * STRIDE: HEADER + (p + 1) * STRIDE])
    return bytes(bank[:HEADER]) + bytes(rec)


slots, ranges = S.leaf_slots(), S.declared_ranges()
cases = [(0, 47), (12, 3), (55, 20), (31, 62)]
seeded = []
for k in range(3):
    a, _, _ = S.seed_bank(bank, 9100 + 2 * k, slots, ranges, wild=False)
    b, _, _ = S.seed_bank(bank, 9101 + 2 * k, slots, ranges, wild=False)
    seeded.append((a, b))
res = {}
rnd = random.Random(5)
pairs = [('f%d->f%d' % (a, b), record(a), record(b)) for a, b in cases] + \
        [('s%d' % k, a, b) for k, (a, b) in enumerate(seeded)]
for name, ra, rb in pairs:
    out = {}
    for mode in ('flag1', 'asc', 'desc', 'shuf'):
        e = engine()
        pids = pid_map(e)
        RR.apply_recall(e, 0, ra, lt, E, R)          # the starting patch, settled
        e.render(256)
        if mode == 'flag1':
            RR.apply_recall(e, 0, rb, lt, E, R)
            n = -1
        else:
            n = host_load(e, rb, mode, pids, rnd)
        e.render(SETTLE)
        out[mode] = (n, zlib.compress(grab(e), 6))
        del e
    res[name] = out
    sys.stderr.write('%s done (%d leaves through the host entry)\n' % (name, out['asc'][0])); sys.stderr.flush()
pickle.dump(res, open(os.path.join(REPO, 'scratchpad', 'b6_load_order.pkl'), 'wb'))
print('wrote scratchpad/b6_load_order.pkl')
