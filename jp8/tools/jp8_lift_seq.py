#!/usr/bin/env python3
"""jp8_lift_seq.py -- the SHARED drive of the lifted-code gates (both sides import it; no unicorn, no ctypes).
Every gate = boot patch P on the corrected drive, IDLE_N idle samples, note-on KEY, WARM warm-up samples (the
oracle's normal stubs), then the JUDGED EVENT LIST below, executed identically on both sides: 'render' = n samples of
VOICE_WRAP x8 then MASTER_WRAP (every output word compared), 'noteon'/'noteoff' = NOTEON/NOTEOFF (lifted on the C
side), 'recall' = every active pool of patch B through DISPATCH (flag 0, engine frame) on all 9 units + ASG_NOTIFY
on all 9 (lifted on the C side); the whole heap is compared after the list.
Layers (JP8_LIFT_LAYER): 'render' (layer 1: the per-sample renders + the note path) and 'recall' (layer 2: the
dispatch/setter/notify path + the ramp walker settling, then a note through the recalled patch)."""
import os
LAYER = os.environ.get("JP8_LIFT_LAYER", "render")
KEY = 60; KEY2 = 67
IDLE_N = 8
WARM = 256
N = 64
RECALL_TO = 5          # layer 2: the patch recalled during the judged list (from each boot patch of PATCHES)
if os.environ.get("JP8_LIFT_PATCHES"):                       # a reach run overrides the patch list (jp8_lift_reach.sh)
    PATCHES = [int(x) for x in os.environ["JP8_LIFT_PATCHES"].split(",")]
elif LAYER in ("recall", "boot"):
    PATCHES = [2, 63]
else:
    PATCHES = [2, 63, 10, 0]
VOICE_WRAP = 0x3F80B0
MASTER_WRAP = 0x3F8040
NOTEON = 0x445CF0
NOTEOFF = 0x445C90     # (rcx=HOST, dl=note, r8b=vel)
DISPATCH = 0x437630    # (rcx=proc, edx=id, r8=flag, r9=value)
ASG_NOTIFY = 0x37CD80  # (rcx=assign obj, edx=what)
BUILD = 0x445020; SETSR = 0x4464F0; HOSTPARAM = 0x4465B0; ALLOC = 0x6F5B04
ROOTS = "0x3F80B0,0x3F8040,0x445CF0,0x445C90,0x437630,0x37CD80,0x445020,0x4464F0,0x4465B0"
# the tooth per layer: ONE addss turned into subss by jp8_lift.py --tooth; the gate must FAIL with it
#   render: 0x3965cb = the VCO1 RANGE add in the per-sample pitch block (fn 0x395000)
#   recall: 0x38633e = the FINE TUNE child setter's "+ 0.0003" (0x386310), reached only through DISPATCH
#   boot:   the same FINE TUNE setter (0x3F8240 holds no scalar arithmetic; the boot drive recalls patch 5 through DISPATCH)
TOOTH = {"render": "0x3965cb", "recall": "0x38633e", "boot": "0x38633e"}[LAYER]
# oracle regions (jp8_emu constants; the C side maps the same ones)
IMG_BASE = 0x180000000
HEAP_BASE = 0x310000000
STACK_BASE = 0x200000000; STACK_SIZE = 0x2000000
BUF_BASE = 0x700000000; BUF_SIZE = 0x400000
PAIR_V = BUF_BASE + 0x100; OUT_M = BUF_BASE + 0x200; OUT_S = BUF_BASE + 0x204
PAIR_M = BUF_BASE + 0x300; OUT_L = BUF_BASE + 0x400; OUT_R = BUF_BASE + 0x404
A2 = BUF_BASE + 0x500
VOUT = BUF_BASE + 0x600
GS_BASE = BUF_BASE + 0x20000   # the oracle's page 0 (gs:[...] reads) lives here on the C side (jp8_cpu.h JP8_GS_BASE)
def events():
    if LAYER == "boot":     # from the post-static-init image: the whole hosted boot, then a note (no snap: the walker settles)
        return [("build", 0), ("setsr", 44100.0), ("hostinit", 0), ("recall", RECALL_TO), ("render", 2200), ("noteon", KEY), ("render", N), ("noteoff", KEY), ("render", N)]
    if LAYER == "recall":
        return [("recall", RECALL_TO), ("render", 8 * N), ("noteon", KEY), ("render", N), ("noteoff", KEY), ("render", N)]
    return [("render", N), ("noteon", KEY2), ("render", N), ("noteoff", KEY), ("noteoff", KEY2), ("render", N)]
def hostinit_values(host_map):
    """[(host id, raw value)] the controller's default push writes (jp8_emu.host_init's law: mapped ids only, DB default - min)"""
    import sys
    sys.path.insert(0, "/home/user/jn60c99/tools/verify")
    import pe_recon
    rows = pe_recon.PE(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "truth", "JUPITER-8VST3_64bit.vst3")).params(list(range(5223)))["rows"]
    out = []
    for hid, eng in sorted(host_map.items()):
        r = rows.get(eng)
        if not r or not r["name"] or r["name"] == "_reserve_" or 433 <= eng < 485: continue
        if r["min"] == r["max"] == r["default"] == 0: continue
        out.append((hid, r["default"] - r["min"]))
    return out
def recall_values(patch):
    """[(engine id, engine-frame value)] for every active pool of the factory patch -- pure python (jp8_bank + pe_recon)"""
    import sys
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
    import jp8_bank as B, pe_recon
    rows = pe_recon.PE(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "truth", "JUPITER-8VST3_64bit.vst3")).params([B.POOL_BASE_ID + p for p in B.ACTIVE_POOLS])["rows"]
    blob = B.patch_blob(B.bank_bytes(), patch)
    return [(B.POOL_BASE_ID + p, B.pool_value(blob, p) + rows[B.POOL_BASE_ID + p]["min"]) for p in B.ACTIVE_POOLS]
