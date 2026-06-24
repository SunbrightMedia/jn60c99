/* juno_param_table.h - paramID/offset -> denormalize tableId.
   src=0 definitive (matched in PD Juno Pad capture, bit-exact);
   src=1 inferred from consistent name->tableId grouping (UNVALIDATED).
   Full rigorous coverage of all 1121 params needs the controller vtable wiring. */
typedef struct { int paramId, offset, tableId, inferred; } juno_param_ent;
#define JUNO_PARAM_TABLE_N 243
static const juno_param_ent JUNO_PARAM_TABLE[JUNO_PARAM_TABLE_N] = {
  {1,304,32,0}, /* M.CV */
  {7,624,4,0}, /* Portamento Time */
  {16,1920,44,0}, /* LFO Delay */
  {32,2784,35,0}, /* ENV Attack */
  {33,2800,50,0}, /* ENV Sustain */
  {34,2816,38,0}, /* ENV Decay */
  {35,2832,38,0}, /* ENV Release */
  {38,3264,35,0}, /* ENV Attack */
  {39,3280,50,1}, /* ENV Sustain */
  {40,3296,38,0}, /* ENV Decay */
  {41,3312,38,0}, /* ENV Release */
  {55,4032,0,0}, /* LFO Level */
  {61,4128,21,0}, /* Bend Range */
  {62,4144,45,0}, /* PWM Level */
  {63,4192,54,0}, /* JU OSC Saw Lev */
  {65,4224,54,0}, /* JU OSC Sub Lev */
  {66,5520,27,0}, /* Duty Tune */
  {68,6512,54,0}, /* Osc1 Level */
  {69,6528,12,0}, /* Osc Noise Level */
  {73,6864,21,0}, /* Velocity */
  {79,7344,47,0}, /* LFO Level */
  {82,7392,46,0}, /* ENV Level */
  {85,7440,24,0}, /* Velocity Offset */
  {87,7472,21,0}, /* Bend Range */
  {95,9584,21,0}, /* AMP TONE */
  {97,9616,56,0}, /* AMP FIX VELOCITY LEVEL */
  {98,9680,56,0}, /* Velocity */
  {104,10240,41,0}, /* HPF Cutoff */
  {111,10816,32,1}, /* M.CV */
  {117,11136,4,1}, /* Portamento Time */
  {126,12432,44,1}, /* LFO Delay */
  {142,13296,35,1}, /* ENV Attack */
  {143,13312,50,1}, /* ENV Sustain */
  {144,13328,38,1}, /* ENV Decay */
  {145,13344,38,1}, /* ENV Release */
  {148,13776,35,1}, /* ENV Attack */
  {149,13792,50,1}, /* ENV Sustain */
  {150,13808,38,1}, /* ENV Decay */
  {151,13824,38,1}, /* ENV Release */
  {171,14640,21,1}, /* Bend Range */
  {172,14656,45,1}, /* PWM Level */
  {173,14704,54,1}, /* JU OSC Saw Lev */
  {175,14736,54,1}, /* JU OSC Sub Lev */
  {176,16032,27,1}, /* Duty Tune */
  {178,17024,54,1}, /* Osc1 Level */
  {179,17040,12,1}, /* Osc Noise Level */
  {192,17904,46,1}, /* ENV Level */
  {195,17952,24,1}, /* Velocity Offset */
  {197,17984,21,1}, /* Bend Range */
  {205,20096,21,1}, /* AMP TONE */
  {207,20128,56,1}, /* AMP FIX VELOCITY LEVEL */
  {214,20752,41,1}, /* HPF Cutoff */
  {221,21328,32,1}, /* M.CV */
  {227,21648,4,1}, /* Portamento Time */
  {236,22944,44,1}, /* LFO Delay */
  {252,23808,35,1}, /* ENV Attack */
  {253,23824,50,1}, /* ENV Sustain */
  {254,23840,38,1}, /* ENV Decay */
  {255,23856,38,1}, /* ENV Release */
  {258,24288,35,1}, /* ENV Attack */
  {259,24304,50,1}, /* ENV Sustain */
  {260,24320,38,1}, /* ENV Decay */
  {261,24336,38,1}, /* ENV Release */
  {281,25152,21,1}, /* Bend Range */
  {282,25168,45,1}, /* PWM Level */
  {283,25216,54,1}, /* JU OSC Saw Lev */
  {285,25248,54,1}, /* JU OSC Sub Lev */
  {286,26544,27,1}, /* Duty Tune */
  {288,27536,54,1}, /* Osc1 Level */
  {289,27552,12,1}, /* Osc Noise Level */
  {302,28416,46,1}, /* ENV Level */
  {305,28464,24,1}, /* Velocity Offset */
  {307,28496,21,1}, /* Bend Range */
  {315,30608,21,1}, /* AMP TONE */
  {317,30640,56,1}, /* AMP FIX VELOCITY LEVEL */
  {324,31264,41,1}, /* HPF Cutoff */
  {331,31840,32,1}, /* M.CV */
  {337,32160,4,1}, /* Portamento Time */
  {346,33456,44,1}, /* LFO Delay */
  {362,34320,35,1}, /* ENV Attack */
  {363,34336,50,1}, /* ENV Sustain */
  {364,34352,38,1}, /* ENV Decay */
  {365,34368,38,1}, /* ENV Release */
  {368,34800,35,1}, /* ENV Attack */
  {369,34816,50,1}, /* ENV Sustain */
  {370,34832,38,1}, /* ENV Decay */
  {371,34848,38,1}, /* ENV Release */
  {391,35664,21,1}, /* Bend Range */
  {392,35680,45,1}, /* PWM Level */
  {393,35728,54,1}, /* JU OSC Saw Lev */
  {395,35760,54,1}, /* JU OSC Sub Lev */
  {396,37056,27,1}, /* Duty Tune */
  {398,38048,54,1}, /* Osc1 Level */
  {399,38064,12,1}, /* Osc Noise Level */
  {412,38928,46,1}, /* ENV Level */
  {415,38976,24,1}, /* Velocity Offset */
  {417,39008,21,1}, /* Bend Range */
  {425,41120,21,1}, /* AMP TONE */
  {427,41152,56,1}, /* AMP FIX VELOCITY LEVEL */
  {434,41776,41,1}, /* HPF Cutoff */
  {441,42352,32,1}, /* M.CV */
  {447,42672,4,1}, /* Portamento Time */
  {456,43968,44,1}, /* LFO Delay */
  {472,44832,35,1}, /* ENV Attack */
  {473,44848,50,1}, /* ENV Sustain */
  {474,44864,38,1}, /* ENV Decay */
  {475,44880,38,1}, /* ENV Release */
  {478,45312,35,1}, /* ENV Attack */
  {479,45328,50,1}, /* ENV Sustain */
  {480,45344,38,1}, /* ENV Decay */
  {481,45360,38,1}, /* ENV Release */
  {501,46176,21,1}, /* Bend Range */
  {502,46192,45,1}, /* PWM Level */
  {503,46240,54,1}, /* JU OSC Saw Lev */
  {505,46272,54,1}, /* JU OSC Sub Lev */
  {506,47568,27,1}, /* Duty Tune */
  {508,48560,54,1}, /* Osc1 Level */
  {509,48576,12,1}, /* Osc Noise Level */
  {522,49440,46,1}, /* ENV Level */
  {525,49488,24,1}, /* Velocity Offset */
  {527,49520,21,1}, /* Bend Range */
  {535,51632,21,1}, /* AMP TONE */
  {537,51664,56,1}, /* AMP FIX VELOCITY LEVEL */
  {544,52288,41,1}, /* HPF Cutoff */
  {551,52864,32,1}, /* M.CV */
  {557,53184,4,1}, /* Portamento Time */
  {566,54480,44,1}, /* LFO Delay */
  {582,55344,35,1}, /* ENV Attack */
  {583,55360,50,1}, /* ENV Sustain */
  {584,55376,38,1}, /* ENV Decay */
  {585,55392,38,1}, /* ENV Release */
  {588,55824,35,1}, /* ENV Attack */
  {589,55840,50,1}, /* ENV Sustain */
  {590,55856,38,1}, /* ENV Decay */
  {591,55872,38,1}, /* ENV Release */
  {611,56688,21,1}, /* Bend Range */
  {612,56704,45,1}, /* PWM Level */
  {613,56752,54,1}, /* JU OSC Saw Lev */
  {615,56784,54,1}, /* JU OSC Sub Lev */
  {616,58080,27,1}, /* Duty Tune */
  {618,59072,54,1}, /* Osc1 Level */
  {619,59088,12,1}, /* Osc Noise Level */
  {632,59952,46,1}, /* ENV Level */
  {635,60000,24,1}, /* Velocity Offset */
  {637,60032,21,1}, /* Bend Range */
  {645,62144,21,1}, /* AMP TONE */
  {647,62176,56,1}, /* AMP FIX VELOCITY LEVEL */
  {654,62800,41,1}, /* HPF Cutoff */
  {661,63376,32,1}, /* M.CV */
  {667,63696,4,1}, /* Portamento Time */
  {676,64992,44,1}, /* LFO Delay */
  {692,65856,35,1}, /* ENV Attack */
  {693,65872,50,1}, /* ENV Sustain */
  {694,65888,38,1}, /* ENV Decay */
  {695,65904,38,1}, /* ENV Release */
  {698,66336,35,1}, /* ENV Attack */
  {699,66352,50,1}, /* ENV Sustain */
  {700,66368,38,1}, /* ENV Decay */
  {701,66384,38,1}, /* ENV Release */
  {721,67200,21,1}, /* Bend Range */
  {722,67216,45,1}, /* PWM Level */
  {723,67264,54,1}, /* JU OSC Saw Lev */
  {725,67296,54,1}, /* JU OSC Sub Lev */
  {726,68592,27,1}, /* Duty Tune */
  {728,69584,54,1}, /* Osc1 Level */
  {729,69600,12,1}, /* Osc Noise Level */
  {742,70464,46,1}, /* ENV Level */
  {745,70512,24,1}, /* Velocity Offset */
  {747,70544,21,1}, /* Bend Range */
  {755,72656,21,1}, /* AMP TONE */
  {757,72688,56,1}, /* AMP FIX VELOCITY LEVEL */
  {764,73312,41,1}, /* HPF Cutoff */
  {771,73888,32,1}, /* M.CV */
  {777,74208,4,1}, /* Portamento Time */
  {786,75504,44,1}, /* LFO Delay */
  {802,76368,35,1}, /* ENV Attack */
  {803,76384,50,1}, /* ENV Sustain */
  {804,76400,38,1}, /* ENV Decay */
  {805,76416,38,1}, /* ENV Release */
  {808,76848,35,1}, /* ENV Attack */
  {809,76864,50,1}, /* ENV Sustain */
  {810,76880,38,1}, /* ENV Decay */
  {811,76896,38,1}, /* ENV Release */
  {831,77712,21,1}, /* Bend Range */
  {832,77728,45,1}, /* PWM Level */
  {833,77776,54,1}, /* JU OSC Saw Lev */
  {835,77808,54,1}, /* JU OSC Sub Lev */
  {836,79104,27,1}, /* Duty Tune */
  {838,80096,54,1}, /* Osc1 Level */
  {839,80112,12,1}, /* Osc Noise Level */
  {852,80976,46,1}, /* ENV Level */
  {855,81024,24,1}, /* Velocity Offset */
  {857,81056,21,1}, /* Bend Range */
  {865,83168,21,1}, /* AMP TONE */
  {867,83200,56,1}, /* AMP FIX VELOCITY LEVEL */
  {874,83824,41,1}, /* HPF Cutoff */
  {907,91136,64,0}, /* Error Depth */
  {910,91184,64,0}, /* LFO Depth */
  {913,91232,64,0}, /* Wet Level */
  {914,91248,64,0}, /* Ip Fc */
  {919,96368,64,0}, /* LFO Depth */
  {920,96384,64,0}, /* Ip Fc */
  {923,101072,49,0}, /* Patch Level */
  {925,101152,19,0}, /* Volume */
  {950,102464,55,0}, /* High Cut Fc */
  {955,102544,64,1}, /* Ip Fc */
  {956,102560,21,1}, /* Feedback */
  {959,102608,57,0}, /* LF Damp Fc */
  {962,102656,55,0}, /* HF Damp Fc */
  {972,4297696,55,0}, /* High Cut Fc */
  {977,4297776,64,1}, /* Ip Fc */
  {978,4297792,21,0}, /* Tap Time */
  {979,4297808,21,0}, /* Feedback */
  {984,4297888,4,0}, /* Wet Gain */
  {985,4297904,57,0}, /* LF Damp Fc */
  {988,4297952,55,0}, /* HF Damp Fc */
  {995,6396160,4,0}, /* LFO Manual */
  {1003,6396288,55,0}, /* High Cut Fc */
  {1006,6396336,64,0}, /* Low Cut Fc */
  {1010,6396400,64,0}, /* Ip Fc */
  {1011,6396416,21,1}, /* Feedback */
  {1017,6396512,4,1}, /* Wet Gain */
  {1022,6430496,4,1}, /* LFO Manual */
  {1030,6430624,55,1}, /* High Cut Fc */
  {1033,6430672,64,1}, /* Low Cut Fc */
  {1037,6430736,64,1}, /* Ip Fc */
  {1038,6430752,21,1}, /* Feedback */
  {1041,6430800,20,1}, /* LFO St.Phase */
  {1050,6497280,55,0}, /* High Cut Fc */
  {1054,6497344,21,0}, /* Wet Level */
  {1055,6497360,64,1}, /* Ip Fc */
  {1056,6497376,21,0}, /* Feedback */
  {1059,6497424,57,0}, /* LF Damp Fc */
  {1062,6497472,55,0}, /* HF Damp Fc */
  {1069,10693040,4,0}, /* LFO Manual */
  {1070,10693056,22,0}, /* LFO Depth */
  {1077,10693168,55,0}, /* High Cut Fc */
  {1080,10693216,64,0}, /* Low Cut Fc */
  {1084,10693280,64,0}, /* Ip Fc */
  {1085,10693296,21,1}, /* Feedback */
  {1088,10693344,20,0}, /* LFO St.Phase */
  {1092,10759392,4,0}, /* Rev Ecf Density */
  {1095,10759440,21,0}, /* Rev Ecf Glb Lev */
};
