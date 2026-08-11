export const meta = {
  name: 'fork-adversarial-audit',
  description: 'Loop-until-dry adversarial hunt for defects in the S3 fork, every finding refuted before it survives',
  phases: [
    { title: 'Hunt', detail: 'lens-diverse refuters, told to break the fork' },
    { title: 'Refute', detail: 'independent skeptics try to kill each finding' },
    { title: 'Synthesise', detail: 'survivors ranked, with the defect class named' },
  ],
}

const REPO = '/home/user/jn60c99'

const SHIPPING = `-DEB_FORK_S3 -DEB_DCO_WT=1 -DEB_LFO_SHARED=1 -DEB_VCF_DEADCOEF=1
-DEB_VCF_RES_LUT=256 -DEB_ATREST_BLOCK=1 -DEB_ATREST_O1=1 -DEB_ZEROCOEF=1
-DEB_EXP_MEMO=1 -DEB_HALF_OS_VCF=1 -DEB_NOLIBM=1 -DEB_VCF_MAPFAST=1 -DEB_FPDIV=1
-DEB_CR_PITCH=1 -DEB_CR_MODCV=1 -DEB_CR_VCFCV=1 -DEB_CR_ENV=1
-DEB_CR_N=4 -DEB_CR_NP=4 -DEB_CR_NC=2 -DEB_CR_NE=2 -DEB_ENV_CR=2
firmware side: -DS3_CORES=2 -DS3L_SPLIT=7 -DS3L_VOICE_LO=5 -DS3L_FX_PIPE=1
               -DS3L_REPORT_EVERY=5 CHUNK=256 S3L_VOICES=3 S3_NOFX=0`

const BASE = `
You are auditing the ESP32-S3 FORK of a bit-exact JUNO-60 port at ${REPO}.
Your job is to BREAK IT. Default to the assumption that it is defective.

THE FORK'S SHIPPING FLAG SET (this is what runs on the user's board):
${SHIPPING}

THE STANDARD:
- The TRUNK must be BIT-EXACT (null gate: residual EXACTLY 0). Do not propose
  trunk changes.
- The FORK is held to an AUDIBLE standard: tools/engineb/sonic_gate.py, worst
  third-octave band, control 3.17 dB. The user judges by ear on WAVs.
- Correctness defects (the instrument does the WRONG THING) outrank cost.

THE DEFECT CLASS THAT JUST COST THIS PROJECT A WHOLE NIGHT, and your best
template for finding more:

  The device sets voice 0 at rest (no wake mask but 0xff has bit 0, and the
  shipping build has S3L_VOICE_LO=5). eb_render.c:84 then returns from the
  SHARED prologue with the LFO outputs left at 0 and ready=1. eb_render.c:491
  hands those zeros to every voice. eb_alloc.c:99 scans TOP-DOWN so voice 0 is
  the LAST voice ever allocated. Result: under EB_LFO_SHARED the instrument
  has NO LFO below eight-note polyphony.
  NO GATE COULD SEE IT: engine_b/shim/standalone/juno_driver.c:337 forces
  atrest = 0 on every voice, so the certified fork and the shipping firmware
  differ in exactly the flag that decides whether the LFO exists.

Generalise that shape. It has three ingredients and you are hunting for more
of each:
  (a) the DEVICE is configured differently from the GATE HARNESS;
  (b) a SHORTCUT justified for one voice/one case silently affects something
      SHARED or GLOBAL;
  (c) a precondition that was TRUE when a lever was proven and is FALSE now.

HOUSE RULES:
- Label every claim PROVEN (you executed it) / READ (source or doc) / INFERRED.
- Cite file:line for everything. A claim without a citation is worthless here.
- Give a CONCRETE FAILURE SCENARIO: inputs/state -> what the user would hear or
  what number would be wrong. "This looks risky" is not a finding.
- Do NOT modify any file. Read, reason, and where possible EXECUTE a probe in
  a scratch directory to prove it.
- A subtraction is not a measurement. An estimate is not a result.
- Six of seven estimates in this project were optimistic. Assume yours is too.
Docs: ${REPO}/docs/engineb/data/*.md, ${REPO}/CLAUDE.md, ${REPO}/docs/engineb/METHOD_PLAYBOOK.md
`

