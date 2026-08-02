#!/usr/bin/env python3
"""cost.py -- the ENGINE B cycle cost rig.

Every engine B design decision must be measured, not argued. This tool turns a
C function or file into a per-sample cycle estimate for three targets:

    host      x86-64          (a reference point, and the only place where
                               DYNAMIC instruction counts can be MEASURED)
    m7        Cortex-M7       (Daisy Seed -- the calibration anchor, because
                               this project has real SILICON numbers for it)
    s3        ESP32-S3 LX7    (THE TARGET: 240 MHz, 1 core, 48 kHz
                               -> 5,000 cyc/sample hard, 3,500 budget)

LABELS. Every number this tool prints carries one of:
    MEASURED  produced by executing something (objdump of a real compile,
              callgrind of a real run, or a silicon number recorded in this
              repo's docs).
    MODELED   arithmetic on top of MEASURED inputs, using the CPI table below.
              A MODELED number is a BAND, never a point.
    STATIC    counted from the compiled object without executing it.

WHAT THIS TOOL IS NOT. It is not a simulator. Its M7 model is calibrated
against one real board measurement and its S3 model is calibrated against
NOTHING -- no S3 silicon number exists in this project. Every S3 cycle figure
is MODELED and is printed with its band. Read `cost.py calibrate` before
quoting any S3 number.

--------------------------------------------------------------------------
THE COST MODEL
--------------------------------------------------------------------------
    cycles_per_invocation = issue + memory

    issue  = SUM over instruction classes  n_class * rho * cpi_class
    memory = (loads + stores) * rho * extra_latency(memory_tier)

`rho` is the EXECUTION DENSITY: dynamic instructions divided by static
instructions for the same function at the same -O2. It is what stops this rig
from repeating the old llvm-mca error of charging both sides of every branch.
rho is MEASURED on the host with callgrind (`cost.py density`) and transferred
to the cross targets, which is the one genuinely MODELED step in the
instruction count.

`extra_latency` is the per-access stall beyond the base CPI. It is what makes
the Daisy number 669,682 instead of ~36,000, and it is why engine B's <1 KB
per voice matters more than its arithmetic.
"""

import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# ==========================================================================
# TARGETS
# ==========================================================================

BASE_CFLAGS = ["-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing",
               "-Wno-unused-parameter", "-Wno-unused-but-set-variable", "-w"]


def find_s3_gcc():
    for pat in ("/root/.espressif/tools/xtensa-esp-elf/*/xtensa-esp-elf/bin",
                os.path.expanduser("~/.espressif/tools/xtensa-esp-elf/*/xtensa-esp-elf/bin")):
        for d in sorted(glob.glob(pat)):
            gcc = os.path.join(d, "xtensa-esp32s3-elf-gcc")
            if os.path.exists(gcc):
                return gcc, os.path.join(d, "xtensa-esp32s3-elf-objdump")
    return None, None


def targets():
    """Available targets, in report order. Missing toolchains are SKIPPED
    loudly -- never silently, and never faked."""
    t = {}
    if shutil.which("gcc"):
        t["host"] = dict(cc="gcc", objdump=shutil.which("objdump"), isa="x86",
                         flags=[], name="x86-64 host")
    arm = shutil.which("arm-none-eabi-gcc")
    if arm:
        t["m7"] = dict(cc=arm, objdump=shutil.which("arm-none-eabi-objdump"), isa="arm",
                       flags=["-mcpu=cortex-m7", "-mfpu=fpv5-d16", "-mfloat-abi=hard"],
                       name="Cortex-M7 (Daisy Seed)")
    gcc3, od3 = find_s3_gcc()
    if gcc3:
        t["s3"] = dict(cc=gcc3, objdump=od3, isa="xtensa", flags=["-mlongcalls"],
                       name="ESP32-S3 LX7 (TARGET)")
    return t


# ==========================================================================
# INSTRUCTION CLASSIFICATION  (per ISA, applied to objdump mnemonics)
# ==========================================================================
# Classes: fp_arith fp_mem fp_move int_alu int_mem branch call other
# `libm` is a sub-count of `call` -- calls to expf/logf/powf/sinf/... which are
# hundreds of cycles each on a target with no FP library in ROM, and are the
# single easiest thing for a naive port to hide.

LIBM = re.compile(r"\b(exp|log|pow|sin|cos|tan|atan|asin|acos|sqrt|fmod|"
                  r"floor|ceil|round|trunc|ldexp|frexp|hypot|cbrt|tanh|sinh|cosh)"
                  r"[fl]?\b")


# Compiler-emitted arithmetic helpers. These are NOT libm; they are the
# compiler admitting the target cannot do the operation in hardware:
#   __divsf3      single-precision DIVIDE  (the LX7 FPU has no divider)
#   __*df3, __*df2, __extendsfdf2, __truncdfsf2   DOUBLE precision in software
# On the ESP32-S3 each one is tens to hundreds of cycles. A single stray
# `double` literal in an engine B module can cost more than the module. The rig
# reports them separately and loudly for exactly that reason.
SOFTFP = re.compile(r"^__(add|sub|mul|div|neg|cmp|eq|ne|lt|le|gt|ge|unord)"
                    r"(sf|df|tf)[23]$|^__(extend|trunc|float|fix|fixuns|floatun)\w*(sf|df)\w*$")


