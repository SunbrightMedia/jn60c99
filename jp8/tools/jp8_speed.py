#!/usr/bin/env python3
"""jp8_speed.py REFDIR LIB MODE N -- the speed of the JUPITER-8's render (playbook 230): jp8_lift_c.py's setup and
events for its first patch, up to the first render event, then N samples of VOICE_WRAP x8 + MASTER_WRAP timed in C
(jp8_speed_bench.c): MODE lift (the lifted code in LIB) or native (the plugin's own machine code, the image mapped
RWX at its own address, called with the Win64 convention). Plumbing only; the checksum of the outputs is printed so
the modes can be seen to agree. One mode per process (both change the state).
    cc -std=gnu99 -O2 -ffp-contract=off -fno-strict-aliasing -fwrapv -w -fPIC -shared -Ijp8/src -o LIB \
       LIFTED.c jp8/src/jp8_rt.c jp8/tools/jp8_speed_bench.c -lm
    python3 jp8/tools/jp8_speed.py build/jp8_lift/ref_d2_render ./LIB lift|native 22050"""
import sys, os, json, struct, ctypes
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jp8_lift_seq as Q
refdir, so, mode, n = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
lib = ctypes.CDLL(so)
lib.jp8_map.argtypes = [ctypes.c_uint64, ctypes.c_uint64]; lib.jp8_map.restype = ctypes.c_int
lib.jp8_load.argtypes = [ctypes.c_uint64, ctypes.c_char_p]; lib.jp8_load.restype = ctypes.c_int
lib.jp8_call.argtypes = [ctypes.c_void_p] + [ctypes.c_uint64] * 5; lib.jp8_call.restype = ctypes.c_int
lib.jp8_call_f.argtypes = [ctypes.c_void_p, ctypes.c_uint64, ctypes.c_uint64, ctypes.c_float]; lib.jp8_call_f.restype = ctypes.c_int
lib.jp8_heap_set.argtypes = [ctypes.c_uint64, ctypes.c_uint64]
lib.jp8_last_trap.restype = ctypes.c_char_p
if hasattr(lib, 'jp8_hc_set'): lib.jp8_hc_set.argtypes = [ctypes.c_uint64]
lib.bench_lift.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_uint64, ctypes.c_uint32, ctypes.c_int, ctypes.c_void_p]
lib.bench_lift.restype = ctypes.c_double
lib.bench_native.argtypes = [ctypes.c_void_p, ctypes.c_uint32, ctypes.c_int, ctypes.c_void_p, ctypes.c_uint64, ctypes.c_uint64]
lib.bench_native.restype = ctypes.c_double
CPU_SZ = 512; RSP_OFF = 32; RAX_OFF = 0; MX_OFF = 16 * 8 + 16 * 16 + 5 * 4
def rd(a, k): return ctypes.string_at(a, k)
def wr(a, b): ctypes.memmove(a, b, len(b))
patch = Q.PATCHES[0]
d = os.path.join(refdir, 'p%02d' % patch); meta = json.load(open(os.path.join(d, 'meta.json')))
for base, size in ((Q.IMG_BASE, meta['img_size']), (Q.HEAP_BASE, Q.HEAP_MAP), (Q.STACK_BASE, Q.STACK_SIZE), (Q.BUF_BASE, Q.BUF_SIZE)):
    if lib.jp8_map(base, size): sys.exit('cannot map 0x%x' % base)
lib.jp8_load(Q.IMG_BASE, os.path.join(d, 'img.bin').encode()); lib.jp8_load(Q.HEAP_BASE, os.path.join(d, 'heap_pre.bin').encode())
lib.jp8_load(Q.STACK_BASE, os.path.join(d, 'stack.bin').encode())
wr(Q.GS_BASE, open(os.path.join(d, 'page0.bin'), 'rb').read())
lib.jp8_heap_set(meta['heap_ptr0'], Q.HEAP_BASE + Q.HEAP_MAP)
if hasattr(lib, 'jp8_hc_set'): lib.jp8_hc_set(meta['hc0'])
wr(Q.A2, b''.join(struct.pack('<QQ', Q.VOUT + 8 * v, Q.VOUT + 8 * v + 4) for v in range(8)))
cpu = ctypes.create_string_buffer(CPU_SZ); cp = ctypes.addressof(cpu)
state = meta['state']; mx = meta.get('mx0', 0x9FC0)
def enter(m):
    ctypes.memmove(cp + RSP_OFF, struct.pack('<Q', meta['rsp']), 8); ctypes.memmove(cp + MX_OFF, struct.pack('<I', m), 4)
    wr(meta['rsp'] - 8, struct.pack('<Q', Q.RET))
for k, ((ev, arg), rec) in enumerate(zip(Q.events(), meta['calls'])):
    if ev == 'render':
        break
    for c in rec:
        mx = c['mx']; enter(c['mx'])
        rc = lib.jp8_call_f(cp, c['fn'], c['rcx'], struct.unpack('<f', struct.pack('<I', c['xmm1']))[0]) if 'xmm1' in c else \
            lib.jp8_call(cp, c['fn'], c['rcx'], c['rdx'], c['r8'], c['r9'])
        if rc: sys.exit('trap %s' % lib.jp8_last_trap().decode())
    if ev == 'build':
        host = meta['host']
        state = [struct.unpack('<Q', rd(host + 0xA0 + 64 * i, 8))[0] for i in range(9)]
    mx = meta['mx_after'][k]
st = (ctypes.c_uint64 * 9)(*state); sm = ctypes.c_uint32()
if mode == 'lift':
    t = lib.bench_lift(cp, st, meta['rsp'], mx, n, ctypes.byref(sm))
else:
    t = lib.bench_native(st, mx, n, ctypes.byref(sm), Q.IMG_BASE, meta['img_size'])
print('%s: %d samples in %.3f s = %.1f ms per second of audio at 44.1 kHz (checksum %08x, mxcsr 0x%x)' % (
    mode, n, t, 1000 * t / (n / 44100.0), sm.value, mx))
