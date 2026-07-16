#!/usr/bin/env python3
"""plugin_recall_ref.py -- the self-proven plugin recall reference (voice-0).

For every patch, build the plugin's recalled engine state from the plugin's OWN
pieces only:
  - index set   = the plugin's own recall enumerator 0x3B48A0 (executed)
  - blob values = the plugin's own parser 0x330ED0 (executed) at the Script.xml-
                  validated leaf positions (real_recall.leaf_table, 563/577 desc-matched)
  - apply       = the plugin's own setter 0x3B9A30 via e.dispatch (executed)
Only the front-panel recall set (indices present in leaf_table) is applied here;
that is what the port's voice-0 block covers. Output: {patch: bytes(10512)}.

Two-process rule: E2E/Unicorn only. Diff vs the port side (port_state.pkl) is a
separate pickle-only step (plugin_recall_diff.py).
"""
import sys, pickle
sys.path.insert(0, 'tools/verify')
import e2e_emu as E
import real_recall as RR
import real_bank_parse as RB
import plugin_recall_set as PRS

PKL = '/home/user/jn60c99/scratchpad/plugin_recall_ref.pkl'
BLOCK = 10512


def main():
    print("recovering plugin recall index set (0x3B48A0)...")
    recall_idx = set(PRS.recall_indices())            # executed enumerator
    lt = dict(RR.leaf_table())                        # index -> blob position (validated)
    fp = sorted(i for i in recall_idx if i in lt)     # front-panel recalled indices
    print("recall set: %d indices; front-panel (in leaf_table): %d" % (len(recall_idx), len(fp)))
    print("  incl 751-760:", [i for i in fp if 751 <= i <= 760])

    recs = RB.parse_records(E.bank_bytes())           # plugin parser, 64 records

    e = E.E2E(); e.build(48000.0)                      # one build; every patch overwrites the same cells
    ref = {}
    for patch in range(64):
        rec = recs[patch]
        for idx in fp:
            e.dispatch(0, idx, RB.record_value(rec, lt[idx]))
        ref[patch] = bytes(e.uc.mem_read(e.state[0], BLOCK))
        if patch % 16 == 0:
            sys.stderr.write("  patch %d done\n" % patch); sys.stderr.flush()
    pickle.dump(ref, open(PKL, 'wb'))
    print("saved plugin recall reference (voice-0, 64 patches) -> %s" % PKL)


if __name__ == '__main__':
    main()
