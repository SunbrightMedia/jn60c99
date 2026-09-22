#!/usr/bin/env python3
"""jp8_memcensus.py -- memory census of the JP8 boot on the Unicorn oracle (jp8/tools/jp8_emu.py, imported READ-ONLY).
usage: jp8_memcensus.py A <outjson>        pass A: allocation/import/stage-diff census + wall times (no mem hooks)
       jp8_memcensus.py B <outjson> [N]    pass B: image read/write reach (UC_HOOK_MEM_READ/WRITE on the image, TB flushed)
Sequence (both passes): JP8() -> run_static_init -> build -> set_ftz -> set_sr(44100) -> host_init -> recall(2) flag 0
(+notify, NO snap) -> render_both(N=4096) -> note_on(60) -> render_both(512) -> note_off(60) -> render_both(512)."""
import os, sys, time, struct, collections, json
sys.dont_write_bytecode = True
os.environ.setdefault("JP8_EMU_QUIET", "0")
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import numpy as np
import jp8_emu as J
from unicorn import *
from unicorn.x86_const import *

MODE = sys.argv[1]; OUT = sys.argv[2]; NREN = int(sys.argv[3]) if len(sys.argv) > 3 else 4096
IB = J.IB; IMGSZ = J.IMGSZ
PRISTINE = np.frombuffer(bytes(J.IMG), dtype=np.uint8)
PRISTINE = np.concatenate([PRISTINE, np.zeros(IMGSZ - len(PRISTINE), np.uint8)])
SECS = [(s.Name.rstrip(b"\0").decode(), s.VirtualAddress, s.VirtualAddress + max(s.Misc_VirtualSize, s.SizeOfRawData)) for s in J.pe.sections]
SECS = [("HDR", 0, 0x1000)] + SECS
IAT = (0x9B7000, 0x9B7000 + 0x1648)
TEXT = [s for s in SECS if s[0] == ".text"][0]
def secof(rva):
    for n, a, b in SECS:
        if a <= rva < b: return n
    return "?"
T0 = time.time()
def log(m): print("[%7.1fs] %s" % (time.time() - T0, m), flush=True)

class C(J.JP8):
    def __init__(self):
        self.stage = "ctor"; self.bumps = []; self.frees = []; self._tag = None
        self.imps = collections.defaultdict(collections.Counter)
        self.emu_t = collections.Counter(); self.bsize = {}; self.reallocs = []; self.heapsize = []
        super().__init__()
    def bump(self, sz):
        p = super().bump(sz)
        rsp = self.uc.reg_read(UC_X86_REG_RSP)
        try: ret = int.from_bytes(self.uc.mem_read(rsp, 8), "little")
        except Exception: ret = 0
        tag = self._tag or "harness"
        self.bsize[p] = sz
        self.bumps.append((self.stage, tag, sz, p, (ret - IB) if (tag != "harness" and IB <= ret < IB + IMGSZ) else -1))
        return p
    def _imp(self, uc, address, size, user):
        if address in self.stub2name:
            name = self.stub2name[address][1]
            self.imps[self.stage][name] += 1
            if name == "HeapFree": self.frees.append((self.stage, uc.reg_read(UC_X86_REG_R8)))
            elif name in ("free", "??3@YAXPEAX@Z"): self.frees.append((self.stage, uc.reg_read(UC_X86_REG_RCX)))
            elif name == "HeapReAlloc":
                old = uc.reg_read(UC_X86_REG_R8); nsz = uc.reg_read(UC_X86_REG_R9)
                osz = self.bsize.get(old)
                nzo = int(np.count_nonzero(np.frombuffer(bytes(uc.mem_read(old, osz)), np.uint8))) if osz else None
                rsp = uc.reg_read(UC_X86_REG_RSP); ret = int.from_bytes(uc.mem_read(rsp, 8), "little")
                self.reallocs.append(dict(stage=self.stage, old=hex(old), old_size=osz, old_nonzero=nzo, new_size=nsz, flags=hex(uc.reg_read(UC_X86_REG_RDX)), caller=hex(ret - IB)))
            elif name == "HeapSize":
                rsp = uc.reg_read(UC_X86_REG_RSP); ret = int.from_bytes(uc.mem_read(rsp, 8), "little")
                self.heapsize.append(dict(stage=self.stage, ptr=hex(uc.reg_read(UC_X86_REG_R8)), true_size=self.bsize.get(uc.reg_read(UC_X86_REG_R8)), caller=hex(ret - IB)))
            self._tag = "imp:" + name
        try: return super()._imp(uc, address, size, user)
        finally: self._tag = None
    def _alloc(self, uc, address, size, user):
        self._tag = "ALLOC_0x6F5B04"; self.imps[self.stage]["<CRT ALLOC 0x6F5B04 hook>"] += 1
        try: return super()._alloc(uc, address, size, user)
        finally: self._tag = None
    def call(self, *a, **k):
        t = time.perf_counter()
        try: return super().call(*a, **k)
        finally: self.emu_t[self.stage] += time.perf_counter() - t
    def _run(self, stub):
        t = time.perf_counter()
        try: return super()._run(stub)
        finally: self.emu_t[self.stage] += time.perf_counter() - t

