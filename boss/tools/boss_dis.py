#!/usr/bin/env python3
"""boss_dis.py -- the function(s) holding the given rvas, disassembled, calls named (imports; ILT thunks followed).
READ-only plumbing for probes. usage: python3 boss/tools/boss_dis.py <rva hex> ..."""
import pefile, bisect, sys
from capstone import *
pe=pefile.PE(__import__('os').path.join(__import__('os').path.dirname(__import__('os').path.abspath(__file__)), '..', 'truth', 'BOSS_Effects_Pedals.vst3')); img=pe.get_memory_mapped_image(); ib=pe.OPTIONAL_HEADER.ImageBase
md=Cs(CS_ARCH_X86,CS_MODE_64)
imp={}
for e in pe.DIRECTORY_ENTRY_IMPORT:
    for i in e.imports: imp[i.address]=i.name.decode() if i.name else ''
fns=sorted((e.struct.BeginAddress,e.struct.EndAddress) for e in pe.DIRECTORY_ENTRY_EXCEPTION)
st=[a for a,b in fns]
def fn(r): k=bisect.bisect_right(st,r)-1; return fns[k]
def tgt(a):
    for i in md.disasm(img[a:a+8],ib+a):
        if i.mnemonic=='jmp' and i.op_str.startswith('0x'): return int(i.op_str,16)-ib
    return a
for arg in sys.argv[1:]:
    r=int(arg,16); a,b=fn(r)
    leaf = not (a <= r < b)
    if leaf: a, b = r, r + 0x200            # no unwind entry: a leaf, read to its first ret
    if len(sys.argv)>2 or True: print('=== fn',hex(a),hex(b),'for',hex(r))
    for i in md.disasm(img[a:b],ib+a):
        s=i.op_str
        if i.mnemonic=='call':
            if 'rip' in s: s+='   ; '+imp.get(i.address+i.size+int(s.split('+')[-1].strip(' ]'),16),'?')
            elif s.startswith('0x'): s+='   -> '+hex(tgt(int(s,16)-ib))
        print(hex(i.address-ib), i.mnemonic, s)
        if leaf and i.mnemonic == 'ret': break
