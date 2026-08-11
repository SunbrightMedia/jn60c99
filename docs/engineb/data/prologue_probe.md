# Finding the last cycles: FIRST, the target was wrong (2026-08-11)

## 696, not 119

`fxpipe2_result.md` said 577 of the 696 was "bad balance and reachable by
scheduling". **That is wrong, and enumerating every partition proves it:**

    core0=prologue+0v     core1=3v+FX      9,708   over 4,266
    core0=prologue+0v+FX  core1=3v         7,086   over 1,644
    core0=prologue+1v     core1=2v+FX      7,346   over 1,904
    core0=prologue+1v+FX  core1=2v         6,398   over   956
    core0=prologue+2v     core1=1v+FX      6,138   over   696   <- TODAY
    core0=prologue+2v+FX  core1=1v         8,760   over 3,318
    core0=prologue+3v     core1=0v+FX      8,500   over 3,058
    core0=prologue+3v+FX  core1=0v        11,122   over 5,680

**The arrangement now shipping is already the best of the eight.** The
perfect-balance figure of 5,561 requires splitting work at a grain finer than
one voice, and no such unit exists -- except possibly the prologue.

So the honest target is **696 cycles off core 0**, and the only sub-voice
candidate is the prologue's 1,414.

## But 1,414 is a SUBTRACTION, not a measurement

It came from `core0 (6,138) - 2 voices (4,724)`. That difference silently
contains everything else core 0 does per sample: the at-rest advance, and the
per-voice loop cost of the FIVE voices this chord does not sound (`vout[v]=0`,
the at-rest test, two control-rate state writes, `continue`).

Moving "the prologue" to the other core would move only the part that is
actually `eb_engine_render_shared` -- the noise LFSR, voice 0's cvgate and
glide, and the LFO. If that part is 400 cycles rather than 1,400, the move is
not worth attempting, and the remaining 1,000 is per-voice loop overhead that
a smaller `EB_NUM_VOICES` would remove instead.

**Those are completely different pieces of work, and the subtraction cannot
tell them apart.** So the prologue gets its own measurement before anyone
designs against it.

## The probe

`juno_s3_PROBE_PROLOGUE.bin` runs all 128 prologues in ONE timed batch, then
the voices, and prints `PROLOGUE x.xx us/sample`.

⚠ **This build DELIBERATELY SERIALISES the two halves** -- core 1 is blocked
until the batch ends -- so its loop total is worse BY CONSTRUCTION and must
not be quoted. The only number it exists to produce is the prologue's.

The timer is read twice per BLOCK, not per sample, for the reason the main
loop already records: at two calls a sample it bills its own cost to the thing
it is measuring.

## What each outcome would mean

- **Prologue ~1,400** -- it really is the shared work, it is indivisible, and
  moving it to core 1 makes core 1 the bottleneck (6,398). Dead end; the 696
  must come from cheaper arithmetic.
- **Prologue ~400-700** -- the rest is per-voice loop overhead for voices this
  chip does not own. Then TWO levers open at once: pipeline the real prologue
  onto core 1 (which idles 1,154), and stop iterating voices the chip will
  never sound.
