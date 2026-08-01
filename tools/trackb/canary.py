#!/usr/bin/env python3
"""canary.py — how much of this module can the scenario set actually SEE?

WHY CELL PERTURBATION IS NOT ENOUGH (measured, 2026-07-31)
---------------------------------------------------------
observability.py nudges a state CELL and asks who notices. That answers two
useful questions -- does the value survive the sample (carriage), and is this
cell's stored value load-bearing -- but it does NOT answer the one a rewrite
needs: *if I get this module's arithmetic wrong, will the gate catch me?*

Two measured reasons, both from module M1:

  1. The transcription computes into LOCALS and stores to cells; most consumers
     use the local, not a reload. Perturbing the cell after the store changes
     nothing even though the value is used.
  2. Some consumers SATURATE. On the gate cell 560, multiplying by 3 changes
     nothing at all while adding 1 changes 83996 of 84000 samples -- because
     downstream the value is clamped, so any error that keeps it above the clamp
     is genuinely inaudible. That is a real property of the engine, not a probe
     defect: a native gate computing 1.0000001 instead of 1.0 IS inaudible.

So module admissibility is decided by a CANARY: plant a small error in the
module's own arithmetic, rebuild, and require the gate to catch it. This is step
8 of the per-module loop in docs/trackb/PLAN.md, promoted to also being step 1 --
run it BEFORE writing the module, on the transcription, to learn how much of the
module the scenarios can see at all.

METHOD
  For each assignment statement in the given line range of native/<file>, build a
  candidate with that statement's right-hand side scaled by --factor (default
  1.001 = 0.1%), and run the 7-scenario null. Report, per line, how many
  scenarios catch it. Lines caught by 0 scenarios are places where the gate is
  blind: an error there would ship.

USAGE
  canary.py --lines 623-693                 every assignment in the range
  canary.py --lines 623-693 --factor 1.01   louder canary
  canary.py --lines 1129-1149 --max 12      cap the number of builds
  canary.py --lines 964-1021 --add 1.0      ADDITIVE canary (see below)

WHY --add EXISTS (measured on M2/M3, the DCO oscillators, 2026-08-01)
  The default canary multiplies the right-hand side by 1.001. That probe is
  structurally incapable of moving two statement shapes, whatever the scenario
  set does:
    * `v123 = 0.0;`  -- 0.0 * 1.001 is 0.0. A literal zero cannot be scaled.
    * any value whose ONLY consumer is a sign test (`if (v128 < 0.0)`).
      For finite x, 1.001*x has the sign of x, always. Scaling can never flip
      a sign test, so the canary reports 0/N no matter how loud the real error
      would be.
  Seven of the twelve assignments in EACH DCO module are one of those two
  shapes, which is why the multiplicative survey reports them BLIND even after
  a scenario reaches them. `--add D` adds D to the right-hand side instead,
  which moves both shapes. It does NOT change the null threshold or the
  scenario set -- it is a different perturbation, not a weaker gate, and the
  default behaviour is unchanged.
Line numbers are in src/voice_render.c (the blueprints' numbering); they are
mapped onto native/voice_render.c by matching the statement text, so the fork's
header offset does not have to be tracked by hand.
"""
import sys, os, re, glob, shutil, tempfile, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import null_ab

ASSIGN = re.compile(r'^(\s*)([A-Za-z_]\w*(?:\([^()]*\))?)\s*=\s*(.+);\s*$')


def candidates(src_path, lo, hi):
    """[(src_line, text)] — assignment statements in [lo,hi] worth perturbing."""
    lines = open(src_path).read().split('\n')
    out = []
    for i in range(lo - 1, min(hi, len(lines))):
        t = lines[i]
        m = ASSIGN.match(t)
        if not m:
            continue
        rhs = m.group(3)
        if rhs.endswith('\\') or '"' in rhs:
            continue
        # A pure bit-copy (JI(a1,X) = JI(a1,Y)) has no arithmetic to perturb, and
        # scaling an int-typed cell as a float is a type error, not a canary.
        if m.group(2).startswith('JI(') or rhs.startswith('JI('):
            continue
        out.append((i + 1, t))
    return out


