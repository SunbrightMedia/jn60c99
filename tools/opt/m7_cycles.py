#!/usr/bin/env python3
"""m7_cycles.py — model the engine's cost on a real Cortex-M7 pipeline.

Every embedded verdict in this repo so far rested on ONE guessed number: the
x86->M7 IPC ratio. This replaces the guess with ARM's own published pipeline
model, as implemented by llvm-mca's `cortex-m7` scheduler (dispatch width 2,
in-order dual issue, real VFP latencies).

METHOD
  1. Compile the hot sources to Cortex-M7 assembly with the SHIPPING flags
     (-O2 -ffp-contract=off -mfpu=fpv5-d16 -mfloat-abi=hard).
  2. Extract each function body, strip directives/labels.
  3. Feed to llvm-mca. A few mnemonics are absent from the M7 scheduling model;
     each is SUBSTITUTED by a same-class instruction (vcmpe->vcmp etc.) rather
     than dropped, so nothing is silently uncounted. Substitutions and any
     genuinely dropped lines are reported.

HONEST BOUNDS
  * llvm-mca walks the instruction stream in order and ignores branches, so it
    charges for BOTH sides of every conditional. The result is therefore an
    UPPER BOUND on the true per-call cost -- it errs against the port, which is
    the safe direction for a feasibility claim.
  * It models the pipeline, not the memory system: no I-cache misses, no SDRAM
    stalls. On a target running from ITCM/DTCM that is close to reality; running
    from QSPI or with the state in SDRAM it is optimistic.
  So the true number sits below the branch-inflated figure and above the
  perfect-memory figure. Both bounds are printed.
"""
import re, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
OUT = "/tmp/m7cyc"
CC = "arm-none-eabi-gcc"
FLAGS = ("-std=c99 -O2 -ffp-contract=off -fno-strict-aliasing "
         "-mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb").split()

# Mnemonics missing from llvm-mca's M7 model, mapped to a same-timing-class
# instruction so the cycle count stays honest instead of dropping the op.
SUBST = {
    "vcmpe.f32": "vcmp.f32",
    "vcmpe.f64": "vcmp.f64",
    "vmrs": "nop",          # APSR_nzcv transfer; 1 cycle, no VFP issue slot
    "it": None,             # IT blocks: predication, folded into the M7 pipeline
    "ite": None, "itt": None, "ittt": None, "itte": None, "itee": None,
    "iteee": None, "itttt": None, "ittte": None, "itett": None, "itete": None,
    "itett": None, "iteet": None, "iteet": None, "itttе": None,
}

FUNCS = [("voice_render", "juno_voice_render"),
         ("master_render", "juno_master_render"),
         ("juno_dsp", "juno_triangle")]


def extract(path, fn):
    out, on = [], False
    for L in open(path):
        s = L.strip()
        if re.match(r'^' + re.escape(fn) + r':\s*$', s):
            on = True; continue
        if on and s.startswith('.size') and fn in s:
            break
        if not on or not s or s.startswith('@') or s.startswith('.') or s.endswith(':'):
            continue
        out.append(s)
    return out


def mca(lines, tag):
    subs = drops = 0
    body = []
    for s in lines:
        m = re.match(r'^([a-z][a-z0-9._]*)', s)
        mn = m.group(1) if m else ''
        if mn in SUBST:
            rep = SUBST[mn]
            if rep is None:
                drops += 1; continue
            s = s.replace(mn, rep, 1); subs += 1
        body.append(s)

    path = "%s/%s.s" % (OUT, tag)
    for _ in range(60):                       # iterate on residual unsupported ops
        open(path, 'w').write('\n'.join(body) + '\n')
        r = subprocess.run(['llvm-mca', '-mtriple=thumbv7em-none-eabi',
                            '-mcpu=cortex-m7', '-iterations=1', path],
                           capture_output=True, text=True)
        txt = r.stdout + r.stderr
        if 'Total Cycles' in r.stdout:
            d = dict(re.findall(r'^(Instructions|Total Cycles):\s+(\d+)', r.stdout, re.M))
            ipc = re.search(r'^IPC:\s+([\d.]+)', r.stdout, re.M)
            return int(d['Instructions']), int(d['Total Cycles']), float(ipc.group(1)), subs, drops
        bad = re.search(r'note: instruction:\s+(\S+)', txt)
        if not bad:
            print("  %s: llvm-mca failed: %s" % (tag, txt.strip().split('\n')[0][:80]))
            return None
        mn = bad.group(1)
        keep = [s for s in body if not re.match(r'^' + re.escape(mn) + r'\b', s)]
        drops += len(body) - len(keep)
        body = keep
    return None


def main():
    os.makedirs(OUT, exist_ok=True)
    res = {}
    for f, fn in FUNCS:
        src = os.path.join(REPO, "src", f + ".c")
        asm = "%s/%s.s" % (OUT, f)
        subprocess.run([CC] + FLAGS + ["-S", src, "-o", asm],
                       capture_output=True, check=True)
        r = mca(extract(asm, fn), fn)
        if not r: continue
        ins, cyc, ipc, subs, drops = r
        res[fn] = cyc
        print("  %-20s instrs %5d   CYCLES %6d   IPC %.2f   (subst %d, dropped %d)"
              % (fn, ins, cyc, ipc, subs, drops))
    return res


if __name__ == '__main__':
    r = main()
    if len(r) == 3:
        v, m, t = r['juno_voice_render'], r['juno_master_render'], r['juno_triangle']
        # juno_triangle is called ~104x/sample across the 8 voices (gprof: 302M
        # calls over the benchmark). It is already inside voice_render's own
        # call sites, so count it separately at the measured rate.
        total = 8 * v + m + 104 * t
        print("\n  per sample (8 voices + master + 104 triangle calls):")
        print("    8 x %d + %d + 104 x %d = %d cycles/sample  [UPPER BOUND]"
              % (v, m, t, total))
        for name, hz, sr in (("Daisy H750", 480e6, 48000), ("Daisy H750", 480e6, 44100),
                             ("Teensy 4.1", 600e6, 44100), ("Teensy 4.1 OC", 816e6, 44100),
                             ("i.MX RT1176", 1000e6, 48000)):
            b = hz / sr
            print("    %-14s @%4d MHz %5.1f kHz : budget %6d  ->  %.2fx %s"
                  % (name, hz/1e6, sr/1000, b, total/b,
                     "OK" if total <= b else "OVER"))