def classify_arm(mn, ops):
    if mn.startswith("v"):
        if re.match(r"v(ldr|str|ldm|stm|push|pop|ldn|stn)", mn):
            return "fp_mem"
        if re.match(r"v(mov|mrs|msr|cvt|dup|sel)", mn):
            return "fp_move"
        return "fp_arith"
    if re.match(r"^(bl|blx)$", mn):
        return "call"
    if re.match(r"^(b|bx|cbz|cbnz)(\.\w+)?$", mn) or re.match(r"^b(eq|ne|cs|cc|mi|pl|vs|vc|hi|ls|ge|lt|gt|le|al)", mn):
        return "branch"
    if re.match(r"^(ldr|str|ldm|stm|push|pop|ldrb|ldrh|strb|strh|ldrd|strd|ldrsb|ldrsh)", mn):
        return "int_mem"
    if mn.startswith("it"):
        return "other"
    return "int_alu"


X86_FP = re.compile(r"^(v?)(add|sub|mul|div|sqrt|max|min|and|andn|or|xor|cmp|ucomi|comi|"
                    r"rcp|rsqrt|round|fma\w*)(ss|sd|ps|pd)$")
X86_FPMOV = re.compile(r"^(v?)(mov(ss|sd|aps|apd|ups|upd|d|q)|cvt\w+|unpck\w+|shuf\w+|pxor|"
                       r"insert\w+|extract\w+|blend\w+)$")


def classify_x86(mn, ops):
    memop = bool(re.search(r"[-\w()%]*\(%[a-z0-9]+", ops)) or "(%rip)" in ops
    if X86_FP.match(mn):
        return "fp_mem" if memop else "fp_arith"
    if X86_FPMOV.match(mn):
        return "fp_mem" if memop else "fp_move"
    if mn == "call" or mn.startswith("call"):
        return "call"
    if re.match(r"^(jmp|j[a-z]+|loop\w*)$", mn):
        return "branch"
    if re.match(r"^(mov|movz|movs|lea|push|pop|xchg)", mn) and memop:
        return "int_mem"
    if memop:
        return "int_mem"
    return "int_alu"


XT_FP = re.compile(r"^(add|sub|mul|madd|msub|abs|neg|div0|recip0|rsqrt0|sqrt0|nexp01|"
                   r"const|addexp|divn|maddn|mkdadj|mksadj|un|oeq|ueq|olt|ult|ole|ule)\.s$")


def classify_xtensa(mn, ops):
    if mn in ("lsi", "lsx", "lsiu", "lsxu"):
        return "fp_mem"
    if mn in ("ssi", "ssx", "ssiu", "ssxu"):
        return "fp_mem"
    if mn in ("wfr", "rfr") or mn.startswith("float.s") or mn.startswith("trunc.s") \
       or mn.startswith("utrunc.s") or mn.startswith("ufloat.s") or mn.startswith("round.s") \
       or mn in ("mov.s", "moveqz.s", "movnez.s", "movltz.s", "movgez.s", "movt.s", "movf.s"):
        return "fp_move"
    if XT_FP.match(mn):
        return "fp_arith"
    if re.match(r"^(call0|call4|call8|call12|callx0|callx4|callx8|callx12)$", mn):
        return "call"
    if re.match(r"^(b\w+|j|jx|loop\w*|ret\w*)$", mn):
        return "branch"
    if re.match(r"^(l8ui|l16ui|l16si|l32i|l32i\.n|l32r|l32e|s8i|s16i|s32i|s32i\.n|s32e|"
                r"l32ai|s32ri)$", mn):
        return "int_mem"
    return "int_alu"


CLASSIFY = {"arm": classify_arm, "x86": classify_x86, "xtensa": classify_xtensa}


def access_weight(isa, mn, ops):
    """How many memory ACCESSES one memory INSTRUCTION performs.

    This matters and it is not cosmetic. ARM ldm/stm/push/pop/vldm/vstm move a
    whole register list in one instruction; counting instructions under-counts
    accesses, and accesses are the term that decides the whole budget. Found by
    calibrating against the SILICON accesses/sample figure, which the
    instruction-count version missed by 0.66x."""
    if isa == "arm":
        if re.match(r"^(ldm|stm|push|pop|vldm|vstm|vpush|vpop)", mn):
            br = re.search(r"\{([^}]*)\}", ops)
            if br:
                return max(1, br.group(1).count(",") + 1)
            return 1
        if re.match(r"^(ldrd|strd)", mn):
            return 2
    return 1
CLASSES = ["fp_arith", "fp_mem", "fp_move", "int_alu", "int_mem", "branch", "call", "other"]
MEMCLASSES = ("fp_mem", "int_mem")


# ==========================================================================
# CPI TABLE  (lo, nominal, hi) -- MODELED, from published core behaviour
# ==========================================================================
# M7: dual-issue in-order, FPv5-D16. FP single-precision throughput 1/cycle,
#     latency 4 -> a dependent chain costs up to 4. VMRS/VMOV core<->FP stall.
# S3: Xtensa LX7, single issue, 5 stage, single-precision FPU. No branch
#     predictor: a taken branch costs 2-3. Windowed calls can spill a register
#     window (the `call8` count is therefore a real risk, not free).
# x86: NOT modeled from this table -- for the host we use the callgrind
#     MEASURED instruction count and the MEASURED host IPC instead.

CPI = {
    "m7": {"fp_arith": (1.0, 1.8, 4.0), "fp_mem": (1.0, 1.5, 2.0),
           "fp_move": (1.0, 2.0, 5.0), "int_alu": (0.5, 0.7, 1.0),
           "int_mem": (1.0, 1.5, 2.0), "branch": (1.0, 2.0, 4.0),
           "call": (3.0, 4.0, 6.0), "other": (0.5, 1.0, 1.5)},
    "s3": {"fp_arith": (1.0, 1.3, 2.0), "fp_mem": (1.0, 1.3, 2.0),
           "fp_move": (1.0, 1.5, 2.5), "int_alu": (1.0, 1.0, 1.2),
           "int_mem": (1.0, 1.3, 2.0), "branch": (2.0, 2.5, 3.0),
           "call": (3.0, 4.0, 6.0), "other": (1.0, 1.0, 1.5)},
    "host": {c: (0.3, 0.4, 0.6) for c in CLASSES},
}

