# DEVICE-SIDE RECALL — the design, the three defects, and their fix
(design 2026-08-11; **all three defects CLOSED 2026-08-12**, and closing them
found a defect in the SHIPPING port)

---

## ⚑⚑ THE ADVERSARIAL ROUND, 2026-08-12 — THREE MORE FATAL DEFECTS, ALL IN THE GATE'S OWN COVERAGE, ALL NOW FIXED AND TOOTHED

Two independent skeptics executed the gate and broke it three ways. All three
findings were **CONFIRMED BY RE-EXECUTION** here, not accepted on report; the
numbers below are this session's own runs.

**F1 — THE LIVE-EDIT SEQUENCE WAS DEAD, TWICE OVER, so 384 of 1,152 cases were
byte-identical duplicates of another 384.** `edit()` was called with BLOB ids
35/54/38 where it took a BINDINGS INDEX (`juno_param_count()` is 31, so all
three returned at the first line), and the calls sat BEFORE a recall that
overwrites every cell an edit touches. MEASURED on the gate's own
`host_trunk.bin`: 384 of 384 SEQ_EDIT records identical to their SEQ_WARM twin.
Effective coverage was 768, not 1,152, and **END_GOAL item 5 — live parameter
control — had ZERO coverage.**
FIX: the expansion rule now lives ONCE, in `juno_apply_param_leaf`
(`src/juno_apply.c`), which `gui/juno_bridge.c` and the gate both call — the
duplicate copy is what drifted. The gate selects by BLOB (what a panel has) and
**aborts** on an unresolvable one; the sequence is now `A→edit→B→edit`, so the
second edit is the knob move. MEASURED after: **384 of 384 SEQ_EDIT records
DIFFER**, and a new `LIVE EDIT` section fails the gate if they ever stop.
The bridge refactor is PROVEN identity: 3 rates × 10 patches × 31 params × 16
bytes, hashing all 8 voices' whole per-voice block, `ddbcd95c049c7ba3` both
sides; toothed (replicate from voice 2 instead of 1 → `780a09b71a7311e3`).

**F2 — A KNOB TURN MADE THE MAP MISS, and `eb_recall.c`'s own rule mutes on
that.** Replaying the port's per-voice replication literally on the device is
42 writes to per-voice offsets the map does not carry. REPRODUCED HERE, exactly:
**84 accesses, 42 distinct offsets — cells 624, 6736, 10240, 10256, 10272,
10288 × voices 1..7**, only one of the 31 bindings (cell 592) being a scatter
cell.
FIX, and it is at the source rather than in the map: the replication is
**redundant** on a shared tile. `ebdev_broadcast_cell()` broadcasts exactly the
cell that moved and only if it is a scatter cell; everything else is already
served by the tile. It deliberately does **not** blanket-drop per-voice writes —
a caller writing DIFFERENT values per voice at a non-scatter offset is defect 2
again and must still miss, and it does, because this path never touches the map.
MEASURED after: **unmapped accesses = 0 with the live edit running**, host vs
device bit-identical over all 1,152 cases. Two teeth: `JUNO_TOOTH_EDIT_PORTLOOP`
(the defect as reported → dev half refuses) and `JUNO_TOOTH_NO_EDIT_BCAST`
(drop the broadcast → 384 cases differ).

**F3 — `EBDEV_NV=6`, THE FORK'S OWN VOICE COUNT, WAS NOT A WORKING
CONFIGURATION AND NO GATE BUILT IT.** REPRODUCED: **82 accesses, 22 distinct
offsets — voices 6 and 7's whole scatter, including cell 320, the ADSR gate.**
Defect 2, reintroduced by a build flag. The 1,152-case comparison could not see
it: at `EB_NUM_VOICES=6` only six voices are READ, so the coefficients still
matched **0 of 1,152 differing** — the tooth fires through the unmapped counter
alone.
FIX: **the scatter row count is the PORT's voice count, not the fork's.**
`ebdev_scatter_slow` derives the row from the port offset, so a row index IS a
port voice number, and `src/juno_apply.c:478/:500/:814` write all eight
unconditionally. `EBDEV_NV` now defaults to the generated `EBDEV_NVPORT` and
`-DEBDEV_NV=6` **refuses to compile**; `EB_NUM_VOICES > EBDEV_NV` refuses too.
It costs 96 bytes and buys the thing END_GOAL item 2 will need: the same image
is addressable by a board owning ANY subset of the port's voices.
**And the gate now runs the fork at `-DEB_NUM_VOICES=6`** — it had printed
`EB_NUM_VOICES=8` under the heading "shipping fork" at every run.

