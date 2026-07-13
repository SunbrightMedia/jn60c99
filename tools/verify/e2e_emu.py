#!/usr/bin/env python3
"""e2e_emu.py — full-instance JUNO-60 engine under Unicorn for the END-TO-END A/B.

Composition ground truth (see e2e_ab_findings.md):
  BUILD (0x3C68D0) constructs 9 engine units (8 voice units + 1 master unit),
  each with its own 12MB state. Per audio block the plugin renders voice unit v
  per sample via sub_7FF91DFF8F30(state_v, v, {&main_v[i], &sub_v[i]}), then the
  master per sample via sub_7FF91DFF8EC0(state_8, a2(16 ptrs), {&L[i], &R[i]}).
  Per block per voice: assigner_v+168 += nSamples (sub_7FF91DFB5AB0).
  Note on/off broadcast: 0x3C72D0 / 0x3C7330 (synth, note, vel) -> 9 note objects.

This module reproduces exactly that composition, replacing only the WORKER THREAD
TRANSPORT (SetEvent/wait) with direct in-order calls — the DSP code, call order
per unit, and per-sample sequencing are the binary's own. Machine-code loop stubs
(hand-assembled below) run each unit's whole-block per-sample loop inside one
emu_start, so the JIT runs at full speed (all hooks are range-limited).
"""
import struct, collections
import pefile
from unicorn import *
from unicorn.x86_const import *

BIN = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/aea4b19d-JUNO60VST3_64bit.vst3"
pe = pefile.PE(BIN)
IB = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()
IMGSZ = (len(IMG) + 0xFFF) & ~0xFFF

BUILD   = IB + 0x3C68D0
SETSR   = IB + 0x3C7A20
DISPATCH= IB + 0x3B9A30
NOTEON  = IB + 0x3C7330   # sub_7FF91E027330 -> noteobj 0242D0 -> assigner noteOn (vtbl+8), carries velocity
NOTEOFF = IB + 0x3C72D0   # sub_7FF91E0272D0 -> noteobj 024230 -> assigner noteOff (vtbl+16, zeroes vel)
VOICE_WRAP  = IB + 0x398F30   # (state, voiceIdx, DWORD** outPair)
MASTER_WRAP = IB + 0x398EC0   # (state, float** a2x16, ptr-> {outL*, outR*})
ALLOC   = IB + 0x67522C
FATAL   = IB + 0x6ae028
PROC_VPTR = IB + 0x9C3018     # param-dispatch processor vtable
STATE_SZ  = 0xA83010
LATCH_OFF = 11022344

STACK_BASE=0x200000000; STACK_SIZE=0x2000000
HEAP_BASE =0x310000000; HEAP_SIZE =0x200000000
STUB_BASE =0x600000000
SCRATCH   =0x100000
FAKE_HEAP =0x4242000000
CODE_BASE =STUB_BASE+0x8000     # our driver stubs (outside import-hook range)
PB_VOICE  =STUB_BASE+0xA000     # voice stub parameter block
PB_MASTER =STUB_BASE+0xA100     # master stub parameter block (incl. 16-ptr a2)
BUF_BASE  =0x700000000          # audio buffers
BUF_SIZE  =0x200000

IMPORTS={}
for entry in pe.DIRECTORY_ENTRY_IMPORT:
    dll=entry.dll.decode()
    for imp in entry.imports:
        IMPORTS[imp.address-IB]=(dll, imp.name.decode() if imp.name else f"ord{imp.ordinal}")

# ---------------------------------------------------------------- tiny assembler
class Asm:
    def __init__(self): self.b=bytearray(); self.labels={}; self.fix=[]
    def raw(self,*bs): self.b+=bytes(bs)
    def label(self,n): self.labels[n]=len(self.b)
    def jnz(self,n):   self.b+=b"\x75"; self.fix.append((len(self.b),n)); self.b+=b"\x00"
    def movabs_rbp(self,imm): self.b+=b"\x48\xBD"+struct.pack("<Q",imm)
    def movabs_rax(self,imm): self.b+=b"\x48\xB8"+struct.pack("<Q",imm)
    def done(self):
        for pos,n in self.fix:
            rel=self.labels[n]-(pos+1)
            assert -128<=rel<128
            self.b[pos]=rel&0xFF
        return bytes(self.b)

