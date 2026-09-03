# CHAIN4 — the ORIGINAL-port CLASSIC on FOUR boards

Four three-bin sets, one per chain position. Design + wiring:
docs/engineb/CHAIN4.md. Engine: trunk + EXACTLY-0 levers + EB_CLASSIC
(the b44 CLASSIC-EXACT recipe), chord-6 answer key, base 0 on every chip.

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
  N.GPIO15 <- (N-1).GPIO10   hop BCLK   (downstream drives)
  N.GPIO16 <- (N-1).GPIO11   hop LRCK   (downstream drives)
  N.GPIO17 -> (N-1).GPIO12   hop DATA   (upstream drives)
  N.GPIO8  -> (N-1).GPIO14   control    (upstream TX)
  N.GPIO9  <- (N-1).GPIO13   control    (downstream TX)
DAC stays on chip 1 GPIO 5/6/7; MIDI (optional) chip 1 GPIO 18.
