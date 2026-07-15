#!/usr/bin/env python3
"""recall_exhaust.py -- Phase-1 EXHAUSTIVE per-value proof for the fixed recall
params. For each fixed cell, the plugin's OWN setter (executed under Unicorn) is
swept over the record byte 0..255 at 44100/48000/96000; the port must reproduce
every value bit-exactly. Two-process.

  process 1 (--ref):  plugin setter sweep -> pickle (all params x 256 x 3 rates)
  process 2 (--port): port recall per byte via a synthetic record, assert equal
"""
import sys, struct, pickle
HERE='/home/user/jn60c99/tools/verify'; sys.path.insert(0,HERE)
PKL='/home/user/jn60c99/scratchpad/recall_exhaust.pkl'
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
RATES=[44100,48000,96000]
# param: (name, dispatch_idx, unit(0=voice,8=master), RECORD_byte, [cells])
#   RECORD_byte = the absolute-in-record byte the PORT reads for this leaf. For a
#   voice front-panel leaf at blob_pos p the port reads blob[2p] = record[16+2p]
#   (blob = record + 16); for the delay FX leaves it reads the record byte directly.
#   The reference (--ref) does NOT use this field -- it sweeps the setter input
#   directly -- so it is only the port-side nibble-injection position.
PARAMS=[
 ("feet",        760, 0, 48,   [3840]),        # blob16 -> record 16+32
 ("PWMdepth",    758, 0, 44,   [4144]),        # blob14 -> record 16+28
 ("PWMsource",   759, 0, 46,   [3888,3904,3920,3936]),  # blob15
 ("LFOdelay",    751, 0, 30,   [1920,1936]),   # blob7
 ("LFOrate",     752, 0, 32,   [1088,2064]),   # blob8 ; 1072 host-tempo re-derived
 ("DCOlfoMod",   753, 0, 34,   [4032]),        # blob9
 ("VCFlfoMod",   754, 0, 36,   [7344]),        # blob10
 ("LFOkeyTrig",  756, 0, 40,   [1872]),        # blob12
 ("DelayFeedbk", 1179,8, 3057, [102560]),
 ("DelayDirect", 1181,8, 3060, [102512]),
]
if len(sys.argv)>1 and sys.argv[1]=='--ref':
    import e2e_emu as E, real_recall as R
    out={}
    for sr in RATES:
        e=E.E2E(); e.build(float(sr)); e.snap_all()
        for (nm,idx,unit,rb,cells) in PARAMS:
            st=e.state[unit]; base=bytes(e.uc.mem_read(st,110000))
            for c in cells: out[(sr,c)]=[]
            for v in range(256):
                e.uc.mem_write(st,base)
                try: e.dispatch(unit,idx,v)
                except RuntimeError: pass
                e.snap_all()
                for c in cells:
                    out[(sr,c)].append(struct.unpack('<I',e.uc.mem_read(st+c,4))[0])
        sys.stderr.write("ref sr %d done\n"%sr); sys.stderr.flush()
    pickle.dump(out,open(PKL,'wb')); print("saved",len(out),"(sr,cell) sweeps")
elif len(sys.argv)>1 and sys.argv[1]=='--port':
    import ctypes
    ref=pickle.load(open(PKL,'rb'))
    basebank=bytearray(open(BANK,'rb').read())
    HEADER,STRIDE=23,20223
    BASE_IDX=0   # patch 0 = DELAY TYPE 0 (feedback path active)
    lib=ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype=ctypes.c_void_p
    lib.juno_gui_create.argtypes=[ctypes.c_float,ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_int,ctypes.c_int]
    lib.juno_gui_peek.restype=ctypes.c_uint; lib.juno_gui_peek.argtypes=[ctypes.c_void_p,ctypes.c_int]
    lib.juno_gui_destroy.argtypes=[ctypes.c_void_p]
    total=0; fails=[]
    for sr in RATES:
        for (nm,idx,unit,rb,cells) in PARAMS:
            recoff=HEADER+BASE_IDX*STRIDE+rb     # absolute record-byte position
            for v in range(256):
                b=bytearray(basebank)
                b[recoff]=(v>>4)&0xF; b[recoff+1]=v&0xF   # inject nibble pair
                c=lib.juno_gui_create(ctypes.c_float(float(sr)),0)
                lib.juno_gui_apply_bank(c,bytes(b),len(b),BASE_IDX)
                for cell in cells:
                    got=lib.juno_gui_peek(c,cell)
                    want=ref[(sr,cell)][v] & 0xffffffff
                    total+=1
                    if got!=want: fails.append((sr,nm,cell,v,want,got))
                lib.juno_gui_destroy(c)
    print("=== exhaustive per-value recall: port vs plugin setter ===")
    print("checks: %d (params x 256 x 3 rates x cells)"%total)
    if not fails:
        print("ALL PASS -- every fixed param bit-exact at every byte 0..255, all rates.")
    else:
        print("FAILURES: %d"%len(fails))
        for (sr,nm,cell,v,w,g) in fails[:40]:
            print("  sr %d %s cell %d byte %d: want %08x got %08x"%(sr,nm,cell,v,w,g))
else:
    print("usage: recall_exhaust.py --ref | --port"); sys.exit(2)
