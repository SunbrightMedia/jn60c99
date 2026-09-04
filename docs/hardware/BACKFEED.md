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

1. **ONE supply for all four slots.** A single 5 V input (wall adapter, not
   USB) feeds every slot. No slot can be unpowered while another runs, so the
   asymmetry that causes back-feed never exists in normal use.
2. **Series resistors on EVERY hop line — 330 Ω, 0603.** 15 per hop, 45 in
   total. They cap the clamp current at roughly 8 mA a pin during any
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
