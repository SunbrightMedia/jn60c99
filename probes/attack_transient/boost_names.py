#!/usr/bin/env python3
"""Dump the plugin's own names for SYSTEM indices 15..30 and their declared
ranges/defaults, to identify the output-stage controls (Boost Mode / Output Gain)
that write NO engine cells and are therefore absent from the port entirely."""
import sys, struct
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E
e=E.E2E(); uc=e.uc; NT=E.IB+0x9a0030; DESC=E.IB+0x98c040
def nm(i):
    p=int.from_bytes(uc.mem_read(NT+8*i,8),'little')
    if not (E.IB<=p<E.IB+E.IMGSZ): return '?'
    b=bytearray(); a=p
    while len(b)<120:
        c=uc.mem_read(a,1)[0]
        if c==0: break
        b.append(c); a+=1
    return b.decode('latin1')
print("idx  name                                              [min,max] default")
for i in range(15,31):
    mn,mx,df=struct.unpack('<iii',uc.mem_read(DESC+16*i,12))
    print("%3d  %-50s [%d,%d] d=%d"%(i,nm(i),mn,mx,df))
