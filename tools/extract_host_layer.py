#!/usr/bin/env python3
# extract_host_layer.py — locate & dump the HOST/PARAMETER layer above the audio
# closure, to TRANSCRIBE (from original code, not captures):
#   #1 the note/MIDI -> pitch+gate handler (so the port can play notes)
#   #2 the parameter -> coefficient appliers (so the port honours any patch)
#
# REBASE-SAFE: anchors are addressed by RVA + the database's CURRENT imagebase, so
# it works whether or not the DB was rebased by a past debug session.
# It walks the call graph BOTH WAYS from known anchors (audio worker, voice
# dispatch, voice-list lifecycle, param registrar/registry): callees reach the
# event/note handling the worker performs; callers reach the process callback and
# the voice-allocation / parameter-manager paths. Plus a scan for voice-gate
# writers. Output: Hex-Rays .c + .asm per function.
#
# RUN: File -> Script file... -> extract_host_layer.py ; zip+upload host_layer/.

import os, re
import ida_funcs, ida_hexrays, ida_name, idautils, idc, ida_bytes, ida_ua, ida_xref, ida_nalt

BASE = ida_nalt.get_imagebase()          # current imagebase (handles rebasing)
def A(rva): return BASE + rva
WORKER_RVA   = 0x3C6F00
DISPATCH_RVA = 0x398F30
LIFE_RVAS    = [0x3C24A0, 0x3C2E00]
REGISTRAR_RVA= 0x3ABA00
REGISTRY_RVA = 0x388170
AUX_OFFS     = set(range(101440, 101620, 4))   # voice gate region (note-on=1.0)
MAX_DUMPS    = 140
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "host_layer")

def log(m): print("[host] " + m)
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)
def safe(s): return re.sub(r"[^A-Za-z0-9_.-]", "_", s)[:80]
def is_noise(ea):
    nm = fname(ea).lower()
    return nm.startswith(("j_", "nullsub", "operator")) or "std" in nm \
           or "_xlen" in nm or "throw" in nm or "_cxx" in nm or "_scrt" in nm

_dumped = set()
def dump(ea, tag):
    if ea in _dumped or len(_dumped) >= MAX_DUMPS: return
    f = ida_funcs.get_func(ea)
    if not f: return
    _dumped.add(ea)
    rva = ea - BASE
    try:
        cf = ida_hexrays.decompile(ea); ps = str(cf) if cf else "// None\n"
    except Exception as e: ps = "// DECOMPILE FAILED: %s\n" % e
    try: open(os.path.join(OUT,"%s_%s_%X.c"%(tag,safe(fname(ea)),rva)),"w",encoding="utf-8")\
            .write("// %s @ rva 0x%X\n\n"%(fname(ea),rva)+ps+"\n")
    except Exception as e: log("c SKIP (%s)"%e)
    try:
        with open(os.path.join(OUT,"%s_%s_%X.asm"%(tag,safe(fname(ea)),rva)),"w",encoding="utf-8") as fh:
            fh.write("; %s @ rva 0x%X\n\n"%(fname(ea),rva))
            for h in idautils.Heads(f.start_ea,f.end_ea):
                raw=ida_bytes.get_bytes(h,idc.get_item_size(h)) or b""
                fh.write("%016X  %-26s  %s\n"%(h," ".join("%02X"%b for b in raw),idc.GetDisasm(h)))
    except Exception as e: log("asm SKIP (%s)"%e)
    log("dumped %s @ rva 0x%X (%s)"%(fname(ea),rva,tag))

def callers(ea):
    out=set(); x=ida_xref.get_first_cref_to(ea)
    while x!=idc.BADADDR:
        if idc.print_insn_mnem(x).startswith(("call","jmp")):
            cf=ida_funcs.get_func(x)
            if cf: out.add(cf.start_ea)
        x=ida_xref.get_next_cref_to(ea,x)
    return out

def callees(ea):
    out=set(); f=ida_funcs.get_func(ea)
    if not f: return out
    for h in idautils.Heads(f.start_ea,f.end_ea):
        if idc.print_insn_mnem(h)=="call":
            t=idc.get_operand_value(h,0)
            if t and ida_funcs.get_func(t): out.add(t)
    return out

def walk(start, tag, levels, up=True, down=False):
    frontier=[start]
    for lvl in range(levels):
        nxt=[]
        for fn in frontier:
            nb=set()
            if up:   nb|=callers(fn)
            if down: nb|=callees(fn)
            for c in nb:
                if c not in _dumped and not is_noise(c):
                    dump(c,"%s_L%d"%(tag,lvl+1)); nxt.append(c)
        frontier=nxt

def touches(ea,offs):
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
    ida_hexrays.init_hexrays_plugin()
    os.makedirs(OUT,exist_ok=True)
    log("imagebase = 0x%X  (master should be 0x%X)"%(BASE,A(0x363380)))
    if not ida_funcs.get_func(A(WORKER_RVA)):
        log("WARN: no function at worker RVA — analysis/imagebase issue."); 
    # #1 note/event path: worker (callers+callees), dispatch (callers), lifecycle (callers)
    dump(A(WORKER_RVA),"worker");  walk(A(WORKER_RVA),"worker_up",2,up=True);  walk(A(WORKER_RVA),"worker_dn",2,up=False,down=True)
    dump(A(DISPATCH_RVA),"dispatch"); walk(A(DISPATCH_RVA),"dispatch_up",2,up=True)
    for r in LIFE_RVAS: dump(A(r),"lifecycle"); walk(A(r),"life_up",2,up=True)
    # #2 param appliers: registrar/registry callers (+ registrar callees: the apply/curve fns)
    dump(A(REGISTRAR_RVA),"registrar"); walk(A(REGISTRAR_RVA),"reg_up",2,up=True); walk(A(REGISTRAR_RVA),"reg_dn",1,up=False,down=True)
    dump(A(REGISTRY_RVA),"registry");   walk(A(REGISTRY_RVA),"regy_up",1,up=True)
    # targeted gate-writer scan
    log("scanning all functions for voice-gate writers...")
    cand=[]
    for j,ea in enumerate(idautils.Functions()):
        if j and j%5000==0: log("  ...%d"%j)
        n=touches(ea,AUX_OFFS)
        if n>=1: cand.append((ea,n))
    cand.sort(key=lambda kv:kv[1],reverse=True)
    with open(os.path.join(OUT,"note_path_candidates.md"),"w",encoding="utf-8") as idx:
        idx.write("# Functions touching the voice gate region\n\n| rva | hits |\n|--|--|\n")
        for ea,n in cand: idx.write("| 0x%X | %d |\n"%(ea-BASE,n))
    for ea,n in cand[:10]: dump(ea,"gatecand%d"%n)
    log("DONE: %d functions dumped. Zip host_layer/ and upload."%len(_dumped))

if __name__=="__main__":
    main()
