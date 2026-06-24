#!/usr/bin/env python3
# extract_all.py — THE one-and-done extraction. Dumps the ENTIRE plugin's code so
# we never need another IDA session: a manifest of every function (so anything can
# be located by name/size/strings/xrefs) + the Hex-Rays decompile and disassembly
# of all plugin functions, bucketed into a handful of files for easy upload.
#
# After this, the note/MIDI handler (#1), the parameter appliers (#2), and any
# other code are all findable OFFLINE by searching the dump.
#
# RUN: File -> Script file... -> extract_all.py  (fresh/analyzed DB; AU: idle).
#   Takes a while (decompiling thousands of functions). Output: ./allcode/.
#   Zip allcode/ and upload (it compresses well).

import os, re
import ida_funcs, ida_hexrays, ida_name, idautils, idc, ida_bytes, ida_xref, ida_nalt

BASE = ida_nalt.get_imagebase()
CODE_LIMIT_RVA = 0x600000          # dump decompile+asm for plugin code below this
BUCKET = 0x40000                   # group output by 256 KB RVA buckets
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "allcode")

def log(m): print("[all] " + m)
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)

def strings_of(ea):
    """string literals referenced by the function (great for locating handlers)."""
    out=[]
    f=ida_funcs.get_func(ea)
    if not f: return out
    for h in idautils.Heads(f.start_ea,f.end_ea):
        for xr in idautils.DataRefsFrom(h):
            s=idc.get_strlit_contents(xr, -1, idc.STRTYPE_C)
            if s:
                try: out.append(s.decode("ascii","replace"))
                except Exception: pass
    return out

def callees(ea):
    out=set(); f=ida_funcs.get_func(ea)
    if not f: return out
    for h in idautils.Heads(f.start_ea,f.end_ea):
        if idc.print_insn_mnem(h)=="call":
            t=idc.get_operand_value(h,0)
            if t: out.add(t)
    return out

def main():
    have=ida_hexrays.init_hexrays_plugin()
    os.makedirs(OUT,exist_ok=True)
    log("imagebase=0x%X  hexrays=%s"%(BASE,have))
    funcs=list(idautils.Functions())
    log("total functions: %d"%len(funcs))

    man=open(os.path.join(OUT,"manifest.tsv"),"w",encoding="utf-8")
    man.write("rva\tname\tsize\txrefs_to\tn_callees\tstrings\n")
    cbuckets={}; abuckets={}
    done=0
    for ea in funcs:
        rva=ea-BASE
        f=ida_funcs.get_func(ea)
        size=(f.end_ea-f.start_ea) if f else 0
        nx=sum(1 for _ in idautils.CodeRefsTo(ea,0))
        strs=strings_of(ea)
        man.write("0x%X\t%s\t0x%X\t%d\t%d\t%s\n"%(rva,fname(ea),size,nx,len(callees(ea)),
                  " | ".join(s.replace("\t"," ")[:40] for s in strs[:8])))
        if 0 <= rva < CODE_LIMIT_RVA and f:
            b=rva//BUCKET
            # decompile
            try:
                cf=ida_hexrays.decompile(ea); ps=str(cf) if cf else "// None"
            except Exception as e: ps="// DECOMPILE FAILED: %s"%e
            cbuckets.setdefault(b,[]).append("// ==== %s @ rva 0x%X ====\n%s\n"%(fname(ea),rva,ps))
            # asm
            lines=["; ==== %s @ rva 0x%X ===="%(fname(ea),rva)]
            for h in idautils.Heads(f.start_ea,f.end_ea):
                raw=ida_bytes.get_bytes(h,idc.get_item_size(h)) or b""
                lines.append("%08X  %-24s  %s"%(rva+(h-f.start_ea)," ".join("%02X"%x for x in raw),idc.GetDisasm(h)))
            abuckets.setdefault(b,[]).append("\n".join(lines)+"\n")
        done+=1
        if done%2000==0: log("  ...%d/%d"%(done,len(funcs)))
    man.close()
    for b,parts in sorted(cbuckets.items()):
        open(os.path.join(OUT,"decomp_%06X.c"%(b*BUCKET)),"w",encoding="utf-8").write("\n".join(parts))
    for b,parts in sorted(abuckets.items()):
        open(os.path.join(OUT,"asm_%06X.asm"%(b*BUCKET)),"w",encoding="utf-8").write("\n".join(parts))
    log("DONE. manifest.tsv + %d decomp + %d asm files. Zip allcode/ and upload."
        %(len(cbuckets),len(abuckets)))

if __name__=="__main__":
    main()
