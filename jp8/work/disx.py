import pefile, struct, sys, capstone
path=sys.argv[1]
pe=pefile.PE(path); IB=pe.OPTIONAL_HEADER.ImageBase; IMG=pe.get_memory_mapped_image()
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64); md.detail=True
def show(rva,n,label=""):
    print("=== %s 0x%x ==="%(label,rva))
    cnt=0
    for ins in md.disasm(bytes(IMG[rva:rva+n*10]), IB+rva):
        extra=""
        if 'rip' in ins.op_str:
            for op in ins.operands:
                if op.type==capstone.x86.X86_OP_MEM and op.mem.base==capstone.x86.X86_REG_RIP:
                    tgt=ins.address+ins.size+op.mem.disp; extra="  ; rva 0x%x"%(tgt-IB)
                    try:
                        if 0xcbb000<=tgt-IB<0xd2c000: extra+=" .data"
                        elif 0x9b7000<=tgt-IB<0xcbb000: extra+=" .rdata q=0x%x"%struct.unpack_from("<Q",IMG,tgt-IB)[0]
                    except: pass
        if ins.mnemonic in('call','jmp') and ins.op_str.startswith('0x'): extra="  -> rva 0x%x"%(int(ins.op_str,16)-IB)
        print("  0x%x: %-8s %s%s"%(ins.address-IB, ins.mnemonic, ins.op_str, extra))
        cnt+=1
        if ins.mnemonic=='ret' or cnt>=n: break
        if ins.mnemonic=='jmp' and ins.op_str.startswith('0x') and cnt>2: break
for a in sys.argv[2:]:
    if '=' in a: lab,r=a.split('='); show(int(r,16),int(sys.argv[0] and 45),lab)
    else: show(int(a,16),45)
