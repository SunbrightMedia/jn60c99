# voice_render (0x180369070) — full stage map

Per-sample, mono-per-voice render. Operates on the voice-state struct (`a1`).
Output: one float at `a1+10672`, written to both L and R (`**a2`, `*a2[1]`);
stereo is added later by the chorus. All 8 voice copies are identical (per-voice
base stride +10512). Line numbers refer to `dsp_dump/0021_sub_180369070_*.c`.

## Stages (top → bottom)

| Lines | Stage | Notes |
|-------|-------|-------|
| 560–567 | Note-on reset | gate at `a1+101504==1.0` latches `a1+320`. |
| 568–654 | **DCO phase + saw** | inlined `wrap24` (×-16777216) on `a1+84336`; param propagation; first saw via `a1+544` offset. |
| 655–930 | **DCO pulse/PWM, sub, sync** | pulse from phase+PWM offsets (`a1+2288…2512`); `juno_triangle` call @881 (**arg dropped**); big mix → `a1+1792/1808`. |
| 931–1041 | **Sub-osc / noise** (two gated blocks `a1+2560`, `a1+3040`) | 1-pole smoothers; `0.00390625` (=1/256) scaling. |
| 1042–1106 | Waveform mix matrix | combines saw/pulse/sub/noise with `a1+3584…4176` gains. |
| 1107–1196 | Pre-filter HPF + mix | non-resonant HPF; `a1+6720…6816` 4th-order shaper. |
| 1201–1259 | **Filter-coeff compute** (gated `a1+7632==1.0`) | `wrap24` @1207 (**arg dropped**); `expf` + rational poly `a1+7872…8176` → cutoff coeff; `v240/(v240+1)` normalise. |
| 1304–1481 | **4-pole ladder VCF** (gated `a1+9056==1.0`) | `wrap24` @1308 (**arg dropped**); 4 identical stages (`fminf` clamp + 5th-order tanh-ish poly `a1+9184`); dispersion FIR sum `a1+9280…9504`. |
| 1482–1533 | LFO / mod smoothing | 1-pole smoothers; `a1+9648…10032`. |
| 1534–1606 | VCA env + pre-out | env at `a1+10080…10400`; output accum `a1+10656/10672`. |
| 1607–1631 | **Pitch/tuning table** | `v385=clamp(...,-20,8.9)`; table `unk_1809894E0` stride 208, 13-term poly → `a1+4416`. |
| 1632–2099 | **4× unison oscillator bank** | four near-identical blocks; each generates saw+pulse+sub via `juno_triangle`/`wrap24` — **~12 helper calls, args dropped** (lines 1700,1727,1754,1804,1831,1858,1908,1935,1962,2012,2039,2066). 5th-order waveshaper `a1+5952…6016`. |
| 2100–2139 | Bank mix + 1-pole | FIR-style sum `a1+5696…5936`; final smoother → `a1+4928`/`a1+3520`. |
| 2140–2149 | Output write | `a1+10672` → `**a2` and `*a2[1]`. |

## TRANSCRIPTION HAZARD — dropped XMM arguments

Hex-Rays rendered the waveshaper/phase helpers (`0x180368FC0` triangle,
`0x180368D60` wrap24) as **no-argument calls** because it lost the XMM register
carrying the phase. There are ~15 such sites (listed above). The decompile also
shows a few `fmodf(...)` results discarded (e.g. 865, 869) for the same reason.

These cannot be transcribed bit-exactly from the pseudocode alone — the argument
register is only visible in the **disassembly**. Resolution: `extract_asm.py`
dumps the asm of `0x180369070` + the two helpers; the XMM source of each call is
then unambiguous. Per the handoff rule, we read more carefully here — we do not
substitute a plausible guess.

Everything *outside* these helper-call sites is unambiguous in the pseudocode and
will be transcribed directly; the asm is needed only to pin the helper arguments.

## RESOLVED helper arguments (from `asm_dump/sub_180369070_180369070.asm`)

The x64 ABI passes the float arg in **xmm0**; tracing the xmm0 setup before each
`call` gives the exact argument:

| asm line | helper | argument | decompile site |
|----------|--------|----------|----------------|
| 446  | triangle | `v108` (wrapped phase, `a1+2304` offset) | ~881 |
| 1052 | wrap24 | `-v230`, v230 = old `*(a1+7552)` (`xorps xmm0,xmm11` = negate) | 1207 |
| 1251 | wrap24 | `-v244`, v244 = old `*(a1+8976)` | 1308 |
| 2101,2280,2458,2636 | triangle | **Pattern A** `(phase+1.0)*0.5`, phase=`*(a1+4640)` (xmm12=0.5=`dword_180AE500C`) | 1700,1804,1908,2012 |
| 2152,2330,2508,2686 | triangle | **Pattern B** `v412 / (a1+4816 ± 1.0)` (± by sign of v412) | 1727,1831,1935,2039 |
| 2205,2383,2561,2739 | triangle | **Pattern C** `-|xmm7|` (`andps` abs then `xorps` negate) | 1754,1858,1962,2066 |

Patterns A/B/C repeat once per oscillator across the 4-voice unison bank. The
exact source register for Pattern B's numerator and Pattern C's `xmm7` will be
re-confirmed against full register state when that stage is transcribed (the asm
file has the complete trace).

**Status:** all data needed for the voice engine is now in hand — `dsp_dump`
(algorithm) + `init_dump` (coefficients) + `asm_dump` (dropped args). No further
extraction is required; remaining work is transcription.
