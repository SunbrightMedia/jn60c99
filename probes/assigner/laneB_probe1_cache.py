#!/usr/bin/env python3
"""LANE B probe 1 — can the plugin's assigner SEE the recalled voice modes, and
does the ENGINE noteOn entry (0x3C7330) reach the assigner at all?

Executed facts wanted:
  A) assigner+160 == proc[u]?  (the assigner's "parent" object)
  B) proc getter  0x3B6C40(proc, 0, pid, &out) for 798/799/800 after recall:
     does it return found=1 and the recalled byte?
  C) the assigner's own cache refreshers:
        0x3549F0(asg)      -> asg+16 (ASSIGN MODE)
        0x354A60(asg)      -> asg+20 (LEGATO)
        0x355940(asg, sr)  -> vtbl+128 "prepare", does both
  D) does e.note_on() (engine entry 0x3C7330) call the assigner noteOn 0x355820?
     (hook it and count)
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8

CW = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
SR = 48000.0
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 4

IB = E.IB
GET  = IB + 0x3B6C40      # proc vtbl+0x60  (proc, cat, paramId, &out) -> found
SET  = IB + 0x3B9A30      # proc vtbl+0x58  (proc, paramId, flag, value)
RD_MODE = IB + 0x3549F0   # assigner: refresh ASSIGN MODE cache (+16) from param 800
RD_LEG  = IB + 0x354A60   # assigner: refresh LEGATO cache (+20) from param 799
PREP    = IB + 0x355940   # assigner vtbl+128 "prepare": flush + refresh both
ASG_ON  = IB + 0x355820   # assigner vtbl+24 noteOn(self, note, vel)
ASG_OFF = IB + 0x355780   # assigner vtbl+16 noteOff(self, note)

bank = open(CW, 'rb').read()
leaves = R.leaf_table()
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR)
uc = e.uc
def u64(a): return int.from_bytes(uc.mem_read(a, 8), 'little')
def i32(a): return struct.unpack('<i', uc.mem_read(a, 4))[0]

OUT = e.bump(64)
asg = e.assign[0]

print("=== A. object identity ===")
print("  assign[0]      = 0x%x" % asg)
print("  assign[0]+160  = 0x%x" % u64(asg + 160))
for nm, arr in (('state', e.state), ('proc', e.proc), ('assign', e.assign), ('noteobj', e.noteobj)):
    print("  %-8s[0] = 0x%x" % (nm, arr[0]))
print("  parent == proc[0]:", u64(asg + 160) == e.proc[0])
print("  proc[0] vptr rva 0x%x" % (u64(e.proc[0]) - IB))

print("\n=== B. proc getter 0x3B6C40 after recall (patch %d) ===" % PATCH)
for pid in (798, 799, 800, 801, 856, 873):
    uc.mem_write(OUT, b'\xAA' * 8)
    ret = e.call(GET, rcx=e.proc[0], rdx=0, r8=pid, r9=OUT)
    print("  get(%4d) found=%d out=%d" % (pid, ret & 0xffffffff, i32(OUT)))

print("\n=== C. assigner cache refreshers ===")
print("  before: +16 mode=%d  +20 legato=%d" % (i32(asg + 16), i32(asg + 20)))
e.call(RD_MODE, rcx=asg)
print("  after 0x3549F0 : +16 mode=%d  +20 legato=%d" % (i32(asg + 16), i32(asg + 20)))
e.call(RD_LEG, rcx=asg)
print("  after 0x354A60 : +16 mode=%d  +20 legato=%d" % (i32(asg + 16), i32(asg + 20)))
e.call(PREP, rcx=asg, rdx=int(SR))
print("  after 0x355940 : +16 mode=%d  +20 legato=%d" % (i32(asg + 16), i32(asg + 20)))

print("\n=== D. does ENGINE noteOn 0x3C7330 reach the assigner? ===")
hits = []
def hook(u_, addr, size, user):
    hits.append((addr - IB, u_.reg_read(UC_X86_REG_RCX),
                 u_.reg_read(UC_X86_REG_RDX) & 0xff, u_.reg_read(UC_X86_REG_R8) & 0xff))
h1 = uc.hook_add(UC_HOOK_CODE, hook, begin=ASG_ON, end=ASG_ON)
h2 = uc.hook_add(UC_HOOK_CODE, hook, begin=ASG_OFF, end=ASG_OFF)
e.note_on(60, 105)
uc.hook_del(h1); uc.hook_del(h2)
print("  engine note_on(60,105) -> assigner entry hits: %d" % len(hits))
for (rva, this, a2, a3) in hits[:12]:
    which = 'noteOn' if rva == 0x355820 else 'noteOff'
    unit = [i for i in range(9) if e.assign[i] == this]
    print("    rva 0x%x %-7s this=0x%x (unit %s) note=%d vel=%d"
          % (rva, which, this, unit, a2, a3))
print("faults:", e.faults)
