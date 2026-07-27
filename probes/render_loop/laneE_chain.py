#!/usr/bin/env python3
"""LANE E — trace the ACTUAL call chain of the plugin's own engine noteOn under
Unicorn on a RECALLED engine. Hooks the candidate rvas and reports hit counts +
argument tuples. Also dumps the proc-object vtable (rva 0x9C3018) slot 11, which
the assigner's publish thunk 0x355AC0 calls."""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX,
                               UC_X86_REG_R8, UC_X86_REG_R9)

PATCH = int(os.environ.get('JUNO_PATCH', '3'))
SR = 48000.0
bank = E.bank_bytes(); leaves = R.leaf_table()
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR); uc = e.uc
print("patch %d recalled" % PATCH, flush=True)

print("proc vtable rva 0x9C3018:")
for s in range(0, 16*8, 8):
    q = int.from_bytes(uc.mem_read(E.IB + 0x9C3018 + s, 8), 'little')
    tag = ('rva 0x%X' % (q - E.IB)) if E.IB <= q < E.IB + E.IMGSZ else '<0x%x>' % q
    print("   +%-3d slot %2d %s" % (s, s//8, tag))

print("\nnoteobj[0]=0x%x  assign[0]=0x%x  proc[0]=0x%x" % (e.noteobj[0], e.assign[0], e.proc[0]))
for off in (1304, 1312):
    p = int.from_bytes(uc.mem_read(e.noteobj[0] + off, 8), 'little')
    print("   noteobj[0]+%d -> 0x%x %s" % (off, p, '== assign[0]' if p == e.assign[0] else ''))
p160 = int.from_bytes(uc.mem_read(e.assign[0] + 160, 8), 'little')
print("   assign[0]+160 -> 0x%x %s" % (p160, '== proc[0]' if p160 == e.proc[0] else ''))

CAND = {0x3C7330:'engine noteOn', 0x3C72D0:'engine noteOff', 0x3C42D0:'noteobj noteOn',
        0x3C4230:'noteobj noteOff', 0x355820:'assigner slot3 noteOn',
        0x355780:'assigner slot2 noteOff', 0x353870:'poly alloc (mode!=1,2)',
        0x353150:'voice publish (mode!=3)', 0x3535C0:'voice publish (mode==3)',
        0x3538F0:'mono/uni alloc', 0x353B00:'porta alloc on', 0x353B60:'porta alloc off',
        0x355AC0:'assigner publish thunk', 0x3B9A30:'value-tree dispatch',
        0x3B48A0:'recall enumerator', 0x3C7AE0:'host param entry'}
hits = {}
args = {}
def mk(rva):
    def hk(u_, a, s, x):
        hits[rva] = hits.get(rva, 0) + 1
        if len(args.setdefault(rva, [])) < 24:
            args[rva].append((u_.reg_read(UC_X86_REG_RCX), u_.reg_read(UC_X86_REG_RDX),
                              u_.reg_read(UC_X86_REG_R8), u_.reg_read(UC_X86_REG_R9) & 0xffffffff))
    return hk
for rva in CAND:
    uc.hook_add(UC_HOOK_CODE, mk(rva), begin=E.IB + rva, end=E.IB + rva)

for label, fn in (('noteOn(60,100)', lambda: e.note_on(60, 100)),
                  ('noteOff(60,64)', lambda: e.note_off(60, 64))):
    hits.clear(); args.clear()
    fn()
    print("\n--- %s ---" % label)
    for rva in sorted(hits, key=lambda r: -hits[r]):
        print("  0x%-8X %-26s hits=%d" % (rva, CAND[rva], hits[rva]))
    for rva in (0x355AC0, 0x3B9A30, 0x353150, 0x3535C0, 0x3538F0, 0x353B00, 0x353B60):
        if rva in args:
            print("  args 0x%X %s:" % (rva, CAND[rva]))
            for a in args[rva][:16]:
                print("     rcx=0x%x rdx=%d r8=%d r9=%d" % a)
