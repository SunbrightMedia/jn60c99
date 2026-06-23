#!/usr/bin/env python3
# extract_init.py — recover the COEFFICIENT VALUES the audio closure reads but
# never writes. IDA Pro 9.3 (SP2), x86-64, Hex-Rays. Companion to extract_dsp.py.
#
# WHY THIS EXISTS
#   voice_render and the chorus read many fixed coefficients from struct fields
#   (e.g. the waveshaper polynomial, filter/mix scalars). Those fields are filled
#   by INITIALIZATION / constructor code that is NOT in the audio call-closure,
#   so the numeric values are absent from dsp_dump/. This script finds the init
#   code and the static float tables it copies from.
#
# WHAT IT DOES (one pass over every function in the binary)
#   1. Scores each function by how many DISTINCT plausible .rdata float constants
#      it references. Coefficient-table initializers score very high (they load
#      dozens of floats into a struct), so they rise to the top.
#   2. Dumps the Hex-Rays pseudocode of the top TOP_N functions — these contain
#      the "*(struct + N) = <constant>" assignments that map value -> field.
#   3. Emits a CONSOLIDATED global float table: every .rdata address referenced
#      by ANY code, with its float value. Safety net so no stored value is missed.
#
# WHAT IT CANNOT GET
#   Coefficients COMPUTED at runtime (not stored as constants) — notably some
#   chorus values derived from the sample rate at init. Those come from the old
#   project's Frida golden dumps. This script will get everything that is static.
#
# HOW TO RUN  (same as before)
#   GUI:  File > Script file… > extract_init.py   (on the analyzed database)
#   Output goes to ./init_dump/ next to the database. Zip it and upload.

import os, struct
import ida_hexrays, ida_funcs, ida_bytes, ida_name, ida_segment
import idautils, idc, ida_idaapi

# ─────────────────────────── CONFIG ───────────────────────────
IMAGE_BASE = 0x180000000
TOP_N      = 60          # how many constant-heaviest functions to decompile/dump
MIN_SCORE  = 6           # ignore functions referencing fewer than this many floats
OUT        = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "init_dump")

# A float constant is "plausible" as a DSP coefficient if it is finite and either
# exactly zero or within a sane magnitude band (filters out pointers/garbage that
# happen to decode as enormous/tiny floats).
def plausible_float(u32):
    try:
        f = struct.unpack("<f", struct.pack("<I", u32 & 0xFFFFFFFF))[0]
    except Exception:
        return None
    if f != f or f in (float("inf"), float("-inf")):   # NaN/Inf
        return None
    a = abs(f)
    if a == 0.0 or (1e-12 <= a <= 1e12):
        return f
    return None

def log(m): print("[extract_init] " + m)

def seg_name(ea):
    s = ida_segment.getseg(ea)
    return ida_segment.get_segm_name(s) if s else "?"

# ─────────────────────────── main ───────────────────────────
def main():
    if not ida_hexrays.init_hexrays_plugin():
        log("ERROR: x86-64 decompiler not available. (No output written.)")
        return
    os.makedirs(OUT, exist_ok=True)
    log("output folder: %s" % os.path.abspath(OUT))

    funcs = list(idautils.Functions())
    log("scanning %d functions for .rdata float references…" % len(funcs))

    scores      = {}    # func_ea -> set of distinct .rdata float addrs it reads
    global_tbl  = {}    # rdata_addr -> (f32, name)  (every code-referenced float)

    for n, fea in enumerate(funcs):
        if n and n % 5000 == 0:
            log("  …scanned %d/%d" % (n, len(funcs)))
        f = ida_funcs.get_func(fea)
        if not f:
            continue
        hits = set()
        for head in idautils.Heads(f.start_ea, f.end_ea):
            for d in idautils.DataRefsFrom(head):
                if seg_name(d) != ".rdata":
                    continue
                fv = plausible_float(ida_bytes.get_dword(d))
                if fv is None:
                    continue
                hits.add(d)
                if d not in global_tbl:
                    global_tbl[d] = (fv, ida_name.get_name(d) or "")
        if len(hits) >= MIN_SCORE:
            scores[fea] = hits

    log("functions with >= %d float refs: %d" % (MIN_SCORE, len(scores)))

    # rank and dump the constant-heaviest functions (the initializers)
    ranked = sorted(scores.items(), key=lambda kv: len(kv[1]), reverse=True)[:TOP_N]
    log("decompiling top %d initializer candidates…" % len(ranked))

    with open(os.path.join(OUT, "init_ranking.md"), "w", encoding="utf-8") as idx:
        idx.write("# Initializer candidates (most .rdata float constants first)\n\n")
        idx.write("| rank | addr | RVA | name | #floats |\n|--|--|--|--|--|\n")
        for rank, (fea, hits) in enumerate(ranked):
            nm = ida_name.get_name(fea) or ("sub_%X" % fea)
            idx.write("| %d | 0x%X | 0x%X | %s | %d |\n"
                      % (rank, fea, fea - IMAGE_BASE, nm, len(hits)))
            safe = nm.replace("?", "_").replace(":", "_").replace("/", "_")[:70]
            path = os.path.join(OUT, "%03d_%s_%X.c" % (rank, safe, fea))
            try:
                cf = ida_hexrays.decompile(fea)
                pseudo = str(cf) if cf else "// decompile returned None\n"
            except Exception as e:
                pseudo = "// DECOMPILE FAILED: %s\n" % e
            with open(path, "w", encoding="utf-8") as fh:
                fh.write("// %s  @ 0x%X  (RVA 0x%X)  floats=%d\n"
                         % (nm, fea, fea - IMAGE_BASE, len(hits)))
                fh.write("// .rdata float constants referenced by this function:\n")
                for d in sorted(hits):
                    fv, dn = global_tbl[d]
                    fh.write("//   0x%X  %s = %r\n" % (d, dn or "(unnamed)", fv))
                fh.write("\n" + pseudo + "\n")

    # global float table (safety net): every code-referenced .rdata float
    with open(os.path.join(OUT, "global_float_constants.txt"), "w", encoding="utf-8") as fh:
        fh.write("# addr  value  name   (every .rdata float referenced by code)\n")
        for d in sorted(global_tbl):
            fv, dn = global_tbl[d]
            fh.write("0x%X  %r  %s\n" % (d, fv, dn))

    log("DONE. Wrote top-%d pseudocode + init_ranking.md + global_float_constants.txt"
        % len(ranked))
    log("  %s" % os.path.abspath(OUT))
    log("Next: zip the init_dump folder and upload it.")

if __name__ == "__main__":
    main()
