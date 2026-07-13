#!/usr/bin/env python3
"""Scenario C port side (libjuno.so via ctypes) + bit-compare vs cached plugin stream."""
import sys, struct, ctypes, pickle, math
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')

BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"
PKL = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/scenC_plugin.pkl'

lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_render.restype = ctypes.c_int

bank = open(BANK, 'rb').read()
c = lib.juno_gui_create(ctypes.c_float(48000.0), 0)   # chorus=0: proven cold baseline
lib.juno_gui_apply_bank(c, bank, len(bank), 0)        # patch 0 (not an arp patch)

L = []; R = []
def rend(n):
    buf = (ctypes.c_float * (2 * n))()
    lib.juno_gui_render(c, buf, n)
    inter = struct.unpack("<%dI" % (2 * n), bytes(buf))
    L.extend(inter[0::2]); R.extend(inter[1::2])

lib.juno_gui_note_on(c, 60, 100); lib.juno_gui_note_on(c, 64, 100); lib.juno_gui_note_on(c, 67, 100)
rend(6000)
for nt in (48, 50, 52, 53, 55, 57):
    lib.juno_gui_note_on(c, nt, 100)
    rend(500)
rend(6000)

d = pickle.load(open(PKL, 'rb'))
La, Ra, segs = d['L'], d['R'], d['segments']
n = min(len(La), len(L))
assert len(La) == len(L) == n, (len(La), len(L))

def f(x): return struct.unpack("<f", struct.pack("<I", x))[0]

ndiff = 0; first = None
for i in range(n):
    if La[i] != L[i] or Ra[i] != R[i]:
        ndiff += 1
        if first is None: first = i

print("compared %d frames (%d uint32 samples). mismatched frames=%d" % (n, 2 * n, ndiff))
if first is None:
    print("VERDICT: BIT-IDENTICAL over all %d frames." % n)
else:
    i = first
    seg = next(s for s in segs if s[1] <= i < s[2])
    print("FIRST DIVERGENCE frame %d, in segment %r (frames %d..%d)" % (i, seg[0], seg[1], seg[2]))
    print("  plugin L=%08x (%.9g)  port L=%08x (%.9g)" % (La[i], f(La[i]), L[i], f(L[i])))
    print("  plugin R=%08x (%.9g)  port R=%08x (%.9g)" % (Ra[i], f(Ra[i]), R[i], f(R[i])))
    a, b = max(0, i - 250), min(n, i + 250)
    def rms(v): return math.sqrt(sum(f(x)**2 for x in v) / len(v))
    print("  RMS(L) around it [%d..%d): plugin=%.6g port=%.6g" % (a, b, rms(La[a:b]), rms(L[a:b])))
    print("  RMS(R) around it [%d..%d): plugin=%.6g port=%.6g" % (a, b, rms(Ra[a:b]), rms(R[a:b])))
    # per-segment diff counts to minimize which event introduced divergence
    print("  per-segment mismatch counts:")
    for lbl, s0, s1 in segs:
        cdiff = sum(1 for k in range(s0, s1) if La[k] != L[k] or Ra[k] != R[k])
        print("    %-28s frames %5d..%5d  diffs=%d" % (lbl, s0, s1, cdiff))
