#!/usr/bin/env python3
"""LANE A part 2 — closure + audio A/B.

(a) Dump the ENGINE (CWaveGen) vtable at runtime, then STATICALLY scan every slot
    function body for any reference to the accumulator subobject at ENGINE+1040
    (displacements 0x410..0x428). If only slot10/slot13 touch it, the accumulator
    is a closed 2-toucher subobject and cannot reach the DSP.
(b) AUDIO A/B: same recall, render 512 samples one sample at a time,
    with vs without slot13 called once per sample (exactly the plugin's
    voice-0 work-item cadence). Bit-compare the output.
"""
import sys, os, struct, collections
HERE = '/home/user/jn60c99/tools/verify'
sys.path.insert(0, HERE)
import e2e_emu as E
import real_recall as R
import recall_render_ab as AB
import capstone

IB = E.IB
SR = float(os.environ.get('JUNO_SR', '48000'))
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 3
NS = int(os.environ.get('LANEA_NS', '512'))
SLOT13 = IB + 0x3C7230

md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
IMG = E.IMG

man = {}
for line in open('/home/user/jn60c99/refs/manifest.tsv'):
    p = line.rstrip('\n').split('\t')
    if len(p) >= 3 and p[0].startswith('0x'):
        try: man[int(p[0], 16)] = (p[1], int(p[2], 16))
        except ValueError: pass

bank = E.bank_bytes(); leaves = R.leaf_table()
e = AB.prepare_recall(PATCH, bank, leaves, E, R, SR)
e.note_on(60, 100)
uc = e.uc; HOST = e.HOST
def rq(a): return int.from_bytes(uc.mem_read(a, 8), 'little')

vptr = rq(HOST)
print("ENGINE vptr = 0x%016x  rva 0x%X" % (vptr, vptr - IB))
slots = []
for s in range(40):
    v = rq(vptr + 8 * s)
    if not (IB <= v < IB + E.IMGSZ): break
    slots.append(v - IB)
print("vtable slots (%d): %s" % (len(slots), ", ".join("%d:0x%X" % (i, r) for i, r in enumerate(slots))))

print("\n-- static scan of every vtable slot body for ENGINE+0x410..0x428 refs --")
DISPS = ('0x410', '0x414', '0x418', '0x41c', '0x420', '0x424', '0x428')
touchers = []
for i, rva in enumerate(slots):
    sz = man.get(rva, (None, 0x200))[1] or 0x200
    hits = []
    for ins in md.disasm(IMG[rva:rva + sz], IB + rva):
        for d in DISPS:
            if d + ']' in ins.op_str:
                hits.append((ins.address - IB, ins.mnemonic, ins.op_str))
    if hits:
        touchers.append(i)
        for h in hits: print("   slot%-2d rva 0x%X: 0x%X %s %s" % (i, rva, *h))
print("   slots touching the accumulator: %s" % touchers)

# also confirm nothing else in the image calls 0x3C7180 / 0x3C7230 / 0x324980 / 0x324A30 / 0x324A70
print("\n-- direct-call xrefs to the accumulator API (whole .text linear scan) --")
targets = {0x3C7180: 'slot10 meterRead', 0x3C7230: 'slot13 meterPush',
           0x324980: 'acc::readReset', 0x324A30: 'acc::push', 0x324A70: 'acc::lastAsInt'}
found = collections.defaultdict(list)
sec = [s for s in E.pe.sections if b'.text' in s.Name][0]
lo = sec.VirtualAddress; hi = lo + sec.Misc_VirtualSize
off = lo
for ins in md.disasm(IMG[lo:hi], IB + lo):
    if ins.mnemonic in ('call', 'jmp') and ins.op_str.startswith('0x'):
        t = int(ins.op_str, 16) - IB
        if t in targets: found[t].append(ins.address - IB)
for t, n in targets.items():
    print("   0x%X %-16s direct callers: %s" % (t, n, ["0x%X" % a for a in found[t]] or "NONE (vtable-only)"))

# --------------------------------------------------------------- audio A/B
print("\n-- AUDIO A/B: %d samples, block=1, with vs without slot13 per sample --" % NS)
import pickle, copy
def snapshot():
    return None
# run WITHOUT first
LA, RA = [], []
for i in range(NS):
    l, r = e.render(1, block=1)
    LA += l; RA += r
print("   pass A (no slot13) done, %d samples, first=%08x last=%08x" % (len(LA), LA[0], LA[-1]))

# rebuild a fresh identical instance and run WITH slot13 per sample
e2 = AB.prepare_recall(PATCH, bank, leaves, E, R, SR)
e2.note_on(60, 100)
LB, RB = [], []
for i in range(NS):
    l, r = e2.render(1, block=1)
    LB += l; RB += r
    e2.call(SLOT13, rcx=e2.HOST, count=2_000_000)
print("   pass B (slot13 x1/sample) done, %d samples, first=%08x last=%08x" % (len(LB), LB[0], LB[-1]))

nd = sum(1 for i in range(NS) if LA[i] != LB[i] or RA[i] != RB[i])
first = next((i for i in range(NS) if LA[i] != LB[i] or RA[i] != RB[i]), None)
print("   differing samples: %d / %d   first=%s" % (nd, NS, first))
nz = sum(1 for x in LA if x not in (0, 0x80000000))
print("   non-zero L samples in pass A: %d (sanity: the render is actually producing audio)" % nz)
print("\n== AUDIO A/B VERDICT: %s ==" % ("BIT-IDENTICAL -> slot13 is audio-inert" if nd == 0 else "DIVERGES"))
