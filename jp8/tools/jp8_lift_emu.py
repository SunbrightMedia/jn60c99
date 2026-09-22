#!/usr/bin/env python3
"""jp8_lift_emu.py -- ORACLE side (process A) of the lifted-code gates. For each patch of jp8_lift_seq: boot on the
corrected drive, idle, note-on, warm-up, DUMP the address space (image, heap up to the bump pointer), then run the
judged event list exactly as jp8_lift_seq says (direct calls with the stubs' arguments), recording every output
word; dump the heap again afterwards. Writes <outdir>/p<NN>/{img.bin,heap_pre.bin,heap_post.bin,meta.json,words.bin}.
usage: jp8_lift_emu.py <outdir>   (JP8_LIFT_LAYER selects the drive; JP8_LIFT_DEBUG=1 adds a note-off trace)"""
import sys, os, json, struct, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, jp8_lift_seq as Q
t0=time.time()
def log(m): print("[%6.1fs] %s"%(time.time()-t0,m),flush=True)
outdir=sys.argv[1]
for patch in Q.PATCHES:
    d=os.path.join(outdir,"p%02d"%patch); os.makedirs(d,exist_ok=True)
    jp=J.JP8(); jp.run_static_init(); uc=jp.uc
    if Q.LAYER=="boot":
        jp.set_ftz(); heap_end=jp.heap+0x7800000        # the C side maps 128 MB of heap; BUILD's 9 x 11 MB land inside
        hmap=jp.host_map()
    else:
        jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w,f=jp.host_init(); assert f==0
        jp.recall(patch); jp.snap_ramps(); jp.clear_latch()
        jp.render_both(Q.IDLE_N); jp.note_on(Q.KEY,100); jp.render_both(Q.WARM)
        heap_end=jp.heap; hmap=None
    heap_ptr0=jp.heap; hc0=getattr(jp,"_hc",0x9000)
    open(os.path.join(d,"img.bin"),"wb").write(bytes(uc.mem_read(J.IB,J.IMGSZ)))
    open(os.path.join(d,"heap_pre.bin"),"wb").write(bytes(uc.mem_read(Q.HEAP_BASE,heap_end-Q.HEAP_BASE)))
    uc.mem_write(Q.PAIR_V,struct.pack("<QQ",Q.OUT_M,Q.OUT_S)); uc.mem_write(Q.PAIR_M,struct.pack("<QQ",Q.OUT_L,Q.OUT_R))
    uc.mem_write(Q.A2,b"".join(struct.pack("<QQ",Q.VOUT+8*v,Q.VOUT+8*v+4) for v in range(8)))
    words=bytearray(); nsamp=0
    for ev,arg in Q.events():
        if ev=="build": jp.build(); assert jp.heap<=heap_end
        elif ev=="setsr": jp.call_f(J.SETSR,jp.HOST,arg)
        elif ev=="hostinit":
            for hid,val in Q.hostinit_values(hmap): jp.call(J.HOSTPARAM,rcx=jp.HOST,rdx=hid,r8=val)
        elif ev=="noteon": jp.call(J.NOTEON,rcx=jp.HOST,rdx=arg,r8=100)
        elif ev=="noteoff":
            if os.environ.get("JP8_LIFT_DEBUG"):
                from unicorn import UC_HOOK_CODE
                from unicorn.x86_const import UC_X86_REG_RAX,UC_X86_REG_RCX,UC_X86_REG_RDX,UC_X86_REG_RBX,UC_X86_REG_XMM0
                tr=bytearray()
                def th(uc_,a,sz,u): tr.extend(struct.pack("<IQQQQI",(a-J.IB)&0xFFFFFFFF,uc_.reg_read(UC_X86_REG_RAX),uc_.reg_read(UC_X86_REG_RCX),uc_.reg_read(UC_X86_REG_RDX),uc_.reg_read(UC_X86_REG_RBX),uc_.reg_read(UC_X86_REG_XMM0)&0xFFFFFFFF))
                uc.ctl_flush_tb(); hh=uc.hook_add(UC_HOOK_CODE,th); jp.call(J.NOTEOFF,rcx=jp.HOST,rdx=arg,r8=64); uc.hook_del(hh); uc.ctl_flush_tb()
                open(os.path.join(d,"trace_noteoff.bin"),"wb").write(bytes(tr))
                open(os.path.join(d,"heap_noteoff.bin"),"wb").write(bytes(uc.mem_read(Q.HEAP_BASE,heap_end-Q.HEAP_BASE)))
            else: jp.call(J.NOTEOFF,rcx=jp.HOST,rdx=arg,r8=64)
        elif ev=="recall":
            for u in range(9):
                for pid,val in Q.recall_values(arg): jp.call(J.DISPATCH,rcx=jp.proc[u],rdx=pid,r8=0,r9=val)
            for u in range(9): jp.call(J.ASG_NOTIFY,rcx=jp.assign[u],rdx=4)
        elif ev=="render":
            for s in range(arg):
                for v in range(8):
                    uc.mem_write(Q.OUT_M,b"\0"*8); uc.mem_write(Q.PAIR_V,struct.pack("<QQ",Q.OUT_M,Q.OUT_S))
                    jp.call(J.VOICE_WRAP,rcx=jp.state[v],rdx=v,r8=Q.PAIR_V)
                    mw=uc.mem_read(Q.OUT_M,8); words+=mw; uc.mem_write(Q.VOUT+8*v,bytes(mw))
                uc.mem_write(Q.OUT_L,b"\0"*8); uc.mem_write(Q.PAIR_M,struct.pack("<QQ",Q.OUT_L,Q.OUT_R))
                jp.call(J.MASTER_WRAP,rcx=jp.state[8],rdx=Q.A2,r8=Q.PAIR_M)
                words+=uc.mem_read(Q.OUT_L,8); nsamp+=1
    open(os.path.join(d,"words.bin"),"wb").write(bytes(words))
    open(os.path.join(d,"heap_post.bin"),"wb").write(bytes(uc.mem_read(Q.HEAP_BASE,heap_end-Q.HEAP_BASE)))
    open(os.path.join(d,"page0.bin"),"wb").write(bytes(uc.mem_read(0,0x1000)))
    meta=dict(patch=patch,layer=Q.LAYER,heap_end=heap_end,heap_ptr0=heap_ptr0,hc0=hc0,host_map=hmap,state=jp.state,proc=jp.proc,assign=jp.assign,host=jp.HOST,nsamp=nsamp,
              img_size=J.IMGSZ,faults=jp.faults,rsp=(Q.STACK_BASE+Q.STACK_SIZE-0x10000)&~0xF)
    json.dump(meta,open(os.path.join(d,"meta.json"),"w"))
    nz=sum(1 for i in range(0,len(words),4) if words[i:i+4]!=b"\0\0\0\0")
    log("layer %s patch %d: %d judged samples, %d output words (%d nonzero), heap %.1f MB, faults %d"%(Q.LAYER,patch,nsamp,len(words)//4,nz,(heap_end-Q.HEAP_BASE)/1e6,jp.faults))
