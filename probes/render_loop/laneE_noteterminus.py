#!/usr/bin/env python3
"""LANE E — note-path terminus, PROVEN.

Q: a real host's MIDI note reaches the engine via the queue consumer 0x320B20 ->
   engine vtable slot16 noteOn (0x3C7330). The oracle + port drive that same
   entry. But the recall enumerator also fires a per-voice Note/Gate/Mute bus
   (433-440 / 450-457 / 467-474). Are those the SAME lifecycle or two entries?

This probe executes the plugin's own noteOn under Unicorn on a RECALLED engine
(trap-4 safe) with a hook on the value-tree dispatch 0x3B9A30, and records every
(proc, idx, flag, value) it fires. It also dumps the assigner object's vtable.
Oracle-only (Unicorn); NO libjuno/ctypes here (two-process rule).
"""
import sys, os, struct, json
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX,
                               UC_X86_REG_R8, UC_X86_REG_R9)

PATCH = int(os.environ.get('JUNO_PATCH', '3'))
SR = 48000.0
DISPATCH = E.IB + 0x3B9A30
NAMES_RVA = 0x9a0030
DB_LO = 0x98C040

bank = E.bank_bytes()
leaves = R.leaf_table()

def pname(uc, i):
    p = int.from_bytes(uc.mem_read(E.IB + NAMES_RVA + 8*i, 8), 'little')
    if not (E.IB <= p < E.IB + E.IMGSZ): return '?'
    b = bytes(uc.mem_read(p, 96)); z = b.find(b'\0')
    return b[:z if z >= 0 else 96].decode('latin1')

def dbrange(uc, i):
    lo, hi = struct.unpack('<ii', uc.mem_read(E.IB + DB_LO + 16*i, 8))
    return lo, hi

e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR)
uc = e.uc
print("patch %d '%s' recalled at %g Hz" % (PATCH, E.patch_name(bank, PATCH), SR), flush=True)

# --- assigner + noteobj vtables -------------------------------------------
for label, arr in (('assign', e.assign), ('noteobj', e.noteobj)):
    vt = int.from_bytes(uc.mem_read(arr[0], 8), 'little')
    print("%s[0]=0x%x vtable rva 0x%X" % (label, arr[0], vt - E.IB))
    for s in range(0, 14*8, 8):
        q = int.from_bytes(uc.mem_read(vt + s, 8), 'little')
        tag = ('rva 0x%X' % (q - E.IB)) if E.IB <= q < E.IB + E.IMGSZ else '<0x%x>' % q
        print("    +%-3d slot %2d %s" % (s, s//8, tag))

# --- descriptor ranges for the note bus -----------------------------------
print("\nparamDB {min,max} + names for the live note bus:")
for i in list(range(433, 441)) + list(range(450, 458)) + list(range(467, 475)) + [493, 495, 498]:
    lo, hi = dbrange(uc, i)
    print("  idx %4d  min=%-6d max=%-6d  cur=%-6d  %s" % (i, lo, hi, R.rd_desc(e, i), pname(uc, i)))

# --- hook dispatch, then fire the plugin's own noteOn ----------------------
log = []
proc2u = {p: u for u, p in enumerate(e.proc)}
def hk(u_, a, s, x):
    log.append((proc2u.get(u_.reg_read(UC_X86_REG_RCX), -1),
                u_.reg_read(UC_X86_REG_RDX),
                u_.reg_read(UC_X86_REG_R8),
                u_.reg_read(UC_X86_REG_R9) & 0xffffffff))
hid = uc.hook_add(UC_HOOK_CODE, hk, begin=DISPATCH, end=DISPATCH)

log.clear(); e.note_on(60, 100)
on_log = list(log)
print("\nnoteOn(60,100) -> %d dispatch calls" % len(on_log))
seen = []
for rec in on_log:
    if rec not in seen: seen.append(rec)
for u, idx, flag, val in seen:
    print("   unit%-2d idx %4d flag %d val %-6d  %s" % (u, idx, flag, val, pname(uc, idx)))

log.clear(); e.note_off(60, 64)
off_log = list(log)
print("\nnoteOff(60,64) -> %d dispatch calls" % len(off_log))
seen = []
for rec in off_log:
    if rec not in seen: seen.append(rec)
for u, idx, flag, val in seen:
    print("   unit%-2d idx %4d flag %d val %-6d  %s" % (u, idx, flag, val, pname(uc, idx)))
uc.hook_del(hid)

json.dump({'on': on_log, 'off': off_log},
          open('/home/user/jn60c99/probes/render_loop/laneE_noteterminus.json', 'w'))