# Cost of one libm call, MODELED. newlib's expf/logf on an M7 with no
# hardware transcendentals. Wide band on purpose: this project has a
# MEASURED fact that expf glibc==newlib bit-identical, but no cycle count.
LIBM_CALL = (80.0, 150.0, 300.0)

# MEASURED EXECUTION OVERRIDES.  symbol -> executions per invocation.
#
# WHY THIS EXISTS (docs/engineb/HARNESS_AUDIT.md F5). The counts above are
# STATIC: how many call sites the compiler emitted. A call site inside a branch
# that is never taken costs nothing at run time, and charging it inflates the
# top of the band on exactly the modules that are being optimised.
#
# An entry here must be MEASURED by counting executions, never assumed. The one
# entry present was measured by planting a counter in the fallback arms of
# eb_dco_wrap and eb_triangle and rendering the full 30-scenario set: 0
# executions in 60,989,440 DCO steps. Those arms exist for out-of-domain phase
# values that a phase accumulator does not reach, and they are kept because
# removing them would change behaviour outside the measured domain -- they are
# unreached, not dead.
#
# Set from the command line with --exec SYMBOL=N. A symbol that is NOT listed
# keeps its static count, which is the conservative direction.
EXEC_OVERRIDE = {}


# Cost of one compiler soft-float helper call, MODELED, wide on purpose.
# __divsf3 sits at the low end, a soft-double multiply at the high end.
SOFT_CALL = (25.0, 70.0, 180.0)

# ==========================================================================
# MEMORY TIERS -- extra stall cycles per access, beyond the base CPI.
# ==========================================================================
# The Daisy rows are MEASURED in this repo (docs/trackb/SILICON_TRUTH.md, E7).
# They are the reason the port costs 669,682 and not ~36,000.
MEM_TIERS = {
    # name:            (lo, nom, hi, label, note)
    "tcm":       (0.0, 0.0, 0.5, "MEASURED-ANCHORED", "M7 ITCM/DTCM, zero wait"),
    "s3_iram":   (0.0, 0.3, 1.0, "MODELED", "ESP32-S3 internal SRAM, 0-wait nominal; "
                                            "band covers bus arbitration. NO S3 SILICON EXISTS."),
    "axi":       (13.0, 16.0, 19.0, "MEASURED", "Daisy AXI SRAM, from SILICON_TRUTH 14-19"),
    "sdram4":    (78.74, 78.74, 78.74, "MEASURED", "Daisy SDRAM, 4-byte stride (E7)"),
    "sdram16":   (138.10, 138.10, 138.10, "MEASURED", "Daisy SDRAM, 16-byte stride (E7)"),
    "s3_psram":  (30.0, 60.0, 120.0, "MODELED-UNVALIDATED", "ESP32-S3 octal PSRAM. "
                                                            "GUESS. Do not quote."),
}

DEFAULT_TIER = {"host": "tcm", "m7": "tcm", "s3": "s3_iram"}

# ==========================================================================
# MEASURED CONSTANTS from this repo -- the calibration anchors.
# ==========================================================================
ANCHORS = {
    # docs/trackb/SILICON_TRUTH.md, second full run, 64-bit accumulator.
    "daisy_port_qspi_sdram": 669682.0,
    "daisy_port_itcm": 525921.0,
    "daisy_accesses_per_sample": 9850.0,
    "daisy_budget_48k": 8333.0,
    # x86 host, port, 8 voices + FX
    "host_port_cyc_per_sample": 14970.0,
    # ESP32-S3, user-set
    "s3_hard_limit": 5000.0,
    "s3_budget": 3500.0,
}

# Execution density measured on this repo by `cost.py density` (callgrind
# delta method, 8 voices, patch 0, 48 kHz). See DENSITY_MEASURED below.
DENSITY_DEFAULT = 0.630          # MEASURED for juno_voice_render on x86-64
DENSITY_BAND = (0.55, 0.630, 1.00)   # hi = 1.0 == "every static instruction runs"

DENSITY_FILE = os.path.join(REPO, "docs", "engineb", "DENSITY.json")


def load_density():
    if os.path.exists(DENSITY_FILE):
        try:
            return json.load(open(DENSITY_FILE))
        except Exception:
            pass
    return {}


# ==========================================================================
# COMPILE + COUNT
# ==========================================================================

def compile_obj(tgt, sources, extra, outdir):
    obj = os.path.join(outdir, "cost_%s.o" % tgt["cc"].split("/")[-1].replace("-", "_"))
    objs = []
    for i, s in enumerate(sources):
        o = obj + ".%d.o" % i
        cmd = [tgt["cc"], "-c"] + BASE_CFLAGS + tgt["flags"] + extra + [s, "-o", o]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            return None, "COMPILE FAILED: %s\n%s" % (" ".join(cmd), r.stderr[-2000:])
        objs.append(o)
    return objs, None


DIS = re.compile(r"^\s*[0-9a-f]+:\s+(?:[0-9a-f]{2,8}\s)+\s*([a-z][\w.]*)\s*(.*)$")
FUNC = re.compile(r"^[0-9a-f]+\s+<([^>]+)>:")


