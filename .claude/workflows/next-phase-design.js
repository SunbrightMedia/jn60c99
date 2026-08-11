export const meta = {
  name: 'juno-s3-next-phase',
  description: 'Design the two-chip link and the random-note harness from the repo evidence',
  phases: [
    { title: 'Understand', detail: 'four parallel readers over the mechanisms that gate the next step' },
    { title: 'Design', detail: 'link design and harness design, fed by the readers' },
    { title: 'Critique', detail: 'adversarial review of the link design, plus a completeness pass' },
  ],
}

const REPO = '/home/user/jn60c99'

const FINDINGS = {
  type: 'object',
  properties: {
    summary: { type: 'string', description: 'The single most important sentence first.' },
    facts: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          claim: { type: 'string' },
          evidence: { type: 'string', description: 'file:line or command output that proves it' },
          label: { type: 'string', enum: ['PROVEN', 'READ', 'INFERRED'] },
        },
        required: ['claim', 'evidence', 'label'],
      },
    },
    blockers: { type: 'array', items: { type: 'string' }, description: 'Things that make the next step impossible or expensive as currently built' },
    unknowns: { type: 'array', items: { type: 'string' } },
  },
  required: ['summary', 'facts', 'blockers', 'unknowns'],
}

const DESIGN = {
  type: 'object',
  properties: {
    summary: { type: 'string' },
    design: { type: 'string', description: 'The full design in markdown. Concrete: names, files, constants, call sites.' },
    cost_estimate: { type: 'string', description: 'Cycle/latency/memory cost, with the pessimistic edge quoted as the planning number' },
    risks: { type: 'array', items: { type: 'string' } },
    measurement_gate: { type: 'string', description: 'The single decisive test, with two named outcomes' },
  },
  required: ['summary', 'design', 'cost_estimate', 'risks', 'measurement_gate'],
}

phase('Understand')

const CONTEXT = `
You are reading a real, heavily-measured embedded audio project at ${REPO}.
It is a bit-exact C99 port of the Roland JUNO-60 (JU-06A) VST3 DSP, and the
current work is a fork of its "engine B" running on ESP32-S3 hardware.

STATE AS OF TONIGHT, all MEASURED on the user's own board (do not re-derive):
  budget            5,442 cycles/sample (240 MHz / 44,100 Hz)
  voice slope       2,362 cycles, linear
  FX chain          2,622 cycles, measured three independent ways within 1 %
  shared prologue     117 cycles (eb_engine_render_shared)
  output stage         91 cycles
  chip A (3 voices, no FX)                     4,724, fits with 718 spare
  chip B (3 voices + FX, owning only its own)  5,440 timed loop, 0.29 % behind on the wall clock

The plan is TWO ESP32-S3 boards, 3 voices each, FX on chip B. The user has
ruled out permanently: a third chip, a different chip, 32 kHz, fewer voices,
dropping FX.

HOUSE RULES YOU MUST FOLLOW:
- Label every claim PROVEN (you executed something) / READ (you read source or
  a doc) / INFERRED. Never over-claim.
- A subtraction is not a measurement. An estimate is not a result.
- Six of seven estimates in this project were optimistic. Quote pessimistic edges.
- Read the code before pricing the code. This project has been bitten three
  times tonight by describing a structure without reading it.
- Do NOT modify any file. You are reading and reporting only.
Useful docs: ${REPO}/docs/engineb/data/*.md and ${REPO}/CLAUDE.md (top block).
`

