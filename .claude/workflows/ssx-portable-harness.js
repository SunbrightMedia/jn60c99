export const meta = {
  name: 'ssx-portable-harness',
  description: 'Generalize the Track B harness into a reusable, config-driven framework for future synth ports',
  phases: [
    { title: 'Survey', detail: 'what is JUNO-specific in each gate and doc' },
    { title: 'Design', detail: 'the portable contract, judged by a panel' },
    { title: 'Build', detail: 'implement the config-driven gates + porting guide' },
  ],
}

const CTX = `PROJECT: /home/user/jn60c99 — a bit-exact C99 port of the Roland JUNO-60 (JU-06A)
VST3 DSP, proven against the plugin binary executed under Unicorn.

WHY THIS WORK EXISTS. The user has just confirmed on real hardware (Daisy Seed,
Cortex-M7 @400MHz) that the bit-exact engine costs 93,288 cyc/sample for 8 voices
against a budget of 8,333 - 11.19x over. So "Track B" begins: a variant engine
that keeps SONIC IDENTITY while giving up bit-exactness, validated by gates
rather than by ear. The user's instruction, verbatim:

  "please make whatever you do reproducable for other project-ssx synthesizers
   that we may port later. make sure it is SONICALLY ACCURATE, and runs on the
   daisy."

So the deliverable is not JUNO-specific. It is a REUSABLE FRAMEWORK that any
future synth port can adopt: given (a) a sealed reference engine and (b) a
candidate engine, prove sonic identity and measure the cost.

WHAT EXISTS TODAY (read all of it before proposing anything):
  tools/trackb/README.md      - the four gates, and why each exists
  tools/trackb/null_ab.py     - gate 1, identity: RMS + worst-1024-block null
  tools/trackb/coverage_probe.py - gate 2, gcov: was the code reached
  tools/trackb/observability.py  - gate 3, cell perturbation / carriage
  tools/trackb/canary.py      - gate 4, module admissibility (plant 0.1% error)
  tools/trackb/fork_check.py, perturb_rt.c
  docs/TRACKB_CHARTER.md      - the gates and the rules they enforce
  docs/trackb/PLAN.md         - 685-line execution plan
  docs/trackb/NEXT.md         - resume note, and the measured module order
  docs/trackb/CARRIAGE.tsv, EQUIVALENCE.tsv - the ledgers
  native/voice_render.c       - currently a VERBATIM fork of src/voice_render.c

HARD PROJECT RULES that constrain any design (from CLAUDE.md):
  - Never validate by ear. Never ask the user to A/B. That is a "capture" and is
    forbidden. Gates decide, not listening.
  - Label every claim PROVEN(executed) / MEASURED / MODELED / READ / INFERRED.
  - src/ stays frozen and bit-exact. Track B lives in native/. The two claims
    must never be conflated.
  - Simplest thing that holds. Reuse existing gates before adding machinery.

IMPORTANT: the harness found FIVE defects in ITSELF by being run (see
docs/trackb/NEXT.md). A generalized framework must carry those lessons forward as
built-in self-tests, not as prose.`

phase('Survey')

const SURVEY = {
  type:'object',
  required:['file','juno_specific','portable_core','coupling_points'],
  properties:{
    file:{type:'string'},
    juno_specific:{type:'array', items:{type:'string'}},
    portable_core:{type:'array', items:{type:'string'}},
    coupling_points:{type:'array', items:{type:'object', required:['what','why_hard'],
      properties:{what:{type:'string'}, why_hard:{type:'string'}}}},
    notes:{type:'string'},
  },
}

const TARGETS = [
  'tools/trackb/null_ab.py',
  'tools/trackb/coverage_probe.py',
  'tools/trackb/observability.py',
  'tools/trackb/canary.py',
  'docs/TRACKB_CHARTER.md + docs/trackb/PLAN.md + docs/trackb/NEXT.md',
]

