# CELLMAP — per-voice state inventory of `src/voice_render.c`

**Track B blueprint.** This is the master cell map of the JUNO-60 per-voice DSP
state as touched by `src/voice_render.c` (2185 lines, exact transcription of
sub_180369070). It is the template a later agent uses to write a NATIVE
(non-transcribed) voice implementation that must null below −90 dB against the
bit-exact reference — and the reusable method for mapping any sibling voice
(JX-3P etc.): scan every `JF/JI/JU(a1|base, off)` site, classify R/W, group by
dataflow, then name from the plugin's own registry.

Legend / provenance tags:
- **[REG]** name READ from the plugin's own parameter registry
  (`docs/COEFF_PARAM_MAP.md`, parsed from sub_180388170).
- **[R]** role READ from a cited port source (`src/juno_apply.c`,
  `src/juno_note.c`, `src/juno_prepare.c`, `src/juno_init.c`) whose own
  provenance is the executed binary.
- **[I]** role INFERRED here from the dataflow of `voice_render.c` alone —
  verify before renaming anything user-visible.
- Line numbers `:NNN` refer to the current `src/voice_render.c`.
- `[off]` in a formula means the float at that a1-relative offset.

## 0. Region model (READ, `src/juno_engine.h:20-35` + header comment `voice_render.c:18-31`)

One function serves all 8 voices. Three address regions, derived by diffing the
8 specialised binary copies (docs/POLYPHONY.md):

| region | offsets | per-voice stride | base pointer |
|---|---|---|---|
| main per-voice block | [176, 10672] | +voice*10512 (`a1`) | tiles [176, 84272) exactly |
| shared global block | [84272, 84432] (end 84436) | +0 — ALL voices, chained in order 0..7 | `base` |
| aux one-shot edge | 101504 | +voice*32 | `base` (`auxoff`) |

Totals from the scan: **610 distinct a1-relative cells** (this table is
complete — every access site in the file), **11 shared base cells**, plus the
aux latch. Voices MUST render in order 0..7 each sample: the shared noise
block is advanced once per voice and chains.

## 1. Subsystem boundaries — cells owned

One sub-table per subsystem; together these are ALL cells the voice render touches.


### A. Note / pitch-CV input conditioner  `[176..512]` (22 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 176 | JF | R | 624 | -- | ramped M.CV alt input (inactive at rest: gated by 448==240*272==0) [I] |
| 192 | JF | W | -- | 636 | shadow of 176 [I] |
| 208 | JF | R | 623 | -- | ramped M.Gate alt input (same gating) [I] |
| 224 | JF | W | -- | 632 | shadow of 208 [I] |
| 240 | JF | R | 650 | -- | smoother-enable factor A (0 at rest, juno_note.c:27) [R] |
| 256 | JF | W | -- | 652 | shadow of 240 [I] |
| 272 | JF | R | 647 | -- | smoother-enable factor B (0 at rest) [R] |
| 288 | JF | W | -- | 648 | shadow of 272 [I] |
| 304 | JF | R | 654 | -- | M.CV -- note pitch CV (juno_note.c:97, param 1, immediate) [R] |
| 320 | JF/JI | RW | 587,591 | 593,2177 | M.Gate -- gate input; saved/zeroed by retrig latch head, restored at tail [R] |
| 336 | JF | W | -- | 655 | shadow of 304 [I] |
| 352 | JF | W | -- | 639 | shadow of gate value v2 [I] |
| 368 | JF | R | 626 | -- | mod-CV input A (bend/wheel bus; smoother-fed) [I] |
| 384 | JF | R | 628 | -- | "Part Tune" [REG] |
| 400 | JF | W | -- | 641 | shadow of 368 [I] |
| 416 | JF | W | -- | 642 | shadow of 384 [I] |
| 432 | JI | W | -- | 631 | int zeroed every sample [I] |
| 448 | JF | W | -- | 656 | smoother-enable product v26 = [272]*[240] [I] |
| 464 | JF | W | -- | 659 | conditioned pitch v28 = lerp([304],[176],v26) [I] |
| 480 | JF | W | -- | 660 | conditioned gate v29 = lerp(gate,[208],v26) [I] |
| 496 | JF/JI | RW | 638 | 672 | gate sign helper (float write; prev int-copied to 512) [I] |
| 512 | JI | W | -- | 638 | int shadow of 496 [I] |

### B. Gate binarizer  `[528..576]` (4 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 528 | JF | W | -- | 690 | gate code copy of 560 (v36 = signclamp+1, in {0,1,2}) [I] |
| 544 | JF | R | 662 | -- | gate threshold offset (into v31) [I] |
| 560 | JF/JI | RW | 686,973,1028,1551 | 691 | BINARY GATE -- drives both ADSRs and gate ramp (juno_note.c:45-53) [R] |
| 576 | JI | W | -- | 692 | int shadow of prev 560 [I] |

### C. Portamento / glide  `[592..832]` (15 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 592 | JF | R | 696 | -- | "Portamento OnOff" [REG] |
| 608 | JF | R | 682 | -- | "Portamento Mode" [REG] |
| 624 | JF | R | 685 | -- | "Portamento Time" [REG] |
| 656 | JF | RW | 698 | 703 | glide integrator [I] |
| 672 | JF | RW | 697 | 705 | glide rate state [I] |
| 688 | JF | RW | 701 | 720 | glide arrival flag (0/ramp/1) [I] |
| 704 | JF | RW | 687 | 734 | glided pitch [I] |
| 720 | JF | W | -- | 693 | shadow of 704 [I] |
| 736 | JF | W | -- | 699 | glide-enable v45 = ((sign+1)*[608]-[608]+1)*[592] [I] |
| 752 | JF/JI | RW | 1078,1086,1176 | 735 | FINAL PITCH CV (consumed by KCV mixers 3616/6976 and copied to 3696) [I] |
| 768 | JF | R | 684 | -- | glide rate factor [I] |
| 784 | JF | R | 688 | -- | glide rate offset [I] |
| 800 | JF | R | 697 | -- | glide denominator offset [I] |
| 816 | JF | R | 695 | -- | glide arrival window [I] |
| 832 | JF | R | 714 | -- | glide arrival ramp inc [I] |

### D. Mod-CV combiner + external LFO inputs  `[848..1024]` (12 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 848 | JF | R | 729 | -- | gain: input A [368] -> mod CV [I] |
| 864 | JF | R | 724 | -- | gain: Part Tune [384] -> mod CV [I] |
| 880 | JF/JI | RW | 725,1079,1177 | 732 | summed tune/mod CV = [384]*[864]+[368]*[848] (into 3616/6976) [I] |
| 896 | JI | W | -- | 725 | int shadow of 880 [I] |
| 912 | JF | R | 727 | -- | LFO rate-mod mantissa (scaled by both exp tables) [I] |
| 928 | JF | W | -- | 738 | shadow of 912 [I] |
| 944 | JF | R | 733 | -- | LFO ext-gate input [I] |
| 960 | JF | W | -- | 737 | shadow of 944 [I] |
| 976 | JI | R | 730 | -- | ext LFO input 0 [I] |
| 992 | JI | W | -- | 739 | shadow of 976 [I] |
| 1008 | JI | R | 728 | -- | ext LFO input 1 [I] |
| 1024 | JI | W | -- | 740 | shadow of 1008 [I] |

### E. LFO rate + tempo sync + delay envelope drive  `[1040..1216]` (12 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 1040 | JF | R | 783 | -- | "LFO Griffer Rate Sw" [REG] |
| 1056 | JF | R | 797 | -- | "LFO Tempo Rate Sw" [REG]; TEMPO SYNC switch (recall blob 59) [R] |
| 1072 | JF | R | 799 | -- | "LFO Tempo Rate" [REG]; tempo-synced LFO rate coeff (host BPM, juno_apply.c:793-816) [R] |
| 1088 | JF | R | 785 | -- | "LFO Rate" [REG]; LFO RATE recall c22 (BINDINGS) [R] |
| 1104 | JF | RW | 736 | 786 | smoothed modded rate [I] |
| 1120 | JF | W | -- | 741 | shadow of 1104 [I] |
| 1136 | JF | W | -- | 819 | effective LFO rate (post tempo-select) [I] |
| 1152 | JF | R | 784 | -- | rate smoothing coeff [I] |
| 1168 | JF | R | 726 | -- | rate-mod exponent (int-valued float) [I] |
| 1184 | JF | R | 798 | -- | exp rate scale [I] |
| 1200 | JF | R | 798 | -- | exp rate arg gain [I] |
| 1216 | JF | R | 801 | -- | exp rate offset [I] |

### F. LFO oscillator (multi-wave, S&H, noise, delay env)  `[1408..2544]` (72 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 1408 | JF | RW | 958 | 870 | LFO noise output [I] |
| 1424 | JF/JI | RW | 839 | 814 | latched shared noise (int copy of base[84432]) [I] |
| 1440 | JF/JI | RW | 961 | 812 | latched ext LFO 0 (copy of 976-val) [I] |
| 1456 | JF/JI | RW | 962 | 813 | latched ext LFO 1 [I] |
| 1472 | JF | RW | 955 | 853 | LFO delay-envelope level (clamped >=0) [I] |
| 1488 | JF | RW | 805 | 825 | ext-gate clamped [-1,1] [I] |
| 1504 | JF | RW | 802 | 810,840 | LFO delay ramp state [I] |
| 1520 | JF | W | -- | 809 | prev of 1504 [I] |
| 1536 | JF | RW | 806 | 868 | LFO master phase [I] |
| 1552 | JF | RW | 854 | 811 | prev phase [I] |
| 1568 | JF/JI | RW | 800 | 852 | S&H noise smoother state [I] |
| 1584 | JF/JI | RW | 851 | 800 | prev of 1568 [I] |
| 1600 | JF/JI | RW | 804 | 882 | S&H held value [I] |
| 1616 | JF/JI | RW | 867 | 804 | prev of 1600 [I] |
| 1632 | JI | R | 807 | -- | S&H clock [I] |
| 1648 | JI | W | -- | 807 | prev of 1632 [I] |
| 1664 | JF | W | -- | 834 | LFO phase increment = min([2128],[1136]/65536)*[2144] [I] |
| 1680 | JF | RW | 944 | 885 | LFO saw out [I] |
| 1696 | JF | RW | 945 | 888 | LFO inv-saw out (= -[1680]) [I] |
| 1712 | JF | RW | 956 | 941 | LFO square out [I] |
| 1728 | JF | RW | 953 | 928 | LFO triangle out [I] |
| 1744 | JF | W | -- | 952 | LFO sine out (quartic shaper 2160..2240) [I] |
| 1760 | JF | RW | 943 | 886 | LFO S&H out [I] |
| 1776 | JF | W | -- | 959 | LFO delay-env depth v120 = ([1936]*[1472]-[1936])+1 [I] |
| 1792 | JF | RW | 1083,1187 | 961 | LFO OUT (int/ext mix; feeds DCO 3712 and VCF smoother 7088) [I] |
| 1808 | JF/JI | RW | 964,1094,1196 | 960 | LFO waveform mix pre-switch (feeds 3712 gain path and VCF smoother 7168) [I] |
| 1824 | JF/JI | RW | 965,967,1022 | 929 | square-phase sign; env-trigger source for ENV1/ENV2 [I] |
| 1840 | JF | W | -- | 818 | prev of 1856 [I] |
| 1856 | JF | R | 816 | -- | "Gate" [REG]; any-key-held flag, broadcast to all voices (juno_note.c:204-226) [R] |
| 1872 | JF | R | 838 | -- | "LFO Trig" [REG]; LFO KEY TRIG recall: byte==0 -> 1.0 (juno_apply.c:623) [R] |
| 1888 | JF | R | 845 | -- | "Reset Sw" [REG]; phase run gate; prepare=1.0 (juno_prepare.c:76) [R] |
| 1904 | JF | R | 803 | -- | "LFO UseExtGate" [REG] |
| 1920 | JF | R | 827 | -- | "LFO Delay" [REG]; LFO DELAY recall (SR-variant c42/43/44) [R] |
| 1936 | JF | R | 955 | -- | "LFO Delay Sw" [REG]; LFO DELAY switch recall: byte!=0 -> 1.0 [R] |
| 1952 | JF | R | 957 | -- | "LFO Sin Sw" [REG] |
| 1968 | JF | R | 942 | -- | "LFO Tri Sw" [REG] |
| 1984 | JF | R | 956 | -- | "LFO Sqr Sw" [REG] |
| 2000 | JF | R | 944 | -- | "LFO Saw Sw" [REG] |
| 2016 | JF | R | 945 | -- | "LFO Saw(Inv) Sw" [REG] |
| 2032 | JF | R | 943 | -- | "LFO S&H Sw" [REG] |
| 2048 | JF | R | 958 | -- | "LFO Noise Sw" [REG] |
| 2064 | JF | R | 855,856 | -- | "LFO Noise Mix" [REG]; registry name kept; recall mirrors LFO RATE c22 here (BINDINGS 2064) [R] |
| 2080 | JF | R | 954 | -- | "LFO Internal Sw" [REG] |
| 2096 | JF | R | 961 | -- | "LFO External0 Sw" [REG] |
| 2112 | JF | R | 962 | -- | "LFO External1 Sw" [REG] |
| 2128 | JF | R | 824 | -- | phase-inc clamp max (init 1014923857) [R] |
| 2144 | JF | R | 832 | -- | phase-inc scale rate->cycles/sample [I] |
| 2160 | JF | R | 948 | -- | sine shaper c0 [I] |
| 2176 | JF | R | 948 | -- | sine shaper c1 [I] |
| 2192 | JF | R | 949 | -- | sine shaper c2 [I] |
| 2208 | JF | R | 947 | -- | sine shaper c3 [I] |
| 2224 | JF | R | 946 | -- | sine shaper c4 [I] |
| 2240 | JF | R | 950 | -- | sine shaper offset [I] |
| 2256 | JF | R | 844 | -- | delay-env scale [I] |
| 2272 | JF | R | 841 | -- | delay-env offset [I] |
| 2288 | JF | R | 869 | -- | saw phase offset [I] |
| 2304 | JF | R | 905 | -- | square phase offset [I] |
| 2320 | JF | R | 887 | -- | triangle phase offset [I] |
| 2336 | JF | R | 927 | -- | sine phase offset [I] |
| 2352 | JF | R | 884 | -- | saw gain [I] |
| 2368 | JF | R | 930 | -- | square gain [I] |
| 2384 | JF | R | 917 | -- | triangle gain [I] |
| 2400 | JF | R | 951 | -- | sine gain [I] |
| 2416 | JF | R | 883 | -- | S&H gain [I] |
| 2432 | JF | R | 870 | -- | noise gain [I] |
| 2448 | JF | R | 855 | -- | noise smoother mix [I] |
| 2464 | JF | R | 851 | -- | noise smoother coeff [I] |
| 2480 | JF | R | 884 | -- | saw offset [I] |
| 2496 | JF | R | 916 | -- | square threshold offset [I] |
| 2512 | JF | R | 930 | -- | square offset [I] |
| 2528 | JI | W | -- | 965 | int shadow of 1824 [I] |
| 2544 | JI | W | -- | 966 | int shadow of 1808 [I] |

