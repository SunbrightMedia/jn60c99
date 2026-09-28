#!/usr/bin/env python3
"""jp8_template_export.py -- the SHIPPING TEMPLATE of the JP8 engine (PORT_PIPELINE step 6), process A (Unicorn).
Cut point: POST-STATIC-INIT (PSI). Everything after it -- the FACTORY 0x444FE0 (ALLOC 0x8D0 + ctor 0x444000), BUILD,
FTZ, SETSR, host_init, every recall -- runs LIVE in the lifted C (jp8_engine.c), exactly the drive2 order the layer-3
gate proves. The template is the oracle's address space right after run_static_init(), region by region:
  page0  guest 0x0          (the gs page: __chkstk reads its stack limit there)
  image  guest 0x180000000  the whole mapped image AS ORACLE MEMORY (.text byte tables, .rdata, .data incl. the
                            runtime-filled tail, IAT -> stub pointers) -- never a partial image (SHIPPING_DESIGN item 5)
  stack  guest 0x200000000  WITH the static-init residue (PORT_LESSONS 12: BUILD copies stack bytes into the heap)
  heap   guest 0x310000000  [base, bump pointer)
  buf    guest 0x700000000  empty (render buffers + pointer tables, the gates' layout)
  pb     guest 0x600000000  empty (the stub parameter blocks PB_VOICE/PB_MASTER; import stubs are call targets only)
and the runtime scalars (heap_ptr0, heap limit, hc0 = the fake-handle counter, the entry rsp, the RET sentinel, the
static-init stats). Also the recall/host_init call lists: every HOSTPARAM call jp8_emu makes, RECORDED from the oracle
(host id, raw value) -- the engine replays them verbatim (plumbing only).
FORMAT JP8T v1 (little endian): "JP8T" u32 version u32 nregions
   per region: u64 guest_base u64 map_size u32 nruns, per run: u32 off u32 len bytes[len]   (zero pages are skipped)
   scalars: u64 heap_ptr0 u64 heap_limit u64 hc0 u64 rsp u64 ret u32 static_ok u32 static_fail u32 static_skipped u32 faults
   u32 crc32 of every byte before it
Self-check: the file is parsed back and every region compared byte for byte with oracle memory; TOOTH: one flipped
byte in a copy must fail the check (seen to fail).
usage: jp8_template_export.py <out.bin> [recall_tab.h] [recall_tab.json]"""
import sys, os, struct, zlib, gzip, json, time, hashlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m),flush=True)
out=sys.argv[1]
HEAP_MAP=0x8000000
REGIONS=[("page0",0x0,0x100000),("image",J.IB,J.IMGSZ),("stack",J.STACK_BASE,J.STACK_SIZE),("heap",J.HEAP_BASE,HEAP_MAP),
         ("buf",J.BUF_BASE,J.BUF_SIZE),("pb",J.STUB_BASE,0x10000)]
RSP=(J.STACK_BASE+J.STACK_SIZE-0x10000)&~0xF; RET=J.SCRATCH+0x5000
PAGE=0x1000
def runs_of(blob):
    """(off, bytes) runs of the non-zero pages of blob"""
    out=[]; i=0; n=len(blob)
    while i<n:
        if not any(blob[i:i+PAGE]): i+=PAGE; continue
        j=i
        while j<n and any(blob[j:j+PAGE]): j+=PAGE
        out.append((i,blob[i:j])); i=j
    return out