def build_voice_stub(pb, fn):
    a=Asm()
    a.raw(0x55)                       # push rbp
    a.movabs_rbp(pb)
    a.raw(0x48,0x83,0xEC,0x30)        # sub rsp,0x30
    a.label("loop")
    a.raw(0x48,0x8B,0x45,0x10)        # mov rax,[rbp+0x10]  pMain
    a.raw(0x48,0x89,0x45,0x28)        # mov [rbp+0x28],rax  a3cell0
    a.raw(0x48,0x8B,0x45,0x18)        # mov rax,[rbp+0x18]  pSub
    a.raw(0x48,0x89,0x45,0x30)        # mov [rbp+0x30],rax  a3cell1
    a.raw(0x48,0x8B,0x4D,0x00)        # mov rcx,[rbp+0]     state
    a.raw(0x8B,0x55,0x08)             # mov edx,[rbp+8]     voice
    a.raw(0x4C,0x8D,0x45,0x28)        # lea r8,[rbp+0x28]
    a.movabs_rax(fn)
    a.raw(0xFF,0xD0)                  # call rax
    a.raw(0x48,0x83,0x45,0x10,0x04)   # add qword [rbp+0x10],4
    a.raw(0x48,0x83,0x45,0x18,0x04)   # add qword [rbp+0x18],4
    a.raw(0x48,0xFF,0x4D,0x20)        # dec qword [rbp+0x20]
    a.jnz("loop")
    a.raw(0x48,0x83,0xC4,0x30)        # add rsp,0x30
    a.raw(0x5D)                       # pop rbp
    a.raw(0xC3)                       # ret
    return a.done()

def build_master_stub(pb, fn):
    a=Asm()
    a.raw(0x55)
    a.movabs_rbp(pb)
    a.raw(0x48,0x83,0xEC,0x30)
    a.label("loop")
    a.raw(0x48,0x8B,0x45,0x08)        # mov rax,[rbp+8]     pL
    a.raw(0x48,0x89,0x45,0x20)        # mov [rbp+0x20],rax
    a.raw(0x48,0x8B,0x45,0x10)        # mov rax,[rbp+0x10]  pR
    a.raw(0x48,0x89,0x45,0x28)        # mov [rbp+0x28],rax
    a.raw(0x48,0x8B,0x4D,0x00)        # mov rcx,[rbp+0]     state8
    a.raw(0x48,0x8D,0x55,0x30)        # lea rdx,[rbp+0x30]  a2[16]
    a.raw(0x4C,0x8D,0x45,0x20)        # lea r8,[rbp+0x20]
    a.movabs_rax(fn)
    a.raw(0xFF,0xD0)
    a.raw(0x48,0x8D,0x4D,0x30)        # lea rcx,[rbp+0x30]
    a.raw(0xB8,0x10,0x00,0x00,0x00)   # mov eax,16
    a.label("adv")
    a.raw(0x48,0x83,0x01,0x04)        # add qword [rcx],4
    a.raw(0x48,0x83,0xC1,0x08)        # add rcx,8
    a.raw(0xFF,0xC8)                  # dec eax
    a.jnz("adv")
    a.raw(0x48,0x83,0x45,0x08,0x04)   # add qword [rbp+8],4
    a.raw(0x48,0x83,0x45,0x10,0x04)   # add qword [rbp+0x10],4
    a.raw(0x48,0xFF,0x4D,0x18)        # dec qword [rbp+0x18]
    a.jnz("loop")
    a.raw(0x48,0x83,0xC4,0x30)
    a.raw(0x5D)
    a.raw(0xC3)
    return a.done()

