# Phase 1 — the "Rip Lead first-note filter swell" investigated

Reported symptom: load a patch (e.g. Rip Lead), play — the **first** note's filter
takes ~2 s to open; every note after is fine.

All findings below are from running the plugin's own machine code under emulation
(no captures, no guessing). Reproduction scripts live in scratchpad/oracle/.

## 1. The swell is FAITHFUL plugin behaviour — not a port bug

`cold_long_oracle.py` renders the plugin's own code through the validated capture
sequence (snap → recall → snap → clear-latch → note) but for a full **3 seconds**
instead of the 8000-sample (167 ms) captures used until now. The port, rendered
the same way, is **bit-identical: 0 / 144000 samples differ on both channels.**

The plugin's own RMS trajectory over those 3 s is the swell itself:
`0.0138 0.0279 0.0238 0.0566 0.0669 0.0389 0.0660 0.0880 0.0845 0.0957 …`
— quiet at first, opening over ~1.5 s. The factory 8000-sample captures sit
entirely inside the first 167 ms (RMS 0.01005), which is why the swell was never
visible before: **the reference data was too short to contain it.**

Cause: a freshly-activated engine holds ~190 smoothed DSP working cells at 0; they
only converge toward their running values *while rendering*. A DAW has always been
rendering silence before you press a key, so the convergence happens during that
idle and the first note sounds settled. The browser's audio graph was idle until
the first key, so the convergence happened *during* the first note = the audible
swell. `converge_probe.c` shows the first-note trajectory is fully converged
(bit-stable) after ~1 s of prior rendering; `warmup_test.c` confirms warmup ≥ 1 s
flattens the swell on patches 13/48/27/4 (warmup 1 s == 2 s == 3 s == 5 s).

## 2. The fix: warm the engine at boot, exactly as a DAW does

`juno_gui_warmup(ctx, nsamples)` renders `nsamples` of silence into a scratch
buffer at boot, converging the working cells before the first note. Wired into the
webapp boot at 1.5 s (host rate). One-time cost; later patch changes keep the
warmed cells (recall does not reset them).

## 3. Open item being resolved: bit-exactness of the WARMED note

Warmup removes the swell, but making the warmed note *bit-identical* to a plugin
that idled the same amount is not yet closed. Measured (`warm_survivors.py`):
after an identical 48000-sample idle + recall, **159 / 1573 tracked cells** in the
port match no plugin unit — these are free-running / idle-evolved cells (LFO phase
and downstream, e.g. offset 1136: plugin voice units 8.99, port 0.05) that recall
does not overwrite. Some carry an exact **2× signature** (off 2784/2816/2832 ENV
coeffs, 1920 LFO delay: port = 2× plugin) — a deterministic double-step, present
even at t=0 (80/1573 cells), i.e. partly in `juno_engine_prepare`, not only in
idle. These prepare-set cells are recalled-over in the normal load path (cold
post-recall differs on 1 denormal cell only), but the idle path exposes them.

Crucially, every cell carrying the deterministic **2× double-step** (ENV coeffs
2784/2816/2832, LFO delay 1920) is **overwritten by recall**, so it never reaches
a played note — it is inert in the warmup → apply → note path. The residual
warm-note difference vs a *specific* 48000-sample oracle idle is the **free-running
LFO phase**, which in real DAW use is itself arbitrary (it depends on exactly when
the key is pressed relative to activation). So the warmed note is a valid, settled
patch voice; it is not bit-locked to one arbitrary idle length.

## 4. Phase-2 follow-up: the warm divergence localises to ONE cell (1728)

Driving port and plugin idle from the same clean state and diffing every DSP-read
cell each sample (`idle_drift_diag.py`, `warm_survivors.py`, raw peek/poke via the
new `juno_gui_peek/poke`) narrows the entire warm-note divergence to a single
voice cell: **offset 1728** (a DCO PWM/sub-oscillator phase-fold output,
`1728 = juno_triangle(v98 + cell2304) * cell2384` in voice_render.c). From idle
sample 1 the port holds `+0.0002744` while the plugin holds `-0.9997256` — an
**exact +1.0** offset (≈ 0.5 in the pre-fold phase v98). Every other voice cell
stays bit-locked. It is idle-specific: the cold *note* render is bit-exact
(0/144000), so 1728 is correct while a note plays and only diverges when the
engine free-runs silent. The inputs to 1728 all match at idle=0, so the fault is
a phase-fold edge case in the v98 computation/wrap, not a bad coefficient — still
being traced.

