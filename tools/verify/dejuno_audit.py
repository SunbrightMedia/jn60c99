#!/usr/bin/env python3
"""dejuno_audit.py -- E4: no needless JUNO constant in an ITEM-7 tool.

END_GOAL item 7 (USER-BINDING): the process must be repeatable for the next
synth. FINAL_GUIDE: "Hardcoding a JUNO constant into [an item-7 tool] is a
defect against END_GOAL item 7 in the same way a wrong coefficient is a defect
against item 1." This is the audit that was owed.

WHAT IS AND IS NOT AUDITED. The DSP transcription is JUNO by definition and is
NOT audited. The audit covers the MANIFEST below: the tools that claim to be
the reusable method -- the transformers, gates, generators and harnesses the
JX-3P port will run again. A tool not yet in the manifest is not yet claimed.

HOW A LEGITIMATE CONSTANT IS CARRIED. A generic tool may still need a synth's
number TODAY. It does so by (a) reading it from a config/bank/generated header,
or (b) carrying the literal on a line marked `JUNO-BOUND:` with a reason. The
marker is not an escape hatch: it is the list of exactly what must be
parameterised before the next synth, and this audit PRINTS that list.

THE SIGNATURES are high-signal literals only -- bank geometry, blob offsets,
state cell addresses, port addresses. Deliberately NOT '64' or '8': voice and
patch counts collide with too much innocent arithmetic to grep for.

usage: dejuno_audit.py [--tooth]        exit 0 = clean
"""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))

# ---- the ITEM-7 manifest: files that claim to travel to the next synth ----
MANIFEST = [
    # the mechanical transformers (the method's core)
    "tools/engineb/arm_xform.py",
    "tools/translate_voice.py",
    "tools/translate_master.py",
    "tools/translate_init.py",
    "tools/translate_chorus_init.py",
    # generators that derive rather than restate
    "tools/engineb/devboot/make_boot.py",
    "tools/engineb/gen_devcells.py",
    # the boundary that explicitly promises synth-agnosticism
    "tools/engineb/boundary_check.py",
    "event/juno_event.h",
    # the generic optimiser
    "tools/opt/regcache.py",
    # O6: the role/link decision layer travels whole to the next pair of chips
    "esp32s3/main/s3_role.h",
    "esp32s3/main/s3_link.h",
]

# ---- JUNO signatures: (regex, what it is) ---------------------------------
SIGS = [
    (r"\b20223\b",              "BANK_STRIDE (JUNO preset bank geometry)"),
    (r"\b(?<!0x)23\s*[,)]?\s*#?\s*(?:BANK_HEADER|bank header)", "BANK_HEADER 23 named"),
    (r"\bBANK_HEADER\s*=\s*23\b", "BANK_HEADER literal"),
    (r"\b134\b",                "the 134-byte JUNO patch record"),
    (r"\b650\b",                "record offset 650 (DELAY TYPE)"),
    (r"\b5520\b|\b7600\b|\b10320\b|\b3968\b", "CONDITION/UNISON state cells"),
    (r"\b6497616\b|\b8594784\b|\b10693488\b|\b10726272\b", "port ring addresses"),
    (r"\b1856\b|\b6864\b|\b9680\b", "note-path smoother cells"),
    (r"presetbankog1",          "the JUNO factory bank filename"),
    (r"\bjuno_bank_\w+",        "juno_bank_* API (bank-layout-bound)"),
    (r"\bJUNO_VOICE_MAIN_STRIDE\b", "JUNO state stride"),
]

ALLOW = re.compile(r"JUNO-BOUND:")   # carried, listed, owed a parameter

def scan(path, text):
    hits, owed = [], []
    for n, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        for rx, what in SIGS:
            if re.search(rx, line):
                (owed if ALLOW.search(line) else hits).append((n, what, stripped[:88]))
                break
    return hits, owed

def main():
    if "--tooth" in sys.argv:
        h, _ = scan("tooth", "stride = 20223  # planted\n")
        if not h:
            print("TOOTH NOT CAUGHT: a planted BANK_STRIDE went unseen"); return 1
        print("tooth caught: planted 20223 detected"); return 0

    bad = 0
    print("=== E4 DE-JUNO AUDIT -- %d item-7 files ===" % len(MANIFEST))
    for rel in MANIFEST:
        p = os.path.join(REPO, rel)
        if not os.path.exists(p):
            print("  %-44s *** MISSING (manifest rot)" % rel); bad += 1; continue
        with open(p, errors="replace") as f:
            hits, owed = scan(rel, f.read())
        tag = "clean" if not hits else "*** %d UNMARKED JUNO constant(s)" % len(hits)
        if owed and not hits:
            tag = "clean (%d JUNO-BOUND, owed a parameter)" % len(owed)
        print("  %-44s %s" % (rel, tag))
        for n, what, ln in hits:
            print("      L%-5d %s\n             %s" % (n, what, ln)); bad += 1
        for n, what, ln in owed:
            print("      L%-5d owed: %s" % (n, what))
    print("\n%s" % ("E4: CLEAN -- every carried constant is marked and listed."
                    if not bad else "E4: %d defect(s) against END_GOAL item 7." % bad))
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main())
