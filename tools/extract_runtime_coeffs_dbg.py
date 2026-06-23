#!/usr/bin/env python3
# extract_runtime_coeffs_dbg.py — capture the 349 runtime-applied coefficients
# using IDA's OWN debugger (no Frida). Reads the exact values the live plugin
# computed -- the most-accurate-to-the-original source for the runtime-only
# coefficients (BBD clock, LFO/mix, voice patch), as MEASUREMENTS, not fitted.
#
# WHY THE DEBUGGER (vs static): these values are produced at runtime (some from
# the sample rate, the rest applied by the parameter system from the patch), so
# they exist only in a running instance. A debugger read is the same data as a
# Frida read, with the same trust level, but stays inside IDA.
#
# SELF-VALIDATION baked in (so a captured number isn't taken on faith):
#   1. base check  — the engine-state pointer (rcx at the master) must expose the
#      fields juno_chorus_init set statically (state[2199956]==0x80000,
#      [95828]/[101028]==1024). If not, we're reading the wrong object -> abort.
#   2. invariance  — snapshot the 349 offsets several times across blocks; any
#      offset that CHANGES is per-sample STATE, not a coefficient -> emitted as 0.
#   After pasting, also eyeball values vs docs/COEFF_PARAM_MAP.md, and the final
#   arbiter is the sample-accurate A/B of port vs plugin.
#
# HOW TO RUN
#   1. In a VST host, load Cloud 60 with the PATCH + CHORUS MODE you want to
#      reproduce. Make sure audio is running (the master is called every block).
#      Let it settle ~1-2 s after choosing the patch.
#   2. In IDA (this plugin's database): Debugger -> Attach to process -> the host.
#      IDA rebases this database onto the loaded module, so the addresses below
#      "just work". (Pick the Windows debugger backend.)
#   3. File -> Script file... -> extract_runtime_coeffs_dbg.py
#   4. It sets a breakpoint at the master, collects a few snapshots, prints the C
#      table AND writes runtime_coeffs_capture.txt next to the database. Paste the
#      table over the placeholder k[] in src/runtime_coeffs_data.c.
#
# If automation is flaky in your setup, see MANUAL MODE at the bottom.

import struct, os
import idc, ida_dbg, ida_name, idautils

IMAGE_BASE = 0x180000000
RVA_MASTER = 0x363380        # sub_180363380 within the plugin module
MASTER     = IMAGE_BASE + RVA_MASTER   # database EA (fallback only)
# Substring(s) (lowercased) of the plugin module's file name, used to find its
# REAL runtime base after attaching to the host (the DLL may load at a relocated
# base, so the database EA above won't bind a breakpoint unless IDA rebased). The
# shipped binary is "JUNO-60(VST3 64bit).vst3"; add hints if yours differs.
PLUGIN_HINTS = ["juno", "cloud"]
SNAPSHOTS  = 3               # number of snapshots to compare for invariance
SKIP       = 30              # block-hits to run between snapshots (catch slow drift)
KNOWN      = [(2199956, 0x80000), (95828, 1024), (101028, 1024)]  # static base check
OUT        = os.path.join(os.path.dirname(idc.get_idb_path()) or ".",
                          "runtime_coeffs_capture.txt")

