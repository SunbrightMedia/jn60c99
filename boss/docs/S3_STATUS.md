# BOSS Effects Pedals (Roland Cloud .vst3) — intake only, NOT a port yet

The only status page of this track. Labels: PROVEN = executed; READ = static (strings / RTTI / version
resource); INFERRED = deduction. A separate track from the JUNO-60 lift (the user, 2026-10-16).

## Intake (PORT_PIPELINE step 0) — done 2026-10-16
`boss/truth/BOSS_Effects_Pedals.vst3` (18,032,640 bytes), pinned in `boss/truth/SHA256SUMS`
(sha256 999f192a…9d729). Resolve it ONLY through `boss/tools/boss_truth.py` (`$BOSS_TRUTH` overrides the
directory). `python3 boss/tools/boss_truth.py --tooth` verifies the bytes and proves the check fails on one
flipped byte (PROVEN, seen to fail 2026-10-16).

## What the binary says (READ, 2026-10-16)
| fact | value |
|---|---|
| Format | PE32+ DLL, x86-64, 11 sections (the `.vst3` is the bare DLL, not a bundle) |
| Version resource | ProductName "BOSS Effects Pedals", FileVersion 1.14, ProductVersion 22.0.9.2, (C) 2025 Roland Corporation |
| Family | ZenCore / Koa: `CWaveGen`, the `CKoa*Control` GUI classes, JUCE, protobuf — the JX-3P / JP8 / TB-303 family |
| Pedal models (RTTI `C<model>` / `C<model>Dsp`) | BF-2, BF-3, CE-2, CS-1, CS-2, DC-2, DD-2, DD-8, DF-2, DM-2, DS-1, DS-2, HM-2, HM-3, MD-2, MZ-2, OC-2, OD-1, OD-2, OD-3, PH-1, PN-2, PS-2, PW-2, SD-1, SG-1, SP-1, TR-2, TW-1, VB-2, XT-2 (31; plus a `CTestalgDsp`) |
| Plugin wrappers | `CEfxStereoPlugin<CMultiChannelProcessor<…Dsp,2>>`, `…WithCarryover` (DD-2, DM-2, PS-2), `CEfxStereoSharedChannelPlugin` (CS-1, CS-2, DF-2, MZ-2, SG-1, TW-1, XT-2, OC-2), `CEfxMultiProcessorStereoPlugin` (DC-2: input mixer, DSP, output stage) |
| Companion files the binary names | `Script.xml`, `TextCodeTable.dat`, `Initial.bin`, `auth_strings_*.bin` — NOT supplied yet |

## Owed before any gate (PORT_PIPELINE steps 1-4, then the lift plan of docs/JUNO_LIFT.md)
1. The companion files (Script.xml, TextCodeTable.dat, Initial.bin, any preset / .Dat files) from the user's
   install, checksummed into `boss/truth/` — or a PROVEN statement that the engine boots without them.
2. Census (`tools/verify/pe_recon.py`; needs `pip install pefile`), the ABI ledger, the oracle boot recipe
   (from `jp8/tools/jp8_emu.py`), the listen proof on the oracle.
3. Then the lift (L1-L7), not a hand transcription (the user's 2026-10-15 rule).
