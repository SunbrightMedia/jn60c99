# VCF / HPF / VCA — native-implementation blueprint (Track B)

Blueprint for a native (non-transcribed) implementation of the FILTER subsystem
of `src/voice_render.c`: the VCF cutoff-CV taper, the mod matrix, the
cutoff→coefficient mapper, the 4-pole ladder core with its nonlinearity and
resonance solve, the decimator, the HPF/boost stage, and the VCA/tone/output
chain that follows.

Target: `tools/trackb/null_ab.py` at −90 dB rel. Every equation below is in the
**exact float evaluation order of the transcription** — single precision, one
rounding per operation, `-ffp-contract=off` (no FMA), and the source's
parenthesisation is load-bearing.

**Provenance labels.** Almost everything here is **READ** — I read it in
`src/voice_render.c`, `src/juno_init.c`, `src/juno_prepare.c`,
`src/juno_apply.c`, `src/juno_note.c`, `src/juno_dsp.c` and cross-checked it
against `docs/trackb/CELLMAP.md`. **PROVEN** appears only where I executed
something; in this task the only execution was decoding the init/prepare
integer bit-patterns to floats with `struct.unpack` (marked PROVEN(decode)).
**INFERRED** marks every naming/DSP-identification claim (e.g. "this is
`tan`") — the *ops* are READ, the *meaning* is INFERRED.

**Line numbers** are the CURRENT `src/voice_render.c` (2185 lines, pilot-2
scratch-promotion header included). Every cite below was verified by reading
that exact line.

**Notation** (same as `ENV.md` / `CELLMAP.md`): `[N]` = the float32 cell at
per-voice offset N, `a1 = base + voice*10512`; `[[N]]` = the same cell accessed
as int32 bits. `[N]'` = the value written this sample.

---

## 1. Subsystem boundary — cells READ and WRITTEN

Classification used throughout:

- **CARRIED** — the value written this sample is read on a LATER sample. Real
  state; a native implementation must keep it.
- **SCRATCH** — written and read inside the same sample only. No carry; a
  native implementation may hold it in a register (pilot 2 already did this for
  some of them, `voice_render.c:34-54`).
- **SHADOW** — written every sample, never read by `voice_render.c` (grep-
  verified). Kept for probes / state-A/B parity only.
- **INPUT-CONST** — read-only here; written by `juno_init.c` (constructor),
  `juno_prepare.c` (setSampleRate), `juno_apply.c` (recall) or `juno_note.c`
  (note events). Never written by the render.

### 1.1 Cutoff-CV taper `[6576..6816]` (READ :1150-1169)

| cell | class | R@ | W@ | role |
|---|---|---|---|---|
| 6576 | INPUT-CONST (=0) | 1154 | — | cutoff key-CV alt input; **no writer anywhere in `src/`** |
| 6592 | SHADOW | — | 1150 | int shadow of 6576 |
| 6608 | INPUT-CONST (=0) | 1151, 1207 | — | live cutoff/bend mod source |
| 6624 | SHADOW | — | 1151 | int shadow of 6608 |
| 6640 | INPUT-CONST (=0) | 1152, 1186 | — | "Int" source of the F-ENV mix |
| 6656 | SHADOW | — | 1152 | int shadow of 6640 |
| 6672 | INPUT-CONST (=0) | 1153, 1211 | — | external LFO input (VCF) |
| 6688 | SHADOW | — | 1153 | int shadow of 6672 |
| 6704 | **SCRATCH** | 1230 | 1169 | final cutoff CV, clamped to [0,1] |
| 6720 | INPUT-CONST (=0) | 1154, 1155 | — | "Griffer SW" — no writer ⇒ 0 |
| 6736 | INPUT-CONST | 1155, 1156 | — | **VCF CUTOFF FREQ** (recall, `juno_apply.c:169`) |
| 6752/6768/6784/6800/6816 | INPUT-CONST | 1157-1160 | — | quartic taper c0..c4 (`juno_init.c:1063-1067`) |

### 1.2 Resonance + VCF velocity `[6832..6928]` (READ :1170-1175)

| cell | class | R@ | W@ | role |
|---|---|---|---|---|
| 6832 | INPUT-CONST | 1170 | — | **VCF RESONANCE** (recall, `juno_apply.c:170`) |
| 6848 | **SCRATCH** | 1231, 1570 | 1170 | same-sample bit-latch of 6832 |
| 6864 | INPUT-CONST | 1171 | — | VCF velocity target, written by note-on (`juno_note.c:196`) |
| 6880 | SHADOW | — | 1172 | z⁻¹ of 6864 |
| 6896 | **CARRIED** | 1173, 1208 | 1175 | smoothed VCF velocity (one-pole state) |
| 6912 | SHADOW | — | 1174 | z⁻¹ of 6896 |
| 6928 | INPUT-CONST | 1175 | — | velocity smoother coefficient (`juno_init.c:1068`) |

### 1.3 Mod matrix `[6944..7504]` (READ :1176-1229)

| cell | class | R@ | W@ | role |
|---|---|---|---|---|
| 6944 / 6960 | INPUT-CONST (=1.0) | 1179 | — | pitch-CV / tune-CV gains into VCF KCV |
| 6976 | **SCRATCH** | 1206 | 1179 | VCF keyboard CV |
| 6992 | SHADOW | — | 1178 | int shadow of 6976 |
| 7008 | INPUT-CONST (=0) | 1180 | — | ENV1/ENV2 select — **never recalled** (`juno_apply.c:540-562`) |
| 7024 | INPUT-CONST (=0) | 1181 | — | Int/Env mix — never recalled |
| 7040 | **SCRATCH** | 1184, 1185 | 1180 | bit-latch of 7008 |
| 7056 | SHADOW | — | 1182 | copy of 7024 |
| 7072 | **SCRATCH** | 1205 | 1186 | selected filter-env CV |
| 7088 | **CARRIED** | 1188 | 1193 | LFO-A smoother state |
| 7104 | **SCRATCH** (round-trip) | 1204 | 1189, 1194 | LFO-A smoother output — written then re-read from memory |
| 7120 / 7136 / 7152 | INPUT-CONST | 1191/1194/1192 | — | LFO-A coeff / direct-path gain (=0) / output gain (=1.0) |
| 7168 | **CARRIED** | 1195 | 1201 | LFO-B smoother state |
| 7184 | SHADOW | — | 1197, 1203 | LFO-B output copy — the consumer uses the register |
| 7200 / 7216 / 7232 | INPUT-CONST | 1199/1202/1200 | — | LFO-B coeff / direct (=0) / gain (=1.0) |
| 7248 | **SCRATCH** | 1216 | 1208 | bit-latch of 6896 |
| 7264 | SHADOW | — | 1209 | bit-latch of 6608 |
| 7280 | SHADOW | — | 1229 | total cutoff-mod sum (the consumer uses the register `v227`) |
| 7296 | INPUT-CONST (=1.0) | 1210 | — | "LFO Gain" (`juno_prepare.c:85`) |
| 7312 | INPUT-CONST (=0) | 1211, 1220, 1224 | — | Ext LFO Sw |
| 7328 | INPUT-CONST (=0) | 1212, 1213 | — | bend-source select |
| 7344 | INPUT-CONST | 1226 | — | **VCF LFO MOD** (recall, `juno_apply.c:233`) |
| 7360 | INPUT-CONST | 1222 | — | **MOD SENS VCF** = `curve22(byte)*10` (`juno_apply.c:455`) |
| 7376 | INPUT-CONST (=0) | 1223 | — | MOD SW (mod wheel, 0 at rest) |
| 7392 | INPUT-CONST | 1228 | — | **VCF ENV MOD** (recall, `juno_apply.c:199`) |
| 7408 | INPUT-CONST | 1227 | — | **VCF KEY FOLLOW** (recall, `juno_apply.c:195`, bipolar curve 24) |
| 7424 | INPUT-CONST | 1218 | — | **VCF VEL SENS** = `record_byte/255` (`juno_apply.c:681`) |
| 7440 | INPUT-CONST | 1216 | — | velocity centre offset −0.503937 (`juno_prepare.c:86`) |
| 7456 | INPUT-CONST (=0) | 1213, 1214 | — | live bend amount (0 at rest) |
| 7472 | INPUT-CONST | 1215 | — | **BEND depth VCF** (recall product, `juno_apply.c:453`) |
| 7488 | INPUT-CONST (=−4.0) | 1227 | — | KCV offset (`juno_init.c:1077`) |
| 7504 | INPUT-CONST (=8.0) | 1217 | — | velocity path scale (`juno_init.c:1078`) |

### 1.4 Cutoff → coefficient mapper `[7520..8192]` (READ :1230-1297)

Entirely inside `if ([7632] == 1.0)`; `[7632]` is 1.0 from `juno_prepare.c:87`
and has no other writer, so the else-branch (:1294-1297) is unreachable in the
port.

| cell | class | R@ | W@ | role |
|---|---|---|---|---|
| 7520 | **SCRATCH** while gate on; CARRIED in the held branch | 1296 | 1292 | ladder integrator gain `G = g/(1+g)` |
| 7536 | **SCRATCH** while gate on; CARRIED in the held branch | 1299 | 1243 | resonance drive `k` |
| 7552 | **CARRIED** | 1233 | 1241 | cutoff-dither phase (`juno_wrap24` chain) |
| 7568 | **CARRIED** | — | 1234, 1239 | dither smoother state (see the dead store at :1234) |
| 7584 | **CARRIED** (read z⁻¹ of 7568) | 1237, 1238 | 1232 | previous 7568 |
| 7600 | INPUT-CONST | 1240 | — | **CONDITION** per-voice cutoff fine trim (`juno_apply.c:481`) |
| 7616 | INPUT-CONST (=0) | 1243 | — | resonance trim; no writer (`juno_apply.c:483`) |
| 7632 | INPUT-CONST (=1.0) | 1235 | — | coefficient-update gate (`juno_prepare.c:87`) |
| 7648 | INPUT-CONST (=12.128) | 1247 | — | gain on the cutoff CV |
| 7664 | INPUT-CONST (=−0.423) | 1250 | — | cutoff sum offset |
| 7680 | INPUT-CONST (=1.0) | 1246 | — | gain on the mod sum |
| 7696 | INPUT-CONST | 1240 | — | dither gain (rate-armed) |
| 7712 | INPUT-CONST | 1238 | — | dither smoother coeff (rate-armed) |
| 7728 | INPUT-CONST (=0.1) | 1242 | — | resonance→cutoff compensation slope |
| 7744 | INPUT-CONST (=0.075) | 1249 | — | compensation clamp |
| 7760 / 7776 | INPUT-CONST | 1251 / 1252 | — | cutoff clamp hi (rate-armed) / lo (=−3.0) |
| 7792 | INPUT-CONST (=5.4) | 1243 | — | resonance drive scale |
| 7808 | **DEAD** | — | — | written by `juno_init.c:1089` (−4.75); **never read by `voice_render.c`** (grep) |
| 7824 / 7840 | INPUT-CONST | 1253 / 1254 | — | ln2 = 0.6931472 / −3.2924490 |
| 7856 | INPUT-CONST | 1273 | — | rad-per-sample scale (rate-armed) |
| 7872..8032 (11 cells) | INPUT-CONST | 1262-1271 | — | `exp` fractional-part polynomial |
| 8048..8192 (10 cells) | INPUT-CONST | 1275-1289 | — | `tan` rational (sin numerator / cos denominator) |

`8192` is written by `juno_init.c:1113` as `JI(a1, 0x2000)` and read at :1275 as
`*(float *)(a1 + 0x2000)` — the same cell, spelled differently. CELLMAP §T also
lists a read at :607; that is a **false positive** (see §1.8 item 5).

### 1.5 Ladder core + decimator `[8208..9536]` (READ :1298-1515)

Entirely inside `if ([9056] == 1.0)`; `[9056]` is 1.0 from `juno_prepare.c:88`.

**Pipeline** (7 cells, shifted at :1300-1306) — all **CARRIED**:

| cell | holds after the shift | consumed at |
|---|---|---|
| 8208 | (write-only into the shift) nonlinearity output of sub-step 4 | 1306 |
| 8224 | `x[n−1]` = previous nonlinearity output | 1365 |
| 8240 | `y1[n−1]` | 1364 |
| 8256 | `y2[n−1]` | 1367 |
| 8272 | `y3[n−1]` | 1372 |
| 8288 | `y4[n−1]` | 1375 |
| 8304 | `S` (state contribution) from the previous sub-step | 1351 |
| 8320 | `S` from two sub-steps ago (weight `[9536]` = 0) | 1353 |

Written at the end of the sample by sub-step 4: 8208 (:1466), 8224 (:1469),
8240 (:1474), 8256 (:1477), 8272 (:1482), 8288 (:1484), 8304 (:1457).

**Stage scratch** — all **SCRATCH**, already register-promoted (pilot 2,
`voice_render.c:47-52`): 8336 (:1363,1397,1433), 8352 (:1366,1400,1436), 8368
(:1371,1405,1441), 8384 (:1374,1408,1444), 8400 (:1376,1410,1446), 8416
(:1354,1387,1423). 9008 (:1349) and 9024 (:1346) likewise (`:53-54`).

**Four dispersion/decimation lines**, 8 cells each, shifted at :1307-1334 — all
**CARRIED**:

| line | head (written) | history (oldest last) |
|---|---|---|
| A | 8432 (:1488, sub-step 4) | 8448, 8464, 8480, 8496, 8512, 8528, 8544 |
| B | 8560 (:1454, sub-step 3) | 8576, 8592, 8608, 8624, 8640, 8656, 8672 |
| C | 8688 (:1419, sub-step 2) | 8704, 8720, 8736, 8752, 8768, 8784, 8800 |
| D | 8816 (:1384, sub-step 1) | 8832, 8848, 8864, 8880, 8896, 8912, 8928 |

**Input node / dither / gate**:

| cell | class | R@ | W@ | role |
|---|---|---|---|---|
| 8944 | **CARRIED** | 1335, 1347, 1383, 1386, 1411, 1418, 1453 | 1343 | VCF input drive |
| 8960 | **CARRIED** (read z⁻¹ of 8944) | 1348, 1383, 1418 | 1335 | previous 8944 |
| 8976 | **CARRIED** | 1336 | 1342 | ladder dither phase |
| 8992 | SHADOW | — | 1337 | z⁻¹ of 8976 |
| 9040 | **SCRATCH** while gate on; CARRIED in the held branch | 1568 | 1514 | **VCF OUTPUT** |
| 9056 | INPUT-CONST (=1.0) | 1338 | — | ladder render gate (`juno_prepare.c:88`) |
| 9072 / 9088 / 9104 | INPUT-CONST | 1384,1419,1454,1487 / 1382,1417,1452,1486 / 1382,1417,1452,1486 | — | −12 / −18 / −24 dB-per-octave tap gains; **0 / 0 / 1.0** ⇒ 4-pole only |
| 9120 | INPUT-CONST | 1341 | — | dither→input gain 3.86667e−5 |
| 9136 | INPUT-CONST (=0.25) | 1340 | — | input drive gain |
| 9152 | INPUT-CONST (=4.0) | 1513 | — | decimator output gain |
| 9168 | INPUT-CONST (=0.5) | 1340 | — | resonance→input-gain compensation |
| 9184 | INPUT-CONST (=−0.2) | 1362,1395,1431,1465 | — | quintic nonlinearity coefficient |
| 9200 / 9216 / 9232 / 9248 | INPUT-CONST | 1456 / 1350,1421 / 1352,1421 / 1386 | — | 1.0 / 0.75 / 0.25 / 0.5 — the 4× input interpolation weights |
| 9264..9504 (16 cells) | INPUT-CONST | 1489-1511 | — | folded 32-tap decimation FIR |
| 9520 / 9536 | INPUT-CONST (=1.0 / 0.0) | 1356,1389,1425,1459 | — | feedback taps on `S`, `S₋₁` |

### 1.6 HPF / boost / VCA output stage `[9552..10672]` (READ :1516-1640)

The envelope, velocity, mute and gate-ramp cells `9680..10032` (and `9712`,
`9776`, `9856`, `9904` in particular) are **owned by `docs/trackb/ENV.md` §2.8-
2.10**; they are consumed here and not re-derived. What this doc owns:

| cell | class | R@ | W@ | role |
|---|---|---|---|---|
| 9552 | INPUT-CONST (=0) | 1516, 1572 | — | external VCA env input; no writer in `src/` |
| 9568 | SHADOW | — | 1516 | int shadow of 9552 |
| 9584 | INPUT-CONST | 1518 | — | **VCA TONE** (recall, `juno_apply.c:200`, bipolar curve 24) |
| 9600 | INPUT-CONST | 1517 | — | **VCA VEL SENS** = `record_byte/255` (`juno_apply.c:682`) |
| 9616 | INPUT-CONST (=0.93) | 1520 | — | fixed-velocity base (`juno_prepare.c:90`) |
| 9632 | **SCRATCH** | 1614 | 1518 | bit-latch of 9584 |
| 9648 / 9664 | **SCRATCH** | 1527 / 1527,1528 | 1519 / 1520 | bit-latches of 9600 / 9616 |
| 10048 | **SCRATCH** | 1587, 1588 | 1575 | bit-latch of ENV2 out `[3232]` |
| 10064 | **SCRATCH** | 1586 | 1576 | bit-latch of `[9552]` |
| 10080 | **SCRATCH** | 1599 | 1579 | resonance level compensation term |
| 10096 | **CARRIED** | — | 1584 | HPF one-pole LP state |
| 10112 | **CARRIED** (read z⁻¹ of 10096) | 1577 | 1573 | previous 10096 — this is the cell actually read |
| 10128 | **CARRIED** | — | 1603 | boost-path one-pole smoother state |
| 10144 | **CARRIED** (read z⁻¹ of 10128) | 1601, 1602 | 1574 | previous 10128 |
| 10160 | SHADOW | — | 1605 | pre-DC-block sample |
| 10176 / 10192 / 10208 | INPUT-CONST | 1578 / 1582 / 1581 | — | **VCA MODE** one-hot Gate/ENV1/ENV2 (`juno_apply.c:410-421`) |
| 10224 | INPUT-CONST (=0) | 1586, 1587 | — | Ext-ENV SW; no writer |
| 10240 | INPUT-CONST | 1583 | — | **HPF CUTOFF** as a one-pole LP coefficient (SR-variant curve 39/40/41 + HPF TYPE joint, `juno_apply.c:171`, `hpf_type_lut.c`) |
| 10256 | INPUT-CONST | 1589 | — | **HPF Switch** — the HPF/dry crossfade (`juno_apply.c:174`) |
| 10272 | INPUT-CONST | 1596 | — | **Boost LPF Level** (`juno_apply.c:175`) |
| 10288 | INPUT-CONST | 1600 | — | **Boost Thru Level**, bipolar transform (`juno_apply.c:176`) |
| 10304 | INPUT-CONST (=1.0) | 1590 | — | env level (`juno_prepare.c:93`) |
| 10320 | INPUT-CONST | 1598 | — | **CONDITION** per-voice AMP LEVEL (`juno_apply.c:482`) |
| 10336 | INPUT-CONST (=−0.15) | 1579 | — | resonance→level compensation gain |
| 10352 / 10368 | INPUT-CONST (=1.0 / 0.0) | 1585 | — | HPF output taps (high-passed / low-passed) |
| 10384 | INPUT-CONST | 1602 | — | boost smoother coeff (rate-armed) |
| 10400 | INPUT-CONST (=0.023) | 1604 | — | voice output gain |
| 10416 | **SCRATCH** | 1607, 1613 | 1611 | DC-block output (:1607's cross-sample read feeds a dead store) |
| 10432 | **CARRIED** | 1606 | 1607, 1612 | DC-block LP state (:1607 is the dead store) |
| 10448 | **CARRIED** (read z⁻¹ of 10432) | 1608 | 1606 | previous 10432 — the cell actually read |
| 10464 | INPUT-CONST | 1609 | — | DC-block coefficient (rate-armed) |
| 10480 | **CARRIED** | 1617 | 1618 | tone filter `x[n]` (read next sample as `x[n−1]`) |
| 10496 | **CARRIED** (dual role) | 1616, 1619, 1621 | 1617, 1627 | after the shift = `x[n−1]`; after :1627 = `yA[n]` |
| 10512 | **CARRIED** (dual role) | 1615, 1620 | 1616, 1629 | after the shift = `yA[n−1]`; after :1629 = `yB[n]` |
| 10528 | **CARRIED** | 1622 | 1615 | after the shift = `yB[n−1]` |
| 10544 | SHADOW | — | 1637 | tone-blended sample |
| 10560/10576/10592 | INPUT-CONST | 1619, 1620 | — | tone A (bright shelf) b0, b1, a1 |
| 10608/10624/10640 | INPUT-CONST | 1621, 1622 | — | tone B (dark shelf) b0, b1, a1 |
| 10656 | SHADOW | — | 1639 | sample × VCA velocity gain |
| 10672 | **output** | 2180, 2181, 2182 | 1640 | VOICE OUTPUT |

### 1.7 Inputs consumed from other subsystems

| cell | producer | doc |
|---|---|---|
| 6544 | DCO/noise source mix (:1141-1149) | `DCO.md` §2.7 |
| 752, 880 | glide pitch CV, tune/mod CV (:693-735, :724-732) | `DCO.md` §2.3-2.4 |
| 1792, 1808 | LFO-A / LFO-B outputs (:800-966) | `CELLMAP.md` §F |
| 2752, 3232 | ENV1 / ENV2 normalised outputs (:1018-1021, :1072-1075) | `ENV.md` §2.4 |
| 560 | binary gate (:661-693) — reaches this subsystem only through the gate ramp `[9936]` | `ENV.md` §2.3 |
| 6864, 9680 | note-on velocity coefficients `juno_curve(56/57, vel)` | `juno_note.c:196-197`, `ENV.md` §2.5/2.8 |
| 9776, 9856, 9936 | VCA velocity gain, mute smoother, gate ramp | `ENV.md` §2.8-2.10 |

### 1.8 Where I disagree with `CELLMAP.md`

Four corrections; the CELLMAP tables are otherwise accurate and I used them as
the cross-check.

1. **"VCF 4-pole ladder core, 3× oversampled"** (CELLMAP §U heading, line 598)
   — it is **4×**, not 3×. Four sub-steps run per host sample with input
   interpolation weights 0.25 / 0.5 / 0.75 / 1.0 (`[9216]`/`[9232]` swapped for
   sub-steps 1 and 3, `[9248]` for 2, `[9200]` for 4 — READ :1350-1352, :1386,
   :1421, :1456), four dispersion lines of 8 cells each = 32 samples of 4×
   history, and a 32-tap decimating FIR. CELLMAP's own *dataflow* section
   (line 996-1013) correctly says "4 sub-steps" — only the heading is wrong.
2. **"Amp tone filter … 3-tap FIRs A/B"** (CELLMAP §AA heading and dataflow
   line 1035) — they are **1-pole/1-zero IIRs**, not FIRs. `[10592]` and
   `[10640]` multiply `[10512]` / `[10528]`, which after the :1615-1617 shift
   hold the *previous outputs* `yA[n−1]` / `yB[n−1]`, not input history (READ
   :1619-1622 against the writes at :1627/:1629). This matters: an FIR
   re-implementation would not null.
3. **CELLMAP §U names `[7520]` "g" and `1−2[7520]` "G"** (line 1000). `[7520]`
   is already `g/(1+g)` (the integrator gain); `1−2·[7520]` is the bilinear
   pole coefficient. I use `G = [7520]` and `A = 1−2G` below to avoid the trap.
4. **`[7808]`** is listed nowhere in CELLMAP §T and is indeed **never read** —
   `juno_init.c:1089` writes −4.75 into it and `voice_render.c` never touches
   it. Worth recording as a known-dead init cell rather than a gap.

5. **CELLMAP §T lists `[8192]` as "read @ 607, 1275"** (line 597). Line 607 is
   `v10 = v8 & 0x200000;` — an integer bit mask inside `juno_wrap24`'s inlined
   copy in the noise block, not a cell access. The textual `0x2000` matched
   `0x200000`. `[8192]` is read **only** at :1275. (READ; I read line 607.)

Minor: CELLMAP §T's `[7568]` row does not record the **dead store at :1234**
(`JF(7568) = v230`, overwritten at :1239 whenever `[7632]==1`). It only matters
in the unreachable held branch, but a native port that "optimises" by moving
the store inside the `if` changes the held-branch state.

---

## 2. Signal flow

```
 [6544]  DCO+noise mix            (written :1149, DCO.md)
    |
    |    [6736] cutoff knob --> quartic taper --> [6704]        :1150-1169
    |    [6832] resonance   --> bit-latch      --> [6848]        :1170
    |    [6864] velocity    --> one-pole       --> [6896]/[7248] :1171-1175, :1208
    |    752,880 --> KCV [6976]                                  :1176-1179
    |    ENV1/ENV2 --> [7072]                                    :1180-1186
    |    LFO 1792/1808 --> one-poles --> [7104], v221            :1187-1203
    |         \___ all summed into the cutoff-mod sum v227 ([7280])  :1204-1229
    |                                        |
    |                                        v
    |                          cutoff sum + clamp + exp + tan     :1230-1292
    |                          --> G = [7520],  k = [7536]
    v
 input drive [8944] = (1 + 0.5k)*(in*0.25) - dither*3.87e-5       :1340-1343
    |
    v
 4 sub-steps x { ZDF solve -> clamp[-1,1] -> x + (-0.2)x^5
                 -> 4 cascaded bilinear one-poles (G, A=1-2G)
                 -> tap = 24dB stage }                            :1350-1488
    |            heads -> lines D, C, B, A
    v
 32-tap folded FIR over the 4 lines, * 4.0  --> [9040] VCF OUT    :1489-1514
    |
    v
 HPF one-pole [10096]/[10112]; hp = vcf - lp[n-1]                 :1583-1585
 crossfade hp/dry by [10256], * (1 + (-0.15)*res)  --> y          :1591, :1599
 boost: [10272]*smooth(y) + [10288]*y, * ampCV, * 0.023 --> [10160] :1600-1605
    |
    v
 DC block ([10432]/[10448], coeff [10464])         --> v375       :1606-1613
    |
    v
 tone shelves A(bright)/B(dark), blended by sign of [9632] -> [10544] :1614-1637
    |
    v
 * [9776] (VCA velocity)  --> [10656]                             :1638-1639
 * [9856] (mute smoother) --> [10672] = VOICE OUTPUT              :1640
    |
    v
 *outL = *outR = [10672];  return bits                            :2180-2182
```

The VCA velocity/mute/gate-ramp block (:1516-1567) sits between the ladder and
the VCA mix in program order but is a separate subsystem (`ENV.md`).

---

## 3. Per-stage equations, exact evaluation order

Every `(float)` in the source marks a rounding point. Where a literal `1.0` or
`0.25` appears in the source it is a **double** and the enclosing expression is
evaluated in double before being rounded to float — for `+ − × ÷` with float
operands this is provably identical to the float-only computation (double
rounding is innocuous when `p2 ≥ 2·p1 + 2`, i.e. 53 ≥ 50), so a native
implementation may use plain float there. That equivalence is per-operation:
it does **not** license re-association.

### 3.1 Cutoff-CV taper → `[6704]`  (READ :1154-1169)

```
v200 = (([6720]*[6576]) - ([6736]*[6720])) + [6736]              // :1154-1156
v201 =   ((((v200*v200)*v200)*v200) * [6816])
       + (   (((v200*v200)*v200) * [6800])
           + (   ((v200*[6768]) + [6752])
               + ((v200*v200) * [6784]) ) )                       // :1157-1160
v202 = (v201 <= 0.0) ? 0.0 : v201                                 // :1161-1164
v203 = v202
v42  = 1.0 ; if (v203 < 1.0) v42 = v203                           // :1166-1167, seeded :689
[6704] = v42                                                      // :1169
```

`[6720]` has no writer ⇒ 0, so `v200 == [6736]` exactly. **NaN behaviour is
asymmetric and load-bearing**: a NaN `v201` survives the `<= 0.0` test as NaN,
then fails `v203 < 1.0`, so `[6704]` becomes **1.0**, not NaN. `v42` is
declared `double` (`:94`) and seeded to 1.0 at :689 — a native port must seed
it *outside* the filter block, per sample.

### 3.2 Resonance latch and VCF velocity smoother  (READ :1170-1175)

```
[[6848]] = [[6832]]                                               // :1170 bit copy
v205 = [6864] ; [6880] = v205                                     // :1171-1172
v206 = [6896] ; [6912] = v206                                     // :1173-1174
[6896] = ((v205 - v206) * [6928]) + v206                          // :1175
```

`[6928]` is **1.3072726 at 44100 Hz** — greater than 1, so this one-pole is
deliberately damped-oscillatory on a velocity step. Keep the exact form
`(target − state)*coef + state`.

### 3.3 Keyboard CV and filter-env select  (READ :1176-1186)

```
[6976] = ([880]*[6960]) + ([752]*[6944])                          // :1176-1179
[[7040]] = [[7008]]                                               // :1180
v209 = [7024] ; [7056] = v209                                     // :1181-1182
v210 = [2752] + (([7040]*[3232]) - ([7040]*[2752]))               // :1183-1185
[7072] = ((v209*[6640]) - (v209*v210)) + v210                     // :1186
```

`[7008]` and `[7024]` have no writers (proven non-recalled,
`juno_apply.c:540-562`) ⇒ both 0 ⇒ `[7072] == [2752]` (ENV1). Keep the full
lerp: the plugin exposes both as settable descriptors.

### 3.4 LFO smoothers  (READ :1187-1203)

```
LFO-A: v211=[1792]; v212=[7088]; [7104]=v212;                     // :1187-1189 (dead store)
       v213 = v211 - v212
       v214 = (v213*[7120]) + v212
       [7088] = v214                                              // :1193
       [7104] = (v213*[7136]) + ([7152]*v214)                     // :1194
       v222 = [7104]                                              // :1204  <-- memory round-trip
LFO-B: v216=[7168]; v217=[1808]; [7184]=v216;                     // :1195-1197 (dead store)
       v218 = v217 - v216
       v219 = (v218*[7200]) + v216
       [7168] = v219                                              // :1201
       v221 = (v218*[7216]) + ([7232]*v219)                       // :1202
       [7184] = v221                                              // :1203 (write-only)
```

`[7136]=[7216]=0` and `[7152]=[7232]=1.0`, so both outputs equal the one-pole
state. Note the asymmetry: LFO-A's output is re-loaded from `[7104]`, LFO-B's
uses the register — numerically identical, structurally different.

### 3.5 Cutoff-mod sum → `v227` / `[7280]`  (READ :1204-1229)

```
v222 = [7104]  (LFO-A out)   v223 = [7072]  (filter env)
v224 = [6976]  (VCF KCV)     v221 = LFO-B out
v227in = f32_from_bits(JU(6608))                                  // :1207
[[7248]] = [[6896]]                                               // :1208
[[7264]] = bits(v227in)                                           // :1209
v225 = [7296]                                                     // :1210
v226 = [7312] * [6672]                                            // :1211

A = ((( v227in*[7328] - [7456]*[7328] ) + [7456]) * [7472])       // :1212-1215
B = (([7440] + [7248]) * [7504]) * [7424]                         // :1216-1218
C = (((v226 - ([7312]*(v221*v225))) + (v221*v225)) * [7360]) * [7376]   // :1219-1223
D =  ((v226 - ([7312]*(v222*v225))) + (v222*v225)) * [7344]       // :1224-1226
E = ((v224 + [7488]) * [7408]) + (v223 * [7392])                  // :1227-1228

v227 = (A + B) + ((C + D) + E)                                    // :1212-1228
[[7280]] = bits(v227)                                             // :1229
```

The three-level grouping `(A+B) + ((C+D)+E)` is exactly what the source
brackets. `[7312]`, `[7328]`, `[7376]`, `[7456]` are all 0 at rest, so at rest
`A = 0`, `C = 0`, `D = (v222*v225)*[7344]`.

### 3.6 Dither, resonance drive, cutoff clamp  (READ :1230-1254)

```
v228 = [6704] ; v229 = [6848]                                     // :1230-1231
[[7584]] = [[7568]]                                               // :1232
v230 = [7552] ; [7568] = v230                                     // :1233-1234 (dead when gate on)
if ([7632] == 1.0) {                                              // :1235
  v231 = [7584] + (([7712]*v230) - ([7712]*[7584]))               // :1237-1238
  [7568] = v231                                                   // :1239
  v232 = (v231*[7696]) + [7600]                                   // :1240
  [7552] = juno_wrap24(-v230)                                     // :1241
  v233 = (1.0 - v229) * [7728]                                    // :1242
  [7536] = (v229*[7792]) + [7616]                                 // :1243   k = 5.4*res
  v227 = fmaxf( fminf( ((((v227*[7680]) + (v228*[7648])) + v232)
                         + fminf([7744], v233)) + [7664],
                       [7760] ),
                [7776] ) * [7824] + [7840]                        // :1244-1254
```

`juno_wrap24` is `juno_dsp.c:20-45` — a signed-24-bit wrap with a tie
adjustment on bits 21/23; it is the *algorithm*, not a formula, and must be
transcribed verbatim. `[7552]` free-runs from its own previous value, so it is
a pure state oscillator that never depends on audio.

### 3.7 Cutoff → `G`: floor split, `exp`, `tan`  (READ :1255-1292)

```
  v234 = v227 ; v235 = (int)v227
  if (v235 != 0x80000000 && (float)v235 != v227)
      v234 = (float)(v235 - ((bits(v227) >> 31) & 1))             // :1255-1258  == floorf(v227)
  v236 = v227 - v234                                              // :1259   frac in [0,1)
  v237 = (v236*v236) * 0.25                                       // :1260   q = f^2/4

  P = ((((((((((( (v236*[8032]) + [8016]) * v237) + (v236*[8000])) + [7984]) * v237)
              + (v236*[7968])) + [7952]) * v237)
              + (v236*[7936])) + [7920]) * v237)
              + (v236*[7904])) + [7888]) * v237)
              + (v236*[7872])) + 1.0                              // :1262-1272 (exact nesting in source)
  v238 = (expf(v234) * P) * [7856]                                // :1261-1273
  v239 = v238 * v238
  NUM = ((((((((v238*v238) * *(a1+0x2000)) + [8160]) * (v239*v239))
             + (((v238*v238)*[8128]) + [8096]))
           * (((v238*v238)*v238) * (v238*v238)))
          + (((v238*v238)*v238) * [8064])) + v238)                // :1275-1282
  DEN = ((((((((v238*v238)*[8176]) + [8144]) * (v239*v239))
            + ((v238*v238)*[8112])) + [8080]) * (v239*v239))
          + ((v238*v238)*[8048])) + 1.0                           // :1283-1290
  v240 = NUM / DEN                                                // :1275-1290
  [7520] = v240 / (v240 + 1.0)                                    // :1291-1292
} else { v241 = [7520]; }                                         // :1294-1297
```

**Identification (INFERRED, ops are READ).** `P` is the interleaved
sinh/cosh Taylor split of `exp(frac)` in `q = frac²/4`. In `q`, the even
(`cosh`) coefficients are `[7888],[7920],[7952],[7984],[8016]` =
2, 2/3, 4/45, 2/315, 4/14175 and the odd (`sinh(f)/f`, multiplied by `v236`)
coefficients are `[7872],[7904],[7936],[7968],[8000],[8032]` =
1, 2/3, 2/15, 4/315, 2/2835, 4/155925 — each matching the decoded cell to
float precision (PROVEN(decode); values in §4.1). `P(0) = 1.0` exactly.
`NUM/DEN` is `sin(x)/cos(x) = tan(x)` from the first five odd / five even
Taylor terms (`−1/3!, 1/5!, −1/7!, 1/9!, −1/11!` over
`−1/2!, 1/4!, −1/6!, 1/8!, −1/10!`, all PROVEN(decode)). So

```
E    = clamp(cutoff_sum, [7776]=-3.0, [7760])          // :1244-1252
fc   = 440 * exp(E*ln2 - 3.2924490)   Hz               // INFERRED
arg  = pi*fc/(4*H) = exp(...) * [7856]                 // [7856] = pi*440/(4H), PROVEN(decode)
g    = tan(arg)                                        // v240
G    = g/(1+g)                                         // [7520]
```

At 44100 Hz the clamp hi `[7760] = 10.397000` puts `fc_max` at **22048.0 Hz**
(≈ H/2), `arg_max` at 0.3926635 (≈ π/8 = 0.3926991), `g_max ≈ 0.41413` and
`G_max ≈ 0.29285`; `fc_min` (E = −3) is **2.0439 Hz**. At every other rate
`[7760] = 11.0`, giving `fc_max ≈ 33488 Hz` — which is *not* the analogous
Nyquist relation, because `[7760]` is a fixed 96 kHz-family constant, not a
continuous law (the same 2-arm design `juno_init.c:313-314` uses everywhere).
All numbers PROVEN(decode) from the cited cells; the *identification* as
`fc`/`tan`/`G` is INFERRED, the ops are READ.

`expf` is called only on integers (the floor of a value bounded by the clamp),
so its argument set is `{-6 … 3}` — 10 distinct values. CLAUDE.md records that
glibc and newlib `expf` agree bit-for-bit over 32,000,423 inputs (PROVEN
elsewhere), so a native port may tabulate these 10 results, but must not
substitute its own `exp`.

### 3.8 Ladder input node  (READ :1298-1349)

```
v242 = [6544] ; v243 = [7536]                                     // :1298-1299
  ... 7-cell pipeline shift :1300-1306, four 8-cell line shifts :1307-1334 ...
[[8960]] = [[8944]]                                               // :1335
v244 = [8976] ; [8992] = v244                                     // :1336-1337
if ([9056] == 1.0) {                                              // :1338
  v245 = (((v243*[9168]) + 1.0) * (v242*[9136])) + ((-v244)*[9120]) // :1340-1341
  [8976] = juno_wrap24(-v244)                                     // :1342
  [8944] = v245                                                   // :1343
  v246 = 1.0 - (v241 + v241)                        // A = 1-2G   // :1344
  v247 = 1.0 / ((((v241*v241)*(v241*v241)) * v243) + 1.0)         // :1345
  [9024] = v247                                     // 1/(1+G^4*k)// :1346
  [9008] = v247 * v243                              // k/(1+G^4*k)// :1349
```

`v246` must be computed as `1.0 − (G+G)`, not `1 − 2·G`; `v247` must be a real
**division** (a reciprocal approximation will not null).

### 3.9 One sub-step (READ :1350-1384 for k=1; :1385-1419, :1420-1454,
:1455-1488 are the same shape)

Let `G = v241`, `A = v246`, `R = [9024]`, `Rk = [9008]`. Per sub-step:

```
in_k  = interp_k * R                       // weights below
x     = in_k - ((S_new*[9520]) + (S_old*[9536])) * Rk             // :1355-1357
x     = (x >= -1.0) ? fminf(x, 1.0) : -1.0                        // :1358-1361  NaN -> -1.0
nl    = x + ((((x*x)*x)*x) * (x*[9184]))                          // :1362
y1    = (G * (nl + xz1)) + (y1z * A)                              // :1365
y2    = (G * (y1 + y1z)) + (y2z * A)                              // :1368,1370
y3    = (G * (y2 + y2z)) + (y3z * A)                              // :1373
y4    = ((y3z + y3) * G) + (A * y4z)                              // :1375
p2    = G * (((G*nl) + (A*y1)) + y1)                              // :1369  zero-input y2 one step ahead
S     = (G * ((((G * ((p2 + (A*y2)) + y2)) + (A*y3)) + y3))) + (A*y4)  // :1377-1381
tap   = ((y3*[9088]) + (y4*[9104])) + ([9072]*y2)                 // :1382-1384
```

with the interpolation of the input drive:

| sub-step | `interp_k` | source |
|---|---|---|
| 1 | `([8960]*[9216]) + ([8944]*[9232])` = 0.75·prev + 0.25·cur | :1350, :1352, :1355 |
| 2 | `([8960] + [8944]) * [9248]` = 0.5·(prev+cur) | :1386 |
| 3 | `([8960]*[9232]) + ([8944]*[9216])` = 0.25·prev + 0.75·cur | :1421 |
| 4 | `[8944] * [9200]` = cur | :1456 |

and the **feedback pair** `(S_new, S_old)`: sub-step 1 uses `([8304], [8320])`
(:1351, :1353); sub-steps 2/3/4 use `(S from the previous sub-step, the one
before it)` carried in the register `_s8416` (:1385/:1387, :1420/:1423,
:1455). `[9536] = 0`, so `S_old` contributes nothing — but the multiply is
still executed.

**Identification (INFERRED).** `y1..y4` are four cascaded bilinear one-poles
`y[n] = G(x[n]+x[n−1]) + (1−2G)y[n−1]`; `S` is the zero-input response of the
whole 4-pole chain one sub-step ahead, and the input node solves
`u = in·R − S·Rk`, i.e. `u(1+kG⁴) = in − kS` — a linear zero-delay-feedback
resolution. The nonlinearity is applied to the **solved** node, *outside* the
loop, so no iteration is needed. This is why a native rewrite can be a
straight-line function.

Sub-step 4 differs in three ways (READ :1455-1488): it writes the stage values
to the **pipeline cells** `8208/8224/8240/8256/8272` instead of scratch, it
writes `S` to `[8288]` as `v320 + (v246*v319)` (:1484), and its tap is
associated as `((y4*[9104]) + ([9088]*[8256])) + (y2*[9072])` (:1486-1487) —
the same value by commutativity, but written differently. Sub-step 3's `S` goes
to `[8304]` (:1457).

Sub-step heads go to the dispersion lines in **reverse** order:
1→`[8816]` (D, :1384), 2→`[8688]` (C, :1419), 3→`[8560]` (B, :1454),
4→`[8432]` (A, :1488).

### 3.10 Decimating FIR → `[9040]`  (READ :1489-1514)

The 4 lines interleave into a single 4×-rate history. Naming line A head `a0`
(8432) … `a7` (8544) and likewise `b*` (8560…8672), `c*` (8688…8800),
`d*` (8816…8928), the 4× lag order newest→oldest is
`a0, b0, c0, d0, a1, b1, c1, d1, …, a7, b7, c7, d7` (lags 0…31).

The sum is 16 **symmetric folded pairs** `(lag t + lag 31−t) * [9264+16t]`,
accumulated **from the centre tap outward** — this order is load-bearing:

```
acc = ([8496]+[8864]) * [9504]        // t15  (lags 16,15)
acc = acc + ([8624]+[8736]) * [9488]  // t14
acc = acc + ([8752]+[8608]) * [9472]  // t13
acc = acc + ([8480]+[8880]) * [9456]  // t12
acc = acc + ([8848]+[8512]) * [9440]  // t11
acc = acc + ([8720]+[8640]) * [9424]  // t10
acc = acc + ([8768]+[8592]) * [9408]  // t9
acc = acc + ([8896]+[8464]) * [9392]  // t8
acc = acc + ([8832]+[8528]) * [9376]  // t7
acc = acc + ([8704]+[8656]) * [9360]  // t6
acc = acc + ([8784]+[8576]) * [9344]  // t5
acc = acc + ([8912]+[8448]) * [9328]  // t4
acc = acc + ([8816]+[8544]) * [9312]  // t3
acc = acc + v325                      // t2 = ([8688]+[8672])*[9296], computed :1490
acc = acc + ([8800]+[8560]) * [9280]  // t1
acc = acc + v324                      // t0 = ([8432]+[8928])*[9264], computed :1489
[9040] = acc * [9152]                                             // :1513-1514
```

`v324`/`v325` are computed **before** the chain (:1489-1490) but added **last**
(:1512) and third-from-last (:1510). The 16 taps sum to 0.49999999
(PROVEN(decode), double accumulation), so the folded 32-tap FIR has DC gain
≈1.0 and `[9152] = 4.0` restores the 4:1 decimation gain against the
`[9136] = 0.25` input attenuation (4.0 × 0.25 = 1.0).

### 3.11 HPF / boost / VCA mix → `[10160]`  (READ :1568-1605)

```
v348=[9040]; v349=[2752]; v350=[6848]; v351=[[3232]]; v352=[[9552]]  // :1568-1572
[[10112]] = [[10096]] ; [[10144]] = [[10128]]                     // :1573-1574
[[10048]] = v351 ; [[10064]] = v352                               // :1575-1576
v353 = [10112]                       // lp[n-1]                   // :1577
[10080] = v350 * [10336]             // -0.15*res                 // :1579
v355 = v348 - v353                                                // :1580
v357 = (v349*[10192]) + ([10176]*[9936])                          // :1582
v358 = v353 + ((v348 - v353) * [10240])                           // :1583
[10096] = v358                                                    // :1584
v359 = (v355*[10352]) + (v358*[10368])                            // :1585
v360 = (([10224]*[10064]) - ([10224]*(v357 + ([10208]*[10048]))))
       + (v357 + ([10208]*[10048]))                               // :1586-1588
v361 = [10256]                                                    // :1589
v362 = v360 * [10304]                                             // :1590
v363 = v348 * (1.0 - v361)                                        // :1591
v364 = (v362 <= 0.0) ? 0.0 : v362                                 // :1592-1595
v367 = v364 * [10320]                                             // :1597-1598
v368 = ((v361*v359) + v363) * ([10080] + 1.0)                     // :1599
v369 = [10288] * v368                                             // :1600
v370 = [10144] + (([10384]*v368) - ([10384]*[10144]))             // :1601-1602
[10128] = v370                                                    // :1603
[10160] = (((( [10272]*v370) + v369) * v367) * [10400])           // :1604-1605
```

Notes that a native rewrite gets wrong easily:

- The HPF output `v359` uses `lp[n−1]` (`v353`), **not** the freshly-updated
  `v358`. `[10368] = 0` kills the low-passed branch entirely, so
  `v359 == v348 − lp[n−1]`.
- `[10256]` is a crossfade, not a switch: `v368` mixes `HPF·[10256]` with
  `dry·(1−[10256])`.
- `[10224] = 0` collapses `v360` to `v357 + [10208]*[10048]`, but the
  expression evaluates `(v357 + [10208]*[10048])` **twice** in the source; both
  evaluations are bit-identical, so a native port may compute it once.
- `v367` (the amp CV) is clamped at 0 **before** the CONDITION re-level
  `[10320]`, and `[10320]` can exceed 1.0 (`cube*scal + 1.0`,
  `juno_apply.c:482`).

### 3.12 DC block  (READ :1606-1613)

```
[[10448]] = [[10432]]                                             // :1606
[[10432]] = [[10416]]                        // DEAD (overwritten :1612)
v372 = [10448] ; v373 = [10464]                                   // :1608-1609
v374 = v371 - v372                                                // :1610
[10416] = v374                                                    // :1611
[10432] = (v373*v374) + v372                                      // :1612
v375 = [10416]                               // memory round-trip // :1613
```

### 3.13 Tone shelves and output  (READ :1614-1640, :2180-2182)

```
v376 = [9632]                                 // AMP TONE, bipolar
[[10528]] = [[10512]]   // yB[n-1]                                // :1615
[[10512]] = [[10496]]   // yA[n-1]                                // :1616
[[10496]] = [[10480]]   // x[n-1]                                 // :1617
[10480]   = v375        // x[n]                                   // :1618

v377 = (([10496]*[10576]) + (v375*[10560])) + ([10592]*[10512])   // :1619-1620  bright
v378 = (([10496]*[10624]) + (v375*[10608])) + ([10640]*[10528])   // :1621-1622  dark
v379 = (v376 <= 0.0) ? 0.0 : v376                                 // :1623-1626
[10496] = v377                                                    // :1627
[10512] = v378                                                    // :1629
v381 = ((v379*v377) - (v379*v375)) + v375                         // :1630
v19  = 0.0 ; if (v376 < -0.0) v19 = -v376                         // seeded :633, :1631-1632
v383 = v375 + ((v19*v378) - (v19*v375))                           // :1634
if (v376 >= 0.0) v383 = v381                                      // :1635-1636
[10544] = v383                                                    // :1637
[10656] = v383 * [9776]                                           // :1638-1639
[10672] = [10656] * [9856]                                        // :1640
*outL = *outR = [10672] ; return bits([10672])                    // :2180-2182
```

Both shelves are `y[n] = b0·x[n] + b1·x[n−1] + a1·y[n−1]`. With the §4
coefficients, tone A has DC gain 1.0 and Nyquist gain 3.981 (+12 dB treble) and
tone B is its mirror (+12 dB at DC, unity at Nyquist) — **INFERRED** from the
decoded coefficients; the ops are READ.

`v19` is declared `double` (`:71`) and seeded to 0.0 at **:633**, outside this
block — same pattern as `v42`. The `-0.0` comparison at :1631 is deliberate:
`v376 == -0.0` takes the `>= 0.0` branch at :1635 anyway.

---

## 4. Constants

`init` = `juno_init.c` (constructor; two arms selected by
`if (JF(a1,16) == 44100)` at :314, else-branch at :620ff). `prepare` =
`juno_prepare.c`. All float values are PROVEN(decode) from the exact int
bit-patterns in those files — **store the bit patterns, not the decimals**.

### 4.1 Rate-invariant

| cell(s) | bits | value | role | source |
|---|---|---|---|---|
| 6752 | 0x0786e000 | 2.0293734e−34 | cutoff taper c0 (≈0) | init:1063 |
| 6768 | 0x3e27adb4 | 0.16374856 | taper c1 | init:1064 |
| 6784 | 0x40351aa2 | 2.8297505 | taper c2 | init:1065 |
| 6800 | 0xbfff8a6e | −1.9964120 | taper c3 | init:1066 |
| 6816 | 0x3ca279c3 | 0.019833451 | taper c4 | init:1067 |
| 6944, 6960 | 0x3f800000 | 1.0 | KCV mix gains | init:1069-1070 |
| 7136, 7216 | 0x00000000 | 0.0 | LFO smoother direct path | init:1072, 1075 |
| 7152, 7232 | 0x3f800000 | 1.0 | LFO smoother output gain | init:1073, 1076 |
| 7296 | 0x3f800000 | 1.0 | LFO gain | prepare:85 |
| 7440 | 0xbf010204 | −0.50393701 | velocity centre offset | prepare:86 |
| 7488 | 0xc0800000 | −4.0 | KCV offset | init:1077 |
| 7504 | 0x41000000 | 8.0 | velocity scale | init:1078 |
| 7632 | 0x3f800000 | 1.0 | coefficient-update gate | prepare:87 |
| 7648 | 0x41420c4a | 12.128000 | cutoff-CV gain | init:1079 |
| 7664 | 0xbed89375 | −0.42300001 | cutoff sum offset | init:1080 |
| 7680 | 0x3f800000 | 1.0 | mod-sum gain | init:1081 |
| 7728 | 0x3dcccccd | 0.10000000 | res→cutoff comp slope | init:1084 |
| 7744 | 0x3d99999a | 0.075000003 | comp clamp | init:1085 |
| 7776 | 0xc0400000 | −3.0 | cutoff clamp lo | init:1087 |
| 7792 | 0x40accccd | 5.4000001 | resonance drive scale | init:1088 |
| 7808 | 0xc0980000 | −4.75 | **dead** (never read) | init:1089 |
| 7824 | 0x3f317218 | 0.69314718 (ln 2) | cutoff→exp scale | init:1090 |
| 7840 | 0xc052b77c | −3.2924490 | cutoff→exp offset | init:1091 |
| 7872 | 0x3f800000 | 1.0 | exp poly k1 (sinh/f) | init:1093 |
| 7888 | 0x40000000 | 2.0 | k2 (cosh) | init:1094 |
| 7904, 7920 | 0x3f2aaaab | 0.66666669 | k3, k4 | init:1095-1096 |
| 7936 | 0x3e088889 | 0.13333334 | k5 | init:1097 |
| 7952 | 0x3db60b61 | 0.088888891 | k6 | init:1098 |
| 7968 | 0x3c500d01 | 0.012698413 | k7 | init:1099 |
| 7984 | 0x3bd00d01 | 0.0063492064 | k8 | init:1100 |
| 8000 | 0x3a38ef1e | 7.0546742e−4 | k9 | init:1101 |
| 8016 | 0x3993f27c | 2.8218690e−4 | k10 | init:1102 |
| 8032 | 0x37d73242 | 2.5653400e−5 | k11 | init:1103 |
| 8048 | 0xbf000000 | −0.5 | tan denom c1 (=−1/2!) | init:1104 |
| 8064 | 0xbe2aaaab | −0.16666667 | tan num c1 (=−1/3!) | init:1105 |
| 8080 | 0x3d2aaaab | 0.041666668 | denom c2 (1/4!) | init:1106 |
| 8096 | 0x3c088889 | 0.0083333338 | num c2 (1/5!) | init:1107 |
| 8112 | 0xbab60b61 | −0.0013888889 | denom c3 (−1/6!) | init:1108 |
| 8128 | 0xb9500d01 | −1.9841270e−4 | num c3 (−1/7!) | init:1109 |
| 8144 | 0x37d00d01 | 2.4801588e−5 | denom c4 (1/8!) | init:1110 |
| 8160 | 0x3638ef1d | 2.7557319e−6 | num c4 (1/9!) | init:1111 |
| 8176 | 0xb493f27e | −2.7557320e−7 | denom c5 (−1/10!) | init:1112 |
| 8192 (`a1+0x2000`) | 0xb2d7322b | −2.5052108e−8 | num c5 (−1/11!) | init:1113 |
| 9056 | 0x3f800000 | 1.0 | ladder render gate | prepare:88 |
| 9072, 9088 | — | **0.0** (calloc; no writer) | −12 / −18 dB taps | — |
| 9104 | 0x3f800000 | 1.0 | −24 dB tap | prepare:89 |
| 9120 | 0x38222e0e | 3.8666702e−5 | dither→input gain | init:1114 |
| 9136 | 0x3e800000 | 0.25 | input drive gain | init:1115 |
| 9152 | 0x40800000 | 4.0 | decimator output gain | init:1116 |
| 9168 | 0x3f000000 | 0.5 | resonance→input compensation | init:1117 |
| 9184 | 0xbe4ccccd | −0.20000000 | quintic nonlinearity coeff | init:1118 |
| 9200 | 0x3f800000 | 1.0 | sub-step 4 interp | init:1119 |
| 9216 | 0x3f400000 | 0.75 | interp A | init:1120 |
| 9232 | 0x3e800000 | 0.25 | interp B | init:1121 |
| 9248 | 0x3f000000 | 0.5 | sub-step 2 interp | init:1122 |
| 9264..9504 | see below | | 16 folded FIR taps | init:1123-1138 |
| 9520 | 0x3f800000 | 1.0 | feedback tap `S` | init:1139 |
| 9536 | 0x00000000 | 0.0 | feedback tap `S₋₁` | init:1140 |
| 9616 | 0x3f6e147a | 0.92999995 | VCA fixed-velocity base | prepare:90 |
| 10224 | — | **0.0** (calloc; no writer) | Ext-ENV SW | — |
| 10304 | 0x3f800000 | 1.0 | env level | prepare:93 |
| 10336 | 0xbe19999a | −0.15000001 | resonance→level comp | init:1150 |
| 10352 | 0x3f800000 | 1.0 | HPF high-passed tap | init:1151 |
| 10368 | 0x00000000 | 0.0 | HPF low-passed tap | init:1152 |
| 10400 | 0x3cbc6a7f | 0.023000000 | voice output gain | init:1154 |

FIR taps t0..t15 (`[9264]` … `[9504]`, PROVEN(decode)):

```
t0  0xba254611 -6.3046912e-4    t8  0xbc1650b1 -9.1745118e-3
t1  0xbaee5d05 -1.8185681e-3    t9  0xbcf38e3b -2.9730907e-2
t2  0xbb27e63f -2.5619415e-3    t10 0xbd231694 -3.9816454e-2
t3  0xbad01376 -1.5874940e-3    t11 0xbcb6b1f2 -2.2301648e-2
t4  0x3b1b49d3  2.3695126e-3    t12 0x3cfe2e5c  3.1027965e-2
t5  0x3c088507  8.3324974e-3    t13 0x3de39f34  1.1114350e-1
t6  0x3c4163f1  1.1803613e-2    t14 0x3e451307  1.9245540e-1
t7  0x3bdd7d17  6.7592966e-3    t15 0x3e799469  2.4373020e-1
```

### 4.2 Rate-armed (44100 arm / all other rates)

`juno_init.c` is strictly 2-arm; the "else" values are the 96 kHz family and
are used verbatim at 48000, 88200, 96000, 192000 (CLAUDE.md cold-state gate,
PROVEN elsewhere). Do **not** "fix" this into a continuous law.

| cell | 44100 bits / value | else bits / value | role | source |
|---|---|---|---|---|
| 6928, 9744 | 0x3fa754b5 / 1.3072726 | 0x3f2493b7 / 0.64287895 | velocity smoother coeff | init:1068, 1141 |
| 7120, 7200 | 0x3e5a6d3b / 0.21330731 | 0x3dc8fb30 / 0.098135352 | LFO smoother coeff | init:1071, 1074 |
| 7696 | 0x3d800000 / 0.0625 | 0x3dbcdaa3 / 0.092213891 | dither gain | init:1082 |
| 7712 | 0x3ba3670d / 0.0049866498 | 0x3b16204f / 0.0022907441 | dither smoother coeff | init:1083 |
| 7760 | 0x41265a1d / 10.397000 | 0x41300000 / 11.0 | cutoff clamp hi | init:1086 |
| 7856 | 0x3c00634a / 0.0078361724 | 0x3b6be9a4 / 0.0035997415 | rad/sample scale (= π·440/4H) | init:1092 |
| 10384 | 0x3be96e95 / 0.0071237781 | 0x3b56774a / 0.0032724910 | boost smoother coeff | init:1153 |
| 10464 | 0x3a3abef7 / 7.1237929e−4 | 0x39ab92a6 / 3.2724923e−4 | DC-block coeff | init:1155 |
| 10560 | 0x4054945c / 3.3215551 | 0x4068ca68 / 3.6373539 | tone A b0 | init:1156 |
| 10576 | 0xc03842f0 / −2.8790855 | 0xc05a0840 / −3.4067535 | tone A b1 | init:1157 |
| 10592 | 0x3f0eba50 / 0.55753040 | 0x3f44f760 / 0.76939964 | tone A a1 | init:1158 |
| 10608 | 0x3f86b818 / 1.0524931 | 0x3f831cb4 / 1.0243134 | tone B b0 | init:1159 |
| 10624 | 0xbf698bc4 / −0.91228890 | 0xbf759990 / −0.95937443 | tone B b1 | init:1160 |
| 10640 | 0x3f76fbf8 / 0.96478224 | 0x3f7bd2fc / 0.98368812 | tone B a1 | init:1161 |
| 10240 | 0x3b9a10b5 / 0.0047016987 | 48k 0x3b8d8c28 / 0.0043196864; else 0x3b0d8c2e / 0.0021598446 | HPF cutoff default — **3-class**, not 2-class | prepare:135, 259 |

### 4.3 Recalled (per patch, `juno_apply.c` BINDINGS)

| cell | parameter | law | power-on default |
|---|---|---|---|
| 6736 | VCF CUTOFF FREQ | `juno_curve(22, blob35)` | 1.0 (prepare:255) |
| 6832 | VCF RESONANCE | `juno_curve(22, blob37)` | 0.0 (calloc) |
| 7344 | VCF LFO MOD | `juno_curve(47, blob10)` | 4.1631999e−28 (prepare:256) |
| 7360 | MOD SENS VCF | `juno_curve(22, rec538) * 10.0` | 0.86274511 (prepare:257) |
| 7392 | VCF ENV MOD | `juno_curve(46, blob39)` | 0.0 |
| 7408 | VCF KEY FOLLOW | `juno_curve(24, blob44)` — **bipolar** | 0.0 |
| 7424 | VCF VEL SENS | `record_byte(1868)/255` | 0.0 |
| 7472 | BEND depth VCF | `curve22(rec522)*curve4(BEND RANGE)*mode` | 0.16862746 (prepare:258) |
| 7600 | CONDITION cutoff fine | `cube * COND_FINE_SCAL[v]` (per voice) | 0.0 |
| 9584 | VCA TONE | `juno_curve(24, blob49)` — **bipolar** | 0.0 |
| 9600 | VCA VEL SENS | `record_byte(2102)/255` | 0.0 |
| 10176/10192/10208 | VCA MODE | one-hot Gate/ENV1/ENV2 | 10208 = 1.0 (prepare:92), overwritten by recall |
| 10240 | HPF CUTOFF | SR-variant curve 39/40/41, then joint with HPF TYPE (`hpf_type_lut.c`) | 0.0021598446 (prepare:259) |
| 10256 | HPF Switch | `juno_curve(52, blob38)` | 0.0 |
| 10272 | Boost LPF Level | `juno_curve(10, blob38)` | 0.0 |
| 10288 | Boost Thru Level | `juno_curve(18, (blob38>>1)+128)` | 1.0 (prepare:99) |
| 10320 | CONDITION AMP LEVEL | `cube * COND_GAIN_SCAL[v] + 1.0` (per voice) | 1.0 (prepare:94) |

The **four HPF cells all share blob byte 38** and must be written together on
any live edit (`juno_apply.c:304-314`), and re-joined with the patch's HPF TYPE
(`juno_bank_hpf_type`) — a live cutoff move that forgets the TYPE writes the
TYPE-0 values.

---

## 5. Modulation inputs (produced elsewhere; not re-derived here)

| input | cell(s) | producing subsystem | where it enters |
|---|---|---|---|
| Filter envelope | `[2752]` ENV1, `[3232]` ENV2 | ENV (`ENV.md` §2.4) | `[7072]` lerp :1183-1186; depth `[7392]` :1228 |
| Envelope select | `[7008]`, `[7024]` | none — **never recalled**, both 0 ⇒ always ENV1 | :1180-1186 |
| LFO | `[1792]` LFO-A, `[1808]` LFO-B | LFO block :800-966 (`CELLMAP.md` §F) | smoothers :1187-1203; depths `[7344]` (LFO MOD) and `[7360]·[7376]` (mod wheel) :1219-1226 |
| Key follow | `[752]` glided pitch CV, `[880]` tune/mod CV | DCO (`DCO.md` §2.3-2.4) | `[6976]` :1176-1179; depth `[7408]`, offset `[7488]` :1227 |
| Velocity (VCF) | `[6864]` = `juno_curve(56, vel)` | note path `juno_note.c:196`; wrapper velocity policy in CLAUDE.md (Kbd Vel SW OFF ⇒ every note forced to 100) | smoother :1171-1175 → `[7248]` → `(([7440]+[7248])*[7504])*[7424]` :1216-1218 |
| Velocity (VCA) | `[9680]` = `juno_curve(57, vel)` | note path `juno_note.c:197` | `ENV.md` §2.8 → `[9776]` :1638 |
| Gate | `[560]` → gate ramp `[9936]` | gate conditioner + gate-mode env (`ENV.md` §2.3, §2.10) | VCA CV :1582 (only when VCA MODE = GATE) |
| CONDITION scatter | `[7600]` cutoff fine, `[10320]` amp level | `juno_apply.c:472-485`, per-voice-distinct, applied AFTER `seed_voices` | :1240, :1598 |
| Pitch/mod bend | `[6608]` source, `[7456]` amount, `[7472]` depth, `[7328]` select | live runtime; all 0 at rest | :1207, :1212-1215 |
| Host live modulation | dispatch idx 312 (VCF CUTOFF), 313 (HPF CUTOFF), 314 (VCF RESONANCE) | `juno_mod.c` — acts on the recall **byte**, not the engine cell | recall re-runs; identity at offset 0 |
| Resonance→level | `[6848]` | this doc (§3.2) | `[10080]` :1579, consumed :1599 |

---

## 6. Native-rewrite notes

### 6.1 What is a genuine dependency chain

These carry information across samples and **cannot** be restructured away:

1. **`[7552]` / `[7568]` / `[7584]` cutoff dither** and **`[8976]` ladder
   dither** — two independent free-running `juno_wrap24` oscillators plus a
   one-pole. They are audio-independent, so they *can* be generated ahead of
   time, but their exact sequence is part of the sound.
2. **The 7-cell ladder pipeline** `[8208..8320]` — the correct native form is
   seven named variables `xz1, y1z, y2z, y3z, y4z, Sprev, Sprev2` rotated once
   per host sample. It is *not* a uniform delay line: `8288`/`8304` hold state
   contributions `S`, not stage outputs.
3. **The four 8-cell dispersion lines** `[8432..8928]` = 32 samples of 4×
   history. A circular buffer with a modulo index is legitimate; the FIR
   summation order is not negotiable (§3.10).
4. **`[8944]` / `[8960]`** — the input drive and its z⁻¹, needed for the 4×
   interpolation.
5. **`[6896]`, `[7088]`, `[7168]`** — three one-pole smoothers (velocity, LFO-A,
   LFO-B).
6. **`[10096]`/`[10112]`, `[10128]`/`[10144]`, `[10432]`/`[10448]`** — three
   one-poles where the *shadow* is the cell actually read; collapse each pair
   to a single variable holding `state[n−1]`, but keep both stores if state
   parity is wanted.
7. **`[10480]`, `[10496]`, `[10512]`, `[10528]`** — the tone shelves' `x[n−1]`,
   `yA[n−1]`, `yB[n−1]`. The memory layout aliases them (§6.2); the *variables*
   are three, plus the current input.
8. **`[7520]`, `[7536]`, `[9040]`** — carried only in the `[7632]!=1` /
   `[9056]!=1` held branches, which are unreachable in the port (both cells are
   1.0 from prepare and have no other writer). Keep the branch or document its
   removal; do not silently drop the hold semantics.

### 6.2 What is pure memory round-tripping

Safe to eliminate for the audio null (`null_ab.py` compares samples only):

- **Same-sample latches**: `[6704]`, `[6848]`, `[6976]`, `[7040]`, `[7072]`,
  `[7248]`, `[9632]`, `[9648]`, `[9664]`, `[10048]`, `[10064]`, `[10080]`,
  `[10416]`. Written then read a few lines later, never across samples.
- **Register-promoted scratch**: `[8336]`, `[8352]`, `[8368]`, `[8384]`,
  `[8400]`, `[8416]`, `[9008]`, `[9024]` — pilot 2 already did this
  (`voice_render.c:34-54`); the stores remain only so probes see them.
- **Write-only shadows**: `[6560]`, `[6592]`, `[6624]`, `[6656]`, `[6688]`,
  `[6880]`, `[6912]`, `[6992]`, `[7056]`, `[7184]`, `[7264]`, `[7280]`,
  `[8992]`, `[9568]`, `[10160]`, `[10544]`, `[10656]`.
- **Two explicit reloads**: `v222 = [7104]` (:1204) reloads what :1194 just
  stored; `v375 = [10416]` (:1613) reloads what :1611 just stored. Use the
  register.
- **Two dead stores**: `[7568] = v230` (:1234, overwritten :1239 whenever the
  gate is on) and `[[10432]] = [[10416]]` (:1607, overwritten :1612). Also
  `[7104] = v212` (:1189) and `[7184] = v216` (:1197).
- **The `[10496]`/`[10512]` alias**: in memory, `10496` is read as `x[n−1]` and
  written as `yA[n]`; `10512` is read as `yA[n−1]` and written as `yB[n]`. In a
  native rewrite these are four independent variables. Reproducing the alias is
  only needed for byte-level state comparison.
- **`v360`'s duplicated sub-expression** (:1586-1588): `v357 + [10208]*[10048]`
  is written twice; computing it once is bit-identical.

**Caveat.** Dropping the shadow stores makes the port fail any *state* diff
(`recall_gate.py`, `coldstate_ab.py`, `renderstruct_ab.py`), which compare
engine cells, not audio. Track B's gate is audio-only, but the project's
existing gates are not — so either keep the stores or run the state gates
against the transcribed reference, not the native candidate.

### 6.3 Where rounding order is observable (must not restructure)

- **The mod sum's three-level grouping** `(A+B) + ((C+D)+E)` (§3.5). Any
  flattening changes the last bits of the cutoff.
- **The cutoff clamp expression** `fmaxf(fminf(...+[7664], [7760]), [7776]) *
  [7824] + [7840]` — the `+[7664]` is *inside* the `fminf`, the `*[7824]` is
  *outside* both.
- **The `exp` polynomial's interleaved Horner** in `q = f²/4` (§3.7): the sinh
  and cosh series are woven together and the association is not the obvious
  one.
- **The `tan` rational**: numerator and denominator each have their own nesting
  with repeated `v238*v238` and `v239*v239` sub-terms; `v239 = v238*v238` is
  computed once (:1274) and `(v238*v238)` is recomputed inline several times —
  same value, but the *tree* must match.
- **`v246 = 1.0 − (v241 + v241)`** — not `1 − 2*G`.
- **The quintic** `x + ((((x*x)*x)*x) * (x*[9184]))` — not `x + k*x*x*x*x*x`
  and not `x*(1 + k*x⁴)`.
- **Every one-pole is `(a*t − a*s) + s` or `(t − s)*a + s`** — the two forms
  appear in different places and are **not** interchangeable at the bit level.
  Compare :1175 `((v205-v206)*[6928]) + v206` with :1543
  `(([9888]*v336) - ([9888]*v337)) + v337`.
- **The FIR accumulation order** (centre-out, with `v324`/`v325` injected out
  of sequence) — §3.10.
- **The four sub-steps' interpolation associations** differ (§3.9); sub-step 4's
  tap association differs from sub-steps 1-3 (§3.9, commutative but written
  differently).
- **Two clamps have asymmetric NaN behaviour**: the ladder input clamp sends
  NaN to −1.0 (:1358-1361) and the cutoff-CV clamp sends NaN to 1.0
  (:1161-1168). A `fminf/fmaxf` pair in the "wrong" order changes both.
- **`1.0 / (…)` must be a division** (:1345). SSE `rcpps`, a Newton iteration,
  or `-ffast-math` will not null.
- **`expf` must be the platform libm's `expf`** (or an exact 10-entry table of
  its integer outputs). Never `exp()` truncated to float, never `exp2`-based.

