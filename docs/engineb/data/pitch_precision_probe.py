#!/usr/bin/env python3
"""pitch_precision_probe.py — DECISION MEASUREMENT for eb_pitch precision.

Runs the ENGINE B NULL HARNESS (tools/engineb/null_b.py, unmodified) with the
pitch module's eb_pitch.c REPLACED by a precision variant in the candidate
build only. Uses null_b's own _plant hook: the variant file is copied over
engine_b/eb_pitch.c in the COPIED build tree, so the real build path, the real
two-process render and the real -100/-80 dB gates all apply.

Cases, each over the FULL 30-scenario set (not --quick):
  control  : --module pitch, unmutated  (must be EXACTLY 0 -- proves any
             residual below is the variant's own)
  float32  : all arithmetic float (Variant A)
  dekker   : only run if float32 FAILS (Variant B)
"""
import sys, os, shutil
sys.path.insert(0, "/home/user/jn60c99/tools/engineb")
import null_b

SCRATCH = os.path.dirname(os.path.abspath(__file__))
VARIANTS = {
    "float32": os.path.join(SCRATCH, "pitch_var_float32.c"),
    "dekker":  os.path.join(SCRATCH, "pitch_var_dekker.c"),
    "dekker_drow": os.path.join(SCRATCH, "pitch_var_dekker_drow.c"),
}


def _plant(tmp, mutate):
    """Replace engine_b/eb_pitch.c in the copied tree with the named variant."""
    src = VARIANTS[mutate]
    dst = os.path.join(tmp, "engine_b", "eb_pitch.c")
    assert os.path.exists(src), src
    assert os.path.exists(dst), dst
    shutil.copyfile(src, dst)


null_b._plant = _plant

if __name__ == "__main__":
    cases = sys.argv[1:] or ["control", "float32"]
    print("=== eb_pitch precision null (gates: global <= %.0f dB, "
          "block <= %.0f dB) ===" % (null_b.THRESH_DB, null_b.BLOCK_THRESH_DB))
    ref = null_b.oracle_render(False)          # ONE oracle render, reused
    for name in cases:
        mut = None if name == "control" else name
        fails, worst, caught = null_b.run(
            ["pitch"], False, mutate=mut, ref=ref,
            label="pitch variant: %s" % name, verbose=False)
        print("SUMMARY %s: fails=%d worst_global=%s caught=%s\n"
              % (name, fails,
                 "EXACTLY0" if worst is None else "%.1f dB" % worst,
                 sorted(caught) if caught else "none"))
