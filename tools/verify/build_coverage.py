#!/usr/bin/env python3
"""PILLAR 1 / Stage A — assemble COVERAGE.tsv + the GAP LIST.

Inputs (all binary-sourced): coverage_leaves.tsv (the plugin's own value-tree
leaf enumeration), leaf_cellmap.pkl (each leaf's written cells, from executing
the plugin's setters), port_writeset.pkl (cells the port's recall writes).
Audio-cell universe = every cell read by voice_render.c / master_render.c
(grep of `a1 + N)`), so scratch/routing writes (cell 120, routing ints) are
excluded from the gap test — only cells that actually reach audio count.

A leaf is:
  APPLIED  — writes >=1 audio cell, all of them in the port's write set
  GAP      — writes an audio cell the port never writes  (the darkness class)
  SILENT   — wrote no audio cell in any tested FX context (needs its activating
             context OR an inert proof — the bucket Pillar 1 must still resolve)
"""
import sys, re, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
SP = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
OUT = '/home/user/jn60c99/COVERAGE.tsv'

# audio-cell universe: cells read by any render source
audio = set()
for fn in ('src/voice_render.c', 'src/master_render.c', 'src/juno_note.c',
           'src/juno_dsp.c', 'src/juno_ramp.c'):
    txt = open('/home/user/jn60c99/' + fn).read()
    for m in re.finditer(r'a1 \+ (\d+)\)', txt):
        audio.add(int(m.group(1)))
# per-voice cells repeat at +v*10512; fold voice-1..7 copies into voice-0 base
STRIDE = 10512
folded = set()
for c in audio:
    folded.add(c)
    if 176 <= c < 176 + STRIDE:
        folded.add(c)  # base already
# also accept any cell whose (c-176)%10512 maps into a read voice-0 offset
def is_audio(cell):
    if cell in audio: return True
    if 176 <= cell < 84272:
        base = 176 + ((cell - 176) % STRIDE)
        return base in audio
    return False

cellmap = pickle.load(open(SP + '/leaf_cellmap.pkl', 'rb'))
port = pickle.load(open(SP + '/port_writeset.pkl', 'rb'))

leaves = {}
for ln in open('/home/user/jn60c99/tools/verify/coverage_leaves.tsv').read().splitlines()[1:]:
    f = ln.split('\t')
    leaves[int(f[1])] = f  # disp -> row

rows = []
for disp in sorted(cellmap):
    info = cellmap[disp]
    row = leaves.get(disp)
    fam = row[2] if row else '?'; struct_ = info['struct']; name = info['name']
    cells = info['cells']
    inport = [c for c in cells if c in port]
    # a cell is a real audio gap if the port never writes it AND render reads it
    missing = [c for c in cells if c not in port and is_audio(c)]
    if missing:
        status, detail = 'GAP', 'missing_audio_cells=' + ','.join(map(str, missing[:8]))
    elif inport:
        status, detail = 'APPLIED', 'port_cells=%d' % len(inport)
    else:
        status, detail = 'SILENT', ('scratch_only=%d' % len(cells)) if cells else 'no_cell'
    rows.append((disp, fam, struct_, name, status, detail))

# Known context-missed gaps (chorus fine-FX: sweep's chorus ctx didn't activate
# the block; ext_sweeps.pkl proved these write 10693xxx). Mark SILENT->GAP-known.
KNOWN_GAP = {1210: 'CHORUS PRE DELAY', 1211: 'CHORUS LOW CUT', 1212: 'CHORUS HIGH CUT'}
for i, (disp, fam, st, nm, status, detail) in enumerate(rows):
    if disp in KNOWN_GAP and status == 'SILENT':
        rows[i] = (disp, fam, st, nm, 'GAP', 'context-missed; ext_sweeps proved cells 10693xxx')

with open(OUT, 'w') as f:
    f.write("# COVERAGE.tsv — Pillar 1 completeness ledger (Stage A first pass)\n")
    f.write("# audio-cell universe = %d render-read offsets; %d value-tree leaves swept\n" % (len(audio), len(cellmap)))
    f.write("# STATUS: APPLIED=port writes all its audio cells (verify laws in Pillar 3);\n")
    f.write("#   GAP=port never writes a render-read cell this leaf writes (FIX these);\n")
    f.write("#   SILENT=wrote no audio cell in tested FX contexts. SILENT is NOT yet\n")
    f.write("#   resolved: it splits into performance features provably outside preset\n")
    f.write("#   audio (PAT3_SEQ_* sequencer, PAT2_CHORD chord-memory) that need an\n")
    f.write("#   INERT proof, and FX leaves (PAT2_FL flanger, PAT2_MFX mode-5, some\n")
    f.write("#   REV/CHO) that need their activating FX-mode context re-swept (the\n")
    f.write("#   chorus cuts proved this: SILENT here, but ext_sweeps shows they DO\n")
    f.write("#   write cells). Ledger is airtight only when SILENT=0 (every row\n")
    f.write("#   APPLIED/GAP/INERT-PROVEN). This first pass delivers the GAP LIST.\n")
    f.write("disp\tfamily\tstruct\tname\tstatus\tdetail\n")
    for disp, fam, st, nm, status, detail in rows:
        f.write("%d\t%s\t%s\t%s\t%s\t%s\n" % (disp, fam, st, nm, status, detail))

from collections import Counter
c = Counter(r[4] for r in rows)
print("COVERAGE.tsv written:", dict(c))
print("\n=== GAP LIST (audio-relevant, port never writes these cells) ===")
for disp, fam, st, nm, status, detail in rows:
    if status == 'GAP':
        print("  disp %4d  %-22s %-9s  %s" % (disp, nm[:22], struct_ if False else fam, detail))