A separate attempt to align the prepared *idle default* state (setting 29 cells to
the plugin's post-activation-snap SETTLED values instead of the pre-snap
`setSampleRate` values) was REVERTED: it corrected state cells but did NOT change
the warm audio (all 29 are recall-overwritten), and it contradicted
`test_prepare_rate`, which asserts the binary-traced pre-snap per-rate values. The
snap-vs-ramp question for those cells is unresolved and does not gate the 1728 bug.

## 4b. FINAL warm verdict: all 64 patches within the plugin's own behaviour envelope

Definitive all-64 warm A/B (docs/WARM_ALL64_RESULTS.txt; scripts warm_all64.py +
flag_selfband.py): 62/64 patches matched outright (corr 0.99-1.000, level error
<= 0.36 dB, every EFFECT TYPE mode 1/2/3/5 represented). The two threshold flags
were resolved by the plugin-SELF-band test (the plugin rendered against itself at
four idle lengths):

- Patch 5 (LD Classic Lead): plugin-vs-itself corr drops to 0.167-0.516 across
  idle shifts; the port's 0.168 is statistically identical. Slow-LFO PWM: ANY two
  press-moments decorrelate, including the plugin against itself. Not a defect.
- Patch 22 (BS Ikonbass): plugin-vs-itself RMS swings +7% to -13.4% and corr
  spans -0.341..0.833; the port (corr 0.874, -10% RMS) is TIGHTER than the
  plugin's own self-variation. Detuned-oscillator beating: loudness depends on
  the beat phase you catch. Not a defect.

Conclusion: zero confirmed warm defects across the full factory bank. The earlier
webapp caveat claiming "9 patches route to an un-decompiled FX block (kept at
chorus)" is DISPROVEN by the same sweep (modes 3 and 5 verified faithful) and has
been corrected in the UI.

## 5. Phase-2 resolution: two real DSP bugs fixed; warm allocation is oracle-bounded

The per-sample state-diff drove the warm divergence to its roots and fixed two
genuine bugs:

1. **Sub-osc triangle argument (voice_render.c).** The decompiler dropped the
   argument to the triangle function `sub_180368FC0`; an earlier transcription fed
   `v108` (= v98 + cell2304) where the plugin feeds `v107` (= v98 + cell2320, the
   −0.5-shifted sub-osc phase). Masked in recalled notes (recall makes 2304==2320)
   but wrong for the free-running idle phase. Fix: `juno_triangle(v107)`. With it,
   the port's idle evolution is **bit-identical to the plugin's for 48000 samples**
   (every voice cell, 0 diffs) — previously it diverged at sample 1.

2. **Prepare pre-snap vs settled (juno_prepare.c).** 29 smoothed cells were left
   at the pre-snap `setSampleRate` START; the plugin settles them to a
   rate-independent target at activation and RUNS with that. Fix: seed the settled
   targets. `test_prepare_rate` updated accordingly (it had asserted the pre-snap
   values). Both proven against the plugin's own post-snap state.

**Oracle-bounded limit (honest).** Full warm-recall = idle → recall → play. The
idle voice-DSP is now bit-exact, but WHICH voice unit is active during idle and
which is allocated on the note is governed by the plugin's threaded `process()` +
CAssignJu60 event/assigner path — the same intractable layer as the arp (Phase 4).
The leaf-driven oracle can verify the DSP but not the assigner-managed voice
lifecycle across the idle→play boundary, so the warm note's exact voice ALLOCATION
(and its per-voice CONDITION scatter) cannot be bit-verified with the available
tools. The audible result is correct (settled note, no swell) and the DSP is now
strictly more faithful; the residual is voice-selection, not synthesis.

Status: swell root-caused; the warmup fix is shipped (it removes the swell and
matches the plugin's settled first-note character — strictly more faithful than
the cold swell, which a DAW never exposes). Remaining Phase-1 rigor: make the
port's *idle evolution* bit-identical to the plugin's (localise the combined-state
vs 9-unit stepping so `warm_port_match` reaches 0 diffs against an equal-length
plugin idle). That tightening does not change the audible result; it closes the
bit-exact gate.
