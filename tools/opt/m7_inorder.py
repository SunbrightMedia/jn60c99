#!/usr/bin/env python3
"""m7sched.py — in-order dual-issue scoreboard model of Cortex-M7 running THIS
engine's real compiled code, weighted by measured execution counts.

WHY THIS EXISTS. tools/opt/m7_cycles.py fed whole FUNCTIONS to llvm-mca. That
walks the instruction stream straight through and therefore charges for BOTH
sides of every branch, and it has no execution weights at all. This model
instead:
  * splits each function into BASIC BLOCKS (branch targets / branch instructions),
  * weights each block by its gcov-measured execution count in the real 8-voice
    steady state, so never-taken code costs nothing,
  * simulates in-order dual issue with a register scoreboard and the M7's
    structural limits (<=1 FP data-op/cycle, <=1 load-store/cycle, width 2),
  * reports the cycle total with PERFECT memory (every load hits, 2-cycle).

The gap between this number and the SILICON 93,288 cyc/sample is, by
construction, everything the pipeline model cannot explain: memory stalls,
branch mispredicts, and any per-instruction penalty larger than the table below.

LATENCY TABLE — label READ (ARM Cortex-M7 TRM r1p2, "Instruction timings"), not
measured here. Where the TRM gives a range the pessimistic end is used and the
sensitivity is printed at the end.
"""
import re, os, glob, subprocess, collections, sys
from dynall import gcov_counts, SAMPLES, S, REPO, AFLAGS

# ---------------------------------------------------------------- latencies
LAT = {
    'f32_arith': 4,      # VADD/VSUB/VMUL/VABS/VNEG/VMINNM/VMAXNM .F32
    'f32_cmp':   4,      # VCMP(E).F32 -> FPSCR
    'vmrs':      4,      # FPSCR -> APSR, serialising against the FP pipe
    'f32_div':  14,      # VDIV.F32, not pipelined
    'f64_arith': 7,      # VADD/VSUB/VMUL/VMLA .F64  (half-rate on FPv5-D16)
    'f64_div':  28,
    'cvt':       4,
    'vmov_fp':   2,      # VMOV.F32 reg,reg / #imm
    'vmov_x':    5,      # VMOV Rt,Sn / Sn,Rt  (register-file crossing)
    'fpld':      2,      # VLDR, cache/TCM hit
    'ild':       2,      # LDR
    'st':        0,      # stores produce no register result
    'alu':       1,
    'branch':    1,
    'call':      1,
}
ISSUE = {                # occupancy of the issuing pipe, cycles
    'f32_div': 14, 'f64_div': 28, 'f64_arith': 2,
}
FPPIPE = {'f32_arith', 'f32_cmp', 'f32_div', 'f64_arith', 'f64_div', 'cvt',
          'vmov_fp', 'vmov_x', 'vmrs'}
LSU = {'fpld', 'ild', 'st'}


def classify(t):
    mn = re.sub(r'\.(w|n)$', '', t.split()[0])
    if mn.startswith('vdiv'):  return 'f64_div' if '.f64' in mn else 'f32_div'
    if mn.startswith('vcmp'):  return 'f32_cmp'
    if mn == 'vmrs' or mn == 'vmsr': return 'vmrs'
    if mn.startswith('vcvt'):  return 'cvt'
    if re.match(r'^v(add|sub|mul|mla|mls|nmla|nmls|nmul|abs|neg|minnm|maxnm|sqrt|rint|sel)', mn):
        return 'f64_arith' if '.f64' in mn else 'f32_arith'
    if mn.startswith('vmov'):
        return 'vmov_fp' if ('.f32' in mn or '.f64' in mn) else 'vmov_x'
    if mn.startswith('vldr') or mn.startswith('vldm') or mn == 'vpop': return 'fpld'
    if mn.startswith('vstr') or mn.startswith('vstm') or mn == 'vpush': return 'st'
    if re.match(r'^(ldr|ldm|pop)', mn):  return 'ild'
    if re.match(r'^(str|stm|push)', mn): return 'st'
    if re.match(r'^bl(x)?$', mn):        return 'call'
    if re.match(r'^(b|bx|cb(n)?z|tb[bh])', mn) and not mn.startswith('bic') and not mn.startswith('bfi'):
        return 'branch'
    return 'alu'


SREG = re.compile(r'\b([sd])(\d+)\b')
RREG = re.compile(r'\b(r\d+|sl|fp|ip|sp|lr|pc)\b')


def regs(t):
    """(dst set, src set) as canonical single-precision lane ids + GPRs."""
    parts = t.split(None, 1)
    mn, ops = parts[0], (parts[1] if len(parts) > 1 else '')
    cls = classify(t)
    fl, gl = [], []
    for kind, num in SREG.findall(ops):
        n = int(num)
        fl.append(('s', n) if kind == 's' else ('d', n))
    for g in RREG.findall(ops):
        gl.append(g)
    def expand(x):
        k, n = x
        return [('s', 2*n), ('s', 2*n+1)] if k == 'd' else [('s', n)]
    fl = [y for x in fl for y in expand(x)]
    toks = [o.strip() for o in ops.split(',')]
    dst, src = set(), set()
    if cls in ('st',):
        src.update(fl); src.update(gl)
    elif cls in ('fpld', 'ild'):
        # first operand is the destination, remainder address
        if toks:
            d = toks[0]
            m = SREG.search(d)
            if m: dst.update(expand((m.group(1), int(m.group(2)))))
            m = RREG.search(d)
            if m and not SREG.search(d): dst.add(m.group(1))
        src.update(g for g in gl if g not in dst)
        src.update(f for f in fl if f not in dst)
    elif cls in ('branch', 'call'):
        src.update(gl); src.add('APSR')
    elif cls == 'vmrs':
        dst.add('APSR'); src.add('FPSCR')
    elif cls == 'f32_cmp':
        dst.add('FPSCR'); src.update(fl); src.update(gl)
    else:
        if toks:
            d = toks[0]
            m = SREG.search(d)
            if m: dst.update(expand((m.group(1), int(m.group(2)))))
            else:
                m = RREG.search(d)
                if m: dst.add(m.group(1))
        src.update(x for x in fl if x not in dst)
        src.update(x for x in gl if x not in dst)
        if re.match(r'^(adcs?|sbcs?|.*s)$', mn) and mn.endswith('s'):
            dst.add('APSR')
    return dst, src


