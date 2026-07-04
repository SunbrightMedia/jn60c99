// bank.js — decode a Roland JUNO-60 preset bank (KoaBankFile00003 / PG-JU60) in
// the browser. Port of tools/decode_bank.py (verified against the plugin binary).
// Gives 64 real patch names + per-patch parameter values. Parameter labels are
// transform-derived ROLES, not confirmed panel names (see docs/BANK_FORMAT.md).

const MAGIC = "KoaBankFile00003";
const HEADER_LEN = 23, PATCH_STRIDE = 20223, PATCH_COUNT = 64, NAME_LEN = 16, BLOB_OFF = 16;

// (src_blob_offset, prog_dest, role, confidence) — the real extracted src→dest table.
const TABLE = [
  [4,16,"prog@16","unconfirmed"],[6,14,"prog@14","unconfirmed"],[10,24,"prog@24","unconfirmed"],
  [18,32,"prog@32","low"],[20,18,"Bipolar mod depth @18","medium"],[22,28,"prog@28","unconfirmed"],
  [24,30,"Switch @30","medium"],[26,52,"Switch @52","low"],[28,54,"Enable switch @54","medium"],
  [30,56,"Filter-mapped discrete @56","low"],[32,58,"Filter-mapped discrete @58","low"],
  [44,76,"prog@76","unconfirmed"],[46,70,"prog@70","unconfirmed"],[48,74,"prog@74","unconfirmed"],
  [52,78,"Bipolar +/- param @78","medium"],[54,20,"Bipolar mod depth @20","medium"],
  [56,88,"Bipolar mod depth @88","medium"],[68,468,"Mode switch @468","low"],
  [70,132,"Level (amplitude/dB)","medium"],[82,80,"Continuous slider @80","low"],
  [84,82,"Continuous slider @82","low"],[86,84,"Continuous slider @84","low"],
  [88,86,"Continuous slider @86","low"],[100,612,"Osc mode/range select","medium"],
  [102,104,"prog@104","low"],[104,106,"Time/level (exp curve) @106","medium"],
  [106,3041,"Chorus / effect param","medium"],[122,108,"prog@108","unconfirmed"],
  [124,110,"prog@110","unconfirmed"],[126,112,"3-position switch @112","low"],
  [130,118,"prog@118","unconfirmed"],
];

export function decodeBank(arrayBuffer) {
  const b = new Uint8Array(arrayBuffer);
  const magic = new TextDecoder("latin1").decode(b.slice(0, 16));
  if (magic !== MAGIC) throw new Error(`not a KoaBankFile00003 bank (got "${magic}")`);
  const model = new TextDecoder("latin1").decode(b.slice(16, 23)).replace(/\0+$/, "");
  const expected = HEADER_LEN + PATCH_COUNT * PATCH_STRIDE;
  if (b.length !== expected)
    throw new Error(`unexpected size ${b.length} (expected ${expected} for 64 patches)`);
  const patches = [];
  for (let i = 0; i < PATCH_COUNT; i++) {
    const base = HEADER_LEN + i * PATCH_STRIDE;
    let name = new TextDecoder("latin1").decode(b.slice(base, base + NAME_LEN));
    name = name.split("\0")[0].replace(/\s+$/, "");
    const blob = b.slice(base + BLOB_OFF, base + BLOB_OFF + 222);
    const params = TABLE.map(([src, dest, role, conf]) => {
      const raw = ((blob[src] & 0xF) << 4) | (blob[src + 1] & 0xF);
      return { prog_dest: dest, src, role, confidence: conf, raw, normalized: raw / 255 };
    });
    patches.push({ index: i, name, params });
  }
  return { magic, model, patch_count: PATCH_COUNT, patches };
}
