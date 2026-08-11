export const meta = {
  name: 'exactly0-audit',
  description: 'Audit every engine_b DSP module for EXACTLY-0 (no sonic cost) optimizations on an in-order Xtensa LX7',
  phases: [
    { title: 'Audit', detail: 'one agent per module group finds EXACTLY-0 optimization candidates' },
    { title: 'Verify', detail: 'adversarially check each candidate is truly zero-cost / bit-exact' },
  ],
}

const REPO = '/home/user/jn60c99'

const GROUPS = [
  { key: 'vcf_ladder', files: 'engine_b/eb_vcf_ladder.c engine_b/eb_vcf_ladder.h' },
  { key: 'vcf_res',    files: 'engine_b/eb_vcf_res.c engine_b/eb_vcf_res.h' },
  { key: 'vcf_cv',     files: 'engine_b/eb_vcf_cv.c engine_b/eb_vcf_cv.h' },
  { key: 'vca_hpf',    files: 'engine_b/eb_vca_hpf.c engine_b/eb_vca_hpf.h' },
  { key: 'dco_wt',     files: 'engine_b/eb_dco_wt.c engine_b/eb_dco_wt.h' },
  { key: 'envgen',     files: 'engine_b/eb_envgen.c engine_b/eb_envgen.h' },
  { key: 'pitch',      files: 'engine_b/eb_pitch.c engine_b/eb_pitch_fork.c engine_b/eb_pitch.h' },
  { key: 'glide',      files: 'engine_b/eb_glide.c engine_b/eb_glide.h' },
  { key: 'dcoprep_modcv', files: 'engine_b/eb_dcoprep.c engine_b/eb_modcv.c engine_b/eb_cvgate.c' },
  { key: 'decim_nsvf', files: 'engine_b/eb_decim.c engine_b/eb_noise_svf.c engine_b/eb_noisemix.c' },
  { key: 'render',     files: 'engine_b/eb_render.c' },
  { key: 'fx',         files: 'engine_b/eb_chorus.c engine_b/eb_delay.c engine_b/eb_reverb.c engine_b/eb_master.c' },
]

const SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['module', 'candidates'],
  properties: {
    module: { type: 'string' },
    candidates: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['kind', 'location', 'claim', 'why_exactly_zero', 'est_cycles_saved', 'how_to_verify', 'confidence'],
        properties: {
          kind: { type: 'string', description: 'zero-coefficient | dead-store | redundant-recompute | strength-reduction | interleave-structure | hoist-invariant | other' },
          location: { type: 'string', description: 'file:line and the exact expression/statement' },
          claim: { type: 'string', description: 'the specific optimization' },
          why_exactly_zero: { type: 'string', description: 'why this changes NO output sample, or is bit-exact' },
          est_cycles_saved: { type: 'string', description: 'rough per-voice or per-sample cycles on an in-order LX7' },
          how_to_verify: { type: 'string', description: 'the concrete check: which coefficient to test across 128 patch sets, or which gate' },
          confidence: { type: 'string', description: 'high | medium | low' },
        },
      },
    },
  },
}

