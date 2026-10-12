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
"resumed_at"). JP8_REACH_STEPS=a-b records only the drive's steps a..b (1-based, the setup is step 1): the steps
before run unhooked (the same state, fast), the ones after are not run -- a long drive's reach in pieces that run at
once, united later (jp8_reach_merge.py); recorded in "steps".
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
h.heap_reuse_on()                    # the host's heap reuses freed blocks from the template's point (jp8_host_ref.py)
q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
slot = lambda obj, k: q(q(obj) + 8 * k) - IB
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
roots = None
def roots_of():
    """every entry the host calls, read from the plugin's own vtables (after host_setup: the controller's interfaces)"""
    return dict(process=slot(h.audio, H.PROCESS_SLOT), setupProcessing=slot(h.audio, 7), setActive=slot(h.comp, 11),
                getState=slot(h.comp, 13), setState=slot(h.comp, 12), patch_load=X.W.PATCH_LOAD - IB, worker=X.WORKER,
                ui_drain=slot(h.core, 1), cc_index=h.CC_INDEX, cc_learn=h.CC_LEARN, cc_forget=h.CC_FORGET,
                ctl_qi=slot(h.ctrl, 0), ctl_compstate=slot(h.ctrl, 5), ctl_setstate=slot(h.ctrl, 6), ctl_getstate=slot(h.ctrl, 7),
                ctl_count=slot(h.ctrl, 8), ctl_info=slot(h.ctrl, 9), midi_assign=slot(h.mm, 3), unit_count=slot(h.ui, 3),
                unit_info=slot(h.ui, 4), unit_lists=slot(h.ui, 5), unit_selected=slot(h.ui, 11), unit_select=slot(h.ui, 12),
                ctl_createview=slot(h.ctrl, 17), zoom_get=H.ZOOM_GET - IB,    # v8 (E1): the editor's entries the C side
                **{'ctl%d' % k: slot(h.ctrl, k) for k in range(10, 16)})     # calls (the view's own after it exists)
done = []; resumed = []; STEPS = None
def dump(path):
    tmp = path + '.tmp'
    json.dump(dict(drive='host steps (jp8_host_seq)', rate=Q.RATE, rates=Q.RATES, patches=done, resumed_at=resumed, roots=roots,
                   steps=STEPS, sweep=Q.SWEEP,
                   executed=sorted('%x' % a for a in executed),
                   indirect={'%x' % s: sorted('%x' % t for t in ts) for s, ts in indirect.items()},
                   stubs=dict(stubs)), open(tmp, 'w'))
    os.replace(tmp, path)
old = None
if os.environ.get('JP8_REACH_RESUME') and os.path.exists(out + '.partial'):
    old = json.load(open(out + '.partial'))
    assert old['rate'] == Q.RATE, 'the partial reach is another drive'
    executed.update(int(a, 16) for a in old['executed']); stubs.update(old['stubs'])
    for s, ts in old['indirect'].items(): indirect[int(s, 16)].update(int(t, 16) for t in ts)
    done = list(old['patches']); resumed = list(old.get('resumed_at', [])) + [len(done)]
    log('resumed: %d patches from %s.partial' % (len(done), out))
todo = [p for p in patches if p not in done]
if not todo: raise SystemExit('nothing to do: every patch is in %s.partial (rename it to %s)' % (out, out))
bank = B.bank_bytes(); states = {}; cstates = {}
blob = lambda p: B.patch_blob(bank, p)
ST = Q.steps(todo)
RANGE = os.environ.get('JP8_REACH_STEPS')
lo, hi = (int(x) for x in RANGE.split('-')) if RANGE else (1, len(ST))
assert 1 <= lo <= hi <= len(ST), 'JP8_REACH_STEPS outside the drive (%d steps)' % len(ST)
hk = None
def hook_on():
    global hk
    uc.ctl_flush_tb(); hk = uc.hook_add(UC_HOOK_BLOCK, block)   # every block translated from here on is hooked
if lo == 1: hook_on()
h.host_setup(ST[0][1], Q.MAXBLOCK, Q.NPQ)          # jp8h_init's setup (the C side's), the controller's interfaces
roots = roots_of()
log('roots (the plugin\'s vtables): %s' % ', '.join('%s 0x%x' % kv for kv in roots.items()))
if old is not None and old['roots'] != roots:
    raise SystemExit('the partial reach has other roots: another drive')
n0 = len(executed); cur = None
for i, st in enumerate(ST[1:hi], start=2):
    if i == lo and hk is None:
        hook_on(); log('the hook on from step %d (%s)' % (i, st[0]))
    k = st[0]
    if k == 'patch':
        cur = st[1]
    h.run_step(st, blob, Q.state_variant, states, cstates)
    if k == 'editor':                                # v8 (E1): IPlugView::attached, a method of the view just made
        roots['view_attached'] = slot(h.view, 4)
    if k == 'getstate' and cur is not None and st[1] == 'p%d' % cur:     # a patch's steps end with its state
        log('patch %d %r: executed %d (+%d), %d indirect sites, %d stub names' % (
            cur, B.patch_name(bank, cur), len(executed), len(executed) - n0, len(indirect), len(stubs)))
        done.append(cur); dump(out + '.partial'); cur = None; n0 = len(executed)
log('the steps after the patches (controllers, rates, setActive, states): executed %d (+%d), %d indirect sites, %d stub names' % (
    len(executed), len(executed) - n0, len(indirect), len(stubs)))
uc.hook_del(hk); uc.ctl_flush_tb()
STEPS = [lo, hi]
dump(out)
if os.path.exists(out + '.partial'): os.remove(out + '.partial')
log('stubs reached: %s' % ', '.join('%s x%d' % kv for kv in stubs.most_common()))
log('wrote %s' % out)
