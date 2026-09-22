#!/usr/bin/env python3
"""jp8_d4_probe.py -- D4 execution proof: fresh boot (static init -> BUILD -> SETSR float -> FTZ -> host_init ->
recall FLAG 0 -> snap + latch), optional id=val overrides (flag 0 like the recall, all units, then snap), then for each key a FRESH
note: DRY f0 by autocorrelation in an EARLY window (1024..17408) and a LATE window (49152..65536, after a pitch
envelope has decayed), each against the engine's OWN pitch cells [0x16e0]/[0x16f0] read at the window start. The cells are a
KEY-INDEPENDENT offset in octaves (2.0024 at keys 48, 60 and 72 alike on patch 2: d4_spec logs): the key enters at the
oscillator (0x39b21a adds the cell to the key term), so expected f = midi_hz(key) * 2^(cell - 2.0). PASS when the
measured f0 sits within 25 cents of one VCO's expected pitch (the mix's autocorrelation finds the lower VCO).
usage: jp8_d4_probe.py <patch> <keys e.g. 48,60> [id=val ...]"""
import sys, os, struct, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, audio_metrics as AM, numpy as np
t0=time.time(); SR=44100.0
patch=int(sys.argv[1]); keys=[int(k) for k in sys.argv[2].split(",")]; over=[a.split("=") for a in sys.argv[3:]]
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(SR); w,f=jp.host_init(); assert f==0
jp.recall(patch)
for pid,v in over:                      # overrides ride the SAME hosted path (flag 0 = arm the ramp; a flag-1
    for u in range(9): jp.dispatch(u,int(pid),int(v),flag=0)   # write here is undone by the recall's still-armed ramp at the snap)
if over: jp.notify()
jp.snap_ramps(); jp.clear_latch(); uc=jp.uc
lab="patch %d%s"%(patch,"".join(" %s:=%s"%tuple(o) for o in over))
def cells():
    out=[]
    for u in range(8):
        c1,c2=struct.unpack("<ff",uc.mem_read(jp.state[u]+0x16e0,4)+uc.mem_read(jp.state[u]+0x16f0,4))
        if c1!=0 or c2!=0: out.append((u,c1,c2))
    return out
fails=0
for key in keys:
    jp.note_on(key,100); jp.render_both(1024)
    for win,skip in (("EARLY",0),("LATE",49152-17408)):
        if skip: jp.render_both(skip)
        cs=cells(); d,Lw,Rw=jp.render_both(16384); d=np.array(d)
        f0=AM.f0_autocorr(d,SR); c=1200*math.log2(f0/AM.midi_hz(key)) if f0>0 else float('nan'); h=AM.harmonicity(d,SR,f0) if f0>0 else 0
        eng=[(u,AM.midi_hz(key)*2**(c1-2.0),AM.midi_hz(key)*2**(c2-2.0)) for u,c1,c2 in cs]
        ok=any(abs(1200*math.log2(f0/fe))<=25 for u,f1,f2 in eng for fe in (f1,f2)) if f0>0 else False
        fails+=not ok
        print("[%5.1fs] %s key %d %s: DRY f0 %.2f Hz (%+.0f c vs key) harm %.2f peak %.3g | engine VCO1/VCO2 %s -> %s"%(time.time()-t0,lab,key,win,f0,c,h,float(np.abs(d).max()),
              " ".join("u%d %.2f/%.2f Hz"%(u,f1,f2) for u,f1,f2 in eng) or "(no unit sounding)","PASS" if ok else "FAIL"),flush=True)
    jp.note_off(key,64); jp.render_both(3000)
print("D4 PROBE %s: %s"%(lab,"PASS" if not fails else "%d FAIL"%fails))
