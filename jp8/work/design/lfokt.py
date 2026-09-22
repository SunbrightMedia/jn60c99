import sys, os, struct
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); os.environ["JP8_EMU_QUIET"]="1"
import jp8_emu as J
patch=int(sys.argv[1])
jp=J.JP8(); jp.run_static_init(); uc=jp.uc
jp.build(); jp.set_ftz(); jp.set_sr(44100.0); jp.host_init()
def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
def kt():
    out=[]
    for u in range(9):
        o=rq(jp.HOST+0xd8+64*u)
        if not o: out.append(None); continue
        s=rq(o+0x18); out.append((uc.mem_read(s+0xc,1)[0], uc.mem_read(s+0xb,1)[0]) if s else 'null+0x18')
    return out
print("patch",patch,"before recall (mode,dirty) per unit:",kt())
jp.recall(patch)
print("after oracle recall (DISPATCH 756 flag 0 + notify):",kt())
for u in range(9): jp.call(J.IB+0x442c30, rcx=rq(jp.HOST+0xd8+64*u), rdx=1)
print("after the host path's direct setter 0x442c30(1):",kt())
