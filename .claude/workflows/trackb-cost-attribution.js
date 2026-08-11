export const meta = {
  name: 'trackb-cost-attribution',
  description: 'Recalibrate the M7 cost model on the new silicon point and attribute the 93k cyc/sample to modules',
  phases: [
    { title: 'Calibrate', detail: 'recalibrate the model against SILICON 93,288 and E1-E4' },
    { title: 'Attribute', detail: 'per-module cost share, host profile + static ARM analysis' },
    { title: 'Synthesize', detail: 'ranked target list against the 10x requirement' },
  ],
}

const SILICON = `SILICON FACTS from the first full Daisy Seed run, 2026-08-01 (authoritative,
these supersede every MODELED/INFERRED number in the repo):
  SysClk 400 MHz (NOT 480). Budget @48kHz = 8,333 cyc/sample.
  E1 golden corpus 8/8 BIT-EXACT on real Cortex-M7.
  E2: 0 voices(idle) 85,137 | 1v 82,967 | 2v 88,458 | 4v 84,560 | 8v 93,288 cyc/sample
      -> 8 voices = 11.19x OVER budget. Idle floor is 91% of the 8-voice cost.
  E3: 8v D-cache ON 287,075 / OFF 302,258 -> ratio 1.05x.
      WARNING: E3's ABSOLUTE numbers are a 3x discrepancy vs E2 for the same
      nominal workload and are UNRECONCILED. Use the ratio only; investigating
      the discrepancy is in scope.
  E4: sequential AXI 4.98 vs SDRAM 8.79 cyc/access (1.76x);
      scattered AXI 12.02 vs SDRAM 75.34 cyc/access (6.26x).
  Prior x86 MEASURED figure: 14,500 cyc/sample. So the x86->M7 ratio is
  93,288/14,500 = 6.43x. The repo's llvm-mca model was calibrated at 2.15x,
  i.e. it was optimistic by ~3x. Recalibration is the point of this work.
Repo root /home/user/jn60c99. Engine sources in src/. Track B fork native/.
ARM toolchain arm-none-eabi-* IS installed. libDaisy at /home/user/libDaisy.
Label every number SILICON / MEASURED / MODELED / STATIC / INFERRED. Never
present a MODELED number as measured. Return raw data, not prose.`

phase('Calibrate')

const CAL = {
  type: 'object',
  required: ['findings', 'ratio_notes'],
  properties: {
    findings: { type: 'array', items: { type: 'object',
      required: ['claim', 'label', 'evidence'],
      properties: { claim: {type:'string'}, label: {type:'string'}, evidence: {type:'string'} } } },
    ratio_notes: { type: 'string' },
  },
}

const calib = await parallel([
  () => agent(`${SILICON}

TASK: Explain the x86->M7 ratio of 6.43x from first principles, and say what the
old 2.15x llvm-mca calibration got wrong. Build the engine's hot objects for
Cortex-M7 (arm-none-eabi-gcc -mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard -O2
-ffp-contract=off) and for x86-64, and compare instruction mix, FP op counts,
load/store counts, and branch counts for voice_render.o and master_render.o.
State how much of 6.43x is explained by instruction count, how much by FP
latency/throughput, how much must be memory stalls. Be quantitative.`,
    {label:'calib:isa-ratio', phase:'Calibrate', schema: CAL}),

  () => agent(`${SILICON}

TASK: Reconcile E3 with E2, or prove the discrepancy is a harness artefact.
Read daisy/juno60_daisy.cpp measure_cost() and measure_dcache() line by line.
They both claim "8 voices" at E2_RATE. E2 reports 93,288 cyc/sample, E3 reports
287,075. Find every difference in how they are set up and timed: warmup length,
N, block loop bounds, what report() divides by, cache state on entry, whether
notes are actually sounding in both, DWT wraparound at 32 bits, anything else.
A 3x error in a measurement tool is itself a defect to fix. Give the most likely
cause with the code evidence, and the exact patch that would settle it.`,
    {label:'calib:e2-e3', phase:'Calibrate', schema: CAL}),

  () => agent(`${SILICON}

TASK: The idle floor is 85,137 of 93,288 cyc/sample - 91%. Establish WHY from
the source. In src/voice_render.c and src/master_render.c, determine what work
is unconditional per sample per voice regardless of whether a note sounds:
count the arithmetic on the always-executed path, identify every branch that
could skip work but does not, and quantify how much of the per-voice cost is
free-running oscillator/LFO/envelope/filter state update. Cross-check against
the repo's own claim that 74.8% of voice arithmetic feeds next-sample state.
This number decides whether Track B has any headroom at all.`,
    {label:'calib:idle-floor', phase:'Calibrate', schema: CAL}),
])