const AUDIT_PROMPT = (g) => `You are auditing a DSP module of a bit-exact JUNO-60 synthesizer C99 port for optimizations that change NO audible output — the standard is EXACTLY 0 difference (or provably bit-exact). Target hardware: ESP32-S3, Xtensa LX7, IN-ORDER single-issue FPU where a dependent float chain STALLS (measured cycles-per-instruction 1.56, ~36% of cycles are stalls). Read these files:

${g.files.split(' ').map(f => REPO + '/' + f).join('\n')}

Also read ${REPO}/engine_b/eb_types.h for the coef/state struct layouts, and ${REPO}/docs/engineb/CAMPAIGN_8H.md for context.

Find EVERY candidate optimization that is provably ZERO-COST to the sound:
1. ZERO-COEFFICIENT: a coefficient field multiplied in that is 0.0 in all 64 factory patches (like c9072/c9088/c9536 already found in eb_vcf_ladder — do NOT re-report those). Name the exact field so it can be tested across all 128 (note,gate,voice) coefficient sets.
2. DEAD-STORE: a state write never read back, or (void)-discarded work.
3. REDUNDANT-RECOMPUTE: a value computed every sample that is invariant within a note (coefficients are frozen per note in the S3 blob) OR recomputed identically in a sibling call.
4. STRENGTH-REDUCTION: divisions replaceable by a reciprocal multiply that is bit-exact, repeated subexpressions.
5. INTERLEAVE-STRUCTURE: map the module tick's dependency chain. Is it a long serial chain of dependent float ops (the thing that stalls the in-order FPU)? Could two independent voices' calls be woven statement-by-statement (like eb_vcf_tick2 already does for the ladder) to fill stalls? Report the chain depth and whether the state updates are cleanly per-voice.

For each candidate give: kind, exact location (file:line + expression), the claim, WHY it changes no output sample, rough cycles saved, and the concrete verification. Be rigorous: this project has a catalogue of "optimizations" that turned out to change the sound. If you are not sure a change is exactly zero, mark confidence low and say what would disprove it. Do NOT propose anything that trades accuracy for speed — that is a separate forbidden category. Report only zero-cost candidates.`

phase('Audit')
const audits = await parallel(GROUPS.map(g => () =>
  agent(AUDIT_PROMPT(g), { label: `audit:${g.key}`, phase: 'Audit', schema: SCHEMA, effort: 'high' })
))

const allCands = []
for (const a of audits.filter(Boolean)) {
  for (const c of (a.candidates || [])) allCands.push({ ...c, module: a.module })
}
log(`Audit found ${allCands.length} raw candidates across ${audits.filter(Boolean).length} modules`)

const toVerify = allCands.filter(c => c.kind !== 'interleave-structure')

const VSCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['verdict', 'reasoning', 'refined_claim'],
  properties: {
    verdict: { type: 'string', description: 'CONFIRMED-ZERO-COST | REJECTED | NEEDS-MEASUREMENT' },
    reasoning: { type: 'string' },
    refined_claim: { type: 'string', description: 'the precise, corrected statement of the optimization and its verification' },
  },
}

phase('Verify')
const verified = await parallel(toVerify.map(c => () =>
  agent(`Adversarially verify this claimed ZERO-COST optimization of a JUNO-60 C99 port. Default to REJECTED if there is any way it changes an output sample. Read the relevant file under ${REPO}/engine_b/ and check the actual code.

CANDIDATE:
kind: ${c.kind}
module: ${c.module}
location: ${c.location}
claim: ${c.claim}
why claimed zero: ${c.why_exactly_zero}
verification proposed: ${c.how_to_verify}

Check: does the "dead" store really have no reader anywhere in engine_b? Is the "zero" coefficient possibly nonzero in some factory patch (reason about whether the code path or comments imply it is ever set)? Does the strength reduction actually stay bit-exact under -ffp-contract=off (no reassociation of float adds is allowed — a+b+c reordered is NOT bit-exact)? Is the "invariant" truly constant within a note, or does it depend on a per-sample input? Return CONFIRMED-ZERO-COST only if you are confident, else REJECTED or NEEDS-MEASUREMENT, with a refined precise claim.`,
    { label: `verify:${c.module}:${c.kind}`, phase: 'Verify', schema: VSCHEMA, effort: 'high' })
    .then(v => ({ ...c, ...v }))
))

const confirmed = verified.filter(Boolean).filter(v => v.verdict === 'CONFIRMED-ZERO-COST')
const measure = verified.filter(Boolean).filter(v => v.verdict === 'NEEDS-MEASUREMENT')
const interleave = allCands.filter(c => c.kind === 'interleave-structure')

return {
  summary: {
    raw: allCands.length,
    confirmed: confirmed.length,
    needs_measurement: measure.length,
    interleave_findings: interleave.length,
  },
  confirmed,
  needs_measurement: measure,
  interleave,
}
