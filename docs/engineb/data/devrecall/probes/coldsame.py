import sys, ctypes, struct
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import truth
bank=open(truth.BANK,'rb').read(); N=8000
def mk(p):
    l=ctypes.CDLL(p)
    l.juno_gui_create.restype=ctypes.c_void_p
    l.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
    l.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
    l.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
    l.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
    l.juno_gui_destroy.argtypes=[ctypes.c_void_p]
    return l
def run(l,p,sr):
    c=l.juno_gui_create(ctypes.c_float(sr),0)
    l.juno_gui_apply_bank(c,bank,len(bank),p); l.juno_gui_note_on(c,60,105)
    b=(ctypes.c_float*(2*N))(); l.juno_gui_render(c,b,N); l.juno_gui_destroy(c)
    return bytes(b)
A=mk('/home/user/jn60c99/libjuno.so')
B=mk(sys.argv[1])
for sr in (44100.0,48000.0):
    bad=[p for p in range(64) if run(A,p,sr)!=run(B,p,sr)]
    print("COLD render, shipping vs fixed, %g Hz: %d of 64 patches differ %s"%(sr,len(bad),bad))