def parse(buf):
    """-> (regions {name: (base, size, bytearray)}, scalars dict); raises on a bad file"""
    assert buf[:4]==b"JP8T", "magic"
    ver,nreg=struct.unpack_from("<II",buf,4); assert ver==1, "version"
    crc=struct.unpack_from("<I",buf,len(buf)-4)[0]
    if zlib.crc32(buf[:-4])&0xFFFFFFFF!=crc: raise ValueError("crc32 mismatch")
    p=12; regs=[]
    for _ in range(nreg):
        base,size,nruns=struct.unpack_from("<QQI",buf,p); p+=20
        mem=bytearray(size)
        for _ in range(nruns):
            off,ln=struct.unpack_from("<II",buf,p); p+=8; mem[off:off+ln]=buf[p:p+ln]; p+=ln
        regs.append((base,size,mem))
    sc=struct.unpack_from("<QQQQQIIII",buf,p); p+=struct.calcsize("<QQQQQIIII")
    assert p==len(buf)-4, "trailing bytes"
    return regs,dict(zip(("heap_ptr0","heap_limit","hc0","rsp","ret","static_ok","static_fail","static_skipped","faults"),sc))

jp=J.JP8(); assert not jp.legacy
ok,fail=jp.run_static_init(); skipped=jp.static_skipped
log("static init: %d ok, %d failed, %d skipped by address, %d faults (stray pages mapped), heap 0x%x, hc 0x%x"%(
    ok,fail,skipped,jp.faults,jp.heap,getattr(jp,"_hc",0x9000)))
assert fail==0
hc0=getattr(jp,"_hc",0x9000)
mem={}
for name,base,size in REGIONS:
    if name=="heap": mem[name]=bytes(jp.uc.mem_read(base,jp.heap-base))+b"\0"*0     # [base, bump pointer)
    elif name in ("buf","pb"): mem[name]=b""
    else: mem[name]=bytes(jp.uc.mem_read(base,min(size,0x1000) if name=="page0" else size))
# the oracle maps stray pages for faults during static init: list them (they are NOT carried; state it)
stray=[(b,e) for b,e,_ in jp.uc.mem_regions() if not any(rb<=b<rb+rs for _,rb,rs in REGIONS) and not (J.STUB_BASE<=b<J.STUB_BASE+0x100000)]
log("oracle regions outside the template: %s"%(", ".join("0x%x-0x%x"%(b,e+1) for b,e in stray) or "none"))
body=bytearray(b"JP8T"+struct.pack("<II",1,len(REGIONS)))
for name,base,size in REGIONS:
    rr=runs_of(mem[name])
    body+=struct.pack("<QQI",base,size,len(rr))
    for off,b in rr: body+=struct.pack("<II",off,len(b))+b
    log("region %-5s guest 0x%09x map 0x%08x: %d runs, %d bytes carried"%(name,base,size,len(rr),sum(len(b) for _,b in rr)))
body+=struct.pack("<QQQQQIIII",jp.heap,J.HEAP_BASE+HEAP_MAP,hc0,RSP,RET,ok,fail,skipped,jp.faults)
body+=struct.pack("<I",zlib.crc32(bytes(body))&0xFFFFFFFF)
open(out,"wb").write(body); open(out+".gz","wb").write(gzip.compress(bytes(body),9))
log("wrote %s (%d bytes, sha256 %s) and .gz (%d bytes)"%(out,len(body),hashlib.sha256(body).hexdigest()[:16],os.path.getsize(out+".gz")))
# SELF-CHECK: parse the file back, compare every region with oracle memory byte for byte
def check(buf):
    regs,sc=parse(buf); bad=0
    for (name,base,size),(b2,s2,m2) in zip(REGIONS,regs):
        assert (b2,s2)==(base,size)
        if name=="heap": ref=bytes(jp.uc.mem_read(base,jp.heap-base)); got=bytes(m2[:len(ref)]); tail=any(m2[len(ref):])
        elif name in ("buf","pb"): ref=b""; got=b""; tail=any(m2)
        elif name=="page0": ref=bytes(jp.uc.mem_read(0,0x1000)); got=bytes(m2[:0x1000]); tail=any(m2[0x1000:])
        else: ref=bytes(jp.uc.mem_read(base,size)); got=bytes(m2); tail=False
        if ref!=got or tail: bad+=1; log("SELF-CHECK: region %s differs"%name)
    if (sc["heap_ptr0"],sc["hc0"],sc["rsp"],sc["ret"])!=(jp.heap,hc0,RSP,RET): bad+=1; log("SELF-CHECK: scalars differ")
    return bad
