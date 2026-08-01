# Track B Target List — honest ceiling analysis

## 0. The one fact that reorders everything

E2's "0 voices = 85,137" does **not** mean the engine is 91% fixed overhead. It means **all 8 voices render unconditionally regardless of notes held** (consistent with the repo's own MEASURED "idle-voice-skip = 0% at full polyphony"). So the idle floor *is* voice code. Voice-side modules are therefore the right target — but "fewer voices" remains dead because the loop runs them anyway until it is restructured.

Second fact: **E2's absolute numbers are a DWT CYCCNT 32-bit wrap** (MEASURED-arithmetic). E2's rows are low by 194,783 cyc/sample; true 8v ≈ 288,071, reconciling with E3's 287,075 (0.35% apart). **Every number below is quoted in E2-frame (93,288) because the reduction task was set in that frame, but the real overrun may be ~34.5×, not 11.19×.** This must be resolved before any target is trusted — see §4.

---

## 1. Ranking: cost share × achievable reduction

Ranked by **cycles removable**, not code size. Shares are of the SILICON 93,288 cyc/sample (E2-frame).

| # | Target | Cycles held | Achievable reduction | **Cycles removable** | Label | Bit-exact? |
|---|---|---|---|---|---|---|
| 1 | **Instruction fetch / code placement** (hot .text 32.8 KB vs 16 KB I-cache, QSPI XIP) | 50,742 (54%) | 80–100% if the I-fetch hypothesis holds; **0% if it does not** | **~45,000** | INFERRED | **Yes** (linker only) |
| 2 | **FP dependency stalls** (f32 lat 4, VMRS, load-use) | 25,300 (27%) | 40–60% via scheduling, FMA, VMRS elimination, s/w pipelining | **~12,000** | MODELED | No (FMA), yes (scheduling) |
| 3 | **Control-rate demotion of envelopes/smoothers** (M2 range 964–1021 + M1a 654–658 + every recall-constant smoother) | ~8–12% of issue work | 80% of those blocks at 8× decimation | **~2,500–3,500** | MODELED | No |
| 4 | **Share the noise SVF across voices** (M1b) | ~1,400 (1.5%) | 87% (1 instance instead of 8) | **~1,200** | MODELED | No — **and 15/18 assignments are BLIND to the current scenario set. Blocked.** |
| 5 | **Constant folding + dead scratch-store removal** (M1a dup stores, M1b const products, 188 NOT-CARRIED cells) | ~4–6% | 50% | **~2,000** | MODELED/STATIC | Yes (proven-dead cells only) |
| 6 | **State-layout / register caching** (JF(a1,off) reloads; 1072 memory insns/voice) | inside terms 1&2 | 25% of voice loads | **~1,500** | MODELED | Yes in principle |
| 7 | **Noise-off / silent-voice gating** | patch-dependent | 100% when off | 0 on worst-case patch | MODELED | Yes |
| 8 | **vdiv → reciprocal-estimate** (voice_render:694, ~14 cyc non-pipelined) | ~80/sample | 70% | **~60** | MODELED | No |

Everything from #3 down is, collectively, worth less than half of #1 alone.

---

## 2. Arithmetic best case — every reduction landing perfectly

Stacked in the only order that is physically meaningful (stalls first, then the instruction stream they were stalling on):

