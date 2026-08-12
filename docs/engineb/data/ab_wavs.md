# A4: the trunk-vs-fork listening set, and the level table behind it
(2026-08-12)

`tools/engineb/ab_wavs.py`. Renders every gated scenario twice -- engine B at
TRUNK flags (bit-exact to the plugin, 64/64) and at the SHIPPING FORK's flags
-- and writes 24-bit WAVs scaled by ONE gain taken from the trunk's peak, so a
level difference stays audible instead of being normalised away.

**It is not a gate.** It returns no verdict and nothing may be tuned from what
anyone hears. The gates decide whether the fork is CORRECT; the user decides
whether it is ACCEPTABLE. That is the whole of END_GOAL item 1's remaining
work.

## The flag set matters, and the existing script had the wrong one

`lastmile_run.sh`'s BASE omits `EB_NOLIBM`, `EB_VCF_MAPFAST`, `EB_FPDIV` and
all five control-rate flags. A comparison built on it is of a fork nobody
ships. This tool takes the set verbatim from `esp32s3/main/CMakeLists.txt` plus
the M1 build's `S3_EXTRA_DEFS`.

## Whole-stream RMS, trunk vs shipping fork, 36 scenarios

    worst   +0.255 dB   delay keys
            +0.240 dB   DELAY type 4 (synthetic)
            +0.202 dB   EFFECT type 4 (synthetic)
            +0.174 dB   DCO noise / idle noise 48
    best    +0.001 dB   realloc chorus, DCO neg warm chorus

**Every scenario is within 0.26 dB, and the fork is louder in 32 of 36.** A
consistent small positive bias rather than scatter -- worth noting, because a
bias has a cause and scatter does not. Not chased here; recorded.

The third-octave band bound the sonic gate enforces is 1.0 dB, so these
whole-stream figures sit at about a quarter of it.

## ⚠ WHAT THESE FILES CANNOT SHOW

**The LFO fix is invisible in them.** They are rendered through the standalone
shim, which holds every voice awake (`juno_driver.c:337`), so
`EB_LFO_FREERUN`'s branch never executes -- the same blind spot that hid the
dead LFO for a night (playbook defect #28). The LFO fix is proven separately by
`tools/engineb/device_sonic.c` under the device's own wake masks.

So: these files answer "does the fork's ARITHMETIC sound like the plugin".
They do not answer "does the FIRMWARE sound like the plugin". That needs the
board, and the board has no note path yet.
