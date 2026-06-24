#!/usr/bin/env python3
# resolve_vtable.py — resolve a C++ vtable (or any .rdata pointer run) to function
# names, using the uploaded data_sections/ dump + the allcode decompile headers.
#
#   usage: resolve_vtable.py <vtable_rva_hex> [count]
#          resolve_vtable.py 0x9891E8 24      # CDSPSystem8DlyDly
# Vtable RVAs are in data_sections/data_sections/data_symbols.tsv (??_7<Class>@@6B@).
import sys, struct, glob, re, os

IMG = 0x7FF91DC60000                 # DB imagebase (sub_7FF91DFC9070 == IMG+0x369070)
DS  = os.path.join(os.path.dirname(__file__), "..", "data_sections", "data_sections")
RD_START = 0x935650

def load_names():
    fn = {}
    for f in glob.glob(os.path.join(os.path.dirname(__file__), "..", "allcode", "decomp_*.c")):
        for m in re.finditer(r'// ==== (\S+) @ rva (0x[0-9A-Fa-f]+) ====', open(f).read()):
            fn[int(m.group(2), 16)] = m.group(1)
    return fn

def main():
    rva = int(sys.argv[1], 16)
    n   = int(sys.argv[2]) if len(sys.argv) > 2 else 32
    rd  = open(os.path.join(DS, "seg_rdata_935650.bin"), "rb").read()
    fn  = load_names()
    off = rva - RD_START
    for i in range(n):
        q = struct.unpack_from('<Q', rd, off + 8*i)[0]
        if q < IMG or q > IMG + 0xD40000:
            break
        trva = q - IMG
        print(f"[{i:2d}] (vtable+{8*i:#x})  0x{trva:X}  {fn.get(trva, 'sub_%X'%trva)}")

if __name__ == "__main__":
    main()
