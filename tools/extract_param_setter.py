#!/usr/bin/env python3
# extract_param_setter.py — IDA Pro 9.3 (x86-64) DECISIVE dump for "Option B".
#
# QUESTION THIS ANSWERS (one function):
#   The parameter registry sub_180388170 registers ~1121 parameters, each handing
#   the registrar sub_1803ABA00 a descriptor {name, &coeffSlot, typeFlag}. We need
#   to know whether the registrar (or what it calls) WRITES a usable default value
#   into *coeffSlot -- in which case Option B is just "transcribe one denormalize
#   function" -- or whether it only stores metadata and the real coefficient is
#   applied later from a preset (in which case Option B = the whole parameter
#   framework + preset data, and a validated runtime capture is the proportionate
#   route). This dump settles it.
#
# WHAT IT DUMPS
#   - sub_1803ABA00 (the registrar) + sub_1803ABA40 + sub_180387F80 (the other
#     register variants the registry calls): decompile + asm + their callees one
#     level down (the mapping/apply chain).
#   - The raw 16 bytes (+ float/int views) of the default-descriptor constants the
#     registry uses: xmmword_18098C030, dword_18098BC64, dword_18098BE1C.
#
# HOW TO RUN
#   GUI: File > Script file... > extract_param_setter.py   (analyzed DB)
#   Output: ./param_setter/ next to the database. Zip and upload it.

import os, struct, re
import ida_funcs, ida_hexrays, ida_name, idautils, idc, ida_bytes

IMAGE_BASE = 0x180000000
REGISTRARS = [0x1803ABA00, 0x1803ABA40, 0x180387F80, 0x1803ABA80, 0x1803AB700]
CONSTS     = [0x18098C030, 0x18098BC64, 0x18098BE1C]   # the default descriptors
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "param_setter")

def log(m): print("[param_setter] " + m)
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)
# Windows-safe filename token (C++ mangled names contain ? @ < > : etc.)
def safe(s): return re.sub(r"[^A-Za-z0-9_.-]", "_", s)[:80]

def dump_pseudo(ea, tag):
    path = os.path.join(OUT, "%s_%s_%X.c" % (tag, safe(fname(ea)), ea))
    try:
        cf = ida_hexrays.decompile(ea); ps = str(cf) if cf else "// decompile returned None\n"
    except Exception as e:
        ps = "// DECOMPILE FAILED: %s\n" % e
    try:
        with open(path, "w", encoding="utf-8") as fh:
            fh.write("// %s @ 0x%X (RVA 0x%X)\n\n" % (fname(ea), ea, ea-IMAGE_BASE) + ps + "\n")
        log("c    -> %s" % os.path.basename(path))
    except Exception as e:
        log("c    SKIP 0x%X (%s)" % (ea, e))

def dump_asm(ea, tag):
    f = ida_funcs.get_func(ea)
    if not f: log("WARN no func @ 0x%X" % ea); return []
    path = os.path.join(OUT, "%s_%s_%X.asm" % (tag, safe(fname(ea)), ea))
    callees = []
    try:
        with open(path, "w", encoding="utf-8") as fh:
            fh.write("; %s @ 0x%X (RVA 0x%X) size=0x%X\n\n" % (fname(ea), ea, ea-IMAGE_BASE, f.end_ea-f.start_ea))
            for head in idautils.Heads(f.start_ea, f.end_ea):
                raw = ida_bytes.get_bytes(head, idc.get_item_size(head)) or b""
                fh.write("%016X  %-26s  %s\n" % (head, " ".join("%02X"%b for b in raw), idc.GetDisasm(head)))
                if idc.print_insn_mnem(head) == "call":
                    t = idc.get_operand_value(head, 0)
                    if t and ida_funcs.get_func(t): callees.append(t)
        log("asm  -> %s" % os.path.basename(path))
    except Exception as e:
        log("asm  SKIP 0x%X (%s)" % (ea, e))
    return callees

def dump_const(addr):
    b = ida_bytes.get_bytes(addr, 16) or b""
    f32 = struct.unpack("<4f", b[:16]) if len(b) >= 16 else ()
    i32 = struct.unpack("<4i", b[:16]) if len(b) >= 16 else ()
    return ("0x%011X %s\n  bytes : %s\n  as f32: %s\n  as i32: %s\n"
            % (addr, fname(addr), " ".join("%02X"%x for x in b),
               ", ".join("%g"%v for v in f32), ", ".join(str(v) for v in i32)))

def main():
    have = ida_hexrays.init_hexrays_plugin()
    os.makedirs(OUT, exist_ok=True)
    log("output: %s" % os.path.abspath(OUT))
    seen = set()
    for ea in REGISTRARS:
        if not ida_funcs.get_func(ea):
            log("skip (no func) 0x%X" % ea); continue
        if have: dump_pseudo(ea, "reg")
        callees = dump_asm(ea, "reg")
        # one level down: the mapping / apply chain. STL/CRT helpers (e.g.
        # vector::_Xlen) come along as noise — harmless, just ignore those files.
        for c in callees:
            if c in seen or c in REGISTRARS: continue
            seen.add(c)
            try:
                if have: dump_pseudo(c, "callee")
                dump_asm(c, "callee")
            except Exception as e:
                log("callee SKIP 0x%X (%s)" % (c, e))
    with open(os.path.join(OUT, "default_constants.txt"), "w", encoding="utf-8") as fh:
        fh.write("# default-descriptor constants the registry hands the registrar\n\n")
        for a in CONSTS: fh.write(dump_const(a) + "\n")
    log("default_constants.txt written")
    log("DONE. Zip the param_setter folder and upload it.")

if __name__ == "__main__":
    main()
