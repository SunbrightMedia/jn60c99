export const meta = {
  name: 'engineb-s3-assessment',
  description: 'Verify engine B state and measure the true ESP32-S3 cost, then a verdict',
  phases: [
    { title: 'Measure', detail: 'gates, float-pitch null, xtensa table, libgcc paths, qemu scout' },
    { title: 'Verdict', detail: 'adversarial synthesis into S3_ASSESSMENT.md' },
  ],
}

const CTX = `Repo /home/user/jn60c99. ENGINE B for the JUNO-60 port.

SITUATION. Engine B is 13 DSP modules, each proven bit-exact against the plugin
binary (the authority, run under Unicorn) at 44.1 and 48 kHz, whole-engine, via
tools/engineb/null_b.py (proxy gate vs the sealed port in src/) and
tools/engineb/plugin_check.py (authority gate). The goal is USER-BINDING:
8 voices + ALL FX + 48 kHz, sonically accurate, on an ESP32-S3 (240 MHz LX7).
Budget: 5,000 cycles/sample on one core (hard), 3,500 target; the second core is
a reserve that may be spent before any voice is dropped. 6 voices is the ONLY
permitted compromise and only as a LAST RESORT (docs/trackb/CONSTRAINTS.md).
ACCURACY STANDARD (docs/trackb/ACCURACY_STANDARD.md): sample-domain null vs the
port at <= -100 dB global / -80 dB worst-1024-block. Bit-exact is kept where
free, but -100 dB is the gate.

A prior analysis compared HOST x86 callgrind instruction counts (engine B DSP =
15,450 instr/sample at 8 voices, patch 20, 48 kHz) directly against the S3 cycle
budget and concluded the target is unreachable. That comparison is INVALID in
both directions: host counts hide S3-only costs (soft-double, soft-divide) and
host x86 instructions are not S3 cycles.

NEW MEASURED FACTS (2026-08-03, xtensa-esp32s3-elf-gcc -O2, relocation census):
- engine_b/eb_pitch.c runs 8x/sample (once per voice) and each call makes
  ~23 __muldf3 + 13 __adddf3 + 2 __extendsfdf2 + 1 __fixdfsi + 1 __truncdfsf2
  + 2 double fmin/fmax calls. libgcc for esp32s3: __muldf3 = 105 static instrs,
  __adddf3 = 116, __truncdfsf2 = 59, __extendsfdf2 = 37, __fixdfsi = 28,
  __divsf3 = 30 (FPU-assisted, cheap).
- eb_dco: 7 static __divsf3 sites; MEASURED 32 executed divides/sample.
- eb_vcf_ladder: 1 __divsf3 site.
- Everything else: clean (no soft-float, no libm on the hot path; fmodf sites
  exist but MEASURED 0 executions in 60,989,440 DCO steps).

RULES (from CLAUDE.md, binding):
- The plugin binary under Unicorn is the ONLY ground truth. src/ is the frozen
  bit-exact port and the fast proxy oracle. NEVER edit src/.
- Two-process rule: never build a Unicorn E2E instance and ctypes-load a .so in
  the same python process. null_b.py already obeys this; use it, do not rebuild.
- Never validate by ear. Label every number PROVEN(executed)/MEASURED/STATIC/
  MODELED/READ/INFERRED.
- Do NOT commit or push. Write results to files and report; the main session
  commits.
- Toolchain: export PATH=/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/xtensa-esp-elf/bin:$PATH
- Report only numbers you measured, with the exact command that produced them.`

phase('Measure')

