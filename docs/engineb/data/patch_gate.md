# O4 — the compact patch drives ENGINE B, and what on-device recall costs

Date 2026-08-04 (Opus 5).

## The result

**`patch_roundtrip.py --module standalone`: 64/64 factory patches BIT-EXACT,
from 127 compact bytes each.**

For every patch the gate takes patch 0's whole record as a template, copies in
only the compact bytes, and renders BOTH banks through ENGINE B's standalone
chain, requiring identical samples. Teeth in the same configuration: the
documented 118-byte set FAILS on 7 patches (the arpeggiator patches, −3.3 to
+2.7 dB), so the gate is demonstrably sensitive to a dropped parameter.

**This is not the question the gate asked before.** It previously rendered
through the PORT. Engine B reads its own subset of cells — through
`eb_render_coefs_build` and `eb_master_coefs_build` — so:

* a parameter the PORT consumes but engine B ignores would pass the old form of
  this gate while still being absent from the engine, and
* a parameter ENGINE B needs that the format drops would fail here and nowhere
  else.

Both directions now have a gate. The bytes engine B adds over the documented
set are 112, 282/283, 290/291, 298/299, 466/467.

## What this does NOT claim

The recall MATH is still the port's. The chain proven here is

    127 compact bytes -> the port's record -> the PORT's recall -> engine B's
    coefficient builders -> engine B's render

so engine B owns everything from the coefficients onward, and the parameter
format is proven sufficient for it. **Engine B does not yet derive coefficients
without the port's state block**, and no claim here says otherwise.

## ★ What on-device recall would cost, MEASURED

The obstacle to engine B doing its own recall is not the arithmetic — the port's
recall is already portable C99 and bit-exact — it is that the recall writes at
absolute offsets up to 11,022,348 in a 12 MB block no microcontroller has.

MEASURED, the coefficient builders read:

| | count | span |
|---|---|---|
| distinct per-voice cell offsets | 300 (×8 voices) | 176 … 10,496 |
| shared/master cell offsets | 563 | 10,512 … 11,022,348 |

* eight voice blocks: **82.1 KB**
* the shared set touches **17 distinct 4 KB pages: 68 KB**

**Total ≈ 150 KB — inside docs/engineb/SCOPE.md's 200 KB internal budget.** The
12 MB span is almost entirely the FX delay lines, which are already
caller-owned (`eb_master_rings`, 6.10 MB) and separate from this.

So on-device recall is a PAGING problem, not a rewrite: `JF`/`JI` in
`src/juno_engine.h` are macros over `(state, offset)`, so a build that
substitutes a translating accessor would let the SAME recall source run against
a compact arena. ### The size of that job, MEASURED rather than guessed

| recall TU | `JF`/`JI` | `mem*()` | raw ptr |
|---|---|---|---|
| `juno_init.c` | 2,296 | 0 | 0 |
| `juno_prepare.c` | 127 | 1 | 0 |
| `delay_recall.c` | 44 | 11 | 13 |
| `juno_apply.c` | 32 | 1 | 0 |
| `effect_modes.c` | 18 | 1 | 2 |
| `juno_note.c` | 16 | 1 | 0 |
| `chorus_recall.c` | 11 | 2 | 0 |
| `reverb_recall.c` | 8 | 1 | 1 |
| `finefx_recall.c` | 3 | 1 | 0 |
| **`chorus_init.c`** | **0** | **0** | **2,966** |
| TOTAL | 2,555 | 20 | 2,981 |

A translating accessor covers the **2,555** macro sites for free. Of the 3,001
that it does not, **2,966 are in `chorus_init.c` alone and every one of them is
the SAME shape** — `*(_DWORD *)(a1 + N)`, 2,966 of 2,966, with no `memcpy` or
`memset` anywhere in that file. That is one mechanical rewrite to `JI(a1, N)`,
not 2,966 decisions.

**So the real manual surface is about 35 sites**, concentrated in
`delay_recall.c` (11 `mem*` + 13 raw). That is a bounded, one-session job — and
`src/` is frozen, so it must be done as an engine B FORK of those TUs with its
own gate: the coefficients it produces must be identical, cell for cell, to the
ones the port's recall produces. Recorded with the number so the next session
starts from a size rather than from a phrase.
