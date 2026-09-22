#!/usr/bin/env python3
"""jp8_srtrace.py -- who writes the rate-ratio cell state[0]+0x8b0 in SETSR, and its value per rate."""
import sys, os, time, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J
from unicorn import *; from unicorn.x86_const import *
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m), flush=True)
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz()
st=jp.state[0]; uc=jp.uc
watch={st+0x8b0:"st0+0x8b0", st+0x10:"st0+0x10", st+0x3a0:"st0+0x3a0", st+0xc00:"st0+0xc00", st+0x1810:"st0+0x1810", jp.HOST+8:"HOST+8"}
seen=[]
def w(uc,access,address,size,value,user):
    if address in watch:
        rip=uc.reg_read(UC_X86_REG_RIP)
        v=struct.unpack("<f",struct.pack("<I",value&0xffffffff))[0] if size==4 else value
        seen.append((watch[address],rip-J.IB,v))
uc.hook_add(UC_HOOK_MEM_WRITE,w,begin=st,end=st+0x2000)
uc.hook_add(UC_HOOK_MEM_WRITE,w,begin=jp.HOST,end=jp.HOST+0x100)
def rd(off): return struct.unpack("<f",uc.mem_read(st+off,4))[0]
for sr in (44100.0,48000.0,96000.0,88200.0,12000.0,24000.0,22050.0,44100.0):
    seen.clear(); jp.set_sr(sr)
    log("SETSR %g: st0+0x10=%r +0x8b0=%r +0x3a0=%r +0xc00=%r +0x1810=%r ; writes: %s"%(sr,rd(0x10),rd(0x8b0),rd(0x3a0),rd(0xc00),rd(0x1810),
        ["%s@0x%x=%r"%(a,b,c) for a,b,c in seen][:12]))
