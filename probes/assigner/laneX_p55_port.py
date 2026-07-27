#!/usr/bin/env python3
"""Port half: same sequence, diff each voice v against plugin unit v (the layout
docs/RENDER_LOOP_LOG.md proves: plugin voice v lives in unit v at +v*10512)."""
import ctypes, pickle, struct, sys
sys.path.insert(0, 'tools/verify')
import truth
STRIDE, NV = 10512, 8
st9 = pickle.load(open('/tmp/p55_ref.pkl', 'rb'))
lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_ubyte), ctypes.c_int]
bank = open(truth.BANK, 'rb').read()
c = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
lib.juno_gui_apply_bank(c, bank, len(bank), 55)
lib.juno_gui_note_on(c, 60, 100)
done = 0
while done < 3000:
    b = min(512, 3000 - done)
    buf = (ctypes.c_float * (2*b))()
    lib.juno_gui_render(c, buf, b); done += b
lib.juno_gui_note_on(c, 67, 100)

nd = 0
for v in range(NV):
    base = 176 + v*STRIDE
    n = STRIDE
    buf = (ctypes.c_ubyte * n)()
    lib.juno_gui_dump(c, base, buf, n)
    port = bytes(buf)
    ref = st9[v][base:base+n]
    for i in range(0, n, 4):
        if port[i:i+4] != ref[i:i+4]:
            a = struct.unpack('<f', ref[i:i+4])[0]; b = struct.unpack('<f', port[i:i+4])[0]
            nd += 1
            if nd <= 40:
                print("  voice %d cell %5d : plugin %-14g port %-14g" % (v, i, a, b))
print("TOTAL differing per-voice cells after note 2: %d" % nd)
