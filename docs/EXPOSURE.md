# Exposure map — what the JUNO-60 product actually uses vs. framework code

**The problem this solves.** Cloud 60 (JUNO-60) is one product built on RolandCloud's
**shared plugin framework** (the same lineage that surfaces as "System-8" in the FX
class names, `CPrmDSPSystem8Dly…`). The decompiled DLL therefore contains a *superset*:
JUNO-60-specific code **plus** framework code for things the JUNO-60 never exposes.
**"Present in the binary" ≠ "used by this product."** Mistaking framework code for
JUNO-60 code has already cost us real time (below), so this is the authoritative
boundary, built capture-free from the binary.

## Where it already bit us

- **The parameter registry has 1121 params for a JUNO-60 with ~30 panel controls.**
  It is one ~110-param framework *voice template* replicated **~16×** (16 parts) — names
  like `LFO Level`, `ENV Attack` each appear 16 times (`docs/PARAM_MAP.tsv`). Trying to
  map the real JUNO patch params into this 1121-param framework set — without knowing
  which are the JUNO ones — is exactly why the DB→engine continuous-param binding looked
  intractable ("the System-8 multi-OSC layout" the bridge doc kept hitting).
- **The arp**: the `CKbdArp` 150-pattern sequencer is framework; the JUNO-60 arp is the
  `CArpeggio` MODE×RANGE engine only (`docs/ARP_DSP.md`).
- Within even one framework voice, the **LFO waveform switches** (Sin/Tri/Sqr/Saw/S&H)
  are System-8 — a JUNO LFO is triangle-only.

## The four authoritative sources of "exposed"

In order of directness:

1. **The VSTGUI `.uidesc` panel resource** — maps every on-screen control → ParamID.
   This is the ideal artifact, BUT it lives in the `.vst3` **bundle's `Resources/`
   folder**, not in the decompiled PE. The binary holds only VSTGUI *parser* error
   strings ("root panel", "node panel") and the SVG control assets — confirming VSTGUI
   but not yielding the control→ParamID list. **Not recoverable from what we have.**
2. **The factory-preset DB synth block (DB 755..877)** — the **123 params the preset
   format actually stores**, each with a value-format **spec** that is the panel's
   control labelling (`64FEET|32FEET…`, `POLY1|MONO|UNISON`, `LPF -24dB…`,
   `JUNO CH1|JUNO CH2`, `AMBIENCE|ROOM|HALL`). **This is the exposed set, fully static.**
   (`refs/default_patch.json`.)
3. **The controller's published parameters / the registry** (`docs/PARAM_MAP.tsv`) —
   names + engine offsets; the superset to scope *down* from.
4. **The confirmed panel photo** — ARPEGGIO / ARP MODE (UP·UP&DOWN·DOWN) / ARP RANGE
   (1·2·3) + the standard DCO/VCF/VCA/ENV/LFO/CHORUS sections.

## What the map says (`refs/exposure_map.json`)

The **exposed JUNO-60 patch surface is the 123-param DB block, not the 1121-param
registry.** Of those 123:

| group | count | note |
|---|---|---|
| actual JUNO-60 patch params | **84** | DCO / VCF / VCA / ENV1 / ENV2 / LFO / NOISE / CHORUS / REVERB / GLOBAL / ARP |
| framework modular CV/jack matrix (DB 830–852) | 23 | stored in presets but **not** JUNO panel controls (System-8 patch-jacks) |
| preset name characters (DB 814–829) | 16 | not controls |
| of the 84: proven engine-offset bindings | 8 | feet, tune, + driver selectors (chorus/reverb/filter/model/key-assign) |
| of the 84: continuous, runtime-only binding | ~45 | the knobs — DB→offset is runtime-only (`docs/DB_ENGINE_BRIDGE.md`) |

`refs/exposure_map.json` lists every exposed DB param with `{spec, default_step,
panel_section, panel_control, engine_offset?, binding, confidence}`, plus a
`framework_only_NOT_exposed_by_juno60` list (the 16× replication, LFO waveform switches,
second LFO/MOD block, OSC2/3, the CV/jack matrix, CKbdArp, portamento, ext-jacks, etc.).

## How this helps going forward

1. **Scope every param/transcription task to the 123 exposed params**, never the 1121.
   When a function/table/param isn't reachable from the exposed set, treat it as
   framework until proven otherwise.
2. **It tightens the continuous-param binding.** The DB→engine offset for continuous
   params is runtime-only (proven, `docs/DB_ENGINE_BRIDGE.md`), but knowing the exposed
   set is ~84 params (not 1121), each with a panel section + UI spec + adjacency to the
   8 proven anchors, turns the LFO/VCF/ENV mapping from "wild guess across 1121" into a
   constrained best-effort over a small, labelled set — the realistic path to the LFO
   rate/depth behind the pitch drift, without a capture.
3. **The only thing that would make it exact** is the bundle's `.uidesc` (control→ParamID)
   or a one-time runtime observation of the ParamID→engine-slot binding.

## Honest limits

- Panel-section assignment for the unclassified continuous knobs (DB indices with bare
  `0..255` specs) is by spec + JUNO-60 layout, not proven per-control — flagged
  `CONTINUOUS (unclassified)` in the JSON.
- The exposed *set* (123) is authoritative (it's what the preset format stores); the
  per-control panel grouping and the continuous engine-offset bindings are best-effort
  until the `.uidesc` or a runtime trace is available.
