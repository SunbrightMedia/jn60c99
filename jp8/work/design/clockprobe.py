"""who reads the assigner sample clock ([assign+0xB0], advanced ONLY by host RENDER 0x445edc -> 0x37df50)?"""
import sys, os, struct
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); os.environ["JP8_EMU_QUIET"]="1"
import jp8_emu as J
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ
from unicorn.x86_const import UC_X86_REG_RIP
jp=J.JP8(); jp.run_static_init(); uc=jp.uc
HOST=jp.bump(0x8000); uc.mem_write(HOST,b"\0"*0x8000); uc.mem_write(HOST+8,struct.pack("<f",96000.0))
jp.HOST=HOST; jp.call(J.BUILD,rcx=HOST)
jp.state=[int.from_bytes(uc.mem_read(HOST+0xA0+64*i,8),'little') for i in range(9)]
jp.proc=[int.from_bytes(uc.mem_read(HOST+0xB0+64*i,8),'little') for i in range(9)]
jp.assign=[int.from_bytes(uc.mem_read(HOST+0xB8+64*i,8),'little') for i in range(9)]
print("assign vptrs:", sorted(set(hex(int.from_bytes(uc.mem_read(a,8),'little')-J.IB) for a in jp.assign)))
jp.set_ftz(); jp.set_sr(44100.0); jp.host_init(); jp.recall(2)
hits={}
cells=[a+0xB0 for a in jp.assign]
def rd(uc_,acc,addr,size,val,u):
    for k,c in enumerate(cells):
        if c<=addr<c+8: 
            rip=uc_.reg_read(UC_X86_REG_RIP)-J.IB; hits[(k,hex(rip),PH[0])]=hits.get((k,hex(rip),PH[0]),0)+1
PH=["render"]
uc.ctl_flush_tb(); h=uc.hook_add(UC_HOOK_MEM_READ,rd); uc.ctl_flush_tb()
jp.render_both(512)
for ph,fn in (("noteon",lambda: [jp.note_on(k,100) for k in (60,64,67,71,74,77,80,83,86,89)]),("render2",lambda: jp.render_both(512)),("noteoff",lambda: [jp.note_off(k,64) for k in (60,64,67)]),("render3",lambda: jp.render_both(256))):
    PH[0]=ph; fn()
uc.hook_del(h); uc.ctl_flush_tb()
print("reads of [assign+0xB0] (unit, pc, phase): count ->", hits if hits else "NONE")
print("clock values:", [int.from_bytes(uc.mem_read(c,8),'little') for c in cells])
