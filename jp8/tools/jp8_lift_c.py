#!/usr/bin/env python3
"""jp8_lift_c.py -- C side (process B) of the lifted-render gate: ctypes-loads libjp8lift.so, maps the oracle's regions
at the SAME addresses, loads the dumps, replays the judged drive of jp8_lift_seq through the LIFTED VOICE_WRAP /
MASTER_WRAP, and compares every output word and the whole post-run heap with the oracle's. exit 0 = EXACTLY 0.
No unicorn here (two-process rule). usage: jp8_lift_c.py <refdir> <libjp8lift.so>"""
import sys, os, json, struct, ctypes, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jp8_lift_seq as Q
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m),flush=True)
refdir,so=sys.argv[1],sys.argv[2]
lib=ctypes.CDLL(so)
lib.jp8_map.argtypes=[ctypes.c_uint64,ctypes.c_uint64]; lib.jp8_map.restype=ctypes.c_int
lib.jp8_load.argtypes=[ctypes.c_uint64,ctypes.c_char_p]; lib.jp8_load.restype=ctypes.c_int
lib.jp8_call.argtypes=[ctypes.c_void_p,ctypes.c_uint64,ctypes.c_uint64,ctypes.c_uint64,ctypes.c_uint64,ctypes.c_uint64]; lib.jp8_call.restype=ctypes.c_int
lib.jp8_alloc.argtypes=[ctypes.c_void_p]
lib.jp8_last_trap.restype=ctypes.c_char_p
lib.jp8_call_f.argtypes=[ctypes.c_void_p,ctypes.c_uint64,ctypes.c_uint64,ctypes.c_float]; lib.jp8_call_f.restype=ctypes.c_int
lib.jp8_heap_set.argtypes=[ctypes.c_uint64,ctypes.c_uint64]; lib.jp8_heap_get.restype=ctypes.c_uint64
DEBUG=os.environ.get("JP8_LIFT_DEBUG")
if DEBUG and hasattr(lib,"jp8_trace_open"): lib.jp8_trace_open.argtypes=[ctypes.c_char_p]
def trace_diff(oracle_path, c_path):
    """compare the two per-instruction traces (rva + rax rcx rdx rbx xmm0.lo); print the first divergence"""
    import capstone, pefile
    o=open(oracle_path,"rb").read(); m=open(c_path,"rb").read(); REC=4+32+4
    no,nm=len(o)//REC,len(m)//REC
    pe=pefile.PE("/home/user/jn60c99/jp8/truth/JUPITER-8VST3_64bit.vst3"); IMG=pe.get_memory_mapped_image(); IB=pe.OPTIONAL_HEADER.ImageBase
    md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64)
    def ins(rva):
        i=next(md.disasm(bytes(IMG[rva:rva+16]),IB+rva),None); return "%s %s"%(i.mnemonic,i.op_str) if i else "?"
    for k in range(min(no,nm)):
        ro=struct.unpack("<IQQQQI",o[REC*k:REC*k+REC]); rm=struct.unpack("<IQQQQI",m[REC*k:REC*k+REC])
        if ro!=rm:
            log("TRACE: %d instructions agree; divergence at step %d: oracle rva %x (%s) rax %x rcx %x rdx %x rbx %x xmm0 %08x | C rva %x (%s) rax %x rcx %x rdx %x rbx %x xmm0 %08x"%(
                k,k,ro[0],ins(ro[0]),ro[1],ro[2],ro[3],ro[4],ro[5],rm[0],ins(rm[0]),rm[1],rm[2],rm[3],rm[4],rm[5]))
            for j in range(max(0,k-6),k):
                r=struct.unpack("<IQQQQI",o[REC*j:REC*j+REC]); log("   step %d: %x %s  rax %x rcx %x rdx %x rbx %x"%(j,r[0],ins(r[0]),r[1],r[2],r[3],r[4]))
            return
    log("TRACE: identical over %d steps (oracle %d, C %d)"%(min(no,nm),no,nm))
