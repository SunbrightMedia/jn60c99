# EMBEDDED ROADMAP — the honest big picture (2026-07-31)

> ## ⚑ P1 IS CLOSED. SILICON NUMBERS EXIST (2026-08-01, Daisy Seed, user's board)
>
> The whole document below was written while the SILICON row of the label table
> was empty. It is no longer empty. Read this box before trusting any estimate
> further down.
>
> | quantity | SILICON | what the doc assumed |
> |---|---|---|
> | SysClk | **400 MHz** | 480 MHz |
> | budget @48 kHz | **8,333 cyc/sample** | 10,884 @44.1k |
> | 8 voices + FX | **93,288 cyc/sample → 11.19× OVER** | MODELED 30–42k; "honest band" 18–42k |
> | 0 voices (idle floor) | **85,137 cyc/sample** | — |
> | 4 voices | **84,560** | — |
> | D-cache ON vs OFF | **1.05×** | E3 existed because this might dominate |
> | AXI vs SDRAM, scattered | **6.26×** | — |
> | golden corpus on M7 | **8/8 BIT-EXACT** | PROVEN under qemu only |
>
> **Three conclusions follow immediately, and they close P2.**
>
> 1. **The measurement is 2.2× worse than the worst case we modeled.** The
>    "honest band" of 18–42k was optimistic by more than a factor of two. Every
>    INFERRED "N× over" claim below is understated.
> 2. **Reducing polyphony does not help.** The idle floor is 85,137 of the
>    93,288 — **91%**. Cutting 8 voices to 4 saves 9%, not 50%. The plugin
>    free-runs all 8 voices every sample by design, so "fewer voices" was never
>    a lever. This kills the cheapest escape route in the plan.
> 3. **Memory placement cannot close the gap.** E3 measures the D-cache as worth
>    only 1.05×, so the engine is not SDRAM-latency-bound, and relocating hot
>    state into internal RAM has at most 5% to give against an 11.19× deficit.
>    E4's 6.26× scattered-access penalty is real but is not what dominates.
>
> Boosting the H750 to 480 MHz buys 1.2× and leaves 9.3× over. There is no
> combination of clock, polyphony and memory placement that reaches 1.0×.
>
> **Track B's STOP rule S1 does NOT fire.** S1 abandons Track B if `F + 8V` fits
> the Teensy budget or if a bit-exact 4-voice Daisy is acceptable. Neither holds:
> a 4-voice Daisy is still 10.1× over, and the Teensy at 816 MHz has an
> 18,503 cyc/sample budget against 93,288 cycles of measured work — ~5× over,
> even before its slower memory. Track B (sonic identity instead of
> bit-exactness) is now the only remaining path to 8 voices on this class of
> part, and it must find better than 10×, which no listed lever approaches.
>
> **Unexplained, and flagged rather than smoothed over:** E3 reports 287,075
> cyc/sample for the same nominal 8-voice workload that E2 measures at 93,288 —
> a 3× discrepancy between two measurements in the same run. E3's *ratio* is
> internally consistent and is what conclusion 3 rests on, but its absolute
> numbers are not reconciled with E2's and must not be quoted until they are.
>
> Raw log: the user's first full run, 2026-08-01. E1/E2/E4 numbers above are
> SILICON. Everything else in this document keeps its original label.

*Written after a week in which the embedded verdict swung from "1.5× over" to
"maybe fine" to "3–4× over" to "hopeless." The swings were the mess. This
document fixes the method, corrects the record, and lays out the plan. It is
the LIVE WORK ORDER for the embedded track.*

## 0. Label discipline (the rule that prevents another whiplash week)

Every performance number carries one of these labels, highest to lowest trust:

