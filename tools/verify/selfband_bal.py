import sys, ctypes
sys.path.insert(0,'/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
import numpy as np
IDLE0,NOTE=44100,12000
def plug_warm(p,idle):
    e=E.E2E(); e.build(44100); e.snap_all(); e.clear_latch(); e.set_ftz()
    e.render(idle); e.snap_all(); E.recall_patch(e,p); e.snap_all(); e.clear_latch()
    e.note_on(60,105); L,R=e.render(NOTE)
    return (np.array(L,np.uint32).view(np.float32).astype(np.float64),
            np.array(R,np.uint32).view(np.float32).astype(np.float64))
def rms(x): return float(np.sqrt((x*x).mean()))
def db(x): return 20*np.log10(max(x,1e-12))
def corr(x,y,maxlag=96):
    b=-2
    for lag in range(0,maxlag+1):
        xx=x[lag:]; yy=y[:len(y)-lag] if lag else y; n=min(len(xx),len(yy)); xx,yy=xx[:n],yy[:n]
        if xx.std()<1e-9 or yy.std()<1e-9: continue
        b=max(b,float(((xx-xx.mean())*(yy-yy.mean())).mean()/(xx.std()*yy.std())))
    return b
for p in [int(a) for a in sys.argv[1:]]:
    rl,rr=plug_warm(p,IDLE0); ref_bal=db(rms(rl))-db(rms(rr))
    print(f"patch {p} plugin self-band @44.1k (ref idle=44100, bal {ref_bal:+.2f}dB):",flush=True)
    for idle in (44541,46000,55000):
        l,r=plug_warm(p,idle)
        bal=db(rms(l))-db(rms(r))
        print(f"  idle={idle}: rmsL {rms(l):.4f} ({100*(rms(l)/rms(rl)-1):+5.1f}%)  balShift {abs(bal-ref_bal):.2f}dB  corrL={corr(rl,l):.3f} corrR={corr(rr,r):.3f}",flush=True)