### G. ENV1 -- filter ADSR  `[2560..3024]` (30 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 2560 | JF | R | 971 | -- | "LFO trigger env sw" [REG]; ENV1 LFO-trigger arm (LFO TRIG ENV leaf 121, juno_apply.c:665-668) [R] |
| 2576 | JF | W | -- | 974 | ENV1 gated gate = [560]*trig [I] |
| 2592 | JF/JI | RW | 975 | 1017 | ENV1 output accumulator [I] |
| 2608 | JF/JI | RW | 985,1007 | 975 | ENV1 prev out [I] |
| 2624 | JF/JI | RW | 977 | 986 | ENV1 integrator [I] |
| 2640 | JF/JI | RW | 976,988 | 977,1000 | ENV1 region flag [I] |
| 2656 | JF/JI | RW | 985 | 976 | ENV1 prev integrator [I] |
| 2672 | JF/JI | RW | 978 | 1009 | ENV1 peak target [I] |
| 2688 | JF/JI | RW | 1001 | 978 | ENV1 prev region flag [I] |
| 2704 | JF | RW | 1006 | 989 | ENV1 target blend = lerp([2928],[2960],[2848]) [I] |
| 2720 | JF/JI | RW | 979 | 1014 | ENV1 rate hold [I] |
| 2736 | JF/JI | RW | 1012,1013 | 979 | ENV1 prev rate [I] |
| 2752 | JF/JI | RW | 1084,1183,1185,1569 | 1020 | ENV1 OUT raw (VCA source; F-ENV lerp base, juno_apply.c:553) [R] |
| 2768 | JF | W | -- | 1021 | ENV1 out scaled = [2752]*[3024] -- WRITE-ONLY in voice render [I] |
| 2784 | JF | R | 998 | -- | "ENV Attack" [REG] |
| 2800 | JF | R | 999 | -- | "ENV Sustain" [REG] |
| 2816 | JF | R | 1004 | -- | "ENV Decay" [REG] |
| 2832 | JF | R | 1010 | -- | "ENV Release" [REG] |
| 2848 | JF | R | 989,990 | -- | "Q24C Initialize" [REG] |
| 2864 | JF | R | 980 | -- | ENV1 gate threshold offset [I] |
| 2880 | JF | R | 987 | -- | ENV1 attack region offset [I] |
| 2896 | JF | R | 985 | -- | ENV1 integrator feedback coeff [I] |
| 2912 | JF | R | 1011 | -- | ENV1 sustain/level input [I] |
| 2928 | JF | R | 990,991,999,1008 | -- | ENV1 peak clamp [I] |
| 2944 | JF | R | 1002 | -- | ENV1 decay target [I] |
| 2960 | JF | R | 989 | -- | ENV1 target B [I] |
| 2976 | JF | R | 1012 | -- | ENV1 rate smoothing coeff [I] |
| 2992 | JF | R | 1018 | -- | ENV1 out scale A [I] |
| 3008 | JF | R | 1018 | -- | ENV1 out scale B [I] |
| 3024 | JF | R | 1019 | -- | ENV1 aux out scale [I] |

### H. ENV2 -- amp ADSR  `[3040..3504]` (30 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 3040 | JF | R | 1026 | -- | "LFO trigger env sw" [REG]; ENV2 LFO-trigger arm (same leaf 121) [R] |
| 3056 | JF | W | -- | 1029 | ENV2 gated gate [I] |
| 3072 | JF/JI | RW | 1030 | 1071 | ENV2 output accumulator [I] |
| 3088 | JF/JI | RW | 1040,1062 | 1030 | ENV2 prev out [I] |
| 3104 | JF/JI | RW | 1032 | 1041 | ENV2 integrator [I] |
| 3120 | JF/JI | RW | 1031,1043 | 1032,1055 | ENV2 region flag [I] |
| 3136 | JF/JI | RW | 1040 | 1031 | ENV2 prev integrator [I] |
| 3152 | JF/JI | RW | 1033 | 1064 | ENV2 peak target [I] |
| 3168 | JF/JI | RW | 1056 | 1033 | ENV2 prev region flag [I] |
| 3184 | JF | RW | 1061 | 1044 | ENV2 target blend [I] |
| 3200 | JF/JI | RW | 1034 | 1069 | ENV2 rate hold [I] |
| 3216 | JF/JI | RW | 1067,1068 | 1034 | ENV2 prev rate [I] |
| 3232 | JF/JI | RW | 1085,1184,1571 | 1074 | ENV2 OUT raw (amp env; F-ENV lerp target) [R] |
| 3248 | JF | W | -- | 1075 | ENV2 out scaled = [3232]*[3504] -- WRITE-ONLY in voice render [I] |
| 3264 | JF | R | 1054 | -- | "ENV Attack" [REG] |
| 3280 | JF | R | 1053 | -- | "ENV Sustain" [REG] |
| 3296 | JF | R | 1059 | -- | "ENV Decay" [REG] |
| 3312 | JF | R | 1065 | -- | "ENV Release" [REG] |
| 3328 | JF | R | 1044,1045 | -- | "Q24C Initialize" [REG] |
| 3344 | JF | R | 1035 | -- | ENV2 gate threshold offset [I] |
| 3360 | JF | R | 1042 | -- | ENV2 attack region offset [I] |
| 3376 | JF | R | 1040 | -- | ENV2 integrator feedback coeff [I] |
| 3392 | JF | R | 1066 | -- | ENV2 sustain/level input [I] |
| 3408 | JF | R | 1045,1046,1053,1063 | -- | ENV2 peak clamp [I] |
| 3424 | JF | R | 1057 | -- | ENV2 decay target [I] |
| 3440 | JF | R | 1044 | -- | ENV2 target B [I] |
| 3456 | JF | R | 1067 | -- | ENV2 rate smoothing coeff [I] |
| 3472 | JF | R | 1072 | -- | ENV2 out scale A [I] |
| 3488 | JF | R | 1072 | -- | ENV2 out scale B [I] |
| 3504 | JF | R | 1073 | -- | ENV2 aux out scale [I] |

### I. Mod-router taps (KCV, env/bend/pitch latches, feedback sample)  `[3520..3696]` (12 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 3520 | JF/JI | RW | 1076 | 2174 | DCO bank output this sample (written at :2174 from 4928) [I] |
| 3536 | JF/JI | RW | 1144 | 1076 | prev-sample bank output (feedback tap into 6480) [I] |
| 3552 | JI | R | 1077,1087 | -- | bend CV input (0 at rest, juno_apply.c:436) [R] |
| 3568 | JI | W | -- | 1077 | shadow of 3552 [I] |
| 3584 | JF | R | 1081 | -- | gain: pitch CV -> keyboard CV [I] |
| 3600 | JF | R | 1081 | -- | gain: tune/mod CV -> keyboard CV [I] |
| 3616 | JF/JI | RW | 1080 | 1082 | keyboard CV (DCO) = [880]*[3600]+[752]*[3584] [I] |
| 3632 | JI | W | -- | 1080 | shadow of 3616 [I] |
| 3648 | JF/JI | RW | 1109,1120 | 1090 | latched ENV1 out (int copy of 2752) [I] |
| 3664 | JF/JI | RW | 1108,1121 | 1091 | latched ENV2 out (int copy of 3232) [I] |
| 3680 | JF/JI | RW | 1103 | 1087 | latched bend CV (int copy of 3552) [I] |
| 3696 | JF/JI | RW | 1116 | 1088 | latched pitch CV (int copy of 752) [I] |

### J. DCO pitch / PWM mod mixers  `[3712..3824]` (7 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 3712 | JF | RW | 1106 | 1095 | LFO x LFO-Gain product = [4016]*[1808] [I] |
| 3744 | JF | RW | 1116 | 1101 | DCO mod-sens term = ([3984]*[3712])*[4000] [I] |
| 3760 | JF | RW | 1116 | 1104 | DCO bend term = lerp([4112],[3680],[3856])*[4128] [I] |
| 3776 | JF | RW | 1641,1666 | 1108 | DCO TOTAL PITCH-MOD SUM (input to pitch spline + feedback map 5456) [I] |
| 3792 | JF/JI | RW | 1664 | 1115 | latched OSC1 Feet (int copy of 3840; multiplies spline out) [I] |
| 3808 | JF | RW | 1711 | 1117 | PWM MOD SUM (added to Duty Tune -> pulse width 4816) [I] |
| 3824 | JF | W | -- | 1124 | VCF-bound CV sum = [3744]+[3696]+[3760] -- WRITE-ONLY in voice render [I] |

