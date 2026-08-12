import sys, ctypes, struct, random
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import truth
bank=open(truth.BANK,'rb').read(); N=6000; SR=44100.0
def mk(p):
    l=ctypes.CDLL(p)
    l.juno_gui_create.restype=ctypes.c_void_p
    l.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
    l.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
    l.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
    l.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
    l.juno_gui_destroy.argtypes=[ctypes.c_void_p]
    return l
def run(l,seq):
    c=l.juno_gui_create(ctypes.c_float(SR),0)
    for p in seq: l.juno_gui_apply_bank(c,bank,len(bank),p)
    l.juno_gui_note_on(c,60,105)
    b=(ctypes.c_float*(2*N))(); l.juno_gui_render(c,b,N); l.juno_gui_destroy(c)
    return bytes(b)
random.seed(7)
pairs=[(random.randrange(64),random.randrange(64)) for _ in range(400)]
pairs=[(a,b) for a,b in pairs if a!=b]
for name,path in (("SHIPPING","/home/user/jn60c99/libjuno.so"),("FIXED",sys.argv[1])):
    l=mk(path); bad=[]
    for a,b in pairs:
        if run(l,[b])!=run(l,[a,b]): bad.append((a,b))
    print("%-9s port warm-vs-cold RENDER over %d random pairs: %d differ"%(name,len(pairs),len(bad)))
    if bad: print("          e.g.",bad[:15])
