#!/usr/bin/env python3
"""gen_devcells.py -- generate engine_b/dev/ebdev_seg.h and ebdev_map.h.

The device does not carry the port's 11 MB cell array. It carries ONE voice
tile, a handful of dense segments, and a per-voice SCATTER of the cells that
are genuinely voice-distinct. `ebdev_at(off)` maps a port cell offset into
that array.

TWO THINGS THIS GENERATOR MUST GET RIGHT, and both are load-bearing:

1. THE MAP IS EMITTED AS A LITERAL BINARY-SEARCH CHAIN, NOT AS A LOOP OVER A
   TABLE. At a compile-time-constant offset -- which is what almost every
   recall site is -- GCC folds the whole chain to a single load. MEASURED on
   xtensa-esp-elf-gcc -O2: `entry / l32r / l32i / retw.n` = 4 instructions,
   the same code a flat array would give. The array-loop form does NOT fold:
   27 instructions and 14.2 probes. That is why this file exists at all.

2. THE PER-VOICE SCATTER IS TWELVE CELLS, NOT FIVE. The five the first design
   carried are the RECALL-time per-voice cells. The NOTE PATH writes seven
   more (src/juno_note.c: 304 pitch, 320 gate, 592 porta gate, 1856 held,
   6864 VCF velocity, 9680 VCA velocity, 9824 gate twin) and SIX of those are
   read back per voice by eb_render_coefs_build. With a shared tile every
   sounding voice takes the LAST note's pitch and velocity, and cell 320 --
   the ADSR gate, read every sample at engine_b/eb_render.c:484 -- is not
   addressable for voices 1..N at all. That is defect 2, and it is why the
   scatter list lives here and is generated rather than typed.

WHY A SCATTER AND NOT A DENSE PER-VOICE TILE. Asked, and measured: the twelve
offsets span [304, 10324), i.e. 10,020 bytes to hold 48 bytes of data (0.5 %
dense). The smallest prefix tile covering them is the whole 10,688-byte voice
block. Six voices of that is 64,128 bytes against the scatter's 288. A dense
tile is not available at these offsets; it is not a simplicity-versus-size
trade, it is a 220x one.

INPUTS (all checked in, all under docs/engineb/data/devrecall/):
    touched.txt        the 2026-08-11 executed recall trace, 343 cells
    cells_gate.txt     what THIS gate measured with notes, warm sequences and
                       the synthetic bank -- the aux retrigger array and the
                       slot-2 EFFECT block. Read its header.
    static_extra.txt   the static constant scan's extra candidates
    cells_legacy.txt   14 segments with no provenance -- read its header

The gate is the arbiter of completeness, not this script: `ebdev_at` counts
every offset it cannot place and the gate fails on a non-zero count.
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
DATA = os.path.join(REPO, 'docs', 'engineb', 'data', 'devrecall')
OUT = os.path.join(REPO, 'engine_b', 'dev')

VOICE_STRIDE = 10512          # src/juno_engine.h JUNO_VOICE_MAIN_STRIDE
VOICE_LO = 176                # first per-voice cell (juno_apply/eb_coefs)
VOICE_HI = 84272              # first non-voice cell; 176 + 8*10512
VTILE = 10688                 # one voice block, rounded up past cell 10672

# The per-voice SCATTER. Offsets are voice-block-relative.
#   recall-written, all 8 voices (src/juno_apply.c):
#     1072  LFO tempo baseline      :622,:815
#     3968  UNISON spread           :504
#     5520  CONDITION tune          :480
#     7600  CONDITION fine          :481
#    10320  CONDITION gain          :482
#   note-written (src/juno_note.c), added 2026-08-11 -- DEFECT 2:
#      304  pitch CV                :160,:274   -> eb_coefs.c:264
#      320  ADSR gate               :164,:249   -> eb_coefs.c:351,:371
#                                                  eb_render.c:484 every sample
#      592  glide / portamento gate :305        -> eb_coefs.c:218
#     1856  any-key-held            :200,:225   -> eb_coefs.c:232
#     6864  VCF velocity            :196,:320   -> eb_coefs.c:58
#     9680  VCA velocity            :197,:321   -> eb_coefs.c:92
#     9824  gate twin               :201,:306   -> eb_coefs.c:93
SCATTER = [304, 320, 592, 1072, 1856, 3968, 5520, 6864, 7600, 9680, 9824, 10320]

# The aux DCO-retrigger latch at 101504+32v is NOT here: all eight voices'
# copies already live inside the non-voice segment [101024,102804).


def read_offsets(path):
    out = set()
    with open(path) as f:
        for line in f:
            line = line.split('#', 1)[0].strip()
            if line:
                out.add(int(line))
    return out


def segments(offs, gap, width=4):
    """Coalesce sorted offsets into [lo,hi) runs, merging across <= gap."""
    segs = []
    for o in sorted(offs):
        if segs and o - segs[-1][1] <= gap:
            segs[-1][1] = o + width
        else:
            segs.append([o, o + width])
    return [(a, b) for a, b in segs]


def emit_chain(segs, out, depth=0):
    """Literal binary-search chain over [lo,hi) -> sg+at. Folds at -O2."""
    pad = '    ' * (depth + 3)
    if len(segs) == 1:
        lo, hi, at = segs[0]
        out.append('%sif (off >= %uu && off < %uu) '
                   'return EBDEV_S.sg + %uu + (off - %uu); \\' % (pad, lo, hi, at, lo))
        out.append('%sgoto miss; \\' % pad)
        return
    mid = len(segs) // 2
    pivot = segs[mid][0]
    out.append('%sif (off < %uu) { \\' % (pad, pivot))
    emit_chain(segs[:mid], out, depth + 1)
    out.append('%s} else { \\' % pad)
    emit_chain(segs[mid:], out, depth + 1)
    out.append('%s} \\' % pad)


def emit_scat_chain(sc, out, depth=0):
    """Literal chain mapping a VOICE-0 constant offset to &scat[0][i]."""
    pad = '    ' * (depth + 3)
    if len(sc) == 1:
        off, i = sc[0]
        out.append('%sif (off == %uu) return &EBDEV_S.scat[0][%d]; \\' % (pad, off, i))
        return
    mid = len(sc) // 2
    out.append('%sif (off < %uu) { \\' % (pad, sc[mid][0]))
    emit_scat_chain(sc[:mid], out, depth + 1)
    out.append('%s} else { \\' % pad)
    emit_scat_chain(sc[mid:], out, depth + 1)
    out.append('%s} \\' % pad)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--gap', type=int, default=256,
                    help='coalesce cells closer than this into one segment')
    ap.add_argument('--out', default=OUT)
    ap.add_argument('--no-legacy', action='store_true',
                    help='drop the 14 unprovenanced segments (see cells_legacy.txt)')
    ap.add_argument('--check', action='store_true',
                    help='regenerate into memory and fail if the files differ')
    ap.add_argument('--drop-seg', type=int, default=-1, metavar='LO',
                    help='TOOTH: delete the segment starting at byte offset LO. '
                         'Used by devrecall_gate.py to measure which segments '
                         'the scenario set can actually reach.')
    ap.add_argument('--shift-seg', default='', metavar='LO:DELTA',
                    help='TOOTH: move the segment starting at LO by DELTA bytes '
                         'in the PORT address space. The 2026-08-11 gate\'s '
                         'first tooth. Both halves rebuild against it, so what '
                         'it perturbs is the map and not the exchange format.')
    a = ap.parse_args()

    touched = read_offsets(os.path.join(DATA, 'touched.txt'))
    static = read_offsets(os.path.join(DATA, 'static_extra.txt'))
    legacy = set() if a.no_legacy else read_offsets(os.path.join(DATA, 'cells_legacy.txt'))
    gatemeas = read_offsets(os.path.join(DATA, 'cells_gate.txt'))
    allcells = touched | static | legacy | gatemeas

    voice = sorted(o for o in allcells if o < VOICE_HI)
    nonvoice = sorted(o for o in allcells if o >= VOICE_HI)

    # Every per-voice cell must fall inside the tile. If one does not, the tile
    # is wrong and the map would silently sink it.
    for o in voice:
        k = o if o < VOICE_LO else (o - VOICE_LO) % VOICE_STRIDE + VOICE_LO
        if k >= VTILE:
            sys.exit('cell %d folds to %d, outside the %d-byte tile' % (o, k, VTILE))

    segs = segments(nonvoice, a.gap)
    if a.drop_seg >= 0:
        before = len(segs)
        segs = [s for s in segs if s[0] != a.drop_seg]
        if len(segs) == before:
            sys.exit('--drop-seg %d: no segment starts there' % a.drop_seg)
    if a.shift_seg:
        lo0, d = (int(x) for x in a.shift_seg.split(':'))
        if not any(s[0] == lo0 for s in segs):
            sys.exit('--shift-seg: no segment starts at %d' % lo0)
        segs = [((lo + d, hi + d) if lo == lo0 else (lo, hi)) for lo, hi in segs]
        segs.sort()
    placed, at = [], 0
    for lo, hi in segs:
        placed.append((lo, hi, at))
        at += hi - lo
    segbytes = at

    seg_h = []
    seg_h.append('/* GENERATED by tools/engineb/gen_devcells.py -- DO NOT EDIT. */')
    seg_h.append('/* union of docs/engineb/data/devrecall/')
    seg_h.append(' *   touched.txt static_extra.txt cells_gate.txt cells_legacy.txt */')
    seg_h.append('#ifndef EBDEV_SEG_H')
    seg_h.append('#define EBDEV_SEG_H')
    seg_h.append('#define EBDEV_VTILE   %uu' % VTILE)
    seg_h.append('#define EBDEV_VSTRIDE %uu' % VOICE_STRIDE)
    seg_h.append('#define EBDEV_VLO     %uu' % VOICE_LO)
    seg_h.append('#define EBDEV_VHI     %uu' % VOICE_HI)
    seg_h.append('#define EBDEV_NSEG %d' % len(placed))
    seg_h.append('#define EBDEV_SEGBYTES %uu' % segbytes)
    seg_h.append('#define EBDEV_NSCAT %d' % len(SCATTER))
    seg_h.append('typedef struct { unsigned lo, hi, at; } ebdev_seg;')
    seg_h.append('/* The TABLE is the reference form. ebdev.c uses the literal chain in')
    seg_h.append(' * ebdev_map.h for the real lookup and, under -DEBDEV_INSTRUMENT, checks')
    seg_h.append(' * the chain against this table on every access. A generator that emits')
    seg_h.append(' * a chain disagreeing with its own table is the failure this catches. */')
    seg_h.append('static const ebdev_seg EBDEV_SEGTAB[EBDEV_NSEG] = {')
    for lo, hi, at in placed:
        seg_h.append('  { %uu, %uu, %uu },' % (lo, hi, at))
    seg_h.append('};')
    seg_h.append('static const unsigned EBDEV_SCATTAB[EBDEV_NSCAT] = {')
    seg_h.append('  ' + ', '.join('%uu' % s for s in SCATTER))
    seg_h.append('};')
    seg_h.append('#endif')
    seg_txt = '\n'.join(seg_h) + '\n'

    body = []
    emit_chain(placed, body)
    sc = sorted((s, i) for i, s in enumerate(SCATTER))
    sbody = []
    emit_scat_chain(sc, sbody)
    sbody.append('            ' + 'goto tile; \\')

    map_h = []
    map_h.append('/* GENERATED by tools/engineb/gen_devcells.py -- DO NOT EDIT.')
    map_h.append(' *')
    map_h.append(' * LITERAL binary-search chains. At a compile-time-constant offset GCC')
    map_h.append(' * folds each of these to ONE load -- MEASURED at 4 Xtensa instructions')
    map_h.append(' * (entry / l32r / l32i / retw.n). An array loop over EBDEV_SEGTAB does')
    map_h.append(' * NOT fold and costs 27 instructions. Do not "simplify" this into a loop.')
    map_h.append(' */')
    map_h.append('#ifndef EBDEV_MAP_H')
    map_h.append('#define EBDEV_MAP_H')
    map_h.append('')
    map_h.append('/* voice-0 scatter: a constant offset inside the tile that is per-voice */')
    map_h.append('#define EBDEV_SCAT0_BODY \\')
    map_h.extend(sbody)
    map_h.append('')
    map_h.append('/* the non-voice segments */')
    map_h.append('#define EBDEV_MAP_BODY \\')
    map_h.extend(body)
    map_h.append('')
    map_h.append('#endif')
    map_txt = '\n'.join(map_h) + '\n'

    files = {'ebdev_seg.h': seg_txt, 'ebdev_map.h': map_txt}
    if a.check:
        bad = 0
        for name, txt in files.items():
            p = os.path.join(a.out, name)
            cur = open(p).read() if os.path.exists(p) else None
            if cur != txt:
                print('STALE: %s' % p)
                bad = 1
        if bad:
            sys.exit(1)
        print('gen_devcells --check: up to date')
        return

    os.makedirs(a.out, exist_ok=True)
    for name, txt in files.items():
        with open(os.path.join(a.out, name), 'w') as f:
            f.write(txt)

    nv = 6
    hdr = 16
    print('cells: %d touched + %d static + %d gate-measured + %d legacy -> %d distinct'
          % (len(touched), len(static), len(gatemeas), len(legacy), len(allcells)))
    print('voice cells %d (tile %u B)   non-voice %d -> %d segments, %u B'
          % (len(voice), VTILE, len(nonvoice), len(placed), segbytes))
    print('scatter: %d cells/voice = %d B at NV=6, %d B at NV=8'
          % (len(SCATTER), len(SCATTER) * 4 * 6, len(SCATTER) * 4 * 8))
    for n in (6, 8):
        print('  ebdev_state at NV=%d: %d B'
              % (n, VTILE + segbytes + len(SCATTER) * 4 * n + hdr))
    print('wrote %s/ebdev_seg.h and ebdev_map.h' % a.out)
    del nv, hdr


if __name__ == '__main__':
    main()