### K. DCO coefficients + level staging  `[3840..4272]` (28 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 3840 | JI | R | 1107 | -- | "OSC1 Feet" [REG]; DCO RANGE feet recall 2^(n-3) (juno_apply.c:624) [R] |
| 3856 | JF | R | 1097 | -- | "Griffer Bend SW" [REG] |
| 3872 | JF | R | 1102 | -- | "Bend Enable SW" [REG] |
| 3888 | JF | R | 1119 | -- | "PWM SW LFO" [REG]; PWM source one-hot: LFO [R] |
| 3904 | JF | R | 1120 | -- | "PWM SW ENV1" [REG]; PWM source one-hot: ENV1 (+/-1) [R] |
| 3920 | JF | R | 1121 | -- | "PWM SW ENV2" [REG]; PWM source one-hot: ENV2 (+/-1) [R] |
| 3936 | JF | R | 1122 | -- | "PWM SW Manual" [REG]; PWM source one-hot: Manual [R] |
| 3952 | JF | R | 1113 | -- | "Tune" [REG] |
| 3968 | JF | R | 1114 | -- | "Detune" [REG]; UNISON per-voice detune spread (juno_apply.c:487-506) [R] |
| 3984 | JF | R | 1092 | -- | "Mod Sens" [REG]; mod depth DCO = c22(MOD SENS DCO) (juno_apply.c:454) [R] |
| 4000 | JF | R | 1100 | -- | "Mod Sw" [REG] |
| 4016 | JF | R | 1089 | -- | "LFO Gain" [REG] |
| 4032 | JF | R | 1098 | -- | "LFO Level" [REG]; DCO LFO MOD recall c0 (BINDINGS) [R] |
| 4048 | JF | R | 1099 | -- | "LFO Sw" [REG] |
| 4064 | JF | R | 1109 | -- | "ENV1 Level" [REG] |
| 4080 | JF | R | 1108 | -- | "ENV2 Level" [REG] |
| 4096 | JF | R | 1110 | -- | "ENV Sw" [REG] |
| 4112 | JF | R | 1096 | -- | "Bend Level" [REG]; live bend amount (0 at centered wheel, juno_apply.c:434) [R] |
| 4128 | JF | R | 1103 | -- | "Bend Range" [REG]; recalled bend-depth DCO product (juno_apply.c:452) [R] |
| 4144 | JF | R | 1123 | -- | "PWM Level" [REG]; DCO PWM DEPTH recall c45 (BINDINGS; registry name 'PWM Level') [R] |
| 4160 | JF | R | 1117 | -- | PWM LFO scale [I] |
| 4176 | JF | R | 1118 | -- | PWM LFO offset [I] |
| 4192 | JI | R | 1126 | -- | "JU OSC Saw Lev" [REG]; DCO SAW LEVEL recall c54 [R] |
| 4208 | JI | R | 1125 | -- | "JU OSC Sqr Lev" [REG]; DCO PWM LEVEL recall c54 (registry 'JU OSC Sqr Lev') [R] |
| 4224 | JI | R | 1128 | -- | "JU OSC Sub Lev" [REG]; DCO SUB LEVEL recall c54 [R] |
| 4240 | JI | RW | 1667 | 1126 | latched saw level [I] |
| 4256 | JI | RW | 1668 | 1127 | latched pulse level [I] |
| 4272 | JI | RW | 1669 | 1128 | latched sub level [I] |

### L. Noise shaping filter (SVF on shared noise)  `[4288..4400]` (8 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 4288 | JF | RW | 1131 | 1139 | noise SVF state 1 [I] |
| 4304 | JF/JI | RW | 1130 | 1132,1134 | noise SVF state 2 [I] |
| 4320 | JF/JI | RW | 1133,1145 | 1130,1140 | noise SVF output (filtered shared noise -> 6496) [I] |
| 4336 | JF | R | 1133,1138 | -- | noise SVF coeff f [I] |
| 4352 | JF | R | 1135 | -- | noise SVF coeff f2 [I] |
| 4368 | JF | R | 1140 | -- | noise SVF tap hp [I] |
| 4384 | JF | R | 1140 | -- | noise SVF tap bp [I] |
| 4400 | JF | R | 1136 | -- | noise SVF tap lp [I] |

### M. DCO frequency (pitch spline)  `[4416..4448]` (2 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 4416 | JF | W | -- | 1665 | DCO FREQUENCY = clamp(spline(4448+3776),+-512)*[3792] [I] |
| 4448 | JF | R | 1641 | -- | fixed DCO tune -4.75 (init; juno_note.c:99 DO NOT write) [R] |

### N. DCO oscillator bank (4 iterations/sample: saw+pulse+sub, BLEP, FIR)  `[4640..5504]` (52 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 4640 | JF/JI | RW | 1759,1805,1863,1909,1967,2013,…(8) | 1732,1836,1940,2044 | DCO master phase (wrap [-1,1)) [I] |
| 4656 | JF | W | -- | 1720,1824,1928,2032 | prev phase [I] |
| 4672 | JF/JI | RW | 1765,1767,1806,1869,1871,1910,…(12) | 1722,1775,1825,1879,1929,1983,…(8) | sub-osc counter (float 0/2, wraps at 4) [I] |
| 4736 | JF/JI | RW | 1822,1926,2030,2132 | 1702 | saw level latch (from 4240) [I] |
| 4752 | JF/JI | RW | 1823,1927,2031,2133 | 1703 | pulse level latch [I] |
| 4768 | JF/JI | RW | 1821,1925,2029,2131 | 1707 | sub level latch [I] |
| 4784 | JF | W | -- | 1710 | phase inc = max([5568],[4416]*[5536]) [I] |
| 4800 | JF | W | -- | 1716 | BLEP scale = 0.00390625/[4784] [I] |
| 4816 | JF | W | -- | 1711 | pulse width = [5520]+[3808] [I] |
| 4832 | JI | RW | 1670 | 2136 | counter history latch [I] |
| 4848 | JI | RW | 1719 | 1670 | counter latch [I] |
| 4864 | JI | RW | 1671 | 2135 | phase history latch [I] |
| 4880 | JF/JI | RW | 1718 | 1671 | phase latch [I] |
| 4896 | JF | W | -- | 1748,1852,1956,2060 | saw sample scratch [I] |
| 4912 | JF | W | -- | 1787,1891,1995,2099 | pulse sample scratch [I] |
| 4928 | JF | W | -- | 2173 | DCO BANK OUTPUT (copied to 3520) [I] |
| 4944 | JF/JI | RW | 1678,2139 | 1807 | bank sample iter-1 [I] |
| 4960 | JF/JI | RW | 1677,2148 | 1678 | DCO iter FIR history A[0] [I] |
| 4976 | JF/JI | RW | 1676,2156 | 1677 | DCO iter FIR history A[1] [I] |
| 4992 | JF/JI | RW | 1675,2162 | 1676 | DCO iter FIR history A[2] [I] |
| 5008 | JF/JI | RW | 1674,2165 | 1675 | DCO iter FIR history A[3] [I] |
| 5024 | JF/JI | RW | 1673,2159 | 1674 | DCO iter FIR history A[4] [I] |
| 5040 | JF/JI | RW | 1672,2154 | 1673 | DCO iter FIR history A[5] [I] |
| 5056 | JF/JI | RW | 2145 | 1672 | DCO iter FIR history A[6] [I] |
| 5072 | JF/JI | RW | 1685,2137 | 1911 | bank sample iter-2 [I] |
| 5088 | JF/JI | RW | 1684,2150 | 1685 | DCO iter FIR history B[0] [I] |
| 5104 | JF/JI | RW | 1683,2157 | 1684 | DCO iter FIR history B[1] [I] |
| 5120 | JF/JI | RW | 1682,2163 | 1683 | DCO iter FIR history B[2] [I] |
| 5136 | JF/JI | RW | 1681,2164 | 1682 | DCO iter FIR history B[3] [I] |
| 5152 | JF/JI | RW | 1680,2158 | 1681 | DCO iter FIR history B[4] [I] |
| 5168 | JF/JI | RW | 1679,2152 | 1680 | DCO iter FIR history B[5] [I] |
| 5184 | JF/JI | RW | 2142 | 1679 | DCO iter FIR history B[6] [I] |
| 5200 | JF/JI | RW | 1692,2141 | 2015 | bank sample iter-3 [I] |
| 5216 | JF/JI | RW | 1691,2152 | 1692 | DCO iter FIR history C[0] [I] |
| 5232 | JF/JI | RW | 1690,2158 | 1691 | DCO iter FIR history C[1] [I] |
| 5248 | JF/JI | RW | 1689,2164 | 1690 | DCO iter FIR history C[2] [I] |
| 5264 | JF/JI | RW | 1688,2163 | 1689 | DCO iter FIR history C[3] [I] |
| 5280 | JF/JI | RW | 1687,2157 | 1688 | DCO iter FIR history C[4] [I] |
| 5296 | JF/JI | RW | 1686,2150 | 1687 | DCO iter FIR history C[5] [I] |
| 5312 | JF/JI | RW | 2137 | 1686 | DCO iter FIR history C[6] [I] |
| 5328 | JF/JI | RW | 1699,2144 | 2117 | bank sample iter-4 [I] |
| 5344 | JF/JI | RW | 1698,2154 | 1699 | DCO iter FIR history D[0] [I] |
| 5360 | JF/JI | RW | 1697,2159 | 1698 | DCO iter FIR history D[1] [I] |
| 5376 | JF/JI | RW | 1696,2165 | 1697 | DCO iter FIR history D[2] [I] |
| 5392 | JF/JI | RW | 1695,2162 | 1696 | DCO iter FIR history D[3] [I] |
| 5408 | JF/JI | RW | 1694,2156 | 1695 | DCO iter FIR history D[4] [I] |
| 5424 | JF/JI | RW | 1693,2147 | 1694 | DCO iter FIR history D[5] [I] |
| 5440 | JF/JI | RW | 2134 | 1693 | DCO iter FIR history D[6] [I] |
| 5456 | JF | RW | 2170 | 1717 | DCO feedback amount = max(0,([3776]+[6304])*[6320]+[6288]) [I] |
| 5472 | JF/JI | RW | 1701 | 2169 | output filter state A [I] |
| 5488 | JF/JI | RW | 1700,2160 | 1701,2166 | output filter state B [I] |
| 5504 | JF/JI | RW | 2161 | 1700 | output filter state C [I] |

### O. DCO bank coefficients  `[5520..6336]` (38 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 5520 | JF | R | 1706 | -- | "Duty Tune" [REG]; CONDITION per-voice PWM/tune trim (juno_apply.c:480) [R] |
| 5536 | JF | R | 1705 | -- | freq->phase-inc scale [I] |
| 5552 | JF | R | 1740,1776,1804,1844,1880,1908,…(12) | -- | shaper drive [I] |
| 5568 | JF | R | 1708 | -- | min phase inc [I] |
| 5584 | JF | R | 1763,1867,1971,2075 | -- | sub gate threshold [I] |
| 5600 | JF | R | 1735,1839,1943,2047 | -- | BLEP gain saw [I] |
| 5616 | JF | R | 1768,1872,1976,2080 | -- | BLEP gain pulse [I] |
| 5632 | JF | R | 1799,1903,2007,2111 | -- | BLEP gain sub [I] |
| 5648 | JF | R | 1733,1837,1941,2045 | -- | wave gain saw [I] |
| 5664 | JF | R | 1760,1864,1968,2072 | -- | wave gain pulse [I] |
| 5680 | JF | R | 1798,1902,2006,2110 | -- | wave gain sub [I] |
| 5696 | JF | R | 2140 | -- | DCO dispersion FIR tap t0 [I] |
| 5712 | JF | R | 2138 | -- | DCO dispersion FIR tap t1 [I] |
| 5728 | JF | R | 2143 | -- | DCO dispersion FIR tap t2 [I] |
| 5744 | JF | R | 2146 | -- | DCO dispersion FIR tap t3 [I] |
| 5760 | JF | R | 2149 | -- | DCO dispersion FIR tap t4 [I] |
| 5776 | JF | R | 2151 | -- | DCO dispersion FIR tap t5 [I] |
| 5792 | JF | R | 2153 | -- | DCO dispersion FIR tap t6 [I] |
| 5808 | JF | R | 2155 | -- | DCO dispersion FIR tap t7 [I] |
| 5824 | JF | R | 2156 | -- | DCO dispersion FIR tap t8 [I] |
| 5840 | JF | R | 2157 | -- | DCO dispersion FIR tap t9 [I] |
| 5856 | JF | R | 2158 | -- | DCO dispersion FIR tap t10 [I] |
| 5872 | JF | R | 2159 | -- | DCO dispersion FIR tap t11 [I] |
| 5888 | JF | R | 2162 | -- | DCO dispersion FIR tap t12 [I] |
| 5904 | JF | R | 2163 | -- | DCO dispersion FIR tap t13 [I] |
| 5920 | JF | R | 2164 | -- | DCO dispersion FIR tap t14 [I] |
| 5936 | JF | R | 2165 | -- | DCO dispersion FIR tap t15 [I] |
| 5952 | JF | R | 1742,1784,1818,1846,1888,1922,…(12) | -- | quintic shaper c3 [I] |
| 5968 | JF | R | 1745,1782,1814,1849,1886,1918,…(12) | -- | quintic shaper c0 [I] |
| 5984 | JF | R | 1745,1781,1813,1849,1885,1917,…(12) | -- | quintic shaper c2 [I] |
| 6000 | JF | R | 1743,1779,1809,1847,1883,1913,…(12) | -- | quintic shaper c0' [I] |
| 6016 | JF | R | 1743,1778,1808,1847,1882,1912,…(12) | -- | quintic shaper c2' [I] |
| 6256 | JF | R | 2161,2169 | -- | output filter coeff a [I] |
| 6272 | JF | R | 2168 | -- | output filter coeff b [I] |
| 6288 | JF | R | 1709 | -- | feedback map offset [I] |
| 6304 | JF | R | 1704 | -- | feedback map pre-offset [I] |
| 6320 | JF | R | 1709 | -- | feedback map scale [I] |
| 6336 | JF | R | 2170,2171 | -- | final mix blend [I] |

