#!/usr/bin/env python3
"""coverage_audit.py -- prove the one-run extractor's band is EVERYTHING the
port ever needs from IDA. Answers the standing question "is this all?" with a
measurement, not a promise, and does it with NO IDA (pure PE parsing) so it can
be re-run any time on any workstation.

THE CLAIM UNDER TEST. ida_extract_all.py decompiles every function in the DSP
BAND (lowest DSP vtable method .. highest parameter-class method, +/-0x10000)
plus a call-graph closure. The claim: nothing the finished JUNO port ever took
from IDA falls outside that set.

THE TEST. Harvest every .text-range code address the JUNO port's own tools and
records reference (the oracle harness, PROVENANCE, the recall/parse/translate
scripts -- the addresses a human pulled out of IDA over eight visits). For each,
require it is either
  (a) inside the band's address range (so IDA's function DB dumps it -- note
      MANY are functions WITHOUT .pdata unwind info, which is why coverage is
      judged by RANGE, the way the extractor's idc.get_next_func walk sees it,
      not by the .pdata table), or
  (b) reached by the direct-call closure from the band, or
  (c) a documented NON-transcription reference: a dump-limit constant, a
      negative probe result, or a CRT function the emulator HOOKS by address and
      never transcribes.

Green = the band is provably sufficient. A surprise address is a real gap and
prints as one.

usage: coverage_audit.py            (audits the JUNO port -- the only finished
                                     one; the JX port has no references yet)
"""
import sys, os, re, glob, struct, bisect, collections

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))

# addresses the port references that are NOT DSP to transcribe -- each named,
# each with the reason it is legitimately outside a "decompile the DSP" dump.
KNOWN_NON_DSP = {
    0x600000: "CODE_LIMIT_RVA -- a dump cutoff constant, not a function",
    0x8B05B8: "documented negative probe (real_apply_node_probe: no reader here)",
    0x67522C: "CRT allocator -- emulator STUB hook, addressed not transcribed",
    0x6AE028: "CRT fatal handler -- emulator STUB hook, addressed not transcribed",
}

def sections(d):
    pe = struct.unpack_from('<I', d, 0x3c)[0]
    nsec = struct.unpack_from('<H', d, pe + 6)[0]
    opt = struct.unpack_from('<H', d, pe + 20)[0]
    base = struct.unpack_from('<Q', d, pe + 24 + 24)[0]
    st = pe + 24 + opt
    secs = []
    for i in range(nsec):
        o = st + 40 * i
        name = d[o:o+8].rstrip(b'\x00').decode('latin1')
        va = struct.unpack_from('<I', d, o+12)[0]
        vsz = struct.unpack_from('<I', d, o+8)[0]
        raw = struct.unpack_from('<I', d, o+20)[0]
        rsz = struct.unpack_from('<I', d, o+16)[0]
        secs.append((name, va, max(vsz, rsz), raw, rsz))
    return base, secs

def sec(secs, n):
    for s in secs:
        if s[0] == n: return s
    return None

def off2rva(secs, o):
    for _, va, sz, raw, _ in secs:
        if raw <= o < raw + sz: return va + (o - raw)
    return None

def pdata_starts(d, secs):
    _, va, sz, raw, rsz = sec(secs, '.pdata')
    return sorted({struct.unpack_from('<I', d, o)[0]
                   for o in range(raw, raw + rsz - 11, 12)
                   if struct.unpack_from('<I', d, o)[0]})

def method_addrs(d, secs, base, prefixes):
    text = sec(secs, '.text'); tlo, thi = text[1], text[1] + text[2]
    addrs = set()
    for p in prefixes:
        needle = b'.?AV' + p.encode()
        i = -1
        while True:
            i = d.find(needle, i + 1)
            if i < 0: break
            td_rva = off2rva(secs, i - 16)
            if td_rva is None: continue
            tdn = struct.pack('<I', td_rva)
            j = -1
            while True:
                j = d.find(tdn, j + 1)
                if j < 0: break
                if j < 12 or struct.unpack_from('<I', d, j-12)[0] != 1: continue
                col_rva = off2rva(secs, j - 12)
                if col_rva is None or struct.unpack_from('<I', d, j+8)[0] != col_rva:
                    continue
                ptr = struct.pack('<Q', base + col_rva)
                k = d.find(ptr)
                while k >= 0:
                    e = 0
                    while True:
                        v = struct.unpack_from('<Q', d, k + 8 + 8*e)[0] - base
                        if tlo <= v < thi:
                            addrs.add(v); e += 1
                        else:
                            break
                    k = d.find(ptr, k + 1)
    return addrs

