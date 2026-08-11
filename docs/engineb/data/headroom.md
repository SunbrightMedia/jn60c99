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
