#!/usr/bin/env python3
"""jp8_emu.py -- JUPITER-8 full-instance engine under Unicorn, GENERATED from
tools/verify/jx_emu.py by make_jp8_emu.py (constants swapped, see gen/abi_ledger.md). WORK IN PROGRESS: this file stands the harness up incrementally,
each entry point PROVEN by execution, never guessed. Import it and call the
probes; nothing here is asserted true until its probe runs green.

Ground-truth paths via truth.py-style resolution against jx3p/truth/.
"""
import os, sys, struct, collections
import pefile
from unicorn import *
from unicorn.x86_const import *

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, "/home/user/jn60c99/tools/verify"); sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
BIN  = '/home/user/jn60c99/jp8/truth/JUPITER-8VST3_64bit.vst3'
pe = pefile.PE(BIN)
IB  = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()
IMGSZ = (len(IMG) + 0xFFF) & ~0xFFF

# PROVEN so far (READ from the dump / cross-checked S2). Construction entries are
# discovered by probe below, not hardcoded.
PROC_VPTR = IB + 0xA54158     # CPrmDSPJp8Plugin vtable (RTTI, xmap8.py) READ
DISPATCH  = IB + 0x437630     # Plugin slot 11 (same cmp edx,0x138 jump-table idiom) READ
ALLOC     = IB + 0x6F5B04     # CRT allocator: the callee BUILD passes ecx=STATE_SZ to READ
BUILD     = IB + 0x445020     # CWaveGen slot 0x08: mov r15d,9 ; mov ecx,0xa9c0c0 READ
VOICE_WRAP= IB + 0x3F80B0     # (state, voiceIdx, DWORD** outPair) -- JX idiom byte-for-byte: latch [rcx+0xa9c0b8], tail-call GC 0x440180 READ
MASTER_WRAP=IB + 0x3F8040     # (state8, a2[16], DWORD** outPair) -- RENDER calls it at 0x446229 with rcx=[HOST+0x2a0]=state[8] READ
RENDER    = IB + 0x445DC0     # CWaveGen slot 0x38 = host process(): needs a CONSTRUCTED CWaveGen (per-channel vectors at HOST+0x50/+0x78); faults on the zero-filled HOST -- NOT the oracle path
STATE_SZ  = 0xA9C0C0
N_UNITS   = 9

# ABI LEDGER (tools/verify/abi_check.py, 2026-09-05 -- METHOD_PLAYBOOK 87).
# Every entry below was disassembled; the register each argument is READ
# from is recorded here. A call that fills a different register is WRONG
# whatever the gates say (the SETSR rdx-vs-xmm1 defect hid for the whole port).
SETSR     = IB + 0x4464F0     # (rcx=HOST, xmm1=float rate)   -- FLOAT IN XMM1 (abi_check)
NOTEON    = IB + 0x445CF0     # (rcx=HOST, dl=note, r8b=vel)  CWaveGen slot 0x70 -> unit 0x442030
NOTEOFF   = IB + 0x445C90     # (rcx=HOST, dl=note, r8b=vel)  CWaveGen slot 0x68 -> unit 0x441f90
ASG_NOTIFY= IB + 0x37CD80     # (rcx=assign obj, edx=what)    CAssignJp8 vtable 0x9f3158 slot 1
HOSTPARAM = IB + 0x4465B0     # (rcx=HOST, edx=host id, r8d=val) -- CWaveGen slot 0x60; needs the
                              # controller-built id map at .data 0xD22478 (rip-relative load in HOSTPARAM)
ENGINE_VTBL = IB + 0xA704B0   # CWaveGen (36 slots): 08 BUILD 18 SETSR 38 RENDER 60 HOSTPARAM
                              #        68 NOTEOFF 70 NOTEON (roles by STRUCTURE, not slot transfer)
XC_TABLE  = (0x9B8658, 0x9BA0C0)   # C++ static initializers (pe_recon crt_init);
                              # they fill .data's runtime tail [0xD20A00,0xD2BBE0)
LATCH_OFF = 0xA9C0B8          # the wrappers decrement [rcx+0xa9c0b8] (READ); reads 960 at clean boot (PROVEN, recon boot)

