#!/usr/bin/env python3
"""d4_census.py -- parameter -> cell census for the pitch block: for each engine id, dispatch min then max on
unit 0 after a full boot and record every cell written in slot 0 (< 0x5ED0) of state[0] and in proc[0].
usage: d4_census.py <patch> <id_lo> <id_hi>"""
import sys, os, struct, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J, pe_recon
from unicorn import UC_HOOK_MEM_WRITE
patch=int(sys.argv[1]); lo=int(sys.argv[2]); hi=int(sys.argv[3])
rows=pe_recon.PE(J.BIN).params(list(range(lo,hi+1)))["rows"]
jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w,f=jp.host_init(); assert f==0
jp.recall(patch); jp.snap_ramps(); jp.clear_latch()
uc=jp.uc; st=jp.state[0]; pr=jp.proc[0]
for pid in range(lo,hi+1):
    r=rows.get(pid)
    if not r or not r["name"] or r["name"] in ("_reserve_","_NULL_"): continue
    if r["min"]==r["max"]: continue
    got=collections.OrderedDict()
    def hw(uc_,acc,addr,size,value,user):
        if st<=addr<st+0x5ED0: got.setdefault(("st",addr-st,size),[]).append(value)
        elif pr<=addr<pr+0x4000: got.setdefault(("proc",addr-pr,size),[]).append(value)
    h=uc.hook_add(UC_HOOK_MEM_WRITE,hw)
    try:
        for v in (r["min"],r["max"]):
            jp.dispatch(0,pid,v,flag=1)
    except Exception as e:
        print("id %d %s: dispatch failed %s"%(pid,r["name"],str(e)[:50])); uc.hook_del(h); continue
    uc.hook_del(h)
    def fmt(k,vs):
        if k[2]==4:
            fl=[struct.unpack("<f",struct.pack("<I",x&0xffffffff))[0] for x in vs]
            return "%s+0x%x=[%s]"%(k[0],k[1],",".join("%.5g"%x if abs(x)>1e-6 or x==0 else "%.3e"%x for x in fl))
        return "%s+0x%x=%r"%(k[0],k[1],vs)
    cells=[fmt(k,vs) for k,vs in got.items()]
    print("id %d %-22s [%d..%d] def %d: %s"%(pid,r["name"],r["min"],r["max"],r["default"]," ".join(cells) if cells else "(no writes)"), flush=True)
