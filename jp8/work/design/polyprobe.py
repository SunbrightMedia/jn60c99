import sys, os, struct
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); os.environ["JP8_EMU_QUIET"]="1"
import jp8_emu as J
jp=J.JP8(); jp.run_static_init(); uc=jp.uc
HOST=jp.bump(0x8000); uc.mem_write(HOST,b"\0"*0x8000); uc.mem_write(HOST+8,struct.pack("<f",96000.0))
jp.HOST=HOST; jp.call(J.BUILD,rcx=HOST)
a0=int.from_bytes(uc.mem_read(HOST+0xB8,8),'little'); vt=int.from_bytes(uc.mem_read(a0,8),'little')
f88=int.from_bytes(uc.mem_read(vt+0x88,8),'little'); f80=int.from_bytes(uc.mem_read(vt+0x80,8),'little')
print("assign0 vtbl slot 0x88 = rva 0x%x, slot 0x80 = rva 0x%x"%(f88-J.IB,f80-J.IB))
print("after BUILD: assigner voice count ([vt+0x88]()) =", jp.call(f88,rcx=a0)&0xFFFFFFFF, " host [HOST+0x38] (zero HOST) =", int.from_bytes(uc.mem_read(HOST+0x38,4),'little'), "(real ctor writes 8)")
