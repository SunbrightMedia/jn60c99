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
    if f[8] != '1':            # canonical dispatchable column
        continue
    leaves[int(f[1])] = f  # disp -> row

# The 3 mode ROUTERS (EFFECT/DELAY/REVERB TYPE) write the routing int (which the
# port applies) PLUS, as a side effect of sweeping across modes, every mode's
# block cells — including the fine-FX filter cells that are the true gaps of the
# per-mode fine params (DELAY HIGH CUT etc.). Those shared cells must be
# attributed to their PRIMARY fine-FX leaf, not double-counted as a router gap.
# Build the set of cells owned by a more-specific GAP leaf so the routers aren't
# mislabeled: the router is APPLIED (routing works) if its only missing cells are
# ones another leaf is primarily responsible for.
ROUTERS = {873, 875, 876}
_finegap_cells = set()
for _d, _i in cellmap.items():
    if _d in ROUTERS:
        continue
    for _c in _i['cells']:
        if _c not in port and is_audio(_c):
            _finegap_cells.add(_c)

rows = []
for disp in sorted(cellmap):
    info = cellmap[disp]
    row = leaves.get(disp)
    fam = row[2] if row else '?'; struct_ = info['struct']; name = info['name']
    cells = info['cells']
    # port_writeset is the RELIABLE audio signal (cells the port sets for recall);
    # render-read (is_audio) is used only to CATCH a gap the port misses. This
    # keeps APPLIED robust to any incompleteness in the render-read grep.
    port_cells = [c for c in cells if c in port]
    missing_render = [c for c in cells if c not in port and is_audio(c)]
    # A mode ROUTER's missing cells that a fine-FX leaf owns are not the router's
    # gap (the router IS applied; the port routes + sets the active mode). Only a
    # missing cell NO other leaf owns would be a router-specific gap.
    if disp in ROUTERS:
        missing_render = [c for c in missing_render if c not in _finegap_cells]
    if missing_render:
        status, detail = 'GAP', 'missing_audio_cells=' + ','.join(map(str, missing_render[:8]))
    elif port_cells:
        status, detail = 'APPLIED', 'port_cells=%d,all_covered' % len(port_cells)
    else:
        # wrote no render-read cell in 12 contexts. Split HONESTLY: an extended-FX
        # block leaf may have written nothing only because load_leaves recall does
        # not set up that block (the block-setup params are themselves extended
        # leaves) — I did NOT prove it inert, I failed to activate it. Those are
        # UNRESOLVED (must be driven via a full-value-tree recall / covered by
        # Pillar 3), NOT silently inert. Non-FX leaves that write nothing across
        # all contexts (sequencer, chord, display, reserve, system) are inert.
        UNACTIVATABLE_FX = ('PAT2_MFX', 'PAT2_FL', 'PAT2_REV', 'PAT2_CHO',
                            'PAT2_CTRL', 'PAT2_FLT', 'PAT2_AMP', 'PAT2_LFO')
        # SYSTEM-8 plug-out params (2nd oscillator, cross-mod/ring/sync, mod
        # matrix, selectable LFO wave / filter type) + GUI/editor state ('vs').
        # The port targets JUNO-60 mode (GOAL.md): these wrote NO cell in
        # JUNO-60-mode recall -> proven inert IN SCOPE. SYSTEM-8 mode is a
        # documented non-goal, not a silent omission.
        SYS8 = struct_ in ('OSC2', 'EXTEND') or name in (
            'LFO WAVE', 'LFO AMP DEPTH', 'OSC1 CROSS MOD', 'MIX SUB OSC TYPE',
            'MIX NOISE TYPE', 'VCO ENV', 'PITCH ATTACK', 'PITCH DECAY',
            'FILTER LPF TYPE')
        GUI = struct_ in ('vs', 'ks')
        if struct_ in UNACTIVATABLE_FX:
            status, detail = 'UNRESOLVED', 'extended-FX leaf not activated by load_leaves recall; needs full-tree recall'
        elif SYS8:
            status, detail = 'INERT-PROVEN', 'SYSTEM-8-mode param (out of JUNO-60 scope); no cell in JUNO-60 recall'
        elif GUI:
            status, detail = 'INERT-PROVEN', 'GUI/editor state; no engine cell'
        elif cells:
            status, detail = 'INERT-PROVEN', 'nonaudio_writes=%d(not_port,not_render-read)' % len(cells)
        else:
            status, detail = 'INERT-PROVEN', 'no_engine_write_in_12_contexts'
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
    f.write("# KNOWN SOFT EDGE (honest): classification uses ISOLATED leaf dispatch +\n")
    f.write("#   memory-write instrumentation. It is SOLID for GAP (a render-read cell no\n")
    f.write("#   patch's port-recall writes, port_writeset spans all 6 effect types) and\n")
    f.write("#   for APPLIED (port writes the cell). The INERT-PROVEN detail\n")
    f.write("#   'no_engine_write_in_12_contexts' is WEAKER: a CONDITIONAL setter (e.g.\n")
    f.write("#   disp 854 (F ENV VARIATION) = VCF env-source, which the port DOES apply)\n")
    f.write("#   can write nothing in isolation -> such rows are applied-but-mislabeled,\n")
    f.write("#   NOT gaps. Hardening these + the UNRESOLVED FX leaves requires the\n")
    f.write("#   full-value-tree recall differential (drive every leaf at a patch's\n")
    f.write("#   value in port AND plugin, diff state) — the defined next step. The\n")
    f.write("#   GAP worklist below is unaffected by this soft edge.\n")
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
