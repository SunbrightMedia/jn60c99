import sys, os, struct
sys.path.insert(0,'gen'); import jp8_emu as J
from unicorn import *; from unicorn.x86_const import *
jp=J.JP8(); uc=jp.uc; IB=J.IB
jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); jp.host_init(); jp.recall(0); jp.snap_ramps(); jp.clear_latch()
print("booted, faults",jp.faults, flush=True)
CLO,CHI=IB+0x1000,IB+0x9b6a38
calls=[]   # (call site rva, target rva, rsp)
def code(uc,address,size,user):
    b=bytes(uc.mem_read(address,size))
    if b[0]==0xE8 or (b[0]==0xFF and len(b)>1 and (b[1]&0x38) in (0x10,)):   # call rel32 / call r/m
        calls.append(address-IB)
        if len(calls)>4000: calls.pop(0)
uc.hook_add(UC_HOOK_CODE, code, begin=IB, end=IB+J.IMGSZ)
done=[False]
def unm(uc,access,address,size,value,user):
    if done[0]: return False
    done[0]=True
    rip=uc.reg_read(UC_X86_REG_RIP); rsp=uc.reg_read(UC_X86_REG_RSP)
    print("FIRST UNMAPPED addr 0x%x at rva 0x%x rsp 0x%x"%(address,rip-IB,rsp))
    st=uc.mem_read(rsp,0x600)
    for i in range(0,0x600,8):
        v=struct.unpack_from("<Q",st,i)[0]
        if CLO<=v<CHI: print("   [rsp+0x%x] = rva 0x%x"%(i,v-IB))
    print("   last 40 call sites:",[hex(x) for x in calls[-40:]])
    return False
uc.hook_add(UC_HOOK_MEM_READ_UNMAPPED|UC_HOOK_MEM_WRITE_UNMAPPED, unm)
try: jp.render_host(64,block=64); print("render ok")
except Exception as e: print("render exc:",e)
