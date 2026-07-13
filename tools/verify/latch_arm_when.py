#!/usr/bin/env python3
"""latch_arm_when.py — WHEN does the plugin arm Array A (101504+v*32, the DCO
retrigger latch the DSP consumes)? build? recall? re-recall after consume?
And is note_off's Array-A write real or a leaf-oracle assigner artifact?
Ground truth = plugin machine code under Unicorn."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

def arrA(e):
    """Array A cell for each voice, read from that voice's OWN unit (the only
    copy the DSP consumes): unit v, off 101504+v*32."""
    return [struct.unpack('<f', struct.pack('<I', e.rd_u32(e.state[v] + 101504 + v*32)))[0] for v in range(8)]

def hookwrites(e, fn, lo=101504, hi=101504+8*32):
    w = []
    st = e.state
    def wh(uc, a, addr, sz, val, u):
        for uu in range(9):
            if st[uu]+lo <= addr < st[uu]+hi: w.append((uu, addr-st[uu], val)); break
    h = e.uc.hook_add(UC_HOOK_MEM_WRITE, wh); fn(); e.uc.hook_del(h); return w

e = E.E2E()
e.build(48000)
print("Array A (unit v, slot v) right after BUILD:      ", arrA(e))
e.snap_all()
print("  after snap_all:                                ", arrA(e))
w = hookwrites(e, lambda: E.recall_patch(e, 0))
print("  recall(0) wrote", len(w), "aux cells; distinct offs:", sorted(set((o-101504) for _,o,_ in w)))
print("Array A after recall(0):                         ", arrA(e))
e.snap_all(); e.clear_latch(); e.set_ftz()
print("Array A after snap/clear:                        ", arrA(e))
# consume via render
e.note_on(60,105); e.render(2)
print("Array A after note_on+render(2) (all consumed?): ", arrA(e))
# 2nd recall (warm) — does it re-arm?
w2 = hookwrites(e, lambda: E.recall_patch(e, 4))
print("  re-recall(4) wrote", len(w2), "aux cells; distinct offs:", sorted(set((o-101504) for _,o,_ in w2)))
print("Array A after 2nd recall(4):                     ", arrA(e))

# note_off targeting: cold, single note on a known voice, note_off, watch Array A
print("\n--- note_off targeting test (fresh) ---")
e2 = E.E2E(); e2.build(48000); e2.snap_all(); E.recall_patch(e2,0); e2.snap_all(); e2.clear_latch(); e2.set_ftz()
won = hookwrites(e2, lambda: e2.note_on(60,105))
von = [(o-101504) for _,o,_ in won]; print("note_on(60,105) aux write rel-offs:", sorted(set(von)), "-> voices", sorted(set((o)//32 for o in set(von))))
e2.render(2)
print("Array A after note_on+render(2):", arrA(e2))
woff = hookwrites(e2, lambda: e2.note_off(60))
voff = [(o-101504) for _,o,_ in woff]; print("note_off(60) aux write rel-offs:", sorted(set(voff)), "arrays:", sorted(set(('A' if o%32==0 else 'B') for o in set(voff))))
print("Array A after note_off(60):     ", arrA(e2))
