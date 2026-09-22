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

6. **Without an IDA dump, LIFT the machine code mechanically and let the oracle grade it** (2026-09-22,
   step 5 layer 1). `jp8_lift.py` turns the static reach of an entry (recursive descent, MSVC jump tables read
   from the image, indirect targets from a TB-flushed dynamic reach) into one C statement per instruction over a
   register-file struct, with the oracle's regions mapped at the SAME virtual addresses on the C side
   (MAP_FIXED_NOREPLACE) so pointer-valued cells need no relocation. 71k instructions lifted in seconds, 17 s to
   compile, EXACTLY 0 on the first four patches after three lifter defects (below). Everything the lifter cannot
   express is a `jp8_trap` (219 AVX/CRT-dispatch sites, none reached): reaching one turns the gate red.

7. **A lifted function must START at its entry, not at its lowest address** (paid 2026-09-22): MSVC shares
   tail blocks, so a function's descent reaches blocks at LOWER addresses than its entry; emitting in address
   order ran f_441f90 from 0x4418a0 and the note-off did nothing. One `goto L_entry;` first.

8. **Every NEW Unicorn hook re-pays D5 unless the TB cache is flushed first** (paid three times on 2026-09-22:
   the instruction counter, the trace hook, the dynamic reach). Blocks translated before `hook_add` never call
   the hook; the reach missed the note-off's vtable target 0x37df10 (shared with the assigner notify run at boot)
   and the trace "showed" the oracle skipping a callee. `uc.ctl_flush_tb()` before every hook_add, always.

9. **The judged drive must carry the control-plane events on BOTH sides.** A note-off applied by the oracle
   between two judged phases left the C twin holding the note (gate cells 1.0 vs 0): NOTEON/NOTEOFF are lifted
   and replayed on the C side, which also makes the note path part of the proven reach.

10. **A tooth that is a no-op on the drive's data is not a tooth** (paid 2026-09-22, layer 2). The render
    layer's tooth flips the VCO1 RANGE addss (0x3965cb); on a RANGE-3 patch that cell is 0.0 and + and - agree,
    so the recall-layer gate stayed green WITH the tooth. Each layer now names its own tooth in
    `jp8_lift_seq.TOOTH` (recall: the FINE TUNE setter's + 0.0003 at 0x38633e, reachable only through DISPATCH,
    9,292 differences) and the gate prints the first differing word. Rule: pick the tooth on a path the drive
    exercises with a NON-neutral value, and read the tooth's failing line, never only its exit code.

11. **A running job's build artifacts are part of the frozen tree** (paid 2026-09-22). The 64-patch reach job
    was reading build/jp8_lift/libjp8lift.so while the boot-layer gate rebuilt it (and the C-side script
    changed under it): patches 22-25 "FAILED" with a Traceback that was mine, not the port's. CLAUDE.md's
    FREEZE rule covers every file a gate loads, generated ones included; a reach job gets its own copy of the
    library (or the gate waits). The reach was rerun on a quiet tree (logs/lift_reach64.log).
