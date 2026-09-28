# The purple GY-PCM5102 (PCM5102A) I2S DAC module -> ONE ESP32-S3 (written 2026-09-28)

The 15-pin Amazon/AliExpress breakout the user owns. Sources (web, 2026-09-28): the mt32-pi wiki "GY-PCM5102 DAC module"
(https://github.com/dwhinham/mt32-pi/wiki/GY-PCM5102-DAC-module) for the 6-pin header and the jumpers; the note.com
"PCM5102 Stereo DAC Wiring and Connection Guide" (https://note.com/ndenki/n/n402814a33262) for the 9-pin header.
S3 pins = the firmware's own (esp32s3/LISTEN.md, main/juno_s3_listen.c `S3L_BCLK/S3L_LRCK/S3L_DOUT`), proven on the bench:
the DAC played once XSMT was set high (2026-09-13 bench session).

## 6-pin header (digital side), physical order
| pin | function | ESP32-S3 |
|---|---|---|
| SCK | system clock | GND (no MCLK: the chip uses its internal PLL; a floating SCK = silence) |
| BCK | bit clock | GPIO 5 |
| DIN | data in | GPIO 7 |
| LCK | word select (LRCK/WS) | GPIO 6 |
| GND | ground | GND |
| VIN | supply (the module regulates it) | 5V |

## 9-pin header (control + analog side), physical order
| pin | function | connect |
|---|---|---|
| FLT | filter: L = normal FIR, H = low-latency IIR | leave to jumper 1 (L) |
| DEMP | de-emphasis: L = off | leave to jumper 2 (L) |
| XSMT | soft mute: L = MUTE, H = play | leave to jumper 3 (H) — the usual cause of silence |
| FMT | format: L = I2S, H = left-justified | leave to jumper 4 (L) |
| A3V3 | 3.3 V made ON the module (an output) | nothing; never feed it |
| AGND | analog ground | audio ground |
| ROUT | right line out | amp / jack right |
| AGND | analog ground | audio ground |
| LOUT | left line out | amp / jack left |

## Back-side solder jumpers (must be set before any sound)
Jumper 1 (FLT) = L, jumper 2 (DEMP) = L, jumper 3 (XSMT) = **H**, jumper 4 (FMT) = L.
Some boards also have a front pad that ties SCK to GND.
