# b23 — O6/D3: the global voice index, and a silent defect fixed

First piece of O6. Chosen first because it is the only one of D1-D4 that needs
no second board, and because it is a CORRECTNESS defect rather than a wiring
job.

## 1. The defect

`juno_apply_condition` and `juno_apply_unison_spread` both index PER-VOICE
DISTINCT tables -- three CONDITION scalars and the UNISON spread -- by the
LOCAL slot 0..7:

    JF(state, 5520u + b) = L * COND_TUNE_SCAL[v];   /* v is the LOCAL slot */

On one instrument the local slot IS the global voice, so this is right. On the
shipping two-chip layout (END_GOAL 2: EXACTLY two ESP32-S3s, six voices) chip B
owns GLOBAL voices 3..5 in its LOCAL slots 0..2 -- and would be dealt global
0..2's scatter. **Both chips would carry the same three analog identities.**

Measured, before any fix, by the gate below:

    slots where chip B deals EXACTLY chip A's scatter: 3 of 3

### It is SILENT, which is why it needed a gate rather than a test run

Nothing crashes. No block is missed. Every coefficient CRC still matches the
host answer key, because each chip is internally self-consistent. The only
symptom is a chord three voices wide instead of six -- and this project may
never validate by ear (THE ONE RULE), so an ear was never going to find it.

## 2. The gate, seen to fail first

`tools/engineb/d3_voiceindex_gate.c`. It builds a REFERENCE -- one instrument,
eight slots, global order -- then builds two chips exactly as the firmware
builds one, and requires the six sounding voices to carry the reference's
global 0..5 scatter, bit for bit, on all four cells.

It also checks the defect's own SIGNATURE directly rather than inferring it
from a mismatch count: are chip B's slots byte-identical to chip A's? That is
the line that names the fault instead of merely reporting a number.

    before: D3 RED  -- 3 of 6 voices wrong, 3 of 3 slots duplicated
    after : D3 GREEN -- 6 distinct identities, 0 of 3 duplicated

## 3. The fix, and why it cannot disturb the frozen port

    void juno_apply_condition_at    (unsigned char *state, int cbyte,  int base);
    void juno_apply_unison_spread_at(unsigned char *state, int assign, int base);

`base` is the GLOBAL index of local voice 0; the table index becomes
`(base + v) & 7`. The two frozen entry points are now one-line wrappers at
`base = 0`, so the old behaviour is preserved **BY CONSTRUCTION** rather than by
inspection -- there is no second copy of the arithmetic to drift.

    make verify: GREEN, with src/ touched.
    PROVENANCE.tsv: zero non-PROVEN data rows.

The index is MASKED, not clamped: a global voice is a position in an
eight-entry analog scatter and 8 is the port's own voice count.

## 4. ⚠ ONE DECISION THIS SURFACES, and it is the user's

The JUNO-60 has SIX voices; the CONDITION tables have EIGHT entries. **Which
six the fork keeps is an audible choice**, and FINAL_GUIDE already flags it as
unresolved. The gate assumes global 0..5 -- the only choice that needs no
justification. `GLOBAL[]` in the gate is the one line to change if the user
picks differently, and `base` then follows.

Not claimed: that 0..5 is what the hardware JUNO-60 does. Nothing here has been
compared against six real voices.

## 5. What D3 still owes

The firmware does not yet CALL the `_at` forms -- `eb_devseq.c:56-57` still uses
the base-0 wrappers, correctly, because the single-chip build IS base 0. Wiring
`base` to the chip's role is D4's job (role by strap pin), and it is the next
piece.
