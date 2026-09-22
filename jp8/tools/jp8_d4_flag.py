#!/usr/bin/env python3
"""recall with dispatch flag <flag> (0 = arm ramp, the HOSTPARAM way; 1 = write cell now), snap, then render: do the
recalled cells survive the plugin's own ramp walker? usage: d4_flag.py <patch> <flag>"""
import sys, os, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J
patch=int(sys.argv[1]); flag=int(sys.argv[2])
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w,f=jp.host_init(); assert f==0
uc=jp.uc; st=jp.state[0]
def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
def rf(a): return struct.unpack("<f",uc.mem_read(a,4))[0]
CELLS=(0x1390,0x13a0,0x1470,0x1480,0x14e0,0x5340,0x52d0,0x5200,0x5210,0x320,0x330,0xc00,0xc10,0xc20,0xc30)
def show(tag): print("%-34s active ramps %3d | %s"%(tag,(rq(st+0x78)-rq(st+0x70))//4," ".join("%x=%.5g"%(c,rf(st+c)) for c in CELLS)))
mins=jp.pool_mins(); blob=J.patch_blob(J.bank_bytes(),patch)
for u in range(9):
    for pool in J.ACTIVE_POOLS:
        pid=J.POOL_BASE_ID+pool; jp.dispatch(u,pid,J.pool_value(blob,pool)+mins[pid],flag=flag)
jp.notify()
show("flag %d recall(%d)"%(flag,patch))
jp.snap_ramps(); jp.clear_latch(); show("  + snap")
jp.render_both(64); show("  + 64 samples")
jp.render_both(4096); show("  + 4160 samples")
