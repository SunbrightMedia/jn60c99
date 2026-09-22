# JP8 PORT LESSONS -- the legacy for the NEXT .vst3 port (mantra 4)

Written as earned, in the jx3p/docs/PORT_LESSONS.md style. Each item is a trap that
cost real time on the JUPITER-8 PLUG-OUT port and is now a one-line check. The JX
lessons 1-11 all still apply; these are the ones the JP8 added.

1. **The recall must take the HOST PARAM ENTRY's dispatch flag** (paid 2026-09-22,
   playbook 99). The JX oracle's `dispatch(flag=1)` was inherited. On the JP8 flag 1
   is "write the cell now" (0x440430) and leaves the boot ramp targeting that cell
   armed with its OLD limit; the plugin's own walker then reverts the cell within 64
   samples (jp8/logs/d4_ramp1480_p0.log) and a snap reverts it at once. ENV1
   SUSTAIN, MIXER VCO1, HPF, PORTAMENTO and FINE TUNE were silently lost on patch 0
   (d4_flag1_p0.log) and every listen proof before that day ran on a half-defaulted
   patch. HOSTPARAM 0x4465B0 dispatches with r8d = 0 (READ): flag 0 arms the ramp
   with the new limit and the walker/snap settles it (d4_flag0_p0.log: every cell
   holds after 4160 samples). `JP8.recall` now dispatches flag 0. Check: after the
   recall, let the plugin render 64 samples with NO snap and diff the cells.

2. **Probe overrides take the recall's path too.** A flag-1 override after a flag-0
   recall is undone by the snap (the recall's ramp is still armed). "MIXER VCO1 :=
   0" never muted VCO1; the f0 detector then read VCO1 (261 Hz) while the pitch
   cells said VCO2 (528 Hz) and a probe "refuted" the RANGE law
   (d4_spec_p2_rflag0_range4.log shows both peaks). Rule: overrides use flag 0 and
   are followed by the snap, and every f0 line carries `spectral_peaks`.

3. **The pitch cells are OFFSETS; the key enters at the oscillator.** [state+0x16e0]
   / [+0x16f0] read 2.0024 at keys 48, 60 and 72 alike (d4_spec logs). 0x39b21a
   adds the cell to the key term [0x35b0] before 0x394db0 (2^x). So expected f =
   midi_hz(key) * 2^(cell - 2.0), verified to the cent on three keys x three
   settings (d4_probe_p2_*.log). Reading a cell as an absolute pitch matched key 60
   by coincidence (65.4064 * 2^2 = C4) and was one octave off at key 48.

4. **A pitch-envelope patch fails an early-window listen law by design.** Patch 0
   'PD Jupiter Glide' (VCO ENV MOD 18, ENV1 A0/D140/S0) dives ~2.7 octaves and
   settles only after 1.5 s (d4_windows_p0_k60.log: -1197 cents from window 4 on,
   harmonic 0.99). The sweep measures a LATE window (49152..65536) when the early
   one fails and names the confound; it never tunes the patch.

5. **The parameter -> cell census is cheap and settles arguments.** One memory-write
   hook per dispatch (jp8_param_census.py, d4_param_census_p0.log) maps every panel
   id to its engine cells and value law in a minute: RANGE = table[.rdata 0xcbc2b8]
   (octaves), SUB RANGE = v/12, FINE TUNE = curve 0x40 of .data 0xd22428 + 0.0003.
   Do it before any pitch/timbre debate, and before step 5's recall layer.
