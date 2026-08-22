#!/usr/bin/env python3
"""jx_emu.py -- JX-3P full-instance engine under Unicorn (the JX twin of
e2e_emu.py). WORK IN PROGRESS: this file stands the harness up incrementally,
each entry point PROVEN by execution, never guessed. Import it and call the
probes; nothing here is asserted true until its probe runs green.

Ground-truth paths via truth.py-style resolution against jx3p/truth/.
"""
import os, sys, struct, collections
import pefile
from unicorn import *
from unicorn.x86_const import *

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BIN  = os.path.join(REPO, "jx3p", "truth", "JX3P.vst3")
pe = pefile.PE(BIN)
IB  = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()
IMGSZ = (len(IMG) + 0xFFF) & ~0xFFF

# PROVEN so far (READ from the dump / cross-checked S2). Construction entries are
# discovered by probe below, not hardcoded.
PROC_VPTR = IB + 0x9F9A90     # CPrmDSPJx3pPlugin vtable (S2 RTTI-located)
DISPATCH  = IB + 0x3EBB00     # Plugin slot 11 (S2 vtable-slot transfer)
ALLOC     = IB + 0x6AB63C     # CRT allocator twin (byte-pattern, unique match)
BUILD     = IB + 0x3F8610     # PROVEN by probe: builds 9 units of STATE_SZ
VOICE_WRAP= IB + 0x377080     # (state, voiceIdx, DWORD** outPair) -- JUNO twin
MASTER_WRAP=IB + 0x377010     # (state, a2[16], DWORD** outPair) -- JUNO twin
STATE_SZ  = 0xAAC310
N_UNITS   = 9

STACK_BASE=0x200000000; STACK_SIZE=0x2000000
HEAP_BASE =0x310000000; HEAP_SIZE =0x200000000
STUB_BASE =0x600000000
SCRATCH   =0x100000
FAKE_HEAP =0x4242000000
CODE_BASE =STUB_BASE+0x8000
PB_VOICE  =STUB_BASE+0xA000
PB_MASTER =STUB_BASE+0xA100
BUF_BASE  =0x700000000
BUF_SIZE  =0x400000

IMPORTS={}
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    dll=entry.dll.decode()
    for imp in entry.imports:
        IMPORTS[imp.address-IB]=(dll, imp.name.decode() if imp.name else f"ord{imp.ordinal}")

class _Asm:
    def __init__(self): self.b=bytearray(); self.labels={}; self.fix=[]
    def raw(self,*bs): self.b+=bytes(bs)
    def label(self,n): self.labels[n]=len(self.b)
    def jnz(self,n): self.b+=b"\x75"; self.fix.append((len(self.b),n)); self.b+=b"\x00"
    def movabs_rbp(self,imm): self.b+=b"\x48\xBD"+struct.pack("<Q",imm)
    def movabs_rax(self,imm): self.b+=b"\x48\xB8"+struct.pack("<Q",imm)
    def done(self):
        for pos,n in self.fix:
            rel=self.labels[n]-(pos+1); assert -128<=rel<128; self.b[pos]=rel&0xFF
        return bytes(self.b)

def _voice_stub(pb, fn):
    a=_Asm(); a.raw(0x55); a.movabs_rbp(pb); a.raw(0x48,0x83,0xEC,0x30)
    a.label("loop")
    a.raw(0x48,0x8B,0x45,0x10); a.raw(0x48,0x89,0x45,0x28)   # a3[0]=pMain
    a.raw(0x48,0x8B,0x45,0x18); a.raw(0x48,0x89,0x45,0x30)   # a3[1]=pSub
    a.raw(0x48,0x8B,0x4D,0x00)                                # rcx=state
    a.raw(0x8B,0x55,0x08)                                     # edx=voice
    a.raw(0x4C,0x8D,0x45,0x28)                                # r8=&a3
    a.movabs_rax(fn); a.raw(0xFF,0xD0)
    a.raw(0x48,0x83,0x45,0x10,0x04); a.raw(0x48,0x83,0x45,0x18,0x04)
    a.raw(0x48,0xFF,0x4D,0x20); a.jnz("loop")
    a.raw(0x48,0x83,0xC4,0x30); a.raw(0x5D); a.raw(0xC3); return a.done()

