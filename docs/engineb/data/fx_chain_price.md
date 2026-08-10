# THE MASTER/FX CHAIN — PRICED, AND THE SECOND CHIP'S REAL PROBLEM
2026-08-10, Opus 5. The FX chain is the SECOND CHIP's entire budget and had
not been priced since the fork changed.

## 1. WHAT IT COSTS TODAY (MEASURED, from the repo's own silicon run)
`docs/engineb/data/o8_halfos_result.md` §10, listen firmware on the user's S3:

    2 voices, full engine   11,476 instr   20,465 cycles   c/i 1.78
    2 voices, voices only    8,200 instr   12,820 cycles   c/i 1.56
    THE FX CHAIN ALONE       3,276 instr    7,745 cycles   **c/i 2.36**

And that file already names the cause: *"The FX chain runs at c/i ~= 2.36,
and that one IS memory: its rings are 6.2 MB in PSRAM."*

## 2. ★ THE RINGS FIT IN INTERNAL SRAM, AND NOBODY HAD CHECKED
`JUNO_EB_RING_PROBE=1`, all 36 scenarios, deepest read behind each write
pointer, rounded up to a power of two:

    t1     31,007 -> 32,768 = 128.0 KB      t5_2    741 -> 1,024 =  4.0 KB
    t5_0   15,503 -> 16,384 =  64.0 KB      t5_3    705 -> 1,024 =  4.0 KB
    t5_1   15,503 -> 16,384 =  64.0 KB      e5      205 ->   256 =  1.0 KB
    t23       536 ->  1,024 =   4.0 KB      t4_0/1   71 ->   128 =  0.5 KB

**EXACTLY ONE DELAY ARM RUNS PER PATCH** -- charging all of them bills a
patch for arms it does not have, which is an error `engine_price.py` already
records. Per arm:

    DELAY TYPE 1   128.0 KB      TYPE 2/3   4.0 KB
    DELAY TYPE 5   136.0 KB      TYPE 4     1.0 KB
    WORST ACTIVE SET, plus the effect ring:  **137.0 KB**

The listen firmware prints **free internal 167,043 bytes = 163 KB**.

**137 KB fits in 163 KB.** The 6.10 MB allocation that forces PSRAM is 45x
the working set, inherited from the plugin's own length cells.

CAVEAT, STATED RATHER THAN BURIED: 31,007 samples is the deepest read THIS
BANK produces. A shipping allocation must be derived from the DELAY TIME
parameter's MAXIMUM, not from observed lag, or a patch outside the battery
reads past the end. That derivation is NOT done, and it is the precondition
for this lever, not a footnote to it.

## 3. THE TWO-CHIP LAYOUT ARITHMETIC, which changes what "the FX problem" is
Six voices, two chips, four cores. The FX must run on ONE chip (it sums all
voices, so the other chip's voices cross the link). The best layout:

    chip A: core A0 = 2 voices          6,136
            core A1 = 1 voice           3,068     -> chip A = 6,136
    chip B: core B0 = 2 voices          6,136
            core B1 = 1 voice + FX      3,068 + FX -> chip B = max(6136, 3068+FX)

**SO THE FX IS FREE UP TO 3,068 CYCLES.** Below that it hides entirely behind
the two-voice core and costs the instrument nothing.

    FX today                     7,745   -> chip B = 10,813, FX IS the problem
    FX at the voice chain's c/i   5,111   -> chip B =  8,179, still the problem
    FX under 3,068                        -> chip B =  6,136, FX is FREE

So the target for the FX is not "fast", it is **under 3,068 cycles**, and the
whole gap between 5,111 and 3,068 is what the ring placement has to buy. That
is a much better-defined goal than "make the FX faster", and it is the first
time it has been stated as a number.

**AND NOTE WHAT THIS SAYS ABOUT THE WHOLE PROJECT:** with the FX free, BOTH
chips land at 6,136 -- the two-voices-on-one-core constraint, identical on
each. The voice is the binding constraint on both chips, and the FX is a
threshold problem rather than a scaling one.

## 4. WHAT LANDED TONIGHT ON THIS CHAIN
`EB_NOLIBM` extended to the master and FX modules: **72 fminf/fmaxf call
sites -> 0**, rewired mechanically (a non-zero literal second operand gets
the 2-instruction form, 23 sites; everything else gets the 4-instruction
exact form, 13 sites, because only a literal rules out both the NaN case and
the opposite-signed-zero case). GATE: trunk null `--module standalone`, all
36 scenarios, **PASS EXACTLY 0** -- the master chain is inside that gate.

No cycle claim. At c/i 2.36 the FX chain's arithmetic is not what dominates
it; the memory is. That is the next measurement, not the next assumption.

## 5. HEAD POINTER FOR THE SECOND CHIP
1. Derive the ring length from the DELAY TIME parameter maximum (precondition).
2. Allocate the ACTIVE arm's rings in internal SRAM; measure the FX chain's
   cycles again. The hypothesis being tested is that c/i 2.36 -> ~1.6 and the
   FX approaches the 3,068 threshold that makes it free.
3. If it does not reach 3,068: the effect send is ALREADY a one-sample
   feedback loop (the port forms its output BEFORE dispatching the effect
   arms; an arm reaches the audio on the NEXT sample through cells
   84672/84704). That means the FX arms do not have to be serial with the
   master -- they could run on the other core with the delay that already
   exists. UNEXPLORED, and it is the structural fallback.
