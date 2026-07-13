import sys, ctypes
sys.path.insert(0,'/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
import numpy as np
IDLE0,NOTE=48000,12000
def plug_warm(p,idle):
    e=E.E2E(); e.build(48000); e.snap_all(); e.clear_latch(); e.set_ftz()
    e.render(idle); e.snap_all(); E.recall_patch(e,p); e.snap_all(); e.clear_latch()
    e.note_on(60,105); L,R=e.render(NOTE)
    return (np.array(L,np.uint32).view(np.float32).astype(np.float64),
            np.array(R,np.uint32).view(np.float32).astype(np.float64))
def rms(x): return float(np.sqrt((x*x).mean()))
def corr(x,y,maxlag=96):
    b=-2
    for lag in range(0,maxlag+1):
        xx=x[lag:]; yy=y[:len(y)-lag] if lag else y; n=min(len(xx),len(yy)); xx,yy=xx[:n],yy[:n]
        if xx.std()<1e-9 or yy.std()<1e-9: continue
        b=max(b,float(((xx-xx.mean())*(yy-yy.mean())).mean()/(xx.std()*yy.std())))
    return b
for p in (5,22):
    ref_l,ref_r=plug_warm(p,IDLE0)
    print("patch %d plugin self-band (vs idle=48000):"%p, flush=True)
    for idle in (48480, 50000, 60000):
        l,r=plug_warm(p,idle)
        print("  idle=%d: rmsL %.4f (ref %.4f, %+5.1f%%)  corrL=%.3f corrR=%.3f"
              %(idle,rms(l),rms(ref_l),100*(rms(l)/rms(ref_l)-1),corr(ref_l,l),corr(ref_r,r)), flush=True)
