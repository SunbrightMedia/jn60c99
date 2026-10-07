"""Oracle-only probe (CLAIMS B13b): WHO writes what during the plugin's setSampleRate on a running
engine. As setsr_writes.py, but a memory-write hook inside the call records, for every 4-byte word
of the nine unit states written, the instruction address and the innermost return addresses (the
call chain), and the value. Prints, per writer function (the chain's innermost frame), how many
words it wrote and in which offset bands. Writes scratchpad/setsr_writers.pkl.

    python3 probes/b13b/setsr_writers.py [patch] [setting] [host_rate]      (Unicorn only)"""
import os
import pickle
import struct
import sys
from collections import defaultdict

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H          # noqa: E402
import e2e_emu as E                   # noqa: E402
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE   # noqa: E402
from unicorn.x86_const import UC_X86_REG_RSP, UC_X86_REG_RIP   # noqa: E402
from host_process_gate import HEADER, STRIDE, NAME   # noqa: E402

# past 102800 only these bands are logged (the effect blocks' cells, the reverb's taps): the
# 2 MB buffers the chorus constructor clears would need gigabytes
KEEP = [(102800 - 600, 102800), (2199900, 2199968), (4297000, 4298096), (6396000, 6396640),
        (8594600, 8594784), (10759000, 10760000), (11022000, 11022352)]


def main():
    patch = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    setting = int(sys.argv[2]) if len(sys.argv) > 2 else 2
    rate = float(sys.argv[3]) if len(sys.argv) > 3 else 48000.0
    bank = E.bank_bytes()
    h = H.HostProcess()
    h.start(rate, 4096)
    on = {'v': False}
    calls = []                       # the call stack inside setSampleRate: (callee, return address)
    writes = {}                      # (unit, off) -> (rip rva, callee chain, value)
    units = [(h.state[u], u) for u in range(9)]

    def on_entry(uc, addr, size, ud):
        on['v'] = True

    def on_ret(uc, addr, size, ud):
        on['v'] = False
    h.uc.hook_add(UC_HOOK_CODE, on_entry, begin=E.IB + 0x3C7A20, end=E.IB + 0x3C7A20)
    h.uc.hook_add(UC_HOOK_CODE, on_ret, begin=E.IB + 0x3C7AD3, end=E.IB + 0x3C7AD3)

    def on_write(uc, access, addr, size, value, ud):
        if not on['v']:
            return
        for base, u in units:
            if base <= addr < base + E.STATE_SZ:
                rip = uc.reg_read(UC_X86_REG_RIP) - E.IB
                # the innermost function: walk the stack for return addresses into the image
                rsp = uc.reg_read(UC_X86_REG_RSP)
                chain = []
                raw = bytes(uc.mem_read(rsp, 8 * 64))
                for k in range(64):
                    q = struct.unpack_from('<Q', raw, 8 * k)[0]
                    if E.IB <= q < E.IB + 0x1000000:
                        chain.append(q - E.IB)
                        if len(chain) >= 4:
                            break
                off = addr - base
                for o in range(off & ~3, off + size, 4):
                    if o >= 102800 and not any(a <= o < b for a, b in KEEP):
                        continue                 # the big buffers: counted, not logged
                    writes[(u, o)] = (rip, tuple(chain), value)
                return
    h.uc.hook_add(UC_HOOK_MEM_WRITE, on_write)
    rec = bank[HEADER + patch * STRIDE: HEADER + (patch + 1) * STRIDE]
    h.load_patch(rec[NAME:])
    ev = lambda off, p, v: ('on', off, 0, p, v)
    h.process(256, events=[ev(0, 60, 0.8), ev(0, 64, 0.7)])
    for _ in range(int(os.environ.get('NBLK', '40'))):
        h.process(256)
    pl = struct.pack('>Ii', H.SAMPLERATE_ID, setting)
    if h.set_state(struct.pack('>I', len(pl)) + pl) != 0:
        raise SystemExit('setState failed')
    h.process(256)
    by = defaultdict(list)
    for (u, o), (rip, chain, val) in writes.items():
        by[rip].append((u, o))
    print('%d words written in %d units by %d store sites' % (len(writes), len({u for u, o in writes}), len(by)))
    for rip, lst in sorted(by.items(), key=lambda kv: -len(kv[1]))[:60]:
        ch = writes[lst[0]][1]
        offs = sorted(o for u, o in lst if u == 0) or sorted(o for u, o in lst)
        print('store %06x  chain %s  %6d words  unit0 offs %s%s' % (
            rip, ' '.join('%06x' % c for c in ch), len(lst), offs[:6], ' ...' if len(offs) > 6 else ''))
    p = os.path.join(REPO, 'scratchpad', 'setsr_writers.pkl')
    pickle.dump({'patch': patch, 'setting': setting, 'host': rate, 'writes': writes}, open(p + '.partial', 'wb'))
    os.replace(p + '.partial', p)
    print('wrote', p)


if __name__ == '__main__':
    main()