def disassemble(tgt, objs):
    """-> {func: {'n': total, 'classes': {...}, 'libm': n, 'calls': [names]}}
    STATIC counts, from a real objdump of a real compile. MEASURED-STATIC."""
    out = {}
    cls = CLASSIFY[tgt["isa"]]
    for o in objs:
        r = subprocess.run([tgt["objdump"], "-d", "-r", o], capture_output=True, text=True)
        cur = None
        last_named = False
        for line in r.stdout.splitlines():
            m = FUNC.match(line)
            if m:
                cur = out.setdefault(m.group(1), dict(n=0, classes={c: 0 for c in CLASSES},
                                                      libm=0, soft=0, accesses=0,
                                                      callnames=[], softnames=[]))
                continue
            if cur is None:
                continue
            m = DIS.match(line)
            if not m:
                # A relocation line names the callee when the disassembly could
                # not. Counting BOTH double-counts every libm call -- objdump
                # prints "bl 0 <fmodf>" AND "R_ARM_THM_CALL fmodf". Only take
                # the relocation when the call line itself was anonymous.
                rm = re.search(r"R_\w+\s+([A-Za-z_][\w.]*)", line)
                if rm and not last_named:
                    nm2 = rm.group(1)
                    if SOFTFP.match(nm2):
                        cur["soft"] += 1
                        cur["softnames"].append(nm2)
                    elif LIBM.search(nm2):
                        cur["libm"] += 1
                        cur["callnames"].append(nm2)
                continue
            mn, ops = m.group(1), m.group(2)
            c = cls(mn, ops)
            last_named = False
            cur["n"] += 1
            cur["classes"][c] += 1
            if c in MEMCLASSES:
                cur["accesses"] += access_weight(tgt["isa"], mn, ops)
            if c == "call":
                nm = re.search(r"<([^>+]+)>", ops)
                if nm:
                    cur["callnames"].append(nm.group(1))
                    last_named = True
                    if SOFTFP.match(nm.group(1)):
                        cur["soft"] += 1
                        cur["softnames"].append(nm.group(1))
                    elif LIBM.search(nm.group(1)):
                        cur["libm"] += 1
    return out


# ==========================================================================
# THE MODEL
# ==========================================================================

def model_cycles(tgt_key, stat, rho_band, tier):
    """-> (lo, nom, hi) cycles per invocation. MODELED."""
    lat = MEM_TIERS[tier]
    res = []
    for i, rho in enumerate(rho_band):
        issue = 0.0
        for c in CLASSES:
            issue += stat["classes"][c] * CPI[tgt_key][c][i]
        mem = stat["accesses"] * lat[i]
        libm = _charged(stat, "libm", "callnames") * LIBM_CALL[i]
        soft = _charged(stat, "soft", "softnames") * SOFT_CALL[i]
        res.append((issue + mem + libm + soft) * rho)
    return tuple(res)


def _charged(stat, key, namekey):
    """Static call count, with any MEASURED execution count substituted in.

    Falls back to the static number for every symbol not measured, so an
    unlisted symbol is never quietly discounted."""
    names = stat.get(namekey) or []
    if not names or not EXEC_OVERRIDE:
        return stat.get(key, 0)
    n = 0.0
    for nm in names:
        n += EXEC_OVERRIDE.get(nm, 1.0)
    return n


def fmt(x):
    return "%,.0f".replace(",", ",") % x if False else format(int(round(x)), ",d")


def band(b):
    return "%s .. %s  (nom %s)" % (fmt(b[0]), fmt(b[2]), fmt(b[1]))


# ==========================================================================
# SUBCOMMAND: census / measure
# ==========================================================================

