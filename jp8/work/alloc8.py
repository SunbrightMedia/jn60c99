import pefile, struct, re, capstone
JP=pefile.PE("../truth/JUPITER-8VST3_64bit.vst3"); IB=JP.OPTIONAL_HEADER.ImageBase; IMG=bytes(JP.get_memory_mapped_image())
JX=pefile.PE("/home/user/jn60c99/jx3p/truth/JX3P.vst3"); JXI=bytes(JX.get_memory_mapped_image())
sig=JXI[0x6AB63C:0x6AB63C+40]
# wildcard the two rel32 call displacements: e8 xx xx xx xx
pat=re.escape(sig[:14])+b"\xe8"+b"...."+re.escape(sig[19:27])+b"\xe8"+b"...."+re.escape(sig[32:40])
hits=[m.start() for m in re.finditer(pat,IMG,re.S)]
print("JP8 ALLOC wildcard hits:",["0x%x"%h for h in hits])
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64)
for h in hits:
    print("== 0x%x"%h)
    for ins in md.disasm(IMG[h:h+48],IB+h):
        t=""
        if ins.mnemonic=='call': t="  -> 0x%x"%(int(ins.op_str,16)-IB)
        print("  0x%x: %s %s%s"%(ins.address-IB,ins.mnemonic,ins.op_str,t))
        if ins.mnemonic=='ret': break
# callers count of ALLOC in JP8 vs JX ALLOC callers
def callers(img,lo,hi,rva):
    n=0
    for a in range(lo,hi-5):
        if img[a]==0xE8 and struct.unpack_from("<i",img,a+1)[0]==rva-a-5: n+=1
    return n
for h in hits: print("JP8 0x%x callers: %d"%(h,callers(IMG,0x1000,0x9b6a38,h)))
print("JX ALLOC 0x6AB63C callers: %d"%callers(JXI,0x1000,0x1000+0x9c0000,0x6AB63C))
