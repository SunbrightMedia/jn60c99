# PLAN A — the CLASSIC JUNO on ONE ESP32-S3, as accurate as the chip allows (LIVING, 2026-10-17)

The user's goal (2026-10-17): the first small synth on the fabbed boards (motherboard + Headphone_Dac), a classic
JUNO-60 panel, 6 voices, one S3, "sounding as ACCURATE as possible", and NO pops or clicks under any circumstance.
Method: start from the bit-exact fork and replace one part at a time; each replacement is graded by a null against
the bit-exact port on all 64 factory patches, and kept only if the budget needs it.

## 1. The budget (44.1 kHz, 240 MHz, two cores)
480,000,000 / 44,100 = **10,884 cycles per sample** (arithmetic). The old "~7,000 comfortable ceiling"
(ONE_BOARD_BUDGET.md) is a RULE OF THUMB from a retired chat (~70 % of 10,000 at 48 kHz): no derivation exists.
Plan A replaces it with the measured rule of section 3.

## 2. Does the classic fit? (sources: docs/engineb/data/b44_classic_silicon.md, ONE_BOARD_BUDGET.md)
| item | cycles / sample | label |
|---|---|---|
| fork classic voice (EB_DCO_WT + CR levers + EB_CLASSIC), 6 voices | ~15,300 (~2,550 / voice) | MEASURED b44 |
| of which the WT DCO (PWM edge residual = 5.3x the saw) | ~1,868 / voice | MEASURED share |
| classic master: chorus | ~620-670 | MEASURED b44 |
| classic master: in / out / delay / reverb collapsed | ~260 | MEASURED b44 |
| **6 voices with a mip-table DCO built from the exact DCO (~60 / voice)** | **~4,500** | MODELED |
| **total with full-rate chorus** | **~5,400 = ~50 % of 10,884** | MODELED |
Half-rate FX is NOT needed for the fit (the classic master is ~900 in all). The mip-table DCO is the one change
that makes 6 voices fit. Open: its accuracy (the earlier WT DCO nulled -36.5 dB vs the exact DCO; the target is
set BEFORE the run, proposed -60 dB) and the two-core split (FINAL_GUIDE: a wrong split costs ~1,860 cycles).
The headroom left (~5,000) buys accuracy back, in this order: VCF 4x kept, modulators at full rate, the DCO's
edge residual on the PWM only, ... each one measured.

## 3. No clicks, by design and by measurement (the user's rule; agreed 2026-10-17)
1. **Constant cost by design.** All 6 voices always run (silent ones too); control-rate and patch-change work is
   spread evenly over blocks; every engine table and voice state in internal SRAM. Then the measured maximum is the
   true maximum, not a lucky sample.
2. **Measure the distance to a click directly.** The firmware logs the closest call: the lowest fill of the I2S
   DMA buffer (ms of audio left), plus the worst block's cycles (CCOUNT), under a scripted stress run: 6 notes in
   one block, patch changes every block, a MIDI flood, pot sweeps, for >= 10 minutes. underruns must stay 0.
3. **The margin comes from data.** margin = 2 x the measured jitter (worst block - typical block of the constant-
   cost engine). The rest of the chip is spent on accuracy (section 2). A test cannot prove "never": the small
   measured margin plus the DMA buffer (it absorbs one slow block) is what covers the unseen case.

## 4. Next session (in order)
1. The timing instrumentation of section 3 in the fork firmware (closest-call log, CCOUNT worst block, stress script).
2. The mip-table DCO built from the exact DCO's output; its null vs the bit-exact DCO and vs the port, 64 patches.
3. 6 classic voices + chorus on the board, split over two cores; the section-3 stress run; record the margin.
4. Spend the measured headroom on accuracy, one lever at a time, each graded by the null.
JUNO LITE (esp32s3/junolite/) stays a hardware test only (hand-written, not the product).
