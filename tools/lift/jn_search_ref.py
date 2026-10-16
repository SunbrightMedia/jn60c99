#!/usr/bin/env python3
"""jn_search_ref.py -- L6 ORACLE side of one search seed: the host oracle booted and set up as junoh_init does, then the
seeded plan (jn_search_seq.plan) through jn_ops.OracleOps; after EVERY op the end-state digest (image + heap + host
arena), the heap / arena tops and any output words. A C++ throw ends the plan (both sides must throw at the same op);
an oracle failure ends it as 'oracle_error' (a limit of the harness, reported, never counted as clean).
Unicorn only (two-process rule). usage: python3 tools/lift/jn_search_ref.py <outdir> <seed | midi> [nops]
(midi: L5's fixed MIDI-controller drive, jn_search_seq.plan_midi)"""
import sys
import os
import json
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402
import truth                                                       # noqa: E402
import jn_search_seq as S                                          # noqa: E402
import jn_ops                                                      # noqa: E402


def main():
    out = sys.argv[1]
    nops = int(sys.argv[3]) if len(sys.argv) > 3 else 120
    if sys.argv[2] == 'midi':                                     # L5's MIDI-controller drive (a fixed plan)
        seed, plan = -1, S.plan_midi()
    else:
        seed = int(sys.argv[2]); plan = S.plan(seed, nops)
    os.makedirs(out, exist_ok=True)
    t0 = time.time()
    h = H.HostProcess()
    h.start(48000.0, 512)
    ops = jn_ops.OracleOps(h, open(truth.BANK, 'rb').read())
    rows, words, end = [], bytearray(), 'complete'
    for k, op in enumerate(plan):
        try:
            status, w = ops.run(op)
        except Exception as e:                                    # the oracle could not run it: a harness limit
            rows.append(dict(k=k, status='oracle_error', error=str(e)[:300]))
            end = 'oracle_error'
            break
        d, ht, cn = ops.digest()
        rows.append(dict(k=k, status=status, digest=d, heap_top=ht, com_next=cn, woff=len(words), wlen=len(w)))
        words += w
        if status == 'throw':
            end = 'throw'
            break
    open(os.path.join(out, 'words.bin'), 'wb').write(bytes(words))
    meta = dict(seed=seed, nops=nops, plan=plan, rows=rows, end=end, bank=truth.BANK, layout=ops.layout(),
                secs=round(time.time() - t0, 1))
    with open(os.path.join(out, 'meta.json.partial'), 'w') as f:
        json.dump(meta, f)
    os.replace(os.path.join(out, 'meta.json.partial'), os.path.join(out, 'meta.json'))
    print('search ref seed %d: %d ops (%s) in %.0fs -> %s' % (seed, len(rows), end, time.time() - t0, out))


if __name__ == '__main__':
    main()