### P. Noise / osc-feedback mix into VCF  `[6416..6560]` (10 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 6416 | JI | R | 1141 | -- | noise-mix gain target (init 1.0) [R] |
| 6432 | JF/JI | RW | 1145 | 1141 | prev of 6416 [I] |
| 6448 | JF | R | 1142 | -- | "Osc1 Mute" [REG] |
| 6464 | JF | W | -- | 1143 | prev of 6448 [I] |
| 6480 | JF | W | -- | 1146 | osc-feedback scratch = [6448]*[3536] [I] |
| 6496 | JF | W | -- | 1147 | noise scratch = [6432]*[4320] [I] |
| 6512 | JF | R | 1149 | -- | "Osc1 Level" [REG] |
| 6528 | JF | R | 1149 | -- | "Osc Noise Level" [REG]; DCO NOISE LEVEL recall c54 [R] |
| 6544 | JF/JI | RW | 1148,1298 | 1149 | VCF AUDIO INPUT = [6496]*[6528]+[6480]*[6512] [I] |
| 6560 | JI | W | -- | 1148 | int shadow of 6544 [I] |

### Q. VCF cutoff CV (key follow + cutoff base)  `[6576..6816]` (16 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 6576 | JF/JI | R | 1150,1154 | -- | cutoff key-CV input (smoother-fed) [I] |
| 6592 | JI | W | -- | 1150 | shadow of 6576 [I] |
| 6608 | JI/JU | R | 1151,1207 | -- | cutoff mod input (latched to 7264; blended via 7328) [I] |
| 6624 | JI | W | -- | 1151 | int shadow of 6608 [I] |
| 6640 | JF/JI | R | 1152,1186 | -- | internal env source 'Int' of F-ENV lerp (juno_apply.c:556) [R] |
| 6656 | JI | W | -- | 1152 | shadow of 6640 [I] |
| 6672 | JF/JI | R | 1153,1211 | -- | ext LFO (VCF) input [I] |
| 6688 | JI | W | -- | 1153 | shadow of 6672 [I] |
| 6704 | JF | RW | 1230 | 1169 | FINAL CUTOFF CV = clamp01(poly4(lerp([6736],[6576],[6720]))) [I] |
| 6720 | JF | R | 1154,1155 | -- | "Griffer SW" [REG] |
| 6736 | JF | R | 1155,1156 | -- | "LPF Cutoff" [REG]; VCF CUTOFF FREQ recall c22 (BINDINGS) [R] |
| 6752 | JF | R | 1159 | -- | cutoff CV poly c0 [I] |
| 6768 | JF | R | 1159 | -- | cutoff CV poly c1 [I] |
| 6784 | JF | R | 1160 | -- | cutoff CV poly c2 [I] |
| 6800 | JF | R | 1158 | -- | cutoff CV poly c3 [I] |
| 6816 | JF | R | 1157 | -- | cutoff CV poly c4 [I] |

### R. VCF resonance + velocity smoothing  `[6832..6928]` (7 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 6832 | JI | R | 1170 | -- | "LPF Resonance" [REG]; VCF RESONANCE recall c22 [R] |
| 6848 | JF/JI | RW | 1231,1570 | 1170 | latched resonance (int copy) [I] |
| 6864 | JF | R | 1171 | -- | "Velocity" [REG]; VCF velocity coeff = c56(vel), note-on immediate (juno_note.c:196) [R] |
| 6880 | JF | W | -- | 1172 | prev of 6864 [I] |
| 6896 | JF/JI | RW | 1173,1208 | 1175 | smoothed VCF velocity [I] |
| 6912 | JF | W | -- | 1174 | prev of 6896 [I] |
| 6928 | JF | R | 1175 | -- | velocity smoothing coeff [I] |

### S. VCF modulation matrix  `[6944..7504]` (36 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 6944 | JF | R | 1179 | -- | gain: pitch CV -> VCF KCV [I] |
| 6960 | JF | R | 1179 | -- | gain: tune/mod CV -> VCF KCV [I] |
| 6976 | JF/JI | RW | 1178,1206 | 1179 | VCF keyboard CV = [880]*[6960]+[752]*[6944] [I] |
| 6992 | JI | W | -- | 1178 | int shadow of 6976 [I] |
| 7008 | JI | R | 1180 | -- | "Env1/2" [REG]; F-ENV select lerp ENV1->ENV2 (never recalled; juno_apply.c:540-562) [R] |
| 7024 | JF | R | 1181 | -- | "Int/Env" [REG]; F-ENV Int/Env mix (never recalled) [R] |
| 7040 | JF/JI | RW | 1184,1185 | 1180 | int-latched 7008 [I] |
| 7056 | JF | W | -- | 1182 | copy of 7024 [I] |
| 7072 | JF | RW | 1205 | 1186 | selected filter-env CV = lerp(lerp(ENV1,ENV2,[7040]),[6640],[7024]) [I] |
| 7088 | JF | RW | 1188 | 1193 | LFO-A smoother state (input 1792) [I] |
| 7104 | JF | RW | 1204 | 1189,1194 | LFO-A smoother out [I] |
| 7120 | JF | R | 1191 | -- | LFO-A coeff 1 [I] |
| 7136 | JF | R | 1194 | -- | LFO-A coeff 2 [I] |
| 7152 | JF | R | 1192 | -- | LFO-A gain [I] |
| 7168 | JF | RW | 1195 | 1201 | LFO-B smoother state (input 1808) [I] |
| 7184 | JF | W | -- | 1197,1203 | LFO-B smoother out [I] |
| 7200 | JF | R | 1199 | -- | LFO-B coeff 1 [I] |
| 7216 | JF | R | 1202 | -- | LFO-B coeff 2 [I] |
| 7232 | JF | R | 1200 | -- | LFO-B gain [I] |
| 7248 | JF/JI | RW | 1216 | 1208 | latched smoothed velocity (int copy of 6896) [I] |
| 7264 | JI | W | -- | 1209 | latched 6608 (bit copy) [I] |
| 7280 | JI | W | -- | 1229 | VCF TOTAL CUTOFF-MOD SUM v227 (bit-stored) [I] |
| 7296 | JF | R | 1210 | -- | "LFO Gain" [REG] |
| 7312 | JF | R | 1211,1220,1224 | -- | "Ext LFO Sw" [REG] |
| 7328 | JF | R | 1212,1213 | -- | "GRF Bned SW" [REG] |
| 7344 | JF | R | 1226 | -- | "LFO Level" [REG]; VCF LFO MOD recall c47 (BINDINGS) [R] |
| 7360 | JF | R | 1222 | -- | "MOD Sens" [REG]; mod depth VCF = c22(MOD SENS VCF)*10 (juno_apply.c:455) [R] |
| 7376 | JF | R | 1223 | -- | "MOD SW" [REG] |
| 7392 | JF | R | 1228 | -- | "ENV Level" [REG]; VCF ENV MOD recall c46 (BINDINGS) [R] |
| 7408 | JF | R | 1227 | -- | "KCV Level" [REG]; VCF KEY FOLLOW recall c24 (BINDINGS) [R] |
| 7424 | JF | R | 1218 | -- | "Velocity Sens" [REG]; VCF VEL SENS recall byte/255 (juno_apply.c:681) [R] |
| 7440 | JF | R | 1216 | -- | "Velocity Offset" [REG] |
| 7456 | JF | R | 1213,1214 | -- | "Bend Level" [REG]; live bend amount VCF (0 at rest) [R] |
| 7472 | JF | R | 1215 | -- | "Bend Range" [REG]; recalled bend-depth VCF product (juno_apply.c:453) [R] |
| 7488 | JF | R | 1227 | -- | KCV offset [I] |
| 7504 | JF | R | 1217 | -- | velocity-path scale [I] |

### T. VCF coefficient compute (gated by 7632==1)  `[7520..8192]` (42 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 7520 | JF | RW | 1296 | 1292 | ladder coefficient g/(1+g) (held when [7632]!=1) [I] |
| 7536 | JF | RW | 1299 | 1243 | resonance drive = [6848]*[7792]+[7616] [I] |
| 7552 | JF | RW | 1233 | 1241 | cutoff dither phase (wrap24 of negated prev) [I] |
| 7568 | JF/JI | RW | 1232 | 1234,1239 | dither smoother state [I] |
| 7584 | JF/JI | RW | 1237,1238 | 1232 | prev of 7568 [I] |
| 7600 | JF | R | 1240 | -- | "Cutoff Tune" [REG]; CONDITION per-voice cutoff fine trim (juno_apply.c:481) [R] |
| 7616 | JF | R | 1243 | -- | "Resonance Tune" [REG]; resonance trim (CONDITION family) [R] |
| 7632 | JF | R | 1235 | -- | "PlugIn Sw" [REG]; coeff-update gate; prepare=1.0 (juno_prepare.c:87) [R] |
| 7648 | JF | R | 1247 | -- | gain: cutoff CV [6704] [I] |
| 7664 | JF | R | 1250 | -- | cutoff sum offset [I] |
| 7680 | JF | R | 1246 | -- | gain: mod sum [7280] [I] |
| 7696 | JF | R | 1240 | -- | gain: dither [I] |
| 7712 | JF | R | 1238 | -- | dither smoother coeff [I] |
| 7728 | JF | R | 1242 | -- | res->cutoff comp scale [I] |
| 7744 | JF | R | 1249 | -- | comp clamp [I] |
| 7760 | JF | R | 1251 | -- | cutoff clamp hi [I] |
| 7776 | JF | R | 1252 | -- | cutoff clamp lo [I] |
| 7792 | JF | R | 1243 | -- | res drive scale [I] |
| 7824 | JF | R | 1253 | -- | cutoff->exp scale [I] |
| 7840 | JF | R | 1254 | -- | cutoff->exp offset [I] |
| 7856 | JF | R | 1273 | -- | freq scale (exp out) [I] |
| 7872 | JF | R | 1271 | -- | exp2 frac poly k1 [I] |
| 7888 | JF | R | 1269 | -- | exp2 frac poly k2 [I] |
| 7904 | JF | R | 1268 | -- | exp2 frac poly k3 [I] |
| 7920 | JF | R | 1266 | -- | exp2 frac poly k4 [I] |
| 7936 | JF | R | 1265 | -- | exp2 frac poly k5 [I] |
| 7952 | JF | R | 1263 | -- | exp2 frac poly k6 [I] |
| 7968 | JF | R | 1262 | -- | exp2 frac poly k7 [I] |
| 7984 | JF | R | 1262 | -- | exp2 frac poly k8 [I] |
| 8000 | JF | R | 1262 | -- | exp2 frac poly k9 [I] |
| 8016 | JF | R | 1262 | -- | exp2 frac poly k10 [I] |
| 8032 | JF | R | 1262 | -- | exp2 frac poly k11 [I] |
| 8048 | JF | R | 1289 | -- | tan-map denom c1 [I] |
| 8064 | JF | R | 1281 | -- | tan-map num c1 [I] |
| 8080 | JF | R | 1287 | -- | tan-map denom c2 [I] |
| 8096 | JF | R | 1279 | -- | tan-map num c2 [I] |
| 8112 | JF | R | 1286 | -- | tan-map denom c3 [I] |
| 8128 | JF | R | 1278 | -- | tan-map num c3 [I] |
| 8144 | JF | R | 1284 | -- | tan-map denom c4 [I] |
| 8160 | JF | R | 1276 | -- | tan-map num c4 [I] |
| 8176 | JF | R | 1283 | -- | tan-map denom c5 [I] |
| 8192 | JF* | R | 607,1275 | -- | tan-map num c5 (accessed as *(a1+0x2000), :1275) [I] |