log('calibration done; attributing cost per module')

phase('Attribute')

const MODULES = [
  {key:'M1a_conditioner_gate', lines:'654-693'},
  {key:'M1b_noise_svf',        lines:'1129-1149'},
  {key:'M2_dco',               lines:'964-1021'},
  {key:'M3_dco2',              lines:'1022-1075'},
  {key:'M4_vcf',               lines:'1516-1640'},
  {key:'M5_pwm',               lines:'1076-1128'},
  {key:'M6_mix',               lines:'1150-1229'},
  {key:'M7_env',               lines:'1298-1400'},
  {key:'M8_vca_out',           lines:'1718-1830'},
]

const ATTR = {
  type:'object',
  required:['module','cost_share_pct','label','instr_count','fp_ops','loads','stores','transcendentals','notes'],
  properties:{
    module:{type:'string'}, cost_share_pct:{type:'number'}, label:{type:'string'},
    instr_count:{type:'number'}, fp_ops:{type:'number'}, loads:{type:'number'},
    stores:{type:'number'}, transcendentals:{type:'string'},
    reduction_ideas:{type:'array', items:{type:'string'}},
    notes:{type:'string'},
  },
}

const attributed = await pipeline(MODULES,
  m => agent(`${SILICON}

TASK: Attribute cost for module ${m.key}, src/voice_render.c lines ${m.lines}.
Work out its share of the per-voice per-sample cost on Cortex-M7. Method:
compile src/voice_render.c for M7 at -O2 -ffp-contract=off, map the source range
to its instructions (use -g and objdump line info, or a targeted extraction),
count instructions, FP ops, loads, stores, and any calls to expf/fmodf/powf.
Then give its share of the whole voice render. State the method you used and its
error bars honestly - if you cannot attribute precisely, say so and give bounds.
Also list concrete arithmetic reductions that would preserve SONIC character but
not bit-exactness (this is Track B: sonic identity, NOT bit-exactness). For each
idea estimate the saving as a fraction of this module.`,
    {label:`attr:${m.key}`, phase:'Attribute', schema: ATTR}),
)

phase('Synthesize')

const plan = await agent(`${SILICON}

You are given per-module cost attribution and calibration findings.

CALIBRATION:
${JSON.stringify(calib.filter(Boolean), null, 1).slice(0, 12000)}

ATTRIBUTION:
${JSON.stringify(attributed.filter(Boolean), null, 1).slice(0, 20000)}

TASK: Produce the Track B target list. The requirement is brutal: 8 voices + FX
must come from 93,288 cyc/sample to under 8,333 - a factor of 11.19. Answer:
 1. Rank modules by (cost share) x (achievable reduction) - i.e. where the
    cycles actually are, not where the code is easiest.
 2. Give the arithmetic best case: if EVERY listed reduction landed perfectly,
    what total factor do we get? State it plainly even if it is far below 11.19.
 3. If the best case is below 11.19x, say so unambiguously and enumerate what
    else would have to give: voice count, FX, sample rate, block-rate control
    updates, a different part. Quantify each.
 4. Name the single highest-value experiment to run first and why.
Do not be optimistic. An honest "this cannot reach 11x, here is what can" is a
far more valuable answer than a hopeful plan. Return markdown.`,
  {label:'synth:target-list', phase:'Synthesize'})

return { calibration: calib.filter(Boolean), attribution: attributed.filter(Boolean), plan }
