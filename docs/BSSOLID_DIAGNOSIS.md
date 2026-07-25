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