def build_with(mutated_text, orig_text, dst):
    tmp = tempfile.mkdtemp(prefix="canary_")
    shutil.copytree(os.path.join(REPO, "native"), os.path.join(tmp, "native"))
    p = os.path.join(tmp, "native", "voice_render.c")
    s = open(p).read()
    if s.count(orig_text) != 1:
        shutil.rmtree(tmp)
        return None                       # not uniquely locatable in the fork
    open(p, 'w').write(s.replace(orig_text, mutated_text, 1))
    native = sorted(glob.glob(os.path.join(tmp, "native", "*.c")))
    shadow = {os.path.basename(n) for n in native}
    src = [x for x in sorted(glob.glob(os.path.join(REPO, "src", "*.c")))
           if os.path.basename(x) not in shadow] + native
    r = subprocess.run(["cc", "-std=c99", "-O2", "-ffp-contract=off",
                        "-fno-strict-aliasing", "-I" + os.path.join(REPO, "src"),
                        "-shared", "-fPIC", "-o", dst,
                        os.path.join(REPO, "gui", "juno_bridge.c")] + src + ["-lm"],
                       capture_output=True, text=True)
    shutil.rmtree(tmp)
    return None if r.returncode else dst


def main():
    argv = sys.argv[1:]
    if "--lines" not in argv:
        raise SystemExit(__doc__)
    lo, hi = (int(x) for x in argv[argv.index("--lines") + 1].split("-"))
    factor = argv[argv.index("--factor") + 1] if "--factor" in argv else "1.001"
    addend = argv[argv.index("--add") + 1] if "--add" in argv else None
    cap = int(argv[argv.index("--max") + 1]) if "--max" in argv else 10 ** 6

    null_ab.truth.require()
    bank = open(null_ab.truth.BANK, "rb").read()
    ref = null_ab.load(os.path.join(REPO, "libjuno.so"))
    base = {tag: null_ab.render_script(ref, bank, null_ab.SR, p, sc)
            for p, sc, tag in null_ab.SCEN}

    cands = candidates(os.path.join(REPO, "src", "voice_render.c"), lo, hi)[:cap]
    print("=== TRACK B CANARY: %d assignments in src/voice_render.c:%d-%d, each "
          "%s ===" % (len(cands), lo, hi,
                      ("offset by +%s" % addend) if addend else
                      ("scaled by %s" % factor)))
    print("  a line caught by 0 scenarios is a place the gate is BLIND: an error "
          "there would ship.\n")
    blind, tested, skipped = [], 0, 0
    for ln, text in cands:
        m = ASSIGN.match(text)
        if addend:
            mutated = "%s%s = (float)(%s) + %sf;" % (m.group(1), m.group(2),
                                                     m.group(3), addend)
        else:
            mutated = "%s%s = (%s) * %sf;" % (m.group(1), m.group(2), m.group(3),
                                              factor)
        so = "/tmp/canary_%d.so" % ln
        if not build_with(mutated, text, so):
            skipped += 1
            print("  :%-5d SKIP (not uniquely locatable, or does not compile)" % ln)
            continue
        cand = null_ab.load(so)
        seen, worst = 0, None
        for p, sc, tag in null_ab.SCEN:
            out = null_ab.render_script(cand, bank, null_ab.SR, p, sc)
            sig, rel, blk, ok = null_ab.judge(base[tag], out)
            if not ok:
                seen += 1
                m2 = max(x for x in (rel, blk) if x is not None)
                worst = m2 if worst is None else max(worst, m2)
        tested += 1
        if seen == 0:
            blind.append(ln)
        print("  :%-5d %-58s %d/%d%s" % (ln, text.strip()[:58], seen,
                                         len(null_ab.SCEN),
                                         "" if worst is None else
                                         "  loudest %.1f dB" % worst))
        os.unlink(so)
    print("\nCANARY: %d/%d assignments observable; %d BLIND%s; %d skipped"
          % (tested - len(blind), tested, len(blind),
             (" (lines %s)" % blind[:20]) if blind else "", skipped))
    if blind:
        print("  A rewrite touching those lines cannot be validated by this "
              "scenario set.\n  Add a scenario that exercises them, or record them "
              "in the ledger as\n  out of scope with the reason.")
    return 1 if blind else 0


if __name__ == "__main__":
    sys.exit(main())
