#!/usr/bin/env python3
"""LANE E: the aux one-shot arrays across baseline / noteOn / noteOff, for the
plugin's OWN engine noteOn/noteOff on a recalled engine (unit 7 = the unit whose
voice-7 region actually renders). Answers: which aux cell does note-on touch,
and does note-off arm Array A (101504+32v) as src/juno_note.c does?"""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA

PATCH = int(os.environ.get('JUNO_PATCH', '3')); SR = 48000.0
bank = E.bank_bytes(); leaves = R.leaf_table()
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR)
LO, HI = 101400, 102000
def win(u): return bytes(e.uc.mem_read(e.state[u] + LO, HI - LO))
b0 = win(0); b7 = win(7)
e.note_on(60, 100); o0 = win(0); o7 = win(7)
e.note_off(60, 64); f0 = win(0); f7 = win(7)
print("patch %d  window [%d,%d)  (u0 = unit0, u7 = unit7)" % (PATCH, LO, HI))
print("%-8s %-6s %-14s %-14s %-14s" % ("off", "unit", "baseline", "afterOn", "afterOff"))
for o in range(0, HI - LO, 4):
    trip0 = (b0[o:o+4], o0[o:o+4], f0[o:o+4])
    trip7 = (b7[o:o+4], o7[o:o+4], f7[o:o+4])
    for lbl, t in (('u0', trip0), ('u7', trip7)):
        if len(set(t)) > 1 or any(x != b'\0\0\0\0' for x in t):
            print("%-8d %-6s %-14g %-14g %-14g" % (
                LO + o, lbl, *[struct.unpack('<f', x)[0] for x in t]))
print("\nArray A (101504+32v) / Array B (101520+32v) for v=0..7, unit7:")
for v in range(8):
    for name, base in (('A', 101504), ('B', 101520)):
        o = base + 32*v - LO
        print("  %s v%d off %-8d base=%-8g on=%-8g off=%-8g" % (
            name, v, base+32*v,
            struct.unpack('<f', b7[o:o+4])[0],
            struct.unpack('<f', o7[o:o+4])[0],
            struct.unpack('<f', f7[o:o+4])[0]))
