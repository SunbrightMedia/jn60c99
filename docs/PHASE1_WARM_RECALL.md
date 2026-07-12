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

Status: swell root-caused; the warmup fix is shipped (it removes the swell and
matches the plugin's settled first-note character — strictly more faithful than
the cold swell, which a DAW never exposes). Remaining Phase-1 rigor: make the
port's *idle evolution* bit-identical to the plugin's (localise the combined-state
vs 9-unit stepping so `warm_port_match` reaches 0 diffs against an equal-length
plugin idle). That tightening does not change the audible result; it closes the
bit-exact gate.
