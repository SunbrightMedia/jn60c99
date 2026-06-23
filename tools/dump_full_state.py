#!/usr/bin/env python3
# dump_full_state.py — capture the live engine-state block by SCANNING memory for
# its fingerprint. No breakpoints, no dependence on which build of the plugin runs.
#
# WHY: breakpoints on every DSP function never fired while audio played -> the
# running audio path is a different build than our database (CPU-specific variant).
# But the engine STATE is a ~11.5 MB heap block with a unique signature set by the
# chorus constructor: state[2199956]==0x80000, state[95828]==1024, [101028]==1024.
# We just suspend the process, enumerate its memory, and find the block by that
# signature -- then dump it twice (t0/t1) so offline we can extract every
# coefficient and tell coeff-vs-state.
#
# HOW TO RUN
#   1. Host: JUNO-60 loaded with the PATCH + CHORUS MODE you want (a note doesn't
#      even need to be held -- the state exists as soon as the plugin initialised).
#   2. IDA attached to the host (Local Windows debugger).
#   3. File -> Script file... -> dump_full_state.py
#   4. It suspends, scans, finds the state, dumps state_dump/. Zip & upload.

import os, struct
import idc, ida_dbg

SIG = [(2199956, 0x80000), (95828, 1024), (101028, 1024)]   # state fingerprint
MAXOFF      = max(o for o, _ in SIG)                          # 2199956
MIN_REGION  = MAXOFF + 16                                     # region must cover the sig
DUMP_SIZE   = 0xB80000        # ~11.5 MB dumped from the found base
RCHUNK      = 0x100000        # 1 MB read chunks
REGION_CAP  = 0x4000000       # scan at most 64 MB per region
OUTDIR      = os.path.join(os.path.dirname(idc.get_idb_path()) or ".", "state_dump")

def log(m): print("[scan] " + m)

def regions():
    """List (start, end, perm) of debuggee memory regions, robustly."""
    out = []
    try:
        import ida_idd, ida_dbg as _d
        mi = ida_idd.meminfo_vec_t()
        if _d.get_memory_info(mi) > 0:
            for r in mi: out.append((r.start_ea, r.end_ea, getattr(r, "perm", 0)))
            return out
    except Exception as e:
        log("get_memory_info failed (%s); trying segments." % e)
    try:
        ida_dbg.refresh_debugger_memory()
    except Exception:
        pass
    ea = idc.get_first_seg()
    while ea != idc.BADADDR:
        out.append((ea, idc.get_segm_end(ea), idc.get_segm_attr(ea, idc.SEGATTR_PERM)))
        ea = idc.get_next_seg(ea)
    return out

def read_region(start, size):
    size = min(size, REGION_CAP)
    buf = bytearray(); off = 0
    while off < size:
        sz = min(RCHUNK, size - off)
        b = idc.read_dbg_memory(start + off, sz)
        if off == 0 and (not b or len(b) != sz):
            return None                      # region not readable
        buf += b if (b and len(b) == sz) else b"\x00" * sz
        off += sz
    return bytes(buf)

def find_state():
    need = struct.pack("<I", SIG[0][1])      # 0x80000 little-endian
    v1024 = struct.pack("<I", 1024)
    regs = regions()
    log("enumerated %d memory regions; scanning ones >= %d bytes..." % (len(regs), MIN_REGION))
    scanned = 0
    for (s, e, perm) in regs:
        size = e - s
        if size < MIN_REGION: continue
        buf = read_region(s, size)
        if buf is None: continue
        scanned += 1
        idx = buf.find(need)
        while idx != -1:
            p = idx - SIG[0][0]
            if p >= 0 and p + 101032 <= len(buf) \
               and buf[p+95828:p+95832] == v1024 and buf[p+101028:p+101032] == v1024:
                log("FOUND state fingerprint at 0x%X (region 0x%X..0x%X)" % (s + p, s, e))
                return s + p
            idx = buf.find(need, idx + 1)
    log("scanned %d readable large regions; fingerprint NOT found." % scanned)
    return None

def ru32(ea):
    b = idc.read_dbg_memory(ea, 4)
    return struct.unpack("<I", b)[0] if b and len(b) == 4 else None

def dump_state(base, path):
    n = 0
    with open(path, "wb") as fh:
        while n < DUMP_SIZE:
            sz = min(0x10000, DUMP_SIZE - n)
            b = idc.read_dbg_memory(base + n, sz)
            fh.write(b if b and len(b) == sz else b"\x00" * sz)
            n += sz
    log("wrote %s (%d bytes)" % (os.path.basename(path), DUMP_SIZE))

def main():
    if ida_dbg.get_process_state() == 0:
        log("No debug session. Attach IDA to the host first, then re-run."); return
    # make sure the process is suspended so memory is stable
    if ida_dbg.get_process_state() > 0:
        log("suspending process for a stable scan...")
        ida_dbg.suspend_process()
        ida_dbg.wait_for_next_event(ida_dbg.WFNE_SUSP, 10)

    base = find_state()
    if base is None:
        log("Could not find the engine state. Make sure JUNO-60 is loaded/initialised")
        log("in the host. If it still fails, tell the porting side the region list above.")
        return

    os.makedirs(OUTDIR, exist_ok=True)
    sr = ru32(base + 16)
    log("dumping t0 (big read; a few seconds)...")
    dump_state(base, os.path.join(OUTDIR, "state_t0.bin"))
    # resume briefly so per-sample state advances, then re-suspend and dump t1 from
    # the SAME base (a heap block doesn't move).
    try:
        ida_dbg.continue_process(); ida_dbg.wait_for_next_event(ida_dbg.WFNE_SUSP, 1)
        ida_dbg.suspend_process();  ida_dbg.wait_for_next_event(ida_dbg.WFNE_SUSP, 5)
    except Exception:
        pass
    log("dumping t1...")
    dump_state(base, os.path.join(OUTDIR, "state_t1.bin"))
    with open(os.path.join(OUTDIR, "meta.txt"), "w") as fh:
        fh.write("state_base=0x%X\nsize=0x%X\nsample_rate_bits=0x%08X\n"
                 % (base, DUMP_SIZE, sr or 0))
        fh.write("# fill in: patch name, chorus mode, MIDI note (if any)\n")
    log("DONE. Zip state_dump/ and upload it.")

if __name__ == "__main__":
    main()
