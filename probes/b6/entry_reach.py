"""Oracle-only probe (CLAIMS B6/B10): what each of the 95 state-load entries does
at the engine's host entry (rva 0x3C7AE0). For every (id, value) the plugin's
own setState queues (scratchpad/b6/state_load_census.pkl, the getState payload),
on a fresh engine with the parameter map built: is the id in the map, does the
call return, and how many state bytes change (all 9 units) plus HOST+0x38.
    python3 probes/b6/entry_reach.py      (Unicorn only)"""
import os, sys, struct, pickle, zlib
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import recall_render_ab as RR

cen = pickle.load(open(os.path.join(REPO, 'scratchpad', 'b6', 'state_load_census.pkl'), 'rb'))
s0 = cen['state0']
n = struct.unpack('>I', s0[:4])[0]
ent = [struct.unpack('>Ii', s0[4 + i:12 + i]) for i in range(0, n, 8)][:95]


def pid_map(e):
    uc = e.uc
    q = lambda x: int.from_bytes(uc.mem_read(x, 8), 'little')
    out, seen = {}, set()

    def walk(nd):
        if not nd or nd in seen or uc.mem_read(nd + 25, 1)[0]:
            return
        seen.add(nd); walk(q(nd))
        pid, idx = struct.unpack('<II', uc.mem_read(nd + 28, 8)); out[pid] = idx
        walk(q(nd + 16))
    walk(q(q(E.IB + 0xCB0E18) + 8))
    return out


e = RR.build_engine(E, 44100.0)
e.call(E.IB + 0xAD5A0, count=200_000_000)
pm = pid_map(e)
snap = lambda: [bytes(e.uc.mem_read(e.state[u], E.STATE_SZ)) for u in range(9)]
res = []
for k, (pid, v) in enumerate(ent):
    before = snap(); h0 = bytes(e.uc.mem_read(e.HOST, 0x480))
    err = None
    try:
        e.call(E.IB + 0x3C7AE0, rcx=e.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=60_000_000)
    except Exception as ex:
        err = str(ex)[:80]
    after = snap(); h1 = bytes(e.uc.mem_read(e.HOST, 0x480))
    nb = sum(sum(1 for i in range(0, E.STATE_SZ, 4) if a[i:i + 4] != b[i:i + 4]) for a, b in zip(before, after))
    hb = [i for i in range(0, 0x480, 4) if h0[i:i + 4] != h1[i:i + 4]]
    res.append((k, pid, v, pm.get(pid), err, nb, hb))
    print(k, hex(pid), v, 'map' if pid in pm else 'NOT-IN-MAP', err or '', 'cells', nb, 'host', [hex(x) for x in hb][:6])
pickle.dump(res, open(os.path.join(REPO, 'scratchpad', 'b6', 'entry_reach.pkl'), 'wb'))
