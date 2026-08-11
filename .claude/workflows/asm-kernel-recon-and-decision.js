export const meta = {
  name: 'asm-kernel-recon-and-decision',
  description: 'Settle the c/i question that sizes the ASM ladder kernel, then build its verification tooling',
  phases: [
    { title: 'Recon' },
    { title: 'Decide' },
    { title: 'Build' },
    { title: 'Verify' },
  ],
}

const REPO = '/home/user/jn60c99'
const CC = '/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/xtensa-esp-elf/bin/xtensa-esp32s3-elf-gcc'
const OBJDUMP = '/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/xtensa-esp-elf/bin/xtensa-esp32s3-elf-objdump'

// The SHIPPING fork config, verbatim from the LASTMILE2 firmware minus every
// control-rate flag (the addendum closes that trade).
const SHIP = '-DEB_FORK_S3 -DEB_DCO_WT=1 -DEB_LFO_SHARED=1 -DEB_VCF_DEADCOEF=1 ' +
             '-DEB_VCF_RES_LUT=256 -DEB_ATREST_BLOCK=1 -DEB_ATREST_O1=1 ' +
             '-DEB_ZEROCOEF=1 -DEB_EXP_MEMO=1 -DEB_HALF_OS_VCF=1'

const COMMON = `
REPO: ${REPO}   (read-only unless told otherwise; do NOT commit)
Xtensa GCC:   ${CC}
Xtensa objdump: ${OBJDUMP}
SHIPPING FORK FLAGS (the build on the user's board, minus the now-closed
control-rate levers):
  ${SHIP}
Compile flags used by the firmware: -O2 -flto -ffp-contract=off -fno-strict-aliasing -std=c99
Include dirs: -I${REPO}/engine_b -I${REPO}/src -I${REPO}/esp32s3/main

MEASURED ON THE USER'S ESP32-S3 TONIGHT (240 MHz, 44100 Hz, 6-voice listen
firmware, two cores, S3L_SPLIT=5). These are CYCLES, from the board:
  wake 0x00 (0 voices)  1,130
  wake 0x80 (1 voice)   3,710
  wake 0xc0 (2 voices)  6,716
  wake 0xe0 (3 voices)  9,744
  wake 0xfc (6 voices) 10,051
  wake 0xd0 (1 voice core0 + 2 voices core1) 6,681   <- the two-chip workload
  BUDGET 5,442 cycles/sample wall clock.
Consecutive masks add exactly ONE sounding voice on core 1, so the SLOPE is
the voice cost with no assumption about the floor:
  0xc0-0x80 = 3,006 ; 0xe0-0xc0 = 3,028  ->  voice ~= 3,017 cycles
  prologue/head = 3,710 - 3,017 = ~693 cycles

Report FACTS with file:line evidence. Label every claim MEASURED / READ /
INFERRED. If you cannot establish something, say so plainly -- a confident
wrong answer here costs the user another failed firmware.
`

phase('Recon')

