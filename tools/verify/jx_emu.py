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

# ABI LEDGER (tools/verify/abi_check.py, 2026-09-05 -- METHOD_PLAYBOOK 87).
# Every entry below was disassembled; the register each argument is READ
# from is recorded here. A call that fills a different register is WRONG
# whatever the gates say (the SETSR rdx-vs-xmm1 defect hid for the whole port).
SETSR     = IB + 0x3F9970     # (rcx=HOST, xmm1=float rate)   -- FLOAT IN XMM1
NOTEON    = IB + 0x3F9150     # (rcx=HOST, dl=note, r8b=vel)  engine vtbl 0x80
NOTEOFF   = IB + 0x3F90F0     # (rcx=HOST, dl=note, r8b=vel)  engine vtbl 0x78
ASG_NOTIFY= IB + 0x356BF0     # (rcx=assign obj, edx=what)    JUNO twin 0x3549B0
HOSTPARAM = IB + 0x3F9A30     # (rcx=HOST, edx=host id, r8d=val) -- needs the
                              # controller-built id map at .data 0xCE9038
POPULATE  = IB + 0xAD480      # fills that map (= the JUNO's 0xAD5A0, fw_map --pair; READ) -- one of the
                              # static initializers: after run_static_init the map holds 744 ids (678
                              # model ids 0x0060xxxx / 0x00A0xxxx), equal to the booted plugin's (EXECUTED)
PATCH_RECORDS = os.path.join(REPO, "jx3p", "gen", "jx_patch_records.json")   # jx_patch_records.py
FACTORY   = IB + 0x3F84E0     # the engine factory (no args): ALLOC(0x880) + ctor inline; rax = HOST (READ)
HOST_SZ   = 0x880             # its ALLOC size (`mov ecx,0x880` at 0x3F84F4, READ)
ENGINE_VTBL = IB + 0xA15B88   # slots: 08 BUILD 18 SETSR 38 RENDER 78 NOTEOFF
RENDER    = IB + 0x3F9220     # the engine render (vtable 0x38): render_engine() below
                              #        80 NOTEON 70 HOSTPARAM (pe_recon vtable)
XC_TABLE  = (0x96C660, 0x96E0C8)   # C++ static initializers (pe_recon crt_init);
                              # they fill .data's runtime tail [0xCE7800,0xCF2860)
LATCH_OFF = 0xAAC308          # per-unit warm-up mute latch (960 at clean boot)

