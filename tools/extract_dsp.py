#!/usr/bin/env python3
# extract_dsp.py — one-time DSP call-tree extractor for IDA Pro 9.3 (SP2), x86-64.
#
# PURPOSE
#   Dump the COMPLETE decompiled DSP closure of the target VST so the whole audio
#   engine can be transcribed to C99 from real pseudocode — no curve-fitting, no
#   guessing. Run ONCE; after this you never need to go back to IDA for code.
#
# WHAT IT DOES
#   1. Starts from one known seed (the per-voice render) and climbs UP a few caller
#      levels to find the audio roots (the process / master-mix function that calls
#      the render and the chorus).
#   2. From those roots, walks DOWN the call graph transitively to the leaves —
#      the full closed set of functions the audio path touches.
#   3. For every function in that closure, emits: Hex-Rays pseudocode (.c),
#      prototype, and every constant/global it reads (.rdata/.data values).
#   4. Writes a MANIFEST + call graph so the next step (transcription) has an index.
#
# HOW TO RUN
#   GUI:      File > Script file… > extract_dsp.py   (on the auto-analyzed .i64)
#   Headless: idat64 -A -S"extract_dsp.py" -L"extract.log"  path\to\plugin.vst3
#   Output goes to ./dsp_dump/ next to the database.
#
# TWO THINGS TO CONFIRM BEFORE RUNNING (see CONFIG):
#   • SEED_EAS  — the per-voice render is pre-filled. Add the master-mix and chorus
#                 process addresses here too if you already know them (cleaner than
#                 relying on the caller-climb to find them).
#   • SCOPE     — "subtree" (audio closure only, recommended) or "all".
#
# Targets the IDA 9.x IDAPython API (ida_hexrays / ida_funcs / idautils). Stable
# across the 9.3 service packs.

import os
import ida_hexrays, ida_funcs, ida_bytes, ida_name, ida_segment
import idautils, idc, ida_idaapi

# ─────────────────────────── CONFIG ───────────────────────────
IMAGE_BASE = 0x180000000
SEED_EAS   = [
    0x180369070,   # per-voice render (was FUN_180369070 in the old Ghidra dump)
    # 0x1803xxxxx, # <-- add master-mix / output-stage address here if known
    # 0x1803xxxxx, # <-- add chorus process address here if known
]
SCOPE          = "subtree"   # "subtree" = audio closure only; "all" = every function
CALLER_LEVELS  = 3           # how many levels to climb above the seed to find roots
MAX_FUNCS      = 6000        # safety cap on closure size
OUT            = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "dsp_dump")

# ─────────────────────────── helpers ───────────────────────────
def log(msg):
    print("[extract_dsp] " + msg)

def fname(ea):
    n = ida_name.get_name(ea)
    return n if n else ("sub_%X" % ea)

def func_start(ea):
    f = ida_funcs.get_func(ea)
    return f.start_ea if f else ida_idaapi.BADADDR

def callees_of(ea):
    """All call targets inside the function at ea, resolved to function starts."""
    out = set()
    f = ida_funcs.get_func(ea)
    if not f:
        return out
    for head in idautils.Heads(f.start_ea, f.end_ea):
        for xref in idautils.XrefsFrom(head, 0):
            # fl_CN/fl_CF = near/far call; fl_JN/fl_JF can be tail-calls too
            if xref.type in (ida_idaapi.fl_CN, ida_idaapi.fl_CF,
                             ida_idaapi.fl_JN, ida_idaapi.fl_JF):
                tgt = func_start(xref.to)
                if tgt != ida_idaapi.BADADDR:
                    out.add(tgt)
    return out

def callers_of(ea):
    """All functions that call into the function at ea."""
    out = set()
    f = ida_funcs.get_func(ea)
    if not f:
        return out
    for xref in idautils.XrefsTo(f.start_ea, 0):
        if xref.type in (ida_idaapi.fl_CN, ida_idaapi.fl_CF,
                         ida_idaapi.fl_JN, ida_idaapi.fl_JF):
            src = func_start(xref.frm)
            if src != ida_idaapi.BADADDR:
                out.add(src)
    return out

def climb_to_roots(seeds, levels):
    """Climb up `levels` of callers so the master/process function (which calls the
    render AND the chorus) is included as a root. Returns the union of seeds + the
    callers found, so nothing below the render is ever lost."""
    roots = set(func_start(s) for s in seeds if func_start(s) != ida_idaapi.BADADDR)
    frontier = set(roots)
    for _ in range(levels):
        nxt = set()
        for ea in frontier:
            for c in callers_of(ea):
                if c not in roots:
                    nxt.add(c); roots.add(c)
        frontier = nxt
        if not frontier:
            break
    return roots

def data_refs(ea):
    """Constants / globals the function reads, with their values where small."""
    refs = []
    f = ida_funcs.get_func(ea)
    if not f:
        return refs
    seen = set()
    for head in idautils.Heads(f.start_ea, f.end_ea):
        for dref in idautils.DataRefsFrom(head):
            if dref in seen:
                continue
            seen.add(dref)
            seg = ida_segment.getseg(dref)
            segname = ida_segment.get_segm_name(seg) if seg else "?"
            name = ida_name.get_name(dref) or ""
            # pull a 4- and 8-byte view; float reads are the ones we care about
            try:
                u32 = ida_bytes.get_dword(dref)
                f32 = idc.atof if False else None  # placeholder; raw bits below
                import struct
                f32 = struct.unpack("<f", struct.pack("<I", u32))[0]
                f64 = struct.unpack("<d", ida_bytes.get_qword(dref).to_bytes(8, "little"))[0]
                refs.append((dref, segname, name, u32, f32, f64))
            except Exception:
                refs.append((dref, segname, name, None, None, None))
    return refs

