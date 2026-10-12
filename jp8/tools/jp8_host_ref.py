#!/usr/bin/env python3
"""jp8_host_ref.py -- ORACLE side (process A) of the JUPITER-8 host gate (jp8_host_seq.py). Boots the plugin as a DAW
does up to the point a host learns its sample rate (jp8_host_emu.JP8Host.boot_host: DllMain, the factory, the
component and the controller initialized and connected, the handler, setComponentState), then writes:
  * the JP8H TEMPLATE: the oracle's memory at that point, region by region (page 0, the image, the stack, the heap up
    to the bump pointer, the stubs, BUF, the TEB, the host objects), the facts the C side needs (the component, the
    audio processor, the core, the patch load, the vtables of the host objects it creates, the bump pointer, the
    fake-handle counter, MXCSR, the registers) and the name of every stub address (imports and host-object methods).
    It holds no sample rate: the C side's jp8h_init makes the host's setup calls itself, with the rate it is given;
  * the REFERENCES of the drive (jp8_host_seq.steps): per step the host call's result, every output word of every
    block, every state byte, then the performEdit calls the plugin made, the worker jobs, and the memory hashes.
Plumbing only. FORMAT JP8H v2 (little endian): "JP8H" u32 2 u32 nregions; per region u64 base u64 size u32 nruns,
per run u32 off u32 len bytes; u32 nfacts, per fact char key[24] u64 value; u32 nstubs, per stub u64 addr u32 len
name; u32 crc32 of every byte before it.
usage: jp8_host_ref.py <outdir>"""
import sys, os, json, struct, time, hashlib, zlib
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import jp8_host_emu as X, jp8_bank as B, jp8_host_seq as Q
J = X.J; H = X.H
from unicorn.x86_const import UC_X86_REG_MXCSR
from unicorn import x86_const as XC
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)
out = sys.argv[1]; os.makedirs(out, exist_ok=True)
h = X.JP8Host(); IB = X.IB; uc = h.uc
h.boot_host(log=log)
q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
heap_top = h.heap
HEAP_MAP = ((heap_top - Q.HEAP_BASE + 0x10000000 + 0xFFFFF) & ~0xFFFFF)      # the heap so far + 256 MB of room
REGIONS = [(0x0, 0x100000), (IB, J.IMGSZ), (Q.STACK_BASE, Q.STACK_SIZE), (Q.HEAP_BASE, HEAP_MAP),
           (J.STUB_BASE, 0x100000), (J.BUF_BASE, J.BUF_SIZE), (X.W.TEB, 0x10000), (Q.COM_BASE, Q.COM_SIZE)]
mapped = [(b, e + 1) for b, e, _ in uc.mem_regions()]
stray = [(b, e) for b, e in mapped if not any(rb <= b < rb + rs for rb, rs in REGIONS) and not (Q.HEAP_BASE <= b < Q.HEAP_BASE + J.HEAP_SIZE)]
log('heap 0x%x (%.1f MB used), %d oracle regions outside the template: %s' % (heap_top, (heap_top - Q.HEAP_BASE) / 1e6, len(stray),
    ', '.join('0x%x-0x%x' % be for be in stray[:6]) or 'none'))
def region_bytes(base, size):
    if base == Q.HEAP_BASE: return bytes(uc.mem_read(base, heap_top - base))
    return bytes(uc.mem_read(base, size))
PAGE = 0x1000
def runs_of(blob):
    out_, i, n = [], 0, len(blob)
    while i < n:
        if not any(blob[i:i + PAGE]): i += PAGE; continue
        j = i
        while j < n and any(blob[j:j + PAGE]): j += PAGE
        out_.append((i, blob[i:j])); i = j
    return out_
facts = dict(ctrl=h.ctrl, heap_ptr=heap_top, heap_limit=Q.HEAP_BASE + HEAP_MAP, hc=getattr(h, '_hc', 0x9000), mxcsr=uc.reg_read(UC_X86_REG_MXCSR),
             rsp=(Q.STACK_BASE + Q.STACK_SIZE - 0x10000) & ~0xF, ret=J.SCRATCH + 0x5000, audio=h.audio, comp=h.comp, core=h.core,
             process_fn=q(q(h.audio) + 8 * H.PROCESS_SLOT), patch_fn=X.W.PATCH_LOAD, com_next=h.com_next,
             vt_events=h.vt['events'], vt_pchanges=h.vt['pchanges'], vt_pqueue=h.vt['pqueue'], vt_stream=h.vt['stream'])
# THE REGISTERS the oracle's next call starts from (they persist between calls: only rsp, rcx, rdx, r8, r9 and the
# RET slot are written per call) -- the C side starts from the same
GPR = ['RAX', 'RCX', 'RDX', 'RBX', 'RSP', 'RBP', 'RSI', 'RDI'] + ['R%d' % k for k in range(8, 16)]
for k, nm in enumerate(GPR): facts['r%d' % k] = uc.reg_read(getattr(XC, 'UC_X86_REG_' + nm))
for k in range(16):
    v = uc.reg_read(getattr(XC, 'UC_X86_REG_XMM%d' % k)); facts['x%dlo' % k] = v & (2**64 - 1); facts['x%dhi' % k] = v >> 64
facts['eflags'] = uc.reg_read(XC.UC_X86_REG_EFLAGS)
stubs = sorted((a, nm[1]) for a, nm in h.stub2name.items())
body = bytearray(b'JP8H' + struct.pack('<II', 2, len(REGIONS)))
for base, size in REGIONS:
    rr = runs_of(region_bytes(base, size))
    body += struct.pack('<QQI', base, size, len(rr))
    for off, b in rr: body += struct.pack('<II', off, len(b)) + b
