I have the evidence I need. Here is the design.

---

# Device-Side Preset and Parameter Recall — Complete Design

**Status: the mechanism is BUILT and GATED on the host this session. Evidence is in `/tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad/cells/`.**

## The sentence that matters

**Device recall works, and it is now PROVEN and not estimated: a 29,352-byte cell array with a 31-segment address map and ONE shared voice block, driven by the port's own unmodified recall code, produces coefficients BIT-IDENTICAL to the 11 MB host path over 384 cases (64 patches x 3 rates x factory-and-synthetic), at BOTH trunk defaults and the shipping fork flags — and the burst that does it is small enough for chip A to absorb inside one audio block.**

Two things must change before you build it. The compact patch format is **five parameters short**, and the resonance table that both earlier readers put in the burst is **not in the burst at all**.

---

## 1. The design

### 1.1 The shape

```
132 patch bytes ─┐
                 ├─► juno_bank_apply (VERBATIM)  ─► 29 KB CELL ARRAY ─► eb_render_coefs_build ─► coefficients
4 KB flash       ┘   + FX recall (VERBATIM)          (internal SRAM)     eb_master_coefs_build    (double buffered)
template record
```

Both ends stay the proven code. Only the **address space between them** is new.

### 1.2 The cell array — MEASURED, not estimated

The port's array is 11 MB. Engine B's builders and the port's recall together touch a tiny, tightly clustered part of it. I enumerated it two ways and took the union:

| source | result | label |
|---|---|---|
| Executed trace: patched `JF`/`JI` in a copy of `src/`, 64 patches x 3 rates x 3 trials | **343 distinct cells** touched by recall | PROVEN |
| Static scan of every constant in `src/*.c`, `src/*.h`, `engine_b/eb_*.c` in cell range | 1,241 non-voice candidates | READ |
| `CF(a1,·)` / `CF(base,·)` constants in `eb_coefs.c`, `eb_master_coefs.c` | 286 voice-relative, 721 absolute | READ |

The factory bank alone found **321** of the 343 cells. Randomising every record nibble found **343**. So 22 cells are invisible to the factory bank. This repeats the cell-map reader's lesson exactly, and it is why the generator must never use the factory bank alone.

The touched set falls into **one voice tile plus 31 small segments**:

| region | port offsets | device bytes |
|---|---|---|
| voice tile (native offsets, ONE copy) | `[0, 10688)` | 10,688 |
| 31 non-voice segments (dense, rebased) | `84272 … 11022352` | 18,488 |
| per-voice scatter, 5 floats x N voices | see 1.4 | 120 (6 voices) |
| **total** | | **~29,300** |

### 1.3 New files

| file | contents |
|---|---|
| `engine_b/dev/ebdev.h` | `ebdev_state` (the array), `ebdev_at()`, `ebdev_voice_select()`, `ebdev_trap()` |
| `engine_b/dev/ebdev_seg.h` | GENERATED. `EBDEV_VTILE`, `EBDEV_NSEG`, `EBDEV_SEGBYTES`, the segment table |
| `engine_b/dev/ebdev_map.h` | GENERATED. `EBDEV_MAP_BODY` — a literal-constant binary-search chain |
| `engine_b/dev/ebdev_boot.h` | GENERATED. The baked post-`init`+`prepare` image, one per rate |
| `engine_b/dev/eb_recall.c` | `eb_recall_apply()`, `eb_recall_param()`, `eb_recall_publish()` |
| `engine_b/dev/eb_patch132.h` | the 132-byte format (see 1.6) and the flash template record |
| `tools/engineb/gen_devcells.py` | the generator for all four generated headers |
| `tools/engineb/devrecall_gate.py` | THE GATE (section 4) |

### 1.4 The address map