def _master_stub(pb, fn):
    a=_Asm(); a.raw(0x55); a.movabs_rbp(pb); a.raw(0x48,0x83,0xEC,0x30)
    a.label("loop")
    a.raw(0x48,0x8B,0x45,0x08); a.raw(0x48,0x89,0x45,0x20)   # a3[0]=pL
    a.raw(0x48,0x8B,0x45,0x10); a.raw(0x48,0x89,0x45,0x28)   # a3[1]=pR
    a.raw(0x48,0x8B,0x4D,0x00)                                # rcx=state8
    a.raw(0x48,0x8D,0x55,0x30)                                # rdx=&a2[16]
    a.raw(0x4C,0x8D,0x45,0x20)                                # r8=&a3
    a.movabs_rax(fn); a.raw(0xFF,0xD0)
    a.raw(0x48,0x8D,0x4D,0x30); a.raw(0xB8,0x10,0x00,0x00,0x00)
    a.label("adv"); a.raw(0x48,0x83,0x01,0x04); a.raw(0x48,0x83,0xC1,0x08)
    a.raw(0xFF,0xC8); a.jnz("adv")
    a.raw(0x48,0x83,0x45,0x08,0x04); a.raw(0x48,0x83,0x45,0x10,0x04)
    a.raw(0x48,0xFF,0x4D,0x18); a.jnz("loop")
    a.raw(0x48,0x83,0xC4,0x30); a.raw(0x5D); a.raw(0xC3); return a.done()

