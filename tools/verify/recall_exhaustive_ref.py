#!/usr/bin/env python3
"""recall_exhaustive_ref.py -- A2: the plugin's OWN recall setter output for EVERY
front-panel index x EVERY byte value 0..255, at one host rate. The recall input
domain is FINITE (index in the enumerator's set, byte in 0..255), so this EXHAUSTS
it -- it does not sample. This is the ground-truth half of the exhaustive recall
gate; the port half (recall_exhaustive_gate.py) diffs against it.

Method (plugin machine code only, Unicorn oracle):
  build(rate) -> snap_all -> baseline = voice-0 block (10512 bytes).
  For each front-panel index (enumerator 0x3B48A0 set intersect leaf_table):
    for value in 0..255:
      restore voice-0 block to baseline   (isolate this index+value fully)
      dispatch(0, index, value)           (the plugin's OWN setter 0x3B9A30)
      record every cell whose bits != baseline -> LUT[index][cell][value]
  A cell "belongs to" an index if it differs from baseline for ANY value; its
  256-entry value->bits array is the plugin's exact per-value law for that cell.

Dispatching index i with value v IS the plugin recalling a bank blob byte = v at
i's leaf (real_recall: recall = wr_desc(i, dec(blob,bb)); dispatch(i, rd_desc(i))),
so the port's recall of that same byte is directly comparable.

Output: scratchpad/recall_exhaustive_<rate>.pkl =
  { 'rate': int, 'baseline': bytes(10512),
    'lut': { index: { 'bb': blob_byte_pos, 'cells': { cell: [bits]*256 } } } }

Two-process rule: E2E/Unicorn only. Usage: recall_exhaustive_ref.py <rate>
NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, os, struct, pickle
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import e2e_emu as E
import real_recall as RR
import plugin_recall_set as PRS

BLOCK = 10512
STRIDE = 16


def main():
    rate = float(sys.argv[1]) if len(sys.argv) > 1 else 48000.0
    out = '/home/user/jn60c99/scratchpad/recall_exhaustive_%d.pkl' % int(rate)

    recall_idx = set(PRS.recall_indices())
    lt = dict(RR.leaf_table())
    fp = sorted(i for i in recall_idx if i in lt)     # front-panel recalled indices
    sys.stderr.write("rate %g: %d front-panel indices to enumerate x 256 values\n" % (rate, len(fp)))

    e = E.E2E(); e.build(rate); e.snap_all()
    uc = e.uc; st0 = e.state[0]
    baseline = bytes(uc.mem_read(st0, BLOCK))
    base_cells = [struct.unpack('<I', baseline[o:o+4])[0] for o in range(0, BLOCK, STRIDE)]

    lut = {}
    for n, idx in enumerate(fp):
        # per (idx, value): reset to baseline, dispatch, diff -> touched cells
        touched = {}   # cell offset -> [bits]*256
        for v in range(256):
            uc.mem_write(st0, baseline)                  # full isolation
            try:
                e.dispatch(0, idx, v)
            except RuntimeError:
                pass
            blk = uc.mem_read(st0, BLOCK)
            for ci, o in enumerate(range(0, BLOCK, STRIDE)):
                bits = struct.unpack('<I', blk[o:o+4])[0]
                if bits != base_cells[ci]:               # this cell moved off baseline
                    touched.setdefault(o, [base_cells[ci]] * 256)[v] = bits
        if touched:
            lut[idx] = {'bb': lt[idx], 'cells': touched}
        if n % 10 == 0:
            sys.stderr.write("  %d/%d indices (idx %d -> %d cells)\n"
                             % (n, len(fp), idx, len(touched))); sys.stderr.flush()

    uc.mem_write(st0, baseline)
    pickle.dump({'rate': int(rate), 'baseline': baseline, 'lut': lut}, open(out, 'wb'))
    ncells = sum(len(d['cells']) for d in lut.values())
    print("rate %d: %d indices write %d voice-0 cells -> %s" % (int(rate), len(lut), ncells, out))


if __name__ == '__main__':
    main()
