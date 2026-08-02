# RESUME — 2026-08-02, engine B under construction

## Live workflow runs (resume with resumeFromRunId; completed agents replay free)

    scripts in /tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad/
      wf_found.js  -> wf_a09fe521-882   foundation completion (seal phase running)
      wf_fx.js     -> wf_2f043aa9-3d2   chorus/delay/reverb: extract + implement
      wf_voice.js  -> wf_23c72bdd-1ca   voice modules: VCF ladder, DCO, CV, VCA
    Also under .../workflows/scripts/ . If the container is gone, rebuild from
    docs/engineb/SCOPE.md + docs/trackb/{CONSTRAINTS,ACCURACY_STANDARD,MODULE_ORDER}.md

## State

**The port (`src/`) is sealed and bit-exact.** It is now the ORACLE, not the
product. It is 80x too slow on hardware.

**Engine B: 3 modules done, all EXACT, none spending error budget.**

| module | proof | S3 cost |
|---|---|---|
| noise LFSR | bit-identical over 200,000 oracle samples | 24 instr |
| triangle | bit-identical over ALL 2^32 float inputs | 73 instr |
| envelopes | 26/26 scenarios residual EXACTLY 0 | **1,188 cyc/sample = 34% of budget** |

**Memory: the architecture works.** eb_voice 204 B (port: 10,512), whole engine
138,748 B (port: 12 MB). Under 1 KB/voice and under 200 KB total, both met.

**Target: ESP32-S3, one core, 240 MHz, 48 kHz, 3,500 cyc/sample** with 30%
headroom against the 5,000 hard limit.

## The open question

Envelopes alone are 34%. ~2,300 cyc/sample remain for the DCO, VCF, mixers and
ALL FX. The FX are the largest piece by code volume (master_render.c is 4,774
instructions against the voice path's 3,491) and are 0% written. **Whether it
fits is genuinely unknown** and the two running workflows are measuring it.

## Foundation, and what it guarantees

* `tools/engineb/null_b.py` — engine B vs oracle, --module stubbing, 30
  scenarios (17 idle-prefix). Teeth proven: 1 ULP = -130.7 dB passes, 3e-5 =
  -90.4 dB fails, lockstep break = +5.5 dB fails in 17.
* `tools/engineb/cost.py` — host + Cortex-M7 + ESP32-S3, calibrated to silicon.
* `tools/engineb/plugin_check.py` — the AUTHORITATIVE comparison, against the
  plugin binary rather than the port.
* `tools/trackb/canary.py` — DUAL-PROBE. BLIND only if neither shape moves a line.
* `tools/trackb/verify_labels.py` — a label must match the cells it touches.
* `tools/trackb/deadstore.py` — a store is dead only if a mutation is
  bit-identical over 30 scenarios + 384 bank comparisons + fuzz.

## Traps found the hard way — do not re-learn these

1. **A 32-bit cycle counter is a 10.7-second ruler.** Every hardware number this
   project had was wrong by 7x until the wrap was caught. The real Daisy cost is
   669,682 cyc/sample, not 93,288.
2. **A multiplicative probe cannot move a literal zero, a sign test or a
   saturating consumer.** It under-reported observability and set the entire work
   order. Fixed in one tool and left in another, where it came back.
3. **Six of nine module labels were wrong**, three swapped between subsystems.
   "M2 DCO" was the ENV1 ADSR; the real DCO was called "VCA/output".
4. **eb_triangle's obvious fmodf replacement** was mathematically identical and
   disagreed on 8,388,608 of 2^32 inputs through rounding. Caught only by an
   exhaustive test.
5. **eb_env_atrest looked like a free exact skip** and holds for 9 of 162
   coefficient sets. Rest-stability must be decided from the coefficients at
   recall, not from the state each sample.
6. **The DCO's negative phase wrap sits 0.0003 from firing.** It is not dead code
   and MUST be implemented; a scenario gate cannot protect a margin that thin.

## Next, in order

1. Read the FX verdict — it decides whether PSRAM is needed and whether the
   budget closes.
2. Read the voice budget roll-up.
3. Whatever is left of the voice path.
4. **Get engine B's hot loop onto an actual ESP32-S3 EARLY.** The single largest
   process error in this project was measuring on the target too late.
