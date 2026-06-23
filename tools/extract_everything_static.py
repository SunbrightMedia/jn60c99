#!/usr/bin/env python3
# extract_everything_static.py — ONE comprehensive STATIC dump (no debugger, fully
# safe, read-only). Gets every remaining static artifact for a complete port so we
# never have to come back to IDA for static data:
#   - all 8 per-voice render functions (for polyphony / dropped-arg resolution)
#   - the voice dispatch + lifecycle (host glue around the renders)
#   - the note/MIDI path: functions that touch the voice-trigger fields (gate, etc.)
# For each: Hex-Rays decompile (.c) + disassembly (.asm) + the constants it reads.
#
# HOW TO RUN  (on a freshly re-analyzed database; AU: idle)
#   File -> Script file... -> extract_everything_static.py
#   Output: ./everything_static/ next to the database. Zip and upload it.

import os, struct
import ida_funcs, ida_hexrays, ida_name, idautils, idc, ida_bytes, ida_ua

IMAGE_BASE = 0x180000000
VOICES = [0x180369070, 0x18036CE00, 0x180370B90, 0x180374900,
          0x180378690, 0x18037C420, 0x180380190, 0x180383F20]   # 8 voice renders
GLUE   = [0x180398F30,                # voice dispatch (switch on voiceIndex)
          0x1803C24A0, 0x1803C2E00]   # voice lifecycle (prune / is-active)
# voice-trigger fields the note/MIDI handler writes (voice 0 absolute offsets):
#   101504 = note-on gate (==1.0).  The handler that writes these is the MIDI path.
TRIGGER_OFFS = {101504, 101472, 101440, 101536}
KNOWN = set(VOICES) | set(GLUE) | {0x180363380, 0x1803990C0, 0x1803A1300, 0x180388170}
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "everything_static")

def log(m): print("[static] " + m)
def fname(ea): return ida_name.get_name(ea) or ("sub_%X" % ea)
def safe(s):
    import re; return re.sub(r"[^A-Za-z0-9_.-]", "_", s)[:80]

def dump_c(ea, tag):
    p = os.path.join(OUT, "%s_%s_%X.c" % (tag, safe(fname(ea)), ea))
    try:
        cf = ida_hexrays.decompile(ea); s = str(cf) if cf else "// decompile returned None\n"
    except Exception as e:
        s = "// DECOMPILE FAILED: %s\n" % e
    try:
        open(p, "w", encoding="utf-8").write("// %s @ 0x%X (RVA 0x%X)\n\n" % (fname(ea), ea, ea-IMAGE_BASE) + s + "\n")
        log("c   -> %s" % os.path.basename(p))
    except Exception as e: log("c   SKIP 0x%X (%s)" % (ea, e))

def dump_asm(ea, tag):
    f = ida_funcs.get_func(ea)
    if not f: log("no func @ 0x%X" % ea); return
    p = os.path.join(OUT, "%s_%s_%X.asm" % (tag, safe(fname(ea)), ea))
    try:
        with open(p, "w", encoding="utf-8") as fh:
            fh.write("; %s @ 0x%X (RVA 0x%X) size=0x%X\n\n" % (fname(ea), ea, ea-IMAGE_BASE, f.end_ea-f.start_ea))
            for h in idautils.Heads(f.start_ea, f.end_ea):
                raw = ida_bytes.get_bytes(h, idc.get_item_size(h)) or b""
                fh.write("%016X  %-26s  %s\n" % (h, " ".join("%02X"%b for b in raw), idc.GetDisasm(h)))
        log("asm -> %s" % os.path.basename(p))
    except Exception as e: log("asm SKIP 0x%X (%s)" % (ea, e))

def touches(ea, offs):
    f = ida_funcs.get_func(ea)
    if not f: return 0
    hit = set()
    for h in idautils.Heads(f.start_ea, f.end_ea):
        insn = ida_ua.insn_t()
        if not ida_ua.decode_insn(insn, h): continue
        for op in insn.ops:
            if op.type == ida_ua.o_displ and op.addr in offs: hit.add(op.addr)
    return len(hit)

def main():
    have = ida_hexrays.init_hexrays_plugin()
    os.makedirs(OUT, exist_ok=True)
    log("output: %s" % os.path.abspath(OUT))

    for i, ea in enumerate(VOICES):
        if have: dump_c(ea, "voice%d" % i)
        dump_asm(ea, "voice%d" % i)
    for ea in GLUE:
        if have: dump_c(ea, "glue")
        dump_asm(ea, "glue")
    log("dumped 8 voices + glue")

    log("scanning all functions for the note/MIDI voice-trigger path...")
    cands = []
    for j, ea in enumerate(idautils.Functions()):
        if j and j % 5000 == 0: log("  ...%d" % j)
        n = touches(ea, TRIGGER_OFFS)
        if n: cands.append((ea, n))
    cands.sort(key=lambda kv: kv[1], reverse=True)
    with open(os.path.join(OUT, "note_path_ranking.md"), "w", encoding="utf-8") as idx:
        idx.write("# Functions touching the voice-trigger fields (gate 101504, etc.)\n\n")
        idx.write("| addr | RVA | hits | known? |\n|--|--|--|--|\n")
        for ea, n in cands:
            idx.write("| 0x%X | 0x%X | %d | %s |\n" % (ea, ea-IMAGE_BASE, n, "Y" if ea in KNOWN else ""))
    dumped = 0
    for ea, n in cands:
        if ea in KNOWN or dumped >= 10: continue
        if have: dump_c(ea, "notepath%d" % n)
        dump_asm(ea, "notepath%d" % n); dumped += 1
    log("note-path: ranked %d, dumped top %d candidates" % (len(cands), dumped))
    log("DONE. Zip the everything_static folder and upload it.")

if __name__ == "__main__":
    main()
