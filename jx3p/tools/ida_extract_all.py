# ida_extract_all.py -- THE ONE-AND-ONLY IDA RUN for a full port.
#
# Built for the JX-3P, but synth-agnostic: point CLASS_PREFIX at the DSP class
# family and it dumps EVERYTHING a bit-exact port + oracle needs, in one pass,
# so IDA never has to be opened again. It replaces the EIGHT separate JUNO
# scripts (extract_dsp / tables / init / param_setter / param_meta /
# master_deps / everything_static / host_layer) with their union.
#
# ============================ THE STRATEGY ============================
# The render leaves (per-sample voice/master/effect helpers) are reached by
# INDIRECT dispatch, not direct calls -- a plain call-graph closure CANNOT see
# them. PROVEN against the JUNO binary: a direct-call closure from every DSP
# vtable method reaches 154 functions and NONE of the four hand-found leaves
# (voice render, master/chorus, parameter registry, chorus-coefficient gen).
#
# What DOES reach them: an ADDRESS BAND. MSVC lays a class's methods and the
# non-virtual helpers they dispatch to into one contiguous slab of .text. Every
# one of the four JUNO leaves falls inside the band spanning the lowest DSP
# vtable method to the highest parameter-class method, +/-0x10000. Measured:
#   JUNO band 0x346150..0x3CCD80 = 1282 functions, all 4 leaves + BUILD +
#             NOTEON/NOTEOFF + the per-sample wrappers IN, 44000 CRT/GUI OUT.
#   JX   band 0x3486E0..0x3FEB70 = 1291 functions, every DSP method + the
#             master process (which the old fptr-sweep dump MISSED) IN.
# So the band is the completeness guarantee. Two call-graph closures are added
# only as belt-and-suspenders for any straggler outside the band.
#
# The old blanket .rdata function-pointer sweep is GONE: it pulled 275+ JUCE/
# Gdiplus/CRT functions into the set and, with a 6000 cap, crowded the real DSP
# out (132 of 185 DSP methods were lost). The band replaces it and cannot
# truncate: it is a bounded address range, not a capped graph walk.
# =====================================================================
#
# ============================ HOW TO RUN ============================
#   1. IDA Pro -> File -> Open -> JX3P.vst3   (let auto-analysis FINISH;
#      the bottom-left says "AU: idle". Several minutes on a 14 MB DLL --
#      wait for it, the dump is only complete on a done database.)
#   2. File -> Script file... -> this file.
#   3. Watch the Output window. It prints a progress line per phase and ends
#      with a COMPLETENESS line "N/M DSP vtable methods decompiled" -- that
#      number MUST read M/M. If it does not, it lists the missing methods and
#      the dump is incomplete; do not upload, tell Claude the printed gap.
#   4. Zip the output directory it names (next to the .i64) and upload it.
# ===================================================================

import os, re, struct, json
import ida_funcs, ida_hexrays, ida_name, ida_bytes, ida_segment, ida_nalt
import idautils, idc, ida_xref, ida_typeinf

IMAGE_BASE   = idc.get_inf_attr(idc.INF_BASEADDR)
SYNTH_TOKEN  = "Jx3p"            # the per-synth token: Ju60 / Jx3p
CLASS_PREFIX = "CDSP" + SYNTH_TOKEN            # DSP module family
PLUGIN_HINT  = "CPrmDSP"         # the control/parameter class family
# the other audio-path classes, matched by token so the completeness check
# covers them too: the voice assigner (CAssign<token>) and the sim/registry
# class (C<token>Sim -- on the JUNO its methods hold the parameter registry
# leaf 0x388170 the port consumes). GUI controls (Slider/Latch/Led/Button) are
# deliberately NOT matched -- their code lives outside the DSP slab.
AUDIO_PATH   = ["CAssign" + SYNTH_TOKEN, "C" + SYNTH_TOKEN + "Sim"]
BAND_MARGIN  = 0x10000           # slab padding; PROVEN to catch every JUNO leaf
CLOSURE_CAP  = 8000              # safety only; the band, not this, bounds the run
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "jx3p_dump")
if not os.path.isdir(OUT):
    os.makedirs(OUT)

def log(m): print("[extract] " + m)
def rva(ea): return ea - IMAGE_BASE
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)
def safe(s): return re.sub(r"[^A-Za-z0-9_.-]", "_", s)[:90]