const recon = await parallel([
  () => agent(`${COMMON}

TASK: Inventory EVERY c/i (cycles-per-instruction) claim in this repository,
with its provenance, and determine which ones apply to the CURRENT shipping
fork build.

THE CONTRADICTION TO RESOLVE. ${REPO}/CLAUDE.md records F4 first silicon as
"c/i = 0.95 ... instruction counts ARE cycle counts on this chip (within
5%)". But ${REPO}/docs/engineb/STEP1_ATTRIBUTION.md records "c/i is 1.56"
and "c/i ~1.9 still" for the ladder+VCA. Both cannot describe the same code.

Search docs/engineb/**, docs/engineb/data/**, CLAUDE.md, tools/engineb/**
and any firmware source. For EACH c/i claim record: the number, WHAT PROGRAM
it was measured on (full standard? fork? which modules?), HOW (QEMU
instruction count vs CCOUNT? static objdump?), and the file:line.

Then answer directly: is there any DIRECT measurement of instructions-per-
sample for the CURRENT fork voice loop (wavetable DCO + half-OS ladder +
res LUT) that can be compared against the 3,017 cycles/voice above? If yes,
give the number and where it is. If no, say NO DIRECT MEASUREMENT EXISTS.`,
    { label: 'recon:ci-claims', phase: 'Recon', schema: {
      type: 'object', additionalProperties: false,
      required: ['claims', 'direct_fork_instr_measurement', 'summary'],
      properties: {
        claims: { type: 'array', items: { type: 'object', additionalProperties: false,
          required: ['value', 'program', 'method', 'where'],
          properties: { value: {type:'string'}, program: {type:'string'},
                        method: {type:'string'}, where: {type:'string'} } } },
        direct_fork_instr_measurement: { type: 'string' },
        summary: { type: 'string' } } } }),

  () => agent(`${COMMON}

TASK: Establish, by STATIC ANALYSIS OF REAL XTENSA CODE, how many
instructions one VOICE of the current shipping fork executes per sample.
This is the number that decides whether a hand-scheduled assembly kernel can
help at all: compare it against the MEASURED 3,017 cycles/voice.

METHOD (do it, do not describe it):
1. Compile every ${REPO}/engine_b/eb_*.c to an object with the SHIPPING
   FLAGS above (no -flto, so symbols survive), e.g.
     ${CC} -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing <flags> \\
       -I... -c eb_vcf_ladder.c -o /tmp/k/eb_vcf_ladder.o
   Report any file that fails to compile.
2. Disassemble with ${OBJDUMP} -d and count instructions per FUNCTION.
3. Read ${REPO}/engine_b/eb_render.c's per-voice path (the body of
   eb_engine_render_range's voice loop, for a SOUNDING voice) and build the
   call list: which functions run, how many times per sample per voice.
   NOTE the half-OS ladder runs TWO sub-steps, not four; the DCO is the
   wavetable one (eb_dco_wt); eb_vcf_res is a table lookup.
4. Price loops by their real trip counts (e.g. the 16-tap folded decimator
   in the half-OS path is 8 iterations).
5. Sum to instructions/sample/voice.

${REPO}/tools/engineb/engine_price.py already does static call-graph pricing
for this project -- READ IT FIRST and reuse its method and its traps (it
records five prior pricing errors, all flattering: whole-TU symbol sums,
missing intra-module relocations, libgcc helpers, missing master chain,
missing dispatch arms). Do not repeat them.

Report the total, the per-function breakdown, and the implied c/i =
3017 / (your instructions). State plainly whether the voice loop has a
STALL POOL (c/i well above 1.0) or is INSTRUCTION-BOUND (c/i near 1.0).`,
    { label: 'recon:instr-count', phase: 'Recon', schema: {
      type: 'object', additionalProperties: false,
      required: ['instr_per_voice', 'breakdown', 'implied_ci', 'verdict', 'caveats'],
      properties: {
        instr_per_voice: { type: 'number' },
        breakdown: { type: 'array', items: { type: 'object', additionalProperties: false,
          required: ['fn','instr','calls_per_sample','total'],
          properties: { fn:{type:'string'}, instr:{type:'number'},
                        calls_per_sample:{type:'number'}, total:{type:'number'} } } },
        implied_ci: { type: 'number' },
        verdict: { type: 'string', enum: ['STALL_POOL', 'INSTRUCTION_BOUND', 'INCONCLUSIVE'] },
        caveats: { type: 'string' } } } }),

  () => agent(`${COMMON}

TASK: Report exactly what was already tried to fill the ladder's stalls, and
under WHICH configuration -- because one of them may never have been measured
under the CURRENT half-oversampled ladder.

Read ${REPO}/engine_b/eb_vcf_ladder.c (especially the EB_VCF_ILV section and
eb_vcf_tick2), ${REPO}/engine_b/eb_render.c (EB_FUSE_VCA, EB_VCF_ILV use),
${REPO}/docs/engineb/STEP1_ATTRIBUTION.md, and docs/engineb/data/*.md.

For EACH attempt (EB_VCF_ILV two-voice interleave, EB_FUSE_VCA, forced
inlining, prologue pipelining, any other): what it did, what it MEASURED on
silicon or on the host, and CRUCIALLY under which ladder configuration
(4x full oversampling vs EB_HALF_OS_VCF).

THE SPECIFIC QUESTION I NEED ANSWERED, with evidence: eb_vcf_ladder.c
contains an #error that REFUSES to combine EB_VCF_ILV with EB_HALF_OS_VCF.
Was the two-voice interleave EVER measured with the half-OS ladder (2
sub-steps, far smaller live set) rather than the 4x ladder (4 sub-steps)?
Quote the #error and any measurement. If it was never measured under
half-OS, say so explicitly -- that would make it a cheap untested lever.`,
    { label: 'recon:prior-negatives', phase: 'Recon', schema: {
      type: 'object', additionalProperties: false,
      required: ['attempts', 'ilv_under_halfos_ever_measured', 'summary'],
      properties: {
        attempts: { type: 'array', items: { type: 'object', additionalProperties: false,
          required: ['name','what','measured','ladder_config','where'],
          properties: { name:{type:'string'}, what:{type:'string'},
                        measured:{type:'string'}, ladder_config:{type:'string'},
                        where:{type:'string'} } } },
        ilv_under_halfos_ever_measured: { type: 'boolean' },
        summary: { type: 'string' } } } }),

  () => agent(`${COMMON}

TASK: Map the two verification surfaces the kernel will need, concretely
enough that another agent can write code against them without re-reading
everything.

(a) THE QEMU HARNESS: ${REPO}/tools/engineb/qemu/ (build.sh, run.sh,
    harness.c, crt0.S, link.ld, run.log). Report: what it builds, how it is
    invoked, what it measures (instruction count? CCOUNT?), whether the QEMU
    binary is still present on this machine (find it), and whether it can be
    made to run eb_vcf_tick + eb_vca_tick over a vector list and report
    per-function instruction counts. Give the EXACT commands. Note the
    recorded warning that its per-function CCOUNT figures quantise at 25 and
    are untrustworthy for short spans.

(b) THE ON-BOARD SELF-TEST: ${REPO}/esp32s3/main/juno_s3_listen.c contains a
    boot-time "FORK EVALUATOR VECTORS: BIT-EXACT" style self-test. Find it,
    quote its shape (file:line), and describe exactly where and how a new
    vector test comparing a C tick against an asm kernel would hook in --
    including how it prints and how it halts.

Also report: does anything in the repo already compare FULL STATE STRUCTS
bytewise between two implementations? (The work order's S2a demands that.)
If yes, name it so it can be reused rather than reinvented.`,
    { label: 'recon:verification-surfaces', phase: 'Recon', schema: {
      type: 'object', additionalProperties: false,
      required: ['qemu', 'selftest', 'state_compare_precedent'],
      properties: {
        qemu: { type: 'object', additionalProperties: false,
          required: ['what_it_builds','how_invoked','what_it_measures','binary_present','commands','caveats'],
          properties: { what_it_builds:{type:'string'}, how_invoked:{type:'string'},
            what_it_measures:{type:'string'}, binary_present:{type:'string'},
            commands:{type:'string'}, caveats:{type:'string'} } },
        selftest: { type: 'object', additionalProperties: false,
          required: ['where','shape','hook_point'],
          properties: { where:{type:'string'}, shape:{type:'string'}, hook_point:{type:'string'} } },
        state_compare_precedent: { type: 'string' } } } }),

  () => agent(`${COMMON}

TASK: Produce the exact live-value inventory of the CURRENT half-oversampled
ladder plus the VCA, so a hand-scheduler knows whether the 16 FP registers
can hold two independent chains.

Read ${REPO}/engine_b/eb_vcf_ladder.c (the EB_HALF_OS_VCF branch of
eb_vcf_tick, and eb_vcf_substep) and ${REPO}/engine_b/eb_vca_hpf.c
(eb_vca_control / eb_vca_audio / eb_vca_tick).

Report:
1. For ONE half-OS ladder tick: every floating-point value that is LIVE
   across the two sub-steps, and every value live only within a sub-step.
   Count them.
2. The serial FP dependency chain through one sub-step: list the ops in
   order and mark which are dependent on the immediately preceding result
   (those are the ones that stall on an in-order FPU).
3. The same for eb_vca_control and eb_vca_audio, and state which of their
   values are INDEPENDENT of the ladder's chain (candidate filler work).
4. Any INTEGER work in or adjacent to the ladder (wrap24, dither, ring index
   arithmetic) -- integer ops can fill FP stall slots at zero FP-register
   cost, which is the work order's filler category (b).

Then judge: with only 2 sub-steps (not 4), how many FP registers does ONE
voice's ladder need live at once, and could TWO voices' ladders be
interleaved within 16 FP registers? Give a number, not an impression.`,
    { label: 'recon:live-set', phase: 'Recon', schema: {
      type: 'object', additionalProperties: false,
      required: ['ladder_live_across_substeps','ladder_live_within_substep','dependency_chain',
                 'vca_independent_values','integer_filler','two_voice_register_verdict'],
      properties: {
        ladder_live_across_substeps: { type: 'number' },
        ladder_live_within_substep: { type: 'number' },
        dependency_chain: { type: 'string' },
        vca_independent_values: { type: 'string' },
        integer_filler: { type: 'string' },
        two_voice_register_verdict: { type: 'string' } } } }),
])

