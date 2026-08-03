#!/usr/bin/env python3
"""engine_price.py — what does the WHOLE of engine B cost on the ESP32-S3?

THE METHOD IS P3's, APPLIED TO EVERY MODULE. MEASURED x STATIC, and neither
half involves QEMU:

  STATIC  every engine B module is cross-compiled for the ESP32-S3 at the
          shipping flags and its instructions counted with objdump, including
          the libgcc helper bodies its relocations name (a call is ONE
          instruction to objdump; __divsf3's thirty are not).

  MEASURED the per-sample invocation counts are the port's own structure: the
          voice modules run once per voice per sample (eight), the DCO's inner
          step runs four times per voice, the envelopes twice, and the FX once
          for the whole engine. The DCO's own figure comes from
          tools/engineb/dco_price.py, which prices it on branch rates counted
          over the real gated scenario set rather than on a worst case.

WHY NOT QEMU. The QEMU harness's per-call spans are untrustworthy (CCOUNT
advances 25 instructions at a time at translation-block boundaries; two builds
differing only in EB_PITCH_FAST disagreed by exactly 500,000 units on functions
that did not change). Its sample_total is sound, but a sample_total of the
COMPLETE engine needs eb_engine_render to be gated and running, which it is
not. This tool answers the same question from the side that is already
measurable.

WHAT THIS IS NOT. It is not a cycle count: on an in-order LX7 the
cycles-per-instruction factor is >= 1 and unknown until silicon. It is not the
finished engine either -- it prices the per-sample DSP chain, and excludes
voice allocation, note handling and the once-per-recall coefficient
derivation. Both exclusions are stated in the output, not buried.
"""
import glob
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
XT = sorted(glob.glob("/root/.espressif/tools/xtensa-esp-elf/*/xtensa-esp-elf/bin"))
if not XT:
    raise SystemExit("no Xtensa toolchain found -- this prices the TARGET.")
GCC = os.path.join(XT[0], "xtensa-esp32s3-elf-gcc")
OBJDUMP = os.path.join(XT[0], "xtensa-esp32s3-elf-objdump")
CFLAGS = ["-std=c99", "-O2", "-ffp-contract=off", "-fno-strict-aliasing",
          "-I" + os.path.join(REPO, "engine_b"), "-I" + os.path.join(REPO, "src")]

# libgcc helper BODIES, MEASURED from this toolchain's own libgcc.a by locating
# the object that DEFINES each symbol (nm --defined-only) and counting its
# instructions. Finding the object that merely REFERENCES the symbol gives
# wildly wrong numbers -- _divdc3.o "contains" __muldf3 by reference and is 903
# instructions. __muldf3 = 105 and __adddf3 = 116 agree with the figures this
# project recorded independently, which cross-checks the method.
HELPERS = {"__divsf3": 30, "__muldf3": 105, "__adddf3": 116, "__subdf3": 148,
           "__truncdfsf2": 59, "__extendsfdf2": 37, "__fixdfsi": 28,
           # LIBM IS NOT FREE, and the first version of this tool charged it at
           # ZERO -- a hole in the flattering direction, caught in review.
           # MEASURED from this toolchain's own libm.a (wrapper + the
           # __ieee754_* body it calls): expf = 34+150, fmodf = 27+110.
           "expf": 184, "fmodf": 137, "fminf": 22, "fmaxf": 22, "fabsf": 4,
           "fmin": 22, "fmax": 22}