const FIND = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', description: 'short kebab-case slug' },
          title: { type: 'string' },
          severity: { type: 'string', enum: ['CORRECTNESS', 'SONIC', 'COST', 'GATE-BLINDNESS', 'DOC-STALE'] },
          claim: { type: 'string' },
          evidence: { type: 'string', description: 'file:line citations, or executed output' },
          failure_scenario: { type: 'string', description: 'concrete: state -> wrong result the user would notice' },
          label: { type: 'string', enum: ['PROVEN', 'READ', 'INFERRED'] },
          gate_sees_it: { type: 'string', description: 'which existing gate would catch this, or why none can' },
        },
        required: ['id', 'title', 'severity', 'claim', 'evidence', 'failure_scenario', 'label', 'gate_sees_it'],
      },
    },
    swept: { type: 'string', description: 'what you actually looked at, so coverage is auditable' },
  },
  required: ['findings', 'swept'],
}

const VERDICT = {
  type: 'object',
  properties: {
    refuted: { type: 'boolean', description: 'true if the finding is WRONG or harmless' },
    confidence: { type: 'string', enum: ['certain', 'likely', 'unsure'] },
    reasoning: { type: 'string' },
    correction: { type: 'string', description: 'if partly right, the corrected claim' },
    evidence: { type: 'string', description: 'file:line or executed output that settles it' },
  },
  required: ['refuted', 'confidence', 'reasoning', 'evidence'],
}

const LENSES = [
  { id: 'gateblind', title: 'gate vs device divergence',
    ask: `Enumerate EVERY way the DEVICE is configured differently from the GATE
HARNESS. Read engine_b/shim/standalone/juno_driver.c and shim/voices/, all of
tools/engineb/null_b.py and sonic_gate.py, and esp32s3/main/juno_s3_listen.c.
For each difference: what does the device do that the gate never exercises?
The atrest one is already known -- find the others. Consider: how coefficients
arrive (host blob vs eb_render_coefs_build), which voices exist, the split
ranges, the FX pipeline banks, the master state load, the ring lengths, the
sample rate, the note path, block sizes, and initial state.` },

  { id: 'shared', title: 'shared state depending on per-voice conditions',
    ask: `Find every SHARED or GLOBAL quantity in the fork and prove whether its
computation depends on a per-voice or per-range condition that may be false on
the device. Start from eb_shared_tick in eb_render.h and every field of it, the
noise LFSR (eb_notecv), the LFO, v0_pit_in / v0_gate_sign / v0_dly_env /
v0_pitch_cv, and anything the two CORES exchange (w_shb, w_vbb, w_ready, the
S3L_FX_PIPE banks). For each: what happens when the owning voice is at rest, or
lives on the other core, or on the other CHIP?` },

  { id: 'shortcuts', title: 'every skip, early return and continue',
    ask: `Enumerate EVERY shortcut in the fork: early returns, 'continue',
'if (flag) skip', memoisation, held/control-rate values, zero-coefficient
skips, dead-coefficient skips. For each, name EXACTLY what it skips and prove
whether anything else depends on the skipped work. Pay special attention to
EB_ZEROCOEF, EB_VCF_DEADCOEF, EB_EXP_MEMO, EB_ATREST_BLOCK, EB_ATREST_O1 and
the EB_CR_* holds. A memoised expf whose memo key is stale, or a zero-coef skip
whose coefficient becomes nonzero mid-note, are the shapes to hunt.` },

  { id: 'flags', title: 'flag combinations never gated together',
    ask: `Read engine_b/eb_fork_config.h and every #if in engine_b/*.c and .h.
Build the matrix of fork flags. Then determine, from tools/engineb/*.py and the
docs, WHICH COMBINATIONS have actually been gated together and which have not.
The shipping set is ~22 flags; the sonic gate runs one BASE set. Find flags
whose interaction is unproven, especially where two of them touch the same
state. Name any flag that is ON in the firmware but was proven only in
isolation or only with a different set.` },

  { id: 'ranges', title: 'index, range and buffer arithmetic',
    ask: `Audit every index and range in the fork's two-core / owned-voice
scheme: S3L_VOICE_LO, S3L_SPLIT, EB_NUM_VOICES, EB_SLOTS, the wake masks, the
w_vbb[2][CHUNK][EB_NUM_VOICES] banks, w_pcm, the at-rest advance range, the
master's sum over voices, and load_coefs' memcpy sizes against the real struct
sizes at the SHIPPING FLAGS. Compile the headers at those flags and compare
sizeof against the blob's header constants. An off-by-one here is silent and
this project has already had one (rev_pending[33] vs EB_REV_NTAP 34).` },

  { id: 'numeric', title: 'approximations whose preconditions may have moved',
    ask: `Every fork approximation was proven under some condition. Re-derive
whether those conditions still hold TOGETHER in the shipping set: the wavetable
DCO (EB_DCO_WT), half-oversampled VCF (EB_HALF_OS_VCF), the control-rate holds
(EB_CR_*, EB_ENV_CR=2), EB_VCF_MAPFAST, EB_FPDIV, EB_NOLIBM's ternary min/max,
EB_VCF_RES_LUT=256, EB_EXP_MEMO. For each: what was the proof, what set was it
proven in, and does anything in the current set invalidate it? The bias law
applies: phase-integrated quantities need bias < 1e-9, memoryless ones tolerate
~1e-5. Flag anything where an approximation now feeds a phase integrator.` },

  { id: 'firmware', title: 'the firmware itself, as a program',
    ask: `Audit esp32s3/main/juno_s3_listen.c as a concurrent program. The two
cores share w_go/w_done/w_ready/w_cur/w_have_prev as plain volatile ints with no
barriers on an LX7. Prove or refute: is the FX pipeline's bank flip actually
race-free? Is w_ready's publish ordered after the prologue's writes? What does
-flto do to those accesses? Also audit: the blob layout assert, ms_load's
member-by-member copy, the I2S error paths, what happens if load_coefs runs
while core 1 is mid-chunk, and whether the gate/frame counter can desynchronise
from the snapshot it assumes.` },
]

