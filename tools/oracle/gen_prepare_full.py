import emu2, struct, json
from emu2 import IB, f32, STACK_BASE, STACK_SIZE, SCRATCH
from unicorn import UcError
from unicorn.x86_const import *
reads=[int(x) for x in open("/tmp/dspreads.txt")]
cinit={}
for ln in open("/tmp/c_initonly.txt"): o,h=ln.split(); cinit[int(o)]=int(h,16)
# descriptor names for annotation
desc={}
try:
    for d in json.load(open("param_descriptor_map.json")): desc[int(d["off"])]=d["name"]
except: pass
e=emu2.Emu(); HOST=e.bump(0x8000); e.uc.mem_write(HOST,b"\x00"*0x8000)
try: e.call(emu2.BUILD, rcx=HOST)
except UcError: pass
uc=e.uc
rsp=((STACK_BASE+STACK_SIZE-0x10000)&~0xF)-8
uc.reg_write(UC_X86_REG_RSP,rsp); uc.reg_write(UC_X86_REG_RCX,HOST)
uc.reg_write(UC_X86_REG_XMM1, struct.unpack('<Q',struct.pack('<f',96000.0)+b'\0\0\0\0')[0])
uc.mem_write(rsp,struct.pack("<Q",SCRATCH+0x5000))
try: uc.emu_start(IB+0x3C7A20, SCRATCH+0x5000, count=800_000_000)
except UcError: pass
ST=sorted([a for a,s in e.allocs if s==0xA83010])[0]
try: e.call(IB+0x3C29B0, rcx=ST, count=400_000_000)   # snap-all smoothers to defaults
except UcError as ex: print("// snapall err", ex)
def emu(o): return struct.unpack("<I",uc.mem_read(ST+o,4))[0]
# complete prepare delta = read offsets where post-snap != init, excluding params ptr(136)
delta=[(o,emu(o)) for o in reads if emu(o)!=cinit.get(o,0) and o!=136]
voice=[(o,v) for o,v in delta if o<84272]
shared=[(o,v) for o,v in delta if o>=84272]
json.dump([[o,v] for o,v in delta], open("/tmp/prepare_full.json","w"))
print(f"// complete prepare delta: {len(delta)}  (voice {len(voice)}, shared {len(shared)})")
# also dump ALL of them so we can regenerate the C file
def emit(rows, label):
    print(f"\n// ==== {label}: {len(rows)} ====")
    for o,v in rows:
        nm=desc.get(o,"")
        print(f"    JI(st, {o:9d}) = 0x{v:08x};  /* {f32(v):>12.6g}  {nm} */")
emit(voice, "voice (o<84272)")
emit(shared, "shared/master (o>=84272)")
