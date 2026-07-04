#!/usr/bin/env python3
"""decode_bank.py — decode a Roland Cloud JUNO-60 preset BANK (KoaBankFile00003
/ PG-JU60) into its 64 patches: real names + the per-patch parameter values.

VERIFIED against the plugin binary (imagebase 0x180000000): the 64-patch tiling,
the per-patch parser sub_7FF91DFB1710 (rva 0x351710), and the extracted src→dest
table dword_7FF91E8A4290 (31 entries, embedded below). An adversarial pass
re-decoded all 64 patches (1984 params) with zero mismatches.

WHAT THIS GIVES (solid): 64 real factory patch names + for each patch the 31
front-panel parameter values (0..255, normalized /255), positioned by the real
src→dest table and tagged with the parser transform.

WHAT IT DOES NOT GIVE (honest — see docs/BANK_FORMAT.md): specific panel NAMES
per parameter, or application to our engine's coefficients. The plugin routes
these values through a reflection-based "Koa" value tree to the engine
coefficients; that binding is not a small table and is not ported. So parameter
labels here are transform-derived ROLES (hedged), not confirmed panel names, and
loading a patch is inspection-only, not audible recall.

Usage:
    python3 tools/decode_bank.py BANK.bin              # list the 64 names
    python3 tools/decode_bank.py BANK.bin --json OUT   # full decode -> JSON
    python3 tools/decode_bank.py BANK.bin --patch 6    # dump one patch
"""
import sys, json, argparse

MAGIC = b"KoaBankFile00003"
HEADER_LEN = 23
PATCH_STRIDE = 20223
PATCH_COUNT = 64
NAME_LEN = 16
BLOB_OFF = 16

# Real src→dest table (dword_7FF91E8A4290), 31 entries, + the transform-derived
# ROLE label per programmer-state destination (hedged; see module docstring).
# (src_blob_offset, prog_dest, role, confidence)
TABLE = [
    (4, 16, "prog@16", "unconfirmed"),           (6, 14, "prog@14", "unconfirmed"),
    (10, 24, "prog@24", "unconfirmed"),           (18, 32, "prog@32", "low"),
    (20, 18, "Bipolar mod depth @18", "medium"),  (22, 28, "prog@28", "unconfirmed"),
    (24, 30, "Switch @30", "medium"),             (26, 52, "Switch @52", "low"),
    (28, 54, "Enable switch @54", "medium"),       (30, 56, "Filter-mapped discrete @56", "low"),
    (32, 58, "Filter-mapped discrete @58", "low"), (44, 76, "prog@76", "unconfirmed"),
    (46, 70, "prog@70", "unconfirmed"),            (48, 74, "prog@74", "unconfirmed"),
    (52, 78, "Bipolar +/- param @78", "medium"),   (54, 20, "Bipolar mod depth @20", "medium"),
    (56, 88, "Bipolar mod depth @88", "medium"),   (68, 468, "Mode switch @468", "low"),
    (70, 132, "Level (amplitude/dB)", "medium"),   (82, 80, "Continuous slider @80", "low"),
    (84, 82, "Continuous slider @82", "low"),      (86, 84, "Continuous slider @84", "low"),
    (88, 86, "Continuous slider @86", "low"),      (100, 612, "Osc mode/range select", "medium"),
    (102, 104, "prog@104", "low"),                 (104, 106, "Time/level (exp curve) @106", "medium"),
    (106, 3041, "Chorus / effect param", "medium"),(122, 108, "prog@108", "unconfirmed"),
    (124, 110, "prog@110", "unconfirmed"),         (126, 112, "3-position switch @112", "low"),
    (130, 118, "prog@118", "unconfirmed"),
]


def decode_bank(data):
    if data[:16] != MAGIC:
        raise ValueError("not a KoaBankFile00003 bank (bad magic %r)" % data[:16])
    model = data[16:23].rstrip(b"\x00").decode("latin1")
    expected = HEADER_LEN + PATCH_COUNT * PATCH_STRIDE
    if len(data) != expected:
        raise ValueError("unexpected size %d (expected %d for 64 patches)"
                         % (len(data), expected))
    patches = []
    for i in range(PATCH_COUNT):
        base = HEADER_LEN + i * PATCH_STRIDE
        name = data[base:base + NAME_LEN].split(b"\x00")[0].decode("latin1").rstrip()
        blob = data[base + BLOB_OFF: base + BLOB_OFF + 222]
        params = []
        for src, dest, role, conf in TABLE:
            raw = ((blob[src] & 0xF) << 4) | (blob[src + 1] & 0xF)  # hi-nibble first
            params.append({"prog_dest": dest, "src": src, "role": role,
                           "confidence": conf, "raw": raw,
                           "normalized": round(raw / 255.0, 4)})
        patches.append({"index": i, "name": name, "params": params})
    return {"magic": MAGIC.decode(), "model": model,
            "patch_count": PATCH_COUNT, "patches": patches}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bank")
    ap.add_argument("--json", metavar="OUT")
    ap.add_argument("--patch", type=int)
    a = ap.parse_args()
    bank = decode_bank(open(a.bank, "rb").read())
    if a.json:
        json.dump(bank, open(a.json, "w"), indent=1)
        print("wrote %s (%d patches)" % (a.json, bank["patch_count"]))
        return
    if a.patch is not None:
        p = bank["patches"][a.patch]
        print("[%d] %s" % (p["index"], p["name"]))
        for pr in p["params"]:
            print("  %-30s = %3d  (%.3f)  [%s]"
                  % (pr["role"], pr["raw"], pr["normalized"], pr["confidence"]))
        return
    print("Bank %s  model=%s  %d patches" %
          (bank["magic"], bank["model"], bank["patch_count"]))
    for p in bank["patches"]:
        print("  %2d  %s" % (p["index"], p["name"]))


if __name__ == "__main__":
    main()
