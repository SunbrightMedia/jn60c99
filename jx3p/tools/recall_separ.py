#!/usr/bin/env python3
"""recall_separ.py -- measure JX recall separability the CORRECT way (clean base,
one build). For each active pool, capture from the SAME clean base which voice-0
4-byte cells its dispatch writes and to what, per input byte (a per-param LUT).
Then, per patch, compose the LUTs (clean base + each active pool's writes in pool
order) and compare to the true sequential reference. Cells that differ are the
INTERACTING params -- the ones needing bespoke laws (as JUNO's apply.c has). This
distinguishes 'genuinely proc-mediated' from 'harness reset bug'."""
import sys, os, struct, pickle, json
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools", "verify"))
import jx_emu as J

BANK = os.path.join(J.REPO, "jx3p", "truth", "preset_bank_1.bin")
BLOCK = 16128; HEADER = 23; STRIDE = 20223; BLOB_OFF = 16; NPATCH = 64

def decode(blob, pool):
    p = 2 * pool - 8   # CORRECTED 2026-09-05 (playbook 88, jx_bank_census.py)
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)

def main():
    refdir = sys.argv[1]
    ref = pickle.load(open(os.path.join(refdir, "recall_ref.pkl"), "rb"))
    meta = json.load(open(os.path.join(refdir, "recall_meta.json")))
    active = meta["active"]
    bank = open(BANK, "rb").read()
    jx = J.JX().build(); jx.set_ftz(); uc = jx.uc; st0 = jx.state[0]
    jx.set_sr(44100.0)   # the LUTs must come from a RATED boot (playbook 87)
    clean = bytes(uc.mem_read(st0, BLOCK))

    # per-pool LUT: byte -> {cell_off: 4-byte value} captured from clean base
    lut = {}
    for pool in active:
        idx = pool + 740; d = {}
        for b in range(256):
            uc.mem_write(st0, clean)
            jx.dispatch(0, idx, b)
            cur = bytes(uc.mem_read(st0, BLOCK))
            writes = {}
            for o in range(0, BLOCK, 4):
                if cur[o:o+4] != clean[o:o+4]:
                    writes[o] = cur[o:o+4]
            d[b] = writes
        lut[pool] = d
        uc.mem_write(st0, clean)

    # compose per patch and diff vs sequential reference
    bad_cells = {}   # cell -> count of patches wrong
    bad_pool_owner = {}
    patch_fail = 0
    for patch in range(NPATCH):
        rec = bank[HEADER + patch * STRIDE:]; blob = rec[BLOB_OFF:]
        comp = bytearray(clean)
        for pool in active:
            for o, val in lut[pool][decode(blob, pool)].items():
                comp[o:o+4] = val
        r = ref[patch]
        diffs = [o for o in range(0, BLOCK, 4) if bytes(comp[o:o+4]) != r[o:o+4]]
        if diffs:
            patch_fail += 1
            for o in diffs:
                bad_cells[o] = bad_cells.get(o, 0) + 1
    print("compose vs sequential: %d/%d patches match" % (NPATCH - patch_fail, NPATCH))
    print("interacting cells: %d" % len(bad_cells))
    for o in sorted(bad_cells):
        print("  cell %d  wrong in %d patches" % (o, bad_cells[o]))
    # which active pools WRITE each bad cell (candidate owners)
    writers = {}
    for pool in active:
        cells = set()
        for b in range(256):
            cells |= set(lut[pool][b].keys())
        for c in cells:
            writers.setdefault(c, []).append(pool)
    print("=== writers of interacting cells ===")
    for o in sorted(bad_cells):
        print("  cell %d written by pools %s" % (o, writers.get(o, [])))
    pickle.dump({"lut": lut, "active": active, "clean": clean, "bad_cells": bad_cells,
                 "writers": writers}, open(os.path.join(refdir, "recall_lut.pkl"), "wb"))

if __name__ == "__main__":
    main()