jp = C(); uc = jp.uc
BASE_REGIONS = sorted(uc.mem_regions())
res = dict(mode=MODE, nren=NREN, stages=[], walls={})

# ---------------------------------------------------------------- pass B hooks (installed before ANY emulation; TB flushed)
if MODE == "B":
    GROUPS = ["static", "boot", "recall", "play"]
    RD = {g: bytearray(IMGSZ) for g in GROUPS}; WR = {g: bytearray(IMGSZ) for g in GROUPS}
    TXT = {g: collections.Counter() for g in GROUPS}       # (pc rva, addr rva, size) of .text reads
    LOW = {g: collections.Counter() for g in GROUPS}       # (kind, pc rva, addr) of reads/writes in [0, 0x100000)
    ONES = [b"\x01" * n for n in range(64)]
    cur = {"g": "static"}
    def h_rd(uc_, acc, addr, size, val, u):
        o = addr - IB; RD[cur["g"]][o:o + size] = ONES[size]
    def h_wr(uc_, acc, addr, size, val, u):
        o = addr - IB; WR[cur["g"]][o:o + size] = ONES[size]
    def h_txt(uc_, acc, addr, size, val, u):
        TXT[cur["g"]][(uc_.reg_read(UC_X86_REG_RIP) - IB, addr - IB, size)] += 1
    def h_low(uc_, acc, addr, size, val, u):
        LOW[cur["g"]][("W" if acc == UC_MEM_WRITE else "R", uc_.reg_read(UC_X86_REG_RIP) - IB, addr, size)] += 1
    uc.ctl_flush_tb()
    uc.hook_add(UC_HOOK_MEM_READ, h_rd, begin=IB, end=IB + IMGSZ - 1)
    uc.hook_add(UC_HOOK_MEM_WRITE, h_wr, begin=IB, end=IB + IMGSZ - 1)
    uc.hook_add(UC_HOOK_MEM_READ, h_txt, begin=IB + TEXT[1], end=IB + TEXT[2] - 1)
    uc.hook_add(UC_HOOK_MEM_READ | UC_HOOK_MEM_WRITE, h_low, begin=0, end=0xFFFFF)

