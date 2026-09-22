#!/usr/bin/env python3
"""analysis of passB.json + its read-union bitmap: .text read-site disassembly, run lists per section, .data read cells"""
import sys, json, collections
sys.dont_write_bytecode = True
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import numpy as np, capstone, jp8_emu as J
r = json.load(open("passB.json")); U = np.load("passB.json.read_union.npy")
IMG = np.frombuffer(bytes(J.IMG), np.uint8)
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
def dis(rva):
    i = next(md.disasm(bytes(J.IMG[rva:rva + 16]), J.IB + rva)); return "%s %s" % (i.mnemonic, i.op_str)
def runs(mask, base):
    idx = np.nonzero(mask)[0]; out = []
    if not len(idx): return out
    st = idx[0]; pv = idx[0]
    for x in idx[1:]:
        if x != pv + 1: out.append((base + int(st), int(pv - st + 1))); st = x
        pv = x
    out.append((base + int(st), int(pv - st + 1))); return out
pcs = set()
for g, v in r["reach"].items():
    if g.startswith("UNION") or g == "control": continue
    for pc in v["text_read_distinct_pcs"]: pcs.add((g, int(pc, 16)))
bypc = collections.defaultdict(set)
for g, pc in pcs: bypc[pc].add(g)
print("== .text-reading instructions (all groups):", len(bypc))
for pc in sorted(bypc): print("  %x %-10s %s" % (pc, ",".join(sorted(bypc[pc])), dis(pc)))
for name, a, b in [(".text", 0x1000, 0x9B7000), (".rdata", 0x9B7000, 0xCBB000), (".data", 0xCBB000, 0xD2C000)]:
    rr = runs(U[a:b], a)
    print("== union boot+recall+play %s: %d bytes in %d runs; largest runs:" % (name, int(np.count_nonzero(U[a:b])), len(rr)),
          ", ".join("%x+%d" % (s, n) for s, n in sorted(rr, key=lambda x: -x[1])[:12]))
    if name == ".text": print("   all .text runs:", ", ".join("%x+%d" % (s, n) for s, n in rr))
# post-static-init image (short Unicorn run in this process; no ctypes here)
jp = J.JP8(); jp.run_static_init(); post = np.frombuffer(bytes(jp.uc.mem_read(J.IB, J.IMGSZ)), np.uint8)
di = np.nonzero(U[0xCBB000:0xD2C000])[0] + 0xCBB000
print("== .data cells read after static init (rva: pristine -> post-static):")
for s, n in runs(U[0xCBB000:0xD2C000], 0xCBB000):
    pr = bytes(IMG[s:s + n]).hex(); po = bytes(post[s:s + n]).hex()
    print("  %x+%d %s%s%s" % (s, n, pr, "" if pr == po else " -> " + po, "  [runtime tail]" if s >= 0xD20A00 else ""))
ri = np.nonzero(U[0x9B7000:0xCBB000])[0] + 0x9B7000
chg = ri[post[ri] != IMG[ri]]
print("== .rdata read bytes that differ post-static vs pristine:", len(chg), "all inside IAT:", bool(np.all((chg >= 0x9B7000) & (chg < 0x9B7000 + 0x1648))))
iat = runs(U[0x9B7000:0x9B7000 + 0x1648], 0x9B7000)
print("   IAT slots read after static init:", [(hex(s), J.IMPORTS.get(s, ("?", "?"))[1]) for s, n in iat])
