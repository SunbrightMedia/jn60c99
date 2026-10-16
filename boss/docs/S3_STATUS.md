# BOSS Effects Pedals (Roland Cloud .vst3) — intake only, NOT a port yet

The only status page of this track. Labels: PROVEN = executed; READ = static (strings / RTTI / version
resource); INFERRED = deduction. A separate track from the JUNO-60 lift (the user, 2026-10-16).

## Intake (PORT_PIPELINE step 0) — done 2026-10-16
`boss/truth/BOSS_Effects_Pedals.vst3` (18,032,640 bytes), pinned in `boss/truth/SHA256SUMS`
(sha256 999f192a…9d729). Resolve it ONLY through `boss/tools/boss_truth.py` (`$BOSS_TRUTH` overrides the
directory). `python3 boss/tools/boss_truth.py --tooth` verifies the bytes and proves the check fails on one
flipped byte (PROVEN, seen to fail 2026-10-16).

## The companion files — received 2026-10-16 ("everything you should ever need", the user)
238 files pinned in `boss/truth/SHA256SUMS` (60 MB), kept as the user supplied them:
- `boss/truth/Script/` (the user's boss-script.zip, 212 files): `Script.xml`, `ScriptAbout.xml`, `ScriptEfx.xml`,
  `ScriptResource.xml`, `ScriptView.xml`, `TextCodeTable.dat`, `Initial.bin` (100,384 bytes), `BX00_DATA.BIN`
  (8,766,144 bytes), 204 PNG (the GUI art). `Script.xml` has the fm / vm struct layout of the ZenCore family.
- `boss/truth/Preset/` (boss-preset.zip): 25 factory preset files `Preset<model>.bin`, each 100,384 bytes (the size
  of `Initial.bin`).
- 25 models have a preset file AND GUI art (`bm<model>.png`). Six classes in the binary have NEITHER: BF-3, DD-8,
  DS-2, MD-2, OD-3, TR-2 (and `CTestalgDsp`). READ; INFERRED: these are not in the shipped product. The census
  (step 1) decides, from the binary, which models a product path can reach.

## What the binary says (READ, 2026-10-16)
| fact | value |
|---|---|
| Format | PE32+ DLL, x86-64, 11 sections (the `.vst3` is the bare DLL, not a bundle) |
| Version resource | ProductName "BOSS Effects Pedals", FileVersion 1.14, ProductVersion 22.0.9.2, (C) 2025 Roland Corporation |
| Family | ZenCore / Koa: `CWaveGen`, the `CKoa*Control` GUI classes, JUCE, protobuf — the JX-3P / JP8 / TB-303 family |
| Pedal models (RTTI `C<model>` / `C<model>Dsp`) | BF-2, BF-3, CE-2, CS-1, CS-2, DC-2, DD-2, DD-8, DF-2, DM-2, DS-1, DS-2, HM-2, HM-3, MD-2, MZ-2, OC-2, OD-1, OD-2, OD-3, PH-1, PN-2, PS-2, PW-2, SD-1, SG-1, SP-1, TR-2, TW-1, VB-2, XT-2 (31; plus a `CTestalgDsp`) |
| Plugin wrappers | `CEfxStereoPlugin<CMultiChannelProcessor<…Dsp,2>>`, `…WithCarryover` (DD-2, DM-2, PS-2), `CEfxStereoSharedChannelPlugin` (CS-1, CS-2, DF-2, MZ-2, SG-1, TW-1, XT-2, OC-2), `CEfxMultiProcessorStereoPlugin` (DC-2: input mixer, DSP, output stage) |
| Companion files the binary names | `Script.xml`, `TextCodeTable.dat`, `Initial.bin` (received 2026-10-16, below); `auth_strings_*.bin` not supplied — the login, out of scope ("leave out anything Roland related", the user 2026-10-15) |
| Build path (pdb string) | `...\SsxFx\AppFx\BX00\Editor\Win\BOSS Effects Pedals.pdb` — the "SsxFx" tree, product code BX00 |

## Owed before any gate (PORT_PIPELINE steps 1-4, then the lift plan of docs/JUNO_LIFT.md)
1. DONE 2026-10-16: the companion files (above).
2. Census (`tools/verify/pe_recon.py`; needs `pip install pefile`), the ABI ledger, the oracle boot recipe
   (from `jp8/tools/jp8_emu.py`), the listen proof on the oracle.
3. Then the lift (L1-L7), not a hand transcription (the user's 2026-10-15 rule).