---

## 7. RISK list — where a native rewrite will break the −90 dB null

Ordered by my estimate of likelihood × blast radius. Each item names an
isolation test that does not need the full engine.

| # | Risk | Why it bites | Isolation test |
|---|---|---|---|
| R1 | **`expf`/`tan` chain re-implemented as "the obvious" `tanf(M_PI*fc/fs)`** | Changes `G` in the last bits on *every* sample, so *every* patch drifts. The plugin's `tan` is a 5-term rational; its `exp` is `expf(floor) × a woven Taylor`. | Drive `v227` over its full clamped range `[-3, 11]` in 2²⁴ steps through both the transcribed :1255-1292 and the candidate; require bit-identical `[7520]`. No audio needed. |
| R2 | **FIR summation re-ordered** (natural `t0→t15`, or a `for` loop) | 16 float adds; reordering shifts the result ~1 ULP per sample, which at 30000 frames is well above −90 dB on resonant patches. | Feed a fixed 32-sample vector into both FIR expressions; require bit-identical output. |
| R3 | **`1/(1+G⁴k)` via reciprocal approximation or `-ffast-math`** | Silent, compiler-flag-driven; scales the whole resonance path. | Compile the candidate and disassemble for `rcpss`/`vrcp`; plus a unit test `v247` over `G∈[0,0.3]`, `k∈[0,5.4]`. |
| R4 | **The ladder pipeline treated as a uniform 7-tap delay line** | `[8288]`/`[8304]`/`[8320]` hold *state contributions*, not stage outputs; a uniform shift feeds the wrong values into the feedback and into stage 4. Fails loudly on high resonance, subtly at low resonance. | Single-voice impulse into `[6544]` with `[6832]` swept 0→255; compare `[9040]` sample-by-sample against the transcription. |
| R5 | **Tone shelves implemented as FIRs** (following CELLMAP's mislabel, §1.8) | Removes the pole entirely; changes the spectrum on every patch with `VCA TONE != 0` (bipolar curve 24, nonzero on most patches). | White noise through `:1614-1637` alone with `[9632]` = ±0.5; compare magnitude response and bits. |
| R6 | **HPF using `lp[n]` instead of `lp[n−1]`** (:1583-1585) | A one-sample error in the subtraction — inaudible in isolation, but it is a *different filter* and never nulls. | Step response of `:1583-1585` with `[10240]` at the recalled default; compare bits. |
| R7 | **`[9072]`/`[9088]` assumed nonzero, or the tap sum dropped** | They are 0 by calloc with no writer, so the tap is `1.0*stage4`. A native port that "simplifies" to stage 4 is *correct today* but silently wrong if a future recall path writes them. | Grep gate: assert no writer of 9072/9088 exists in `src/`; keep the three-term sum. |
| R8 | **Rate-armed constants collapsed into one arm or a continuous law** | 10 filter-path cells differ at 44100 (§4.2), including the cutoff clamp `[7760]` and the whole tone-shelf set. The port is gated at 44.1 k *and* 88.2 k; a continuous law passes neither. | Cold-state compare: build at 44100 and at 96000, dump `[6928 7120 7200 7696 7712 7760 7856 10384 10464 10560..10640]`, compare to §4.2. |
| R9 | **`juno_wrap24` re-expressed as `fmodf`** | The bit-fiddling tie adjustment on bits 21/23 is the algorithm (`juno_dsp.c:11-19` says so explicitly). Both dither oscillators diverge within a few hundred samples, and the divergence is *additive noise* — exactly what a −90 dB null measures. | Iterate `x = juno_wrap24(-x)` 10⁶ times from the power-on value in both implementations; require bit-identical sequences. |
| R10 | **`v42` / `v19` seeded inside the filter block** | Both are seeded far away (:689 and :633). Seeding them locally is *usually* the same, but changes the NaN path of the cutoff clamp and the `-0.0` tone path. | Force `[6736]` to a value making the taper NaN/negative; force `[9632] = -0.0`; compare `[6704]` and `[10544]`. |
| R11 | **`[10320]` (CONDITION amp level) or `[7600]` (CONDITION cutoff) applied before `seed_voices`** | They are per-voice-DISTINCT (`juno_apply.c:462-485`); a block copy clobbers the scatter and all 8 voices become identical — audible as a lost chorusing, and the null fails on every patch. | Recall any patch, dump `[7600]` and `[10320]` for voices 0..7, assert 8 distinct values. |
| R12 | **`[10240]` recalled without re-joining HPF TYPE** | The four HPF cells are a joint function of blob 38 **and** record byte 618 (`juno_apply.c:691-701`); 10 factory patches are TYPE 1. | Recall the 10 TYPE-1 patches, compare `[10240 10256 10272 10288]` against `hpf_type_lut.c`. |
| R13 | **One-pole written in the other algebraic form** (§6.3) | `(t−s)*a+s` vs `(a*t−a*s)+s` differ by 1 ULP; there are 6 one-poles in this subsystem and the errors accumulate through the resonant loop. | Per-smoother unit test over 10⁶ random `(t,s,a)` triples. |
| R14 | **Sub-step interpolation weights swapped between steps 1 and 3** | Both use `[9216]`/`[9232]`; only the operand pairing differs (:1350-1352 vs :1421). Easy to transcribe symmetrically and wrong. | Impulse into `[6544]`, dump the four line heads `[8816] [8688] [8560] [8432]` for one sample, compare bits. |
| R15 | **`-ffp-contract` not `off`, or `-O3` vectorisation of the FIR** | FMA collapses `a*b+c` into one rounding; the reference is x86 SSE2 with no FMA. The existing FMA canary test covers the shipped build, not a Track-B candidate. | Add the FMA canary to the candidate's own test list before running `null_ab.py`. |

### 7.1 Gate-coverage gap worth closing first

`tools/trackb/null_ab.py`'s docstring (lines 22-23) claims the scenario set
covers "a high-resonance patch", but `SCEN` (lines 37-43) contains
patches 5, 15, 61, 20, 2 — pluck / MONO / UNISON / chorus pad / delay keys.
**There is no explicitly high-resonance scenario**, which is precisely where
R3, R4, R9 and R13 do their damage (the resonance loop multiplies the error by
`1/(1+G⁴k)` every sub-step). Before trusting a −90 dB pass on this subsystem,
add a scenario on a patch with `blob37` (VCF RESONANCE) near maximum and a low
cutoff, plus a cutoff sweep (live `juno_gui_set_param` on the VCF CUTOFF row)
so `[7520]` actually moves during the render — every current scenario holds the
cutoff constant, so the whole `:1230-1292` mapper is exercised at exactly one
operating point per patch. **READ from the tool source; not executed here.**

### 7.2 Suggested build order for the native VCF

1. `:1150-1229` (taper, latches, smoothers, mod sum) — pure feed-forward, no
   state except three one-poles. Test against R13, R10.
2. `:1230-1292` (the mapper) — the highest-risk block; test in isolation
   (R1, R3, R9) before wiring it to anything.
3. `:1298-1488` (the ladder) — build with `[9184] = 0` first (linear ladder,
   exactly solvable) to validate the pipeline and the ZDF solve, then enable
   the quintic. Test R4, R14.
4. `:1489-1514` (the decimator) — test R2 standalone.
5. `:1568-1640` (HPF/boost/DC/tone/output) — test R5, R6.

Only then run `null_ab.py --cand`; and run `null_ab.py --teeth` first to
confirm the gate still has teeth on the current tree.

---

## 8. Open questions

1. **`[6576]`, `[6608]`, `[6640]`, `[6672]`, `[7008]`, `[7024]`, `[7312]`,
   `[7328]`, `[7376]`, `[7456]`, `[9552]`, `[10224]`, `[7616]`** have no writer
   anywhere in `src/` ⇒ 0 from calloc. Several of them are *settable parameter
   descriptors* in the plugin (`[7008]` "Env1/2", `[7024]` "Int/Env" are named
   in the registry). The simplifications they enable (`v200 == [6736]`,
   `[7072] == [2752]`, `v360 == v357 + [10208]*[10048]`, `v226 == 0`) are
   correct **today**; confirm against the binary before hard-coding any of
   them, exactly as `ENV.md` §5 flags for `[9552]`/`[10224]`.
2. **`[7808]`** (−4.75, `juno_init.c:1089`) is written and never read. Either
   it belongs to a code path the transcription does not reach, or the
   constructor writes a cell the render abandoned. Worth a single grep against
   the decompile before declaring it dead. INFERRED dead.
3. **The `[7760]` clamp at non-44100 rates.** At 44100 the constant places
   `fc_max` exactly at the host Nyquist (§3.7); at 96000 the stored 11.0 does
   *not* produce the analogous relation. Consistent with the plugin's frozen
   2-arm design, but it means the filter's top end is rate-dependent in a way
   that is not a simple scaling. INFERRED; do not "correct" it.
4. **`[8288]`'s write at :1484 uses `v320 + (v246*v319)`** while the in-loop `S`
   uses the full :1377-1381 form. They are the same expression with `v320`
   playing the role of the inner nest — I verified the shapes match, but the
   *last* sub-step's `S` is the only one that crosses the sample boundary, so
   any error there is a once-per-sample DC-ish artefact rather than a 4× one.
   Worth a targeted A/B.
5. **`[7104]` vs `[7184]` asymmetry** (§3.4): LFO-A round-trips through memory,
   LFO-B does not. Numerically identical; if the plugin ever adds a consumer of
   `[7184]` the asymmetry becomes meaningful. INFERRED harmless.
6. **The 16 FIR taps sum to 0.49999999** (PROVEN(decode), §3.10) and
   `[9152]·[9136] = 1.0` exactly. This is a strong internal consistency check
   that the tap→lag mapping in §3.10 is right; it does **not** prove the
   *pairing*, only the gain — a candidate that pairs the lines wrongly would
   still sum to 0.5. The pairing itself is READ from the source expression, not
   proven by a null.
7. **`[7856]` = π·440/(4·H)** matches to 7 significant figures (PROVEN(decode):
   cell 0.007836172357201576 vs π·440/176400 = 0.007836172151811276 — a 2.6e−8
   relative difference, i.e. the constant was stored to float precision from a
   slightly different expression). The "440 Hz" and "4×" readings are therefore
   INFERRED, not exact; the *cell value* is what a native port must use.