const [ci, instr, prior, surf, live] = recon

log('recon complete: implied c/i = ' + (instr ? instr.implied_ci : 'n/a') +
    ', verdict ' + (instr ? instr.verdict : 'n/a'))

phase('Decide')

// THE DECISION GATE. A single static count can be wrong in the flattering
// direction -- engine_price.py records five such errors -- so the number is
// independently RE-DERIVED by a second agent that is told the first answer
// and asked to refute it. A stall pool that only one method can see is not
// a stall pool.
const audit = await agent(`${COMMON}

An earlier agent priced ONE VOICE of the shipping fork at
${instr ? instr.instr_per_voice : 'UNKNOWN'} Xtensa instructions per sample,
implying c/i = ${instr ? instr.implied_ci : 'UNKNOWN'} against the measured
3,017 cycles/voice, and concluded: ${instr ? instr.verdict : 'UNKNOWN'}.

Its breakdown:
${instr ? JSON.stringify(instr.breakdown, null, 1) : '(none)'}
Its caveats: ${instr ? instr.caveats : '(none)'}

YOUR JOB IS TO REFUTE IT. This project has been misled FIVE times by pricing
errors and every one flattered its subject. Re-derive the number INDEPENDENTLY
(compile and disassemble yourself; do not trust the table above), then attack
it specifically:
 - Are any functions MISSING from the call list? Walk eb_render.c's sounding-
   voice path line by line against the table.
 - Are loop trip counts right? (half-OS decimator iterations, DCO wavetable
   inner loops, any residual-ring loop.)
 - Are libgcc/libm helper bodies charged? (__divsf3, expf, fmodf -- the repo
   records charging these at ZERO as its fourth pricing error.)
 - Does the count include the at-rest advance, the shared prologue, or other
   work that is NOT per-sounding-voice? It must not: 3,017 is a SLOPE between
   consecutive wake masks, i.e. purely one extra sounding voice.
 - Are branchy functions counted on BOTH arms (over-charge) or on the taken
   arm (correct)? The repo records the DCO worst-case over-charge at 51%.

Give YOUR number, YOUR c/i, and a verdict. If the two derivations disagree by
more than 15%, say which is right and why. Default to STALL_POOL only if the
evidence forces it; the expensive mistake here is telling the user there are
stalls to reclaim when there are none.`,
  { label: 'decide:refute-pricing', phase: 'Decide', effort: 'high', schema: {
    type: 'object', additionalProperties: false,
    required: ['instr_per_voice','implied_ci','verdict','disagreements','confidence'],
    properties: {
      instr_per_voice: { type: 'number' },
      implied_ci: { type: 'number' },
      verdict: { type: 'string', enum: ['STALL_POOL','INSTRUCTION_BOUND','INCONCLUSIVE'] },
      disagreements: { type: 'string' },
      confidence: { type: 'string' } } } })

