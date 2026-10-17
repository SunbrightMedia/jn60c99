# BOSS Effects Pedals — the binary census (intake, PORT_PIPELINE step 1)

All READ (static), mechanical and reproducible: `python3 boss/tools/boss_census.py` emits
`boss/docs/census.json`, bound to the pinned sha256 (`boss/tools/boss_census.py --tooth` proves a flipped byte
breaks the bind). The companion truth (238 files) verifies: `boss_truth.verify()` is True. This page summarises
`census.json`; the JSON is the record.

## The binary
| fact | value |
|---|---|
| file | `boss/truth/BOSS_Effects_Pedals.vst3`, 18,032,640 bytes |
| sha256 | `999f192afb927b40aae459d64e64967e44e5e6b6819d7ccb20ad749ca619d729` |
| format | PE32+ DLL, x86-64 (the `.vst3` is the bare DLL, not a bundle) |
| version | ProductName/FileDescription "BOSS Effects Pedals"; FileVersion 1.14; ProductVersion 22.0.9.2; (C) 2025 Roland Corporation |
| exports (VST3 ABI) | `InitDll`, `ExitDll`, `GetPluginFactory` |
| entry point | 0x20b8 (DllMain via the CRT); TLS callback 0xb4d3c0 |
| imports | 720 across 20 DLLs (KERNEL32 262, USER32 172, gdiplus 56, WS2_32 32, WINMM 31, ADVAPI32 25, WININET 17, …) |
| RTTI classes | 1,525 type descriptors |

## The product = one DLL, many pedals
One int parameter `fm.tt.ms.model` selects the pedal (READ from `truth/Script/ScriptEfx.xml`; 0..255, panels
0..47; the model→panel table is in `boss/docs/S3_STATUS.md`). The factory instantiates **31** effect-plugin
instances across **4 wrapper categories** (READ from RTTI):

| wrapper category | count | meaning |
|---|---|---|
| `CEfxStereoPlugin` | 18 | one DSP, stereo |
| `CEfxStereoSharedChannelPlugin` | 9 | shared-channel stereo (CS-1/2, DF-2, MZ-2, SG-1, TW-1, XT-2, OC-2, PN-2) |
| `CEfxStereoPluginWithCarryover` | 3 | DD-2, DM-2, PS-2 (tail carryover) |
| `CEfxMultiProcessorStereoPlugin` | 1 | DC-2 (input mixer → DSP → output stage) |

**30 model DSP classes** are named in RTTI (`C<Model>Dsp`): Bf2, Ce2, Cs1, Cs2, Dc2, Dd2, Df2, Dm2, Ds1, Ds2,
Hm2, Hm3, Md2, Mz2, Oc2, Od1, Od2, Od3, Ph1, Pn2, Ps2, Pw2, Sd1, Sg1, Sp1, Testalg, Tr2, Tw1, Vb2, Xt2.
The 25 shipped pedals (art + a `Preset<model>.bin`): selector 0, 4, 6, 19, 27–47 (S3_STATUS). `Testalg` is a
test algorithm. Family: ZenCore / Koa (JUCE + protobuf) — the JX-3P / JP8 / TB-303 family.

## Companion truth (238 files, all verified)
- `boss/truth/Script/` (212): `Script.xml`, `ScriptAbout/Efx/Resource/View.xml`, `TextCodeTable.dat`,
  `Initial.bin` (100,384 B), `BX00_DATA.BIN` (8,766,144 B), 204 PNG (GUI art).
- `boss/truth/Preset/` (25): `Preset<model>.bin`, each 100,384 B (the size of `Initial.bin`).

## Sections (runtime-filled tails noted in census.json)
`.text` 0xcaa3cf · `.rdata` 0x36ae89 · `.data` 0x3fed9 (tail 0x1047e00–0x1056ed9 filled at startup) · `.pdata`
0x93aa4 · `.idata` · `.tls` · `_RDATA` · `.fptable` · `.rsrc` · `.reloc`. The `.pdata` holds the unwind info the
lift's L3/L4 use; the runtime-filled `.data` tail is zero in the file and written by startup code (watch it —
the JX pulse wavetable once lived in such a tail and read zero under the emulator).

## Not in scope (the user, 2026-10-15/17)
The Roland Cloud login / authorization (RCM, WININET/WS2_32, OpenSSL) and the demo path: the port runs offline,
licensed by the user; the licence runs once at boot on a PC and is never in the port. See S3_STATUS (2026-10-17).
