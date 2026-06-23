#!/usr/bin/env python3
# extract_host_layer.py — locate & dump the HOST/PARAMETER layer that sits above
# the audio closure, so we can TRANSCRIBE (not capture) the two remaining pieces:
#   #1 the note/MIDI -> pitch+gate handler (so the port can play notes)
#   #2 the parameter -> coefficient appliers (so the port responds to any patch)
#
# Method = call-graph neighborhood of functions we ALREADY know (reliable, not the
# signature-guessing that wasted time before):
#   - walk UP from the audio worker / voice dispatch / voice-list lifecycle: their
#     callers are the process callback and the note-on / voice-allocation path (#1).
#   - walk UP from the parameter registrar / registry: their callers are the
#     parameter manager and the per-parameter setters (#2).
#   - plus a targeted scan for functions that write into the voice aux/gate region
#     (the note-on writes gate=1.0 there).
# For every function found: Hex-Rays decompile (.c) + disassembly (.asm).
#
# HOW TO RUN  (fresh analyzed DB; AU: idle)
#   File -> Script file... -> extract_host_layer.py
#   Output: ./host_layer/ next to the database. Zip and upload it.

import os, re
import ida_funcs, ida_hexrays, ida_name, idautils, idc, ida_bytes, ida_ua, ida_xref

IMAGE_BASE = 0x180000000
WORKER     = 0x1803C6F00     # audio process worker (calls dispatch + chorus)
DISPATCH   = 0x180398F30     # switch(voiceIndex) -> voice_render
LIFECYCLE  = [0x1803C24A0, 0x1803C2E00]  # active-voice list mgmt (alloc/prune)
REGISTRAR  = 0x1803ABA00     # param descriptor push_back
REGISTRY   = 0x180388170     # registers ~1121 params
# voice aux/gate region (voice 0 absolute; note-on writes gate=1.0 at 101504):
AUX_OFFS   = set(range(101440, 101620, 4))
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "host_layer")

def log(m): print("[host] " + m)
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)
def safe(s): return re.sub(r"[^A-Za-z0-9_.-]", "_", s)[:80]

_dumped = set()
def dump(ea, tag):
    if ea in _dumped: return
    _dumped.add(ea)
    f = ida_funcs.get_func(ea)
    if not f: return
    cpath = os.path.join(OUT, "%s_%s_%X.c" % (tag, safe(fname(ea)), ea))
    apath = os.path.join(OUT, "%s_%s_%X.asm" % (tag, safe(fname(ea)), ea))
    try:
        cf = ida_hexrays.decompile(ea); ps = str(cf) if cf else "// None\n"
    except Exception as e:
        ps = "// DECOMPILE FAILED: %s\n" % e
    try: open(cpath,"w",encoding="utf-8").write("// %s @ 0x%X (RVA 0x%X)\n\n"%(fname(ea),ea,ea-IMAGE_BASE)+ps+"\n")
    except Exception as e: log("c SKIP 0x%X (%s)"%(ea,e))
    try:
        with open(apath,"w",encoding="utf-8") as fh:
            fh.write("; %s @ 0x%X (RVA 0x%X)\n\n"%(fname(ea),ea,ea-IMAGE_BASE))
            for h in idautils.Heads(f.start_ea,f.end_ea):
                raw=ida_bytes.get_bytes(h,idc.get_item_size(h)) or b""
                fh.write("%016X  %-26s  %s\n"%(h," ".join("%02X"%b for b in raw),idc.GetDisasm(h)))
    except Exception as e: log("asm SKIP 0x%X (%s)"%(ea,e))
    log("dumped %s @ 0x%X (%s)" % (fname(ea), ea, tag))

def callers(ea):
    out=[]; x=ida_xref.get_first_cref_to(ea)
    while x!=idc.BADADDR:
        if idc.print_insn_mnem(x).startswith(("call","jmp")):
            cf=ida_funcs.get_func(x)
            if cf: out.append(cf.start_ea)
        x=ida_xref.get_next_cref_to(ea,x)
    return sorted(set(out))

def walk_up(ea, tag, levels):
    frontier=[ea]
    for lvl in range(levels):
        nxt=[]
        for fn in frontier:
            for c in callers(fn):
                if c not in _dumped:
                    dump(c, "%s_caller%d"%(tag,lvl+1)); nxt.append(c)
        frontier=nxt

def touches(ea, offs):
    f=ida_funcs.get_func(ea)
    if not f: return 0
    hit=set()
    for h in idautils.Heads(f.start_ea,f.end_ea):
        insn=ida_ua.insn_t()
        if not ida_ua.decode_insn(insn,h): continue
        for op in insn.ops:
            if op.type==ida_ua.o_displ and op.addr in offs: hit.add(op.addr)
    return len(hit)

def main():
    have=ida_hexrays.init_hexrays_plugin()
    os.makedirs(OUT, exist_ok=True)
    log("output: %s"%os.path.abspath(OUT))

    # ---- #1 note / voice-trigger path: anchors + their callers ----
    dump(WORKER,"audio_worker"); walk_up(WORKER,"worker",2)
    dump(DISPATCH,"dispatch");   walk_up(DISPATCH,"dispatch",2)
    for ea in LIFECYCLE: dump(ea,"lifecycle"); walk_up(ea,"lifecycle",2)
    log("scanning all functions for writers of the voice aux/gate region...")
    cand=[]
    for j,ea in enumerate(idautils.Functions()):
        if j and j%5000==0: log("  ...%d"%j)
        n=touches(ea,AUX_OFFS)
        if n: cand.append((ea,n))
    cand.sort(key=lambda kv:kv[1],reverse=True)
    with open(os.path.join(OUT,"note_path_candidates.md"),"w",encoding="utf-8") as idx:
        idx.write("# Functions touching the voice aux/gate region (note-on writes gate=1.0)\n\n| addr | RVA | hits |\n|--|--|--|\n")
        for ea,n in cand: idx.write("| 0x%X | 0x%X | %d |\n"%(ea,ea-IMAGE_BASE,n))
    for ea,n in cand[:12]: dump(ea,"notecand%d"%n)

    # ---- #2 parameter -> coefficient appliers: registrar/registry callers ----
    dump(REGISTRAR,"param_registrar"); walk_up(REGISTRAR,"registrar",2)
    dump(REGISTRY,"param_registry");   walk_up(REGISTRY,"registry",1)

    log("DONE (%d functions dumped). Zip host_layer/ and upload it."%len(_dumped))

if __name__=="__main__":
    main()
