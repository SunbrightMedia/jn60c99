#!/usr/bin/env python3
"""PILLAR 1 / Stage A — the PORT's applied audio-cell set: every unit-0 cell the
port's recall (juno_gui_apply_bank + all appliers) writes, unioned over patches
covering each FX type so conditional appliers (etype==0 guard, delay-type arms,
mode-5) are all exercised. Since 2026-10-05 the extra coverage comes from
synthetic one-record banks (factory patches with every EFFECT TYPE x DELAY
TYPE pair forced), not from a user bank: the ledger must regenerate from the
truth/ files alone. Cross-referenced against leaf_cellmap.pkl (the
plugin's setter cell-map) to produce the GAP: cells the plugin's parameter
setters write that the port never touches. Port-only process (ctypes libjuno);
NO Unicorn here (two-process rule)."""
import os as _os_jrepo; _JREPO = _os_jrepo.path.dirname(_os_jrepo.path.dirname(_os_jrepo.path.dirname(_os_jrepo.path.abspath(__file__))))  # repo root from this file; never hardcode it (tools/verify/pathcheck.py)
import sys, ctypes, struct, pickle
import refio
SP = _JREPO + '/scratchpad'
OUT = SP + '/port_writeset.pkl'
SZ = 0xA83010

lib = ctypes.CDLL(_JREPO + '/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_int]

sys.path.insert(0, _JREPO + '/tools/verify')
import truth
FAC = str(truth.BANK)

lib.juno_gui_state.restype = ctypes.c_void_p
lib.juno_gui_state.argtypes = [ctypes.c_void_p]
lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
# Cells the recall READS keep their value in the flipped copy: the C++ header
# and host rate [0,176) and the slot routing cells JUNO_PROG_EFX/DLY (11022052/56).
# Everything else in the object, the reverb tap array (11022208..) included, is
# flipped. The port-owned shadows (src/juno_engine.h) lie past KEEP_HI and are
# never flipped; shadow_bounds_gate.py check 3 forbids naming them here.
KEEP_LO, KEEP_HI = 176, 0xA83010
KEEP = (11022052, 11022056)


def _after(bankbytes, idx, flip):
    c = lib.juno_gui_create(ctypes.c_float(48000.0), 0)
    if flip:
        st = lib.juno_gui_state(c)
        raw = (ctypes.c_ubyte * (KEEP_HI - KEEP_LO)).from_address(st + KEEP_LO)
        import numpy as np
        a = np.frombuffer(raw, dtype=np.uint32)
        keep = [(k - KEEP_LO) // 4 for k in KEEP if KEEP_LO <= k < KEEP_HI]
        saved = a[keep].copy()
        a ^= np.uint32(0x5A5A5A5A)
        a[keep] = saved
    lib.juno_gui_apply_bank(c, bankbytes, len(bankbytes), idx)
    buf = ctypes.create_string_buffer(SZ); lib.juno_gui_dump(c, 0, buf, SZ)
    lib.juno_gui_destroy(c)
    return buf.raw


def writeset_for(bankbytes, idx):
    """Cells the recall WRITES, including writes of the value already there:
    recall onto the cold state and onto the cold state with every word XORed
    (outside the cells the recall reads); a written cell ends equal in both, an
    untouched one keeps the XOR difference. (The old before/after diff missed
    every cell written with its cold value, e.g. 91216 = the prepare seed 1.3,
    and showed them as false GAPs.)"""
    a = _after(bankbytes, idx, False)
    b = _after(bankbytes, idx, True)
    return set(o for o in range(KEEP_LO, KEEP_HI, 4) if a[o:o+4] == b[o:o+4] and o not in KEEP)

fac = open(FAC, 'rb').read()
HEADER, STRIDE = 23, 20223


def synth(base, et, dt):
    # factory patch `base` with EFFECT TYPE (record 634) and DELAY TYPE (650) forced
    rec = bytearray(fac[HEADER + base * STRIDE: HEADER + (base + 1) * STRIDE])
    for off, v in ((634, et), (650, dt)):
        rec[off] = (v >> 4) & 0xF
        rec[off + 1] = v & 0xF
    return bytes(fac[:HEADER]) + bytes(rec)


allcells = set()
for idx in range(64):
    allcells |= writeset_for(fac, idx)
# the factory bank omits EFFECT TYPE 0/4 and DELAY TYPE 4: force every pair
n_synth = 0
for base in (0, 4, 20):
    for et in range(6):
        for dt in range(6):
            allcells |= writeset_for(synth(base, et, dt), 0)
            n_synth += 1
allcells = sorted(allcells)
refio.dump(set(allcells), OUT)
print("port writes %d distinct unit-0 cells across 64 factory + %d synthetic records" % (len(allcells), n_synth))
print("wrote", OUT)
