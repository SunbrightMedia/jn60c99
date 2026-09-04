#!/usr/bin/env python3
"""jx_hostinit_probe.py -- PROVE the host-parameter-init hypothesis (charter 7b
robustness arc). The unhosted plugin plays ~35 Hz for note 60 and its EFX
network self-poisons; the hypothesis: a DAW writes every host parameter's
DEFAULT at insert, and the clean boot without them is simply un-initialized.

Ground truth, all READ from the binary (no captures):
  name table  rva 0x9D6C00 (id 20 = MASTER TUNE, 433 = Note (voice 1), ...)
  ENGINE DB   rva 0x9C2C10, 16-byte rows {i32 min,max,default,flags}
    (id 433 default = 36 -- the EXACT wrong pitch the audit measured)

The probe: build A = clean boot; build B = clean boot + dispatch(default) for
every named non-event id (events = Note 433-449, Gate 450-466, Mute 467-484:
a DAW sends those as events, never as parameter defaults). Then on each:
idle render (finite? silent?), NOTEON 60, render, zero-crossing f0.
PASS = B plays ~261.6 Hz where A plays ~35 Hz, and B idles finite.
"""
import sys, os, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J

NAMES, ENGDB = 0x9D6C00, 0x9C2C10
SETSR, NOTEON = 0x3F9970, 0x3F9150
EVENT_IDS = set(range(433, 485))          # Note/Gate/Mute/ModuleCvOut
ID_LIMIT = 1500


def read_db():
    import pefile
    pe = pefile.PE(os.path.join(J.REPO, "jx3p", "truth", "JX3P.vst3"))
    IB = pe.OPTIONAL_HEADER.ImageBase
    img = pe.get_memory_mapped_image()

    def sname(i):
        p = struct.unpack("<Q", img[NAMES + 8 * i:NAMES + 8 * i + 8])[0]
        if not (IB <= p < IB + len(img)):
            return None
        r = p - IB
        e = img.index(b"\0", r)
        return img[r:e].decode("latin1") if e - r <= 96 else None

    rows = []
    for i in range(ID_LIMIT):
        n = sname(i)
        if not n or n == "_reserve_" or i in EVENT_IDS:
            continue
        mn, mx, df, fl = struct.unpack(
            "<iiii", img[ENGDB + 16 * i:ENGDB + 16 * i + 16])
        if mn == mx == df == 0:
            continue
        rows.append((i, n, df))
    return rows


def f32(words):
    return struct.unpack("<%df" % len(words),
                         struct.pack("<%dI" % len(words), *words))


ACTIVE = [10, 11, 12, 13, 14, 16, 17, 19, 20, 22, 24, 25, 26, 28, 29, 30, 31,
          32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
          49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65]
HEADER, STRIDE, BLOB_OFF = 23, 20223, 16


def apply_patch(jx, patch):
    bank = open(os.path.join(J.REPO, "jx3p", "truth",
                             "preset_bank_1.bin"), "rb").read()
    blob = bank[HEADER + patch * STRIDE + BLOB_OFF:]
    for u in range(J.N_UNITS):
        for pool in ACTIVE:
            p = 2 * pool + 8
            jx.dispatch(u, pool + 740,
                        ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF))


def render_dry(jx, n, block=256):
    """Voice-sum render: run the same wrapper stubs jx.render runs, but
    collect the per-voice MIX buffers (master bypassed)."""
    uc = jx.uc
    offs = {}
    p = J.BUF_BASE
    for v in range(8):
        offs[v] = p; p += 8 * block
    acc = [0.0] * n
    done = 0
    while done < n:
        b = min(block, n - done)
        for v in range(8):
            uc.mem_write(J.PB_VOICE, struct.pack(
                "<QQQQQ", jx.state[v], v, offs[v], offs[v] + 4 * block, b))
            jx._run(jx.SVOICE)
            w = struct.unpack("<%dI" % b, uc.mem_read(offs[v], 4 * b))
            for i, x in enumerate(f32(w)):
                if x == x:
                    acc[done + i] += x
        done += b
    return acc


def zc_f0(f):
    zc = sum(1 for i in range(1, len(f)) if f[i - 1] < 0.0 <= f[i])
    return zc * 44100.0 / len(f)


def measure(jx, tag):
    fi = render_dry(jx, 2048)
    bad = sum(1 for x in fi if x != x or abs(x) > 1e6)
    peak_i = max((abs(x) for x in fi if x == x), default=0.0)
    jx.call(J.IB + NOTEON, rcx=jx.HOST, rdx=60, r8=100)
    render_dry(jx, 2048)                          # attack settles
    f = render_dry(jx, 8192)
    f0 = zc_f0(f)
    peak = max((abs(x) for x in f if x == x), default=0.0)
    print("%s: idle bad=%d idle_peak=%.3g  note60 DRY f0~%.1f Hz peak=%.3g"
          % (tag, bad, peak_i, f0, peak))
    return f0


def main():
    rows = read_db()
    print("host-init vector: %d named non-event ids" % len(rows))

    jx = J.JX().build(); jx.set_ftz()
    jx.call(J.IB + SETSR, rcx=jx.HOST,
            rdx=struct.unpack("<Q", struct.pack("<d", 44100.0))[0])
    apply_patch(jx, 0)
    f0a = measure(jx, "A patch-only   ")

    jx = J.JX().build(); jx.set_ftz()
    jx.call(J.IB + SETSR, rcx=jx.HOST,
            rdx=struct.unpack("<Q", struct.pack("<d", 44100.0))[0])
    for i, n, df in rows:
        for u in range(J.N_UNITS):
            jx.dispatch(u, i, df)
    apply_patch(jx, 0)
    f0b = measure(jx, "B defaults+patch")

    ok = abs(f0b - 261.6) < 15.0
    print("VERDICT: %s (A=%.1f, B=%.1f, want ~261.6)"
          % ("HOST-INIT PROVEN" if ok else "NOT PROVEN", f0a, f0b))


if __name__ == "__main__":
    main()
