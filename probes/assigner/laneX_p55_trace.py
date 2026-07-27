#!/usr/bin/env python3
"""What does the plugin ACTUALLY leave in every voice's 592 / 9824 / 320 across a
LEGATO+PORTA note sequence? Measured, not inferred from the decompiler (which
dropped the value argument of the else-branch 467+v setter call)."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA
SR, P = 44100.0, 55
bank = E.bank_bytes(); leaves = R.leaf_table()
e = RA.prepare_recall(P, bank, leaves, E, R, SR)
def g(v, c):
    return struct.unpack('<f', e.uc.mem_read(e.state[v] + c + v*10512, 4))[0]
def show(t):
    print("  %-24s 592 %s" % (t, [g(v, 592) for v in range(8)]))
    print("  %-24s 9824 %s" % ("", [g(v, 9824) for v in range(8)]))
    print("  %-24s 320 %s" % ("", [g(v, 320) for v in range(8)]))
show("after recall")
e.note_on(60, 100);  show("note_on 60")
e.render(3000, block=512)
e.note_on(67, 100);  show("note_on 67")
e.render(3000, block=512)
e.note_off(60);      show("note_off 60")
e.render(3000, block=512)
e.note_on(72, 100);  show("note_on 72")
del e
