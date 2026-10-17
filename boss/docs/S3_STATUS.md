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

## The pedal selector (READ, ScriptEfx.xml / Script.xml, 2026-10-16)
One parameter picks the pedal: `fm.tt.ms.model` (int, range 0..255; the panels use 0..47). Model -> panel:
0 ds1, 1 dd8, 2 tr2, 3 testalg, 4 sd1, 5 bd2, 6 od1, 7 os2, 8 ds2, 9 mt2, 10 bf3, 11 ph3, 12 ml2, 13 ge7, 14 odb3,
15 md2, 16 rv6, 17 cs3, 18 ch1, 19 ph1, 20 ds1x, 21 od3, 22 te2, 23 mo2, 24 oc5, 25 aw3, 26 sy1, 27 cs1, 28 sp1,
29 sg1, 30 tw1, 31 ce2, 32 dc2, 33 dm2, 34 bf2, 35 pn2, 36 oc2, 37 ps2, 38 dd2, 39 vb2, 40 df2, 41 od2, 42 pw2,
43 xt2, 44 cs2, 45 hm2, 46 hm3, 47 mz2.
The 25 shipped pedals (art + preset): 0, 4, 6, 19, 27-47. The rest are in the script but not shipped (INFERRED).

## The oracle (boss/tools/boss_emu.py, boss_host.py; 2026-10-16)
- Boot by the VST3 interfaces only: TLS callback 0xb4d3c0, DllMain (entry 0x20b8), InitDll, GetPluginFactory,
  getClassInfo, createInstance, initialize. Every address from the PE header (PROVEN: TLS + DllMain return in 0.9 s).
- The JUNO wrapper profile does NOT apply: jx3p/tools/fw_map.py maps 3 of 24 JUNO wrapper functions into this
  image (setActive 0x2BC070, setupProcessing 0x4040E0, automatic engine rate 0x2BCE70). The rest differ (READ).
- InitDll reads every Script file from `<module>\Script\`, the fonts folder, and lists the ProgramData / user
  folders (MEASURED, fslog). It reads BX00_DATA.BIN one byte per `std::istream::get` (~200 instructions a byte):
  the boot costs ~2e9 instructions (~10 min) under Unicorn, so boss_boot.py boots once and saves
  scratchpad/boss/boot.snap; every probe resumes from it.

## CORRECTED 2026-10-17 — the boot stop is NOT a licence check (the 2026-10-16 note below was wrong)
The user authorized a licensed run and asked for the minimum to start the port the JUNO way (the lift, L1-L7).
`boss/tools/boss_throw_probe.py` (READ-only, boots once, PROVEN under job boss_throw3) settles what stops the
boot. The earlier "waits for the Roland Cloud licence check" claim was a HYPOTHESIS, never measured; it is false.

What the boot actually does and where it stops (PROVEN 2026-10-17):
- Before the stop it reads ONLY the Script files and one GUI-pref key `Software\Roland Cloud\...\View`; it calls
  WsaStartup and misses `openssl.cnf`. NO licence file and NO licence registry key is read. The stop is not a
  licence gate.
- A WORKER thread throws `std::system_error` (`_Thrd_busy`, std code 3) from a timed mutex lock (`_Mtx_lock`,
  rva 0xb09ba0) reached through a `call_once` static init (rva 0x47e8e0, which throws `_Throw_Cpp_error(eax)`
  when the lock returns non-zero). Enclosing frames carry C++ catch handlers (backtrace frames with h=True:
  0x47e9a4, 0x528807, 0x4b50f3), so on a real run the exception is DELIVERED TO A CATCH and the boot continues.
- The oracle stops at the throw for TWO plumbing reasons, both in `boss/tools/boss_emu.py`, neither in the plugin:
  1. No C++/SEH unwinder: a throw is reported, not delivered to its handler.
  2. The thread model runs each thread to completion under one thread-id. `_Mtx_lock` compares the mutex owner
     id (struct +0x48) with GetCurrentThreadId; serializing the real interleaving onto one id makes the lock
     look self-owned, so a timed lock returns `_Thrd_busy` where a real, interleaved run would acquire or wait.

So the blocker is the ORACLE's thread/exception plumbing, not licensing and not the DSP. The port itself needs
NO licence code: the licence runs once at boot on a PC; the offline ESP32-S3 / Pi port never runs it (the user,
2026-10-17: do not lift the licence code — it would be bloat, like the demo path).

### The minimum to start the lift — two routes (the user has the licensed plugin + Python + a C compiler)
- ROUTE A (on the user's licensed PC, RECOMMENDED, the JP8 native-oracle pattern, jp8/docs/NATIVE_ORACLE.md):
  a minimal C VST3 host loads the REAL authorized plugin (licence passes, real OS threads), boots it, drives the
  product paths, and writes the artifacts the lift needs: the reach census (L1), the booted template (L4), and
  golden output / state / end-memory for the gates (L5). This sidesteps the oracle's thread-model limit entirely.
- ROUTE B (here, heavier): fix the oracle's thread scheduling so threads interleave with distinct ids and timed
  locks do not self-collide (and, if a real run does throw-and-catch here, add a C++ EH unwinder). Faithful only
  once it reproduces what the real plugin does, which cannot be checked from this container.
L2 (the lift of the reachable instructions) and L3 (per-instruction-form proof vs the CPU) do NOT need the boot
and can begin from static reach now; L1/L4/L5 need a booted instance from ROUTE A or B.

## STOPPED 2026-10-16 (SUPERSEDED by the 2026-10-17 correction above — kept for provenance)
InitDll does not return under the oracle: the plugin's start-up waits for its Roland Cloud licence check. Getting
past it would mean working around that check, which this project does not do. The track waits for the user's
decision (an authorized run on the user's own machine, Roland's permission, or another track). The oracle plumbing in
boss/tools/ (threads run when their creator blocks, events, a virtual clock, the effect host, the census, the drive)
is general and kept; no gate has run.

## Intake (PORT_PIPELINE steps 0-1) — DONE 2026-10-17
1. DONE 2026-10-16: the `.vst3` + 238 companion files pinned; `boss_truth.verify()` True; the sha tooth bites.
2. DONE 2026-10-17: the binary census — `boss/tools/boss_census.py` -> `boss/docs/census.json` (+ `--tooth`),
   summarised in `boss/docs/CENSUS.md`: version, VST3 exports, 720 imports / 20 DLLs, sections (runtime-filled
   tails), TLS + entry, and the product surface (31 effect-plugin instances in 4 wrapper categories over 30
   model DSP classes). All READ (static), reproducible, bound to the pinned sha256.

## Owed next (the lift — boss/docs/LIFT_PLAN.md, the JUNO way)
- The ABI ledger (which imports the oracle must serve) and the booted instance are part of the lift, not intake:
  the oracle cannot boot yet (the thread-model stop, above), so L1/L4/L5 wait on ROUTE A (a native host on the
  user's licensed PC) or ROUTE B (fix the oracle thread model). L2 (lift the reachable instructions) and L3
  (per-form proof vs the CPU) need no boot and start in-container now. Not a hand transcription (the user,
  2026-10-15). The progress measure is in LIFT_PLAN.md section 6; today ~1%.
