#!/usr/bin/env python3
"""lut_validate.py — Phase-2 proof: the parameter→coefficient apply is a LUT lookup
(coefficient = table[step]), validated bit-exact against the PD Juno Pad capture.

It decodes the 66 denormalize LUTs that sub_356380 (rva 0x356380) dispatches over
(table base symbols dword_7FF91E5C*/5E*), then checks every captured coefficient in
src/runtime_coeffs_data.c for exact membership. Exact members prove the mechanism and
recover the patch's raw step value (the index). Switches read 0/1. The remainder are the
scale*value+offset family (sub_356150).

    python3 tools/lut_validate.py            # report
    python3 tools/lut_validate.py --dump     # also write refs/recovered_param_steps.json

Needs the dumped data segments in data_sections/ ; no binary or capture tools required.
"""
import struct, os, glob, re, sys, json

BASE = 0x7FF91DC60000
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def rd(rt, n):
    rva = rt - BASE
    for f in glob.glob(os.path.join(ROOT, 'data_sections/data_sections/seg_*.bin')):
        b = int(f.split('_')[-1].split('.')[0], 16)
        if b <= rva < b + os.path.getsize(f):
            with open(f, 'rb') as fh:
                fh.seek(rva - b); return fh.read(n)
    return None

def table_addrs():
    """parse the dword_7FF91E....[v] table symbols from sub_356380's switch, in case order."""
    dec = glob.glob(os.path.join(ROOT, 'allcode/decomp_340000.c'))[0]
    txt = open(dec).read()
    s = txt.index('0x356380 ====')
    e = txt.index('@ rva 0x', s + 20)
    body = txt[s:e]
    seen, out = set(), []
    for m in re.finditer(r'dword_(7FF91E[0-9A-F]+)\[', body):
        a = m.group(1)
        if a not in seen:
            seen.add(a); out.append(int(a, 16))
    return out

def main():
    tabs = []
    for rt in table_addrs():
        b = rd(rt, 256 * 4)
        if b:
            tabs.append((rt, struct.unpack('<256f', b)))
    cap_src = open(os.path.join(ROOT, 'src/runtime_coeffs_data.c')).read()
    pairs = re.findall(r'\{(\d+),0x([0-9a-fA-F]{8})u\}', cap_src)
    caps = {int(o): struct.unpack('<f', struct.pack('<I', int(h, 16)))[0] for o, h in pairs}

    sw = exact = 0; other = []; recovered = {}
    for o in sorted(caps):
        v = caps[o]
        if abs(v) < 1e-12 or abs(v - 1.0) < 1e-7:
            sw += 1; continue
        hit = None
        for rt, t in tabs:
            for i, x in enumerate(t):
                if struct.pack('<f',x)==struct.pack('<f',v):
                    hit = (rt, i); break
            if hit: break
        if hit:
            exact += 1
            recovered[o] = {"table": f"0x{hit[0]:X}", "step": hit[1], "value": v}
        else:
            other.append((o, round(v, 5)))

    tot = len(caps)
    print(f"LUT tables decoded: {len(tabs)} (256 floats each)")
    print(f"captured coefficients: {tot}")
    print(f"  switch/identity (0 or 1)            : {sw:3} ({100*sw/tot:.0f}%)")
    print(f"  EXACT LUT member coeff=table[step]  : {exact:3} ({100*exact/tot:.0f}%)  <- bit-exact, step recovered")
    print(f"  scale*value+offset / other          : {len(other):3} ({100*len(other)/tot:.0f}%)")
    print(f"  => {100*(exact+sw)/tot:.0f}% reproduced by LUT-lookup or switch, no capture needed")
    if '--dump' in sys.argv:
        json.dump(recovered, open(os.path.join(ROOT, 'refs/recovered_param_steps.json'), 'w'), indent=0)
        print(f"wrote refs/recovered_param_steps.json ({len(recovered)} params)")

if __name__ == '__main__':
    main()
