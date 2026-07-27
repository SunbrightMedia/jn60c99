#!/usr/bin/env python3
"""PROVEN probe: does the plugin's ASSIGNER ever learn a patch's ASSIGN MODE (800)
/ LEGATO (799) through the recall path our oracle+port both use?

Mechanism found statically (READ, decomp_340000.c:15451-15500):
  sub_7FF91DFB49B0(asg, group)   rva 0x3549B0  -- assigner onParameterChanged
      if group == 4:
          sub_7FF91DFB49F0(asg)             -- reads param 800 -> *(asg+16)  MODE
          getter(asg, 4, 799, &v); asg[5]=v --                  *(asg+20)  LEGATO
  note dispatch (decomp:16295 sub_7FF91DFB5820):
      asg[4]==1 -> MONO (0x3538F0) ; asg[4]==2 -> UNISON (0x353B00/0x353B60)
      else      -> POLY (0x353870)

This probe EXECUTES: recall a patch, read asg+16/+20, then call the plugin's OWN
0x3549F0 and re-read. No hand-written logic.
"""
import sys, os, struct
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA

CW = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
      '0e8b9cb5-Chillwave.bin')
ASG_ONPARAM = E.IB + 0x3549B0
ASG_REFRESH = E.IB + 0x3549F0
SR = 44100.0

def show(e, tag):
    out = []
    for u in range(9):
        a = e.assign[u]
        out.append((e.rd_i32(a + 16), e.rd_i32(a + 20)))
    print("  %-28s mode/legato per unit: %s" % (tag, out))
    return out

for bankname, path, idxs in (("CHILLWAVE", CW, [3, 4, 30]),
                             ("FACTORY", truth.BANK, [61, 5])):
    bank = open(path, 'rb').read()
    leaves = R.leaf_table()
    for p in idxs:
        blob = E.patch_blob(bank, p)
        g = lambda i: ((blob[2*i] & 0xF) << 4) | (blob[2*i+1] & 0xF)
        nm = E.patch_name(bank, p)
        print("\n%s p%d %r  blob PORTA=%d LEGATO=%d ASSIGN=%d"
              % (bankname, p, nm, g(54), g(55), g(56)))
        e = RA.prepare_recall(p, bank, leaves, E, R, SR)
        before = show(e, "after recall")
        # now run the PLUGIN'S OWN assigner param refresh on every unit
        for u in range(9):
            e.call(ASG_ONPARAM, rcx=e.assign[u], rdx=4)
        after = show(e, "after plugin onParam(4)")
        # and the direct refresh entry, in case onParam gates on something
        for u in range(9):
            e.call(ASG_REFRESH, rcx=e.assign[u])
        show(e, "after plugin 0x3549F0")
        print("  VERDICT: recall %s the assigner mode field"
              % ("DOES NOT reach" if before == after and after == [(0,0)]*9
                 else "changes -> see above"))
        del e
