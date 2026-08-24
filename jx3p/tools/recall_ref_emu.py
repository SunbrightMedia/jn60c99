#!/usr/bin/env python3
"""recall_ref_emu.py -- the self-proven JX recall reference (voice-0), the twin
of tools/verify/plugin_recall_ref.py.

For each patch: ONE build; dispatch the front-panel recall indices (pool+740)
with the blob-decoded byte (2*pool+8, int2x4 nibble pair) IN POOL ORDER, exactly
as the plugin's own recall sequence; capture voice-0's coefficient block. Every
patch overwrites the same cells (no rebuild) -- the plugin's own recall model.

Two-process rule: writes files only (a pickle of {patch: bytes(BLOCK)} + the
active index set). The port diff is a separate ctypes-only step.
"""
import sys, os, struct, pickle, json
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools", "verify"))
import jx_emu as J

BANK = os.path.join(J.REPO, "jx3p", "truth", "preset_bank_1.bin")
# Voice-unit capture window. Was 16128 (the per-voice ARM stride) -- too narrow:
# recall also writes voice-unit cells ABOVE that stride, so HPF CUTOFF, EFFECT
# LEVEL/TONE, DELAY LEVEL/TIME and VCA LEVEL were invisible to both the
# discovery probe and the reference capture (playbook 80, flaw 3). 0x60000 is
# the window the render A/B already compares, so the two agree by construction.
BLOCK = 0x60000
HEADER = 23; STRIDE = 20223; BLOB_OFF = 16; NPATCH = 64
POOL_LO, POOL_HI = 2, 140

def decode(blob, pool):
    p = 2 * pool + 8
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)

def main():
    outdir = sys.argv[1]
    os.makedirs(outdir, exist_ok=True)
    bank = open(BANK, "rb").read()
    jx = J.JX().build(); jx.set_ftz(); uc = jx.uc
    st0 = jx.state[0]

    # Discover the active recall set: pools whose dispatch (pool+740) MOVES a
    # voice-0 coefficient. Probe from the clean build.
    #
    # DEFECT PAID 2026-08-24 (playbook 80): this loop used to probe each pool
    # ONLY with the values that pool takes in the FACTORY BANK. A parameter that
    # is constant across all 64 factory patches never moved off the clean base
    # and was silently classified inactive -- so the gate that consumes this set
    # shrank its own scope and still reported green. 25 real pools were missing
    # (DCO1 LEVEL, HPF CUTOFF, ENV2 SUSTAIN, EFFECT/DELAY/REVERB, BEND/MOD SENS,
    # ...), found only when a human counted the host's 63 panel parameters.
    # A discovery step must never depend on the corpus it is discovering FOR:
    # probe the full in-range value spread instead. jx3p/tools/probe_pools.py is
    # the independent re-derivation (voice AND master windows) and completeness
    # is now toothed against it.
    PROBE_VALUES = (0, 255, 1, 64, 128, 192)
    base = bytes(uc.mem_read(st0, BLOCK))
    active = []
    for pool in range(POOL_LO, POOL_HI):
        idx = pool + 740
        moved = False
        for v in PROBE_VALUES:
            jx.dispatch(0, idx, v)
            if bytes(uc.mem_read(st0, BLOCK)) != base:
                moved = True
            uc.mem_write(st0, base)   # restore clean base after probe
            if moved:
                break
        if moved:
            active.append(pool)
    sys.stderr.write("active recall pools: %d (%s)\n" % (len(active), active))

    # Now the real reference: one persistent build, per patch dispatch the active
    # set in pool order, capture voice-0 block. Restore clean base per patch so
    # each patch is a fresh recall (matches the plugin: recall on a prepared engine).
    uc.mem_write(st0, base)
    clean = bytes(uc.mem_read(st0, BLOCK))
    ref = {}
    for patch in range(NPATCH):
        uc.mem_write(st0, clean)
        rec = bank[HEADER + patch * STRIDE:]
        blob = rec[BLOB_OFF:]
        for pool in active:
            jx.dispatch(0, pool + 740, decode(blob, pool))
        ref[patch] = bytes(uc.mem_read(st0, BLOCK))
    pickle.dump(ref, open(os.path.join(outdir, "recall_ref.pkl"), "wb"))
    json.dump({"active": active, "block": BLOCK, "faults": jx.faults},
              open(os.path.join(outdir, "recall_meta.json"), "w"))
    print("recall ref written: %d patches, %d active pools, faults=%d"
          % (NPATCH, len(active), jx.faults))

if __name__ == "__main__":
    main()
