import sys, os, struct, time
sys.path.insert(0,'gen'); import jp8_emu as J
from unicorn import *; from unicorn.x86_const import *
def trial(label, steps):
    jp=J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0)
    for s in steps:
        if s=='host': jp.host_init()
        elif s=='recall': jp.recall(0)
        elif s=='recall_nonotify': jp.recall(0,notify=False)
        elif s=='notify': jp.notify()
        elif s=='snap': jp.snap_ramps()
        elif s=='latch': jp.clear_latch()
        elif s=='noteon': jp.note_on(60,100)
    f0=jp.faults
    try:
        L,R=jp.render_host(128,block=64); pk=max(abs(x) for x in L if x==x)
        print("%-40s RENDER OK  peak %.4g faults %d->%d"%(label,pk,f0,jp.faults), flush=True)
    except Exception as e:
        print("%-40s RENDER FAIL %s faults %d->%d"%(label,str(e)[:40],f0,jp.faults), flush=True)
trial("build+setsr", [])
trial("build+setsr+noteon", ['noteon'])
trial("+host_init", ['host'])
trial("+recall(no notify)", ['recall_nonotify'])
trial("+recall+notify", ['recall'])
trial("+snap", ['snap'])
trial("+latch", ['latch'])
trial("host+recall+snap+latch", ['host','recall','snap','latch'])
