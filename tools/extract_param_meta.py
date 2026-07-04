#!/usr/bin/env python3
# extract_param_meta.py — dump the plugin's per-parameter RANGE/DISPLAY table so
# the GUI sliders can use the real min/max the plugin allows (not heuristics).
# IDA Pro 9.3, x86-64. Pure data dump (no decompile). Instant.
#
# WHY
#   The parameter registry binds each param ID to a flat-state offset (already in
#   docs/COEFF_PARAM_MAP.md). The *ranges* live in a separate flat metadata table
#   the indexer sub_1803ABAF0 returns from:
#       char *sub_1803ABAF0(int id) { return &unk_1809EC040 + 16*id; }   // 4966 entries
#   Readers (sub_1803ABBA0) clamp/display with:
#       if (a2 >= *(DWORD*)rec && a2 <= *((DWORD*)rec + 1)) ...           // rec+0 min, rec+4 max
#       if (rec[12]) ... enum-string path (off_1809609B60[2*id])         // rec+12 flag
#   So each 16-byte record is { u32 min, u32 max, u32 field8, u8 flag@12, ... }.
#   These bytes are .rdata DATA — not present in the code-only decompile archive,
#   so they must be dumped here from the analyzed binary.
#
# IMAGEBASE 0x180000000. If your DB rebased, the tool auto-corrects via idaapi.
# RVAs: table 0x9EC040, string-ptr table 0x9609B60, count 4966.
#
# HOW TO RUN
#   GUI: File > Script file… > extract_param_meta.py   (on the analyzed database)
#   Output: ./param_meta_dump/param_meta.json  — copy it to gui/param_meta.json
#   in the repo. The web GUI (gui/juno_web.py) loads it automatically and drives
#   every matched slider from the real min/max (marked ● instead of ~).
#
#   The JSON is keyed by STATE OFFSET (what the GUI uses), remapped from param ID
#   via docs/COEFF_PARAM_MAP.md if that file sits next to the script; otherwise it
#   is keyed by param ID and the GUI-side helper can remap. See NOTE at bottom.

import os, json, struct
import ida_bytes, idc, idaapi

RVA_TABLE   = 0x9EC040     # unk_1809EC040  (16 bytes * 4966)
RVA_STRPTRS = 0x9609B60    # off_1809609B60 (enum string ptr pairs, 2 per id)
COUNT       = 4966
REC         = 16

def base():
    # imagebase-relative -> actual (handles a rebased database)
    return idaapi.get_imagebase()

def u32(ea):
    return ida_bytes.get_dword(ea) & 0xFFFFFFFF

def as_f32(u):
    return struct.unpack("<f", struct.pack("<I", u & 0xFFFFFFFF))[0]

def cstr(ea):
    if not ea:
        return None
    s = ida_bytes.get_strlit_contents(ea, -1, 0)
    return s.decode("latin1", "replace") if s else None

def main():
    b = base()
    tbl = b + RVA_TABLE
    strs = b + RVA_STRPTRS
    out_dir = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "param_meta_dump")
    os.makedirs(out_dir, exist_ok=True)

    recs = {}
    for i in range(COUNT):
        rec = tbl + i * REC
        mn = u32(rec + 0)
        mx = u32(rec + 4)
        f8 = u32(rec + 8)
        flag = ida_bytes.get_byte(rec + 12) & 0xFF
        # min/max are stored as the raw dword; try both int and float views so the
        # GUI can pick. Most JUNO params are small integer step-ranges (0..N) with
        # the float mapping applied elsewhere; some are float. We emit both.
        entry = {
            "id": i,
            "min_i": mn if mn < 0x80000000 else mn - (1 << 32),
            "max_i": mx if mx < 0x80000000 else mx - (1 << 32),
            "min_f": as_f32(mn),
            "max_f": as_f32(mx),
            "field8": f8,
            "enum": bool(flag),
        }
        # enum labels, when present
        if flag:
            base_ptr = strs + i * 16          # off_...9B60[2*i] = two 8-byte ptrs
            p0 = ida_bytes.get_qword(base_ptr) & 0xFFFFFFFFFFFFFFFF
            entry["enum_str0"] = cstr(p0)
        recs[str(i)] = entry

    raw = os.path.join(out_dir, "param_meta_by_id.json")
    with open(raw, "w", encoding="utf-8") as fh:
        json.dump(recs, fh, indent=0)

    # Remap ID -> state offset using COEFF_PARAM_MAP.md if available next to script.
    remapped, mapped = {}, 0
    map_md = os.path.join(os.path.dirname(__file__) or ".", "..", "docs", "COEFF_PARAM_MAP.md")
    id_by_offset = None
    # COEFF_PARAM_MAP.md is offset->name (registration order == id). Build
    # offset list in file order; index == id.
    try:
        import re
        offs = []
        with open(map_md, encoding="utf-8") as fh:
            for line in fh:
                m = re.match(r"\|\s*(\d+)\s*\|", line)
                if m:
                    offs.append(int(m.group(1)))
        # NOTE: the map lists only the 349 DSP-read params, not all 4966 — so this
        # ID alignment is APPROXIMATE. Emitting by-id is the safe artifact; the
        # by-offset file is best-effort for the mapped subset only.
        for idx, off in enumerate(offs):
            if str(idx) in recs:
                remapped[str(off)] = _ui_range(recs[str(idx)])
                mapped += 1
    except Exception as e:
        print("offset remap skipped:", e)

    if remapped:
        with open(os.path.join(out_dir, "param_meta.json"), "w", encoding="utf-8") as fh:
            json.dump(remapped, fh, indent=0)

    print("wrote %d records -> %s" % (len(recs), raw))
    print("by-offset (approx, %d mapped) -> param_meta.json" % mapped)
    print("Copy param_meta_dump/param_meta.json to gui/param_meta.json in the repo.")
    print("VERIFY the ID->offset alignment before trusting it (see NOTE in header).")

def _ui_range(e):
    # Choose the view the GUI should use. Integer step-range if it looks like a
    # small count; otherwise the float view. Kept simple + explicit.
    lo_i, hi_i = e["min_i"], e["max_i"]
    if e["enum"] or (0 <= lo_i <= hi_i <= 1024):
        return {"min": float(lo_i), "max": float(max(hi_i, lo_i + 1)),
                "kind": "switch" if hi_i - lo_i == 1 else "cont", "src": "int"}
    return {"min": e["min_f"], "max": e["max_f"], "kind": "cont", "src": "float"}

if __name__ == "__main__":
    main()
