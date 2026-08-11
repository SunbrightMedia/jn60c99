# DEVICE-SIDE RECALL — the design, and the three defects that broke it
(2026-08-11, Opus 5 + a 7-agent workflow: 4 readers, 1 designer, 2 refuters)

**READ THIS PAGE BEFORE BUILDING ANY OF IT.** The design below is real work and
most of it holds. Both refuters returned **BROKEN**, and they are right. Build
the corrected version, not the design as written.

Evidence lives beside this file in `data/devrecall/`. The workflow ran in a
scratchpad, and a scratchpad dies with the container, so the load-bearing
artifacts are copied into the repo: the address map, the two halves of the
gate, the touched-cell list, and every refutation probe.

---

## THE ONE SENTENCE

**Device recall is possible, and the hard part is measured: the port's own
11 MB cell array reduces to about 29 KB with a 31-segment address map, the map
costs ZERO instructions at a constant offset, and the recall burst is about
90,000 cycles — which chip A can absorb inside ONE audio block.**

**And the design as written cannot play a note.** Three defects, all found by
refuters who were told to break it, all measured against the repo's own code:

| # | defect | why it is fatal |
|---|---|---|
| 1 | **Warm recall is not cold recall.** Patch A then patch B does not equal patch B alone. Coefficients differ in **24 of 64** pairs, master coefficients in **41 of 64**. | The device recalls warm. The gate recalls cold. The design's own rule — CRC mismatch means MUTE — stops the instrument on the second patch change. |
| 2 | **Per-voice state is unmapped.** Only five per-voice cells are in the map. The engine reads about forty per voice, including **cell 320, the ADSR gate**. | Voices 1 to 5 cannot sound a note. The trap fires on the first chord. |
| 3 | **`eb_render_events_mirror` is on the recall path and WRITES into the cell array.** The design says it is not. | The "nobody listens to the cell array" argument, which the whole double-buffer plan rests on, is unsound as stated. And nothing clears `dco_live_seeded`, so after a patch change the DCO stays on the OLD patch while everything else moves. |

Defect 1 is the largest. It is not a defect in the design at all — it is a
property of the PORT, and therefore of the plugin, that nobody had measured.
**Which of those two it is has not been established, and it must be, before
any device CRC table is generated.**

---

## WHAT THE DESIGN GOT RIGHT, AND IT IS MOST OF IT

Each of these was attacked and survived. The refuter says so in its own words.

**The address map is free.** A constant-offset cell read compiles to four
Xtensa instructions — `entry / l32r / l32i / retw.n` — for the voice tile and
for the deepest segment alike. That is the same code a flat 11 MB array gives.
The refuter regenerated the map and reproduced the result independently. An
array-loop form does NOT fold and costs 27 instructions, so the literal
binary-search chain is load-bearing.

**The cell array is about 29 KB, not 11 MB.** 343 distinct cells are touched by
recall, in one voice tile plus 31 small segments. All of it fits in internal
SRAM. **PSRAM is not touched by the burst at all**, which removes the biggest
unmeasured term from the earlier estimate.

**The burst fits.** About 28,000 instructions measured, and a planning number
of 90,000 cycles set at twice the top of the band, because six of this
project's eight estimates flattered themselves. Chip A's lighter core has
460,800 spare cycles per block. **The burst is 20 % of ONE block.**

**The resonance table leaves the burst entirely.** `eb_vcf_res_prepare` is
about 460,000 instructions for six voices and would dominate everything. It
does not have to run: the table is **identical in every voice** (2,688 of 2,688
comparisons) and **no parameter moves it** (0 of 123 recall-affecting record
bytes), because it is a function of sample rate alone. Build it once at boot.
This corrects `data/res_lut.md:99`, which says a shared table would be wrong.
The refuter checked the source and confirms the design, not the old note.

**No libm anywhere in recall.** Zero `expf`/`logf`/`powf`/`fmodf` sites in the
thirteen recall files. `juno_curve` is a clamp plus a table punned back to
float. So no picolibc-versus-glibc difference can reach a coefficient.

