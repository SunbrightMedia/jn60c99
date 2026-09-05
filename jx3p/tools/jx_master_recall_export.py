#!/usr/bin/env python3
"""jx_master_recall_export.py -- per-patch recall AUX data (charter 7b).

jx_bank_apply (proven 64/64) covers each voice unit's 0x60000 DSP window.
The plugin's recall ALSO: writes the master unit's cells, writes every
unit's HIGH parameter window [0xA60000,0xAAD000), and RE-ARMS ramp slots +
the GC id vector. All of that, per factory patch, derived fresh from the
binary under Unicorn (one clean build per patch so nothing leaks between).

Output jx3p/gen/jx_master_recall.bin ('JXM3'):
  u32 npatches; per patch:
    u32 nmruns;  master runs {u32 off,u32 len,bytes}     (diff vs clean)
    8x: u32 nlruns; voice DSP-window runs (0-based, 0x60000 window)
    8x: u32 nhruns; voice high-window runs (off is 0xA60000-based)
    9x: wrap record  {i32 latch,u8 flag,pad3, u32 nids, ids,
                      u32 nslot, slots{u32 target_off, 32 bytes}}
  u32 crc32 tail.
"""
import sys, os, struct, zlib
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J

HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
SETSR = 0x3F9970
SNAP_M = 0xAAD000
HI_LO, HI_SZ = 0xA60000, 0x4D000
ACTIVE = [10, 11, 12, 13, 14, 16, 17, 19, 20, 22, 24, 25, 26, 28, 29, 30, 31,
          32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
          49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65]


def decode(blob, pool):
    p = 2 * pool - 8   # CORRECTED 2026-09-05 (playbook 88, jx_bank_census.py)
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)


def sparse_diff(a, b, base=0):
    runs, i, L = [], 0, len(a)
    while i < L:
        if a[i] == b[i]:
            i += 1; continue
        j = i
        while j < L and a[j] != b[j]:
            j += 1
        runs.append((base + i, b[i:j]))
        i = j
    return runs


def pack_runs(runs):
    out = struct.pack("<I", len(runs))
    for off, data in runs:
        out += struct.pack("<II", off, len(data)) + data
    return out


def wrap_record(jx, uc, u):
    def rq(a): return int.from_bytes(uc.mem_read(a, 8), "little")
    st = jx.state[u]
    latch = struct.unpack("<i", uc.mem_read(st + 0xAAC308, 4))[0]
    flag = uc.mem_read(st + 0x14, 1)[0]
    arr = rq(st + 0x58)
    b0 = rq(st + 0x70); e0 = rq(st + 0x78)
    ids = list(struct.unpack("<%di" % ((e0 - b0) // 4),
                             uc.mem_read(b0, e0 - b0))) if e0 > b0 else []
    nslot = (max(ids) + 1) if ids else 0
    rec = struct.pack("<iBxxxI", latch, flag, len(ids))
    rec += struct.pack("<%di" % len(ids), *ids) if ids else b""
    rec += struct.pack("<I", nslot)
    for i in range(nslot):
        sl = bytes(uc.mem_read(arr + 40 * i, 40))
        tgt = struct.unpack("<Q", sl[:8])[0]
        off = tgt - st if tgt else 0xFFFFFFFF
        rec += struct.pack("<I", off & 0xFFFFFFFF) + sl[8:]
    return rec


def main():
    bank = open(os.path.join(J.REPO, "jx3p", "truth",
                             "preset_bank_1.bin"), "rb").read()
    out = b"JXM3" + struct.pack("<I", 64)
    clean_m = clean_h = None
    for patch in range(64):
        # boot per jx_emu.boot(): SETSR takes the rate as a FLOAT in xmm1
        # (ABI ledger); ramps/latch live, as the C engine replays them
        jx = J.JX().boot(44100.0, snap=False, host_init=True); uc = jx.uc
        if clean_m is None:
            clean_m = bytes(uc.mem_read(jx.state[8], SNAP_M))
            clean_h = [bytes(uc.mem_read(jx.state[v] + HI_LO, HI_SZ))
                       for v in range(8)]
            clean_l = [bytes(uc.mem_read(jx.state[v], 0x60000))
                       for v in range(8)]
        jx.recall(patch, bank=bank, notify=False)   # the plugin's own pool set
        out += pack_runs(sparse_diff(clean_m,
                                     bytes(uc.mem_read(jx.state[8], SNAP_M))))
        for v in range(8):
            lo = bytearray(uc.mem_read(jx.state[v], 0x60000))
            lo[136:144] = clean_l[v][136:144]     # the link pointer: excluded
            out += pack_runs(sparse_diff(clean_l[v], bytes(lo)))
        for v in range(8):
            out += pack_runs(sparse_diff(
                clean_h[v], bytes(uc.mem_read(jx.state[v] + HI_LO, HI_SZ)),
                0))
        for u in range(9):
            out += wrap_record(jx, uc, u)
        print("p%d done (%d B so far)" % (patch, len(out)))
    out += struct.pack("<I", zlib.crc32(out) & 0xFFFFFFFF)
    dst = os.path.join(J.REPO, "jx3p", "gen", "jx_master_recall.bin")
    open(dst, "wb").write(out)
    import gzip
    gzip.open(dst + ".gz", "wb", 9).write(out)
    print("recall aux: %d B (%d B gz) -> %s"
          % (len(out), os.path.getsize(dst + ".gz"), dst))


if __name__ == "__main__":
    main()
