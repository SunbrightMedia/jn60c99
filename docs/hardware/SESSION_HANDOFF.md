# HARDWARE SESSION HANDOFF (written 2026-09-12)

Everything a fresh session needs to continue the MasterAudio / satellite-board
hardware work. Written as if this chat is deleted. Pairs with PCB_PLACEMENT.md
(placement rules), AUDIT.md (audit laws), CHAIN4.md (breadboard firmware).

The user hand-builds every KiCad schematic and PCB. Claude is a LEARNING TOOL,
not a board generator: give methods, part numbers, and pin-level answers — NEVER
auto-generate KiCad projects or edit the user's files unless explicitly asked.

## USER-BINDING PREFERENCES (do not violate)
1. Reply in ASD-STE100 Simplified Technical English, under ~150 words
   (tables/code exempt). Direct answer first.
2. Audits are ALWAYS net-level, never count-only. See AUDIT.md.
3. Connector rows on the four ESP sockets use aliases L1-L22 / R1-R22, never
   raw KiCad pin numbers.
4. GND on pin 1 of EVERY JST connector.
5. JST stock: 2/3/4-pin JST-XH only (mostly 3-pin). Side-entry S2B/S3B/S4B.
6. Zip any file sent whose name has hyphens (the download pipeline strips them).
7. Verify EVERY LCSC part before quoting — never from memory. LCSC pages are
   blocked from Claude's network; use web search or ask the user to open the page.

## THE AUDIT TOOL — tools/hardware/schem_audit.py
THE single net-level auditor for any .kicad_sch. Committed this session.
- `python3 schem_audit.py FILE.kicad_sch` — net dump + STUB/NC/ambiguity checks.
- `python3 schem_audit.py FILE.kicad_sch --tooth` — self-test; ALL teeth must
  BITE or the run is untrusted. Teeth: cut-wire, t-tap, unmirror, rotate90,
  drop-label.
- `python3 schem_audit.py FILE.kicad_sch --bom BOMFILE.txt` — every intended
  LCSC part must be PLACED on the sheet or FAIL (BOMFILE = whitespace list of
  C-numbers).
- AUDIT LAW: teeth before trust; raw geometry before any FAIL; if a tooth does
  not bite, say so and DO NOT trust the STUB verdicts.
Three tool bugs were found and fixed this session (each now guarded by a tooth):
  D1 label-only nets (wire-only nets read as floating), D2 dropped mirror,
  D3 wire-to-wire T-tap merge (junction dots). Never audit with an ad-hoc script.

