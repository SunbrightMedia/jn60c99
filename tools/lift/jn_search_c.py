#!/usr/bin/env python3
"""jn_search_c.py -- L6 C side of one search seed: the lifted JUNO host (libjunohost.so) booted with junoh_init, then
the SAME plan the oracle ran (read from its meta.json) through jn_ops.LiftOps; after EVERY op the status (ok / throw),
the end-state digest, the heap / arena tops and the output words are compared with the oracle's row. The first
difference names its op. ctypes only (two-process rule). A tooth (--tooth) raises the first note-on's pitch (or the
first editor value) by one: the search MUST report a divergence.
exit 0 clean, 1 divergence, 3 the oracle stopped early (oracle_error: not a lift result).
usage: python3 tools/lift/jn_search_c.py <so> <template> <refdir> [--tooth]"""
import ctypes
import sys
import os
import json

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import jn_ops                                                      # noqa: E402


def perturb(plan):
    """the tooth: the first note-on one semitone up, else the first editor value one higher"""
    for op in plan:
        if op[0] == 'proc':
            for e in op[2]:
                if e[0] == 'on':
                    e[3] = (e[3] + 1) & 127
                    return 'note-on pitch +1 at an op'
    for op in plan:
        if op[0] == 'model':
            op[2] = op[2] + 1
            return 'editor value +1'
    return None


def main():
    so, tmpl, refdir = sys.argv[1], sys.argv[2], sys.argv[3]
    tooth = '--tooth' in sys.argv
    meta = json.load(open(os.path.join(refdir, 'meta.json')))
    ref_words = open(os.path.join(refdir, 'words.bin'), 'rb').read()
    plan = meta['plan']
    what = perturb(plan) if tooth else None
    lib = ctypes.CDLL(so)
    lib.junoh_init.restype = ctypes.c_int
    lib.junoh_init.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_double, ctypes.c_int]
    lib.junoh_error.restype = ctypes.c_char_p
    t = open(tmpl, 'rb').read()
    b = ctypes.create_string_buffer(t, len(t))
    if lib.junoh_init(b, len(t), 48000.0, 512):
        print('search seed %d: junoh_init failed: %s' % (meta['seed'], lib.junoh_error().decode('latin1', 'replace')))
        return 1
    ops = jn_ops.LiftOps(lib, open(meta['bank'], 'rb').read(), meta['layout'])
    for row in meta['rows']:
        k = row['k']; op = plan[k]
        if row['status'] == 'oracle_error':
            if tooth:
                print('TOOTH inconclusive: the oracle stopped at op %d before a difference' % k); return 1
            print('search seed %d: the oracle stopped at op %d (%s) -- %d ops compared, all equal'
                  % (meta['seed'], k, row['error'][:120], k)); return 3
        try:
            status, w = ops.run(op)
        except Exception as e:
            if tooth:
                print('TOOTH bit (%s): the lift failed at op %d (%s)' % (what, k, op[0])); return 0
            print('search seed %d DIVERGES at op %d %s: the lift failed where the oracle ran: %s'
                  % (meta['seed'], k, json.dumps(op)[:200], str(e)[:300])); return 1
        d, ht, cn = ops.digest()
        if os.environ.get('JN_DUMP_AT') == str(k):                # a divergence's diff: the regions after op k
            ops.dump(os.path.join(os.environ.get('JN_DUMP_DIR', refdir), 'c_%d' % k))
        diffs = [n for n, a, bb in (('status', status, row['status']), ('digest', d, row['digest']),
                                    ('heap_top', ht, row['heap_top']), ('com_next', cn, row['com_next']),
                                    ('words', w, ref_words[row['woff']:row['woff'] + row['wlen']])) if a != bb]
        if diffs:
            if tooth:
                print('TOOTH bit (%s): divergence at op %d (%s): %s' % (what, k, op[0], ', '.join(diffs))); return 0
            print('search seed %d DIVERGES at op %d %s: %s' % (meta['seed'], k, json.dumps(op)[:200], ', '.join(diffs)))
            return 1
    if tooth:
        print('TOOTH DID NOT BITE (%s): every op equal' % what); return 1
    print('search seed %d: CLEAN -- %d ops (%s), every op\'s state, digest, tops and words equal the oracle'
          % (meta['seed'], len(meta['rows']), meta['end']))
    return 0


if __name__ == '__main__':
    sys.exit(main())
