#!/usr/bin/env python3
"""jp8_patch_census.py -- READ-only census (pefile + capstone; no Unicorn, no ctypes): which PATCH-struct parameters the factory bank
stores BEYOND the 64 ACTIVE_POOLS that jp8_emu.recall sends. Law under test (INFERRED, checked here): the executed host
map's PATCH ids are Script addresses 0x60xxxx; a field sits at blob offset (hid - 0x600000) + 12 and spans up to the next
mapped id (2 bytes = int2x4 for the pools, 8 bytes = 8 one-nibble bytes = a 32-bit value for the rest). Tooth: the same
decode must return the patch NAME from PATCH NAME 000..063 (eng 814..829) for every patch; a shifted offset fails it.
Every decoded value must sit in [0, max-min] of the ENGINE DB. Host map: the READ list of static init 0xAD320
(identical to the EXECUTED walk: logs/drive2/boot_p2_44100.log)."""
import sys, os
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_bank as B, pe_recon
shift = int(sys.argv[1]) if len(sys.argv) > 1 else 0          # tooth: a nonzero shift must fail
BIN = os.path.join(HERE, "..", "truth", "JUPITER-8VST3_64bit.vst3")
def static_map_read():
    """READ (pefile + capstone only): the (host id, engine id) pairs static init 0xAD320 stores at [rbp+0x1670, rbp+0x2db0)
    before 0x443dd0 -- the same reader as jp8_drive2_probe.static_map_read, kept here so this census never imports Unicorn"""
    import pefile, capstone
    img = pefile.PE(BIN).get_memory_mapped_image()
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64); md.detail = True
    mem = {}
    for ins in md.disasm(bytes(img[0xAD320:0xB46F2]), 0xAD320):
        if ins.mnemonic == "mov" and "dword ptr [rbp +" in ins.op_str:
            o = ins.operands
            if o[1].type == capstone.x86.X86_OP_IMM: mem[o[0].mem.disp] = o[1].imm & 0xFFFFFFFF
            elif o[1].type == capstone.x86.X86_OP_REG: mem[o[0].mem.disp] = 0   # 0xad358: mov [rbp+0x1670], eax (eax = 0)
    return {mem.get(d): mem.get(d + 4) for d in range(0x1670, 0x2DB0, 8)}
hm = static_map_read(); rows = pe_recon.PE(BIN).params(list(range(5223)))["rows"]
patch_ids = sorted((k, v) for k, v in hm.items() if 0x600000 <= k < 0x610000)
bank = B.bank_bytes()
def field(blob, hid, nxt):
    p = (hid - 0x600000) + 12 + shift; w = nxt - hid
    v = 0
    for i in range(w): v = (v << 4) | (blob[p + i] & 0xF)
    return v, w
fails = 0; names_ok = 0; bad = []
for k in range(64):
    blob = B.patch_blob(bank, k); name = b""
    for i, (hid, eid) in enumerate(patch_ids):
        nxt = patch_ids[i + 1][0] if i + 1 < len(patch_ids) else hid + 8
        v, w = field(blob, hid, nxt); r = rows[eid]
        if 814 <= eid <= 829: name += v.to_bytes(4, "big"); continue
        if w == 2:   # int2x4 pool: RAW frame 0..max-min (jp8_bank_census.py)
            if not (0 <= v <= r["max"] - r["min"]): fails += 1; bad.append((k, eid, v))
        else:        # 8 one-nibble bytes: a signed 32-bit ENGINE value (INFERRED: OCTAVE SHIFT of patch 31 = 0xFFFFFFFF = -1)
            sv = v - (1 << 32) if v >= 1 << 31 else v
            if r["max"] >= r["min"] and not (r["min"] <= sv <= r["max"]): fails += 1; bad.append((k, eid, sv))
    names_ok += name[:16].decode("latin1") == B.patch_name(bank, k)
print("PATCH-struct ids in the executed host map: %d (pools %d, others %d); shift %d" % (len(patch_ids), sum(1 for h, e in patch_ids if 750 <= e <= 813), sum(1 for h, e in patch_ids if not 750 <= e <= 813), shift))
print("TOOTH patch names decoded from eng 814..829: %d/64 match the record name" % names_ok)
print("values outside their frame (pools: raw 0..max-min; 8-nibble fields: signed engine min..max): %d of %d %s" % (fails, 64 * (len(patch_ids) - 16), bad[:8]))
b0, b2 = B.patch_blob(bank, 0), B.patch_blob(bank, 2)
for i, (hid, eid) in enumerate(patch_ids):
    if eid < 830: continue
    nxt = patch_ids[i + 1][0] if i + 1 < len(patch_ids) else hid + 8
    vals = [field(B.patch_blob(bank, k), hid, nxt)[0] for k in range(64)]; vals = [x - (1 << 32) if x >= 1 << 31 else x for x in vals]; r = rows[eid]
    print("  eng %d host 0x%x %-24s DB %d..%d def %d | bank raw: p0 %d p2 %d, %d distinct over 64" % (eid, hid, r["name"], r["min"], r["max"], r["default"], vals[0], vals[2], len(set(vals))))
print("PATCH CENSUS: %s" % ("GREEN" if names_ok == 64 and fails == 0 else "FAIL"))
