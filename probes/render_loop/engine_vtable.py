#!/usr/bin/env python3
"""Dump the engine interface vtable (rva 0x9df1d8) from the loaded image and
identify slot +104 — the function voice 0's work item calls ONCE PER SAMPLE
(rva 0x3C6F00: `if(!voiceIdx) (*(engine->vt+104))(engine);`). Anchors: slot
holding rva 0x3C68D0 = BUILD, 0x3C7A20 = setSampleRate, 0x3C7330 = noteOn,
0x3C72D0 = noteOff, 0x3C7400 = the per-block render callback."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

e = E.E2E()          # loads the image; no build needed
uc = e.uc
VT = E.IB + 0x9df1d8
ANCH = {0x3C68D0:'BUILD', 0x3C7A20:'setSampleRate', 0x3C7330:'noteOn',
        0x3C72D0:'noteOff', 0x3C7400:'PER-BLOCK RENDER (pool dispatch)',
        0x3C6F00:'work-item body'}
print("engine vtable @ rva 0x9df1d8")
for s in range(0, 30*8, 8):
    q = int.from_bytes(uc.mem_read(VT + s, 8), 'little')
    if not (E.IB <= q < E.IB + E.IMGSZ):
        print("  +%-4d (slot %2d)  <non-code 0x%x>" % (s, s//8, q)); continue
    rva = q - E.IB
    tag = ANCH.get(rva, '')
    mark = '   <=== VOICE-0 PER-SAMPLE CALL' if s == 104 else ''
    print("  +%-4d (slot %2d)  rva 0x%-8X %s%s" % (s, s//8, rva, tag, mark))
