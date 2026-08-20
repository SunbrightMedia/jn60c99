# TWO-CHIP WIRING — O6/D1, what to connect and why

Both boards get **the same firmware image**. The only difference is one jumper.

## The jumper decides the role

| board | GPIO 4 | becomes |
|---|---|---|
| chip **A** | **leave unconnected** | MASTER — owns the clock, owns the DAC, global voices 0-2 |
| chip **B** | **wire to any GND pin** | SLAVE — clocked by A, no DAC, global voices 3-5 |

The sense is deliberate. An unstrapped board reads HIGH through the internal
pull-up and is therefore chip A — which is exactly what a single board is
today, so **the board you already have keeps working unchanged**. A broken
jumper makes two masters, which the firmware detects and says out loud; the
opposite sense would make a broken jumper a silent mute.

## The wires — six plus ground

    ┌─────────────── chip A (no jumper) ───────────────┐
    │                                                  │
    │  GPIO 5  BCLK ─┐                                 │
    │  GPIO 6  LRCK ─┼──> the ONE audio board          │
    │  GPIO 7  DOUT ─┘                                 │
    │                                                  │
    │  GPIO 15 BCLK ───────────────────────────────>   │  A drives
    │  GPIO 16 LRCK ───────────────────────────────>   │  A drives
    │  GPIO 17 DIN  <───────────────────────────────   │  B drives
    │  GPIO 8  TX   ───────────────────────────────>   │
    │  GPIO 9  RX   <───────────────────────────────   │
    │  GND          <──────────────────────────────>   │
    └──────────────────────────────────────────────────┘
                                                       │
    ┌─────────────── chip B (GPIO 4 to GND) ───────────┘
    │  GPIO 15 BCLK   (input, from A)
    │  GPIO 16 LRCK   (input, from A)
    │  GPIO 17 DOUT   (output, to A)
    │  GPIO 9  RX     (from A's GPIO 8)
    │  GPIO 8  TX     (to A's GPIO 9)
    │  GND
    │  GPIO 5/6/7     LEAVE UNCONNECTED — chip B has no audio board
    └──────────────────────────────────────────────────

**Connection list, one line per wire:**

    A GPIO 15  ->  B GPIO 15      link bit clock
    A GPIO 16  ->  B GPIO 16      link word clock
    A GPIO 17  <-  B GPIO 17      link audio data (B's three voices)
    A GPIO  8  ->  B GPIO  9      control: A tells B the patch
    A GPIO  9  <-  B GPIO  8      control: B answers with its CRC
    A GND      <-> B GND          REQUIRED — without it nothing works

**Do NOT connect:** the two boards' 5V or 3V3 rails, and chip B's GPIO 5/6/7.
Power each board from its own USB.

## Why A receives but still drives the clock

This is the line most likely to be "corrected" by intuition, so it is stated
plainly: **the sender does not clock this wire.** Chip A owns the only
oscillator in the instrument, so A generates BCLK/LRCK on *both* of its I2S
peripherals — the one feeding the audio board and the one receiving chip B.
Chip B is a *slave that transmits*.

Reverse it and there are two oscillators, which is exactly what the one-DAC
decision exists to make impossible. With this arrangement drift between the
chips cannot happen **by construction** rather than being corrected, and chip
B gets its sample tick for free.

## ⚠ The control pair is two wires the original decision did not cover

D1 settled the *audio* path at "three wires plus ground, no MCLK". D2 — patch
distribution and the CRC handshake — needs a path from **A to B**, and the
audio link only carries data B→A. So the control UART is an addition, and it
is flagged rather than slipped in.

**The alternative, and why it is worse:** control bits could be hidden in the
low bits of the I2S audio frame, needing no extra wires. That would put a
permanent, invisible coupling between the audio sample format and the control
protocol — a change to one silently corrupting the other. This session has
spent its entire length paying for silent couplings. Two wires is the honest
price.

If the extra pair is genuinely impossible, say so and it will be designed the
other way, with the coupling documented and gated.

## What happens on first power-up

The firmware brings the link up **before** it makes any sound, and reports:

* which role each board decided it is, and from what pin level
* whether a peer answered at all
* whether the pair is valid (not two masters or two slaves)
* whether both chips hold the same patch **and built the same coefficients**
  (by CRC — matching patch numbers alone is not enough)
* whether the two chips claim disjoint global voices

Any failure is printed by name and the instrument stays silent rather than
playing half a chord. The failure names are in `s3_link.h`.

## What is proven and what is not

**Proven on a workstation** (`sh tools/engineb/o6_gates.sh`): the role table,
the direction table — every wire has exactly one driver — and all six
handshake rejections, each seen to fail.

**NOT proven:** that GPIO 15 on A reaches GPIO 15 on B. No wire has existed at
any point in this design. Nothing here has been on two boards.
