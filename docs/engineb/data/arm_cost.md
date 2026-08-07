# What the TRUNK costs on an ARM application core — 2026-08-08

**The question:** the user needs a board under $25 CAD, with no SD card, that
runs the BIT-EXACT trunk with 8 voices and full FX. The only ARM number this
project owned was the Daisy's **93,288 cycles/sample on a Cortex-M7**, and
nobody had ever run this engine on a Cortex-A. A board cannot be chosen from
clock speed when the one measurement in hand is 6.4x worse than x86.

## Measured

| | |
|---|---|
| x86 instructions/sample, 8 voices + FX | **30,471** |
| ARM/x86 static instruction ratio, same source at -O2 | **0.77** |
| **ARM instructions/sample** | **≈ 23,500** |

The x86 figure is EXACT and DIFFERENTIAL: callgrind over the real
`juno_gui_render` path with a real factory patch and an eight-note chord,
478,230,247 instructions minus a 166,209,432 baseline that renders nothing,
over 10,240 samples. Setup, recall and warm-up are subtracted, not estimated.

ARM32 needs FEWER instructions than x86-64 here — 0.77 — because VFP is
three-operand with 32 registers while SSE needs explicit moves. That is the
opposite of the intuition that a small core needs more work.

## The cross-check that makes it trustworthy

23,500 instructions against the Daisy's MEASURED 93,288 cycles/sample implies a
Cortex-M7 IPC of **0.25**, which is what an M7 running from flash and SDRAM
does. **The model reproduces the one ARM number we already had.** It was not
fitted to it.

## What that means per core — IPC is ESTIMATED, everything above is not

| core | clock | IPC (est) | cycles/sample | budget/core | verdict |
|---|---|---|---|---|---|
| Cortex-M7, Daisy | 400 MHz | 0.25 (measured) | 93,288 | 9,070 | 10.3x OVER |
| Cortex-A7, single | 1.2 GHz | 0.6 | ~39,000 | 27,210 | **1.4x OVER** |
| Cortex-A53, quad | 1.0 GHz | 0.9 | ~26,000 | 22,675 | 1.15x over ONE core, **FITS on two** |

## The answer

**A single Cortex-A7 at 1.2 GHz does not run this engine.** That rules out the
Luckfox Pico class, which was the only candidate under $25 CAD with onboard
flash and no SD card.

**A quad Cortex-A53 at 1 GHz does**, using two of its four cores — and the
engine already has a two-core split in its design (voices on one, FX on the
other). That is the Pi Zero 2 W.

WHAT IS NOT MEASURED: the IPC of any Cortex-A running this code. Both A-core
rows are estimates, and this project has been wrong about unmeasured
performance repeatedly. The A53 row has ~4x of headroom across four cores
before the conclusion flips; the A7 row does not.