def region_census(tag):
    """nonzero bytes of every mapped region except the heap (read up to the bump pointer + 64 MB margin)"""
    out = {}
    for (a, b, p) in sorted(uc.mem_regions()):
        if a == J.HEAP_BASE:
            n = jp.heap - J.HEAP_BASE
            h = np.frombuffer(bytes(uc.mem_read(J.HEAP_BASE, n)), np.uint8)
            beyond = np.frombuffer(bytes(uc.mem_read(jp.heap, 64 << 20)), np.uint8)
            out["heap"] = dict(allocated=n, nonzero=int(np.count_nonzero(h)), nonzero_beyond_bump_64MB=int(np.count_nonzero(beyond)))
            continue
        if a == IB: continue
        buf = np.frombuffer(bytes(uc.mem_read(a, b - a + 1)), np.uint8)
        nz = np.nonzero(buf)[0]
        name = {J.STACK_BASE: "stack", J.STUB_BASE: "stubs", 0: "low_0_1MB(gs page0)", J.BUF_BASE: "BUF"}.get(a, "EXTRA_0x%x" % a)
        d = dict(start=hex(a), size=b - a + 1, nonzero=int(len(nz)))
        if len(nz):
            d["first_nz"] = hex(a + int(nz[0])); d["last_nz"] = hex(a + int(nz[-1]))
            d["pages_nz"] = sorted(set(hex(a + (int(x) & ~0xFFF)) for x in nz))[:12]
        out[name] = d
    extra = [(hex(a), hex(b + 1)) for (a, b, p) in sorted(uc.mem_regions()) if (a, b, p) not in BASE_REGIONS]
    out["regions_mapped_since_ctor"] = extra
    return out

def image_diff(ref, tag):
    cur_img = np.frombuffer(bytes(uc.mem_read(IB, IMGSZ)), np.uint8)
    d = cur_img != ref
    idx = np.nonzero(d)[0]
    per = collections.OrderedDict()
    for n, a, b in SECS:
        k = idx[(idx >= a) & (idx < b)]
        if len(k): per[n] = dict(bytes=int(len(k)), pages=int(len(set((k >> 12).tolist()))))
    iat = int(np.count_nonzero(d[IAT[0]:IAT[1]]))
    return dict(bytes=int(len(idx)), pages=int(len(set((idx >> 12).tolist()))), per_section=per, iat_bytes=iat), cur_img

def data_ptr_cells(img):
    """qwords (8-aligned) of .data that point into heap / image / stubs"""
    n, a, b = [s for s in SECS if s[0] == ".data"][0]
    q = img[a:b - ((b - a) % 8)].view(np.uint64)
    return dict(to_heap=int(np.count_nonzero((q >= J.HEAP_BASE) & (q < jp.heap))),
                to_image=int(np.count_nonzero((q >= IB) & (q < IB + IMGSZ))),
                to_stubs=int(np.count_nonzero((q >= J.STUB_BASE) & (q < J.STUB_BASE + 0x100000))))

def heap_census(tag, top=12):
    n = jp.heap - J.HEAP_BASE
    h = np.frombuffer(bytes(uc.mem_read(J.HEAP_BASE, n)), np.uint8)
    q = h[: n - n % 8].view(np.uint64)
    ptr = dict(to_heap=int(np.count_nonzero((q >= J.HEAP_BASE) & (q < jp.heap))),
               to_image=int(np.count_nonzero((q >= IB) & (q < IB + IMGSZ))),
               to_image_text=int(np.count_nonzero((q >= IB + TEXT[1]) & (q < IB + TEXT[2]))),
               to_stubs=int(np.count_nonzero((q >= J.STUB_BASE) & (q < J.STUB_BASE + 0x100000))),
               to_stack=int(np.count_nonzero((q >= J.STACK_BASE) & (q < J.STACK_BASE + J.STACK_SIZE))),
               to_buf=int(np.count_nonzero((q >= J.BUF_BASE) & (q < J.BUF_BASE + J.BUF_SIZE))))
    pg = h[: n - n % 4096].reshape(-1, 4096)
    pages_nz = int(np.count_nonzero(pg.any(axis=1)))
    freed = set(p for _, p in jp.frees)
    hist = collections.Counter(); stage_ct = collections.Counter(); tag_ct = collections.Counter()
    blocks = []
    for st, tg, sz, p, ret in jp.bumps:
        rs = ((sz + 15) & ~15) or 16
        hist[sz] += 1; stage_ct[st] += 1; tag_ct[tg] += 1
        blocks.append((rs, p, st, tg, ret, sz))
    blocks.sort(reverse=True)
    big = []
    for rs, p, st, tg, ret, sz in blocks[:top]:
        o = p - J.HEAP_BASE; seg = h[o:o + rs]
        big.append(dict(ptr=hex(p), size=sz, stage=st, via=tg, caller_rva=hex(ret) if ret >= 0 else None,
                        nonzero=int(np.count_nonzero(seg)), pages_nz=int(np.count_nonzero(seg[: rs - rs % 4096].reshape(-1, 4096).any(axis=1))) if rs >= 4096 else None,
                        freed=p in freed, is_state=p in jp.__dict__.get("state", [])))
    live = sum(((sz + 15) & ~15) or 16 for st, tg, sz, p, ret in jp.bumps if p not in freed)
    return dict(allocated_bytes=n, nonzero_bytes=int(np.count_nonzero(h)), nonzero_pages_4k=pages_nz, total_pages_4k=n // 4096,
                n_allocs=len(jp.bumps), n_frees=len(jp.frees), live_bytes_not_freed=live,
                allocs_by_stage=dict(stage_ct), allocs_by_path=dict(tag_ct),
                size_hist_top=sorted(((s, c) for s, c in hist.items()), key=lambda x: (-x[1], -x[0]))[:30],
                size_hist_bytes_top=sorted(((s, c, s * c) for s, c in hist.items()), key=lambda x: -x[2])[:12],
                n_distinct_sizes=len(hist), largest=big, pointer_qwords=ptr)