**Recall code is about 210 KB of flash**, of which `juno_curve.o` is 126,444
bytes. The refuter built the objects for Xtensa and got 216,276. Within 3 %.

**No ring churn on a patch change.** The nine delay-ring lengths are ONE
distinct set over all 64 factory patches AND over a fully randomised synthetic
bank. This attack was expected to land and did not.

**The compact patch format is five bytes short, and the finding is real.**
BEND GAIN (record 506), CHORUS PRE DELAY / LOW CUT / HIGH CUT (3286-3288) and
REVERB DENSITY (3950) change the recalled coefficients and are NOT carried.
All five are constant in all 64 factory patches, which is exactly why the
byte-scan that produced the 127-byte format could not see them, and exactly
the blindness `eb_patch.h`'s own header warns about. Forcing them to
non-factory values changes **8,807 bytes** of built coefficients.
**`EB_PATCH_BYTES` must go 127 -> 132.** The "64/64 bit-exact" claim survives.
END_GOAL item 5 does not.

---

## THE GATE THAT EXISTS

`data/devrecall/gate_host.c` and `gate_dev.c` build two programs from one
tree. The only difference is the address map. Cases: 64 patches x 3 rates x
{factory bank, synthetic bank with every record nibble randomised} = **384**,
at trunk defaults AND at the shipping fork flags.

    DEVICE path done. cell array = 29352 B  unmapped accesses = 0
    RES LUT across voices: 2688 IDENTICAL, 0 DIFFERENT
    *** BIT-IDENTICAL over 384 cases ***          (both flag sets)

**Teeth, measured:**

| tooth | result |
|---|---|
| move one hot segment by 4 bytes | CAUGHT, 190,424 bytes differ |
| flip 1 ULP in one scatter cell on voice 3 | CAUGHT, 384 bytes differ |
| set the five uncarried record bytes to non-factory values | CAUGHT, 8,807 bytes differ |
| route voice 0's scatter cells through the shared tile | CAUGHT, 2,582 bytes differ |
| delete a COLD segment from the map | **NOT CAUGHT**, and the gate says so |

The fourth was **found, not planted**. The fifth is the honest one: 17 of 31
segments are never touched by the gate. They stay, they cost 4,600 bytes, and
the firmware must print the cold count so the fat stays visible.

**⚠ THE GATE PROVES THE REBASE, NOT THE DEVICE.** Both sides are built by the
same host compiler from the same sources. It is a complete proof that the
31-segment map is correct and complete FOR COLD RECALL, and a proof of nothing
about Xtensa. The design's headline said "device recall works ... PROVEN"; the
refuter is right that the headline over-claims what section 9 already conceded.

**And the gate never issues a note.** That is how defect 2 stayed invisible.
The gate calls `juno_bank_apply` and the two builders, and never calls
`eb_render_state_seed` or `eb_render_events_mirror`. The fourth tooth found
the per-voice hazard once; the harness stops one step short of the place that
hazard recurs.

---

## THE CORRECTIONS THAT MUST LAND BEFORE ANY FIRMWARE

1. **A WARM CASE IN THE GATE.** Recall a SEQUENCE — A, then B; and A, then a
   parameter edit, then B — and compare against the same sequence on the host.
   First settle whether the port's non-clobbering recall is the plugin's own
   behaviour or a port defect. CLAUDE.md already records one warm-recall root
   cause in this exact area.
2. **PER-VOICE STATE IN THE MAP.** Cell 320 above all, plus the env, VCA,
   glide, resonance and LFO state offsets. About 40 floats x 6 voices is under
   1 KB, so this is cheap. The alternative is to state that engine B's own
   note path replaces `eb_render_events_mirror`, and to gate that.
3. **THE PER-VOICE SCATTER SET IS THIRTEEN CELLS, NOT FIVE.** The note path
   writes eight more: 304 (pitch), 320 (gate), 6864 and 9680 (velocity), 1856,
   9824, 592 (portamento gate) and the aux latch 101504+32v. Six of the eight
   are read back per voice by the builder. With ONE shared tile every sounding
   voice takes the LAST note's pitch and velocity.