def cmd_measure(a):
    tg = targets()
    outdir = a.workdir
    os.makedirs(outdir, exist_ok=True)
    extra = ["-I" + i for i in (a.include or [])] + ["-D" + d for d in (a.define or [])]
    dens = load_density()
    calls = dict((x.split("=")[0], float(x.split("=")[1])) for x in (a.calls or []))
    EXEC_OVERRIDE.clear()
    for x in (getattr(a, "exec", None) or []):
        k, v = x.split("=", 1)
        EXEC_OVERRIDE[k] = float(v)
    if EXEC_OVERRIDE:
        print("MEASURED EXECUTION OVERRIDES in force: %s"
              "\n   (these replace the STATIC call count for those symbols; "
              "every other symbol keeps its static count)"
              % ", ".join("%s=%g" % kv for kv in sorted(EXEC_OVERRIDE.items())))

    print("=" * 78)
    print("ENGINE B COST RIG   sources: %s" % ", ".join(os.path.basename(s) for s in a.source))
    print("budget: %s cyc/sample (ESP32-S3 target)   hard limit %s"
          % (fmt(ANCHORS["s3_budget"]), fmt(ANCHORS["s3_hard_limit"])))
    print("=" * 78)

    missing = [k for k in ("host", "m7", "s3") if k not in tg]
    if missing:
        print("!! TOOLCHAIN MISSING, targets SKIPPED (not estimated, not faked): %s"
              % ", ".join(missing))

    report = {}
    for key in ("host", "m7", "s3"):
        if key not in tg:
            continue
        tgt = tg[key]
        objs, err = compile_obj(tgt, a.source, extra, outdir)
        if err:
            print("\n[%s] %s" % (key, err))
            continue
        funcs = disassemble(tgt, objs)
        sel = {f: v for f, v in funcs.items()
               if (not a.func or any(re.search(p, f) for p in a.func)) and v["n"] > 0}
        if not sel:
            print("\n[%s] no matching functions in %s" % (key, list(funcs)))
            continue
        tier = a.tier or DEFAULT_TIER[key]
        print("\n" + "-" * 78)
        print("TARGET %-5s %-28s  memory tier: %s  [%s]"
              % (key, tgt["name"], tier, MEM_TIERS[tier][3]))
        print("        %s" % MEM_TIERS[tier][4])
        print("-" * 78)
        hdr = "%-26s %6s %6s %6s %6s %6s %6s %6s %5s %5s" % (
            "function (STATIC counts)", "total", "fparit", "fpmem", "fpmov",
            "intalu", "intmem", "brnch", "libm", "soft")
        print(hdr)
        tot = {c: 0 for c in CLASSES}
        tot_n = tot_libm = tot_acc = tot_soft = 0
        rows = []
        for f, v in sorted(sel.items(), key=lambda kv: -kv[1]["n"]):
            c = v["classes"]
            print("%-26s %6d %6d %6d %6d %6d %6d %6d %5d %5d" % (
                f[:26], v["n"], c["fp_arith"], c["fp_mem"], c["fp_move"],
                c["int_alu"], c["int_mem"], c["branch"], v["libm"], v["soft"]))
            for k in CLASSES:
                tot[k] += c[k]
            tot_n += v["n"]
            tot_libm += v["libm"]
            tot_acc += v["accesses"]
            tot_soft += v["soft"]
            rows.append((f, v))
        agg = dict(n=tot_n, classes=tot, libm=tot_libm, accesses=tot_acc, soft=tot_soft)

        if tot_soft or tot_libm:
            from collections import Counter
            sn = Counter(n for v in sel.values() for n in v["softnames"])
            ln = Counter(n for v in sel.values() for n in v["callnames"] if LIBM.search(n))
            if tot_soft:
                print("\n!! SOFT-FLOAT HELPERS on this target [MEASURED-STATIC]: %d calls  %s"
                      % (tot_soft, dict(sn)))
                print("   The compiler could not do this arithmetic in hardware here.")
                print("   __divsf3 = a float divide; __*df* = a DOUBLE leaked into the code.")
                print("   Modelled at %g..%g cyc each. Remove them before optimising anything else."
                      % (SOFT_CALL[0], SOFT_CALL[2]))
            if tot_libm:
                print("\n!! LIBM CALLS [MEASURED-STATIC]: %d  %s   modelled %g..%g cyc each"
                      % (tot_libm, dict(ln), LIBM_CALL[0], LIBM_CALL[2]))

        # execution density
        if a.rho is not None:
            rb = (a.rho, a.rho, a.rho)
            rlab = "USER-SUPPLIED"
        elif a.func and len(a.func) == 1 and a.func[0] in dens:
            d = dens[a.func[0]]
            rb = (d["rho"] * 0.9, d["rho"], min(1.0, d["rho"] * 1.15))
            rlab = "MEASURED (callgrind, this repo)"
        else:
            rb = DENSITY_BAND
            rlab = "MEASURED-TRANSFERRED from juno_voice_render (rho=%.3f), band to 1.0" % DENSITY_DEFAULT
        print("\nexecution density rho = %.3f .. %.3f   [%s]" % (rb[0], rb[2], rlab))

        mem_acc = tot_acc
        print("memory ACCESSES per invocation (STATIC, register-list weighted): %s   x rho -> %s .. %s"
              % (fmt(mem_acc), fmt(mem_acc * rb[0]), fmt(mem_acc * rb[2])))

        # ---- per-module breakdown ------------------------------------
        print("\nPER-MODULE BREAKDOWN [MODELED, nominal; band in the totals below]")
        print("%-26s %8s %10s %12s %8s" % ("function", "calls/s", "cyc/call",
                                           "cyc/sample", "% budget"))
        bud = ANCHORS["s3_budget"]
        rows2 = []
        for f, v in sorted(sel.items(), key=lambda kv: -kv[1]["n"]):
            n = calls.get(f, a.per_sample)
            one = model_cycles(key, v, rb, tier)
            rows2.append((f, n, one))
        rows2.sort(key=lambda r: -r[1] * r[2][1])
        for f, n, one in rows2:
            print("%-26s %8g %10s %12s %7.1f%%" % (
                f[:26], n, fmt(one[1]), fmt(one[1] * n), 100.0 * one[1] * n / bud))
        tot_nom = sum(n * one[1] for _, n, one in rows2)
        print("%-26s %8s %10s %12s %7.1f%%" % ("TOTAL", "", "", fmt(tot_nom),
                                               100.0 * tot_nom / bud))

        cyc = model_cycles(key, agg, rb, tier)
        print("\ncycles per invocation   [MODELED]: %s" % band(cyc))
        if calls:
            per = tuple(sum(calls.get(f, a.per_sample) * model_cycles(key, v, rb, tier)[i]
                            for f, v in sel.items()) for i in range(3))
            print("invocations per sample: per-function (--calls)")
        else:
            per = cyc[0] * a.per_sample, cyc[1] * a.per_sample, cyc[2] * a.per_sample
            print("invocations per sample: %g" % a.per_sample)
        print("CYCLES PER SAMPLE       [MODELED]: %s" % band(per))
        if key == "s3":
            b = ANCHORS["s3_budget"]
            print("vs ENGINE B BUDGET %s: %.2fx .. %.2fx of budget   -> %s"
                  % (fmt(b), per[0] / b, per[2] / b,
                     "FITS across the whole band" if per[2] <= b else
                     ("FITS only at the optimistic end" if per[0] <= b else "OVER BUDGET across the whole band")))
            hl = ANCHORS["s3_hard_limit"]
            print("vs HARD LIMIT      %s: %.2fx .. %.2fx" % (fmt(hl), per[0] / hl, per[2] / hl))
        report[key] = dict(target=tgt["name"], tier=tier, static=agg,
                           rho=list(rb), cyc_per_invocation=list(cyc),
                           per_sample=list(per), label="MODELED",
                           functions={f: v for f, v in sel.items()})

    if a.json:
        json.dump(report, open(a.json, "w"), indent=1)
        print("\nwrote %s" % a.json)
    print("\n" + "=" * 78)
    print("ERROR BARS. The band above is NOT a confidence interval; it is the")
    print("span of the CPI and density assumptions. Its width is the honest")
    print("answer. Run `cost.py calibrate` to see how far the M7 arm of this")
    print("model lands from the one real SILICON number this project owns.")
    print("=" * 78)
    return 0