def stage(name):
    jp.stage = name
    if MODE == "B":
        cur["g"] = {"static": "static", "build": "boot", "setsr": "boot", "hostinit": "boot", "recall": "recall"}.get(name, "play")

SP0 = (J.STACK_BASE + J.STACK_SIZE - 0x10000) & ~0xF
def run(name, fn):
    uc.mem_write(J.STACK_BASE, b"\0" * (SP0 - 0x100 - J.STACK_BASE))      # dead stack below every call's rsp
    stage(name); t = time.perf_counter(); r = fn(); w = time.perf_counter() - t
    sb = np.frombuffer(bytes(uc.mem_read(J.STACK_BASE, SP0 - J.STACK_BASE)), np.uint8); nz = np.nonzero(sb)[0]
    res.setdefault("stack_depth_by_stage", {})[name] = int(SP0 - (J.STACK_BASE + int(nz[0]))) if len(nz) else 0
    res["walls"][name] = dict(wall_s=round(w, 3), emu_s=round(jp.emu_t[name], 3))
    log("%s: wall %.2fs (emulation %.2fs) -> %r" % (name, w, jp.emu_t[name], r if not isinstance(r, tuple) or len(r) < 5 else "..."))
    return r

img_ctor = np.frombuffer(bytes(uc.mem_read(IB, IMGSZ)), np.uint8)
dctor, _ = image_diff(PRISTINE, "ctor")
res["image_after_ctor_vs_pristine"] = dctor
okf = run("static", lambda: jp.run_static_init())
res["static_init"] = dict(ok=okf[0], fail=okf[1], skipped=jp.static_skipped, faults=jp.faults)
if MODE == "B":
    # the heap objects static init built: are they read / written by boot, recall, play?
    HS0 = J.HEAP_BASE; HS1 = jp.heap; HSZ = HS1 - HS0
    HRD = {g: bytearray(HSZ) for g in ("boot", "recall", "play", "control")}; HWR = {g: bytearray(HSZ) for g in ("boot", "recall", "play", "control")}
    HPC = {g: collections.Counter() for g in ("boot", "recall", "play", "control")}
    def h_hrd(uc_, acc, addr, size, val, u):
        o = addr - HS0; HRD[cur["g"]][o:o + size] = ONES[size]; HPC[cur["g"]][uc_.reg_read(UC_X86_REG_RIP) - IB] += 1
    def h_hwr(uc_, acc, addr, size, val, u):
        o = addr - HS0; HWR[cur["g"]][o:o + size] = ONES[size]
    uc.ctl_flush_tb()
    uc.hook_add(UC_HOOK_MEM_READ, h_hrd, begin=HS0, end=HS1 - 1)
    uc.hook_add(UC_HOOK_MEM_WRITE, h_hwr, begin=HS0, end=HS1 - 1)
    res["static_heap_bytes"] = HSZ
