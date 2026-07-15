#!/usr/bin/env python3
"""full_recall_triage.py -- recall triage over the FULL cell range (voice + FX).

Extends frozen_triage.py from voice-0 to the master/effects region (chorus, delay,
reverb) so the recall-correctness picture is complete. Loads the PROVEN plugin
dispatch maps (pickles), and captures the port's per-patch values via libjuno in
THIS process (no E2E instance here -> two-process rule preserved; the maps were
produced in the E2E process earlier).

Cell regions in a unit-0 block (STATE_SZ = 0xA83010):
  voice 0     : [0, 10512)
  voices 1..7 : [10512, 84096)   -- replicas of voice-0 params; skipped (redundant)
  master/FX   : [84096, STATE_SZ) -- chorus/delay/reverb + master

Verdict per plugin-writable cell: CORRECT / FROZEN-OK / CANDIDATE / SPURIOUS
(same definitions as frozen_triage.py).
"""
import sys, struct, pickle, ctypes

ICM  = '/home/user/jn60c99/scratchpad/index_cell_map.pkl'
PCM  = '/home/user/jn60c99/scratchpad/param_cell_map.pkl'
LIB  = '/home/user/jn60c99/libjuno.so'
BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
SR   = 48000.0
VOICE, NVOICE, VOICES_END = 10512, 8, 84096


def main():
    icm = pickle.load(open(ICM, 'rb'))
    pcm = pickle.load(open(PCM, 'rb'))
    map_indices = {idx for (idx, cells) in pcm.values()}

    # plugin-writable cells in voice-0 OR master/FX (skip voice 1..7 replicas)
    cell_idx = {}
    for idx, cells in icm.items():
        for off in cells:
            if off < VOICE or off >= VOICES_END:
                cell_idx.setdefault(off, []).append(idx)
    cells = sorted(cell_idx)

    lib = ctypes.CDLL(LIB)
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    bank = open(BANK, 'rb').read()

    # port value per cell across 64 patches
    varies = {}
    for off in cells:
        varies[off] = set()
    for idx in range(64):
        ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), idx)
        for off in cells:
            varies[off].add(lib.juno_gui_peek(ctx, off))

    def region(off): return 'voice' if off < VOICE else 'FX/master'
    def reach(off):  return any(i in map_indices for i in cell_idx[off])

    correct = [c for c in cells if len(varies[c]) > 1]
    frozen  = [c for c in cells if len(varies[c]) == 1]
    cand    = [c for c in frozen if reach(c)]
    ok      = [c for c in frozen if not reach(c)]

    print("=== FULL recall triage (voice-0 + master/FX, 64 patches) ===")
    print("plugin-writable cells examined: %d (%d voice, %d FX/master)"
          % (len(cells), sum(1 for c in cells if c < VOICE),
             sum(1 for c in cells if c >= VOICES_END)))
    print("CORRECT   (port recalls)          : %d  (voice %d, FX %d)"
          % (len(correct), sum(1 for c in correct if c < VOICE),
             sum(1 for c in correct if c >= VOICES_END)))
    print("FROZEN-OK (not value-tree-reachable): %d" % len(ok))
    print("CANDIDATE (port may drop a recall)  : %d" % len(cand))
    for off in cand:
        print("   %-9s cell %8d  <- idx %s" % (region(off), off, ",".join(map(str, cell_idx[off]))))
    # FX region specifically
    fx_cand = [c for c in cand if c >= VOICES_END]
    fx_corr = [c for c in correct if c >= VOICES_END]
    print("\nFX/master: %d correct-recalled, %d candidate-frozen" % (len(fx_corr), len(fx_cand)))
    print("  FX correct cells:", fx_corr)
    print("  FX candidate-frozen cells:", fx_cand)


if __name__ == '__main__':
    main()