### U. VCF 4-pole ladder core, 3x oversampled (gated by 9056==1)  `[8208..9536]` (84 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 8208 | JF/JI | RW | 1306 | 1466 | ladder stage-1 nl out (iter-3 write) [I] |
| 8224 | JF/JI | RW | 1305,1365 | 1306,1469 | ladder chain s2 [I] |
| 8240 | JF/JI | RW | 1304,1364,1483 | 1305,1474 | ladder chain s3 [I] |
| 8256 | JF/JI | RW | 1303,1367,1486 | 1304,1477 | ladder chain s4 [I] |
| 8272 | JF/JI | RW | 1302,1372 | 1303,1482 | ladder chain s5 [I] |
| 8288 | JF/JI | RW | 1301,1375 | 1302,1484 | ladder chain s6 [I] |
| 8304 | JF/JI | RW | 1300,1351 | 1301,1457 | ladder chain s7 [I] |
| 8320 | JF/JI | RW | 1353 | 1300 | ladder chain s8 (oldest) [I] |
| 8336 | JF | W | -- | 1363,1397,1433 | scratch: nl out (register-promoted _s8336) [I] |
| 8352 | JF | W | -- | 1366,1400,1436 | scratch: stage-1 out [I] |
| 8368 | JF | W | -- | 1371,1405,1441 | scratch: stage-2 out [I] |
| 8384 | JF | W | -- | 1374,1408,1444 | scratch: stage-3 out [I] |
| 8400 | JF | W | -- | 1376,1410,1446 | scratch: stage-4 out [I] |
| 8416 | JF | W | -- | 1354,1387,1423 | scratch: integrator sum [I] |
| 8432 | JF/JI | RW | 1313 | 1488 | dispersion line A input (iter-3 tap mix) [I] |
| 8448 | JF/JI | RW | 1312,1506 | 1313 | VCF disp line A hist[0] [I] |
| 8464 | JF/JI | RW | 1311,1496 | 1312 | VCF disp line A hist[1] [I] |
| 8480 | JF/JI | RW | 1310,1491 | 1311 | VCF disp line A hist[2] [I] |
| 8496 | JF/JI | RW | 1309,1485 | 1310 | VCF disp line A hist[3] [I] |
| 8512 | JF/JI | RW | 1308,1491 | 1309 | VCF disp line A hist[4] [I] |
| 8528 | JF/JI | RW | 1307,1499 | 1308 | VCF disp line A hist[5] [I] |
| 8544 | JF/JI | RW | 1508 | 1307 | VCF disp line A hist[6] [I] |
| 8560 | JF/JI | RW | 1320,1511 | 1454 | dispersion line B input [I] |
| 8576 | JF/JI | RW | 1319,1504 | 1320 | VCF disp line B hist[0] [I] |
| 8592 | JF/JI | RW | 1318,1493 | 1319 | VCF disp line B hist[1] [I] |
| 8608 | JF/JI | RW | 1317,1491 | 1318 | VCF disp line B hist[2] [I] |
| 8624 | JF/JI | RW | 1316,1491 | 1317 | VCF disp line B hist[3] [I] |
| 8640 | JF/JI | RW | 1315,1492 | 1316 | VCF disp line B hist[4] [I] |
| 8656 | JF/JI | RW | 1314,1502 | 1315 | VCF disp line B hist[5] [I] |
| 8672 | JF/JI | RW | 1490 | 1314 | VCF disp line B hist[6] [I] |
| 8688 | JF/JI | RW | 1327,1490 | 1419 | dispersion line C input [I] |
| 8704 | JF/JI | RW | 1326,1501 | 1327 | VCF disp line C hist[0] [I] |
| 8720 | JF/JI | RW | 1325,1492 | 1326 | VCF disp line C hist[1] [I] |
| 8736 | JF/JI | RW | 1324,1491 | 1325 | VCF disp line C hist[2] [I] |
| 8752 | JF/JI | RW | 1323,1491 | 1324 | VCF disp line C hist[3] [I] |
| 8768 | JF/JI | RW | 1322,1493 | 1323 | VCF disp line C hist[4] [I] |
| 8784 | JF/JI | RW | 1321,1504 | 1322 | VCF disp line C hist[5] [I] |
| 8800 | JF/JI | RW | 1511 | 1321 | VCF disp line C hist[6] [I] |
| 8816 | JF/JI | RW | 1334,1508 | 1384 | dispersion line D input [I] |
| 8832 | JF/JI | RW | 1333,1498 | 1334 | VCF disp line D hist[0] [I] |
| 8848 | JF/JI | RW | 1332,1491 | 1333 | VCF disp line D hist[1] [I] |
| 8864 | JF/JI | RW | 1331,1491 | 1332 | VCF disp line D hist[2] [I] |
| 8880 | JF/JI | RW | 1330,1491 | 1331 | VCF disp line D hist[3] [I] |
| 8896 | JF/JI | RW | 1329,1495 | 1330 | VCF disp line D hist[4] [I] |
| 8912 | JF/JI | RW | 1328,1506 | 1329 | VCF disp line D hist[5] [I] |
| 8928 | JF/JI | RW | 1489 | 1328 | VCF disp line D hist[6] [I] |
| 8944 | JF/JI | RW | 1335,1347,1386,1411,1453 | 1343 | VCF input drive = (([7536]*[9168]+1)*([6544]*[9136]))-prevphase*[9120] [I] |
| 8960 | JF/JI | RW | 1348,1383,1418 | 1335 | prev of 8944 [I] |
| 8976 | JF | RW | 1336 | 1342 | VCF dither phase (wrap24 of negated prev) [I] |
| 8992 | JF | W | -- | 1337 | prev of 8976 [I] |
| 9008 | JF | W | -- | 1349 | scratch g*k (register-promoted) [I] |
| 9024 | JF | W | -- | 1346 | scratch 1/(1+g^4*k) [I] |
| 9040 | JF | RW | 1568 | 1514 | VCF OUTPUT (held when [9056]!=1) [I] |
| 9056 | JF | R | 1338 | -- | "PlugIn Sw" [REG]; ladder render gate; prepare=1.0 (juno_prepare.c:88) [R] |
| 9072 | JF | R | 1384,1419,1454,1487 | -- | "-12dB/oct Tap" [REG] |
| 9088 | JF | R | 1382,1417,1452,1486 | -- | "-18dB/oct Tap" [REG] |
| 9104 | JF | R | 1382,1417,1452,1486 | -- | "-24dB/oct Tap" [REG] |
| 9120 | JF | R | 1341 | -- | dither->input gain [I] |
| 9136 | JF | R | 1340 | -- | input drive gain [I] |
| 9152 | JF | R | 1513 | -- | VCF output gain [I] |
| 9168 | JF | R | 1340 | -- | res feedback into input stage [I] |
| 9184 | JF | R | 1362,1395,1431,1465 | -- | quintic nonlinearity coeff (x^5 term) [I] |
| 9200 | JF | R | 1456 | -- | iter-3 input gain [I] |
| 9216 | JF | R | 1350,1421 | -- | input interp gain A [I] |
| 9232 | JF | R | 1352,1421 | -- | input interp gain B [I] |
| 9248 | JF | R | 1386 | -- | iter-2 input gain [I] |
| 9264 | JF | R | 1489 | -- | VCF output FIR tap t0 [I] |
| 9280 | JF | R | 1511 | -- | VCF output FIR tap t1 [I] |
| 9296 | JF | R | 1490 | -- | VCF output FIR tap t2 [I] |
| 9312 | JF | R | 1509 | -- | VCF output FIR tap t3 [I] |
| 9328 | JF | R | 1507 | -- | VCF output FIR tap t4 [I] |
| 9344 | JF | R | 1505 | -- | VCF output FIR tap t5 [I] |
| 9360 | JF | R | 1503 | -- | VCF output FIR tap t6 [I] |
| 9376 | JF | R | 1500 | -- | VCF output FIR tap t7 [I] |
| 9392 | JF | R | 1497 | -- | VCF output FIR tap t8 [I] |
| 9408 | JF | R | 1494 | -- | VCF output FIR tap t9 [I] |
| 9424 | JF | R | 1492 | -- | VCF output FIR tap t10 [I] |
| 9440 | JF | R | 1491 | -- | VCF output FIR tap t11 [I] |
| 9456 | JF | R | 1491 | -- | VCF output FIR tap t12 [I] |
| 9472 | JF | R | 1491 | -- | VCF output FIR tap t13 [I] |
| 9488 | JF | R | 1491 | -- | VCF output FIR tap t14 [I] |
| 9504 | JF | R | 1491 | -- | VCF output FIR tap t15 [I] |
| 9520 | JF | R | 1356,1389,1425,1459 | -- | feedback tap (newest stage sum) [I] |
| 9536 | JF | R | 1356,1389,1425,1459 | -- | feedback tap (older) [I] |

### V. VCA source select + tone inputs  `[9552..9664]` (8 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 9552 | JI | R | 1516,1572 | -- | ext env input (VCA) [I] |
| 9568 | JI | W | -- | 1516 | int shadow of 9552 [I] |
| 9584 | JI | R | 1518 | -- | "AMP TONE" [REG]; VCA TONE recall c24 (BINDINGS) [R] |
| 9600 | JI | R | 1517 | -- | "AMP VELOCITY SENS" [REG]; VCA VEL SENS recall byte/255 (juno_apply.c:682) [R] |
| 9616 | JI | R | 1520 | -- | "AMP FIX VELOCITY LEVEL" [REG]; fixed-velocity level [R] |
| 9632 | JF/JI | RW | 1614 | 1518 | latched AMP TONE (int copy) [I] |
| 9648 | JF/JI | RW | 1527 | 1519 | latched vel sens [I] |
| 9664 | JF/JI | RW | 1527,1528 | 1520 | latched fixed-vel level [I] |

### W. VCA velocity smoother  `[9680..9808]` (9 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 9680 | JF | R | 1521 | -- | "Velocity" [REG]; VCA velocity coeff = c57(vel), note-on immediate (juno_note.c:197) [R] |
| 9696 | JF | W | -- | 1522 | prev of 9680 [I] |
| 9712 | JF | RW | 1523 | 1526 | velocity smoother state [I] |
| 9728 | JF | W | -- | 1524 | prev of 9712 [I] |
| 9744 | JF | R | 1525 | -- | velocity smoothing coeff [I] |
| 9760 | JF | W | -- | 1529 | velocity level after sens/fixed lerp [I] |
| 9776 | JF | RW | 1530,1638 | 1538 | VCA velocity gain (clamped >=0) [I] |
| 9792 | JF | W | -- | 1531 | prev of 9776 [I] |
| 9808 | JF | R | 1532 | -- | velocity gain smoothing coeff [I] |

### X. VCA mute smoother  `[9824..9888]` (5 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 9824 | JF | R | 1539 | -- | "Mute" [REG]; Mute/gate twin (juno_note.c:201,306; 0 kills output) [R] |
| 9840 | JF | W | -- | 1540 | prev of 9824 [I] |
| 9856 | JF | RW | 1541,1640 | 1549 | smoothed mute gain (final output multiplier) [I] |
| 9872 | JF | W | -- | 1542 | prev of 9856 [I] |
| 9888 | JF | R | 1543 | -- | mute smoothing coeff [I] |

### Y. VCA gate ramp  `[9904..10032]` (9 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 9904 | JF | RW | 1550 | 1567 | gate ramp state [I] |
| 9920 | JF | W | -- | 1552 | prev of 9904 [I] |
| 9936 | JF | RW | 1582 | 1566 | gate ramp out (VCA 'Gate' source) [I] |
| 9952 | JF | R | 1559 | -- | ramp threshold offset [I] |
| 9968 | JF | R | 1560 | -- | ramp attack coeff [I] |
| 9984 | JF | R | 1554 | -- | ramp alt offset [I] |
| 10000 | JF | R | 1553 | -- | ramp region scale [I] |
| 10016 | JF | R | 1561 | -- | release coeff A [I] |
| 10032 | JF | R | 1561,1562 | -- | release coeff B [I] |