class JX:
    def __init__(self):
        self.heap=HEAP_BASE; self.allocs=[]; self.tls={}; self.tls_ctr=1
        self.unhandled=collections.Counter(); self.newsizes=collections.Counter()
        self.uc=uc=Uc(UC_ARCH_X86,UC_MODE_64)
        uc.mem_map(IB,IMGSZ,UC_PROT_ALL); uc.mem_write(IB,bytes(IMG))
        uc.mem_map(STACK_BASE,STACK_SIZE,UC_PROT_ALL)
        uc.mem_map(HEAP_BASE,HEAP_SIZE,UC_PROT_ALL)
        uc.mem_map(STUB_BASE,0x100000,UC_PROT_ALL)
        uc.mem_map(0,0x100000,UC_PROT_ALL)
        uc.mem_map(BUF_BASE,BUF_SIZE,UC_PROT_ALL)
        cr0=uc.reg_read(UC_X86_REG_CR0); cr0&=~(1<<2); cr0|=(1<<1); uc.reg_write(UC_X86_REG_CR0,cr0)
        cr4=uc.reg_read(UC_X86_REG_CR4); cr4|=(1<<9)|(1<<10); uc.reg_write(UC_X86_REG_CR4,cr4)
        self.stub2name={}
        for i,(rva,(dll,name)) in enumerate(sorted(IMPORTS.items())):
            stub=STUB_BASE+8*i
            uc.mem_write(IB+rva, struct.pack("<Q",stub)); uc.mem_write(stub,b"\xC3")
            self.stub2name[stub]=(dll,name)
        stub_end=STUB_BASE+8*len(IMPORTS)+8
        uc.hook_add(UC_HOOK_CODE,self._imp,begin=STUB_BASE,end=stub_end)
        uc.hook_add(UC_HOOK_CODE,self._alloc,begin=ALLOC,end=ALLOC)
        uc.hook_add(UC_HOOK_MEM_FETCH_UNMAPPED,self._fetch)
        uc.hook_add(UC_HOOK_MEM_READ_UNMAPPED|UC_HOOK_MEM_WRITE_UNMAPPED,self._unmapped)
        self.faults=0
        # per-sample loop stubs (voice + master), reused from the JUNO harness --
        # the calling convention is identical (proven: same signatures).
        self.SVOICE=CODE_BASE
        uc.mem_write(self.SVOICE, _voice_stub(PB_VOICE, VOICE_WRAP))
        self.SMASTER=CODE_BASE+0x400
        uc.mem_write(self.SMASTER, _master_stub(PB_MASTER, MASTER_WRAP))
    def bump(self,sz):
        sz=(sz+15)&~15 or 16
        if sz>0x2000000: sz=0x2000000
        p=self.heap; self.heap+=sz
        if self.heap>HEAP_BASE+HEAP_SIZE: raise RuntimeError("heap oom")
        return p
    def _ret(self,uc,val): uc.reg_write(UC_X86_REG_RAX,val&(2**64-1))
    def _imp(self,uc,address,size,user):
        if address not in self.stub2name: return
        dll,name=self.stub2name[address]
        rcx=uc.reg_read(UC_X86_REG_RCX); rdx=uc.reg_read(UC_X86_REG_RDX)
        r8=uc.reg_read(UC_X86_REG_R8)
        if name=="GetProcessHeap": return self._ret(uc,FAKE_HEAP)
        if name in ("HeapAlloc","calloc"):
            p=self.bump(r8 or rdx or 16)
            uc.mem_write(p,b"\x00"*min(((r8 or rdx or 16)+15)&~15,0x2000000))
            self.allocs.append((p,r8 or rdx or 16)); return self._ret(uc,p)
        if name in ("malloc","??2@YAPEAX_K@Z","operator new"):
            self.newsizes[rcx]+=1; p=self.bump(rcx or 16); self.allocs.append((p,rcx or 16))
            return self._ret(uc,p)
        if name=="HeapReAlloc":
            p=self.bump(uc.reg_read(UC_X86_REG_R9)); return self._ret(uc,p)
        if name in ("HeapFree","HeapDestroy","free","??3@YAXPEAX@Z"): return self._ret(uc,1)
        if name in ("VirtualAlloc","VirtualAllocEx"):
            sz=rdx or 0x1000; p=self.bump(sz); self.allocs.append((p,sz)); return self._ret(uc,p)
        if name in ("CoTaskMemAlloc","GlobalAlloc","GdipAlloc","SysAllocString"):
            sz=rcx or 0x100; p=self.bump(sz); return self._ret(uc,p)
        if name=="TlsAlloc": i=self.tls_ctr; self.tls_ctr+=1; return self._ret(uc,i)
        if name=="TlsSetValue": self.tls[rcx]=rdx; return self._ret(uc,1)
        if name=="TlsGetValue": return self._ret(uc,self.tls.get(rcx,0))
        if name.startswith("Initialize") or name in ("EnterCriticalSection","LeaveCriticalSection","DeleteCriticalSection"):
            return self._ret(uc,1)
        if name in ("GetCurrentThreadId","GetCurrentProcessId"): return self._ret(uc,0x1000)
        if name.startswith("Create") or name.startswith("Open"):
            self._hc=getattr(self,"_hc",0x9000)+16; return self._ret(uc,self._hc)
        self.unhandled[name]+=1; return self._ret(uc,0)
    def _alloc(self,uc,address,size,user):
        if address!=ALLOC: return
        sz=uc.reg_read(UC_X86_REG_RCX) or 16
        p=self.bump(sz); uc.mem_write(p,b"\x00"*min(((sz+15)&~15),0x2000000))
        self.allocs.append((p,sz))
        rsp=uc.reg_read(UC_X86_REG_RSP); r=int.from_bytes(uc.mem_read(rsp,8),'little')
        uc.reg_write(UC_X86_REG_RAX,p); uc.reg_write(UC_X86_REG_RIP,r); uc.reg_write(UC_X86_REG_RSP,rsp+8)
    def _fetch(self,uc,access,address,size,value,user):
        try: uc.mem_map(address&~0xFFF,0x1000,UC_PROT_ALL)
        except: pass
        uc.mem_write(address,b"\xC3"); uc.reg_write(UC_X86_REG_RAX,0); self.faults+=1; return True
    def _unmapped(self,uc,access,address,size,value,user):
        self.faults+=1
        try: uc.mem_map(address&~0xFFF,0x1000,UC_PROT_ALL); return True
        except: return True
    def call(self,fn,rcx=0,rdx=0,r8=0,r9=0,count=0):
        uc=self.uc
        uc.reg_write(UC_X86_REG_MXCSR, getattr(self,'_mxcsr',0x1F80))
        rsp=(STACK_BASE+STACK_SIZE-0x10000)&~0xF; rsp-=8
        uc.reg_write(UC_X86_REG_RSP,rsp)
        for reg,v in ((UC_X86_REG_RCX,rcx),(UC_X86_REG_RDX,rdx),(UC_X86_REG_R8,r8),(UC_X86_REG_R9,r9)):
            uc.reg_write(reg,v&(2**64-1))
        RET=SCRATCH+0x5000; uc.mem_write(rsp,struct.pack("<Q",RET))
        uc.emu_start(fn,RET,count=count)
        rip=uc.reg_read(UC_X86_REG_RIP)
        if rip!=RET: raise RuntimeError("call 0x%x stopped rva 0x%x"%(fn-IB,rip-IB))
        return uc.reg_read(UC_X86_REG_RAX)

    def set_ftz(self):
        self._mxcsr=0x9FC0
        """Match the plugin's DSP FP environment: FTZ|DAZ + all exceptions
        masked (MXCSR 0x9FC0), the same env the JUNO engine runs in and the
        one the C port compiles against. Without this the emulated render keeps
        denormals the real plugin would flush, so the reference diverges from a
        correct transcription on every denormal-producing cell."""
        self.uc.reg_write(UC_X86_REG_MXCSR, 0x9FC0)
    def _run(self,stub):
        uc=self.uc
        uc.reg_write(UC_X86_REG_MXCSR, getattr(self,'_mxcsr',0x1F80))
        rsp=(STACK_BASE+STACK_SIZE-0x10000)&~0xF; rsp-=8
        uc.reg_write(UC_X86_REG_RSP,rsp)
        RET=SCRATCH+0x5000; uc.mem_write(rsp,struct.pack("<Q",RET))
        uc.emu_start(stub,RET,count=0)
        rip=uc.reg_read(UC_X86_REG_RIP)
        if rip!=RET: raise RuntimeError("stub stopped rva 0x%x"%(rip-IB))
    def build(self):
        self.HOST=self.bump(0x8000); self.uc.mem_write(self.HOST,b"\x00"*0x8000)
        self.call(BUILD, rcx=self.HOST)
        u=self.uc; self.state=[]; self.proc=[]
        for i in range(N_UNITS):
            self.state.append(int.from_bytes(u.mem_read(self.HOST+80+64*i,8),'little'))
            self.proc.append(int.from_bytes(u.mem_read(self.HOST+96+64*i,8),'little'))
        big=[a for a,s in self.allocs if s==STATE_SZ]
        assert len(big)>=N_UNITS, "state allocs %d"%len(big)
        for i in range(N_UNITS):
            vp=int.from_bytes(u.mem_read(self.proc[i],8),'little')
            assert vp==PROC_VPTR, "unit%d proc vptr 0x%x"%(i,vp)
        return self
    def dispatch(self,unit,idx,val,flag=1):
        return self.call(DISPATCH, rcx=self.proc[unit], rdx=idx, r8=flag, r9=val)
    def render(self, n, block=256):
        uc=self.uc; Lout=[]; Rout=[]
        offs={}; p=BUF_BASE
        for v in range(8):
            offs[('m',v)]=p; p+=4*block; offs[('s',v)]=p; p+=4*block
        offL=p; p+=4*block; offR=p; p+=4*block
        assert p<BUF_BASE+BUF_SIZE
        done=0
        while done<n:
            b=min(block,n-done)
            for v in range(8):
                uc.mem_write(PB_VOICE, struct.pack("<QQQQQ",
                    self.state[v], v, offs[('m',v)], offs[('s',v)], b))
                self._run(self.SVOICE)
            a2=b"".join(struct.pack("<Q",x) for pair in
                        ((offs[('m',v)],offs[('s',v)]) for v in range(8)) for x in pair)
            uc.mem_write(PB_MASTER, struct.pack("<QQQQ", self.state[8], offL, offR, b)
                         + b"\x00"*16 + a2)
            self._run(self.SMASTER)
            Lout+=list(struct.unpack("<%dI"%b, uc.mem_read(offL,4*b)))
            Rout+=list(struct.unpack("<%dI"%b, uc.mem_read(offR,4*b)))
            done+=b
        return Lout,Rout

