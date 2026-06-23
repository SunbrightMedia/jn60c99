#!/usr/bin/env python3
# extract_tables.py — dump the .rdata LOOKUP TABLES the voice engine indexes.
# IDA Pro 9.3, x86-64. Pure data dump (no decompile). Instant. Final data need
# for the voice engine.
#
# WHY
#   voice_render indexes three .rdata tables that earlier scalar dumps did not
#   capture in full:
#     - dword_18098AD3C[]  exponent/ldexp scaling table (floats)
#     - dword_18098ACC0[]  exponent/ldexp scaling table (floats)
#     - unk_1809894E0      pitch spline: rows of 26 doubles, 208-byte stride
#   We need the real values to transcribe the pitch + exponent stages exactly.
#
# HOW TO RUN
#   GUI: File > Script file… > extract_tables.py   (on the analyzed database)
#   Output: ./tables_dump/tables.txt next to the database. Upload that one file.

import os, struct
import ida_bytes, idc

OUT = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "tables_dump")

def f32(ea):
    return struct.unpack("<f", struct.pack("<I", ida_bytes.get_dword(ea) & 0xFFFFFFFF))[0]

def f64(ea):
    return struct.unpack("<d", (ida_bytes.get_qword(ea) & 0xFFFFFFFFFFFFFFFF).to_bytes(8, "little"))[0]

def main():
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, "tables.txt")
    with open(path, "w", encoding="utf-8") as fh:
        # Exponent tables: dump a generous float window covering both bases and
        # their neighbours so the full extent and indexing are unambiguous.
        fh.write("=== FLOAT WINDOW 0x18098AC00 .. 0x18098AE00 (covers ACC0 & AD3C) ===\n")
        ea = 0x18098AC00
        while ea < 0x18098AE00:
            fh.write("0x%X [idx %+4d from ACC0, %+4d from AD3C]  %r\n"
                     % (ea, (ea - 0x18098ACC0)//4, (ea - 0x18098AD3C)//4, f32(ea)))
            ea += 4

        # Pitch spline table: 29 rows (index 0..28), 26 doubles each, 208B stride.
        fh.write("\n=== DOUBLE TABLE unk_1809894E0: 29 rows x 26 doubles (208B stride) ===\n")
        base = 0x1809894E0
        for row in range(29):
            row_ea = base + 208 * row
            vals = [f64(row_ea + 8 * c) for c in range(26)]
            fh.write("row %2d @ 0x%X:\n" % (row, row_ea))
            for c in range(26):
                fh.write("  [%2d] %r\n" % (c, vals[c]))
    print("[extract_tables] wrote %s" % os.path.abspath(path))
    print("[extract_tables] DONE. Upload tables_dump/tables.txt")

if __name__ == "__main__":
    main()
