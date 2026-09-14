# CHAIN4 — the FULL ORIGINAL PORT on FOUR boards

Four three-bin sets, one per chain position. Design + wiring:
docs/engineb/CHAIN4.md. Engine: trunk + levers + the uniform CR set
(USER-BINDING 2026-09-14), full master chain (delay+reverb live),
chord-6 answer key, base 0 on every chip.

⚠ THE FOUR IMAGES ARE A SET. The event chain now carries parameter
events (kind 3); an older follower image misreads them as note-offs.
Always flash all four from the same zip, never pos1 alone.

| dir | position | renders slots | role |
|---|---|---|---|
| pos1/ | 1 (DAC end) | 7 | chorus + master + DAC + MIDI/console; notes enter here |
| pos2/ | 2 | 6 | forward + merge |
| pos3/ | 3 | 4,5 | forward + merge |
| pos4/ | 4 (far end) | 2,3 | chain head |

Flash each board with ITS OWN pos directory (the three-bin convention,
one line, from inside that directory):

  python -m esptool --chip esp32s3 -b 460800 --before default-reset --after hard-reset write-flash --flash-mode dio --flash-size 8MB --flash-freq 80m 0x0 bootloader.bin 0x8000 partitiontable.bin 0x10000 juno_s3.bin

A board with NO wires runs alone: it plays its own voice window, the mix
gates stay closed, and CHAINup/CHAINdn report "no peer yet" — that is
normal, not a fault. Bring-up order that diagnoses itself: flash all four,
wire ONE hop at a time (control pair first, then the three audio wires),
and watch for hs=OK then mix=OPEN on the downstream console.

Wiring per hop (N = 2,3,4 talks to N-1), plus common ground:
  N.GPIO15 <- (N-1).GPIO9    hop BCLK   (downstream drives)
  N.GPIO16 <- (N-1).GPIO10   hop LRCK   (downstream drives)
  N.GPIO17 -> (N-1).GPIO11   hop DATA   (upstream drives)
  N.GPIO5  -> (N-1).GPIO47   control    (upstream TX)
  N.GPIO6  <- (N-1).GPIO46   control    (downstream TX)
DAC stays on chip 1 GPIO 5/6/7; MIDI (optional) chip 1 GPIO 18.

## The hand panel (BOARD 1 ONLY — safe while unwired)

Buttons: wire a normally-open button from the pin to GND. The pin has an
internal pull-up, so an unwired pin plays nothing.
  IO12 = octave down     IO13 = octave up
  IO14 = C   IO15 = C#   IO16 = D   IO17 = D#
Pots (10k linear is good): outer legs to 3V3 and GND, wiper to the pin.
  IO1 = VCF CUTOFF       IO4 = VCF RESONANCE
A pot must be held STILL for about half a second before the firmware ARMS
it (the console prints `PANEL: ... ARMED`); arming sends nothing — move
the knob after that to take the value over. An unwired pot never arms.
Board 1's console must show the robot OFF ('r') to hear your own hands.
One knob moves ALL SIX voices: parameter events ride the event chain to
every board.