buf=open(out,"rb").read()
assert check(buf)==0, "template self-check FAILED"
log("SELF-CHECK: every region byte-identical to oracle memory, scalars equal")
# the tooth: one byte flipped inside the image run -> the check must fail (crc, or the region compare with the crc fixed)
t=bytearray(buf); k=len(t)//2; t[k]^=0x01
try: check(bytes(t)); bit=False
except ValueError as e: bit="crc: %s"%e
t[-4:]=struct.pack("<I",zlib.crc32(bytes(t[:-4]))&0xFFFFFFFF)
try: r=check(bytes(t)); bit2=r>0
except Exception as e: bit2="parse: %s"%e
assert bit and bit2, "TEMPLATE TOOTH DID NOT BITE (%r, %r)"%(bit,bit2)
log("TOOTH bites: flipped byte %d -> %s; with the crc re-sealed -> region compare fails (%s)"%(k,bit,bit2))
# ---- the recorded call lists: host_init + the 64 recalls, as the ORACLE issues them on drive2
if len(sys.argv)>2:
    tab_h=sys.argv[2]; tab_j=sys.argv[3] if len(sys.argv)>3 else os.path.splitext(tab_h)[0]+".json"
    jp.build(); jp.set_ftz(); jp.set_sr(44100.0)
    rec=[]; orig=jp.call
    def rcall(fn,rcx=0,rdx=0,r8=0,r9=0,count=0,timeout_us=0):
        rec.append((fn-J.IB,rcx,rdx&0xFFFFFFFF,r8&0xFFFFFFFF)); return orig(fn,rcx=rcx,rdx=rdx,r8=r8,r9=r9,count=count,timeout_us=timeout_us)
    jp.call=rcall
    w,f=jp.host_init(); assert f==0
    hinit=[(hid,val) for fn,rcx,hid,val in rec if fn==J.HOSTPARAM-J.IB and rcx==jp.HOST]; assert len(hinit)==len(rec)==w
    recalls=[]
    for p in range(64):
        rec.clear(); jp.recall(p)
        assert all(fn==J.HOSTPARAM-J.IB and rcx==jp.HOST for fn,rcx,_,_ in rec)
        recalls.append([(hid,val) for _,_,hid,val in rec])
    jp.call=orig
    npool=len(recalls[0]); assert all(len(r)==npool for r in recalls)
    hids=[h for h,_ in recalls[0]]; assert all([h for h,_ in r]==hids for r in recalls), "the host id order differs between patches"
    import jp8_bank as B
    bk=B.bank_bytes(); names=[B.patch_name(bk,p) for p in range(64)]
    json.dump(dict(host_init=hinit,host_ids=hids,values=[[v for _,v in r] for r in recalls],names=names),open(tab_j,"w"))
    L=["/* jp8_recall_tab.h -- GENERATED by jp8/tools/jp8_template_export.py from the ORACLE's own HOSTPARAM calls on drive2",
       " * (host id, raw value), never re-derived. host_init first, then per factory patch the recall in call order. */",
       "#define JP8_NHOSTINIT %d"%len(hinit),"#define JP8_NPOOL %d"%npool,
       "static const uint32_t jp8_hostinit_tab[JP8_NHOSTINIT][2] = {%s};"%", ".join("{0x%x, %d}"%hv for hv in hinit),
       "static const uint32_t jp8_recall_hid[JP8_NPOOL] = {%s};"%", ".join("0x%x"%h for h in hids),
       "static const uint32_t jp8_recall_val[64][JP8_NPOOL] = {"]
    for r in recalls: L.append("  {%s},"%", ".join("%d"%v for _,v in r))
    L.append("};")
    open(tab_h,"w").write("\n".join(L)+"\n")
    log("recall table: host_init %d calls, %d pools per patch, 64 patches -> %s, %s"%(len(hinit),npool,tab_h,tab_j))
