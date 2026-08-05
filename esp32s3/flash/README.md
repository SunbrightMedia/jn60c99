# Flash and measure — no IDE, no toolchain, one cable (F4)

Two prebuilt images. The difference is the PSRAM type, and the WRONG one
does not boot — if the first image you try crash-loops at startup with a
PSRAM error, use the other one. Common devkits: ESP32-S3-DevKitC-1 **N8R8 /
N16R8 = OCTAL**; **N8R2 / N16R2 = QUAD**.

| file | PSRAM |
|---|---|
| `juno_s3_octal_psram.bin` | octal (R8 modules) |
| `juno_s3_quad_psram.bin` | quad (R2 modules) |

## 1. Flash (any OS, Python only)

```
pip install esptool
esptool --chip esp32s3 -p <PORT> write-flash 0x0 juno_s3_octal_psram.bin
```

`<PORT>` is `COM5`-style on Windows, `/dev/ttyUSB0` or `/dev/ttyACM0` on
Linux, `/dev/cu.usbmodem*` on macOS. Use the USB port labeled **UART** if the
board has two. If flashing does not start, hold BOOT, tap RESET, release
BOOT, retry.

## 2. Read the output

Any serial monitor at **115200 baud** (Arduino IDE's Serial Monitor works
fine, or `python -m serial.tools.miniterm <PORT> 115200`). Press RESET and
copy everything between `=== JUNO S3 FORK FIRMWARE ===` and `=== done`.

## 3. What the lines mean — the two that matter

- **`FORK EVALUATOR VECTORS: BIT-EXACT`** — required. If it says FAIL, the
  S3's arithmetic differs from the host's and every number after it is
  about a different function; the firmware halts on purpose. Report the
  mismatch lines.
- **`REGION sample_total CALLS 12500 TOT <N>`** — the measurement.
  On silicon CCOUNT counts CYCLES, so:

```
cycles/sample = N / 12500
c/i           = (N / 12500) / 40275     <- QEMU's executed count, same program
```

The budget is 5,000 cycles/sample/core (240 MHz / 48 kHz), ~10,000 for two
cores. The whole F4 question is the c/i ratio: near 1.0 keeps the S3 alive
(with the C2 lever still to execute); Daisy-style 2–3 ends it and the
Teensy fork is the path.

Sanity that must also hold, or the number is void: every `SINK <region>` is
nonzero (except sample_total/cal, which are meta), and `OVERRUN delay 0
reverb 0`.

## What this measures / does not

Same workload as the QEMU instruction count (one program, two hosts): the
fork chain, 8 voices, FX states in PSRAM — the product's own placement for
the big states. It does NOT play patches (engine B's device-side recall is
the known open item) and its voice-coefficient set is the harness's driven
synthetic one, not a recalled patch. It is a c/i and cycles measurement,
not a sound demo.
