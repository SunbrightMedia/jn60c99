#!/bin/sh
# foundation.sh -- ONE COMMAND FOR THE ENGINE B FOUNDATION.  `make engineb`.
#
# Runs every foundation gate in dependency order and stops at the first red.
# It stops rather than continuing because the gates are ordered: a null result
# from a stale library, or a module null run through a harness whose teeth have
# not been checked, is not a weaker result -- it is a MEANINGLESS one, and this
# project's recurring failure is exactly a green that means nothing.
#
# ORDER, and why:
#   1  labels        cheap, and it decides which src/ range a module claims to
#                    replace. Six of nine labels once pointed at the wrong
#                    subsystem; everything downstream inherits that.
#   2  unit tests    the engine B contracts (sizes / free-run / patch decode).
#                    They need no oracle, so they come before anything slow.
#   3  self-test     null_b --module none MUST be EXACTLY 0. This is the
#                    comparator's own passthrough proof. If it is not exactly
#                    zero, no module result below it can be believed.
#   4  teeth (B)     the module gate must be shown to CATCH a planted error
#                    before it is used to clear one.
#   5  modules       the actual engine B equivalence claims.
#   6  teeth (A/B)   the src/-level harness the module gate is built on.
#   7  cost          the rig's own calibration + the budget accounting.
#   8  ledger        every emitted row re-hashed: STALE / FORGED -> red.
#
# TIERS
#   full   (default)  everything above.
#   --quick           everything EXCEPT steps 4 and 6, the two teeth batteries,
#                     and it drops the one long scenario from the null runs.
#                     WHAT --quick DOES NOT COVER is printed by the run itself
#                     and is written out in docs/engineb/FOUNDATION.md. Short
#                     version: --quick checks that the gates are GREEN; it does
#                     not check that the gates can go RED.
set -u
cd "$(dirname "$0")/../.." || exit 2
REPO=$(pwd)
QUICK=0
[ "${1:-}" = "--quick" ] && QUICK=1

