# archive/ -- retired device targets (history)

Kept so that every result they produced stays traceable; no make target builds them.

| Folder | What | Retired |
|---|---|---|
| `daisy/` | The Daisy Seed (STM32H750, Cortex-M7) build of the port, with ITCM placement of the render loops; its measurements are in docs/ARM_MEASURED.md and docs/trackb/ | the Track B arc is parked (CLAUDE.md LIVE STATE) |
| `teensy/` | The Teensy 4.x PlatformIO build; its golden corpus lives on in tests/test_teensy_golden.c (tests/teensy_golden.h, regen-checked) | superseded by the ESP32-S3 and the Pi tracks |

The live device targets are `esp32s3/` (ONE board per synth, CLAUDE.md) and `pi/`.
