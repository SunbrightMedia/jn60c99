# PCB PLACEMENT DETAILS — MasterAudio board

Running notes for the PCB editor stage. Written during schematic work.
Add to this file as more items appear.

---

## 1. BULK CAPACITORS — the two 22 uF on +5V

Do NOT put both next to the polyfuse. Split them:

1. **First 22 uF — at the polyfuse output.** This is where +5V begins.
   It catches the supply's own ripple as current enters the board.
2. **Second 22 uF — at the far end of the slot row**, near slot 3 or slot 4.
   The boards farthest from the entry point see the weakest supply, because
   the trace between them has resistance. A reserve tank out there steadies them.

Reason for splitting: a capacitor only helps what is near it. Two caps side by
side act like one bigger cap in one place, and leave the far end unprotected.

These are the BULK reserve — a slow, large store for when all four boards draw
current at once. Different job from the 100 nF parts (see item 2).

## 2. THE 100 nF DECOUPLING CAPS — position is the whole point

Every powered chip has one. Each must sit **directly beside its own chip's
power pins**, on the same side of the board, with the shortest possible trace.
Their value is not critical; their position is.

Pairs to keep tight:
- 100 nF at the optocoupler — right beside its pins 5 and 6
- 100 nF at each MIDI buffer — beside its pins 3 and 5
- 100 nF at the DAC — beside each of its supply pins (it has several)
- 100 nF at each op-amp — one on the + rail, one on the - rail
- 100 nF at the mux
- 100 nF at the 3.3 V regulator output

A 100 nF cap placed 20 mm from its chip does almost nothing.

## 3. +5V DISTRIBUTION — wide copper

Four ESP boards can pull over 1 A between them. Run +5V as a **wide trace or a
copper pour**, never a thin line. Same for the ground return.

## 4. THE ANALOG SECTION — keep digital away

Analog parts: the DAC, both op-amps, the headphone amp, the volume pot, and the
three audio jacks.

Rules:
- **No digital traces routed through or past this area.** That includes the
  I2S lines beyond their series resistors, the breakout header traces, the USB
  data pairs, and anything from the slots.
- Keep the analog parts grouped together, near their jacks, away from the slot
  array and the USB/mux section.
- The 3.3 V analog regulator (3V3A) should sit near the DAC, not near the slots.

**Measured precedent from this project:** earlier in the build, an LED blinking
during serial output coupled electrically into the DAC and produced an audible
click. This was measured, not theoretical. Digital switching noise reaching the
analog section is a real, proven failure mode on this design.

## 5. THE 33 OHM SERIES RESISTORS (I2S to DAC)

Place them **close to the ESP slot-1 socket**, at the source end of the trace —
not near the DAC. Their job is to soften the sharp digital edge before it
travels, so they must come first.

## 6. THE 10 OHM BUILD-OUT RESISTORS (headphone output)

Place close to the headphone jack, at the end of the chain, after the amp.

## 7. BREAKOUT HEADERS (8 free GPIO per slot)

- Position is free — decide late, once the rest is placed.
- **Keep their traces away from the analog section** (item 4).
- Suggested pin order with a ground at each end:
  `GND, IO4, IO12, IO13, IO14, IO1, IO40, IO39, IO38, GND, 3V3_ESPn`
  A ground at both ends of the signal group gives every signal a short return
  path. Two grounds beat one; one beats none.
- Exposed strapping pins are a hazard: if something plugged into a header holds
  IO3 / IO45 / IO46 at a level during boot, that board will not start. Those
  three are NOT on the breakout headers by design. Keep it that way.

## 8. USB-C CONNECTORS

- The **CC resistors (5.1 k)** should sit close to their own connector.
- The **upload port's data pair** (D+ / D-) must run as a matched pair: keep the
  two traces the same length, side by side, and short. Route them straight to
  the ESD protection part, then to the mux.
- The **ESD protection parts** must sit right at the connector, before anything
  else on the data lines. That is the whole point of them — they intercept a
  static discharge at the entry point.

## 9. MOUNTING HOLES

Add four. Not electrical, easy to forget, and impossible to add after the board
is fabricated.

## 10. SLOT SOCKET ALIGNMENT — silkscreen note

The 40-pin and 44-pin ESP boards both fit the 2x22 sockets, but the 40-pin board
must be **centred**, leaving row 1 and row 22 empty at each end.

Print on the silkscreen beside each socket:
- Pin 1 marker
- "44-pin: fill all rows. 40-pin: leave top and bottom row empty."

Also print the populate-in-order rule: **slot 1 must always be populated.**
Fill 1, then 2, then 3, then 4 — never skip a slot, or the audio chain breaks.

## 11. SILKSCREEN — the upload switch

Label the four switch positions 1 / 2 / 3 / 4 next to the slide switch, so it is
obvious which board the upload port is pointed at.

## 12. THE LM2776 CHARGE PUMP (-5 V)

- Keep the **flying capacitor (2.2 uF) very close** to the chip's C+ and C- pins.
  That node switches fast; a long trace there radiates noise straight into the
  audio section.
- Keep the whole charge pump **away from the analog section**, even though it
  feeds it. It is a switching part.
- Its output capacitor goes close to its VOUT pin.

## 13. GROUND — one plane

Use a single continuous ground pour on an inner or bottom layer. Do not split it
into separate analog and digital islands unless you know exactly why you are
doing it — a split done wrong is worse than no split. A solid, unbroken plane
under the whole board is the safer choice here.

Avoid cutting long slots through the plane with traces; a return current forced
to detour around a slot is a noise source.

## 14. HEADPHONE AMP THERMAL

The TPA6120 has a thermal pad (pin 21 / EP). It **must** be soldered to a ground
copper area with thermal vias, or the chip overheats. Do not leave it floating.

---

## OPEN ITEMS TO RESOLVE BEFORE LAYOUT

- [ ] LM2776 placed and wired in the schematic (symbol is in the user's library)
- [ ] 10 k pullup on CTRL_RSP to 3V3A
- [ ] Decide: BOOT JSTs for slots 2-4 (optional, ~$0.10 each)
- [ ] Decide: board 4 listen header (S4_RX_BCK / _WS / _SD)
- [ ] BOM: JST quantities still blank (S2B, S3B, S4B)
- [ ] BOM: 1 k quantity 6 -> 8
- [ ] BOM: 2.2 uF +1 and 10 uF +1 for the LM2776
- [ ] BOM: PM254-1-11 header 16 -> 20 (breakout headers)
- [ ] BOM: 10 k +1 (CTRL_RSP pullup)
- [ ] Verify PJ-603 jack pinout against its datasheet (assumed 2=TIP, 5=RING, 3=SLEEVE)
- [ ] Verify slide switch pinout against its datasheet (assumed 1=COM, 3=POS2, 4=POS3, 5=POS4)
- [ ] Run ERC to zero errors before opening the PCB editor
