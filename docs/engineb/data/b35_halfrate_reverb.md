# b35 — the REAL half-rate reverb, built and confirmed (2026-08-28)

b34 PRICED the half-rate FX and proved the lever closes the headroom gap. b35
BUILDS the real half-rate reverb (b33/b34 were hold-probes that sound wrong on
purpose). Flag `EB_REVERB_HALF`, default OFF.

## What it does
Runs the reverb tank at half the gate rate — clocked once per two master
samples:
- input pair decimated 2:1 (a 2-tap average, first-order half-band);
- every ring read depth HALVED (`eb_rev_derive`) so a delay of N samples at the
  full rate becomes N/2 at half rate — the SAME real time;
- the rate-dependent coefficients rescaled (`eb_reverb_halfrate_cfg`): the loop-
  damper one-pole corner `g' = 1-(1-g)^2`, the TYPE-5 modulation `lfo_inc*2`,
  `lfo_depth/2`. Structural allpass gain, per-pass loop decay and the input
  filter are LEFT AS-IS (stated trades);
- output linearly interpolated 1:2.

Every rescale is derived from the filter math, NOT fitted from a capture.

THE DRY MAIN SIGNAL STAYS FULL RATE. The reverb is an INLINE stage — its output
is the wet tank PLUS `c->dry*inB` (crossed), and c->dry is MEASURED 1.0 on every
factory patch (gate 1.0 too), so that dry pair is the whole main signal. The
wrapper strips the dry from the tank output and re-adds it at full rate, so only
the wet TAIL is half-rated; the dry path is bit-exact. When the tank is muted the
module returns the unity passthrough (= c->dry*inB while dry==1.0), so the
stripped wet is exactly 0 — a patch with no reverb is untouched.

## Proof (mantra 2 before 3)
| check | result |
|---|---|
| trunk / flag-OFF byte-exact | `null_b --module reverb` residual EXACTLY 0, all 36 scenarios |
| half path reached, non-vacuous | builds with `EB_REVERB_HALF=1`; nonzero A/B deltas every reverb scenario |
| real tail TIME preserved | decay slope ref vs half within 0.1 dB/s (chorus pad -20.00 vs -19.92; long tail -7.12 vs -7.06) |
| level preserved | RMS delta < 0.1 dB on every scenario |

The decay-slope check is the one that separates this from the probe: a wrong
depth-halving would run the tail ~2x slow. It does not.

## The trade the user judges (F2)
Diffuse and small: reverb energy above ~11 kHz is gone from the tail (the
decimator band-limits the send), and the mute-gate crossfade fades at half
speed. Level, decay time and stereo image are unchanged. A/B WAVs rendered by
`tools/engineb/halfrate_ab.py --rev` (ref = full-rate fork, half = candidate).

## Next
Delay half-rate (`EB_DELAY_HALF`), same pattern; then A/B for the delay-heavy
patches. The two levers together are the b34 headroom that covers idle AND the
four delay-t5 worst patches.
