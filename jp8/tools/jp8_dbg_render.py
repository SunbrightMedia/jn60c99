import sys, os, struct, time
sys.path.insert(0,'gen'); import jp8_emu as J
from unicorn import *; from unicorn.x86_const import *
jp=J.JP8(); uc=jp.uc; IB=J.IB
jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); jp.host_init(); jp.recall(0); jp.snap_ramps(); jp.clear_latch()
print("booted, faults",jp.faults, flush=True)
trace=[]
def code(uc,address,size,user):
    trace.append(address-IB)
    if len(trace)>24: trace.pop(0)
uc.hook_add(UC_HOOK_CODE, code, begin=IB, end=IB+J.IMGSZ)
def unm(uc,access,address,size,value,user):
    rip=uc.reg_read(UC_X86_REG_RIP)
    print("UNMAPPED %s addr 0x%x size %d at rva 0x%x  rcx=0x%x rdx=0x%x rax=0x%x r12=0x%x"%("W" if access==UC_MEM_WRITE_UNMAPPED else "R",address,size,rip-IB,
          uc.reg_read(UC_X86_REG_RCX),uc.reg_read(UC_X86_REG_RDX),uc.reg_read(UC_X86_REG_RAX),uc.reg_read(UC_X86_REG_R12)), flush=True)
    return False
uc.hook_add(UC_HOOK_MEM_READ_UNMAPPED|UC_HOOK_MEM_WRITE_UNMAPPED, unm)
try:
    L,R=jp.render_host(64,block=64); print("render ok peak",max(abs(x) for x in L))
except Exception as e:
    print("render exc:",e)
    print("last rvas:",[hex(x) for x in trace])
    print("rsp=0x%x"%uc.reg_read(UC_X86_REG_RSP))
