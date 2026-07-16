#!/usr/bin/env python3
"""delay_fb_sweep.py -- B1 evidence: the plugin's OWN law for the two FX-region
delay leaves, executed over the FULL byte domain.

  idx 1179  DELAY FEEDBACK      (record byte 3057)
  idx 1181  DELAY DIRECT LEVEL  (record byte 3060)

For each index x value 0..255 x rate {44100,48000,96000}: restore the unit-0
state block to the post-build baseline, dispatch the plugin's own setter, and
diff the ENTIRE state block (0xA83010 bytes, numpy) to find every cell written
and its exact bits. Then bit-fit the candidate laws:
  f(v) = f32(f32(v)/255) * f32(0.9)   [mulss order A]
  f(v) = f32(v) * f32(0.9/255)        [mulss order B]
  f(v) = f32(v)/255                   [plain]
against the observed 256-entry table, per rate. Exact u32-bit match required.

Output: scratchpad/delay_fb_sweep.pkl {rate: {idx: {cell: [bits]*256}}} + verdict.
Two-process rule: E2E/Unicorn only.
NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, os, struct, pickle
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import e2e_emu as E

STATE_SZ = E.STATE_SZ
RATES = [44100.0, 48000.0, 96000.0]
IDXS = [1179, 1181]


def f32(x):
    return np.float32(x)


def law_bits(fn):
    out = []
    for v in range(256):
        out.append(struct.unpack('<I', struct.pack('<f', float(fn(v))))[0])
    return out


LAWS = {
    'f32(v/255)*0.9 (mulss A)': lambda v: f32(f32(f32(v) / f32(255.0)) * f32(0.9)),
    'v*f32(0.9/255) (mulss B)': lambda v: f32(f32(v) * f32(f32(0.9) / f32(255.0))),
    'v/255':                    lambda v: f32(f32(v) / f32(255.0)),
    'v/255*0.9 (dbl then f32)': lambda v: f32(v / 255.0 * 0.9),
}


def sweep_rate(rate):
    e = E.E2E(); e.build(rate); e.snap_all()
    uc = e.uc; st0 = e.state[0]
    baseline = np.frombuffer(bytes(uc.mem_read(st0, STATE_SZ)), dtype=np.uint32).copy()
    out = {}
    for idx in IDXS:
        cells = {}
        for v in range(256):
            uc.mem_write(st0, baseline.tobytes())
            try:
                e.dispatch(0, idx, v)
            except RuntimeError:
                pass
            cur = np.frombuffer(bytes(uc.mem_read(st0, STATE_SZ)), dtype=np.uint32)
            for w in np.nonzero(cur != baseline)[0]:
                off = int(w) * 4
                cells.setdefault(off, [int(baseline[w])] * 256)[v] = int(cur[w])
        out[idx] = cells
        sys.stderr.write("  rate %g idx %d -> writes cells %s\n" % (rate, idx, sorted(cells)))
    return out


def main():
    data = {}
    for r in RATES:
        data[int(r)] = sweep_rate(r)
    pickle.dump(data, open('/home/user/jn60c99/scratchpad/delay_fb_sweep.pkl', 'wb'))

    print("=== plugin's own delay-leaf laws (executed, all 256 values x 3 rates) ===")
    for idx in IDXS:
        cellsets = [set(data[int(r)][idx]) for r in RATES]
        same_cells = cellsets[0] == cellsets[1] == cellsets[2]
        print("idx %d: cells %s  (identical across rates: %s)" % (idx, sorted(cellsets[0]), same_cells))
        for cell in sorted(cellsets[0]):
            tables = [data[int(r)][idx][cell] for r in RATES]
            rate_indep = tables[0] == tables[1] == tables[2]
            fits = [name for name, fn in LAWS.items() if law_bits(fn) == tables[1]]
            f0 = struct.unpack('<f', struct.pack('<I', tables[1][0]))[0]
            f255 = struct.unpack('<f', struct.pack('<I', tables[1][255]))[0]
            print("  cell %6d: rate-indep=%s  v0=%.6g v255=%.6g  BIT-EXACT law: %s"
                  % (cell, rate_indep, f0, f255, fits if fits else "NO simple fit -- use LUT"))


if __name__ == '__main__':
    main()
