import emu2, struct
from emu2 import IB, STACK_BASE, STACK_SIZE, SCRATCH
from unicorn import UcError
from unicorn.x86_const import *
reads=[int(x) for x in open('/tmp/masterreads.txt')]
e=emu2.Emu(); HOST=e.bump(0x8000); e.uc.mem_write(HOST,b"\x00"*0x8000)
try: e.call(emu2.BUILD, rcx=HOST)
except UcError: pass
uc=e.uc
ST=sorted([a for a,s in e.allocs if s==0xA83010])[0]
# snap-all (defaults + output stage)
try: e.call(IB+0x3C29B0, rcx=ST, count=400_000_000)
except UcError as ex: print("# snapall", ex)
# setSampleRate (structural last)
rsp=((STACK_BASE+STACK_SIZE-0x10000)&~0xF)-8
uc.reg_write(UC_X86_REG_RSP,rsp); uc.reg_write(UC_X86_REG_RCX,HOST)
uc.reg_write(UC_X86_REG_XMM1, struct.unpack('<Q',struct.pack('<f',96000.0)+b'\0\0\0\0')[0])
uc.mem_write(rsp,struct.pack("<Q",SCRATCH+0x5000))
try: uc.emu_start(IB+0x3C7A20, SCRATCH+0x5000, count=800_000_000)
except UcError: pass
out=open('/tmp/binseq_master.txt','w')
for o in reads:
    v=struct.unpack("<I",uc.mem_read(ST+o,4))[0]
    out.write(f"{o} {v:08x}\n")
out.close()
print("dumped", len(reads), "master offsets (BUILD->snap-all->setSampleRate)")