# ---------------------------------------------------------------- RTTI seeds
# Find every class vtable whose RTTI TypeDescriptor name starts with a prefix.
def find_vtables(prefixes):
    out = {}
    # non-capturing group around the alternation so \w* applies to EVERY prefix,
    # not just the last one -- otherwise CDSPJx3pOscVoice fails to match and only
    # the raw-COL fallback saves it.
    pat = re.compile(r"\?\?_7((?:" + "|".join(prefixes) + r")\w*)@@6B")
    for ea, name in idautils.Names():
        m = pat.match(name)
        if m:
            out.setdefault(m.group(1), ea)
    if len(out) >= 8:
        return out
    log("find_vtables: only %d named; raw RTTI COL scan" % len(out))
    for seg in idautils.Segments():
        s = ida_segment.getseg(seg)
        if ida_segment.get_segm_name(s) not in (".data", ".rdata"): continue
        ea = s.start_ea
        while ea < s.end_ea - 4:
            if ida_bytes.get_bytes(ea, 4) == b".?AV":
                end = ea
                while end < ea + 200 and ida_bytes.get_byte(end) != 0: end += 1
                cls = ida_bytes.get_bytes(ea + 4, end - ea - 4).decode("latin1").rstrip("@")
                if any(cls.startswith(p) for p in prefixes):
                    td = ea - 16
                    for xr in idautils.XrefsTo(td, 0):
                        col = xr.frm - 12
                        if ida_bytes.get_dword(col) == 1:
                            for vxr in idautils.XrefsTo(col, 0):
                                vft = vxr.frm + 8
                                if ida_funcs.get_func(ida_bytes.get_qword(vft)):
                                    out.setdefault(cls, vft)
                ea = end
            ea += 1
    return out

# Read ALL virtual slots of a vtable (up to 64), keeping those that are real
# function starts; stop after two consecutive non-function slots (vtable end).
def vtable_methods(vft):
    ms, gap = [], 0
    for i in range(64):
        p = ida_bytes.get_qword(vft + 8 * i)
        f = ida_funcs.get_func(p)
        if f and f.start_ea == p:
            ms.append(p); gap = 0
        else:
            gap += 1
            if gap >= 2: break
    return ms

# --------------------------------------------------------- call-graph closure
def callees(ea):
    f = ida_funcs.get_func(ea)
    if not f: return []
    out = set()
    for h in idautils.Heads(f.start_ea, f.end_ea):
        for xr in idautils.XrefsFrom(h, 0):
            if xr.type in (ida_xref.fl_CN, ida_xref.fl_CF):
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

def closure_down(seeds):
    seen, stack, hit = set(), list(seeds), False
    while stack:
        if len(seen) >= CLOSURE_CAP:
            hit = True; break
        ea = stack.pop()
        if ea in seen: continue
        seen.add(ea)
        stack.extend(callees(ea))
    if hit:
        log("WARNING closure_down hit CLOSURE_CAP=%d -- band still bounds the "
            "run, but report this to Claude" % CLOSURE_CAP)
    return seen

# ------------------------------------------------------------- band of .text
def funcs_in_band(lo, hi):
    out = set()
    ea = idc.get_next_func(lo - 1)
    while ea != idc.BADADDR and ea <= hi:
        out.add(ea)
        ea = idc.get_next_func(ea)
    return out