## MASTERAUDIO BOARD — current state
Latest good file (user's PC): the 09d916c4 / f08694c4 generation. Net audit
GREEN, all teeth bite, 0 STUBs. Board keeps the analog AND digital sections
together (user chose NOT to split DAC/digital boards — the JLC per-unique-board
assembly fee is too high). So place with extra care: rules 4, 12, 13, 14 in
PCB_PLACEMENT.md are load-bearing.

### Bead FB1 (C46550600) — PLACED, wired right
600R 0805 ferrite in the PCM5102A (U1) analog rail:
`3V3A -> FB1 -> AVDD_F(=U1 pin 8 AVDD)`, and C40 (100nF) moved to AVDD_F->GND.
FB1's EasyEDA library entry 404s (part alive on LCSC, model on Pro backend only);
its footprint lives only in the user's Global_LCSC library — BACK IT UP.

### MIDI — MOVING to its own board (midi3), delete from MasterAudio
The user has a standalone midi3 board (IN+OUT+THRU): opto U4 (H11L1S), buffers
U5/U6 (SN74AHCT1G126), 3 DIN-5, pull-up R6 1k, decoupling C1/C2/C3. It audits
clean, self-contained. Interface = TWO 3-pin JSTs:
  CN1 power: GND / +5V / +3V3      CN2 signal: GND / MIDI_RX / MIDI_TX
DELETE from MasterAudio: U7 (opto), U8, U9 (buffers), J1/J2/J3 (DIN), R30 R32
R33 R34 R35 (220R), R31 (pull-up), D3 (clamp), C28 C30 C61 C63 (decoupling for
those chips — NOT C64, which is 267mm away by the DAC). Delete their wires/labels.
KEEP on MasterAudio: J11 (existing 3-pin MIDI JST) becomes the SIGNAL cable to
CN2; ADD one 3-pin JST (S3B-XH C157928) for the POWER cable to CN1.
Power source: +5V (buffers) and **3V3_ESP1** (opto pull-up) — NOT 3V3A (analog),
NOT 3V3_ESP4 (dead when slot 4 empty). 3V3_ESP1 is the only always-present slot
rail (slot 1 is always populated). Levels are safe: MIDI_RX pulled to 3V3 =
3.3V-safe for the ESP; MIDI_TX 3.3V drives the AHCT (TTL-threshold) buffer fine.

### R63 change (pending)
R63 (10k) is the CTRL_RSP bus pull-up. Change pin 2 from `3V3A` to
`3V3_ESP1` (keep digital noise off the analog rail). Place R63 near the slot-1
socket (short 3V3_ESP1 stub); it taps the shared CTRL_RSP bus. Never use
3V3_ESP4 (dead in 1-3 board setups). Re-run ERC after.

### SW2/SW3 reset button
The master-reset was assigned the WRONG footprint (SSSS812701, a 4-pos slide =
SW1 the upload selector). The reset is a 2-terminal button. Chosen part:
TS-1102-5016, LCSC **C111609** (6x6 through-hole tactile, robust, 4 pads = 2
pairs). Wire diagonal pins: one terminal -> EN_ALL, other -> GND. Alternatives:
6x6 SMD C720477; 12x12 THT C2845239.

### U12 LM2776 (-5V generator)
Makes VNEG (-5V) for the OPA1656 op-amps (U3,U4) and TPA6120 headphone amp (U2)
so audio swings below ground. Its footprint (SOT-23-6) was missing from
Global_LCSC — import C69527. Flying cap C1 (2.2uF) tight to C+/C-.
J10 (VNEG IN 2-pin JST) is a LEGACY external -5V input, redundant now U12 exists.
Delete it unless the user wants to export -5V or bypass U12.

## MUX / 595 ENABLE SYSTEM — split to a satellite board
The 16 EN JSTs + mux headers bloated the master board. Decision: the mux16
boards (CD74HC4067, the user already has muxboardv1) and a small 595 enable-driver
satellite board leave the master with only the existing J14/J15 pair.

### Master <-> mux board connectors (already on MasterAudio, 1:1 straight cables)
J15 (3-pin SIGIN):  1 GND, 2 SIG(SDA1 via R64, IO8 ADC1), 3 VCC(3V3_ESP1)
J14 (4-pin SEL):    1 SCL1(S0), 2 SEND1(S1), 3 SEND2(S2), 4 SEND3(S3)
Names differ from the mux board's silk (SIGIN/SEL) but map pin-for-pin. Cable is
straight-through; keep pin 1 the same physical end on both housings.
Rules: do not use the I2C header (J12) and the mux at once (shared IO8/IO3);
RC filter R64(1k)+C67(10nF) sits at the ADC end, tight to slot-1 socket H1B pin 1.

### 595 enable-driver satellite board (BOM)
Purpose: 2x SN74HC595 give 16 EN lines from 3 GPIOs, chainable.
| Qty | Part | Value | LCSC |
|---|---|---|---|
| 2 | SN74HC595DR | shift register | C10092 |
| 2 | 100nF | 0805 decoupling | C49678 |
| 1 | JST-XH 4-pin | input ctrl: 1 GND, 2 DS, 3 SHCP, 4 STCP | C157925 |
| 1 | JST-XH 2-pin | input power: 1 GND, 2 3V3_ESP1 | C157931 |
| 2-4 | M3 mounting hole pad | — | KiCad MountingHole:MountingHole_3.2mm_M3_Pad |
Outputs = 16 EN lines; connector style still UNDECIDED (16x 2-pin C157931, or
fewer multi-pin). 595 chain wiring: chip A DS<-DS, both SHCP shared, both STCP
shared, A QH'(pin9)->B DS(pin14), ~MR->3V3(never reset), ~OE->GND, VCC+GND+cap.
Firmware shifts 16 bits, one bit low = that mux enabled.

## RESISTOR PLACEMENT MAP (MasterAudio) — where each goes on the PCB
Principle: edge-shaping R at the SOURCE; input filter/protection R at the
DESTINATION; feedback/gain R tight to the amplifier.
| Refs | Value/LCSC | Job | Place near |
|---|---|---|---|
| R1-R4 | 33R C23140 | line-out series | jacks J6 (L) / J7 (R) |
| R5-R7 | 33R C23140 | I2S series termination | slot-1 socket (H1A), SOURCE |
| R8,R9 | 10R C22859 | headphone build-out | HP jack J8 |
| R20,R21 | 5.1k C23186 | USB-C CC (upload J5) | at J5 |
| R23,R24 | 5.1k C23186 | USB-C CC (power J4) | at J4 |
| R22 | 10k C17414 | power-LED limit | LED1 |
| R25,R27 | 10k C17414 | upload-select pulldowns | mux U6 / switch SW1 |
| R26 | 10k C17414 | DAC XSMT pull-up (to 3V3A, OK) | DAC U1 pin 17 |
| R28 | 10k C17414 | volume RC into ADC (with C29) | slot-1 ADC pin H1C1.5 |
| R40,R41,R46,R47 | 1k C21190 | op-amp gain/feedback | U3/U4 (OPA1656) |
| R42-R45 | 1k C21190 | TPA6120 feedback/gain | U2 |
| R48-R56 | 330R C25231 | I2S hop series term | driver socket: R48-50 slot2(H2A), R51-53 slot3(H3A), R54-56 slot4(H4A) |
| R57-R62 | 330R C25231 | control-UART hop term | R57 s2,R58 s1,R59 s3,R60 s2,R61 s4,R62 s3 |
| R63 | 10k C17414 | CTRL_RSP bus pull-up | slot-1; retarget to 3V3_ESP1 |
| R64 | 1k C21190 | mux SIG RC into ADC (with C67) | slot-1 socket H1B pin 1 |
| R30-R35, R31 | MIDI | DELETE (moving to midi3) | — |

## KEY PART NUMBERS (verified this session)
PCM5102A DAC C107671 · OPA1656 op-amp C1849431 · TPA6120 HP amp C70439 ·
TPS7A2033 3V3A LDO C2862740 · LM2776 -5V C69527 · CD4052 USB mux C253890 ·
USBLC6-2SC6 TVS C2827654 · H11L1S opto C899473 · SN74AHCT1G126 buffer C163712 ·
SN74HC595 C10092 · CD74HC4067 mux16 C496123 · DIN-504D-M5 C2939347 ·
PJ-603 audio jack C41409498 · Type-C C165948 · RK09K pot C351173 ·
polyfuse C438899 · reset button C111609 · upload slide SW SSSS812701 C2843299 ·
ferrite bead C46550600 · Type-C mux etc. See the schematic BOM for all.
Passives: 100nF 0805 C49678 / 0603 C14663 · 220R 0805 C17557 / 0603 C22962 ·
1k 0805 C17513 / 0603 C21190 · 10k 0805 C17414 · 33R 0603 C23140 ·
10R 0603 C22859 · 330R 0603 C25231 (also 0805 C25231?) · 5.1k C23186 ·
4.7k C23179 · 22uF C45783 · 10uF C15850 · 2.2uF C23630 · 1N4148W C81598.

## LIBRARY MANAGEMENT (easyeda2kicad)
- ONE global library `Global_LCSC`. Register it once in BOTH the global SYMBOL
  and FOOTPRINT tables (Preferences -> Manage ... Libraries -> Global).
- Nickname MUST be exactly `Global_LCSC` (no asterisk, no space — those are
  illegal). Some old boards use the dead nickname `A_lcsc` or a broken
  `*Global LCSC` symbol prefix; fix by find/replace `A_lcsc:`/`*Global LCSC:`
  -> `Global_LCSC:` in the .kicad_sch, OR the footprints will not resolve.
- The user CDs into `C:\Users\sunbr\Documents\KiCad Resources` and runs, per part:
  `easyeda2kicad --full --overwrite --lcsc_id=Cxxxx --output ./Global_LCSC`
  (relative path — the user always CDs first; do not switch to absolute).
- EasyEDA API RATE-LIMIT: ~14 new parts per window, then HTTP 403 for the rest.
  Do NOT re-run finished IDs (they burn the budget). Wait, then run only the
  missing list. A different error, "Failed to fetch ... (not 403)" or a 404 from
  `easyeda.com/api/products/Cxxxx/components`, means EasyEDA deleted/migrated the
  part's library entry (Pro-backend only) — the tool cannot get it. Then: copy
  the footprint/symbol from another machine, or use KiCad stock parts (a bead is
  just Device:FerriteBead + Resistor_SMD:R_0805; a jack is mechanical, needs the
  real footprint). JLC2KiCadLib shares the same EasyEDA backend — it will NOT help.
- BACK UP the Global_LCSC folder: it holds footprints that no longer exist upstream.

## KICAD HOW-TO NOTES (learned this session)
- 3D-model offset applies per FOOTPRINT: edit the footprint's 3D tab, save, then
  Tools -> Update Footprints from Library to push to all instances.
- Malformed-courtyard DRC: the easyeda footprint drew F.CrtYd as overlapping
  segments. Fix IN THE FOOTPRINT (not the PCB): delete all F.CrtYd graphics, draw
  ONE closed Rectangle, save, Update Footprints from Library.
- Thermal-relief / spoke DRC on a GND pad: set the pad's Zone Connection to
  Solid (fine for hot-plate reflow), or add stitching vias, or lower min spoke
  count. Split GND pours need a via in EACH island to join through the other layer.
- Stitching via: route a short GND track from the pad, press V to drop a via and
  switch layer, then B to refill.
- Mounting-hole grid rule: 8.25mm from grid line = 8.00mm from board edge;
  hole spacing 42n - 16.5mm (see PCB_PLACEMENT.md item 19).
- Solder jumper (3-way, address select): symbol Jumper:SolderJumper_3_Open,
  footprint Jumper:SolderJumper-3_P2.0mm_Open_TrianglePad1.0x1.5mm (largest stock).
- Fab output: KiCad File->Plot (Gerbers) + drill, or install the "Fabrication
  Toolkit" plugin via Plugin and Content Manager for one-click JLCPCB output.

## 4-LAYER STACKUP (MasterAudio)
L1 Top: components + short signal routing (local fills only).
L2 inner: SOLID unbroken GND plane (full pour) — never split.
L3 inner: power pours as separate zones +5V / 3V3A / VNEG + slow routing.
L4 Bottom: signal routing, analog kept apart (local GND fill).
Wide +5V/GND (>1A). No digital over the analog cluster. D+/D- matched pair.

## SMART BUTTON/FADER BACKPACKS (design decided, not yet built)
Digital button/LED boards use ONE PCA9555/XL9555 I2C expander (16 IO) —
LCSC XL9555 **C609791** (~$0.25, cheaper clone of PCA9555, TSSOP-24). 8 buttons +
8 LEDs per board, 4 wires out (GND/VCC/SDA/SCL), address by 3 solder jumpers
(0x20-0x27, 8 boards/bus). Daisy-chain via two 4-pin bus JSTs in parallel.
BOM per board: XL9555 C609791, 1x 100nF C49678, 8x 220R C17557, 2x 4-pin JST
C157929 (VERIFY — 4-pin S4B-XH-A C157925 is the confirmed one; C157929 unverified),
button/LED parts. Bus pull-ups (2x 4.7k) once on the master only.
Buttons on the existing 3-button analog scheme still work: common=SIG(mux),
A=VCC, B=GND. FADERS/POTS stay analog (mux -> 1k+10nF RC -> ESP ADC1) — the
expander is DIGITAL ONLY, no analog.
I2C address clash escape hatch: reserve address blocks, use both ESP I2C buses,
or add a TCA9548A switch (8 segments x 8 = 64 boards). A per-board MCU
(CH32V003 ~$0.15) gives arbitrary addresses but adds a firmware project — the
user chose the expander for zero firmware.

## BREADBOARD 4x ESP32-S3 BUILD (CHAIN4 firmware) — unaffected by PCB changes
This runs the CHAIN4 firmware, separate from the MasterAudio PCB work above.
Wiring follows CHAIN4.md section 6 (CARRIER pin map, 2026-09-08):
hop N talks to N-1 (N=2,3,4):
  N.15 <- (N-1).9,  N.16 <- (N-1).10,  N.17 -> (N-1).11   (audio I2S RX)
  N.5  -> (N-1).47, N.6  <- (N-1).46                       (control UART)
  plus common ground.
If the breadboard used an OLDER pin map (control on IO5/6 to other pins), rewire
to the carrier map. Firmware review this session fixed the chunk-marker law
(distinct tag, bounded realign) — gated, images rebuilt/committed. Flash from
esp32s3/flash/chain4/pos{1..4}. Criterion: hs=OK + mix=OPEN + chord-6 CRC MATCH
on all four consoles.

## OPEN ITEMS BEFORE FAB (MasterAudio)
- [ ] Delete MIDI parts (list above); add the 3-pin power JST to CN1.
- [ ] R63 -> 3V3_ESP1.
- [ ] Import C69527 (LM2776 footprint) and C111609 (reset button).
- [ ] Verify PJ-603 pinout (assumed 2=TIP, 5=RING, 3=SLEEVE) and slide-switch
      pinout (assumed 1=COM, 3/4/5 = POS2/3/4) against datasheets.
- [ ] Decide J10 (keep as -5V export, or delete).
- [ ] Fix any A_lcsc / *Global LCSC nickname mismatches so all footprints resolve.
- [ ] Fix malformed courtyards (redraw F.CrtYd rectangles in the footprints).
- [ ] Add 4 mounting holes (grid rule).
- [ ] ERC to zero, then schem_audit.py --tooth then the audit + --bom, all GREEN,
      immediately before generating fab outputs.