CPU_SZ=512; R_OFF=0; RSP_OFF=4*8
# rsp = the CALLER's stack pointer meta["rsp"]; jp8_call_x pushes the dummy return slot, so the callee enters at meta["rsp"]-8,
# the oracle's entry rsp (jp8_emu.call). Until 2026-09-22 this was meta["rsp"]-8: every C frame sat 8 bytes low (PORT_LESSONS 12).
RELOC=hasattr(lib,"jp8_host")            # a JP8_RELOC build: guest addresses are translated to host arenas (jp8_cpu.h JP8_H)
if RELOC: lib.jp8_host.argtypes=[ctypes.c_uint64]; lib.jp8_host.restype=ctypes.c_void_p
def H(addr): return lib.jp8_host(addr) if RELOC else addr
def rd(addr,n): return ctypes.string_at(H(addr),n)
def wr(addr,b): ctypes.memmove(H(addr),b,len(b))
mapped=False; bad_total=0
for patch in Q.PATCHES:
    d=os.path.join(refdir,"p%02d"%patch); meta=json.load(open(os.path.join(d,"meta.json")))
    heap_len=meta["heap_end"]-Q.HEAP_BASE
    if not mapped:
        regions=((Q.IMG_BASE,meta["img_size"]),(Q.HEAP_BASE,0x8000000),(Q.STACK_BASE,Q.STACK_SIZE),(Q.BUF_BASE,Q.BUF_SIZE))
        if RELOC: regions=((0,0x100000),)+regions      # band 0 = the oracle's page 0 (gs base 0); the identity path mirrors it at BUF+0x20000
        for base,size in regions:
            if lib.jp8_map(base,size): sys.exit("cannot map 0x%x"%base)
        mapped=True
    assert heap_len<=0x8000000, "heap larger than the mapped 128 MB"
    lib.jp8_load(Q.IMG_BASE,os.path.join(d,"img.bin").encode()); lib.jp8_load(Q.HEAP_BASE,os.path.join(d,"heap_pre.bin").encode())
    if os.path.exists(os.path.join(d,"stack.bin")): lib.jp8_load(Q.STACK_BASE,os.path.join(d,"stack.bin").encode())   # PORT_LESSONS 12
    ctypes.memset(H(Q.BUF_BASE),0,Q.BUF_SIZE)
    if os.path.exists(os.path.join(d,"page0.bin")): wr(0 if RELOC else Q.GS_BASE,open(os.path.join(d,"page0.bin"),"rb").read())
    lib.jp8_heap_set(meta.get("heap_ptr0",meta["heap_end"]),Q.HEAP_BASE+0x8000000)
    if hasattr(lib,"jp8_hc_set"): lib.jp8_hc_set.argtypes=[ctypes.c_uint64]; lib.jp8_hc_set(meta.get("hc0",0x9000))
    wr(Q.PAIR_V,struct.pack("<QQ",Q.OUT_M,Q.OUT_S)); wr(Q.PAIR_M,struct.pack("<QQ",Q.OUT_L,Q.OUT_R))
    wr(Q.A2,b"".join(struct.pack("<QQ",Q.VOUT+8*v,Q.VOUT+8*v+4) for v in range(8)))
    cpu=ctypes.create_string_buffer(CPU_SZ); cp=ctypes.addressof(cpu)
    ref=open(os.path.join(d,"words.bin"),"rb").read(); got=bytearray(); state=meta["state"]
    trap=None; first=[]
    def call(rva,rcx,rdx,r8,r9=0):
        ctypes.memmove(cp+RSP_OFF,struct.pack("<Q",meta["rsp"]),8)
        return lib.jp8_call(cp,rva,rcx,rdx,r8,r9)
    for ev,arg in Q.events():
        if trap: break
        if ev=="build":
            # jp8_emu.build(): HOST = bump(0x8000) zeroed, then BUILD(HOST); state/proc/assign read from the HOST record
            host=lib.jp8_heap_get(); ctypes.memmove(cp+RSP_OFF,struct.pack("<Q",meta["rsp"]),8)
            lib.jp8_alloc  # (the runtime bumps through jp8_alloc; here the harness bumps the HOST block the same way)
            class _C(ctypes.Structure): _fields_=[("r",ctypes.c_uint64*16)]
            cc=_C.from_address(cp); cc.r[1]=0x8000; lib.jp8_alloc(cp); host=cc.r[0]
            if host!=meta["host"]: log("HOST differs: oracle 0x%x C 0x%x"%(meta["host"],host)); bad_total+=1
            if call(Q.BUILD,host,0,0): trap=lib.jp8_last_trap().decode(); continue
            state=[struct.unpack("<Q",rd(host+0xA0+64*i,8))[0] for i in range(9)]
            if state!=meta["state"]: log("state pointers differ: oracle %s C %s"%(["%x"%x for x in meta["state"]],["%x"%x for x in state]))
        elif ev=="setsr":
            ctypes.memmove(cp+RSP_OFF,struct.pack("<Q",meta["rsp"]),8)
            if lib.jp8_call_f(cp,Q.SETSR,meta["host"],arg): trap=lib.jp8_last_trap().decode()
        elif ev=="hostinit":
            for hid,val in Q.hostinit_values({int(k):v for k,v in meta["host_map"].items()}):
                if call(Q.HOSTPARAM,meta["host"],hid,val): trap=lib.jp8_last_trap().decode(); break
        elif ev=="noteon":
            if call(Q.NOTEON,meta["host"],arg,100): trap=lib.jp8_last_trap().decode()
        elif ev=="noteoff":
            if DEBUG and hasattr(lib,"jp8_trace_open"): lib.jp8_trace_open(os.path.join(d,"trace_noteoff_c.bin").encode())
            rc=call(Q.NOTEOFF,meta["host"],arg,64)
            if DEBUG and hasattr(lib,"jp8_trace_open"):
                lib.jp8_trace_close()
                if os.path.exists(os.path.join(d,"trace_noteoff.bin")): trace_diff(os.path.join(d,"trace_noteoff.bin"),os.path.join(d,"trace_noteoff_c.bin"))
            if rc: trap=lib.jp8_last_trap().decode()
        elif ev=="recall":
            vals=Q.recall_values(arg)
            for u in range(9):
                for pid,val in vals:
                    if call(Q.DISPATCH,meta["proc"][u],pid,0,val): trap=lib.jp8_last_trap().decode(); break
                if trap: break
            for u in range(9):
                if trap: break
                if call(Q.ASG_NOTIFY,meta["assign"][u],4,0): trap=lib.jp8_last_trap().decode()
        elif ev=="render":
            for s in range(arg):
                for v in range(8):
                    wr(Q.OUT_M,b"\0"*8); wr(Q.PAIR_V,struct.pack("<QQ",Q.OUT_M,Q.OUT_S))
                    if call(Q.VOICE_WRAP,state[v],v,Q.PAIR_V): trap=lib.jp8_last_trap().decode(); break
                    mw=rd(Q.OUT_M,8); got+=mw; wr(Q.VOUT+8*v,mw)
                if trap: break
                wr(Q.OUT_L,b"\0"*8); wr(Q.PAIR_M,struct.pack("<QQ",Q.OUT_L,Q.OUT_R))
                if call(Q.MASTER_WRAP,state[8],Q.A2,Q.PAIR_M): trap=lib.jp8_last_trap().decode(); break
                got+=rd(Q.OUT_L,8)
    bad=0
    if trap: log("patch %d: %s after %d words"%(patch,trap,len(got)//4)); bad+=1
    nw=min(len(ref),len(got))
    diffs=[i//4 for i in range(0,nw,4) if ref[i:i+4]!=got[i:i+4]]
    if len(ref)!=len(got): bad+=1
    if diffs:
        bad+=len(diffs)
        for i in diffs[:6]:
            per=18; smp=i//per; k=i%per; who="voice %d %s"%(k//2,"main" if k%2==0 else "sub") if k<16 else ("L" if k==16 else "R")
            log("patch %d: word %d (sample %d, %s) oracle %08x C %08x"%(patch,i,smp,who,struct.unpack("<I",ref[4*i:4*i+4])[0],struct.unpack("<I",got[4*i:4*i+4])[0]))
    post=open(os.path.join(d,"heap_post.bin"),"rb").read(); mine=rd(Q.HEAP_BASE,heap_len)
    if post!=mine:
        nd=0; shown=0
        for off in range(0,heap_len,4):
            if post[off:off+4]!=mine[off:off+4]:
                nd+=1
                if shown<6:
                    a=Q.HEAP_BASE+off; where="heap+0x%x"%off
                    for u,st in enumerate(state):
                        if st<=a<st+0xA9C0C0: where="state[%d]+0x%x"%(u,a-st)
                    log("patch %d: state differs at %s: oracle %s C %s"%(patch,where,post[off:off+4].hex(),mine[off:off+4].hex())); shown+=1
        bad+=nd; log("patch %d: %d heap dwords differ"%(patch,nd))
    log("patch %d: %d output words (%d differ), heap %s -> %s"%(patch,nw,len(diffs),"EXACT" if post==mine else "DIFFERS","PASS" if not bad else "FAIL"))
    bad_total+=bad
print("JP8 LIFT A/B (layer %s): %s"%(Q.LAYER,"EXACTLY 0 -- every output word and every heap byte match on patches %s"%Q.PATCHES if not bad_total else "%d differences -- NOT bit-exact"%bad_total))
sys.exit(0 if not bad_total else 1)