const results = await parallel([
  () => agent(`${CTX}

TASK: certify the CURRENT gate state of engine B. Run, verbatim, and report:
 1. make -C engine_b/tests            (six unit tests, seconds)
 2. python3 tools/engineb/null_b.py --module all --quick
 3. python3 tools/engineb/plugin_check.py --check-port --quick
 4. python3 tools/engineb/merge_shims.py --check   (composite freshness)
Report each command's tail output verbatim and a one-line verdict per gate.
If ANY gate is red, that is the most important finding -- report it first with
the full failing output. Do not fix anything; report.`,
    { label: 'verify:gates', phase: 'Measure' }),

  () => agent(`${CTX}

TASK: THE DECISION MEASUREMENT. What does the sonic gate say about removing the
double-precision arithmetic from the pitch polynomial (engine_b/eb_pitch.c)?

This decides whether ~28,000 Xtensa instructions/sample of soft-double can be
removed. The output of the polynomial is already truncated to float by the port
itself (fmaxf/fminf at the end), so the question is only whether float (or
double-float) INTERMEDIATES stay under the -100 dB null. Pitch errors INTEGRATE
in phase accumulators, so this cannot be reasoned about -- it must be measured
over the full 30-scenario set.

METHOD -- use the existing harness exactly as prior probes did:
 1. Read engine_b/eb_pitch.c (small) and tools/engineb/null_b.py's _plant
    mechanism (search for "def _plant"). Prior probe scripts followed this
    pattern: import null_b; override null_b._plant with a function that edits
    files in the COPIED tree (argument tmp); then
    ref = null_b.oracle_render(False) once, and
    null_b.run(["pitch"], False, mutate="X", ref=ref, label=..., verbose=False)
    per variant. run() returns (fails, worst_dB_or_None, caught_tags).
 2. VARIANT A "float32": in the copied tree rewrite engine_b/eb_pitch.c so all
    arithmetic is float: double->float, fmin/fmax->fminf/fmaxf, 20.0->20.0f etc.
    Keep the SAME term order. It must compile as C99 -- test-compile with
    cc -std=c99 -c before running the harness.
 3. VARIANT B "double-float (Dekker)": only if A fails the gate. Products via
    Dekker/TwoProd using float FMA-free split, sums via TwoSum, ~49-bit
    effective. If you build it, keep it simple and correct.
 4. Report PER SCENARIO the residual dB (the harness prints them), plus the
    worst global and worst block, for each variant. State PASS/FAIL against
    -100 dB global / -80 dB block. All 30 scenarios, not --quick.
 5. Write the numbers to docs/engineb/data/pitch_precision_null.md (create it).
Do not touch src/. Do not commit. The gate is the truth: report what it says,
whichever way it goes.`,
    { label: 'measure:pitch-null', phase: 'Measure' }),

  () => agent(`${CTX}

TASK: build the honest per-function S3 cost table for engine B.

METHOD:
 1. Compile every engine_b/eb_*.c for the S3:
    xtensa-esp32s3-elf-gcc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing
      -DEB_DELAY_LEN=65536 -Iengine_b -Isrc -c
    and count STATIC instructions per function via objdump -d (count lines
    matching '^\\s+[0-9a-f]+:' inside each function).
 2. Compile the same files for the HOST (cc, same flags) and count static
    instructions per function the same way.
 3. HOST EXECUTED instr/sample per function (MEASURED earlier, callgrind, 8
    voices, patch 20, 48 kHz -- reuse these, do not re-run callgrind):
    eb_dco_step4 3012, eb_vcf_substep 2624 (inlined into eb_vcf_tick on some
    builds), eb_vcf_tick 2426, eb_vca_tick 1448, eb_env_tick 1264,
    eb_decim_tick 952, eb_vcf_cv_tick 576, eb_pitch_eval 536,
    eb_reverb_process 511, eb_chorus_tick_x 432, eb_delay_process 354,
    eb_modcv_tick 296, eb_cvgate 264, eb_dco_set_shape 232.
 4. S3 estimate per function = host_executed x (xtensa_static / host_static),
    PLUS penalties from the census in the context above (pitch soft-double at
    8 calls/sample; 32 divides/sample at ~30 instr each). For the pitch
    penalty use the libgcc static counts as the per-call cost band (state the
    assumption: straight-line common path).
 5. Produce a table: function | host exec/sample | xtensa/host ratio | S3
    instr/sample estimate | penalty | total. Sum it. Compare against 5,000
    (one core) and 9,500 (two cores, scheduling overhead allowed for).
 6. State the band honestly: instr != cycles on an in-order LX7 (loads, taken
    branches). Give nominal and a 1.0x..1.5x cycles-per-instr band.
 7. Write the table to docs/engineb/data/s3_cost_table.md (create it).
Label every number. Do not commit.`,
    { label: 'measure:xtensa-table', phase: 'Measure' }),

  () => agent(`${CTX}

TASK: the EXECUTED-PATH cost of the soft-double helpers, not the static size.

The static counts (__muldf3 105, __adddf3 116) include special-case arms
(NaN, inf, denormal, zero) that normal audio data never takes. The honest
per-call cost is the COMMON PATH.

METHOD: disassemble libgcc's _muldf3.o, _addsubdf3.o, _divsf3.o,
_truncdfsf2.o, _extendsfdf2.o, _fixdfsi.o from
$(xtensa-esp32s3-elf-gcc -print-libgcc-file-name) (ar x into a temp dir).
Trace the common path by hand for normal finite inputs: count instructions
from entry to return, following the no-special-case branch at each test.
Note any loops (soft multiply of 53-bit mantissas may loop or use mull -- the
ESP32-S3 HAS a 32x32 integer multiplier, so check whether __muldf3 uses mull
instructions or a shift-add loop; this decides whether the cost is ~60 or
~300).
Report per helper: common-path instruction count, whether it loops, and a
cycle band. Then compute the per-sample pitch penalty: 8 calls x
(23 muldf3 + 13 adddf3 + 2 extend + 1 fixdfsi + 1 truncdfsf2 + 2 double
fmin/fmax from newlib -- disassemble those too from libm.a).
Write results to docs/engineb/data/softfloat_cost.md. Do not commit.`,
    { label: 'measure:libgcc-path', phase: 'Measure' }),

  () => agent(`${CTX}

TASK: QEMU scout. Can this container run ESP32-S3 code and count executed
instructions, so engine B gets a real executed-Xtensa number before the user's
board arrives?

CHECK, in order, timeboxed (do not spend more than ~15 minutes of wall time):
 1. which qemu-system-xtensa; ls /root/.espressif (espressif distributes a
    qemu-xtensa build via their tools installer).
 2. If absent: can it be fetched through the proxy?
    Try: pip download/install nothing -- instead check
    https://github.com/espressif/qemu/releases (curl -sIL the latest
    xtensa release asset URL) and https://dl.espressif.com availability.
    Network goes through a preconfigured HTTPS proxy; curl normally works.
 3. If a tarball is obtainable (<200 MB), download to
    /tmp/claude-0/.../scratchpad (the session scratchpad, NOT the repo),
    extract, and run qemu-system-xtensa --machine help to confirm esp32s3.
 4. If it runs: describe (do not build yet) the minimal bare-metal harness:
    an ELF for esp32s3 that runs one engine B module N times and reads the
    CCOUNT special register before/after, printing via the UART or
    semihosting. Note that QEMU's CCOUNT is instruction-approximate, not
    cycle-accurate, and say so.
Report what is possible, what you verified by running it, and the exact
commands. If nothing is obtainable, say so plainly -- a clear NO is a good
answer. Do not commit.`,
    { label: 'scout:qemu', phase: 'Measure' }),
])