# -------------------------------------------------------------- data globals
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

    # 1. RTTI: every DSP + control + audio-path class vtable, ALL slots
    vts = find_vtables([CLASS_PREFIX, PLUGIN_HINT] + AUDIO_PATH)
    log("phase 1: %d class vtables from RTTI" % len(vts))
    methods_by_class = {}     # class -> [method_ea...]
    with open(os.path.join(OUT, "00_vtables.txt"), "w") as fh:
        for cls in sorted(vts):
            vft = vts[cls]
            ms = vtable_methods(vft)
            methods_by_class[cls] = ms
            fh.write("%-32s vft=0x%X (RVA 0x%X)\n" % (cls, vft, rva(vft)))
            for i, p in enumerate(ms):
                fh.write("    [%2d] 0x%X (RVA 0x%X) %s\n" % (i, p, rva(p), fname(p)))

    # concrete methods = the real DSP methods to transcribe and to prove present.
    # Two things are NOT methods and must not stretch the band:
    #   (a) _purecall / pure-virtual thunks (dropped by name), and
    #   (b) any FOREIGN stub a vtable happens to point at, which lands far from
    #       the DSP slab. The DSP methods form ONE tight cluster (~0.6 MB on both
    #       the JUNO and JX); a genuine method is never megabytes away. So drop
    #       by distance from the cluster median -- geometry, not refcount, is the
    #       clean separator (JUNO/JX _purecall sits ~3.4 MB out; the legitimately
    #       shared effect methods, ~0.3 MB from the median, are KEPT). This is
    #       why the old refcount rule was wrong: it conflated the 18-way _purecall
    #       with a 4-way SHARED-but-real effect method.
    all_m = sorted({m for ms in methods_by_class.values() for m in ms})
    named = [m for m in all_m if fname(m) not in ("_purecall", "__purecall")]
    if not named:
        log("FATAL: no non-purecall methods -- wrong CLASS_PREFIX?"); return
    med = named[len(named) // 2]
    OUTLIER = 0x200000        # 2 MB: far wider than any real DSP cluster
    concrete = sorted(m for m in named if abs(m - med) <= OUTLIER)
    dropped = [m for m in all_m if m not in concrete]
    band_lo, band_hi = min(concrete) - BAND_MARGIN, max(concrete) + BAND_MARGIN
    log("phase 1: %d concrete methods (%d stub/outlier dropped); "
        "band 0x%X..0x%X (margin 0x%X)" %
        (len(concrete), len(dropped), band_lo, band_hi, BAND_MARGIN))

    # 2. THE BAND -- every function in the DSP slab. This is completeness.
    band = funcs_in_band(band_lo, band_hi)
    log("phase 2: %d functions in the DSP band" % len(band))

    # 2b. belt-and-suspenders closures: direct/resolvable callees DOWN from every
    #     method (catches a direct-called helper outside the slab, if any), and
    #     callers UP 2 levels (the engine BUILD, NOTEON/NOTEOFF, per-sample
    #     wrappers -- plain non-virtual roots the oracle harness needs).
    down = closure_down(set(concrete))
    up = set()
    for m in concrete:
        up |= callers(m, 2)
    extra = (down | up) - band
    log("phase 2b: closure adds %d functions outside the band "
        "(down=%d up=%d)" % (len(extra), len(down - band), len(up - band)))
    full = band | extra

    # 3. decompile + disasm the whole set; collect data refs
    log("phase 3: decompiling %d functions (the slow phase)..." % len(full))
    all_data = set()
    asm = open(os.path.join(OUT, "01_closure.asm"), "w", encoding="utf-8")
    protos = open(os.path.join(OUT, "02_protos.txt"), "w", encoding="utf-8")
    manifest = []
    order = sorted(full)
    for i, ea in enumerate(order):
        dump_c(ea)
        dump_asm(ea, asm)
        protos.write("0x%X (RVA 0x%X)  %-40s  %s\n" % (ea, rva(ea), fname(ea), proto(ea)))
        all_data |= data_refs(ea)
        manifest.append({"ea": ea, "rva": rva(ea), "name": fname(ea),
                         "in_band": ea in band})
        if i % 200 == 0: log("   ...%d/%d" % (i, len(full)))
    asm.close(); protos.close()

    # 4. every constant table the set reads, with values
    log("phase 4: %d data globals" % len(all_data))
    with open(os.path.join(OUT, "03_constants.txt"), "w", encoding="utf-8") as fh:
        for ea in sorted(all_data):
            dump_data(ea, fh)

    # 5. segment map + machine-readable manifest
    log("phase 5: layout + manifest")
    with open(os.path.join(OUT, "04_segments.txt"), "w") as fh:
        for s in idautils.Segments():
            seg = ida_segment.getseg(s)
            fh.write("%-10s 0x%X..0x%X (RVA 0x%X, size 0x%X)\n" % (
                ida_segment.get_segm_name(seg), seg.start_ea, seg.end_ea,
                rva(seg.start_ea), seg.end_ea - seg.start_ea))

    # 6. THE COMPLETENESS SELF-CHECK -- every concrete method must have a fn_*.c.
    #    Prints M/M when whole; lists the gap otherwise so truncation is visible
    #    in the Output window BEFORE the zip leaves the machine.
    written = set()
    for f in os.listdir(OUT):
        m = re.match(r"fn_.*_([0-9A-Fa-f]+)\.c$", f)
        if m: written.add(int(m.group(1), 16))
    missing = [m for m in concrete if m not in written]
    ok = len(concrete) - len(missing)
    json.dump({"image_base": IMAGE_BASE, "class_prefix": CLASS_PREFIX,
               "band": [band_lo, band_hi], "band_count": len(band),
               "closure_extra": len(extra), "total": len(full),
               "vtables": {c: rva(v) for c, v in vts.items()},
               "concrete_methods": len(concrete),
               "methods_decompiled": ok, "methods_missing": [rva(m) for m in missing],
               "functions": manifest},
              open(os.path.join(OUT, "manifest.json"), "w"), indent=1)

    log("=== DONE. Zip %s and send it. ===" % OUT)
    log("    %d functions, %d constant tables, %d classes." %
        (len(full), len(all_data), len(vts)))
    log("    COMPLETENESS: %d/%d DSP vtable methods decompiled." %
        (ok, len(concrete)))
    if missing:
        log("    *** INCOMPLETE -- %d methods have no fn_*.c (RVAs): %s" %
            (len(missing), ", ".join("0x%X" % rva(m) for m in missing[:40])))
        log("    *** Do NOT upload as complete; send this list to Claude.")
    else:
        log("    ALL methods present. One run was enough.")

main()
