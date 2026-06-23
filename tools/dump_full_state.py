#!/usr/bin/env python3
# dump_full_state.py — capture the ENTIRE live engine-state block, ONCE, via IDA's
# debugger. Instead of cherry-picking 349 offsets, we dump the whole ~11.5 MB the
# DSP uses, twice (t0/t1), to binary files. Offline we then extract ANY coefficient,
# verify time-invariance (coeff vs state), inspect per-voice values, and find the
# played note's pitch -- all without ever returning to the debugger.
#
# TWO-PHASE, NON-BLOCKING (reliable; gives visual confirmation):
#   Run #1 (process suspended, not at master): arm breakpoint + resume, return.
#           Let audio play; IDA STOPS at the master (disasm jumps there) = it works.
#   Run #2 (stopped AT master): dump t0, run a few blocks, dump t1, write meta.
#
# HOW TO RUN
#   1. Host: load JUNO-60 with the PATCH + CHORUS MODE you want, hold a sustained
#      note (e.g. middle C), audio running, settle ~1-2 s.
#   2. IDA attached to the host (Local Windows debugger), process suspended.
#   3. File -> Script file... -> dump_full_state.py   (run once to arm)
#   4. Let audio play; when IDA stops at the master, run it AGAIN to dump.
#   5. Zip the state_dump/ folder and upload it.

import os, struct
import idc, ida_dbg, idautils

IMAGE_BASE  = 0x180000000
RVA_MASTER  = 0x363380
MASTER      = IMAGE_BASE + RVA_MASTER
PLUGIN_HINTS = ["juno", "cloud"]
DUMP_SIZE   = 0xB80000        # ~11.5 MB: covers the whole state the DSP reads
CHUNK       = 0x10000         # 64 KB reads (zero-filled on any unmapped page)
SETTLE_HITS = 16             # master hits between the two dumps
KNOWN       = [(2199956, 0x80000), (95828, 1024), (101028, 1024)]
OUTDIR      = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "state_dump")

def log(m): print("[full-dump] " + m)

def resolve_master():
    found = []
    for m in idautils.Modules():
        nm = m.name or ""; found.append(nm)
        if any(h in os.path.basename(nm).lower() for h in PLUGIN_HINTS):
            log("plugin module: %s @ 0x%X -> master 0x%X" % (nm, m.base, m.base + RVA_MASTER))
            return m.base + RVA_MASTER
    log("module not found; loaded: " + ", ".join(os.path.basename(n) for n in found if n))
    log("using database EA 0x%X (only if IDA rebased)." % MASTER)
    return MASTER

def ru32(ea):
    b = idc.read_dbg_memory(ea, 4)
    return struct.unpack("<I", b)[0] if b and len(b) == 4 else None

def verify_base(base):
    ok = True
    for off, exp in KNOWN:
        got = ru32(base + off)
        if got != exp:
            log("BASE CHECK FAILED: state[%d]=%s expected 0x%X"
                % (off, ("0x%X"%got) if got is not None else "None", exp)); ok = False
    if ok: log("base check OK — rcx is the engine state.")
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

def wait_master(master, max_events=20000):
    k = 0
    while k < max_events:
        ida_dbg.continue_process()
        if ida_dbg.wait_for_next_event(ida_dbg.WFNE_SUSP, -1) <= 0: return False
        k += 1
        if idc.get_reg_value("rip") == master: return True
    return False

def main():
    st = ida_dbg.get_process_state()
    if st == 0:
        log("No debug session. Attach IDA to the host first, then re-run."); return
    master = resolve_master()
    if st < 0 and idc.get_reg_value("rip") == master:
        # PHASE 2: capture
        os.makedirs(OUTDIR, exist_ok=True)
        base = idc.get_reg_value("rcx"); log("engine state (rcx) = 0x%X" % base)
        if not verify_base(base): return
        sr = ru32(base + 16)
        log("dumping t0 (this is the big read; a few seconds)...")
        dump_state(base, os.path.join(OUTDIR, "state_t0.bin"))
        for _ in range(SETTLE_HITS):
            if not wait_master(master): break
        base2 = idc.get_reg_value("rcx")
        log("dumping t1...")
        dump_state(base2, os.path.join(OUTDIR, "state_t1.bin"))
        with open(os.path.join(OUTDIR, "meta.txt"), "w") as fh:
            fh.write("base_t0=0x%X\nbase_t1=0x%X\nsize=0x%X\nsample_rate_bits=0x%08X\n"
                     % (base, base2, DUMP_SIZE, sr or 0))
            fh.write("# fill in: patch name, chorus mode, MIDI note held\n")
        ida_dbg.del_bpt(master)
        log("DONE. Zip state_dump/ and upload it. (process left suspended.)")
        return
    if st > 0:
        log("Process RUNNING. Wait until IDA stops at the master, then run again."); return
    # PHASE 1: arm + resume.
    # Disable IDA's auto-suspend on thread/library/start events so the process runs
    # straight to OUR breakpoint instead of stopping in ntdll every time a thread or
    # DLL loads (that bouncing 0x7FF9... is exactly that). Breakpoints still suspend.
    try:
        old = ida_dbg.set_debugger_options(0)
        log("disabled auto-suspend on thread/library events (was 0x%X)." % old)
    except Exception as e:
        log("couldn't auto-set options (%s); in the GUI uncheck 'Suspend on thread "
            "start/exit' and 'Suspend on library load/unload'." % e)
    ida_dbg.add_bpt(master)
    log("breakpoint ARMED at master 0x%X." % master)
    log(">>> Make sure Ableton is actually producing sound (audio engine ON, track")
    log(">>> not frozen/bypassed). IDA will STOP at the master (disasm jumps there).")
    log(">>> THEN run this script AGAIN to dump.")
    ida_dbg.continue_process()

if __name__ == "__main__":
    main()
