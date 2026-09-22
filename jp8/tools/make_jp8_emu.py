#!/usr/bin/env python3
"""make_jp8_emu.py -- generate jp8_emu.py FROM tools/verify/jx_emu.py (the
JX-3P oracle template) by constant substitution, the way the TB-303 emu was
made (/tmp/tb303/make_emu.py). Every replacement is asserted present, so a
template drift breaks the generator loudly instead of silently shipping JX
constants. The JP8 constants are READ (static, abi_check + disassembly,
gen/abi_ledger.md) unless marked otherwise; the recon boot proves them."""
import os, re
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = "/home/user/jn60c99/tools/verify/jx_emu.py"
src = open(SRC).read()
TRUTH = os.path.normpath(os.path.join(HERE, "..", "truth", "JUPITER-8VST3_64bit.vst3"))

repl = [
 ('BIN  = os.path.join(REPO, "jx3p", "truth", "JX3P.vst3")',
  'sys.path.insert(0, "/home/user/jn60c99/tools/verify"); sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))\n'
  'BIN  = %r' % TRUTH),
 ('PROC_VPTR = IB + 0x9F9A90     # CPrmDSPJx3pPlugin vtable (S2 RTTI-located)',
  'PROC_VPTR = IB + 0xA54158     # CPrmDSPJp8Plugin vtable (RTTI, xmap8.py) READ'),
 ('DISPATCH  = IB + 0x3EBB00     # Plugin slot 11 (S2 vtable-slot transfer)',
  'DISPATCH  = IB + 0x437630     # Plugin slot 11 (same cmp edx,0x138 jump-table idiom) READ'),
 ('ALLOC     = IB + 0x6AB63C     # CRT allocator twin (byte-pattern, unique match)',
  'ALLOC     = IB + 0x6F5B04     # CRT allocator: the callee BUILD passes ecx=STATE_SZ to READ'),
 ('BUILD     = IB + 0x3F8610     # PROVEN by probe: builds 9 units of STATE_SZ',
  'BUILD     = IB + 0x445020     # CWaveGen slot 0x08: mov r15d,9 ; mov ecx,0xa9c0c0 READ'),
 ('VOICE_WRAP= IB + 0x377080     # (state, voiceIdx, DWORD** outPair) -- JUNO twin',
  'VOICE_WRAP= IB + 0x3F80B0     # (state, voiceIdx, DWORD** outPair) -- JX idiom byte-for-byte: latch [rcx+0xa9c0b8], tail-call GC 0x440180 READ'),
 ('MASTER_WRAP=IB + 0x377010     # (state, a2[16], DWORD** outPair) -- JUNO twin',
  'MASTER_WRAP=IB + 0x3F8040     # (state8, a2[16], DWORD** outPair) -- RENDER calls it at 0x446229 with rcx=[HOST+0x2a0]=state[8] READ\nRENDER    = IB + 0x445DC0     # CWaveGen slot 0x38 = host process(): needs a CONSTRUCTED CWaveGen (per-channel vectors at HOST+0x50/+0x78); faults on the zero-filled HOST -- NOT the oracle path'),
 ('STATE_SZ  = 0xAAC310', 'STATE_SZ  = 0xA9C0C0'),
 ('SETSR     = IB + 0x3F9970     # (rcx=HOST, xmm1=float rate)   -- FLOAT IN XMM1',
  'SETSR     = IB + 0x4464F0     # (rcx=HOST, xmm1=float rate)   -- FLOAT IN XMM1 (abi_check)'),
 ('NOTEON    = IB + 0x3F9150     # (rcx=HOST, dl=note, r8b=vel)  engine vtbl 0x80',
  'NOTEON    = IB + 0x445CF0     # (rcx=HOST, dl=note, r8b=vel)  CWaveGen slot 0x70 -> unit 0x442030'),
 ('NOTEOFF   = IB + 0x3F90F0     # (rcx=HOST, dl=note, r8b=vel)  engine vtbl 0x78',
  'NOTEOFF   = IB + 0x445C90     # (rcx=HOST, dl=note, r8b=vel)  CWaveGen slot 0x68 -> unit 0x441f90'),
 ('ASG_NOTIFY= IB + 0x356BF0     # (rcx=assign obj, edx=what)    JUNO twin 0x3549B0',
  'ASG_NOTIFY= IB + 0x37CD80     # (rcx=assign obj, edx=what)    CAssignJp8 vtable 0x9f3158 slot 1'),
 ('HOSTPARAM = IB + 0x3F9A30     # (rcx=HOST, edx=host id, r8d=val) -- needs the',
  'HOSTPARAM = IB + 0x4465B0     # (rcx=HOST, edx=host id, r8d=val) -- CWaveGen slot 0x60; needs the'),
 ('                              # controller-built id map at .data 0xCE9038',
  '                              # controller-built id map at .data 0xD22478 (rip-relative load in HOSTPARAM)'),
 ('ENGINE_VTBL = IB + 0xA15B88   # slots: 08 BUILD 18 SETSR 38 RENDER 78 NOTEOFF',
  'ENGINE_VTBL = IB + 0xA704B0   # CWaveGen (36 slots): 08 BUILD 18 SETSR 38 RENDER 60 HOSTPARAM'),
 ('                              #        80 NOTEON 70 HOSTPARAM (pe_recon vtable)',
  '                              #        68 NOTEOFF 70 NOTEON (roles by STRUCTURE, not slot transfer)'),
 ('XC_TABLE  = (0x96C660, 0x96E0C8)   # C++ static initializers (pe_recon crt_init);',
  'XC_TABLE  = (0x9B8658, 0x9BA0C0)   # C++ static initializers (pe_recon crt_init);'),
 ('                              # they fill .data\'s runtime tail [0xCE7800,0xCF2860)',
  '                              # they fill .data\'s runtime tail [0xD20A00,0xD2BBE0)'),
 ('LATCH_OFF = 0xAAC308          # per-unit warm-up mute latch (960 at clean boot)',
  'LATCH_OFF = 0xA9C0B8          # the wrappers decrement [rcx+0xa9c0b8] (READ); reads 960 at clean boot (PROVEN, recon boot)'),
 ('from jx_bank import (BANK_HEADER, BANK_STRIDE, BANK_BLOB_OFF, ACTIVE_POOLS,\n                     POOL_BASE_ID, bank_bytes, patch_blob, pool_value)',
  'from jp8_bank import (BANK_HEADER, BANK_STRIDE, BANK_BLOB_OFF, ACTIVE_POOLS,\n                     POOL_BASE_ID, bank_bytes, patch_blob, pool_value, patch_name)'),
 # HOST record: JX state@+80 proc@+96 assign@+104 ; JP8 state@+0xa0 proc@+0xb0 assign@+0xb8 (BUILD: lea rsi,[rcx+0xa8]; [rsi-8]=state [rsi+8]=proc [rsi+0x10]=assign)
 ("self.state.append(int.from_bytes(u.mem_read(self.HOST+80+64*i,8),'little'))",
  "self.state.append(int.from_bytes(u.mem_read(self.HOST+0xA0+64*i,8),'little'))"),
 ("self.proc.append(int.from_bytes(u.mem_read(self.HOST+96+64*i,8),'little'))",
  "self.proc.append(int.from_bytes(u.mem_read(self.HOST+0xB0+64*i,8),'little'))"),
 ("self.assign.append(int.from_bytes(u.mem_read(self.HOST+104+64*i,8),'little'))",
  "self.assign.append(int.from_bytes(u.mem_read(self.HOST+0xB8+64*i,8),'little'))"),
 ('buf=bytes(self.uc.mem_read(IB+0xCE7800, 0xCF2860-0xCE7800))',
  'buf=bytes(self.uc.mem_read(IB+0xD20A00, 0xD2BBE0-0xD20A00))'),
 ('root=rq(IB+0xCE9038)', 'root=rq(IB+0xD22478)'),
 ('SKIP_CTORS = {0xB73A4, 0xB6F30, 0x57DEF0}', 'SKIP_CTORS = set(JP8_SKIP_CTORS)'),
 ('"jx_emu: UNMAPPED', '"jp8_emu: UNMAPPED'),
 ('os.environ.get("JX_EMU_QUIET")', 'os.environ.get("JP8_EMU_QUIET")'),
]
for a, b in repl:
    assert src.count(a) == 1, "template drift, expected once: %r (%d)" % (a[:60], src.count(a))
    src = src.replace(a, b)