### Z. VCA env combine + HPF/boost + output stage  `[10048..10464]` (27 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 10048 | JF/JI | RW | 1587,1588 | 1575 | latched ENV2 out (int copy of 3232) [I] |
| 10064 | JF/JI | RW | 1586 | 1576 | latched ext env (int copy of 9552) [I] |
| 10080 | JF | RW | 1599 | 1579 | res-comp term = [6848]*[10336] [I] |
| 10096 | JF/JI | RW | 1573 | 1584 | HPF 1-pole LP state [I] |
| 10112 | JF/JI | RW | 1577 | 1573 | prev of 10096 [I] |
| 10128 | JF/JI | RW | 1574 | 1603 | post-HPF smoother state [I] |
| 10144 | JF/JI | RW | 1601,1602 | 1574 | prev of 10128 [I] |
| 10160 | JF | W | -- | 1605 | final VCA-scaled sample (pre DC-block; WRITE-ONLY here) [I] |
| 10176 | JF | R | 1578 | -- | "Gate SW" [REG]; VCA MODE: Gate SW (juno_apply.c:410-421) [R] |
| 10192 | JF | R | 1582 | -- | "ENV1 SW" [REG]; VCA MODE: ENV1 SW [R] |
| 10208 | JF | R | 1581 | -- | "ENV2 SW" [REG]; VCA MODE: ENV2 SW [R] |
| 10224 | JF | R | 1586,1587 | -- | "Ext ENV SW" [REG]; VCA MODE: Ext ENV SW [R] |
| 10240 | JF | R | 1583 | -- | "HPF Cutoff" [REG]; HPF CUTOFF recall (SR-variant c39/40/41); used as 1-pole LP coeff [R] |
| 10256 | JF | R | 1589 | -- | "HPF Switch" [REG]; HPF Switch (crossfade recall, 2nd HPF coeff) [R] |
| 10272 | JF | R | 1596 | -- | "Boost LPF Level" [REG]; Boost LPF Level (3rd HPF coeff) [R] |
| 10288 | JF | R | 1600 | -- | "Boost Thru Level" [REG]; Boost Thru Level (4th HPF coeff, bipolar) [R] |
| 10304 | JF | R | 1590 | -- | "ENV LEVEL" [REG] |
| 10320 | JF | R | 1598 | -- | "AMP LEVEL" [REG]; AMP LEVEL -- CONDITION per-voice re-level (juno_apply.c:482) [R] |
| 10336 | JF | R | 1579 | -- | res-comp gain coeff [I] |
| 10352 | JF | R | 1585 | -- | boost path tap (hp) [I] |
| 10368 | JF | R | 1585 | -- | boost path tap (lp) [I] |
| 10384 | JF | R | 1602 | -- | post-HPF smoother coeff [I] |
| 10400 | JF | R | 1604 | -- | voice output gain [I] |
| 10416 | JF/JI | RW | 1607,1613 | 1611 | DC-block out = in - LP [I] |
| 10432 | JF/JI | RW | 1606 | 1607,1612 | DC-block LP state [I] |
| 10448 | JF/JI | RW | 1608 | 1606 | prev of 10432 [I] |
| 10464 | JF | R | 1609 | -- | DC-block coeff [I] |

### AA. Amp tone filter + final gains  `[10480..10656]` (12 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 10480 | JF/JI | RW | 1617 | 1618 | tone filter input [I] |
| 10496 | JF/JI | RW | 1616,1619,1621 | 1617,1627 | tone filter A out (bright) [I] |
| 10512 | JF/JI | RW | 1615,1620 | 1616,1629 | tone filter B out (dark) [I] |
| 10528 | JF/JI | RW | 1622 | 1615 | prev of 10512 [I] |
| 10544 | JF | W | -- | 1637 | tone-selected sample (sign of [9632] picks A/B) [I] |
| 10560 | JF | R | 1619 | -- | tone A b0 [I] |
| 10576 | JF | R | 1619 | -- | tone A b1 [I] |
| 10592 | JF | R | 1620 | -- | tone A b2 [I] |
| 10608 | JF | R | 1621 | -- | tone B b0 [I] |
| 10624 | JF | R | 1621 | -- | tone B b1 [I] |
| 10640 | JF | R | 1622 | -- | tone B b2 [I] |
| 10656 | JF | W | -- | 1639 | sample x velocity gain [9776] [I] |

### AB. Voice output  `[10672..10672]` (1 cells)

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 10672 | JF/JU | RW | 2180,2181,2182 | 1640 | VOICE OUTPUT = [10656]*[9856]; returned as bits, written to L and R [I] |

### SH. Shared noise generator (base-relative, `[84272..84432]`, 164 bytes end 84436)

Advanced ONCE PER VOICE per sample (`:595-653`) — 8 advances per engine sample,
chained in voice order. The port's snapshot/restore policy is proven equivalent
to 9 isolated units (docs/RENDER_LOOP_LOG.md); the block is closed and
autonomous, and `master_render.c` reads none of [84272,84436).

| offset | acc | R/W | read @ | written @ | name / role |
|---|---|---|---|---|---|
| 84272 | JF | R | 596 | -- | noise input A (never written here; source of ext-noise arm) [I] |
| 84288 | JF | W | -- | 599 | shadow of 84272 [I] |
| 84304 | JF | R | 597 | -- | "Ext Noise Sw" [REG]; Ext Noise Sw (blend ext vs internal) [R] |
| 84320 | JF | W | -- | 600 | shadow of 84304 [I] |
| 84336 | JF | RW | 595 | 643 | noise core phase (inline wrap24 chaotic map) [I] |
| 84352 | JF | W | -- | 598 | shadow of 84336 [I] |
| 84368 | JF/JI | RW | 637 | 645 | filtered noise = wrapped*[84400]+[84416] [I] |
| 84384 | JI | W | -- | 637 | int shadow of 84368 [I] |
| 84400 | JF | R | 644 | -- | noise gain (init juno_init.c:2870) [R] |
| 84416 | JF | R | 644 | -- | noise offset (init 0) [R] |
| 84432 | JF/JI | RW | 808,1129 | 653 | SHARED NOISE OUTPUT (consumed at :814 S&H latch, :1129/:1137 noise SVF) [I] |
| 101504+v*32 (`auxoff`) | JF/JI | RW | 589,2175 | 2178 | DCO retrigger one-shot latch 'Array A' (juno_note.c:56-69): armed by note-off / MONO retrig; consumed head `:589-594` (saves+zeroes gate 320), cleared tail `:2175-2179` (restores 320). Array B at 101520+v*32 is NOT touched by the render (DSP-inert note-on marker). |


## 2. Per-sample dataflow — equations with line cites

All arithmetic is single-precision f32 (`-ffp-contract=off` is load-bearing),
EXCEPT the pitch spline (:1641-1663), which accumulates in `double` over
`double` coefficients — see §3 and §5 item 8. `[N]` = float cell at a1+N,
`[[N]]` = int bit-copy. `'` marks the value written this sample. The transcribed
code is the spec; these equations are the map, not a substitute.

**Association discipline (READ, and load-bearing for a −90 dB null):**
`lerp(a,b,t)` here is shorthand for the source's OWN distributed form
`(t*b − t*a) + a` (a few sites spell it `a + (t*b − t*a)`; identical, since
IEEE `+` and `*` are commutative). It is NEVER `a + t*(b−a)` — that rounds
`b−a` first and does not null. Every other equation below is given in the
source's parenthesization; where a line is deliberately normalized instead
(e.g. a `Σ` or a `poly11(...)` gloss), the transcription in
`src/voice_render.c` at the cited lines is the authority. Lines tagged
"exact association" have been re-derived character-for-character.

**Evaluation order inside one voice-sample (structural, critical):**
retrig-latch head → shared noise advance → input conditioning → gate → glide →
LFO → ENV1 → ENV2 → mod router → DCO mod mixers → noise SVF → VCF input mix →
cutoff CV → VCF coeff (gated) → VCF ladder (gated) → VCA → **output written**
(:1640) → pitch spline → **DCO bank** (:1666-2174) → latch tail. The DCO bank
output `4928 → 3520` is written AFTER the output, and the VCF consumed
`3536 = prev-sample 3520` (:1076) — i.e. **the DCO reaches the VCF with exactly
one sample of latency**. A native rewrite must preserve this or it will not null.

### Retrig latch (head :587-594, tail :2175-2179)
If `base[auxoff]==1.0`: save `v528=[[320]]`, force gate `v2=0`, `[320]=0`
(:589-594). At tail: restore `[320]=v528`, clear `base[auxoff]=0` (:2175-2179).
One-sample gate mask that re-phases the DCO (juno_note.c:56-69).

### SH. Shared noise (:595-653, once per voice, chained 0..7)
Shadows: `[84352]=[84336], [84288]=[84272], [84320]=[84304]` (:598-600);
`[[84384]]=[[84368]]` (:637). Inline wrap24 (same algorithm as
`juno_wrap24`, juno_dsp.c:20-45) applied to `-[84336]` via the folded
`* -16777216.0` (:601-622,625-643): `[84336]' = wrap24(-[84336])`.
`[84368]' = [84336]'*[84400] + [84416]` (:644-645).
`[84432]' = [84272]*[84304] - [84304]*[84368]' + [84368]'`
`         = lerp([84368]', [84272], [84304])` (:630,646-653) — Ext Noise Sw
selects external noise vs the internal chaotic map.

### A. Input conditioner (:623-660)
`v26 = [272]*[240]` → `[448]` (:647-656); at rest v26==0 (juno_note.c:27).
`[464]' = ([176]*v26 - v26*[304]) + [304]` (pitch; :624,654,657,659)
`[480]' = ([208]*v26 - gate*v26) + gate` (gate; :623,658,660)
Shadows 192/224/256/288/336/352/400/416 updated; `[[432]]=0` (:631).

### B. Gate binarizer (:661-693)
`v31 = [480]' + [544]`; `v34 = ([480]'==0) ? -1 : min(v31,0)` (:661-672, also
stored to `[496]`), then sign-clamped to {-1,0,1}; `[528]=[560]'=v34+1` ∈
{0,1,2} (:673-691). `[[576]] = old [[560]]` (:686,692). `[560]` is THE binary
gate consumed by ENV1 (:973), ENV2 (:1028) and the VCA gate ramp (:1551).

### C. Portamento / glide (:682-735)
`v45 = ((([560]'*[608]) - [608]) + 1) * [592]` → `[736]` (glide enable;
:682,694-699). Rate: `v46 = ([672]/([768]*[624]+[800]))*[768]` (:697);
`[656]' = (([656]-v46) + [464]') - [704]` (:698-703);
`[672]' = [656]'*([624]+[784])` (:685-705).
Arrival: if `[816] - |[704]-[464]'| < 0` → `[688]'=0`, else
`[688]' = min([688]+[832], 1)` (:707-720).
`[704]' = [752]' = (v45==0) ? [464]' : lerp([672]'+[704], [464]', [688]')`
(:721-735). `[752]` is the per-sample FINAL PITCH CV.

### D. Mod CV + LFO rate (:724-819)
`[880]' = [384]*[864] + [368]*[848]` (:724-732).
Rate mod: `v59 = [912] * exptab(int([1168])) * exptab(int(-[1168]))` where
exptab = `juno_exp_ad3c[e]` (e>0), `juno_exp_acc0[~e]` (e<0), `2^-32` under
-32, clamp 32 (:727-782). `[1104]' = (v59-[1104])*[1152] + [1104]` (:783-786).
`v70 = lerp([1088], [1104]', [1040])`, clamp [0,1] (:787-796).
`[1136]' = lerp(expf(v70*[1200])*[1184] + [1216], [1072], [1056])`
(:797-819) — TEMPO SYNC `[1056]==1` substitutes the host-BPM coeff `[1072]`
verbatim (juno_apply.c:793-816).

