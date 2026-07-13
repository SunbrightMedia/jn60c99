#!/usr/bin/env python3
"""Seed-70 residual: minimal repro + causal proof.
Minimal script (patch 15, 48 kHz): one note, flip TEMPO SYNC (blob-59 row 24,
byte 139) at frame 400, render past the 128-BPM synced tap (16873).
  A: port verbatim (fuzz conventions)        -> expect DIVERGE @16873 R-only
  B: port + arp_config(...,128.0,...) tempo   -> expect OK (BPM route causal)
  C: port + poke 4297584 = plugin bits after flip -> expect OK (cell causal)
Also validates the coefficient law in pure python.
"""
import sys, struct, ctypes
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import fuzz_diff as F
import e2e_emu as E

lib = F.lib
BLOBS = F.BLOBS
RATE, PATCH = 48000.0, 15
EV = [('on', 33, 65), ('render', 400), ('param', 24, 139), ('render', 17000)]
HORIZON = 17400

# --- coefficient law check (pure python, float32) ---
import numpy as np
f32 = np.float32
def coeff(H, ms): return f32(f32(f32(H)*f32(ms)) * f32(1.0/16384000.0)) - f32(2.0/16384.0)
c128 = coeff(48000, f32(0.75*60000/128))   # division 8 (byte 128), 128 BPM
c120 = coeff(48000, f32(0.75*60000/120))   # division 8, 120 BPM
print(f"law: coeff@128BPM={struct.unpack('<I', struct.pack('<f', c128))[0]:08x} "
      f"(plugin wrote 3f83d200), coeff@120BPM={struct.unpack('<I', struct.pack('<f', c120))[0]:08x} "
      f"(port wrote 3f8c9c00)")
print(f"law: tap@128 = {float(c128)*16384:.1f} samples, tap@120 = {float(c120)*16384:.1f} samples")

# --- plugin (once) ---
e = E.E2E(); e.build(RATE); e.snap_all(); E.recall_patch(e, PATCH)
e.snap_all(); e.clear_latch(); e.set_ftz()
La, Ra = [], []
for x in EV:
    if x[0] == 'on': e.note_on(x[1], x[2])
    elif x[0] == 'off': e.note_off(x[1])
    elif x[0] == 'param':
        for u in range(9):
            try: e.dispatch(u, BLOBS[x[1]] + 744, x[2])
            except RuntimeError: pass
        e.snap_all()
    else:
        l, r = e.render(x[1]); La += l; Ra += r
plug_cell = struct.unpack('<I', bytes(e.uc.mem_read(e.state[8] + 4297584, 4)))[0]
print(f"plugin 4297584 after run = {plug_cell:08x}")

# --- port variants ---
bank = open(F.BANK, 'rb').read()
lib.juno_gui_get.restype = ctypes.c_float
lib.juno_gui_get.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_set.restype = None
lib.juno_gui_set.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_float]
lib.juno_gui_peek.restype = ctypes.c_uint
lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]

def run_port(variant):
    c = lib.juno_gui_create(ctypes.c_float(RATE), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), PATCH)
    if variant == 'B':          # non-arp tempo push at the fuzz harness's 128 BPM
        lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)
    Lb, Rb = [], []
    for x in EV:
        if x[0] == 'on': lib.juno_gui_note_on(c, x[1], x[2])
        elif x[0] == 'off': lib.juno_gui_note_off(c, x[1])
        elif x[0] == 'param':
            lib.juno_gui_set_param(c, x[1], x[2])
            if variant == 'C':  # poke the plugin's 128-BPM re-time bits
                lib.juno_gui_set(c, 4297584, struct.unpack('<f', struct.pack('<I', 0x3f83d200))[0])
        else:
            n = x[1]; buf = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, buf, n)
            inter = struct.unpack("<%dI" % (2*n), bytes(buf))
            Lb += inter[0::2]; Rb += inter[1::2]
    cell = lib.juno_gui_peek(c, 4297584)
    return Lb, Rb, cell

for variant in ('A', 'B', 'C'):
    Lb, Rb, cell = run_port(variant)
    n = min(len(La), len(Lb))
    first = next((i for i in range(n) if La[i] != Lb[i] or Ra[i] != Rb[i]), None)
    if first is None:
        print(f"variant {variant}: OK frames={n} (port 4297584={cell:08x})")
    else:
        # count L-only vs R-only diffs in a window after first
        print(f"variant {variant}: DIVERGE @frame {first} "
              f"plugL={La[first]:08x} portL={Lb[first]:08x} "
              f"plugR={Ra[first]:08x} portR={Rb[first]:08x} (port 4297584={cell:08x})")
        ld = sum(1 for i in range(first, min(first+200, n)) if La[i] != Lb[i])
        rd = sum(1 for i in range(first, min(first+200, n)) if Ra[i] != Rb[i])
        print(f"           next 200 frames: L diffs={ld}, R diffs={rd}")
