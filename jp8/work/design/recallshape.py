"""oracle recall law (units outer, pools inner, notify once) vs the HOST PARAM ENTRY's own shape (per param: per unit:
[756 -> direct setter 0x442c30], DISPATCH flag 0, ASG_NOTIFY 4). Constructed HOST (HOST+8 = 96000.0), no snap."""
import sys, os, struct, hashlib
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); os.environ["JP8_EMU_QUIET"]="1"
import jp8_emu as J, jp8_lift_seq as Q
shape=sys.argv[1]; patch=int(sys.argv[2])
jp=J.JP8(); jp.run_static_init(); uc=jp.uc
HOST=jp.bump(0x8000); uc.mem_write(HOST,b"\0"*0x8000); uc.mem_write(HOST+8,struct.pack("<f",96000.0))
jp.HOST=HOST; jp.call(J.BUILD,rcx=HOST)
jp.state=[int.from_bytes(uc.mem_read(HOST+0xA0+64*i,8),'little') for i in range(9)]
jp.proc=[int.from_bytes(uc.mem_read(HOST+0xB0+64*i,8),'little') for i in range(9)]
jp.assign=[int.from_bytes(uc.mem_read(HOST+0xB8+64*i,8),'little') for i in range(9)]
def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
jp.set_ftz(); jp.set_sr(44100.0); jp.host_init()
vals=Q.recall_values(patch)
if shape=="oracle":
    for u in range(9):
        for pid,val in vals: jp.call(J.DISPATCH,rcx=jp.proc[u],rdx=pid,r8=0,r9=val)
    for u in range(9): jp.call(J.ASG_NOTIFY,rcx=jp.assign[u],rdx=4)
else:
    for pid,val in vals:
        for u in range(9):
            if pid==756: jp.call(J.IB+0x442c30,rcx=rq(HOST+0xd8+64*u),rdx=val)
            jp.call(J.DISPATCH,rcx=jp.proc[u],rdx=pid,r8=0,r9=val)
            jp.call(J.ASG_NOTIFY,rcx=jp.assign[u],rdx=4)
d0,L0,R0=jp.render_both(2048); jp.note_on(60,100); d1,L1,R1=jp.render_both(8192); jp.note_off(60,64); d2,L2,R2=jp.render_both(4096)
W=struct.pack("<%dI"%(2*(len(L0)+len(L1)+len(L2))),*(L0+L1+L2+R0+R1+R2))
open("rs_%s_p%d.bin"%(shape,patch),"wb").write(W)
open("rsheap_%s_p%d.bin"%(shape,patch),"wb").write(bytes(uc.mem_read(J.HEAP_BASE,jp.heap-J.HEAP_BASE)))
print(shape,patch,"master sha",hashlib.sha256(W).hexdigest()[:16],"dry(note) sha",hashlib.sha256(struct.pack("<%df"%len(d1),*d1)).hexdigest()[:16])