STEP=0
say()  { printf '\n=== [%s] %s ===\n' "$1" "$2"; }
die() {
    printf '\n########################################################\n'
    printf '### make engineb: RED at step %s -- %s\n' "$STEP" "$1"
    printf '###\n'
    shift
    while [ $# -gt 0 ]; do printf '### %s\n' "$1"; shift; done
    printf '########################################################\n'
    exit 1
}

printf '=== ENGINE B FOUNDATION (%s tier) ===\n' \
    "$([ $QUICK = 1 ] && echo quick || echo full)"
printf 'repo %s\n' "$REPO"
printf 'commit %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo '(no git)')"

# ---------------------------------------------------------------- 0 build deps
STEP="0 libjuno.so"
say "$STEP" "the reference library (the null's oracle side)"
make libjuno.so || die "libjuno.so did not build" \
    "The oracle side of every null is a fresh build of FROZEN src/." \
    "FIX: read the compiler error above. Do NOT edit src/ to make it" \
    "     compile -- src/ is sealed and bit-exact. If a header of yours" \
    "     is included by src/, that inclusion is the bug."

# ---------------------------------------------------------------- 1 labels
STEP="1 labels"
say "$STEP" "module labels vs the cells the code actually touches"
python3 tools/trackb/verify_labels.py || die "a module label names the wrong src/ range" \
    "A label decides which code a module claims to replace, so a wrong one" \
    "makes a green null a statement about the wrong subsystem." \
    "FIX: tools/trackb/verify_labels.py prints the range and the cells it" \
    "     really touches. Correct docs/trackb/MODULE_ORDER.md to match the" \
    "     MEASUREMENT, never the other way round." \
    "NOTE: 3 of the 9 ranges carry expect=None and are NOT checked at all" \
    "     (audit finding F3). A pass here is weaker than it looks."

# ---------------------------------------------------------------- 2 unit tests
STEP="2 engine_b unit tests"
say "$STEP" "sizes / free-run contract / 118-byte patch decode"
make -C engine_b/tests || die "an engine B unit test failed" \
    "These need no oracle: a failure here is engine B disagreeing with its" \
    "own contracts (hot-state budget, free-run determinism, patch decode)." \
    "FIX: run 'make -C engine_b/tests clean && make -C engine_b/tests' to" \
    "     rule out a stale binary, then read the FAIL lines -- each names" \
    "     the field or sample index that disagreed."

# ---------------------------------------------------------------- 3 self-test
STEP="3 null self-test"
say "$STEP" "null_b --module none  (MUST be EXACTLY 0, not 'below threshold')"
if [ $QUICK = 1 ]; then Q="--quick"; else Q=""; fi
python3 tools/engineb/null_b.py --module none $Q || die "the passthrough null is NOT exactly zero" \
    "With no module substituted, candidate and oracle are the same code." \
    "A non-zero residual means the HARNESS differs between the two sides --" \
    "every module number below would be measuring the harness, not engine B." \
    "FIX: this is a comparator bug, not a DSP bug. Check that engine_b/*.c" \
    "     linked into the reference has no global side effect, and that no" \
    "     shim directory leaked into the 'none' build."

# ---------------------------------------------------------------- 4 teeth (B)
STEP="4 null_b teeth"
if [ $QUICK = 1 ]; then
    say "$STEP" "SKIPPED by --quick -- the module gate's teeth are NOT checked"
else
    say "$STEP" "the module gate must catch planted errors"
    python3 tools/engineb/null_b.py --teeth || die "the module gate is BLIND to a planted error" \
        "A gate that cannot fail cannot clear anything. Do not run module" \
        "nulls until this is green." \
        "FIX: the battery names the mutation it lost. Either the scenario" \
        "     set no longer reaches that code (add a scenario -- do not" \
        "     relax the expectation), or the mutation stopped taking (check" \
        "     it still compiles into the candidate)."
fi

# ---------------------------------------------------------------- 5 modules
STEP="5 modules"
MODS=$(ls engine_b/shim 2>/dev/null | while read -r m; do
           [ -d "engine_b/shim/$m" ] && echo "$m"; done)
if [ -z "$MODS" ]; then
    say "$STEP" "no shim module exists yet -- nothing to null"
else
    for m in $MODS; do
        # The list is snapshotted above; re-check, because a run takes minutes
        # and a shim can be created or removed under it. A module that vanished
        # must be reported as SKIPPED, never reported as a null failure -- a
        # gate that blames the code for a race is a gate people stop believing.
        if [ ! -d "engine_b/shim/$m" ]; then
            say "$STEP" "SKIPPED '$m' -- its shim directory disappeared mid-run"
            continue
        fi
        say "$STEP" "null_b --module $m"
        python3 tools/engineb/null_b.py --module "$m" $Q || die "module '$m' does not null against src/" \
            "engine B's '$m' is audibly different from the frozen port." \
            "FIX: the failing scenarios are listed with a dB residual and a" \
            "     worst-1024-block figure. Reproduce one alone, then bisect" \
            "     the shim. Do NOT widen the threshold: the bands (-100 dB" \
            "     global / -80 dB block) are calibrated by the teeth battery" \
            "     in step 4 and moving one invalidates the other."
    done
fi

# ---------------------------------------------------------------- 6 teeth (A/B)
STEP="6 null_ab teeth"
if [ $QUICK = 1 ]; then
    say "$STEP" "SKIPPED by --quick -- the src/-level harness teeth are NOT checked"
else
    say "$STEP" "the underlying src/ A/B harness must catch planted errors"
    python3 tools/trackb/null_ab.py --teeth || die "the src/-level gate is BLIND to a planted error" \
        "null_b is built on this harness's scenarios and metrics, so a hole" \
        "here is a hole in every engine B result above." \
        "FIX: the battery prints, per mutation, the scenarios that caught it" \
        "     and the ones expected to. An expectation may only SHRINK when" \
        "     the loss is explained by measurement (e.g. the mutated code is" \
        "     proven bit-identical on that patch), never to go green."
fi

# ---------------------------------------------------------------- 7 cost
STEP="7 cost rig"
say "$STEP" "the cycle model's own calibration"
python3 tools/engineb/cost.py calibrate || die "the cost rig failed its calibration" \
    "Every S3 number in the ledger comes out of this model." \
    "FIX: read which anchor moved. If a silicon anchor changed, update the" \
    "     anchor and re-emit every ledger row -- do not leave rows costed" \
    "     by an old model."

say "$STEP" "budget accounting vs the 3,500 cyc/sample S3 target"
python3 tools/engineb/ledger.py show || die "the ledger could not be summarised" \
    "FIX: run 'python3 tools/engineb/ledger.py check' for the reason."
cat <<'EOF'
BUDGET NOTE (read before quoting the sum above):
  The sum is ADVISORY and is deliberately NOT a failure condition here.
  * It covers only the modules that are WRITTEN. Most of engine B, and all
    of the FX, contribute 0 to it because they do not exist.
  * The triangle row is charged at 104 invocations/sample, which is the
    ORACLE's measured call rate, not engine B's -- engine B's DCO is not
    written, so that is the number to BEAT, not a number engine B owes.
  Failing the build on an arithmetic that is knowingly incomplete would
  train everyone to pass -k. It is reported loudly and gated by nothing.
EOF

# ---------------------------------------------------------------- 8 ledger
STEP="8 ledger integrity"
say "$STEP" "re-hash every emitted row (STALE / FORGED)"
python3 tools/engineb/ledger.py check || die "the equivalence ledger does not match the tree" \
    "STALE = an artefact a row depends on (module source, proof source, gate" \
    "        harness, scenario set) changed after the row was emitted. The" \
    "        row's numbers describe code that no longer exists." \
    "FORGED = a row's own digest does not match its columns: someone edited" \
    "        a number by hand." \
    "FIX: re-run the proof and let it write the row --" \
    "     python3 tools/engineb/ledger.py emit --all" \
    "     There is no --accuracy and no --cycles argument, by design."

# Advisory, printed last so it is not lost: a shim that nulls green but has no
# ledger row has NO recorded cost and NO recorded accuracy evidence. Green here
# and absent there is the shape of a claim nobody can reproduce later.
UNLEDGERED=""
for m in $MODS; do
    [ "$m" = "skeleton" ] && continue
    grep -q "^$m@" docs/trackb/EQUIVALENCE.tsv 2>/dev/null || UNLEDGERED="$UNLEDGERED $m"
done
if [ -n "$UNLEDGERED" ]; then
    printf '\nADVISORY -- shim module(s) with NO ledger row:%s\n' "$UNLEDGERED"
    printf '  They nulled green above, but nothing recorded WHAT was proven or\n'
    printf '  what they COST. Close with: python3 tools/engineb/ledger.py emit <m>\n'
    printf '  (add a PROOFS entry first). Advisory, not a failure: a module can\n'
    printf '  legitimately be mid-flight. A module that ships without one cannot.\n'
fi

printf '\n########################################################\n'
printf '### make engineb: GREEN (%s tier)\n' \
    "$([ $QUICK = 1 ] && echo quick || echo full)"
if [ $QUICK = 1 ]; then
    printf '###\n### --quick DID NOT COVER:\n'
    printf '###   * null_b --teeth      (step 4) -- the module gate was NOT\n'
    printf '###     shown to be able to FAIL in this run.\n'
    printf '###   * null_ab.py --teeth  (step 6) -- ditto for the src/ harness.\n'
    printf '###   * the "long LFO+tail" scenario, dropped from every null.\n'
    printf '### A quick green says the gates are green. It does NOT say the\n'
    printf '### gates have teeth. Run the full tier before believing a module.\n'
fi
printf '########################################################\n'
exit 0
