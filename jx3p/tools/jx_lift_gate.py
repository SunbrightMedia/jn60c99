#!/usr/bin/env python3
"""jx_lift_gate.py -- the JX-3P's parameter system, LIFTED (jx_lift.py: the JP8 lifter on the JX binary), against the
plugin's own code on the SAME running engine (JX-11; the JP8's layer-2 recall gate, jp8/tools/jp8_lift_c.py).

PROCESS A (the oracle, Unicorn): tools/verify/jx_emu.py boot(44100, product=True, patch=BASE) -- the plugin's own
boot and patch load --, a key held, 2048 samples rendered: the running engine. Dumped: page 0, the image (with its
data as the boot left it), the stack, the heap in use. Then the judged calls: for every patch of --loads, its 75
patch-load records through the engine's host entry HOSTPARAM (0x3F9A30), each call recorded (entry, rcx, rdx, r8,
r9, MXCSR, the return value); then the heap and the stack again.
PROCESS B (the C twin, ctypes, no Unicorn): the lifted library (jp8/src/jp8_rt.c + build/jx_lift/jx_lift.c, built
-DJP8_RELOC -DJP8_RELOC_CHECK=1: guest addresses kept, every access translated, an access outside every region
traps), the oracle's regions mapped at their guest addresses and loaded from the dumps, the recorded calls replayed
VERBATIM through the lifted entry -- nothing re-derived (plumbing only). Compared: every return value, the whole
heap after the calls (byte for byte), the stack (reported).

    python3 jx3p/tools/jx_lift_gate.py [--base 0] [--loads 5,34,40,62 | --loads sweep] [--tooth RVA] [--relift]
                                       [--keep]
  --loads sweep: every id of the host entry's map at 13 values, a heap checkpoint after each id, the base
  patch's records after it (the host edits beyond a patch load).
  --tooth RVA: lift with that one addss turned into subss (jp8_lift.py --tooth) -- the gate must FAIL.
exit 0 = every return value and every heap byte equal.
"""
import ctypes
import glob
import json
import os
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
BUILD = os.path.join(REPO, 'build', 'jx_lift')
HOSTPARAM = 0x3F9A30
ROOTS = '3F9A30'
SWEEP = (0, 1, 2, 3, 5, 7, 9, 64, 127, 128, 255, 1000, -1)    # = jx_dynreach.py's
# the reach runs (jx_dynreach.py): warm loads and the id sweep from patch 0 (ARPEGGIO off) and from 34 (on) -- a
# reach from one base alone missed the switch-off path (the gate trapped: "indirect target 0x3e0210 not lifted")
REACH = (('dynreach_loads.json', ['--no-sweep']), ('dynreach_sweep.json', []),
         ('dynreach_loads_b34.json', ['--base', '34', '--no-sweep']), ('dynreach_sweep_b34.json', ['--base', '34']),
         ('dynreach_loads_b61.json', ['--base', '61', '--no-sweep']), ('dynreach_loads_b40.json', ['--base', '40', '--no-sweep']))
RET = 0x100000 + 0x5000                    # jx_emu.call's return sentinel (SCRATCH + 0x5000)
CPU_SZ, RSP_OFF, RAX_OFF, MX_OFF = 512, 4 * 8, 0, 16 * 8 + 16 * 16 + 5 * 4     # jp8_cpu.h CPU


