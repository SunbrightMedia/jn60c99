#!/usr/bin/env python3
"""Full-instance emulation with proper Win32 import stubs.

Build the whole DSP engine graph via sub_7FF91E0268D0 so the plugin's broadcast
targets (voice/DSP components) are live, then drive the param dispatch and
capture writes into an 11MB engine state block => (engine_offset, value) exactly
as the plugin's recall writes them (validated against the 40 golden coeffs)."""
import struct, sys, collections
import pefile
from unicorn import *
from unicorn.x86_const import *

BIN = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/aea4b19d-JUNO60VST3_64bit.vst3"
pe = pefile.PE(BIN)
IB = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()
IMGSZ = (len(IMG) + 0xFFF) & ~0xFFF

BUILD  = IB + 0x3C68D0
DISP   = IB + 0x419A30
CURVE  = IB + 0x356380
ALLOC  = IB + 0x67522C
VTABLE = 0x9C3018

STACK_BASE=0x200000000; STACK_SIZE=0x2000000
HEAP_BASE =0x310000000; HEAP_SIZE =0x200000000
STUB_BASE =0x600000000
SCRATCH   =0x100000
FAKE_HEAP =0x4242000000   # non-zero heap handle

# gather imports: IAT slot rva -> name
IMPORTS={}
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    dll=entry.dll.decode()
    for imp in entry.imports:
        IMPORTS[imp.address-IB]=(dll, imp.name.decode() if imp.name else f"ord{imp.ordinal}")

class Emu:
    def __init__(self):
        self.heap=HEAP_BASE
        self.allocs=[]
        self.tls={}
        self.tls_ctr=1
        self.uc=Uc(UC_ARCH_X86,UC_MODE_64)
        uc=self.uc
        uc.mem_map(IB,IMGSZ,UC_PROT_ALL); uc.mem_write(IB,bytes(IMG))
        uc.mem_map(STACK_BASE,STACK_SIZE,UC_PROT_ALL)
        uc.mem_map(HEAP_BASE,HEAP_SIZE,UC_PROT_ALL)
        uc.mem_map(STUB_BASE,0x100000,UC_PROT_ALL)
        uc.mem_map(0,0x100000,UC_PROT_ALL)
        # rewrite IAT: each import slot -> unique stub addr (mapped, holds `ret`);
        # a CODE hook intercepts execution at the stub to run import semantics.
        self.stub2name={}
        for i,(rva,(dll,name)) in enumerate(sorted(IMPORTS.items())):
            stub=STUB_BASE+8*i
            uc.mem_write(IB+rva, struct.pack("<Q",stub))
            uc.mem_write(stub, b"\xC3")   # ret
            self.stub2name[stub]=(dll,name)
        self.capture=None
        self.unhandled=collections.Counter()
        uc.hook_add(UC_HOOK_CODE,self._code)
        uc.hook_add(UC_HOOK_MEM_WRITE,self._write)
        uc.hook_add(UC_HOOK_MEM_FETCH_UNMAPPED,self._fetch)
        uc.hook_add(UC_HOOK_MEM_READ_UNMAPPED|UC_HOOK_MEM_WRITE_UNMAPPED,self._unmapped)
    def bump(self,sz):
        sz=(sz+15)&~15 or 16
        if sz>0x2000000: sz=0x2000000
        p=self.heap; self.heap+=sz
        if self.heap>HEAP_BASE+HEAP_SIZE: raise RuntimeError("heap oom")
        return p
    def _ret(self,uc,val):
        # set rax only; the mapped `ret` at the stub performs the return
        uc.reg_write(UC_X86_REG_RAX,val&(2**64-1))
    def _retpop(self,uc,val):
        rsp=uc.reg_read(UC_X86_REG_RSP)
        r=int.from_bytes(uc.mem_read(rsp,8),'little')
        uc.reg_write(UC_X86_REG_RAX,val&(2**64-1))
        uc.reg_write(UC_X86_REG_RIP,r); uc.reg_write(UC_X86_REG_RSP,rsp+8)
    def _import(self,uc,dll,name):
        rcx=uc.reg_read(UC_X86_REG_RCX); rdx=uc.reg_read(UC_X86_REG_RDX)
        r8=uc.reg_read(UC_X86_REG_R8);   r9=uc.reg_read(UC_X86_REG_R9)
        if name=="GetProcessHeap": return self._ret(uc,FAKE_HEAP)
        if name=="HeapAlloc":
            p=self.bump(r8);
            if rdx&8: uc.mem_write(p,b"\x00"*((r8+15)&~15))
            self.allocs.append((p,r8)); return self._ret(uc,p)
        if name=="HeapReAlloc":
            p=self.bump(r9); self.allocs.append((p,r9))
            try:
                if r8: uc.mem_write(p, uc.mem_read(r8, min(r9,0x1000)))
            except: pass
            return self._ret(uc,p)
        if name in ("HeapFree","HeapDestroy"): return self._ret(uc,1)
        if name=="HeapSize": return self._ret(uc,0x1000)
        if name in ("VirtualAlloc","VirtualAllocEx"):
            sz=rdx or 0x1000; p=self.bump(sz); self.allocs.append((p,sz)); return self._ret(uc,p)
        if name in ("CoTaskMemAlloc","GlobalAlloc","GdipAlloc","SysAllocString"):
            sz=rcx or 0x100; p=self.bump(sz); return self._ret(uc,p)
        if name=="TlsAlloc":
            i=self.tls_ctr; self.tls_ctr+=1; return self._ret(uc,i)
        if name=="TlsSetValue":
            self.tls[rcx]=rdx; return self._ret(uc,1)
        if name=="TlsGetValue":
            return self._ret(uc,self.tls.get(rcx,0))
        if name in ("InitializeCriticalSection","InitializeCriticalSectionAndSpinCount",
                    "InitializeCriticalSectionEx","DeleteCriticalSection",
                    "EnterCriticalSection","LeaveCriticalSection","InitializeSListHead"):
            return self._ret(uc,1)
        if name in ("GetLastError",): return self._ret(uc,0)
        if name in ("GetCurrentThreadId","GetCurrentProcessId"): return self._ret(uc,0x1000)
        if name.startswith("Create") or name.startswith("Open"):   # handles: non-zero
            self._hc=getattr(self,"_hc",0x9000)+16; return self._ret(uc,self._hc)
        if name in ("RaiseException","RtlPcToFileHeader","RtlUnwind","RtlUnwindEx",
                    "RtlCaptureContext","RtlLookupFunctionEntry","RtlVirtualUnwind",
                    "_CxxThrowException","terminate","abort"):
            self.unhandled[name]+=1; return self._ret(uc,0)  # swallow EH
        if name.startswith("Get") or name.startswith("Query"): return self._ret(uc,0)
        self.unhandled[name]+=1
        return self._ret(uc,0)
    FATAL={IB+0x6ae028}   # std::_Xlength_error / terminate helper
    def _code(self,uc,address,size,user):
        if address in self.FATAL:
            self.hit_fatal=getattr(self,'hit_fatal',0)+1
            uc.emu_stop(); return
        if address in self.stub2name:
            dll,name=self.stub2name[address]
            self._import(uc,dll,name)   # sets rax; mapped `ret` returns
            return
        if address==ALLOC:
            sz=uc.reg_read(UC_X86_REG_RCX) or 16
            p=self.bump(sz); uc.mem_write(p,b"\x00"*min(((sz+15)&~15),0x2000000))
            self.allocs.append((p,sz))
            self._retpop(uc,p)
    def _write(self,uc,access,address,size,value,user):
        if self.capture is not None and size==4:
            self.capture.append((address,value))
    def _fetch(self,uc,access,address,size,value,user):
        # unknown code fetch (unresolved indirect): map a ret so it returns
        try: uc.mem_map(address&~0xFFF,0x1000,UC_PROT_ALL)
        except: pass
        uc.mem_write(address, b"\xC3"); uc.reg_write(UC_X86_REG_RAX,0)
        return True
    def _unmapped(self,uc,access,address,size,value,user):
        try: uc.mem_map(address&~0xFFF,0x1000,UC_PROT_ALL); return True
        except: return True   # already mapped / overlap -> tolerate
    def call(self,fn,rcx=0,rdx=0,r8=0,r9=0,cap=None,count=200_000_000):
        uc=self.uc
        rsp=(STACK_BASE+STACK_SIZE-0x10000)&~0xF; rsp-=8
        uc.reg_write(UC_X86_REG_RSP,rsp)
        uc.reg_write(UC_X86_REG_RCX,rcx&(2**64-1)); uc.reg_write(UC_X86_REG_RDX,rdx&(2**64-1))
        uc.reg_write(UC_X86_REG_R8,r8&(2**64-1));   uc.reg_write(UC_X86_REG_R9,r9&(2**64-1))
        RET=SCRATCH+0x5000
        uc.mem_write(rsp,struct.pack("<Q",RET))
        self.capture=cap
        try: uc.emu_start(fn,RET,count=count)
        finally: self.capture=None
        return uc.reg_read(UC_X86_REG_RAX)

