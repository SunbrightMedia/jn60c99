#!/usr/bin/env python3
"""recall_state_leaves.py -- like recall_fullstate_diff but the reference is the
plugin's COMPLETE-LEAF recall (leaves-only, all 9 units) = the faithful recall,
NOT the full 0..4965 loop (which clobbers 6736/1088/2064). Two-process."""
import sys, struct, pickle
HERE='/home/user/jn60c99/tools/verify'; sys.path.insert(0,HERE)
PKL='/home/user/jn60c99/scratchpad/recall_state_leaves.pkl'
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
BLOCK=10512; STRIDE=16
PATCHES=[62,5,18,39,6,14,31,0,21,53,50,12,45,13,22]
def as_f32(u): return struct.unpack('<f',struct.pack('<I',u))[0]
if sys.argv[1]=='--ref':
    import e2e_emu as E, real_recall as R
    bank=E.bank_bytes(); leaves=R.leaf_table(); out={}
    for idx in PATCHES:
        e=E.E2E(); e.build(R.SR); e.snap_all()
        blob=E.patch_blob(bank,idx)
        for (disp,bb) in leaves: R.wr_desc(e,disp,R.dec(blob,bb))
        for u in range(9):
            for (disp,bb) in leaves:
                try: e.dispatch(u,disp,R.rd_desc(e,disp))
                except RuntimeError: pass
        e.snap_all()
        out[idx]=bytes(e.uc.mem_read(e.state[0],BLOCK))
        sys.stderr.write("ref %d done\n"%idx); sys.stderr.flush()
    pickle.dump(out,open(PKL,'wb')); print("saved",len(out))
else:
    import ctypes
    ref=pickle.load(open(PKL,'rb')); bankbytes=open(BANK,'rb').read()
    lib=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype=ctypes.c_void_p
    lib.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
    lib.juno_gui_peek.restype=ctypes.c_uint
    lib.juno_gui_peek.argtypes=[ctypes.c_void_p,ctypes.c_int]
    percell={}
    for idx,blk in ref.items():
        ctx=lib.juno_gui_create(ctypes.c_float(48000.0),0)
        lib.juno_gui_apply_bank(ctx,bankbytes,len(bankbytes),idx)
        for off in range(0,BLOCK,STRIDE):
            pv=struct.unpack('<I',blk[off:off+4])[0]; qv=lib.juno_gui_peek(ctx,off)
            if pv!=qv: percell.setdefault(off,[]).append((idx,as_f32(pv),as_f32(qv)))
    print("=== leaves-only reference state diff (port vs faithful plugin recall) ===")
    for off in sorted(percell):
        rows=percell[off]; ex=rows[0]
        print("cell %6d (%d): e.g. p%d plugin %.6g vs port %.6g" % (off,len(rows),ex[0],ex[1],ex[2]))
        print("   ", ", ".join("%d[%.4g/%.4g]"%(p,a,b) for p,a,b in rows))
