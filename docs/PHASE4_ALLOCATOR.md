# Phase 4 — Allocator sub-modes (finding + disposition)

Ground truth = the plugin binary under Unicorn (tools/verify/e2e_emu.py).

## Question

The plugin's `CAssignJu60` has four allocator sub-modes (docs/VOICE_MODES.md):
POLY (0), MONO (1), UNISON (2), POLY-variant (3). 14 factory patches store
ASSIGN MODE = MONO and 2 store UNISON. The port hardwires `assign_mode = 0`
(POLY) in `apply_bank` (gui/juno_bridge.c:642). Phase 4 asks: are the MONO/UNISON
allocators reachable, and is the hardwired POLY correct?

## Finding — the value-tree cannot engage the sub-modes (measured)

1. **Cold recall keeps POLY.** Recalling a MONO factory patch (e.g. patch 5) and
   playing a 3-note chord sounds **3 voices** on the plugin (voices 5,6,7 gated) —
   POLY behaviour, not MONO (which would sound 1 voice). Measured directly on the
   binary. So the patch's stored ASSIGN MODE is NOT pushed into the live allocator
   by recall.

2. **The value-tree ASSIGN MODE leaf is a no-op on the allocator.** Dispatching the
   ASSIGN MODE value-tree leaf (engine param 800, leaf 58) = 1 (MONO) or = 2
   (UNISON) to all 9 units + snap_all leaves the allocator object's mode cell at
   **0** (unchanged), and a subsequent chord still sounds POLY (3 voices). The
   value-tree stores the parameter for patch save/display; it does not drive the
   live `CAssignJu60` allocator mode.

The allocator reads its mode from its own object state, updated only by the
front-panel KEY ASSIGN switch's control path (a `CAssignJu60` setter RVA), which
is NOT exposed through the VST3 parameter/value-tree interface a host drives.

## Disposition

- **The port's hardwired POLY is correct for the ENTIRE parameter-driven surface.**
  Every state a host can reach — patch recall + any parameter automation — leaves
  the plugin allocator in POLY, which the port matches. Proven bit-exact for all
  64 factory patches (including the 14 MONO + 2 UNISON) across the 203-seed corpus
  (random chords) and the exhaustions.
- **MONO / UNISON / POLY-variant are reachable only via the front-panel KEY ASSIGN
  switch**, whose `CAssignJu60` mode-setter path is not yet mapped. The port
  retains `mono_note_on` / `unison_note_on` / `poly_note_on(variant=1)` for that
  future selector. Verifying them (allocator state-diff + audio A/B against the
  plugin's setter) is deferred to the front-panel-editor surface (task #86), where
  the setter RVA is mapped and driven.

## Gate G4 impact

The "allocator sub-modes" half of Gate G4 is resolved by scoping: no parameter/
recall path engages the sub-modes, so nothing in the plugin's automatable surface
is left unverified. The remaining Gate-G4 work is the **arp thread-pool splice**
(direct arp-audio A/B), tracked separately. The sub-mode allocators themselves
move to #86 with the mapping+A/B method specified above.

## Repro

`tools/verify/` — recall a MONO patch, chord, count gated voices; dispatch leaf
800 and re-check the allocator mode cell (assign object +16). Both shown inline in
the Phase-4 session log.
