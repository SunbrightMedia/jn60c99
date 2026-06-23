#!/usr/bin/env python3
# extract_asm.py — disassembly of the voice render + its leaf helpers, so the
# XMM register arguments Hex-Rays dropped on the waveshaper/phase-wrap calls can
# be recovered. IDA Pro 9.3 (SP2), x86-64. Companion to extract_dsp.py.
#
# WHY
#   In voice_render (0x180369070) the decompiler shows the triangle helper
#   (0x180368FC0) and the wrap24 helper (0x180368D60) as no-argument calls — it
#   lost the XMM register holding the phase. The argument is only visible in the
#   assembly. This dumps that assembly (small, fast, fully static).
#
# WHAT IT DOES
#   For each seed function, emits a .asm with: address, raw bytes, and the full
#   disassembled instruction (mnemonic + operands + IDA's auto comments). That is
#   enough to trace which xmm reg feeds each `call` to the helpers.
#
# HOW TO RUN
#   GUI:  File > Script file… > extract_asm.py   (on the analyzed database)
#   Output goes to ./asm_dump/ next to the database. Zip it and upload.

import os
import ida_funcs, ida_name, idautils, idc, ida_bytes

IMAGE_BASE = 0x180000000
SEED_EAS = [
    0x180369070,   # voice_render (one copy suffices; all 8 are identical)
    0x180368FC0,   # juno_triangle helper
    0x180368D60,   # juno_wrap24 helper
]
OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "asm_dump")

def log(m): print("[extract_asm] " + m)

def fname(ea):
    n = ida_name.get_name(ea)
    return n if n else ("sub_%X" % ea)

def dump(ea):
    f = ida_funcs.get_func(ea)
    if not f:
        log("  no function at 0x%X" % ea); return
    nm = fname(f.start_ea)
    path = os.path.join(OUT, "%s_%X.asm" % (nm, f.start_ea))
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("; %s  @ 0x%X  (RVA 0x%X)\n" % (nm, f.start_ea, f.start_ea - IMAGE_BASE))
        fh.write("; prototype: %s\n\n" % (idc.get_type(f.start_ea) or ""))
        for head in idautils.Heads(f.start_ea, f.end_ea):
            raw = ida_bytes.get_bytes(head, idc.get_item_size(head)) or b""
            hexb = " ".join("%02X" % b for b in raw)
            dis  = idc.GetDisasm(head)
            fh.write("%016X  %-30s  %s\n" % (head, hexb, dis))
    log("  wrote %s" % os.path.abspath(path))

def main():
    os.makedirs(OUT, exist_ok=True)
    log("output folder: %s" % os.path.abspath(OUT))
    for ea in SEED_EAS:
        dump(ea)
    log("DONE. Zip the asm_dump folder and upload it.")

if __name__ == "__main__":
    main()