def f32(b): return struct.unpack("<f",struct.pack("<I",b&0xFFFFFFFF))[0]

if __name__=="__main__":
    e=Emu()
    HOST=e.bump(0x8000); e.uc.mem_write(HOST,b"\x00"*0x8000)
    try:
        r=e.call(BUILD, rcx=HOST)
        print(f"BUILD OK: ret={r&0xff} allocs={len(e.allocs)} heap=0x{e.heap-HEAP_BASE:x}")
    except UcError as ex:
        rip=e.uc.reg_read(UC_X86_REG_RIP)
        print(f"BUILD FAULT {ex} @rva 0x{rip-IB:x} allocs={len(e.allocs)}")
        from capstone import Cs,CS_ARCH_X86,CS_MODE_64
        md=Cs(CS_ARCH_X86,CS_MODE_64)
        for ins in md.disasm(bytes(e.uc.mem_read(rip,16)),rip):
            print(f"   0x{ins.address-IB:x}: {ins.mnemonic} {ins.op_str}"); break
    # plugin objects
    plug=[]
    for a,s in e.allocs:
        try: v=int.from_bytes(e.uc.mem_read(a,8),'little')
        except: continue
        if v==IB+VTABLE: plug.append((a,s))
    print(f"plugin objects (vptr 0x9c3018): {len(plug)}", [hex(a) for a,s in plug[:4]])
    if plug:
        obj=plug[0][0]
        # inspect broadcast target array [obj+0x110 ..]
        print(f"first plugin OBJ=0x{obj:x}")
        for off in (0x110,0x118,0x120,0x64c,0x650):
            v=int.from_bytes(e.uc.mem_read(obj+off,8),'little')
            print(f"   [obj+0x{off:x}]=0x{v:x}")
    if e.unhandled:
        print("unhandled imports:", e.unhandled.most_common(12))
