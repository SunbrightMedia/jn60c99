import struct, sys
from unicorn import *
from unicorn.x86_const import *
from vectors import V
OPS={"mulss":b"\xF3\x0F\x59\xC1","divss":b"\xF3\x0F\x5E\xC1","addss":b"\xF3\x0F\x58\xC1","minss":b"\xF3\x0F\x5D\xC1","maxss":b"\xF3\x0F\x5F\xC1",
     "cvtsd2ss":b"\xF2\x0F\x5A\x40\x10","comiss":b"\x0F\x2F\xC1\x0F\x94\x40\x1C"}
CODE=0x10000; DATA=0x20000
for mx in (0x9FC0,0x1F80):
  for name,op,a,b,d in V:
    uc=Uc(UC_ARCH_X86,UC_MODE_64); uc.mem_map(CODE,0x1000); uc.mem_map(DATA,0x1000)
    cr4=uc.reg_read(UC_X86_REG_CR4); uc.reg_write(UC_X86_REG_CR4,cr4|(1<<9)|(1<<10))
    code=b"\x0F\xAE\x10"+b"\xF3\x0F\x10\x40\x08"+b"\xF3\x0F\x10\x48\x0C"+OPS[op]+b"\xF3\x0F\x11\x40\x18"+b"\x0F\xAE\x58\x04"
    uc.mem_write(CODE,code); uc.mem_write(DATA,struct.pack("<IIIIQII",mx,0,a,b,d,0xDEADBEEF,0))
    uc.reg_write(UC_X86_REG_RAX,DATA); uc.emu_start(CODE,CODE+len(code))
    m=uc.mem_read(DATA,32); out=struct.unpack_from("<I",m,24)[0]; mo=struct.unpack_from("<I",m,4)[0]; zf=m[28]
    print("UC  mx=%04x %-32s out=%08x mxcsr_after=%04x zf=%d"%(mx,name,out,mo,zf))
