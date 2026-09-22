import sys, os, struct
sys.path.insert(0,'gen'); import jp8_emu as J
from unicorn import *; from unicorn.x86_const import *
IB=J.IB; CLO,CHI=IB+0x1000,IB+0x9b6a38
class D(J.JP8):
    shown=0
    def bt(self,uc,label):
        rip=uc.reg_read(UC_X86_REG_RIP); rsp=uc.reg_read(UC_X86_REG_RSP)
        out=["%s at rva 0x%x rsp 0x%x rax=0x%x rcx=0x%x rdx=0x%x r8=0x%x"%(label,rip-IB,rsp,uc.reg_read(UC_X86_REG_RAX),uc.reg_read(UC_X86_REG_RCX),uc.reg_read(UC_X86_REG_RDX),uc.reg_read(UC_X86_REG_R8))]
        st=uc.mem_read(rsp,0x400)
        for i in range(0,0x400,8):
            v=struct.unpack_from("<Q",st,i)[0]
            if CLO<=v<CHI: out.append("   [rsp+0x%x] = rva 0x%x"%(i,v-IB))
        print("\n".join(out[:16]), flush=True)
    def _fetch(self,uc,access,address,size,value,user):
        if self.shown<4: self.shown+=1; self.bt(uc,"FETCH UNMAPPED 0x%x"%address)
        return super()._fetch(uc,access,address,size,value,user)
    def _unmapped_map(self,uc,access,address,size,value,user):
        if self.shown<4: self.shown+=1; self.bt(uc,"UNMAPPED %s 0x%x"%("W" if access==UC_MEM_WRITE_UNMAPPED else "R",address))
        return super()._unmapped_map(uc,access,address,size,value,user)
jp=D(); uc=jp.uc
a,b=J.XC_TABLE
ptrs=struct.unpack("<%dQ"%((b-a)//8), uc.mem_read(IB+a, b-a))
try: jp.call(ptrs[1], count=2_000_000)
except Exception as e: print("exc",e)
print("faults",jp.faults)
