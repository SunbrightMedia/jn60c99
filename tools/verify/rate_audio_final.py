#!/usr/bin/env python3
"""rate_audio_final.py — post-fix audio A/B at 44100 AND 96000 for one patch per
DELAY TYPE (v39 = 0/1/2/3/5) + patch 9 (the only v551=1 patch). 12000-frame cold
note render, full bit-compare vs the plugin's own code."""
import sys, struct, ctypes
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"
bank = open(BANK, 'rb').read()
N = 12000
PATCHES = [13, 4, 11, 19, 5, 9]
lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_arp_config.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float, ctypes.c_float]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
ARPS = {1, 9, 17, 25, 33, 41, 49}

for sr in (44100.0, 96000.0):
    print(f"=== rate {int(sr)} ===", flush=True)
    for p in PATCHES:
        e = E.E2E(); e.build(sr); e.snap_all(); E.recall_patch(e, p); e.snap_all(); e.clear_latch(); e.set_ftz()
        e.note_on(60, 105); La, Ra = e.render(N)
        c = lib.juno_gui_create(ctypes.c_float(sr), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), p)
        if p in ARPS: lib.juno_gui_arp_config(c, 0, 0, 1, 120.0, 0.6)
        lib.juno_gui_note_on(c, 60, 105)
        buf = (ctypes.c_float * (2*N))(); lib.juno_gui_render(c, buf, N)
        inter = struct.unpack("<%dI" % (2*N), bytes(buf))
        L = inter[0::2]; R = inter[1::2]
        first = next((i for i in range(N) if La[i] != L[i] or Ra[i] != R[i]), None)
        print(f"  patch {p:2d}: {'BIT-EXACT over %d frames' % N if first is None else 'FIRST DIFF @' + str(first)}", flush=True)
