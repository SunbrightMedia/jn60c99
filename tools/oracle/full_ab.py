#!/usr/bin/env python3
"""Full-state A/B: emulate BUILD + setSampleRate(96000), then compare the
binary's prepared part object against the compiled C engine (init + chorus_init
+ prepare, NO capture) across every DSP-read offset. Categorise each divergence:
  - FX param cell (in param_descriptor_map.json) -> should be recalled per-patch
  - invariant algo constant (emu!=0, not a param cell) -> belongs in prepare
  - my engine has a value the emu doesn't (my extra) -> suspicious
"""
import emu2, struct, json
from emu2 import IB, f32, STACK_BASE, STACK_SIZE, SCRATCH
from unicorn import UcError
from unicorn.x86_const import *

reads = [int(x) for x in open("/tmp/dspreads.txt")]
cnocap = {}
for ln in open("/tmp/c_nocap.txt"):
    o, h = ln.split(); cnocap[int(o)] = int(h, 16)
ccap = {}
for ln in open("/tmp/c_cap.txt"):
    o, h = ln.split(); ccap[int(o)] = int(h, 16)

# FX param descriptor cells (offset -> name), from the agent's dump
descmap = {}
try:
    for d in json.load(open("param_descriptor_map.json")):
        descmap[int(d["off"])] = d["name"]
except Exception as ex:
    print("WARN: no param_descriptor_map.json:", ex)

# ---- run BUILD + setSampleRate(96000) -------------------------------------
e = emu2.Emu()
HOST = e.bump(0x8000); e.uc.mem_write(HOST, b"\x00" * 0x8000)
try: e.call(emu2.BUILD, rcx=HOST)
except UcError: pass
uc = e.uc
rsp = ((STACK_BASE + STACK_SIZE - 0x10000) & ~0xF) - 8
uc.reg_write(UC_X86_REG_RSP, rsp); uc.reg_write(UC_X86_REG_RCX, HOST)
uc.reg_write(UC_X86_REG_XMM1, struct.unpack('<Q', struct.pack('<f', 96000.0) + b'\0\0\0\0')[0])
uc.mem_write(rsp, struct.pack("<Q", SCRATCH + 0x5000))
try: uc.emu_start(IB + 0x3C7A20, SCRATCH + 0x5000, count=800_000_000)
except UcError: pass
ST = sorted([a for a, s in e.allocs if s == 0xA83010])[0]

def emu_u32(o): return struct.unpack("<I", uc.mem_read(ST + o, 4))[0]

match = 0
fx_cell_gap = []      # emu!=cnocap, offset is a bound FX param cell
algo_gap = []         # emu!=0, cnocap==0, NOT a param cell -> invariant algo const to add
my_extra = []         # cnocap!=0 but emu==0
other = []            # emu!=cnocap, both nonzero, not a cell
for o in reads:
    ev = emu_u32(o); cv = cnocap.get(o, 0)
    if ev == cv:
        match += 1; continue
    if o in descmap:
        fx_cell_gap.append((o, ev, cv, descmap[o]))
    elif cv == 0 and ev != 0:
        algo_gap.append((o, ev))
    elif ev == 0 and cv != 0:
        my_extra.append((o, cv))
    else:
        other.append((o, ev, cv))

print(f"DSP-read offsets: {len(reads)}")
print(f"  exact match (C no-capture == binary): {match}")
print(f"  FX param cells differing (recall target; emu power-on=0): {len(fx_cell_gap)}")
print(f"  invariant algo-const gap (emu set, my init/prepare 0): {len(algo_gap)}")
print(f"  my-engine-extra (I set, emu 0): {len(my_extra)}")
print(f"  other (both nonzero, not a cell): {len(other)}")

# how many of the algo_gap does the CAPTURE currently cover (== emu)?
cap_covers = sum(1 for o, ev in algo_gap if ccap.get(o, 0) == ev)
print(f"\n  of the {len(algo_gap)} algo-const gaps, capture matches binary on: {cap_covers}")

print("\n--- invariant algo-const gap (first 60) ---")
for o, ev in algo_gap[:60]:
    cc = ccap.get(o, 0)
    print(f"  {o:9d}  emu=0x{ev:08x} {f32(ev):>13.6g}  cap={'==' if cc==ev else '0x%08x'%cc}")
print(f"  ... {len(algo_gap)} total")

print("\n--- FX param cells (emu power-on should be 0) — nonzero on either side ---")
for o, ev, cv, nm in fx_cell_gap[:40]:
    print(f"  {o:9d}  {nm:16.16}  emu=0x{ev:08x}  Cnocap=0x{cv:08x}")
print(f"  ... {len(fx_cell_gap)} total")

print("\n--- my-engine-extra (I set nonzero, binary is 0) — first 40 ---")
for o, cv in my_extra[:40]:
    innm = descmap.get(o, "")
    print(f"  {o:9d}  Cnocap=0x{cv:08x} {f32(cv):>13.6g}   {innm}")
print(f"  ... {len(my_extra)} total")

# persist the algo gap for code-gen
json.dump([[o, ev] for o, ev in algo_gap], open("/tmp/algo_gap.json", "w"))
json.dump([[o, ev, cv, nm] for o, ev, cv, nm in fx_cell_gap], open("/tmp/fx_cell_gap.json", "w"))
json.dump([[o, cv] for o, cv in my_extra], open("/tmp/my_extra.json", "w"))
print("\nwrote /tmp/algo_gap.json /tmp/fx_cell_gap.json /tmp/my_extra.json")
