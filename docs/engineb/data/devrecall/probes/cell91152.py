#!/usr/bin/env python3
"""Targeted: cell 91152 (chorus block-A LFO rate, read EVERY SAMPLE by
master_render.c:2783) across cold and warm plugin recalls.

Port behaviour (src/chorus_recall.c:70-76): 91152 is written ONLY when
EFFECT TYPE == 3.  So after 12 (ET 3) -> 13 (ET 2) the port keeps chorus II's
rate while running chorus I.  What does the PLUGIN do?
"""
import sys, struct, gc
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R
from warm_plugin import recall_into, build_engine

SR = 44100.0
OFFS = [91120, 91152, 91168, 91184, 91200, 91216, 91232]
bank = E.bank_bytes(); leaves = R.leaf_table()


def cells(e):
    return {o: struct.unpack('<f', e.uc.mem_read(e.state[8] + o, 4))[0] for o in OFFS}


def show(tag, e):
    c = cells(e)
    print('%-24s ' % tag + '  '.join('%d=%.8g' % (o, c[o]) for o in OFFS))
    sys.stdout.flush()


for seq in ([12], [13], [12, 13], [13, 12]):
    e = build_engine(SR)
    for p in seq:
        recall_into(e, p, bank, leaves, 'enum')
    show('recall ' + '->'.join(str(p) for p in seq), e)
    del e; gc.collect()

# does dispatching EFFECT TYPE=2 alone rewrite 91152 after a mode-3 recall?
e = build_engine(SR)
recall_into(e, 12, bank, leaves, 'enum')
show('after 12 (ET3)', e)
for u in range(9):
    e.dispatch(u, 873, 2)
show('  + dispatch 873 <- 2', e)
for u in range(9):
    e.dispatch(u, 873, 3)
show('  + dispatch 873 <- 3', e)
print('0.96/44100 = %.8g   (juno_prepare.c:111 default)' % (0.96 / 44100.0))