```c
static inline void *ebdev_at(unsigned long off)
{
    if (off < EBDEV_VTILE) {              /* voice 0 and cell 16 — NATIVE */
        if (off == 1072u)  return &EBS.scat[0][0];
        if (off == 3968u)  return &EBS.scat[0][1];
        if (off == 5520u)  return &EBS.scat[0][2];
        if (off == 7600u)  return &EBS.scat[0][3];
        if (off == 10320u) return &EBS.scat[0][4];
        return EBS.v0 + off;
    }
    if (off < 84272u) return ebdev_scatter(off);   /* voice v > 0 */
    EBDEV_MAP_BODY                                 /* 31 segments, literal binary search */
miss:
    ebdev_trap(off);                               /* HARD FAILURE, never a silent sink */
    return EBS.v0;
}
```

**The five scatter cells are the whole per-voice story, and I proved it structurally, not statistically.** The recall writes exactly **54 voice-0 cells** plus exactly **five per-voice sites** — `1072`, `3968`, `5520`, `7600`, `10320`. Nothing else is ever written per voice. `juno_driver_seed_voices` is a memcpy of voice 0 and becomes a **no-op** on the device, because there is only one voice block.

This **confirms the two-chip reader and strengthens it**. That reader compared built coefficients over 448 pairs and found 4 differing floats. I find the same 4, plus a fifth write site — `1072`, the LFO tempo baseline (`src/juno_apply.c:815`), which writes the **same value** to all 8 voices. So "four floats differ" is correct. It is now true by construction, not by a survey of 64 patches.

### 1.5 Three call classes, and how each is handled

| class | count per recall | handling | Xtensa cost |
|---|---|---|---|
| constant offset (`JF(state, 6736)`, `CF(a1, 2864)`) | most | GCC folds `EBDEV_MAP_BODY` to one load | **4 instructions**, MEASURED |
| runtime offset (`BINDINGS[i].offset`, `FILT[k]`, the reverb tap loop) | ~150 | out-of-line `ebdev_at` | ~35 on the taken path |
| raw pointer cast (17 sites) | 17 | rewritten to `ebdev_at` | as above |

The fold is MEASURED, not hoped for. `xtensa-esp-elf-gcc -O2 -mlongcalls` compiles a constant-offset read to:

```
entry a1,32 / l32r a8,<EBS> / l32i a2,a8,228 / retw.n      = 4 instructions
```

That is the same code a flat 11 MB array would give. **The segment map costs nothing at a constant offset.** An array-loop version does NOT fold — it costs 27 instructions and 14.2 probes. The literal chain is load-bearing and the generator must emit it.

**The 17 raw-cast sites must be rewritten** (13 in `delay_recall.c:388-408`, 1 in `reverb_recall.c:288`, 1 in `effect_modes.c:51`, 2 in `juno_driver.c:50-51`, plus `eb_chorus_shim.c`'s `ld`/`ldi` and `eb_master_coefs.c:749`'s reverb-seed cast). They bypass `JF`/`JI`, so no accessor audit sees them. My trace missed them for exactly that reason and the build then crashed on a wild pointer. That is the right failure. The trap must keep it that way.

### 1.6 The patch format must grow from 127 bytes to 132

I measured which record byte positions change the recalled cells. Method: perturb each of 20,223 positions to three values, over 6 factory patches and 6 synthetic patches with every nibble randomised.

**123 record positions affect recall. 118 are among the 127 the compact patch carries. FIVE ARE NOT:**

| record | blob | parameter | value in all 64 factory patches |
|---|---|---|---|
| 506 | 490 | BEND GAIN (`src/juno_apply.c:447`) | 0 |
| 3286 | 3270 | CHORUS PRE DELAY (`src/finefx_recall.c:175`) | 20 |
| 3287 | 3271 | CHORUS LOW CUT (`src/finefx_recall.c:174`) | 2 |
| 3288 | 3272 | CHORUS HIGH CUT (`src/finefx_recall.c:173`) | 13 |
| 3950 | 3934 | REVERB DENSITY (`src/finefx_recall.c:149`) | 10 |

