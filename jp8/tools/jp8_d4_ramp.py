#!/usr/bin/env python3
"""the ramp slot behind st+0x1480 (VCO2 FINE TUNE): after recall(0) (no snap) print limit/current/active, then let the
PLUGIN'S OWN walker run (render, no snap) and watch the cell. Then the same with the snap. usage: d4_ramp1480.py"""
import sys, os, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w,f=jp.host_init(); assert f==0
uc=jp.uc; st=jp.state[0]
def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
def rf(a): return struct.unpack("<f",uc.mem_read(a,4))[0]
def slot_for(off):
    arr=rq(st+0x58); b0=rq(st+0x70); e0=rq(st+0x78)
    ids=struct.unpack("<%di"%((e0-b0)//4), uc.mem_read(b0,e0-b0)) if e0>b0 else ()
    out=[]
    for i in range(1000):
        a=arr+40*i
        try: tgt=rq(a)
        except Exception: break
        if tgt==st+off: out.append((i,i in ids,rf(a+0xc),rf(a+0x14),rf(a+0x18),uc.mem_read(a+0x1c,1)[0]))
    return out
def show(tag):
    print("%s: cell 0x1480 = %.6g ; slots -> %s ; active list len %d"%(tag,rf(st+0x1480),
        ["id %d listed %s accum %.6g limit %.6g rate %.6g active %d"%s for s in slot_for(0x1480)],(rq(st+0x78)-rq(st+0x70))//4))
show("after host_init")
jp.recall(0)
show("after recall(0)")
jp.render_both(64); show("after 64 samples rendered (no snap)")
jp.render_both(2048); show("after 2112 samples rendered (no snap)")
jp.note_on(60,100); jp.render_both(1024); show("after note_on(60)+1024")
