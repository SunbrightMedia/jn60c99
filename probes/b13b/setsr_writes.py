"""Oracle-only probe (CLAIMS B13b): what the plugin's setSampleRate (CWaveGen vt+24, rva 0x3C7A20)
does to a RUNNING engine. Boots the plugin as a host does (the default engine-rate setting: engine
96000), loads a factory patch, holds keys for a while, then sets vm.vs.sampleRate to another
setting through setState: the driver's next block calls setSampleRate. Hooks its entry and its
return and saves the compared regions (voice v from unit v, the master from unit 8) before and
after the call -- nothing renders in between. Writes scratchpad/setsr_writes.pkl.

    python3 probes/b13b/setsr_writes.py [patch] [setting] [host_rate]      (Unicorn only)"""
import os
import pickle
import struct
import sys
import zlib

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H          # noqa: E402
import e2e_emu as E                   # noqa: E402
import warm_render_gate as WR         # noqa: E402
from unicorn import UC_HOOK_CODE      # noqa: E402
from host_process_gate import HEADER, STRIDE, NAME   # noqa: E402  (never typed by hand)


def recs(h):
    """every unit's ramp records (40 bytes each: out ptr, incr, accum, start, target, rate, active,
    subdiv, step) and its active list, and the first 0x2100 bytes of its processor object"""
    out = []
    q = lambda a: struct.unpack('<Q', h.uc.mem_read(a, 8))[0]
    for u in range(9):
        st = h.state[u]
        a, b = q(st + 88), q(st + 96)
        la, lb = q(st + 112), q(st + 120)
        out.append((bytes(h.uc.mem_read(a, b - a)), bytes(h.uc.mem_read(la, lb - la)) if lb > la else b'',
                    bytes(h.uc.mem_read(h.proc[u], 0x2100))))
    return out


def snap(h):
    parts = []
    for v in range(8):
        for a, b in WR.voice_regions(v):
            parts.append(bytes(h.uc.mem_read(h.state[v] + a, b - a)))
    for a, b in WR.master_ranges():
        parts.append(bytes(h.uc.mem_read(h.state[8] + a, b - a)))
    return zlib.compress(b''.join(parts), 1)


def main():
    patch = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    setting = int(sys.argv[2]) if len(sys.argv) > 2 else 2
    rate = float(sys.argv[3]) if len(sys.argv) > 3 else 48000.0
    bank = E.bank_bytes()
    h = H.HostProcess()
    h.start(rate, 4096)
    cap = {'calls': []}

    def on_entry(uc, addr, size, ud):
        from unicorn.x86_const import UC_X86_REG_XMM1
        r = struct.unpack('<f', struct.pack('<I', uc.reg_read(UC_X86_REG_XMM1) & 0xFFFFFFFF))[0]
        cap['calls'].append({'rate': r, 'before': snap(h), 'rec_before': recs(h)})

    def on_ret(uc, addr, size, ud):
        cap['calls'][-1]['after'] = snap(h)
        cap['calls'][-1]['rec_after'] = recs(h)
    h.uc.hook_add(UC_HOOK_CODE, on_entry, begin=E.IB + 0x3C7A20, end=E.IB + 0x3C7A20)
    h.uc.hook_add(UC_HOOK_CODE, on_ret, begin=E.IB + 0x3C7AD3, end=E.IB + 0x3C7AD3)
    rec = bank[HEADER + patch * STRIDE: HEADER + (patch + 1) * STRIDE]
    h.load_patch(rec[NAME:])
    on = lambda off, p, v: ('on', off, 0, p, v)
    h.process(256, events=[on(0, 60, 0.8), on(0, 64, 0.7)])
    for _ in range(int(os.environ.get('NBLK', '40'))):
        h.process(256)
    if os.environ.get('EDIT_BEFORE'):          # ramps in flight at the switch: a VCF CUTOFF edit
        pe = struct.pack('>Ii', 0x0060003A, 40)    # one 64-sample block before it
        if h.set_state(struct.pack('>I', len(pe)) + pe) != 0:
            raise SystemExit('setState failed')
        h.process(64)
    n0 = len(cap['calls'])
    pl = struct.pack('>Ii', H.SAMPLERATE_ID, setting)
    if h.set_state(struct.pack('>I', len(pl)) + pl) != 0:
        raise SystemExit('setState failed')
    l, r = h.process(256)
    print('setSampleRate calls before the edit: %d, in the switch block: %d (rates %s)' % (
        n0, len(cap['calls']) - n0, [c['rate'] for c in cap['calls'][n0:]]))
    out = {'patch': patch, 'setting': setting, 'host': rate, 'calls': cap['calls'][n0:]}
    p = os.path.join(REPO, 'scratchpad', 'setsr_writes.pkl')
    pickle.dump(out, open(p + '.partial', 'wb'))
    os.replace(p + '.partial', p)
    print('wrote', p)


if __name__ == '__main__':
    main()
