#!/usr/bin/env python3
"""jp8_sweep_collect.py -- build jp8/docs/SWEEP_44100.md from jp8/logs/sweep44100/p*.log (the ROW lines).
usage: jp8_sweep_collect.py [logdir] [out.md]"""
import sys, os, glob, re
HERE=os.path.dirname(os.path.abspath(__file__))
logdir=sys.argv[1] if len(sys.argv)>1 else os.path.join(HERE,"..","logs","sweep44100")
outp=sys.argv[2] if len(sys.argv)>2 else os.path.join(HERE,"..","docs","SWEEP_44100.md")
rows={}; missing=[]
for p in range(64):
    f=os.path.join(logdir,"p%02d.log"%p)
    if not os.path.exists(f): missing.append(p); continue
    r=[l for l in open(f) if "] ROW " in l]
    if not r: missing.append(p); continue
    rows[p]=r[-1].split("] ROW ",1)[1].strip()
npass=sum(1 for r in rows.values() if "| PASS |" in r)
fails=[p for p,r in rows.items() if "| PASS |" not in r]
with open(outp,"w") as o:
    o.write("# SWEEP_44100.md -- 64-patch listen sweep of the JP8 oracle at 44100 (PORT_PIPELINE step 4 reach)\n\n")
    o.write("Produced by `jp8/tools/jp8_sweep.py <patch>` (one fresh boot per patch, recall dispatch flag 0 = the HOSTPARAM path) and\n")
    o.write("collected by `jp8_sweep_collect.py`; every row has its log in `jp8/logs/sweep44100/pNN.log`. Labels: PROVEN (executed on\n")
    o.write("the plugin's own code under Unicorn). Pitch = DRY f0 by autocorrelation vs the engine's OWN pitch cells (jp8_d4_law.py),\n")
    o.write("E = early window (1024..17408 after note-on), L = late window (49152..65536); release = 24000-sample tail or the 3 s tail rule.\n\n")
    o.write("**Result: %d/64 PASS, %d FAIL%s%s.**\n\n"%(npass,len(fails)," (%s)"%",".join(str(p) for p in fails) if fails else "",
            "; %d patches missing (%s)"%(len(missing),",".join(str(p) for p in missing)) if missing else ""))
    o.write("| patch | name | verdict | f0 vs key per key (window) | harmonic | idle peak | NaN | faults | instr/sample idle/sustain | confound candidates |\n|---|---|---|---|---|---|---|---|---|---|\n")
    for p in range(64):
        if p in rows: o.write(rows[p]+"\n")
        else: o.write("| %d | (no log) | MISSING | | | | | | | |\n"%p)
print("SWEEP_44100.md: %d/64 PASS, fails %s, missing %s"%(npass,fails,missing))
