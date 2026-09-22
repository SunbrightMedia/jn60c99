import sys, pefile, capstone, struct
BIN='/home/user/jn60c99/jp8/truth/JUPITER-8VST3_64bit.vst3'
pe=pefile.PE(BIN); IB=pe.OPTIONAL_HEADER.ImageBase
img=pe.get_memory_mapped_image()
text=[s for s in pe.sections if s.Name.startswith(b'.text')][0]
va=text.VirtualAddress; sz=text.Misc_VirtualSize
code=img[va:va+sz]
targets=[int(x,16) for x in sys.argv[1:]]
# brute scan for rip-relative disp32 pointing to targets: look for 4-byte disp such that insn_end+disp == target
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64); md.detail=False
hits=[]
for off in range(0,len(code)-4):
    d=struct.unpack_from('<i',code,off)[0]
    for t in targets:
        # instruction end is off+4 (+ imm bytes possible); accept end in off+4..off+5
        for extra in (0,1,4):
            if va+off+4+extra+d==t: hits.append((va+off,t,extra))
for h in hits:
    # disassemble around
    s=h[0]-8
    for back in range(1,9):
        st=h[0]-back
        ins=list(md.disasm(code[st-va:st-va+16],IB+st,1))
        if ins and ins[0].address+ins[0].size>=h[0]+4 and 'rip' in ins[0].op_str:
            print(hex(st),ins[0].mnemonic,ins[0].op_str,'->',hex(h[1])); break