def decompile_text(ea):
    try:
        cf = ida_hexrays.decompile(ea)
        if cf:
            return str(cf)
    except Exception as e:
        return "// DECOMPILE FAILED: %s\n" % e
    return "// DECOMPILE returned None\n"

def disasm_text(ea):
    f = ida_funcs.get_func(ea)
    if not f:
        return ""
    lines = []
    for head in idautils.Heads(f.start_ea, f.end_ea):
        lines.append("%016X  %s" % (head, idc.GetDisasm(head)))
    return "\n".join(lines)

# ─────────────────────────── main ───────────────────────────
def main():
    if not ida_hexrays.init_hexrays_plugin():
        log("ERROR: Hex-Rays decompiler not available. Need the x86-64 decompiler "
            "assigned to this license.")
        return
    os.makedirs(OUT, exist_ok=True)

    if SCOPE == "all":
        closure = set(idautils.Functions())
        roots = set(func_start(s) for s in SEED_EAS)
        log("SCOPE=all → %d functions" % len(closure))
    else:
        roots = climb_to_roots(SEED_EAS, CALLER_LEVELS)
        log("roots (after climbing %d caller levels): %d" % (CALLER_LEVELS, len(roots)))
        # transitive callee walk from roots
        closure = set(roots)
        frontier = set(roots)
        while frontier and len(closure) < MAX_FUNCS:
            nxt = set()
            for ea in frontier:
                for c in callees_of(ea):
                    if c not in closure:
                        closure.add(c); nxt.add(c)
            frontier = nxt
        log("closure size: %d functions" % len(closure))

    closure = sorted(closure)
    manifest = []
    data_index = {}

    for i, ea in enumerate(closure):
        nm = fname(ea)
        safe = nm.replace("?", "_").replace(":", "_").replace("/", "_")[:80]
        path = os.path.join(OUT, "%04d_%s_%X.c" % (i, safe, ea))
        proto = idc.get_type(ea) or ""
        pseudo = decompile_text(ea)
        if pseudo.startswith("// DECOMPILE"):
            pseudo += "\n// ---- disassembly fallback ----\n" + disasm_text(ea)
        drefs = data_refs(ea)
        with open(path, "w", encoding="utf-8") as fh:
            fh.write("// %s  @ 0x%X  (RVA 0x%X)\n" % (nm, ea, ea - IMAGE_BASE))
            fh.write("// prototype: %s\n" % proto)
            if ea in roots:
                fh.write("// *** AUDIO ROOT ***\n")
            fh.write("// callees: %s\n" %
                     ", ".join("0x%X" % c for c in sorted(callees_of(ea))))
            if drefs:
                fh.write("// constants/globals referenced:\n")
                for (d, seg, dn, u32, f32, f64) in drefs:
                    fh.write("//   0x%X [%s] %s  u32=%s  f32=%s  f64=%s\n"
                             % (d, seg, dn, u32, f32, f64))
                    data_index.setdefault(d, (seg, dn, u32, f32, f64))
            fh.write("\n" + pseudo + "\n")
        manifest.append((i, ea, nm, ea in roots, len(drefs)))

    # MANIFEST
    with open(os.path.join(OUT, "MANIFEST.md"), "w", encoding="utf-8") as fh:
        fh.write("# DSP extraction manifest\n\n")
        fh.write("ImageBase 0x%X | scope=%s | %d functions | %d roots\n\n"
                 % (IMAGE_BASE, SCOPE, len(closure), len(roots)))
        fh.write("| # | addr | RVA | name | root | #consts |\n|--|--|--|--|--|--|\n")
        for (i, ea, nm, isroot, nd) in manifest:
            fh.write("| %d | 0x%X | 0x%X | %s | %s | %d |\n"
                     % (i, ea, ea - IMAGE_BASE, nm, "Y" if isroot else "", nd))

    # call graph (edge list)
    with open(os.path.join(OUT, "callgraph.txt"), "w", encoding="utf-8") as fh:
        for ea in closure:
            for c in sorted(callees_of(ea)):
                if c in closure:
                    fh.write("0x%X -> 0x%X\n" % (ea, c))

    # consolidated constants table (the float coefficients live here)
    with open(os.path.join(OUT, "constants.txt"), "w", encoding="utf-8") as fh:
        fh.write("# addr  segment  name  u32  f32  f64\n")
        for d in sorted(data_index):
            seg, dn, u32, f32, f64 = data_index[d]
            fh.write("0x%X  %s  %s  %s  %s  %s\n" % (d, seg, dn, u32, f32, f64))

    log("DONE. Wrote %d functions to %s" % (len(closure), OUT))
    log("Read MANIFEST.md first, then the root functions, then their callees.")

if __name__ == "__main__":
    main()
