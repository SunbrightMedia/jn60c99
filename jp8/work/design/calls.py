import sys, pefile, struct
pe=pefile.PE('/home/user/jn60c99/jp8/truth/JUPITER-8VST3_64bit.vst3'); img=pe.get_memory_mapped_image()
t=[s for s in pe.sections if s.Name.startswith(b'.text')][0]; va=t.VirtualAddress; code=img[va:va+t.Misc_VirtualSize]
for tgt in [int(x,16) for x in sys.argv[1:]]:
    for off in range(len(code)-5):
        if code[off]==0xE8 and va+off+5+struct.unpack_from('<i',code,off+1)[0]==tgt: print(hex(tgt),'called from',hex(va+off))