| label | meaning | examples so far |
|---|---|---|
| **SILICON** | measured on the target hardware | **none exist yet — this is the whole problem** |
| **MEASURED** | measured on real hardware, wrong ISA | x86 bench: 14,500 cyc/sample; gprof 83.9% voice |
| **MODELED** | a pipeline simulator on real compiled code | llvm-mca M7: 30–42k cyc/sample band |
| **STATIC** | instruction/cell counts from objdump/source | M7 3,518 instrs/voice; 61% scratch stores |
| **INFERRED** | arithmetic on any of the above | every "N× over" claim in this repo |

Standing rules, effective now:
1. **No optimization work before a SILICON number exists.** Every lever tried
   this week was aimed at a MODELED target that could be off 2× either way.
2. No unlabeled cycle claims in docs, commits, or chat.
3. Every pilot/transform ends with a **fresh build** + gate run — twice this
   week a stale binary (prebuilt `tests/test_teensy_golden`, then a stale
   `libjuno.so` after a failed compile) produced a **false green**. The gates
   were right both times; the artifact under test was old.

## 1. What is DONE — the mountain already climbed

Nothing below invalidates any of this. The port itself is the product:

- **Bit-exact engine, sealed:** render A/B 57/57 @44.1k+48k+88.2k, fuzz 24/24
  (seed-15 MONO retrigger regression found and fixed), exhaustive recall 0
  mismatches ×3 rates, arp 7/7+7/7, cold-state 5 rates, assigner 28/28,
  PROVENANCE 20/20 PROVEN.
- **Bit-exact on ARM:** 8/8 golden hashes identical on ARM32 (qemu), clean
  bare-metal Cortex-M7 compile (373 KB), libm parity proven (expf glibc==newlib
  over 32,000,423 inputs), 32-bit pointer bug found & fixed, stack 584 B.
- **Working webapp** (WASM==native gate), **Daisy firmware that builds and
  links** (`daisy/`, self-playing, E1–E5 instrumentation), Teensy firmware
  written (`teensy/`, never compiled against Teensyduino).
- **Memory truth:** a voice = 10,512 B + 164 B shared noise. 8 voices = 86 KB.
  Full-FX hot set ≈ 1.14 MB inside a 10.5 MB span (delay lines at 2.2/4.3/6.4 MB
  offsets, reverb ~10.7 MB). Chorus lives entirely in the low ~102 KB block
  (region map from the recall sources). Daisy SDRAM covers everything; PSRAM on
  Teensy is only needed for the full-FX build.

## 2. The record, corrected

The week's wrong or shaky claims, fixed in one place:

