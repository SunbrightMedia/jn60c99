#!/usr/bin/env python3
"""decode_bank.py — decode a Roland Cloud JUNO-60 preset BANK (KoaBankFile00003
/ PG-JU60) into its 64 patches.

Format reverse-engineered from the plugin's own loader (sub_7FF91DFB2380 ->
per-patch parser sub_7FF91DFB1710) and verified end-to-end (see
docs/BANK_FORMAT.md). WHAT IS SOLID vs WHAT ISN'T:

  SOLID (verified against the decompile + exact byte tiling):
    * 23-byte header: "KoaBankFile00003" (16) + "PG-JU60" (7).
    * 64 patch records, 20223 bytes each  (23 + 64*20223 == file size exactly).
    * Record = [0:16] 16-byte space-padded ASCII NAME
             + [16:238] 222-byte nibble parameter blob (the only region the
               plugin's parser consumes; the rest of the record is padding).
    * 111 parameter values per patch, hi-nibble first:
          value[k] = ((blob[2k] & 0xF) << 4) | (blob[2k+1] & 0xF)   # 0..255
      normalized = value / 255.0.
    * All 64 factory names decode cleanly (SY Poly Synth ... FX Wind).
    * 19 of the 111 positions have parser-CONFIRMED semantics (transform + the
      programmer-state byte slots they write); see PARSER_CASES below.

  NOT recoverable offline (do NOT fabricate — see docs/BANK_FORMAT.md):
    * The value -> ENGINE-coefficient-offset binding. The (src->dest) table
      (dword_7FF91E8A4290) is plugin .rdata, only referenced in the decompile;
      the original ~12 MB binary isn't here. And the parser fills a nibble-packed
      "programmer" state that a separate, un-ported stage (sub_7FF91DF9CDA0)
      translates into the flat engine coefficients our port reads. So a decoded
      patch's values cannot (yet) be applied to make our engine sound like it.
      This decoder therefore exposes patch NAMES + per-position VALUES only.

Usage:
    python3 tools/decode_bank.py BANK.bin              # list the 64 patch names
    python3 tools/decode_bank.py BANK.bin --json OUT   # full decode -> JSON
    python3 tools/decode_bank.py BANK.bin --patch 6    # dump one patch's values
"""
import sys, json, argparse

MAGIC = b"KoaBankFile00003"
MODEL = b"PG-JU60"
HEADER_LEN = 23                 # 16 + 7
PATCH_STRIDE = 20223
PATCH_COUNT = 64
NAME_LEN = 16
BLOB_OFF = 16
PARAMS_PER_PATCH = 111

# position -> parser-confirmed semantics (from sub_7FF91DFB1710 switch cases,
# keyed on src blob offset = position*2). Labels describe the transform and the
# programmer-state byte slots written; these are NOT engine coefficient offsets.
PARSER_CASES = {
    2:  ("float value/255 + nibble store", [652, 653, 654, 655, 656, 657, 658, 659]),
    9:  ("value + 2", [33]),
    10: ("bipolar recenter (v>>1)+128", None),
    13: ("boolean -> {10,13}/0", None),
    14: ("boolean -> {10,13}/0", None),
    15: ("LFO-rate cubic-Hz inverse-lookup", None),
    16: ("pow(v,1.6) curve inverse-lookup", None),
    23: ("float value/255 + nibble store", [1854, 1855, 1856, 1857, 1858, 1859, 1860, 1861]),
    26: ("conditional recenter / inverted half-range", None),
    27: ("bipolar recenter (v>>1)+128", None),
    28: ("bipolar recenter (v>>1)+128", None),
    34: ("boolean -> prog_state[475]={0,2}", [475]),
    35: ("dB curve inverse-lookup", None),
    50: ("literal-init block", [619, 626, 627, 100, 101]),
    51: ("16-entry float-table inverse-lookup (table absent)", None),
    52: ("curve/float-table inverse-lookup (tables absent)", None),
    53: ("16-entry float-table inverse-lookup + fixed block",
         [3043] + list(range(3062, 3078))),
    61: ("conditional recenter", None),
    63: ("map {2:1,3:2,else:0}", None),
}


def decode_bank(data):
    """Return {header:{...}, patches:[{index,name,values:[{pos,byte,normalized,
    parser}]}]}. Raises ValueError on a non-matching file."""
    if data[:16] != MAGIC:
        raise ValueError("not a KoaBankFile00003 bank (bad magic %r)" % data[:16])
    model = data[16:23].rstrip(b"\x00")
    expected_len = HEADER_LEN + PATCH_COUNT * PATCH_STRIDE
    if len(data) != expected_len:
        raise ValueError("unexpected size %d (expected %d for a 64-patch bank)"
                         % (len(data), expected_len))
    patches = []
    for i in range(PATCH_COUNT):
        base = HEADER_LEN + i * PATCH_STRIDE
        name = data[base:base + NAME_LEN].decode("latin1").rstrip(" \x00").strip()
        blob = data[base + BLOB_OFF: base + BLOB_OFF + 2 * PARAMS_PER_PATCH]
        vals = []
        for k in range(PARAMS_PER_PATCH):
            byte = ((blob[2 * k] & 0xF) << 4) | (blob[2 * k + 1] & 0xF)
            label, dest = PARSER_CASES.get(k, (None, None))
            v = {"pos": k, "byte": byte, "normalized": round(byte / 255.0, 6)}
            if label:
                v["parser"] = label
                if dest:
                    v["prog_state_dest"] = dest
            vals.append(v)
        patches.append({"index": i, "name": name, "values": vals})
    return {"header": {"magic": MAGIC.decode(), "model": model.decode("latin1"),
                       "patch_count": PATCH_COUNT}, "patches": patches}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bank")
    ap.add_argument("--json", metavar="OUT", help="write full decode to JSON")
    ap.add_argument("--patch", type=int, help="dump one patch's values")
    a = ap.parse_args()
    bank = decode_bank(open(a.bank, "rb").read())
    if a.json:
        json.dump(bank, open(a.json, "w"), indent=1)
        print("wrote %s (%d patches)" % (a.json, len(bank["patches"])))
        return
    if a.patch is not None:
        p = bank["patches"][a.patch]
        print("[%d] %s" % (p["index"], p["name"]))
        for v in p["values"]:
            tag = ("  <- " + v["parser"]) if "parser" in v else ""
            print("  pos %3d = %3d (%.3f)%s" % (v["pos"], v["byte"], v["normalized"], tag))
        return
    print("Bank: %s  model=%s  %d patches" %
          (bank["header"]["magic"], bank["header"]["model"], len(bank["patches"])))
    for p in bank["patches"]:
        print("  %2d  %s" % (p["index"], p["name"]))


if __name__ == "__main__":
    main()