if MODE == "A":
    d1, img1 = image_diff(PRISTINE, "static")
    d1b, _ = image_diff(img_ctor, "static")
    res["S1"] = dict(image_vs_pristine=d1, image_vs_after_harness_ctor=d1b, regions=region_census("static"),
                     heap=heap_census("static"), data_ptr_cells=data_ptr_cells(img1),
                     bss_tail_nonzero=jp.bss_fill())
    log("S1 image vs pristine %s" % json.dumps(d1))
run("build", lambda: jp.build())
def _sr(): jp.set_ftz(); return jp.set_sr(44100.0)
run("setsr", _sr)
if MODE == "A":
    import pe_recon
    t = time.perf_counter(); pe_recon.PE(J.BIN).params(list(range(5223))); res["pe_recon_parse_s"] = round(time.perf_counter() - t, 3)
res["hostinit"] = run("hostinit", lambda: jp.host_init())
run("recall", lambda: jp.recall(2))          # flag 0 (RECALL_FLAG), notify=True, NO snap
if MODE == "A":
    d2, img2 = image_diff(PRISTINE, "boot"); d2b, _ = image_diff(img1, "boot")
    res["S2_boot"] = dict(image_vs_pristine=d2, image_vs_after_static=d2b, regions=region_census("boot"),
                          heap=heap_census("boot"), data_ptr_cells=data_ptr_cells(img2))
    log("S2 boot heap %d B, nonzero %d" % (res["S2_boot"]["heap"]["allocated_bytes"], res["S2_boot"]["heap"]["nonzero_bytes"]))
n_before = len(jp.bumps)
if MODE == "A":
    HEAP_BOOT = np.frombuffer(bytes(uc.mem_read(J.HEAP_BASE, jp.heap - J.HEAP_BASE)), np.uint8).copy()
def _ren(n):
    def f():
        dry, L, R = jp.render_both(n)
        Lf = np.frombuffer(struct.pack("<%dI" % len(L), *L), np.float32)
        return dict(n=n, dry_nan=jp.dry_nan, master_peak=float(np.nanmax(np.abs(Lf))), master_nan=int(np.isnan(Lf).sum()), dry_peak=float(max(abs(x) for x in dry)))
    return f
res["render4096"] = run("render%d" % NREN, _ren(NREN))
if MODE == "A":
    d3, img3 = image_diff(PRISTINE, "render"); d3b, _ = image_diff(img2, "render")
    res["S3_render"] = dict(image_vs_pristine=d3, image_vs_after_boot=d3b, regions=region_census("render"),
                            heap=heap_census("render"), allocs_during_render=len(jp.bumps) - n_before, data_ptr_cells=data_ptr_cells(img3))
