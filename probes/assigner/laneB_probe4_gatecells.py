#!/usr/bin/env python3
"""LANE B probe 4 — pin the GATE-on aux cell's base/stride (3 voices) and dump the
glide-law input cells (592 porta-enable, 624 porta time, 608/784/800/816/832)
for a portamento patch after the host-path recall+notify."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
import truth

SR = 48000.0
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 55
BANKSEL = sys.argv[2] if len(sys.argv) > 2 else 'factory'
CW = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
STRIDE = 10512
bank = open(truth.BANK if BANKSEL == 'factory' else CW, 'rb').read()
leaves = R.leaf_table()
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR)
uc = e.uc
NOTIFY = E.IB + 0x3549B0
for u in range(9):
    e.call(NOTIFY, rcx=e.assign[u], rdx=4)
print("patch %d (%s) assigner mode=%d legato=%d"
      % (PATCH, BANKSEL, struct.unpack('<i', uc.mem_read(e.assign[0]+16, 4))[0],
         struct.unpack('<i', uc.mem_read(e.assign[0]+20, 4))[0]))

ST = e.state[0]; N = 0xA83010
def f32(a): return struct.unpack('<f', uc.mem_read(a, 4))[0]

print("\nglide-law input cells, unit0 per voice (BEFORE any note):")
print(" v   592(porta en) 608        624(porta t) 784        800        816        832")
for v in range(8):
    b = ST + v*STRIDE
    print(" %d  %11.6f %10.6f %11.6f %10.6f %10.6f %10.6f %10.6f"
          % (v, f32(b+592), f32(b+608), f32(b+624), f32(b+784), f32(b+800), f32(b+816), f32(b+832)))

def snap(): return bytes(uc.mem_read(ST, N))
base = snap()
for v in (1, 3, 6):
    e.call(E.IB + 0x3B9A30, rcx=e.proc[0], rdx=450+v, r8=0, r9=105)
    cur = snap()
    abs_cells = []
    for i in range(8*STRIDE, N, 4):
        if base[i:i+4] != cur[i:i+4]:
            abs_cells.append(i)
    rel_cells = []
    for i in range(0, 8*STRIDE, 4):
        if base[i:i+4] != cur[i:i+4]:
            rel_cells.append((i//STRIDE, i - (i//STRIDE)*STRIDE))
    print("GATE 450+%d=105 -> rel %s   ABS %s  (101504+32v=%d, 101520+32v=%d)"
          % (v, rel_cells, abs_cells, 101504+32*v, 101520+32*v))
    base = cur
print("faults:", e.faults)
