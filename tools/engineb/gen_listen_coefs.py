#!/usr/bin/env python3
"""gen_listen_coefs.py -- dump one patch's BUILT engine-B coefficient sets and
seeded state as a C header, so firmware can render audio before engine B has a
device-side recall path.

WHAT THIS IS AND IS NOT. Engine B's own recall (eb_patch -> coefficients) is a
recorded OPEN item; until it exists, a target has no way to turn patch bytes
into coefficients. This tool does that step ON THE HOST, using the same
eb_render_coefs_build / eb_master_coefs_build the certified standalone gate
uses, and freezes the RESULT. The firmware then runs the real per-sample chain
on real coefficients.

So the firmware proves the ENGINE on silicon, not the RECALL. Saying otherwise
would be the over-claim this project keeps a catalogue of.

Two snapshots per note: coefficients with the gate ON (captured just after a
note-on) and with the gate OFF (after the note-off). The firmware seeds state
once per note, renders with the ON set, then swaps to the OFF set for the
release -- which is exactly what the port's own cells do when a key is let go.
"""
import ctypes, os, struct, sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REPO = "/home/user/jn60c99"
sys.path[:0] = [os.path.join(REPO, "tools", "verify"),
                os.path.join(REPO, "tools", "trackb"),
                os.path.join(REPO, "tools", "engineb")]
import truth, null_ab, null_b

# CHORDS, not single notes, and sized 1..8. A firmware that wants to know
# whether this board can do N voices must render N voices SOUNDING; a single
# note with a voice cap of N renders one voice and seven at rest, which
# measures almost nothing. Chord k holds k notes.
CHORD = [48, 55, 60, 64, 67, 72, 76, 79]
NOTES = list(range(1, 9))          # chord sizes

# THE HOLD LENGTH IS SHARED WITH THE FIRMWARE, and it has to be.
#
# The note-off snapshot's VOICE STATE is copied into the running engine when
# the firmware releases the chord, because the gate lives in state and not in
# the coefficients (verified: swapping coefficients alone does not release the
# note at all -- the level sits at full for the whole release window). So the
# state being copied in must be the state the engine would ALREADY be in at
# that instant, or the copy is a jump.
#
# It was a jump: the first version captured note-off after 1024 samples while
# the firmware held for 1.5 s, so releasing teleported the envelope back to
# 23 ms into the note. MEASURED as a 4,716-count single-sample step and a
# level that RISES on release -- audible as a pluck at the end of every note,
# which is exactly what it was reported as.
#
# Capturing at the same 1.5 s makes the copy continuous, and it is continuous
# to the last bit rather than approximately: engine B nulls EXACTLY 0 against
# the port, so the state the port reaches after 1.5 s IS the state engine B
# reaches after 1.5 s.
HOLD_FRAMES = 44100 * 3 // 2
REL_FRAMES  = 44100 * 7 // 10
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 0
OUT = os.path.join(REPO, "esp32s3", "main", "s3_listen.bin")


