# "BS Solid does not have enough noise" — diagnosis

Research only (2026-07-25). Nothing in this document was tuned, fitted, or changed;
every number below is measured, and every claim is labelled PROVEN (executed) /
READ (static) / INFERRED. Written as a handover.

User report: *"there are still issues… a clue: the patch BS Solid does not have
enough noise."* BS Solid is **Chillwave patch 3** (the user's own bank, not the
factory bank). Its `DCO NOISE LEVEL` is 73/255.

---

## 1. Headline

**The engine is not the defect.** BS Solid in the port is *bit-identical*, sample
for sample, to BS Solid rendered by the plugin's own recall + render under Unicorn
— including when the noise level is forced to its extremes. The noise the user is
missing is missing **in the plugin too**, at the parameters our recall installs.

What actually gates noise audibility on this patch is **how far the filter opens**,
and that is where the port and the user's DAW instance measurably differ (#124).
"Not enough noise" is the *first audible symptom* of a brightness deficit, because
on this patch the noise sits ~31 dB under the signal and is the first thing a
closing filter removes.

---

## 2. What was proven this session

### 2.1 BS Solid is bit-exact — including over a realistic note length  (PROVEN)

`scratchpad/bssolid_ab.py`, two-process (Unicorn oracle vs ctypes libjuno), oracle
started from `recall_render_ab.prepare_recall` (the plugin's own recall enumerator):

| condition | result |
|---|---|
| 48 kHz, vel 105, 16000 frames, mono + poly | BIT-EXACT |
| 44.1 kHz, vel 100, 16000 frames (webapp conditions) | BIT-EXACT |
| **44.1 kHz, vel 100, 88200 frames (2 s)** | **BIT-EXACT**, peak 0.23259, rms 0.053306 both sides |

The 2-second run matters: *every* render gate in this project is 16000 samples
(≈1/3 s). A slow divergence would have been invisible to all of them. There is none.

### 2.2 The noise path is correct  (PROVEN)

The bank record's noise byte is `record[74] | record[75]<<4` (located empirically).
Two modified banks were built with `DCO NOISE LEVEL` forced to 0 and to 255, and
**both engines re-run their own full recall on the modified input**:

| forced noise | port vs plugin | plugin rms | port rms |
|---|---|---|---|
| 0   | BIT-EXACT | 0.107660 | 0.107660 |
| 73 (patch) | BIT-EXACT | — | — |
| 255 | BIT-EXACT | 0.098896 | 0.098896 |

Note the plugin's *own* numbers: driving noise from 0 to 255 barely changes the
level (and slightly *lowers* rms, because broadband noise into a nearly-shut
resonant lowpass displaces rather than adds). **The weak noise is the plugin's
behaviour, faithfully reproduced.**

### 2.3 Why the noise is inaudible: the filter, not the noise  (PROVEN)

BS Solid: `VCF CUTOFF 15`, `VCF ENV MOD 215`, `VCF VELOCITY SENS 157`,
`VCA VELOCITY SENS 0`. The filter is nearly shut; all brightness comes from
ENV1 and velocity. Measured on the port (== the plugin, per §2.1),
note 60, vel 100, 0.5 s (`scratchpad/bright_sens.py`):

| VCF CUTOFF | centroid | % energy >3 kHz | noise level below signal |
|---|---|---|---|
| **15 (patch)** | **136 Hz** | **0.00 %** | **−31.5 dB** |
| 40  | 155 Hz | 0.00 % | −30.2 dB |
| 80  | 248 Hz | 0.19 % | −25.9 dB |
| 120 | 458 Hz | 3.07 % | −22.5 dB |
| 255 | 510 Hz | 3.27 % | −21.6 dB |

Noise audibility is a **monotone function of filter opening**, worth ~10 dB across
the range. A modest deficit in how far the filter opens is heard as "not enough
noise" long before it is heard as "too dark".

---

## 3. Hypotheses eliminated (each with the evidence that killed it)

| # | Hypothesis | Verdict | Evidence |
|---|---|---|---|
| 1 | Noise level law wrong past factory range | **DEAD** | cell 6528 exhaustively gated all 256 bytes; §2.2 A/B at 0 / 73 / 255 all bit-exact |
| 2 | `VCF CUTOFF FREQ H` (leaf 1029, PATCH2) is the real cutoff and the port ignores it | **DEAD** | It is the **low byte of float32(coarse/255)** — a redundant mirror (verified across both banks, mismatches are ±1 rounding). Forcing it changes nothing: renders bit-identical at every cutoff (`scratchpad/cutoff_h.py`) |
| 3 | A SYSTEM global (Boost Mode / Output Gain / MASTER TUNE) is non-neutral by default | **DEAD** | READ from the plugin's own descriptor DB (rva 0x98c040): Boost Mode **0**, Output Gain **0**, MASTER TUNE **0**, Kbd Vel SW **0**. The port is right to ignore them (`scratchpad/sysparams.py`) |
| 4 | The live MODULATION layer (#112, idx 312–317) has a non-zero host default, so a DAW opens the filter further | **DEAD** | All six descriptor defaults are **0** = identity (`scratchpad/moddefaults.py`). Worth noting this was the strongest candidate: its law is `base + off·(255−base)/100`, so at base 15 an offset of +20 would have moved cutoff to 63 — exactly the needed effect. It is simply not armed by default |
| 5 | Webapp velocity path differs from the plugin | **DEAD** | `velSw` checkbox defaults unchecked → engine receives velocity 100, matching the wrapper's hardcoded `if (!sw) vel = 100`. The bit-exact test in §2.1 used vel 100 |
| 6 | Webapp render path colours the signal | **DEAD** | 1024-frame `ScriptProcessor`, no gain node, no resampling (engine built at device rate), only a ±1 clamp — and BS Solid peaks at 0.23. WASM == native proven 8/8 |
| 7 | A second hidden noise leaf is unapplied | **DEAD** | Value tree has exactly two: 773 `DCO NOISE LEVEL` and 775 `(MIX NOISE TYPE)`; both are `APPLIED / in_recall` in COVERAGE.tsv |

### Retraction

An earlier note in this session flagged **FX Noise Seq (Chillwave 21)** as a real
port bug ("2× louder, 15973/16000 samples differ"). **That was a harness artifact:
patch 21 has `ARPEGGIO SW` on, and the render-A/B oracle has no transport clock, so
the port arpeggiated and the oracle did not.** It is not evidence of an engine
defect. (Chillwave arp patches: 9, 21, 58, 59, 60, 61, 62, 63.)

---

## 4. Where the defect actually is

Everything reachable by our gates is bit-exact, yet the port measures **12–23 %
lower spectral centroid** than the user's DAW bounces of the *factory* presets
(#124, `scratchpad/bounce_relocate.py`, covenant role 1 — locating only). The port
is darker on 6 of 8. That deficit, applied to a patch whose filter is nearly shut
and whose noise sits 31 dB down, presents as **"not enough noise"**.

The one path a real DAW uses that this project has **never executed** is the
wrapper's preset load:

- `IComponent::setState` = **rva 0x34aaa0** (READ, decompiled this session). It
  reads a length-prefixed blob from the `IBStream` and hands it to a consumer method
  at `class+328`, vtable slot 6. Real code — the roadmap's old claim that it is a
  bare-`ret` no-op was already retracted in `docs/P112_FINDINGS.md`.
- Our recall instead drives the **engine's** recall enumerator (rva 0x3B48A0)
  directly. #112 proved the host's parameter *dispatch* is the same function
  (`0x3B9A30`, differing only by a role flag) — but it never proved that the
  *set of parameters a DAW's setState pushes* equals the set our enumerator pushes.
  **That is the open surface, and it is exactly the shape of a brightness deficit
  that survives every green gate.**
- It is blocked by #133: `IComponent::initialize` reaches the engine factory and
  trips a CRT invalid-parameter inside a magic-static string parse (a TEB/TLS
  emulation artefact); neutralising it lets execution continue but it faults at
  rva 0x284c04.

**Recommended next step (H1 of the work order, unchanged but now better scoped):**
get `IComponent::initialize` past the magic-static fault, drive `setState` with a
real preset blob, and full-state-diff the engine against our recall-driven engine
for the same patch. Every differing cell is a bug by definition. §3 has eliminated
the cheap alternatives, so this is now the *only* remaining candidate of the right
shape.

---

## 5. Structural blind spot worth fixing regardless

The factory bank barely exercises the velocity→VCF path that dominates BS Solid:

- Factory `VCF VELOCITY SENS`: median **0**; only patch 47 is ≥157.
- BS Solid: **157**, with `VCA VELOCITY SENS 0` — velocity controls the filter alone.
- Every gate passes velocity *explicitly* into `note_on`, so the wrapper's
  fixed-velocity policy never enters any comparison at all.

So the port's most brightness-critical control path is gated almost entirely by
patches that don't use it. Adding a velocity-swept render A/B on a high-vel-sens
patch would close this.

---

## Reproduction

```
# bit-exactness, 2 s, webapp conditions (two processes, in this order)
JUNO_RENDER_SR=44100 JUNO_VEL=100 JUNO_N=88200 JUNO_MONO_ONLY=1 \
  JUNO_BS_PKL=scratchpad/bslong.pkl python3 scratchpad/bssolid_ab.py --ref  --patches 3
JUNO_RENDER_SR=44100 JUNO_VEL=100 JUNO_N=88200 JUNO_MONO_ONLY=1 \
  JUNO_BS_PKL=scratchpad/bslong.pkl python3 scratchpad/bssolid_ab.py --port --patches 3

python3 scratchpad/bright_sens.py     # filter opening vs noise audibility
python3 scratchpad/cutoff_h.py        # H mirror is inert
python3 scratchpad/sysparams.py 40    # SYSTEM defaults, from the binary
python3 scratchpad/moddefaults.py     # modulation defaults, from the binary
```

All probes are diagnostic; none is wired into `make verify`, and none derives a
constant from anything but the plugin binary.

---

## RESOLVED (same day, follow-up session)

The concrete, user-audible cause was found one layer above everything examined
here: **the web app shipped with the SYSTEM "Keyboard Velocity SW" OFF**, which
forces every note to fixed velocity 100 at the wrapper layer (the plugin's own
factory-default rule). On BS Solid, played velocity is the *only* control that
opens the filter beyond cutoff 15 (`VCF VELOCITY SENS 157`, `VCA VELOCITY SENS
0`), so with the switch off the app pins the centroid at 136 Hz **no matter how
hard you play** (vel 1 and vel 127 render identically), while a
velocity-responsive setup reaches 163 Hz / +1.6 dB noise at vel 127. §3's
measurement ("noise audibility is a monotone function of filter opening") is the
mechanism; the fixed-velocity gate is why the user could never reach the open
part of that curve.

Fix (commit 18d47d3): the web app now defaults Kbd Vel **ON** (the toggle still
restores the plugin's factory fixed-100 rule in one click). Engine, WASM, and
the wrapper policy in `juno_bridge.c` are untouched — this is a UI default, not
a coefficient.

Also settled here:
- **Bank-wide sweep** (56 non-arp Chillwave patches, oracle vs port, 44.1 kHz):
  **52/56 BIT-EXACT**. The 4 divergers — 24 KY Flanged, 38 LD Juno Dreams,
  56 PL Floaty Sq (all EFFECT TYPE 3/5 + DELAY TYPE 4/5 beyond-factory combos =
  tracked #122) and 49 PD Motion (12 samples, the known ~1-ULP class).
- The deployed bundle was **current** (embedded WASM sha == freshly built
  `gui/web/juno.wasm`), ruling out a stale deploy.
- §4's setState lead stays open as #124/#133 (the ~12–23 % factory-bounce
  centroid delta is still unexplained), with one new datum: the two bounce
  presets that *match* the DAW (p0 +2 %, p5 +6 %) are the only two with high
  `VCF VELOCITY SENS` (105/92); every non-arp vel-sens-0 preset is dark
  (−12…−23 %). Whatever #124 is, it is masked or compensated on
  velocity-sensitive patches — a usable constraint for the state diff.
- #133 progress: the `initialize` abort is now precisely located — MSVC
  aligned-free sanity checks inside the `GT::CIniProfile` load
  (`BufferObject/Value` key, magic static at 0x3E4930, abort from
  `sub_7FF91DEE45B0`'s error stubs at 0x284bec) — i.e. harness file-I/O
  plumbing, not plugin logic.

---

## ROUND 2 (2026-07-25, new capture `lastcatpureEVER.wav`) — the instance-state finding

User supplied a second diagnostic capture (C3, vel 100, 44.1 kHz, 0.5 s + 2 s + tail)
plus a screenshot of their DAW instance, reporting it STILL sounds wrong. Full
structural comparison against the port at identical driving (`scratchpad/lastcap_ab.py`
and successors). Covenant roles only: the capture located the divergence; nothing
from it entered the port or the ledger.

### What matches (MEASURED)
- Pitch: f0 130.0 Hz both (C3 = MIDI 60; the port is in tune).
- Chorus LFO rate: the sustain has an amplitude modulation at **0.65–0.67 Hz in
  both** (harmonics 1.3/1.95 Hz both), same comb geometry (autocorr lag trace
  identical), L/R envelope correlation +0.97 both (the modulation is pre-stereo).
- Release: both decay ~2.5–2.6 s; tails match in shape.
- Pitch stability: 0.6 Hz FM is ~1–2 cents on both sides — the wobble is NOT pitch.

### What differs (MEASURED)
1. **Global level**: capture peak 0.728 vs port 0.233 (~2.9× peak, ~1.5–1.7×
   envelope-mean, i.e. +4.5…+9 dB flat gain). A scalar; no timbre content.
2. **Chorus modulation depth**: relative AM (AM/mean-env) capture **0.112** vs port
   at the bank's EFFECT DEPTH 92 **0.043**. The port reproduces the capture's
   relative depth at **EFFECT DEPTH ≈ 200** (0.107 @200, 0.132 @220) — its own law,
   just a different input byte.
3. Harmonics 6–8 (780–1040 Hz) +5–8 dB in the capture — chorus-ripple-consistent.

### The screenshot corroborates it (READ)
In the DAW screenshot the EFFECT **DEPTH knob points right-of-vertical (>128)**
while TONE points left-of-vertical (≈71 ✓). The uploaded Chillwave bank decodes
BS Solid EFFECT TONE=71, **DEPTH=92** — at 92 the two knobs would sit at nearly
the same angle. They visibly do not.

### Conclusion
**The user's DAW instance is not playing the uploaded bank's BS Solid.** An
Ableton project restores the plugin's *saved project state* (including any
edits made after the patch was loaded), not the bank file; the web app plays
the bank file. At minimum the instance's EFFECT DEPTH is ≈180–210 vs the bank's
92, plus a flat +4.5–9 dB somewhere in the chain (Roland SYSTEM Output Gain /
Boost Mode / interface gain — indistinguishable from here, timbre-neutral).
The engine remains bit-exact against the plugin's own recall+render for this
patch under every driving tested.

**10-second verification for the user:** in Ableton, re-select BS Solid from the
plugin's own PATCH browser (a fresh recall from the bank). The DEPTH knob should
snap left (~10–11 o'clock) and the instance should then sound like the web app.
Conversely, setting the web app's EFFECT DEPTH slider to ≈200 should reproduce
the DAW instance's swirl.

### Genuinely new engine finding from this dig (PROVEN, kept)
The EFFECT-TYPE **activation** path (0x3B93E0 — the setter the flanger work
validated) does things recall never does: with role flag 0 it writes a SECOND
program selector at state **11022056** (owned by DELAY TYPE leaf 875; the
master chases it at params+136, i.e. the slot-1 program) and fully configures
the **6396xxx chorus block** (pre-delay, low/high-cut biquads, five enable
gates — 20 cells, real coefficients). Our recall — and therefore every render
gate's oracle — leaves all of it at zero. For BS Solid this is inaudible
(DELAY LEVEL 0 = the slot-1 block gets no input; verified by rendering with the
block armed: bit-identical env/AM), but for patches that route audio through
slot 1 it is exactly the #122/#124 class. Also established: the role flag gates
the activation's routing write (flag 1 skips it), and dispatching the full
recall with flag=0 vs flag=1 is state-identical for BS Solid (task #132's
value-level comparison, executed for this patch's values: no diff).

---

## ROUND 3 (2026-07-25, later) — RETRACTION + the real mechanism localized

The user then supplied a screenshot of a **freshly-recalled factory instance** of
BS Solid. That falsifies Round 2's conclusion ("the user's project state was
edited") — **retracted**. The knob position is what a REAL recall produces:
EFFECT DEPTH displaying ~60–65 % while the bank record byte is 92 (36 %).

Putting the two user artifacts together with the port's own proven law:

- The capture's relative chorus modulation (AM/env 0.112) lands on the port's own
  EFFECT DEPTH law at ≈ **190–210**, not at the record's 92 (0.043).
- The fresh-recall knob shows ~**60–65 %** ≈ 160–185. Same number, two
  independent sources.
- Therefore **the real plugin's preset path drives the slot-2 chorus at an
  effective depth ≈ 2× the raw record byte** (or at a JUNO-60-model fixed deep
  setting) — while the ENGINE-side recall enumerator (rva 0x3B48A0, the ground
  truth for our entire recall reference) dispatches the raw byte 92. Our port
  bit-exactly matches the engine enumerator; the REAL preset path goes through
  the CONTROLLER, which decodes the record itself and pushes its own values.
- READ: the host param entry 0x3C7AE0's transform table is tiny (769→v−11,
  20/665→v−100, 22→v−12, 871→bool) — identity for 794 EFFECT DEPTH. So the
  scaling lives in the controller's record→param decode, not the engine entry.
- Hardware context that makes this plausible: the JUNO-60 has NO chorus depth
  control (OFF/I/II buttons, fixed deep BBD chorus). The JUNO-60 PLUG-OUT model
  overriding/re-scaling the JU-06A DEPTH byte is exactly the kind of
  model-specific behavior a controller implements.
- **Blast radius: every EFFECT TYPE 2 patch** — including all 8 factory bounce
  presets — which makes this the strongest #124 candidate found to date
  (bidirectional per-patch brightness/width deltas: each patch's record DEPTH
  sits on a different side of the model's effective value).

### New execution facts (PROVEN, this round)
- `CVstEditController` (createInstance 0x3473D0) constructs with 0 faults AND
  **`initialize` returns kResultOk** under emulation — the #133 magic-static
  fault is PROCESSOR-only. Controller vtable mapped (setComponentState slot 5 =
  rva 0x347f20, setParamNormalized 15 = 0x3486f0, normalizedParamToPlain 12 =
  0x3d21e0).
- `getParameterCount` returns 0 after initialize — the param table populates
  from component state / model config. **Next step:** drive slot-5
  `setComponentState` with a component-state stream (its own code), then
  enumerate `getParameterInfo`/`getParamNormalized` and read the controller's
  own EFFECT DEPTH for a recalled patch; alternatively trace the controller's
  bank-record decode directly. Deriving THAT law from the binary — never from
  the capture — is the covenant-clean fix path.

### Status of the user-facing claim
The user is right: the port audibly differs from a real factory instance on
BS Solid. The engine is a faithful port of the engine; the CONTROLLER's
preset-path value law for the chorus (and possibly other model-adapted params)
is the missing layer. No number measured from the capture may be wired into the
port; the controller derivation above is the way the real value enters the
ledger.

---

## ROUND 4 (2026-07-25, final) — measured correctly at last

**Two of my own measurement errors invalidated Rounds 2 and 3. Both retracted.**

1. **Round 2/3 "chorus modulation is 2.6x shallower in the port" — WRONG.** Artifact of a
   coarse envelope + no decay detrend. Measured properly (Hilbert envelope, 2nd-order
   log-domain detrend), the modulation spectra are near-identical: capture 1.43 Hz
   2.22 dB / 0.72 Hz 1.78 dB, port 1.43 Hz 2.79 dB / 0.72 Hz 2.15 dB. Same rates, same
   harmonic structure, port marginally *deeper*. **The EFFECT DEPTH / controller-scaling
   hypothesis (task #135) has no support and is withdrawn.**
2. **"The port is brighter than the plugin" — WRONG, and it was a window-alignment bug.**
   The port render used for that table carried 0.5 s of pre-note silence, so the port's
   *attack* was compared against the capture's *sustain*.

### The correct measurement (both windows 0.5-1.9 s AFTER note-on)
Median of per-window RMS-normalized spectra (immune to chorus phase), dither floor
checked per harmonic:

| harmonic | Hz | capture | port | delta |
|---|---|---|---|---|
| 1-5 | 130-650 | — | — | **-0.0 .. +0.3 dB (match)** |
| 6 | 780 | -11.0 | -18.4 | **-7.5** |
| 7 | 910 | +0.9 | -6.4 | **-7.3** |
| 8 | 1040 | -8.5 | -26.8 | **-18.3** |
| 10 | 1300 | -13.8 | -34.0 | **-20.2** |
| 13 | 1690 | -12.7 | -33.3 | **-20.6** |

**Harmonics 1-5 match to 0.3 dB. Above ~700 Hz the port is 7-21 dB too dark.** The user's
original report ("not enough noise") was accurate: this band is what reads as air/noise.

### It is NOT the noise source
Forcing DCO NOISE LEVEL to 255 lifts the 975 Hz inter-harmonic floor only to -26.6 dB;
the capture is at **-17.5 dB**. The port cannot reach the capture's broadband level at
any noise setting. The deficit is filter-side, and it is both harmonic and broadband.

### It IS the filter's sustained opening
Sweeping the port's VCF CUTOFF with the corrected metric brackets the capture:

| port variant | h7 910 Hz | h10 1300 Hz | h13 1690 Hz |
|---|---|---|---|
| capture (target) | **+0.9** | **-13.8** | **-12.7** |
| port as recalled (cutoff 15) | -6.4 | -34.0 | -33.3 |
| port cutoff 64 | +25.1 | +0.5 | -1.9 |

The capture sits between the port at cutoff 15 and cutoff 64 — the real instance's
**sustained** filter opening is equivalent to roughly cutoff byte 30-40. ENV1 SUSTAIN is
equally sensitive (23->128 overshoots hugely), so the same deficit is expressible as the
VCF envelope decaying too far/too fast. Attack and low harmonics agree, so the error is
specifically in **where the VCF envelope settles during sustain**, not in the filter's
low-frequency response, the oscillator mix, the chorus, or the noise.

### Why every gate misses it, precisely
`recall_exhaustive` proves the per-byte cutoff CELL; the render A/B proves the port's
voice render against the plugin's own voice render **driven from those same cells**. Both
sides therefore share any error in the *sustained CV sum* (base + ENV1xENV MOD +
velocity x VEL SENS). BS Solid is nearly unique in stressing it: **VCF CUTOFF 15 (lowest
byte in either bank), VCF ENV MOD 215, VCF VELOCITY SENS 157 (factory-bank median: 0)**.

### Systematic check — the port is otherwise correct  (IMPORTANT, PROVEN)
Same corrected metric against the 7 original factory bounces:

| preset | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| port-minus-bounce (dB) | +0.9 | -0.0 | -2.2 | +0.1 | -1.9 | +0.8 | +0.2 | **-17.5** |

**Presets 0-6 match within ±2.2 dB.** This retires the old #124 claim that the port is
systematically 12-23 % darker — that came from a spectral-centroid metric dominated by
near-dither noise-floor bands. Preset 7 (Bell Tower, the lone EFFECT TYPE 5 patch) is
badly off at -17.5 dB and belongs to the known #122 family.

### Where this leaves the fix
The defect is real, quantified, reproducible, and localized to the **sustained VCF
envelope/CV path on high-ENV-MOD + high-VELOCITY-SENS patches**. It is NOT reachable by
any existing gate because the oracle shares the input. Closing it requires a reference
for the sustained cutoff CV that does *not* come from our own recall dispatch — i.e. the
real host/controller preset path (#133/#135 machinery), or an execution-level trace of
the plugin's own note-on -> VCF CV computation compared against the port's, at this
patch's parameter combination. No value from the capture may enter the port.
