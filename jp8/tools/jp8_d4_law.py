#!/usr/bin/env python3
"""jp8_d4_law.py -- D4: the VCO RANGE / VCO2 FINE TUNE / VCO2 SUB RANGE -> pitch law, READ FROM THE CELLS THE
PLUGIN'S OWN SETTERS WRITE (PROVEN by execution on a full boot, no formula of mine).

How the cells were found (d4_trace, 2026-09-22): a memory-write hook on dispatch(unit 0, id, v) after a full
boot. Every panel id fans out (proc setter -> 8 child DSP objects, vtbl 0xa19110) and lands ONE float per
voice slot (stride 0x5ED0) via 0x440430 ([[state+0x38]+idx*40+0x20] = xmm2):
   760 VCO1 RANGE     -> state+0x1390   child slot 0x40 = 0x385aa0: table[.rdata 0xcbc2b8][v] (v<=5), set now
   765 VCO2 RANGE     -> state+0x13a0   child slot 0x48 = 0x385ad0: the same table, set now
   769 VCO2 SUB RANGE -> state+0x1470   child slot 0x50 = 0x385a30
   766 VCO2 FINE TUNE -> state+0x1480   child slot 0xa8 = 0x386310: curve 0x40 of .data 0xd22428 (runtime-built)
                                        via 0x37e990, + 0.0003 (.rdata 0xa192e8); flag 0 -> arm ramp 0x43eec0,
                                        flag 1 -> set now 0x43ee80
The consumer (fn 0x395000, per sample, PROVEN by a read hook): the cells are OCTAVES summed into the two pitch
cells [state+0x16e0] (VCO1) / [state+0x16f0] (VCO2), clamped to [0x18e0]=-4 .. [0x18d0]=10:
   VCO1 = [0x1630] + [0x1370] + [0x1610](key) + [0x1460] + [0x1390](RANGE1)                      (0x3965cb)
   VCO2 = [0x1640] + lerp([0x1610](key),[0x1730],[0x1580](LOW FREQ)) + [0x1380] + [0x1470](SUB) + [0x1480](FINE)
          + [0x13a0](RANGE2)                                                                     (0x3965eb)
Key 60 puts [0x1610] at 2.0, so f = 65.4064 Hz * 2^cell (verified by execution in jp8_d4_probe.py).
usage: jp8_d4_law.py  (prints the tables; ~25 s)"""
import sys, os, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w,f=jp.host_init(); assert f==0
jp.recall(0); jp.snap_ramps(); jp.clear_latch()
uc=jp.uc; st=jp.state[0]
def cell(off): return struct.unpack("<f",uc.mem_read(st+off,4))[0]
def law(pid,off,vals,unit):
    out=[]
    for v in vals:
        jp.dispatch(0,pid,v,flag=1); out.append((v,cell(off)))
    return out
print("RANGE law (ids 760/765, cells +0x1390/+0x13a0, octaves; 1 octave = 12 semitones):")
for pid,off in ((760,0x1390),(765,0x13a0)):
    print("  id %d: "%pid+"  ".join("%d -> %+g oct (%+d semis)"%(v,c,round(12*c)) for v,c in law(pid,off,range(6),"oct")))
print("SUB RANGE law (id 769, cell +0x1470, engine frame -36..36 = raw byte - 36):")
rows=law(769,0x1470,range(-36,37),"oct"); bad=[(v,c) for v,c in rows if abs(c-v/12.0)>1e-6]
print("  cell = v/12 octaves = v semitones for all 73 values (max |cell*12 - v| = %.2e)"%max(abs(12*c-v) for v,c in rows))
print("  samples: "+"  ".join("%d -> %+.6g"%(v,c) for v,c in rows if v in (-36,-24,-12,-1,0,1,12,24,36)))
print("FINE TUNE law (id 766, cell +0x1480, octaves; cents = 1200*cell):")
rows=law(766,0x1480,range(256),"oct")
print("  full table (v -> cents): "+" ".join("%d:%+.2f"%(v,1200*c) for v,c in rows))
# the shape, stated as INFERRED from the table (the table itself is the law)
def fit(v):
    d = v-120 if v<=120 else (v-135 if v>=135 else 0)
    return 0.0003+0.05/120.0*d
err=max(abs(c-fit(v)) for v,c in rows)
print("  INFERRED shape: cents = 1200*(0.0003 + (0.05/120)*dead(v)), dead(v)= v-120 (v<=120), 0 (121..134), v-135 (v>=135); max |table - shape| = %.2e oct (%.3f cents)"%(err,1200*err))
print("  extremes: 0 -> %+.2f c, 120 -> %+.2f c, 128 -> %+.2f c, 135 -> %+.2f c, 255 -> %+.2f c"%tuple(1200*dict(rows)[v] for v in (0,120,128,135,255)))