phase('Verdict')

const verdict = await agent(`${CTX}

RESULTS FROM THE MEASUREMENT AGENTS:
${JSON.stringify(results.filter(Boolean), null, 1).slice(0, 45000)}

TASK: write docs/engineb/S3_ASSESSMENT.md -- the corrected feasibility
assessment -- and be ADVERSARIAL about it in both directions.

 1. First try to REFUTE "the S3 target is unreachable": list every lever the
    prior analysis missed or mispriced (soft-double pitch removal if the null
    permits it; RECIP for the 32 divides, already MEASURED at -121 dB in
    engine_b/eb_dco.h; the second core, which the binding constraints allow
    before any voice is dropped; block processing / call-overhead not yet
    measured on Xtensa).
 2. Then try to REFUTE "the S3 target is reachable": sum the honest S3
    estimate AFTER the fixable penalties are removed, against 5,000 one-core
    and ~9,500 two-core. State the remaining gap as a number with its band.
 3. Check the capacity arithmetic yourself: 240 MHz / 48 kHz = 5,000
    cycles/sample/core. State what fraction the constraints' 'room to spare'
    target (3,500) represents and what spending the reserve core means.
 4. End with a ranked, concrete work plan: each step, its measured or modeled
    saving, its accuracy gate, and the measurement that retires it. The last
    resort (6 voices) appears only at the bottom with its measured ~1/8-per-
    voice saving.
 5. Every number carries its label (PROVEN/MEASURED/STATIC/MODELED). Where the
    agents' numbers disagree, show both and say which to trust and why.
Be blunt. The user was told 'unreachable' on invalid numbers once already;
do not repeat that mistake in either direction. Do not commit.`,
  { label: 'verdict:assessment', phase: 'Verdict' })

return { results: results.filter(Boolean), verdict }