export const meta = {
  name: 'find-600-cycles',
  description: 'Find ~800 cycles on chip B core 0, adversarially verified, without losing audible accuracy',
  phases: [
    { title: 'Hunt', detail: 'lens-diverse lever finders over the measured record' },
    { title: 'Refute', detail: 'skeptics attack each lever' },
    { title: 'Rank', detail: 'survivors ranked by cycles per unit of risk' },
  ],
}

const REPO = '/home/user/jn60c99'

const FACTS = `
THE MEASURED STATE, all from the user's own ESP32-S3 board. Treat as given.

  budget                       5,442 cycles/sample (240 MHz / 44,100 Hz)
  chip B, LFO ON, patch 50     5,981 whole loop  -> OVER by 539
  chip B, LFO ON, patch 0      6,040 whole loop  -> OVER by 598

  voice slope                  2,362  linear, measured over a wake sweep
  FX chain                     2,622  measured three independent ways within 1 %
  output stage                    91
  shared prologue, LFO-FREE       117  measured directly by a batched probe
  the LFO added                   600  measured as a build-to-build delta

THE ARRANGEMENT NOW SHIPPING (S3L_VOICE_LO=5, S3L_SPLIT=7, S3L_FX_PIPE=1):
  core 0 = shared prologue + LFO + 2 voices   <- CRITICAL, ~5,960
  core 1 = 1 voice + FX (FX runs FIRST, one chunk behind)   ~4,984, idles ~976

THE FX IS ALREADY FREE. Moving core 1's FX loop above its voice loop hid 2,608
of its 2,622 cycles (docs/engineb/data/fxpipe2_result.md). Cutting FX cycles
buys NOTHING while core 1 is not the critical core.

THE PARTITION IS ALREADY OPTIMAL. All four assignments were enumerated; the
current one is the best. Total work is ~10,944, so PERFECT balance would be
~5,472 -- only ~30 over budget. **The work very nearly fits; the ALLOCATION
does not.** Roughly 490 cycles need to move from core 0 to core 1, or come off
core 0 entirely.

THE TARGET:
  ~540-600  parity (not enough -- MIDI, parameter control and DEVICE RECALL are
            all still missing and recall is a BURST; a chip at parity drops
            audio the first time a patch changes)
  ~811      5 % headroom
  ~1,083    10 % headroom

LEVERS ALREADY CLOSED BY MEASUREMENT -- do not re-propose without NEW evidence:
  TRIM (deleting a redundant pre-zero loop + duplicated R convert): +35 on the
    binding mask, +34 PER VOICE. The 16-register wall.
  EB_VCF_ILV (voice interleave): +131 in its own best case. Same wall.
  EB_PROLOGUE_PIPE: -7, then -2 on a retest under prologue-bound conditions.
    It changes WHEN core 1 is RELEASED; core 1 is no longer waiting, and core 0
    is WORK-bound. A lever aimed at a dependency cannot move a work bound.
  Ring placement internal vs PSRAM: PSRAM is 24 cycles FASTER. Twice.
  Memory contention as an explanation: dead, moving rings internal made it worse.
  EB_FUSE_VCA: +168. The 16-register wall.
  C1 control-rate pitch, C2 control-rate CV, C4 fixed-point/SIMD, C5 call
    fusion: all closed negative in the trunk work, for reasons in CLAUDE.md.
  The 2-tap decimator: 10.07 dB on the sonic gate, far past the standard.

THE 16-REGISTER WALL has killed FIVE compiler-side scheduling attempts. The
LX7 has sixteen float registers. Anything that forces more live values across
a call boundary spills, and the spill costs more than the scheduling saves.
Say so explicitly for anything in that class.

THE STANDARD:
  TRUNK stays BIT-EXACT. Do not propose trunk changes.
  FORK is AUDIBLE: tools/engineb/sonic_gate.py, worst third-octave band,
  control 3.17 dB, user judges by ear. A lever that costs sonic accuracy must
  say how much, and "probably inaudible" is not a measurement.
  The bias law: phase-integrated quantities (pitch -> DCO phase, LFO rate ->
  LFO phase) need bias < 1e-9 and admit NO causal approximation. Memorylessly
  consumed quantities (VCF coefficients, gains) tolerate ~1e-5.

HOUSE RULES:
  Label PROVEN (executed) / READ (source) / INFERRED. Cite file:line.
  A subtraction is not a measurement. An estimate is not a result.
  SEVEN of eight estimates in this project were wrong; six flattered
  themselves and one was 2.5x pessimistic. Quote a range, not a point.
  Read the code before pricing the code. Three defects tonight came from
  describing a structure without reading it.
`