**Also closed in the same round, each with its own measurement:**
- **The D1 table was not measuring the fields it named at the fork flags.**
  `warm_vs_cold` sliced at the literals 10564/1704 — the TRUNK's struct sizes —
  so at the fork both the `render_coefs` and the `master_coef` columns were
  reading inside `eb_render_coefs`. That, and only that, is the "D1 inverts
  under the fork flags" anomaly. Sizes now come from the binary that wrote the
  file, and **the table is identical at both flag sets**: factory 44/119,
  synthetic 192/15.
- **The boot image had two producers and nothing compared them.** The device
  cannot run the port's boot — `src/chorus_init.c` is 2,971 raw
  `*(_DWORD *)(a1 + N)` stores plus pointer walks, which no cell map can rebase
  — so it is baked and flashed. The gate now builds
  `tools/engineb/devboot/bootgen.c` (what the FIRMWARE carries) and requires its
  bytes to equal the gate's own gather: **BIT-IDENTICAL at 44,100 / 48,000 /
  96,000**, toothed by baking at 88,200. Its cost is now in the size section:
  **30,252 B of flash per sample rate**, on top of the 30,272 B array.
- **The boot exchange is self-describing.** A packing disagreement between the
  two halves used to surface as a short read and a refusal — which reads as a
  tooth firing. It is now a named `BOOT LAYOUT MISMATCH` and exit 3, which the
  gate reports as a HARNESS ERROR and never as a verdict.
- **A second publish, and the FX-pipe deferral, had never executed.** The route
  latch's whole justification is a DELAY TYPE change ACROSS publishes and the
  section planted the previous id by hand. It now publishes twice and requires
  the mirrors to carry the id the FIRST publish DERIVED. `EB_RECALL_FX_PIPE`
  appeared nowhere but its own `#if`; the gate now builds the publish section
  with it on. **21 of 21 checks.**
- **Step 7c saved the DCO's per-sample half by naming five fields.** With
  `-DEB_DCO_RECIP=1` the struct grows `rm1`/`rp1` in that same group and the
  hand list dropped them. It is now the struct's own boundary,
  `EB_DCO_PERSAMPLE_BYTES = offsetof(eb_dco_coef, lvl_saw)`.
- **`build/devrecall` had no interlock and it cost a false FAIL.** OBSERVED
  here: one run from a clean tree printed FAIL with `old-1b`/`old-5b` firing as
  "EXPECTED NOT TO FIRE AND IT DID" and `old-5a` NOT CAUGHT, while two serial
  runs on either side PASSED and agreed line for line. There is a lock file now.

**REFUTED, with a measurement rather than an argument:** `tools/engineb/devboot/`
is **tracked** (`git ls-files` lists all three files; added in `cdabfe9`), and
the third copy of the recall sources, `esp32s3/main/gen_recall/`, was **deleted**
in `8c61f67`. The device sources are also no longer a Python text rewrite — the
rebase is `-DEB_DEVCELLS` in the checked-in files, so the gate and the firmware
compile the same bytes.

---

## ⚑ STATE AS OF 2026-08-12 — READ THIS BEFORE THE 08-11 TEXT BELOW

The three defects listed further down are **FIXED AND GATED**. The 08-11 text
is kept because its evidence is still the evidence; where it disagrees with
this block, this block wins.

**What now exists in the repo, not in a scratchpad:**

| file | what it is |
|---|---|
| `engine_b/dev/ebdev.{h,c}` | the device cell array and `ebdev_at()`. Fast path is a `static inline` literal chain; the cold paths, the reference TABLE form and an exhaustive chain-vs-table self-test are in the .c |
| `engine_b/dev/ebdev_seg.h`, `ebdev_map.h` | GENERATED. Still a literal binary-search chain, never a loop |
| `engine_b/dev/eb_recall.{h,c}` | **the publish contract**, steps 1-8, in the shims' own order |
| `tools/engineb/gen_devcells.py` | the generator for the two headers |
| `tools/engineb/devrecall_gate.py` + `devrecall/gate.c` | THE GATE, runnable standalone |

**The gate now runs 1,152 cases per flag set** — 3 sequences (cold, warm A→B,
A→edit→B→edit) × 3 rates × 64 patches × {factory, nibble-randomised synthetic}
— at trunk defaults AND at the shipping fork flags, and it **ISSUES NOTES**
across every voice and runs `eb_render_state_seed` and
`eb_render_events_mirror`. Those were the two holes that hid defects 2 and 3.
Result: **BIT-IDENTICAL over 1,152 cases at both flag sets, for both the
instrumented map and the shipping inline-chain map, unmapped accesses 0.**