const MAX_ROUNDS = 3
const seen = new Set()
const survivors = []
let dry = 0, round = 0
const dropped = []

while (dry < 2 && round < MAX_ROUNDS) {
  round++
  phase('Hunt')
  const already = survivors.length
    ? `\n\nALREADY FOUND AND CONFIRMED IN EARLIER ROUNDS -- do NOT report these again, find NEW ones:\n` +
      survivors.map(s => `- [${s.id}] ${s.title}`).join('\n')
    : ''

  const hunts = await parallel(LENSES.map(L => () =>
    agent(`${BASE}${already}

YOUR LENS: ${L.title}

${L.ask}

Report every defect you can PROVE or strongly evidence. Quality over quantity:
a finding with a real file:line chain and a concrete failure scenario is worth
ten suspicions. If your lens turns up nothing real, return an empty findings
list and say what you swept -- an honest empty result is useful and a padded
one is not.`,
      { label: `hunt${round}:${L.id}`, phase: 'Hunt', schema: FIND, effort: 'high' })
      .then(v => ({ lens: L.id, ...v }))))

  const fresh = []
  for (const h of hunts.filter(Boolean)) {
    for (const f of (h.findings || [])) {
      const key = (f.id || f.title || '').toLowerCase().replace(/[^a-z0-9]/g, '')
      if (!key || seen.has(key)) continue
      seen.add(key)
      fresh.push({ ...f, lens: h.lens })
    }
  }
  log(`round ${round}: ${fresh.length} fresh findings from ${hunts.filter(Boolean).length} lenses`)

  if (!fresh.length) { dry++; continue }
  dry = 0

  const CAP = 14
  const toVerify = fresh.slice(0, CAP)
  if (fresh.length > CAP) {
    for (const f of fresh.slice(CAP)) dropped.push(`${f.id} (${f.severity}) -- not verified, over the ${CAP}/round cap`)
    log(`⚠ ${fresh.length - CAP} findings NOT verified this round (cap ${CAP}) -- listed in the result`)
  }

  phase('Refute')
  const judged = await parallel(toVerify.map(f => () =>
    parallel([
      () => agent(`${BASE}

REFUTE THIS FINDING. Your default answer is that it is WRONG. Only concede if
you cannot break it.

  TITLE: ${f.title}
  CLAIM: ${f.claim}
  EVIDENCE OFFERED: ${f.evidence}
  FAILURE SCENARIO CLAIMED: ${f.failure_scenario}
  REPORTER'S LABEL: ${f.label}

Go to the source yourself. Check every citation resolves and says what is
claimed. Check the code path is REACHABLE at the shipping flags. Check whether
some other mechanism already handles it. Check whether the failure scenario
would actually occur, or is prevented by something the reporter did not read.
Set refuted=true if the finding is wrong, unreachable, already handled, or
harmless in practice.`,
        { label: `refute:${f.id}`, phase: 'Refute', schema: VERDICT, effort: 'high' }),

      () => agent(`${BASE}

REACHABILITY AND IMPACT CHECK on this claimed defect. You are not judging
whether the code is odd -- you are judging whether it BITES.

  TITLE: ${f.title}
  CLAIM: ${f.claim}
  EVIDENCE: ${f.evidence}
  SCENARIO: ${f.failure_scenario}

Answer, with citations: (1) At the shipping flag set, is this code path
actually executed? Prove it. (2) If it is, what is the AUDIBLE or NUMERICAL
consequence -- quantify it if you can, by executing a probe if that is
possible. (3) Does any existing gate catch it, and if not, what is the smallest
gate that would? Set refuted=true if it is unreachable or the consequence is
below the fork's audible standard AND below any cycle relevance.`,
        { label: `impact:${f.id}`, phase: 'Refute', schema: VERDICT, effort: 'high' }),
    ]).then(vs => {
      const v = vs.filter(Boolean)
      const kills = v.filter(x => x.refuted).length
      return { finding: f, verdicts: v, survived: v.length > 0 && kills < v.length }
    })))

  const kept = judged.filter(Boolean).filter(j => j.survived)
  for (const k of kept) survivors.push({ ...k.finding, verdicts: k.verdicts })
  log(`round ${round}: ${kept.length}/${toVerify.length} survived refutation; ${survivors.length} total`)
}