# D7 (2026-09-22): THE HOST IS CONSTRUCTED THE WAY THE PLUGIN'S PROCESSOR DOES IT (READ, processor init fn
# 0x33a590): `call 0x444fe0` at 0x33a8db = the CWaveGen FACTORY -- no arguments; ALLOC(0x8D0) through the CRT
# allocator 0x6F5B04, ctor 0x444000 on the block, returns the HOST in rax (0 if ALLOC failed) -- then at once
# BUILD through vtbl+8 (0x33a8ed), then vtbl+0x20 (0x36cad0 = movss xmm0,[HOST+8]) and SETSR vtbl+0x18
# (0x33a9cf) with float(rate), rate = table .rdata 0x9CEBA8 {96000,88200,48000,44100,32000}[mode] or
# round([HOST+8]) (vtbl+0x28 0x36cdf0) when mode == 5. The ctor: base ctor 0x36c890 stores xmm1 = .rdata
# 0xA18A44 = 96000.0 into [HOST+8]; vtable 0xA704B0; [HOST+0x38] = 8 (voice count; HOSTPARAM id 0xFFFC00E
# rewrites it); two deques grown to 0x493E0 ints (ALLOC(0x10) per 4 ints -> ~150k allocations).
# BUILD copies [HOST+8] into every state+0x10 (0x44508a / 0x445267 -> 0x4400f0): the old zero-filled HOST
# armed every boot ramp with rate 0 (inf/NaN steps) and the snap + latch clear hid it (S3_STATUS D7).
# The old zero HOST is kept ONLY behind the explicit legacy flag (JP8(legacy=True) or env
# JP8_EMU_LEGACY_HOST=1) so logs dated before drive2 stay reproducible; it is never the default.
FACTORY   = IB + 0x444FE0     # CWaveGen factory (no args) -> rax = HOST (READ)
HOST_CTOR = IB + 0x444000     # CWaveGen ctor (rcx = block) (READ)
HOST_SZ   = 0x8D0             # ALLOC size in the factory (`mov ecx,0x8d0`, READ)
HOST_RATE0= 96000.0           # [HOST+8] after the ctor (.rdata 0xA18A44, READ)
HOST_NVOICE=8                 # [HOST+0x38] after the ctor (READ)
FACTORY_CAP=400_000_000       # instruction bound for the factory call (deterministic, never wall clock)
HP_CAP    = 5_000_000         # instruction bound for one HOSTPARAM call (9 units x setter + dispatch + notify)
LEGACY_ENV= os.environ.get("JP8_EMU_LEGACY_HOST") == "1"
# host_init writes the controller default of these HOST ids only (the set the pre-drive2 harness wrote: its
# map walker dropped every key >= 0x100000, see host_map). The full-map push is an OPEN question (frame law
# of generic ids with a nonzero DB min, e.g. TEMPO 400..3000) -- measured, not adopted (jp8_drive2_probe.py).
HOSTINIT_IDS = (0, 1, 2)

# the factory bank geometry + decode live in jx_bank.py (pure python, so the
# ctypes half of a two-process gate can import the SAME definition without
# pulling Unicorn in). blob_pos = 2*pool - 8: playbook 88, jx_bank_census.py.
from jp8_bank import (BANK_HEADER, BANK_STRIDE, BANK_BLOB_OFF, ACTIVE_POOLS,
                     POOL_BASE_ID, bank_bytes, patch_blob, pool_value, patch_name)

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

