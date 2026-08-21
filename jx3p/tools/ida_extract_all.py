# ida_extract_all.py -- THE ONE-AND-ONLY IDA RUN for a full port.
#
# Built for the JX-3P, but synth-agnostic: point CLASS_PREFIX at the DSP class
# family and it dumps EVERYTHING a bit-exact port + oracle needs, in one pass,
# so IDA never has to be opened again. It replaces the EIGHT separate JUNO
# scripts (extract_dsp / tables / init / param_setter / param_meta /
# master_deps / everything_static / host_layer) with their union, and it
# discovers its own targets from RTTI + call-graph closure rather than a
# hand-list of addresses -- so completeness does not depend on guessing.
#
# IDA Pro 9.x (Hex-Rays), x86-64. Read-only, no debugger. Safe to run on the
# freshly auto-analysed database.
#
# ============================ HOW TO RUN ============================
#   1. IDA Pro -> File -> Open -> JX3P.vst3   (let auto-analysis FINISH;
#      the bottom-left says "AU: idle". This can take several minutes on a
#      14 MB DLL -- wait for it, the dump is only complete on a done database.)
#   2. File -> Script file... -> this file.
#   3. Watch the Output window. It prints a progress line per phase and ends
#      with "=== DONE. Zip <dir> and send it. ===".
#   4. Zip the output directory it names (next to the .i64) and upload it.
# ===================================================================
#
# CPU BUDGET: the closure decompile is the slow part (minutes, not hours).
# Everything else is instant. One run.

import os, re, struct, json
import ida_funcs, ida_hexrays, ida_name, ida_bytes, ida_segment, ida_nalt
import idautils, idc, ida_xref, ida_typeinf

IMAGE_BASE   = idc.get_inf_attr(idc.INF_BASEADDR)
CLASS_PREFIX = "CDSPJx3p"        # DSP module family; also grabs CPrmDSP* below
PLUGIN_HINT  = "CPrmDSP"         # the control/parameter class family
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "jx3p_dump")
if not os.path.isdir(OUT):
    os.makedirs(OUT)

def log(m): print("[extract] " + m)
def rva(ea): return ea - IMAGE_BASE
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)
def safe(s): return re.sub(r"[^A-Za-z0-9_.-]", "_", s)[:90]

# ---------------------------------------------------------------- RTTI seeds
# Find every class vtable whose RTTI TypeDescriptor name starts with a prefix,
# and return {classname: vtable_ea}. Uses IDA's own name for '??_7Name@@6B@'
# (the MSVC vftable symbol) when present, else scans for the COL pattern.
def find_vtables(prefixes):
    out = {}
    for ea, name in idautils.Names():
        # MSVC vftable mangled symbol: ??_7<Class>@@6B@
        m = re.match(r"\?\?_7(" + "|".join(prefixes) + r"\w*)@@6B", name)
        if m:
            out.setdefault(m.group(1), ea)
    if len(out) >= 8:
        return out
    # FALLBACK: IDA did not name the vftables -- scan RTTI directly (the same
    # COL walk rtti_seeds.py uses off-line), so seeds never depend on naming.
    log("find_vtables: only %d named; falling back to raw RTTI COL scan" % len(out))
    for seg in idautils.Segments():
        s = ida_segment.getseg(seg)
        nm = ida_segment.get_segm_name(s)
        if nm not in (".data", ".rdata"): continue
        ea = s.start_ea
        while ea < s.end_ea - 4:
            # TypeDescriptor name string ".?AV<Class>@@"
            b = ida_bytes.get_bytes(ea, 4) or b""
            if b == b".?AV":
                end = ea
                while end < ea + 200 and ida_bytes.get_byte(end) != 0: end += 1
                cls = ida_bytes.get_bytes(ea + 4, end - ea - 4).decode("latin1").rstrip("@")
                if any(cls.startswith(p) for p in prefixes):
                    td = ea - 16
                    for xr in idautils.XrefsTo(td, 0):     # COL references the TD
                        col = xr.frm - 12
                        if ida_bytes.get_dword(col) == 1:   # x64 COL signature
                            for vxr in idautils.XrefsTo(col, 0):
                                vft = vxr.frm + 8
                                if ida_funcs.get_func(ida_bytes.get_qword(vft)):
                                    out.setdefault(cls, vft)
                ea = end
            ea += 1
    return out

# fallback if IDA didn't name the vftables: scan .rdata for COLs (rare on 9.x)
def seeds_from_vtables(vts):
    seeds = set()
    for cls, vft in vts.items():
        for i in range(24):                       # first virtual slots
            p = ida_bytes.get_qword(vft + 8 * i)
            f = ida_funcs.get_func(p)
            if f and f.start_ea == p:
                seeds.add(p)
            else:
                break
    return seeds