OFFSETS = [
    272, 304, 368, 384, 592, 608, 624, 1040, 1056, 1072, 1088, 1856,
    1872, 1888, 1904, 1920, 1936, 1952, 1968, 1984, 2000, 2016, 2032, 2048,
    2064, 2080, 2096, 2112, 2560, 2784, 2800, 2816, 2832, 2848, 3040, 3264,
    3280, 3296, 3312, 3328, 3840, 3856, 3872, 3888, 3904, 3920, 3936, 3952,
    3968, 3984, 4000, 4016, 4032, 4048, 4064, 4080, 4096, 4112, 4128, 4144,
    4192, 4208, 4224, 5520, 6448, 6512, 6528, 6720, 6736, 6832, 6864, 7008,
    7024, 7296, 7312, 7328, 7344, 7360, 7376, 7392, 7408, 7424, 7440, 7456,
    7472, 7600, 7616, 7632, 9056, 9072, 9088, 9104, 9584, 9600, 9616, 9680,
    9824, 10176, 10192, 10208, 10224, 10240, 10256, 10272, 10288, 10304, 10320, 84304,
    84448, 84464, 84480, 84496, 84544, 84560, 85136, 85152, 85168, 85184, 85984, 86288,
    86304, 86320, 87056, 91120, 91136, 91152, 91168, 91184, 91200, 91216, 91232, 91248,
    91264, 91280, 96336, 96352, 96368, 96384, 96400, 96416, 101072, 101136, 101152, 101744,
    102352, 102368, 102384, 102400, 102416, 102432, 102448, 102464, 102480, 102496, 102512, 102528,
    102560, 102576, 102592, 102608, 102624, 102640, 102656, 102672, 102688, 4297584, 4297600, 4297616,
    4297632, 4297648, 4297664, 4297680, 4297696, 4297712, 4297728, 4297744, 4297760, 4297792, 4297808, 4297824,
    4297840, 4297856, 4297872, 4297888, 4297904, 4297920, 4297936, 4297952, 4297968, 4297984, 6395312, 6395328,
    6396128, 6396144, 6396160, 6396176, 6396192, 6396208, 6396224, 6396240, 6396256, 6396272, 6396288, 6396304,
    6396320, 6396336, 6396352, 6396368, 6396384, 6396400, 6396416, 6396432, 6396448, 6396464, 6396480, 6396496,
    6396512, 6429472, 6429488, 6430464, 6430480, 6430496, 6430512, 6430528, 6430544, 6430560, 6430576, 6430592,
    6430608, 6430624, 6430640, 6430656, 6430672, 6430688, 6430704, 6430720, 6430736, 6430752, 6430768, 6430784,
    6430800, 6430816, 6497168, 6497184, 6497200, 6497216, 6497232, 6497248, 6497264, 6497280, 6497296, 6497312,
    6497328, 6497344, 6497376, 6497392, 6497408, 6497424, 6497440, 6497456, 6497472, 6497488, 6497504, 10692016,
    10692032, 10693008, 10693024, 10693040, 10693056, 10693072, 10693088, 10693104, 10693120, 10693136, 10693152, 10693168,
    10693184, 10693200, 10693216, 10693232, 10693248, 10693264, 10693280, 10693296, 10693312, 10693328, 10693344, 10693360,
    10759376, 10759392, 10759408, 10759424, 10759440, 10759488, 10759504, 10759520, 10759536, 10759552, 10759568, 10759584,
    10759600, 10759616, 10759632, 10759648, 10759664, 10759680, 10759696, 10759712, 10759728, 10759744, 10759760, 10759776,
    10759792, 10759808, 10759824, 11022208, 11022212, 11022216, 11022220, 11022224, 11022228, 11022232, 11022236, 11022240,
    11022244, 11022248, 11022252, 11022256, 11022260, 11022264, 11022268, 11022272, 11022276, 11022280, 11022284, 11022288,
    11022292, 11022296, 11022300, 11022304, 11022308, 11022312, 11022316, 11022320, 11022324, 11022328, 11022332, 11022336,
    11022340,
]

def log(m): print("[dbg-capture] " + m)

def resolve_master():
    """Find the plugin module's runtime base and return the live address of the
    master. Falls back to the database EA if the module can't be found by name."""
    found = []
    for m in idautils.Modules():
        nm = m.name or ""
        found.append(nm)
        base = os.path.basename(nm).lower()
        if any(h in base for h in PLUGIN_HINTS):
            ea = m.base + RVA_MASTER
            log("plugin module: %s @ 0x%X -> master 0x%X" % (nm, m.base, ea))
            return ea
    log("plugin module (hints %s) not found among debugged modules." % PLUGIN_HINTS)
    log("loaded modules: " + ", ".join(os.path.basename(n) for n in found if n))
    log("set PLUGIN_HINT to a substring of the right one; using database EA 0x%X "
        "as a fallback (works only if IDA rebased the database)." % MASTER)
    return MASTER

def ru32(ea):
    b = idc.read_dbg_memory(ea, 4)
    return struct.unpack("<I", b)[0] if b and len(b) == 4 else None

