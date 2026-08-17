#!/usr/bin/env python3
"""ring_derive.py -- SIZE THE DELAY RINGS FROM THE PARAMETER, not from the bank.

THIS IS L1'S PRECONDITION, and the repo already says so in its own words --
docs/engineb/data/fx_chain_price.md:38-41:

    "CAVEAT, STATED RATHER THAN BURIED: 31,007 samples is the deepest read THIS
     BANK produces. A shipping allocation must be derived from the DELAY TIME
     parameter's MAXIMUM, not from observed lag, or a patch outside the battery
     reads past the end. That derivation is NOT done, and it is the
     precondition for this lever, not a footnote to it."

Moving the rings into internal SRAM is worth ~2,634 cycles at best
(M2_WORST_CASE.md). Moving them at the WRONG SIZE is a read past the end of an
array on a patch nobody tested -- silence or noise on a user's synth, and the
kind of defect that is found by a customer rather than a gate. So the size
comes first.

WHY IT MUST BE MEASURED AND CANNOT BE READ OFF A COEFFICIENT
engine_b/eb_master.c's probe carries the reason (null_b.py:249-255): "the read
index is a smoothed, modulated value", so no cell holds the answer. The tap in
eb_delay_t1.c:184 is (int)(float)(v433 * -16384.0) where v433 is the smoothed,
LFO-modulated time -- the maximum of a product of two moving values, not a
constant. It is therefore swept through the ENGINE'S OWN CODE, exactly as the
factory-bank figure was, but over the PARAMETER'S range instead of the bank's.

WHAT IS SWEPT
  DELAY TIME  blob position 53 (juno_apply.c:925), full 0..255
  DELAY SYNC  blob position 59 -- OFF and ON. Sync ties the time to tempo, so
              it can reach lengths the free-running range does not.
  the arm     one factory patch per DELAY TYPE, chosen by the port's own
              juno_bank_delay_modes, so each ring is actually exercised.

The rate is the DEVICE's 44,100 (esp32s3/main/juno_s3_listen.c:214). A ring is
samples, so a higher host rate would need a proportionally longer one; the
report states this rather than leaving it implied.

USAGE
    ring_derive.py            # sweep and report the required length per ring
    ring_derive.py --teeth    # prove the sweep can move the answer
"""
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))

RING_LOG = "/tmp/eb_ring.log"
TIME_POS, SYNC_POS = 53, 59          # blob positions, juno_apply.c:925-926

# Settle: the tap is a SMOOTHED value, so a step must be given time to arrive
# before the deepest read means anything. 1 s at 44.1 k is far past any
# smoother in this engine and costs little in a sweep this size.
SETTLE = 44100


def doctor(bank, patch, pos, val):
    """Set one front-panel byte, through the SAME nibble-pair encoding the
    bank uses (null_b.py:372-391, juno_apply.c:925: blob byte = 2*pos, high
    nibble then low)."""
    # juno_apply.c:125-128. BLOB_OFF IS 16. An earlier version of this file
    # used 662 -- the rec[650] area the DTYPE decode reads -- so every write
    # landed on unrelated bytes, the sweep was a NO-OP, and the swept column
    # came back byte-identical to the factory one. Verified by reading the
    # value back through juno_bank_delay_modes (see verify_doctor).
    HDR_REC, STRIDE_REC, BLOB_OFF = 23, 20223, 16
    b = bytearray(bank)
    o = HDR_REC + patch * STRIDE_REC + BLOB_OFF + 2 * pos
    b[o] = (b[o] & 0xF0) | ((val >> 4) & 0xF)
    b[o + 1] = (b[o + 1] & 0xF0) | (val & 0xF)
    return bytes(b)


