#!/usr/bin/env python3
"""port_state_dump.py -- the PORT side of the reconstruction-free recall diff.

Dumps the port's per-voice engine state (unit-0 block) for every patch, so it can
be diffed cell-by-cell against the plugin's OWN controller-driven recall reference
(built separately under Unicorn). This side touches ONLY libjuno via ctypes and
imports NOTHING from e2e_emu -- honoring the two-process rule (never build an E2E
instance and load libjuno in the same process).

Output: a pickle {patch_idx: bytes(voice-0 block)} plus a printed feet-3840 table.

Usage:
  python3 tools/verify/port_state_dump.py                 # dump + feet table
  python3 tools/verify/port_state_dump.py --feet-only      # just the feet table
"""
import sys, struct, pickle, ctypes

LIB   = '/home/user/jn60c99/libjuno.so'
import os as _o, sys as _s; _s.path.insert(0, _o.path.dirname(_o.path.abspath(__file__)))
import truth; BANK = truth.BANK  # single source of ground truth (truth/ folder)
PKL   = '/home/user/jn60c99/scratchpad/port_state.pkl'
SR    = 48000.0
BLOCK = 10512          # per-voice unit-0 block (matches recall_fullstate_diff)
STRIDE = 16            # engine cells are 16-byte slots (float in low 4 bytes)
FEET_OFF = 3840        # DCO octave multiplier cell

# 28 patches whose stored DCO RANGE (record leaf bb32) != 3 (= not 8'/feet 1.0),
# per the proven parser (real_bank_parse). If the port recalls DCO RANGE these
# feet values would be non-1.0; the reverted baseline leaves them all at 1.0.
NONDEFAULT = {3:0.5,4:0.5,6:0.5,10:0.5,11:0.5,12:0.5,14:0.5,18:2.0,22:0.5,25:2.0,
              26:2.0,29:2.0,30:0.5,33:0.5,34:0.5,38:0.5,39:4.0,40:2.0,42:0.5,46:0.5,
              51:0.5,53:2.0,54:0.5,55:2.0,57:0.5,59:0.5,61:2.0,62:0.5}


def as_f32(u32):
    return struct.unpack('<f', struct.pack('<I', u32))[0]


def load_lib():
    import freshlib  # stale-artifact guard (ROADMAP P0.3): refuse a libjuno.so older than src
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    return lib


def main():
    feet_only = '--feet-only' in sys.argv
    lib = load_lib()
    bank = open(BANK, 'rb').read()
    states = {}
    print("=== PORT feet 3840 for the 28 non-default-DCO-RANGE patches ===")
    print("(if the port recalled DCO RANGE these would match the stored feet; baseline = all 1.0)")
    mism = 0
    for idx in range(64):
        ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), idx)
        if not feet_only:
            # full 10512-byte unit-0 block (all bytes, matches plugin state[0]); cells
            # live at 16-byte stride but we mirror every byte so byte-offset indexing works.
            blk = b''.join(struct.pack('<I', lib.juno_gui_peek(ctx, off)) for off in range(0, BLOCK, 4))
            states[idx] = blk
        feet = as_f32(lib.juno_gui_peek(ctx, FEET_OFF))
        if idx in NONDEFAULT:
            stored = NONDEFAULT[idx]
            flag = '' if abs(feet - 1.0) < 1e-9 else '  <-- non-1.0!'
            print("  patch %2d  port feet=%-6s  stored DCO RANGE feet=%-4s%s" %
                  (idx, feet, stored, flag))
    if not feet_only:
        pickle.dump(states, open(PKL, 'wb'))
        print("\nsaved port voice-0 block for 64 patches -> %s (%d bytes/patch)" % (PKL, BLOCK))
    print("\nNOTE: this is the PORT side only. The reference side is the plugin's OWN")
    print("controller-driven recall (built under Unicorn); the diff is a separate step.")


if __name__ == '__main__':
    main()