def build_edges(d, secs, starts):
    """direct-call graph: caller-func-start -> set(callee starts), via E8 scan."""
    _, tva, tsz, traw, trsz = sec(secs, '.text')
    buf = d[traw:traw + trsz]
    sset = set(starts)
    edges = collections.defaultdict(set)
    for i in range(len(buf) - 4):
        if buf[i] == 0xE8:
            src = tva + i
            t = src + 5 + struct.unpack_from('<i', buf, i + 1)[0]
            if t in sset:
                j = bisect.bisect_right(starts, src) - 1
                if j >= 0:
                    edges[starts[j]].add(t)
    return edges

def main():
    juno = os.path.join(REPO, "truth", "JUNO60.vst3")
    if not os.path.exists(juno):
        print("JUNO binary not found at %s" % juno); return 1
    d = open(juno, 'rb').read()
    base, secs = sections(d)
    starts = pdata_starts(d, secs)

    # the band, exactly as the extractor computes it (median-window on methods),
    # over the same class set: DSP + parameter + audio-path (assigner, sim).
    methods = sorted(method_addrs(d, secs, base,
        ["CDSPJu60", "CPrmDSPJu60", "CAssignJu60", "CJu60Sim"]))
    med = methods[len(methods) // 2]
    concrete = [m for m in methods if abs(m - med) <= 0x200000]
    band_lo, band_hi = min(concrete) - 0x10000, max(concrete) + 0x10000
    print("JUNO DSP band: 0x%X .. 0x%X  (%d .pdata funcs; IDA's DB has more)" %
          (band_lo, band_hi, sum(1 for s in starts if band_lo <= s <= band_hi)))

    # closure DOWN from the whole band
    edges = build_edges(d, secs, starts)
    seen, stack = set(), [s for s in starts if band_lo <= s <= band_hi]
    while stack:
        x = stack.pop()
        if x in seen: continue
        seen.add(x)
        stack.extend(c for c in edges.get(x, ()) if c not in seen)
    print("closure from band reaches %d .pdata functions total" % len(seen))

    # harvest every .text-range address the port references
    srcs = (glob.glob(os.path.join(REPO, "tools/verify/*.py")) +
            glob.glob(os.path.join(REPO, "tools/*.py")) +
            glob.glob(os.path.join(REPO, "tools/engineb/*.py")) +
            [os.path.join(REPO, "PROVENANCE.tsv")])
    refs = {}
    for p in srcs:
        if not os.path.exists(p): continue
        for m in re.finditer(r'0x1800?([0-9a-fA-F]{5,6})\b|(?<![\d.])0x([3-9][0-9a-fA-F]{5})\b',
                             open(p, errors='replace').read()):
            v = int(m.group(1) or m.group(2), 16)
            if 0x100000 <= v <= 0x950000:
                refs.setdefault(v, set()).add(os.path.basename(p))

    if "--tooth" in sys.argv:
        # plant a reference to a real .text function far outside band+closure
        # (a GUI/CRT function low in .text) and require the audit to catch it.
        plant = 0x176D  # first .pdata function, deep in the CRT, never DSP
        refs[plant] = {"TOOTH"}

    def covered(a):
        if band_lo <= a <= band_hi:
            return "IN BAND RANGE"
        j = bisect.bisect_right(starts, a) - 1
        if j >= 0 and starts[j] in seen:
            return "in closure"
        return None

    print("\n=== LEDGER: %d distinct .text addresses the JUNO port consumed ===" %
          len(refs))
    gaps = []
    counts = collections.Counter()
    for a in sorted(refs):
        how = covered(a)
        if how:
            counts[how] += 1
        elif a in KNOWN_NON_DSP:
            counts["known non-DSP"] += 1
        else:
            gaps.append(a)
    for k, n in counts.most_common():
        print("  %-16s %d" % (k, n))
    if gaps:
        print("\n*** %d UNEXPLAINED address(es) outside band+closure+known:" % len(gaps))
        for a in gaps:
            print("    0x%X  referenced by %s" % (a, ", ".join(sorted(refs[a]))))
        print("\nCOVERAGE AUDIT: FAIL -- the band is not yet everything.")
        return 1
    print("\nCOVERAGE AUDIT: PASS -- every address the finished JUNO port took")
    print("from IDA is in the band range, reached by its closure, or a named")
    print("non-DSP reference. One run of the band extractor is sufficient.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
