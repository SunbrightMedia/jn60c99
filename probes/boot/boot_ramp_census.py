"""Oracle-only census (CLAIMS B15): the engine's ramp records the plugin's boot leaves, before its
first process() -- the product start (default setting: the engine built at 96000, no
setSampleRate), host rates 44100 / 48000 / 96000. For every ramped cell of the port
(src/ramp_cells.h, voice v from unit v, the master from unit 8): the record (incr, accum, start,
target, rate, active, subdiv, step) and the cell. Prints: active records per boot, their rate /
subdiv values, whether the boots agree, and the idle records whose stored target differs from the
cell (versus JUNO_RAMP_BUILD0, which a build + setSampleRate + snap gave). Writes
scratchpad/boot_ramp_census.pkl.
    python3 probes/boot/boot_ramp_census.py      (Unicorn only)"""
import os
import pickle
import re
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H        # noqa: E402
import e2e_emu as E                 # noqa: E402

src = open(os.path.join(REPO, 'src', 'ramp_cells.h')).read()
cells = [int(x) for x in re.findall(r'(\d+)u', src[src.index('JUNO_RAMP_CELL['):src.index('};', src.index('JUNO_RAMP_CELL['))])]
b0 = src[src.index('JUNO_RAMP_BUILD0[JUNO_RAMP_N]'):]
build0 = [int(x) for x in re.findall(r'\b([01])\b', b0[b0.index('{') + 1:b0.index('}')])]
assert len(cells) == len(build0), (len(cells), len(build0))


def unit_of(c):
    if 176 <= c < 176 + 8 * 10512:
        return (c - 176) // 10512
    if 101488 <= c < 101488 + 8 * 32:
        return (c - 101488) // 32
    return 8


def records(uc, st):
    base = struct.unpack('<Q', uc.mem_read(st + 88, 8))[0]
    a = struct.unpack('<Q', uc.mem_read(st + 112, 8))[0]
    b = struct.unpack('<Q', uc.mem_read(st + 120, 8))[0]
    act = list(struct.unpack('<%di' % ((b - a) // 4), uc.mem_read(a, b - a))) if b > a else []
    out = {}
    k = 0
    while True:
        raw = bytes(uc.mem_read(base + 40 * k, 40))
        outp = struct.unpack_from('<Q', raw, 0)[0]
        if not outp or not (st <= outp < st + E.STATE_SZ):
            break
        out[outp - st] = (k in act, struct.unpack_from('<IIIIIIII', raw, 8),
                          struct.unpack('<I', uc.mem_read(outp, 4))[0])
        k += 1
    return out, act


res = {}
for rate in (48000.0, 44100.0, 96000.0):
    h = H.HostProcess()
    h.start(rate, 512)
    recs = [records(h.uc, h.state[u]) for u in range(9)]
    table = []
    for i, c in enumerate(cells):
        rr, act = recs[unit_of(c)]
        if c not in rr:
            raise SystemExit('cell %d has no record on unit %d' % (c, unit_of(c)))
        table.append(rr[c])
    res[rate] = dict(table=table, nact=[len(recs[u][1]) for u in range(9)])
    del h
t0 = res[48000.0]['table']
same = all(res[r]['table'] == t0 for r in res)
print('boots agree at 44100 / 48000 / 96000:', same)
print('active records per unit (48000):', res[48000.0]['nact'])
act = [(cells[i], t) for i, t in enumerate(t0) if t[0]]
print('port ramped cells with an active record:', len(act))
f = lambda x: struct.unpack('<f', struct.pack('<I', x))[0]
rates = sorted(set(f(t[1][4]) for c, t in act))
subd = sorted(set(t[1][6] for c, t in act))
print('active rate fields:', rates, 'subdiv fields:', subd)
idle_diff = [i for i, t in enumerate(t0) if not t[0] and t[1][3] != t[2]]
print('idle records with stored target != cell:', len(idle_diff),
      ' BUILD0 marks:', sum(build0), ' overlap:', len(set(idle_diff) & set(i for i, b in enumerate(build0) if b)))
print('idle target==0.0 and cell!=0:', sum(1 for i in idle_diff if t0[i][1][3] == 0))
for c, t in act[:12]:
    print('  cell %8d start %.6g target %.6g incr %.6g accum %.6g step %d value %.6g' % (
        c, f(t[1][2]), f(t[1][3]), f(t[1][0]), f(t[1][1]), t[1][7], f(t[2])))
pickle.dump(dict(cells=cells, res=res), open(os.path.join(REPO, 'scratchpad', 'boot_ramp_census.pkl'), 'wb'))