| Step | Result (cyc/sample) | Factor so far |
|---|---|---|
| SILICON 8v + FX | **93,288** | 1.00× |
| − all fetch/memory stalls (perfect ITCM/AXI placement) | 42,546 | 2.19× |
| − **all** FP dependency stalls (perfect scheduling — physically unreachable) | 17,200 (width-2 issue floor) | 5.42× |
| − 35% of the instruction stream (folding, dead stores, control-rate demotion, shared noise SVF, all of §1 #3–#8 landing at their optimistic ends) | **11,180** | **8.34×** |

**Best case = 8.34×. Required = 11.19×. The best case misses by 1.34×.**

And that 8.34× assumes: the I-fetch hypothesis is correct *and* fully fixable; a perfectly scheduled in-order core with **zero** dependency stalls; and a 35% instruction cut that no measured lever in this repo has ever approached (best measured single lever: triangle LUT ~11% STATIC; block hoisting 2.8% MEASURED, ceiling 17.4%).

A realistic case — I-fetch fixed (90%), half the FP stalls removed, 20% instruction cut — lands at **~24,000 cyc/sample = 3.9×, i.e. still 2.9× over budget.**

---

## 3. Unambiguous statement, and what else must give

> **Track B as scoped — 8 voices + all FX at 48 kHz on this Daisy — cannot reach 11.19× by optimizing the DSP. The arithmetic best case is 8.34×, and the honest expected case is ~3.9×. The instruction stream must shrink below ~16,600 instr/sample from today's 34,387 even for a flawless port to fit, and that is a rewrite, not an optimization.**

Levers outside the code, quantified against the **realistic** 24,000 cyc/sample post-optimization figure (budget 8,333):

| Lever | Factor gained | Notes / cost |
|---|---|---|
| **Restructure the render loop so idle voices are genuinely skipped**, then run 4 voices | up to 2.0× | Currently 0% because all 8 render unconditionally. This is the largest untapped structural lever and it is **bit-exact**. Gets 24,000 → 12,000. Still 1.44× over. |
| **Sample rate 48 k → 32 k** | 1.50× | Budget becomes 12,500 cyc/sample. Combined with 4 voices: **fits, with ~4% margin.** Cost: resampling the whole coefficient set (rate-armed cells already exist), and the port's rate-dependent laws are PROVEN at 44.1/48/88.2/96/192k only — 32 k is a new derivation. |
| **Sample rate 48 k → 44.1 k** | 1.09× | Nearly free; the golden corpus is already 44.1 k. Take it. |
| **Drop FX (reverb+delay), keep chorus** | ~1.3–1.5× | master_render.o is 18,368 B of the 32.8 KB hot text — dropping it is also the single biggest I-cache-pressure relief. Sonically the JUNO-60's identity is chorus; delay/reverb are JU-06A additions. **Best sonic-cost-per-cycle trade available.** |
| **Block-rate control updates** (all recall-constant smoothers, envelopes, LFO at 1/8 rate) | 1.15–1.25× | Already counted inside §2 step 3; do not double-count. |
| **Different part** | — | Teensy 4.1 @ 816 MHz with tightly-coupled RAM: budget 18,503 cyc/sample @44.1k. Against the realistic 24,000-at-400 MHz figure, scaled to 816 MHz that workload costs ~11,700 cyc/sample-equivalent → **fits with 36% margin, at 8 voices.** The i.MX RT1062 has 512 KB TCM and no QSPI-XIP hot-loop problem, which is exactly the 54% term. **If the I-fetch hypothesis is confirmed, the Teensy is the rational answer and Daisy is the wrong board for this engine.** |

**The combination that actually closes:** 44.1 kHz + real idle-voice skip + drop delay/reverb + the §2 realistic optimization set → fits 8 voices on Daisy with chorus only. Or: keep all FX and 8 voices, move to Teensy 4.1.

---

## 4. The single highest-value experiment

**Re-run E2 with (a) a 64-bit cycle accumulator, (b) `voice_render` + `master_render` linked into ITCM, and (c) the I-cache toggled — three points, one board session.**

Why this and nothing else first:

1. **It decides 54% of the budget.** Every other item on the list combined is worth less than the residual this test resolves. Optimizing FP arithmetic while 54% of cycles are instruction fetch is optimizing the wrong 46%.
2. **It repairs the measurement.** The 64-bit accumulator removes the CYCCNT wrap that makes E2 and E3 differ by 3.08×. Until that is fixed **every ratio in this document rests on a number that is arithmetically known to be wrong.** No target list should be executed against a broken counter.
3. **It is cheap and bit-exact.** A linker-script section attribute and a counter widening. No engine change, no sonic risk, no gate to re-prove. Hours, not days.
4. **It is decisive either way.** If ITCM removes ~45,000 cyc/sample → the residual is QSPI XIP, the fix is placement, and Track B's whole premise changes from "remove math" to "place code". If ITCM barely moves it → the 42,546 pipeline model is wrong by 2.19×, the model must be rebuilt before any module is touched, and P2 should go straight to the part-change decision.

**Second experiment, only after the first:** differential SILICON measurement — stub one module at a time and re-measure. Every per-module share in the attribution above is MODELED or STATIC. **There is still no measured per-module silicon number, and none of §1 #2–#8 should be implemented until there is.**

---

## 5. Standing blockers

- **M1b (noise SVF) is behind a blind gate.** 15 of 18 assignments unobservable by the current scenario set (canary, MEASURED). No rewrite permitted until scenarios reach it.
- **FMA is forbidden in `src/`** and permitted only in `native/`. Any cycle count that assumes `vfma.f32` is a Track-B-only number and must never be quoted as a `src/` figure.
- **`src/` stays frozen and bit-exact.** Every reduction in §1 except #1, #5, #6 breaks bit-exactness and belongs to the sonic-identity claim, not the bit-exact one. The two must never be conflated in a report.