# ---------------------------------------------------------------- emulator
class E2E:
    def __init__(self):
        self.heap=HEAP_BASE; self.allocs=[]; self.tls={}; self.tls_ctr=1
        self.unhandled=collections.Counter()
        self.uc=uc=Uc(UC_ARCH_X86,UC_MODE_64)
        uc.mem_map(IB,IMGSZ,UC_PROT_ALL); uc.mem_write(IB,bytes(IMG))
        uc.mem_map(STACK_BASE,STACK_SIZE,UC_PROT_ALL)
        uc.mem_map(HEAP_BASE,HEAP_SIZE,UC_PROT_ALL)
        uc.mem_map(STUB_BASE,0x100000,UC_PROT_ALL)
        uc.mem_map(0,0x100000,UC_PROT_ALL)
        uc.mem_map(BUF_BASE,BUF_SIZE,UC_PROT_ALL)
        # SSE enable (like unit2 harness; harmless if already ok)
        cr0=uc.reg_read(UC_X86_REG_CR0); cr0&=~(1<<2); cr0|=(1<<1); uc.reg_write(UC_X86_REG_CR0,cr0)
        cr4=uc.reg_read(UC_X86_REG_CR4); cr4|=(1<<9)|(1<<10); uc.reg_write(UC_X86_REG_CR4,cr4)
        # IAT -> unique stubs holding `ret`; ranged code hook applies semantics
        self.stub2name={}
        for i,(rva,(dll,name)) in enumerate(sorted(IMPORTS.items())):
            stub=STUB_BASE+8*i
            uc.mem_write(IB+rva, struct.pack("<Q",stub))
            uc.mem_write(stub, b"\xC3")
            self.stub2name[stub]=(dll,name)
        stub_end=STUB_BASE+8*len(IMPORTS)+8
        assert stub_end < CODE_BASE
        # our driver stubs
        self.SVOICE=CODE_BASE
        vb=build_voice_stub(PB_VOICE, VOICE_WRAP)
        uc.mem_write(self.SVOICE, vb)
        self.SMASTER=CODE_BASE+0x400
        uc.mem_write(self.SMASTER, build_master_stub(PB_MASTER, MASTER_WRAP))
        # RANGE-LIMITED hooks only (JIT runs at full speed elsewhere)
        uc.hook_add(UC_HOOK_CODE,self._imp,begin=STUB_BASE,end=stub_end)
        uc.hook_add(UC_HOOK_CODE,self._alloc,begin=ALLOC,end=ALLOC)
        uc.hook_add(UC_HOOK_CODE,self._fatal,begin=FATAL,end=FATAL)
        uc.hook_add(UC_HOOK_MEM_FETCH_UNMAPPED,self._fetch)
        uc.hook_add(UC_HOOK_MEM_READ_UNMAPPED|UC_HOOK_MEM_WRITE_UNMAPPED,self._unmapped)
        self.faults=0
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
        r8=uc.reg_read(UC_X86_REG_R8);   r9=uc.reg_read(UC_X86_REG_R9)
        if name=="GetProcessHeap": return self._ret(uc,FAKE_HEAP)
        if name=="HeapAlloc":
            p=self.bump(r8)
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
        if name=="TlsSetValue": self.tls[rcx]=rdx; return self._ret(uc,1)
        if name=="TlsGetValue": return self._ret(uc,self.tls.get(rcx,0))
        if name in ("InitializeCriticalSection","InitializeCriticalSectionAndSpinCount",
                    "InitializeCriticalSectionEx","DeleteCriticalSection",
                    "EnterCriticalSection","LeaveCriticalSection","InitializeSListHead"):
            return self._ret(uc,1)
        if name in ("GetLastError",): return self._ret(uc,0)
        if name in ("GetCurrentThreadId","GetCurrentProcessId"): return self._ret(uc,0x1000)
        if name.startswith("Create") or name.startswith("Open"):
            self._hc=getattr(self,"_hc",0x9000)+16; return self._ret(uc,self._hc)
        if name in ("RaiseException","RtlPcToFileHeader","RtlUnwind","RtlUnwindEx",
                    "RtlCaptureContext","RtlLookupFunctionEntry","RtlVirtualUnwind",
                    "_CxxThrowException","terminate","abort"):
            self.unhandled[name]+=1; return self._ret(uc,0)
        if name.startswith("Get") or name.startswith("Query"): return self._ret(uc,0)
        self.unhandled[name]+=1
        return self._ret(uc,0)
    def _alloc(self,uc,address,size,user):
        if address!=ALLOC: return
        sz=uc.reg_read(UC_X86_REG_RCX) or 16
        p=self.bump(sz); uc.mem_write(p,b"\x00"*min(((sz+15)&~15),0x2000000))
        self.allocs.append((p,sz))
        rsp=uc.reg_read(UC_X86_REG_RSP)
        r=int.from_bytes(uc.mem_read(rsp,8),'little')
        uc.reg_write(UC_X86_REG_RAX,p)
        uc.reg_write(UC_X86_REG_RIP,r); uc.reg_write(UC_X86_REG_RSP,rsp+8)
    def _fatal(self,uc,address,size,user):
        if address==FATAL:
            self.hit_fatal=getattr(self,'hit_fatal',0)+1
            uc.emu_stop()
    def _fetch(self,uc,access,address,size,value,user):
        try: uc.mem_map(address&~0xFFF,0x1000,UC_PROT_ALL)
        except: pass
        uc.mem_write(address, b"\xC3"); uc.reg_write(UC_X86_REG_RAX,0)
        self.faults+=1
        return True
    def _unmapped(self,uc,access,address,size,value,user):
        self.faults+=1
        try: uc.mem_map(address&~0xFFF,0x1000,UC_PROT_ALL); return True
        except: return True
    def call(self,fn,rcx=0,rdx=0,r8=0,r9=0,count=0):
        uc=self.uc
        rsp=(STACK_BASE+STACK_SIZE-0x10000)&~0xF; rsp-=8
        uc.reg_write(UC_X86_REG_RSP,rsp)
        uc.reg_write(UC_X86_REG_RCX,rcx&(2**64-1)); uc.reg_write(UC_X86_REG_RDX,rdx&(2**64-1))
        uc.reg_write(UC_X86_REG_R8,r8&(2**64-1));   uc.reg_write(UC_X86_REG_R9,r9&(2**64-1))
        RET=SCRATCH+0x5000
        uc.mem_write(rsp,struct.pack("<Q",RET))
        uc.emu_start(fn,RET,count=count)
        rip=uc.reg_read(UC_X86_REG_RIP)
        if rip!=RET: raise RuntimeError(f"call to 0x{fn-IB:x} stopped at rva 0x{rip-IB:x}")
        return uc.reg_read(UC_X86_REG_RAX)
    def call_f(self,fn,rcx,xmm1_f32):
        uc=self.uc
        rsp=(STACK_BASE+STACK_SIZE-0x10000)&~0xF; rsp-=8
        uc.reg_write(UC_X86_REG_RSP,rsp)
        uc.reg_write(UC_X86_REG_RCX,rcx)
        uc.reg_write(UC_X86_REG_XMM1,struct.unpack('<Q',struct.pack('<f',xmm1_f32)+b'\0\0\0\0')[0])
        RET=SCRATCH+0x5000
        uc.mem_write(rsp,struct.pack("<Q",RET))
        uc.emu_start(fn,RET,count=0)
        rip=uc.reg_read(UC_X86_REG_RIP)
        if rip!=RET: raise RuntimeError(f"call_f stopped at rva 0x{rip-IB:x}")
    # ------------------------------------------------------------ instance ops
    def build(self, sr):
        self.HOST=self.bump(0x8000); self.uc.mem_write(self.HOST,b"\x00"*0x8000)
        self.call(BUILD, rcx=self.HOST)
        self.call_f(SETSR, self.HOST, sr)
        u=self.uc
        self.state=[]; self.proc=[]; self.assign=[]; self.noteobj=[]
        for i in range(9):
            self.state.append(int.from_bytes(u.mem_read(self.HOST+80+64*i,8),'little'))
            self.proc.append(int.from_bytes(u.mem_read(self.HOST+96+64*i,8),'little'))
            self.assign.append(int.from_bytes(u.mem_read(self.HOST+104+64*i,8),'little'))
            self.noteobj.append(int.from_bytes(u.mem_read(self.HOST+120+64*i,8),'little'))
        # sanity
        st_allocs=sorted(a for a,s in self.allocs if s==STATE_SZ)
        assert len(st_allocs)>=9, f"state allocs {len(st_allocs)}"
        for i in range(9):
            assert self.state[i] in st_allocs, hex(self.state[i])
            vp=int.from_bytes(u.mem_read(self.proc[i],8),'little')
            assert vp==PROC_VPTR, f"unit{i} proc vptr {hex(vp)}"
    def rd_u32(self,addr): return struct.unpack("<I",self.uc.mem_read(addr,4))[0]
    def rd_i32(self,addr): return struct.unpack("<i",self.uc.mem_read(addr,4))[0]
    def dispatch(self,unit,idx,val,flag=1):
        return self.call(DISPATCH, rcx=self.proc[unit], rdx=idx, r8=flag, r9=val)
    def dispatch_all(self,idx,val,flag=1):
        for u in range(9): self.dispatch(u,idx,val,flag)
    def note_on(self,note,vel):  self.call(NOTEON,  rcx=self.HOST, rdx=note, r8=vel)
    def note_off(self,note,vel=64): self.call(NOTEOFF, rcx=self.HOST, rdx=note, r8=vel)
    def snap_all(self):
        """Settle only the ACTIVE ramps of every unit to their targets and
        deactivate them. This clears the mid-flight ramps setSampleRate/recall
        arm (incl. the 5 nan start==target,time=0 ramps) so the state reaches the
        steady state our C engine holds — WITHOUT touching inactive records, whose
        stale targets would otherwise clobber recall's DIRECT coefficient writes
        (the plugin recalls ENV/VCF coeffs by immediate store, not through the
        ramp record). Snapping active-only was validated: post-snap coeffs then
        match our recall bit-for-bit."""
        uc=self.uc
        for u in range(9):
            st=self.state[u]
            base=int.from_bytes(uc.mem_read(st+88,8),'little')
            a=int.from_bytes(uc.mem_read(st+112,8),'little')
            b=int.from_bytes(uc.mem_read(st+120,8),'little')
            n=(b-a)//4
            idxs=struct.unpack("<%di"%n,uc.mem_read(a,4*n)) if n>0 else []
            for ix in idxs:
                rec=base+40*ix
                outp=int.from_bytes(uc.mem_read(rec,8),'little')
                tgt=bytes(uc.mem_read(rec+20,4))     # target bits
                if outp: uc.mem_write(outp,tgt)      # *out = target
                uc.mem_write(rec+12,b"\x00\x00\x00\x00")  # accum = 0
                uc.mem_write(rec+28,b"\x00\x00\x00\x00")  # active = 0
                uc.mem_write(rec+36,b"\x00\x00\x00\x00")  # step_cnt = 0
            uc.mem_write(st+120,struct.pack("<Q",a))  # empty active-index list
    def clear_latch(self):
        """Zero every unit's warmup mute latch (state+11022344) so voice+master
        DSP renders immediately, matching our C engine (no warmup mute)."""
        for u in range(9):
            self.uc.mem_write(self.state[u]+LATCH_OFF,b"\x00\x00\x00\x00")
    def active_smoothers(self,u):
        a=int.from_bytes(self.uc.mem_read(self.state[u]+112,8),'little')
        b=int.from_bytes(self.uc.mem_read(self.state[u]+120,8),'little')
        return (b-a)//4
    def set_ftz(self):
        self.uc.reg_write(UC_X86_REG_MXCSR, 0x9FC0)   # FTZ|DAZ + mask all
    # ------------------------------------------------------------ block render
    def render(self, n, block=600):
        """Render n samples; returns (Lbits,Rbits) lists of uint32."""
        uc=self.uc
        Lout=[]; Rout=[]
        # buffer layout: per-voice main[block], sub[block]; master L,R
        offs={}
        p=BUF_BASE
        for v in range(8):
            offs[('m',v)]=p; p+=4*block
            offs[('s',v)]=p; p+=4*block
        offL=p; p+=4*block
        offR=p; p+=4*block
        assert p<BUF_BASE+BUF_SIZE
        done=0
        while done<n:
            b=min(block,n-done)
            # per-block per-voice: assigner counter += b (sub_7FF91DFB5AB0)
            for v in range(8):
                c=int.from_bytes(uc.mem_read(self.assign[v]+168,8),'little')
                uc.mem_write(self.assign[v]+168, struct.pack("<Q",(c+b)&(2**64-1)))
            # voices (whole block each, in order — units are isolated)
            for v in range(8):
                uc.mem_write(PB_VOICE, struct.pack("<QQQQQ",
                    self.state[v], v, offs[('m',v)], offs[('s',v)], b))
                self._run(self.SVOICE)
            # master per sample over the block
            a2=b"".join(struct.pack("<Q",x) for pair in
                        ((offs[('m',v)],offs[('s',v)]) for v in range(8)) for x in pair)
            uc.mem_write(PB_MASTER, struct.pack("<QQQQ", self.state[8], offL, offR, b)
                         + b"\x00"*16 + a2)
            self._run(self.SMASTER)
            lb=uc.mem_read(offL,4*b); rb=uc.mem_read(offR,4*b)
            Lout+=list(struct.unpack(f"<{b}I",lb))
            Rout+=list(struct.unpack(f"<{b}I",rb))
            done+=b
        return Lout,Rout
    def _run(self,stub):
        uc=self.uc
        rsp=(STACK_BASE+STACK_SIZE-0x10000)&~0xF; rsp-=8
        uc.reg_write(UC_X86_REG_RSP,rsp)
        RET=SCRATCH+0x5000
        uc.mem_write(rsp,struct.pack("<Q",RET))
        uc.emu_start(stub,RET,count=0)
        rip=uc.reg_read(UC_X86_REG_RIP)
        if rip!=RET: raise RuntimeError(f"stub stopped at 0x{rip:x} (rva 0x{rip-IB:x})")

