#!/usr/bin/env python3
"""jp8_lift_c.py -- C side (process B) of the lifted-code gates, on DRIVE2: ctypes-loads libjp8lift.so, maps the
oracle's regions at the SAME guest addresses (identity mmap, or host arenas in a JP8_RELOC build), loads the dumps,
then replays the judged drive of jp8_lift_seq: every control-plane event is the list of top-level calls process A
RECORDED from the oracle (entry, rcx, rdx, r8, r9, MXCSR, xmm1 float for SETSR), replayed verbatim through the LIFTED
code -- nothing is re-derived here (plumbing only); renders call the lifted VOICE_WRAP x8 + MASTER_WRAP. Compares
every output word, every recorded return value, the bump pointer, the whole post-run heap (and reports the stack).
exit 0 = EXACTLY 0. No unicorn here (two-process rule). usage: jp8_lift_c.py <refdir> <libjp8lift.so>"""
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
lib.jp8_last_trap.restype=ctypes.c_char_p
lib.jp8_call_f.argtypes=[ctypes.c_void_p,ctypes.c_uint64,ctypes.c_uint64,ctypes.c_float]; lib.jp8_call_f.restype=ctypes.c_int
lib.jp8_heap_set.argtypes=[ctypes.c_uint64,ctypes.c_uint64]; lib.jp8_heap_get.restype=ctypes.c_uint64
if hasattr(lib,"jp8_hc_set"): lib.jp8_hc_set.argtypes=[ctypes.c_uint64]
CPU_SZ=512; RSP_OFF=4*8; RAX_OFF=0; MX_OFF=16*8+16*16+5*4      # jp8_cpu.h CPU: r[16], x[16], zf sf cf of pf, mxcsr
RELOC=hasattr(lib,"jp8_host")            # a JP8_RELOC build: guest addresses are translated to host arenas (jp8_cpu.h JP8_H)
if RELOC: lib.jp8_host.argtypes=[ctypes.c_uint64]; lib.jp8_host.restype=ctypes.c_void_p
def H(addr): return lib.jp8_host(addr) if RELOC else addr
def rd(addr,n): return ctypes.string_at(H(addr),n)
def wr(addr,b): ctypes.memmove(H(addr),b,len(b))
def rq(addr): return struct.unpack("<Q",rd(addr,8))[0]
mapped=False; bad_total=0
for patch in Q.PATCHES:
    d=os.path.join(refdir,"p%02d"%patch); meta=json.load(open(os.path.join(d,"meta.json")))
    assert meta.get("drive")=="drive2", "reference %s is not a drive2 reference"%d
    heap_len=meta["heap_end"]-Q.HEAP_BASE
    if not mapped:
        regions=((Q.IMG_BASE,meta["img_size"]),(Q.HEAP_BASE,Q.HEAP_MAP),(Q.STACK_BASE,Q.STACK_SIZE),(Q.BUF_BASE,Q.BUF_SIZE))
        if RELOC: regions=((0,0x100000),)+regions      # band 0 = the oracle's page 0 (gs base 0); the identity path mirrors it at BUF+0x20000
        for base,size in regions:
            if lib.jp8_map(base,size): sys.exit("cannot map 0x%x"%base)
        mapped=True
    assert heap_len<=Q.HEAP_MAP, "heap larger than the mapped region"
    ctypes.memset(H(Q.HEAP_BASE),0,Q.HEAP_MAP)
    lib.jp8_load(Q.IMG_BASE,os.path.join(d,"img.bin").encode()); lib.jp8_load(Q.HEAP_BASE,os.path.join(d,"heap_pre.bin").encode())
    lib.jp8_load(Q.STACK_BASE,os.path.join(d,"stack.bin").encode())            # PORT_LESSONS 12
    ctypes.memset(H(Q.BUF_BASE),0,Q.BUF_SIZE)
    wr(0 if RELOC else Q.GS_BASE,open(os.path.join(d,"page0.bin"),"rb").read())
    lib.jp8_heap_set(meta["heap_ptr0"],Q.HEAP_BASE+Q.HEAP_MAP)
    if hasattr(lib,"jp8_hc_set"): lib.jp8_hc_set(meta["hc0"])
    wr(Q.PAIR_V,struct.pack("<QQ",Q.OUT_M,Q.OUT_S)); wr(Q.PAIR_M,struct.pack("<QQ",Q.OUT_L,Q.OUT_R))
    wr(Q.A2,b"".join(struct.pack("<QQ",Q.VOUT+8*v,Q.VOUT+8*v+4) for v in range(8)))
    cpu=ctypes.create_string_buffer(CPU_SZ); cp=ctypes.addressof(cpu)
    ref=open(os.path.join(d,"words.bin"),"rb").read(); got=bytearray(); state=meta["state"]
    trap=None; bad=0; mx=[meta.get("mx0",0x9FC0)]
    def enter(mxcsr):
        """the oracle's call(): MXCSR written, rsp = the fixed caller rsp, the RET sentinel at [rsp-8]"""
        ctypes.memmove(cp+RSP_OFF,struct.pack("<Q",meta["rsp"]),8)
        ctypes.memmove(cp+MX_OFF,struct.pack("<I",mxcsr),4)
        wr(meta["rsp"]-8,struct.pack("<Q",Q.RET))
    def call(rva,rcx,rdx,r8,r9=0,mxcsr=None):
        enter(mx[0] if mxcsr is None else mxcsr)
        return lib.jp8_call(cp,rva,rcx,rdx,r8,r9)
    for k,((ev,arg),rec) in enumerate(zip(Q.events(),meta["calls"])):
        if trap: break
        if ev=="render":
            for s in range(arg):
                for v in range(8):
                    wr(Q.OUT_M,b"\0"*8); wr(Q.PAIR_V,struct.pack("<QQ",Q.OUT_M,Q.OUT_S))
                    if call(Q.VOICE_WRAP,state[v],v,Q.PAIR_V): trap=lib.jp8_last_trap().decode(); break
                    mw=rd(Q.OUT_M,8); got+=mw; wr(Q.VOUT+8*v,mw)
                if trap: break
                wr(Q.OUT_L,b"\0"*8); wr(Q.PAIR_M,struct.pack("<QQ",Q.OUT_L,Q.OUT_R))
                if call(Q.MASTER_WRAP,state[8],Q.A2,Q.PAIR_M): trap=lib.jp8_last_trap().decode(); break
                got+=rd(Q.OUT_L,8)
            mx[0]=meta["mx_after"][k]; continue
        for c in rec:                                   # the oracle's own top-level calls for this event, verbatim
            mx[0]=c["mx"]
            if "xmm1" in c:
                enter(c["mx"]); rc=lib.jp8_call_f(cp,c["fn"],c["rcx"],struct.unpack("<f",struct.pack("<I",c["xmm1"]))[0])
            else:
                rc=call(c["fn"],c["rcx"],c["rdx"],c["r8"],c["r9"],c["mx"])
            if rc: trap="%s (event %s, call rva 0x%x)"%(lib.jp8_last_trap().decode(),ev,c["fn"]); break
            rax=struct.unpack("<Q",ctypes.string_at(cp+RAX_OFF,8))[0]
            if rax!=c["rax"]:
                log("patch %d: event %s call rva 0x%x returned 0x%x, oracle 0x%x"%(patch,ev,c["fn"],rax,c["rax"])); bad+=1
        if ev=="build" and not trap:
            host=meta["host"]
            st=[rq(host+0xA0+64*i) for i in range(9)]
            if st!=meta["state"]: log("patch %d: state pointers differ"%patch); bad+=1
            state=st
        mx[0]=meta["mx_after"][k]                       # the MXCSR the oracle's next call runs at (set_ftz inside 'build')
    if trap: log("patch %d: %s after %d words"%(patch,trap,len(got)//4)); bad+=1
    nw=min(len(ref),len(got))
    diffs=[i//4 for i in range(0,nw,4) if ref[i:i+4]!=got[i:i+4]]
    if len(ref)!=len(got): bad+=1; log("patch %d: %d words, oracle %d"%(patch,len(got)//4,len(ref)//4))
    if diffs:
        bad+=len(diffs)
        for i in diffs[:6]:
            per=18; smp=i//per; k=i%per; who="voice %d %s"%(k//2,"main" if k%2==0 else "sub") if k<16 else ("L" if k==16 else "R")
            log("patch %d: word %d (sample %d, %s) oracle %08x C %08x"%(patch,i,smp,who,struct.unpack("<I",ref[4*i:4*i+4])[0],struct.unpack("<I",got[4*i:4*i+4])[0]))
    hp=lib.jp8_heap_get()
    if hp!=meta["heap_final"]: log("patch %d: bump pointer C 0x%x oracle 0x%x"%(patch,hp,meta["heap_final"])); bad+=1
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
    spost=open(os.path.join(d,"stack_post.bin"),"rb").read(); smine=rd(Q.STACK_BASE,Q.STACK_SIZE)
    sd=0 if spost==smine else sum(1 for off in range(0,Q.STACK_SIZE,4) if spost[off:off+4]!=smine[off:off+4])
    log("patch %d: %d output words (%d differ), %d recorded calls replayed, heap %s, stack %s -> %s"%(
        patch,nw,len(diffs),sum(len(c) for c in meta["calls"]),"EXACT" if post==mine else "DIFFERS",
        "EXACT" if not sd else "%d dwords differ (reported, not graded)"%sd,"PASS" if not bad else "FAIL"))
    bad_total+=bad
print("JP8 LIFT A/B (layer %s, drive2): %s"%(Q.LAYER,"EXACTLY 0 -- every output word, return value and heap byte match on patches %s"%Q.PATCHES if not bad_total else "%d differences -- NOT bit-exact"%bad_total))
sys.exit(0 if not bad_total else 1)
