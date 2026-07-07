#!/usr/bin/env python3
"""Emit the bit-exact voice-block prepare constants from the plugin's own
setSampleRate (CWaveGen::setSampleRate @0x3C7A20), and A/B-verify that my C
init, once it also writes them, reproduces the binary's prepared voice-0 block
bit-for-bit.

Ground truth is the binary executed under Unicorn — NOT a capture of the running
commercial plugin. These are the values the plugin's own prepare code writes.
"""
import emu2, struct, re
from emu2 import IB, f32, STACK_BASE, STACK_SIZE, SCRATCH
from unicorn import UcError
from unicorn.x86_const import *

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

# ---- my C init state (dump at same absolute offsets) ----------------------
cinit = {}
for ln in open("/tmp/c_init.txt"):
    o, h = ln.split(); cinit[int(o)] = int(h, 16)

# ---- DSP-read offset set (voice_render + master_render) -------------------
r = set()
for f in ("/home/user/jn60c99/src/voice_render.c", "/home/user/jn60c99/src/master_render.c"):
    s = open(f).read()
    r.update(int(m) for m in re.findall(r'a1, ?(\d+)\)', s))
    r.update(int(m) for m in re.findall(r'a1 \+ (\d+)\b', s))
readset = set(o for o in r if 0 < o <= 12058620)

# ---- recall-written offsets (juno_apply.c coefficient table) --------------
rt = open("/home/user/jn60c99/src/juno_apply.c").read()
recall = set(int(m) for m in re.findall(r'\{\s*\d+,\s*-?\d+,\s*\w+,\s*(\d+),', rt))

# ---- voice-0 main block window: [176, 176+10512) --------------------------
V0LO, V0HI = 176, 176 + 10512

# find every voice-0 DSP-read offset the emulation sets but my init leaves 0
gap = []
for o in range(V0LO, V0HI, 4):
    if o not in readset:            # only what the DSP actually reads
        continue
    ev = emu_u32(o)
    cv = cinit.get(o, 0)
    if ev != 0 and cv == 0:
        gap.append((o, ev, o in recall))

print(f"/* voice-0 DSP-read offsets init leaves zero: {len(gap)} */")
for o, ev, rc in gap:
    tag = "recall-default" if rc else "INVARIANT (unrecalled)"
    print(f"    JI(st, {o:5d}) = 0x{ev:08x};  /* {f32(ev):>13.7g}  {tag} */")

# ---- A/B: if my init ALSO wrote these, would the whole voice-0 block match? ----
after = dict(cinit)
for o, ev, _ in gap:
    after[o] = ev
mismatch = 0
metadata = 0
for o in range(0, V0HI, 4):
    ev = emu_u32(o)
    cv = after.get(o, 0)
    if ev != cv:
        if o < V0LO:                # object header (vtable/ptrs/counts) — not DSP
            metadata += 1
        else:
            mismatch += 1
            if mismatch <= 20:
                print(f"  REMAIN o={o} emu=0x{ev:08x} c=0x{cv:08x} read={o in readset}")
print(f"\nAFTER adding the {len(gap)} constants:")
print(f"  voice-block [176,10688) mismatches remaining: {mismatch}")
print(f"  object-header [0,176) diffs (C++ metadata, not DSP-read): {metadata}")
