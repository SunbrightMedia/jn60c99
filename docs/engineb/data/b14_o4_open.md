# b14 — O4 opened: what the 306 µs actually is

## 1. b12's numbers reconcile, so the target is real

Before choosing a lever, the measurement it rests on was checked against an
independent number from the SAME run.

    blocks total        487,791   (burst 83,670 + note 200,827 + quiet 203,294)
    at PERIOD           2,831.6 s   47.19 min
    at MEASURED durs    2,981.2 s   49.69 min
    implied drift         149.5 s
    REPORTED drift        150.1 s   (150,106 µs, printed by the board)

**Agreement to 0.4 %.** The block durations and the drift counter are computed
by different code from different clocks, and they say the same thing. b12's
`B4dur` is trustworthy.

## 2. The target, restated correctly

b12 quoted the QUIET class (6,001 µs vs 5,804 µs = +197 µs) and FINAL_GUIDE
repeated it as "O4's number". That is the FLOOR — what a block costs with no
build work at all. The number that actually accumulates is the run average:

    mean overrun        306.6 µs per block
    per sample          287 cycles over budget
    actual              ~5,729 cyc/sample against a 5,442 budget

Both figures are true and they answer different questions. The floor says how
much is structural; the average says how much drift the instrument really
accrues. **O4 must close 287 cycles/sample, not 184.**

For scale: b6 measured the RENDER at 5,112-5,389 cyc/sample on non-delay
patches. So roughly **340-620 cycles/sample live outside the render
measurement entirely** — prologue, I2S, publish, timer. That gap is where O4
should look first, and no lever should be chosen before it is attributed.

## 3. ⚠ THE HYPOTHESIS THAT COULD DISSOLVE ALL OF IT

`juno_s3_listen.c` blocks inside `i2s_channel_write(..., portMAX_DELAY)`, and
its own comment says why: "a blocking write is the correct way to be ahead: it
parks the loop until the DAC has room, which locks the engine to the DAC's own
clock instead of free-running against it."

**So when the engine is AHEAD, the block interval is not the CPU's cost — it
is the DAC's period.** And the block interval is exactly what `B4dur`
measures.

That gives two completely different readings of the same 306 µs:

| reading | what it means | what O4 must do |
|---|---|---|
| **CPU behind** | the engine really needs 5,729 cyc/sample | find 287 cycles — split the master chain, hunt the delay arm |
| **DAC slow** | the engine is ahead and parked; 6,001 µs is the DAC's real period, i.e. an effective 42,660 Hz | fix an I2S clock configuration. There is NO cycle deficit and O4's lever list is moot |

The second reading also explains the `ovr_late`/drift anomaly left open since
`b4_first_run.md` §5, which has never had a mechanism.

⚠ Against it: an `I2S_STD_CLK_DEFAULT_CONFIG(44100)` on this part is normally
accurate to well under 0.1 %, and 3.4 % is far outside that. So the CPU-behind
reading is the more likely one — but "more likely" is not a measurement, and
this project has paid for that distinction repeatedly (playbook 46).

## 4. The decisive number is ALREADY PRINTED — no new build needed

The firmware has carried the discriminator all along:

    I2S: blocked <min>/<max> us (min/max)  zero-block <n> of <N>  ...
         [a zero-block write means the ~29 ms DMA lead is GONE;
          a blocking one means it is held]

* **`zero-block` high, `blocked` ~0** → the write never waits, the DMA lead is
  gone, the engine is BEHIND. The CPU-behind reading is correct and O4 is a
  cycle hunt.
* **`blocked` large, `zero-block` low** → the loop is parked in the DAC's
  write, the engine is AHEAD, and the block interval is the DAC's clock. O4 is
  a clock-configuration fix.

`wrote_blocked_us` is computed, min/maxed and printed; only a stray
`(void)wrote_blocked_us;` suggests otherwise, and that is a no-op suppressor,
not a disablement.

**ACTION: read the `I2S:` line off the next board log before writing one line
of O4 code.** It costs nothing, it is already in the O3 build now being
flashed, and it chooses between two lever lists that share no work.

## 5. What is NOT claimed here

No lever is picked. No cycles are attributed. The prologue is still unmeasured
(`S3L_TIME_PROLOGUE` exists and is 0), and until §4 is read, measuring it may
be work on the wrong hypothesis.
