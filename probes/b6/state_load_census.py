"""Oracle-only census (CLAIMS B6): what the plugin's OWN preset load hands the
engine. Boots the plugin as a VST3 host does (probes/b6/wrapper_emu.py:
DllMain, InitDll, createInstance, IComponent::initialize, the edit controller
created, initialized, connected both ways, a component handler attached), then:

  1. reads the engine event queue (core+440) left by initialize -- the
     parameter defaults the first process() call applies;
  2. IComponent::getState -> the plugin's own state payload (list order);
  3. IComponent::setState with that payload, and with payloads whose values
     are changed (every value, and one value), recording the engine queue
     and every IComponentHandler call (beginEdit/performEdit/endEdit).

Each queue record is the plugin's own 24-byte event: kind 2 = (parameter id,
raw value) applied through the engine's host entry (rva 0x3C7AE0) by the
render driver (rva 0x320B20) at the start of the next block.
Writes scratchpad/b6/state_load_census.pkl.
    python3 probes/b6/state_load_census.py      (Unicorn only)"""
import os, sys, struct, pickle, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wrapper_emu as W

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(REPO, 'scratchpad', 'b6', 'state_load_census.pkl')


def payload(state):
    n = struct.unpack('>I', state[:4])[0]
    pl = state[4:4 + n]
    return [list(struct.unpack('>Ii', pl[i:i + 8])) for i in range(0, len(pl), 8)]


def build(entries):
    pl = b''.join(struct.pack('>Ii', i, v) for i, v in entries)
    return struct.pack('>I', len(pl)) + pl


def decode(q):
    out = []
    for kind, off, rec in q:
        out.append((kind, off, struct.unpack_from('<I', rec, 12)[0], struct.unpack_from('<i', rec, 20)[0]))
    return out


def main():
    t0 = time.time()
    w = W.Wrapper(); uc = w.uc
    w.boot()
    fac = w.call(W.FACTORY, count=100_000_000)
    buf = w.alloc_com(0x40)
    uc.mem_write(buf, bytes.fromhex('c74480f256663d4c9cfcecce62993ffd') + W.IID_IEDITCONTROLLER)
    assert w.vcall(fac, 6, buf, buf + 16, buf + 0x30) & 0xFFFFFFFF == 0
    ctrl = struct.unpack('<Q', uc.mem_read(buf + 0x30, 8))[0]
    assert w.vcall(ctrl, 3, w.new_obj('hostctx'), count=4_000_000_000) & 0xFFFFFFFF == 0

    def qi(obj, iid):
        uc.mem_write(buf, iid)
        assert w.vcall(obj, 0, buf, buf + 0x30) & 0xFFFFFFFF == 0
        return struct.unpack('<Q', uc.mem_read(buf + 0x30, 8))[0]
    cp_p, cp_c = qi(w.comp, W.IID_ICONNECTIONPOINT), qi(ctrl, W.IID_ICONNECTIONPOINT)
    assert w.vcall(cp_p, 3, cp_c) & 0xFFFFFFFF == 0 and w.vcall(cp_c, 3, cp_p) & 0xFFFFFFFF == 0
    assert w.vcall(ctrl, 16, w.new_obj('handler')) & 0xFFFFFFFF == 0
    res = {'boot_s': time.time() - t0}
    res['init_queue'] = decode(w.queue())
    s0 = w.get_state()
    res['state0'] = s0
    assert w.vcall(ctrl, 5, w.stream(s0), count=4_000_000_000) & 0xFFFFFFFF == 0   # setComponentState
    ent0 = payload(s0)
    cases = [('same', ent0)]
    bumped = [[i, (v + 1) if k < 95 else v] for k, (i, v) in enumerate(ent0)]
    cases.append(('all+1', bumped))
    one = [list(e) for e in ent0]; one[12][1] = 100       # VCF CUTOFF FREQ only
    cases.append(('cutoff', one))
    rev = [list(e) for e in ent0[:95][::-1]] + [list(e) for e in ent0[95:]]
    cases.append(('reversed payload', rev))
    res['cases'] = []
    for name, ent in cases:
        n0, e0 = len(w.queue()), len(w.edits)
        r = w.set_state(build(ent))
        q = decode(w.queue())[n0:]
        res['cases'].append(dict(name=name, ret=r, payload=ent, queue=q, edits=list(w.edits[e0:])))
        print('%-18s setState 0x%x: %3d engine events, %3d handler calls' % (name, r, len(q), len(w.edits) - e0))
    pickle.dump(res, open(OUT, 'wb'))
    print('wrote', OUT, '(%.0fs)' % (time.time() - t0))


if __name__ == '__main__':
    main()
