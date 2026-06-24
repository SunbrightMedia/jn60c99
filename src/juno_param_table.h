/* juno_param_table.h - paramID/offset -> denormalize tableId.
   AUTO-GENERATED from refs/param_table_full.json (vtable-wiring extraction).
   inferred=0 : DEFINITIVE. source=oracle (bit-exact PD capture) | vtable
               (CDSPJu60* setter vtable -> sub_356380 tableId, node==paramID)
               | vtable-multi (node shared by >1 setter; primary tableId chosen).
   inferred=1 : name-fallback (name maps to a single tableId across all
               definitively-resolved params; UNVALIDATED structurally).
   Oracle agreement: 61/61 overlapping offsets, bit-exact (0 disagree). */
typedef struct { int paramId, offset, tableId, inferred; } juno_param_ent;
#define JUNO_PARAM_TABLE_N 673
static const juno_param_ent JUNO_PARAM_TABLE[JUNO_PARAM_TABLE_N] = {
  {0,272,52,1}, /* UseExtJack [name-fallback] */
  {1,304,32,0}, /* M.CV [oracle] */
  {3,368,6,0}, /* Master Tune [vtable-multi] */
  {4,384,27,0}, /* Part Tune [vtable] */
  {5,592,52,0}, /* Portamento OnOff [vtable] */
  {6,608,52,0}, /* Portamento Mode [vtable] */
  {7,624,4,0}, /* Portamento Time [oracle] */
  {8,1040,52,0}, /* LFO Griffer Rate Sw [vtable] */
  {9,1056,52,0}, /* LFO Tempo Rate Sw [vtable] */
  {10,1072,53,0}, /* LFO Tempo Rate [vtable-multi] */
  {11,1088,22,0}, /* LFO Rate [vtable] */
  {12,1856,52,0}, /* Gate [vtable] */
  {13,1872,51,0}, /* LFO Trig [vtable] */
  {15,1904,52,0}, /* LFO UseExtGate [vtable] */
  {16,1920,44,0}, /* LFO Delay [oracle] */
  {17,1936,44,0}, /* LFO Delay Sw [vtable] */
  {18,1952,52,0}, /* LFO Sin Sw [vtable] */
  {19,1968,52,0}, /* LFO Tri Sw [vtable] */
  {20,1984,52,0}, /* LFO Sqr Sw [vtable] */
  {21,2000,52,0}, /* LFO Saw Sw [vtable] */
  {22,2016,52,0}, /* LFO Saw(Inv) Sw [vtable] */
  {23,2032,52,0}, /* LFO S&H Sw [vtable] */
  {24,2048,52,0}, /* LFO Noise Sw [vtable] */
  {25,2064,22,0}, /* LFO Noise Mix [vtable] */
  {31,2560,52,0}, /* LFO trigger env sw [vtable] */
  {32,2784,35,0}, /* ENV Attack [oracle] */
  {33,2800,50,0}, /* ENV Sustain [oracle] */
  {34,2816,38,0}, /* ENV Decay [oracle] */
  {35,2832,38,0}, /* ENV Release [oracle] */
  {37,3040,52,0}, /* LFO trigger env sw [vtable] */
  {38,3264,35,0}, /* ENV Attack [oracle] */
  {39,3280,50,0}, /* ENV Sustain [vtable] */
  {40,3296,38,0}, /* ENV Decay [oracle] */
  {41,3312,38,0}, /* ENV Release [oracle] */
  {43,3840,5,0}, /* OSC1 Feet [vtable] */
  {44,3856,52,0}, /* Griffer Bend SW [vtable] */
  {45,3872,52,0}, /* Bend Enable SW [vtable] */
  {50,3952,28,0}, /* Tune [vtable] */
  {53,4000,22,0}, /* Mod Sw [vtable] */
  {55,4032,0,0}, /* LFO Level [oracle] */
  {56,4048,52,0}, /* LFO Sw [vtable] */
  {59,4096,52,0}, /* ENV Sw [vtable] */
  {60,4112,26,0}, /* Bend Level [vtable] */
  {61,4128,21,0}, /* Bend Range [oracle] */
  {62,4144,45,0}, /* PWM Level [oracle] */
  {63,4192,54,0}, /* JU OSC Saw Lev [oracle] */
  {64,4208,54,0}, /* JU OSC Sqr Lev [vtable] */
  {65,4224,54,0}, /* JU OSC Sub Lev [oracle] */
  {66,5520,27,0}, /* Duty Tune [oracle] */
  {68,6512,54,0}, /* Osc1 Level [oracle] */
  {69,6528,12,0}, /* Osc Noise Level [oracle] */
  {70,6720,52,0}, /* Griffer SW [vtable] */
  {71,6736,22,0}, /* LPF Cutoff [vtable] */
  {72,6832,22,0}, /* LPF Resonance [vtable] */
  {73,6864,21,0}, /* Velocity [oracle] */
  {74,7008,52,0}, /* Env1/2 [vtable] */
  {75,7024,52,0}, /* Int/Env [vtable] */
  {77,7312,52,0}, /* Ext LFO Sw [vtable] */
  {78,7328,52,0}, /* GRF Bned SW [vtable] */
  {79,7344,47,0}, /* LFO Level [oracle] */
  {81,7376,22,0}, /* MOD SW [vtable] */
  {82,7392,46,0}, /* ENV Level [oracle] */
  {83,7408,24,0}, /* KCV Level [vtable] */
  {84,7424,22,0}, /* Velocity Sens [vtable] */
  {85,7440,24,0}, /* Velocity Offset [oracle] */
  {86,7456,26,0}, /* Bend Level [vtable] */
  {87,7472,21,0}, /* Bend Range [oracle] */
  {89,7616,31,0}, /* Resonance Tune [vtable] */
  {95,9584,21,0}, /* AMP TONE [oracle] */
  {96,9600,22,0}, /* AMP VELOCITY SENS [vtable] */
  {97,9616,56,0}, /* AMP FIX VELOCITY LEVEL [oracle] */
  {98,9680,56,0}, /* Velocity [oracle] */
  {99,9824,51,0}, /* Mute [vtable] */
  {103,10224,52,0}, /* Ext ENV SW [vtable] */
  {104,10240,41,0}, /* HPF Cutoff [oracle] */
  {108,10304,22,0}, /* ENV LEVEL [vtable] */
  {110,10784,52,0}, /* UseExtJack [vtable] */
  {111,10816,32,1}, /* M.CV [name-fallback] */
  {113,10880,6,0}, /* Master Tune [vtable-multi] */
  {114,10896,27,0}, /* Part Tune [vtable] */
  {115,11104,52,0}, /* Portamento OnOff [vtable] */
  {116,11120,52,0}, /* Portamento Mode [vtable] */
  {117,11136,7,0}, /* Portamento Time [vtable] */
  {118,11552,52,0}, /* LFO Griffer Rate Sw [vtable] */
  {119,11568,52,0}, /* LFO Tempo Rate Sw [vtable] */
  {120,11584,53,0}, /* LFO Tempo Rate [vtable-multi] */
  {121,11600,22,0}, /* LFO Rate [vtable] */
  {122,12368,52,0}, /* Gate [vtable] */
  {123,12384,51,0}, /* LFO Trig [vtable] */
  {125,12416,52,0}, /* LFO UseExtGate [vtable] */
  {126,12432,44,0}, /* LFO Delay [vtable] */
  {127,12448,44,0}, /* LFO Delay Sw [vtable] */
  {128,12464,52,0}, /* LFO Sin Sw [vtable] */
  {129,12480,52,0}, /* LFO Tri Sw [vtable] */
  {130,12496,52,0}, /* LFO Sqr Sw [vtable] */
  {131,12512,52,0}, /* LFO Saw Sw [vtable] */
  {132,12528,52,0}, /* LFO Saw(Inv) Sw [vtable] */
  {133,12544,52,0}, /* LFO S&H Sw [vtable] */
  {134,12560,52,0}, /* LFO Noise Sw [vtable] */
  {135,12576,22,0}, /* LFO Noise Mix [vtable] */
  {141,13072,52,0}, /* LFO trigger env sw [vtable] */
  {142,13296,35,1}, /* ENV Attack [name-fallback] */
  {143,13312,50,0}, /* ENV Sustain [vtable] */
  {144,13328,38,1}, /* ENV Decay [name-fallback] */
  {145,13344,38,1}, /* ENV Release [name-fallback] */
  {147,13552,52,0}, /* LFO trigger env sw [vtable] */
  {148,13776,35,1}, /* ENV Attack [name-fallback] */
  {149,13792,50,0}, /* ENV Sustain [vtable] */
  {150,13808,38,1}, /* ENV Decay [name-fallback] */
  {151,13824,38,1}, /* ENV Release [name-fallback] */
  {153,14352,5,0}, /* OSC1 Feet [vtable] */
  {154,14368,52,0}, /* Griffer Bend SW [vtable] */
  {155,14384,52,0}, /* Bend Enable SW [vtable] */
  {160,14464,28,0}, /* Tune [vtable] */
  {163,14512,22,0}, /* Mod Sw [vtable] */
  {165,14544,0,0}, /* LFO Level [vtable] */
  {166,14560,52,0}, /* LFO Sw [vtable] */
  {169,14608,52,0}, /* ENV Sw [vtable] */
  {170,14624,26,0}, /* Bend Level [vtable] */
  {171,14640,21,1}, /* Bend Range [name-fallback] */
  {172,14656,45,0}, /* PWM Level [vtable] */
  {173,14704,54,0}, /* JU OSC Saw Lev [vtable] */
  {174,14720,54,0}, /* JU OSC Sqr Lev [vtable] */
  {175,14736,54,0}, /* JU OSC Sub Lev [vtable] */
  {176,16032,27,1}, /* Duty Tune [name-fallback] */
  {178,17024,54,0}, /* Osc1 Level [vtable] */
  {179,17040,54,0}, /* Osc Noise Level [vtable] */
  {180,17232,52,0}, /* Griffer SW [vtable] */
  {181,17248,22,0}, /* LPF Cutoff [vtable] */
  {182,17344,22,0}, /* LPF Resonance [vtable] */
  {183,17376,56,0}, /* Velocity [vtable] */
  {184,17520,52,0}, /* Env1/2 [vtable] */
  {185,17536,52,0}, /* Int/Env [vtable] */
  {187,17824,52,0}, /* Ext LFO Sw [vtable] */
  {188,17840,52,0}, /* GRF Bned SW [vtable] */
  {189,17856,47,0}, /* LFO Level [vtable] */
  {191,17888,22,0}, /* MOD SW [vtable] */
  {192,17904,46,0}, /* ENV Level [vtable] */
  {193,17920,24,0}, /* KCV Level [vtable] */
  {194,17936,22,0}, /* Velocity Sens [vtable] */
  {195,17952,56,0}, /* Velocity Offset [vtable] */
  {196,17968,26,0}, /* Bend Level [vtable] */
  {197,17984,21,1}, /* Bend Range [name-fallback] */
  {199,18128,31,0}, /* Resonance Tune [vtable] */
  {205,20096,24,0}, /* AMP TONE [vtable] */
  {206,20112,22,0}, /* AMP VELOCITY SENS [vtable] */
  {207,20128,57,0}, /* AMP FIX VELOCITY LEVEL [vtable] */
  {208,20192,57,0}, /* Velocity [vtable] */
  {209,20336,51,0}, /* Mute [vtable] */
  {213,20736,52,0}, /* Ext ENV SW [vtable] */
  {214,20752,41,1}, /* HPF Cutoff [name-fallback] */
  {218,20816,22,0}, /* ENV LEVEL [vtable] */
  {220,21296,52,0}, /* UseExtJack [vtable] */
  {221,21328,32,1}, /* M.CV [name-fallback] */
  {223,21392,6,0}, /* Master Tune [vtable-multi] */
  {224,21408,27,0}, /* Part Tune [vtable] */
  {225,21616,52,0}, /* Portamento OnOff [vtable] */
  {226,21632,52,0}, /* Portamento Mode [vtable] */
  {227,21648,7,0}, /* Portamento Time [vtable] */
  {228,22064,52,0}, /* LFO Griffer Rate Sw [vtable] */
  {229,22080,52,0}, /* LFO Tempo Rate Sw [vtable] */
  {230,22096,53,0}, /* LFO Tempo Rate [vtable-multi] */
  {231,22112,22,0}, /* LFO Rate [vtable] */
  {232,22880,52,0}, /* Gate [vtable] */
  {233,22896,51,0}, /* LFO Trig [vtable] */
  {235,22928,52,0}, /* LFO UseExtGate [vtable] */
  {236,22944,44,0}, /* LFO Delay [vtable] */
  {237,22960,44,0}, /* LFO Delay Sw [vtable] */
  {238,22976,52,0}, /* LFO Sin Sw [vtable] */
  {239,22992,52,0}, /* LFO Tri Sw [vtable] */
  {240,23008,52,0}, /* LFO Sqr Sw [vtable] */
  {241,23024,52,0}, /* LFO Saw Sw [vtable] */
  {242,23040,52,0}, /* LFO Saw(Inv) Sw [vtable] */
  {243,23056,52,0}, /* LFO S&H Sw [vtable] */
  {244,23072,52,0}, /* LFO Noise Sw [vtable] */
  {245,23088,22,0}, /* LFO Noise Mix [vtable] */
  {251,23584,52,0}, /* LFO trigger env sw [vtable] */
  {252,23808,35,1}, /* ENV Attack [name-fallback] */
  {253,23824,50,0}, /* ENV Sustain [vtable] */
  {254,23840,38,1}, /* ENV Decay [name-fallback] */
  {255,23856,38,1}, /* ENV Release [name-fallback] */
  {257,24064,52,0}, /* LFO trigger env sw [vtable] */
  {258,24288,35,1}, /* ENV Attack [name-fallback] */
  {259,24304,50,0}, /* ENV Sustain [vtable] */
  {260,24320,38,1}, /* ENV Decay [name-fallback] */
  {261,24336,38,1}, /* ENV Release [name-fallback] */
  {263,24864,5,0}, /* OSC1 Feet [vtable] */
  {264,24880,52,0}, /* Griffer Bend SW [vtable] */
  {265,24896,52,0}, /* Bend Enable SW [vtable] */
  {270,24976,28,0}, /* Tune [vtable] */
  {273,25024,22,0}, /* Mod Sw [vtable] */
  {275,25056,0,0}, /* LFO Level [vtable] */
  {276,25072,52,0}, /* LFO Sw [vtable] */
  {279,25120,52,0}, /* ENV Sw [vtable] */
  {280,25136,26,0}, /* Bend Level [vtable] */
  {281,25152,21,1}, /* Bend Range [name-fallback] */
  {282,25168,45,0}, /* PWM Level [vtable] */
  {283,25216,54,0}, /* JU OSC Saw Lev [vtable] */
  {284,25232,54,0}, /* JU OSC Sqr Lev [vtable] */
  {285,25248,54,0}, /* JU OSC Sub Lev [vtable] */
  {286,26544,27,1}, /* Duty Tune [name-fallback] */
  {288,27536,54,0}, /* Osc1 Level [vtable] */
  {289,27552,54,0}, /* Osc Noise Level [vtable] */
  {290,27744,52,0}, /* Griffer SW [vtable] */
  {291,27760,22,0}, /* LPF Cutoff [vtable] */
  {292,27856,22,0}, /* LPF Resonance [vtable] */
  {293,27888,56,0}, /* Velocity [vtable] */
  {294,28032,52,0}, /* Env1/2 [vtable] */
  {295,28048,52,0}, /* Int/Env [vtable] */
  {297,28336,52,0}, /* Ext LFO Sw [vtable] */
  {298,28352,52,0}, /* GRF Bned SW [vtable] */
  {299,28368,47,0}, /* LFO Level [vtable] */
  {301,28400,22,0}, /* MOD SW [vtable] */
  {302,28416,46,0}, /* ENV Level [vtable] */
  {303,28432,24,0}, /* KCV Level [vtable] */
  {304,28448,22,0}, /* Velocity Sens [vtable] */
  {305,28464,56,0}, /* Velocity Offset [vtable] */
  {306,28480,26,0}, /* Bend Level [vtable] */
  {307,28496,21,1}, /* Bend Range [name-fallback] */
  {309,28640,31,0}, /* Resonance Tune [vtable] */
  {315,30608,24,0}, /* AMP TONE [vtable] */
  {316,30624,22,0}, /* AMP VELOCITY SENS [vtable] */
  {317,30640,57,0}, /* AMP FIX VELOCITY LEVEL [vtable] */
  {318,30704,57,0}, /* Velocity [vtable] */
  {319,30848,51,0}, /* Mute [vtable] */
  {323,31248,52,0}, /* Ext ENV SW [vtable] */
  {324,31264,41,1}, /* HPF Cutoff [name-fallback] */
  {328,31328,22,0}, /* ENV LEVEL [vtable] */
  {330,31808,52,0}, /* UseExtJack [vtable] */
  {331,31840,32,1}, /* M.CV [name-fallback] */
  {333,31904,6,0}, /* Master Tune [vtable-multi] */
  {334,31920,27,0}, /* Part Tune [vtable] */
  {335,32128,52,0}, /* Portamento OnOff [vtable] */
  {336,32144,52,0}, /* Portamento Mode [vtable] */
  {337,32160,7,0}, /* Portamento Time [vtable] */
  {338,32576,52,0}, /* LFO Griffer Rate Sw [vtable] */
  {339,32592,52,0}, /* LFO Tempo Rate Sw [vtable] */
  {340,32608,53,0}, /* LFO Tempo Rate [vtable-multi] */
  {341,32624,22,0}, /* LFO Rate [vtable] */
  {342,33392,52,0}, /* Gate [vtable] */
  {343,33408,51,0}, /* LFO Trig [vtable] */
  {345,33440,52,0}, /* LFO UseExtGate [vtable] */
  {346,33456,44,0}, /* LFO Delay [vtable] */
  {347,33472,44,0}, /* LFO Delay Sw [vtable] */
  {348,33488,52,0}, /* LFO Sin Sw [vtable] */
  {349,33504,52,0}, /* LFO Tri Sw [vtable] */
  {350,33520,52,0}, /* LFO Sqr Sw [vtable] */
  {351,33536,52,0}, /* LFO Saw Sw [vtable] */
  {352,33552,52,0}, /* LFO Saw(Inv) Sw [vtable] */
  {353,33568,52,0}, /* LFO S&H Sw [vtable] */
  {354,33584,52,0}, /* LFO Noise Sw [vtable] */
  {355,33600,22,0}, /* LFO Noise Mix [vtable] */
  {361,34096,52,0}, /* LFO trigger env sw [vtable] */
  {362,34320,35,1}, /* ENV Attack [name-fallback] */
  {363,34336,50,0}, /* ENV Sustain [vtable] */
  {364,34352,38,1}, /* ENV Decay [name-fallback] */
  {365,34368,38,1}, /* ENV Release [name-fallback] */
  {367,34576,52,0}, /* LFO trigger env sw [vtable] */
  {368,34800,35,1}, /* ENV Attack [name-fallback] */
  {369,34816,50,0}, /* ENV Sustain [vtable] */
  {370,34832,38,1}, /* ENV Decay [name-fallback] */
  {371,34848,38,1}, /* ENV Release [name-fallback] */
  {373,35376,5,0}, /* OSC1 Feet [vtable] */
  {374,35392,52,0}, /* Griffer Bend SW [vtable] */
  {375,35408,52,0}, /* Bend Enable SW [vtable] */
  {380,35488,28,0}, /* Tune [vtable] */
  {383,35536,22,0}, /* Mod Sw [vtable] */
  {385,35568,0,0}, /* LFO Level [vtable] */
  {386,35584,52,0}, /* LFO Sw [vtable] */
  {389,35632,52,0}, /* ENV Sw [vtable] */
  {390,35648,26,0}, /* Bend Level [vtable] */
  {391,35664,21,1}, /* Bend Range [name-fallback] */
  {392,35680,45,0}, /* PWM Level [vtable] */
  {393,35728,54,0}, /* JU OSC Saw Lev [vtable] */
  {394,35744,54,0}, /* JU OSC Sqr Lev [vtable] */
  {395,35760,54,0}, /* JU OSC Sub Lev [vtable] */
  {396,37056,27,1}, /* Duty Tune [name-fallback] */
  {398,38048,54,0}, /* Osc1 Level [vtable] */
  {399,38064,54,0}, /* Osc Noise Level [vtable] */
  {400,38256,52,0}, /* Griffer SW [vtable] */
  {401,38272,22,0}, /* LPF Cutoff [vtable] */
  {402,38368,22,0}, /* LPF Resonance [vtable] */
  {403,38400,56,0}, /* Velocity [vtable] */
  {404,38544,52,0}, /* Env1/2 [vtable] */
  {405,38560,52,0}, /* Int/Env [vtable] */
  {407,38848,52,0}, /* Ext LFO Sw [vtable] */
  {408,38864,52,0}, /* GRF Bned SW [vtable] */
  {409,38880,47,0}, /* LFO Level [vtable] */
  {411,38912,22,0}, /* MOD SW [vtable] */
  {412,38928,46,0}, /* ENV Level [vtable] */
  {413,38944,24,0}, /* KCV Level [vtable] */
  {414,38960,22,0}, /* Velocity Sens [vtable] */
  {415,38976,56,0}, /* Velocity Offset [vtable] */
  {416,38992,26,0}, /* Bend Level [vtable] */
  {417,39008,21,1}, /* Bend Range [name-fallback] */
  {419,39152,31,0}, /* Resonance Tune [vtable] */
  {425,41120,24,0}, /* AMP TONE [vtable] */
  {426,41136,22,0}, /* AMP VELOCITY SENS [vtable] */
  {427,41152,57,0}, /* AMP FIX VELOCITY LEVEL [vtable] */
  {428,41216,57,0}, /* Velocity [vtable] */
  {429,41360,51,0}, /* Mute [vtable] */
  {433,41760,52,0}, /* Ext ENV SW [vtable] */
  {434,41776,41,1}, /* HPF Cutoff [name-fallback] */
  {438,41840,22,0}, /* ENV LEVEL [vtable] */
  {440,42320,52,0}, /* UseExtJack [vtable] */
  {441,42352,32,1}, /* M.CV [name-fallback] */
  {443,42416,6,0}, /* Master Tune [vtable-multi] */
  {444,42432,27,0}, /* Part Tune [vtable] */
  {445,42640,52,0}, /* Portamento OnOff [vtable] */
  {446,42656,52,0}, /* Portamento Mode [vtable] */
  {447,42672,7,0}, /* Portamento Time [vtable] */
  {448,43088,52,0}, /* LFO Griffer Rate Sw [vtable] */
  {449,43104,52,0}, /* LFO Tempo Rate Sw [vtable] */
  {450,43120,53,0}, /* LFO Tempo Rate [vtable-multi] */
  {451,43136,22,0}, /* LFO Rate [vtable] */
  {452,43904,52,0}, /* Gate [vtable] */
  {453,43920,51,0}, /* LFO Trig [vtable] */
  {455,43952,52,0}, /* LFO UseExtGate [vtable] */
  {456,43968,44,0}, /* LFO Delay [vtable] */
  {457,43984,44,0}, /* LFO Delay Sw [vtable] */
  {458,44000,52,0}, /* LFO Sin Sw [vtable] */
  {459,44016,52,0}, /* LFO Tri Sw [vtable] */
  {460,44032,52,0}, /* LFO Sqr Sw [vtable] */
  {461,44048,52,0}, /* LFO Saw Sw [vtable] */
  {462,44064,52,0}, /* LFO Saw(Inv) Sw [vtable] */
  {463,44080,52,0}, /* LFO S&H Sw [vtable] */
  {464,44096,52,0}, /* LFO Noise Sw [vtable] */
  {465,44112,22,0}, /* LFO Noise Mix [vtable] */
  {471,44608,52,0}, /* LFO trigger env sw [vtable] */
  {472,44832,35,1}, /* ENV Attack [name-fallback] */
  {473,44848,50,0}, /* ENV Sustain [vtable] */
  {474,44864,38,1}, /* ENV Decay [name-fallback] */
  {475,44880,38,1}, /* ENV Release [name-fallback] */
  {477,45088,52,0}, /* LFO trigger env sw [vtable] */
  {478,45312,35,1}, /* ENV Attack [name-fallback] */
  {479,45328,50,0}, /* ENV Sustain [vtable] */
  {480,45344,38,1}, /* ENV Decay [name-fallback] */
  {481,45360,38,1}, /* ENV Release [name-fallback] */
  {483,45888,5,0}, /* OSC1 Feet [vtable] */
  {484,45904,52,0}, /* Griffer Bend SW [vtable] */
  {485,45920,52,0}, /* Bend Enable SW [vtable] */
  {490,46000,28,0}, /* Tune [vtable] */
  {493,46048,22,0}, /* Mod Sw [vtable] */
  {495,46080,0,0}, /* LFO Level [vtable] */
  {496,46096,52,0}, /* LFO Sw [vtable] */
  {499,46144,52,0}, /* ENV Sw [vtable] */
  {500,46160,26,0}, /* Bend Level [vtable] */
  {501,46176,21,1}, /* Bend Range [name-fallback] */
  {502,46192,45,0}, /* PWM Level [vtable] */
  {503,46240,54,0}, /* JU OSC Saw Lev [vtable] */
  {504,46256,54,0}, /* JU OSC Sqr Lev [vtable] */
  {505,46272,54,0}, /* JU OSC Sub Lev [vtable] */
  {506,47568,27,1}, /* Duty Tune [name-fallback] */
  {508,48560,54,0}, /* Osc1 Level [vtable] */
  {509,48576,54,0}, /* Osc Noise Level [vtable] */
  {510,48768,52,0}, /* Griffer SW [vtable] */
  {511,48784,22,0}, /* LPF Cutoff [vtable] */
  {512,48880,22,0}, /* LPF Resonance [vtable] */
  {513,48912,56,0}, /* Velocity [vtable] */
  {514,49056,52,0}, /* Env1/2 [vtable] */
  {515,49072,52,0}, /* Int/Env [vtable] */
  {517,49360,52,0}, /* Ext LFO Sw [vtable] */
  {518,49376,52,0}, /* GRF Bned SW [vtable] */
  {519,49392,47,0}, /* LFO Level [vtable] */
  {521,49424,22,0}, /* MOD SW [vtable] */
  {522,49440,46,0}, /* ENV Level [vtable] */
  {523,49456,24,0}, /* KCV Level [vtable] */
  {524,49472,22,0}, /* Velocity Sens [vtable] */
  {525,49488,56,0}, /* Velocity Offset [vtable] */
  {526,49504,26,0}, /* Bend Level [vtable] */
  {527,49520,21,1}, /* Bend Range [name-fallback] */
  {529,49664,31,0}, /* Resonance Tune [vtable] */
  {535,51632,24,0}, /* AMP TONE [vtable] */
  {536,51648,22,0}, /* AMP VELOCITY SENS [vtable] */
  {537,51664,57,0}, /* AMP FIX VELOCITY LEVEL [vtable] */
  {538,51728,57,0}, /* Velocity [vtable] */
  {539,51872,51,0}, /* Mute [vtable] */
  {543,52272,52,0}, /* Ext ENV SW [vtable] */
  {544,52288,41,1}, /* HPF Cutoff [name-fallback] */
  {548,52352,22,0}, /* ENV LEVEL [vtable] */
  {550,52832,52,0}, /* UseExtJack [vtable] */
  {551,52864,32,1}, /* M.CV [name-fallback] */
  {553,52928,6,0}, /* Master Tune [vtable-multi] */
  {554,52944,27,0}, /* Part Tune [vtable] */
  {555,53152,52,0}, /* Portamento OnOff [vtable] */
  {556,53168,52,0}, /* Portamento Mode [vtable] */
  {557,53184,7,0}, /* Portamento Time [vtable] */
  {558,53600,52,0}, /* LFO Griffer Rate Sw [vtable] */
  {559,53616,52,0}, /* LFO Tempo Rate Sw [vtable] */
  {560,53632,53,0}, /* LFO Tempo Rate [vtable-multi] */
  {561,53648,22,0}, /* LFO Rate [vtable] */
  {562,54416,52,0}, /* Gate [vtable] */
  {563,54432,51,0}, /* LFO Trig [vtable] */
  {565,54464,52,0}, /* LFO UseExtGate [vtable] */
  {566,54480,44,0}, /* LFO Delay [vtable] */
  {567,54496,44,0}, /* LFO Delay Sw [vtable] */
  {568,54512,52,0}, /* LFO Sin Sw [vtable] */
  {569,54528,52,0}, /* LFO Tri Sw [vtable] */
  {570,54544,52,0}, /* LFO Sqr Sw [vtable] */
  {571,54560,52,0}, /* LFO Saw Sw [vtable] */
  {572,54576,52,0}, /* LFO Saw(Inv) Sw [vtable] */
  {573,54592,52,0}, /* LFO S&H Sw [vtable] */
  {574,54608,52,0}, /* LFO Noise Sw [vtable] */
  {575,54624,22,0}, /* LFO Noise Mix [vtable] */
  {581,55120,52,0}, /* LFO trigger env sw [vtable] */
  {582,55344,35,1}, /* ENV Attack [name-fallback] */
  {583,55360,50,0}, /* ENV Sustain [vtable] */
  {584,55376,38,1}, /* ENV Decay [name-fallback] */
  {585,55392,38,1}, /* ENV Release [name-fallback] */
  {587,55600,52,0}, /* LFO trigger env sw [vtable] */
  {588,55824,35,1}, /* ENV Attack [name-fallback] */
  {589,55840,50,0}, /* ENV Sustain [vtable] */
  {590,55856,38,1}, /* ENV Decay [name-fallback] */
  {591,55872,38,1}, /* ENV Release [name-fallback] */
  {593,56400,5,0}, /* OSC1 Feet [vtable] */
  {594,56416,52,0}, /* Griffer Bend SW [vtable] */
  {595,56432,52,0}, /* Bend Enable SW [vtable] */
  {600,56512,28,0}, /* Tune [vtable] */
  {603,56560,22,0}, /* Mod Sw [vtable] */
  {605,56592,0,0}, /* LFO Level [vtable] */
  {606,56608,52,0}, /* LFO Sw [vtable] */
  {609,56656,52,0}, /* ENV Sw [vtable] */
  {610,56672,26,0}, /* Bend Level [vtable] */
  {611,56688,21,1}, /* Bend Range [name-fallback] */
  {612,56704,45,0}, /* PWM Level [vtable] */
  {613,56752,54,0}, /* JU OSC Saw Lev [vtable] */
  {614,56768,54,0}, /* JU OSC Sqr Lev [vtable] */
  {615,56784,54,0}, /* JU OSC Sub Lev [vtable] */
  {616,58080,27,1}, /* Duty Tune [name-fallback] */
  {618,59072,54,0}, /* Osc1 Level [vtable] */
  {619,59088,54,0}, /* Osc Noise Level [vtable] */
  {620,59280,52,0}, /* Griffer SW [vtable] */
  {621,59296,22,0}, /* LPF Cutoff [vtable] */
  {622,59392,22,0}, /* LPF Resonance [vtable] */
  {623,59424,56,0}, /* Velocity [vtable] */
  {624,59568,52,0}, /* Env1/2 [vtable] */
  {625,59584,52,0}, /* Int/Env [vtable] */
  {627,59872,52,0}, /* Ext LFO Sw [vtable] */
  {628,59888,52,0}, /* GRF Bned SW [vtable] */
  {629,59904,47,0}, /* LFO Level [vtable] */
  {631,59936,22,0}, /* MOD SW [vtable] */
  {632,59952,46,0}, /* ENV Level [vtable] */
  {633,59968,24,0}, /* KCV Level [vtable] */
  {634,59984,22,0}, /* Velocity Sens [vtable] */
  {635,60000,56,0}, /* Velocity Offset [vtable] */
  {636,60016,26,0}, /* Bend Level [vtable] */
  {637,60032,21,1}, /* Bend Range [name-fallback] */
  {639,60176,31,0}, /* Resonance Tune [vtable] */
  {645,62144,24,0}, /* AMP TONE [vtable] */
  {646,62160,22,0}, /* AMP VELOCITY SENS [vtable] */
  {647,62176,57,0}, /* AMP FIX VELOCITY LEVEL [vtable] */
  {648,62240,57,0}, /* Velocity [vtable] */
  {649,62384,51,0}, /* Mute [vtable] */
  {653,62784,52,0}, /* Ext ENV SW [vtable] */
  {654,62800,41,1}, /* HPF Cutoff [name-fallback] */
  {658,62864,22,0}, /* ENV LEVEL [vtable] */
  {660,63344,52,0}, /* UseExtJack [vtable] */
  {661,63376,32,1}, /* M.CV [name-fallback] */
  {663,63440,6,0}, /* Master Tune [vtable-multi] */
  {664,63456,27,0}, /* Part Tune [vtable] */
  {665,63664,52,0}, /* Portamento OnOff [vtable] */
  {666,63680,52,0}, /* Portamento Mode [vtable] */
  {667,63696,7,0}, /* Portamento Time [vtable] */
  {668,64112,52,0}, /* LFO Griffer Rate Sw [vtable] */
  {669,64128,52,0}, /* LFO Tempo Rate Sw [vtable] */
  {670,64144,53,0}, /* LFO Tempo Rate [vtable-multi] */
  {671,64160,22,0}, /* LFO Rate [vtable] */
  {672,64928,52,0}, /* Gate [vtable] */
  {673,64944,51,0}, /* LFO Trig [vtable] */
  {675,64976,52,0}, /* LFO UseExtGate [vtable] */
  {676,64992,44,0}, /* LFO Delay [vtable] */
  {677,65008,44,0}, /* LFO Delay Sw [vtable] */
  {678,65024,52,0}, /* LFO Sin Sw [vtable] */
  {679,65040,52,0}, /* LFO Tri Sw [vtable] */
  {680,65056,52,0}, /* LFO Sqr Sw [vtable] */
  {681,65072,52,0}, /* LFO Saw Sw [vtable] */
  {682,65088,52,0}, /* LFO Saw(Inv) Sw [vtable] */
  {683,65104,52,0}, /* LFO S&H Sw [vtable] */
  {684,65120,52,0}, /* LFO Noise Sw [vtable] */
  {685,65136,22,0}, /* LFO Noise Mix [vtable] */
  {691,65632,52,0}, /* LFO trigger env sw [vtable] */
  {692,65856,35,1}, /* ENV Attack [name-fallback] */
  {693,65872,50,0}, /* ENV Sustain [vtable] */
  {694,65888,38,1}, /* ENV Decay [name-fallback] */
  {695,65904,38,1}, /* ENV Release [name-fallback] */
  {697,66112,52,0}, /* LFO trigger env sw [vtable] */
  {698,66336,35,1}, /* ENV Attack [name-fallback] */
  {699,66352,50,0}, /* ENV Sustain [vtable] */
  {700,66368,38,1}, /* ENV Decay [name-fallback] */
  {701,66384,38,1}, /* ENV Release [name-fallback] */
  {703,66912,5,0}, /* OSC1 Feet [vtable] */
  {704,66928,52,0}, /* Griffer Bend SW [vtable] */
  {705,66944,52,0}, /* Bend Enable SW [vtable] */
  {710,67024,28,0}, /* Tune [vtable] */
  {713,67072,22,0}, /* Mod Sw [vtable] */
  {715,67104,0,0}, /* LFO Level [vtable] */
  {716,67120,52,0}, /* LFO Sw [vtable] */
  {719,67168,52,0}, /* ENV Sw [vtable] */
  {720,67184,26,0}, /* Bend Level [vtable] */
  {721,67200,21,1}, /* Bend Range [name-fallback] */
  {722,67216,45,0}, /* PWM Level [vtable] */
  {723,67264,54,0}, /* JU OSC Saw Lev [vtable] */
  {724,67280,54,0}, /* JU OSC Sqr Lev [vtable] */
  {725,67296,54,0}, /* JU OSC Sub Lev [vtable] */
  {726,68592,27,1}, /* Duty Tune [name-fallback] */
  {728,69584,54,0}, /* Osc1 Level [vtable] */
  {729,69600,54,0}, /* Osc Noise Level [vtable] */
  {730,69792,52,0}, /* Griffer SW [vtable] */
  {731,69808,22,0}, /* LPF Cutoff [vtable] */
  {732,69904,22,0}, /* LPF Resonance [vtable] */
  {733,69936,56,0}, /* Velocity [vtable] */
  {734,70080,52,0}, /* Env1/2 [vtable] */
  {735,70096,52,0}, /* Int/Env [vtable] */
  {737,70384,52,0}, /* Ext LFO Sw [vtable] */
  {738,70400,52,0}, /* GRF Bned SW [vtable] */
  {739,70416,47,0}, /* LFO Level [vtable] */
  {741,70448,22,0}, /* MOD SW [vtable] */
  {742,70464,46,0}, /* ENV Level [vtable] */
  {743,70480,24,0}, /* KCV Level [vtable] */
  {744,70496,22,0}, /* Velocity Sens [vtable] */
  {745,70512,56,0}, /* Velocity Offset [vtable] */
  {746,70528,26,0}, /* Bend Level [vtable] */
  {747,70544,21,1}, /* Bend Range [name-fallback] */
  {749,70688,31,0}, /* Resonance Tune [vtable] */
  {755,72656,24,0}, /* AMP TONE [vtable] */
  {756,72672,22,0}, /* AMP VELOCITY SENS [vtable] */
  {757,72688,57,0}, /* AMP FIX VELOCITY LEVEL [vtable] */
  {758,72752,57,0}, /* Velocity [vtable] */
  {759,72896,51,0}, /* Mute [vtable] */
  {763,73296,52,0}, /* Ext ENV SW [vtable] */
  {764,73312,41,1}, /* HPF Cutoff [name-fallback] */
  {768,73376,22,0}, /* ENV LEVEL [vtable] */
  {770,73856,52,0}, /* UseExtJack [vtable] */
  {771,73888,32,1}, /* M.CV [name-fallback] */
  {773,73952,6,1}, /* Master Tune [name-fallback] */
  {774,73968,27,1}, /* Part Tune [name-fallback] */
  {775,74176,52,1}, /* Portamento OnOff [name-fallback] */
  {776,74192,52,1}, /* Portamento Mode [name-fallback] */
  {778,74624,52,0}, /* LFO Griffer Rate Sw [vtable] */
  {779,74640,52,0}, /* LFO Tempo Rate Sw [vtable] */
  {780,74656,53,0}, /* LFO Tempo Rate [vtable-multi] */
  {781,74672,22,0}, /* LFO Rate [vtable] */
  {782,75440,52,0}, /* Gate [vtable] */
  {783,75456,51,0}, /* LFO Trig [vtable] */
  {785,75488,52,0}, /* LFO UseExtGate [vtable] */
  {786,75504,44,0}, /* LFO Delay [vtable] */
  {787,75520,44,0}, /* LFO Delay Sw [vtable] */
  {788,75536,52,0}, /* LFO Sin Sw [vtable] */
  {789,75552,52,0}, /* LFO Tri Sw [vtable] */
  {790,75568,52,0}, /* LFO Sqr Sw [vtable] */
  {791,75584,52,0}, /* LFO Saw Sw [vtable] */
  {792,75600,52,0}, /* LFO Saw(Inv) Sw [vtable] */
  {793,75616,52,0}, /* LFO S&H Sw [vtable] */
  {794,75632,52,0}, /* LFO Noise Sw [vtable] */
  {795,75648,22,0}, /* LFO Noise Mix [vtable] */
  {801,76144,52,0}, /* LFO trigger env sw [vtable] */
  {802,76368,35,1}, /* ENV Attack [name-fallback] */
  {803,76384,50,0}, /* ENV Sustain [vtable] */
  {804,76400,38,1}, /* ENV Decay [name-fallback] */
  {805,76416,38,1}, /* ENV Release [name-fallback] */
  {807,76624,52,0}, /* LFO trigger env sw [vtable] */
  {808,76848,35,1}, /* ENV Attack [name-fallback] */
  {809,76864,50,0}, /* ENV Sustain [vtable] */
  {810,76880,38,1}, /* ENV Decay [name-fallback] */
  {811,76896,38,1}, /* ENV Release [name-fallback] */
  {813,77424,5,1}, /* OSC1 Feet [name-fallback] */
  {814,77440,52,1}, /* Griffer Bend SW [name-fallback] */
  {815,77456,52,1}, /* Bend Enable SW [name-fallback] */
  {820,77536,28,1}, /* Tune [name-fallback] */
  {823,77584,22,1}, /* Mod Sw [name-fallback] */
  {826,77632,52,1}, /* LFO Sw [name-fallback] */
  {829,77680,52,1}, /* ENV Sw [name-fallback] */
  {830,77696,26,1}, /* Bend Level [name-fallback] */
  {831,77712,21,1}, /* Bend Range [name-fallback] */
  {832,77728,45,1}, /* PWM Level [name-fallback] */
  {833,77776,54,1}, /* JU OSC Saw Lev [name-fallback] */
  {834,77792,54,1}, /* JU OSC Sqr Lev [name-fallback] */
  {835,77808,54,1}, /* JU OSC Sub Lev [name-fallback] */
  {836,79104,27,1}, /* Duty Tune [name-fallback] */
  {838,80096,54,1}, /* Osc1 Level [name-fallback] */
  {840,80304,52,0}, /* Griffer SW [vtable] */
  {841,80320,22,0}, /* LPF Cutoff [vtable] */
  {842,80416,22,0}, /* LPF Resonance [vtable] */
  {843,80448,56,0}, /* Velocity [vtable] */
  {844,80592,52,0}, /* Env1/2 [vtable] */
  {845,80608,52,0}, /* Int/Env [vtable] */
  {847,80896,52,0}, /* Ext LFO Sw [vtable] */
  {848,80912,52,0}, /* GRF Bned SW [vtable] */
  {849,80928,47,0}, /* LFO Level [vtable] */
  {851,80960,22,0}, /* MOD SW [vtable] */
  {852,80976,46,0}, /* ENV Level [vtable] */
  {853,80992,24,0}, /* KCV Level [vtable] */
  {854,81008,22,0}, /* Velocity Sens [vtable] */
  {855,81024,56,0}, /* Velocity Offset [vtable] */
  {856,81040,26,0}, /* Bend Level [vtable] */
  {857,81056,21,1}, /* Bend Range [name-fallback] */
  {859,81200,31,0}, /* Resonance Tune [vtable] */
  {865,83168,24,0}, /* AMP TONE [vtable] */
  {866,83184,22,0}, /* AMP VELOCITY SENS [vtable] */
  {867,83200,57,0}, /* AMP FIX VELOCITY LEVEL [vtable] */
  {868,83264,57,0}, /* Velocity [vtable] */
  {869,83408,51,0}, /* Mute [vtable] */
  {873,83808,52,0}, /* Ext ENV SW [vtable] */
  {874,83824,41,1}, /* HPF Cutoff [name-fallback] */
  {878,83888,22,0}, /* ENV LEVEL [vtable] */
  {880,84304,52,0}, /* Ext Noise Sw [vtable] */
  {907,91136,64,0}, /* Error Depth [oracle] */
  {908,91152,22,1}, /* LFO Rate [name-fallback] */
  {910,91184,64,0}, /* LFO Depth [oracle] */
  {912,91216,22,0}, /* Dry Level [vtable] */
  {913,91232,64,0}, /* Wet Level [oracle] */
  {914,91248,64,0}, /* Ip Fc [oracle] */
  {915,91264,52,0}, /* On/Off [vtable] */
  {916,91280,51,1}, /* Mute [name-fallback] */
  {918,96352,22,0}, /* LFO Rate [vtable] */
  {919,96368,64,0}, /* LFO Depth [oracle] */
  {920,96384,64,0}, /* Ip Fc [oracle] */
  {921,96400,22,0}, /* On/Off [vtable-multi] */
  {922,96416,51,1}, /* Mute [name-fallback] */
  {923,101072,49,0}, /* Patch Level [oracle] */
  {924,101136,18,0}, /* Expression [vtable] */
  {925,101152,19,0}, /* Volume [oracle] */
  {950,102464,55,0}, /* High Cut Fc [oracle] */
  {953,102512,22,1}, /* Dry Level [name-fallback] */
  {955,102544,64,1}, /* Ip Fc [name-fallback] */
  {956,102560,21,1}, /* Feedback [name-fallback] */
  {958,102592,51,1}, /* Mute [name-fallback] */
  {959,102608,57,0}, /* LF Damp Fc [oracle] */
  {962,102656,55,0}, /* HF Damp Fc [oracle] */
  {972,4297696,55,0}, /* High Cut Fc [oracle] */
  {975,4297744,22,1}, /* Dry Level [name-fallback] */
  {977,4297776,64,1}, /* Ip Fc [name-fallback] */
  {978,4297792,21,0}, /* Tap Time [oracle] */
  {979,4297808,21,0}, /* Feedback [oracle] */
  {981,4297840,51,1}, /* Mute [name-fallback] */
  {984,4297888,4,0}, /* Wet Gain [oracle] */
  {985,4297904,57,0}, /* LF Damp Fc [oracle] */
  {988,4297952,55,0}, /* HF Damp Fc [oracle] */
  {995,6396160,4,0}, /* LFO Manual [oracle] */
  {1003,6396288,55,0}, /* High Cut Fc [oracle] */
  {1006,6396336,64,0}, /* Low Cut Fc [oracle] */
  {1008,6396368,22,1}, /* Dry Level [name-fallback] */
  {1010,6396400,64,0}, /* Ip Fc [oracle] */
  {1011,6396416,21,1}, /* Feedback [name-fallback] */
  {1013,6396448,51,1}, /* Mute [name-fallback] */
  {1017,6396512,4,1}, /* Wet Gain [name-fallback] */
  {1022,6430496,4,1}, /* LFO Manual [name-fallback] */
  {1030,6430624,55,1}, /* High Cut Fc [name-fallback] */
  {1033,6430672,64,1}, /* Low Cut Fc [name-fallback] */
  {1035,6430704,22,1}, /* Dry Level [name-fallback] */
  {1037,6430736,64,1}, /* Ip Fc [name-fallback] */
  {1038,6430752,21,1}, /* Feedback [name-fallback] */
  {1040,6430784,51,1}, /* Mute [name-fallback] */
  {1041,6430800,20,1}, /* LFO St.Phase [name-fallback] */
  {1050,6497280,55,0}, /* High Cut Fc [oracle] */
  {1053,6497328,22,1}, /* Dry Level [name-fallback] */
  {1054,6497344,21,0}, /* Wet Level [oracle] */
  {1055,6497360,64,1}, /* Ip Fc [name-fallback] */
  {1056,6497376,21,0}, /* Feedback [oracle] */
  {1058,6497408,51,1}, /* Mute [name-fallback] */
  {1059,6497424,57,0}, /* LF Damp Fc [oracle] */
  {1062,6497472,55,0}, /* HF Damp Fc [oracle] */
  {1069,10693040,4,0}, /* LFO Manual [oracle] */
  {1070,10693056,22,0}, /* LFO Depth [oracle] */
  {1077,10693168,55,0}, /* High Cut Fc [oracle] */
  {1080,10693216,64,0}, /* Low Cut Fc [oracle] */
  {1082,10693248,22,1}, /* Dry Level [name-fallback] */
  {1084,10693280,64,0}, /* Ip Fc [oracle] */
  {1085,10693296,21,1}, /* Feedback [name-fallback] */
  {1087,10693328,51,1}, /* Mute [name-fallback] */
  {1088,10693344,20,0}, /* LFO St.Phase [oracle] */
  {1092,10759392,4,0}, /* Rev Ecf Density [oracle] */
  {1095,10759440,21,0}, /* Rev Ecf Glb Lev [oracle] */
};