# ---------------------------------------------------------------- patch recall
SCRIPT_XML = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/7c621d41-Script.xml"
BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"
HEADER, STRIDE, BLOB_OFF, NPATCH = 23, 20223, 16, 64

def load_leaves():
    import re
    xml=open(SCRIPT_XML,encoding='utf-8',errors='replace').read()
    vals=re.findall(r'<value>(.*?)</value>',xml,re.S)
    leaves=[]
    for p,v in enumerate(vals):
        nm=re.search(r'<name>(.*?)</name>',v)
        nm=nm.group(1) if nm else '?'
        ml=p-2
        if 19<=ml<=71: bb=2*ml-4
        elif 88<=ml<=135: bb=8*ml-430
        else: continue
        if nm.startswith('PATCH NAME'): continue
        leaves.append((p,nm,p+740,bb))
    return leaves

def bank_bytes(): return open(BANK,'rb').read()

def patch_blob(bank,idx): return bank[HEADER+idx*STRIDE+BLOB_OFF: HEADER+(idx+1)*STRIDE]

def patch_name(bank,idx):
    nm=bank[HEADER+idx*STRIDE: HEADER+idx*STRIDE+16]
    return bytes(c if 32<=c<127 else 32 for c in nm).decode().strip()

def dec(blob,b): return ((blob[b]&0xF)<<4)|(blob[b+1]&0xF)

def recall_patch(e, idx, leaves=None, bank=None):
    leaves=leaves or load_leaves(); bank=bank or bank_bytes()
    blob=patch_blob(bank,idx)
    errs=0
    for (p,nm,disp,bb) in leaves:
        val=dec(blob,bb)
        for u in range(9):
            try: e.dispatch(u,disp,val)
            except RuntimeError: errs+=1
    return errs
