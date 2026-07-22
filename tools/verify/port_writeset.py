#!/usr/bin/env python3
"""PILLAR 1 / Stage A — the PORT's applied audio-cell set: every unit-0 cell the
port's recall (juno_gui_apply_bank + all appliers) writes, unioned over patches
covering each FX type so conditional appliers (etype==0 guard, delay-type arms,
mode-5) are all exercised. Cross-referenced against leaf_cellmap.pkl (the
plugin's setter cell-map) to produce the GAP: cells the plugin's parameter
setters write that the port never touches. Port-only process (ctypes libjuno);
NO Unicorn here (two-process rule)."""
import sys, ctypes, struct, pickle
SP = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
OUT = SP + '/port_writeset.pkl'
CW = SP + '/chillwave.bin'
SZ = 0xA83010

lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_int]

sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import truth
FAC = str(truth.BANK)

def writeset_for(bankbytes, idx):
    c = lib.juno_gui_create(ctypes.c_float(48000.0), 0)
    buf0 = ctypes.create_string_buffer(SZ); lib.juno_gui_dump(c, 0, buf0, SZ)
    lib.juno_gui_apply_bank(c, bankbytes, len(bankbytes), idx)
    buf1 = ctypes.create_string_buffer(SZ); lib.juno_gui_dump(c, 0, buf1, SZ)
    a, b = buf0.raw, buf1.raw
    return set(o for o in range(0, SZ, 4) if a[o:o+4] != b[o:o+4])

fac = open(FAC, 'rb').read()
cw = open(CW, 'rb').read()
# factory patches covering FX variety + all 64 for good measure; + chillwave FX combos
allcells = set()
covered = []
for idx in range(64):
    allcells |= writeset_for(fac, idx)
for idx in (3, 4, 5, 24, 32, 38, 56):     # chillwave: fine-FX-heavy + flanger/mode combos
    allcells |= writeset_for(cw, idx)
allcells = sorted(allcells)
pickle.dump(set(allcells), open(OUT, 'wb'))
print("port writes %d distinct unit-0 cells across 64 factory + 7 chillwave patches" % len(allcells))
print("wrote", OUT)
