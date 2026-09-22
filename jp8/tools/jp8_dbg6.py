import sys, os, struct
sys.path.insert(0,'gen'); import jp8_emu as J
from unicorn import *; from unicorn.x86_const import *
IB=J.IB
XI=(0x9ba0c8,0x9ba108)
def run_xi(jp):
    a,b=XI; ptrs=struct.unpack("<%dQ"%((b-a)//8), jp.uc.mem_read(IB+a,b-a)); res=[]
    for p in ptrs:
        if not p: continue
        f0=jp.faults
        try: r=jp.call(p,count=2_000_000); res.append(("0x%x"%(p-IB),"ok rax=%d"%(r&0xffffffff),jp.faults-f0))
        except Exception as e: res.append(("0x%x"%(p-IB),"FAIL "+str(e)[:30],jp.faults-f0))
    return res
jp=J.JP8()
print("XI:",run_xi(jp))
ok,fail=jp.run_static_init(); print("XC after XI: ok",ok,"fail",fail,"faults",jp.faults,"bss",jp.bss_fill(),"map",jp.host_map(), flush=True)
jp.build(); jp.set_ftz(); jp.set_sr(44100.0); print("BUILD+SETSR ok faults",jp.faults, flush=True)
try:
    L,R=jp.render_host(128,block=64); print("RENDER OK peak",max(abs(x) for x in L if x==x),"faults",jp.faults)
except Exception as e: print("RENDER FAIL",e,"faults",jp.faults)
