#!/usr/bin/env python3
"""LANE E: does the plugin's note-OFF arm the DCO-retrigger latch (Array A,
101504+32v) the way src/juno_note.c does? At power-on Array A is already 1.0 for
every voice, so a write of 1.0 is invisible. Render first to CONSUME the latches
(they go to 0), then note-off, then look."""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA

PATCH = int(os.environ.get('JUNO_PATCH', '3')); SR = 48000.0
bank = E.bank_bytes(); leaves = R.leaf_table()
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR)

def aux(u):
    return [struct.unpack('<f', e.uc.mem_read(e.state[u] + 101504 + 32*v, 4))[0] for v in range(8)]
def auxB(u):
    return [struct.unpack('<f', e.uc.mem_read(e.state[u] + 101520 + 32*v, 4))[0] for v in range(8)]
def gate(u):
    return [struct.unpack('<f', e.uc.mem_read(e.state[u] + 10512*v + 320, 4))[0] for v in range(8)]

steps = []
steps.append(('recalled', aux(7), auxB(7), gate(7)))
e.note_on(60, 100);  steps.append(('noteOn(60)', aux(7), auxB(7), gate(7)))
e.render(64, block=64); steps.append(('render 64', aux(7), auxB(7), gate(7)))
e.note_off(60, 64);  steps.append(('noteOff(60)', aux(7), auxB(7), gate(7)))
e.render(64, block=64); steps.append(('render 64', aux(7), auxB(7), gate(7)))
e.note_on(62, 100);  steps.append(('noteOn(62)', aux(7), auxB(7), gate(7)))
for lbl, a, b, g in steps:
    print("%-12s A=%s" % (lbl, ['%g' % x for x in a]))
    print("%-12s B=%s" % ('',   ['%g' % x for x in b]))
    print("%-12s G=%s" % ('',   ['%g' % x for x in g]))