body += struct.pack('<I', len(facts))
for k, v in facts.items(): body += k.encode().ljust(24, b'\0')[:24] + struct.pack('<Q', v & 0xFFFFFFFFFFFFFFFF)
body += struct.pack('<I', len(stubs))
for a, nm in stubs: body += struct.pack('<QI', a, len(nm)) + nm.encode()
body += struct.pack('<I', zlib.crc32(bytes(body)) & 0xFFFFFFFF)
open(os.path.join(out, 'jp8_host_template.bin'), 'wb').write(body)
log('template (before setupProcessing): %d regions, %d facts, %d stubs, %.1f MB (sha256 %s)' % (len(REGIONS), len(facts), len(stubs),
    len(body) / 1e6, hashlib.sha256(body).hexdigest()[:16]))
def memhash():
    m = hashlib.sha256()
    m.update(bytes(uc.mem_read(IB, J.IMGSZ))); m.update(bytes(uc.mem_read(Q.HEAP_BASE, h.heap - Q.HEAP_BASE)))
    m.update(bytes(uc.mem_read(Q.COM_BASE, h.com_next - Q.COM_BASE)))
    return m.hexdigest()
ST = Q.steps()
assert ST[0][0] == 'setup'
e0 = len(h.edits); j0 = len(h.jobs)
h.setup(ST[0][1], Q.MAXBLOCK)                      # setupProcessing + setActive(1) + the blocks' host objects
while len(h._pq) < Q.NPQ:                          # every queue a block may use exists before the drive
    h._pq.append(h.new_obj('pqueue', id=0, points=[]))
h.cc_index_table()                                 # the CC records' ids, read once (the C side: in jp8h_init)
init_hash = memhash()
log('setup %g: the host objects end at 0x%x, %d edits, %d jobs' % (ST[0][1], h.com_next, len(h.edits) - e0, len(h.jobs) - j0))
bank = B.bank_bytes(); words = bytearray(); results = []; states = {}; state_bytes = bytearray(); nblock = 0
for st in ST[1:]:
    k = st[0]
    if k == 'patch':
        h.load_patch(B.patch_blob(bank, st[1])); results.append([k, st[1], 0])
    elif k == 'block':
        _, n, evs, pars, ctx = st
        L, R = h.process(n, events=evs, params=pars, ctx=ctx)
        words += struct.pack('<%dI' % n, *L) + struct.pack('<%dI' % n, *R); nblock += 1
        results.append([k, n, 0])
    elif k == 'getstate':
        s = h.get_state(); states[st[1]] = s; state_bytes += s; results.append([k, st[1], len(s)])
    elif k == 'setstate':
        r = h.set_state(Q.state_variant(states[st[1]], st[2])); results.append([k, '%s/%s' % (st[1], st[2]), r])
    elif k == 'rate':
        h.set_active(0); h.setup_processing(st[1]); h.set_active(1); results.append([k, st[1], 0])
    elif k == 'active':
        h.set_active(st[1]); results.append([k, st[1], 0])
    elif k == 'ctl':
        _, op, pid, arg = st
        if op == 'str':
            buf = h.alloc_com(256); r, x = h.ctl(10, pid, arg, 0, buf); x = 0; extra = bytes(h.uc.mem_read(buf, 256)).hex()
        elif op == 'parse':
            t = arg.encode('utf-16-le') + b'\0\0'; sp = h.alloc_com(len(t)); h.uc.mem_write(sp, t); vp = h.alloc_com(8)
            r, x = h.ctl(11, pid, 0.0, sp, vp); x = 0; extra = bytes(h.uc.mem_read(vp, 8)).hex()   # (xmm0: not a result)
        else:
            r, x = h.ctl({'get': 14, 'set': 15, 'plain': 12, 'norm': 13}[op], pid, arg); extra = ''
        results.append([k, '%s/%x/%r' % (op, pid, arg), r, x, extra])
    elif k == 'drain':
        h.ui_drain(); results.append([k, 0, 0])
    elif k == 'learn':
        h.cc_learn(st[1]); results.append([k, st[1], 0])
    elif k == 'forget':
        h.cc_forget(st[1]); results.append([k, st[1], 0])
    else:
        raise SystemExit('unknown step %r' % (st,))
    if k in ('patch', 'rate', 'setstate'):
        log('%s %s: %d blocks, %d words so far, %d edits, %d jobs' % (k, st[1], nblock, len(words) // 4, len(h.edits) - e0, len(h.jobs) - j0))
edits = [[e[1], struct.unpack('<Q', struct.pack('<d', e[2]))[0]] for e in h.edits[e0:] if e[0] == 'performEdit']
open(os.path.join(out, 'words.bin'), 'wb').write(bytes(words))
open(os.path.join(out, 'states.bin'), 'wb').write(bytes(state_bytes))
json.dump(dict(rate=Q.RATE, patches=Q.PATCHES, rates=Q.RATES, nsteps=len(ST), results=results, init_hash=init_hash,
               end_hash=memhash(), heap_end=h.heap, com_next_end=h.com_next, jobs=len(h.jobs) - j0, edits=edits,
               stack_hash=hashlib.sha256(bytes(uc.mem_read(Q.STACK_BASE, Q.STACK_SIZE))).hexdigest(),
               template_sha256=hashlib.sha256(body).hexdigest()), open(os.path.join(out, 'meta.json'), 'w'))
log('wrote %s: %d steps, %d blocks, %d words, %d state bytes, %d performEdits, %d worker jobs' % (
    out, len(ST), nblock, len(words) // 4, len(state_bytes), len(edits), len(h.jobs) - j0))
