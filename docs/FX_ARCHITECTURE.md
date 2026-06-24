# FX/arp architecture — data unblocked, and the real shape of the work

The data-section dump (`extract_data_sections.py`) **worked**: vtables now resolve,
and every coefficient/tempo table is in hand (`refs/data/`). The earlier blocker is
gone. What it revealed is the *shape* of the remaining work, which is worth stating
plainly.

## Win: the reverb is a recovered, standard algorithmic reverb
`CDSPRev` loads four tables (selected by sample rate, then by hall type via `idx<<6`):
- `unk_63A350` — **delay-line lengths** in samples (246, 738, 1910, 196, 586, 1516, …),
  grouped per comb/allpass stage.
- `unk_639F20` — **allpass feedback coefficients** (1.0, 0.9986, −0.9986, 0.9972, …).
- `unk_63A130` — **damping biquads**: (b0,b1,b2,a1,a2) sets, e.g.
  (0.0004, 0.0008, 0.0004, 1.9417, −0.9434) — lowpass dampers in the tank.
- `unk_63A600` — a scalar (≈0.065, wet/level).
So HALL2 is a Schroeder/FDN tank: delay lines + allpasses + per-stage damping. Fully
transcribable now that the coefficients exist.

## The shape: controller/worker split, several layers deep
Each "effect" is **not** one DSP function. It's a tree of *controller* objects whose
vtables are mostly parameter setters (verified: `refs/data/vtable_*.txt`), with the
actual audio worker reached through more indirection:
- `CDSPRev`: ctor → SR table-select (`sub_1803C17C0`) → **buffer setup**
  (`sub_1803C1AC0`, sums the delay lengths to size the tank, binds them to params
  0x44A/0x454/0x457/…) → a per-sample **worker** that runs the tank (separate fn,
  reached via the FX-chain dispatch — the same indirect-call boundary that originally
  hid the chorus).
- `CDSPSystem8DlyDly`: a composite (DlyDly + DlyCh + DlyPan + DlyMfx1 + DlyFlSt);
  the vtable is 24 control slots, delay time via tempo table `unk_910DC8`.
- `CKbdArp`: clocks a precomputed pattern table; note-getter + note-on are vtable/
  fn-ptr indirect (now resolvable via `refs/data/`).

## Honest scope
This is no longer *blocked*, but it is *large*: each of the three is a multi-layer
subsystem (controller → setup → worker), comparable in effort to a sizable slice of
the synth voice, and the per-sample workers sit behind the FX-chain dispatch that has
to be traced (as the chorus once was). Realistically this is **one subsystem per
work-session**, not a single pass.

Recommended order (clearest first): **reverb** (coefficients fully recovered) →
**delay** (needs the `unk_910DC8` tempo table re-cut from the right offset) →
**arpeggiator** (logic + pattern builder). Each lands as an exact transcription like
the voice/master/chorus, validated as it goes.

## Provenance committed
`refs/data/`: the resolved FX/arp vtables, the six FX/arp/gate tables (raw bytes),
and the segment map. Full 5.4 MB dump (raw `.rdata`/`.data`/`.pdata`) kept locally,
gitignored. Resolver: `tools/resolve_vtable.py`.

## Arp finding (closes the loop)
The arp scanner (`sub_1803C0260`) and note-output (`sub_1803C35A0`: velocity-sens
scaling → synth note-on via `*(synth_vtable+24)`) are transcribable, and the
note-ordering (mode/range via `obj+3472`) is visible in the scanner. BUT the
rhythm/gate **pattern table** (`obj+610`, 6 bytes/step) is **patch data** — it's
what makes "SQ Dynamic **ARPG**" a specific sequenced groove. So reproducing *this*
arp needs the preset parser too. The arp *engine* is doable; the *pattern* is data.

## Net scope to reproduce "SQ Dynamic ARPG"
Four large, partly-interdependent subsystems:
1. **Preset parser** (`KoaBankFile00003` schema) — supplies the patch values AND the
   arp pattern. Largest single sub-project; mostly generic Roland-framework plumbing.
2. **Arp engine** — scanner + key buffer + clock; transcribable, drives note events.
3. **Delay worker** — behind the threading/task dispatch; needs the dispatch traced.
4. **Reverb worker** — Schroeder/FDN tank (coefficients recovered); also behind the
   task dispatch.
The data is fully unblocked for all four; the remaining cost is transcription +
tracing the FX task dispatch, realistically multiple dedicated sessions.