def oracle(ref, base, loads):
    sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
    import jx_emu as J
    jx = J.JX().boot(44100.0, snap=False, product=True, patch=base)
    jx.note_on(60, 100)
    jx.render(2048, 256)
    uc = jx.uc
    os.makedirs(ref, exist_ok=True)
    w = lambda name, a, n: open(os.path.join(ref, name), 'wb').write(bytes(uc.mem_read(a, n)))
    heap_end = (jx.heap + 0xFFF) & ~0xFFF
    w('page0.bin', 0, 0x100000)
    w('img.bin', J.IB, J.IMGSZ)
    w('stack.bin', J.STACK_BASE, J.STACK_SIZE)
    w('heap_pre.bin', J.HEAP_BASE, heap_end - J.HEAP_BASE)
    mx = getattr(jx, '_mxcsr', 0x1F80)
    rsp = (J.STACK_BASE + J.STACK_SIZE - 0x10000) & ~0xF
    calls = []
    recs = J.JX.records()['patches']

    def host(pid, val):
        rax = jx.call(J.IB + HOSTPARAM, rcx=jx.HOST, rdx=pid, r8=val & 0xFFFFFFFF, count=400_000_000)
        calls.append(dict(fn=HOSTPARAM, rcx=jx.HOST, rdx=pid, r8=val & 0xFFFFFFFF, r9=0, mx=mx, rax=rax))
    if loads == ['sweep']:
        # every id of the host entry's map at every SWEEP value; a CHECKPOINT (the heap's sha256) after each id's
        # values, before the base patch's records restore the engine
        import hashlib
        for pid in sorted(jx.id_map()):
            for v in SWEEP:
                host(pid, v)
            calls.append(dict(check=hashlib.sha256(bytes(uc.mem_read(J.HEAP_BASE, heap_end - J.HEAP_BASE))).hexdigest(),
                              id=pid))
            for kind, rid, val in recs[base]:
                if kind == 2:
                    host(rid, val)
    else:
        for p in loads:
            for kind, pid, val in recs[p]:
                if kind == 2:
                    host(pid, val)
    if jx.heap > heap_end:
        raise SystemExit('the judged calls allocated (heap 0x%x past 0x%x): the gate assumes none' % (jx.heap, heap_end))
    w('heap_post.bin', J.HEAP_BASE, heap_end - J.HEAP_BASE)
    w('stack_post.bin', J.STACK_BASE, J.STACK_SIZE)
    json.dump(dict(base=base, loads=loads, img_base=J.IB, img_size=J.IMGSZ, stack_base=J.STACK_BASE,
                   stack_size=J.STACK_SIZE, heap_base=J.HEAP_BASE, heap_end=heap_end, buf_base=J.BUF_BASE,
                   buf_size=J.BUF_SIZE, rsp=rsp, host=jx.HOST, state=[jx.state[u] for u in range(9)],
                   proc=[jx.proc[u] for u in range(9)], calls=calls), open(os.path.join(ref, 'meta.json'), 'w'))
    print('oracle: base %d, %d judged calls, heap 0x%x bytes' % (base, sum(1 for c in calls if 'fn' in c),
                                                                  heap_end - J.HEAP_BASE), flush=True)


def ctwin(ref, so):
    lib = ctypes.CDLL(so)
    lib.jp8_map.argtypes = [ctypes.c_uint64, ctypes.c_uint64]
    lib.jp8_load.argtypes = [ctypes.c_uint64, ctypes.c_char_p]
    lib.jp8_call.argtypes = [ctypes.c_void_p] + [ctypes.c_uint64] * 5
    lib.jp8_last_trap.restype = ctypes.c_char_p
    lib.jp8_host.argtypes = [ctypes.c_uint64]
    lib.jp8_host.restype = ctypes.c_void_p
    m = json.load(open(os.path.join(ref, 'meta.json')))
    heap_len = m['heap_end'] - m['heap_base']
    for b, n in ((0, 0x100000), (m['img_base'], m['img_size']), (m['stack_base'], m['stack_size']),
                 (m['heap_base'], heap_len), (m['buf_base'], m['buf_size'])):
        if lib.jp8_map(b, n):
            raise SystemExit('cannot map 0x%x' % b)
    for name, b in (('page0.bin', 0), ('img.bin', m['img_base']), ('stack.bin', m['stack_base']),
                    ('heap_pre.bin', m['heap_base'])):
        lib.jp8_load(b, os.path.join(ref, name).encode())
    H = lib.jp8_host
    cpu = ctypes.create_string_buffer(CPU_SZ)
    cp = ctypes.addressof(cpu)
    bad, trap = 0, None
    import hashlib
    for k, c in enumerate(m['calls']):
        if 'check' in c:                          # the oracle's heap hash after one id's sweep
            if hashlib.sha256(ctypes.string_at(H(m['heap_base']), heap_len)).hexdigest() != c['check']:
                bad += 1
                print('  CHECKPOINT %d: the heap differs after the sweep of id 0x%x' % (k, c['id']))
                if bad >= 3:
                    break
            continue
        ctypes.memmove(cp + RSP_OFF, struct.pack('<Q', m['rsp']), 8)
        ctypes.memmove(cp + MX_OFF, struct.pack('<I', c['mx']), 4)
        ctypes.memmove(H(m['rsp'] - 8), struct.pack('<Q', RET), 8)
        if lib.jp8_call(cp, c['fn'], c['rcx'], c['rdx'], c['r8'], c['r9']):
            trap = '%s (call %d: id 0x%x value %d)' % (lib.jp8_last_trap().decode(), k, c['rdx'], c['r8'])
            break
        rax = struct.unpack('<Q', ctypes.string_at(cp + RAX_OFF, 8))[0]
        if rax != c['rax']:
            bad += 1
            if bad <= 5:
                print('  call %d (id 0x%x = %d): returned 0x%x, the plugin 0x%x' % (k, c['rdx'], c['r8'], rax, c['rax']))
    if trap:
        print('  TRAP: ' + trap)
        bad += 1
    post = open(os.path.join(ref, 'heap_post.bin'), 'rb').read()
    mine = ctypes.string_at(H(m['heap_base']), heap_len)
    nd = 0
    if post != mine:
        regions = [('state[%d]' % u, a, 0xAAC320) for u, a in enumerate(m['state'])] + \
                  [('proc[%d]' % u, a, 0x26000) for u, a in enumerate(m['proc'])]
        for off in range(0, heap_len, 4):
            if post[off:off + 4] != mine[off:off + 4]:
                nd += 1
                if nd <= 8:
                    a = m['heap_base'] + off
                    where = next(('%s+0x%x' % (n, a - lo) for n, lo, sz in regions if lo <= a < lo + sz), 'heap+0x%x' % off)
                    print('  heap differs at %s: plugin %s lifted %s' % (where, post[off:off + 4].hex(), mine[off:off + 4].hex()))
        bad += nd
    sp = open(os.path.join(ref, 'stack_post.bin'), 'rb').read()
    sm = ctypes.string_at(H(m['stack_base']), m['stack_size'])
    sd = 0 if sp == sm else sum(1 for o in range(0, m['stack_size'], 4) if sp[o:o + 4] != sm[o:o + 4])
    print('lifted: %d calls replayed (%d checkpoints), heap %s (%d dwords differ), stack %s' % (
        sum(1 for c in m['calls'] if 'fn' in c), sum(1 for c in m['calls'] if 'check' in c), 'EXACT' if not nd else 'DIFFERS', nd, 'EXACT' if not sd else '%d dwords differ (reported)' % sd))
    return bad