# static initializers that FAULT under emulation, skipped BY ADDRESS (discovered
# by jp8_boot.py --discover; see JP8_STATUS.md). Empty until discovered.
JP8_SKIP_CTORS = [0xB7244, 0xB6DD0, 0x5C83C0]   # ctor #4 UC_ERR_EXCEPTION, #89 UC_ERR_INSN_INVALID (NULL vtable -> jmp 0), #95 UC_ERR_MAP crash-walk (the JX trio, playbook: same indices)

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
    def __init__(self, legacy=None):
        # legacy=True: the pre-drive2 zero HOST + DISPATCH recall (+ snap/latch allowed). Explicit only.
        self.legacy = LEGACY_ENV if legacy is None else bool(legacy)
        if self.legacy and os.environ.get("JP8_EMU_QUIET")!="1":
            sys.stderr.write("jp8_emu: LEGACY drive (zero HOST, DISPATCH recall) -- reproduces pre-drive2 logs only\n")
        self._sr_set=False; self._recalled=False; self._hmap=None
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
        self.SVOICE=CODE_BASE; self.SMASTER=CODE_BASE+0x400
        if VOICE_WRAP: uc.mem_write(self.SVOICE, _voice_stub(PB_VOICE, VOICE_WRAP))
        if MASTER_WRAP: uc.mem_write(self.SMASTER, _master_stub(PB_MASTER, MASTER_WRAP))
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
    SKIP_CTORS = set(JP8_SKIP_CTORS)

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
        if self.faults<=8 and os.environ.get("JP8_EMU_QUIET")!="1":
            rip=uc.reg_read(UC_X86_REG_RIP)
            sys.stderr.write("jp8_emu: UNMAPPED %s 0x%x (size %d) at rva 0x%x -- zero page mapped\n"
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
        """the processor's own construction (0x33a8db): FACTORY 0x444FE0 = ALLOC(0x8D0) + ctor 0x444000.
        Checks the READ facts on the result (first allocation = HOST of 0x8D0, vtable 0xA704B0,
        [HOST+8] = 96000.0, [HOST+0x38] = 8) and records the allocation count in self.host_allocs."""
        u=self.uc; n0=len(self.allocs)
        h=self.call(FACTORY, count=FACTORY_CAP)
        assert h and self.allocs[n0]==(h,HOST_SZ), "factory: first alloc %r, rax 0x%x"%(self.allocs[n0:n0+1],h)
        vp=int.from_bytes(u.mem_read(h,8),'little')
        rate=struct.unpack("<f",u.mem_read(h+8,4))[0]; nv=struct.unpack("<i",u.mem_read(h+0x38,4))[0]
        assert vp==ENGINE_VTBL and rate==HOST_RATE0 and nv==HOST_NVOICE, \
            "factory HOST: vptr rva 0x%x rate %r voices %d"%(vp-IB,rate,nv)
        self.host_allocs=len(self.allocs)-n0
        return h
    def build(self, legacy=None):
        """HOST (the factory, or the legacy zero block) then BUILD 0x445020(rcx=HOST)"""
        if legacy is None: legacy=self.legacy
        if legacy:
            self.HOST=self.bump(0x8000); self.uc.mem_write(self.HOST,b"\x00"*0x8000); self.host_allocs=0
        else:
            self.HOST=self.make_host()
        self.call(BUILD, rcx=self.HOST)
        u=self.uc; self.state=[]; self.proc=[]; self.assign=[]
        for i in range(N_UNITS):
            self.state.append(int.from_bytes(u.mem_read(self.HOST+0xA0+64*i,8),'little'))
            self.proc.append(int.from_bytes(u.mem_read(self.HOST+0xB0+64*i,8),'little'))
            self.assign.append(int.from_bytes(u.mem_read(self.HOST+0xB8+64*i,8),'little'))
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
        """SETSR 0x4464F0 (float in xmm1). ORDER LAW (drive2): refused after a recall -- the order changes
        the sound (SHIPPING_DESIGN skeptic item 4, orderprobe.py). SETSR returns at once when the rate
        equals [HOST+8] (0x446501 je), so on the constructed HOST SETSR(96000) is a no-op (READ)."""
        if self._recalled and not self.legacy:
            raise RuntimeError("set_sr after recall refused (order law: ctor -> BUILD -> SETSR -> host_init -> recall)")
        self.call_f(SETSR, self.HOST, sr); self._sr_set=True
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
    def _no_poke(self,what,force):
        if not (self.legacy or force):
            raise RuntimeError("%s refused on the drive2 oracle (D7: the snap/latch hid the zero HOST; the plugin's "
                               "own walker settles every ramp). Use JP8(legacy=True) to reproduce old logs, or "
                               "force=True for a labelled probe."%what)
    def snap_ramps(self,force=False):
        """settle every ACTIVE ramp to its limit and deactivate it (JUNO e2e
        snap_all, validated bit-for-bit there); slot layout per jx_gc.c.
        A HARNESS POKE, not plugin behaviour: legacy drive only (or force=True)."""
        self._no_poke("snap_ramps",force)
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
    def clear_latch(self,force=False):
        self._no_poke("clear_latch",force)
        for u in range(N_UNITS): self.uc.mem_write(self.state[u]+LATCH_OFF, b"\x00"*4)
    def ramp_census(self):
        """every ramp record of every unit (40-byte slots, array [st+0x58, st+0x60); live = the id list
        [st+0x70, st+0x78)): counts of NaN/inf in step (+8) and accumulator (+0xC), live and all records,
        plus active flags (+0x1C) and the latch. Pure read (plumbing)."""
        uc=self.uc; c=collections.Counter()
        def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
        import math
        for u in range(N_UNITS):
            st=self.state[u]; arr=rq(st+0x58); end=rq(st+0x60); b0=rq(st+0x70); e0=rq(st+0x78)
            n=(end-arr)//40 if end>arr else 0
            blob=bytes(uc.mem_read(arr,40*n)) if n else b""
            live=set(struct.unpack("<%di"%((e0-b0)//4), uc.mem_read(b0,e0-b0))) if e0>b0 else set()
            c["records"]+=n; c["live"]+=len(live)
            for i in range(n):
                step,acc=struct.unpack_from("<ff",blob,40*i+8)
                bad_s_nan=math.isnan(step); bad_s_inf=math.isinf(step); bad_a=not math.isfinite(acc)
                c["all_step_nan"]+=bad_s_nan; c["all_step_inf"]+=bad_s_inf; c["all_acc_bad"]+=bad_a
                c["active"]+=blob[40*i+0x1C]!=0
                if i in live:
                    c["live_step_nan"]+=bad_s_nan; c["live_step_inf"]+=bad_s_inf; c["live_acc_bad"]+=bad_a
            c["latch_sum"]+=struct.unpack("<i",uc.mem_read(st+LATCH_OFF,4))[0]
        c["live_bad"]=c["live_step_nan"]+c["live_step_inf"]+c["live_acc_bad"]
        c["all_bad"]=c["all_step_nan"]+c["all_step_inf"]+c["all_acc_bad"]
        c["rate0"]=struct.unpack("<f",uc.mem_read(self.state[0]+0x10,4))[0]
        return c
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
        buf=bytes(self.uc.mem_read(IB+0xD20A00, 0xD2BBE0-0xD20A00))
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
        root=rq(IB+0xD22478)
        if not root: raise RuntimeError("host map not built -- run_static_init first")
        if not self.legacy:
            # drive2 walker (defect paid 2026-09-22): the map is an MSVC std::map<int,int> (node: left +0,
            # parent +8, right +0x10, isnil +0x19, key +0x1C, value +0x20; head = [.data 0xD22478], root =
            # [head+8], size = [0xD22480]). Static init 0xAD320 inserts 744 pairs (READ: initializer list
            # [rbp+0x1670, rbp+0x2db0) -> 0x443dd0); host ids are like 0x600026 (VCO2 SUB RANGE). The old
            # walker below kept only keys < 0x100000 and so returned 3 of 744 (PROVEN: executed map = 744).
            if self._hmap is None:
                out={}; stack=[rq(root+8)]; seen=set()
                while stack:
                    n=stack.pop()
                    if not n or n==root or n in seen: continue
                    seen.add(n)
                    if uc.mem_read(n+0x19,1)[0]: continue
                    k,v=struct.unpack("<ii", uc.mem_read(n+0x1C,8)); out[k]=v
                    stack.append(rq(n)); stack.append(rq(n+0x10))
                size=rq(IB+0xD22480)
                assert len(out)==size, "host map walk %d != size field %d"%(len(out),size)
                self._hmap=out
            return dict(self._hmap)
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
        if self._recalled and not self.legacy:
            raise RuntimeError("host_init after recall refused (order law)")
        pe=pe_recon.PE(BIN)
        rows=pe.params(list(range(5223)))["rows"]
        mp=self.host_map()
        # drive2: the written set is pinned to HOSTINIT_IDS (= what the pre-drive2 walker let through),
        # ids="all" pushes every mapped id under the old law (a probe; NOT the drive -- see HOSTINIT_IDS)
        if ids is None and not self.legacy: ids=HOSTINIT_IDS
        if ids=="all": ids=None
        ok=fail=0
        for hid,eng in sorted(mp.items()):
            if ids is not None and hid not in ids: continue
            r=rows.get(eng)
            if not r or not r["name"] or r["name"]=="_reserve_" or 433<=eng<485: continue
            if r["min"]==r["max"]==r["default"]==0: continue
            try:
                # bound by INSTRUCTION COUNT only (skeptic item 6: a wall-clock bound is machine dependent);
                # the legacy drive keeps its old bound so its logs reproduce
                self.call(HOSTPARAM, rcx=self.HOST, rdx=hid, r8=r["default"]-r["min"],
                          count=HP_CAP, timeout_us=1_000_000 if self.legacy else 0); ok+=1
            except Exception as e:
                fail+=1
                if log: log("host write hid %d (eng %d) failed: %s"%(hid,eng,str(e)[:60]))
        return ok,fail
    def boot(self,sr=44100.0,patch=None,static_init=False,snap=True,host_init=False,census=None):
        """DRIVE2 (default): static init -> HOST via the FACTORY (ALLOC 0x8D0 + ctor 0x444000) -> BUILD(HOST)
        -> FTZ -> SETSR(sr, float xmm1) -> host_init (HOSTINIT_IDS through HOSTPARAM) -> recall(patch)
        through HOSTPARAM (host id, raw bank value) per pool. NO snap, NO latch clear: the plugin's own
        walker settles the ramps. census(tag, dict) (optional) is called after every stage with the ramp
        census (ramp_census) and the host_map() size. static_init/snap/host_init are IGNORED on drive2.
        LEGACY (self.legacy): the old recipe, unchanged: [static init] -> zero HOST -> BUILD -> FTZ -> SETSR
        -> [host_init] -> [DISPATCH-flag-0 recall] -> [snap + latch]. Returns self."""
        if self.legacy:
            if static_init or host_init: self.run_static_init()
            self.build(); self.set_ftz(); self.set_sr(sr)
            if host_init:
                ok,fail=self.host_init()
                assert fail==0, "host_init: %d writes failed"%fail
            if patch is not None: self.recall(patch)
            if snap: self.snap_ramps(); self.clear_latch()
            return self
        def cen(tag, ramps=True):
            if census: census(tag, dict(self.ramp_census()) if ramps else {}, len(self.host_map()))
        ok,fail=self.run_static_init(); self.static_ok=(ok,fail); cen("static init", ramps=False)
        self.build(); cen("HOST+BUILD")
        self.set_ftz(); self.set_sr(sr); cen("SETSR %g"%sr)
        ok,fail=self.host_init(); assert fail==0, "host_init: %d writes failed"%fail
        self.hostinit_writes=ok; cen("host_init")
        if patch is not None: self.recall(patch); cen("recall %d"%patch)
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


# ---------------------------------------------------------------- JP8 extension
class JP8(JX):
    """the JP8 oracle: JX machinery + the shipping RENDER entry (no per-unit
    wrappers located yet) + an instruction counter for the S3 cost estimate"""
    def __init__(self, legacy=None):
        super().__init__(legacy=legacy)
        self._count_on=False; self._bcache={}; self._icount=0; self._md=None
    def _blk(self,uc,address,size,user):
        if not self._count_on: return
        c=self._bcache.get(address)
        if c is None:
            if IB<=address<IB+IMGSZ:
                c=sum(1 for _ in self._md.disasm(bytes(IMG[address-IB:address-IB+size]),address))
            else: c=1
            self._bcache[address]=c
        self._icount+=c
    def enable_counter(self):
        import capstone
        self._md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64)
        self.uc.hook_add(UC_HOOK_BLOCK,self._blk)
    def call_stack(self,fn,rcx=0,rdx=0,r8=0,r9=0,stack=(),count=0,timeout_us=0):
        """call() plus stack args 5.. (Win64: [rsp+0x28+8k] at entry)"""
        uc=self.uc
        uc.reg_write(UC_X86_REG_MXCSR, getattr(self,'_mxcsr',0x1F80))
        rsp=(STACK_BASE+STACK_SIZE-0x10000)&~0xF; rsp-=8
        uc.reg_write(UC_X86_REG_RSP,rsp)
        for reg,v in ((UC_X86_REG_RCX,rcx),(UC_X86_REG_RDX,rdx),(UC_X86_REG_R8,r8),(UC_X86_REG_R9,r9)):
            uc.reg_write(reg,v&(2**64-1))
        self._stray=0
        RET=SCRATCH+0x5000; uc.mem_write(rsp,struct.pack("<Q",RET))
        for k,v in enumerate(stack): uc.mem_write(rsp+0x28+8*k, struct.pack("<Q",v&(2**64-1)))
        uc.emu_start(fn,RET,timeout=timeout_us,count=count)
        rip=uc.reg_read(UC_X86_REG_RIP)
        if rip!=RET: raise RuntimeError("call 0x%x stopped rva 0x%x"%(fn-IB,rip-IB))
        return uc.reg_read(UC_X86_REG_RAX)
    # D2 ROOT CAUSE (PROVEN 2026-09-22, gen/d2_2_0_1.log): the factory bank stores
    # every pool in its RAW frame (Script.xml: VCO2 SUB RANGE int2x4 range 0..72,
    # default 36) while DISPATCH with flag 1 takes the ENGINE frame (engine DB
    # min..max: id 769 is -36..36). The JX recall passed raw bytes straight through
    # (no JX pool has a negative min, so it never showed); on the JP8 raw 36 became
    # +36 semitones and every patch played 3 octaves sharp (patch 2 key 60 =
    # 2092 Hz). Re-dispatching 769 := 0 with flag 1 restored 261.36 Hz (-2 cents);
    # flag 0 changed nothing. So recall() adds the engine-DB min of every pool.
    _pool_min=None
    def pool_mins(self):
        if JP8._pool_min is None:
            import pe_recon
            rows=pe_recon.PE(BIN).params([POOL_BASE_ID+p for p in ACTIVE_POOLS])["rows"]
            JP8._pool_min={POOL_BASE_ID+p: rows[POOL_BASE_ID+p]["min"] for p in ACTIVE_POOLS}
        return JP8._pool_min
    # RECALL FLAG (PROVEN 2026-09-22, d4_flag / d4_ramp1480 logs): DISPATCH flag 1 writes the
    # engine cell directly (0x440430: [[state+0x38]+idx*40+0x20] = value) but leaves the BOOT
    # RAMP that targets the same cell active with its OLD limit; the plugin's own walker then
    # moves the cell back to that limit within 64 samples (FINE TUNE 0.00405 -> 0.0003), and a
    # snap does the same at once. Flag 0 is the hosted path: the child setter ARMS the ramp
    # (limit = new value, +0x14; active +0x1C) and the walker/snap settles it. Under flag 1 the
    # recall lost ENV1 SUSTAIN (0 -> 0.995), MIXER VCO1 (2.51 -> 0.5), HPF, PORTAMENTO and
    # FINE TUNE to the boot limits on patch 0. Recall therefore dispatches with flag 0.
    RECALL_FLAG=0
    # RECALL LAW, DRIVE2 (2026-09-22): the processor's event loop (0x33ac90) hands every parameter change to
    # HOSTPARAM = CWaveGen vtbl+0x60 (0x33b370: int event, edx = host id, r8d = int value; 0x33b3bb: float
    # event converted by 0x326560 first) -- READ. HOSTPARAM 0x4465B0 looks the host id up in the static map,
    # then per unit (9): a per-engine-id switch (tables 0x4467e4/0x4467b8; 756 LFO KEY TRIG -> direct setter
    # 0x442c30, 769 -> v-36, ...), the DB range check (0x4274f0), DISPATCH flag 0 (proc vtbl+0x58) and the
    # assigner notify(4). The bank stores the RAW frame; HOSTPARAM takes it (769's v-36 is the proof), so the
    # harness passes the raw bank value and converts NOTHING (plumbing only).
    def host_id(self,eid):
        """engine id -> host id, from the EXECUTED host map (never hardcoded)"""
        inv=getattr(self,"_hinv",None)
        if inv is None:
            inv={}
            for k,v in self.host_map().items():
                assert v not in inv, "engine id %d mapped twice"%v
                inv[v]=k
            self._hinv=inv
        return inv[eid]
    def param(self,eid,raw):
        """ONE host parameter write through HOSTPARAM (engine id -> host id via the map; raw frame value)"""
        return self.call(HOSTPARAM, rcx=self.HOST, rdx=self.host_id(eid), r8=raw&0xFFFFFFFF, count=HP_CAP)
    def recall(self,patch,bank=None,notify=True,flag=None,path=None):
        """path "hostparam" (drive2 default): every active pool, ascending pool id (= ascending host id;
        the host's own order is INFERRED), HOSTPARAM(HOST, host id, raw bank value) -- the notify runs inside
        HOSTPARAM per unit, `notify` is ignored. path "dispatch" (legacy default, or any explicit `flag`):
        the pre-drive2 law -- raw + engine-DB min through DISPATCH(flag) on every unit, units outer, then
        one assigner refresh."""
        if path is None: path="dispatch" if (self.legacy or flag is not None) else "hostparam"
        blob=patch_blob(bank or bank_bytes(), patch)
        if path=="hostparam":
            if not self.legacy and not self._sr_set:
                raise RuntimeError("recall before SETSR refused (order law: ctor -> BUILD -> SETSR -> host_init -> recall)")
            for pool in ACTIVE_POOLS:
                self.param(POOL_BASE_ID+pool, pool_value(blob,pool))
            self._recalled=True
            return
        assert path=="dispatch", path
        mins=self.pool_mins()
        if flag is None: flag=self.RECALL_FLAG
        for u in range(N_UNITS):
            for pool in ACTIVE_POOLS:
                pid=POOL_BASE_ID+pool
                self.dispatch(u, pid, pool_value(blob,pool)+mins[pid], flag=flag)
        if notify: self.notify()
        self._recalled=True
    def render_host(self,n,block=256,count=False):
        """the SHIPPING render entry (CWaveGen slot 0x38): rcx=HOST,
        r9=&{L*,R*}, stack arg6=nframes (READ: movsxd rdi,[rbp+0x168];
        mov rax,[r12+r8*8] r8<2). Returns (L,R) float lists (NaN kept) and,
        with count=True, the instruction total in self._icount."""
        uc=self.uc; L=[]; R=[]
        LBUF=BUF_BASE; RBUF=BUF_BASE+4*block+0x100; OS=BUF_BASE+8*block+0x200
        done=0
        if count: self._icount=0
        while done<n:
            b=min(block,n-done)
            uc.mem_write(LBUF,b"\x00"*(4*b)); uc.mem_write(RBUF,b"\x00"*(4*b))
            uc.mem_write(OS,struct.pack("<QQ",LBUF,RBUF))
            self._count_on=count
            try:
                self.call_stack(RENDER, rcx=self.HOST, r9=OS, stack=(0,b))
            finally:
                self._count_on=False
            L+=list(struct.unpack("<%df"%b, uc.mem_read(LBUF,4*b)))
            R+=list(struct.unpack("<%df"%b, uc.mem_read(RBUF,4*b)))
            done+=b
        return L,R

    def render_both(self,n,block=256,count=False):
        """ONE pass of the JX-style per-sample stubs (VOICE_WRAP x8 then
        MASTER_WRAP) returning BOTH the dry voice sum (main buffers, NaN
        dropped+counted) and the master L/R words -- the two listen paths of
        PORT_PIPELINE step 4 without advancing the state twice. count=True
        accumulates the instruction total in self._icount (block hook)."""
        uc=self.uc; Lout=[]; Rout=[]; dry=[0.0]*n; self.dry_nan=0
        offs={}; p=BUF_BASE
        for v in range(8):
            offs[('m',v)]=p; p+=4*block; offs[('s',v)]=p; p+=4*block
        offL=p; p+=4*block; offR=p; p+=4*block
        assert p<BUF_BASE+BUF_SIZE
        if count: self._icount=0
        done=0
        while done<n:
            b=min(block,n-done)
            self._count_on=count
            try:
                for v in range(8):
                    uc.mem_write(PB_VOICE, struct.pack("<QQQQQ",
                        self.state[v], v, offs[('m',v)], offs[('s',v)], b))
                    self._run(self.SVOICE)
                    w=struct.unpack("<%df"%b, uc.mem_read(offs[('m',v)],4*b))
                    for i,x in enumerate(w):
                        if x==x: dry[done+i]+=x
                        else: self.dry_nan+=1
                a2=b"".join(struct.pack("<Q",x) for pair in
                            ((offs[('m',v)],offs[('s',v)]) for v in range(8)) for x in pair)
                uc.mem_write(PB_MASTER, struct.pack("<QQQQ", self.state[8], offL, offR, b)
                             + b"\x00"*16 + a2)
                self._run(self.SMASTER)
            finally:
                self._count_on=False
            Lout+=list(struct.unpack("<%dI"%b, uc.mem_read(offL,4*b)))
            Rout+=list(struct.unpack("<%dI"%b, uc.mem_read(offR,4*b)))
            done+=b
        return dry,Lout,Rout
