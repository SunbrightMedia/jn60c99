#!/usr/bin/env python3
"""jp8_lift_emu.py -- ORACLE side (process A) of the lifted-code gates, on DRIVE2 (jp8_lift_seq). For each patch:
boot on drive2, settle, note-on, warm-up (layers render/recall) or stop right after the static initializers (layer
boot), DUMP the address space (image, heap, stack, page 0), then run the judged event list, RECORDING every top-level
call the oracle makes for a control-plane event (entry rva, rcx, rdx, r8, r9, MXCSR, the float in xmm1, rax) so the
C side replays exactly those calls; renders call VOICE_WRAP x8 + MASTER_WRAP directly and record every output word.
Dumps the heap and the stack again afterwards.
Writes <outdir>/p<NN>/{img.bin,heap_pre.bin,stack.bin,page0.bin,heap_post.bin,stack_post.bin,meta.json,words.bin}.
usage: jp8_lift_emu.py <outdir>   (JP8_LIFT_LAYER selects the layer)"""
import sys, os, json, struct, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, jp8_lift_seq as Q
from unicorn.x86_const import UC_X86_REG_XMM1
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m),flush=True)
M64=(1<<64)-1
outdir=sys.argv[1]
for patch in Q.PATCHES:
    d=os.path.join(outdir,"p%02d"%patch); os.makedirs(d,exist_ok=True)
    jp=J.JP8(); assert not jp.legacy, "the lift gates grade DRIVE2 only (D7)"
    uc=jp.uc; control={}
    if Q.LAYER=="boot":
        ok,fail=jp.run_static_init(); assert fail==0
        heap_end=jp.heap+0x7800000          # the C side maps 128 MB of heap; factory + BUILD (~105 MB) land inside
    else:
        jp.boot(patch=patch)                # drive2: static init, factory, BUILD, FTZ, SETSR, host_init, recall(patch)
        jp.render_both(Q.SETTLE)            # the plugin's walker settles the recalled ramps (no snap)
        # step-4 control on the SAME drive (PORT_LESSONS 14): the settled idle must be silent and finite
        dry,L,R=jp.render_both(4096)
        fl=struct.unpack("<%df"%(2*len(L)),struct.pack("<%dI"%(2*len(L)),*(L+R)))
        nan=sum(1 for x in fl if x!=x)+jp.dry_nan; peak=max(abs(x) for x in fl if x==x); dpk=max(abs(x) for x in dry)
        control=dict(idle_nan=nan,idle_master_peak=peak,idle_dry_peak=dpk,ramps=dict(jp.ramp_census()))
        log("patch %d CONTROL idle 4096 after the drive2 boot: master peak %.3g dry peak %.3g NaN %d, live bad ramps %d, all bad ramps %d"%(
            patch,peak,dpk,nan,control["ramps"]["live_bad"],control["ramps"]["all_bad"]))
        jp.note_on(Q.KEY,100); jp.render_both(Q.WARM)
        heap_end=jp.heap
    heap_ptr0=jp.heap; hc0=getattr(jp,"_hc",0x9000); mx0=getattr(jp,"_mxcsr",0x1F80)
    open(os.path.join(d,"img.bin"),"wb").write(bytes(uc.mem_read(J.IB,J.IMGSZ)))
    open(os.path.join(d,"heap_pre.bin"),"wb").write(bytes(uc.mem_read(Q.HEAP_BASE,heap_end-Q.HEAP_BASE)))
    # the STACK is state too (PORT_LESSONS 12): BUILD copies a 16-byte record whose last dword is residue of static init
    open(os.path.join(d,"stack.bin"),"wb").write(bytes(uc.mem_read(Q.STACK_BASE,Q.STACK_SIZE)))
    open(os.path.join(d,"page0.bin"),"wb").write(bytes(uc.mem_read(0,0x1000)))
    uc.mem_write(Q.PAIR_V,struct.pack("<QQ",Q.OUT_M,Q.OUT_S)); uc.mem_write(Q.PAIR_M,struct.pack("<QQ",Q.OUT_L,Q.OUT_R))
    uc.mem_write(Q.A2,b"".join(struct.pack("<QQ",Q.VOUT+8*v,Q.VOUT+8*v+4) for v in range(8)))
    # RECORDER: every top-level call jp8_emu makes (make_host, BUILD, SETSR via call_f, HOSTPARAM, NOTEON/OFF ...)
    rec=None; orig=jp.call
    def rcall(fn,rcx=0,rdx=0,r8=0,r9=0,count=0,timeout_us=0):
        ent=dict(fn=fn-J.IB,rcx=rcx&M64,rdx=rdx&M64,r8=r8&M64,r9=r9&M64,mx=getattr(jp,"_mxcsr",0x1F80))
        if fn==J.SETSR: ent["xmm1"]=uc.reg_read(UC_X86_REG_XMM1)&0xFFFFFFFF
        ent["rax"]=orig(fn,rcx=rcx,rdx=rdx,r8=r8,r9=r9,count=count,timeout_us=timeout_us)&M64
        if rec is not None: rec.append(ent)
        return ent["rax"]
    jp.call=rcall
    words=bytearray(); nsamp=0; evcalls=[]; evmx=[]
    for ev,arg in Q.events():
        rec=[]
        if ev=="build": jp.build(); assert jp.heap<=heap_end; jp.set_ftz()
        elif ev=="setsr": jp.set_sr(arg)
        elif ev=="hostinit": w,f=jp.host_init(); assert f==0
        elif ev=="recall": jp.recall(arg)
        elif ev=="noteon": jp.note_on(arg,100)
        elif ev=="noteoff": jp.note_off(arg,64)
        elif ev=="render":
            rec=None
            for s in range(arg):
                for v in range(8):
                    uc.mem_write(Q.OUT_M,b"\0"*8); uc.mem_write(Q.PAIR_V,struct.pack("<QQ",Q.OUT_M,Q.OUT_S))
                    orig(J.VOICE_WRAP,rcx=jp.state[v],rdx=v,r8=Q.PAIR_V)
                    mw=uc.mem_read(Q.OUT_M,8); words+=mw; uc.mem_write(Q.VOUT+8*v,bytes(mw))
                uc.mem_write(Q.OUT_L,b"\0"*8); uc.mem_write(Q.PAIR_M,struct.pack("<QQ",Q.OUT_L,Q.OUT_R))
                orig(J.MASTER_WRAP,rcx=jp.state[8],rdx=Q.A2,r8=Q.PAIR_M)
                words+=uc.mem_read(Q.OUT_L,8); nsamp+=1
        evcalls.append(rec or []); evmx.append(getattr(jp,"_mxcsr",0x1F80))   # MXCSR the oracle's next call uses
        rec=None
    jp.call=orig
    open(os.path.join(d,"words.bin"),"wb").write(bytes(words))
    open(os.path.join(d,"heap_post.bin"),"wb").write(bytes(uc.mem_read(Q.HEAP_BASE,heap_end-Q.HEAP_BASE)))
    open(os.path.join(d,"stack_post.bin"),"wb").write(bytes(uc.mem_read(Q.STACK_BASE,Q.STACK_SIZE)))
    meta=dict(patch=patch,layer=Q.LAYER,drive="drive2",heap_end=heap_end,heap_ptr0=heap_ptr0,heap_final=jp.heap,hc0=hc0,mx0=mx0,
              state=jp.state,proc=jp.proc,assign=jp.assign,host=jp.HOST,nsamp=nsamp,img_size=J.IMGSZ,faults=jp.faults,
              rsp=(Q.STACK_BASE+Q.STACK_SIZE-0x10000)&~0xF,calls=evcalls,mx_after=evmx,control=control,events=Q.events())
    json.dump(meta,open(os.path.join(d,"meta.json"),"w"))
    nz=sum(1 for i in range(0,len(words),4) if words[i:i+4]!=b"\0\0\0\0")
    log("layer %s patch %d: %d judged samples, %d output words (%d nonzero), %d recorded calls, heap %.1f MB (bump +%d B in the list), faults %d"%(
        Q.LAYER,patch,nsamp,len(words)//4,nz,sum(len(c) for c in evcalls),(heap_end-Q.HEAP_BASE)/1e6,jp.heap-heap_ptr0,jp.faults))
