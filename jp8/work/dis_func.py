import pefile, struct, sys, capstone
path=sys.argv[1]; rva=int(sys.argv[2],16); n=int(sys.argv[3]) if len(sys.argv)>3 else 200
pe=pefile.PE(path); IB=pe.OPTIONAL_HEADER.ImageBase; IMG=pe.get_memory_mapped_image()
# back up to the previous int3 padding (function start)
s=rva
if len(sys.argv)>4 and sys.argv[4]=="back":
    k=IMG.rfind(b"\xcc\xcc",rva-0x800,rva); s=k+2 if k>0 else rva
    while IMG[s]==0xcc: s+=1
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64); md.detail=True
print("=== function from 0x%x (target 0x%x) ==="%(s,rva)); cnt=0
for ins in md.disasm(bytes(IMG[s:s+n*12]), IB+s):
    extra=""
    for op in ins.operands:
        if op.type==capstone.x86.X86_OP_MEM and op.mem.base==capstone.x86.X86_REG_RIP:
            tgt=ins.address+ins.size+op.mem.disp; r=tgt-IB; extra="  ; rva 0x%x"%r
            try:
                extra+=" f=%r d=%r i=%d"%(struct.unpack_from("<f",IMG,r)[0],struct.unpack_from("<d",IMG,r)[0],struct.unpack_from("<i",IMG,r)[0])
            except: pass
    if ins.mnemonic in('call','jmp') and ins.op_str.startswith('0x'): extra="  -> rva 0x%x"%(int(ins.op_str,16)-IB)
    mark="*" if ins.address-IB==rva else " "
    print(" %s0x%x: %-9s %s%s"%(mark,ins.address-IB, ins.mnemonic, ins.op_str, extra))
    cnt+=1
    if cnt>=n: break
    if ins.mnemonic=="ret" and ins.address-IB>rva: break
