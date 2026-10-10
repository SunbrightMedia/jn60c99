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


def _template_regions(path):
    """Parse the shipped JXT3 / JXT4 region blocks (links/crc not needed here)."""
    b = open(path, "rb").read()
    if b[:4] not in (b"JXT3", b"JXT4"):
        raise SystemExit("BASE-MATCH TOOTH: %s is not JXT3 / JXT4" % path)
    n = struct.unpack_from("<I", b, 4)[0]
    off, regs = 8, []
    for _ in range(n):
        ln = struct.unpack_from("<I", b, off)[0]; off += 4
        regs.append(b[off:off + ln]); off += ln
    return regs


def check_template_base(clean_l, clean_h, clean_m, path):
    """THE BASE-MATCH TOOTH (defect paid 2026-09-05). WHY: sparse byte diffs
    are valid ONLY over the exact base they were diffed against. At d27c923
    the aux was diffed against the SNAPPED boot while the committed template
    was still pre-snap -- untouched cells kept stale values (0.0 where the
    true clean is 0.686275/1.0) and partial byte runs spliced denormal
    franken-floats (v0+0x440: run 92 91 11 over stale zeros -> 0x00119192,
    FTZ to 0.0), which starved the per-sample state advance in the C twin.
    So: BEFORE any diff is computed, byte-compare this exporter's clean boot
    windows against the same regions of the JXT3 that ships with the aux and
    refuse loudly on any mismatch. Region layout mirrors jx_template_export:
    [0..7]=voice LO (ptr@136 zeroed there), [-9..-2]=voice HI, [-1]=master
    (ptr@136 zeroed). The pointer cells are masked on our side because the
    template zeroes them by design (PORT_LESSONS 4) and the aux excludes
    them from diffs anyway."""
    regs = _template_regions(path)

    def nbad(mine, ref):
        return sum(1 for a, b in zip(mine, ref) if a != b) \
            + abs(len(mine) - len(ref))
    bad = []
    for v in range(8):
        mine = bytearray(clean_l[v]); mine[136:144] = b"\x00" * 8
        d = nbad(bytes(mine), regs[v])
        if d: bad.append("voice%d LO: %d B" % (v, d))
    for v in range(8):
        d = nbad(clean_h[v], regs[len(regs) - 9 + v])
        if d: bad.append("voice%d HI: %d B" % (v, d))
    mm = bytearray(clean_m); mm[136:144] = b"\x00" * 8
    d = nbad(bytes(mm), regs[-1])
    if d: bad.append("master: %d B" % d)
    if bad:
        raise SystemExit(
            "BASE-MATCH TOOTH BITES: %s does not match this exporter's "
            "clean boot (%s). The aux's sparse diffs would be applied over "
            "the WRONG base and splice garbage. Regenerate the template with "
            "jx_template_export.py from the SAME jx_emu revision, then rerun "
            "this exporter." % (path, "; ".join(bad)))
    print("base-match tooth: template matches the clean boot (17 windows)")


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


def variant_records(spec):
    """'34:67=3' -> factory patch 34's patch-load records with record 67's value set to 3 (several
    'idx=val' pairs may follow, comma-separated). The records stay the plugin's own; only a value
    changes, to one the plugin's host entry accepts (the gates print the cells it set).
    '+0xID=V' appends a record for a model id the patch does not carry (its GUI's controls, e.g. the
    step pattern's row 0x600120 and column 0x600128 -- jx3p/docs/HOST_LAYER.md 3e), after the load,
    as the editor sends it; V may be negative (the value travels as its 32 bits)."""
    import copy
    base, _, edits = spec.partition(":")
    recs = copy.deepcopy(J.JX.records()["patches"][int(base)])
    for e in filter(None, edits.split(",")):
        i, _, v = e.partition("=")
        if i.startswith("+"):
            recs.append([2, int(i[1:], 0), int(v, 0)])
        else:
            recs[int(i)][2] = int(v, 0)
    return recs


def main():
    # --variants 'S1;S2;...' --out PATH: the aux of variant patches (variant_records), for a gate that
    # reaches master paths no factory patch reaches; written to PATH, never to the shipped file
    a = sys.argv[1:]
    variants = a[a.index("--variants") + 1].split(";") if "--variants" in a else None
    # --rate R --template T --out PATH: the aux of another engine rate, over that rate's template (JX-4)
    rate = float(a[a.index("--rate") + 1]) if "--rate" in a else 44100.0
    tmpl = a[a.index("--template") + 1] if "--template" in a else os.path.join(J.REPO, "jx3p", "gen", "jx_template.bin")
    import jx_template_export as T
    loads = [variant_records(v) for v in variants] if variants else list(range(64))
    out = b"JXM4" + struct.pack("<I", len(loads))
    clean_m = clean_h = None
    for patch, load in enumerate(loads):
        # boot per jx_emu.boot(): SETSR takes the rate as a FLOAT in xmm1
        # (ABI ledger); ramps/latch live, as the C engine replays them
        jx = J.JX().boot(rate, snap=False, product=True); uc = jx.uc   # the template's base: the plugin's boot records
        if clean_m is None:
            clean_m = bytes(uc.mem_read(jx.state[8], SNAP_M))
            clean_h = [bytes(uc.mem_read(jx.state[v] + HI_LO, HI_SZ))
                       for v in range(8)]
            clean_l = [bytes(uc.mem_read(jx.state[v], 0x60000))
                       for v in range(8)]
            # WHY: refuse a baseline split BEFORE computing any diff -- the
            # aux only makes sense over the exact template it ships with.
            check_template_base(clean_l, clean_h, clean_m, tmpl)
            clean_c = T.control_blobs(jx)       # the template's control regions 8..43 (same boot)
        if variants:
            jx.host_records(load)  # the same host entry, the variant's records
            print("variant %s: mode cells +0xAAC1E8 %d, +0xAAC1E4 %d" % (variants[patch], *struct.unpack(
                "<ii", bytes(uc.mem_read(jx.state[8] + 0xAAC1E4, 8)))[::-1]))
        else:
            jx.recall_product(patch)   # the plugin's own patch load records through its host entry (2026-10-10)
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
        # JXM4 (2026-10-10): the control objects the patch load changes (the parameter objects hold
        # KEY ASSIGN and 798 the assigner reads; the assigners hold its mode) and the engine HOST
        # record (every patch load queues writePatch: the output fade)
        for b0, b1 in zip(clean_c, T.control_blobs(jx)):
            out += pack_runs(sparse_diff(b0, b1))
        out += T.host_record(jx)
        print("p%d done (%d B so far)" % (patch, len(out)))
    out += struct.pack("<I", zlib.crc32(out) & 0xFFFFFFFF)
    dst = a[a.index("--out") + 1] if "--out" in a else os.path.join(J.REPO, "jx3p", "gen", "jx_master_recall.bin")
    if variants and "--out" not in a:
        raise SystemExit("--variants needs --out: the shipped aux holds the factory patches only")
    open(dst, "wb").write(out)
    import gzip
    with open(dst + ".gz", "wb") as fh, gzip.GzipFile(filename="", mode="wb", compresslevel=9,
                                                    fileobj=fh, mtime=0) as gz:   # no name, no time:
        gz.write(out)                                                              # equal bytes every run
    print("recall aux: %d B (%d B gz) -> %s"
          % (len(out), os.path.getsize(dst + ".gz"), dst))


if __name__ == "__main__":
    main()