All five are constant across the factory bank. That is exactly why the byte-scan that produced the 127-byte format could not see them, and it is the same blindness `eb_patch.h`'s own header warns about. The claim "64/64 bit-exact" survives. **END_GOAL item 5 does not.** The moment a user turns CHORUS HIGH CUT, a 127-byte patch cannot store it.

Forcing those five to non-factory values changes **8,807 bytes** of built coefficients. The hole is real and it is measured, not argued.

**EB_PATCH_BYTES goes 127 -> 132.** The nine currently-carried-but-unread bytes (arpeggiator and F ENV VARIATION) stay; they are read by `juno_bank_arp` and by engine B, not by `juno_bank_apply`.

### 1.7 The template record

`juno_bank_apply` reads record positions **30 … 3952**. The device keeps:

* a **4,096-byte const template** in flash (patch 0's record body, positions 0..4095), and
* a **4,096-byte RAM working record**.

At each recall the firmware copies the template into the working record and writes the 132 patch bytes over it. `juno_bank_apply` then runs verbatim against that record through a 6-line wrapper that skips the bank indexing. RAM cost is 4 KB. `ebdev_trap`'s twin, `ebdev_rec_guard`, refuses a read past 4,095 so the measured bound cannot silently become wrong.

### 1.8 Where each piece runs in the firmware loop

```
app_main
  boot:  ebdev_boot_load(SR)          load the baked image into the cell array
         eb_vcf_res_prepare(&LUT)     ONE resonance table, shared (section 3.2)
         eb_recall_apply(patch)       first patch, before I2S starts
         print the boot banner

  per block (render_block(CHUNK)):
         eb_recall_pump()             <-- NEW. Runs at most BUDGET instructions
                                          of pending recall work, into the
                                          INACTIVE coefficient buffer.
         render_block(CHUNK)          reads *RC_ACTIVE only
         eb_recall_publish_if_ready() one pointer swap at the block boundary
         i2s_channel_write(...)
```

`eb_recall_pump()` is the only new call in the audio path. It is placed **before** `render_block` so that a block which overruns its recall budget still renders. It returns immediately when there is no pending work.

---

## 2. Memory

| item | bytes | where | note |
|---|---|---|---|
| cell array `ebdev_state` (6 voices) | **29,304** | internal SRAM | MEASURED, `sizeof` |
| RAM working record | 4,096 | internal SRAM | |
| coefficient buffer A (6 voices) | 15,892 | internal SRAM | `eb_render_coefs` 14,188 + `eb_master_coef` 1,704, MEASURED |
| coefficient buffer B (double buffer) | 15,892 | internal SRAM | |
| **RAM subtotal** | **65,184** | | 40 % of the 163 KB the listen firmware prints free |
| shared resonance LUT (hoisted, section 3.2) | 1,028 | internal SRAM | replaces 6 copies |
| baked boot image, ONE rate | 29,336 | **flash** | MEASURED |
| flash template record | 4,096 | flash | |
| factory bank, 132 B x 64 | 8,448 | flash | |
| recall code + tables | ~210,480 | flash | MEASURED, Xtensa `-O2 -mlongcalls`; `juno_curve.c` is 126,444 of it |

**PSRAM impact is ZERO.** Every recall structure is internal SRAM. This is a design choice and it removes the largest unmeasured term in the earlier burst estimate — the 32,000-160,000 cycles of PSRAM line-fill. Nothing in the burst touches PSRAM.

**Hoisting the resonance LUT saves 5,140 bytes per buffer, i.e. 10,280 bytes across the double buffer.** Section 3.2 proves it is legal.

The listen firmware also **loses 1.69 MB of embedded coefficient blob** (`esp32s3/main/s3_listen.bin`) and its 4 MB app partition can shrink. That releases flash for the user bank.

---

## 3. The burst strategy

### 3.1 The one structural fact that makes it safe

`eb_engine_render` and `eb_engine_render_voices` take `const eb_render_coefs *c`. They never see the cell array. (`eb_render.h:261, 320, 328, 331`.) A half-written cell array is not being listened to. Only the **publish** must be atomic, and one pointer swap at a block boundary achieves it.

So: **build into the inactive buffer over as many blocks as you like, then swap.** There is no partial-patch audio, no zipper on a sweep, and no split reverb tap array. The joint-set analysis the burst reader did is correct but is not needed, because double buffering makes it moot.

### 3.2 The resonance table is NOT in the burst — this corrects both earlier readers

`eb_render_coefs_build` calls `eb_vcf_res_prepare` per voice (`eb_coefs.c:208`). It fills 257 entries, each an `ebr_tail()` evaluation of 236 static Xtensa instructions plus `eb_exp_fork` (122) plus libgcc calls. Six voices of that is roughly 460,000 instructions. It would dominate everything.

It does not have to run. Two measurements:

1. **The table is identical in every voice. 2,688 of 2,688 comparisons, 0 different**, over the 384 gate cases at the shipping flags. Reason, from the source: `ebr_tail` reads only `k7856 … k8192`. The only per-voice-distinct field of `eb_vcf_res_coef` is `k7600`, used at `eb_vcf_res.c:211`, outside the tail.
2. **No parameter moves it. ZERO of the 123 recall-affecting record bytes change cells 7856..8192**, over 4 patches x 123 positions x 3 values. Those cells come from `juno_engine_init`/`juno_engine_prepare` and are a function of **sample rate only**.
   *Control, so the result is not vacuous:* the block DOES change with rate — 44,100 gives 0.007836172, 48,000 and 96,000 give 0.003599741.

**Consequence: build the table ONCE at boot, or bake it (1,028 bytes per rate in flash). It leaves the recall path entirely, and it leaves five of six per-voice copies out of the coefficient struct.**

### 3.3 The numbers

Stage A, patch bytes to cells:

| term | instructions | label |
|---|---|---|
| port recall, 64 patches, 44.1 kHz | 4,710 – 6,379 (mean 5,012) | PROVEN (burst reader, static x gcov) |
| address translation, constant sites | 0 | PROVEN (the fold, Xtensa `-O2`) |
| address translation, ~150 runtime sites x ~35 | ~5,250 | INFERRED from the measured 343-instruction body |
| **stage A pessimistic** | **12,000** | |

Stage B, cells to coefficients:

| term | instructions | label |
|---|---|---|
| `eb_render_coefs_build`, 6 voices | 10,121 | PROVEN (burst reader) |
| `eb_master_coefs_build` | 1,728 | PROVEN (burst reader) |
| resonance LUT | **0** — moved to boot (3.2) | PROVEN this session |
| **stage B pessimistic** | **16,000** | |

| | instructions | cycles at c/i 1.35 – 1.60 |
|---|---|---|
| measured arithmetic | 28,000 | 37,800 – 44,800 |
| **PLANNING NUMBER** | — | **90,000 cycles = 0.375 ms** |

**Use 90,000 cycles.** It is 2x the top of the measured band. The justification is this project's own record: seven of eight estimates were wrong and six flattered themselves. The doubling covers instruction-cache pressure in a code path that runs rarely and is therefore always cold, and the `entry`/`retw` window overflows a rare path provokes.

### 3.4 Where it runs, and what it costs

| chip | spare cycles per 5.805 ms block | burst at 90,000 cycles |
|---|---|---|
| chip A, lighter core (1,800 cyc/sample spare) | 460,800 | **one block, 20 % of the spare** |
| chip B (539 cyc/sample OVER budget) | negative | **impossible in any number of blocks** |

**Recall runs on chip A. This is not negotiable and no amount of spreading changes it — you cannot divide by a negative.** Chip B receives the 132 bytes and builds its own coefficients only if and when it has headroom. Until it does, the design that works is: **chip A builds, and chip B gets the patch bytes with an apply-at-sample-index and builds during a deliberately quiet moment** — or the split moves so chip A owns the FX and both voice groups sit on the chip with headroom.

That is a real constraint and it goes on the record now, not later: **with chip B 539 cycles over budget, chip B cannot recall while it plays.**

### 3.5 The pump

```c
/* Runs at the top of every block on chip A. Never blocks. */
void eb_recall_pump(void)
{
    switch (RCL.stage) {
    case RCL_IDLE:    return;
    case RCL_CELLS:   eb_recall_apply_cells(&RCL);   RCL.stage = RCL_VOICES; return;
    case RCL_VOICES:  eb_recall_build_voice(&RCL, RCL.v++);        /* one voice per block */
                      if (RCL.v == EB_NUM_VOICES) RCL.stage = RCL_MASTER; return;
    case RCL_MASTER:  eb_master_coefs_build(0, &RC_BACK.m);  RCL.stage = RCL_READY; return;
    case RCL_READY:   return;                        /* publish() swaps at the boundary */
    }
}
```

Eight steps at worst. Eight blocks is 46.4 ms of latency between the knob and the sound — inaudible as a delay, and it costs **at most 3 % of chip A's spare per block**. If you want it faster, run the whole thing in one block; the numbers above say it fits. **The pump exists so the answer does not change when someone raises `S3_VOICES` or the FX move.**

Latency is unchanged. The pump adds no DMA cushion and no pipeline stage.

---

## 4. THE GATE

**The requirement: the device's coefficients must be bit-identical to the host's for the same patch bytes. The gate below executes that, and it has already caught a real defect.**

### 4.1 Host half — `tools/engineb/devrecall_gate.py`, in `make verify`

It builds two programs from ONE tree and compares their output byte for byte.

| | reference | candidate |
|---|---|---|
| cell array | the port's 12 MB block | `ebdev_state`, 29,304 B |
| recall | `juno_bank_apply` + `seed_voices` + scatter | the same, `seed_voices` removed |
| builders | `eb_render_coefs_build`, `eb_master_coefs_build` | the same, through `ebdev_at` |
| output | `eb_render_coefs` + `eb_master_coef`, raw | the same |

Cases: **64 patches x 3 rates x {factory bank, synthetic bank with every record nibble randomised} = 384**, run at trunk defaults AND at `-DEB_FORK_S3 -DEB_LFO_SHARED=1 -DEB_VCF_RES_LUT=256`.

**Result, executed this session:**

```
DEVICE path done. cell array = 29352 B  unmapped accesses = 0 (last off 0)
RES LUT across voices: 2688 IDENTICAL, 0 DIFFERENT
*** BIT-IDENTICAL over 384 cases ***          (both flag sets)
```

### 4.2 It can fail, and here is the measurement

| tooth | result |
|---|---|
| move ONE hot segment's placement by 4 bytes | **CAUGHT** — 190,424 bytes differ |
| flip 1 ULP in one scatter cell on voice 3 | **CAUGHT** — 384 bytes differ |
| set the five uncarried record bytes to non-factory values | **CAUGHT** — 8,807 bytes differ |
| route voice-0's scatter cells through the shared tile | **CAUGHT** — 2,582 bytes differ |
| delete a COLD segment from the map | **NOT CAUGHT**, and the gate says so |

The fourth tooth is a defect **the gate found**, not one I planted. Voice 0's five scatter cells must live in `scat[0]`, not in the shared tile. If they live in the tile, `ebdev_voice_select(v)` writes voice v's value over voice 0's recalled one, and what survives is whatever the **boot image** held. Cells 1072 and 5520 came back at their post-`prepare` defaults — 8.735357 and 1.55e-4 — on 330 and 381 of 384 cases. A rendered null gate would have shown this as a wrong LFO rate and a wrong detune, and it would have been diagnosed as a DSP fault.

The fifth tooth is the honest one. **17 of 31 segments are cold under this gate.** They come from the static scan. The gate cannot prove they are needed and it cannot prove they are correct. They stay, because they cost 4,600 bytes and they are the margin against a parameter the gate does not move. **The firmware prints the cold count, so the fat is visible.**

### 4.3 Device half — the gate must reach silicon

A host gate does not prove the device. So:

1. `devrecall_gate.py --emit-crc` writes `tools/engineb/devrecall_crc.h`: CRC32 of `eb_render_coefs` and `eb_master_coef` for all 64 patches at the build's rate and flags.
2. The firmware computes the same CRC32 after every recall and prints it.
3. `--verify-serial` reads the board's serial output and compares.

The CRC covers the **OUTPUT**, never the 132 input bytes. Hashing the input cannot catch a wrong binary, and a wrong binary is the failure this exists for.

### 4.4 What the firmware prints

Boot banner:

```
=== JUNO ENGINE B — S3 RECALL FIRMWARE ===
image  sha256 3f9a1c02…   role A (strap GPIO_x = 0)   rate 44100
flags  EB_FORK_S3 EB_LFO_SHARED=1 EB_VCF_RES_LUT=256 EB_NUM_VOICES=6
cells  29304 B  segments 31 (17 cold at build gate)  boot image crc 0x8e21b40c
recall code 210480 B flash   free internal 133912
RES LUT: built once, rate-only, shared by all voices   crc 0x5c1120af
```

Per recall:

```
RECALL p=32  bytes crc 0x11aa20de  coef crc 0x7d40e18b  mcoef crc 0x0a91c2f4
       burst 6 blocks  cycles 41208/88117/52990 (min/max/last)  unmapped 0
```

Failure lines, and each is a **hard stop**, never a shrug:

```
RECALL: UNMAPPED CELL 0x00a72e10 -- THE MAP IS INCOMPLETE. Instrument muted.
RECALL: RECORD READ PAST 4095 (off 5120) -- template bound wrong. Instrument muted.
RECALL: COEF CRC 0x7d40e18b != host 0x7d40e19c for patch 32 -- MUTED.
RECALL: PEER COEF CRC MISMATCH (A 0x7d40e18b, B 0x9911c02f) -- MUTED.
```

Muting is correct. A wrong coefficient is a wrong instrument, and a wrong instrument that plays is worse than one that stops and says why.

---

## 5. The build increments

Each step is independently gated and independently useful. **Step 0 is host-only and takes no board time.**

### Step 0 — the gate, before any firmware
Add `engine_b/dev/`, the generator, and `devrecall_gate.py` to `make verify`.
**Gate:** 384 cases bit-identical at both flag sets; 4 teeth CAUGHT, 1 declared NOT CAUGHT; zero unmapped.
**Useful because:** it makes every later step falsifiable. It also commits the tooling. The scratchpad dies with the container, and the cell-map reader's own unknown list already says this.
**Done: this session.** The result above is the executed output.

### Step 1 — the baked boot image replaces the frozen blob
Firmware loads `ebdev_boot.h`, builds coefficients for ONE hardcoded patch, prints the CRC.
**Gate:** the printed CRC equals `devrecall_crc.h`. The board sounds the same as the previous blob build.
**Useful because:** it deletes 1.69 MB of embedded blob and the whole `s3_listen_meta.h` layout-mismatch class. The `S3L_*` size checks, `ms_load`'s member-by-member copy and the stale-blob failure mode all go away.
**Flag:** `S3_RECALL=1`.

### Step 2 — 64 factory patches, selectable
132-byte factory bank in flash. A button steps through it. `eb_recall_pump` and the double buffer land here.
**Gate:** all 64 CRCs match the host. Underrun counter stays 0 across 64 consecutive patch changes. Printed burst cycles stay under 90,000.
**Useful because:** the instrument plays the whole bank. This is the first build that is an instrument and not a render engine.
**Flag:** `S3_RECALL=1 S3_BANK=1`.

### Step 3 — eight encoders on eight parameters
Take eight **single-cell BINDINGS rows** (`src/juno_apply.c:168-282`) — VCF CUTOFF, VCF RESONANCE, VCF ENV MOD, DCO PWM, LFO RATE, ENV A/D/S/R. Each is one `juno_curve` lookup and one cell write. A detent runs `eb_recall_param()` and re-runs only stage B.
**Gate:** for each of the eight, sweep all 256 byte values on the board and compare the CRC against a host sweep. 2,048 comparisons.
**Useful because:** this is the step the user asked for. It is playable, and it is eight knobs, not 79.
**Flag:** `S3_RECALL=1 S3_ENC=8`.

> A detent does **not** need the resonance table (section 3.2) and does not need `juno_apply_condition`. Cost is stage B alone. **Measure it on the board and print it** — do not subtract it from the full burst.

### Step 4 — every parameter, and the format grows to 132 bytes
All BINDINGS rows, the discrete block, the extended params, the FX recall, HPF joint recompute, and the **five newly-found bytes**.
**Gate:** the 384-case gate, plus a per-parameter full-byte sweep, plus a new `eb_patch_coverage()` assertion that every one of the 123 recall-affecting record positions is carried.
**Useful because:** END_GOAL item 5 is met on one chip.

### Step 5 — persistence
Factory bank const in flash. User bank in a dedicated data partition. Program-only appends. **Erases never lazy** — schedule them at boot or in an explicitly silent menu state, never on the play path. Prefer an I2C FRAM on chip A if "no stuttering whatsoever" is to be literal.
**Gate:** 200 save/load cycles with the codec running, underrun counter 0, CRC preserved.
**Useful because:** the user can keep a sound.

### Step 6 — patch distribution to chip B
Section 6.
**Gate:** the peer CRC exchange; 1,000 patch changes with no mismatch and no underrun on either chip.

---

## 6. What recall REQUIRES of the two-chip link

The link is a separate job. Recall imposes exactly six requirements.

1. **Carry 132 bytes, never coefficients.** The coefficient block is 15,892 bytes against 132 — a factor of 120 — and a coefficient that arrives over a link is a coefficient whose correctness depends on the link instead of on a gate.
2. **Carry a 32-bit APPLY-AT SAMPLE INDEX with every patch message.** Both chips swap their coefficient pointer at that index. This makes the change atomic across chips. Set the index at least **4 blocks ahead** (23.2 ms) so a chip that spreads its burst still finishes.
3. **Exactly-once, in-order delivery, with loss DETECTED.** The CRC exchange in requirement 5 does the detection.
4. **A per-recall back-channel of 12 bytes:** coefficient CRC32, master CRC32, and the apply index.
5. **A boot-time exchange of the firmware image hash and the sample rate.** A mismatch mutes. `EB_HALF_OS`, `EB_DCO_WT`, `EB_CR_ALL`, `EB_NOLIBM` and `EB_VCF_MAPFAST` all leave the coefficient block bit-identical while changing the per-sample arithmetic — so equal coefficient CRCs do **not** prove equal firmware. Only the image hash does.
6. **A GLOBAL voice index per chip.** The four scatter floats index `COND_TUNE_SCAL[v]`, `COND_FINE_SCAL[v]`, `COND_GAIN_SCAL[v]` and `UNISON_3968[v]` by the global index (`src/juno_apply.c:466-506`). Chip B must map its voices to indices 4..7, not 0..1, or the two chips detune. My measurement makes this exact and small: it is 4 floats per voice and nothing else.

**No per-sample traffic. Recall adds none.**

---

## 7. The risks

| # | risk | what it does | control |
|---|---|---|---|
| R1 | **The map is incomplete for a parameter value no gate reached.** 343 cells and 123 record positions are both LOWER BOUNDS — 64 factory plus 128 synthetic patch instances, single-byte perturbation. | A cell lands in `SINK`, a coefficient is silently wrong, the instrument is subtly detuned. | `ebdev_trap` is a hard mute and a printed offset. The static scan over-includes on purpose. The generator refuses a map built from the factory bank alone. |
| R2 | **17 cold segments are unproven.** | Fat, or a wrong rebase that nothing exercises. | The gate prints the cold list. The firmware prints the count. Do NOT delete them to tidy the map. |
| R3 | **No Xtensa execution of recall exists.** Every cycle number here is static instructions x host execution counts, times a c/i band. | The burst is larger than 90,000. | Step 1 prints min/max/last burst cycles from `esp_timer` on the board. The planning number is falsified or confirmed on the first flash, not argued. |
| R4 | **Cross-binary float determinism is untested on the target.** The two-chip reader tested host optimisation levels, not two Xtensa images. | The two chips build different coefficients from the same bytes. Voices detune. | One image flashed twice, role from a strapping pin. Then equality is a hash comparison, not an argument. Requirement 5 above. |
| R5 | **`eb_render_events_mirror` is ungated** (`eb_coefs.c:360`). It writes BACK into the cell array at `:378`. | A note event corrupts a coefficient cell. | Not on the recall path in this design. Give it its own gate before the device relies on it. Carried forward from the cell-map reader, unchanged. |
| R6 | **The 4,096-byte template bound (positions 30..3952) is measured, not proven.** | A recall reads past the RAM record. | `ebdev_rec_guard` refuses and prints. |
| R7 | **Chip B cannot recall while it plays** (539 cycles over budget). | A patch change on chip B drops audio, or never happens. | Stated in section 3.4. It is a headroom problem, not a recall problem, and recall must not be asked to hide it. The 2/1 voice split and the FX-chip layout are the levers. |
| R8 | **A flash erase stops both cores** (ESP-IDF disables cache and busy-loops the other core). | An audible gap on save. | Erases never lazy. Program-only appends on the play path. I2C FRAM if "no stuttering whatsoever" is literal. From the storage reader, unchanged and correct. |

---

## 8. Corrections to the four readers

| reader | claim | correction | evidence |
|---|---|---|---|
| cell map | 4,817 words / 19,268 B for 8 voices | **29,304 B**, but with ONE voice block instead of 8 and a 31-segment dense map. The packed-array form needs a compile-time index at every site; a dense segment map needs none, because GCC folds it. The larger array buys verbatim source. | `sizeof(ebdev_state)`, and the 4-instruction Xtensa fold |
| cell map | mover count 992 is a lower bound | Confirmed. Recall touches **343** cells, 321 from the factory bank and 22 only from synthetic patches. | executed trace, 3 trials |
| burst | full preset recall 4,710–6,379 instructions | Confirmed, and it is the right number for stage A. Add ~5,250 for runtime-offset translation. Constant-offset translation is **free**. | Xtensa `-O2` disassembly |
| burst | cells→coefficients is 10,121 + 1,728 | Correct **only with the resonance LUT off**. At the shipping flag `EB_VCF_RES_LUT=256` the LUT would add ~460,000 instructions. It does not have to run at all. | `eb_coefs.c:208`, 2,688/2,688 identical, 0/123 parameters move it |
| two chips | exactly four floats differ per voice | Confirmed, and now structural: recall writes 54 voice-0 cells plus **five** per-voice sites, of which `1072` carries the same value to every voice. | executed trace, `src/juno_apply.c:815` |
| two chips | `eb_vcf_res_prepare` is 39,107 instructions per voice, "the expensive half of the build" | It is a **boot** cost, not a recall cost, and it is one build, not six. | section 3.2 |
| two chips | ship 127 patch bytes | Ship **132**. Five parameters are missing. | 8,807 bytes of coefficients change |
| storage | 24 KB NVS, program-only appends, FRAM preferred | No correction. Adopted as written. | — |

---

## 9. What is NOT proven

* No recall code has executed on Xtensa. Every device cycle figure is static x host.
* The 343-cell set and the 123-position set are lower bounds under single-byte perturbation.
* 17 of 31 segments are never touched by the gate.
* Cross-binary float determinism on two Xtensa images is untested.
* `eb_render_events_mirror` has no gate.
* Nothing here has been listened to.

**Against END_GOAL: this design delivers item 5 on one chip, and it does not cost item 4 on chip A. It does not deliver item 5 on chip B, because chip B has no headroom to recall in. That sentence belongs at the top of any status report that follows this work, not at the bottom.**