**D1 — WARM.** The gate's cases are SEQUENCES and its reference for a warm
case is **the same sequence on the host**, never a cold recall. That is the
right reference because warm ≠ cold is the plugin's own behaviour: the plugin's
state differs in **50 of 64** consecutive pairs while its AUDIO differs in
**0 of 64**. **And chasing it found a defect in the shipping port**: EFFECT
TYPE 2 (chorus I) writes the chorus LFO rate cell **91152** in the plugin and
did not in the port (`src/chorus_recall.c`). PROVEN by isolated dispatch of the
plugin's own index-873 setter under Unicorn at four rates. From a cold engine
the missing write is the IDENTITY, which is why every gate in this repo passed
it. Warm, after a chorus II patch, a chorus I patch keeps chorus II's LFO rate
— **1.71× too fast** — and `src/master_render.c:2783` reads that cell every
sample. Ten factory pairs are ET3→ET2. Fixed, with its own tooth
(`-DJUNO_TOOTH_NO_ET2_LFO`), and MEASURED both ways: **0 of 384 cold cases
change** (the 57/57 seal is untouched) and **72 of 768 warm cases do**.

**D2 — PER-VOICE.** The scatter is **twelve cells, not five**: the five
recall-time ones plus the seven the note path writes (304 pitch, 320 the ADSR
gate, 592 porta gate, 1856 held, 6864 / 9680 velocity, 9824 gate twin). The aux
retrigger latch needs nothing — all eight voices' copies already sit inside a
non-voice segment. `ebdev_at` routes scatter cells for **every** voice
including voice 0, whose copies live in `scat[0]` and never in the tile, and
`ebdev_broadcast_scatter()` is the device's `juno_driver_seed_voices`.
A dense per-voice tile was measured and rejected: the twelve offsets span
[304, 10324) to hold 48 bytes, so the smallest covering prefix is the whole
10,688-byte block — 2.8× the array, not a simplicity trade.

**ARRAY SIZE, compiled not computed:** `ebdev_state` = **30,176 B at 6 voices**
and **30,272 B at 8**. The twelve-cell scatter costs **+168 B at NV=6** over
the broken five-cell one. Replicating the whole block per voice would be
83,324 / 104,700 B.

**D3 — PUBLISH.** `engine_b/dev/eb_recall.c` implements the contract: build
into the SHADOW bank; assert quiescence; swap the pointer (master coefficients
deliberately one block late under `EB_RECALL_FX_PIPE`); force all five delay
route-latch mirrors; refresh `rev_wipe` and `rev_pending[]`; refresh
`gate_cell320[v]` per voice and CONSUME the aux one-shot; clear
`dco_live_seeded` for sounding voices and refresh the at-rest voices'
`dco_live` **field-wise** (a whole-struct copy sets their `inc` to 0 and stops
them free-running); release barrier. **13 of 13 contract checks pass and every
step has a tooth that fires.**

**PATCH FORMAT: `EB_PATCH_BYTES` is 133**, not 127 and not the 132 the design
said — record 506 needs 507 too, so BEND GAIN costs two bytes.
`eb_patch_record_coverage()` is the net, `eb_patch_selftest()` calls it, and
the recall-affecting position list was **RE-MEASURED** this run:
`devrecall_gate.py --patch-scan` perturbs all 4,080 positions in [16,4096) over
six base patches and finds **112** that move the recalled coefficients;
`EB_RECALL_POS[]` matches all 112. Dropping a carried byte is CAUGHT.

**WHAT IS STILL NOT PROVEN, and it has not moved:** both halves of the gate are
the same host compiler on the same sources, so this proves the address map and
the publish contract and **nothing about Xtensa**. Not one instruction of
recall has executed on the chip. Nothing here has been listened to. And the
sentence that still goes first: **chip B cannot recall while it plays, because
chip B is over budget.**

Two honest NOT-CAUGHT teeth, both reported by the gate rather than dropped:
deleting a **COLD** segment (18 of 32 are never reached, 4,272 B of fat) and
regenerating at `--gap 64` (the gap only decides how much dead space is
carried; every touched cell stays covered at any gap — and at gap 64 the array
is **28,536 B at NV=6**, 1,640 B smaller, bit-identical, unadopted only because
fewer segments means a shorter chain).

Also corrected while building this: the 08-11 gate's first tooth ("move one hot
segment") was **firing for the wrong reason** — the host half gathers its boot
image THROUGH the generated table, so a tooth that regenerated the map and
rebuilt only the device half fired on a boot-image packing mismatch. Every
map-regenerating tooth now rebuilds both halves. That is what turned the
cold-segment tooth from a false CAUGHT into an honest NOT CAUGHT.

---

## THE ONE SENTENCE (2026-08-11, as written then)

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
