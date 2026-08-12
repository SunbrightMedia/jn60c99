#!/usr/bin/env python3
"""PORT side of the same question: does the port's warm-vs-cold state difference
reach the audio?  ctypes on libjuno.so ONLY -- no Unicorn in this process."""
import sys, ctypes, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import truth, freshlib

SR = float(sys.argv[1]) if len(sys.argv) > 1 else 44100.0
N = 8000
NOTE, VEL = 60, 105
bank = open(truth.BANK, 'rb').read()
lib = freshlib.load()
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]


def run(seq):
    c = lib.juno_gui_create(ctypes.c_float(SR), 0)
    for p in seq:
        lib.juno_gui_apply_bank(c, bank, len(bank), p)
    lib.juno_gui_note_on(c, NOTE, VEL)
    buf = (ctypes.c_float * (2 * N))()
    lib.juno_gui_render(c, buf, N)
    lib.juno_gui_destroy(c)
    return struct.unpack('<%dI' % (2 * N), bytes(buf))


nd_pairs = 0
for a in range(64):
    b = (a + 1) % 64
    cold = run([b]); warm = run([a, b])
    nd = sum(1 for i in range(2 * N) if cold[i] != warm[i])
    if nd: nd_pairs += 1
    print('PORTRENDER %2d -> %2d : %s (%d/%d samples)' %
          (a, b, 'BIT-IDENTICAL' if nd == 0 else 'DIFFERS', nd, 2 * N))
print('\nport warm-vs-cold RENDER at %g Hz: %d of 64 pairs differ' % (SR, nd_pairs))