4. **WRITE THE PUBLISH SEQUENCE OUT.** Swap the pointer; make it visible to
   core 1; clear `dco_live_seeded`; refresh `gate_cell320` and `aux_edge`.
   Without the third the DCO stays on the previous patch — an audible, bisected
   instrument on every program change.
5. **RUN THE BURST IN ONE BLOCK BY DEFAULT.** The pump spreads a build over up
   to 8 blocks and the cell array is single-buffered, so a second knob move
   inside 46 ms splits the chord: voices 0-2 on the old value, voices 3-5 on
   the new. Two detents in 46 ms is ordinary playing. The numbers say one
   block fits; keep the pump only as the fallback for a raised voice count.
6. **MEASURE IT ON XTENSA.** Not one instruction of recall has executed on the
   chip. Print min/max/last burst cycles from the first flash. That is Step 1's
   gate, not a footnote.

---

## THE LARGER GAP: A RENDER ENGINE IS STILL NOT AN INSTRUMENT

The second refuter reviewed for completeness. Its list is long and it is fair.
The design is **preset** recall. These are not in it, and every one of them is
inside END_GOAL item 5:

- **the live single-parameter edit** — the encoders themselves. It is not a
  small variant of full recall: a leaf expands to several binding rows, needs
  the patch's recalled HPF TYPE, and must NOT re-seed voices or re-apply
  CONDITION, because doing so snaps the sound on a live move mid-note.
- **the recall-time stash** — LFO rate byte, delay time/sync/type, HPF type,
  last CONDITION, host BPM. Without it, HPF, portamento and both tempo-synced
  paths are not correctly editable.
- **tempo** — no MIDI clock, no tap, no internal clock. The arpeggiator needs
  a transport that uses double arithmetic and a 64-bit divide, on a chip with
  neither in hardware.
- **continuous controllers** — pitch bend and mod wheel are a stream of 100+
  messages a second, not an event.
- **the global voice index across two chips** — CONDITION scatter and UNISON
  spread are per-voice DISTINCT. Chip B must build global voices 4..7. Nothing
  maps a chip's local slot to a global number, so today both chips would deal
  the same detune. Related and also unwritten: with 6 voices and 8 CONDITION
  scalars, WHICH six the fork keeps is an audible decision.
- **the edit buffer** — without it, "save" saves something the user is not
  hearing.
- **system parameters** — MASTER TUNE is not one of the 132 bytes, so the
  instrument cannot be tuned.
- **FX re-initialisation** on a patch change that switches DELAY TYPE or
  EFFECT TYPE.
- **a rendered comparison.** Nothing here has been listened to. The
  coefficient-byte gate is the right primary standard, but only a
  recall-then-render null covers the state seed, the rings, the publish
  boundary and the note path at once.

---

## AGAINST THE SIX END-GOAL ITEMS

| item | this work |
|---|---|
| 1 audibly identical | **not advanced.** No rendered audio was compared. |
| 2 exactly two boards | **not advanced.** Chip B has no headroom to recall in. |
| 3 full FX | **not advanced.** FX re-init on a patch change is unwritten. |
| 4 seamless real time | **not advanced, and one new fact:** the burst fits on chip A in one block. It does not fit on chip B at all. |
| 5 every parameter | **half advanced.** Preset recall is designed and gated cold. Live parameter edit is not designed. The patch format is five bytes short and now we know which five. |
| 6 confidently proven | **advanced.** A 384-case gate exists, executes, has five measured teeth, and found a defect it did not plant. |

**The sentence that goes first in any status report that follows: chip B
cannot recall while it plays, because chip B is over budget. Recall must not
be asked to hide a headroom problem.**

---

## FULL TEXT

The complete design and both refutations are preserved verbatim:

- `data/devrecall/DESIGN_full.md`
- `data/devrecall/REFUTATIONS_full.md`
