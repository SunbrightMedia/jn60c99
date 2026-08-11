"""lfo_patch_scan.py -- WHICH FACTORY PATCHES ROUTE THE LFO TO AUDIO?

WHY THIS EXISTS. The listen firmware's coefficient blob carries ONE patch, and
on 2026-08-11 that patch turned out to route no LFO anywhere: the modulation ran
and reached nothing, so a proven LFO fix produced EXACTLY 0 audio difference.
Demonstrating the fix audibly needs a blob built from a patch that actually uses
the LFO -- and picking one by its NAME would be a guess.

WHAT IT DOES. For each of the 64 factory patches it applies the bank through the
PORT's own recall, plays one note, dumps the coefficient block the firmware
would freeze, and then asks the only question that matters: does changing the
LFO input change the modulation output? That is answered by calling
eb_modcv_tick twice through the shim's own engine -- executed, not inferred from
a parameter index.

The report is ranked, so the top row is the patch to regenerate the blob from.
"""
import os
import sys
import ctypes
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "tools", "engineb"))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import null_b            # noqa: E402
import null_ab           # noqa: E402
import truth             # noqa: E402

NOTES = [48, 55, 60, 64, 67, 72, 76, 79]


def main():
    tmp = tempfile.mkdtemp(prefix="lfoscan_")
    so = os.path.join(tmp, "eb.so")
    # The STANDALONE shim, for the same reason gen_listen_coefs.py uses it: it
    # is the one that owns the eb_render_coefs the firmware actually runs from.
    null_b.build(so, ["standalone"])
    lib = null_ab.load(so)
    for fn in ("ebsh_dump_sizes", "ebsh_lfo_reach"):
        if not hasattr(lib, fn):
            raise SystemExit(
                "%s missing from the standalone shim. ebsh_lfo_reach is the "
                "executed test this scan is built on; add it to "
                "engine_b/shim/standalone/juno_driver.c." % fn)

    bank = open(truth.BANK, "rb").read()
    lib.ebsh_lfo_reach.restype = ctypes.c_float

    rows = []
    for patch in range(64):
        ctx = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
        lib.juno_gui_apply_bank(ctx, bank, len(bank), patch)
        lib.juno_gui_note_on(ctx, NOTES[0], 100)
        buf = (ctypes.c_float * 1024)()
        lib.juno_gui_render(ctx, buf, 1)
        reach = float(lib.ebsh_lfo_reach(ctx))
        lib.juno_gui_destroy(ctx)
        rows.append((reach, patch))

    rows.sort(reverse=True)
    live = [r for r in rows if r[0] > 0.0]
    print("patches whose LFO reaches the modulation outputs: %d of 64"
          % len(live))
    print("%-7s %s" % ("patch", "reach (max |d(out)/d(lfo)| over the six inputs)"))
    for reach, patch in rows[:12]:
        print("%-7d %.6g%s" % (patch, reach, "" if reach > 0 else "   <- DEAD"))
    if not live:
        print("\nNO PATCH ROUTES THE LFO. That would be a finding in itself and "
              "should be disbelieved until the probe is checked -- a scan that "
              "reports zero everywhere is usually measuring nothing.")
        return 1
    print("\nregenerate the blob with:  python3 tools/engineb/gen_listen_coefs.py %d"
          % live[0][1])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