# --------------------------------------------------------- call-graph closure
def callees(ea):
    f = ida_funcs.get_func(ea)
    if not f: return []
    out = set()
    for h in idautils.Heads(f.start_ea, f.end_ea):
        for xr in idautils.XrefsFrom(h, 0):
            if xr.type in (ida_xref.fl_CN, ida_xref.fl_CF):   # near/far call
                g = ida_funcs.get_func(xr.to)
                if g: out.add(g.start_ea)
    return out

def callers(ea, levels):
    seen, frontier = set(), {ea}
    for _ in range(levels):
        nxt = set()
        for t in frontier:
            for xr in idautils.XrefsTo(t, 0):
                if xr.type in (ida_xref.fl_CN, ida_xref.fl_CF):
                    g = ida_funcs.get_func(xr.frm)
                    if g and g.start_ea not in seen:
                        seen.add(g.start_ea); nxt.add(g.start_ea)
        frontier = nxt
    return seen

def closure_down(seeds, cap=6000):
    seen, stack = set(), list(seeds)
    while stack and len(seen) < cap:
        ea = stack.pop()
        if ea in seen: continue
        seen.add(ea)
        stack.extend(callees(ea))
    return seen

# -------------------------------------------------------------- data globals
# Every constant a function reads: walk its instructions, collect data xrefs
# into .rdata/.data, dump the target bytes and interpret as f32/f64/i32 arrays.
def data_refs(ea):
    f = ida_funcs.get_func(ea)
    if not f: return set()
    refs = set()
    for h in idautils.Heads(f.start_ea, f.end_ea):
        for xr in idautils.XrefsFrom(h, 0):
            if xr.type in (ida_xref.dr_R, ida_xref.dr_O, ida_xref.dr_W):
                s = ida_segment.getseg(xr.to)
                if s and ida_segment.get_segm_name(s) in (".rdata", ".data"):
                    refs.add(xr.to)
    return refs

def guess_len(ea):
    # extend to the next named item or defined item boundary, cap 64 KB
    nxt = idc.next_head(ea, ea + 0x10000)
    return max(4, min(0x10000, (nxt - ea) if nxt != idc.BADADDR else 0x400))