# the factory bank geometry + decode live in jx_bank.py (pure python, so the
# ctypes half of a two-process gate can import the SAME definition without
# pulling Unicorn in). blob_pos = 2*pool - 8: playbook 88, jx_bank_census.py.
from jx_bank import (BANK_HEADER, BANK_STRIDE, BANK_BLOB_OFF, ACTIVE_POOLS,
                     POOL_BASE_ID, bank_bytes, patch_blob, pool_value)

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
        # CRT POINTER OBFUSCATION (defect paid 2026-09-06). WHY identity:
        # the MSVC CRT stores function pointers XORed with a per-process
        # cookie (EncodePointer) and unwraps them with DecodePointer. Our
        # unhandled default returned 0, so a stored pointer decoded to NULL
        # and static initializer 89 (rva 0xb6f30) CALLED ADDRESS 0x60 --
        # UC_ERR_INSN_INVALID. Its half-run left the CRT inconsistent and
        # every later BUILD died with UC_ERR_MAP (a 1-minute export became
        # 97 minutes). Identity is a valid encoding: encode(p)==p,
        # decode(p)==p round-trips exactly, which is all the CRT requires.
        if name in ("EncodePointer","DecodePointer",
                    "EncodeSystemPointer","DecodeSystemPointer",
                    "RtlEncodePointer","RtlDecodePointer"):
            return self._ret(uc,rcx)
        if name=="IsDebuggerPresent": return self._ret(uc,0)
        if name=="IsProcessorFeaturePresent": return self._ret(uc,1)
        if name in ("SetUnhandledExceptionFilter","UnhandledExceptionFilter",
                    "RtlCaptureContext","RtlLookupFunctionEntry",
                    "RtlVirtualUnwind","GetSystemInfo","GetSystemTimeAsFileTime",
                    "QueryPerformanceCounter","GetCurrentProcess"):
            return self._ret(uc,0)
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
    # FLOOD GUARD (defect paid 2026-09-06). WHY: three static initializers
    # fail; the CRT then enters its unhandled-exception path
    # (RtlCaptureContext / RtlLookupFunctionEntry / UnhandledExceptionFilter,
    # none of which we shim) and WALKS MEMORY DOWNWARD, faulting a page at a
    # time. Left alone it mapped 32,698 stray pages below the heap, wrecked
    # the address space so BUILD died with UC_ERR_MAP, and turned a 1-minute
    # export into 100 minutes. A crash-walk is never legitimate work, so it
    # is stopped by COUNT (deterministic on every machine, unlike a clock).
    MAX_STRAY_PAGES = 64

    # CTORS SKIPPED BY ADDRESS (defect paid 2026-09-06, all three MEASURED).
    # These three C++ static initializers fault under emulation. Each one's
    # PARTIAL run leaves the CRT inconsistent, and the damage shows up far
    # away: BUILD then dies with UC_ERR_MAP and a 1-minute template export
    # took 97 minutes. Skipping them by ADDRESS is deterministic (an index
    # or a wall-clock cap is not) and provably costs nothing: with all three
    # skipped the boot still fills the same .data tail (3442 B), builds the
    # SAME controller host-id map (0->18, 1->19, 2->20) and host_init writes
    # the same 3 defaults -- while static init drops from 6009 s to 0.2 s.
    #   0xB73A4  UC_ERR_EXCEPTION
    #   0xB6F30  UC_ERR_INSN_INVALID -- releases an object whose vtable is
    #            NULL, so the CFG thunk at 0x913D00 does `jmp rax` with
    #            rax = 0 and execution lands at address 0x60
    #   0x57DEF0 UC_ERR_MAP after a crash-walk (hits the stray-page guard)
    # If a future port needs what these register, transcribe it explicitly;
    # do not "let them run and fail" -- a half-run ctor is worse than none.
    SKIP_CTORS = {0xB73A4, 0xB6F30, 0x57DEF0}

    def _unmapped(self,uc,access,address,size,value,user):
        self._stray = getattr(self, "_stray", 0) + 1
        if self._stray > self.MAX_STRAY_PAGES:
            uc.emu_stop()          # abort THIS call; the caller counts a fail
            return True
        return self._unmapped_map(uc,access,address,size,value,user)

    def _unmapped_map(self,uc,access,address,size,value,user):
        # A silently zero-mapped page HIDES missing data (the JX pulse
        # wavetable region read as zeros for weeks). Map it so the run can
        # continue, but SAY SO: the first few faults go to stderr and the
        # count is always available as .faults. JX_EMU_QUIET=1 silences.
        self.faults+=1
        if self.faults<=8 and os.environ.get("JX_EMU_QUIET")!="1":
            rip=uc.reg_read(UC_X86_REG_RIP)
            sys.stderr.write("jx_emu: UNMAPPED %s 0x%x (size %d) at rva 0x%x -- zero page mapped\n"
                             %("write" if access in (UC_MEM_WRITE_UNMAPPED,) else "read",
                               address,size,rip-IB))
        try: uc.mem_map(address&~0xFFF,0x1000,UC_PROT_ALL); return True
        except: return True
    def call(self,fn,rcx=0,rdx=0,r8=0,r9=0,count=0,timeout_us=0):
        uc=self.uc
        uc.reg_write(UC_X86_REG_MXCSR, getattr(self,'_mxcsr',0x1F80))
        rsp=(STACK_BASE+STACK_SIZE-0x10000)&~0xF; rsp-=8
        uc.reg_write(UC_X86_REG_RSP,rsp)
        for reg,v in ((UC_X86_REG_RCX,rcx),(UC_X86_REG_RDX,rdx),(UC_X86_REG_R8,r8),(UC_X86_REG_R9,r9)):
            uc.reg_write(reg,v&(2**64-1))
        self._stray=0            # per-call stray-page budget (flood guard)
        RET=SCRATCH+0x5000; uc.mem_write(rsp,struct.pack("<Q",RET))
        # timeout_us bounds WALL CLOCK (a ctor spinning in a shim burns no
        # instructions); count bounds instructions. Use both for foreign code.
        uc.emu_start(fn,RET,timeout=timeout_us,count=count)
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
    def make_host(self):
        """the plugin processor's own construction (call at 0x32064B): FACTORY 0x3F84E0 = ALLOC(0x880)
        + the ctor inline (base ctor 0x34ABA0 with xmm1 = .rdata 0x9BF5D4 = 96000.0 -> [HOST+8];
        vtable 0xA15B88; [HOST+0x38] = 8 voices) -- the JP8 D7 drive (playbook 101). Checks those
        READ facts on the result. The old zero HOST (JX_EMU_LEGACY_HOST=1) BUILDs at rate 0 and has
        no vtable; SETSR returns at once when the rate equals [HOST+8] (0x3F9981, READ), so the two
        drives differ wherever BUILD's rate reaches a cell SETSR does not rewrite -- MEASURED by
        jx3p/tools/jx_host_drive_check.py (jx3p/docs/S3_STATUS.md, the HOST drive section)."""
        u=self.uc; n0=len(self.allocs)
        h=self.call(FACTORY, count=400_000_000)
        assert h and self.allocs[n0]==(h,HOST_SZ), "factory: first alloc %r, rax 0x%x"%(self.allocs[n0:n0+1],h)
        vp=int.from_bytes(u.mem_read(h,8),'little')
        rate=struct.unpack("<f",u.mem_read(h+8,4))[0]; nv=struct.unpack("<i",u.mem_read(h+0x38,4))[0]
        assert vp==ENGINE_VTBL and rate==96000.0 and nv==8, \
            "factory HOST: vptr rva 0x%x rate %r voices %d"%(vp-IB,rate,nv)
        return h
    def build(self, factory=None):
        """BUILD on the plugin's own HOST (make_host); factory=False or JX_EMU_LEGACY_HOST=1: the old
        zero HOST, kept only so jx_host_drive_check.py can measure what it changed"""
        if factory is None: factory = os.environ.get("JX_EMU_LEGACY_HOST") != "1"
        if factory:
            self.HOST=self.make_host()
        else:
            self.HOST=self.bump(0x8000); self.uc.mem_write(self.HOST,b"\x00"*0x8000)
        self.call(BUILD, rcx=self.HOST)
        u=self.uc; self.state=[]; self.proc=[]; self.assign=[]
        for i in range(N_UNITS):
            self.state.append(int.from_bytes(u.mem_read(self.HOST+80+64*i,8),'little'))
            self.proc.append(int.from_bytes(u.mem_read(self.HOST+96+64*i,8),'little'))
            self.assign.append(int.from_bytes(u.mem_read(self.HOST+104+64*i,8),'little'))
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

    # ------------------------------------------------------------ host-side
    # Everything a DAW does to the engine that the raw stubs do not, each
    # step PROVEN by disassembly (abi_check) or by the JUNO e2e precedent.
    def call_f(self,fn,rcx,f32):
        """call with a FLOAT in XMM1 (SETSR reads xmm1 as single -- ledger)"""
        self.uc.reg_write(UC_X86_REG_XMM1, struct.unpack("<I",struct.pack("<f",float(f32)))[0])
        return self.call(fn, rcx=rcx)
    def set_sr(self,sr=44100.0):
        self.call_f(SETSR, self.HOST, sr)
        got=struct.unpack("<f",self.uc.mem_read(self.HOST+8,4))[0]
        assert abs(got-sr)<1e-3, "SETSR did not land: HOST+8=%r"%got
        return got
    def note_on(self,note,vel=100):  self.call(NOTEON,  rcx=self.HOST, rdx=note, r8=vel)
    def note_off(self,note,vel=64):  self.call(NOTEOFF, rcx=self.HOST, rdx=note, r8=vel)
    def notify(self,what=4):
        """the assigner refresh the HOST PARAM ENTRY runs after every write
        (JUNO proof: allocator stayed POLY without it)"""
        for u in range(N_UNITS): self.call(ASG_NOTIFY, rcx=self.assign[u], rdx=what)
    def recall(self,patch,bank=None,notify=True):
        """the plugin's own recall path: every ACTIVE pool of the factory
        record dispatched to every unit, then the assigner refresh"""
        blob=patch_blob(bank or bank_bytes(), patch)
        for u in range(N_UNITS):
            for pool in ACTIVE_POOLS:
                self.dispatch(u, POOL_BASE_ID+pool, pool_value(blob,pool))
        if notify: self.notify()
    def snap_ramps(self):
        """settle every ACTIVE ramp to its limit and deactivate it (JUNO e2e
        snap_all, validated bit-for-bit there); slot layout per jx_gc.c"""
        uc=self.uc
        def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
        for u in range(N_UNITS):
            st=self.state[u]
            arr=rq(st+0x58); b0=rq(st+0x70); e0=rq(st+0x78)
            ids=struct.unpack("<%di"%((e0-b0)//4), uc.mem_read(b0,e0-b0)) if e0>b0 else ()
            for i in ids:
                a=arr+40*i; tgt=rq(a)
                if tgt: uc.mem_write(tgt, bytes(uc.mem_read(a+0x14,4)))   # *target = limit
                uc.mem_write(a+0x0C, b"\x00"*4)                            # accum = 0
                uc.mem_write(a+0x1C, b"\x00")                              # active = 0
            uc.mem_write(st+0x78, struct.pack("<Q", b0))                   # empty id list
    def clear_latch(self):
        for u in range(N_UNITS): self.uc.mem_write(self.state[u]+LATCH_OFF, b"\x00"*4)
    def run_static_init(self,cap=2_000_000,log=None):
        """run the DLL's C++ static initializers (the CRT XC table) so the
        runtime-filled .data tail exists -- the JX pulse wavetable region
        lives there. Each ctor is isolated; failures are counted, not fatal.
        Returns (ok, failed)."""
        a,b=XC_TABLE
        ptrs=struct.unpack("<%dQ"%((b-a)//8), self.uc.mem_read(IB+a, b-a))
        ok=fail=skip=0
        for p in ptrs:
            if not p: continue
            if (p-IB) in self.SKIP_CTORS: skip+=1; continue
            # DETERMINISM (defect paid 2026-09-06): bound each ctor by
            # INSTRUCTION COUNT ONLY. A wall-clock bound makes the boot
            # machine-speed dependent -- on a slower container one more ctor
            # timed out, the CRT entered its unhandled-exception path
            # (RtlCaptureContext / UnhandledExceptionFilter, both unshimmed),
            # which walked memory downward and left ~2300 stray mapped pages
            # below the heap; BUILD then died with UC_ERR_MAP and the whole
            # export took 97 min instead of under 1. Instruction counts are
            # identical on every machine, so the boot is reproducible.
            try: self.call(p, count=cap); ok+=1
            except Exception as e:
                fail+=1
                if log: log("ctor 0x%x failed: %s"%(p-IB, str(e)[:60]))
        self.static_skipped=skip
        return ok,fail
    def bss_fill(self):
        """bytes of the runtime-filled .data tail that are now nonzero"""
        buf=bytes(self.uc.mem_read(IB+0xCE7800, 0xCF2860-0xCE7800))
        return sum(1 for x in buf if x), len(buf)
    def host_map(self):
        """walk the controller's host-id -> engine-id map (root at .data
        0xCE9038, built by the static initializers; node key +0x1C, value
        +0x20). Returns {host_id: engine_id} for every registered id --
        THE authority on what a host may write (PROVEN: host id 2 maps to
        engine 20 MASTER TUNE; the DB row of the HOST id is a different
        parameter and choosing defaults by it detuned the port -39.5 cents)."""
        uc=self.uc
        def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
        root=rq(IB+0xCE9038)
        if not root: raise RuntimeError("host map not built -- run_static_init first")
        out={}; seen=set(); stack=[rq(root+8)]
        while stack:
            n=stack.pop()
            if not n or n in seen or len(seen)>20000: continue
            seen.add(n)
            try:
                k=struct.unpack("<i", uc.mem_read(n+0x1C,4))[0]
                v=struct.unpack("<i", uc.mem_read(n+0x20,4))[0]
            except Exception: continue
            if 0<=k<0x100000 and 0<=v<5223: out[k]=v
            for off in (0,8,0x10): stack.append(rq(n+off))
        return out
    def host_init(self,ids=None,log=None):
        """THE CONTROLLER'S DEFAULT PUSH (2026-09-05): a DAW insert runs the
        DLL's static initializers (they build the host-id map at .data
        0xCE9038) and then the controller writes EVERY parameter's default
        through the HOST PARAM ENTRY (0x3F9A30), which maps host id ->
        engine id, converts the frame, dispatches with flag 0 and runs the
        assigner notify. Without this the master's boot ramps 541/542 carry
        NaN limits and the EFX network self-poisons at idle sample 3681
        (clamp 1.98 forever); with it the master stays finite and the note
        rides through the effects. Defaults come from the binary's own
        ENGINE DB (pe_recon), raw frame = default - min; event ids
        433..484 (Note/Gate/Mute) are never parameters. Requires
        run_static_init() BEFORE build() (boot(host_init=True) orders it).
        Returns (written, failed)."""
        import pe_recon
        pe=pe_recon.PE(BIN)
        rows=pe.params(list(range(5223)))["rows"]
        mp=self.host_map()
        ok=fail=0
        for hid,eng in sorted(mp.items()):
            if ids is not None and hid not in ids: continue
            r=rows.get(eng)
            if not r or not r["name"] or r["name"]=="_reserve_" or 433<=eng<485: continue
            if r["min"]==r["max"]==r["default"]==0: continue
            try:
                self.call(HOSTPARAM, rcx=self.HOST, rdx=hid, r8=r["default"]-r["min"],
                          count=5_000_000, timeout_us=1_000_000); ok+=1
            except Exception as e:
                fail+=1
                if log: log("host write hid %d (eng %d) failed: %s"%(hid,eng,str(e)[:60]))
        return ok,fail
    # ------------------------------------------------------------ the plugin's own patch protocol
    # MEASURED 2026-10-10 (jx3p/tools/jx_patch_protocol.py, jx_recall_product_check.py): the plugin's
    # patch browser load queues records (model id, value) that the render driver hands to the engine's
    # host entry, which maps each id (its map, from the static initializers), moves some values (dispatch 769: -128, 20: -100),
    # checks the range and dispatches to every unit with flag 0, then the assigner notify. The pool
    # model above (recall: 740 + pool, flag 1, the bank nibble pair) sent 17 ids the plugin never sends,
    # never sent 20 the plugin sends (the second half of the tree, the effect floats) and moved no value:
    # patches 0, 20, 49 played ~3x louder. The engine given the plugin's own records through its own host
    # entry holds what the plugin holds, word for word (every unit, 5 patches; the check's tooth bites).
    _records = None
    @classmethod
    def records(cls):
        if cls._records is None:
            import json
            cls._records = json.load(open(PATCH_RECORDS))
        return cls._records
    def id_map(self):
        """the host entry's whole id map (std::map at .data 0xCE9038, in order): {id: dispatch id}.
        host_map() below keeps only ids < 0x100000 (the 3 host-exported ones) and filters out the 678
        model ids -- which once made the map look like 3 entries (2026-10-10)."""
        uc=self.uc
        def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
        out={}
        def walk(n, depth=0):
            if depth > 64 or uc.mem_read(n + 0x19, 1)[0]: return
            walk(rq(n), depth + 1)
            out[struct.unpack('<I', uc.mem_read(n + 0x1C, 4))[0]] = struct.unpack('<i', uc.mem_read(n + 0x20, 4))[0]
            walk(rq(n + 0x10), depth + 1)
        walk(rq(rq(IB + 0xCE9038) + 8))
        return out
    def host_records(self, recs):
        """the kind-2 records through the engine's own host entry, in order (the render driver's
        application at a block's start); kind-0 MIDI records are not engine parameters"""
        for kind, pid, val in recs:
            if kind == 2:
                self.call(HOSTPARAM, rcx=self.HOST, rdx=pid, r8=val & 0xFFFFFFFF, count=400_000_000)
    def product_boot(self):
        """initialize's records (the default patch, MASTER TUNE, the host settings: voiceCount 6 and
        writePatch reach HOST+0x38 and the output fade) through the host entry; the id map it needs is
        the static initializers' (run_static_init)"""
        self.host_records(self.records()["boot"])
    def recall_product(self, patch):
        """factory patch `patch` as the plugin's patch browser loads it: its records through the host entry"""
        self.host_records(self.records()["patches"][patch])
    # ------------------------------------------------------------ the plugin's own engine render
    # RENDER (vtable 0x38, 0x3F9220; READ, jx3p/docs/HOST_LAYER.md 2): per voice unit the assigner's
    # count synced to HOST+0x38, its clock, units below the count flagged for their worker threads, the
    # others' outputs zeroed; the wait for the done count; the master per sample; the output gain stage
    # (HOST+0x860..0x878, armed by writePatch). The ONE replacement is the thread transport, as in
    # jx3p/tools/jx_host_emu.py: the render stops where it takes the done lock (JOBS_DUE), each flagged
    # worker's own body runs from its entry until, its job done, it is back at the top of its loop with
    # its lock released (WORKER_PARK), and the render resumes there. render() above (the stubs) runs
    # every unit and has no count sync and no gain stage.
    JOBS_DUE, WORKER, WORKER_PARK = IB + 0x3F9587, IB + 0x3F8C60, IB + 0x3F8CD0
    def _engine_hooks(self):
        if getattr(self, '_eng_hooked', False): return
        self._eng_hooked = True; self._eng_req = None; self._eng_skip = None; self._job_w = None
        self.jobs = []
        def due(uc, addr, size, ud):
            here = (addr, uc.reg_read(UC_X86_REG_RSP))
            if self._eng_skip == here:
                self._eng_skip = None; return
            if self._job_w is not None: return
            self._eng_req = (uc.context_save(), addr, here[1]); uc.emu_stop()
        def park(uc, addr, size, ud):
            if self._job_w is not None and struct.unpack('<i', uc.mem_read(self._job_w + 0x34, 4))[0] == 0:
                uc.emu_stop()
        self.uc.hook_add(UC_HOOK_CODE, due, begin=self.JOBS_DUE, end=self.JOBS_DUE)
        self.uc.hook_add(UC_HOOK_CODE, park, begin=self.WORKER_PARK, end=self.WORKER_PARK)
    def _engine_jobs(self):
        uc = self.uc; RET = SCRATCH + 0x5000
        for u in range(8):
            w = self.HOST + 0x460 + 0x80 * u
            if struct.unpack('<i', uc.mem_read(w + 0x34, 4))[0] != 1: continue
            self.jobs.append((u, struct.unpack('<i', uc.mem_read(w + 0x30, 4))[0]))
            rsp = (STACK_BASE + 0x800000) & ~0xF; rsp -= 8          # a worker's own stack, below the render's
            uc.reg_write(UC_X86_REG_RSP, rsp); uc.reg_write(UC_X86_REG_RCX, w); uc.reg_write(UC_X86_REG_RDX, u)
            uc.mem_write(rsp, struct.pack('<Q', RET))
            self._job_w = w
            try: uc.emu_start(self.WORKER, RET)
            finally: self._job_w = None
            rip = uc.reg_read(UC_X86_REG_RIP)
            if rip != self.WORKER_PARK or struct.unpack('<i', uc.mem_read(w + 0x34, 4))[0] != 0:
                raise RuntimeError('worker %d did not finish its job (rva 0x%x)' % (u, rip - IB))
    def render_engine(self, n, block=256):
        """n samples through the plugin's own engine render (RENDER, the args the render object passes:
        rcx HOST, r9 the two channel pointers, 5th 2 channels, 6th the count); returns (L, R) bit lists"""
        self._engine_hooks()
        uc = self.uc; RET = SCRATCH + 0x5000
        offL = BUF_BASE; offR = BUF_BASE + 4 * block; ptrs = BUF_BASE + 8 * block
        Lout, Rout = [], []
        done = 0
        while done < n:
            b = min(block, n - done)
            uc.mem_write(ptrs, struct.pack('<QQ', offL, offR))
            uc.reg_write(UC_X86_REG_MXCSR, getattr(self, '_mxcsr', 0x1F80))
            rsp = (STACK_BASE + STACK_SIZE - 0x10000) & ~0xF; rsp -= 8
            uc.mem_write(rsp, struct.pack('<Q', RET))
            uc.mem_write(rsp + 0x28, struct.pack('<QQ', 2, b))
            for reg, v in ((UC_X86_REG_RSP, rsp), (UC_X86_REG_RCX, self.HOST), (UC_X86_REG_RDX, 0),
                           (UC_X86_REG_R8, 0), (UC_X86_REG_R9, ptrs)):
                uc.reg_write(reg, v)
            start = RENDER
            while True:
                self._eng_req = None
                uc.emu_start(start, RET)
                req = self._eng_req
                if req is None:
                    if uc.reg_read(UC_X86_REG_RIP) != RET:
                        raise RuntimeError('engine render stopped at rva 0x%x' % (uc.reg_read(UC_X86_REG_RIP) - IB))
                    break
                self._engine_jobs()
                uc.context_restore(req[0]); self._eng_skip = (req[1], req[2]); start = req[1]
            Lout += list(struct.unpack('<%dI' % b, uc.mem_read(offL, 4 * b)))
            Rout += list(struct.unpack('<%dI' % b, uc.mem_read(offR, 4 * b)))
            done += b
        return Lout, Rout
    def boot(self,sr=44100.0,patch=None,static_init=False,snap=True,host_init=False,product=False):
        """THE boot recipe: [static init] -> BUILD -> SETSR(float) -> FTZ ->
        [product: the id map's populate + initialize's records (product_boot), the plugin's own boot]
        [host_init: the old model of the controller's default push] -> [recall patch: recall_product
        with product=True, else the pool model + notify] -> [snap ramps + clear latch].
        host_init and product imply static_init. Returns self."""
        if static_init or host_init or product: self.run_static_init()
        self.build(); self.set_ftz(); self.set_sr(sr)
        if product:
            self.product_boot()
        elif host_init:
            ok,fail=self.host_init()
            assert fail==0, "host_init: %d writes failed"%fail
        if patch is not None:
            if product: self.recall_product(patch)
            else: self.recall(patch)
        if snap: self.snap_ramps(); self.clear_latch()
        return self
    def render_dry(self,n,block=256):
        """voice-sum render (master bypassed), floats, NaN dropped -- the
        listen path for audio_metrics"""
        uc=self.uc; offs={}; p=BUF_BASE
        for v in range(8): offs[v]=p; p+=8*block
        acc=[0.0]*n; done=0
        while done<n:
            b=min(block,n-done)
            for v in range(8):
                uc.mem_write(PB_VOICE, struct.pack("<QQQQQ",self.state[v],v,offs[v],offs[v]+4*block,b))
                self._run(self.SVOICE)
                w=struct.unpack("<%dI"%b, uc.mem_read(offs[v],4*b))
                for i,x in enumerate(struct.unpack("<%df"%b, struct.pack("<%dI"%b,*w))):
                    if x==x: acc[done+i]+=x
            done+=b
        return acc

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
