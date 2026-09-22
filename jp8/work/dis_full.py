import pefile, struct, sys, capstone
path=sys.argv[1]; rva=int(sys.argv[2],16); n=int(sys.argv[3]) if len(sys.argv)>3 else 200
pe=pefile.PE(path); IB=pe.OPTIONAL_HEADER.ImageBase; IMG=pe.get_memory_mapped_image()
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64); md.detail=True
cnt=0
for ins in md.disasm(bytes(IMG[rva:rva+n*12]), IB+rva):
    extra=""
    for op in ins.operands:
        if op.type==capstone.x86.X86_OP_MEM and op.mem.base==capstone.x86.X86_REG_RIP:
            tgt=ins.address+ins.size+op.mem.disp; r=tgt-IB; extra="  ; rva 0x%x"%r
            try:
                q=struct.unpack_from("<Q",IMG,r)[0]; d=struct.unpack_from("<d",IMG,r)[0]; f=struct.unpack_from("<f",IMG,r)[0]; i=struct.unpack_from("<i",IMG,r)[0]
                extra+=" q=0x%x f=%r d=%r i=%d"%(q,f,d,i)
            except: pass
    if ins.mnemonic in('call','jmp') and ins.op_str.startswith('0x'): extra="  -> rva 0x%x"%(int(ins.op_str,16)-IB)
    print("  0x%x: %-9s %s%s"%(ins.address-IB, ins.mnemonic, ins.op_str, extra))
    cnt+=1
    if cnt>=n: break
