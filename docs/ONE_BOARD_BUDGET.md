# ONE-BOARD BUDGET — what fits ONE ESP32-S3 (REFERENCE, written 2026-09-28)

Why this file: END_GOAL was amended 2026-09-23 — ONE board per synth, of ESP32-S3-class power, no chip-to-chip links.
These numbers were produced in a chat that is being retired; they existed nowhere else. Every row carries its label:
MEASURED (silicon or executed code), MODELED (static Xtensa counts banded against silicon anchors, `tools/engineb/cost.py`),
INFERRED (arithmetic on the rows above). Budget: ~10,000 S3 cycles per sample at 48 kHz (240 MHz, both cores);
~7,000 is the comfortable ceiling (bursts, not averages, cause clicks — FINAL_GUIDE "three facts").

## Per-synth verdicts
| engine | cost | fits one S3? | source |
|---|---|---|---|
| JUNO-60 bit-exact voice | ~5,045 cyc/voice (6 v + FX ~30,300) | NO (~3x over) | b44 silicon, docs/engineb/data/b44_classic_silicon.md |
| JUNO-60 fork voice (all savers: WT DCO, half-band VCF, res LUT, control-rate mods, SRAM state) | ~2,600 cyc/voice (6 v ~15,600) | NO (~1.6x) | b43 silicon |
| JUNO fork with PWM dropped (saw + sub, BLEP residual kept) | ~2,050 cyc/voice (6 v ~12,300) | NO (~25 % over) | MODELED from measured shares (pulse block ~14 %, pwm_cv ~4 %) |
| JUNO with static mip wavetables (no residual) | ~400 cyc/voice (6 v ~2,400) | YES — but no longer a faithful JUNO | MODELED |
| One S3 holds | ~3-4 faithful JUNO voices + FX | — | INFERRED |
| JUPITER-8 bit-exact (8 voices + master) | 30.5k x86 instr/sample -> ~53k S3 cyc | NO (~5.3x); one exact voice ~6.4k cyc | jp8/docs/S3_STATUS.md (instruction counts PROVEN, 1.75 cyc/instr INFERRED) |
| TB-303 voice + FX | 3,797 x86 instr/frame -> ~6,645 S3 cyc | YES (~66 %) | tb303/docs/S3_STATUS.md (not listen-certified) |

Consequence for the JUNO under the one-board rule: a faithful 6-voice JUNO does not fit one S3 by dropping features
alone. The options are a cheaper engine graded against the bit-exact port (END_GOAL amendment), fewer voices, or
a more powerful single board (the Pi track, docs/pi/PORT_PI.md, runs the bit-exact engine on one BCM2837).

## Where the JUNO's cost is (measured shares, fork engine)
| part | share | the lever |
|---|---|---|
| Oscillator / DCO | ~40 % (~1,868 cyc/voice even as a wavetable DCO) | mip-mapped wavetable; the PWM pulse block is 165 instr/step (5.3x the saw) because the moving edge needs a per-edge anti-alias residual |
| VCF ladder (4x oversampled) | 12.7 % | half-band FIR / less oversampling |
| slow modulators (LFO, glide, PWM-CV, VCF-CV) | ~13 % | control rate + interpolation |
| VCF resonance nonlinearity | 6 % | LUT |
| the biggest lever of all | — | voice state < 1 KB in internal SRAM (the engine is memory-bound; engine_b thesis) |

## A new wavetable synth ("Hichord clone", user idea 2026-09-19) — module costs (MODELED, state in SRAM)
| module | cyc/sample (nominal) | band |
|---|---|---|
| full JUNO WT DCO (saw + pulse + sub) | 1,868 | 919-5,952 |
| simple wavetable osc (1 mip) | 6 | 4-18 (a musical one with mips + light oversample ~15-40) |
| VCF ladder tick (`eb_vcf_ladder`) | 38 | 25-116 |
| VCA (`eb_vca_hpf`) | 9 | 6-24 |
| ENV x2 (`eb_envgen`) | 42 | 28-124 |
| reverb (`eb_reverb`, SRAM) | 171 | 112-545; cost is set by stage count, not tail length (a long tail only needs PSRAM) |
Verdict (MODELED): 5 wavetable voices ~110-150 cyc each (~550-750) + a long reverb (+1,000-2,000) fit one S3 with a
large margin. Oscillator fidelity (MEASURED, 2.2 kHz note at 48 kHz, aliasing SNR): naive ESP32 saw 12.1 dB, single
table without mips 13.1 dB, mip-mapped wavetable >= 36 dB (the harness floor, = ideal band-limited). The lifted JUNO WT
DCO nulls -36.5 dB against the exact DCO (audibly matched, not bit-exact). Rule: mip-map every table (one band-limited
table per octave); without mips a wavetable aliases almost as badly as the naive oscillator.
Reusable modules live in `engine_b/` (copy them out; never edit the frozen `src/`): `eb_dco.c`, `eb_dco_wt.c`,
`eb_vcf_ladder.h`, `eb_vca_hpf.c`, `eb_envgen.c`, `eb_lfo.h`.
