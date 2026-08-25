#!/usr/bin/env python3
"""fxsweep_ref.py -- ORACLE side: sweep the FX parameters over their WHOLE byte
domain inside a COMPLETE, REAL recall context.

Why this gate exists (playbook 80 + the 2026-08-25 retraction):
  * mutation testing showed a wrong REVERB or DELAY constant SURVIVES every gate
    in `make verify`. COVERAGE.tsv states the cause for reverb outright:
    "render_A/B bit-exact across 58 factory REVERB LEVEL values" -- 58 of 256.
    REVLVL_LUT[0] and [1] are simply never indexed by the factory bank.
  * the fix is NOT another isolated single-leaf sweep. A single leaf dispatched
    from BUILD DEFAULTS omits the extended leaves the plugin's real recall fires
    (DELAY FEEDBACK idx 1179 and friends) -- that incomplete oracle INVENTED a
    defect on 2026-08-25 and had to be retracted.

So: drive the plugin through its OWN complete recall (recall_render_ab's
prepare_recall / apply_recall), with a bank whose ONE FX byte is overwritten,
for every value 0..255. Same engine reused between values (apply_recall is 75x
cheaper than a rebuild); the PORT side repeats the identical sequence, so both
sides see the same history and a wrong constant still shows.

usage: fxsweep_ref.py [out.pkl] [patches=0,4,5]
"""
import sys, os, pickle, struct

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import e2e_emu as E, real_recall as R, recall_render_ab as RA

FX = {794: 'EFFECT DEPTH', 795: 'REVERB LEVEL', 796: 'DELAY LEVEL', 797: 'DELAY TIME'}
VOICE_END = 84096
MEANINGFUL = 11022352


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else \
        os.path.join(os.path.dirname(os.path.dirname(HERE)), 'scratchpad', 'fxsweep.pkl')
    patches = [int(x) for x in (sys.argv[2] if len(sys.argv) > 2 else '0,4,5').split(',')]

    bank = E.bank_bytes()
    leaves = R.leaf_table()
    lt = dict(leaves)
    e = RA.prepare_recall(patches[0], bank, leaves, E, R, RA.SR)
    uc = e.uc

    def fxregion():
        return bytes(uc.mem_read(e.state[0] + VOICE_END, MEANINGFUL - VOICE_END))

    res = {}
    for P in patches:
        rec_off = E.HEADER + P * E.STRIDE
        for idx, name in FX.items():
            bb = lt[idx]
            rows = {}
            for v in range(256):
                b = bytearray(bank)
                # blob byte bb inside record P: the plugin decodes a nibble pair
                base = rec_off + E.BLOB_OFF
                b[base + bb] = (v >> 4) & 0xF
                b[base + bb + 1] = v & 0xF
                RA.apply_recall(e, P, bytes(b), leaves, E, R)
                rows[v] = fxregion()
            # store only the cells that MOVE across the sweep (keeps the pkl small)
            base_row = rows[0]
            moving = set()
            for v in range(1, 256):
                rv = rows[v]
                if rv != base_row:
                    for o in range(0, len(rv), 4):
                        if rv[o:o + 4] != base_row[o:o + 4]:
                            moving.add(o)
            cells = sorted(moving)
            res[(P, idx)] = {
                'bb': bb, 'name': name,
                'cells': cells,
                'table': {o: [struct.unpack('<I', rows[v][o:o + 4])[0] for v in range(256)]
                          for o in cells},
            }
            sys.stderr.write("patch %d %-13s -> %d moving FX cells\n" % (P, name, len(cells)))
            sys.stderr.flush()

    pickle.dump({'rate': RA.SR, 'patches': patches, 'fx': FX, 'res': res,
                 'voice_end': VOICE_END}, open(out, 'wb'))
    tot = sum(len(d['cells']) for d in res.values())
    print("fxsweep ref: %d (patch,param) sweeps, %d moving FX cells total -> %s"
          % (len(res), tot, out))
    return 0


if __name__ == '__main__':
    sys.exit(main())