# (source, entry symbol, calls per audio sample, note)
# 8 voices unless stated. The DCO is priced separately by dco_price.py because
# its cost is branch-rate dependent and a static body count would be a worst
# case; the number below is that tool's real-patch figure per sample.
CHAIN = [
    ("eb_notecv.c",     "eb_notecv_tick",    1,  "noise LFSR, ENGINE-WIDE"),
    ("eb_glide.c",      "eb_glide_tick",     8,  "portamento + pitch CV"),
    ("eb_lfo.c",        "eb_lfo_tick",       8,  "LFO"),
    ("eb_envgen.c",     "eb_env_tick",      16,  "two envelopes per voice"),
    ("eb_cvgate.c",     "eb_cvgate",         8,  "CV/gate"),
    ("eb_pwm_cv.c",     "eb_modcv_tick",     8,  "pitch/PWM mod CV"),
    ("eb_pitch.c",      "eb_pitch_eval",     8,  "pitch polynomial"),
    ("eb_vcf_cv.c",     "eb_vcf_cv_tick",    8,  "VCF cutoff CV"),
    ("eb_vcf_res.c",    "eb_vcf_res_tick",   8,  "VCF resonance shaper"),
    ("eb_dcoprep.c",    "eb_dcoprep_tick",   8,  "DCO pitch prep"),
    ("eb_decim.c",      "eb_decim_tick",     8,  "4x decimator"),
    ("eb_noise_svf.c",  "eb_nsvf_tick",      8,  "noise SVF"),
    ("eb_noisemix.c",   "eb_noisemix_tick",  8,  "noise mix"),
    ("eb_vcf_ladder.c", "eb_vcf_tick",       8,  "VCF ladder"),
    ("eb_vca_hpf.c",    "eb_vca_tick",       8,  "VCA + HPF"),
    ("eb_chorus.c",     "eb_chorus_tick_x",  1,  "chorus, ENGINE-WIDE"),
    ("eb_delay.c",      "eb_delay_process",  1,  "delay, ENGINE-WIDE"),
    ("eb_reverb.c",     "eb_reverb_process", 1,  "reverb, ENGINE-WIDE"),
]

BUDGET_LO, BUDGET_HI = 6300, 9500      # 9,500 two-core cycles at c/i 1.5..1.0

# MEASURED HELPER RATES, applied PER CALL SITE. Call-site charging is the
# tool's default and is the safe direction -- but for a module whose helper
# sits in a rarely-taken guard arm it becomes a gross overstatement, the DCO
# worst-case problem in miniature. Where a rate has been MEASURED over the real
# gated scenario set it replaces the implicit 1.0 per site.
# eb_lfo's fmodf (EB_LFO_COUNT counters, 48 kHz, all 30 scenarios): 60,989,440
# wrap calls, 5,945,944 slow arms taken = 9.75% per wrap call. A wrap call has
# TWO fmodf sites and at most one fires, so the PER-SITE rate is 9.75/2 =
# 4.9% -- the first version of this override used 0.39 (the per-TICK count)
# per site and overstated the charge eightfold. Per tick the corrected charge
# is 4 wraps x 2 sites x 0.049 x 137 = 54 instructions, which matches the
# measured 0.39 executions x 137 directly.
RATE_OVERRIDES = {("eb_lfo.c", "fmodf"): 0.049}


