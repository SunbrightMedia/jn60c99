export const meta = {
  name: 'cycle-attribution-design',
  description: 'Design per-module CCOUNT cycle attribution for the JUNO engine on ESP32-S3, and adversarially find its failure modes',
  phases: [
    { title: 'Design', detail: 'independent designs for probe macros, insertion points, two-core handling, reporting' },
    { title: 'Critique', detail: 'adversarial review of each design for measurement errors' },
  ],
}

const REPO = '/home/user/jn60c99'

const CONTEXT = `PROJECT: a bit-exact JUNO-60 C99 port running on ESP32-S3 (Xtensa LX7, dual core, 240 MHz).
GOAL: 6 voices + full FX in real time. Budget 5,442 cycles/sample wall clock. Currently 14,441 (2.65x over).

TASK CONTEXT: every remaining lever is inside per-voice module ARITHMETIC (~4,200 cyc/critical-path voice vs ~1,400 affordable). The plan is to redesign module STRUCTURE for equivalent RESPONSE under a 1.0 dB third-octave sonic gate -- the method that already took the DCO from 2,864 to 1,090 cycles at 0.40 dB. To know WHICH module to redesign first we need per-module CYCLE attribution ON SILICON. Host instruction counts have misled this project three times (they killed voice interleaving on the wrong metric, hid 903 KB of flash-resident wavetables, and mispredicted a cache fix that measured zero).

KEY FILES:
  ${REPO}/engine_b/eb_render.c        -- eb_engine_render_range(), the per-voice loop, and eb_engine_render_shared() (the prologue)
  ${REPO}/esp32s3/main/juno_s3_listen.c -- firmware: render_block(), the core-1 worker task, the sweep, the per-second print
  ${REPO}/docs/engineb/PLAN_REALTIME.md and ${REPO}/docs/engineb/DOUBT_OPUS.md -- the plan and the measured record

CRITICAL FACTS:
- The engine renders voices [0,5) on core 0 and [5,8) on core 1 via eb_engine_render_range(). CCOUNT is a PER-CORE register on Xtensa -- core 0 and core 1 each have their own.
- render_block() runs 128 samples: core 0 does the prologue + its range per sample; core 1 does its range, gated by a rolling w_ready index.
- The firmware prints once per second and sweeps voice counts via a WAKE mask (0x00,0x80,0xc0,0xe0,0xf0,0xfc).
- The build must remain EXACTLY 0 (bit-identical audio) with profiling OFF, and profiling must be a compile-time flag.`

const SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['approach', 'probe_macro_design', 'instrumentation_points', 'two_core_handling', 'overhead_calibration', 'reporting_design', 'pitfalls'],
  properties: {
    approach: { type: 'string', description: 'the overall measurement strategy and why it is sound' },
    probe_macro_design: { type: 'string', description: 'exact C for the probe macros, including the OFF case being a true no-op' },
    instrumentation_points: {
      type: 'array',
      description: 'every place to instrument, in order',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['id', 'file_line', 'what_it_wraps', 'note'],
        properties: {
          id: { type: 'string' },
          file_line: { type: 'string' },
          what_it_wraps: { type: 'string' },
          note: { type: 'string' },
        },
      },
    },
    two_core_handling: { type: 'string', description: 'how per-core CCOUNT is kept separate and correctly attributed' },
    overhead_calibration: { type: 'string', description: 'how probe overhead is measured and subtracted' },
    reporting_design: { type: 'string', description: 'how totals are normalized (per sample, per voice) and printed' },
    pitfalls: { type: 'array', items: { type: 'string' }, description: 'specific ways this measurement could LIE, and the guard for each' },
  },
}

phase('Design')
const ANGLES = [
  { key: 'ccount-inline', prompt: 'Design DIRECT CCOUNT instrumentation: read the cycle counter around each module call and accumulate into per-module counters. Focus on making the probe as cheap as possible and on correctly handling the two cores.' },
  { key: 'ablation', prompt: 'Design an ABLATION-based attribution instead: build variants with one module bypassed/short-circuited at a time and take deltas of the existing wake=0xfc number. Focus on which modules can be safely bypassed for a COST measurement (correctness of audio does not matter, only that the remaining work is unchanged), and on what makes a delta trustworthy.' },
  { key: 'robustness', prompt: 'Design whichever approach you judge most ROBUST, with the explicit priority being that the measurement must not lie. This project has been misled three times by measurements that flattered their subject. Prioritize guards, cross-checks and self-tests over precision.' },
]

const designs = await parallel(ANGLES.map(a => () =>
  agent(`${CONTEXT}

YOUR ANGLE: ${a.prompt}

Read the key files listed above before designing. Produce a concrete, implementable design: exact macro C code, exact instrumentation points with file:line and what each wraps, two-core handling, overhead calibration, reporting, and a rigorous list of ways the measurement could LIE with a guard for each. Be specific to THIS code, not generic.`,
    { label: `design:${a.key}`, phase: 'Design', schema: SCHEMA, effort: 'high' })
))

const VSCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['verdict', 'fatal_flaws', 'fixable_flaws', 'best_elements'],
  properties: {
    verdict: { type: 'string', description: 'SOUND | SOUND-WITH-FIXES | UNSOUND' },
    fatal_flaws: { type: 'array', items: { type: 'string' } },
    fixable_flaws: { type: 'array', items: { type: 'string' } },
    best_elements: { type: 'array', items: { type: 'string' }, description: 'elements worth keeping in a final synthesis' },
  },
}

phase('Critique')
const critiques = await parallel(designs.filter(Boolean).map((d, i) => () =>
  agent(`${CONTEXT}

Adversarially review this proposed cycle-attribution design. Your job is to find how it would produce a WRONG number that looks plausible. This project's record: three measurements have already misled it. Default to skepticism.

DESIGN:
approach: ${d.approach}
probe macros: ${d.probe_macro_design}
two-core: ${d.two_core_handling}
calibration: ${d.overhead_calibration}
reporting: ${d.reporting_design}
points: ${(d.instrumentation_points||[]).map(p => p.id + ' @ ' + p.file_line).join('; ')}
self-reported pitfalls: ${(d.pitfalls||[]).join(' | ')}

Check specifically: Is CCOUNT read correctly on Xtensa and is it per-core? Does the probe perturb what it measures (cache, pipeline, register pressure)? Does instrumenting a call inside a hot loop change inlining or scheduling enough to invalidate the result? Are the at-rest branch, the v==0 shared-LFO special case, and the prologue attributed correctly? Can counters overflow or wrap? Does the sum of parts actually reconcile with the measured whole (14,441 at 6 voices) -- and is that reconciliation CHECKED? Read the actual files if needed.`,
    { label: `critique:${i}`, phase: 'Critique', schema: VSCHEMA, effort: 'high' })
    .then(v => ({ design_index: i, ...v }))
))

return {
  designs: designs.filter(Boolean).map((d, i) => ({ index: i, approach: d.approach, probe: d.probe_macro_design, points: d.instrumentation_points, two_core: d.two_core_handling, calib: d.overhead_calibration, report: d.reporting_design, pitfalls: d.pitfalls })),
  critiques: critiques.filter(Boolean),
}