const stalls = audit && audit.verdict === 'STALL_POOL' &&
               instr && instr.verdict === 'STALL_POOL'
const contested = audit && instr && audit.verdict !== instr.verdict

log('DECISION: independent c/i = ' + (audit ? audit.implied_ci : 'n/a') +
    ' -> ' + (audit ? audit.verdict : 'n/a') +
    (contested ? '  (CONTESTED: the two derivations disagree)' : ''))

phase('Build')

// Two things are worth building REGARDLESS of the verdict, because both are
// cheap and both are needed by whichever path wins:
//   - asm_diff.py, the operation-multiset checker the work order demands
//     first (it also documents what it CANNOT prove).
//   - the ILV-under-half-OS question: if the two-voice interleave was never
//     measured with the 2-sub-step ladder, that is a compiler-level test of
//     the SAME hypothesis the kernel rests on, costing one build instead of
//     days of assembly.
const build = await parallel([
  () => agent(`${COMMON}

TASK: WRITE ${REPO}/tools/engineb/asm_diff.py -- step A1 of
${REPO}/docs/engineb/ASM_KERNEL_WORKORDER.md. Create the file; do not commit.

WHAT IT MUST DO. Given (1) a compiler-generated reference assembly file
produced by ${CC} -S -O2 -ffp-contract=off with the SHIPPING FLAGS, and (2) a
hand-scheduled .S file, decide whether the hand file performs the SAME
OPERATIONS -- same opcode multiset, same immediates, same memory offsets --
regardless of ORDER. It must FAIL on:
  * any madd.s / msub.s / any fused multiply-add (the reference rounds
    twice; a fused op rounds once and is NOT bit-exact) -- this check is
    absolute and applies even if the multiset somehow matched;
  * a retyped constant (an immediate or a .literal value present in one file
    and not the other);
  * a dropped or added arithmetic operation;
  * a changed load/store offset.
It must IGNORE: instruction order, register NAMES (allocation may differ),
label names, and pure scheduling no-ops.

WRITE INTO THE FILE ITSELF, as a comment, exactly what it CANNOT prove:
it cannot prove that the ORDER within a floating-point dependency chain is
preserved, and order changes within a chain change rounding. Only the
on-silicon vector test (S2a) can prove that. Saying otherwise would be the
over-claim this project keeps a catalogue of.

PROVE IT WORKS BEFORE YOU FINISH. Generate a real reference: compile
${REPO}/engine_b/eb_vcf_ladder.c with -S and the shipping flags. Then run
asm_diff.py against (a) itself -- must PASS -- and against FOUR mutated
copies you create in /tmp: one with an add.s deleted, one with a mul.s
turned into madd.s, one with an immediate changed, one with a load offset
changed. ALL FOUR MUST FAIL, and each must name what it found. Report the
actual output of all five runs. A checker never seen to fail is not a
checker.`,
    { label: 'build:asm-diff', phase: 'Build', effort: 'high', schema: {
      type: 'object', additionalProperties: false,
      required: ['file_written','self_pass','mutations','output_excerpt','limits_documented'],
      properties: {
        file_written: { type: 'string' },
        self_pass: { type: 'boolean' },
        mutations: { type: 'array', items: { type: 'object', additionalProperties: false,
          required: ['mutation','caught','message'],
          properties: { mutation:{type:'string'}, caught:{type:'boolean'}, message:{type:'string'} } } },
        output_excerpt: { type: 'string' },
        limits_documented: { type: 'boolean' } } } }),

  () => agent(`${COMMON}

TASK: Determine whether the EXISTING two-voice interleaved ladder
(EB_VCF_ILV / eb_vcf_tick2 in ${REPO}/engine_b/eb_vcf_ladder.c) can be made
to work with the HALF-OVERSAMPLED ladder, and if so PREPARE it -- because it
tests the SAME hypothesis the hand-written kernel rests on (that the LX7's
in-order FPU stalls can be filled with a second voice's independent work) at
the cost of one build instead of days of assembly.

FACTS: eb_vcf_ladder.c has an #error that refuses EB_VCF_ILV together with
EB_HALF_OS_VCF, EB_VCF_ADAA and EB_VCF_NOSAT. The interleave was rejected
earlier under the 4x ladder (4 sub-steps, large live set -- the "16-register
wall"). The half-OS ladder has only TWO sub-steps, so the live set is much
smaller and the wall may not be there.

DO THIS:
1. Read eb_vcf_tick2 and the half-OS branch of eb_vcf_tick carefully.
2. Write a half-OS version of eb_vcf_tick2 -- two voices, two sub-steps
   each, statements interleaved -- behind the SAME EB_VCF_ILV flag, and
   narrow the #error so half-OS is permitted while ADAA/NOSAT still are not.
   IT MUST BE ARITHMETICALLY IDENTICAL PER VOICE: same operations, same
   order within each voice's own dependency chain. Interleaving may only
   change the ORDER OF INDEPENDENT chains. Do not "simplify" anything.
3. Build it for the HOST (gcc, ${SHIP} plus -DEB_VCF_ILV=1) and prove
   bit-exactness against the non-interleaved half-OS ladder: write a small
   standalone C driver in /tmp that runs BOTH through >= 200,000 random
   (input, G, k) vectors over the MEASURED domain G in [0.000119, 0.20977],
   k in [0, 3.981], with EVOLVING state, and compares the returned floats
   BITWISE (memcmp of the bit patterns, not ==) and the full eb_vcf_state
   structs bytewise. Report the exact mismatch count. It must be ZERO.
4. Also compile both for Xtensa with ${CC} and report the instruction count
   of eb_vcf_tick vs eb_vcf_tick2 per voice (objdump), plus the number of
   STACK STORES (s32i/ssi to sp) inside each -- the work order's rule is
   that a draft which spills inside the sub-step loop has already lost.

Report honestly if the interleave cannot be made bit-exact, or if it spills.`,
    { label: 'build:ilv-halfos', phase: 'Build', effort: 'high', schema: {
      type: 'object', additionalProperties: false,
      required: ['feasible','bitexact_vectors','mismatches','instr_tick','instr_tick2_per_voice',
                 'stack_stores_tick','stack_stores_tick2','files_changed','verdict'],
      properties: {
        feasible: { type: 'boolean' },
        bitexact_vectors: { type: 'number' },
        mismatches: { type: 'number' },
        instr_tick: { type: 'number' },
        instr_tick2_per_voice: { type: 'number' },
        stack_stores_tick: { type: 'number' },
        stack_stores_tick2: { type: 'number' },
        files_changed: { type: 'string' },
        verdict: { type: 'string' } } } }),
])