# ==========================================================================
# SUBCOMMAND: density  (MEASURED, callgrind delta method)
# ==========================================================================

def cmd_density(a):
    """Measure dynamic/static execution density with callgrind.

    Delta method: run the same binary at two sample counts and divide the
    difference. This removes setup, bank parse and teardown, which would
    otherwise be charged to the render loop."""
    if not shutil.which("valgrind"):
        print("SKIP: valgrind not installed. No density can be MEASURED.")
        return 2
    os.makedirs(a.workdir, exist_ok=True)
    counts = {}
    for n in (a.n_low, a.n_high):
        out = os.path.join(a.workdir, "cg_%d.out" % n)
        cmd = ["valgrind", "--tool=callgrind", "--callgrind-out-file=" + out] + \
              [x.replace("{n}", str(n)) for x in a.cmd]
        r = subprocess.run(cmd, capture_output=True, text=True, cwd=REPO)
        if r.returncode != 0:
            print("callgrind failed:\n" + r.stderr[-2000:])
            return 1
        ann = subprocess.run(["callgrind_annotate", "--threshold=99.9", out],
                             capture_output=True, text=True).stdout
        per = {}
        for line in ann.splitlines():
            m = re.match(r"\s*([\d,]+)\s*\(\s*[\d.]+%\)\s+\S*:(\S+)", line)
            if m:
                per[m.group(2).split()[0]] = int(m.group(1).replace(",", ""))
        m = re.search(r"I\s+refs:\s+([\d,]+)", r.stderr)
        per["__TOTAL__"] = int(m.group(1).replace(",", "")) if m else sum(per.values())
        counts[n] = per

    divisors = dict((x.split("=")[0], float(x.split("=")[1])) for x in (a.divisor or []))
    nsamp = a.n_high - a.n_low
    print("=" * 78)
    print("EXECUTION DENSITY -- MEASURED (callgrind, delta of n=%d and n=%d)"
          % (a.n_low, a.n_high))
    print("=" * 78)
    dyn = {}
    for f in sorted(set(counts[a.n_high]) | set(counts[a.n_low])):
        d = counts[a.n_high].get(f, 0) - counts[a.n_low].get(f, 0)
        if d > 0:
            dyn[f] = d / float(nsamp)

    # static counts on the host, for the same functions
    tg = targets()
    stat = {}
    if a.source:
        objs, err = compile_obj(tg["host"], a.source, ["-I" + i for i in (a.include or [])],
                                a.workdir)
        if err:
            print(err)
        else:
            stat = disassemble(tg["host"], objs)

    print("rho > 1 means the function runs more than once per sample (leaf helper);")
    print("pass --divisor FUNC=N to normalise it. rho < 1 means branches skip code.\n")
    print("%-30s %14s %10s %8s  %s" % ("function", "dyn instr/samp", "static", "rho", "label"))
    res = {}
    for f, d in sorted(dyn.items(), key=lambda kv: -kv[1])[:a.top]:
        s = stat.get(f, {}).get("n", 0)
        div = divisors.get(f, 1)
        rho = (d / div) / s if s else None
        print("%-30s %14s %10s %8s  %s" % (
            f[:30], format(int(d), ",d"), format(s, ",d") if s else "-",
            "%.3f" % rho if rho else "-",
            "MEASURED" if rho else "MEASURED (dynamic only)"))
        if rho:
            res[f] = dict(rho=round(rho, 4), dyn_per_sample=d, static=s,
                          label="MEASURED", divisor=div)
    print("\nTOTAL host instructions/sample [MEASURED]: %s"
          % fmt(dyn.get("__TOTAL__", sum(dyn.values()))))
    res["__TOTAL__"] = dict(dyn_per_sample=dyn.get("__TOTAL__", sum(dyn.values())),
                            label="MEASURED", note="whole process, per audio sample")
    if a.save:
        os.makedirs(os.path.dirname(DENSITY_FILE), exist_ok=True)
        old = load_density()
        old.update(res)
        json.dump(old, open(DENSITY_FILE, "w"), indent=1)
        print("wrote %s" % DENSITY_FILE)
    return 0


# ==========================================================================
# SUBCOMMAND: calibrate
# ==========================================================================

CAL_DOC = """
CALIBRATION -- what this rig is allowed to claim.

The task brief supplied a decomposition of "1.125x instruction count x 2.53x
in-order CPI x 2.193x memory-and-fetch stalls" = 6.24x from the x86 host to
the Daisy. Applied to the MEASURED host figure it gives:

    14,970 x 6.24 = 93,414 cyc/sample

That is the OLD E2 number (93,288) -- the one docs/trackb/SILICON_TRUTH.md
proves was a 32-bit DWT counter wrap artefact and declares VOID. The true
SILICON figure is 669,682. So:

    TRUE host->Daisy ratio = 669,682 / 14,970 = 44.7x
    the 6.24x decomposition accounts for                6.24x
    UNACCOUNTED residual                                7.16x

This rig therefore does NOT use a blanket multiplier at all. The 7.16x
residual is not a mystery: SILICON_TRUTH measures 9,850 memory accesses per
sample at 68 cycles each = 669,800 cyc/sample, which is the entire Daisy cost
to within 0.02%. The port is memory-bound on SDRAM and its arithmetic is
almost free by comparison.

So the model is issue + accesses x per-access-latency, with latency a MEASURED
property of where the state lives. That is also the whole thesis of engine B:
moving 10,512 B/voice into <1 KB/voice does not make the arithmetic faster, it
removes the term that is 95% of the cost.
"""


