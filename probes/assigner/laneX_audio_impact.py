#!/usr/bin/env python3
"""Does running the PLUGIN'S OWN assigner refresh (0x3549B0 group 4) after recall
change the PLUGIN'S OWN audio? Pure plugin code on both arms; the ONLY difference
is whether the assigner's onParameterChanged was invoked."""
import sys, os, math, struct
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA

CW = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
      '0e8b9cb5-Chillwave.bin')
ASG_ONPARAM = E.IB + 0x3549B0
SR, N, NOTE, VEL = 44100.0, 22050, 60, 100

def f32(b): return struct.unpack('<f', struct.pack('<I', b))[0]

def run(bank, p, leaves, refresh):
    e = RA.prepare_recall(p, bank, leaves, E, R, SR)
    if refresh:
        for u in range(9):
            e.call(ASG_ONPARAM, rcx=e.assign[u], rdx=4)
    e.note_on(NOTE, VEL)
    L, Rr = e.render(N, block=512)
    gated = [e.rd_u32(e.state[v] + 176 + v*10512 + 320) for v in range(8)]
    del e
    return [f32(x) for x in L], [f32(x) for x in Rr], gated

def rms(x, a, b):
    s = x[a:b]
    return math.sqrt(sum(v*v for v in s)/max(1, len(s)))

leaves = R.leaf_table()
for bankname, path, idxs in (("CHILLWAVE", CW, [3, 4, 30]),
                             ("FACTORY", truth.BANK, [61, 5, 0])):
    bank = open(path, 'rb').read()
    for p in idxs:
        blob = E.patch_blob(bank, p)
        g = lambda i: ((blob[2*i] & 0xF) << 4) | (blob[2*i+1] & 0xF)
        nm = E.patch_name(bank, p)
        a_l, a_r, a_g = run(bank, p, leaves, False)
        b_l, b_r, b_g = run(bank, p, leaves, True)
        diff = sum(1 for x, y in zip(a_l, b_l) if x != y)
        ra, rb = rms(a_l, 0, N), rms(b_l, 0, N)
        print("%-9s p%-2d %-16r ASG=%d LEG=%d PORTA=%-3d | differing %6d/%d  "
              "RMS %.5f -> %.5f (%+.2f dB)  M.Gate>0 voices %d -> %d"
              % (bankname, p, nm, g(56), g(55), g(54), diff, N, ra, rb,
                 20*math.log10(rb/ra) if ra > 0 and rb > 0 else float('nan'),
                 sum(1 for x in a_g if f32(x) > 0), sum(1 for x in b_g if f32(x) > 0)))
