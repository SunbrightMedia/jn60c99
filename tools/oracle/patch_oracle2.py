#!/usr/bin/env python3
"""patch_oracle2.py — corrected exhaustive per-patch recall oracle.

Drives EACH engine-writing value-tree dispatch with the patch's CORRECT record byte:
  - front-panel dispatches: byte at blob position from the census pairing (authoritative,
    handles the A/D/S/R record reordering the naive formula got wrong).
  - extended dispatches (VCA mode, LFO trig, HPF type, bend/mod sens, condition, ...):
    byte at record position 8*(disp-742)-430  (verified: disp855 VCA MODE -> rec 490).
  - FX dispatches: their FX blob/record positions (from src/*_recall.c).
Collects every engine write (offset->bits) => the plugin's own complete recall output.

Writes patch_state2/patch_NN.json {offset:bits}. Compare with dump_ours.
"""
import importlib.util, sys, os, json, struct

UNIT2 = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/unit2'
BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin'
OUT = '/home/user/jn60c99/scratchpad/oracle/patch_state2'
spec = importlib.util.spec_from_file_location('evt', UNIT2 + '/emu_valuetree.py')
m = importlib.util.module_from_spec(spec); sys.modules['evt'] = m; spec.loader.exec_module(m)
reg = m._reg
def off_of(pid): return reg[pid][0] if 0 <= pid < len(reg) else None
def keep(o): return o is not None and ((176 <= o < 10688) or o >= 84272)

HEADER, STRIDE, BOFF, N = 23, 20223, 16, 64
bank = open(BANK, 'rb').read()
census = json.load(open('/home/user/jn60c99/scratchpad/oracle/dispatch_census.json'))
paired = {int(k): v['slot'] for k, v in census['paired'].items()}   # disp -> blob_pos

# engine-writing dispatches (from census, non-faulting)
WRITERS = [int(d) for d in census["census"] if "_err" not in census["census"][d] and int(d) not in (878,1029)]

def blob(idx): return bank[HEADER + idx * STRIDE + BOFF: HEADER + (idx + 1) * STRIDE]
def dec_bp(b, bp): return ((b[2 * bp] & 0xF) << 4) | (b[2 * bp + 1] & 0xF)   # front-panel
def dec_rec(b, roff): return ((b[roff - 16] & 0xF) << 4) | (b[roff - 16 + 1] & 0xF)  # extended

# explicit record positions for non-front-panel writers (verified in src/*.c):
#   FX blob positions: EFFECT DEPTH blob50, DELAY LEVEL blob40, DELAY TIME blob49
FX_BLOB = {794: 50, 796: 40, 797: 49}
# extended record positions = 8*(disp-742)-430 (disp is docpos+740 => myleaf=disp-742)
def ext_roff(disp): return 8 * (disp - 742) - 430 + 16   # returns roff for dec_rec

def patch_byte(disp, b):
    if disp in paired:
        return dec_bp(b, paired[disp])
    if disp in FX_BLOB:
        return dec_bp(b, FX_BLOB[disp])
    # PWM source (759) is front-panel blob 15; portamento/bend front-panel too
    SPECIAL_BP = {759: 15, 798: 54, 799: 55, 800: 56, 801: 57, 810: 66}
    if disp in SPECIAL_BP:
        return dec_bp(b, SPECIAL_BP[disp])
    # extended block (>=855): record byte via ext formula
    roff = ext_roff(disp)
    if 16 <= roff - 16 < len(b) - 1:
        return dec_rec(b, roff)
    return 0

def apply(vt, idx):
    b = blob(idx); writes = {}; used = {}
    for disp in WRITERS:
        val = patch_byte(disp, b)
        used[disp] = val
        r, d = vt.set_param(disp, val)
        if r[0] != 'OK':
            continue
        for pid, bits in d.items():
            o = off_of(pid)
            if keep(o):
                writes[o] = bits
    return writes, used

def main():
    os.makedirs(OUT, exist_ok=True)
    args = sys.argv[1:]
    want = list(range(N)) if (args and args[0] == 'all') else [int(a) for a in args] or [1]
    vt = m.VT(); assert vt.construct()[0] == 'OK'
    for idx in want:
        w, used = apply(vt, idx)
        nm16 = bank[HEADER + idx * STRIDE: HEADER + idx * STRIDE + 16]
        pname = bytes(c if 32 <= c < 127 else 32 for c in nm16).decode().strip()
        json.dump({'patch': idx, 'name': pname,
                   'writes': {str(k): v for k, v in sorted(w.items())},
                   'bytes': {str(k): v for k, v in used.items()}},
                  open(OUT + '/patch_%02d.json' % idx, 'w'))
        sys.stderr.write("patch %2d %-18s offsets=%d\n" % (idx, pname, len(w)))

if __name__ == '__main__':
    main()
