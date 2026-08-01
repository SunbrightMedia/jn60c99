#!/usr/bin/env python3
"""ifootprint.py — the audio path's INSTRUCTION footprint per audio sample, in
32-byte Cortex-M7 I-cache lines, for M7 and for x86-64.

The measured Daisy firmware is APP_TYPE = BOOT_QSPI (daisy/Makefile:11), i.e.
.text is executed in place from QSPI NOR flash at 0x90040000 through a 16 KB,
2-way, 32-byte-line instruction cache. If the per-sample hot footprint exceeds
16 KB the loop cannot be resident and every sample re-streams it.

"Hot" = instruction whose source line has a nonzero gcov count in the measured
8-voice steady state.
"""
import re, os, glob, subprocess, collections
from dynall import gcov_counts, SAMPLES, S, REPO, AFLAGS, XFLAGS

LINE = 32


def scan(obj, arch, src, counts):
    tool = "arm-none-eabi-objdump" if arch == 'arm' else "objdump"
    out = subprocess.run([tool, "-dl", obj], capture_output=True, text=True).stdout
    sym, curln = None, None
    hot_bytes = collections.Counter()      # sym -> hot bytes
    all_bytes = collections.Counter()
    hot_lines = collections.defaultdict(set)
    for L in out.split("\n"):
        m = re.match(r'^[0-9a-f]+ <([^>]+)>:', L)
        if m: sym = m.group(1); curln = None; continue
        m = re.match(r'^(/\S+?):(\d+)(?:\s|$)', L)
        if m:
            curln = int(m.group(2)) if src in m.group(1) else None
            continue
        if sym is None: continue
        if not L.strip(): sym = None; continue
        m = re.match(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2,8}\s)+)\s*(.*)$', L)
        if not m: continue
        addr = int(m.group(1), 16)
        nb = sum(len(g) for g in m.group(2).split()) // 2
        txt = m.group(3).strip()
        if txt.startswith(('.word', '.short', '.byte')): continue
        all_bytes[sym] += nb
        w = counts.get(curln) if curln is not None else None
        if w:
            hot_bytes[sym] += nb
            for a in range(addr, addr + nb):
                hot_lines[sym].add(a // LINE)
    return hot_bytes, all_bytes, hot_lines


def run(arch):
    flags = AFLAGS if arch == 'arm' else XFLAGS
    cc = "arm-none-eabi-gcc" if arch == 'arm' else "gcc"
    tot_hot = tot_all = tot_lines = 0
    rows = []
    for path in sorted(glob.glob(REPO + "/src/*.c")):
        src = os.path.basename(path); base = src[:-2]
        counts = gcov_counts(f"{S}/gcov/{src}.gcov")
        if not counts: continue
        o = f"{S}/all_{base}_{arch}.o"
        if not os.path.exists(o):
            subprocess.run([cc] + flags + [path, "-o", o], capture_output=True)
        hb, ab, hl = scan(o, arch, src, counts)
        for sym in hb:
            rows.append((sym, hb[sym], ab[sym], len(hl[sym])))
            tot_hot += hb[sym]; tot_lines += len(hl[sym])
        tot_all += sum(ab.values())
    rows.sort(key=lambda r: -r[1])
    print(f"--- {arch} ---")
    print(f"{'function':30s} {'hot B':>8s} {'total B':>8s} {'hot 32B lines':>14s}")
    for sym, h, a, l in rows:
        if h < 200: continue
        print(f"{sym:30s} {h:8d} {a:8d} {l:14d}")
    print(f"{'TOTAL audio path':30s} {tot_hot:8d} {'':8s} {tot_lines:14d}")
    print(f"  hot code = {tot_hot/1024.0:.1f} KiB in {tot_lines} lines of 32 B")
    return tot_hot, tot_lines


if __name__ == '__main__':
    ha, la = run('arm')
    print()
    hx, lx = run('x86')
    print()
    print("Cortex-M7 (Daisy Seed, STM32H750) I-cache: 16 KiB, 2-way, 32-byte lines = 512 lines")
    print(f"  M7 hot audio-path footprint   : {ha/1024.0:8.1f} KiB   {la:5d} lines"
          f"   = {ha/16384.0:5.2f}x the I-cache")
    print("Xeon (measured host) L1I: 32 KiB 8-way; L2 1 MiB unified; L3 shared")
    print(f"  x86 hot audio-path footprint  : {hx/1024.0:8.1f} KiB   {lx:5d} lines"
          f"   = {hx/32768.0:5.2f}x L1I  (and {hx/1048576.0:.2f}x L2, i.e. L2-resident)")
