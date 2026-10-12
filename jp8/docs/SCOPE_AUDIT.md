# JUPITER-8 — SCOPE AUDIT (what the gates actually prove)

Written 2026-10-12, in the JX-3P's format (jx3p/docs/SCOPE_AUDIT.md) and under docs/PORT_COMPLETENESS_CHARTER.md:
every dimension along which a gate's scope can be narrower than its claim, with its MEASURED status. A row is CLOSED
only when a named gate run says so. "The JUPITER-8 is bit-exact" means nothing without this table.

The port is the plugin's own machine code, LIFTED (jp8/tools/jp8_lift.py -> jp8/src/jp8_host_lift.c, then
jp8_fast.py and jp8_xlane.py for the product build), run by jp8/src/jp8_host.c on the memory the host oracle had
before the host learned its rate (jp8/docs/HOST_LAYER.md). So a row is about two things: REACH (did a drive make the
plugin run that code, so that it is lifted at all -- code outside the reach is a trap, never a silent difference) and
GRADING (did a gate compare that behavior word for word against the oracle).

| # | Scope dimension | Status | Evidence |
|---|---|---|---|
| 1 | Parameter coverage | **OPEN -- the v7 drive closes it** | Census: 226 controller parameters (96 panel + CC 0..127 + aftertouch + bend; jp8_controller_census.py -> jp8/gen/jp8_controller.json) and every panel parameter's POSITIONS from the plugin's own getParamStringByValue at k / 256 (jp8_param_positions.py -> jp8/gen/jp8_param_positions.json: 37 switches of 2..24 positions, 59 continuous). The v6 drive moves ~10 of the 96 by host automation (two per patch, MASTER TUNE, a swept one, a learned one); the 4 patches' recalls set the rest to those patches' values. The v7 drive (jp8_host_seq.sweep_steps, 1,358 steps) moves ALL 96: every switch position, five values of a continuous one, from a fresh patch load each, a chord sounding, bend and mod wheel moving. |
| 2 | Effects (3 units x 6 types) | **OPEN -- the v7 drive closes it** | EFFECT TYPE, DELAY TYPE, REVERB TYPE: 6 positions each (census). v6: the 4 patches' own settings only. v7: each type of each unit with the levels up, that unit's parameters at every position / three values under it, a chord re-struck per type, a tail. |
| 3 | Arpeggiator | **OPEN -- the v7 drive closes it** | ARPEGGIO SW, MODE (6), RANGE (6), TEMPO SYNC (2). v6: never on. v7: every mode x range, free and synced to a running host clock (ppq advancing per block), the switch off under held keys. Host transport states (stopped, loop, tempo changes) are NOT in it. |
| 4 | Note allocation | **OPEN -- the v7 drive closes it** | v6: a chord of ten keys on eight voices (stealing), release, velocities 0.3..1.0, keys inside blocks. v7 adds ASSIGN MODE (4) x LEGATO x PORTA TYPE with overlapping keys and portamento, and KEY HOLD across a release. Not covered: MIDI channels other than 0, a note-on of velocity 0. |
| 5 | Patches graded through the host path | **PARTIAL** | REACH: all 64 factory patches (jp8/gen/jp8_hostreach_48000.json, drive v6 over 0-63: 111,848 instructions). GRADED: 4 patches per host gate run (2, 63, 0, 12); the ENGINE path (jp8_full_gate.sh, drive2) 64 / 64 at 44100 (job jp8full_64). The host path over 64 patches is not graded. |
| 6 | Render duration / effect tails | **PARTIAL** | Host path: ~8 blocks of 512 per patch, ~90 blocks after; the engine path 17,096-22,096 samples per patch. A delay or reverb tail of seconds (a delay line's wrap, a long feedback) is not graded through process(). |
| 7 | Block size | **PARTIAL** | Through process(): 512, 480, 32 (max block 512); the engine path random chunks 1..300 (full gate RUN B). A host max block other than 512 and blocks above it are not graded. |
| 8 | Sample rates | **CLOSED for the rates named** | First rates 48000, 44100, 96000 (template before setupProcessing; job jp8_host_gate7 on v5, gate8 on v6); changes on a running instance to 44100 / 96000 / 88200 / 22050 (no converter: silence) and back. Other rates (32000, 192000) are not graded. |
| 9 | Cold start | **CLOSED** | jp8h_init makes the setup calls on the oracle's pre-setup memory; CONTROL 1 (image + heap + host objects) and every word from the first block. |
| 10 | Warm recall (a patch change on a running engine) | **CLOSED (v6); v7 adds 68 loads** | the plugin's own patch load, lifted, between running blocks; the engine path: a patch change under a held note (patch 0). |
| 11 | Engine-rate setting, voice count | **PARTIAL** | Through setState: the engine-rate setting 1..6 (6: no converter), the voice count 4 and 1. Other voice counts, and both by host automation, are not graded (the JX's lesson: an illegal voice count throws in the plugin, playbook 231). |
| 12 | MIDI controllers | **CLOSED** | mod wheel, expression, sustain across a release, aftertouch, bend down / up / back, all notes off under held keys; IMidiMapping CC n -> 0x0FFFC100 + n (v3). |
| 13 | DAW state | **CLOSED** | getState byte for byte; setState of 16 inputs (crafted CC maps, values out of range, short / empty streams, the engine-rate setting, the voice count); setComponentState after each (v6). |
| 14 | UI timer, MIDI learn | **CLOSED** | the drain (rva 0x33A290), Learn / Forget, a learn of an id with no record (v4). |
| 15 | What a DAW asks the controller at load | **CLOSED with gate8** | 226 parameter infos, the MIDI mapping of every controller number on channels 0 and 15 (and 16, bus 1, 255), the units, the program lists, the selected unit, the controller's own state (v6, job jp8_host_gate8). |
| 16 | The engine's eight workers | **CLOSED** | sequential (ISO C99) and on POSIX threads (JP8H_THREADS), three threaded runs per rate (gate7, gate8). |
| 17 | The heap over a long session | **CLOSED** | both sides reuse a freed block by its rounded size; the host buffers are one scratch area (playbook 238; 160 patch loads: the heap grows 31 MB, then stops). |
| 18 | NaN / denormal parity | **CLOSED on x86-64 by construction; OPEN elsewhere** | the lift executes the plugin's own instructions at the plugin's MXCSR (FTZ, DAZ), so every NaN, sign and payload is the hardware's, as in the plugin -- the JUNO / JX row 24 does not arise here. On a host without x86 SSE (JP8_SOFTFP) the runtime's software rules are not graded on the JUPITER-8. |
| 19 | ISO C99 | **CLOSED** | every gate build is gcc -std=c99 -pedantic-errors; the threads are a separate platform layer (_POSIX_C_SOURCE). |
| 20 | Mutation reach (charter section 4) | **OPEN** | 9 teeth, each seen to fail (the lift's addss, the transport, the template, the rate chain, the stream, the drain, the heap reuse, the info copy, the lanes) -- planted defects, not a mutation campaign over the lifted code. |
| 21 | The editor | **OPEN** | zoom, meters, CC menu, patch window: the framework's code (the JUNO-60's; ported there as A37-A40) -- not lifted or graded here. The drawn panel: eight panel types are defined in no script of truth/ (HOST_LAYER.md section 3) and the 43 bitmaps are not in truth/ -- the user's files are owed. |
| 22 | A playable product | **OPEN** | no app or web page runs the lifted JUPITER-8 yet. Speed (this 4-core VM, other jobs running): ~640 ms per second of audio sequential (lanes + non-volatile memory, playbook 239); the plugin itself ~410. |
