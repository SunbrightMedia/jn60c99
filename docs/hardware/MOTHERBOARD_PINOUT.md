# ESP32-S3 MOTHERBOARD — PINOUT REFERENCE (single S3, N16R8)

Binding connector map for the general-synth motherboard. ONE ESP32-S3-DevKitC-1
(N16R8). No Wi-Fi. Connectors are 2/3/4-pin JST-XH ONLY. **Pin 1 = GND on every
JST that carries GND** (project connector rule). Power rides its own 2-pin feeds
so signal connectors stay 3-pin.

## Rule that makes it fit
24 direct GPIO used, 1 spare. Everything LOW-SPEED and HIGH-COUNT (mux selects,
buttons, encoders, extra gates, extra chip-selects) rides the **I2C/SPI
expanders on the breakout boards — never the S3**.

## Reserved — never wire to a connector
IO19/20 (USB), IO26-32 (flash), IO35-37 (PSRAM), IO43/44 (console),
IO0/3/45/46 (strap), IO48 (LED).

## Direct on the S3 — the 24 usable pins
| Function | Signal | GPIO |
|---|---|---|
| I2S audio | BCK / WS / SD | IO15 / IO16 / IO17 |
| I2C bus | SDA / SCL | IO8 / IO9 |
| I2C INT | INT | IO18 |
| SPI bus | MOSI / MISO / SCK | IO11 / IO13 / IO12 |
| SPI CS (main ×2) | CS1 / CS2 | IO10 / IO14 |
| CAN (TWAI) | TX / RX | IO4 / IO5 |
| MIDI ext (UART1) | TX / RX | IO1 / IO2 |
| MIDI int (UART2) | TX / RX | IO38 / IO39 |
| Volume pot | WIPER (ADC1) | IO7 |
| Performance | TIP (ADC1) | IO6 |
| CV/Gate | LDAC / sync | IO21 |
| Clock/sync | CLK_IN / CLK_OUT / RUN | IO40 / IO41 / IO42 |
| EXT spare | GPIO | IO47 |

ADCs on ADC1 (IO6/IO7). USB (IO19/20) + console (IO43/44) left free — flash +
debug intact. No strapping pins used — clean boot.

## The JST-XH connectors
| Connector | Pins | Pin order (1→n) | GPIO |
|---|---|---|---|
| PWR_IN | 2 | GND, +5V | — |
| 3V3_FEED (×n) | 2 | GND, +3V3 | — |
| AUDIO_I2S | 4 | GND, BCK, WS, SD | IO15/16/17 |
| AUDIO_PWR | 2 | GND, +5V | — |
| I2C (×2-3, one bus) | 4 | GND, +3V3, SDA, SCL | IO8/9 |
| STEMMA-QT (retrofit) | 4 | GND, +3V3, SDA, SCL | (same bus) |
| I2C_INT | 2 | GND, INT | IO18 |
| SPI_BUS | 4 | GND, MOSI, MISO, SCK | IO11/13/12 |
| SPI_CS (×n) | 3 | GND, +3V3, CS | IO10, IO14 |
| CAN | 4 | GND, +5V, TWAI_TX, TWAI_RX | IO4/5 |
| VOL_POT | 3 | GND, WIPER, +3V3 | IO7 (ADC) |
| MIDI_EXT | 4 | GND, +5V, TX, RX | IO1/2 |
| MIDI_INT | 3 | GND, TX, RX | IO38/39 |
| PERF_CTRL | 3 | GND, TIP(ADC), RING | IO6, IO21 |
| CLOCK_SYNC | 4 | GND, CLK_IN, CLK_OUT, RUN | IO40/41/42 |
| CV_GATE | — | rides SPI_BUS + one SPI_CS + LDAC | expander |
| MUX_SEL / EN | — | on expander (74HC138 / XL9555) | expander |
| EXT / spare | 3 | GND, GPIO, GPIO | IO47 + spare |

## The one jumper — J26 (5V)
Joins board **+5V** to the DevKit **5V pin**. Backfeed isolation: stops the
DevKit's USB 5V and board 5V from fighting.
- Closed: board powers the ESP.
- Open: ESP runs on its own USB; board 5V stays off it.

## Optional through-hole resistors — DNP footprints (ship passive-free)
| Resistor (TH, DNP) | For | Populate when | Type |
|---|---|---|---|
| 2× SDA/SCL pull-up (4.7 k → 3V3) | I2C bus | no breakout provides them | shunt |
| 1× INT pull-up (10 k → 3V3) | open-drain INT | expander board doesn't | shunt |
| 3× I2S series (33 Ω on BCK/WS/SD) | edge damping | long I2S run | series |
| 2× CAN/UART series (opt) | EMI | noisy runs | series |
| 3× strap pull (IO0/45/46 → level) | safe boot | a breakout tugs a strap | shunt |

Rule: **shunt** (pull-up) safe to leave empty; **series** (in-line) must be
filled (0 Ω bridge if you skip damping). Put the I2C pull-up pads near the S3.

## Placement note
Place each GPIO at its silk position on the DevKit footprint (H1A1/H1B1/H1C1/
H1D1). The silk names the IOxx per physical pin; drop each signal above onto its
matching IOxx. GND and the power rails are plane/pour, not point wires.