const LEVER = {
  type: 'object',
  properties: {
    levers: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          title: { type: 'string' },
          kind: { type: 'string', enum: ['MOVE-WORK', 'REMOVE-WORK', 'CHEAPER-ARITHMETIC', 'RESTRUCTURE', 'CONFIG'] },
          mechanism: { type: 'string', description: 'exactly what changes, file:line level' },
          cycles_low: { type: 'number', description: 'pessimistic edge on the critical core' },
          cycles_high: { type: 'number' },
          sonic_cost: { type: 'string', description: 'EXACTLY 0 / bounded dB / unknown, and why' },
          register_wall: { type: 'string', description: 'does it add live values across a call boundary? be honest' },
          evidence: { type: 'string' },
          label: { type: 'string', enum: ['PROVEN', 'READ', 'INFERRED'] },
          gate: { type: 'string', description: 'the one test that would decide it' },
        },
        required: ['id', 'title', 'kind', 'mechanism', 'cycles_low', 'cycles_high', 'sonic_cost', 'register_wall', 'evidence', 'label', 'gate'],
      },
    },
    swept: { type: 'string' },
  },
  required: ['levers', 'swept'],
}

phase('Hunt')

const LENSES = [
  { id: 'movework', title: 'move work off core 0 onto core 1',
    ask: `Core 1 idles ~976 cycles every sample. Core 0 is critical. Find every
piece of core 0's work that could RUN ON CORE 1 instead, including pipelined a
chunk ahead the way the FX already is.

The strongest candidate to evaluate first, and you must evaluate it properly
rather than accept it: the shared prologue + LFO. It is autonomous -- it
depends on its own state, the noise LFSR, and voice 0's cvgate/glide -- so it
could in principle be computed ONE CHUNK AHEAD on core 1 and published, exactly
as eb_master_render now is. Read engine_b/eb_render.c's eb_engine_render_shared
and eb_shared_tick, and esp32s3/main/juno_s3_listen.c's render_block and
worker. Answer: what does the prologue read that the voices of the SAME chunk
write? If nothing, it can be pipelined. If something, name it and say whether
that dependency can be broken.

Also consider moving only PART of it (the LFO but not the noise LFSR, or vice
versa), and what each part costs. Note the noise LFSR feeds eb_lfo_tick, so
they may not separate.` },

  { id: 'removework', title: 'work the shipping build does not need',
    ask: `Find work core 0 does that the SHIPPING product does not require.
S3L_VOICE_LO already removed five voices' worth. Look for more of the same
shape: loops over EB_NUM_VOICES=8 where only 3 exist, at-rest advances for
voices this chip does not own, coefficient copies of blocks that never change,
zeroing that a static already guarantees, per-sample work that is constant
across a chunk.

Read esp32s3/main/juno_s3_listen.c and engine_b/eb_render.c's
eb_engine_render_range with S3L_VOICE_LO=5 / S3L_SPLIT=7 in mind. Compile the
headers at the shipping flags and check struct sizes and loop bounds against
what three owned voices actually need. EB_NUM_VOICES is 8 and the product is 6
across two chips -- what does that cost, concretely?` },

  { id: 'lfoitself', title: 'the LFO chain itself',
    ask: `The LFO cost 600 cycles measured. Read engine_b/eb_lfo.c,
eb_cvgate.*, eb_glide.* and price what is actually in that chain at the
shipping flags -- READ IT, do not model it. Then find what is cheap to remove
WITHOUT changing what it computes:

- eb_lfo.c has EB_EXP_MEMO on one of its two exp sites. Why not the other?
- fmodf's slow arm is MEASURED at 9.75 % of calls (CLAUDE.md). Is the fast arm
  as cheap as it could be under EB_NOLIBM?
- The LFO runs at audio rate. Its OUTPUT is consumed memorylessly by the
  modulation stage (bias law: ~1e-5 tolerated) but its PHASE integrates
  (needs 1e-9). Can the phase advance exactly while the SHAPE is evaluated at
  control rate and interpolated? EB_CR_* already does this for other modules;
  read eb_render.c's CR_RUN/CR_OUT and say whether an EB_CR_LFO is admissible
  under the bias law, and what it would cost sonically.
- Voice 0's cvgate and glide run in the prologue purely to feed the LFO's delay
  envelope. When voice 0 is AT REST, what do they actually produce, and is
  there a cheaper exact path for that case?` },

  { id: 'config', title: 'configuration and build settings',
    ask: `Find cycles in settings rather than code. Read esp32s3/sdkconfig,
sdkconfig.defaults, main/CMakeLists.txt and the linker fragment.

Consider and price honestly: instruction/data cache size and associativity
(the current settings are 32 KB I / 64 KB D, 8-way); putting the hot engine
code in internal RAM rather than flash-mapped XIP (the .text is 2.85 MB
flash-mapped -- what is the icache miss cost at 44,100 samples/s?); the linker
fragment's placement choices; -O2 vs -O3 vs -Os on the engine translation
units; PSRAM speed and mode; whether the voice STATE (eb_render_state, ~736 KB)
being in PSRAM costs measurable cycles versus a 3-voice subset in internal RAM.

That last one is the big one: with S3L_VOICE_LO=5 only THREE voices' state is
touched. What is 3 voices' worth of eb_render_state, and does it fit in the
~78 KB of internal RAM the firmware reports free?` },
]

