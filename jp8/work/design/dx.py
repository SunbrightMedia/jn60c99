import sys, pefile, capstone
BIN='/home/user/jn60c99/jp8/truth/JUPITER-8VST3_64bit.vst3'
pe=pefile.PE(BIN); IB=pe.OPTIONAL_HEADER.ImageBase
img=pe.get_memory_mapped_image()
md=capstone.Cs(capstone.CS_ARCH_X86,capstone.CS_MODE_64)
a=int(sys.argv[1],16); n=int(sys.argv[2])
for i,ins in enumerate(md.disasm(bytes(img[a:a+n*15]),a)):
    if i>=n: break
    print("%x: %s %s"%(ins.address,ins.mnemonic,ins.op_str))
