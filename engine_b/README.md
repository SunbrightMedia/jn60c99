# engine_b — THE SKELETON

Engine B is a new, fast engine that sounds the same as the sealed port in `src/`.
`src/` does not change; it is the ORACLE. Target and budgets:
`docs/engineb/SCOPE.md`. Accuracy standard: `docs/trackb/ACCURACY_STANDARD.md`.
Comparison discipline: `docs/trackb/THREE_WAY_GATE.md`.

## What exists at this commit

| file | what it is |
|---|---|
| `eb_types.h` | `eb_voice`, `eb_engine`, `eb_params`, `eb_fx`, and the budget `_Static_assert`s |
| `eb_freerun.h` | **the free-run contract** — `step` + O(1) `advance(n)` for every free-running quantity |
| `noise_lfsr.h` | the shared noise LFSR, PROVEN bit-identical over 200,000 oracle samples |
| `eb_patch.h/.c` | the compact preset format, **127 bytes** (MEASURED — see below) |
| `eb_modules.h` | one flag per module; all zero but NOISE |
| `eb_engine.h/.c` | lifecycle, the allocator's bookkeeping, and one stub per module |
| `shim/skeleton/` | a verbatim fork of `src/juno_driver.c` that runs the skeleton in the real audio path |
| `tests/` | `make -C engine_b/tests` — sizes, the free-run contract, the parameter path |

## MEASURED, this commit

```
eb_env                    16 B
eb_voice                 204 B    budget 1024 B    (the port: 10,512 B, 51.5x)
eb_voice x 8            1632 B    budget 8192 B
eb_params                 59 B
eb_fx, control only       52 B
eb_fx, delay lines    136960 B    compile-time budget, placeholders
eb_engine (total)     138748 B    budget 204800 B
```

One voice's per-sample hot state is the **first 112 bytes** of `eb_voice` — four
32-byte cache lines, contiguous. The port's is 620 cells scattered over 10,512
bytes, each on its own 16-byte boundary, which is why it costs 669,682 cycles a
sample on a Daisy Seed.

```
tools/engineb/null_b.py --module skeleton   30/30 scenarios EXACTLY 0
engine_b/tests                              BUDGET / FREE-RUN CONTRACT /
                                            PARAMETER PATH all PASS
tools/engineb/patch_roundtrip.py --teeth    64/64 patches bit-exact
```

## Be clear about what the zero is worth

It proves the skeleton is compiled into the real audio path, is initialised, runs
on **every** rendered sample of every scenario — including the idle prefixes —
and perturbs the output by exactly 0. It says **nothing** about engine B's DSP,
because engine B has no DSP: `eb_engine_process()` returns `EB_INCOMPLETE` and
the port's sample is the one returned. It is the baseline the first real module
is measured against.

The hand-over line is not dead code, and that was checked rather than assumed:
compiling the shim with `-DEB_SKELETON_FORCE_HANDOVER=1` makes engine B claim the
output and the null then FAILS in **25 of 25** scenarios at 0.0 dB rel (engine B
computes silence). The gate can see the moment engine B takes over.

## The three rules this skeleton is built around

1. **Plain structs and locals, never a flat array with offset macros.** The
   port's fatal flaw is that it never keeps anything in a register.
2. **Skip the AUDIO work of a silent voice, never its STATE ADVANCE.** Every
   free-running quantity exposes both `step` and an O(1) `advance(n)`, and
   `advance(n) == n steps` EXACTLY is a unit test with a negative control
   (`tests/test_freerun.c`). MEASURED: one single sample of idling changes every
   sample of the note that follows.
3. **No module before its gate.** `eb_modules.h` holds one flag per module and
   `eb_engine_process()` structurally refuses the output while any is zero, so a
   module cannot be forgotten and no null run can score a green on an unfinished
   engine.

## A finding this work produced

The 118-byte compact preset format is **insufficient**: gated at the OUTPUT it
reproduces only **57 of 64** factory patches, because it carries none of the
arpeggiator parameters. Engine B uses **127 bytes** and reproduces 64/64
bit-exactly. Full write-up and the two further bytes it also drops:
`docs/engineb/COMPACT_FORMAT_FINDING.md`.

## Next

Modules, in the measured order, each with its own `shim/<name>/` and its own null
run. `tests/test_patch118.c` prints the 18 parameters whose blob position engine B
has **not** derived (never guessed) — the FX families are most of them, and they
are the parameter work the FX modules will need.
