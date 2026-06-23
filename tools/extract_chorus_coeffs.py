#!/usr/bin/env python3
# [SUPERSEDED — kept for provenance] This dump was run and DISPROVED its premise:
# sub_180388170 is the PARAMETER REGISTRY (registers ~1121 params; its "constants"
# are name strings), not the chorus coefficient generator. The chorus constructor
# is sub_1803A1300 (-> src/chorus_init.c); the coefficient VALUES are applied at
# runtime and are captured via tools/capture_runtime_coeffs.js. Do not rerun.
#
# extract_chorus_coeffs.py — IDA Pro 9.3 (x86-64) one-shot dump for the chorus
# COEFFICIENT GENERATOR sub_180388170.
#
# WHY THIS SCRIPT EXISTS
#   The stereo BBD chorus in sub_180363380 reads ~250 read-only coefficient
#   offsets that the voice initializer sub_1803990C0 does NOT write. The function
#   that computes and stores them is sub_180388170 (it touches 20 of the 25
#   chorus-signature offsets — see master_deps/coeff_gen_ranking.md). Hex-Rays
#   returns None on it (decompile failed), so we cannot read the algorithm from
#   pseudocode. We need its DISASSEMBLY, plus the disassembly of how it is
#   CALLED (to recover its arguments), plus the static values of every .rdata
#   float it references. With those three pieces the coefficient math can be
#   transcribed exactly — no fitting, no guessing.
#
#   sub_1803A1300 (5 sig hits) DOES decompile (it is a zeroing/ctor init, already
#   captured as master_deps/coeffgen05_*). We still dump its asm for completeness
#   in case a store there matters, but it is secondary.
#
# HOW TO RUN
#   GUI : File > Script file… > extract_chorus_coeffs.py   (on the analyzed DB)
#   CLI : idat64 -A -S"extract_chorus_coeffs.py" -L"cc.log" <plugin>
#   Output lands in ./chorus_coeffs/ next to the database. Zip and upload it.

import os
import ida_funcs, ida_hexrays, ida_name, idautils, idc, ida_bytes, ida_ua, ida_xref

IMAGE_BASE = 0x180000000
COEFFGEN   = 0x180388170    # chorus coefficient generator (Hex-Rays = None)
ZERO_INIT  = 0x1803A1300    # zeroing/ctor (decompiles; dumped for completeness)
TARGETS    = [COEFFGEN, ZERO_INIT]

OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "chorus_coeffs")

def log(m): print("[chorus_coeffs] " + m)
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)

def dump_asm(ea, tag):
    f = ida_funcs.get_func(ea)
    if not f:
        log("WARN: no function at 0x%X (%s)" % (ea, tag)); return
    path = os.path.join(OUT, "%s_%s_%X.asm" % (tag, fname(ea), ea))
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("; %s @ 0x%X (RVA 0x%X)  size=0x%X\n\n"
                 % (fname(ea), ea, ea - IMAGE_BASE, f.end_ea - f.start_ea))
        for head in idautils.Heads(f.start_ea, f.end_ea):
            raw = ida_bytes.get_bytes(head, idc.get_item_size(head)) or b""
            fh.write("%016X  %-26s  %s\n"
                     % (head, " ".join("%02X" % b for b in raw), idc.GetDisasm(head)))
    log("asm  -> %s" % os.path.basename(path))

def dump_pseudo(ea, tag):
    path = os.path.join(OUT, "%s_%s_%X.c" % (tag, fname(ea), ea))
    try:
        cf = ida_hexrays.decompile(ea)
        ps = str(cf) if cf else "// decompile returned None\n"
    except Exception as e:
        ps = "// DECOMPILE FAILED: %s\n" % e
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("// %s @ 0x%X (RVA 0x%X)\n\n" % (fname(ea), ea, ea - IMAGE_BASE) + ps + "\n")
    log("c    -> %s" % os.path.basename(path))

FLT_SECS = (".rdata", ".data", ".text", ".rodata")

def fmt_float_at(ea):
    """Return (f32, f64) interpretations of the 4/8 bytes at ea, or Nones."""
    import struct
    b = ida_bytes.get_bytes(ea, 8) or b""
    f32 = struct.unpack("<f", b[:4])[0] if len(b) >= 4 else None
    f64 = struct.unpack("<d", b)[0] if len(b) >= 8 else None
    return f32, f64

def dump_const_refs(ea, tag):
    """Every data address this function references, with float interpretations.
    The genuine coefficient *values* the generator multiplies in live here."""
    f = ida_funcs.get_func(ea)
    if not f: return
    refs = {}
    for head in idautils.Heads(f.start_ea, f.end_ea):
        for xr in idautils.DataRefsFrom(head):
            if xr in refs: continue
            f32, f64 = fmt_float_at(xr)
            refs[xr] = (idc.get_item_size(xr), fname(xr), f32, f64)
    path = os.path.join(OUT, "%s_%s_%X_constrefs.txt" % (tag, fname(ea), ea))
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("# data refs from %s @ 0x%X\n" % (fname(ea), ea))
        fh.write("# addr            name                  f32                       f64\n")
        for a in sorted(refs):
            sz, nm, f32, f64 = refs[a]
            fh.write("0x%011X  %-22s  %-24s  %s\n"
                     % (a, nm, repr(f32), repr(f64)))
    log("refs -> %s (%d data refs)" % (os.path.basename(path), len(refs)))

def dump_callers(ea, tag):
    """Disassemble a window around each call site so the generator's ARGUMENTS
    (sample rate, mode, param pointers in rcx/rdx/r8/xmm0…) are recoverable."""
    path = os.path.join(OUT, "%s_%s_%X_callers.asm" % (tag, fname(ea), ea))
    callers = []
    xr = ida_xref.get_first_cref_to(ea)
    while xr != idc.BADADDR:
        if idc.print_insn_mnem(xr).startswith(("call", "jmp")):
            callers.append(xr)
        xr = ida_xref.get_next_cref_to(ea, xr)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("; callers of %s @ 0x%X  (%d call sites)\n\n" % (fname(ea), ea, len(callers)))
        for cs in callers:
            cf = ida_funcs.get_func(cs)
            owner = fname(cf.start_ea) if cf else "?"
            fh.write(";==== call from %s at 0x%X — 40 insns of context ====\n" % (owner, cs))
            head = cs
            # back up ~40 instructions to show argument setup
            for _ in range(40):
                p = idc.prev_head(head, head - 0x200)
                if p == idc.BADADDR or p < (cf.start_ea if cf else 0): break
                head = p
            while head <= cs:
                raw = ida_bytes.get_bytes(head, idc.get_item_size(head)) or b""
                fh.write("%016X  %-26s  %s\n"
                         % (head, " ".join("%02X" % b for b in raw), idc.GetDisasm(head)))
                head = idc.next_head(head, cs + 1)
            fh.write("\n")
    log("call -> %s (%d sites)" % (os.path.basename(path), len(callers)))

def main():
    have_hr = ida_hexrays.init_hexrays_plugin()
    os.makedirs(OUT, exist_ok=True)
    log("output: %s" % os.path.abspath(OUT))
    for ea in TARGETS:
        tag = "coeffgen" if ea == COEFFGEN else "zeroinit"
        dump_asm(ea, tag)
        if have_hr: dump_pseudo(ea, tag)
        dump_const_refs(ea, tag)
        dump_callers(ea, tag)
    log("DONE. Zip the chorus_coeffs folder and upload it.")
    log("  primary artifact: coeffgen_sub_180388170_*.asm (the algorithm)")
    log("  %s" % os.path.abspath(OUT))

if __name__ == "__main__":
    main()