const survey = await parallel(TARGETS.map(t => () => agent(`${CTX}

TASK: Read ${t} completely. Enumerate exactly what is hard-wired to the JUNO-60
and what is genuinely general. Be specific: name constants, paths, symbol names,
API signatures, scenario definitions, patch/bank formats, cell offsets, build
commands, the engine entry points it calls. For each JUNO-specific item say what
the portable equivalent would have to be (a config field? a callback? a plugin
module?). Identify coupling that is HARD to generalize and say why. Do not
propose a design yet - this is a survey. Return raw structured data.`,
  {label:`survey:${t.split('/').pop().slice(0,20)}`, phase:'Survey', schema: SURVEY})))

log(`surveyed ${survey.filter(Boolean).length} targets; designing the portable contract`)

phase('Design')

const DESIGN = {
  type:'object',
  required:['name','summary','config_schema','directory_layout','engine_contract','tradeoffs'],
  properties:{
    name:{type:'string'}, summary:{type:'string'},
    config_schema:{type:'string'},
    directory_layout:{type:'string'},
    engine_contract:{type:'string'},
    migration_of_juno:{type:'string'},
    tradeoffs:{type:'array', items:{type:'string'}},
  },
}

const SURVEY_TXT = JSON.stringify(survey.filter(Boolean), null, 1).slice(0, 30000)

const ANGLES = [
  {k:'config-first', p:'Design it CONFIG-FIRST: a single declarative manifest (TOML/JSON) per synth describes engine API symbols, state size, scenario set, module ranges, build commands; the gates are generic programs that read it. Favor zero code per new synth.'},
  {k:'adapter-first', p:'Design it ADAPTER-FIRST: each synth supplies a small Python adapter module implementing a documented ABC (build(), render(scenario), cells(), modules()); the gates depend only on the ABC. Favor flexibility for synths whose shape differs from the JUNO.'},
  {k:'minimal-diff', p:'Design it MINIMAL-DIFF: keep the four gates almost exactly as they are, extract only what demonstrably differs, and accept some duplication. Favor not breaking a harness that just found five real defects.'},
]

const designs = await parallel(ANGLES.map(a => () => agent(`${CTX}

SURVEY RESULTS:
${SURVEY_TXT}

TASK: ${a.p}

Produce a concrete design for the portable framework. It must cover all four
gates plus the ledgers. Give the config schema or ABC in full, the directory
layout, the exact contract a candidate engine must satisfy, and how the existing
JUNO Track B work migrates onto it with no loss of the properties it already
proves. Name the tradeoffs you are accepting. Be concrete enough to implement.`,
  {label:`design:${a.k}`, phase:'Design', schema: DESIGN})))

const judged = await parallel(designs.filter(Boolean).map((d,i) => () => agent(`${CTX}

Judge this candidate design for the portable Track B framework.

DESIGN:
${JSON.stringify(d, null, 1).slice(0, 14000)}

Score it 0-10 on each of: (a) how little work a NEW synth port needs, (b) risk
of breaking the properties the current gates already prove, (c) whether it
carries the five self-found harness defects forward as built-in self-tests,
(d) implementability today in this repo, (e) honesty - does it make it HARDER
to accidentally claim identity that was not measured. Give a total and the
single worst weakness. Be adversarial: try to find the case where this design
lets a wrong answer through.`,
  {label:`judge:${i}`, phase:'Design',
   schema:{type:'object', required:['total','scores','worst_weakness','failure_case'],
     properties:{total:{type:'number'}, scores:{type:'string'},
       worst_weakness:{type:'string'}, failure_case:{type:'string'}}}})))

phase('Build')

const spec = await agent(`${CTX}

CANDIDATE DESIGNS:
${JSON.stringify(designs.filter(Boolean), null, 1).slice(0, 24000)}

JUDGE VERDICTS:
${JSON.stringify(judged.filter(Boolean), null, 1).slice(0, 10000)}

TASK: Synthesize the FINAL design. Take the winner, graft the best ideas from the
others, and fix every failure case the judges found. Then write it as an
implementable specification: exact files to create, exact config schema, the
engine contract, and the migration steps for the existing JUNO Track B assets.
Include a "porting a new synth" checklist a future session can follow blind.
Return markdown, complete enough to implement without re-deriving anything.`,
  {label:'build:spec', phase:'Build'})

return { survey: survey.filter(Boolean), designs: designs.filter(Boolean), judged: judged.filter(Boolean), spec }