phase('Synthesise')

const synth = await agent(`${BASE}

Below are the defects that SURVIVED independent adversarial refutation, across
${round} hunting rounds. Two skeptics attacked each one; only findings neither
could kill outright are here.

=== SURVIVORS ===
${JSON.stringify(survivors, null, 1).slice(0, 60000)}

=== NOT VERIFIED (over the per-round cap, honest disclosure) ===
${dropped.length ? dropped.join('\n') : '(none)'}

Produce the report the maintainer needs:

1. Rank the survivors by (does the instrument do the WRONG THING) first, then
   sonic, then cost, then gate blindness, then doc staleness.
2. For each, state it in ONE sentence a tired engineer can act on, then the
   file:line chain, then the concrete failure.
3. Group them by DEFECT CLASS -- the three shapes in your brief (device/gate
   divergence, shared-depends-on-per-voice, precondition-moved) plus any new
   class the survivors reveal. Naming the class is more valuable than listing
   instances, because it tells the next session where to look.
4. Name, for each class, the GATE THAT WOULD HAVE CAUGHT IT and does not exist.
   Be concrete enough to build it.
5. State plainly what you did NOT cover, and what the honest confidence is that
   the fork has no further defects of these classes. Do not claim exhaustive.

Write it as markdown, ready to drop into docs/engineb/data/. Lead with the
single most important sentence.`,
  { label: 'synthesise:report', phase: 'Synthesise', effort: 'max' })

return { rounds: round, survivors: survivors.length, dropped, report: synth }
