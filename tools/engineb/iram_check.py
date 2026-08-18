#!/usr/bin/env python3
"""iram_check.py -- every linker.lf entry must actually PLACE something.

WHY THIS EXISTS. An entry in esp32s3/main/linker.lf names an OBJECT FILE. If
the object does not exist -- because the module was split, or the file is named
differently from the module -- ldgen matches NOTHING and says NOTHING. The
build is green, the file looks right, and the code stays in flash.

That is not hypothetical. MEASURED 2026-08-17, on a green build:

    entry            file that actually exists     symbol left in flash
    eb_vca           eb_vca_hpf.c                  eb_vca_tick
    eb_master        eb_master_in.c/eb_master_out.c eb_master_in_tick
    eb_pitch         eb_pitch_fork.c               eb_pitch_fork_eval

plus every delay arm and every effect arm, which were never listed at all. The
engine had been shipping with its per-sample delay and effect arms fetched from
XIP flash, behind a small instruction cache, at 44,100 calls a second.

THE CLASS. This is a SELECTOR THAT SELECTS NOTHING and reports success. The
same shape has been paid for three times in this project already:
  * a teeth anchor that stopped matching and ASSERTED, silencing every gate
    downstream of it for eight days (playbook 54)
  * a coefficient audit that scanned a region the code had moved out of and
    reported "0 cells cached" about a file caching 266
  * a ledger fingerprint that hashes 30 scenarios while the gate runs 36
The cure is always the same: make the selector prove it selected something.

WHAT THIS CHECKS
  1. Every `<obj> (noflash_text)` entry in linker.lf corresponds to a real
     object in the build, and that object contributed at least one symbol to
     IRAM. An entry that placed nothing is an ERROR, not a warning.
  2. No symbol on the KNOWN PER-SAMPLE list is left in flash.

It reads the ELF, never the linker script's intent -- which is the whole point
(playbook 32: a knob is not a knob until something reads it).

USAGE
    iram_check.py [<elf>]        default esp32s3/build/juno_s3.elf
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
LF = os.path.join(REPO, "esp32s3", "main", "linker.lf")
ELF = os.path.join(REPO, "esp32s3", "build", "juno_s3.elf")
NM = "xtensa-esp32s3-elf-nm"

# Symbols this project knows run on the per-sample path. A symbol here found in
# flash is a defect regardless of what linker.lf says. Extend it when a new
# per-sample entry point appears -- that is cheaper than rediscovering this.
PER_SAMPLE = [
    "eb_engine_render_range", "eb_master_render",
    "eb_dly1_tick", "eb_dly23_tick", "eb_dly5_tick", "eb_dly_t4_tick",
    "eb_delay_process", "eb_fx_e0_tick", "eb_fx_e1_tick", "eb_fx_e5_tick",
    "eb_master_in_tick", "eb_master_out_tick", "eb_nsvf_tick",
    "eb_reverb_process", "eb_chorus_tick_x", "eb_vca_tick",
    "eb_pitch_fork_eval", "eb_pitch_poly",
]


def entries():
    """The objects linker.lf claims to place. Commented lines do not count."""
    out = []
    for ln in open(LF):
        s = ln.strip()
        if s.startswith("#"):
            continue
        m = re.match(r"^([A-Za-z0-9_]+)\s*\(noflash_text\)\s*$", s)
        if m:
            out.append(m.group(1))
    return out


def symbols(elf):
    r = subprocess.run([NM, elf], capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit("iram_check: %s failed on %s -- is the IDF export "
                         "sourced?\n%s" % (NM, elf, r.stderr[:400]))
    out = []
    for ln in r.stdout.splitlines():
        p = ln.split()
        if len(p) == 3 and p[1] in "TtDdBbRr":
            out.append((p[0], p[2]))
    return out


def main():
    elf = sys.argv[1] if len(sys.argv) > 1 else ELF
    if not os.path.exists(elf):
        raise SystemExit("iram_check: no ELF at %s -- build first" % elf)
    syms = symbols(elf)
    iram = {n for a, n in syms if a.startswith("403")}
    flash = {n for a, n in syms if a.startswith("42")}
    bad = 0

    print("=== linker.lf entries that placed NOTHING ===")
    ents = entries()
    # AN ENTRY'S SYMBOLS ARE READ FROM ITS OBJECT, not guessed from its name.
    # The first version of this check assumed an object named eb_foo defines
    # symbols starting eb_foo and reported ELEVEN false failures on a build
    # whose per-sample list was completely clean -- eb_delay_t5.c defines
    # eb_dly5_tick, eb_vca_hpf.c defines eb_vca_tick, eb_dsp.c defines
    # eb_pitch_poly. A check that cries wolf is the same defect as one that
    # sleeps: both stop being read.
    objdir = os.path.join(REPO, "esp32s3", "build")
    for e in ents:
        obj = None
        for root, _, files in os.walk(objdir):
            if e + ".c.obj" in files:
                obj = os.path.join(root, e + ".c.obj")
                break
        if obj is None:
            print("  *** %-16s NO OBJECT BUILT (entry matches nothing)" % e)
            bad += 1
            continue
        r = subprocess.run([NM, "--defined-only", obj],
                           capture_output=True, text=True)
        defined = [l.split()[-1] for l in r.stdout.splitlines()
                   if len(l.split()) == 3 and l.split()[1] in "TtDdBbRr"]
        if not defined:
            continue                      # header-only or fully inlined
        placed = [d for d in defined if d in iram]
        if not placed:
            print("  *** %-16s defines %d symbol(s), NONE in IRAM"
                  % (e, len(defined)))
            bad += 1
    print("  %d entr%s checked" % (len(ents), "y" if len(ents) == 1 else "ies"))

    print("=== per-sample symbols left in FLASH ===")
    for s in PER_SAMPLE:
        if s in flash:
            print("  *** %-24s is in flash" % s)
            bad += 1
        elif s not in iram:
            print("      %-24s not found (renamed or inlined?)" % s)
    print()
    print("IRAM engine symbols: %d" % len([n for n in iram
                                           if n.startswith(("eb_", "juno_"))]))
    print("IRAM CHECK: %s" % ("PASS" if bad == 0 else "FAIL (%d)" % bad))
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
