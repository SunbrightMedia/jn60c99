# The last deficit is the console, and headroom is the real question
(2026-08-11)

## The console is 2.0 % of the wall clock

    two report lines           ~235 characters
    at 8N1, 115200 baud        2,350 bits = 20.4 ms EVERY SECOND
    share of wall clock        2.04 %
    MEASURED remaining deficit 1.16 %

`printf` blocks once the driver's buffer fills, and it sits INSIDE the
wall-clock test that decides pass or fail. Same order as the whole remaining
deficit.

`S3L_REPORT_EVERY` (default 5) throttles the PRINTING only; the measurement
still accumulates every second, so the numbers are unchanged and the UART cost
is divided by five. `juno_s3_OWN3B.bin` carries it.

**This is the third time tonight the instrument turned out to be the thing
being measured** -- after the latched verdict and the watchdog sleep. The rule
earned: when the last few percent will not close, price the harness before
pricing the engine.

## ⚠ BUT 4 CYCLES OF MARGIN IS NOT A DESIGN, AND THIS IS THE IMPORTANT PART

OWN3 measured whole loop 5,446 against a 5,442 budget. Even with the console
fixed, the margin is a few tens of cycles on a 5,442-cycle budget -- well
under 1 %.

**Nothing else can be added to that chip.** And the instrument is not
finished: MIDI, parameter control and preset recall are all still missing, and
none of them is free.

    PER SAMPLE      nothing new IF parameters are held between changes. The
                    smoothers already run and are already counted.

    PER BLOCK       MIDI parsing. Small, but not zero, and it lands on core 0.

    PER NOTE EVENT  the allocator, the voice reseed and the retrigger latch.
                    This firmware already pays a version of it: load_coefs()
                    copies a voice-state snapshot at every gate change, INSIDE
                    the timed region. A real note-on does more.

    PER RECALL      the whole coefficient rebuild. Engine B HAS NO DEVICE-SIDE
                    RECALL PATH AT ALL -- CLAUDE.md records that the
                    coefficients here were built on the HOST and frozen into
                    s3_listen.bin. So its cost is not merely unmeasured, it is
                    unwritten. On the plugin this is a large burst of work.

**A burst is what kills a chip with no margin.** A per-sample average that
fits does not survive a recall that takes several milliseconds in one block,
because the codec does not wait. Either recall must be spread across many
blocks, or it must run while the engine is muted, or the chip needs real
headroom -- and today it has none.

## So the honest answer to "will MIDI, parameters and recall be free?"

**No.** Per-sample cost will barely move, which is the part that looks
reassuring. But note events and recall are BURSTS on a budget with no slack,
and recall does not exist yet on the device at all.

The next work is therefore not another cycle hunt. It is:

1. Build the missing paths (device recall above all) and MEASURE them.
2. Win back real headroom -- 5 to 10 %, not 0.07 % -- so a burst has somewhere
   to go.
3. Test with actual playing rather than a looped chord. The voice-to-core map
   is still unforced, and a three-note chord landing entirely on one core was
   already measured at 9,204 cycles, 70 % over.

# OWN3B MEASURED: the console throttle worked, 0.54 % remains (2026-08-11)

    OWN3   drift +1,581 ms / 136 s = 11.6 ms/s = 1.16 % behind
    OWN3B  drift   +568 ms / 105 s =  5.4 ms/s = 0.54 % behind

**The verdict now reads `realtime OK` on EVERY line -- the flicker is gone.**
But the cumulative drift still climbs, so it is still not a pass.

The saving was 0.62 % against a predicted 1.63 %. **Wrong by 2.6x, in the
flattering direction, for the sixth time.** The console model assumed the UART
blocks for its full transmission time; evidently the driver buffers part of
it. The number to trust is the 0.62 %.

## Where the last 29 cycles are

    whole loop says  +4 cycles over
    wall clock says ~29 cycles over
    -> about 25 cycles sit OUTSIDE the timed region

The only work there is per-BLOCK: the I2S write and the single barrier,
amortised over CHUNK samples. At CHUNK=128 a 3,000-cycle write is 23
cycles/sample -- the right size to be the whole remainder.

`juno_s3_OWN3C.bin` doubles CHUNK to 256, which halves that share.

**THE COST IS LATENCY AND IT IS USER-FACING:** 128 frames is 2.9 ms, 256 is
5.8 ms, and the FX pipeline adds one more chunk on top of whichever is
chosen. That is a playability trade, so CHUNK stays a knob rather than a
silent new default.

## ⚠ AND THIS IS WHERE THE CYCLE HUNT SHOULD STOP

Closing 0.54 % buys a margin of roughly zero. The chip would then be exactly
at budget with **MIDI, parameter control and preset recall still missing**,
and recall does not exist on the device at all. Those are BURSTS, and a burst
needs slack, not parity.

Chasing the last 29 cycles is worth one build because it is nearly free. It is
NOT worth a campaign. The next real work is the three items already listed
above: build the missing paths and measure them, win back 5-10 % of genuine
headroom, and test with real playing instead of a looped chord.

# OWN3C MEASURED: 0.29 % behind, and the hunt stops here (2026-08-11)

    OWN3   CHUNK 128, console every 1 s   11.6 ms/s = 1.16 % behind
    OWN3B  CHUNK 128, console every 5 s    5.4 ms/s = 0.54 % behind
    OWN3C  CHUNK 256, console every 5 s    2.9 ms/s = 0.29 % behind

Doubling CHUNK halved the deficit exactly as the per-block model predicted --
the first estimate tonight that was not optimistic.

**The timed loop is now 5,440 against a 5,442 budget: UNDER by 2 cycles.** The
wall clock is still 0.29 % behind, so about 16 cycles/sample remain outside the
timed region.

## Why this is the stopping point

Every halving so far has been bought with latency or with reporting. CHUNK 512
would give roughly 0.15 % and **11.6 ms of latency**, before the FX pipeline
adds its own chunk. That is not a trade worth making on an instrument.

And the arithmetic that matters has not changed: closing 0.29 % leaves a margin
of about zero, on a chip that still has no MIDI, no parameter control and no
device-side recall. Those are bursts. **Parity is not headroom.**

## The measured position, for the record

    chip A : 3 voices, no FX                      4,724   fits, 718 spare
    chip B : 3 voices + FX, owning only its own   5,440   fits the timed loop
             wall clock                           0.29 % behind

    voice slope   2,362      measured, linear
    FX chain      2,622      measured three ways within 1 %
    prologue        117      measured directly
    output stage     91      measured