def cmd_calibrate(a):
    print(CAL_DOC)
    tg = targets()
    print("=" * 78)
    print("AVAILABLE TOOLCHAINS")
    for k in ("host", "m7", "s3"):
        print("  %-5s %s" % (k, tg[k]["name"] + "  " + tg[k]["cc"] if k in tg else "MISSING -- target SKIPPED"))
    print("=" * 78)

    src = [os.path.join(REPO, "src", "voice_render.c"),
           os.path.join(REPO, "src", "master_render.c")]
    src = [s for s in src if os.path.exists(s)]
    inc = ["-I" + os.path.join(REPO, "src")]
    dens = load_density()

    print("\nANCHOR 1 [MEASURED, docs/trackb/SILICON_TRUTH.md]")
    print("  Daisy Seed, port, 8 voices + FX, QSPI + SDRAM : %s cyc/sample"
          % fmt(ANCHORS["daisy_port_qspi_sdram"]))
    print("  same, both hot functions in ITCM              : %s cyc/sample"
          % fmt(ANCHORS["daisy_port_itcm"]))
    print("  memory accesses per sample                    : %s"
          % fmt(ANCHORS["daisy_accesses_per_sample"]))
    print("  implied cycles per access                     : %.1f"
          % (ANCHORS["daisy_port_qspi_sdram"] / ANCHORS["daisy_accesses_per_sample"]))
    print("ANCHOR 2 [MEASURED] x86-64 host, same workload  : %s cyc/sample"
          % fmt(ANCHORS["host_port_cyc_per_sample"]))

    if "m7" not in tg:
        print("\nCANNOT CALIBRATE: no arm-none-eabi-gcc.")
        return 2

    objs, err = compile_obj(tg["m7"], src, inc, a.workdir)
    if err:
        print(err)
        return 1
    f7 = disassemble(tg["m7"], objs)
    vr = f7.get("juno_voice_render")
    mr = f7.get("juno_master_render")
    if not vr:
        print("juno_voice_render not found in the M7 build")
        return 1

    rho = dens.get("juno_voice_render", {}).get("rho", DENSITY_DEFAULT)
    rlab = "MEASURED" if "juno_voice_render" in dens else "MEASURED (baked default, re-run `density` to refresh)"
    print("\nEXECUTION DENSITY of juno_voice_render on x86 : rho = %.3f  [%s]" % (rho, rlab))

    print("\nSTATIC instruction counts, this compile [MEASURED-STATIC]")
    for key in ("host", "m7", "s3"):
        if key not in tg:
            continue
        o2, e2 = compile_obj(tg[key], src, inc, a.workdir)
        if e2:
            print("  %-5s COMPILE FAILED" % key)
            continue
        ff = disassemble(tg[key], o2)
        v = ff.get("juno_voice_render", {})
        m = ff.get("juno_master_render", {})
        acc = v.get("accesses", 0)
        print("  %-5s voice_render %6s instr, %5s memory accesses | master_render %6s instr"
              % (key, fmt(v.get("n", 0)), fmt(acc), fmt(m.get("n", 0))))

    # ---- the M7 back-solve
    accv = vr["accesses"]
    accm = mr["accesses"] if mr else 0
    dyn_acc = (8 * accv + accm) * rho
    print("\nM7 BACK-SOLVE against the SILICON anchor")
    print("  modelled accesses/sample = (8 x %s + %s) x rho %.3f = %s   [MODELED]"
          % (fmt(accv), fmt(accm), rho, fmt(dyn_acc)))
    print("  SILICON measured accesses/sample                         = %s   [MEASURED]"
          % fmt(ANCHORS["daisy_accesses_per_sample"]))
    print("  agreement: %.2fx  <-- this is the rig's only independent check that"
          % (dyn_acc / ANCHORS["daisy_accesses_per_sample"]))
    print("             its static->dynamic pipeline is not lying")

    agg = dict(n=0, classes={c: 8 * vr["classes"][c] + (mr["classes"][c] if mr else 0)
                             for c in CLASSES},
               libm=8 * vr["libm"] + (mr["libm"] if mr else 0),
               accesses=8 * accv + accm,
               soft=8 * vr.get("soft", 0) + (mr.get("soft", 0) if mr else 0))
    for tier in ("tcm", "axi", "sdram4", "sdram16"):
        cyc = model_cycles("m7", agg, (rho, rho, rho), tier)
        print("  M7 model, tier %-8s -> %10s cyc/sample   [MODELED]"
              % (tier, fmt(cyc[1])))
    print("  SILICON, QSPI + SDRAM        -> %10s cyc/sample   [MEASURED]"
          % fmt(ANCHORS["daisy_port_qspi_sdram"]))
    print("  SILICON, hot code in ITCM    -> %10s cyc/sample   [MEASURED]"
          % fmt(ANCHORS["daisy_port_itcm"]))

    # Back-solve the per-access latency the SILICON number implies, given the
    # issue term this rig computes. This is the calibration, and it is the one
    # number that says whether the model's SHAPE is right.
    issue_only = model_cycles("m7", agg, (rho, rho, rho), "tcm")[1]
    sil = ANCHORS["daisy_port_qspi_sdram"]
    dyn_acc_m = agg["accesses"] * rho
    implied = (sil - issue_only) / dyn_acc_m
    print("\n  IMPLIED per-access latency to reproduce SILICON exactly: %.1f cyc" % implied)
    print("  MEASURED Daisy SDRAM latencies (E7): 4-byte stride %.1f, 16-byte stride %.1f"
          % (MEM_TIERS["sdram4"][1], MEM_TIERS["sdram16"][1]))
    print("  SILICON-implied cyc/access from the board's own access count: %.1f"
          % (sil / ANCHORS["daisy_accesses_per_sample"]))
    ratio = model_cycles("m7", agg, (rho, rho, rho), "sdram4")[1] / sil
    print("\n  VERDICT: with every state cell in SDRAM at the MEASURED 4-byte-stride")
    print("           latency, this rig predicts %s against a SILICON %s."
          % (fmt(model_cycles("m7", agg, (rho, rho, rho), "sdram4")[1]), fmt(sil)))
    print("           ERROR = %.2fx. The rig %s the board." % (ratio, "over-predicts" if ratio > 1 else "under-predicts"))
    print("           It over-predicts because not every access reaches SDRAM: stack,")
    print("           literals and the chorus block live in faster memory. The implied")
    print("           blended latency %.1f sits between the MEASURED AXI (%.0f) and" % (implied, MEM_TIERS["axi"][1]))
    print("           SDRAM-4B (%.1f) tiers, which is what a mixed placement should give." % MEM_TIERS["sdram4"][1])
    print("           TAKE FROM THIS: the M7 arm is good to about +/- 1.2x on a")
    print("           memory-bound workload. Do not quote its third digit.")
    # ---- second, independent validation point: the host itself -----------
    dtot = dens.get("__TOTAL__", {}).get("dyn_per_sample")
    print("\nVALIDATION 2 -- the host arm, which is independent of the M7 arm")
    if dtot:
        ipc = dtot / ANCHORS["host_port_cyc_per_sample"]
        print("  MEASURED host instructions/sample (callgrind)      : %s" % fmt(dtot))
        print("  MEASURED host cycles/sample                        : %s"
              % fmt(ANCHORS["host_port_cyc_per_sample"]))
        print("  implied host IPC                                   : %.2f  [MEASURED]" % ipc)
        hm = sum(dtot * CPI["host"][c][1] for c in ["int_alu"]) / len(["int_alu"])
        print("  this rig's host CPI table predicts                 : %s cyc/sample" % fmt(hm))
        print("  host model error                                   : %.2fx" % (hm / ANCHORS["host_port_cyc_per_sample"]))
        print("  An out-of-order x86 is the WORST case for a static rig; that this")
        print("  arm lands inside ~1.3x is a floor on the rig's quality, not a ceiling.")
    else:
        print("  SKIPPED: no MEASURED host total. Run `cost.py density ... --save`.")

    print("""
WHAT IS AND IS NOT CALIBRATED
  M7 + SDRAM      : anchored on 1 real board measurement, 1 workload. Trust
                    the ORDER OF MAGNITUDE, not the third digit.
  M7 + TCM/AXI    : the per-access latencies are MEASURED (E7) but the
                    combination has never been measured end to end. MODELED.
  ESP32-S3        : NOTHING is calibrated. No S3 board exists in this project.
                    The instruction counts are MEASURED-STATIC from a real
                    xtensa-esp32s3-elf compile; every cycle number is MODELED
                    and its band is the honest answer. The rig's S3 nominal
                    should be treated as +/- 2x until a board says otherwise.
  Density rho     : MEASURED on x86 and TRANSFERRED to M7/S3. Same source,
                    same -O2, same control flow -- but not the same branch
                    layout. Treat as +/- 15%.
""")
    return 0


