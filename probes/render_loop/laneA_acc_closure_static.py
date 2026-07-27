#!/usr/bin/env python3
"""LANE A part 3 — STATIC closure of the ENGINE+1040 accumulator subobject.

No Unicorn, no libjuno. Pure disassembly of truth/JUNO60.vst3.
  1. find the CWaveGen vftable referenced by the ctor 0x3C5A50, dump its slots
  2. resync-safe linear scan of .text for `lea r??,[r??+0x410]` (the ONLY way to
     form a pointer to the accumulator subobject) and for direct calls to the
     accumulator API
  3. report every producer/consumer of ENGINE+1040
"""
import sys, struct, collections
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import truth, pefile, capstone

pe = pefile.PE(truth.VST3)
IB = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)

man = {}
for line in open('/home/user/jn60c99/refs/manifest.tsv'):
    p = line.rstrip('\n').split('\t')
    if len(p) >= 3 and p[0].startswith('0x'):
        try: man[int(p[0], 16)] = (p[1], int(p[2], 16))
        except ValueError: pass

# ---- 1. ctor 0x3C5A50 -> the vftable it stores
print("-- ctor 0x3C5A50 lea/vftable stores --")
vft = None
for ins in md.disasm(IMG[0x3C5A50:0x3C5A50 + 0x200], IB + 0x3C5A50):
    if ins.mnemonic == 'lea' and 'rip' in ins.op_str:
        import re as _re
        m = _re.search(r'rip ([+-]) (0x[0-9a-f]+)\]', ins.op_str)
        if not m: continue
        d = int(m.group(2), 16) * (1 if m.group(1) == '+' else -1)
        tgt = ins.address + ins.size + d
        print("   0x%X lea %s -> rva 0x%X" % (ins.address - IB, ins.op_str, tgt - IB))
        if vft is None: vft = tgt - IB
print("   CWaveGen vftable rva = 0x%X" % vft)

n = 0
slots = []
while True:
    v = struct.unpack('<Q', IMG[vft + 8 * n: vft + 8 * n + 8])[0]
    if not (IB <= v < IB + len(IMG)): break
    slots.append(v - IB); n += 1
    if n > 48: break
print("   %d slots: %s" % (len(slots), ", ".join("%d:0x%X" % (i, r) for i, r in enumerate(slots))))
for want, name in ((0x3C68D0, 'BUILD'), (0x3C7A20, 'setSampleRate'), (0x3C7400, 'PER-BLOCK RENDER'),
                   (0x3C7180, 'meterRead'), (0x3C7230, 'meterPush'), (0x3C72D0, 'noteOff'),
                   (0x3C7330, 'noteOn'), (0x3C7AE0, 'hostParamEntry')):
    print("   slot of 0x%X (%s) = %s" % (want, name, slots.index(want) if want in slots else 'NOT IN VTABLE'))

# ---- 2. resync-safe linear scan
def scan(lo, hi):
    pos = lo
    while pos < hi:
        got = 0
        for ins in md.disasm(IMG[pos:hi], IB + pos):
            yield ins
            got = ins.address - IB + ins.size - pos
            pos = ins.address - IB + ins.size
        if got == 0:
            pos += 1

sec = [s for s in pe.sections if s.Name.rstrip(b'\x00') == b'.text'][0]
LO, HI = sec.VirtualAddress, sec.VirtualAddress + sec.Misc_VirtualSize
print("\n-- .text rva 0x%X..0x%X, resync linear scan --" % (LO, HI))

ACC_API = {0x3C7180: 'slot?? meterRead', 0x3C7230: 'slot?? meterPush',
           0x324980: 'acc::readReset', 0x324A30: 'acc::push', 0x324A70: 'acc::lastAsInt',
           0x3C10B0: 'unitStateLeafGet(29)', 0x3C2520: 'leafGet body'}
calls = collections.defaultdict(list)
lea410 = []
nins = 0
for ins in scan(LO, HI):
    nins += 1
    if ins.mnemonic in ('call', 'jmp') and ins.op_str.startswith('0x'):
        t = int(ins.op_str, 16) - IB
        if t in ACC_API: calls[t].append(ins.address - IB)
    elif ins.mnemonic == 'lea' and '+ 0x410]' in ins.op_str:
        lea410.append((ins.address - IB, ins.op_str))
print("   instructions decoded: %d" % nins)
print("\n-- direct call/jmp xrefs to the accumulator API --")
for t, nm in ACC_API.items():
    src = calls.get(t, [])
    print("   0x%-7X %-22s  <- %s" % (t, nm, ["0x%X" % a for a in src] or "NONE (vtable-only)"))

print("\n-- every `lea reg,[reg+0x410]` in .text (the only way to address ENGINE+1040) --")
for a, op in lea410:
    owner = max((r for r in man if r <= a), default=None)
    onm, osz = man.get(owner, ('?', 0))
    inside = owner is not None and a < owner + osz
    print("   0x%-7X lea %-22s  in %s @0x%X%s" % (a, op, onm, owner or 0, "" if inside else "  (past fn end)"))
