#!/usr/bin/env python3
"""LANE B probe 0 — MAP the assigner object before driving it.

Oracle-only (Unicorn). No libjuno. Outputs:
  1. Chillwave bank patch names + PORTAMENTO(798)/LEGATO(799)/ASSIGN MODE(800)
     values, decoded by the plugin's own record parser.
  2. The unit-0 assigner vtable (all slots, as rvas) so noteOn/noteOff and the
     parent-getter slot can be named from the binary rather than assumed.
  3. Assigner cached fields +16 (ASSIGN MODE) / +20 (LEGATO) after a full recall.
  4. Whether the assigner's parent getter vtable[+80](self,4,paramId,&out) can
     actually READ 798/799/800 back out of the engine (i.e. whether recall makes
     the assigner see them at all).
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import real_bank_parse as RB
import recall_render_ab as RRA

CW = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
SR = 48000.0
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 4

bank = open(CW, 'rb').read()
leaves = R.leaf_table()

# ---- 1. bank values (plugin parser) -------------------------------------
recs = RB.parse_records(bank)
print("=== Chillwave bank: voice-mode leaves (plugin's own record parser) ===")
print("idx  name              PORTA(798,rb108)  LEGATO(799,rb110)  ASSIGN(800,rb112)")
for i in range(8):
    base = RB.HEADER + i * RB.STRIDE
    nm = ''.join(chr(c) if 32 <= c < 127 else ' ' for c in bank[base:base+16]).strip()
    p = RB.record_value(recs[i], 108)
    l = RB.record_value(recs[i], 110)
    a = RB.record_value(recs[i], 112)
    print("%3d  %-16s %8d %18d %18d" % (i, nm, p, l, a))

# leaf_table membership check
lt = dict(leaves)
print("\nleaf_table contains 798=%s 799=%s 800=%s" %
      (lt.get(798), lt.get(799), lt.get(800)))

# ---- 2/3/4. engine + assigner ------------------------------------------
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR)
uc = e.uc
def u64(a): return int.from_bytes(uc.mem_read(a, 8), 'little')
def u32(a): return struct.unpack('<I', uc.mem_read(a, 4))[0]
def i32(a): return struct.unpack('<i', uc.mem_read(a, 4))[0]

NT = E.IB + 0x9a0030
def pname(idx):
    p = u64(NT + 8*idx)
    if not (E.IB <= p < E.IB + E.IMGSZ): return '?'
    b = bytearray(); a = p
    while len(b) < 128:
        c = uc.mem_read(a, 1)[0]
        if c == 0: break
        b.append(c); a += 1
    return b.decode('latin1')

print("\nnames: 798=%r 799=%r 800=%r" % (pname(798), pname(799), pname(800)))

asg = e.assign[0]
vt = u64(asg)
print("\n=== unit-0 assigner @0x%x  vtable rva 0x%x ===" % (asg, vt - E.IB))
for s in range(0, 128, 8):
    fn = u64(vt + s)
    tag = ('rva 0x%x' % (fn - E.IB)) if (E.IB <= fn < E.IB + E.IMGSZ) else ('0x%x' % fn)
    print("  vtbl+%-3d  %s" % (s, tag))

print("\nassigner fields after recall of patch %d:" % PATCH)
for off, nm in ((8, 'N voices'), (12, 'all mask'), (16, 'ASSIGN MODE'),
                (20, 'LEGATO'), (24, 'HOLD'), (32, 'glide mask a1[8]'),
                (68, 'force-glide mask a1[17]'), (152, 'N (LRU tail)'),
                (156, 'model variant')):
    print("  +%-4d %-22s = %d" % (off, nm, i32(asg + off)))
print("  +160 parent engine = 0x%x" % u64(asg + 160))
print("  per-voice note/gate/rel bytes @+96:",
      list(uc.mem_read(asg + 96, 24)))

# ---- 4. can the assigner READ 798/799/800 from its parent? --------------
SCRATCH_OUT = 0x100000 + 0x9000
getter = u64(vt + 80)
setter72 = u64(vt + 72)
print("\nparent getter vtbl+80 = rva 0x%x ; setter vtbl+72 = rva 0x%x"
      % (getter - E.IB, setter72 - E.IB))
for pid in (798, 799, 800, 433, 450):
    uc.mem_write(SCRATCH_OUT, b'\xAA' * 8)
    try:
        ret = e.call(getter, rcx=asg, rdx=4, r8=pid, r9=SCRATCH_OUT)
        out = bytes(uc.mem_read(SCRATCH_OUT, 8))
        print("  getter(cat=4, %d) -> ret=%d  out=%s (i32=%d, f32=%.6f)"
              % (pid, ret & 0xff, out.hex(),
                 struct.unpack('<i', out[:4])[0], struct.unpack('<f', out[:4])[0]))
    except RuntimeError as ex:
        print("  getter(cat=4, %d) FAULT %s" % (pid, ex))
print("faults:", e.faults)
