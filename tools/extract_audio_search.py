#!/usr/bin/env python3
# extract_audio_search.py — find the audio DSP functions that the call-graph walk
# missed because they're reached through indirect/vtable calls (notably the
# stereo chorus and the voice-mix/output stage). IDA Pro 9.3, x86-64.
#
# METHOD
#   Rank EVERY function by floating-point-DSP density (count of scalar/packed SSE
#   float-arithmetic instructions: mul/add/sub/div/min/max/sqrt/fmadd in ss/ps).
#   Threading and CRT code score ~0; real DSP scores high. Dump the top functions
#   that are NOT already in our closure (the 8 voice renders + helpers), with
#   pseudocode + constants, so the chorus and output stage can be identified and
#   transcribed exactly.
#
# HOW TO RUN
#   GUI: File > Script file… > extract_audio_search.py  (analyzed database)
#   Output: ./audio_search/ next to the database. Zip and upload it.

import os
import ida_funcs, ida_hexrays, ida_name, ida_bytes, ida_segment
import idautils, idc, ida_idaapi

IMAGE_BASE = 0x180000000
TOP_N      = 40
# already-known DSP (skip these in the dump; still scored for reference)
KNOWN = {0x180369070,0x18036CE00,0x180370B90,0x180374900,0x180378690,
         0x18037C420,0x180380190,0x180383F20,0x180368D60,0x180368FC0,
         0x1803990C0,0x180398F30}
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "audio_search")

# SSE float-arithmetic mnemonics (scalar + packed, single + double + FMA)
FLOAT_OPS = set()
for base in ("mul","add","sub","div","min","max","sqrt","rcp","rsqrt"):
    for suf in ("ss","ps","sd","pd"):
        FLOAT_OPS.add(base+suf)
for fma in ("vfmadd","vfmsub","vfnmadd","vfnmsub"):
    for variant in ("132","213","231"):
        for suf in ("ss","ps","sd","pd"):
            FLOAT_OPS.add(fma+variant+suf)

def log(m): print("[audio_search] " + m)

def score(ea):
    f = ida_funcs.get_func(ea)
    if not f: return 0
    n = 0
    for head in idautils.Heads(f.start_ea, f.end_ea):
        m = idc.print_insn_mnem(head)
        if m in FLOAT_OPS:
            n += 1
    return n

def main():
    if not ida_hexrays.init_hexrays_plugin():
        log("ERROR: decompiler unavailable."); return
    os.makedirs(OUT, exist_ok=True)
    log("output: %s" % os.path.abspath(OUT))
    funcs = list(idautils.Functions())
    log("scoring %d functions by float-DSP density…" % len(funcs))
    scores = {}
    for i, ea in enumerate(funcs):
        if i and i % 5000 == 0: log("  …%d/%d" % (i, len(funcs)))
        s = score(ea)
        if s >= 8:               # ignore trivial float users
            scores[ea] = s
    ranked = sorted(scores.items(), key=lambda kv: kv[1], reverse=True)
    log("functions with >=8 float ops: %d" % len(ranked))

    dumped = 0
    with open(os.path.join(OUT, "ranking.md"), "w", encoding="utf-8") as idx:
        idx.write("# Float-DSP density ranking (candidates for chorus / mix / output)\n\n")
        idx.write("| rank | addr | RVA | float_ops | known? |\n|--|--|--|--|--|\n")
        for rank, (ea, s) in enumerate(ranked):
            known = ea in KNOWN
            nm = ida_name.get_name(ea) or ("sub_%X" % ea)
            idx.write("| %d | 0x%X | 0x%X | %d | %s |\n"
                      % (rank, ea, ea-IMAGE_BASE, s, "Y" if known else ""))
            if known or dumped >= TOP_N:
                continue
            dumped += 1
            safe = nm.replace("?","_").replace(":","_").replace("/","_")[:70]
            path = os.path.join(OUT, "%03d_%s_%X.c" % (rank, safe, ea))
            try:
                cf = ida_hexrays.decompile(ea); ps = str(cf) if cf else "// none\n"
            except Exception as e:
                ps = "// DECOMPILE FAILED: %s\n" % e
            with open(path, "w", encoding="utf-8") as fh:
                fh.write("// %s @ 0x%X (RVA 0x%X)  float_ops=%d\n\n" % (nm, ea, ea-IMAGE_BASE, s))
                fh.write(ps + "\n")
    log("DONE. Dumped top %d unknown DSP candidates + ranking.md to:" % dumped)
    log("  %s" % os.path.abspath(OUT))
    log("Zip the audio_search folder and upload it.")

if __name__ == "__main__":
    main()
