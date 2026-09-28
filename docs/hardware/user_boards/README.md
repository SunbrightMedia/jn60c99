# user_boards — snapshots of the user's own KiCad files (REFERENCE, saved 2026-09-28)

The user draws every schematic and PCB by hand; the CURRENT files live on the user's PC. These are the latest copies the
user uploaded to the retired chat (upload date in brackets), kept so a new session can audit nets without asking again.
Never treat them as newer than what the user has; ask for a fresh upload before any audit that matters.

| file | what | uploaded |
|---|---|---|
| EspMotherboard.kicad_sch | ESP32-S3 motherboard (N16R8 DevKitC-1 socket, headers to every satellite board) | 2026-09-21 |
| HeadphoneBreakout.kicad_sch | headphone / DAC board (= Headphone_Dac in the BOM) | 2026-09-21 |
| AudioBreakout.kicad_sch + .kicad_pcb | the audio breakout (PCM5102A DAC, OPA1656 line drivers, TPA6120 HP amp, LM2776 -5 V) | 2026-09-21 |
| buttonpack3.kicad_sch | 3-button pack (PB86-A1 3-Pack) | 2026-09-22 |
| muxboardv1.kicad_sch | CD74HC4067 16-channel mux board (Multiplex16) | 2026-09-21 |
| EVERY_PCB_FILES_2026-09-23.zip | the user's JLC export of all 14 boards (gerbers + bom + designators + netlist per board); the BOM inputs in `../bom/inputs/` come from it | 2026-09-23 |

The SegmentBackpack schematic is in `../SegmentBackpack/`, the Switch/Fader boards in `../SwitchBoard/` and `../FaderBoard/`.
Audit any of them with `tools/hardware/schem_audit.py FILE --tooth` first (docs/hardware/AUDIT.md).
