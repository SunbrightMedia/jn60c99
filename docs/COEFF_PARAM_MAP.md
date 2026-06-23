# Coefficient → parameter map (from sub_180388170 registry)

The 349 runtime-applied coefficients are registered parameters. This maps each
to its parameter NAME and registered default source, parsed from
`chorus_coeffs/coeffgen_sub_180388170_180388170.asm`. 312 of 349 are covered
here; the default constant `xmmword_18098C030` is metadata `{1,0,0,0}` (a type
flag), NOT the value — values are applied downstream by the parameter system
(see docs/PARAM_SETTER_PLAN.md). Use this to VALIDATE any capture: e.g. an
on/off slot must read 0 or 1; 'Part Tune' should be ~centred.

| state offset | parameter | default source |
|---|---|---|
| 384 | Part Tune | xmmword_18098C030 |
| 592 | Portamento OnOff | 0 (xorps) |
| 608 | Portamento Mode | 0 (xorps) |
| 624 | Portamento Time | xmmword_18098C030 |
| 1040 | LFO Griffer Rate Sw | 0 (xorps) |
| 1056 | LFO Tempo Rate Sw | 0 (xorps) |
| 1072 | LFO Tempo Rate | 0 (xorps) |
| 1088 | LFO Rate | xmmword_18098C030 |
| 1856 | Gate | 0 (xorps) |
| 1872 | LFO Trig | 0 (xorps) |
| 1888 | Reset Sw | 0 (xorps) |
| 1904 | LFO UseExtGate | xmmword_18098C030 |
| 1920 | LFO Delay | xmmword_18098C030 |
| 1936 | LFO Delay Sw | xmmword_18098C030 |
| 1952 | LFO Sin Sw | xmmword_18098C030 |
| 1968 | LFO Tri Sw | xmmword_18098C030 |
| 1984 | LFO Sqr Sw | xmmword_18098C030 |
| 2000 | LFO Saw Sw | xmmword_18098C030 |
| 2016 | LFO Saw(Inv) Sw | xmmword_18098C030 |
| 2032 | LFO S&H Sw | xmmword_18098C030 |
| 2048 | LFO Noise Sw | xmmword_18098C030 |
| 2064 | LFO Noise Mix | xmmword_18098C030 |
| 2080 | LFO Internal Sw | xmmword_18098C030 |
| 2096 | LFO External0 Sw | xmmword_18098C030 |
| 2112 | LFO External1 Sw | xmmword_18098C030 |
| 2560 | LFO trigger env sw | 0 (xorps) |
| 2784 | ENV Attack | xmmword_18098C030 |
| 2800 | ENV Sustain | xmmword_18098C030 |
| 2816 | ENV Decay | xmmword_18098C030 |
| 2832 | ENV Release | xmmword_18098C030 |
| 2848 | Q24C Initialize | xmmword_18098C030 |
| 3040 | LFO trigger env sw | 0 (xorps) |
| 3264 | ENV Attack | xmmword_18098C030 |
| 3280 | ENV Sustain | xmmword_18098C030 |
| 3296 | ENV Decay | xmmword_18098C030 |
| 3312 | ENV Release | xmmword_18098C030 |
| 3328 | Q24C Initialize | xmmword_18098C030 |
| 3840 | OSC1 Feet | 0 (xorps) |
| 3856 | Griffer Bend SW | 0 (xorps) |
| 3872 | Bend Enable SW | 0 (xorps) |
| 3888 | PWM SW LFO | 0 (xorps) |
| 3904 | PWM SW ENV1 | 0 (xorps) |
| 3920 | PWM SW ENV2 | 0 (xorps) |
| 3936 | PWM SW Manual | 0 (xorps) |
| 3952 | Tune | xmmword_18098C030 |
| 3968 | Detune | xmmword_18098C030 |
| 3984 | Mod Sens | xmmword_18098C030 |
| 4000 | Mod Sw | xmmword_18098C030 |
| 4016 | LFO Gain | xmmword_18098C030 |
| 4032 | LFO Level | xmmword_18098C030 |
| 4048 | LFO Sw | xmmword_18098C030 |
| 4064 | ENV1 Level | xmmword_18098C030 |
| 4080 | ENV2 Level | xmmword_18098C030 |
| 4096 | ENV Sw | xmmword_18098C030 |
| 4112 | Bend Level | xmmword_18098C030 |
| 4128 | Bend Range | xmmword_18098C030 |
| 4144 | PWM Level | xmmword_18098C030 |
| 4192 | JU OSC Saw Lev | xmmword_18098C030 |
| 4208 | JU OSC Sqr Lev | xmmword_18098C030 |
| 4224 | JU OSC Sub Lev | xmmword_18098C030 |
| 5520 | Duty Tune | xmmword_18098C030 |
| 6448 | Osc1 Mute | xmmword_18098C030 |
| 6512 | Osc1 Level | xmmword_18098C030 |
| 6528 | Osc Noise Level | xmmword_18098C030 |
| 6720 | Griffer SW | 0 (xorps) |
| 6736 | LPF Cutoff | xmmword_18098C030 |
| 6832 | LPF Resonance | xmmword_18098C030 |
| 6864 | Velocity | 0 (xorps) |
| 7008 | Env1/2 | 0 (xorps) |
| 7024 | Int/Env | 0 (xorps) |
| 7296 | LFO Gain | 0 (xorps) |
| 7312 | Ext LFO Sw | 0 (xorps) |
| 7328 | GRF Bned SW | 0 (xorps) |
| 7344 | LFO Level | xmmword_18098C030 |
| 7360 | MOD Sens | xmmword_18098C030 |
| 7376 | MOD SW | xmmword_18098C030 |
| 7392 | ENV Level | xmmword_18098C030 |
| 7408 | KCV Level | xmmword_18098C030 |
| 7424 | Velocity Sens | xmmword_18098C030 |
| 7440 | Velocity Offset | xmmword_18098C030 |
| 7456 | Bend Level | xmmword_18098C030 |
| 7472 | Bend Range | xmmword_18098C030 |
| 7600 | Cutoff Tune | xmmword_18098C030 |
| 7616 | Resonance Tune | xmmword_18098C030 |
| 7632 | PlugIn Sw | ? |
| 9056 | PlugIn Sw | 0 (xorps) |
| 9072 | -12dB/oct Tap | xmmword_18098C030 |
| 9088 | -18dB/oct Tap | xmmword_18098C030 |
| 9104 | -24dB/oct Tap | xmmword_18098C030 |
| 9584 | AMP TONE | xmmword_18098C030 |
| 9600 | AMP VELOCITY SENS | xmmword_18098C030 |
| 9616 | AMP FIX VELOCITY LEVEL | xmmword_18098C030 |
| 9680 | Velocity | 0 (xorps) |
| 9824 | Mute | 0 (xorps) |
| 10176 | Gate SW | 0 (xorps) |
| 10192 | ENV1 SW | 0 (xorps) |
| 10208 | ENV2 SW | 0 (xorps) |
| 10224 | Ext ENV SW | 0 (xorps) |
| 10240 | HPF Cutoff | xmmword_18098C030 |
| 10256 | HPF Switch | xmmword_18098C030 |
| 10272 | Boost LPF Level | xmmword_18098C030 |
| 10288 | Boost Thru Level | xmmword_18098C030 |
| 10304 | ENV LEVEL | xmmword_18098C030 |
| 10320 | AMP LEVEL | xmmword_18098C030 |
| 84304 | Ext Noise Sw | 0 (xorps) |
| 84448 | Voice01 Output On/Off | xmmword_18098C030 |
| 84464 | Voice23 Output On/Off | xmmword_18098C030 |
| 84480 | Voice45 Output On/Off | xmmword_18098C030 |
| 84496 | Voice67 Output On/Off | xmmword_18098C030 |
| 84544 | Effect SW | xmmword_18098C030 |
| 84560 | Mute SW | xmmword_18098C030 |
| 85136 | DS Drive | xmmword_18098C030 |
| 85152 | DS Level | xmmword_18098C030 |
| 85168 | DS Mute | xmmword_18098C030 |
| 85184 | DS BiasMute | xmmword_18098C030 |
| 85984 | OD TONE | xmmword_18098C030 |
| 86288 | DS Drive | xmmword_18098C030 |
| 86304 | DS Level | xmmword_18098C030 |
| 86320 | DS Mute | xmmword_18098C030 |
| 87056 | DS TONE | xmmword_18098C030 |
| 91120 | Delay Time | 0 (xorps) |
| 91136 | Error Depth | 0 (xorps) |
| 91152 | LFO Rate | xmmword_18098C030 |
| 91168 | LFO Phase | xmmword_18098C030 |
| 91184 | LFO Depth | xmmword_18098C030 |
| 91200 | Noise Level | xmmword_18098C030 |
| 91216 | Dry Level | xmmword_18098C030 |
| 91232 | Wet Level | xmmword_18098C030 |
| 91248 | Ip Fc | xmmword_18098C030 |
| 91264 | On/Off | xmmword_18098C030 |
| 91280 | Mute | xmmword_18098C030 |
| 96336 | Delay Time | 0 (xorps) |
| 96352 | LFO Rate | xmmword_18098C030 |
| 96368 | LFO Depth | xmmword_18098C030 |
| 96384 | Ip Fc | xmmword_18098C030 |
| 96400 | On/Off | xmmword_18098C030 |
| 96416 | Mute | xmmword_18098C030 |
| 101072 | Patch Level | xmmword_18098C030 |
| 101136 | Expression | xmmword_18098C030 |
| 101152 | Volume | xmmword_18098C030 |
| 101744 | DLY Mute | xmmword_18098C030 |
| 102352 | Delay Time | 0 (xorps) |
| 102368 | High Cut C0 | xmmword_18098C030 |
| 102384 | High Cut A0 | xmmword_18098C030 |
| 102400 | High Cut A1 | xmmword_18098C030 |
| 102416 | High Cut B0 | xmmword_18098C030 |
| 102432 | High Cut B2 | xmmword_18098C030 |
| 102448 | Use IIR High Cut Filter | xmmword_18098C030 |
| 102464 | High Cut Fc | xmmword_18098C030 |
| 102480 | High Cut Qc | xmmword_18098C030 |
| 102496 | High Cut Sw | xmmword_18098C030 |
| 102512 | Dry Level | xmmword_18098C030 |
| 102528 | Wet Level | xmmword_18098C030 |
| 102560 | Feedback | xmmword_18098C030 |
| 102576 | On/Off | xmmword_18098C030 |
| 102592 | Mute | xmmword_18098C030 |
| 102608 | LF Damp Fc | xmmword_18098C030 |
| 102624 | LF Damp Hp | xmmword_18098C030 |
| 102640 | LF Damp Lp | xmmword_18098C030 |
| 102656 | HF Damp Fc | xmmword_18098C030 |
| 102672 | HF Damp Hp | xmmword_18098C030 |
| 102688 | HF Damp Lp | xmmword_18098C030 |
| 4297584 | Delay Time | 0 (xorps) |
| 4297600 | High Cut C0 | xmmword_18098C030 |
| 4297616 | High Cut A0 | xmmword_18098C030 |
| 4297632 | High Cut A1 | xmmword_18098C030 |
| 4297648 | High Cut B0 | xmmword_18098C030 |
| 4297664 | High Cut B2 | xmmword_18098C030 |
| 4297680 | Use IIR High Cut Filter | xmmword_18098C030 |
| 4297696 | High Cut Fc | xmmword_18098C030 |
| 4297712 | High Cut Qc | xmmword_18098C030 |
| 4297728 | High Cut Sw | xmmword_18098C030 |
| 4297744 | Dry Level | xmmword_18098C030 |
| 4297760 | Wet Level | xmmword_18098C030 |
| 4297792 | Tap Time | xmmword_18098C030 |
| 4297808 | Feedback | xmmword_18098C030 |
| 4297824 | On/Off | xmmword_18098C030 |
| 4297840 | Mute | xmmword_18098C030 |
| 4297856 | Tap Sw | xmmword_18098C030 |
| 4297872 | Stereo Sw | xmmword_18098C030 |
| 4297888 | Wet Gain | xmmword_18098C030 |
| 4297904 | LF Damp Fc | xmmword_18098C030 |
| 4297920 | LF Damp Hp | xmmword_18098C030 |
| 4297936 | LF Damp Lp | xmmword_18098C030 |
| 4297952 | HF Damp Fc | xmmword_18098C030 |
| 4297968 | HF Damp Hp | xmmword_18098C030 |
| 4297984 | HF Damp Lp | xmmword_18098C030 |
| 6395312 | Chorus CV | xmmword_18098C030 |
| 6395328 | Chrus LFO Sync | xmmword_18098C030 |
| 6396128 | Delay Time | 0 (xorps) |
| 6396144 | LFO Curve | xmmword_18098C030 |
| 6396160 | LFO Manual | xmmword_18098C030 |
| 6396176 | LFO Depth | xmmword_18098C030 |
| 6396192 | High Cut C0 | xmmword_18098C030 |
| 6396208 | High Cut A0 | xmmword_18098C030 |
| 6396224 | High Cut A1 | xmmword_18098C030 |
| 6396240 | High Cut B0 | xmmword_18098C030 |
| 6396256 | High Cut B2 | xmmword_18098C030 |
| 6396272 | Use IIR High Cut Filter | xmmword_18098C030 |
| 6396288 | High Cut Fc | xmmword_18098C030 |
| 6396304 | High Cut Qc | xmmword_18098C030 |
| 6396320 | High Cut Sw | xmmword_18098C030 |
| 6396336 | Low Cut Fc | xmmword_18098C030 |
| 6396352 | Low Cut Sw | xmmword_18098C030 |
| 6396368 | Dry Level | xmmword_18098C030 |
| 6396384 | Wet Level | xmmword_18098C030 |
| 6396400 | Ip Fc | xmmword_18098C030 |
| 6396416 | Feedback | xmmword_18098C030 |
| 6396432 | On/Off | xmmword_18098C030 |
| 6396448 | Mute | xmmword_18098C030 |
| 6396464 | Tap Sw | xmmword_18098C030 |
| 6396480 | Stereo Sw | xmmword_18098C030 |
| 6396496 | Dry Gain | xmmword_18098C030 |
| 6396512 | Wet Gain | xmmword_18098C030 |
| 6429472 | Flanger CV | xmmword_18098C030 |
| 6429488 | Flanger LFO Sync | xmmword_18098C030 |
| 6430464 | Delay Time | 0 (xorps) |
| 6430480 | LFO Curve | xmmword_18098C030 |
| 6430496 | LFO Manual | xmmword_18098C030 |
| 6430512 | LFO Depth | xmmword_18098C030 |
| 6430528 | High Cut C0 | xmmword_18098C030 |
| 6430544 | High Cut A0 | xmmword_18098C030 |
| 6430560 | High Cut A1 | xmmword_18098C030 |
| 6430576 | High Cut B0 | xmmword_18098C030 |
| 6430592 | High Cut B2 | xmmword_18098C030 |
| 6430608 | Use IIR High Cut Filter | xmmword_18098C030 |
| 6430624 | High Cut Fc | xmmword_18098C030 |
| 6430640 | High Cut Qc | xmmword_18098C030 |
| 6430656 | High Cut Sw | xmmword_18098C030 |
| 6430672 | Low Cut Fc | xmmword_18098C030 |
| 6430688 | Low Cut Sw | xmmword_18098C030 |
| 6430704 | Dry Level | xmmword_18098C030 |
| 6430720 | Wet Level | xmmword_18098C030 |
| 6430736 | Ip Fc | xmmword_18098C030 |
| 6430752 | Feedback | xmmword_18098C030 |
| 6430768 | On/Off | xmmword_18098C030 |
| 6430784 | Mute | xmmword_18098C030 |
| 6430800 | LFO St.Phase | xmmword_18098C030 |
| 6430816 | LFO St.Ofst | xmmword_18098C030 |
| 6497168 | Delay Time | 0 (xorps) |
| 6497184 | High Cut C0 | xmmword_18098C030 |
| 6497200 | High Cut A0 | xmmword_18098C030 |
| 6497216 | High Cut A1 | xmmword_18098C030 |
| 6497232 | High Cut B0 | xmmword_18098C030 |
| 6497248 | High Cut B2 | xmmword_18098C030 |
| 6497264 | Use IIR High Cut Filter | xmmword_18098C030 |
| 6497280 | High Cut Fc | xmmword_18098C030 |
| 6497296 | High Cut Qc | xmmword_18098C030 |
| 6497312 | High Cut Sw | xmmword_18098C030 |
| 6497328 | Dry Level | xmmword_18098C030 |
| 6497344 | Wet Level | xmmword_18098C030 |
| 6497376 | Feedback | xmmword_18098C030 |
| 6497392 | On/Off | xmmword_18098C030 |
| 6497408 | Mute | xmmword_18098C030 |
| 6497424 | LF Damp Fc | xmmword_18098C030 |
| 6497440 | LF Damp Hp | xmmword_18098C030 |
| 6497456 | LF Damp Lp | xmmword_18098C030 |
| 6497472 | HF Damp Fc | xmmword_18098C030 |
| 6497488 | HF Damp Hp | xmmword_18098C030 |
| 6497504 | HF Damp Lp | xmmword_18098C030 |
| 10692016 | Chorus CV | xmmword_18098C030 |
| 10692032 | Chrus LFO Sync | xmmword_18098C030 |
| 10693008 | Delay Time | 0 (xorps) |
| 10693024 | LFO Curve | xmmword_18098C030 |
| 10693040 | LFO Manual | xmmword_18098C030 |
| 10693056 | LFO Depth | xmmword_18098C030 |
| 10693072 | High Cut C0 | xmmword_18098C030 |
| 10693088 | High Cut A0 | xmmword_18098C030 |
| 10693104 | High Cut A1 | xmmword_18098C030 |
| 10693120 | High Cut B0 | xmmword_18098C030 |
| 10693136 | High Cut B2 | xmmword_18098C030 |
| 10693152 | Use IIR High Cut Filter | xmmword_18098C030 |
| 10693168 | High Cut Fc | xmmword_18098C030 |
| 10693184 | High Cut Qc | xmmword_18098C030 |
| 10693200 | High Cut Sw | xmmword_18098C030 |
| 10693216 | Low Cut Fc | xmmword_18098C030 |
| 10693232 | Low Cut Sw | xmmword_18098C030 |
| 10693248 | Dry Level | xmmword_18098C030 |
| 10693264 | Wet Level | xmmword_18098C030 |
| 10693280 | Ip Fc | xmmword_18098C030 |
| 10693296 | Feedback | xmmword_18098C030 |
| 10693312 | On/Off | xmmword_18098C030 |
| 10693328 | Mute | xmmword_18098C030 |
| 10693344 | LFO St.Phase | xmmword_18098C030 |
| 10693360 | LFO St.Ofst | xmmword_18098C030 |
| 10759376 | Rev Ecf On | xmmword_18098C030 |
| 10759392 | Rev Ecf Density | xmmword_18098C030 |
| 10759408 | Rev Ecf Level | xmmword_18098C030 |
| 10759424 | Rev Ecf Dir Lev | xmmword_18098C030 |
| 10759440 | Rev Ecf Glb Lev | xmmword_18098C030 |
| 10759488 | Rev Ecf Depth | xmmword_18098C030 |
| 10759504 | Rev Ecf Rate | dword_18098BC64 |
| 10759520 | Rev Ecf HPF C0 | xmmword_18098C030 |
| 10759536 | Rev Ecf HPF A0 | xmmword_18098C030 |
| 10759552 | Rev Ecf HPF B0 | xmmword_18098C030 |
| 10759568 | Rev Ecf LPF C0 | xmmword_18098C030 |
| 10759584 | Rev Ecf LPF A0 | xmmword_18098C030 |
| 10759600 | Rev Ecf LPF A1 | xmmword_18098C030 |
| 10759616 | Rev Ecf LPF B0 | xmmword_18098C030 |
| 10759632 | Rev Ecf LPF B1 | xmmword_18098C030 |
| 10759648 | Rev Ecf DPF0 Fc | xmmword_18098C030 |
| 10759664 | Rev Ecf DPF0 Hp | xmmword_18098C030 |
| 10759680 | Rev Ecf DPF0 Lp | xmmword_18098C030 |
| 10759696 | Rev Ecf DPF1 Fc | xmmword_18098C030 |
| 10759712 | Rev Ecf DPF1 Hp | xmmword_18098C030 |
| 10759728 | Rev Ecf DPF1 Lp | xmmword_18098C030 |
| 10759744 | Rev Ecf DPF2 Fc | xmmword_18098C030 |
| 10759760 | Rev Ecf DPF2 Hp | xmmword_18098C030 |
| 10759776 | Rev Ecf DPF2 Lp | xmmword_18098C030 |
| 10759792 | Rev Ecf DPF3 Fc | xmmword_18098C030 |
| 10759808 | Rev Ecf DPF3 Hp | xmmword_18098C030 |
| 10759824 | Rev Ecf DPF3 Lp | xmmword_18098C030 |

**41 coefficients default to literal 0** (already correct in our zero-init):

592, 608, 1040, 1056, 1072, 1856, 1872, 1888, 2560, 3040, 3840, 3856, 3872, 3888, 3904, 3920, 3936, 6720, 6864, 7008, 7024, 7296, 7312, 7328, 9056, 9680, 9824, 10176, 10192, 10208, 10224, 84304, 91120, 91136, 96336, 102352, 4297584, 6396128, 6430464, 6497168, 10693008
