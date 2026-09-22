"""MXCSR schedule: the plugin sets FTZ|DAZ itself only inside process/worker (guard 0x36c8c0, READ); BUILD+SETSR run on
the host thread. Does SETSR (and BUILD) at 0x1F80 vs 0x9FC0 change the state? constructed HOST (+8 = 96000)."""
import sys, os, struct, hashlib
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); os.environ["JP8_EMU_QUIET"]="1"
import jp8_emu as J
mode=sys.argv[1]; sr=float(sys.argv[2])
jp=J.JP8(); jp.run_static_init(); uc=jp.uc
HOST=jp.bump(0x8000); uc.mem_write(HOST,b"\0"*0x8000); uc.mem_write(HOST+8,struct.pack("<f",96000.0))
jp.HOST=HOST
if mode=="allftz": jp.set_ftz()
jp.call(J.BUILD,rcx=HOST)
jp.state=[int.from_bytes(uc.mem_read(HOST+0xA0+64*i,8),'little') for i in range(9)]
jp.proc=[int.from_bytes(uc.mem_read(HOST+0xB0+64*i,8),'little') for i in range(9)]
jp.assign=[int.from_bytes(uc.mem_read(HOST+0xB8+64*i,8),'little') for i in range(9)]
h_build=hashlib.sha256(bytes(uc.mem_read(J.HEAP_BASE,jp.heap-J.HEAP_BASE))).hexdigest()[:16]
if mode=="oracle": jp.set_ftz()          # jp8_emu.boot order: BUILD 1F80, then FTZ, then SETSR
jp.set_sr(sr)
h_sr=hashlib.sha256(bytes(uc.mem_read(J.HEAP_BASE,jp.heap-J.HEAP_BASE))).hexdigest()[:16]
if mode=="hostthread": jp.set_ftz()      # plugin-faithful: SETSR on the host thread (1F80), FTZ only for process-side calls
jp.host_init(); jp.recall(63); d,L,R=jp.render_both(2048); jp.note_on(60,100); d2,L2,R2=jp.render_both(2048)
h_end=hashlib.sha256(bytes(uc.mem_read(J.HEAP_BASE,jp.heap-J.HEAP_BASE))).hexdigest()[:16]
W=hashlib.sha256(struct.pack("<%dI"%(2*(len(L)+len(L2))),*(L+L2+R+R2))).hexdigest()[:16]
print("%-10s sr %6.0f: heap after BUILD %s, after SETSR %s, end %s, words %s"%(mode,sr,h_build,h_sr,h_end,W))
