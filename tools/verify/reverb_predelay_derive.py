"""W1: derive the REVERB PRE DELAY (idx 1323) law.

Hypothesis (to be CONFIRMED by execution, not assumed): PRE DELAY sets the reverb
pre-delay in samples and shifts the reverb tap-index array (34 ints at 11022208,
written by juno_write_reverb_taps) uniformly. reverb_recall.c already bakes a base
predelay = (int)(0.019995*H) at the DEFAULT byte (note 0.019995 == 20*0.00099975);
this sweep executes the plugin's OWN setter (dispatch 0x3B9A30 idx 1323 + snap) over
the full int1x7 range 0..127 for each REVERB TYPE class (0, 1, 2..5-share) at each
host rate, reads EVERY changed state cell, and classifies tap vs non-tap so the port
can reproduce the exact per-byte movement. Required identity: at byte 20 (default)
the taps must EQUAL juno_write_reverb_taps' current output.

Covenant-clean (plugin's own setter under Unicorn, dispatch+snap). Two-process.
Output: scratchpad/reverb_predelay.json { "cls|rate": {cell: [128 values]} }.
"""
import sys, json
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import numpy as np, e2e_emu as E

SZ = 0xA83010; NW = SZ // 4
RT = 876; PRE = 1323                  # idx 876 = REVERB TYPE (moves taps); 877 = TIME
TAP0 = 11022208                       # first tap cell; array spans 34 ints
fac = E.bank_bytes(); std = E.load_leaves()

def nib(r, o): return ((r[o] & 0xF) << 4) | (r[o + 1] & 0xF)
def apply_std(e, blob):
    for (p, nm, disp, bb) in std:
        for u in range(9):
            try: e.dispatch(u, disp, E.dec(blob, bb))
            except RuntimeError: pass
def force(e, disp, v):
    for u in range(9):
        try: e.dispatch(u, disp, v)
        except RuntimeError: pass
def rd(e): return np.frombuffer(bytes(e.uc.mem_read(e.state[0], SZ)), dtype='<u4')
revp = max(range(64), key=lambda i: nib(E.patch_blob(fac, i), 118 - 16))

def ctx(sr, rtype):
    e = E.E2E(); e.build(sr); e.snap_all()
    apply_std(e, E.patch_blob(fac, revp)); force(e, RT, rtype)
    e.snap_all(); e.clear_latch(); e.set_ftz(); e.note_on(60, 105); e.render(600)
    return e

def sweep(e, hi=127):
    force(e, PRE, 0); e.snap_all(); a0 = rd(e)
    changed = np.zeros(NW, bool); vals = {}
    for v in range(hi + 1):
        force(e, PRE, v); e.snap_all(); av = rd(e); changed |= (av != a0); vals[v] = av
    ws = np.nonzero(changed)[0]
    return {int(w) * 4: [int(vals[v][w]) for v in range(hi + 1)] for w in ws}

def s32(u): return u - (1 << 32) if u >> 31 else u

def main():
    out = {}
    for sr in [44100.0, 48000.0, 88200.0, 96000.0]:
        for cls, rtype in [(0, 0), (1, 1), (2, 2)]:
            e = ctx(sr, rtype); tbl = sweep(e)
            out['%d|%g' % (cls, sr)] = {str(c): v for c, v in tbl.items()}
            cells = sorted(tbl.keys())
            taps = [c for c in cells if TAP0 <= c < TAP0 + 34 * 4]
            other = [c for c in cells if c not in taps]
            print('cls %d @%g: %d changed cells (%d taps, %d other) taps=%s' % (
                cls, sr, len(cells), len(taps), len(other),
                [(c - TAP0) // 4 for c in taps][:12]))
            if other:
                print('   NON-TAP CHANGED CELLS: %s' % other[:12])
                for c in other[:6]:
                    d = tbl[c]
                    print('      cell %d: b0=%08x b20=%08x b100=%08x' % (c, d[0], d[20], d[100]))
            # predelay tap = entry 1 (cell TAP0+4); reveals the byte->samples law
            pc = TAP0 + 4
            if pc in tbl:
                d = tbl[pc]
                print('   predelay tap (cell %d) vs byte: b0=%d b1=%d b10=%d b20=%d b50=%d b100=%d'
                      % (pc, s32(d[0]), s32(d[1]), s32(d[10]), s32(d[20]), s32(d[50]), s32(d[100])))
                # infer coefficient from byte 100 (largest lever): predelay/byte/H
                if d[100] and sr:
                    print('      coef@b100 = predelay/(byte*H) = %.9f' % (s32(d[100]) / (100.0 * sr)))
            sys.stdout.flush()
    json.dump(out, open('/home/user/jn60c99/scratchpad/reverb_predelay.json', 'w'))
    print('wrote reverb_predelay.json')

if __name__ == '__main__':
    main()