def verify_doctor(bank, patch):
    """PROVE the plant lands before trusting anything it produces.

    This exists because the plant did NOT land once: with the wrong BLOB_OFF
    the sweep changed no byte the engine reads, and every ring reported exactly
    its factory depth. That is a silent no-op, and the FIRST version of the
    teeth below could not see it -- they asked whether the swept depth stayed
    UNDER the factory depth, which a no-op satisfies perfectly. A tooth that a
    broken tool passes is the defect this project has paid for repeatedly."""
    import ctypes
    import freshlib
    fl = freshlib.load()
    fl.juno_bank_delay_modes.argtypes = [
        ctypes.c_char_p, ctypes.c_int, ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int)]

    def rd(b):
        t = ctypes.c_int(-1)
        fl.juno_bank_delay_modes(b, patch, ctypes.byref(t), None, None)
        return t.value

    for want in (0, 77, 255):
        got = rd(doctor(bank, patch, TIME_POS, want))
        if got != want:
            raise SystemExit(
                "ring_derive: THE PLANT DOES NOT LAND. Set DELAY TIME=%d on "
                "patch %d and juno_bank_delay_modes read back %d. Every number "
                "this tool would print is about an unmodified bank. Check "
                "BLOB_OFF against juno_apply.c:125-128." % (want, patch, got))
    return True


def read_log():
    """max maxlag per ring across every line the probe appended."""
    out = {}
    if not os.path.exists(RING_LOG):
        return out
    for ln in open(RING_LOG):
        p = ln.split()
        if len(p) >= 3 and p[1].startswith("maxlag="):
            name = p[0]
            lag = int(p[1].split("=")[1])
            out[name] = max(out.get(name, 0), lag)
    return out


def sweep(so, bank, patches, values, syncs, frames):
    """Drive the engine over the parameter grid.

    ⚠ MUST RUN IN ITS OWN PROCESS. eb_master.c's probe reports from a
    __attribute__((destructor)), so /tmp/eb_ring.log is written at process
    EXIT and not before. The first version of this file swept and then read
    the log inside the SAME interpreter, and got an empty table -- the run had
    not reported yet. An empty table is a loud failure and was easy to catch;
    a partially-flushed one would not have been. The parent therefore forks a
    worker (see --worker) and reads the log only after it has exited."""
    import ctypes
    lib = ctypes.CDLL(so)
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                    ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    buf = (ctypes.c_float * (2 * frames))()
    for pidx in patches:
        for sy in syncs:
            for v in values:
                if v is None:            # the FACTORY pass: bank untouched
                    b = bank
                else:
                    b = doctor(bank, pidx, TIME_POS, v)
                    b = doctor(b, pidx, SYNC_POS, sy)
                ctx = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
                lib.juno_gui_apply_bank(ctx, b, len(b), pidx)
                lib.juno_gui_note_on(ctx, 60, 100)
                n = 0
                while n < frames:
                    k = min(4096, frames - n)
                    lib.juno_gui_render(ctx, buf, k)
                    n += k
                lib.juno_gui_destroy(ctx)


def worker(so, mode):
    """One PASS, in its own process, so the probe's destructor fires."""
    import e2e_emu as E
    bank = E.bank_bytes()
    patches = [int(x) for x in os.environ["RD_PATCHES"].split(",")]
    if mode == "factory":
        sweep(so, bank, patches, [None], [None], SETTLE)
    else:
        vals = [int(x) for x in os.environ["RD_VALS"].split(",")]
        sweep(so, bank, patches, vals, [0, 1], SETTLE)
    return 0


def run_pass(so, mode, patches, vals):
    if os.path.exists(RING_LOG):
        os.remove(RING_LOG)
    env = dict(os.environ, RD_PATCHES=",".join(str(p) for p in patches))
    if vals is not None:
        env["RD_VALS"] = ",".join(str(v) for v in vals)
    subprocess.run([sys.executable, os.path.abspath(__file__),
                    "--worker", so, mode], env=env, check=True)
    return read_log()