const READERS = [
  {
    key: 'noteblob',
    label: 'read:note-and-blob',
    prompt: `${CONTEXT}

YOUR QUESTION: **Can the listen firmware be driven with RANDOMISED NOTE
PATTERNS, or is it structurally limited to the fixed chords it loops today?**

Read ${REPO}/esp32s3/main/juno_s3_listen.c (the chord/gate loop, load_coefs,
blob_open, the S3L_* meta constants) and
${REPO}/tools/engineb/gen_listen_coefs.py, plus
${REPO}/esp32s3/main/s3_listen_meta.h if present.

Answer specifically:
1. What exactly does load_coefs(CH, gate) load, and where does it come from?
2. The blob carries "one snapshot per chord size 1..8" -- what IS a snapshot
   (coefficients only? full voice state? which voices?), and does it pin WHICH
   voice indices sound?
3. If we want note-on/note-off at arbitrary times on arbitrary voices, what
   does the firmware lack? Be concrete: name the missing call, the missing
   state, the missing generator output.
4. Is there any path to randomised notes that does NOT require a device-side
   recall/coefficient-build (which does not exist)? For instance, can a
   snapshot be reused across voice indices, or the wake mask varied while the
   coefficients stay put?
5. What would the CHEAPEST honest randomised-note harness look like, given
   what exists today?

This is the gating question for the whole "test with real playing" item, so be
exact about what is possible and what is not.`,
  },
  {
    key: 'alloc',
    label: 'read:allocator-and-cores',
    prompt: `${CONTEXT}

YOUR QUESTION: **How do notes land on voices, how do voices land on CORES, and
what exactly is the measured disaster case?**

Read ${REPO}/engine_b/eb_alloc.c and .h, the S3L_SPLIT and wake-mask handling
in ${REPO}/esp32s3/main/juno_s3_listen.c, and the S3L_VOICE_LO block added
today. Also read what CLAUDE.md says about "S3L_SPLIT=5 ... 9,204 cycles,
70 % over".

Answer specifically:
1. The allocator's real law (it is CAssignJu60 transcribed). Which voice does a
   fresh note-on take, in POLY? Confirm the "fills from voice 7 downward" claim
   from the code, or correct it.
2. Given that law, for a 1..6 note chord, WHICH voice indices sound? Produce
   the actual table.
3. With core 0 = [S3L_VOICE_LO, S3L_SPLIT) and core 1 = [S3L_SPLIT, 8), which
   SPLIT values give a balanced 2/1 or 2/2 for each chord size? Where does it
   go catastrophically wrong, and why is 9,204 the number?
4. For the TWO-CHIP design (chip A owns 3 voices, chip B owns 3 voices + FX):
   which voice indices should each chip own, and what forces a 6-note chord to
   distribute 3/3 across chips rather than piling onto one? Is there anything
   in the allocator that guarantees or prevents this?
5. Name the concrete mechanism that would FORCE a safe distribution, and what
   it would cost.

Be exact. The 70 %-over case is a real shipping hazard and the mechanism to
prevent it does not exist yet.`,
  },
  {
    key: 'link',
    label: 'read:i2s-link-transport',
    prompt: `${CONTEXT}

YOUR QUESTION: **What is the cheapest correct way to carry 3 voices of audio
from chip A to chip B, and how do the two boards avoid clock drift?**

Read the I2S setup in ${REPO}/esp32s3/main/juno_s3_listen.c (i2s_start, the
GPIO pins, the channel config), ${REPO}/esp32s3/sdkconfig.defaults, and any
board notes in ${REPO}/esp32s3/LISTEN.md. Then use WebSearch/WebFetch on the
ESP-IDF v5.x i2s_std driver documentation and the ESP32-S3 technical reference
manual for: slave mode, external MCLK/BCLK input, simultaneous TX and RX
channels, DMA descriptor cost, and whether one I2S peripheral can do TX and RX
on the same clock.

Answer specifically:
1. How many I2S peripherals does the ESP32-S3 have, and can one do TX and RX
   simultaneously sharing BCLK/WS?
2. Can chip B run its I2S as a SLAVE to chip A's BCLK/WS, so both boards share
   ONE sample clock and the drift question disappears by construction? Cite the
   documentation.
3. What is the per-sample CPU cost of an extra DMA RX channel, honestly? DMA
   moves the bytes, but name every place the CPU still touches them.
4. Pin budget: chip A currently uses GPIO 5/6/7 for BCLK/LRCK/DOUT. What pins
   are free, and does the link need 3 more or can it share the existing clock
   lines?
5. What is the LATENCY cost of the link in samples/ms, and does it stack with
   the FX pipeline's one-chunk delay?
6. Name the failure modes: what happens on power-up ordering, on a dropped
   frame, on a chip B reset.

Cite documentation for every claim about the hardware. Label anything you
could not verify as INFERRED.`,
  },
  {
    key: 'headroom',
    label: 'read:where-headroom-lives',
    prompt: `${CONTEXT}

YOUR QUESTION: **Where could 5-10 % of genuine headroom come from, given
everything already tried and closed?**

Read ${REPO}/docs/engineb/data/*.md thoroughly -- especially
gap_decomposition.md, lastmile_result.md, asm_kernel_recon.md,
trim_result.md, fx_measured.md, fxpipe2_result.md, headroom.md,
prologue_measured.md -- and ${REPO}/CLAUDE.md's top block.

Build a COMPLETE ledger of:
1. Every lever ALREADY CLOSED NEGATIVE, with its measured number and the reason
   it failed. (There are many: TRIM, EB_VCF_ILV, EB_PROLOGUE_PIPE twice, ring
   placement, contention, C1/C2/C4/C5, control-rate holds beyond what shipped,
   the 2-tap decimator, EB_FUSE_VCA...)
2. Every lever ADOPTED and what it bought.
3. Every lever NAMED BUT NEVER MEASURED. This is the important list.
4. For each never-measured lever: what it would plausibly buy, what it would
   cost in sonic terms, and whether its closure conditions have CHANGED since
   it was proposed (several closures tonight turned out to have been measured
   under conditions that no longer hold -- ring placement and prologue-pipe
   both).
5. Rank the never-measured levers by (cycles per unit of risk).

The user's standard for the fork is AUDIBLE accuracy, gated by
tools/engineb/sonic_gate.py against a 3.17 dB control, with the judgement
staying with the user. Do not propose anything that changes the TRUNK, which
must stay bit-exact.

The 16-register wall has killed five compiler-side scheduling attempts; say so
for anything in that class.`,
  },
]

