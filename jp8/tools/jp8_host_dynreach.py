#!/usr/bin/env python3
"""jp8_host_dynreach.py -- DYNAMIC reach of the JUPITER-8's host path on the host oracle (jp8_host_emu.py): the plugin
booted as a DAW boots it up to the point it learns its sample rate (boot_host, where the gate's template is taken),
then a BLOCK hook records every executed instruction, every indirect call / jmp target, and every import or
host-object stub reached (by name), while the gate's own drive runs (jp8_host_seq.steps over the reach's patches):
the setup calls, per patch the plugin's own patch load (the patch browser, 0x355F90) and its process() blocks (a note,
a chord over the eight voices and their release, parameter changes, a host clock), getState, the host-rate changes,
setActive, setState. The lifter (jp8_lift.py --dyn) takes the indirect map; "roots" names every entry the host calls
(read from the plugin's own vtables, so the gate lifts what was called); the stub names list what the C runtime must
answer. Plumbing only (jp8_dynreach.py's method: a block hook, the translation cache flushed first, PORT_LESSONS 8).
After every patch the reach so far is written to <out.json>.partial (playbook 142); JP8_REACH_RESUME=1 takes it and
runs only the patches it does not hold (a fresh boot and its own setup first: the union of two drives, recorded in
"resumed_at").
usage: jp8_host_dynreach.py <out.json> [patches e.g. 0-63] [rate=48000]"""
import sys, os, json, collections, time, struct
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
out = sys.argv[1]
spec = sys.argv[2] if len(sys.argv) > 2 else '0-63'
if len(sys.argv) > 3: os.environ['JP8_HOST_RATE'] = sys.argv[3]
import capstone
from capstone import x86
from unicorn import UC_HOOK_BLOCK
import jp8_host_emu as X, jp8_bank as B, jp8_host_seq as Q
J = X.J; H = X.H
patches = []
for part in spec.split(','):
    a, _, b = part.partition('-'); patches += list(range(int(a), int(b or a) + 1))
t0 = time.time()
def log(m): print('[%6.1fs] %s' % (time.time() - t0, m), flush=True)
h = X.JP8Host(); IB = X.IB; uc = h.uc
h.boot_host(log=log)
q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
slot = lambda obj, k: q(q(obj) + 8 * k) - IB
roots = dict(process=slot(h.audio, H.PROCESS_SLOT), setupProcessing=slot(h.audio, 7), setActive=slot(h.comp, 11),
             getState=slot(h.comp, 13), setState=slot(h.comp, 12), patch_load=X.W.PATCH_LOAD - IB, worker=X.WORKER,
             ui_drain=slot(h.core, 1), cc_index=h.CC_INDEX, cc_learn=h.CC_LEARN, cc_forget=h.CC_FORGET,
             **{'ctl%d' % k: slot(h.ctrl, k) for k in range(10, 16)})
log('roots (the plugin\'s vtables): %s' % ', '.join('%s 0x%x' % kv for kv in roots.items()))
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64); md.detail = True
executed = set(); indirect = collections.defaultdict(set); stubs = collections.Counter()
STUB_LO, STUB_HI = J.STUB_BASE, J.STUB_BASE + 0x10000
bcache = {}; prev = [None]
def block(uc_, address, size, user):
    rva = address - IB
    if prev[0] is not None:
        indirect[prev[0]].add(rva); prev[0] = None
    if STUB_LO <= address < STUB_HI:
        nm = h.stub2name.get(address)
        stubs[nm[1] if nm else '0x%x' % address] += 1      # import stubs and the oracle's named host-object stubs
        return
    if not (0 <= rva < J.IMGSZ): return
    k = (address, size); e = bcache.get(k)
    if e is None:
        rvas = []; last = None
        for ins in md.disasm(bytes(J.IMG[rva:rva + size]), address):
            rvas.append(ins.address - IB); last = ins
        ind = (last is not None and last.mnemonic in ('call', 'jmp') and last.operands[0].type != x86.X86_OP_IMM)
        e = (tuple(rvas), rvas[-1] if ind else None); bcache[k] = e
    executed.update(e[0])
    if e[1] is not None: prev[0] = e[1]
