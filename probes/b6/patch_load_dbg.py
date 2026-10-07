"""Debug probe for probes/b6/patch_load_census.py: boots, then runs rva 0x335850 in
slices of N instructions, printing where it is and which imports it called.
    python3 -u probes/b6/patch_load_dbg.py      (Unicorn only)"""
import os, sys, struct, time, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wrapper_emu as W
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'tools', 'verify'))
import truth
from unicorn.x86_const import UC_X86_REG_RIP, UC_X86_REG_RSP
t0 = time.time()
w = W.Wrapper(); uc = w.uc
w.boot()
print('booted %.0fs' % (time.time() - t0), flush=True)
q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
ser = w.comp + 280
vt = q(ser); print('serializer vt rva', hex(vt - W.IB), 'slot6', hex(q(vt + 48) - W.IB), flush=True)
X = q(ser + 8); M = q(X); print('X', hex(X), 'model', hex(M), 'model vt rva', hex(q(M) - W.IB), flush=True)
bank = open(truth.BANK, 'rb').read()
rec = bank[23: 23 + 20223]
data = w.alloc_com(len(rec) + 16); uc.mem_write(data, rec)
vec = w.alloc_com(24); uc.mem_write(vec, struct.pack('<QQQ', data, data + len(rec), data + len(rec)))
n0 = len(w.queue())
c0 = collections.Counter(w.calls)
rsp = (W.E.STACK_BASE + W.E.STACK_SIZE - 0x10000) & ~0xF; rsp -= 8
RET = W.E.SCRATCH + 0x5000
uc.reg_write(UC_X86_REG_RSP, rsp)
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9
uc.reg_write(UC_X86_REG_RCX, vec); uc.reg_write(UC_X86_REG_RDX, X); uc.reg_write(UC_X86_REG_R8, 0); uc.reg_write(UC_X86_REG_R9, 0)
uc.mem_write(rsp, struct.pack('<Q', RET))
pc = W.IB + 0x335850
from unicorn import UC_HOOK_BLOCK
ring = collections.deque(maxlen=60)
IMG_END = W.IB + W.E.IMGSZ
def bh(uc_, addr, size, ud):
    ring.append(addr)
    if not (W.IB <= addr < IMG_END) and not (W.DYN <= addr < W.DYN_END) and not (W.E.STUB_BASE <= addr < W.E.STUB_BASE + 0x100000) and addr != RET:
        print('LEFT THE IMAGE at 0x%x; last blocks: %s' % (addr, ' '.join(('%x' % (a - W.IB)) if W.IB <= a < IMG_END else ('!%x' % a) for a in list(ring)[-40:])), flush=True)
        uc_.emu_stop()
uc.hook_add(UC_HOOK_BLOCK, bh)
uc.ctl_remove_cache(W.IB, IMG_END) if hasattr(uc, 'ctl_remove_cache') else None
for sl in range(40):
    uc.emu_start(pc, RET, count=20_000_000)
    pc = uc.reg_read(UC_X86_REG_RIP)
    d = collections.Counter(w.calls); d.subtract(c0)
    print('slice %d: rip rva 0x%x  queue +%d  imports %s  (%.0fs)' % (sl, pc - W.IB, len(w.queue()) - n0,
          [(k, v) for k, v in d.most_common(6) if v], time.time() - t0), flush=True)
    if pc == RET:
        print('RETURNED'); break
    if not (W.IB <= pc < IMG_END):
        for kind, off, rec in w.queue()[n0:]:
            print('  queued kind %d off %d id 0x%x value %d' % (kind, off, struct.unpack_from('<I', rec, 12)[0], struct.unpack_from('<i', rec, 20)[0]))
        break