const reads = await parallel(READERS.map(r => () =>
  agent(r.prompt, { label: r.label, phase: 'Understand', schema: FINDINGS })
    .then(v => ({ key: r.key, ...v }))))

const byKey = {}
for (const r of reads.filter(Boolean)) byKey[r.key] = r
const brief = k => byKey[k] ? JSON.stringify(byKey[k], null, 1).slice(0, 9000) : '(that reader returned nothing)'

log(`readers done: ${reads.filter(Boolean).length}/4`)

phase('Design')

const [linkDesign, harnessDesign] = await parallel([
  () => agent(`${CONTEXT}

You are designing the TWO-CHIP LINK. Two readers have already gone over the
ground; their findings are below and you should treat them as your evidence
base, correcting them where you can show they are wrong.

=== I2S / TRANSPORT READER ===
${brief('link')}

=== ALLOCATOR / VOICE-TO-CORE READER ===
${brief('alloc')}

Produce a COMPLETE design for carrying 3 voices of audio from chip A to chip B
and mixing them into chip B's FX chain, such that:
- the two boards share ONE sample clock (no drift by construction, if the
  hardware allows it -- say so plainly if it does not)
- the steady-state CPU cost lands on a core that has slack: chip A's cores have
  718 and ~2,700 spare, chip B's have ~0 and ~460
- latency is stated honestly and stacked with the FX pipeline's chunk
- power-up ordering, chip B reset and a dropped frame all have defined behaviour

Be concrete to the level of: which files change, which functions, which GPIOs,
which i2s_chan_config_t fields, where in render_block the received audio is
summed, and what the firmware prints so a wrong wiring is visible immediately
rather than as silence.

State the cost with the PESSIMISTIC edge as the planning number. Six of seven
estimates in this project were optimistic.

The measurement_gate must be ONE test with TWO named outcomes, runnable with
two boards and the existing serial harness.`,
    { label: 'design:two-chip-link', phase: 'Design', schema: DESIGN, effort: 'high' }),

  () => agent(`${CONTEXT}

You are designing the RANDOM-NOTE (real playing) HARNESS. A reader has already
established what the firmware and the coefficient blob can and cannot express;
its findings are below and are your evidence base.

=== NOTE / BLOB READER ===
${brief('noteblob')}

=== ALLOCATOR / VOICE-TO-CORE READER ===
${brief('alloc')}

The goal: convert "will real playing stutter?" from a fear into a NUMBER,
without needing the device-side recall path that does not exist.

The known hazard this must find: a chord landing entirely on one core was
measured at 9,204 cycles, 70 % over. The voice-to-core map is unforced. Today
every measurement used a FIXED chord with a FIXED wake mask, so this hazard has
never been exercised.

Design a harness that:
- drives note-on/note-off through the REAL allocator (eb_alloc), not a fixed
  wake mask, so voice assignment is the allocator's own
- uses randomised but REPRODUCIBLE patterns (no Math.random on device -- a
  seeded LFSR or a table; the seed must be printable so a bad case can be
  re-run)
- covers the cases that matter: fast repeated notes, held chords of every size
  1..6, overlapping releases, note-stealing, and the pathological
  all-on-one-core distribution
- reports the WORST per-second loop figure and the worst single block, not the
  average -- an average hides exactly the failure we are looking for
- works within what the blob can express (see the reader's findings); if it
  cannot fully, say exactly which cases are unreachable and what would unlock
  them

Be concrete to the level of files, functions, flags and printed output.
State honestly which parts of "real playing" this still does NOT test.

The measurement_gate must be ONE test with TWO named outcomes.`,
    { label: 'design:random-note-harness', phase: 'Design', schema: DESIGN, effort: 'high' }),
])