def probe_build(candidates):
    """Call each candidate with rcx=fresh HOST; the real BUILD allocates several
    EQUAL large state blocks and leaves HOST pointing at objects whose first
    qword is PROC_VPTR. Reports the allocation signature of each."""
    from collections import Counter
    for rva in candidates:
        try:
            jx=JX()
            HOST=jx.bump(0x8000); jx.uc.mem_write(HOST,b"\x00"*0x8000)
            before=len(jx.allocs)
            try:
                jx.call(IB+rva, rcx=HOST, count=20_000_000)
            except Exception as e:
                pass
            sizes=Counter(s for _,s in jx.allocs[before:])
            big=[(s,n) for s,n in sizes.items() if s>0x100000]
            # scan HOST for pointers to objects whose first qword == PROC_VPTR
            unit_ptrs=0
            for off in range(0,0x8000,8):
                p=int.from_bytes(jx.uc.mem_read(HOST+off,8),'little')
                if HEAP_BASE<=p<jx.heap:
                    try:
                        vp=int.from_bytes(jx.uc.mem_read(p,8),'little')
                        if vp==PROC_VPTR: unit_ptrs+=1
                    except: pass
            print("cand 0x%X: allocs=%d big-blocks=%s proc-vptr-units=%d faults=%d"%(
                rva,len(jx.allocs)-before,big[:4],unit_ptrs,jx.faults))
        except Exception as e:
            print("cand 0x%X: harness error %s"%(rva,e))

if __name__=="__main__":
    # default probe set: host-region non-render candidates
    cands=[0x3F8610,0x3F3700,0x3F1030,0x3EA250,0x3F66B0,0x3F4C50,0x3E02E0,0x3F52F0,0x3E6660,0x3DD890]
    probe_build(cands)
