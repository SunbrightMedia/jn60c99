"""host-order sensitivity with the constructed HOST: A = SETSR -> host_init -> recall (the plan), B = host_init ->
recall -> SETSR (a DAW that restores state before setupProcessing). Same MXCSR (FTZ) throughout; no snap."""
import sys, os, struct, hashlib
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); os.environ["JP8_EMU_QUIET"]="1"
import jp8_emu as J
order=sys.argv[1]; patch=int(sys.argv[2])
jp=J.JP8(); jp.run_static_init(); uc=jp.uc
HOST=jp.bump(0x8000); uc.mem_write(HOST,b"\0"*0x8000); uc.mem_write(HOST+8,struct.pack("<f",96000.0))
jp.HOST=HOST; jp.call(J.BUILD,rcx=HOST)
jp.state=[int.from_bytes(uc.mem_read(HOST+0xA0+64*i,8),'little') for i in range(9)]
jp.proc=[int.from_bytes(uc.mem_read(HOST+0xB0+64*i,8),'little') for i in range(9)]
jp.assign=[int.from_bytes(uc.mem_read(HOST+0xB8+64*i,8),'little') for i in range(9)]
jp.set_ftz()
if order=="A": jp.set_sr(44100.0); jp.host_init(); jp.recall(patch)
else: jp.host_init(); jp.recall(patch); jp.set_sr(44100.0)
d,L,R=jp.render_both(4096); jp.note_on(60,100); d2,L2,R2=jp.render_both(4096); jp.note_off(60,64); d3,L3,R3=jp.render_both(4096)
W=struct.pack("<%dI"%(2*(len(L)+len(L2)+len(L3))),*(L+L2+L3+R+R2+R3)); open("ord_%s_p%d.bin"%(order,patch),"wb").write(W)
print(order,patch,"words sha",hashlib.sha256(W).hexdigest()[:16])