phase('Critique')

const VERDICT = {
  type: 'object',
  properties: {
    summary: { type: 'string' },
    fatal: { type: 'array', items: { type: 'string' }, description: 'Things that make the design not work as written' },
    optimistic: { type: 'array', items: { type: 'string' }, description: 'Numbers or assumptions that flatter themselves' },
    unread: { type: 'array', items: { type: 'string' }, description: 'Claims made about code or hardware without reading it' },
    missing: { type: 'array', items: { type: 'string' } },
    verdict: { type: 'string', enum: ['SOUND', 'NEEDS_WORK', 'BROKEN'] },
  },
  required: ['summary', 'fatal', 'optimistic', 'unread', 'missing', 'verdict'],
}

const critiques = await parallel([
  () => agent(`${CONTEXT}

ADVERSARIAL REVIEW. Your job is to REFUTE the two-chip link design below, not
to admire it. Default to finding it broken.

=== THE DESIGN ===
${JSON.stringify(linkDesign, null, 1).slice(0, 14000)}

Check specifically, by READING the repo and the ESP-IDF docs yourself rather
than trusting the design:
1. Does the ESP32-S3 actually support what it claims about I2S slave mode and
   shared clocks? Verify against documentation, do not take the design's word.
2. Does the CPU cost land where the design says? Every place the CPU touches
   the received samples counts, including the sum into the voice bus and any
   format conversion.
3. Is the latency arithmetic right, and does it stack correctly with the FX
   pipeline's one-chunk delay and the I2S DMA depth?
4. Power-up ordering, chip B reset, dropped frame: are these actually handled,
   or merely mentioned?
5. Does anything in it assume a measurement taken under conditions that no
   longer hold? Two closures tonight (ring placement, prologue-pipe) turned out
   to be exactly that.
6. Is any number in it a subtraction rather than a measurement?

Be specific. Cite file:line or a documentation URL for each objection.`,
    { label: 'verify:link-adversarial', phase: 'Critique', schema: VERDICT, effort: 'high' }),

  () => agent(`${CONTEXT}

COMPLETENESS CRITIC. Below are two designs and four reader reports for the next
phase of this project. Your job is to find what is MISSING -- not to review
what is present.

=== LINK DESIGN ===
${JSON.stringify(linkDesign, null, 1).slice(0, 8000)}

=== HARNESS DESIGN ===
${JSON.stringify(harnessDesign, null, 1).slice(0, 8000)}

=== HEADROOM LEDGER ===
${brief('headroom')}

Ask and answer:
1. What subsystem does the shipping instrument need that NOBODY has mentioned
   in either design or any reader report? Read ${REPO}/CLAUDE.md and
   ${REPO}/GOAL.md and list every capability the finished product requires,
   then subtract what exists or is designed. (Think: preset storage, front
   panel, patch changes while playing, tuning, MIDI clock/arpeggiator, stereo
   output stage, power-on state, the trunk's bit-exact gates still passing.)
2. Which claim in either design would be most expensive to discover wrong LATE?
3. What measurement could be taken RIGHT NOW, off-board or on one board, that
   would retire the most risk per flash?
4. Is the ORDER right? The proposed order is: link, real-playing harness,
   device recall, MIDI. Argue for or against, using what could invalidate what.
5. What in the repo is now STALE or CONTRADICTORY after tonight's work, and
   would mislead the next session? Be specific with file and line.`,
    { label: 'verify:completeness', phase: 'Critique', schema: VERDICT, effort: 'high' }),
])

return {
  readers: reads.filter(Boolean),
  linkDesign,
  harnessDesign,
  critiques: critiques.filter(Boolean),
}
