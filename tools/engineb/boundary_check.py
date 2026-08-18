#!/usr/bin/env python3
"""boundary_check.py -- O1's structural gate: NOTHING BYPASSES THE EVENT QUEUE.

WHY THIS EXISTS AND WHY A COMMENT WOULD NOT DO. FINAL_GUIDE O1 (was C11) is a
rule about what the code MAY NOT DO:

    "Keybed, panel, DIN, USB all submit events through one small header.
     Nothing else may reach the engine."

A rule like that decays the first time somebody adds an input in a hurry. The
project already paid for exactly this shape once: two note entry points
deciding velocity separately is how the assigner-mode defect survived for
months (docs/ASSIGNER_MODE_FINDING.md). The cure there was one entry point.
This is what keeps it one.

WHAT IT CHECKS, by reading the firmware source rather than trusting it:

  1. The ALLOCATOR is called from exactly ONE function, and that function is
     the queue's consumer. A second caller is a back door: it reaches the
     engine without passing the cap, so it can neither be deferred nor
     counted, and THE INVARIANT's rules 2, 3 and 4 stop holding for it.
  2. Every input source SUBMITS. Each parser in the firmware calls a
     juno_event_* function -- so a new input that forgot the boundary shows up
     here rather than in a stuck note six weeks later.
     ⚠ ITS GRANULARITY IS PER FILE, stated because a check whose reach is
     assumed is worse than one whose reach is known: a parser that submits on
     one path and bypasses on another PASSES here. Check 1 is what catches the
     bypass, by naming the only function allowed to reach the engine. Together
     they cover it; check 2 alone does not.
  3. The boundary header carries NO JUNO CONSTANT (END_GOAL item 7). The
     header travels to the JX-3P; a JUNO constant in it is a defect there in
     the way a wrong coefficient is a defect here.

SEEN TO FAIL: tools/engineb/boundary_teeth.sh plants each violation and
requires this to catch it. A gate that has never gone red is an untested
detector -- playbook defect 1.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
FW = os.path.join(REPO, "esp32s3", "main")
HDR = os.path.join(REPO, "event", "juno_event.h")

# The engine entry points that MUST sit behind the queue. Extend this when a
# new one appears; that is cheaper than rediscovering why a note vanished.
BEHIND_THE_QUEUE = ["eb_alloc_note_on", "eb_alloc_note_off"]

# The function allowed to call them: the queue's consumer.
CONSUMER = "ev_apply"


def strip_comments(src):
    """Comments describe intent. This gate reads CODE."""
    src = re.sub(r"/\*.*?\*/", " ", src, flags=re.S)
    src = re.sub(r"//[^\n]*", " ", src)
    return src


def enclosing_function(src, pos):
    """Name of the function a byte offset falls in.

    Finds the last line before `pos` that starts in column 0 and looks like a
    definition. Crude on purpose: the firmware is one plain C file per port and
    a parser here would be a second thing to maintain.
    """
    name = "<file scope>"
    for m in re.finditer(r"(?m)^[A-Za-z_][A-Za-z0-9_ \*\t]*?([A-Za-z_][A-Za-z0-9_]*)\s*\([^;]*?\)\s*\{",
                         src):
        if m.start() > pos:
            break
        name = m.group(1)
    return name


def main():
    bad = 0
    srcs = [f for f in sorted(os.listdir(FW)) if f.endswith(".c")]

    print("=== 1. who reaches the engine? ===")
    for fn in srcs:
        raw = open(os.path.join(FW, fn)).read()
        src = strip_comments(raw)
        for sym in BEHIND_THE_QUEUE:
            for m in re.finditer(r"\b%s\s*\(" % re.escape(sym), src):
                where = enclosing_function(src, m.start())
                if where != CONSUMER:
                    print("  *** %s calls %s() from %s(), NOT %s(). That is a "
                          "back door: it reaches the engine without the cap, "
                          "so it cannot be deferred or counted."
                          % (fn, sym, where, CONSUMER))
                    bad += 1
                else:
                    print("      %-22s %s() <- %s()  OK" % (fn, sym, where))

    print("=== 2. does every input SUBMIT? ===")
    for fn in srcs:
        raw = open(os.path.join(FW, fn)).read()
        src = strip_comments(raw)
        # A file that parses input is one that mentions a note. If it does and
        # never submits, it either has a private path or is dead code.
        # NOTE THE TRAILING \\w*: the first version of this line used \\btud_midi\\b,
        # which does NOT match tud_midi_available() because '_' is a word
        # character -- so s3_usbmidi.c was silently exempt from check 2 and the
        # gate reported PASS while USB still went through a shim. A pattern
        # that matches nothing is playbook 55's shape all over again.
        parses = re.search(r"(uart_read_bytes|tud_midi\w*|con_held)\b", src)
        submits = re.search(r"\bjuno_event_(note_on|note_off|param)\s*\(", src)
        if parses and not submits:
            print("  *** %s reads input and never calls juno_event_*(). Every "
                  "input crosses the boundary; this one does not." % fn)
            bad += 1
        elif parses:
            print("      %-22s parses input and submits  OK" % fn)

    print("=== 3. is the header still synth-agnostic? ===")
    hdr = strip_comments(open(HDR).read())
    # Names that would tie the boundary to THIS instrument. `juno_` is the
    # project's own prefix and is allowed; a JUNO PARAMETER is not.
    leaks = []
    # ⚠ NO \b AROUND THESE. '_' is a word character, so r"\bVCF\b" does NOT
    # match JUNO_VCF_CUTOFF_PARAM -- which is exactly how a planted constant
    # walked past this check, and exactly how tud_midi_available walked past
    # check 2 an hour earlier. Same defect, twice, in one afternoon: a pattern
    # that cannot match what it is looking for reports success (playbook 55).
    # Identifiers in C are glued with underscores; match the substring.
    for pat in (r"DCO", r"VCF", r"VCA", r"chorus", r"JUNO_?60",
                r"eb_[a-z_]+", r"juno_(patch|cell|coef|render|apply)"):
        for m in re.finditer(pat, hdr, re.I):
            leaks.append(m.group(0))
    if leaks:
        print("  *** the boundary header names instrument internals: %s"
              % ", ".join(sorted(set(leaks))))
        print("      END_GOAL item 7: this header travels to the next synth.")
        bad += 1
    else:
        print("      no instrument internals in juno_event.h  OK")

    print()
    print("BOUNDARY CHECK: %s" % ("PASS" if bad == 0 else "FAIL (%d)" % bad))
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
