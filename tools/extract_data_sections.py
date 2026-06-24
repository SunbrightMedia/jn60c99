# extract_data_sections.py — dump the DATA the code-only extraction missed.
#
# extract_all.py walked FUNCTIONS only, so .rdata/.data (coefficient & tempo tables,
# the C++ vtables, preset-format schema, scalar constants) were never exported. This
# reads the SAME IDB and dumps all of it, once, so no further data asks are needed.
#
# REBASE-SAFE: everything is addressed by the DB's current imagebase, so it works
# whether or not the DB was rebased by a past debug session. RVA = ea - imagebase.
#
# Outputs (in a `data_sections/` folder next to the IDB):
#   segments.tsv              name, start_rva, end_rva, size, class, perm
#   seg_<name>_<rva>.bin      raw bytes of each NON-code (data) segment
#   data_symbols.tsv          rva, size, name  — every named item in data segments
#   vtables.tsv               vtable_name, slot, target_rva, target_name (resolved)
#   named_tables/<name>.bin   raw bytes of each interesting unk_/?? data symbol
#
# RUN: File -> Script file... -> extract_data_sections.py ; zip+upload data_sections/.

import os, idaapi, idautils, idc, ida_bytes, ida_segment, ida_name, ida_nalt, ida_funcs

BASE = ida_nalt.get_imagebase()
OUT  = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "data_sections")
TBL  = os.path.join(OUT, "named_tables")

def log(m): print("[data] " + m)
def rva(ea): return ea - BASE

def is_code_seg(seg):
    # SEGPERM_EXEC => code; we dump everything that is NOT executable.
    return (seg.perm & ida_segment.SEGPERM_EXEC) != 0

def seg_name(seg):
    return ida_segment.get_segm_name(seg) or ("seg_%X" % rva(seg.start_ea))

def func_name_at(ea):
    f = ida_funcs.get_func(ea)
    nm = ida_name.get_name(ea)
    if nm: return nm
    if f:  return "sub_%X" % ea
    return ""

def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(TBL, exist_ok=True)
    log("imagebase = 0x%X" % BASE)

    # 1) segments.tsv + raw bytes of each data segment
    with open(os.path.join(OUT, "segments.tsv"), "w") as sf:
        sf.write("name\tstart_rva\tend_rva\tsize\tclass\tcode\n")
        for ea in idautils.Segments():
            seg = ida_segment.getseg(ea)
            nm  = seg_name(seg)
            code = is_code_seg(seg)
            sf.write("%s\t0x%X\t0x%X\t0x%X\t%s\t%d\n" %
                     (nm, rva(seg.start_ea), rva(seg.end_ea), seg.size(),
                      ida_segment.get_segm_class(seg) or "", int(code)))
            if not code:
                b = ida_bytes.get_bytes(seg.start_ea, seg.size()) or b""
                fn = os.path.join(OUT, "seg_%s_%X.bin" % (nm.strip(".") or "data", rva(seg.start_ea)))
                with open(fn, "wb") as bf: bf.write(b)
                log("dumped data seg %s rva 0x%X (%d bytes)" % (nm, rva(seg.start_ea), len(b)))

    # 2) every named symbol that lives in a data (non-code) segment
    nsym = 0
    with open(os.path.join(OUT, "data_symbols.tsv"), "w") as df:
        df.write("rva\tsize\tname\n")
        for ea, nm in idautils.Names():
            seg = ida_segment.getseg(ea)
            if not seg or is_code_seg(seg):
                continue
            sz = ida_bytes.get_item_size(ea) or 0
            df.write("0x%X\t0x%X\t%s\n" % (rva(ea), sz, nm))
            nsym += 1
    log("named data symbols: %d" % nsym)

    # 3) vtables -> resolved method lists. A vtable is a run of qwords that each point
    #    into a code segment. We detect by name (contains 'vftable') OR by scanning the
    #    .rdata for pointer runs is overkill; names cover the C++ vtables we need.
    nvt = 0
    with open(os.path.join(OUT, "vtables.tsv"), "w") as vf:
        vf.write("vtable\tslot\ttarget_rva\ttarget_name\n")
        for ea, nm in idautils.Names():
            if "vftable" not in nm and "vtable" not in nm.lower():
                continue
            slot = 0
            p = ea
            while True:
                q = ida_bytes.get_qword(p)
                if q == 0xFFFFFFFFFFFFFFFF or q == 0:
                    break
                tseg = ida_segment.getseg(q)
                if not tseg or not is_code_seg(tseg):
                    break
                vf.write("%s\t%d\t0x%X\t%s\n" % (nm, slot, rva(q), func_name_at(q)))
                slot += 1; p += 8
                if slot > 512: break
            if slot: nvt += 1
    log("vtables resolved: %d" % nvt)

    # 4) raw bytes of the specific tables the FX/arp/gate/preset work needs, plus a
    #    generous trailing window so the full table is captured even if IDA under-sized it.
    wanted = ["unk_7FF91E63A350", "unk_7FF91E63A600", "unk_7FF91E639F20",
              "unk_7FF91E63A130", "unk_7FF91E63EB50", "unk_7FF91E910DC8"]
    # also grab any of the above by short suffix if the DB renamed them
    for nm in wanted:
        ea = idc.get_name_ea_simple(nm)
        if ea == idc.BADADDR:
            log("WARN: %s not found by name" % nm); continue
        b = ida_bytes.get_bytes(ea, 0x1000) or b""   # 4 KB window around the table
        with open(os.path.join(TBL, "%s.bin" % nm), "wb") as bf: bf.write(b)
        log("table %s rva 0x%X -> %d bytes" % (nm, rva(ea), len(b)))

    log("DONE. Zip the data_sections/ folder and upload.")

if __name__ == "__main__":
    main()
