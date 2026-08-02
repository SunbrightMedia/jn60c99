# Engine B's cost, with the harness subtracted

Date 2026-08-02. Executed instructions, MEASURED on the host with callgrind.
4,000 samples, 8 voices sounding, patch 20 (chorus + delay + reverb), 48 kHz,
all thirteen modules in the build.

## The measurement

| | instr/sample | share |
|---|---|---|
| `juno_voice_render` self — the shim marshalling | 27,225 | 54.0 % |
| **engine B's own functions** | **17,943** | 35.6 % |
| `juno_master_render` self | 1,701 | 3.4 % |
| `juno_flush_denormals` | 1,232 | 2.4 % |
| `juno_driver_render_voices` | 312 | 0.6 % |
| **total through the harness** | **50,413** | 100 % |

Inside engine B's 17,943, two functions are **not DSP**:

| | instr/sample |
|---|---|
| `eb_vcf_hist_set` | 1,536 |
| `eb_vcf_hist_get` | 1,536 |

They exist only so the ladder can keep its state in the port's memory cells and
inherit the port's lifecycle. The shipped engine has no such call.

**So engine B's DSP is 17,943 − 3,072 = 14,871 instructions per sample.**
MEASURED, on the host, with real signals and a real patch.

## What that means

The engine measured through the harness is **50,413** instructions per sample.
Engine B's actual DSP is **14,871**. The difference — about **35,500**, or 70 %
— is glue that exists so one module can be substituted at a time, and it will
not be in the shipped engine.

**Every cost figure this project has quoted for engine B before today was
inflated by that glue.**

The standalone engine will add some plumbing of its own — voice allocation, the
free-run advance, patch recall — so 14,871 is a FLOOR, not the finished number.
It is the first honest estimate of the right order.

## Against the target

The ESP32-S3 budget is 3,500 cycles per sample for the whole engine at 48 kHz,
8 voices, all FX.

On an in-order core running from internal RAM, one instruction is roughly one
cycle, so **14,871 instructions per sample is about 4.2× the budget**. That
comparison is **MODELED**, not measured: no engine B code has ever run on an
ESP32, and the host is a different machine in every way that matters.

What is MEASURED is the ratio between engine B and the harness, and that the
engine is far smaller than every previous figure implied.

## What is NOT yet done, and why the standalone gate is still open

`eb_engine_render()` does not exist as working code. `eb_engine.c` is a skeleton:
every DSP call inside it is a stub returning 0 or passing its input through.
Wiring all thirteen modules into it, with patch recall and voice allocation on
engine B's own state, is a substantial build and is the next piece of work.

Until it exists there is nothing to gate, so the standalone gate named in
`STANDALONE.md` is still open. The number above was obtained by subtraction from
the real engine rather than by waiting for it.

`tools/engineb/standalone_cost.c` is a direct-call benchmark written toward that
gate. It builds and runs, and it currently **REFUSES TO REPORT**: its placeholder
coefficients leave the chain silent, and several modules skip work on a zero
signal — the DCO's level gates and its saturator shortcut are the obvious ones —
so a silent run would report a cheaper engine than the one that ships. It needs
driving from a real recalled patch. The guard is deliberate: a benchmark that
quietly measures silence is exactly the class of fault this project keeps
finding.
