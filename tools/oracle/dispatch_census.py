#!/usr/bin/env python3
"""dispatch_census.py — empirically map EVERY patch-range dispatch index of the
plugin's value-tree dispatch (sub_7FF91E019A30) to (engine offsets, value function).

For dispatch 741..960: drive values {0,1,2,3,5,32,64,100,128,200,255} under the VT
harness, record every engine write (offset -> bits per value). Then auto-pair each
dispatch to the verified juno_apply record slot by matching (offset, juno_curve bits)
against the verified BINDINGS — no positional formulas. Output:
  dispatch_census.json: {disp: {"offsets": {off: {val: bits}}, "paired": name/slot}}
"""
import importlib.util, sys, struct, json, ctypes

UNIT2 = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/unit2'
spec = importlib.util.spec_from_file_location('evt', UNIT2 + '/emu_valuetree.py')
m = importlib.util.module_from_spec(spec); sys.modules['evt'] = m; spec.loader.exec_module(m)

jc = ctypes.CDLL('/home/user/jn60c99/scratchpad/oracle/libjunocurve.so')
jc.juno_curve.restype = ctypes.c_float; jc.juno_curve.argtypes = [ctypes.c_int, ctypes.c_int]
def cbits(c, v): return struct.unpack('<I', struct.pack('<f', jc.juno_curve(c, v)))[0]

reg = m._reg
def off_of(pid): return reg[pid][0] if 0 <= pid < len(reg) else None
def keep(o): return o is not None and ((176 <= o < 10688) or o >= 84272)

GRID = [0, 1, 2, 3, 5, 32, 64, 100, 128, 200, 255]

# verified bindings from src/juno_apply.c: (blob_pos, curve, tf, offset, name)
TF = {'ID': lambda v: v, 'HALF': lambda v: v >> 1, 'BIP': lambda v: (v >> 1) + 128,
      'INV': lambda v: 255 - v, 'INVHALF': lambda v: ((255 - v) >> 1) + 1}
BIND = [
 (35,22,'ID',6736,'VCF CUTOFF FREQ'),(37,22,'ID',6832,'VCF RESONANCE'),
 (38,41,'ID',10240,'HPF CUTOFF FREQ'),(44,35,'ID',2784,'ENV1 ATTACK'),
 (41,38,'ID',2816,'ENV1 DECAY'),(42,50,'ID',2800,'ENV1 SUSTAIN'),
 (43,38,'ID',2832,'ENV1 RELEASE'),(45,35,'ID',3264,'ENV2 ATTACK'),
 (52,38,'ID',3312,'ENV2 RELEASE'),(48,24,'ID',7408,'VCF KEY FOLLOW'),
 (39,46,'ID',7392,'VCF ENV MOD'),(53,24,'ID',9584,'VCA TONE'),
 (26,54,'ID',4208,'DCO PWM LEVEL'),(7,44,'ID',1920,'LFO DELAY TIME'),
 (8,22,'ID',1088,'LFO RATE'),(66,49,'ID',101072,'VCA LEVEL'),
 (27,54,'ID',4192,'DCO SAW LEVEL'),(28,54,'ID',4224,'DCO SUB LEVEL'),
 (29,54,'ID',6528,'DCO NOISE LEVEL'),(9,0,'ID',4032,'DCO LFO MOD'),
 (10,47,'ID',7344,'VCF LFO MOD'),(12,51,'ID',1872,'LFO KEY TRIG'),
 (14,45,'ID',4144,'DCO PWM DEPTH'),(16,5,'ID',3840,'DCO RANGE'),
 (46,38,'ID',3296,'ENV2 DECAY'),(47,50,'ID',3280,'ENV2 SUSTAIN'),
 (54,52,'ID',592,'PORTAMENTO'),(57,10,'ID',4128,'BEND RANGE'),
 (59,52,'ID',1056,'TEMPO SYNC'),
]

def main():
    vt = m.VT(); r = vt.construct(); assert r[0] == 'OK', r
    census = {}
    for disp in range(741, 961):
        offs = {}
        for v in GRID:
            r, d = vt.set_param(disp, v)
            if r[0] != 'OK':
                offs.setdefault('_err', {})[v] = str(r[1])[:40]
                continue
            for pid, bits in d.items():
                o = off_of(pid)
                if keep(o):
                    offs.setdefault(o, {})[v] = bits
        if offs:
            census[disp] = offs
    # auto-pair to verified bindings
    paired = {}
    for (bp, curve, tf, off, name) in BIND:
        f = TF[tf]
        for disp, offs in census.items():
            lut = offs.get(off)
            if not lut: continue
            ok = all(lut.get(v) == cbits(curve, f(v)) for v in GRID if v in lut)
            if ok and len([v for v in GRID if v in lut]) >= 8:
                paired[disp] = {'slot': bp, 'name': name, 'via': off}
                break
    out = {'census': {str(k): {str(o): {str(v): b for v, b in lut.items()}
                               for o, lut in offs.items()}
                      for k, offs in census.items()},
           'paired': {str(k): v for k, v in paired.items()}}
    json.dump(out, open('/home/user/jn60c99/scratchpad/oracle/dispatch_census.json', 'w'))
    print("dispatches that write engine cells:", len(census))
    print("paired to verified record slots:", len(paired))
    unpaired = [d for d in census if d not in paired and '_err' not in census[d]]
    print("unpaired engine-writing dispatches:", sorted(unpaired))
    for d in sorted(unpaired):
        offs = sorted(o for o in census[d] if o != '_err')
        names = {reg[p][0]: reg[p][1] for p in range(len(reg)) if reg[p][0] in offs[:4]}
        print("  disp %d -> offsets %s %s" % (d, offs[:8], list(names.values())[:4]))
    errs = [d for d in census if '_err' in census[d]]
    print("dispatches that fault:", sorted(errs))

if __name__ == '__main__':
    main()
