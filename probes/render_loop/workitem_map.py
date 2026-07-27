#!/usr/bin/env python3
"""STEP 1/2 probe: map the plugin's real per-block render work items.

Builds the engine under Unicorn and reads the 8 pool work-item structs the
per-block render callback (rva 0x3C7400) fills, at ENGINE+1152+128*i (derived:
the child locks a1+56 and the parent locks v6+1208+128*i, so item base =
v6+1152+128*i). Identifies every pointer field against the known per-unit
object tables, and resolves the vtable slot +104 that ONLY voice 0 invokes
once per sample inside the work item (rva 0x3C6F00):

    for (i=0;i<blockSize;i++){ VOICE_WRAP(state,voiceIdx,bufs);
                               bufs[0]+=4; bufs[1]+=4;
                               if(!voiceIdx) (*(sharedObj->vt+104))(sharedObj); }

Oracle-only (Unicorn); covenant-clean (plugin's own build code, observed).
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

e = E.E2E(); e.build(48000.0)
uc = e.uc
H = e.HOST
rdq = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
rdd = lambda a: int.from_bytes(uc.mem_read(a, 4), 'little')

print("ENGINE (a1) = 0x%x" % H)
print("a1+48 (?)        = %d" % rdd(H + 48))
print("a1+52 (?)        = %d" % rdd(H + 52))
print("a1+56 numVoices? = %d   <- parent renders voice i only if i < this" % rdd(H + 56))
print("a1+592 masterObj = 0x%x" % rdq(H + 592))
print()

# known per-unit object tables (e2e_emu convention)
tbl = {}
for i in range(9):
    tbl[rdq(H + 80 + 64*i)] = 'state[%d]' % i
    tbl[rdq(H + 96 + 64*i)] = 'proc[%d]' % i
    tbl[rdq(H + 104 + 64*i)] = 'assign[%d]' % i
    tbl[rdq(H + 120 + 64*i)] = 'noteobj[%d]' % i
tbl[H] = 'ENGINE'

def who(p):
    return tbl.get(p, '0x%x' % p)

print("work items @ ENGINE+1152+128*i:")
for i in range(8):
    b = H + 1152 + 128*i
    o8, o16, o24 = rdq(b+8), rdq(b+16), rdq(b+24)
    print("  item%d base=0x%-12x +8=%-12s +16=%-12s +24=%-12s +48(bs)=%d +52(cmd)=%d"
          % (i, b, who(o8), who(o16), who(o24), rdd(b+48), rdd(b+52)))

# resolve the voice-0-only per-sample call: vtable slot at +104 of *(item+8)
b0 = H + 1152
obj = rdq(b0 + 8)
print("\nvoice-0 shared object = %s (0x%x)" % (who(obj), obj))
if obj:
    vt = rdq(obj)
    fn = rdq(vt + 104)
    print("  vtable   = 0x%x (rva 0x%x)" % (vt, vt - E.IB))
    print("  slot+104 = 0x%x (rva 0x%x)   <- called ONCE PER SAMPLE by voice 0 only" % (fn, fn - E.IB))
    for s in range(0, 200, 8):
        f = rdq(vt + s)
        if E.IB <= f < E.IB + E.IMGSZ:
            print("    vt+%-4d rva 0x%x%s" % (s, f - E.IB, '   <== the voice-0 call' if s == 104 else ''))