def snapshot(base):
    return [ru32(base + off) for off in OFFSETS]

def verify_base(base):
    ok = True
    for off, exp in KNOWN:
        got = ru32(base + off)
        if got != exp:
            log("BASE CHECK FAILED: state[%d] = %s, expected 0x%X"
                % (off, ("0x%X" % got) if got is not None else "None", exp))
            ok = False
    if ok: log("base check OK — rcx is the engine state (static fields match).")
    return ok

def wait_break():
    """Continue and wait until the next suspension (our breakpoint)."""
    ida_dbg.continue_process()
    code = ida_dbg.wait_for_next_event(ida_dbg.WFNE_SUSP, -1)
    return code

def f32(bits):
    return struct.unpack("<f", struct.pack("<I", bits))[0] if bits is not None else 0.0

def emit(snaps):
    n = len(OFFSETS)
    base_snap = snaps[-1]            # latest (most settled)
    drifted, lines = [], []
    lines.append("/* captured via IDA debugger @ live plugin -- base-checked, "
                 "invariance-checked over %d snapshots */" % len(snaps))
    lines.append("static const juno_coeff k[] = {")
    row = "  "
    for i in range(n):
        vals = set(s[i] for s in snaps)
        bits = base_snap[i] if base_snap[i] is not None else 0
        if len(vals) != 1:           # changed across snapshots -> state, not coeff
            drifted.append(OFFSETS[i]); bits = 0
        row += "{%d,0x%08xu}, " % (OFFSETS[i], bits)
        if i % 4 == 3:
            row += "/* ~%g */" % f32(bits if bits else 0); lines.append(row); row = "  "
    if row.strip(): lines.append(row)
    lines.append("};")
    table = "\n".join(lines)
    with open(OUT, "w") as fh:
        fh.write(table + "\n")
        if drifted:
            fh.write("\n/* %d offsets varied across snapshots (STATE, emitted 0): %s */\n"
                     % (len(drifted), ", ".join(map(str, drifted))))
    log("===== table (also written to %s) =====" % OUT)
    print(table)
    if drifted:
        log("%d offsets varied -> treated as STATE, emitted 0: %s"
            % (len(drifted), ", ".join(map(str, drifted))))
    else:
        log("all %d offsets time-invariant -- consistent with coefficients." % n)
    log("next: cross-check vs docs/COEFF_PARAM_MAP.md, then A/B vs plugin.")

def main():
    if ida_dbg.get_process_state() == 0:
        log("No active debug session. Attach IDA to the host process first "
            "(Debugger -> Attach), then re-run this script."); return
    master = resolve_master()
    log("setting breakpoint at master 0x%X" % master)
    ida_dbg.add_bpt(master)
    try:
        # first hit -> verify base
        if wait_break() <= 0: log("debugger stopped unexpectedly."); return
        base = idc.get_reg_value("rcx")
        log("engine state (rcx) = 0x%X" % base)
        if not verify_base(base): return
        snaps = [snapshot(base)]
        # further spaced snapshots
        for s in range(1, SNAPSHOTS):
            for _ in range(SKIP):
                if wait_break() <= 0: log("stopped early."); break
            base = idc.get_reg_value("rcx")
            snaps.append(snapshot(base))
            log("snapshot %d/%d taken" % (s + 1, SNAPSHOTS))
        emit(snaps)
    finally:
        ida_dbg.del_bpt(master)
        log("breakpoint removed. (process left suspended; resume or detach in IDA.)")

# ── MANUAL MODE ───────────────────────────────────────────────────────────────
# If the continue/wait loop misbehaves: in the Python console get the master's
# live address (handles the relocated DLL base), set a breakpoint, let it hit
# (audio running), then read once:
#     import sys; m = sys.modules[__name__]
#     ea = m.resolve_master(); import ida_dbg; ida_dbg.add_bpt(ea)   # then resume in IDA
#     # after it breaks:
#     base = idc.get_reg_value("rcx")
#     m.verify_base(base); m.emit([m.snapshot(base)])   # single-snapshot (no invariance)
# Single-snapshot skips the state/coeff check, so prefer the automated path.

if __name__ == "__main__":
    main()
