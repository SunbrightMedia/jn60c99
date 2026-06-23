#!/usr/bin/env python3
# dump_full_state.py — capture the ENTIRE live engine-state block, ONCE, via IDA's
# debugger. Dumps the whole ~11.5 MB the DSP uses, twice (t0/t1), to binary files.
# Offline we extract any coefficient, tell coeff-vs-state by diffing t0/t1, inspect
# per-voice values, and find the played note's pitch -- no more debugging.
#
# ROBUST MULTI-BREAKPOINT: the master alone wasn't being hit, so we breakpoint
# EVERYTHING that runs when a note sounds -- the master, the voice dispatch, and all
# 8 per-voice renders. They all receive the engine state in rcx, so whichever fires
# first gives us the state pointer (validated by a base check). It also logs WHICH
# function fired, which tells us what's actually on the live audio path.
#
# HOW TO RUN
#   1. Host: load JUNO-60 with the PATCH + CHORUS MODE you want. Turn ARP OFF and
#      HOLD a sustained note so audio is CONTINUOUS (you should hear it).
#   2. IDA attached to the host (Local Windows debugger).
#   3. File -> Script file... -> dump_full_state.py   (run ONCE, keep the note held)
#   4. It prints "HIT <fn> ... capturing", dumps t0/t1 + meta.
#   5. Edit state_dump/meta.txt, zip state_dump/, upload it.

import os, struct
import idc, ida_dbg, idautils

IMAGE_BASE  = 0x180000000
PLUGIN_HINTS = ["juno", "cloud"]
# every function that receives the engine state in rcx and runs while a note plays:
RVAS = {
    0x363380: "master",   0x398F30: "dispatch",
    0x369070: "voice0",   0x36CE00: "voice1", 0x370B90: "voice2", 0x374900: "voice3",
    0x378690: "voice4",   0x37C420: "voice5", 0x380190: "voice6", 0x383F20: "voice7",
}
DUMP_SIZE   = 0xB80000        # ~11.5 MB: covers the whole state the DSP reads
CHUNK       = 0x10000         # 64 KB reads (zero-filled on any unmapped page)
WAIT_SECS   = 3              # per wait timeout
WAIT_TRIES  = 20             # total ~60s
KNOWN       = [(2199956, 0x80000), (95828, 1024), (101028, 1024)]
OUTDIR      = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "state_dump")

def log(m): print("[full-dump] " + m)

def resolve_base():
    found = []
    for m in idautils.Modules():
        nm = m.name or ""; found.append(nm)
        if any(h in os.path.basename(nm).lower() for h in PLUGIN_HINTS):
            log("plugin module: %s @ 0x%X" % (nm, m.base)); return m.base
    log("module not found; loaded: " + ", ".join(os.path.basename(n) for n in found if n))
    log("falling back to static imagebase 0x%X." % IMAGE_BASE); return IMAGE_BASE

def ru32(ea):
    b = idc.read_dbg_memory(ea, 4)
    return struct.unpack("<I", b)[0] if b and len(b) == 4 else None

def verify_base(base):
    ok = True
    for off, exp in KNOWN:
        got = ru32(base + off)
        if got != exp:
            log("  base check: state[%d]=%s expected 0x%X"
                % (off, ("0x%X"%got) if got is not None else "None", exp)); ok = False
    return ok

def dump_state(base, path):
    n = 0
    with open(path, "wb") as fh:
        while n < DUMP_SIZE:
            sz = min(CHUNK, DUMP_SIZE - n)
            b = idc.read_dbg_memory(base + n, sz)
            fh.write(b if b and len(b) == sz else b"\x00" * sz)
            n += sz
    log("wrote %s (%d bytes)" % (os.path.basename(path), DUMP_SIZE))

def wait_any(timeout):
    """Continue, wait for any breakpoint suspension. Returns rip or None (timeout)."""
    ida_dbg.continue_process()
    code = ida_dbg.wait_for_next_event(ida_dbg.WFNE_SUSP, timeout)
    return idc.get_reg_value("rip") if code > 0 else None

def capture(state_base, modbase):
    os.makedirs(OUTDIR, exist_ok=True)
    sr = ru32(state_base + 16)
    log("dumping t0 (big read; a few seconds)...")
    dump_state(state_base, os.path.join(OUTDIR, "state_t0.bin"))
    # advance a few block-hits, then dump t1 from a fresh rcx
    base2 = state_base
    for _ in range(12):
        rip = wait_any(WAIT_SECS)
        if rip is None: break
        rcx = idc.get_reg_value("rcx")
        if verify_base(rcx): base2 = rcx
    log("dumping t1...")
    dump_state(base2, os.path.join(OUTDIR, "state_t1.bin"))
    with open(os.path.join(OUTDIR, "meta.txt"), "w") as fh:
        fh.write("state_base_t0=0x%X\nstate_base_t1=0x%X\nmodule_base=0x%X\nsize=0x%X\n"
                 "sample_rate_bits=0x%08X\n" % (state_base, base2, modbase, DUMP_SIZE, sr or 0))
        fh.write("# fill in: patch name, chorus mode, MIDI note held\n")
    for ea in list(RVAS): ida_dbg.del_bpt(modbase + ea)
    log("DONE. Zip state_dump/ and upload it. (process left suspended.)")

def main():
    if ida_dbg.get_process_state() == 0:
        log("No debug session. Attach IDA to the host first, then re-run."); return
    base = resolve_base()
    try:
        old = ida_dbg.set_debugger_options(0)
        log("disabled auto-suspend on thread/library events (was 0x%X)." % old)
    except Exception as e:
        log("couldn't auto-set options (%s); GUI: uncheck the 'Suspend on thread/"
            "library' options." % e)
    addr2name = {}
    for rva, name in RVAS.items():
        ea = base + rva
        ok = ida_dbg.add_bpt(ea)
        addr2name[ea] = name
        log("bp %-8s @ 0x%X  add_bpt=%s" % (name, ea, ok))

    log("resuming and WAITING for any of them to fire (~%ds)." % (WAIT_SECS * WAIT_TRIES))
    log(">>> HOLD a sustained note NOW (arp OFF, audio engine ON).")
    for i in range(WAIT_TRIES):
        rip = wait_any(WAIT_SECS)
        if rip is None:
            log("  ...still waiting (%d/%d) — note held? audio audible?" % (i + 1, WAIT_TRIES))
            continue
        name = addr2name.get(rip, "0x%X" % rip)
        rcx = idc.get_reg_value("rcx")
        log("HIT %s (rip=0x%X), rcx=0x%X" % (name, rip, rcx))
        if verify_base(rcx):
            log("base check OK — that rcx is the engine state. capturing.")
            capture(rcx, base); return
        log("  (rcx isn't the engine state here; continuing to the next hit)")
    log("Nothing fired in ~%ds. If you can clearly HEAR a sustained JUNO-60 note,"
        % (WAIT_SECS * WAIT_TRIES))
    log("then the live audio path uses code at addresses we don't expect (e.g. a")
    log("CPU-specific build) — tell the porting side and we'll adapt. Otherwise make")
    log("sure the note is sustained and audible, and run again.")

if __name__ == "__main__":
    main()