# the stubs need a real wrapper address; only install them when one is known
old = "        self.SVOICE=CODE_BASE\n        uc.mem_write(self.SVOICE, _voice_stub(PB_VOICE, VOICE_WRAP))\n        self.SMASTER=CODE_BASE+0x400\n        uc.mem_write(self.SMASTER, _master_stub(PB_MASTER, MASTER_WRAP))"
new = "        self.SVOICE=CODE_BASE; self.SMASTER=CODE_BASE+0x400\n        if VOICE_WRAP: uc.mem_write(self.SVOICE, _voice_stub(PB_VOICE, VOICE_WRAP))\n        if MASTER_WRAP: uc.mem_write(self.SMASTER, _master_stub(PB_MASTER, MASTER_WRAP))"
assert src.count(old) == 1; src = src.replace(old, new)
# drop the JX __main__ probe; insert the skip list + JP8 extension
src = src[:src.index('if __name__=="__main__":')]
head = src.index("class _Asm:")
src = src[:head] + "# static initializers that FAULT under emulation, skipped BY ADDRESS (discovered\n# by jp8_boot.py --discover; see JP8_STATUS.md). Empty until discovered.\nJP8_SKIP_CTORS = [0xB7244, 0xB6DD0, 0x5C83C0]   # ctor #4 UC_ERR_EXCEPTION, #89 UC_ERR_INSN_INVALID (NULL vtable -> jmp 0), #95 UC_ERR_MAP crash-walk (the JX trio, playbook: same indices)\n\n" + src[head:]
src = src.replace('"""jx_emu.py -- JX-3P full-instance engine under Unicorn (the JX twin of\ne2e_emu.py).',
                  '"""jp8_emu.py -- JUPITER-8 full-instance engine under Unicorn, GENERATED from\ntools/verify/jx_emu.py by make_jp8_emu.py (constants swapped, see gen/abi_ledger.md).')
src += r'''
# ---------------------------------------------------------------- JP8 extension
class JP8(JX):
    """the JP8 oracle: JX machinery + the shipping RENDER entry (no per-unit
    wrappers located yet) + an instruction counter for the S3 cost estimate"""
    def __init__(self):
        super().__init__()
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
'''
out = os.path.join(HERE, "jp8_emu.py")
open(out, "w").write(src)
print("wrote", out, len(src), "bytes")
