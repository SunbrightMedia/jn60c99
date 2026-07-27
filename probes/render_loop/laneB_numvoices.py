#!/usr/bin/env python3
"""LANE B — the numVoices gate *(ENGINE+56).

PROVEN facts gathered by executing the plugin's own machine code under Unicorn:
  * value of ENGINE+56 after e2e_emu build()/setSampleRate
  * value of ENGINE+56 produced by the plugin's OWN engine factory (rva 0x3C6790),
    which is the single construction site used by the real host lifecycle
  * effect of the host param entry 0x3C7AE0 with paramID 268419086
  * assigner vtable slots +128 / +136 and what the setter does to allocation state
Two-process rule: this file NEVER ctypes-loads libjuno.so.
"""
import sys, struct, json, time
T0=time.time()
def mark(m):
    print("[%7.1fs] %s"%(time.time()-T0,m),flush=True)
def dump():
    print(json.dumps(out,indent=1),flush=True)
sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import e2e_emu as E
from e2e_emu import E2E, IB

FACTORY   = IB + 0x3C6790     # sub_7FF91E026790  -> operator new(0x880) + ctor
CTOR      = IB + 0x3C5A50
HOSTPARAM = IB + 0x3C7AE0
ENG_VT    = IB + 0x9df1d8

out = {}

mark("ctor")
e = E2E()
mark("build")
e.build(48000.0)
mark("built")
uc = e.uc
def u32(a): return struct.unpack("<I", uc.mem_read(a, 4))[0]
def i32(a): return struct.unpack("<i", uc.mem_read(a, 4))[0]
def u64(a): return int.from_bytes(uc.mem_read(a, 8), "little")
def f32(a): return struct.unpack("<f", uc.mem_read(a, 4))[0]

H = e.HOST
out["HOST"] = hex(H)
out["after_build"] = {
    "+8 (sampleRate f32)": f32(H + 8),
    "+16 lock": u32(H + 16),
    "+32 peakL": f32(H + 32),
    "+36 peakR": f32(H + 36),
    "+56 numVoices": i32(H + 56),
    "+64 lock": u32(H + 64),
    "+1072 doneCounter": i32(H + 1072),
    "+1080 lock": u32(H + 1080),
}

# ---- ENGINE vtable dump (sanity: which slot is which)
vt = {}
for s in range(32):
    p = u64(ENG_VT + 8 * s)
    vt[s] = hex(p - IB) if p else None
out["engine_vtable_rva_by_slot"] = vt

# ---- per-unit assigner objects
units = []
for i in range(9):
    st = u64(H + 80 + 64 * i)
    proc = u64(H + 96 + 64 * i)
    asg = u64(H + 104 + 64 * i)
    vptr = u64(asg)
    units.append(dict(
        unit=i, state=hex(st), proc=hex(proc), assign=hex(asg),
        assign_vptr_rva=hex(vptr - IB),
        a8_voicecount=i32(asg + 8),
        a12_mask=hex(u32(asg + 12) & 0xFFFFFFFF),
        a152_n=i32(asg + 152),
        a120_order=[i32(asg + 120 + 4 * k) for k in range(8)],
        a168_samplecounter=u64(asg + 168),
    ))
out["units"] = units
mark("units done"); dump()

AVPTR = u64(u64(H + 104))
avt = {}
for s in range(26):
    p = u64(AVPTR + 8 * s)
    avt[s * 8] = hex(p - IB) if p else None
out["assigner_vtable_rva_by_byteoffset"] = avt

GET = u64(AVPTR + 136)
SET = u64(AVPTR + 128)
out["assign_getter_vt+136_rva"] = hex(GET - IB)
out["assign_setter_vt+128_rva"] = hex(SET - IB)

a0 = u64(H + 104)
out["getter_returns_on_unit0"] = e.call(GET, rcx=a0) & 0xFFFFFFFF

# ---- what the plugin's OWN engine factory produces (the real-host path)
mark("calling FACTORY 0x3C6790"); dump()
newe = e.call(FACTORY)
mark("factory returned")
out["factory_0x3C6790"] = {
    "ptr": hex(newe),
    "+8 sampleRate f32": f32(newe + 8),
    "+56 numVoices": i32(newe + 56),
    "+64 lock": u32(newe + 64),
    "+1072 doneCounter": i32(newe + 1072),
    "vptr_rva": hex(u64(newe) - IB),
}

mark("hostparam"); dump()
# ---- host param entry with the magic paramID
for v in (4, 8, 1, 0, 8):
    e.call(HOSTPARAM, rcx=H, rdx=268419086, r8=v)
    out.setdefault("hostparam_268419086", []).append({"sent": v, "engine+56": i32(H + 56)})

# ---- host param entry with a NORMAL paramID must not touch +56
try:
    e.call(HOSTPARAM, rcx=H, rdx=779, r8=100)
    out["hostparam_normal_id_779"] = {"engine+56": i32(H + 56), "note": "map is NULL -> may fault"}
except Exception as ex:
    out["hostparam_normal_id_779"] = {"engine+56": i32(H + 56), "exc": str(ex)[:120]}

# ---- what the assigner voice-count SETTER does to allocation state
def asnap(a):
    return dict(n=i32(a + 8), mask=hex(u32(a + 12)), p16=u64(a + 16), p24=u64(a + 24),
                p32=i32(a + 32), p68=i32(a + 68), p72=i32(a + 72), p76=u64(a + 76),
                p84=u64(a + 84), p92=i32(a + 92), p152=i32(a + 152),
                order=[i32(a + 120 + 4 * k) for k in range(8)],
                p168=u64(a + 168))
mark("setter"); dump()
out["assign0_before_setter"] = asnap(a0)
e.call(SET, rcx=a0, rdx=4)
out["assign0_after_set4"] = asnap(a0)
e.call(SET, rcx=a0, rdx=99)
out["assign0_after_set99_clamp"] = asnap(a0)
e.call(SET, rcx=a0, rdx=8)
out["assign0_after_restore8"] = asnap(a0)



mark("DONE"); dump()
