#!/usr/bin/env python3
"""latch_reads.py — which aux cells does the plugin DSP actually READ during a
render, and what EXACTLY do note_on/note_off write? Resolves Array A (101504+v*32,
consumed by render) vs Array B (101520+v*32, written by note_on) and whether the
DSP reads Array B at all. Ground truth = plugin machine code under Unicorn."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_READ, UC_HOOK_MEM_WRITE

PATCH = 0
AUXLO, AUXHI = 101504, 101504 + 8*32  # [101504, 101760)

def cold(e):
    e.build(48000); e.snap_all(); E.recall_patch(e, PATCH); e.snap_all(); e.clear_latch(); e.set_ftz()

def fbits(x): return struct.unpack('<f', struct.pack('<I', x & 0xffffffff))[0]

e = E.E2E(); cold(e)
e.note_on(60, 105)  # allocates a voice, arms Array B for it

# Hook READS of the aux region across all units during render(1)
reads = []
st = e.state
def rh(uc, access, address, size, value, user):
    for u in range(9):
        b = st[u]
        if b + AUXLO <= address < b + AUXHI:
            reads.append((u, address - b)); break
h = e.uc.hook_add(UC_HOOK_MEM_READ, rh)
e.render(1)
e.uc.hook_del(h)

# Which distinct (unit, off) aux cells were READ by the DSP?
seen = sorted(set(reads))
print(f"aux-region READS during render(1): {len(reads)} total, {len(seen)} distinct cells")
for (u, off) in seen:
    rel = off - 101504
    arr = 'A(101504+v*32)' if rel % 32 == 0 else ('B(101520+v*32)' if rel % 32 == 16 else f'?(+{rel})')
    v = rel // 32
    print(f"   unit{u} off{off}  {arr} voice{v}")

# Now confirm note_off write offset precisely (which array?)
print("\n--- note_off(60) writes to aux region ---")
writes = []
def wh(uc, access, address, size, value, user):
    for u in range(9):
        b = st[u]
        if b + AUXLO <= address < b + AUXHI:
            writes.append((u, address - b, value)); break
h2 = e.uc.hook_add(UC_HOOK_MEM_WRITE, wh)
e.note_off(60)
e.uc.hook_del(h2)
for (u, off, val) in writes:
    rel = off - 101504
    arr = 'A' if rel % 32 == 0 else ('B' if rel % 32 == 16 else '?')
    print(f"   unit{u} off{off} rel+{rel} array{arr} voice{rel//32} <- {fbits(val)}")

# And re-dump the exact note_on write offset with clean arithmetic
print("\n--- fresh cold note_on(67,90): exact write offsets ---")
e2 = E.E2E(); cold(e2)
w2 = []
def wh2(uc, access, address, size, value, user):
    for u in range(9):
        b = e2.state[u]
        if b + AUXLO <= address < b + AUXHI:
            w2.append((u, address - b, value)); break
h3 = e2.uc.hook_add(UC_HOOK_MEM_WRITE, wh2)
e2.note_on(67, 90)
e2.uc.hook_del(h3)
for (u, off, val) in w2:
    rel = off - 101504
    arr = 'A' if rel % 32 == 0 else ('B' if rel % 32 == 16 else '?')
    print(f"   unit{u} off{off} rel+{rel} array{arr} voice{rel//32} (rel%32={rel%32}) <- {fbits(val)}")
