#!/usr/bin/env python3
"""jp8_fw_near.py -- where a JUNO-60 wrapper function's NEAREST twin sits in the JUPITER-8 image (READ, static), for the
functions fw_map.py finds no EQUAL twin of (another version of the framework: jp8/logs/fw_map_jp8.log).

Each function is reduced to fw_map's normalized instruction stream (rip-relative operands, branch targets and image
addresses masked); every JUPITER-8 function within 0.6x..1.7x of the JUNO function's size is scored by
difflib.SequenceMatcher on the two streams, and the best three are printed. A candidate is a lead to READ, not a
proof: the port lifts what the oracle runs, and the oracle names the function by running it.

Its own check (the matcher must find what is known): every function of fw_map's table whose JUPITER-8 twin is known
-- equal (fw_map) or named by the host oracle (jp8_host_emu.PROFILE / HOST_LAYER.md) -- must rank first.
    python3 jp8/tools/jp8_fw_near.py [name=JUNO_RVA ...]       default: fw_map's table
    python3 jp8/tools/jp8_fw_near.py --check [--tooth]         the known pairs must rank first (exit 1 if not);
                                                               --tooth expects GetPluginFactory one byte off: must fail
"""
import difflib
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'jx3p', 'tools'))
import fw_map as F                                     # noqa: E402

JP8 = os.path.join(REPO, 'jp8', 'truth', 'JUPITER-8VST3_64bit.vst3')
# known twins (rva in the JUPITER-8): fw_map's equal ones and those the host oracle names (jp8_host_emu.PROFILE)
KNOWN = {0x348B40: 0x36A700, 0x349EA0: 0x36BA50, 0x34AA50: 0x36C600, 0x34A380: 0x36BF30, 0x3CB150: 0x449EE0,
         0x321AC0: 0x33BC30, 0x3208E0: 0x33AA50, 0x343A80: 0x365310, 0x343E30: 0x3656C0, 0x344280: 0x365B10,
         0x34B260: 0x36CDF0, 0x3C7A20: 0x4464F0, 0x3BE2F0: 0x43C310,
         0x349CA0: 0x36B860,          # createInstance (processor): PROFILE CREATE_PROC
         0x320120: 0x33A290,          # the UI-timer drain (SCOPE_AUDIT row 14: rva 0x33A290)
         0x335850: 0x355F90}          # the patch load: PROFILE PATCH_LOAD


def main():
    a = sys.argv[1:]
    check = '--check' in a
    names = [x for x in a if '=' in x]
    table = [(n.split('=')[0], int(n.split('=')[1], 16)) for n in names] or F.TABLE
    if check:
        table = [(n, r) for n, r in F.TABLE if r in KNOWN]
        if '--tooth' in a:
            KNOWN[0x348B40] += 1
    j, t = F.load(F.JUNO), F.load(JP8)
    jimg, jib, jf = j
    timg, tib, tf = t
    jend = {b: e for b, e in jf}
    tseq = {}
    bad = 0
    for name, rva in table:
        if rva not in jend:
            print('  %-32s JUNO 0x%06X: no unwind entry (a leaf) -- skipped' % (name, rva)); continue
        js = F.norm(jimg, jib, rva, jend[rva])
        size = jend[rva] - rva
        cands = []
        for b, e in tf:
            if not (0.6 * size <= e - b <= 1.7 * size):
                continue
            ts = tseq.get(b)
            if ts is None:
                ts = tseq[b] = F.norm(timg, tib, b, e)
            sm = difflib.SequenceMatcher(None, js, ts, autojunk=False)
            if sm.real_quick_ratio() < 0.5 or sm.quick_ratio() < 0.5:
                continue
            cands.append((sm.ratio(), b))
        cands.sort(reverse=True)
        top = cands[:3]
        known = KNOWN.get(rva)
        mark = ''
        if known is not None:
            ok = bool(top) and top[0][1] == known
            mark = '  known 0x%06X: %s' % (known, 'FIRST' if ok else 'NOT FIRST')
            bad += not ok
        print('  %-32s JUNO 0x%06X (%d bytes) -> %s%s' % (name, rva, size,
              ', '.join('0x%06X %.3f' % (b, r) for r, b in top) or 'no candidate', mark), flush=True)
    if check:
        print('jp8_fw_near --check: %s' % ('every known pair ranks first' if not bad else '%d known pairs NOT first' % bad))
        sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
