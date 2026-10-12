#!/usr/bin/env python3
"""jp8_host_speed.py -- the speed of the JUPITER-8's host path in C: ctypes-loads a host library (a build of
jp8_host_gate.sh: libjp8host_prd.so, _thr.so, ...), jp8h_init from a JP8H template (the gate's ref dir) at a host rate,
the plugin's own patch load, four keys held, then N seconds of 512-sample blocks through the plugin's own process().
Prints the cost of one second of audio in ms on this machine (below 1000: faster than real time), the heap's reuse
layer at the end and a checksum of the output (equal across builds of one lift: the same words). No unicorn
(two-process rule); plumbing only.
usage: jp8_host_speed.py <template.bin> <lib.so> [seconds=10] [patch=2] [rate=48000]"""
import sys, os, time, ctypes, zlib
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import jp8_bank as B
tmpl, so = sys.argv[1], sys.argv[2]
secs = float(sys.argv[3]) if len(sys.argv) > 3 else 10.0
patch = int(sys.argv[4]) if len(sys.argv) > 4 else 2
rate = float(sys.argv[5]) if len(sys.argv) > 5 else 48000.0
N = 512
lib = ctypes.CDLL(os.path.abspath(so))
class EV(ctypes.Structure):
    _fields_ = [('on', ctypes.c_int), ('offset', ctypes.c_int), ('channel', ctypes.c_int), ('pitch', ctypes.c_int), ('velocity', ctypes.c_float)]
lib.jp8h_init.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_double, ctypes.c_int]
lib.jp8h_load_patch.argtypes = [ctypes.c_char_p, ctypes.c_size_t]
lib.jp8h_process.argtypes = [ctypes.c_int, ctypes.POINTER(EV), ctypes.c_int, ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p,
                             ctypes.c_void_p, ctypes.c_void_p]
lib.jp8h_error.restype = ctypes.c_char_p
lib.jp8h_heap_stats.argtypes = [ctypes.POINTER(ctypes.c_uint64), ctypes.POINTER(ctypes.c_uint64)]
lib.jp8h_heap_top.restype = ctypes.c_uint64
t = open(tmpl, 'rb').read()
t0 = time.perf_counter()
if lib.jp8h_init(t, len(t), rate, N): sys.exit('jp8h_init: %s' % lib.jp8h_error().decode())
t1 = time.perf_counter()
blob = B.patch_blob(B.bank_bytes(), patch)
if lib.jp8h_load_patch(blob, len(blob)): sys.exit('patch load: %s' % lib.jp8h_error().decode())
t2 = time.perf_counter()
keys = (EV * 4)(*[EV(1, 0, 0, k, 0.8) for k in (48, 55, 60, 64)])
none = (EV * 1)()
L = (ctypes.c_uint32 * N)(); R = (ctypes.c_uint32 * N)()
nblk = int(secs * rate / N); crc = 0; heap0 = lib.jp8h_heap_top()
ts = time.perf_counter()
for b in range(nblk):
    if lib.jp8h_process(N, keys if b == 0 else none, 4 if b == 0 else 0, None, 0, None, L, R):
        sys.exit('block %d: %s' % (b, lib.jp8h_error().decode()))
    crc = zlib.crc32(bytes(L), crc); crc = zlib.crc32(bytes(R), crc)
te = time.perf_counter()
live, free = ctypes.c_uint64(0), ctypes.c_uint64(0); lib.jp8h_heap_stats(ctypes.byref(live), ctypes.byref(free))
audio = nblk * N / rate
print('%s: patch %d, four keys, %d blocks of %d at %g Hz (%.2f s of audio) in %.3f s = %.0f ms per second of audio; '
      'init %.0f ms, patch load %.1f ms; heap +%d KB over the blocks, reuse layer %d live / %d free blocks; checksum %08x' % (
      os.path.basename(so), patch, nblk, N, rate, audio, te - ts, 1000.0 * (te - ts) / audio, 1000.0 * (t1 - t0),
      1000.0 * (t2 - t1), (lib.jp8h_heap_top() - heap0) // 1024, live.value, free.value, crc & 0xFFFFFFFF))