1. **"The decompiler materialised MSVC register temps; we built a memory-bound
   caricature" — WRONG framing.** Hex-Rays does not invent stores. The 202
   scratch stores per voice-sample are in **Roland's own x86 binary**. The
   desktop engine is store-heavy because on a desktop OoO core with store
   buffers that is free (x86 measured IPC-equivalent ~1.67). On an in-order M7
   it is not. Consequence: scratch elimination is still a *legitimate*
   bit-exact optimization (the cells provably don't carry across samples), but
   it is optimizing Roland's code for a smaller core — not undoing our own
   damage — and the fair comparison point is that **the Boutique JU-06A never
   ran this code.** It runs Roland's separate embedded engine, 4 voices, and is
   itself NOT bit-exact to the plugin. A 4-voice bit-exact Daisy would exceed
   the commercial product's fidelity.
2. **The llvm-mca 2.15× calibration transfer (x86 → M7) is INFERRED,** not a
   measurement. Additional slack the model ignores: it charges **both sides of
   every branch** (~200 branches/voice; on x86 only ~56% of static instructions
   actually execute per call — 1,500 cyc × 1.67 IPC ≈ 2,500 executed of 4,439
   static). Executed-path M7 arithmetic at plausible silicon IPC 0.7–1.0 lands
   at **~18–25k cyc/sample** — versus the calibrated model's 30–42k. The honest
   union band is **~18–42k**, which is exactly why only SILICON settles it.
3. **Pilot-2's "IPC unchanged" was a non-result,** not a refutation: it removed
   65 loads from a 3,252-instruction static stream and read the aggregate
   static IPC. The scratch hypothesis is unproven in both directions.
4. **Hoisting is 2.8%** (measured statically, ceiling 17.4%), **idle-voice skip
   is 25.2% per silent voice and 0% at full polyphony** — both real
   measurements that stand.

## 3. The constraint triangle — the one decision that is the user's

**{Daisy Seed @480 MHz} + {8 voices + all FX} + {bit-exact} — pick two.**

Even the *optimistic* end of the band (~18k vs budget 10.9k @44.1 kHz) leaves
Daisy-480 ~1.7× over for 8v+FX, and the known-safe levers total ~30–40%
(triangle LUT ~11%, FTZ 2.4%, 44.1 kHz +8.8%, placement, scratch elimination
10–20% M7-specific INFERRED). The pessimistic end is 4× over. There is no
identified path that closes 1.7×–4× on this board bit-exact.

| option | keep | give up | cost | confidence |
|---|---|---|---|---|
| **A** | Daisy + bit-exact | voices: ship 2 (safe) – 4 (plausible) | ~CAD $41 | HIGH for 2, MEDIUM for 4 |
| **B** | 8v+FX + bit-exact | the Daisy: Teensy 4.1 @816 MHz | ~CAD $60 (board+PSRAM) | **ON THE BUBBLE** — optimistic band fits, pessimistic doesn't |
| **C** | Daisy + 8v+FX | bit-exactness (Track B rewrite) | weeks + quality risk | user has rejected, rightly |
| **D** | decide later | nothing yet | ~CAD $41 | — |

**Option D is the recommended first step regardless of the eventual choice**,
because H750 (Daisy) and RT1062 (Teensy) are the *same Cortex-M7 core*: one
SILICON measurement of cycles/voice and the floor on a $41 Daisy prices **every**
M7 option at once — including whether B's bubble bursts or holds, and whether A
means 2, 3, or 4 voices. Perspective for option A: the real JUNO-60 is 6-voice,
the JU-06A Roland sells today is 4-voice.

## 4. The plan

### P0 — STABILIZE (now; no hardware; mostly this session)
1. ✅ full end-to-end `make verify` (first complete run since the MONO-retrigger
   fix). RE-RUNNING after items 2/3/5 below: every `tools/verify/*.py` is an
   ORACLE_DEP, so editing any gate correctly invalidates all cached reference
   pickles and they regenerate from `truth/`.
2. ✅ **DONE** — `assigner_ab` gained patch 15 (MONO) and the `warmmono` script:
   the fuzz seed-15 sequence verbatim, including its **747-sample warm-render
   prefix**. That prefix is the load-bearing part: `juno_init` arms the DCO
   retrigger latch at BUILD, so on a cold engine a missing re-arm is invisible
   and every cold gate in the repo is structurally blind to it. 17 cases/rate,
   34 runs. The gate now also refuses a reference pickle built for a different
   case set instead of silently comparing a subset.
3. ✅ **DONE, two holes, both with teeth demonstrated** (commit 956784a):
   - *header prerequisites*: no build rule listed `src/*.h`, yet the constant
     TABLES live in headers (`juno_tables.h`, `chorus_luts.h`, `effect_luts.h`,
     `finefx_tables.h`, `carp_patterns.h`, `hpf_type_lut.h`) — a coefficient
     edit touching only a header rebuilt NOTHING and every gate reported green
     on the old constants. Every rule now depends on `$(HDR)`; recipes use
     `$(filter %.c,$^)`. Verified by touching a header and watching the relink.
   - *stale library*: `tools/verify/freshlib.py` — the 13 port-side gates load
     libjuno through it, and it refuses any library older than `src/*.c`,
     `src/*.h` or `gui/juno_bridge.c`. `__file__`-relative, so a worktree gates
     its own library (the `coldstate_ab` sharp edge). Teeth: touching
     `src/voice_render.c` makes `port_state_dump.py` exit STALE-GUARD.
4. Rebuild + wasm_golden + republish the webapp — **the published artifact
   predates the MONO retrigger fix**, which audibly affects all 14 MONO factory
   patches. Sequenced AFTER the verify run is green (do not ship on an unproven
   engine).
5. ✅ **DONE** — `tools/embed/arm_golden.sh` runs inside `make verify`. Its
   exit 3 ("MISSING: <tool>") prints SKIP and is explicitly labelled *not a
   pass*; any other non-zero exit fails the gate.
6. ✅ CLAUDE.md truth-up (done with this document).

Also landed alongside P0: `make juno_cand.so` — the Track B candidate engine,
where `native/<x>.c` replaces `src/<x>.c` by filename. With `native/` empty it
is a byte-identical twin of the sealed engine and `tools/trackb/null_ab.py
--cand` reports **EXACTLY 0** on all five scenarios, which is the comparator's
own passthrough proof.

### P1 — MEASURE (needs the ~$41 board; one afternoon)
Flash `daisy/` (bootloader ≥v6.0 first: `make program-boot`). Read three things:
- **E1:** golden corpus on silicon. 8/8 = the engine is bit-exact on the
  target. (Everything pre-verified off-device; failure checklist is in
  `daisy/README.md` — do not tune anything.)
- **E2:** DWT cycles at 0/1/2/4/8 voices → **V** (cycles/voice) and **F**
  (floor: master+triangle+overhead). These two numbers replace every estimate
  in this repo.
- **E3/E4:** D-cache on/off + SDRAM vs AXI walk → whether memory placement
  matters at all on this workload.

### P2 — DECIDE (one hour, with P1 numbers; decision table pre-written)
Budget `B_board = clock / rate`. Max bit-exact voices = ⌊(B − F) / V⌋.
- Daisy 480/44.1k: B=10,884 → voices_daisy.
- Teensy 816/44.1k: B=18,503 → if F + 8V ≤ 18,503 → **option B is real: buy
  the Teensy, 8-voice bit-exact JUNO, done.**
- If F + 8V ≤ 10,884 → the model was very wrong and Daisy-8v works after all.
- Else pick A (ship voices_daisy on Daisy) or B-with-optimization: apply the
  ladder below only if it closes a measured gap ≤ ~40%.

### P3 — BUILD OUT (per the P2 branch)
- **Optimization ladder, in order, only against a SILICON gap:** triangle LUT
  (exhaustive-sweep-proven, ~11% STATIC) → hardware FTZ (2.4%) → ITCM/DTCM
  placement → AST-based scratch elimination (needs a real C parser — pycparser/
  libclang, NOT regex; pilot-3's regex approach failed to parse; prize 10–20%
  M7-specific, INFERRED). Each step: fresh build + full gates.
- **Product work (either board):** UART MIDI in, patch selection, startup UX
  around the 4 s warm-up, offline-init state blobs (init on PC, `memcpy` on
  target) if boot time matters.
- **Parked:** #146 in its regex form (superseded by the AST plan above);
  Track B (option C) unless the user reopens it.

### Parallel track — DAW-parity fidelity (independent of embedded)
#141 (HOSTPATH STEP 2–5), #124 (bounce residual), #140 (ASSIGN 3 gate). The
"sounds exactly like my DAW" work continues whenever, unaffected by any of the
above.

## 5. One-paragraph summary for a tired human

The port — the actual months of work — is finished, sealed, and bit-exact,
including on ARM. What failed this week was *estimation*, not engineering: five
different desk methods gave answers from 1.5× to 4× over, which is exactly what
desk methods do. The only remaining question is a number no amount of further
analysis can produce: cycles per voice on a real M7. It costs ~$41 and an
afternoon, the firmware for it already builds, and it prices every option at
once — including the live possibility that the 8-voice bit-exact machine works
on a $60 Teensy, and the guarantee that at minimum a JU-06A-beating 2–4-voice
bit-exact Daisy exists. Nothing is lost; one measurement decides everything.
