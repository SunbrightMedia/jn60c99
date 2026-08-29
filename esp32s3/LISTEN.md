# The S3 LISTEN firmware — how to hear engine B on your board

    cd esp32s3
    idf.py -DS3_LISTEN=1 -DS3_VOICES=2 build flash monitor

THE CANONICAL SHIPPING RECONFIGURE (after ANY rm -rf build -- the cache trap
has now cost three builds; every -D below is load-bearing):

    idf.py -DS3_LISTEN=1 -DS3_RECALL=1 -DS3_VOICES=3 \
      "-DS3_EXTRA_DEFS=-DS3L_SWEEP=0;-DEB_DCO_WT=1;-DS3_CORES=2;-DS3L_SPLIT=7;-DS3L_VOICE_LO=6;-DS3L_FX_PIPE=1;-DEB_VCF_DEADCOEF=1;-DEB_VCF_RES_LUT=256;-DEB_ATREST_BLOCK=1;-DEB_ATREST_O1=1;-DEB_ZEROCOEF=1;-DEB_EXP_MEMO=1;-DEB_HALF_OS_VCF=1;-DEB_NOLIBM=1;-DEB_VCF_MAPFAST=1;-DEB_FPDIV=1;-DEB_CR_PITCH=1;-DEB_CR_MODCV=1;-DEB_CR_VCFCV=1;-DEB_CR_ENV=1;-DEB_CR_N=4;-DEB_CR_NP=4;-DEB_CR_NC=2;-DEB_CR_NE=2;-DEB_ENV_CR=2;-DEB_LFO_TAIL_CR=1;-DEB_DCO_WT_LIVE_CR=1;-DS3L_MIDI=1;-DS3L_STRESS=1;-DEB_MSPROF=1" build

S3_VOICES=N needs the chord-N device-recall answer key:
    python3 tools/engineb/devboot/make_boot.py --chord N
(the DEVCHORD compile-time net refuses the build otherwise.)
Every report line carries [LISTENvN] so a log can never again be attributed
to a build that was not running.

Change three lines in `main/juno_s3_listen.c` first if your DAC is not on
GPIO 5/6/7 (`S3L_BCLK`, `S3L_LRCK`, `S3L_DOUT`). It speaks standard I2S
Philips, 16-bit stereo, 44,100 Hz — a PCM5102, MAX98357A or any I2S codec.

It plays a CHORD of `S3_VOICES` notes from factory patch 0, held 1.5 s and
released 0.7 s, looping, and prints once a second:

    t=12s  underruns=0  render 8.14 us/sample (~1954 cycles at 240 MHz)
           budget 22.68 us  FITS

## What the numbers mean

`underruns` is the only one that decides anything. Zero means the engine kept
the codec fed for that second. Anything else means holes in the audio, and
you will hear them.

`render us/sample` is MEASURED on the board, in the real loop, and it is the
first cycles-per-sample figure in this project that is neither modelled nor
counted on a synthetic workload.

## Finding this board's honest polyphony

Raise `-DS3_VOICES` by one, reflash, listen and read the counter. The last
value that holds `underruns=0` for a minute is the answer. That is a
MEASUREMENT of your board, not a division of a budget — the estimate says
about 2 voices at 44.1 kHz with the half-oversampled DCO, and the estimate
has been wrong in this project five times.

`S3_VOICES` selects a chord of that size, and the firmware wakes exactly the
voices the generator MEASURED as sounding for it. That detail is not
cosmetic: the port's allocator fills from voice 7 DOWNWARD, so a firmware
that woke voices 0..N-1 would wake precisely the silent ones. It did, in the
first draft, and rendered a peak of 16 out of 30000 while looking like a
dead engine.

## What this firmware does NOT prove

It does not prove RECALL. Engine B has no device-side recall path yet; the
coefficients in `s3_listen.bin` were built on the host by the same functions
the standalone gate uses, and frozen. So this proves the ENGINE on silicon,
fed by host-built coefficients — which is exactly the part that was never
audible before, and is not the whole instrument.

To change patch or notes:

    python3 tools/engineb/gen_listen_coefs.py <patch 0-63>

then rebuild. The firmware refuses to run if the blob's layout does not match
the build's struct sizes, so a stale blob is a printed error and not silent
garbage.