const hunts = await parallel(LENSES.map(L => () =>
  agent(`${FACTS}

YOUR LENS: ${L.title}

${L.ask}

Report only levers you can evidence. A lever with a file:line mechanism and an
honest cycle RANGE is worth ten suspicions. If your lens is empty, say so --
this project has been damaged more by confident wrong numbers than by missing
ideas.`,
    { label: `hunt:${L.id}`, phase: 'Hunt', schema: LEVER, effort: 'high' })
    .then(v => ({ lens: L.id, ...v }))))

const all = []
for (const h of hunts.filter(Boolean)) for (const l of (h.levers || [])) all.push({ ...l, lens: h.lens })
log(`${all.length} candidate levers from ${hunts.filter(Boolean).length} lenses`)

phase('Refute')

const VERDICT = {
  type: 'object',
  properties: {
    refuted: { type: 'boolean' },
    confidence: { type: 'string', enum: ['certain', 'likely', 'unsure'] },
    corrected_low: { type: 'number', description: 'your own pessimistic cycle estimate, 0 if refuted' },
    corrected_high: { type: 'number' },
    reasoning: { type: 'string' },
    evidence: { type: 'string' },
  },
  required: ['refuted', 'confidence', 'corrected_low', 'corrected_high', 'reasoning', 'evidence'],
}