def module_cost(src, entry, extra=()):
    """Executed instructions for ONE call of `entry`, expanding intra-TU calls.

    SUMMING EVERY SYMBOL IN THE TRANSLATION UNIT IS WRONG, and wrong in the
    optimistic direction. eb_pitch's fast path calls df_mul eleven times and
    df_mulf fifteen times per evaluation; a whole-TU sum counts each body ONCE
    and reports 921 instructions where the executed cost is about 3,100 -- a
    figure this project had already measured independently, which is how the
    error was caught. So the cost is computed over the CALL GRAPH: each
    function's own body plus, for every call site it contains, the callee's
    cost.

    Call SITES, not executed calls: for branchy code this over-estimates, which
    is the safe direction and is why the DCO -- much the branchiest module -- is
    priced by measured branch rates instead.
    """
    obj = "/tmp/ep_%s.o" % os.path.basename(src).replace(".c", "")
    subprocess.run([GCC] + CFLAGS + list(extra) +
                   ["-c", os.path.join(REPO, "engine_b", src), "-o", obj],
                   check=True)
    dis = subprocess.run([OBJDUMP, "-dr", obj], capture_output=True,
                         check=True).stdout.decode()
    # Symbol start addresses, so that section-relative call targets can be
    # resolved. A call to a STATIC function in the same translation unit does
    # not relocate against the symbol -- it relocates against `.text+0xNNN` --
    # so skipping dotted targets silently drops every intra-module call and
    # prices eb_pitch_eval at 18 instructions. Found by the number being
    # absurd against a figure already on record.
    addr, body, calls, cur = {}, {}, {}, None
    for ln in dis.splitlines():
        m = re.match(r"^([0-9a-f]+) <([^>]+)>:", ln)
        if m:
            cur = m.group(2)
            addr[int(m.group(1), 16)] = cur
            body.setdefault(cur, 0); calls.setdefault(cur, [])
            continue
        if not cur:
            continue
        mr = re.search(r"R_XTENSA\w*\s+(\S+)", ln)
        if mr:
            calls[cur].append(mr.group(1))
            continue
        if len(ln.split("\t")) >= 3 and ln.split("\t")[2].strip():
            body[cur] += 1

    starts = sorted(addr)

    def resolve(t):
        """A relocation target -> the symbol it lands in, or None."""
        if t.startswith(".text") or t.startswith(".literal"):
            if "+" not in t:
                return None
            off = int(t.split("+")[1], 16)
            if not t.startswith(".text"):
                return None            # literal pool, not a call
            hit = None
            for a in starts:
                if a <= off:
                    hit = addr[a]
                else:
                    break
            return hit
        return t.split("+")[0]

    seen = set()

    def cost(fn):
        if fn in HELPERS:
            return HELPERS[fn]
        if fn not in body:
            return 0                      # unknown external; nothing to charge
        if fn in seen:
            return body[fn]               # recursion guard: body only
        seen.add(fn)
        c = body[fn]
        for t in calls[fn]:
            r = resolve(t)
            if r is None or r == fn:
                continue
            mult = RATE_OVERRIDES.get((os.path.basename(src), r))
            if mult is not None and r in HELPERS:
                c += HELPERS[r] * mult
            else:
                c += cost(r)
        seen.discard(fn)
        return c

    # apply measured helper rates for this source file
    def helper_charge(fn, mult):
        return HELPERS[fn] * mult

    if entry not in body:
        raise SystemExit("entry symbol %s not found in %s -- the module was "
                         "renamed and this price would be silently wrong."
                         % (entry, src))
    return cost(entry)


def main():
    fast = "--fast-pitch" in sys.argv[1:]
    recip = "--recip" in sys.argv[1:]
    print("=== ENGINE B, WHOLE PER-SAMPLE DSP CHAIN, STATIC Xtensa "
          "instructions ===")
    print("build: pitch=%s  dco=%s\n"
          % ("EB_PITCH_FAST=1 (v7)" if fast else "double (default)",
             "EB_DCO_RECIP=1" if recip else "division (default)"))
    print("  %-18s %7s %6s %10s   %s"
          % ("module", "instr", "calls", "per sample", "note"))
    total = 0
    for src, sym, calls, note in CHAIN:
        extra = []
        if src == "eb_pitch.c" and fast:
            extra.append("-DEB_PITCH_FAST=1")
        cost = module_cost(src, sym, extra)
        total += cost * calls
        print("  %-18s %7d %6d %10d   %s" % (src[3:-2], cost, calls,
                                             cost * calls, note))
    # THE DCO: real-mix figure from dco_price.py, not a static body count.
    dco = 10202 if recip else 11610
    total += dco
    print("  %-18s %7s %6s %10d   %s"
          % ("dco", "--", "32", dco,
             "MEASURED branch rates x static paths (dco_price.py)"))
    print("\n  %-18s %25d instructions per audio sample" % ("TOTAL", total))
    print("\nAgainst the two-core instruction budget %d-%d "
          "(9,500 cycles at c/i 1.5..1.0):" % (BUDGET_LO, BUDGET_HI))
    print("  %.1fx to %.1fx OVER" % (total / float(BUDGET_HI),
                                     total / float(BUDGET_LO)))
    print("\nEXCLUDED, and stated rather than buried: voice allocation and note\n"
          "handling (eb_alloc, gated but not priced here), the once-per-recall\n"
          "coefficient derivation, and whatever the finished eb_engine_render\n"
          "adds in plumbing. Instructions are NOT cycles.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
