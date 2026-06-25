# Render conventions

User-set rules for how patches are auditioned. Honor these for every render.

1. **Arpeggiated presets are ALWAYS rendered arpeggiated.** If a preset has its
   arpeggiator engaged (bank ARPEGGIO SW = 1, e.g. "SQ Dynamic ARPG"), render the
   held chord *through the arp* — never a held/non-arpeggiated version. Do not send
   a non-arp render of an arp patch.
2. Native sample rate is 96 kHz (the engine's coefficients are 96 kHz-calibrated).
3. Tempo for arp/timed renders: 120 BPM unless told otherwise (matches the user's
   reference DAW). SQ ARPG arp = UP, 1 octave, 1/16 steps.
4. Use the EXACT factory preset from the bank by record index (SQ Dynamic ARPG =
   record 1, the 2nd preset). Capture-free path only.
