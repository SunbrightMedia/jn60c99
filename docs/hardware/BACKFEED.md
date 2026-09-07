# Back-feed through the hop lines — what the bench found, and what the
# MasterAudio carrier board must do about it

MEASURED ON THE BENCH, 2026-09-04. Board 2 had NO USB cable and NO 5 V rail
wire, and it still lit up and half-ran. Board 3 then refused to enter the
esptool download mode ("No serial data received") until every other board was
powered off.

## The mechanism (not a fault in the build — it is how the silicon is made)

Every ESP32-S3 GPIO has an ESD clamp diode from the pin to the chip's own
3.3 V rail. Drive that pin above 3.3 V + Vf while the chip is unpowered and
current flows THROUGH the clamp INTO the rail. One pin passes a few mA. The
CHAIN4 hop presents 15 such pins per board pair, and 15 clamps in parallel
carry enough current to raise the rail, light the LED, and hold the chip in an
undefined state where RESET does not take cleanly.

Consequence for a multi-board instrument: **a board that is unpowered while
its neighbours are powered is never truly off.** Any design that lets one
slot lose power independently inherits this.

## What the carrier board must do

1. **ONE supply for all four slots.** The requirement is ONE SOURCE, not a
   particular kind of source: a single USB-C receptacle on the carrier
   (~$0.15 + two 5.1 kΩ CC resistors) feeds every slot and costs nothing the
   BOM does not already carry. No slot can then be unpowered while another
   runs, so the asymmetry that causes back-feed never exists in normal use.
   Current note: four boards + the DAC draw ~1.2 A, so the finished
   instrument wants a phone charger rather than a 0.5 A laptop port. That is
   a cable choice, not a purchase.
2. **Series resistors on EVERY hop line — 330 Ω, 0603 (0603WAF3300T5E,
   LCSC C25231 — NOT 0603WAF330JT5E, which is 33 Ω).** 5 lines per hop
   (BCLK, LRCK, DATA, two control), 3 hops, 15 in total; one resistor per
   line, placed at the TX end. (Corrected 2026-09-07: this line first said
   "15 per hop, 45 total" — a miscount, never measured.) They cap the clamp current at roughly 8 mA a pin during any
   asymmetry (a slot pulled for service, a board reset by hand) and protect
   the pins themselves. 330 Ω against the ~10 pF of a short trace is ~3 ns —
   negligible against the 2.8 MHz hop bit clock and the 31.25 kbaud control
   pair. Do NOT use 1 kΩ or more: the audio bit clock is the fastest signal
   on the board and must keep clean edges.
3. **A per-slot 5 V jumper (or 2-pin header).** Pull one jumper to isolate
   that slot's 5 V from the rail before a USB cable is plugged in, so the
   carrier supply and the USB VBUS never fight. Normal running: all four
   jumpers in.
4. **Bussed RESET, per-slot BOOT.** One button resets all four together, so
   the chain starts in step and a phantom-powered slot can always be cleared.
   Keep BOOT per slot: bussing it would put all four in download mode at once,
   which no flow needs.
5. **RECOMMENDED — an on-board 4-port USB hub** (CH334 or FE1.1s class, ~$1).
   One USB-C to the PC, four downstream ports hard-wired to the four slots'
   UART bridges. One cable then flashes and monitors all four boards, the
   VBUS question above disappears, and the bench's cable shuffling ends. This
   is the single highest-value addition the carrier board can make to the
   development loop.

## What this does NOT change

The hop pin map (CHAIN4.md §6) is unchanged. The resistors are in series with
the existing nets; they add no nets and no new connector pins.
