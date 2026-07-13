import sys, struct, ctypes
sys.path.insert(0,'/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
bank=open(BANK,'rb').read()
lib=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype=ctypes.c_void_p; lib.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
lib.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
lib.juno_gui_arp_config.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_float,ctypes.c_float]
lib.juno_gui_note_on.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int]
lib.juno_gui_render.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_float),ctypes.c_int]
ARPS={1,9,17,25,33,41,49}
N=12000
for sr in (44100.0, 48000.0):
    for p in [7,21,28,39,40,41,44,55]:
        e=E.E2E(); e.build(sr); e.snap_all(); E.recall_patch(e,p); e.snap_all(); e.clear_latch(); e.set_ftz()
        e.note_on(60,105); La,Ra=e.render(N)
        c=lib.juno_gui_create(ctypes.c_float(sr),0); lib.juno_gui_apply_bank(c,bank,len(bank),p)
        if p in ARPS: lib.juno_gui_arp_config(c,0,0,1,120.0,0.6)
        lib.juno_gui_note_on(c,60,105)
        buf=(ctypes.c_float*(2*N))(); lib.juno_gui_render(c,buf,N)
        inter=struct.unpack('<%dI'%(2*N),bytes(buf))
        first=next((i for i in range(N) if La[i]!=inter[2*i] or Ra[i]!=inter[2*i+1]),None)
        print(f'patch {p:2d} cold @{int(sr)}:', 'BIT-EXACT %d frames'%N if first is None else 'FIRST DIFF @%d'%first, flush=True)
print('DONE', flush=True)