run("noteon", lambda: jp.note_on(60, 100))
res["render_on"] = run("render512_on", _ren(512))
run("noteoff", lambda: jp.note_off(60, 64))
res["render_off"] = run("render512_off", _ren(512))
res["faults_total"] = jp.faults
res["imports_by_stage"] = {k: dict(v) for k, v in jp.imps.items()}
res["unhandled_imports"] = dict(jp.unhandled)
if MODE == "A":
    d4, img4 = image_diff(PRISTINE, "end"); d4b, _ = image_diff(img3, "end")
    res["S4_end"] = dict(image_vs_pristine=d4, image_vs_after_render=d4b, regions=region_census("end"), heap=heap_census("end"),
                         allocs_after_boot=len(jp.bumps) - n_before)
    # which .data/.rdata bytes did boot/render change after static init (the image's runtime-mutable state)
    for tagn, a, b in (("static->end", img1, img4),):
        idx = np.nonzero(a != b)[0]
        res["image_mutated_after_static"] = {n: int(np.count_nonzero((idx >= s) & (idx < e))) for n, s, e in SECS if np.count_nonzero((idx >= s) & (idx < e))}
        res["image_mutated_after_static_rvas"] = [hex(int(x)) for x in idx[:64]]
    # the 9 unit state blocks: per-block nonzero + pairwise identity of the 8 voice blocks
    st = []
    blk0 = None
    for i, p in enumerate(jp.state):
        b = np.frombuffer(bytes(uc.mem_read(p, J.STATE_SZ)), np.uint8)
        e = dict(unit=i, ptr=hex(p), nonzero=int(np.count_nonzero(b)), pages_nz=int(np.count_nonzero(b[: len(b) - len(b) % 4096].reshape(-1, 4096).any(axis=1))))
        if i == 0: blk0 = b
        else: e["bytes_differing_from_unit0"] = int(np.count_nonzero(b != blk0))
        st.append(e)
    res["state_blocks"] = st
    hend = np.frombuffer(bytes(uc.mem_read(J.HEAP_BASE, len(HEAP_BOOT))), np.uint8)
    ch = hend != HEAP_BOOT
    res["heap_changed_boot_to_end"] = dict(bytes=int(np.count_nonzero(ch)), pages=int(np.count_nonzero(ch[: len(ch) - len(ch) % 4096].reshape(-1, 4096).any(axis=1))))
    for e in st:
        p = int(e["ptr"], 16); o = p - J.HEAP_BASE; c = ch[o:o + J.STATE_SZ]; z = hend[o:o + J.STATE_SZ]
        cp = c[: len(c) - len(c) % 4096].reshape(-1, 4096).any(axis=1)
        e["changed_bytes_boot_to_end"] = int(np.count_nonzero(c)); e["changed_pages"] = int(np.count_nonzero(cp))
        # contiguous runs of changed pages (offsets in the block) -- delay/reverb lines show up as long runs
        runs = []; i = 0; n = len(cp)
        while i < n:
            if cp[i]:
                j = i
                while j < n and cp[j]: j += 1
                runs.append((j - i, hex(i * 4096), hex(j * 4096))); i = j
            else: i += 1
        runs.sort(reverse=True); e["changed_page_runs_top"] = runs[:6]; e["n_changed_runs"] = len(runs)
        nzp = z[: len(z) - len(z) % 4096].reshape(-1, 4096).any(axis=1)
        last = int(np.nonzero(z)[0][-1]) if np.count_nonzero(z) else -1
        e["last_nonzero_offset"] = hex(last); e["nonzero_pages_end"] = int(np.count_nonzero(nzp))
        rr = []; i = 0
        while i < len(nzp):
            if nzp[i]:
                j = i
                while j < len(nzp) and nzp[j]: j += 1
                rr.append((hex(i * 4096), hex(j * 4096), int(np.count_nonzero(z[i * 4096:j * 4096])))); i = j
            else: i += 1
        e["nonzero_page_runs"] = rr
    res["stack_depth_bytes"] = (J.STACK_BASE + J.STACK_SIZE - 0x10000) - int(res["S4_end"]["regions"]["stack"]["first_nz"], 16)
    res["reallocs"] = jp.reallocs; res["heapsize_calls"] = jp.heapsize
    np.save(OUT + ".heap_end.npy", hend)
    for (a, b, pp) in sorted(uc.mem_regions()):
        if (a, b, pp) not in BASE_REGIONS:
            buf = bytes(uc.mem_read(a, b - a + 1)); res.setdefault("extra_region_bytes", []).append([hex(a + i) + "=" + hex(x) for i, x in enumerate(buf) if x])