def dump_data(ea, fh):
    n = guess_len(ea); b = ida_bytes.get_bytes(ea, n) or b""
    nm = ida_name.get_name(ea) or ("dat_%X" % ea)
    seg = ida_segment.getseg(ea)
    fh.write("\n## %s @ 0x%X (RVA 0x%X) seg=%s len=%d\n" % (
        nm, ea, rva(ea), ida_segment.get_segm_name(seg) if seg else "?", len(b)))
    fh.write("raw: " + b[:256].hex() + ("..." if len(b) > 256 else "") + "\n")
    if len(b) >= 4 and len(b) % 4 == 0:
        f32 = struct.unpack("<%df" % (len(b) // 4), b)
        if all(abs(x) < 1e30 for x in f32):
            fh.write("f32: " + ", ".join("%.9g" % x for x in f32[:64]) +
                     ("..." if len(f32) > 64 else "") + "\n")
        i32 = struct.unpack("<%di" % (len(b) // 4), b)
        fh.write("i32: " + ", ".join(str(x) for x in i32[:64]) +
                 ("..." if len(i32) > 64 else "") + "\n")

# ------------------------------------------------------------------ dumpers
def dump_c(ea):
    p = os.path.join(OUT, "fn_%s_%X.c" % (safe(fname(ea)), ea))
    try:
        cf = ida_hexrays.decompile(ea)
        s = str(cf) if cf else "// decompile returned None\n"
    except Exception as e:
        s = "// DECOMPILE FAILED: %s\n" % e
    open(p, "w", encoding="utf-8").write(
        "// %s @ 0x%X (RVA 0x%X)\n\n%s\n" % (fname(ea), ea, rva(ea), s))

def dump_asm(ea, fh):
    f = ida_funcs.get_func(ea)
    if not f: return
    fh.write("\n; ==== %s @ 0x%X (RVA 0x%X) size=0x%X ====\n" % (
        fname(ea), ea, rva(ea), f.end_ea - f.start_ea))
    for h in idautils.Heads(f.start_ea, f.end_ea):
        raw = ida_bytes.get_bytes(h, idc.get_item_size(h)) or b""
        fh.write("%016X  %-24s  %s\n" % (
            h, " ".join("%02X" % x for x in raw), idc.GetDisasm(h)))

def proto(ea):
    t = idc.get_type(ea)
    return t if t else ""

# ------------------------------------------------------------------- phases
def main():
    log("ImageBase 0x%X  out=%s" % (IMAGE_BASE, OUT))

    # 1. RTTI: every DSP + control class vtable
    vts = find_vtables([CLASS_PREFIX, PLUGIN_HINT])
    log("phase 1: %d class vtables from RTTI" % len(vts))
    with open(os.path.join(OUT, "00_vtables.txt"), "w") as fh:
        for cls in sorted(vts):
            vft = vts[cls]
            fh.write("%-32s vft=0x%X (RVA 0x%X)\n" % (cls, vft, rva(vft)))
            for i in range(24):
                p = ida_bytes.get_qword(vft + 8 * i)
                f = ida_funcs.get_func(p)
                if not (f and f.start_ea == p): break
                fh.write("    [%2d] 0x%X (RVA 0x%X) %s\n" % (i, p, rva(p), fname(p)))

    # 2. seeds -> full downward closure of the audio+control code
    seeds = seeds_from_vtables(vts)
    log("phase 2: %d vtable-method seeds" % len(seeds))
    # add a few caller levels so the process/BUILD roots come in too
    roots = set()
    for s in list(seeds):
        roots |= callers(s, 3)
    clo = closure_down(seeds | roots)
    log("phase 2: call-closure = %d functions" % len(clo))

    # 2b. FUNCTION-POINTER-TABLE SWEEP -- the gap a call-graph misses and the
    # reason the JUNO needed repeat IDA visits. Effect/delay/reverb arms are
    # often dispatched through .rdata pointer tables, not vtables. Harvest every
    # qword in .rdata/.data that is the start of a function, add it, re-close.
    text = None
    for s in idautils.Segments():
        seg = ida_segment.getseg(s)
        if ida_segment.get_segm_name(seg) == ".text":
            text = (seg.start_ea, seg.end_ea)
    fptrs = set()
    for s in idautils.Segments():
        seg = ida_segment.getseg(s)
        if ida_segment.get_segm_name(seg) not in (".rdata", ".data"): continue
        ea = seg.start_ea
        while ea < seg.end_ea - 8:
            q = ida_bytes.get_qword(ea)
            if text and text[0] <= q < text[1]:
                f = ida_funcs.get_func(q)
                if f and f.start_ea == q:
                    fptrs.add(q)
            ea += 8
    new = fptrs - clo
    log("phase 2b: %d function pointers in data; %d new" % (len(fptrs), len(new)))
    clo = closure_down(clo | fptrs)
    log("phase 2: closure after fptr sweep = %d functions" % len(clo))

    # 3. decompile + disasm the whole closure; collect data refs
    log("phase 3: decompiling %d functions (the slow phase)..." % len(clo))
    all_data = set()
    asm = open(os.path.join(OUT, "01_closure.asm"), "w", encoding="utf-8")
    protos = open(os.path.join(OUT, "02_protos.txt"), "w", encoding="utf-8")
    manifest = []
    for i, ea in enumerate(sorted(clo)):
        dump_c(ea)
        dump_asm(ea, asm)
        protos.write("0x%X (RVA 0x%X)  %-40s  %s\n" % (ea, rva(ea), fname(ea), proto(ea)))
        all_data |= data_refs(ea)
        manifest.append({"ea": ea, "rva": rva(ea), "name": fname(ea)})
        if i % 200 == 0: log("   ...%d/%d" % (i, len(clo)))
    asm.close(); protos.close()

    # 4. every constant table the closure reads, with values
    log("phase 4: %d data globals" % len(all_data))
    with open(os.path.join(OUT, "03_constants.txt"), "w", encoding="utf-8") as fh:
        for ea in sorted(all_data):
            dump_data(ea, fh)

    # 5. the parameter registry: functions that reference the CPrm*Plugin
    #    vtable are the param-processor constructors / registrars (patch ->
    #    coefficient appliers). Dump their callers' closure too.
    log("phase 5: parameter/registry closure")
    prm = [v for c, v in vts.items() if c.startswith("CPrmDSP")]
    reg_seeds = set()
    for vft in prm:
        for xr in idautils.XrefsTo(vft, 0):
            g = ida_funcs.get_func(xr.frm)
            if g: reg_seeds.add(g.start_ea)
    reg_clo = closure_down(reg_seeds, cap=2000) - clo
    for ea in sorted(reg_clo):
        dump_c(ea)
        manifest.append({"ea": ea, "rva": rva(ea), "name": fname(ea), "kind": "registry"})
    log("phase 5: +%d registry functions" % len(reg_clo))

    # 6. segment map + state size hints + a machine-readable manifest
    log("phase 6: layout + manifest")
    with open(os.path.join(OUT, "04_segments.txt"), "w") as fh:
        for s in idautils.Segments():
            seg = ida_segment.getseg(s)
            fh.write("%-10s 0x%X..0x%X (RVA 0x%X, size 0x%X)\n" % (
                ida_segment.get_segm_name(seg), seg.start_ea, seg.end_ea,
                rva(seg.start_ea), seg.end_ea - seg.start_ea))
    json.dump({"image_base": IMAGE_BASE, "class_prefix": CLASS_PREFIX,
               "vtables": {c: rva(v) for c, v in vts.items()},
               "closure_count": len(clo), "registry_count": len(reg_clo),
               "functions": manifest},
              open(os.path.join(OUT, "manifest.json"), "w"), indent=1)

    log("=== DONE. Zip %s and send it. ===" % OUT)
    log("    %d decompiled functions, %d constant tables, %d classes." % (
        len(clo) + len(reg_clo), len(all_data), len(vts)))

main()
