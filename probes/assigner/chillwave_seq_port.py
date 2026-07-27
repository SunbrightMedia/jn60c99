#!/usr/bin/env python3
"""Port half of the Chillwave assigner-level A/B."""
import ctypes, pickle, struct, sys
sys.path.insert(0, 'tools/verify')
from assigner_ab import SCRIPTS, BLOCK
CW = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
      '0e8b9cb5-Chillwave.bin')
d = pickle.load(open('/tmp/cw_seq_ref.pkl', 'rb'))
lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
bank = open(CW, 'rb').read()
bits = lambda f: struct.unpack('<I', struct.pack('<f', f))[0]
fails = checks = 0
for (p, name), (mode, leg, rl, rr) in sorted(d.items()):
    c = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), p)
    L, Rr = [], []
    for ev in SCRIPTS[name]:
        if ev[0] == 'on':    lib.juno_gui_note_on(c, ev[1], ev[2])
        elif ev[0] == 'off': lib.juno_gui_note_off(c, ev[1])
        else:
            done = 0
            while done < ev[1]:
                b = min(BLOCK, ev[1] - done)
                buf = (ctypes.c_float * (2*b))(); lib.juno_gui_render(c, buf, b)
                for i in range(b): L.append(bits(buf[2*i])); Rr.append(bits(buf[2*i+1]))
                done += b
    lib.juno_gui_destroy(c)
    dl = sum(1 for x, y in zip(rl, L) if x != y)
    dr = sum(1 for x, y in zip(rr, Rr) if x != y)
    checks += 1; ok = (dl == 0 and dr == 0)
    if not ok: fails += 1
    print("  CW p%-2d %-8s ASSIGN=%d LEGATO=%d : %s (L %d, R %d of %d)"
          % (p, name, mode, leg, "BIT-EXACT" if ok else "*** DIVERGES ***", dl, dr, len(rl)))
print("CHILLWAVE ASSIGNER A/B: %d/%d bit-exact -> %s"
      % (checks - fails, checks, "PASS" if fails == 0 else "FAIL"))
sys.exit(1 if fails else 0)
