# THE UNDERRUNS WERE THE CONSOLE. THE ENGINE WAS NEVER THE PROBLEM.
(2026-08-12, `juno_s3_BISECT.bin`, the user's board)

## The gap meter, and it says the same thing on every single window

    worst block-to-block gap   65,998 - 117,305 us   RIGHT AFTER: printf
    the block period            5,804 us

**The loop stalls for 66 to 117 MILLISECONDS, eleven to twenty block periods,
and the tag is `printf` every time -- twelve windows out of twelve.**

The arithmetic closes exactly. The per-second report grew to seven lines --
`engine`, `NOTES`, `t=`, `I2S`, `BURST` x2, `SLACK` -- which is about 800
characters. At 115,200 baud, 8N1:

    800 chars x 10 bits / 115200 = 69 ms

`printf` blocks once the UART driver's buffer fills, and it was being called
FROM INSIDE THE AUDIO LOOP.

## The bisect EXONERATES the recall burst

    STEPPING ON    92 / 57 / 26 / 36 / 96 / 33 underruns per 5,160 chunks
    STEPPING OFF    0 / 182 / 184 / 123 / 162 / 0

**Patch stepping OFF has MORE underruns than ON in four of six pairs.** The
burst is not the cause and never was; `nearest burst 245 chunks` was telling
the truth all along.

## THIS IS PLAYBOOK DEFECT 30, FOR THE FOURTH TIME

The catalogue already reads: *"the harness was the thing being measured (x3) --
a vTaskDelay in the audio loop; a latched verdict; 235 characters of console
per second."* The console entry is there BY NAME, with its own arithmetic, and
`S3L_REPORT_EVERY` was added to throttle it.

Then I added four more report lines while hunting a stall, and re-created the
defect at three times the size. Every hypothesis I chased afterwards -- flash
cache, PSRAM, the burst, the resonance table -- was chasing my own diagnostic.

**The rule the playbook already had, restated because it did not stick: THE
AUDIO LOOP MAY NOT CALL printf. Not throttled, not conditionally -- not at
all.** A blocking call in a real-time loop is a defect regardless of how rarely
it fires, and "rarely" is exactly what makes it survive review.

## What this means for the engine

The engine was never over budget in a way that mattered. Every steady-state
figure -- 5,159 at two voices with FX, 5,206 at three without -- was already
inside 5,442, and the drift and underruns were the reporter.

## The fix

Reporting moves to its OWN TASK at low priority. The audio loop writes a
snapshot struct and never blocks. That is the only form that cannot come back:
a throttle makes it rarer, a task makes it impossible.
