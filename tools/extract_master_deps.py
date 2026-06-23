#!/usr/bin/env python3
# extract_master_deps.py — final extraction for the master/chorus function
# sub_180363380. Gets the three missing wave helpers, the disassembly of the
# master (to resolve dropped XMM helper args), and locates the function that
# generates the chorus coefficients (the ~250 read-only offsets sub_1803990C0
# does not set — runtime-computed, per the handoff). IDA Pro 9.3, x86-64.
#
# HOW TO RUN
#   GUI: File > Script file… > extract_master_deps.py  (analyzed database)
#   Output: ./master_deps/ next to the database. Zip and upload it.

import os
import ida_funcs, ida_hexrays, ida_name, idautils, idc, ida_bytes, ida_ua

IMAGE_BASE = 0x180000000
HELPERS = [0x180368DC0, 0x180368F30, 0x180368F90]   # missing wave helpers
MASTER  = 0x180363380                                # mix + chorus + output
# A signature subset of the chorus coeff offsets sub_1803990C0 does NOT init.
# A function touching many of these is the chorus-coefficient generator.
SIG = [84448,84464,84480,84496,84544,84560,85136,85168,85984,86288,
       87056,91120,91136,91184,91216,91248,91264,91280,95828,96336,
       101024,101264,101280,101744,102016]
KNOWN = {MASTER,0x180369070,0x18036CE00,0x180370B90,0x180374900,0x180378690,
         0x18037C420,0x180380190,0x180383F20,0x1803990C0,0x180398F30}
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "master_deps")

def log(m): print("[master_deps] " + m)
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)

def dump_pseudo(ea, tag):
    path = os.path.join(OUT, "%s_%s_%X.c" % (tag, fname(ea), ea))
    try:
        cf = ida_hexrays.decompile(ea); ps = str(cf) if cf else "// none\n"
    except Exception as e:
        ps = "// DECOMPILE FAILED: %s\n" % e
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("// %s @ 0x%X (RVA 0x%X)\n\n" % (fname(ea), ea, ea-IMAGE_BASE) + ps + "\n")

def dump_asm(ea, tag):
    f = ida_funcs.get_func(ea)
    if not f: return
    path = os.path.join(OUT, "%s_%s_%X.asm" % (tag, fname(ea), ea))
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("; %s @ 0x%X (RVA 0x%X)\n\n" % (fname(ea), ea, ea-IMAGE_BASE))
        for head in idautils.Heads(f.start_ea, f.end_ea):
            raw = ida_bytes.get_bytes(head, idc.get_item_size(head)) or b""
            fh.write("%016X  %-26s  %s\n" % (head, " ".join("%02X"%b for b in raw), idc.GetDisasm(head)))

def displ_hits(ea, sigset):
    """How many signature offsets this function accesses as [reg+disp]."""
    f = ida_funcs.get_func(ea)
    if not f: return 0
    hits = set()
    for head in idautils.Heads(f.start_ea, f.end_ea):
        insn = ida_ua.insn_t()
        if not ida_ua.decode_insn(insn, head): continue
        for op in insn.ops:
            if op.type == ida_ua.o_displ and op.addr in sigset:
                hits.add(op.addr)
    return len(hits)

def main():
    if not ida_hexrays.init_hexrays_plugin():
        log("ERROR: decompiler unavailable."); return
    os.makedirs(OUT, exist_ok=True)
    log("output: %s" % os.path.abspath(OUT))

    for h in HELPERS:
        dump_pseudo(h, "helper"); dump_asm(h, "helper")
    dump_asm(MASTER, "master")
    log("dumped helpers + master asm")

    sigset = set(SIG)
    log("scanning all functions for the chorus-coefficient generator…")
    funcs = list(idautils.Functions())
    scored = []
    for i, ea in enumerate(funcs):
        if i and i % 5000 == 0: log("  …%d/%d" % (i, len(funcs)))
        n = displ_hits(ea, sigset)
        if n >= 3:
            scored.append((ea, n))
    scored.sort(key=lambda kv: kv[1], reverse=True)
    with open(os.path.join(OUT, "coeff_gen_ranking.md"), "w", encoding="utf-8") as idx:
        idx.write("# Functions touching the chorus-coeff signature offsets\n\n")
        idx.write("| addr | RVA | sig_hits | known? |\n|--|--|--|--|\n")
        for ea, n in scored:
            idx.write("| 0x%X | 0x%X | %d | %s |\n" % (ea, ea-IMAGE_BASE, n, "Y" if ea in KNOWN else ""))
    # dump pseudocode of the top non-known candidates (the generator)
    dumped = 0
    for ea, n in scored:
        if ea in KNOWN or dumped >= 8: continue
        dump_pseudo(ea, "coeffgen%02d" % n); dumped += 1
    log("DONE. helpers+asm, master asm, coeff_gen_ranking.md, top %d candidates." % dumped)
    log("  %s" % os.path.abspath(OUT))
    log("Zip the master_deps folder and upload it.")

if __name__ == "__main__":
    main()
