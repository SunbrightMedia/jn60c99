"""playbook 90 rule 2 for the JP8: what do the 3 skipped ctors (JP8_SKIP_CTORS) do if run after the others?"""
import sys, os, struct
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); os.environ["JP8_EMU_QUIET"]="1"
import jp8_emu as J
a,b=J.XC_TABLE
for k in J.JP8_SKIP_CTORS:
    jp=J.JP8(); jp.run_static_init(); uc=jp.uc
    ptrs=struct.unpack("<%dQ"%((b-a)//8), uc.mem_read(J.IB+a,b-a)); idx=[i for i,p in enumerate(ptrs) if p and p-J.IB==k]
    d0=bytes(uc.mem_read(J.IB+0xD06000,0xD2BBE0-0xD06000)); h0=jp.heap; f0=jp.faults; hm0=jp.host_map()
    try: jp.call(J.IB+k,count=2_000_000); res="returned"
    except Exception as e: res="FAILED: "+str(e)[:70]
    d1=bytes(uc.mem_read(J.IB+0xD06000,0xD2BBE0-0xD06000))
    diff=[0xD06000+i for i in range(len(d0)) if d0[i]!=d1[i]]
    try: hm1=jp.host_map()
    except Exception as e: hm1="ERR"
    rd=[0xcbc2c4,0xcbc2d0,0xd06048,0xd06068,0xd22478,0xd27900,0xd28f8c,0xd29020]
    print("  changed:",[hex(x) for x in diff][:40],"\n  overlap with post-init READ set (report A):",[hex(r) for r in rd if any(r<=x<r+8 for x in diff)])
    print("ctor rva 0x%x (table index %s): %s; faults +%d, stray %d, heap +%d B, .data bytes changed %d%s, host map %s -> %s, unhandled imports %s"%(k,idx,res,jp.faults-f0,getattr(jp,'_stray',0),jp.heap-h0,len(diff),(" first 0x%x last 0x%x"%(diff[0],diff[-1]) if diff else ""),len(hm0),len(hm1) if hm1!="ERR" else hm1,dict(jp.unhandled)))
