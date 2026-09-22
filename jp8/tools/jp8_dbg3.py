import sys, os, struct, types
sys.path.insert(0,'gen'); import jp8_emu as J
from unicorn import *; from unicorn.x86_const import *
jp=J.JP8(); uc=jp.uc; IB=J.IB
CLO,CHI=IB+0x1000,IB+0x9b6a38
def bt(uc,label):
    rip=uc.reg_read(UC_X86_REG_RIP); rsp=uc.reg_read(UC_X86_REG_RSP)
    out=["%s at rva 0x%x rsp 0x%x rax=0x%x rcx=0x%x rdx=0x%x r8=0x%x r9=0x%x"%(label,rip-IB,rsp,uc.reg_read(UC_X86_REG_RAX),uc.reg_read(UC_X86_REG_RCX),uc.reg_read(UC_X86_REG_RDX),uc.reg_read(UC_X86_REG_R8),uc.reg_read(UC_X86_REG_R9))]
    st=uc.mem_read(rsp,0x800)
    for i in range(0,0x800,8):
        v=struct.unpack_from("<Q",st,i)[0]
        if CLO<=v<CHI: out.append("   [rsp+0x%x] = rva 0x%x"%(i,v-IB))
    print("\n".join(out[:28]), flush=True)
shown=[0]
orig_fetch=jp._fetch; orig_unm=jp._unmapped_map
def my_fetch(uc,access,address,size,value,user):
    if shown[0]<3: shown[0]+=1; bt(uc,"FETCH UNMAPPED 0x%x"%address)
    return orig_fetch(uc,access,address,size,value,user)
def my_unm(uc,access,address,size,value,user):
    if shown[0]<3: shown[0]+=1; bt(uc,"UNMAPPED %s 0x%x"%("W" if access==UC_MEM_WRITE_UNMAPPED else "R",address))
    return orig_unm(uc,access,address,size,value,user)
jp._fetch=my_fetch; jp._unmapped_map=my_unm
# re-register hooks (the originals were bound at __init__)
uc.hook_add(UC_HOOK_MEM_FETCH_UNMAPPED, my_fetch)
jp.run_static_init(); print("static done faults",jp.faults, flush=True)
jp.build(); jp.set_ftz(); jp.set_sr(44100.0); jp.host_init(); jp.recall(0); jp.snap_ramps(); jp.clear_latch()
print("booted, faults",jp.faults, flush=True)
shown[0]=0
try: jp.render_host(64,block=64); print("render ok")
except Exception as e: print("render exc:",e)