const [asmdiff, ilv] = build

phase('Verify')

// A second pair of eyes on the ILV bit-exactness claim, because "bit-exact"
// is the one property the whole fork's sound rests on and the harness that
// proves it was written by the same agent that wants it to pass.
let ilvAudit = null
if (ilv && ilv.feasible && ilv.mismatches === 0) {
  ilvAudit = await agent(`${COMMON}

An agent modified ${REPO}/engine_b/eb_vcf_ladder.c to allow the two-voice
interleaved ladder (EB_VCF_ILV) under EB_HALF_OS_VCF, and reports
${ilv.bitexact_vectors} vectors with ZERO bitwise mismatches against the
non-interleaved half-OS ladder.

REFUTE THAT CLAIM. Specifically:
1. Read the diff (git diff in the repo). Does the interleaved version really
   perform each voice's operations in the SAME ORDER within that voice's own
   dependency chain? Any reassociation, any hoisted common subexpression
   SHARED between the two voices, any changed rounding point is a FAIL --
   quote the lines.
2. Re-run the vector harness YOURSELF (rebuild it; do not trust the prior
   run) and independently confirm the mismatch count. Use different random
   seeds and include EDGE CASES the prior run may have missed: G at both
   measured extremes, k = 0 and k = 3.981, denormal and zero inputs, and a
   long run from a COLD state so the recursive state has to converge.
3. PLANT A DEFECT: transpose one pair of operations INSIDE one voice's
   dependency chain in the interleaved version, rebuild, and confirm the
   harness CATCHES it. Report the mismatch count for the planted build. If
   the harness does not catch a planted in-chain transposition, the harness
   is not measuring what it claims and the zero above means nothing.
   RESTORE the file afterwards (git checkout the planted change only).

Report CONFIRMED or REFUTED with evidence.`,
    { label: 'verify:ilv-bitexact', phase: 'Verify', effort: 'high', schema: {
      type: 'object', additionalProperties: false,
      required: ['verdict','independent_mismatches','planted_defect_caught','evidence'],
      properties: {
        verdict: { type: 'string', enum: ['CONFIRMED','REFUTED','INCONCLUSIVE'] },
        independent_mismatches: { type: 'number' },
        planted_defect_caught: { type: 'boolean' },
        evidence: { type: 'string' } } } })
}

return {
  ci_claims: ci,
  static_pricing: instr,
  pricing_audit: audit,
  stall_pool_confirmed: stalls,
  pricing_contested: contested,
  prior_negatives: prior,
  verification_surfaces: surf,
  live_set: live,
  asm_diff: asmdiff,
  ilv_halfos: ilv,
  ilv_audit: ilvAudit,
}