### F. LFO oscillator (:800-966)
Latches: `[[1584]]=[[1568]], [[1616]]=[[1600]], [[1648]]=[[1632]]`,
`[[1440]]=[[976]], [[1456]]=[[1008]], [[1424]]=[[base 84432]]` (:800-814).
Ext gate: `[1488]' = clamp([944]*[1904] + [1856], -1, 1)` (:816-825);
`[1840]=[1856]` (:818).
Phase inc: `[1664]' = min([2128], [1136]'*2^-16) * [2144]` (:826-834).
Delay ramp: `v89 = (1-[1504prev])*[1920] + [1504prev]`, clamp [-1,1]; on a
**RISING** ext-gate edge (`v92 = [1488prev] - [1488]' < 0`, i.e. the new gate
EXCEEDS the previous one — musically the note-on reset, when any-key-held
[1856] drives [1488] 0→1) force 0 → `[1504]'` (:809-840).
`[1488prev]` is the value loaded at :805, i.e. LAST sample's [1488]; it is
also what :810 shifts into [1504] before :840 overwrites [1504] with `v90`.
So the compare operand is **not** `[1504]'` (= v90) — see the Phase line.
Level: `[1472]' = max(0, ([1504]'+[2272])*[2256])` (:841-853).
Noise smoother: `[1568]' = ([1424]-[1584])*[2464] + [1584]` (:851-852);
`[1408]' = (lerp([1424], [1568]'*[2448], [2064]))*[2432]` (:855-870).
Phase: `v93 = [1664]' + [1536]`; `v94 = (v92 < 0) ? [1872] : 1` where `v92` is
the SAME rising-edge difference as the delay ramp above, `[1488prev] - [1488]'`
(:833, tested :836/:842) — **not** `[1504]' - [1488]'`. Getting this wrong
multiplies the phase by [1872] on every sample while the gate is high instead
of once at the edge. `[1536]' = wrap±1((v93*v94)*[1888])` (:835-868;
prepare sets [1888]=1.0).
S&H: if `[1552old]<0 && phase'>0` → `[1600]'=[1424]` else hold (:871-882);
`[1760]' = [1600]'*[2416]` (:883-886).
Waves (each phase wrapped to [-1,1) by ±1/fmod2):
`[1680]' = wrap(ph+[2288])*[2352] + [2480]`, `[1696]' = -[1680]'` (:869-887);
`[1728]' = juno_triangle(ph+[2320])*[2384]` (:887-928, arg resolved per
docs/VOICE_RENDER_MAP.md:59); `[1824]' = sign(wrap(ph+[2304])+[2496])`,
`[1712]' = [1824]'*[2368] + [2512]` (:905-941);
sine: `u = |wrap(ph+[2336])|` (:927-940),
```
[1744]' = ( ( (u*((u*u)*u))*[2224]
            + ( ((u*u)*u)*[2208]
              + ( (u*[2176] + [2160]) + ((u*u)*[2192]) ) ) )
          + [2240] ) * [2400]
```
(exact association, :946-951). The nesting is NOT a flat descending-power
sum: the CONSTANT and LINEAR terms are added first, then the quadratic, then
the cubic, then the quartic, then [2240], then the scale. Writing it as
`u^4*c4 + u^3*c3 + … + c0` rounds differently and will not null.
Mix: `[1776]' = ([1936]*[1472]'-[1936])+1` (:955-959);
`[1808]' = [1968]*[1728]' + [2032]*[1760]' + [2000]*[1680]' + [2016]*[1696]'
+ [1984]*[1712]' + [1744]'*[1952] + [2048]*[1408]'` (:943-960);
`[1792]' = [2096]*[1440] + [2112]*[1456] + [2080]*[1776]'*[1808]'` (:961-963).
Bit-latches `[[2528]]=[[1824]]', [[2544]]=[[1808]]'` (:964-966).

### G/H. ENV1 (:967-1021) and ENV2 (:1022-1075) — identical, +480 offsets
Given for ENV1; ENV2 substitutes each cell +480.
Trigger: `v123 = ([1824]>0) ? 1 : 0`, forced 1 if `[2560]==0`;
`[2576]' = [560]*v123` (:967-974).
Shifts: `2608←2592, 2656←2640, 2640←2624, 2688←2672, 2736←2720` (:975-979).
`v125 = ([2576]'+[2864] >= 0) ? 0 : 1` (release flag; :980-983).
`[2624]' = (1-v125) * ([2896]*[2656]' + [2608])` (:985-986).
`[2704]' = lerp([2928], [2848]*[2960], [2848])` exact form
`([2848]*[2960] - [2928]*[2848]) + [2928]` (:989-991).
Region: `v130 = ([2624]'+[2880] < 0) ? 0 : 1`; overridden to `1-v125` when
`[2624]' - [2640old] < 0` → `[2640]'` (:987-1000).
Target: `v134 = (1-v125)*([2800]*[2928]) - [2944]*(1-v125) + [2944]`; if
`v134-[2688]' > 0` → `v134 = [2688]' + [2704]'`; `[2672]' = min([2928], v134)`
(:998-1009).
Attack mask: `v135 = v126 * (1-v130)` where `v126 = 1-v125` (:1003) — i.e.
`v135 = (1-v125)*(1-v130)`, nonzero ONLY when not released and not in the
v130 region.
Rate: `v136 = ([2816]*(1/256))*v130 + ([2784]*(1/256))*v135` (:1004);
`[2720]' = lerp([2736]', v136, [2976])` (:1012-1014).
Accum: `v140 = (v135*[2912] + v130*[2672]') - [2608]` (:1011).
**The `(1-v130)` factor carried inside `v135` is load-bearing and must not be
dropped:** wherever `v130 == 1` (the decay/sustain region) it zeroes the
`[2912]` term outright, so an ADSR written as `(1-v125)*[2912] + v130*[2672]'`
diverges on every note in that region. ENV2 mirrors this exactly —
`v157 = v148*(1-v152)` (:1058), consumed at :1066.
`[2592]' = ((([2832]*(1/256))*v125 - v125*[2720]') + [2720]')*v140 + [2608]`
(:1015-1017).
Outputs: `[2752]' = ([2592]'*[2992])*[3008]`, `[2768]' = [2752]'*[3024]`
(:1018-1021). (ENV1 A/D/S/R coeffs 2784/2816/2800/2832 are the recall rows,
juno_apply.c:177-189; the exact branch structure :980-1017 is the spec — the
labels here are INFERRED.)

### I/J. Mod router + DCO mixers (:1076-1128)
`[[3536]]=[[3520]]` (prev-sample DCO out), `[[3568]]=[[3552]]`,
`[[3632]]=[[3616]]` (:1076-1080).
`[3616]' = [880]'*[3600] + [752]'*[3584]` (keyboard CV; :1081-1082).
Latches: `[[3680]]=[[3552]], [[3696]]=[[752]], [[3648]]=[[2752]]',
[[3664]]=[[3232]]'` (:1084-1091).
`[3712]' = [4016]*[1808]'` (:1093-1095).
`[3744]' = ([3984]*[3712]')*[4000]` (:1100-1101).
`[3760]' = (([3856]*[3680] - [4112]*[3856]) + [4112])*[4128]` (:1102-1104).
`[3776]' = ((([4080]*[3664] + [4064]*[3648])*[4096])
           + ([4048]*(([4016]*[1792]')*[4032]) + [3744]' + [3872]*[3760]')
           + [3616]') + [3952] + [3968]` (:1105-1114).
`[[3792]]=[[3840]]` (:1107,1115).
`[3808]' = (([3712]'*[4160] + [4176])*[3888] + [3904]*[3648] + [3920]*[3664]
           + [3936])*[4144]` (:1116-1123).
`[3824]' = [3744]' + [3696] + [3760]'` (:1116,1124; write-only in this file).
Level staging: `[[4240]]=[[4192]], [[4256]]=[[4208]], [[4272]]=[[4224]]`
(:1125-1128).

### L. Noise SVF (:1129-1140)
Input `n = base[84432]'`. `[[4320]]=[[4304]]`; `[4304]' = [4288]*[4336] +
[4320]`; `y = [4288]*[4352] + [4304]'`; `e = n - y`;
`[4288]' = e*[4336] + [4288]`;
`[4320]' = (e*[4368] + ([4304]'*[4400])) + [4288]'*[4384]` (:1129-1140).

### P/Q/R. VCF input + cutoff CV (:1141-1175)
`[6480]' = [6448]*[3536]` (prev-sample osc), `[6496]' = [6432]*[4320]'`
(:1141-1147); `[6544]' = [6496]'*[6528] + [6480]'*[6512]` (:1148-1149).
Shifts 6592/6624/6656/6688 (:1150-1153).
`v200 = ([6720]*[6576] - [6736]*[6720]) + [6736]` = lerp(cutoff, keyCV, sw);
`[6704]' = clamp01(v200^4*[6816] + v200^3*[6800] + v200^2*[6784] +
v200*[6768] + [6752])` (:1154-1169).
`[[6848]]=[[6832]]` (:1170); velocity smoother
`[6896]' = ([6864]-[6896])*[6928] + [6896]` (:1171-1175).

### S. VCF mod matrix (:1176-1229)
`[6976]' = [880]'*[6960] + [752]'*[6944]` (:1176-1179).
F-ENV select: `[[7040]]=[[7008]]`; `v210 = [2752]' + [7040]*([3232]'-[2752]')`;
`[7072]' = ([7024]*([6640]-v210)) + v210` (:1180-1186; juno_apply.c:540-562 —
never recalled, both 0 → pure ENV1).
LFO smoothers: `[7088]' = ([1792]'-[7088])*[7120] + [7088]`;
`[7104]' = ([1792]'-[7088])*[7136] + [7152]*[7088]'` (:1187-1194); same for
input `[1808]'` via 7168/7200/7216/7232 → `[7184]'` (:1195-1203).
Cutoff-mod sum (:1207-1229):
`[7280]'v227 = (([6608]*[7328] - [7456]*[7328]) + [7456])*[7472]
 + (([7440]+[7248])*[7504])*[7424]
 + lerp([7184]'*[7296], [6672]*[7312]-path)*[7360]*[7376]   ; exact :1219-1226
 + lerp([7104]'*[7296], ...)*[7344]
 + ([6976]'+[7488])*[7408] + [7072]'*[7392]`
(the two lerp terms share `v226=[7312]*[6672]`; transcribed form is the spec).

### T. VCF coefficient compute (:1230-1297, only when `[7632]==1.0`)
`[7568]' = [7584] + [7712]*([7552]-[7584])`; `v232 = [7568]'*[7696]+[7600]`;
`[7552]' = juno_wrap24(-[7552])` (:1237-1241, dither osc).
`[7536]' = [6848]*[7792] + [7616]` (res drive; :1242-1243).
`c = clamp(v227*[7680] + [6704]'*[7648] + v232 + min([7744],
(1-[6848])*[7728]) + [7664], ≤[7760], ≥[7776]) * [7824] + [7840]` (:1244-1254).
Split `i = floor(c)` (int-indefinite guard 0x80000000 :1257), `f = c-i`,
`q = f²*0.25`;
`E = expf(i) * (poly11(f,q; [7872..8032]) + 1)` (:1255-1273);
`t = E*[7856]`; `v240 = rational(t; num [8064,8096,8128,8160,8192*], den
[8048,8080,8112,8144,8176])` (:1274-1290; `8192` accessed as `*(a1+0x2000)`
:1275); `[7520]' = v240/(v240+1)` (:1291-1292). Else `[7520]` held (:1294-1297).

### U. VCF ladder, 4 sub-steps (:1298-1515, only when `[9056]==1.0`)
Shifts: three 8-deep dispersion lines + input chain (:1300-1335).
Input: `[8944]' = (([7536]'*[9168]+1)*([6544]'*[9136])) - [8976]*[9120]`;
`[8976]' = juno_wrap24(-[8976])` (:1336-1343).
`g = [7520]'`; `G = 1-2g`; `[9024]' = 1/(g⁴*[7536]'+1)`;
`[9008]' = [9024]'*[7536]'` (:1344-1349).
Per sub-step k=1..4, input interpolation (:1350,1386,1421,1456):
k1 `[8960]*[9216]+[8944]'*[9232]`, k2 `([8960]+[8944]')*[9248]`,
k3 `[8960]*[9232]+[8944]'*[9216]`, k4 `[8944]'*[9200]`.
`x = in*[9024]' - (fb_new*[9520] + fb_old*[9536])*[9008]'`; clamp [-1,1];
`nl = x + x⁵*[9184]` (:1355-1362 form `x + (((x*x)*x)*x)*(x*[9184])`);
4 cascaded one-poles with coefficient g and G (exact association :1365-1381);
per-step tap out `= s3*[9088] + s4*[9104] + s2*[9072]` written to dispersion
line heads `8816, 8688, 8560` (k1..k3; :1384,1419,1454); k4 stores the stage
states to `8208..8320` and line-A head `8432` (:1466-1488).
Output: `[9040]' = (Σ_{t=0..15} (pair_t) * [9264+16t] ) * [9152]`
(:1489-1514, 16 symmetric tap-pairs over the 4 lines). Else all held.

### V..AA. VCA + output (:1516-1640)
Latches `[[9568]]=[[9552]], [[9632]]=[[9584]], [[9648]]=[[9600]],
[[9664]]=[[9616]]` (:1516-1520).
Velocity: `[9712]' = ([9680]-[9712])*[9744] + [9712]`;
`[9760]' = lerp([9664], [9712]', [9648])` (:1521-1529);
`[9776]' = max(0, [9808]*[9760]' + (1-[9808])*[9776])` (:1530-1538).
Mute: `[9856]' = max(0, [9888]*[9824] - [9888]*[9856] + [9856])` (:1539-1549).
Gate ramp (:1550-1567): with `gt=[560]'`:
if `gt!=0`: `[9904]' = ([9904]+[9952]>=0) ? lerp([9904], gt, [9968])
                                          : [9904]+[9984]`;
