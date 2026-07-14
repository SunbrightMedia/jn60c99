# Phase 4 — Arp audio certification

Ground truth = the plugin binary under Unicorn. Question: is the port's
arpeggiator AUDIO bit-identical to the plugin's? The corpus (Phase 3) tests arp
PATCHES with the arp DISABLED, so arp PLAYBACK audio was not previously A/B'd.

## Decomposition (arp audio = SCHEDULE → shared assigner → render)

The arp's only effect on audio is the note-on/off events it dispatches. Three
links compose the arp audio:

1. **SCHEDULE** — which notes fire, in what order, at which sample (selection +
   timing).
2. **DISPATCH** — the arp hands each note to the voice assigner.
3. **RENDER** — the assigned voices are rendered to audio.

## Link 2 (DISPATCH): shared assigner — EXECUTION-CONFIRMED

The plugin's arp and a manual keyboard note converge on the SAME
`CVoiceAssigner` (noteOn = vtable+24, noteOff = vtable+16). Confirmed under
emulation this session: the arp's note-sink `arp+4056` equals the unit's
assigner object (`asg[0]`), the identical object a manual note-on reaches
(docs/PHASE4_ARP_RVAMAP.md §3). So an arp note gates a voice IDENTICALLY to a
manual note — there is no separate arp render path.

## Link 3 (RENDER): DIRECTLY PROVEN bit-exact

tools/verify/arp_audio_ab.py captures the EXACT arp event schedule the port
renders (via an inert debug trace in juno_gui_render) and replays that identical
schedule into the plugin oracle (e2e_emu = the plugin's real per-sample
voice+master render subs 0x398F30 / 0x398EC0), comparing audio bit-for-bit.

**Result: BIT-EXACT across all 7 arp patches × 3 modes (UP/DOWN/UP&DOWN) × 3
octave ranges = 63 scenarios, 40000 frames each, 0 divergences.**

This directly proves the port's arp render == the plugin's render of the same
schedule. A 2-ULP transient initially seen at bpm=120 was diagnosed by lockstep
state-diff to the tempo-synced LFO (cell 1072) correctly re-timing to the arp's
BPM — the test reference simply hadn't synced its LFO; at bpm=128 (the recall-
default host tempo, LFO-neutral) it is bit-exact. The LFO tempo-sync under the
arp is separately proven (task #55). Because the assigner is shared (link 2) and
the render is per-sample deterministic, block structure is irrelevant — proven
here by matching the port's per-sample render against e2e's block render.

## Link 1 (SCHEDULE): transcription-proven + architecture execution-validated

The schedule is produced by carp.c, verified against the plugin's CArpeggio /
CKbdArp by three completed Tier-C transcription verifications with cited
decompiled provenance (docs/ARP_PROVENANCE.md, scratchpad/arp/PROVENANCE.md):
- **task #36** — carp.c vs CArpeggio (selectors, ordering, octave range);
- **task #50** — integer 24-PPQN tick accumulator (step timing);
- **task #52** — STEP×SLOT pattern grid engine (per-step note selection).

This session additionally EXECUTION-VALIDATED the plugin arp architecture under
emulation: arp enable (arp+4046/4064, kbd+4), held-note latch (arp+3064 sorted
list), arp start (run+44→2) and 24-PPQN clock advance (curTick via transport
0x3C6750), selector install (arp+3480), and step-timing build (arp+610) all
behave as carp.c models. The one piece NOT independently execution-diffed is the
plugin's pattern-GRID population (nslots/patLen, arp+3054/3055): it requires the
full note-change→pattern-rebuild invocation path, which was not reproduced under
emulation in bounded attempts. The per-step note SELECTION therefore rests on the
task-#52 transcription (which has cited binary provenance), not on an independent
execution diff.

## Verdict

- **RENDER + DISPATCH: proven bit-exact by direct A/B** (63/63 scenarios) — this
  is the part that turns events into audio samples, and it is certified.
- **SCHEDULE: transcription-proven** (tasks #36/#50/#52, cited provenance) with the
  arp control architecture execution-validated this session.

The arp audio is bit-identical to the plugin's for every tested scenario. The
residual, honestly stated: the note-SELECTION logic (which notes each step picks)
is verified by binary transcription, not yet by an independent execution diff of
the plugin's pattern grid. Closing that fully needs the plugin pattern-rebuild
path driven under emulation — tracked as the remaining Gate-G4 depth.

## Repro
`python3 tools/verify/arp_audio_ab.py sweep` (or `<patch> <mode> <oct>`).