done = []; resumed = []
def dump(path):
    tmp = path + '.tmp'
    json.dump(dict(drive='host steps (jp8_host_seq)', rate=Q.RATE, rates=Q.RATES, patches=done, resumed_at=resumed, roots=roots,
                   executed=sorted('%x' % a for a in executed),
                   indirect={'%x' % s: sorted('%x' % t for t in ts) for s, ts in indirect.items()},
                   stubs=dict(stubs)), open(tmp, 'w'))
    os.replace(tmp, path)
if os.environ.get('JP8_REACH_RESUME') and os.path.exists(out + '.partial'):
    old = json.load(open(out + '.partial'))
    assert old['rate'] == Q.RATE and old['roots'] == roots, 'the partial reach is another drive'
    executed.update(int(a, 16) for a in old['executed']); stubs.update(old['stubs'])
    for s, ts in old['indirect'].items(): indirect[int(s, 16)].update(int(t, 16) for t in ts)
    done = list(old['patches']); resumed = list(old.get('resumed_at', [])) + [len(done)]
    log('resumed: %d patches from %s.partial' % (len(done), out))
todo = [p for p in patches if p not in done]
if not todo: raise SystemExit('nothing to do: every patch is in %s.partial (rename it to %s)' % (out, out))
uc.ctl_flush_tb(); hk = uc.hook_add(UC_HOOK_BLOCK, block)
bank = B.bank_bytes(); states = {}
ST = Q.steps(todo)
h.setup(ST[0][1], Q.MAXBLOCK)
while len(h._pq) < Q.NPQ:
    h._pq.append(h.new_obj('pqueue', id=0, points=[]))
h.cc_index_table()
n0 = len(executed); cur = None
for st in ST[1:]:
    k = st[0]
    if k == 'patch':
        cur = st[1]; h.load_patch(B.patch_blob(bank, st[1]))
    elif k == 'block':
        _, n, evs, pars, ctx = st; h.process(n, events=evs, params=pars, ctx=ctx)
    elif k == 'getstate':
        states[st[1]] = h.get_state()
    elif k == 'setstate':
        h.set_state(Q.state_variant(states[st[1]], st[2]))
    elif k == 'rate':
        h.set_active(0); h.setup_processing(st[1]); h.set_active(1)
    elif k == 'active':
        h.set_active(st[1])
    elif k == 'ctl':
        _, op, pid, arg = st
        if op == 'str':
            buf = h.alloc_com(256); r, x = h.ctl(10, pid, arg, 0, buf); x = 0; extra = bytes(h.uc.mem_read(buf, 256)).hex()
        elif op == 'parse':
            t = arg.encode('utf-16-le') + b'\0\0'; sp = h.alloc_com(len(t)); h.uc.mem_write(sp, t); vp = h.alloc_com(8)
            r, x = h.ctl(11, pid, 0.0, sp, vp); x = 0; extra = bytes(h.uc.mem_read(vp, 8)).hex()   # (xmm0: not a result)
        else:
            r, x = h.ctl({'get': 14, 'set': 15, 'plain': 12, 'norm': 13}[op], pid, arg); extra = ''
    elif k == 'drain':
        h.ui_drain()
    elif k == 'learn':
        h.cc_learn(st[1])
    elif k == 'forget':
        h.cc_forget(st[1])
    else:
        raise SystemExit('unknown step %r' % (st,))
    if k == 'getstate' and cur is not None and st[1] == 'p%d' % cur:     # a patch's steps end with its state
        log('patch %d %r: executed %d (+%d), %d indirect sites, %d stub names' % (
            cur, B.patch_name(bank, cur), len(executed), len(executed) - n0, len(indirect), len(stubs)))
        done.append(cur); dump(out + '.partial'); cur = None; n0 = len(executed)
log('the steps after the patches (controllers, rates, setActive, states): executed %d (+%d), %d indirect sites, %d stub names' % (
    len(executed), len(executed) - n0, len(indirect), len(stubs)))
uc.hook_del(hk); uc.ctl_flush_tb()
dump(out)
if os.path.exists(out + '.partial'): os.remove(out + '.partial')
log('stubs reached: %s' % ', '.join('%s x%d' % kv for kv in stubs.most_common()))
log('wrote %s' % out)
