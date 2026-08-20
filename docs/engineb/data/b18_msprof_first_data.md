# b18 — the profiler works, and b16's attribution does NOT survive it

First run of the corrected MSPROF build (b17, playbook 72). ~51 s, 2 voices,
patch stepping every 4 s.

## 1. The clock is real, and there is an independent check that it is

    MSP: in=102 delay=657 reverb=973 out=142 effect=667 cyc/sample (n=53248)
    MSP: in=102 delay=1123 reverb=1192 out=142 effect=610 cyc/sample (n=220160)

`in` reads **102 on every line of the run**. `out` reads **142 on every line**.
Two stages constant to the cycle while three others move by hundreds.

That is worth more than the `*** BROKEN` tooth. A stub counter gives every
stage the same value; a real counter gives stage-DEPENDENT values, and these
two stages do fixed work per sample so they SHOULD be flat. The instrument
agrees with what is known about the code it is measuring.

## 2. The numbers

| stage | min | max | swing | share of total swing |
|---|---|---|---|---|
| 0 in | 102 | 102 | **0** | — |
| 1 delay | 655 | 1123 | **+468** | 62 % |
| 2 reverb | 951 | 1228 | +277 | 36 % |
| 3 out | 142 | 142 | **0** | — |
| 4 effect | 533 | 675 | +142 | — |

Delay's ratio, max over min: **1123 / 655 = 1.71x**.

## 3. Judging b16's prediction, which was written before the run

b16 §5 stated it in two parts. They do not both survive.

| claim | verdict |
|---|---|
| type-5 : other ratio **1.7-2.0x** | **HOLDS** — 1.71x, at the low edge |
| stage 1 is the **largest single contributor** | **FAILS as stated** |

Delay is the largest single contributor to the **VARIATION** (62 % of the
swing). It is never the largest stage in **ABSOLUTE** cost: reverb outreads it
on every line of the run. b16 did not distinguish the two and the prediction is
only half right. Recorded as half right, not rounded up.

### And one observation points the other way

The run's most expensive moment:

    FXP: fx=3597  (the highest of the run)   ... pat=21   <- a DELAY TYPE 5 patch
    MSP: in=102 delay=735 reverb=1228 out=142 effect=610

At the hottest point, on a type-5 patch, **delay read 735 — near its floor —
while reverb read 1228, its maximum of the whole run.** If the delay module
were the cause, that is the line where it should have peaked.

Meanwhile the run's peak delay (1123) landed on `pat=28`, which is **not** a
type-5 patch.

## 4. ⚠ WHY THIS RUN CANNOT SETTLE IT — the window is the defect

The MSP counters were printed and reset **once per second**. The patch steps
every 4 s. The two are not locked, and `n` proves it: the sample count per
report swung from **3,328 to 264,192** — a factor of 79.

**So no MSP line describes one patch.** Every reading is a blend across an
arbitrary slice of one or more patches. The §3 observations are therefore
suggestive and NOT decisive in either direction: b16 is not confirmed, and it
is not refuted either. Both of §3's pointers could be window artefacts.

This is the same shape as playbook 72 one step further out. There the
instrument was not connected to its clock; here it is connected to the wrong
WINDOW. A profiler whose accumulation window does not match the thing being
attributed cannot attribute, however good its clock.

## 5. The fix, and what the next run decides

The counters are now printed and reset **at the patch boundary**, for the patch
that is ending, emitted before the program change so `pat` names the patch
whose samples were counted:

    MSPP: pat=<n> in= delay= reverb= out= effect=  sum=  (n=)

One line per patch, exactly attributed, 64 lines per sweep, ~4.3 min. The
one-second `MSP:` line no longer resets anything — it is a partial running
average and says so.

**What the next run decides, stated before it runs:**

* If `MSPP:` for patches **5, 16, 21, 49** shows `delay` high and the other 60
  show it low — b16's attribution holds, and the lever is `eb_delay_t5.c`.
* If those four show **reverb** high instead, or show nothing unusual — the
  cost is not the delay module, and the master-chain split across cores
  (b6's option, one block = 5.8 ms of latency) is the lever.

No lever is chosen here. §3 currently leans toward reverb and away from b16,
and that lean is explicitly NOT strong enough to act on.

## 6. Other readings from the run, none of them new

`PARAM: unknown=0 pubretry=0` again, with warm recall applying in 173-201 k
cycles. `wait=5` again — core 0 still spins. `RECALL: CRC MATCH`. Nothing here
changes b17.

⚠ `fx`, `cyc`, `B4dur` and the drift from this build carry six cycle-counter
reads per sample inside them and may not be quoted as costs. `fx=3597` is used
above only to LOCATE the hottest moment in the run, never as a figure.
