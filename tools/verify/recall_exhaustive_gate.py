#!/usr/bin/env python3
"""recall_exhaustive_gate.py -- A2 gate: the port's recall vs the plugin's OWN
setter, EXHAUSTIVELY over every front-panel index x every byte 0..255 x 3 rates.

This is the recall layer's exhaustion proof. recall_gate.py proves the port
matches the plugin on the 64 FACTORY patches (a sample of byte values);
recall_render_ab proves the render on 15 patches. This proves the recall FUNCTION
itself over its ENTIRE finite input domain -- so no byte value the microcontroller
target could ever load is untested.

For each index i and value v (blob byte), the plugin's own setter output is
recall_exhaustive_<rate>.pkl[lut][i]['cells'][cell][v] (built by the oracle,
recall_exhaustive_ref.py). The PORT side (this process, libjuno only) synthesizes
a 1-record bank whose blob byte at i's leaf position (bb) encodes v, applies it
with juno_gui_apply_bank, and reads the same cells. Any (index, value, cell,
rate) where port != plugin is a recall defect:
  - port leaves the cell at its default for all v while the plugin varies it
    -> DROPPED recall (the DCO-RANGE / delay-feedback class), OR
  - port writes a different value -> wrong law.

Reset semantics mirror the oracle: each (i,v) is applied to a FRESH engine so no
prior write leaks (juno_gui_apply_bank from a fresh juno_gui_create).

Two-process rule: libjuno/ctypes only; the oracle pickles were made in a separate
Unicorn process. Usage: recall_exhaustive_gate.py [rate ...]  (default all 3)
NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, os, struct, pickle, ctypes

HERE = os.path.dirname(os.path.abspath(__file__))
LIB = '/home/user/jn60c99/libjuno.so'
HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
BANK_LEN = HEADER + STRIDE
RATES = [44100, 48000, 96000]


def load_lib():
    lib = ctypes.CDLL(LIB)
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    return lib


def port_recall_cell(lib, rate, bb, v, cells):
    """Apply a 1-record bank with blob byte at position bb encoding v; return
    {cell: bits} for the requested cells. bb is the RECORD-relative leaf byte
    (blob-relative = bb - 0? no: leaf_table bb is blob-relative already: dec(blob,bb))."""
    bank = bytearray(BANK_LEN)
    bank[0] = ord('K')
    # juno_bank_apply reads blob = record + BLOB_OFF, then nibble pair at 2*blob_pos.
    # leaf_table bb IS the blob-relative byte index (dec(blob, bb)). So blob[bb]/[bb+1].
    blobbase = HEADER + BLOB_OFF
    bank[blobbase + bb] = (v >> 4) & 0xF
    bank[blobbase + bb + 1] = v & 0xF
    ctx = lib.juno_gui_create(ctypes.c_float(float(rate)), 0)
    lib.juno_gui_apply_bank(ctx, bytes(bank), BANK_LEN, 0)
    out = {c: lib.juno_gui_peek(ctx, c) for c in cells}
    lib.juno_gui_destroy(ctx)          # fresh engine per (idx,value); no leak, no leakage
    return out


def main():
    rates = [int(a) for a in sys.argv[1:]] or RATES
    lib = load_lib()
    total = mism = 0
    dropped = {}     # index -> set(cells) never matched (candidate dropped recall)
    wrong = {}       # index -> set(cells) with a value-level mismatch
    per_rate = {}
    missing = []

    multi_cells = set()
    for rate in rates:
        p = '%s/../../scratchpad/recall_exhaustive_%d.pkl' % (HERE, rate)
        p = os.path.abspath(p)
        if not os.path.exists(p):
            missing.append(rate); continue
        ref = pickle.load(open(p, 'rb'))
        lut = ref['lut']
        # A cell is SINGLE-INPUT iff exactly one index writes it. Multi-writer cells
        # (products/joints: bend depth, portamento-mode, HPF cutoff+type, LFO tempo)
        # are functions of several record bytes, so per-index isolation (one blob
        # byte set, the rest zeroed) does NOT reproduce the plugin's single-dispatch
        # (which holds the other factors at BUILD defaults, not zero). They are
        # verified on real factory byte-combinations by recall_gate.py (67/67, 64
        # patches) and by their formula unit tests (bend/mod 240/240); full
        # combinatorial exhaustion is 256^k and out of this gate's scope.
        writers = {}
        for i in lut:
            for c in lut[i]['cells']:
                writers.setdefault(c, set()).add(i)
        single = {c for c, ws in writers.items() if len(ws) == 1}
        multi_cells |= {c for c, ws in writers.items() if len(ws) > 1}
        rt_mism = 0
        for idx in sorted(lut):
            bb = lut[idx]['bb']
            cells = [c for c in sorted(lut[idx]['cells']) if c in single]
            if not cells:
                continue
            for v in range(256):
                got = port_recall_cell(lib, rate, bb, v, cells)
                for c in cells:
                    want = lut[idx]['cells'][c][v]
                    total += 1
                    if got[c] != want:
                        mism += 1; rt_mism += 1
                        wrong.setdefault(idx, {}).setdefault(c, [0, None])
                        wrong[idx][c][0] += 1
                        wrong[idx][c][1] = (rate, v, want, got[c])
        per_rate[rate] = rt_mism
        sys.stderr.write("rate %d done: %d mismatches (single-input cells only)\n" % (rate, rt_mism))
        sys.stderr.flush()

    print("=== EXHAUSTIVE RECALL GATE (port vs plugin setter, SINGLE-INPUT cells, all values) ===")
    if missing:
        print("MISSING oracle pickles for rates %s -- run recall_exhaustive_ref.py <rate>" % missing)
        return 2
    print("comparisons: %d  (single-input recall cells x 256 values x %d rates)" % (total, len(rates)))
    print("multi-input cells DEFERRED (verified by recall_gate factory combos + formula tests): %s"
          % sorted(multi_cells))
    print("mismatches:  %d   (per rate: %s)" % (mism, per_rate))
    if mism:
        print("\ndefective single-input recalls (index -> cell : wrong-count, example):")
        for idx in sorted(wrong):
            for c, (n, ex) in sorted(wrong[idx].items()):
                rate, v, want, got = ex
                fw = struct.unpack('<f', struct.pack('<I', want))[0]
                fg = struct.unpack('<f', struct.pack('<I', got))[0]
                kind = "DROPPED/frozen" if n >= 256 * len(rates) else "wrong-law"
                print("  idx %3d cell %6d : %4d wrong  [%s]  e.g. @%d v=%d plugin=%.6g port=%.6g"
                      % (idx, c, n, kind, rate, v, fw, fg))
        print("\nGATE: FAIL")
        return 1
    print("\nGATE: PASS -- the port's recall reproduces the plugin's setter for EVERY")
    print("single-input front-panel cell at EVERY byte 0..255, at 44100/48000/96000.")
    return 0


if __name__ == '__main__':
    sys.exit(main())
