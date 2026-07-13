#!/usr/bin/env python3
"""Scenario B — PORT side (libjuno.so) + bit-compare vs plugin dump.
Usage: scenB_port_cmp.py <patch> <plugin_dump_file>
"""
import ctypes, struct, math, sys

BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"
patch = int(sys.argv[1]); plugfile = sys.argv[2]
SR = 48000.0

lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_render.restype = ctypes.c_int

bank = open(BANK, 'rb').read()
c = lib.juno_gui_create(ctypes.c_float(SR), 0)   # chorus=0: proven cold baseline config
lib.juno_gui_apply_bank(c, bank, len(bank), patch)
# patches 13 and 43 are NOT among the 7 SQ arp patches (1,9,17,25,33,41,49): no arp_config needed

SEGS = [('on', 60, 105, 6000), ('off', 60, None, 24000), ('on', 60, 105, 6000),
        ('off', 60, None, 3000), ('on', 60, 40, 6000)]
L = []; R = []
for ev, note, vel, n in SEGS:
    if ev == 'on': lib.juno_gui_note_on(c, note, vel)
    else:          lib.juno_gui_note_off(c, note)
    buf = (ctypes.c_float * (2 * n))()
    lib.juno_gui_render(c, buf, n)
    inter = struct.unpack("<%dI" % (2 * n), bytes(buf))
    L += list(inter[0::2]); R += list(inter[1::2])

N = len(L)
data = open(plugfile, 'rb').read()
assert len(data) == 8 * N, (len(data), N)
Lp = struct.unpack("<%dI" % N, data[:4*N])
Rp = struct.unpack("<%dI" % N, data[4*N:])

def fv(u): return struct.unpack("<f", struct.pack("<I", u))[0]

bounds = [(0, 6000, "seg0 note_on(60,105)"), (6000, 30000, "seg1 note_off tail"),
          (30000, 36000, "seg2 retrigger(60,105)"), (36000, 39000, "seg3 note_off"),
          (39000, 45000, "seg4 note_on(60,40) soft")]
first = None; ndiff = 0
for i in range(N):
    if Lp[i] != L[i] or Rp[i] != R[i]:
        ndiff += 1
        if first is None: first = i
print("patch %d: frames=%d  diff_frames=%d" % (patch, N, ndiff))
for a, b, nm in bounds:
    d = sum(1 for i in range(a, b) if Lp[i] != L[i] or Rp[i] != R[i])
    def rms(v): return math.sqrt(sum(fv(x)**2 for x in v) / len(v))
    print("  %-28s frames %5d-%5d  diffs=%6d  plugRMS_L=%.6g portRMS_L=%.6g" % (
        nm, a, b-1, d, rms(Lp[a:b]), rms(L[a:b])))
if first is not None:
    i = first
    print("FIRST DIVERGENCE frame %d: plug L=%08x (%.9g) R=%08x (%.9g) | port L=%08x (%.9g) R=%08x (%.9g)" % (
        i, Lp[i], fv(Lp[i]), Rp[i], fv(Rp[i]), L[i], fv(L[i]), R[i], fv(R[i])))
    # RMS +-100 around it, both sides
    a = max(0, i-100); b = min(N, i+100)
    def rms(v): return math.sqrt(sum(fv(x)**2 for x in v) / len(v))
    print("  RMS[%d:%d] plug L=%.6g R=%.6g | port L=%.6g R=%.6g" % (
        a, b, rms(Lp[a:b]), rms(Rp[a:b]), rms(L[a:b]), rms(R[a:b])))
else:
    print("VERDICT patch %d: BIT-IDENTICAL over %d stereo frames" % (patch, N))

# tail decay check on the 24000-frame release tail (frames 6000..29999), port floats
def rms_f(a, b):
    sL = sum(fv(x)**2 for x in L[a:b]); sR = sum(fv(x)**2 for x in R[a:b])
    return math.sqrt((sL + sR) / (2 * (b - a)))
head = rms_f(6000, 9000); tail = rms_f(27000, 30000)
print("TAIL DECAY: RMS(first 3000 of tail)=%.8g  RMS(last 3000 of tail)=%.8g  ratio=%.3g" % (
    head, tail, (tail / head) if head > 0 else float('nan')))
