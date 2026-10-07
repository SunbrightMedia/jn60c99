"""Oracle-only probe (CLAIMS B15): the engine's ramp records at the FIRST engine render of the
plugin's own process() (after its boot, the engine-rate setSampleRate, the tempo and the queued
records), unit 0 and unit 6 -- versus the e2e engine built at the same rate WITHOUT the ramp
settle and fed the same records (the oracle every gate uses settles them). Prints the records
that differ between the two (cell, active, start, target, incr, accum, step, cell value).

    python3 probes/host_render/boot_records.py [rate setting]      (Unicorn only)"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H     # noqa: E402
import e2e_emu as E              # noqa: E402

rate = float(sys.argv[1]) if len(sys.argv) > 1 else 48000.0
setting = int(sys.argv[2]) if len(sys.argv) > 2 else 2


def records(uc, st):
    base = struct.unpack('<Q', uc.mem_read(st + 88, 8))[0]
    a = struct.unpack('<Q', uc.mem_read(st + 112, 8))[0]
    b = struct.unpack('<Q', uc.mem_read(st + 120, 8))[0]
    act = set(struct.unpack('<%di' % ((b - a) // 4), uc.mem_read(a, b - a))) if b > a else set()
    out = {}
    k = 0
    while True:
        rec = base + 40 * k
        raw = bytes(uc.mem_read(rec, 40))
        outp = struct.unpack_from('<Q', raw, 0)[0]
        if not outp or not (st <= outp < st + E.STATE_SZ):
            break
        cell = outp - st
        f = struct.unpack_from('<IIIIIIII', raw, 8)
        out[cell] = (1 if k in act else 0, f, struct.unpack('<I', uc.mem_read(outp, 4))[0])
        k += 1
    return out


snap = {}
h = H.HostProcess()


def grab_first(self_serve=H.HostProcess._serve):
    def serve(self, req):
        if 'prod' not in snap:
            snap['prod'] = {u: records(self.uc, self.state[u]) for u in (0, 6)}
        return self_serve(self, req)
    return serve


H.HostProcess._serve = grab_first()
h.start(rate, 512, setting=setting)
init = [(struct.unpack_from('<I', r, 12)[0], struct.unpack_from('<i', r, 20)[0]) for k, o, r in h.queue()]
h.process(512)
del h
e = E.E2E()
e.build(rate)
e.call(E.IB + 0xAD5A0, count=200_000_000)
e.set_ftz()
for pid, v in init:
    e.call(E.IB + 0x3C7AE0, rcx=e.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=60_000_000)
snap['e2e'] = {u: records(e.uc, e.state[u]) for u in (0, 6)}
for u in (0, 6):
    P, Q = snap['prod'][u], snap['e2e'][u]
    print('unit %d: %d records (prod), %d (e2e); active prod %d, e2e %d' % (
        u, len(P), len(Q), sum(v[0] for v in P.values()), sum(v[0] for v in Q.values())))
    diff = [c for c in sorted(P) if P.get(c) != Q.get(c)]
    print('  %d records differ' % len(diff))
    for c in diff[:25]:
        p, q = P[c], Q.get(c)
        print('  cell %8d prod act %d f %s val %08x | e2e act %s f %s val %s' % (
            c, p[0], ' '.join('%08x' % x for x in p[1]), p[2],
            q[0] if q else '-', ' '.join('%08x' % x for x in q[1]) if q else '-', '%08x' % q[2] if q else '-'))