const judged = await parallel(all.slice(0, 16).map(l => () =>
  parallel([
    () => agent(`${FACTS}

REFUTE THIS LEVER. Default to it being wrong, unreachable, or already closed.

  ${l.title} [${l.kind}]
  MECHANISM: ${l.mechanism}
  CLAIMED: ${l.cycles_low}-${l.cycles_high} cycles on the critical core
  SONIC COST CLAIMED: ${l.sonic_cost}
  REGISTER WALL: ${l.register_wall}
  EVIDENCE: ${l.evidence}

Go to the source. Check: is this already closed by one of the measured
negatives? Does it hit the 16-register wall? Does it move work OFF the critical
core or merely rearrange it? Is the cycle number a subtraction? Would it break
the bias law? Does the shipping flag set already do it?

Give your OWN pessimistic and optimistic cycle numbers.`,
      { label: `refute:${l.id}`, phase: 'Refute', schema: VERDICT, effort: 'high' }),

    () => agent(`${FACTS}

SONIC RISK CHECK on this lever. You are judging whether it damages the sound.

  ${l.title}
  MECHANISM: ${l.mechanism}
  SONIC COST CLAIMED: ${l.sonic_cost}

The fork's standard is the third-octave sonic gate, control 3.17 dB. Read
tools/engineb/sonic_gate.py to see exactly what is measured. Then judge: does
this lever change the ARITHMETIC, the ORDER, or only the SCHEDULING? Scheduling
changes are EXACTLY 0 by construction; arithmetic changes are not.

Apply the bias law explicitly. If the lever touches anything feeding a phase
integrator, say so and refute it on those grounds.

Set refuted=true if the sonic cost is unbounded, unmeasurable, or would clearly
exceed the control.`,
      { label: `sonic:${l.id}`, phase: 'Refute', schema: VERDICT, effort: 'high' }),
  ]).then(vs => {
    const v = vs.filter(Boolean)
    return { lever: l, verdicts: v, survived: v.length > 0 && v.every(x => !x.refuted) }
  })))

if (all.length > 16) log(`⚠ ${all.length - 16} levers NOT verified (cap 16)`)

const kept = judged.filter(Boolean).filter(j => j.survived)
log(`${kept.length}/${Math.min(all.length,16)} levers survived refutation`)

phase('Rank')

const report = await agent(`${FACTS}

These levers SURVIVED two independent skeptics -- one attacking the mechanism
and cycle count, one attacking the sonic cost. Both had to fail to kill it.

=== SURVIVORS ===
${JSON.stringify(kept, null, 1).slice(0, 55000)}

=== KILLED (for the record, so nobody re-proposes them) ===
${JSON.stringify(judged.filter(Boolean).filter(j => !j.survived).map(j => ({
  title: j.lever.title, why: j.verdicts.map(v => v.reasoning.slice(0, 300)),
})), null, 1).slice(0, 12000)}

Write the plan the maintainer executes. Requirements:

1. Lead with the single most important sentence.
2. A TABLE of surviving levers: cycles (pessimistic-optimistic, using the
   SKEPTICS' numbers not the proposers'), sonic cost, risk, and the one test
   that decides each.
3. Do they ADD UP to the target? Show the arithmetic for 539 (parity), 811
   (5 % headroom) and 1,083 (10 %). Say plainly if they do not.
4. ORDER them by cycles-per-unit-of-risk, and say which ONE to do first and
   why. Prefer levers whose sonic cost is EXACTLY 0 by construction
   (scheduling, not arithmetic) over anything that changes the sound.
5. For each of the top three, give the CONCRETE change: files, functions, flag
   name, and what the firmware should print so a wrong result is visible.
6. State what you did NOT find, and whether you believe the target is
   reachable at all without a concession the user has ruled out (a third chip,
   a different chip, 32 kHz, fewer voices, dropping FX). If you think it is not
   reachable, say THAT FIRST instead of burying it -- this project's rule is
   that when the numbers say a goal is probably unreachable, that sentence
   goes first.

Markdown, ready for docs/engineb/data/.`,
  { label: 'rank:plan', phase: 'Rank', effort: 'max' })

return { candidates: all.length, survived: kept.length, report }