def main():
    import null_b
    import e2e_emu as E

    teeth = "--teeth" in sys.argv
    bank = E.bank_bytes()

    # One patch per DELAY TYPE, read through the port's own decoder so each
    # ring is genuinely exercised rather than assumed.
    import ctypes
    import freshlib
    fl = freshlib.load()
    fl.juno_bank_delay_modes.argtypes = [
        ctypes.c_char_p, ctypes.c_int, ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int)]
    per_type = {}
    for p in range(64):
        t = ctypes.c_int(-1)
        if fl.juno_bank_delay_modes(bank, p, None, None, ctypes.byref(t)):
            per_type.setdefault(t.value, p)
    patches = sorted(per_type.values())
    verify_doctor(bank, patches[0])   # refuse to run on a plant that no-ops
    print("one patch per DELAY TYPE: %s"
          % ", ".join("t%d=p%d" % (t, per_type[t]) for t in sorted(per_type)))

    tmp = tempfile.mkdtemp(prefix="ringderive_")
    base = list(null_b.CFLAGS)
    null_b.CFLAGS = base + ["-DEB_RING_PROBE=1"]
    so = os.path.join(tmp, "probe.so")
    null_b.build(so, ["standalone"])
    null_b.CFLAGS = base

    # PASS 1 -- the FACTORY bank only. This reproduces the figure the repo
    # already has (t1 31,007) and is the CONTROL: if the sweep below does not
    # exceed it, the sweep did nothing and its answer is worthless.
    factory = run_pass(so, "factory", patches, None)

    # PASS 2 -- the PARAMETER's range, both sync states. Coarse is honest here
    # because the answer wanted is a MAX over the range; see the report, which
    # says plainly that this is a FLOOR on the max, not a proof of it.
    vals = list(range(0, 256, 16)) + [255]
    if teeth:
        vals = [255]                     # the plant: the parameter's LIMIT
    swept = run_pass(so, "sweep", patches, vals)

    names = sorted(set(list(factory) + list(swept)))
    print()
    print("%-6s %12s %12s %10s" % ("ring", "factory", "swept", "required"))
    worse = 0
    for n in names:
        f, s = factory.get(n, 0), swept.get(n, 0)
        need = 1
        while need < max(f, s):
            need <<= 1
        if s > f:
            worse += 1
        print("%-6s %12d %12d %10d%s"
              % (n, f, s, need, "  <- sweep is deeper" if s > f else ""))

    print()
    if teeth:
        # THE TOOTH, WITH THE POLARITY THE FIRST VERSION GOT BACKWARDS.
        # It used to sweep only DELAY TIME=0 and pass if the swept depth
        # stayed under the factory depth -- which a sweep that sets NOTHING
        # satisfies perfectly, and that is exactly the bug this file shipped
        # with for one run. The question a tooth must ask is whether moving
        # the parameter MOVES THE ANSWER.
        ok = worse > 0
        print("TEETH: swept DELAY TIME at its maximum. At least one ring MUST")
        print("  read deeper than the factory bank; the factory patches do not")
        print("  sit at the parameter's limit, so an unchanged answer means")
        print("  the plant is not landing.")
        print("  rings deeper than factory: %d" % worse)
        print("  -> %s" % ("OK -- the parameter moves the depth"
                           if ok else "*** the sweep changed NOTHING ***"))
        return 0 if ok else 1

    total = sum((1 << (max(v, 1) - 1).bit_length()) for v in swept.values())
    print("Sum of required lengths: %d samples = %.1f KB of float"
          % (total, total * 4 / 1024.0))
    print("Internal SRAM free on the listen firmware: 163 KB "
          "(fx_chain_price.md:33)")
    print()
    print("READ THIS BEFORE SIZING ANYTHING FROM THE TABLE:")
    print("  * EXACTLY ONE delay arm runs per patch, so a shipping allocation")
    print("    charges the WORST ACTIVE arm plus the effect ring, not the sum.")
    print("  * The swept column is a FLOOR on the parameter maximum, not a")
    print("    proof of it: 17 values x 2 sync states, and the tap is a")
    print("    smoothed, LFO-modulated product, so a value between steps can")
    print("    read deeper. Size with margin, and keep eb_delay.h's overrun")
    print("    counter -- it is the thing that catches a wrong answer here.")
    print("  * Samples, at 44,100. A host rate of 96 k needs 2.18x these.")
    return 0


if __name__ == "__main__":
    if len(sys.argv) > 3 and sys.argv[1] == "--worker":
        raise SystemExit(worker(sys.argv[2], sys.argv[3]))
    raise SystemExit(main())