def sim(block, perfect_mem=True, ld_extra=0):
    """cycles for one basic block, in-order, dual issue, scoreboard."""
    ready = collections.defaultdict(int)   # reg -> cycle it becomes readable
    cyc = 0
    fp_free = 0          # FP pipe next-free cycle
    ls_free = 0          # load/store unit next-free cycle
    slot = 0             # instructions already issued this cycle
    cur = 0
    for t in block:
        cls = classify(t)
        dst, src = regs(t)
        # earliest by operands
        e = 0
        for r in src:
            e = max(e, ready[r])
        # structural
        if cls in FPPIPE: e = max(e, fp_free)
        if cls in LSU:    e = max(e, ls_free)
        # issue width: at most 2 per cycle, and never before the current cycle
        e = max(e, cur)
        if e == cur and slot >= 2:
            e = cur + 1
        if e > cur:
            cur = e; slot = 0
        slot += 1
        occ = ISSUE.get(cls, 1)
        if cls in FPPIPE: fp_free = cur + occ
        if cls in LSU:    ls_free = cur + 1
        lat = LAT[cls]
        if cls in ('fpld', 'ild') and not perfect_mem:
            lat += ld_extra
        for r in dst:
            ready[r] = cur + lat
        cyc = max(cyc, cur + 1)
    return cyc


def blocks_of(body):
    """split [(text, line)] into basic blocks at branches."""
    out, cur = [], []
    for t, ln in body:
        cur.append((t, ln))
        if classify(t) in ('branch', 'call'):
            out.append(cur); cur = []
    if cur: out.append(cur)
    return out


def dis_lines_arm(obj, src):
    out = subprocess.run(["arm-none-eabi-objdump", "-dl", "--no-show-raw-insn", obj],
                         capture_output=True, text=True).stdout
    per = collections.defaultdict(list)
    sym, curln = None, None
    for L in out.split("\n"):
        m = re.match(r'^[0-9a-f]+ <([^>]+)>:', L)
        if m: sym = m.group(1); curln = None; continue
        m = re.match(r'^(/\S+?):(\d+)(?:\s|$)', L)
        if m:
            curln = int(m.group(2)) if src in m.group(1) else None
            continue
        if L.startswith('/') or L.rstrip().endswith('():'): continue
        if sym is None: continue
        if not L.strip(): sym = None; continue
        m = re.match(r'^\s*[0-9a-f]+:\s+(.*)$', L)
        if not m: continue
        t = re.sub(r'\s*@.*$', '', m.group(1)).strip()
        t = re.sub(r'\s*//.*$', '', t).strip()
        if not t or t.startswith(('...', '.word', '.short', '.byte', '(bad)')): continue
        per[sym].append((t, curln))
    return per


def run(perfect_mem=True, ld_extra=0, verbose=False):
    tot_cyc = 0.0; tot_ins = 0.0
    detail = []
    for path in sorted(glob.glob(REPO + "/src/*.c")):
        src = os.path.basename(path); base = src[:-2]
        counts = gcov_counts(f"{S}/gcov/{src}.gcov")
        if not counts: continue
        o = f"{S}/all_{base}_arm.o"
        if not os.path.exists(o):
            subprocess.run(["arm-none-eabi-gcc"] + AFLAGS + [path, "-o", o],
                           capture_output=True)
        fcyc = 0.0; fins = 0.0
        for sym, body in dis_lines_arm(o, src).items():
            for blk in blocks_of(body):
                ws = [counts.get(ln) for _, ln in blk if ln is not None]
                ws = [w for w in ws if w]
                if not ws: continue
                w = max(set(ws), key=ws.count)          # modal weight of the block
                txt = [t for t, _ in blk]
                fcyc += w * sim(txt, perfect_mem, ld_extra)
                fins += w * len(txt)
        if fins:
            detail.append((src, fcyc / SAMPLES, fins / SAMPLES))
        tot_cyc += fcyc; tot_ins += fins
    return tot_cyc / SAMPLES, tot_ins / SAMPLES, detail


if __name__ == '__main__':
    c, i, det = run(True)
    print("M7 in-order model, PERFECT memory (all loads hit, 2-cycle):")
    for s, cc, ii in sorted(det, key=lambda r: -r[1]):
        if cc < 1: continue
        print(f"   {s:20s} {cc:9.0f} cyc/sample   {ii:8.0f} instr   IPC {ii/cc:.2f}")
    print(f"   {'TOTAL':20s} {c:9.0f} cyc/sample   {i:8.0f} instr   IPC {i/c:.2f}")
    print()
    print("SILICON (E2, 8 voices)      93288 cyc/sample")
    print(f"model / silicon             {c/93288.0:.3f}   -> unexplained {93288-c:.0f} cyc/sample")
    print()
    print("sensitivity: extra cycles added to EVERY load latency")
    for extra in (0, 1, 2, 3, 4, 6, 8):
        cc, ii, _ = run(False, extra)
        print(f"   +{extra} cyc/load : model {cc:8.0f} cyc/sample  ({cc/93288.0:.2f}x silicon)")