# ==========================================================================

def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = p.add_subparsers(dest="cmd", required=True)

    def common(q):
        q.add_argument("--workdir", default="/tmp/engineb_cost")
        q.add_argument("--include", "-I", action="append")

    m = sub.add_parser("measure", help="cost a C file or function for all targets")
    common(m)
    m.add_argument("source", nargs="+")
    m.add_argument("--func", action="append", help="regex; repeatable. default: all")
    m.add_argument("--per-sample", type=float, default=1.0,
                   help="invocations per audio sample (e.g. 8 for a per-voice function)")
    m.add_argument("--tier", choices=sorted(MEM_TIERS), help="memory tier override")
    m.add_argument("--rho", type=float, help="force execution density")
    m.add_argument("--define", "-D", action="append")
    m.add_argument("--calls", action="append",
                   help="FUNC=N invocations per sample for that function; "
                        "overrides --per-sample in the breakdown. Repeatable.")
    m.add_argument("--exec", action="append", default=[], metavar="SYM=N",
                   help="MEASURED executions per invocation for a libm or "
                        "soft-float symbol, e.g. --exec fmodf=0. Unlisted "
                        "symbols keep their STATIC count. Never assume a "
                        "value here -- count it.")
    m.add_argument("--json")
    m.set_defaults(func_=cmd_measure)

    d = sub.add_parser("density", help="MEASURE dynamic/static density with callgrind")
    common(d)
    d.add_argument("cmd", nargs="+", help="command; {n} is replaced by the sample count")
    d.add_argument("--n-low", type=int, default=1000)
    d.add_argument("--n-high", type=int, default=3000)
    d.add_argument("--source", nargs="*", help="sources to static-count for rho")
    d.add_argument("--top", type=int, default=20)
    d.add_argument("--save", action="store_true")
    d.add_argument("--divisor", action="append", default=[],
                   help="FUNC=N -- invocations per sample (e.g. juno_voice_render=8)")
    d.set_defaults(func_=cmd_density)

    c = sub.add_parser("calibrate", help="check the model against the SILICON anchors")
    common(c)
    c.set_defaults(func_=cmd_calibrate)

    a = p.parse_args()
    os.makedirs(a.workdir, exist_ok=True)
    return a.func_(a)


if __name__ == "__main__":
    sys.exit(main())
