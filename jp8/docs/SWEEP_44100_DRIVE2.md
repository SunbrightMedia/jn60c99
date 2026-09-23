# SWEEP_44100_DRIVE2.md -- 64-patch listen sweep of the JP8 oracle at 44100 on DRIVE2 (PORT_PIPELINE step 4 reach)

Produced by `jp8/tools/jp8_sweep.py <patch> <logdir>` on DRIVE2 (S3_STATUS D7: HOST built by the plugin's factory 0x444FE0,
BUILD -> FTZ -> SETSR -> host_init -> recall through HOSTPARAM 0x4465B0 per pool; NO snap, NO latch clear; ramp census per
stage) and collected by `jp8_sweep_collect.py <logdir> <out> drive2`; every row has its log in `jp8/logs/sweep44100_drive2/pNN.log`. Labels: PROVEN (executed on
the plugin's own code under Unicorn). Pitch = DRY f0 by autocorrelation vs the engine's OWN pitch cells (jp8_d4_law.py),
E = early window (1024..17408 after note-on), L = late window (49152..65536); release = 24000-sample tail or the 3 s tail rule.

**Result: 51/64 PASS, 13 FAIL (0,1,7,12,13,24,26,27,34,39,41,44,56).**

| patch | name | verdict | f0 vs key per key (window) | harmonic | idle peak | NaN | faults | instr/sample idle/sustain | confound candidates |
|---|---|---|---|---|---|---|---|---|---|
| 0 | PD Jupiter Glide | FAIL(pitch48,pitch60,track) | 48:+1803c(E) 60:+2104c(E) 72:-1600c(L) | 0.47 0.30 0.90 | 1.57e-13 | 0 | 0 | 30583/30557 | VCO ENV MOD 18; REVERB 30 DELAY 191 |
| 1 | PD Jupiter Str | FAIL(pitch48) | 48:-1188c(E) 60:-1191c(E) 72:-1187c(E) | 0.74 0.81 0.92 | 1.57e-13 | 0 | 0 | 31065/30555 | REVERB 146 DELAY 45 |
| 2 | BR JP PWM Brass | PASS | 48:+7c(E) 60:+5c(E) 72:+5c(E) | 0.97 0.96 0.95 | 1.57e-13 | 0 | 0 | 31001/30549 | REVERB 161 DELAY 37 |
| 3 | SQ JP Arpeggio | PASS | 48:+1217c(E) 60:+1203c(E) 72:+1207c(E) | 0.98 0.99 0.97 | 1.57e-13 | 0 | 0 | 29861/29902 | REVERB 119 DELAY 83 |
| 4 | PL Poly Stack | PASS | 48:-1199c(E) 60:-1201c(E) 72:-1203c(E) | 0.93 0.96 0.95 | 1.57e-13 | 0 | 0 | 30000/29517 | ENV REL 174/120; REVERB 144 DELAY 83 |
| 5 | SY 1964 SciWiFi | PASS | 48:+10c(E) 60:+1c(E) 72:-2c(E) | 0.88 0.93 0.91 | 0.00114 | 0 | 0 | 30101/29659 | SYNC; PORTAMENTO 21; REVERB 139 DELAY 38 |
| 6 | BS Ba-Bass | PASS | 48:-1207c(E) 60:-1203c(E) 72:-1202c(E) | 0.96 0.95 0.94 | 0.000617 | 0 | 0 | 31047/30574 | SYNC; PORTAMENTO 15; REVERB 56 DELAY 35 |
| 7 | LD Siren's Chant | FAIL(pitch48,pitch60,pitch72,track) | 48:+1190c(L) 60:+1201c(L) 72:+1157c(E) | 0.62 0.60 0.59 | 1.57e-13 | 0 | 0 | 30201/30346 | CROSS MOD 8; LOW FREQ; PORTAMENTO 57; ENV REL 157/96; REVERB 152 DELAY 42 |
| 8 | PD JP Square Pad | PASS | 48:+4c(E) 60:+5c(E) 72:+2c(E) | 0.98 0.98 0.98 | 1.57e-13 | 0 | 0 | 29665/29748 | REVERB 153 DELAY 11 |
| 9 | KY XMod Electric | PASS | 48:+2c(E) 60:-3c(E) 72:+0c(E) | 0.98 0.97 0.96 | 1.57e-13 | 0 | 0 | 29947/29789 | CROSS MOD 182; ENV REL 205/115; REVERB 162 DELAY 103 |
| 10 | PD JP Soft Pad | PASS | 48:+4c(E) 60:+7c(E) 72:+2c(E) | 0.96 0.97 0.98 | 1.57e-13 | 0 | 0 | 29960/29983 | REVERB 115 DELAY 56 |
| 11 | KY Warship | PASS | 48:-1205c(E) 60:-1203c(E) 72:-1203c(E) | 0.95 0.97 0.98 | 1.57e-13 | 0 | 0 | 28964/29378 | REVERB 185 DELAY 40 |
| 12 | SQ 8th Peaks | FAIL(pitch72,track) | 48:-2406c(E) 60:-2403c(L) 72:-2404c(L) | 0.85 0.84 0.79 | 0.000419 | 0 | 0 | 32063/31561 | SYNC; REVERB 56 DELAY 3 |
| 13 | LD Hawk Lead | FAIL(pitch48,pitch60,pitch72,track) | 48:+2998c(E) 60:+817c(L) 72:+831c(E) | 0.45 0.57 0.43 | 1.57e-13 | 0 | 0 | 30299/30740 | SYNC; PORTAMENTO 26; REVERB 56 DELAY 20 |
| 14 | PD JP Phaser Pad | PASS | 48:-1190c(E) 60:-1190c(E) 72:-1192c(E) | 0.90 0.96 0.96 | 0.000157 | 0 | 0 | 31065/31068 | REVERB 177 DELAY 31 |
| 15 | BR Grind Tpt | PASS | 48:+3c(E) 60:-1c(E) 72:-1c(E) | 0.98 0.98 0.97 | 1.57e-13 | 0 | 0 | 32017/32040 | REVERB 54 DELAY 124 |
| 16 | LD Jupiter Lead | PASS | 48:-1197c(L) 60:-1197c(E) 72:-1197c(E) | 1.00 1.00 0.99 | 1.57e-13 | 0 | 0 | 32103/31614 | PORTAMENTO 39; REVERB 145 DELAY 15 |
| 17 | BS So Smooth | PASS | 48:-1194c(E) 60:-1195c(E) 72:-1196c(E) | 0.99 0.98 0.98 | 1.57e-13 | 0 | 0 | 29871/29395 | REVERB 120 DELAY 5 |
| 18 | PD Lush City | PASS | 48:+17c(E) 60:+15c(E) 72:+15c(E) | 0.99 0.99 0.98 | 1.57e-13 | 0 | 0 | 31561/31590 | REVERB 255 DELAY 255 |
| 19 | SQ Jumpin' Arpg | PASS | 48:-1193c(E) 60:-1187c(E) 72:-1196c(E) | 0.97 0.99 0.98 | 1.57e-13 | 0 | 0 | 29528/29507 | VCO ENV MOD 255; PORTAMENTO 14; REVERB 115 DELAY 123 |
| 20 | SY Spit Sinker | PASS | 48:+16c(E) 60:+12c(E) 72:+13c(E) | 0.98 0.96 0.91 | 1.57e-13 | 0 | 0 | 25473/25487 | REVERB 172 DELAY 111 |
| 21 | BS Thrillin' Bs | PASS | 48:-2406c(E) 60:-2403c(E) 72:-2403c(E) | 0.99 0.98 0.98 | 1.57e-13 | 0 | 0 | 30079/29603 | REVERB 146 DELAY 2 |
| 22 | PD Phased Dirt | PASS | 48:-1193c(E) 60:-1189c(E) 72:-1189c(E) | 1.00 1.00 0.98 | 0.000703 | 0 | 0 | 29535/29576 | ENV REL 162/126; REVERB 133 DELAY 103 |
| 23 | PD Jupiter Str2 | PASS | 48:+6c(E) 60:+2c(E) 72:-1c(E) | 0.85 0.88 0.81 | 1.57e-13 | 0 | 0 | 31036/31025 | REVERB 128 DELAY 14 |
| 24 | SQ Deep Ocean | FAIL(pitch48,pitch60,pitch72) | 48:-1200c(E) 60:-1200c(L) 72:-1201c(L) | 0.59 0.58 0.61 | 1.57e-13 | 0 | 0 | 30085/29593 | REVERB 144 DELAY 45; LFO->VCO 255 |
| 25 | SY Silk Fives | PASS | 48:-1184c(E) 60:-1185c(E) 72:-1185c(E) | 0.99 1.00 0.99 | 1.57e-13 | 0 | 0 | 31601/31604 | REVERB 217 DELAY 255 |
| 26 | LD ELK Sitar | FAIL(pitch48,reldry48,relmaster48,pitch60,reldry60,relmaster60,pitch72,reldry72,relmaster72,track) | 48:+880c(E) 60:+2867c(E) 72:+2817c(E) | 0.44 0.41 0.46 | 0.000504 | 0 | 0 | 29753/30101 | VCO ENV MOD 255; PORTAMENTO 43; ENV REL 194/215; REVERB 38 DELAY 86; LFO->VCO 200 |
| 27 | BS Waver Bass | FAIL(pitch48,pitch60,track) | 48:-1228c(E) 60:-1238c(L) 72:-1194c(E) | 0.98 0.97 0.96 | 1.57e-13 | 0 | 0 | 31601/31628 | CROSS MOD 73 |
| 28 | PD Warm Pad | PASS | 48:-1201c(E) 60:-1205c(E) 72:-1207c(E) | 0.95 0.98 0.97 | 1.57e-13 | 0 | 0 | 30545/30566 | CROSS MOD 199; REVERB 0 DELAY 130 |
| 29 | PD 4-Seen Voices | PASS | 48:+4c(E) 60:-1c(E) 72:+2c(E) | 0.99 0.98 0.98 | 1.57e-13 | 0 | 0 | 29527/30027 | ENV REL 157/144; REVERB 189 DELAY 35 |
| 30 | SQ Compu-Spike | PASS | 48:-2404c(E) 60:-2404c(E) 72:-2403c(E) | 1.00 1.00 1.00 | 0.000937 | 0 | 0 | 30134/29657 | PORTAMENTO 21; REVERB 119 DELAY 42 |
| 31 | DR Percussion | PASS | 48:+3c(L) 60:-1c(L) 72:-1c(L) | 0.98 0.98 0.99 | 0.00167 | 0 | 0 | 25481/25971 | VCO ENV MOD 0; ENV REL 98/157; REVERB 154 DELAY 0 |
| 32 | SQ Arpg Hardball | PASS | 48:-1203c(E) 60:-1200c(E) 72:-1201c(E) | 0.99 0.99 0.98 | 1.57e-13 | 0 | 0 | 29263/29374 | REVERB 65 DELAY 14 |
| 33 | PD JP Pad Mach | PASS | 48:-2384c(E) 60:-2393c(E) 72:-2391c(E) | 0.82 0.82 0.87 | 1.57e-13 | 0 | 0 | 30011/29524 | REVERB 40 DELAY 152 |
| 34 | SQ Arpg Terra | FAIL(pitch60,pitch72,track) | 48:-1216c(L) 60:-1207c(E) 72:-1211c(E) | 0.87 0.72 0.73 | 0.000827 | 0 | 0 | 29753/30169 | CROSS MOD 252; REVERB 80 DELAY 44 |
| 35 | PD Lunar Breeze | PASS | 48:+12c(E) 60:+3c(E) 72:+10c(E) | 0.99 0.98 0.98 | 1.57e-13 | 0 | 0 | 29545/29591 | REVERB 216 DELAY 108 |
| 36 | PL Stac Echo | PASS | 48:-1201c(E) 60:-1201c(E) 72:-1203c(E) | 0.99 0.96 0.94 | 1.57e-13 | 0 | 0 | 30047/29579 | ENV REL 174/141; REVERB 144 DELAY 83; LFO->VCO 127 |
| 37 | PL PWM Plucking | PASS | 48:+2c(E) 60:+3c(E) 72:+5c(E) | 0.93 0.93 0.91 | 1.57e-13 | 0 | 0 | 31001/30549 | REVERB 146 DELAY 64 |
| 38 | SY Jupiter PWM | PASS | 48:-1193c(E) 60:-1197c(E) 72:-1191c(E) | 0.93 0.92 0.93 | 1.57e-13 | 0 | 0 | 29521/29539 | REVERB 112 DELAY 43 |
| 39 | SQ Peppercorn | FAIL(pitch48,pitch60,pitch72) | 48:+1192c(E) 60:+1200c(E) 72:+1203c(E) | 0.65 0.71 0.60 | 1.57e-13 | 0 | 0 | 30024/29572 | REVERB 80 DELAY 87; LFO->VCO 255 |
| 40 | 1981 NEG Pluck | PASS | 48:-1195c(E) 60:-1200c(E) 72:-1199c(E) | 0.99 0.99 0.97 | 1.57e-13 | 0 | 0 | 29741/29223 | - |
| 41 | 1981 Cars Sync | FAIL(pitch48,pitch60,pitch72,track) | 48:+5172c(E) 60:+301c(L) 72:+264c(L) | 0.05 0.54 0.57 | 1.57e-13 | 0 | 0 | 30023/29497 | VCO ENV MOD 204; SYNC |
| 42 | 1981 Hammer Lead | PASS | 48:-1198c(E) 60:-1198c(E) 72:-1199c(E) | 0.98 0.99 0.98 | 1.57e-13 | 0 | 0 | 30055/29561 | - |
| 43 | 1981 Clav | PASS | 48:-1200c(E) 60:-1201c(E) 72:-1200c(E) | 0.96 0.99 0.98 | 1.57e-13 | 0 | 0 | 30007/29524 | - |
| 44 | 1981 Echo Piano | FAIL(pitch48,reldry48,relmaster48,pitch60,reldry60,relmaster60,reldry72,relmaster72,track) | 48:+3060c(E) 60:+3058c(E) 72:+3108c(E) | 0.97 0.86 0.85 | 1.57e-13 | 0 | 0 | 32073/31605 | VCO ENV MOD 248; ENV REL 0/160 |
| 45 | 1981 Honky Tonk | PASS | 48:+16c(E) 60:+15c(E) 72:+14c(E) | 0.97 0.98 0.97 | 1.57e-13 | 0 | 0 | 29905/29522 | ENV REL 188/100 |
| 46 | 1981 Xylo | PASS | 48:+10c(E) 60:+8c(E) 72:+9c(E) | 0.96 0.94 0.89 | 1.57e-13 | 0 | 0 | 30072/29633 | VCO ENV MOD 130; SYNC; ENV REL 180/120 |
| 47 | 1981 Harp | PASS | 48:-5c(E) 60:-2c(E) 72:-2c(E) | 0.94 0.98 0.97 | 1.57e-13 | 0 | 0 | 30033/29631 | ENV REL 148/168 |
| 48 | 1981 Lo Strings | PASS | 48:-1193c(E) 60:-1195c(E) 72:-1202c(E) | 0.84 0.93 0.93 | 1.57e-13 | 0 | 0 | 31065/31089 | ENV REL 159/120 |
| 49 | 1981 Hi Strings | PASS | 48:+1211c(E) 60:+1212c(E) 72:+1208c(E) | 0.96 0.95 0.93 | 1.57e-13 | 0 | 0 | 31068/31034 | - |
| 50 | 1981 Mellow Str | PASS | 48:+6c(E) 60:+6c(E) 72:+5c(E) | 0.90 0.90 0.87 | 1.57e-13 | 0 | 0 | 29930/29484 | - |
| 51 | 1981 Lo Brass | PASS | 48:-1194c(E) 60:-1195c(E) 72:-1196c(E) | 0.99 0.99 0.98 | 1.57e-13 | 0 | 0 | 32095/31621 | - |
| 52 | 1981 Hi Brass | PASS | 48:+6c(E) 60:+5c(E) 72:+5c(E) | 0.99 0.99 0.98 | 1.57e-13 | 0 | 0 | 32033/31564 | - |
| 53 | 1981 S/H Brass | PASS | 48:-1194c(E) 60:-1195c(E) 72:-1194c(E) | 0.99 0.99 0.99 | 1.57e-13 | 0 | 0 | 31631/31637 | - |
| 54 | 1981 Pipe Organ | PASS | 48:-1201c(E) 60:-1200c(E) 72:-1201c(E) | 0.99 0.99 0.98 | 1.57e-13 | 0 | 0 | 30543/30572 | ENV REL 167/110 |
| 55 | 1981 Drawbar Org | PASS | 48:-1204c(E) 60:-1202c(E) 72:-1202c(E) | 0.98 0.99 0.98 | 1.57e-13 | 0 | 0 | 31034/30544 | - |
| 56 | 1981 Solo Voice | FAIL(pitch48,pitch60,pitch72,track) | 48:+1201c(E) 60:+1197c(E) 72:+1186c(E) | 0.73 0.76 0.74 | 1.57e-13 | 0 | 0 | 29809/29312 | VCO ENV MOD 71; ENV REL 162/57 |
| 57 | 1981 Choir Voice | PASS | 48:+1216c(E) 60:+1214c(E) 72:+1208c(E) | 0.93 0.94 0.93 | 1.57e-13 | 0 | 0 | 30043/29509 | ENV REL 226/115 |
| 58 | 1981 Fat Fifth | PASS | 48:-2407c(E) 60:-2401c(E) 72:-2401c(E) | 0.98 0.99 0.99 | 1.57e-13 | 0 | 0 | 29522/29482 | - |
| 59 | 1981 Fuzzy Fifth | PASS | 48:-1201c(E) 60:-1201c(E) 72:-1202c(E) | 0.96 0.97 0.96 | 1.57e-13 | 0 | 0 | 30492/31016 | - |
| 60 | 1981 Hard Blip | PASS | 48:-1197c(E) 60:-1198c(E) 72:-1197c(E) | 0.98 0.98 0.98 | 1.57e-13 | 0 | 0 | 32095/31597 | VCO ENV MOD 156 |
| 61 | 1981 Flute | PASS | 48:+1204c(E) 60:+1199c(E) 72:+1199c(L) | 0.89 0.84 0.81 | 1.57e-13 | 0 | 0 | 25159/24541 | - |
| 62 | 1981 Whistle | PASS | 48:+2401c(E) 60:+2398c(E) 72:+2400c(E) | 0.96 0.96 0.95 | 1.57e-13 | 0 | 0 | 25031/24579 | - |
| 63 | 1981 Chime | PASS | 48:+19c(E) 60:+12c(E) 72:+6c(E) | 0.90 0.91 0.91 | 1.57e-13 | 0 | 0 | 31164/30663 | CROSS MOD 97; ENV REL 223/157 |
