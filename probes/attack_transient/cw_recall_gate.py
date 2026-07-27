#!/usr/bin/env python3
"""THE GATE NOBODY EVER RAN: recall_gate compares the PORT's computed cells
against the PLUGIN'S OWN SETTER output — but only ever on the FACTORY bank.
Joint/multi-input cells are validated ONLY by that factory sweep, so any formula
error in a combination reached only by a third-party bank passes every gate.
Both patches the user reports wrong are CHILLWAVE. Run the same comparison on
the Chillwave bank. Two-process: --ref (Unicorn) then --port (ctypes)."""
import sys, os, struct, pickle
HERE='/home/user/jn60c99/tools/verify'; sys.path.insert(0,HERE)
CW='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
PKL='/tmp/cw_recall_ref.pkl'
BLOCK=10512
PATCHES=list(range(64))

def ref():
    import e2e_emu as E, real_recall as R, real_bank_parse as RB, recall_render_ab as RA
    bank=open(CW,'rb').read(); leaves=R.leaf_table(); out={}
    for p in PATCHES:
        e=RA.prepare_recall(p,bank,leaves,E,R,48000.0)
        out[p]=bytes(e.uc.mem_read(e.state[0],BLOCK)); del e
        if p%8==0: print("  ref patch %d"%p,flush=True)
    pickle.dump(out,open(PKL,'wb')); print("wrote",PKL)

def port():
    import ctypes
    ref=pickle.load(open(PKL,'rb'))
    lib=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype=ctypes.c_void_p
    lib.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
    lib.juno_gui_peek.restype=ctypes.c_uint
    lib.juno_gui_peek.argtypes=[ctypes.c_void_p,ctypes.c_int]
    bank=open(CW,'rb').read()
    # index_cell_map: only compare cells the plugin's recall enumerator writes
    icm=pickle.load(open('/home/user/jn60c99/scratchpad/index_cell_map.pkl','rb'))
    scope=set()
    for idx,cs in (icm.items() if isinstance(icm,dict) else []):
        for c in (cs if not isinstance(cs,dict) else cs.get('cells',[])):
            if isinstance(c,int) and c<BLOCK: scope.add(c&~3)
    if not scope: scope={o for o in range(0,BLOCK,16)}
    bad={}
    for p in PATCHES:
        c=lib.juno_gui_create(ctypes.c_float(48000.0),0)
        lib.juno_gui_apply_bank(c,bank,len(bank),p)
        pb=b''.join(struct.pack('<I',lib.juno_gui_peek(c,off)) for off in range(0,BLOCK,4))
        rb=ref[p]
        for o in sorted(scope):
            if o+4>BLOCK: continue
            a=struct.unpack('<f',rb[o:o+4])[0]; b=struct.unpack('<f',pb[o:o+4])[0]
            if struct.pack('<f',a)!=struct.pack('<f',b):
                bad.setdefault(o,[]).append((p,a,b))
    print("CHILLWAVE recall gate: %d scope cells, %d patches"%(len(scope),len(PATCHES)))
    print("MISMATCHING CELLS: %d"%len(bad))
    for o,rows in sorted(bad.items())[:25]:
        ps=[r[0] for r in rows]
        print("  cell %5d : %d patches %s"%(o,len(rows),ps[:12]))
        for p_,a,b in rows[:3]:
            print("        patch %2d plugin=%-14.7g port=%-14.7g"%(p_,a,b))
    print("VERDICT:", "PASS" if not bad else "*** MISMATCH — port recall differs from the plugin on this bank ***")

if __name__=='__main__':
    ref() if '--ref' in sys.argv else port()
