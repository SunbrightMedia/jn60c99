#!/usr/bin/env python3
"""frozen_triage.py -- triage the port's frozen recall cells (reconstruction-free).

Combines three PROVEN, executed artifacts (pure pickle analysis here):
  index_cell_map.pkl  : complete setter index -> cells (index_cell_map.py)
  param_cell_map.pkl  : value-tree param_id -> (index, cells) (param_cell_map.py)
                        -> its index set = the indices reachable by the apply node
  port_state.pkl      : port unit-0 block per patch (port_state_dump.py)

Produces the recall-correctness picture for voice-0 cells:
  - CORRECT   : port varies a cell the plugin can write (port recalls it).
  - FROZEN-OK : port freezes a cell whose index is NOT in the value-tree param
                map -> the recall cannot emit it -> freeze is provably correct.
  - CANDIDATE : port freezes a cell whose index IS value-tree-reachable -> the
                recall MIGHT emit it -> the port may be dropping a real recall.
                (necessary, not sufficient: the recall emits a SUBSET = the tree
                leaf set; the host-mediated recall agent gives the final answer.)
  - SPURIOUS  : port varies a cell no plugin index writes -> port bug. (expect 0.)

Caveat: a param recalled via the setProgram worker path (0x3c7400, ~2 params)
rather than the apply node would not show as map-reachable; minor, noted.
"""
import struct, pickle

ICM  = '/home/user/jn60c99/scratchpad/index_cell_map.pkl'    # {index: [cells]}
PCM  = '/home/user/jn60c99/scratchpad/param_cell_map.pkl'    # {pid: (index, [cells])}
PORT = '/home/user/jn60c99/scratchpad/port_state.pkl'        # {patch: bytes(VOICE)}
VOICE = 10512
STRIDE = 16

NAMES = {760: 'DCO RANGE feet', 759: 'LFO cluster', 752: 'LFO rate', 756: 'LFO keytrig',
         751: 'LFO variation', 753: 'DCO LFO mod', 754: 'VCF LFO mod', 758: 'PWM depth',
         1058: 'VCA', 779: 'VCF cutoff', 771: 'DCO saw', 772: 'DCO sub', 773: 'DCO noise'}


def main():
    icm = pickle.load(open(ICM, 'rb'))
    pcm = pickle.load(open(PCM, 'rb'))
    port = pickle.load(open(PORT, 'rb'))
    map_indices = {idx for (idx, cells) in pcm.values()}

    # cell -> indices that write it (voice-0)
    cell_idx = {}
    for idx, cells in icm.items():
        for off in cells:
            if off < VOICE:
                cell_idx.setdefault(off, []).append(idx)
    plugin_cells = set(cell_idx)

    patches = sorted(port)
    varied = set()
    for off in range(0, VOICE, STRIDE):
        vals = {struct.unpack('<I', port[p][off:off + 4])[0] for p in patches}
        if len(vals) > 1:
            varied.add(off)

    correct  = sorted(plugin_cells & varied)
    spurious = sorted(varied - plugin_cells)
    frozen   = sorted(plugin_cells - varied)

    def reach(off):
        return any(i in map_indices for i in cell_idx[off])
    candidate = [c for c in frozen if reach(c)]
    frozen_ok = [c for c in frozen if not reach(c)]

    print("=== recall-correctness triage (voice-0, %d patches) ===" % len(patches))
    print("CORRECT  (port recalls, plugin can write): %d" % len(correct))
    print("SPURIOUS (port varies, no plugin index)  : %d  %s" % (len(spurious), spurious))
    print("FROZEN-OK (freeze provably correct)       : %d  %s" % (len(frozen_ok), frozen_ok))
    print("CANDIDATE (port may drop a real recall)   : %d" % len(candidate))
    for off in candidate:
        idxs = cell_idx[off]
        lbl = "/".join(NAMES.get(i, '') for i in idxs if NAMES.get(i))
        print("   cell %5d  <- idx %-16s %s" % (off, ",".join(map(str, idxs)), lbl))
    print("\nNext: the host-recall agent determines which CANDIDATE indices the")
    print("plugin's real recall actually emits -> those are the true port bugs.")


if __name__ == '__main__':
    main()