def main():
    import tempfile
    tmp = tempfile.mkdtemp(prefix="listen_")
    so = os.path.join(tmp, "eb.so")
    # THE STANDALONE MODULE, not the composite. The composite carries the
    # SKELETON's juno_driver.c, which drives the port's own driver around the
    # per-module shims; only the `standalone` shim owns the eb_render_coefs /
    # eb_master_coef / eb_render_state / eb_master_state that
    # eb_engine_render_voices + eb_master_render actually run from -- and
    # those four blocks are exactly what the firmware needs. This is also the
    # build certified 11/11 bit-exact against the PLUGIN at both rates.
    null_b.build(so, ["standalone"])
    lib = null_ab.load(so)
    for fn in ("ebsh_dump_sizes", "ebsh_dump_blob"):
        if not hasattr(lib, fn):
            raise SystemExit(
                "%s missing: the composite shim needs the dump hook. "
                "Add it to engine_b/shim/standalone/juno_driver.c." % fn)
    bank = open(truth.BANK, "rb").read()

    sizes = (ctypes.c_int * 5)()
    lib.ebsh_dump_sizes(sizes)
    ncoef, nmcoef, nstate, nmstate, nvoice = list(sizes)
    print("sizes: coefs %d  mcoefs %d  rstate %d  mstate %d  voice-prefix %d"
          % (ncoef, nmcoef, nstate, nmstate, nvoice))

    # the port's nine ring-length cells (eb_master.h's own list)
    RING_LEN_CELLS = [6395252, 6429412, 8594772, 10691940, 10726260,
                      10759044, 101028, 6463716, 6496500]
    ring_lens = []
    rows = []
    for k in NOTES:
        # A FRESH CONTEXT PER CHORD. WHICH voices the port allocates is NOT
        # assumed -- it is measured downstream by the mask probe -- because
        # assuming it cost this tool a full cycle: the first version kept
        # voices 0..N-1 awake and the port had put the note on VOICE 7, so the
        # firmware simulation rendered peak 16 out of 30000 and looked like a
        # dead engine rather than a wrong voice index.
        c = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), PATCH)
        buf = (ctypes.c_float * 2048)()
        lib.juno_gui_render(c, buf, 64)          # let the engine settle
        for q in range(k):
            lib.juno_gui_note_on(c, CHORD[q], 100)
        lib.juno_gui_render(c, buf, 1)           # one sample: coefs are built
        on = _grab(lib, ncoef, nmcoef, nstate, nmstate, nvoice)
        _render(lib, c, HOLD_FRAMES)
        for q in range(k):
            lib.juno_gui_note_off(c, CHORD[q])
        lib.juno_gui_render(c, buf, 1)
        off = _grab(lib, ncoef, nmcoef, nstate, nmstate, nvoice)
        if not ring_lens:
            st = ctypes.cast(c, ctypes.POINTER(ctypes.c_void_p))[0]
            base = ctypes.cast(st, ctypes.POINTER(ctypes.c_ubyte))
            ring_lens = [struct.unpack("<i", bytes(base[o:o + 4]))[0]
                         for o in RING_LEN_CELLS]
        lib.juno_gui_destroy(c)
        rows.append((k, on, off))
        print("chord of %d captured" % k)

    # A BINARY BLOB EMBEDDED BY THE LINKER, not a C array of hex bytes. The
    # first attempt emitted hex and produced a 61 MB header: the two STATE
    # blocks are 735 KB and 730 KB (FX rings), and eight snapshots of them is
    # 11.8 MB of binary and five times that as text. Neither fits an 8 MB
    # flash beside the app.
    #
    # So the states are dumped ONCE, from the first note's note-on, and the
    # COEFFICIENTS are dumped per note and per gate. That is not a shortcut
    # around a difficulty, it is what the firmware actually needs: the state
    # is seeded once at boot exactly as the standalone gate seeds it, and a
    # note is expressed by swapping the coefficient set, which is where the
    # pitch and the gate live.
    hdr = struct.pack("<8I", 0x4A554E4F, len(rows), ncoef, nmcoef,
                      nstate, nmstate, nvoice, 0)
    with open(OUT, "wb") as f:
        f.write(hdr)
        f.write(rows[0][1][2])            # render state, note 0, gate on
        f.write(rows[0][1][3])            # master state, note 0, gate on
        for note, on, off in rows:
            for blob in (on, off):
                f.write(blob[0])          # coefficients
                f.write(blob[1])          # master coefficients
                f.write(blob[4])          # per-voice state prefix
    with open(OUT.replace(".bin", "_meta.h"), "w") as f:
        f.write("/* GENERATED by tools/engineb/gen_listen_coefs.py -- the\n"
                " * layout of s3_listen.bin. Patch %d, notes %s. */\n"
                % (PATCH, NOTES))
        f.write("#define S3L_MAGIC 0x4A554E4Fu\n")
        f.write("#define S3L_NNOTE %d\n" % len(rows))
        f.write("#define S3L_COEF_SZ %du\n#define S3L_MCOEF_SZ %du\n"
                "#define S3L_RSTATE_SZ %du\n#define S3L_MSTATE_SZ %du\n"
                "#define S3L_VOICE_SZ %du\n"
                % (ncoef, nmcoef, nstate, nmstate, nvoice))
        f.write("/* The hold/release lengths the OFF snapshot was captured\n"
                " * at. The firmware MUST use these: the release copies a\n"
                " * voice state in, and a state captured at a different\n"
                " * instant is a jump -- measured as a 4,716-count step and\n"
                " * heard as a pluck at the end of every note. */\n"
                "#define S3L_HOLD_FRAMES %du\n#define S3L_REL_FRAMES %du\n"
                % (HOLD_FRAMES, REL_FRAMES))
        f.write("/* chord size of each step */\n"
                "static const int S3L_NVOICE[S3L_NNOTE] = {%s};\n"
                % ",".join(str(r[0]) for r in rows))
        # THE RING LENGTHS ARE READ FROM THE PORT'S OWN CELLS, not written
        # down from memory. The firmware's first draft hardcoded nine
        # plausible powers of two; a ring one size different from the one the
        # coefficients were built against is a wrong delay time at best and a
        # read past the end at worst, and eb_master.h says so in its own
        # comment. These are the same nine cells the standalone shim reads.
        f.write("static const int S3L_RING_LEN[9] = {%s};\n"
                % ",".join(str(x) for x in ring_lens))
    # THE SOUNDING-VOICE MASKS, MEASURED by rendering each voice alone --
    # never assumed. The port's allocator fills from voice 7 DOWNWARD, which
    # is the opposite of the obvious guess and is why this probe exists.
    import subprocess, tempfile as _tf
    mp = os.path.join(_tf.mkdtemp(), "maskprobe")
    subprocess.run(["cc", "-std=c99", "-O2", "-ffp-contract=off",
                    "-fno-strict-aliasing", "-DEB_FORK_S3", "-DEB_LFO_SHARED=1",
                    "-I" + os.path.join(REPO, "engine_b"),
                    "-I" + os.path.join(REPO, "src"),
                    "-I" + os.path.dirname(OUT), "-o", mp,
                    os.path.join(REPO, "tools", "engineb",
                                 "listen_mask_probe.c")]
                   + sorted(__import__("glob").glob(
                       os.path.join(REPO, "engine_b", "eb_*.c"))) + ["-lm"],
                   check=True)
    masks = [int(l.split()[1], 16) for l in
             subprocess.run([mp, OUT], capture_output=True, text=True,
                            check=True).stdout.strip().split("\n")]
    with open(OUT.replace(".bin", "_meta.h"), "a") as f:
        f.write("/* MEASURED by tools/engineb/listen_mask_probe.c: which\n"
                " * voices actually sound in each chord. The allocator fills\n"
                " * from voice 7 downward. */\n")
        f.write("static const unsigned S3L_MASK[S3L_NNOTE] = {%s};\n"
                % ",".join("0x%02xu" % m for m in masks))
    print("masks (measured): %s" % ["0x%02x" % m for m in masks])
    print("wrote %s (%.2f MB) + _meta.h"
          % (OUT, os.path.getsize(OUT) / 1048576.0))


def _render(lib, c, n):
    """Render n frames in chunks (the scratch buffer is 1024 frames)."""
    buf = (ctypes.c_float * 2048)()
    left = n
    while left > 0:
        k = 1024 if left > 1024 else left
        lib.juno_gui_render(c, buf, k)
        left -= k


def _grab(lib, *sz):
    out = []
    for which, n in enumerate(sz):
        b = (ctypes.c_ubyte * n)()
        lib.ebsh_dump_blob(which, b)
        out.append(bytes(b))
    return out


def _arr(name, b):
    L = ["static const unsigned char %s[%d] = {" % (name, len(b))]
    for i in range(0, len(b), 16):
        L.append("    " + "".join("0x%02x," % v for v in b[i:i + 16]))
    L.append("};")
    return "\n".join(L) + "\n"


if __name__ == "__main__":
    main()