def main():
    a = sys.argv[1:]
    if a[:1] == ['--oracle']:
        oracle(a[1], int(a[2]), ['sweep'] if a[3] == 'sweep' else [int(x) for x in a[3].split(',')])
        return 0
    if a[:1] == ['--c']:
        return 1 if ctwin(a[1], a[2]) else 0
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    base, loads = int(opt('--base', '0')), opt('--loads', '5,34,40,62')
    tooth = opt('--tooth', None)
    os.makedirs(BUILD, exist_ok=True)
    src = os.path.join(BUILD, 'jx_lift%s.c' % ('_tooth' if tooth else ''))
    # the dynamic reach (indirect call / jump targets the oracle reached): deterministic, regenerated when absent
    for name, extra in REACH:
        if not os.path.exists(os.path.join(BUILD, name)):
            subprocess.run([sys.executable, os.path.join(HERE, 'jx_dynreach.py'), os.path.join(BUILD, name)] + extra,
                           check=True)
    dyn = sorted(glob.glob(os.path.join(BUILD, 'dynreach_*.json')))
    if tooth or '--relift' in a or not os.path.exists(src):
        cmd = [sys.executable, os.path.join(HERE, 'jx_lift.py'), src, ROOTS]
        for d in dyn:
            cmd += ['--dyn', d]
        if tooth:
            cmd += ['--tooth', tooth]
        subprocess.run(cmd, check=True)
    so = src[:-2] + '.so'
    subprocess.run(['cc', '-O1', '-std=gnu99', '-ffp-contract=off', '-fno-strict-aliasing', '-DJP8_RELOC',
                    '-DJP8_RELOC_CHECK=1', '-I', os.path.join(REPO, 'jp8', 'src'), '-shared', '-fPIC', '-o', so,
                    os.path.join(REPO, 'jp8', 'src', 'jp8_rt.c'), src, '-lm'], check=True)
    ref = os.path.join(BUILD, 'ref_b%d_%s' % (base, loads.replace(',', '_')))
    if not os.path.exists(os.path.join(ref, 'meta.json')):
        subprocess.run([sys.executable, __file__, '--oracle', ref, str(base), loads], check=True)
    r = subprocess.run([sys.executable, __file__, '--c', ref, so])
    if '--keep' not in a:                    # the dumps are ~200 MB per reference: process and delete
        import shutil
        shutil.rmtree(ref, ignore_errors=True)
    if tooth:
        print('jx_lift_gate --tooth 0x%s: %s' % (tooth, 'BITES' if r.returncode else 'DID NOT BITE'))
        return 0 if r.returncode else 1
    print('jx_lift_gate: base %d, warm loads %s through the lifted host entry: %s' % (
        base, loads, 'EXACTLY 0 -- every return value and heap byte' if not r.returncode else 'RED'))
    return r.returncode


if __name__ == '__main__':
    sys.exit(main())