else `[9904]' = lerp([9904], gt, lerp([10032], [10016],
clamp([9904]*[10000], -1, 1)))`; `[9936]'=[9904]'`.
Env combine (:1568-1605): `[[10048]]=[[3232]]', [[10064]]=[[9552]]`;
`[10080]' = [6848]*[10336]`;
`hp_lp: [10096]' = [10112] + ([9040]'-[10112])*[10240]` (HPF as 1-pole LP);
`boost = ([9040]'-[10112])*[10352] + [10096]'*[10368]`;
`env = lerp(([2752]'*[10192] + [10176]*[9936]') + [10208]*[10048],
[10064], [10224])`;
`lvl = max(0, env*[10304]) * [10320]`;
`y = lerp([9040]', boost, [10256]) * ([10080]'+1)`;
`[10128]' = [10144] + [10384]*(y-[10144])`;
`[10160]' = (([10272]*[10128]' + [10288]*y)*lvl)*[10400]`.
DC block (:1606-1612): `[10416]' = v371-[10448]`;
`[10432]' = [10464]*[10416]' + [10448]`.
Tone (:1613-1637): 3-tap FIRs A/B over `10480/10496/10512/10528` history with
coeffs `10560..10592` / `10608..10640`; `[10544]' = tone>=0 ?
lerp([10416]', A, tone) : lerp([10416]', B, -tone)`, `tone=[9632]`.
Output: `[10656]' = [10544]'*[9776]'`; `[10672]' = [10656]'*[9856]'`
(:1638-1640); returned as bits and copied to `*outL/*outR` (:2180-2183).

### M/N. Pitch spline + DCO bank (:1641-2174) — runs AFTER the output write
`p = clamp([4448] + [3776]', -20, 8.9)`;
`[4416]' = clamp(poly13(juno_pitch_table[(int)(p+20)], p), ±512) * [3792]`
(:1641-1665; 13 even-index doubles per row — same law as juno_pitch_poly,
juno_dsp.c:77-98, but f32-stored).
Setup (:1666-1722): shift the four 8-deep FIR histories + `5488/5472/5504`
chain; `[[4736]]=[[4240]], [[4752]]=[[4256]], [[4768]]=[[4272]]`;
`[5456]' = max(0, ([3776]'+[6304])*[6320] + [6288])`;
`[4784]' = max([5568], [4416]'*[5536])`; `[4800]' = 0.00390625/[4784]'`;
`[4816]' = [5520] + [3808]'`.
Four iterations (i=1..4; :1720-2133), each:
- `ph' = wrap±1(ph + [4784]')` → `[4640]` (:1723-1732 etc.)
- saw: `t = juno_triangle((ph'+1)*0.5)` (Pattern A);
  `b = clamp((t*256)*[4800]'*[5600], ±1)*[5552]`;
  `saw = (quintic(b; [5952..6016]) + b) * (ph'*[5648])` → `[4896]` scratch.
- pulse: `w = [4816]'+ph'`; `s = signclamp(w)`;
  `t = juno_triangle(w / (w<0 ? [4816]'-1 : [4816]'+1))` (Pattern B);
  `b = clamp((t*[4800]')*256*[5616], ±1)*[5552]`;
  `pulse = (quintic(b)+b) * (s*[5664])` → `[4912]`.
- sub: counter `[4672]` += 2 on phase wrap past `[5584]`, wraps at 4 (:1764-1775);
  `q = ((cnt+ph')+1)*0.5 - 1`; `t = juno_triangle(-|q|)` (Pattern C);
  `b = clamp(((t+1)*[4800]')*512*[5632], ±1)*[5552]`;
  `sub = (quintic(b)+b) * (signclamp(q)*[5680])`.
- iter out `[4944|5072|5200|5328]' = sub*[4768] + [4896]*[4736] + [4912]*[4752]`
  (:1807-1823 etc.).
Mix (:2134-2168): 16 symmetric FIR tap-pairs `[5696..5936]` over the four
histories; feedback path `[5488]' = [5488]*[6256] + [5504]`,
`[5472]' = (mix - ([5488]*[6272] + [5488]')) * [6256] + [5488]`;
`[4928]' = (([5488]' - v525*[5456]')*[6336] - [6336]*mix) + mix` (:2160-2173);
`[3520]' = [4928]'` (:2174) — consumed by the VCF NEXT sample.

## 3. Constants table (inline literals + tables)

| constant | sites | meaning |
|---|---|---|
| `-16777216.0` | :601 | −2^24 — wrap24 scale with sign fold (phase negation) |
| `0.000000059604645` | :640 | 2^−24 — wrap24 rescale |
| `2.3283064e-10` | :744,:765 | 2^−32 — exp-table underflow arm |
| `0.000015258789` | :826 | 2^−16 — LFO rate → phase inc |
| `0.00390625` | :1004,:1059,:1065,:1070,:1716 | 1/256 — env rate scale; BLEP base scale |
| `0.25` | :1260 | frac² scale in the exp2 poly |
| `256.0` / `512.0` | :1735,:1768,:1799 (+3 more iterations) | BLEP scale saw+pulse / sub |
| `±1.0`, `2.0` | throughout | phase wrap to [−1,1) via `fmodf(x±1,2)∓1` |
| `4.0`, `+2.0`, `0.5`, `−1.0` | :1766-1777 etc. | sub counter wrap 4 / step 2 / sub phase `((cnt+ph)+1)/2−1` |
| `−20.0`, `8.9`, `+20`, `±512.0` | :1641-1663 | pitch-spline domain clamp, row index, output clamp |
| `(int)0x80000000` | :1257 | int-indefinite guard in floor split |
| 32 / −32 clamp | :742-781 | exp-table index clamps |
| `juno_exp_ad3c[33]`, `juno_exp_acc0[33]` | :751,:756,:772,:777 | 2^±n tables (juno_tables.h) |
| `juno_pitch_table` | :1643 | 29 rows × 13 even-indexed doubles (0x1809894E0, stride 208) |
| helpers | `juno_triangle` (0x180368FC0), `juno_wrap24` (0x180368D60) | juno_dsp.c:20-71; dropped-XMM args resolved in docs/VOICE_RENDER_MAP.md:52-69 |

All other numeric behaviour comes from state cells written by
init/prepare/recall — the voice render itself embeds NO other magic numbers.

## 4. Interactions with other subsystems

**Written into the voice block from outside (per event / recall, not per sample):**
- Note driver (`src/juno_note.c`): 304 (M.CV), 320 (M.Gate), 6864/9680
  (velocity via c56/c57), 1856 (any-key-held, broadcast ALL voices),
  9824 (mute/gate twin), 592+9824 (porta gate leaf), aux latch 101504+v*32
  (note-off / MONO retrig).
- Recall (`src/juno_apply.c` BINDINGS + discrete blocks): every [REG]-named
  coefficient cell in §1 (VCF 6736/6832/7392/7408/10240-10288, ENV 2784-2832 /
  3264-3312, DCO 3840/3888-3936/4032/4144/4192/4208/4224/6528, LFO 1088/1920/
  1936/1872/1056/1072/2064, VCA 9584/9600/10176-10224, sens 3984/4128/7360/
  7424/7472, vel-sens 7424/9600). Writes land on voice 0; seed_voices
  replicates; CONDITION (5520/7600/10320) and UNISON (3968) are per-voice
  DISTINCT and re-applied after seeding (juno_apply.c:458-506).
- Prepare (`src/juno_prepare.c`): 1888=1.0 (:76), 7632=1.0 (:87), 9056=1.0
  (:88) — the two DSP gates and the phase-run gate; plus 33 voice-0 offsets.
- Init (`src/juno_init.c`): 4448=−4.75 tune, 2128/2144 phase-inc consts
  (:942-943), 6416=1.0 (:1062), shared 84400/84416 (:2870-2871).
- Smoother subsystem (en=1 host params): feeds the read-only input cells
  176/208/240/272/368/944/976/1008/6576/6608/6672/9552 between samples; all
  are identity at rest in the gated corpus.

**Read by the outside:**
- 10672 is the voice sample; the driver hands it to `juno_master_render` via
  the even-slot pointer array (master reads ONLY even slots —
  docs/MASTER_RENDER_MAP.md, CLAUDE.md render-loop findings). The function also
  returns its bit pattern (eax).
- `master_render.c` reads NO cell in [84272,84436) and none of the write-only
  cells checked (2768/3248/3824 — grep-verified this session).

**Ordering constraints:**
1. Voices render 0..7 in order (shared noise chains through all 8).
2. Master runs per sample after all 8 voices, from unit-8 state in the oracle.
3. Within a voice-sample: VCF consumes the PREVIOUS sample's DCO output
   (3536), so the modulation/filter half runs before the oscillator half
   (see §2 head note). Any native re-ordering must reproduce this delay.

## 5. Open questions (for the native rewrite)

1. **Write-only cells (82 in-file).** Most are shadows (`prev` copies) or
   register-promoted scratch whose live value continues in a register
   (_s4656.., :34-54). True compute-dead in-file: 2768, 3248 (scaled env
   outs), 3824 (VCF-bound CV sum), 10160 (pre-DC sample). None are read by
   master_render.c (grep-verified); before DROPPING any in a native
   implementation, verify no probe/gate/GUI reader relies on them —
   the render A/B gates compare FULL state, so a dropped store fails the
   bit-exact gate even if audio-identical. A −90 dB-null implementation may
   drop them; a bit-exact one may not.
2. **Who writes the read-only inputs** 176/208/240/272 (ramped M.CV/M.Gate
   alt path), 368/944/976/1008 (mod/ext-LFO buses), 6576/6608/6672 (VCF CV
   inputs), 9552 (ext env), 84272 (ext noise)? INFERRED: the en=1 smoother
   subsystem + wrapper mod layer (src/juno_mod.c targets some). They are 0 /
   identity at rest; a native voice must keep them as INPUT PORTS, not fold
   them away.
3. **Dual-typed cells** (accessed as both JF and JI — e.g. 320, 496, 560,
   880, 912, 1808/2544, 1824/2528, 3520/3536, 3232, 2752, 6544, 6608/7264,
   6896/7248): the int accesses are BIT copies. A native port must memcpy,
   never float-assign (denormal/NaN preservation), and FTZ/DAZ semantics
   (juno_ftz.c) are load-bearing on WASM.
4. **ENV state-machine labels** (G/H sub-tables) are INFERRED; the branch
   structure :980-1017 is the spec. Deriving the clean piecewise ADSR form
   and proving branch-for-branch equality is the main analytic task left.
5. **2064 dual identity**: registry "LFO Noise Mix", but recall mirrors LFO
   RATE c22 into it (BINDINGS) and the render uses it as the noise S&H
   glide-mix (:855-856) — i.e. S&H glide follows the LFO rate. Both facts are
   proven; the native name should reflect the RENDER role.
6. **1888 "Reset Sw"** multiplies the phase every sample (:845). Prepare sets
   1.0; a host writing ≠1 would rescale the LFO. Confirm its writer set before
   exposing it.
7. **Naming inversions to keep straight** (registry vs panel): 4144 "PWM
   Level" [REG] = panel DCO PWM DEPTH; 4208 "JU OSC Sqr Lev" [REG] = panel
   DCO PWM LEVEL; 770 is DCO PWM LEVEL (CLAUDE.md correction).
8. **Precision:** the exp2/tan-rational (7872..8192), quintic shapers, and
   FIR sums must keep the EXACT f32 association transcribed here
   (`-ffp-contract=off`); the pitch spline mixes f64 accumulation over f32
   coeffs (:1641-1665). These are the numerically-hot spots where a naive
   refactor will break a −90 dB null first.
9. **JX-3P reuse recipe:** (1) diff the per-voice function copies to get
   region strides (POLYPHONY.md method); (2) run the §0 scanner
   (scratchpad cellscan.py pattern) over the transcription; (3) pull names
   from that plugin's own coefficient registry (its sub_180388170 analogue);
   (4) group by dataflow into §1 sub-tables; (5) write §2 equations from the
   transcription with line cites; (6) only then attempt a native rewrite,
   gated by full-state bit-exact A/B first, −90 dB null second.
