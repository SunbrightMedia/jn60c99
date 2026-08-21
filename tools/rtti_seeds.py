#!/usr/bin/env python3
"""rtti_seeds.py -- ITEM-7: find a synth's DSP class vtable seeds from MSVC RTTI.

WHY THIS EXISTS. Phase 1 of PIPELINE.md needs the render entry points -- the
`dsp_dump` seed addresses `extract_dsp.py` climbs from. On the JUNO those were
found by hand in IDA once. This finds them mechanically from the PE's own RTTI:
every DSP module is a C++ class with a Complete Object Locator and a vftable,
and MSVC leaves the class NAME in a TypeDescriptor, so `vftable_of(
"CDSPJx3pOscVoice")` is derivable, not guessed.

⚠ WHAT IT FINDS, PRECISELY: each class's VTABLE and its virtual slots -- the
`process`/`reset` entry points. NOT the per-sample render LEAF: that leaf is a
non-virtual helper the process slot calls (verified on the JUNO -- its
hand-found render 0x180369070 is NOT a vtable slot; it is reached by climbing
DOWN from the OscVoice process method). These seeds are the ROOTS
extract_dsp.py's call-graph walk starts from, replacing the human who found
them once by hand. Which slot is `process` is confirmed against the decompile.

It is SYNTH-AGNOSTIC: pass the class-name prefix (`CDSPJu60`, `CDSPJx3p`). The
de-JUNO audit covers this file; no JUNO constant may enter it.

Reads a PE (.vst3 DLL) with no external tools -- pure struct parsing, so it
runs on any workstation, IDA not required. IDA is still the decompiler in
phase 1; this just hands it the entry list instead of a human doing so.

usage: rtti_seeds.py <plugin.vst3> <ClassPrefix>   e.g. CDSPJx3p
"""
import sys, struct

def sections(d):
    # PE: e_lfanew at 0x3c -> COFF; optional header size -> section table
    pe = struct.unpack_from('<I', d, 0x3c)[0]
    nsec = struct.unpack_from('<H', d, pe + 6)[0]
    opt = struct.unpack_from('<H', d, pe + 20)[0]
    base = struct.unpack_from('<Q', d, pe + 24 + 24)[0]  # ImageBase (PE32+)
    st = pe + 24 + opt
    secs = []
    for i in range(nsec):
        o = st + 40 * i
        va = struct.unpack_from('<I', d, o + 12)[0]
        vsz = struct.unpack_from('<I', d, o + 8)[0]
        raw = struct.unpack_from('<I', d, o + 20)[0]
        rsz = struct.unpack_from('<I', d, o + 16)[0]
        secs.append((va, max(vsz, rsz), raw))
    return base, secs

def make_maps(base, secs):
    def off2rva(o):
        for va, sz, raw in secs:
            if raw <= o < raw + sz:
                return va + (o - raw)
        return None
    def rva2off(r):
        for va, sz, raw in secs:
            if va <= r < va + sz:
                return raw + (r - va)
        return None
    return off2rva, rva2off

def main():
    if len(sys.argv) < 3:
        sys.exit("usage: rtti_seeds.py <plugin.vst3> <ClassPrefix>")
    d = open(sys.argv[1], 'rb').read()
    pref = sys.argv[2].encode()
    base, secs = sections(d)
    off2rva, rva2off = make_maps(base, secs)
    text_va = secs[0][0]; text_sz = secs[0][1]

    found = {}
    i = -1
    while True:
        i = d.find(b'.?AV' + pref, i + 1)
        if i < 0:
            break
        end = d.find(b'\x00', i)
        cls = d[i + 4:end].decode('latin1').rstrip('@')
        td_off = i - 16                      # TypeDescriptor start
        td_rva = off2rva(td_off)
        if td_rva is None:
            continue
        needle = struct.pack('<I', td_rva)   # image-relative ptr in the COL
        j = -1
        while True:
            j = d.find(needle, j + 1)
            if j < 0:
                break
            if j < 12:
                continue
            if struct.unpack_from('<I', d, j - 12)[0] != 1:   # COL signature (x64)
                continue
            col_rva = off2rva(j - 12)
            if col_rva is None or struct.unpack_from('<I', d, j + 8)[0] != col_rva:
                continue                     # pSelf must point back at the COL
            # a vftable's [-1] slot holds the absolute pointer to this COL
            ptr = struct.pack('<Q', base + col_rva)
            k = d.find(ptr)
            while k >= 0:
                vft_rva = off2rva(k + 8)
                if vft_rva is not None:
                    methods = []
                    for e in range(16):
                        v = struct.unpack_from('<Q', d, k + 8 + 8 * e)[0]
                        if text_va + base <= v < text_va + base + text_sz:
                            methods.append(v)
                        else:
                            break
                    if methods:
                        found.setdefault(cls, []).append((vft_rva, methods))
                k = d.find(ptr, k + 1)

    print("# RTTI seeds for %s* in %s" % (sys.argv[2], sys.argv[1]))
    print("# %d classes located. Each SEED is a class VTABLE; its virtual" %
          len(found))
    print("# slots (m0..) are the process/reset entry points to climb FROM.")
    print("# The per-sample render leaf is reached by walking down from the")
    print("# process slot -- confirm which slot that is against the decompile.")
    for cls in sorted(found):
        for vft_rva, methods in found[cls]:
            print("SEED %-26s vft=0x%08x  m0=0x%x m1=0x%x m2=0x%x" %
                  (cls, vft_rva, methods[0],
                   methods[1] if len(methods) > 1 else 0,
                   methods[2] if len(methods) > 2 else 0))
    return 0

if __name__ == '__main__':
    sys.exit(main())
