#!/usr/bin/env python3
"""latch_probe.py — DECISIVE test of the disputed DCO-retrigger latch.

Scenario C (unverified) claims: the plugin's note-on does NOT arm the aux latch
(cell 101504+voice*32); it is armed only by build/recall and consumed on the
first rendered sample. The port (src/juno_note.c:159) arms it on EVERY note-on.

Ground truth = the plugin's OWN note-on/note-off machine code under Unicorn.
Method: hook EVERY memory write to any unit's state during the note_on / note_off
call, and snapshot the latch cells before/after render, in COLD and WARM states.
No captures. No guessing. We watch what the plugin's code actually writes."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

PATCH = 0  # SY Poly Synth (same patch Scenario C used)

def latch_all(e):
    """Read the aux-latch cell 101504+v*32 from EVERY unit's state (u,v grid)."""
    out = {}
    for u in range(9):
        row = []
        for v in range(8):
            row.append(e.rd_u32(e.state[u] + 101504 + v*32))
        out[u] = row
    return out

def fbits(x):
    return struct.unpack('<f', struct.pack('<I', x))[0]

def cold(e):
    e.build(48000); e.snap_all(); E.recall_patch(e, PATCH); e.snap_all(); e.clear_latch(); e.set_ftz()

# ---- capture writes during a single call ---------------------------------
def hook_call(e, callfn):
    writes = []  # (unit, off, size, value)
    st = e.state
    def wh(uc, access, address, size, value, user):
        for u in range(9):
            base = st[u]
            if base <= address < base + E.STATE_SZ:
                writes.append((u, address - base, size, value))
                break
    h = e.uc.hook_add(UC_HOOK_MEM_WRITE, wh)
    callfn()
    e.uc.hook_del(h)
    return writes

def summarize(writes, tag):
    # focus on latch region (101504..101504+8*32) and per-voice pitch/gate
    print(f"\n=== {tag}: {len(writes)} total state writes ===")
    latch_w = [w for w in writes if 101504 <= w[1] < 101504 + 8*32]
    print(f"  writes to aux-latch region [101504,101760): {len(latch_w)}")
    for (u, off, size, val) in latch_w:
        v = (off - 101504)//32
        print(f"    unit{u} off{off} (voice{v}) sz{size} <- 0x{val & 0xffffffff:08x} ({fbits(val & 0xffffffff):.6g})")
    # pitch(304)/gate(320) writes tell us which unit/voice the note allocated
    pg = [w for w in writes if w[1] in (304, 320)]
    for (u, off, size, val) in pg:
        nm = 'pitch304' if off == 304 else 'gate320'
        print(f"    unit{u} {nm} <- 0x{val & 0xffffffff:08x} ({fbits(val & 0xffffffff):.6g})")

print("################ COLD: latch state right after recall+snap+clear ############")
e = E.E2E(); cold(e)
L0 = latch_all(e)
for u in range(9):
    vals = [f"{fbits(x):.3g}" for x in L0[u]]
    if any(x != 0 for x in L0[u]):
        print(f"  unit{u} latches: {vals}")
print("  (units not shown are all-zero)")

print("\n################ COLD: what does note_on(60,105) WRITE? ############")
w_on = hook_call(e, lambda: e.note_on(60, 105))
summarize(w_on, "note_on(60,105) cold")
L1 = latch_all(e)
print("  latch state AFTER note_on (nonzero units):")
for u in range(9):
    if any(x != 0 for x in L1[u]):
        print(f"    unit{u}: {[f'{fbits(x):.3g}' for x in L1[u]]}")

print("\n################ COLD: render 1 sample, then latch state ############")
e.render(1)
L2 = latch_all(e)
print("  latch state AFTER render(1) (nonzero units):")
for u in range(9):
    if any(x != 0 for x in L2[u]):
        print(f"    unit{u}: {[f'{fbits(x):.3g}' for x in L2[u]]}")

print("\n################ WARM: render 6000 more (consume), then a NEW note ############")
e.render(6000)
L3 = latch_all(e)
print("  latch state after idle render 6001 total (nonzero units):")
for u in range(9):
    if any(x != 0 for x in L3[u]):
        print(f"    unit{u}: {[f'{fbits(x):.3g}' for x in L3[u]]}")
w_on2 = hook_call(e, lambda: e.note_on(64, 100))
summarize(w_on2, "note_on(64,100) WARM (after 6000 render)")
L4 = latch_all(e)
print("  latch state AFTER warm note_on (nonzero units):")
for u in range(9):
    if any(x != 0 for x in L4[u]):
        print(f"    unit{u}: {[f'{fbits(x):.3g}' for x in L4[u]]}")

print("\n################ note_off: does it write the latch? ############")
w_off = hook_call(e, lambda: e.note_off(60))
summarize(w_off, "note_off(60)")
print("\nDONE.")
