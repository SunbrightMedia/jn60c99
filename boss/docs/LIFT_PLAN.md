# THE BOSS EFFECTS PEDALS LIFT — plan for the C99 port (the JUNO way)

Binding method: `docs/JUNO_LIFT.md` (the user, 2026-10-15: "use the plugin's own code, I just need it in C99;
nothing hand-written from scratch unless it is glue to the ESP32 / raspi"). This page is the BOSS-specific plan a
fresh chat executes. The ONLY status page of the track is `boss/docs/S3_STATUS.md`; read it first (its 2026-10-17
correction), then this.

Report progress to full completion as a percentage in every reply (the measure is at the end).

## 0. What we build
`boss/truth/BOSS_Effects_Pedals.vst3` (18,032,640 bytes, sha256 999f192a…9d729, pinned in `boss/truth/SHA256SUMS`,
resolved ONLY via `boss/tools/boss_truth.py`) lifted to a handful of C99 files — the plugin's OWN machine code in
C, not a hand transcription. End state (like the JUNO/JP8 lifts):
- `boss/src/boss_lift.c` — every reachable instruction, lifted by the image-generic lifter.
- `boss/src/bossh.h` + `boss/src/boss_host.c` — the C API and the host glue (the plugin's own VST3 entries +
  the effect-host render path); the ONLY hand-written code, and only glue.
- device glue (ESP32-S3 / Pi) lives apart and carries NO licence code (the user, 2026-10-17: the port runs
  offline; the licence runs once at boot on a PC and is never in the port — do not lift it).
"Done" = a gate like `jp8_host_gate.sh` pointed at the lifted port is EXACTLY 0 on every drive, teeth bite, and
the scope table is stated (the completeness charter, `docs/PORT_COMPLETENESS_CHARTER.md`).

## 1. The one rule, and mantra 5
The `.vst3` is the only ground truth. The port is self-proving: every output word, state byte, and the memory
after each graded step equals the plugin's own execution (the oracle). NEVER validate by ear. Every gate/tooth is
SEEN TO FAIL on a real defect before it is believed. The harness is the prime suspect — it is plumbing only and
never reimplements plugin logic. (The 2026-10-16 "licence wall" was exactly a harness hypothesis that proved
false under measurement.)

## 2. The blocker, and the route to a booted instance (READ S3_STATUS 2026-10-17)
The oracle (`boss/tools/boss_emu.py`) cannot yet boot BOSS: a worker thread throws `std::system_error`
(`_Thrd_busy`, code 3) from a timed `_Mtx_lock` through a `call_once` static init; a real run catches it and goes
on. The cause is the oracle's thread model (one thread-id, run-to-completion) plus no C++/SEH unwinder — NOT a
licence check (no licence file/key is read before the stop) and NOT the DSP. `boss/tools/boss_throw_probe.py`
reproduces this.

L1 (census), L4 (template) and L5 (gates) need a booted instance. Two routes:
- **ROUTE A (recommended, the JP8 native-oracle pattern — the user has the licensed plugin + Python + a C
  compiler).** Build a minimal C VST3 host (BOSS analogue of `jp8/tools/native/jp8_native_host.c`) that the USER
  runs on the licensed PC. It loads the real authorized plugin (licence passes, real OS threads), boots it,
  drives the product paths, and writes the lift's inputs: the reach trace (L1), the booted template (L4), and
  golden output/state/end-memory (L5). This is the real plugin on real silicon, so it is faithful by
  construction, and it never needs the oracle to pass any check. See `jp8/docs/NATIVE_ORACLE.md`.
- **ROUTE B (in-container, heavier, fallback).** Fix `boss_emu.py` so threads interleave with distinct ids (so a
  timed lock does not self-collide) and, if a real run throws-and-catches here, add a C++ EH unwinder. Faithful
  only once it reproduces the real plugin — which cannot be checked from this container, so Route A must confirm
  it anyway.
L2 and L3 need NO boot and start immediately in-container (section 3).

## 3. The steps (L1–L7), BOSS-specific, and the legacy artifact each reuses
| Step | BOSS task | Reuse (legacy / mantra 4) | Done when |
|---|---|---|---|
| L2 | Lift every reachable instruction → `boss/src/boss_lift.c`. Image-generic lifter with `LIFT_BIN=boss/truth/...vst3`. Add any new instruction FORM the image needs to the shared lifter, with a tooth. | `jp8/tools/jp8_lift.py` (+ `jp8_fast.py`, `jp8_xlane.py`); the JUNO L2 did this, `docs/JUNO_LIFT.md` log | every census instruction is in the C; `check_reached.py`-style static check finds no trap on a reachable path |
| L3 | Prove each instruction FORM: the lifted C of one op vs the real CPU and Unicorn over edge+random states (regs, mem, flags, MXCSR). | `jp8/src/jp8_cpu.h` runtime; `l3_flags.py`, `l3_teeth.sh`; playbooks 219–225 (NaN), 228/241 (MXCSR), 120/286 (FTZ/DAZ, Unicorn's 4 named departures) | every form EQUAL; a planted wrong semantic fails |
| L1 | Census: every instruction a product can reach. Static reach (direct calls, jump tables, every vtable + function pointer) ∪ dynamic reach of a drive that exercises **all 25 shipped pedal models** (selector `fm.tt.ms.model`; shipped: 0,4,6,19,27–47) at each shipped rate, plus state/editor/MIDI. | `boss/tools/boss_reach.py`; the JUNO `juno_lift_reach.py`; Route A trace or Route B oracle | the list exists; its size is the L2/L3 denominator |
| L4 | Template = the booted authorized memory at the cut point (after `initialize`, before `setupProcessing`); the C API `bossh.h`; host-object + import shims. | `jp8/tools/jp8_template_export.py`; the JUNO `jn_template_export.py`; `probes/b6/wrapper_emu.py` | every census root callable; self-check byte-identical, tooth bites |
| L5 | Gates: a drive (output words + state bytes + `performEdit` + memory after = EXACTLY 0) over all 25 models, the factory presets (`boss/truth/Preset/*.bin`, 25 files), DAW state, the editor set, MIDI. | the `jp8_host_gate.sh` pattern; the JUNO host gates | all EXACTLY 0; teeth bite |
| L6 | Machine search: random sequences of every entry point, compared after every call, steered to unreached code. | `jp8/tools/native/jp8_reach_scan.py`, `jp8_native_fuzz.py` | 24 h with no difference |
| L7 | Any app (a native host / web page) calls only lifted plugin entries; speed work only in the lifter. | the JP8/JUNO app checks | checked against the plugin |

## 4. BOSS scope facts (from the binary, READ 2026-10-16; `boss/docs/S3_STATUS.md` has the tables)
- A multi-effect: 31 pedal models in RTTI, 25 shipped (art + a `Preset<model>.bin`). One int parameter
  `fm.tt.ms.model` (0..255; panels 0..47) selects the pedal. The census MUST drive every shipped model so each
  model's DSP code is reached; one lift then covers all of them.
- Wrappers: `CEfxStereoPlugin`, `…WithCarryover` (DD-2, DM-2, PS-2), `CEfxStereoSharedChannelPlugin`,
  `CEfxMultiProcessorStereoPlugin` (DC-2). ZenCore/Koa family (same as JX-3P / JP8 / TB-303): JUCE + protobuf.
- The oracle boots by the VST3 interfaces only (TLS cb 0xb4d3c0, DllMain, InitDll, GetPluginFactory,
  getClassInfo/createInstance, initialize); every address from the PE header. InitDll reads `BX00_DATA.BIN` one
  byte per `std::istream::get` (~10 min under Unicorn) — boot once, snapshot, resume.

## 5. Hard rules that bite here (from CLAUDE.md)
- Two-process rule: never build a Unicorn E2E instance AND ctypes-load a `.so` in one Python process.
- Long jobs ONLY via `tools/run_job.sh`; keep a Monitor on the EXIT file; never `pkill -f`.
- Label every claim PROVEN(executed) / READ(static) / INFERRED. A number quoted N times is not measured.
- `-ffp-contract=off`; the NaN/FP/MXCSR/FTZ discipline of the playbooks applies to BOSS unchanged.
- Findings go in `boss/docs/`, never in CLAUDE.md. This page and S3_STATUS are the record.

## 6. The progress measure (report every reply)
progress = 5·L1 + 25·L2 + 15·L3 + 10·L4 + 20·L5 + 15·L6 + 10·L7, each term the fraction done (same weights as
`docs/JUNO_LIFT.md`). Rounded down; a regression lowers it. Today: intake + boot diagnosis only → **~1%**.

## 7. FIRST actions for the fresh chat
1. Read `boss/docs/S3_STATUS.md` (2026-10-17) then this page.
2. Decide Route A vs B with the user (A recommended). If A, build the native host and give the user the exact
   build + run commands; if B, start on `boss_emu.py` thread scheduling.
3. In parallel, start L2 in-container: run the image-generic lifter over the BOSS image and stand up the L3
   per-form proof — these need no boot and produce the first real `.c` now.
