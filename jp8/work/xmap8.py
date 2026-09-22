import pefile, struct, sys, capstone
def load(path):
    pe=pefile.PE(path); IB=pe.OPTIONAL_HEADER.ImageBase; IMG=pe.get_memory_mapped_image()
    t=[s for s in pe.sections if s.Name.startswith(b'.text')][0]
    return dict(pe=pe,IB=IB,IMG=IMG,CLO=t.VirtualAddress,CHI=t.VirtualAddress+t.Misc_VirtualSize)
def q(B,rva): return struct.unpack_from("<Q",B['IMG'],rva)[0]
def i32(B,rva): return struct.unpack_from("<i",B['IMG'],rva)[0]
def is_code(B,va): return B['IB']+B['CLO']<=va<B['IB']+B['CHI']
def vtable_name(B, vt_rva):
    col_va=q(B, vt_rva-8); col_rva=col_va-B['IB']
    td_rva=i32(B, col_rva+12)
    e=B['IMG'].index(b'\0', td_rva+16)
    return B['IMG'][td_rva+16:e].decode('latin1')
def name_to_vtables(B, name):
    pat=(name+"\0").encode(); out=[]
    idx=B['IMG'].find(pat)
    if idx<0: return out
    td_rva=idx-16; needle=struct.pack("<i",td_rva); start=0
    while True:
        j=B['IMG'].find(needle,start)
        if j<0: break
        start=j+1; co=j-12
        if co<0: continue
        if struct.unpack_from("<I",B['IMG'],co)[0]!=1: continue
        col_va=B['IB']+co; k=0
        while True:
            k=B['IMG'].find(struct.pack("<Q",col_va),k)
            if k<0: break
            out.append(k+8); k+=1
    return out
def slots(B, vt_rva, n=60):
    out=[]
    for i in range(n):
        v=q(B, vt_rva+8*i)
        if not is_code(B, v): break
        out.append(v-B['IB'])
    return out
JX=load("/home/user/jn60c99/jx3p/truth/JX3P.vst3")
JP=load("/tmp/claude-0/-home-user-jn60c99/3260b962-c2aa-553d-b245-0100f4709902/scratchpad/jp8/truth/JUPITER-8VST3_64bit.vst3")
print("JP8 IB=0x%x CLO=0x%x CHI=0x%x"%(JP['IB'],JP['CLO'],JP['CHI']))
for label,rva in [("ENGINE",0xA15B88),("PROC",0x9F9A90)]:
    nm=vtable_name(JX,rva); print("JX %s vtable 0x%x -> '%s' slots=%d"%(label,rva,nm,len(slots(JX,rva))))
    for sw in (nm.replace("Jx3p","Jp8").replace("Jx3P","Jp8").replace("JX3P","Jp8"), nm):
        vts=name_to_vtables(JP,sw)
        for vt in vts:
            print("   JP8 '%s' vtable 0x%x slots=%d"%(sw,vt,len(slots(JP,vt))))
            for i,s in enumerate(slots(JP,vt)): print("      slot 0x%02x = 0x%x"%(8*i,s))
        if vts: break
# also the CWaveGen and CJp8Sim vtables by name
for nm in (".?AVCJp8Sim@@",".?AVCWaveGen@@",".?AVCJx3pSim@@"):
    for B,lab in ((JP,"JP8"),(JX,"JX")):
        for vt in name_to_vtables(B,nm):
            print("%s '%s' vtable 0x%x slots=%d: %s"%(lab,nm,vt,len(slots(B,vt)),["0x%x"%s for s in slots(B,vt)]))
# ALLOC by byte pattern
jx_alloc=0x6AB63C; sig=bytes(JX['IMG'][jx_alloc:jx_alloc+40])
print("JX ALLOC bytes:", sig.hex())
for n in (40,32,24,16,12):
    hits=[]; k=0
    while True:
        k=JP['IMG'].find(sig[:n],k)
        if k<0: break
        hits.append(k); k+=1
    print("JP8 ALLOC match len %d: %s"%(n,["0x%x"%h for h in hits[:6]]))
    if hits: break
# JX ENGINE slots
print("JX ENGINE slots:", ["0x%x"%s for s in slots(JX,0xA15B88)])
