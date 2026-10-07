"""Oracle-only census (CLAIMS B6): the value each state entry takes when
IComponent::setState (rva 0x34AAA0 -> deserializer rva 0x321F20) sets it, for
values outside every range: what the engine event carries (the model's
storage law). Also an unknown id and a payload whose entries are not the
plugin's own order. Boots as state_load_census.py does.
Writes scratchpad/b6/state_mask_census.pkl.
    python3 probes/b6/state_mask_census.py      (Unicorn only)"""
import os, sys, struct, pickle, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wrapper_emu as W
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(REPO, 'scratchpad', 'b6', 'state_mask_census.pkl')
TEST = (0x12345678, -1, 0x1FF, 256, 0x100, 0x7FFFFFFF, -0x80000000, 0x10000, 0xFFFF, 0xFF, 0x80, 0x7F, 300, -129)


def payload(state):
    n = struct.unpack('>I', state[:4])[0]
    pl = state[4:4 + n]
    return [list(struct.unpack('>Ii', pl[i:i + 8])) for i in range(0, len(pl), 8)]


def build(entries):
    pl = b''.join(struct.pack('>Ii', i, v) for i, v in entries)
    return struct.pack('>I', len(pl)) + pl


def main():
    t0 = time.time()
    w = W.Wrapper(); uc = w.uc
    w.boot()
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    fac = w.call(W.FACTORY, count=100_000_000)
    buf = w.alloc_com(0x40)
    uc.mem_write(buf, bytes.fromhex('c74480f256663d4c9cfcecce62993ffd') + W.IID_IEDITCONTROLLER)
    assert w.vcall(fac, 6, buf, buf + 16, buf + 0x30) & 0xFFFFFFFF == 0
    ctrl = q(buf + 0x30)
    assert w.vcall(ctrl, 3, w.new_obj('hostctx'), count=4_000_000_000) & 0xFFFFFFFF == 0

    def qi(obj, iid):
        uc.mem_write(buf, iid)
        assert w.vcall(obj, 0, buf, buf + 0x30) & 0xFFFFFFFF == 0
        return q(buf + 0x30)
    cp_p, cp_c = qi(w.comp, W.IID_ICONNECTIONPOINT), qi(ctrl, W.IID_ICONNECTIONPOINT)
    assert w.vcall(cp_p, 3, cp_c) & 0xFFFFFFFF == 0 and w.vcall(cp_c, 3, cp_p) & 0xFFFFFFFF == 0
    assert w.vcall(ctrl, 16, w.new_obj('handler')) & 0xFFFFFFFF == 0
    s0 = w.get_state()
    assert w.vcall(ctrl, 5, w.stream(s0), count=4_000_000_000) & 0xFFFFFFFF == 0
    ent0 = payload(s0)
    res = {'state0': s0, 'cases': []}

    def run(name, ent):
        n0 = len(w.queue())
        r = w.set_state(build(ent))
        qq = [(k, o, struct.unpack_from('<I', rec, 12)[0], struct.unpack_from('<i', rec, 20)[0]) for k, o, rec in w.queue()[n0:]]
        res['cases'].append(dict(name=name, ret=r, payload=ent, queue=qq))
        print('%-24s setState 0x%x: %d events' % (name, r, len(qq)), flush=True)
    for v in TEST:
        run('all=%d' % v, [[i, v] for i, _ in ent0[:95]] + [list(e) for e in ent0[95:]])
    run('unknown id', [[0x7777, 5]] + [list(e) for e in ent0])
    run('params only, shuffled', [list(ent0[k]) for k in (12, 3, 89, 0, 78, 55, 57)])
    run('empty', [])
    run('cc map only', [list(e) for e in ent0[95:]])
    pickle.dump(res, open(OUT, 'wb'))
    print('wrote', OUT, '(%.0fs)' % (time.time() - t0))


if __name__ == '__main__':
    main()