if MODE == "B":
    # positive control (the detector must be SEEN TO FIRE): a stub that reads one .text qword and one .rdata qword
    stage("control")
    cur["g"] = "play"; CTRL = J.CODE_BASE + 0x800
    code = b"\x48\xB8" + struct.pack("<Q", IB + 0x1000) + b"\x48\x8B\x00" + b"\x48\xB8" + struct.pack("<Q", IB + 0xA00000) + b"\x48\x8B\x00" + b"\xC3"
    GROUPS.append("control"); RD["control"] = bytearray(IMGSZ); WR["control"] = bytearray(IMGSZ); TXT["control"] = collections.Counter(); LOW["control"] = collections.Counter()
    cur["g"] = "control"; uc.mem_write(CTRL, code); uc.ctl_flush_tb(); jp.call(CTRL)
    rep = {}
    for g in GROUPS:
        r = np.frombuffer(bytes(RD[g]), np.uint8); w = np.frombuffer(bytes(WR[g]), np.uint8)
        per = {}
        for n, a, b in SECS:
            rr = int(np.count_nonzero(r[a:b])); ww = int(np.count_nonzero(w[a:b]))
            if rr or ww: per[n] = dict(read_bytes=rr, write_bytes=ww, read_pages=int(np.count_nonzero(r[a:b][: (b - a) - (b - a) % 4096].reshape(-1, 4096).any(axis=1))) if b - a >= 4096 else None)
        per["IAT_read_bytes"] = int(np.count_nonzero(r[IAT[0]:IAT[1]]))
        dn, da, db = [s for s in SECS if s[0] == ".data"][0]
        per[".data_tail_read_bytes(runtime-filled 0xD20A00..0xD2BBE0)"] = int(np.count_nonzero(r[0xD20A00:0xD2BBE0]))
        txt = TXT[g]
        per["text_reads_total"] = sum(txt.values())
        per["text_read_sites"] = [dict(pc=hex(pc), addr=hex(ad), size=sz, count=c) for (pc, ad, sz), c in sorted(txt.items())][:80]
        per["text_read_distinct_pcs"] = sorted(set(hex(pc) for (pc, ad, sz) in txt))
        per["low_region_accesses"] = [dict(kind=k, pc=hex(pc), addr=hex(ad), size=sz, count=c) for (k, pc, ad, sz), c in sorted(LOW[g].items())][:40]
        per["low_region_total"] = sum(LOW[g].values())
        rep[g] = per
    # union over boot+recall+play (what a shipping engine touches after static init)
    U = np.zeros(IMGSZ, np.uint8); UW = np.zeros(IMGSZ, np.uint8)
    for g in ("boot", "recall", "play"):
        U |= np.frombuffer(bytes(RD[g]), np.uint8); UW |= np.frombuffer(bytes(WR[g]), np.uint8)
    img_now = np.frombuffer(bytes(uc.mem_read(IB, IMGSZ)), np.uint8)
    un = {}
    for n, a, b in SECS:
        rr = int(np.count_nonzero(U[a:b]))
        if rr or np.count_nonzero(UW[a:b]):
            ra = np.nonzero(U[a:b])[0] + a
            un[n] = dict(read_bytes=rr, write_bytes=int(np.count_nonzero(UW[a:b])),
                         read_bytes_differing_from_pristine_now=int(np.count_nonzero(img_now[ra] != PRISTINE[ra])),
                         read_span=[hex(int(ra.min())), hex(int(ra.max()) + 1)] if len(ra) else None,
                         read_pages=int(len(set((ra >> 12).tolist()))))
    rep["UNION_boot_recall_play"] = un
    for g in ("boot", "recall", "play"):
        np.save(OUT + ".rd_%s.npy" % g, np.frombuffer(bytes(RD[g]), np.uint8))
        hr = np.frombuffer(bytes(HRD[g]), np.uint8); hw = np.frombuffer(bytes(HWR[g]), np.uint8)
        np.save(OUT + ".hrd_%s.npy" % g, hr)
        rep["static_heap_" + g] = dict(read_bytes=int(np.count_nonzero(hr)), write_bytes=int(np.count_nonzero(hw)),
                                       reading_pcs=[(hex(pc), c) for pc, c in HPC[g].most_common(40)])
    np.save(OUT + ".read_union.npy", U); np.save(OUT + ".write_union.npy", UW)
    res["reach"] = rep
json.dump(res, open(OUT, "w"), indent=1, default=str)
log("wrote %s" % OUT)
