#!/usr/bin/env python3
"""jp8_lift_seq.py -- the SHARED drive of the lifted-code gates (both sides import it; no unicorn, no ctypes).
DRIVE2 (2026-09-23, S3_STATUS D7): every gate runs the plugin's own construction -- HOST from the FACTORY 0x444FE0
(ALLOC 0x8D0 + ctor 0x444000), BUILD, FTZ, SETSR (float xmm1), host_init and the recall through HOSTPARAM 0x4465B0,
NO snap and NO latch clear (the plugin's walker settles every ramp). The legacy zero-HOST drive is never graded.
Control-plane events ('build', 'setsr', 'hostinit', 'recall', 'noteon', 'noteoff') are NOT re-derived on the C side:
process A records every top-level call the oracle makes for the event (entry, rcx, rdx, r8, r9, MXCSR, the float in
xmm1 for SETSR) and process B replays that list verbatim through the lifted code (plumbing only, CLAUDE.md).
'render' = n samples of VOICE_WRAP x8 then MASTER_WRAP, called directly on both sides (every output word compared).
After the list the whole heap and the stack region are compared.
Layers (JP8_LIFT_LAYER):
  render (layer 1): drive2 boot of patch P, SETTLE samples, note-on KEY, WARM samples, dump; judged: renders + a second
          key + note-offs (the per-sample renders + the note path).
  recall (layer 2): the same boot; judged: a recall of RECALL_TO[recall] through HOSTPARAM (the per-id switch incl.
          756 LFO KEY TRIG's direct setter and 769's v-36), 8*N samples of the walker settling it, then a note.
  boot   (layer 3): from the POST-STATIC-INIT image: factory + BUILD (MXCSR 0x1F80), FTZ, SETSR, host_init, the
          recall of RECALL_TO[boot], SETTLE samples (no snap), then a note."""
import os
LAYER = os.environ.get("JP8_LIFT_LAYER", "render")
KEY = 60; KEY2 = 67
SETTLE = 2200          # drive2: samples after the boot so the plugin's walker settles the recalled ramps (latch 960 inside)
WARM = 256
N = 64
RECALL_TO = {"recall": 0, "boot": 5, "render": None}[LAYER]   # layer 2 recalls patch 0 (LFO KEY TRIG = 1, pitch envelope)
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
BUILD = 0x445020; SETSR = 0x4464F0; HOSTPARAM = 0x4465B0; ALLOC = 0x6F5B04; FACTORY = 0x444FE0
ROOTS = "0x3F80B0,0x3F8040,0x445CF0,0x445C90,0x437630,0x37CD80,0x445020,0x4464F0,0x4465B0,0x444FE0"
# the tooth per layer: ONE addss turned into subss by jp8_lift.py --tooth; the gate must FAIL with it
#   render: 0x3965cb = the VCO1 RANGE add in the per-sample pitch block (fn 0x395000)
#   recall: 0x38633e = the FINE TUNE child setter's "+ 0.0003" (0x386310), reached only through the recall
#   boot:   the same FINE TUNE setter (the boot drive recalls patch 5 through HOSTPARAM)
TOOTH = {"render": "0x3965cb", "recall": "0x38633e", "boot": "0x38633e"}[LAYER]
# oracle regions (jp8_emu constants; the C side maps the same ones)
IMG_BASE = 0x180000000
HEAP_BASE = 0x310000000; HEAP_MAP = 0x8000000
STACK_BASE = 0x200000000; STACK_SIZE = 0x2000000
BUF_BASE = 0x700000000; BUF_SIZE = 0x400000
RET = 0x105000         # jp8_emu.call's return sentinel (SCRATCH + 0x5000), written at [rsp] of every top-level call
PAIR_V = BUF_BASE + 0x100; OUT_M = BUF_BASE + 0x200; OUT_S = BUF_BASE + 0x204
PAIR_M = BUF_BASE + 0x300; OUT_L = BUF_BASE + 0x400; OUT_R = BUF_BASE + 0x404
A2 = BUF_BASE + 0x500
VOUT = BUF_BASE + 0x600
GS_BASE = BUF_BASE + 0x20000   # the oracle's page 0 (gs:[...] reads) lives here on the C side (jp8_cpu.h JP8_GS_BASE)
def events():
    if LAYER == "boot":
        return [("build", 0), ("setsr", 44100.0), ("hostinit", 0), ("recall", RECALL_TO), ("render", SETTLE), ("noteon", KEY), ("render", N), ("noteoff", KEY), ("render", N)]
    if LAYER == "recall":
        return [("recall", RECALL_TO), ("render", 8 * N), ("noteon", KEY), ("render", N), ("noteoff", KEY), ("render", N)]
    return [("render", N), ("noteon", KEY2), ("render", N), ("noteoff", KEY), ("noteoff", KEY2), ("render", N)]
