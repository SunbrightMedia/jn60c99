# ENGINE B — SCOPE AND TARGET (user-set, 2026-08-02)

> "Please start on engine B. SCOPE AND TARGET: ESP32-S3, with room to spare"

## The budget

The ESP32-S3 runs at 240 MHz. At 48 kHz this gives 5,000 cycles for each sample.
"Room to spare" makes the target tighter:

| item | cycles for each sample |
|---|---|
| hard limit, ESP32-S3, one core | 5,000 |
| **engine B target** | **3,500** |
| headroom | 30% |

The target is for **one core**. The second core is a reserve. It is not part of
the budget.

## The division of the budget

This is a first plan. Measurement replaces it.

| part | cycles | note |
|---|---|---|
| 8 voices | 2,000 | 250 for each voice |
| chorus | 400 | the signature effect. Do not make it worse. |
| delay | 300 | |
| reverb | 500 | |
| control rate work | 200 | envelopes, LFO, smoothers |
| headroom | 100 | |
| **total** | **3,500** | |

## Memory

| item | limit |
|---|---|
| hot state, all voices | < 8 KB |
| total internal RAM | < 200 KB |
| FX delay lines | a compile-time budget, can move to PSRAM |

The port uses 10,512 bytes for each voice. Engine B must use less than 1 KB for
each voice. This is the change that makes engine B possible.

## Rules for the code

- Plain C99. No assembly. No processor-specific commands.
- No assumption about cache size, issue width or memory speed.
- One core. The audio must not need two cores.
- The same code must compile for the ESP32-S3, the Daisy Seed and the host.

## The order of the work

1. **Gates first.** No module gets written before its gate can see it.
2. **Idle-prefix scenarios.** These do not exist. Engine B cannot be validated
   without them, because free-running state changes the sound.
3. **The skeleton and the harness.** Data structures, the null comparison
   against the oracle, and the cycle counter.
4. **Modules, in the measured order**, each with its own gate.
5. **Silicon measurement, early.** Not at the end.
