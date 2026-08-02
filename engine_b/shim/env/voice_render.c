/* engine_b/shim/env/voice_render.c — VERBATIM FORK of src/voice_render.c
 * with ONE block replaced: the two ADSR envelope generators (module M7).
 * Everything else in this file is the port's own code, byte for byte, so a
 * divergence under tools/engineb/null_b.py --module env is attributable to the
 * envelope module and to nothing else. See engine_b/eb_envgen.h.
 */
#include "eb_envgen.h"     /* -I engine_b/ is supplied by the harness */

/* voice_render.c — exact C99 transcription of sub_180369070 (Cloud 60 voice
 * render). Generated first-pass by tools/translate_voice.py then finished by
 * hand for the helper-call args (resolved from asm_dump) and SIMD idioms.
 * The decompile in dsp_dump is the spec; coefficients live in the voice state
 * (written by sub_1803990C0, see init_dump). Build with -fno-strict-aliasing.
 */
#include "juno_engine.h"
#include "juno_dsp.h"
#include "juno_tables.h"
#include <math.h>
#include <string.h>

#define JU(st, off)  (*(uint32_t *)((unsigned char *)(st) + (off)))

static inline float    f32_from_bits(uint32_t b){ float f; memcpy(&f,&b,4); return f; }
static inline uint32_t bits_from_f32(float f){ uint32_t b; memcpy(&b,&f,4); return b; }

/* Render one voice (0..7) of the 8-voice engine.
 *
 * The plugin compiled 8 specialised copies of this function (sub_180369070 =
 * voice 0 .. sub_180383F20 = voice 7). Diffing their decompiled offset constants
 * proves each copy is byte-identical modulo THREE region strides (derived, not
 * guessed — see docs/POLYPHONY.md):
 *   - main per-voice block  offsets [176,10672]  -> +voice*10512   (via a1 below)
 *   - shared global block   offsets [84272,84432] -> +0 (all voices, chained)
 *   - aux one-shot edge      offset 101504         -> +voice*32
 * So this one exact transcription serves every voice: `a1` is the voice's main
 * base (base + voice*10512), the 15 shared sites use `base` unshifted, and the 3
 * aux sites use `base` at 101504+voice*32. voice==0 gives a1==base -> identical
 * to the original voice-0 function bit-for-bit. Render voices in order 0..7 each
 * sample so the shared block chains exactly as the plugin's 8 calls do. */
uint32_t juno_voice_render(unsigned char *base, int voice, float *outL, float *outR)
{
  /* PILOT 2: scratch-cell register promotion, SINGLE-TYPED cells only.
   * These cells are written before read, never carry across samples, and are
   * touched through exactly one of JF/JI -- so the int/float reinterpret hazard
   * that broke pilot 1 (155 dual-typed cells) cannot arise. The memory STORE is
   * kept so master_render/recall/probes are unaffected; only redundant RELOADS
   * go away, which is what stalls an in-order M7 (measured IPC 0.44). Seeded
   * from the cell so any control-flow path is safe. Bit-identical by
   * construction; render A/B + fuzz are the proof. */
  float _s4656 = _s4656;
  float _s4784 = _s4784;
  float _s4800 = _s4800;
  float _s4816 = _s4816;
  float _s4896 = _s4896;
  float _s8336 = _s8336;
  float _s8352 = _s8352;
  float _s8368 = _s8368;
  float _s8384 = _s8384;
  float _s8400 = _s8400;
  float _s8416 = _s8416;
  float _s9008 = _s9008;
  float _s9024 = _s9024;

  float v2; // xmm4_4
  float v5; // xmm0_4
  float v6; // xmm1_4
  float v7; // xmm2_4
  int v8; // edx
  int v9; // edx
  int v10; // eax
  float v11; // xmm3_4
  float v12; // xmm6_4
  int v13; // eax
  float v14; // xmm8_4
  int v15; // ecx
  float v16; // xmm7_4
  signed int v17; // edx
  float v18; // xmm1_4
  double v19; // xmm10_8
  float v20; // xmm0_4
  float v21; // xmm0_4
  float v22; // xmm1_4
  float v23; // xmm2_4
  float v24; // xmm1_4
  float v25; // xmm0_4
  float v26; // xmm2_4
  float v27; // xmm1_4
  float v28; // xmm6_4
  float v29; // xmm3_4
  float v30; // xmm1_4
  float v31; // xmm3_4
  double v32; // xmm0_8
  float v33; // xmm15_4
  float v34; // xmm5_4
  float v35; // xmm0_4
  float v36; // xmm5_4
  float v37; // xmm2_4
  float v38; // xmm1_4
  int v39; // eax
  float v40; // xmm4_4
  float v41; // xmm3_4
  double v42; // xmm12_8
  float v43; // xmm5_4
  float v44; // xmm0_4
  float v45; // xmm5_4
  float v46; // xmm1_4
  float v47; // xmm2_4
  float v48; // xmm2_4
  float v49; // xmm1_4
  float v50; // xmm2_4
  float v51; // xmm2_4
  float v52; // xmm2_4
  float v53; // xmm1_4
  double v54; // xmm0_8
  float v55; // xmm1_4
  float v56; // xmm1_4
  float v57; // xmm7_4
  float v58; // xmm0_4
  float v59; // xmm2_4
  int v60; // xmm9_4
  float v61; // xmm7_4
  int v62; // xmm8_4
  int v63; // eax
  float v64; // xmm7_4
  float v65; // xmm1_4
  int v66; // eax
  float v67; // xmm0_4
  float v68; // xmm2_4
  float v69; // xmm1_4
  float v70; // xmm2_4
  double v71; // xmm0_8
  float v72; // xmm1_4
  double v73; // xmm0_8
  float v74; // xmm6_4
  float v75; // xmm0_4
  float v76; // xmm1_4
  float v77; // xmm0_4
  float v78; // xmm3_4
  float v79; // xmm7_4
  float v80; // xmm2_4
  float v81; // xmm4_4
  int v82; // eax
  float v83; // xmm1_4
  float v84; // xmm0_4
  float v85; // xmm7_4
  float v86; // xmm7_4
  float v87; // xmm6_4
  float v88; // xmm6_4
  float v89; // xmm0_4
  float v90; // xmm0_4
  float v91; // xmm6_4
  float v92; // xmm2_4
  float v93; // xmm6_4
  float v94; // xmm1_4
  float v95; // xmm11_4
  float v96; // xmm0_4
  float v97; // xmm0_4
  float v98; // xmm6_4
  double v99; // xmm1_8
  float v100; // xmm0_4
  float v101; // xmm7_4
  float v102; // xmm7_4
  float v103; // xmm8_4
  float v104; // xmm0_4
  float v105; // xmm8_4
  float v106; // xmm0_4
  float v107; // xmm8_4
  float v108; // xmm7_4
  float v109; // xmm0_4
  float v110; // xmm7_4
  float v111; // xmm0_4
  float v112; // xmm6_4
  float v113; // xmm7_4
  float v114; // xmm6_4
  float v115; // xmm4_4
  float v116; // xmm3_4
  float v117; // xmm6_4
  float v118; // xmm4_4
  float v119; // xmm2_4
  float v120; // xmm3_4
  float v121; // xmm4_4
  int v122; // xmm0_4
  float v123; // xmm0_4
  float v124; // xmm1_4
  float v125; // xmm8_4
  float v126; // xmm5_4
  float v127; // xmm7_4
  float v128; // xmm4_4
  float v129; // xmm7_4
  float v130; // xmm6_4
  float v131; // xmm2_4
  float v132; // xmm3_4
  float v133; // xmm4_4
  float v134; // xmm3_4
  float v135; // xmm5_4
  float v136; // xmm7_4
  float v137; // xmm4_4
  float v138; // xmm0_4
  float v139; // xmm3_4
  float v140; // xmm5_4
  float v141; // xmm2_4
  float v142; // xmm3_4
  float v143; // xmm3_4
  float v144; // xmm0_4
  float v145; // xmm0_4
  float v146; // xmm1_4
  float v147; // xmm8_4
  float v148; // xmm5_4
  float v149; // xmm6_4
  float v150; // xmm4_4
  float v151; // xmm6_4
  float v152; // xmm7_4
  float v153; // xmm0_4
  float v154; // xmm2_4
  float v155; // xmm4_4
  float v156; // xmm3_4
  float v157; // xmm5_4
  float v158; // xmm6_4
  float v159; // xmm4_4
  float v160; // xmm0_4
  float v161; // xmm3_4
  float v162; // xmm5_4
  float v163; // xmm2_4
  float v164; // xmm3_4
  float v165; // xmm3_4
  float v166; // xmm0_4
  float v167; // xmm0_4
  float v168; // xmm8_4
  float v169; // xmm8_4
  float v170; // xmm7_4
  int v171; // xmm1_4
  int v172; // xmm2_4
  int v173; // xmm0_4
  float v174; // xmm4_4
  float v175; // xmm5_4
  float v176; // xmm7_4
  float v177; // xmm4_4
  float v178; // xmm2_4
  float v179; // xmm3_4
  float v180; // xmm7_4
  float v181; // xmm6_4
  float v182; // xmm5_4
  float v183; // xmm0_4
  float v184; // xmm3_4
  float v185; // xmm6_4
  float v186; // xmm3_4
  int v187; // xmm0_4
  float v188; // xmm2_4
  int v189; // xmm0_4
  float v190; // xmm4_4
  float v191; // xmm2_4
  float v192; // xmm3_4
  float v193; // xmm0_4
  float v194; // xmm3_4
  float v195; // xmm4_4
  float v196; // xmm1_4
  float v197; // xmm1_4
  float v198; // xmm1_4
  float v199; // xmm0_4
  float v200; // xmm4_4
  float v201; // xmm0_4
  double v202; // xmm0_8
  float v203; // xmm1_4
  float v204; // xmm0_4
  float v205; // xmm1_4
  float v206; // xmm0_4
  float v207; // xmm1_4
  float v208; // xmm0_4
  float v209; // xmm3_4
  float v210; // xmm2_4
  float v211; // xmm3_4
  float v212; // xmm0_4
  float v213; // xmm3_4
  float v214; // xmm1_4
  float v215; // xmm0_4
  float v216; // xmm0_4
  float v217; // xmm7_4
  float v218; // xmm7_4
  float v219; // xmm1_4
  float v220; // xmm0_4
  float v221; // xmm7_4
  float v222; // xmm4_4
  float v223; // xmm5_4
  float v224; // xmm6_4
  float v225; // xmm0_4
  float v226; // xmm3_4
  float v227; uint32_t v227_bits;
  float v228; // xmm7_4
  float v229; // xmm8_4
  float v230; // xmm0_4
  float v231; // xmm6_4
  float v232; // xmm6_4
  float v233; // xmm2_4
  float v234; // xmm1_4
  int v235; // ecx
  float v236; // xmm9_4
  float v237; // xmm6_4
  float v238; // xmm4_4
  float v239; // xmm3_4
  float v240; // xmm8_4
  float v241; // xmm8_4
  float v242; // xmm1_4
  float v243; // xmm9_4
  float v244; // xmm0_4
  float v245; // xmm6_4
  float v246; // xmm6_4
  float v247; // xmm3_4
  float v248; // xmm1_4
  float v249; // xmm5_4
  float v250; // xmm5_4
  float v251; // xmm2_4
  float v252; // xmm1_4
  float v253; // xmm0_4
  float v254; // xmm5_4
  float v255; // xmm5_4
  float v256; // xmm5_4
  float v257; // xmm3_4
  float v258; // xmm4_4
  float v259; // xmm1_4
  float v260; // xmm3_4
  float v261; // xmm4_4
  float v262; // xmm3_4
  float v263; // xmm5_4
  float v264; // xmm2_4
  float v265; // xmm5_4
  float v266; // xmm4_4
  float v267; // xmm2_4
  float v268; // xmm5_4
  float v269; // xmm0_4
  float v270; // xmm5_4
  float v271; // xmm5_4
  float v272; // xmm5_4
  float v273; // xmm5_4
  float v274; // xmm1_4
  float v275; // xmm3_4
  float v276; // xmm4_4
  float v277; // xmm1_4
  float v278; // xmm3_4
  float v279; // xmm4_4
  float v280; // xmm3_4
  float v281; // xmm5_4
  float v282; // xmm2_4
  float v283; // xmm5_4
  float v284; // xmm1_4
  float v285; // xmm4_4
  float v286; // xmm2_4
  float v287; // xmm5_4
  float v288; // xmm0_4
  float v289; // xmm5_4
  float v290; // xmm5_4
  float v291; // xmm5_4
  float v292; // xmm5_4
  float v293; // xmm1_4
  float v294; // xmm3_4
  float v295; // xmm4_4
  float v296; // xmm1_4
  float v297; // xmm3_4
  float v298; // xmm4_4
  float v299; // xmm3_4
  float v300; // xmm5_4
  float v301; // xmm2_4
  float v302; // xmm5_4
  float v303; // xmm3_4
  float v304; // xmm1_4
  float v305; // xmm5_4
  float v306; // xmm0_4
  float v307; // xmm5_4
  float v308; // xmm5_4
  float v309; // xmm5_4
  float v310; // xmm5_4
  float v311; // xmm3_4
  float v312; // xmm4_4
  float v313; // xmm1_4
  float v314; // xmm3_4
  float v315; // xmm4_4
  float v316; // xmm3_4
  float v317; // xmm5_4
  float v318; // xmm2_4
  float v319; // xmm5_4
  float v320; // xmm8_4
  float v321; // xmm3_4
  float v322; // xmm4_4
  float v323; // xmm5_4
  float v324; // xmm5_4
  float v325; // xmm0_4
  float v326; // xmm4_4
  int v327; // xmm0_4
  float v328; // xmm2_4
  float v329; // xmm0_4
  float v330; // xmm2_4
  float v331; // xmm2_4
  float v332; // xmm1_4
  float v333; // xmm3_4
  double v334; // xmm0_8
  float v335; // xmm0_4
  float v336; // xmm1_4
  float v337; // xmm2_4
  float v338; // xmm3_4
  double v339; // xmm0_8
  float v340; // xmm0_4
  float v341; // xmm5_4
  float v342; // xmm6_4
  float v343; // xmm4_4
  float v344; // xmm3_4
  float v345; // xmm4_4
  float v346; // xmm2_4
  float v347; // xmm0_4
  float v348; // xmm7_4
  float v349; // xmm6_4
  float v350; // xmm3_4
  int v351; // xmm0_4
  int v352; // xmm1_4
  float v353; // xmm4_4
  float v354; // xmm2_4
  float v355; // xmm3_4
  float v356; // xmm1_4
  float v357; // xmm6_4
  float v358; // xmm4_4
  float v359; // xmm3_4
  float v360; // xmm1_4
  float v361; // xmm6_4
  float v362; // xmm1_4
  float v363; // xmm7_4
  double v364; // xmm0_8
  float v365; // xmm4_4
  float v366; // xmm5_4
  float v367; // xmm5_4
  float v368; // xmm6_4
  float v369; // xmm2_4
  float v370; // xmm3_4
  float v371; // xmm4_4
  float v372; // xmm0_4
  float v373; // xmm1_4
  float v374; // xmm4_4
  float v375; // xmm2_4
  float v376; // xmm6_4
  float v377; // xmm5_4
  float v378; // xmm4_4
  double v379; // xmm0_8
  float v380; // xmm3_4
  float v381; // xmm3_4
  float v382; // xmm1_4
  float v383; // xmm2_4
  float v384; // xmm2_4
  double v385; // xmm12_8
  double v386; int v386_lo;
  const double *v387;
  double v388; // xmm4_8
  double v389; // xmm8_8
  double v390; // xmm10_8
  float v391; // xmm3_4
  float v392; // xmm5_4
  int v393; // xmm0_4
  int v394; // xmm1_4
  float v395; // xmm5_4
  float v396; // xmm3_4
  float v397; // xmm0_4
  float v398; // xmm2_4
  float v399; // xmm5_4
  double v400; // xmm0_8
  float v401; // xmm6_4
  int v402; // xmm1_4
  float v403; // xmm6_4
  float v404; // xmm7_4
  double v405; // xmm0_8
  float v406; // xmm5_4
  float v407; // xmm5_4
  float v408; // xmm5_4
  float v409; // xmm0_4
  float v410; // xmm3_4
  float v411; // xmm4_4
  float v412; // xmm0_4
  float v413; // xmm6_4
  float v414; // xmm8_4
  float v415; // xmm6_4
  double v416; // xmm0_8
  float v417; // xmm4_4
  float v418; // xmm0_4
  float v419; // xmm7_4
  float v420; // xmm4_4
  float v421; // xmm4_4
  float v422; // xmm4_4
  float v423; // xmm7_4
  float v424; // xmm9_4
  double v425; // xmm0_8
  float v426; // xmm7_4
  float v427; // xmm8_4
  float v428; // xmm8_4
  float v429; // xmm8_4
  float v430; // xmm6_4
  int v431; // xmm5_4
  float v432; // xmm6_4
  float v433; // xmm7_4
  double v434; // xmm0_8
  float v435; // xmm5_4
  float v436; // xmm5_4
  float v437; // xmm5_4
  float v438; // xmm0_4
  float v439; // xmm3_4
  float v440; // xmm4_4
  float v441; // xmm0_4
  float v442; // xmm6_4
  float v443; // xmm8_4
  float v444; // xmm6_4
  double v445; // xmm0_8
  float v446; // xmm4_4
  float v447; // xmm0_4
  float v448; // xmm7_4
  float v449; // xmm4_4
  float v450; // xmm4_4
  float v451; // xmm4_4
  float v452; // xmm7_4
  float v453; // xmm9_4
  double v454; // xmm0_8
  float v455; // xmm7_4
  float v456; // xmm8_4
  float v457; // xmm8_4
  float v458; // xmm8_4
  float v459; // xmm6_4
  int v460; // xmm5_4
  float v461; // xmm6_4
  float v462; // xmm7_4
  double v463; // xmm0_8
  float v464; // xmm5_4
  float v465; // xmm5_4
  float v466; // xmm5_4
  float v467; // xmm0_4
  float v468; // xmm3_4
  float v469; // xmm4_4
  float v470; // xmm0_4
  float v471; // xmm6_4
  float v472; // xmm8_4
  float v473; // xmm6_4
  double v474; // xmm0_8
  float v475; // xmm4_4
  float v476; // xmm0_4
  float v477; // xmm7_4
  float v478; // xmm4_4
  float v479; // xmm4_4
  float v480; // xmm4_4
  float v481; // xmm7_4
  float v482; // xmm9_4
  double v483; // xmm0_8
  float v484; // xmm7_4
  float v485; // xmm8_4
  float v486; // xmm8_4
  float v487; // xmm8_4
  float v488; // xmm6_4
  int v489; // xmm5_4
  float v490; // xmm6_4
  float v491; // xmm7_4
  double v492; // xmm0_8
  float v493; // xmm5_4
  float v494; // xmm5_4
  float v495; // xmm5_4
  float v496; // xmm0_4
  float v497; // xmm3_4
  float v498; // xmm4_4
  float v499; // xmm0_4
  float v500; // xmm6_4
  float v501; // xmm8_4
  float v502; // xmm6_4
  double v503; // xmm0_8
  float v504; // xmm4_4
  float v505; // xmm0_4
  float v506; // xmm7_4
  float v507; // xmm4_4
  float v508; // xmm4_4
  float v509; // xmm4_4
  float v510; // xmm7_4
  float v511; // xmm8_4
  float v512; // xmm0_4
  float v513; // xmm7_4
  float v514; // xmm0_4
  float v515; // xmm15_4
  int v516; // xmm5_4
  int v517; // xmm6_4
  float v518; // xmm2_4
  float v519; // xmm5_4
  float v520; // xmm2_4
  float v521; // xmm4_4
  float v522; // xmm5_4
  float v523; // xmm1_4
  float v524; // xmm5_4
  float v525; // xmm3_4
  float v526; // xmm4_4
  uint32_t result;
  int v528; // [rsp+D0h] [rbp+8h]
  float v529; // [rsp+E0h] [rbp+18h]

  /* Per-voice region bases (see the header comment above). */
  unsigned char *a1 = base + (unsigned)voice * JUNO_VOICE_MAIN_STRIDE;
  unsigned auxoff  = JUNO_VOICE_AUX_BASE0 + (unsigned)voice * JUNO_VOICE_AUX_STRIDE;

  v2 = JF(a1, 320);
  v528 = 0;
  if ( JF(base, auxoff) == 1.0 )
  {
    v528 = JI(a1, 320);
    v2 = 0.0;
    JI(a1, 320) = 0;
  }
  v5 = JF(base, 84336);
  v6 = JF(base, 84272);
  v7 = JF(base, 84304);
  JF(base, 84352) = v5;
  JF(base, 84288) = v6;
  JF(base, 84320) = v7;
  v8 = (int)(float)(v5 * -16777216.0);
  if ( !v8 )
  {
    v9 = 1;
    goto LABEL_11;
  }
  v10 = v8 & 0x200000;
  if ( (v8 & 0x800000) != 0 )
  {
    if ( !v10 )
    {
      v9 = 2 * v8;
      goto LABEL_11;
    }
  }
  else if ( v10 )
  {
    v9 = 2 * v8;
    goto LABEL_11;
  }
  v9 = 2 * v8 + 1;
LABEL_11:
  v11 = JF(a1, 208);
  v12 = JF(a1, 176);
  v13 = v9 & 0xFFFFFF;
  v14 = JF(a1, 368);
  v15 = v9;
  v16 = JF(a1, 384);
  v17 = v9 | 0xFF000000;
  v18 = v6 * v7;
  JI(a1, 432) = 0;
  JF(a1, 224) = v11;
  v19 = 0.0;
  if ( (v15 & 0x1000000) == 0 )
    v17 = v13;
  JF(a1, 192) = v12;
  JI(base, 84384) = JI(base, 84368);
  JI(a1, 512) = JI(a1, 496);
  JF(a1, 352) = v2;
  v20 = (float)v17 * 0.000000059604645;
  JF(a1, 400) = v14;
  JF(a1, 416) = v16;
  JF(base, 84336) = v20;
  v21 = (float)(v20 * JF(base, 84400)) + JF(base, 84416);
  JF(base, 84368) = v21;
  v22 = v18 - (float)(v7 * v21);
  v23 = JF(a1, 272);
  JF(a1, 288) = v23;
  v24 = v22 + v21;
  v25 = JF(a1, 240);
  v26 = v23 * v25;
  JF(a1, 256) = v25;
  JF(base, 84432) = v24;
  v27 = JF(a1, 304);
  JF(a1, 336) = v27;
  JF(a1, 448) = v26;
  v28 = (float)((float)(v12 * v26) - (float)(v26 * v27)) + v27;
  v29 = (float)((float)(v11 * v26) - (float)(v2 * v26)) + v2;
  JF(a1, 464) = v28;
  JF(a1, 480) = v29;
  v30 = v29;
  v31 = v29 + JF(a1, 544);
  if ( v31 < 0.0 )
    v32 = v31;
  else
    v32 = 0.0;
  v33 = -1.0;
  if ( v30 == 0.0 )
    v34 = -1.0;
  else
    v34 = v32;
  JF(a1, 496) = v34;
  if ( v34 >= 0.0 )
  {
    if ( v34 > 0.0 )
      v34 = 1.0;
  }
  else
  {
    v34 = -1.0;
  }
  v35 = JF(a1, 608);
  v36 = v34 + 1.0;
  v37 = JF(a1, 768);
  v38 = JF(a1, 624);
  v39 = JI(a1, 560);
  v40 = JF(a1, 704);
  v41 = v38 + JF(a1, 784);
  v42 = 1.0;
  JF(a1, 528) = v36;
  JF(a1, 560) = v36;
  JI(a1, 576) = v39;
  JF(a1, 720) = v40;
  v43 = (float)(v36 * v35) - v35;
  v44 = JF(a1, 816);
  v45 = (float)(v43 + 1.0) * JF(a1, 592);
  v46 = (float)(JF(a1, 672) / (float)((float)(v37 * v38) + JF(a1, 800))) * v37;
  v47 = JF(a1, 656);
  JF(a1, 736) = v45;
  v48 = v47 - v46;
  v49 = JF(a1, 688);
  v50 = (float)(v48 + v28) - v40;
  JF(a1, 656) = v50;
  v51 = v50 * v41;
  JF(a1, 672) = v51;
  v52 = v51 + v40;
  if ( (float)(v44 - fabs(v40 - v28)) < 0.0 )
  {
    v53 = 0.0;
LABEL_25:
    v54 = v53;
    goto LABEL_26;
  }
  v53 = v49 + JF(a1, 832);
  if ( v53 < 1.0 )
    goto LABEL_25;
  v54 = 1.0;
LABEL_26:
  v55 = v54;
  JF(a1, 688) = v55;
  v56 = (float)((float)(v55 * v28) - (float)(v55 * v52)) + v52;
  if ( v45 == 0.0 )
    v56 = v28;
  v57 = v16 * JF(a1, 864);
  JI(a1, 896) = JI(a1, 880);
  v58 = JF(a1, 1168);
  v59 = JF(a1, 912);
  v60 = JI(a1, 1008);
  v61 = v57 + (float)(v14 * JF(a1, 848));
  v62 = JI(a1, 976);
  v63 = (int)v58;
  JF(a1, 880) = v61;
  v64 = JF(a1, 944);
  JF(a1, 704) = v56;
  JF(a1, 752) = v56;
  v65 = JF(a1, 1104);
  JF(a1, 960) = v64;
  JF(a1, 928) = v59;
  JI(a1, 992) = v62;
  JI(a1, 1024) = v60;
  JF(a1, 1120) = v65;
  if ( (int)v58 < -32 )
  {
    v59 = v59 * 2.3283064e-10;
    goto LABEL_38;
  }
  if ( v63 > 32 )
  {
    v63 = 32;
LABEL_37:
    v59 = v59 * juno_exp_ad3c[v63];
    goto LABEL_38;
  }
  if ( v63 < 0 )
  {
    v59 = v59 * juno_exp_acc0[~v63];
    goto LABEL_38;
  }
  if ( v63 > 0 )
    goto LABEL_37;
LABEL_38:
  v66 = (int)(float)-v58;
  if ( v66 < -32 )
  {
    v59 = v59 * 2.3283064e-10;
    goto LABEL_46;
  }
  if ( v66 > 32 )
  {
    v66 = 32;
LABEL_45:
    v59 = v59 * juno_exp_ad3c[v66];
    goto LABEL_46;
  }
  if ( v66 < 0 )
  {
    v59 = v59 * juno_exp_acc0[~v66];
    goto LABEL_46;
  }
  if ( v66 > 0 )
    goto LABEL_45;
LABEL_46:
  v67 = JF(a1, 1040);
  v68 = (float)((float)(v59 - v65) * JF(a1, 1152)) + v65;
  v69 = JF(a1, 1088);
  JF(a1, 1104) = v68;
  v70 = (float)((float)(v68 * v67) - (float)(v67 * v69)) + v69;
  if ( v70 <= 0.0 )
    v71 = 0.0;
  else
    v71 = v70;
  v72 = v71;
  if ( v72 < 1.0 )
    v73 = v72;
  else
    v73 = 1.0;
  v74 = JF(a1, 1056);
  v75 = expf((float)v73 * JF(a1, 1200)) * JF(a1, 1184);
  v76 = v74 * JF(a1, 1072);
  JI(a1, 1584) = JI(a1, 1568);
  v77 = v75 + JF(a1, 1216);
  v78 = JF(a1, 1504);
  v79 = v64 * JF(a1, 1904);
  JI(a1, 1616) = JI(a1, 1600);
  v80 = JF(a1, 1488);
  v81 = JF(a1, 1536);
  JI(a1, 1648) = JI(a1, 1632);
  v82 = JI(base, 84432);
  JF(a1, 1520) = v78;
  JF(a1, 1504) = v80;
  JF(a1, 1552) = v81;
  JI(a1, 1440) = v62;
  JI(a1, 1456) = v60;
  JI(a1, 1424) = v82;
  v83 = (float)(v76 - (float)(v74 * v77)) + v77;
  v84 = JF(a1, 1856);
  v85 = v79 + v84;
  JF(a1, 1840) = v84;
  JF(a1, 1136) = v83;
  if ( v85 >= -1.0 )
    v86 = fminf(v85, 1.0);
  else
    v86 = -1.0;
  v87 = JF(a1, 2128);
  JF(a1, 1488) = v86;
  v88 = fminf(v87, v83 * 0.000015258789);
  v89 = (float)((float)(1.0 - v78) * JF(a1, 1920)) + v78;
  if ( v89 >= -1.0 )
    v90 = fminf(v89, 1.0);
  else
    v90 = -1.0;
  v91 = v88 * JF(a1, 2144);
  v92 = v80 - v86;
  JF(a1, 1664) = v91;
  v93 = v91 + v81;
  if ( v92 < 0.0 )
    v90 = 0.0;
  v94 = JF(a1, 1872);
  v95 = JF(a1, 1424);
  JF(a1, 1504) = v90;
  v96 = v90 + JF(a1, 2272);
  if ( v92 >= 0.0 )
    v94 = 1.0;
  v97 = v96 * JF(a1, 2256);
  v98 = (float)(v93 * v94) * JF(a1, 1888);
  if ( v97 <= 0.0 )
    v99 = 0.0;
  else
    v99 = v97;
  v100 = v99;
  v101 = (float)((float)(v95 - JF(a1, 1584)) * JF(a1, 2464)) + JF(a1, 1584);
  JF(a1, 1568) = v101;
  JF(a1, 1472) = v100;
  v529 = JF(a1, 1552);
  v102 = (float)((float)((float)(v101 * JF(a1, 2448)) * JF(a1, 2064))
               - (float)(v95 * JF(a1, 2064)))
       + v95;
  if ( v98 <= 1.0 )
  {
    if ( v98 < -1.0 )
      v98 = fmodf(v98 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v98 = fmodf(v98 + 1.0, 2.0) - 1.0;
  }
  v103 = JF(a1, 1616);
  JF(a1, 1536) = v98;
  v104 = v98 + JF(a1, 2288);
  JF(a1, 1408) = v102 * JF(a1, 2432);
  if ( v529 < 0.0 && v98 > 0.0 )
    v103 = v95;
  if ( v104 <= 1.0 )
  {
    if ( v104 < -1.0 )
      v104 = fmodf(v104 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v104 = fmodf(v104 + 1.0, 2.0) - 1.0;
  }
  JF(a1, 1600) = v103;
  v105 = v103 * JF(a1, 2416);
  v106 = (float)(v104 * JF(a1, 2352)) + JF(a1, 2480);
  JF(a1, 1680) = v106;
  JF(a1, 1760) = v105;
  v107 = v98 + JF(a1, 2320);
  JF(a1, 1696) = -v106;
  if ( v107 <= 1.0 )
  {
    if ( v107 < -1.0 )
      fmodf(v107 - 1.0, 2.0);
  }
  else
  {
    fmodf(v107 + 1.0, 2.0);
  }
  /* v107 (= v98 + cell2320) is the sub-osc TRIANGLE phase; its wrap is folded
   * into juno_triangle below (the decompiler dropped the sub_180368FC0 argument,
   * so an earlier transcription mis-fed v108 here — masked in recalled notes,
   * where cells 2304 and 2320 coincide, but wrong for the free-running idle phase,
   * where they differ by −0.5 and produced a half-cycle sub-osc error). v108
   * (= v98 + cell2304) remains the PULSE phase used for v110. See
   * dsp_dump/0021 lines 860-883 + docs/PHASE1_WARM_RECALL.md. */
  v108 = v98 + JF(a1, 2304);
  if ( v108 <= 1.0 )
  {
    if ( v108 < -1.0 )
      v108 = fmodf(v108 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v108 = fmodf(v108 + 1.0, 2.0) - 1.0;
  }
  v109 = juno_triangle(v107);
  v110 = v108 + JF(a1, 2496);
  v111 = v109 * JF(a1, 2384);
  if ( v110 >= 0.0 )
  {
    if ( v110 > 0.0 )
      v110 = 1.0;
  }
  else
  {
    v110 = -1.0;
  }
  v112 = v98 + JF(a1, 2336);
  JF(a1, 1728) = v111;
  JF(a1, 1824) = v110;
  v113 = (float)(v110 * JF(a1, 2368)) + JF(a1, 2512);
  if ( v112 <= 1.0 )
  {
    if ( v112 < -1.0 )
      v112 = fmodf(v112 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v112 = fmodf(v112 + 1.0, 2.0) - 1.0;
  }
  v114 = fabs(v112);
  JF(a1, 1712) = v113;
  v115 = JF(a1, 1968);
  v116 = (float)((float)(JF(a1, 2032) * JF(a1, 1760))
               + (float)(JF(a1, 2000) * JF(a1, 1680)))
       + (float)(JF(a1, 2016) * JF(a1, 1696));
  v117 = (float)((float)((float)((float)(v114 * (float)((float)(v114 * v114) * v114)) * JF(a1, 2224))
                       + (float)((float)((float)((float)(v114 * v114) * v114) * JF(a1, 2208))
                               + (float)((float)((float)(v114 * JF(a1, 2176)) + JF(a1, 2160))
                                       + (float)((float)(v114 * v114) * JF(a1, 2192)))))
               + JF(a1, 2240))
       * JF(a1, 2400);
  JF(a1, 1744) = v117;
  v118 = (float)(v115 * JF(a1, 1728)) + v116;
  v119 = JF(a1, 2080);
  v120 = (float)((float)(JF(a1, 1936) * JF(a1, 1472)) - JF(a1, 1936)) + 1.0;
  v121 = (float)((float)(v118 + (float)(JF(a1, 1984) * JF(a1, 1712)))
               + (float)(v117 * JF(a1, 1952)))
       + (float)(JF(a1, 2048) * JF(a1, 1408));
  JF(a1, 1776) = v120;
  JF(a1, 1808) = v121;
  JF(a1, 1792) = (float)((float)(JF(a1, 2096) * JF(a1, 1440))
                                + (float)(JF(a1, 2112) * JF(a1, 1456)))
                        + (float)((float)(v119 * v120) * v121);
  /* ================= ENGINE B MODULE M7 — the two ADSR envelopes ==========
   * REPLACES src/voice_render.c:964-1075 verbatim. Diff this file against
   * src/voice_render.c: this block is the ONLY change, plus the include above.
   *
   * The port's 111 lines here do three separable things: shuffle ten shadow
   * cells so that last sample's values can be read back, recompute six
   * loop-invariant products from cells that only a patch recall can change, and
   * run two identical ADSR state machines. Engine B keeps the third and deletes
   * the first two. eb_envgen.c holds the arithmetic; this block is only the
   * plumbing that connects it to the port's cells.
   *
   * STATE LIVES IN THE PORT'S OWN STATE CELLS (2592/2624/2640/2672/2720 and the
   * +480 ENV2 twins) rather than in a static of this file. That is deliberate
   * and it is not laziness: those five cells are zeroed at power-on by
   * chorus_init.c:118-127 and replicated per voice, so using them gives the
   * module the port's exact lifecycle -- create, destroy, re-create, eight
   * voices -- with no ownership question for the harness to get wrong.
   * engine_b/shim/README.md sanctions exactly this ("a shim may read and write
   * the port's cells"). The <1 KB/voice layout arrives when the module owns the
   * whole voice; the CYCLE claim is measured on eb_envgen.c itself, never here.
   *
   * The TEN shadow cells (2608/2656/2688/2736 + ENV2 twins, and 2576/3056) and
   * the four write-only outputs (2528/2544/2768/3248) are NOT written. GREPPED:
   * no reader outside this block anywhere in src/ or gui/. Audio is unaffected;
   * per-cell state parity is not, and that is a sonic-identity claim.
   */
  {
    static eb_env_coef  EBC[JUNO_NUM_VOICES][2];
    static float        EBRAW[JUNO_NUM_VOICES][2][15];
    static int          EBHAVE[JUNO_NUM_VOICES][2];
    int ei;

    for ( ei = 0; ei < 2; ++ei )
    {
      unsigned off = (unsigned)ei * 480u;            /* ENV2 = ENV1 + 480 */
      float raw[15];
      eb_env_state es;
      float k, gin;
      int j, same;

      /* the fifteen cells the coefficients are a pure function of */
      raw[0]  = JF(a1, 2784 + off);   /* A */
      raw[1]  = JF(a1, 2800 + off);   /* S */
      raw[2]  = JF(a1, 2816 + off);   /* D */
      raw[3]  = JF(a1, 2832 + off);   /* R */
      raw[4]  = JF(a1, 2864 + off);
      raw[5]  = JF(a1, 2880 + off);
      raw[6]  = JF(a1, 2896 + off);
      raw[7]  = JF(a1, 2912 + off);
      raw[8]  = JF(a1, 2928 + off);
      raw[9]  = JF(a1, 2944 + off);
      raw[10] = JF(a1, 2960 + off);
      raw[11] = JF(a1, 2848 + off);
      raw[12] = JF(a1, 2976 + off);
      raw[13] = JF(a1, 2992 + off);
      raw[14] = JF(a1, 3008 + off);

      /* Rebuild only on change. In a real host that is once per recall; the
       * comparison is here rather than in a parameter callback because this
       * shim has no parameter path of its own to hook. It is HARNESS cost and
       * is excluded from every cycle figure reported for this module. */
      same = EBHAVE[voice][ei];
      for ( j = 0; j < 15 && same; ++j )
        if ( EBRAW[voice][ei][j] != raw[j] ) same = 0;
      if ( !same )
      {
        for ( j = 0; j < 15; ++j ) EBRAW[voice][ei][j] = raw[j];
        eb_env_set_rate_consts(&EBC[voice][ei], raw[4], raw[5], raw[6], raw[7],
                               raw[8], raw[9], raw[10], raw[11], raw[12],
                               raw[13], raw[14]);
        eb_env_set_adsr(&EBC[voice][ei], raw[0], raw[1], raw[2], raw[3]);
        EBHAVE[voice][ei] = 1;
      }

      /* gated input: gate x LFO-pulse polarity, unless the per-envelope LFO
       * TRIG switch (2560 / 3040) is off, in which case the gate passes. Both
       * operands belong to other modules, so they are read, not recomputed. */
      if ( JF(a1, 1824) <= 0.0f ) k = 0.0f; else k = 1.0f;
      if ( JF(a1, 2560 + off) == 0.0f ) k = 1.0f;
      gin = JF(a1, 560) * k;

      es.y = JF(a1, 2592 + off);
      es.h = JF(a1, 2624 + off);
      es.p = JF(a1, 2640 + off);
      es.t = JF(a1, 2672 + off);
      es.r = JF(a1, 2720 + off);

      JF(a1, 2752 + off) = eb_env_tick(&es, &EBC[voice][ei], gin);

      JF(a1, 2592 + off) = es.y;
      JF(a1, 2624 + off) = es.h;
      JF(a1, 2640 + off) = es.p;
      JF(a1, 2672 + off) = es.t;
      JF(a1, 2720 + off) = es.r;
    }
  }
  /* =============== END ENGINE B MODULE M7 ================================ */

  JI(a1, 3536) = JI(a1, 3520);
  JI(a1, 3568) = JI(a1, 3552);
  v167 = JF(a1, 752);
  v168 = JF(a1, 880);
  JI(a1, 3632) = JI(a1, 3616);
  v169 = (float)(v168 * JF(a1, 3600)) + (float)(v167 * JF(a1, 3584));
  JF(a1, 3616) = v169;
  v170 = JF(a1, 1792);
  v171 = JI(a1, 2752);
  v172 = JI(a1, 3232);
  v173 = JI(a1, 752);
  JI(a1, 3680) = JI(a1, 3552);
  JI(a1, 3696) = v173;
  v174 = JF(a1, 4016);
  JI(a1, 3648) = v171;
  JI(a1, 3664) = v172;
  v175 = JF(a1, 3984);
  v176 = v170 * v174;
  v177 = v174 * JF(a1, 1808);
  JF(a1, 3712) = v177;
  v178 = JF(a1, 4112);
  v179 = JF(a1, 3856);
  v180 = v176 * JF(a1, 4032);
  v181 = JF(a1, 4048);
  v182 = (float)(v175 * v177) * JF(a1, 4000);
  JF(a1, 3744) = v182;
  v183 = JF(a1, 3872);
  v184 = (float)((float)((float)(v179 * JF(a1, 3680)) - (float)(v178 * v179)) + v178) * JF(a1, 4128);
  JF(a1, 3760) = v184;
  v185 = (float)((float)(v181 * v180) + v182) + (float)(v183 * v184);
  v186 = JF(a1, 3712);
  v187 = JI(a1, 3840);
  JF(a1, 3776) = (float)((float)((float)((float)((float)((float)(JF(a1, 4080) * JF(a1, 3664))
                                                                + (float)(JF(a1, 4064) * JF(a1, 3648)))
                                                        * JF(a1, 4096))
                                                + v185)
                                        + v169)
                                + JF(a1, 3952))
                        + JF(a1, 3968);
  JI(a1, 3792) = v187;
  v188 = (float)(JF(a1, 3744) + JF(a1, 3696)) + JF(a1, 3760);
  JF(a1, 3808) = (float)((float)((float)((float)((float)((float)(v186 * JF(a1, 4160))
                                                                + JF(a1, 4176))
                                                        * JF(a1, 3888))
                                                + (float)(JF(a1, 3904) * JF(a1, 3648)))
                                        + (float)(JF(a1, 3920) * JF(a1, 3664)))
                                + JF(a1, 3936))
                        * JF(a1, 4144);
  JF(a1, 3824) = v188;
  v189 = JI(a1, 4208);
  JI(a1, 4240) = JI(a1, 4192);
  JI(a1, 4256) = v189;
  JI(a1, 4272) = JI(a1, 4224);
  v190 = JF(base, 84432);
  JI(a1, 4320) = JI(a1, 4304);
  v191 = JF(a1, 4288);
  JF(a1, 4304) = v191;
  v192 = (float)(v191 * JF(a1, 4336)) + JF(a1, 4320);
  JF(a1, 4304) = v192;
  v193 = (float)(v191 * JF(a1, 4352)) + v192;
  v194 = v192 * JF(a1, 4400);
  v195 = v190 - v193;
  v196 = (float)(v195 * JF(a1, 4336)) + v191;
  JF(a1, 4288) = v196;
  JF(a1, 4320) = (float)((float)(v195 * JF(a1, 4368)) + v194) + (float)(v196 * JF(a1, 4384));
  JI(a1, 6432) = JI(a1, 6416);
  v197 = JF(a1, 6448);
  JF(a1, 6464) = v197;
  v198 = v197 * JF(a1, 3536);
  v199 = JF(a1, 6432) * JF(a1, 4320);
  JF(a1, 6480) = v198;
  JF(a1, 6496) = v199;
  JI(a1, 6560) = JI(a1, 6544);
  JF(a1, 6544) = (float)(v199 * JF(a1, 6528)) + (float)(v198 * JF(a1, 6512));
  JI(a1, 6592) = JI(a1, 6576);
  JI(a1, 6624) = JI(a1, 6608);
  JI(a1, 6656) = JI(a1, 6640);
  JI(a1, 6688) = JI(a1, 6672);
  v200 = (float)((float)(JF(a1, 6720) * JF(a1, 6576))
               - (float)(JF(a1, 6736) * JF(a1, 6720)))
       + JF(a1, 6736);
  v201 = (float)((float)((float)((float)(v200 * v200) * v200) * v200) * JF(a1, 6816))
       + (float)((float)((float)((float)(v200 * v200) * v200) * JF(a1, 6800))
               + (float)((float)((float)(v200 * JF(a1, 6768)) + JF(a1, 6752))
                       + (float)((float)(v200 * v200) * JF(a1, 6784))));
  if ( v201 <= 0.0 )
    v202 = 0.0;
  else
    v202 = v201;
  v203 = v202;
  if ( v203 < 1.0 )
    v42 = v203;
  v204 = v42;
  JF(a1, 6704) = v204;
  JI(a1, 6848) = JI(a1, 6832);
  v205 = JF(a1, 6864);
  JF(a1, 6880) = v205;
  v206 = JF(a1, 6896);
  JF(a1, 6912) = v206;
  JF(a1, 6896) = (float)((float)(v205 - v206) * JF(a1, 6928)) + v206;
  v207 = JF(a1, 752);
  v208 = JF(a1, 880);
  JI(a1, 6992) = JI(a1, 6976);
  JF(a1, 6976) = (float)(v208 * JF(a1, 6960)) + (float)(v207 * JF(a1, 6944));
  JI(a1, 7040) = JI(a1, 7008);
  v209 = JF(a1, 7024);
  JF(a1, 7056) = v209;
  v210 = JF(a1, 2752)
       + (float)((float)(JF(a1, 7040) * JF(a1, 3232))
               - (float)(JF(a1, 7040) * JF(a1, 2752)));
  JF(a1, 7072) = (float)((float)(v209 * JF(a1, 6640)) - (float)(v209 * v210)) + v210;
  v211 = JF(a1, 1792);
  v212 = JF(a1, 7088);
  JF(a1, 7104) = v212;
  v213 = v211 - v212;
  v214 = (float)(v213 * JF(a1, 7120)) + v212;
  v215 = JF(a1, 7152);
  JF(a1, 7088) = v214;
  JF(a1, 7104) = (float)(v213 * JF(a1, 7136)) + (float)(v215 * v214);
  v216 = JF(a1, 7168);
  v217 = JF(a1, 1808);
  JF(a1, 7184) = v216;
  v218 = v217 - v216;
  v219 = (float)(v218 * JF(a1, 7200)) + v216;
  v220 = JF(a1, 7232);
  JF(a1, 7168) = v219;
  v221 = (float)(v218 * JF(a1, 7216)) + (float)(v220 * v219);
  JF(a1, 7184) = v221;
  v222 = JF(a1, 7104);
  v223 = JF(a1, 7072);
  v224 = JF(a1, 6976);
  v227_bits = JU(a1, 6608); v227 = f32_from_bits(v227_bits);
  JI(a1, 7248) = JI(a1, 6896);
  JI(a1, 7264) = (int32_t)bits_from_f32(v227);
  v225 = JF(a1, 7296);
  v226 = JF(a1, 7312) * JF(a1, 6672);
  v227 = (float)((float)((float)((float)((float)(v227 * JF(a1, 7328))
                                                   - (float)(JF(a1, 7456) * JF(a1, 7328)))
                                           + JF(a1, 7456))
                                   * JF(a1, 7472))
                           + (float)((float)((float)(JF(a1, 7440) + JF(a1, 7248))
                                           * JF(a1, 7504))
                                   * JF(a1, 7424)))
                   + (float)((float)((float)((float)((float)((float)(v226
                                                                   - (float)(JF(a1, 7312) * (float)(v221 * v225)))
                                                           + (float)(v221 * v225))
                                                   * JF(a1, 7360))
                                           * JF(a1, 7376))
                                   + (float)((float)((float)(v226 - (float)(JF(a1, 7312) * (float)(v222 * v225)))
                                                   + (float)(v222 * v225))
                                           * JF(a1, 7344)))
                           + (float)((float)((float)(v224 + JF(a1, 7488)) * JF(a1, 7408))
                                   + (float)(v223 * JF(a1, 7392))));
  JI(a1, 7280) = (int32_t)bits_from_f32(v227);
  v228 = JF(a1, 6704);
  v229 = JF(a1, 6848);
  JI(a1, 7584) = JI(a1, 7568);
  v230 = JF(a1, 7552);
  JF(a1, 7568) = v230;
  if ( JF(a1, 7632) == 1.0 )
  {
    v231 = JF(a1, 7584)
         + (float)((float)(JF(a1, 7712) * v230) - (float)(JF(a1, 7712) * JF(a1, 7584)));
    JF(a1, 7568) = v231;
    v232 = (float)(v231 * JF(a1, 7696)) + JF(a1, 7600);
    JF(a1, 7552) = juno_wrap24(-v230);
    v233 = (float)(1.0 - v229) * JF(a1, 7728);
    JF(a1, 7536) = (float)(v229 * JF(a1, 7792)) + JF(a1, 7616);
    v227 = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v227 * JF(a1, 7680))
                                                         + (float)(v228 * JF(a1, 7648)))
                                                 + v232)
                                         + fminf(JF(a1, 7744), v233))
                                 + JF(a1, 7664),
                                   JF(a1, 7760)),
                                 JF(a1, 7776))
                             * JF(a1, 7824))
                     + JF(a1, 7840);
    v234 = v227;
    v235 = (int)v227;
    if ( v235 != (int)0x80000000 && (float)v235 != v227 )
      v234 = (float)(v235 - (int)((bits_from_f32(v227) >> 31) & 1u));
    v236 = v227 - v234;
    v237 = (float)(v236 * v236) * 0.25;
    v238 = (float)(expf(v234)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v236 * JF(a1, 8032)) + JF(a1, 8016)) * v237) + (float)(v236 * JF(a1, 8000))) + JF(a1, 7984)) * v237) + (float)(v236 * JF(a1, 7968)))
                                                                                                 + JF(a1, 7952))
                                                                                         * v237)
                                                                                 + (float)(v236 * JF(a1, 7936)))
                                                                         + JF(a1, 7920))
                                                                 * v237)
                                                         + (float)(v236 * JF(a1, 7904)))
                                                 + JF(a1, 7888))
                                         * v237)
                                 + (float)(v236 * JF(a1, 7872)))
                         + 1.0))
         * JF(a1, 7856);
    v239 = v238 * v238;
    v240 = (float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 0x2000))
                                                         + JF(a1, 8160))
                                                 * (float)(v239 * v239))
                                         + (float)((float)((float)(v238 * v238) * JF(a1, 8128))
                                                 + JF(a1, 8096)))
                                 * (float)((float)((float)(v238 * v238) * v238) * (float)(v238 * v238)))
                         + (float)((float)((float)(v238 * v238) * v238) * JF(a1, 8064)))
                 + v238)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * JF(a1, 8176))
                                                                 + JF(a1, 8144))
                                                         * (float)(v239 * v239))
                                                 + (float)((float)(v238 * v238) * JF(a1, 8112)))
                                         + JF(a1, 8080))
                                 * (float)(v239 * v239))
                         + (float)((float)(v238 * v238) * JF(a1, 8048)))
                 + 1.0);
    v241 = v240 / (float)(v240 + 1.0);
    JF(a1, 7520) = v241;
  }
  else
  {
    v241 = JF(a1, 7520);
  }
  v242 = JF(a1, 6544);
  v243 = JF(a1, 7536);
  JI(a1, 8320) = JI(a1, 8304);
  JI(a1, 8304) = JI(a1, 8288);
  JI(a1, 8288) = JI(a1, 8272);
  JI(a1, 8272) = JI(a1, 8256);
  JI(a1, 8256) = JI(a1, 8240);
  JI(a1, 8240) = JI(a1, 8224);
  JI(a1, 8224) = JI(a1, 8208);
  JI(a1, 8544) = JI(a1, 8528);
  JI(a1, 8528) = JI(a1, 8512);
  JI(a1, 8512) = JI(a1, 8496);
  JI(a1, 8496) = JI(a1, 8480);
  JI(a1, 8480) = JI(a1, 8464);
  JI(a1, 8464) = JI(a1, 8448);
  JI(a1, 8448) = JI(a1, 8432);
  JI(a1, 8672) = JI(a1, 8656);
  JI(a1, 8656) = JI(a1, 8640);
  JI(a1, 8640) = JI(a1, 8624);
  JI(a1, 8624) = JI(a1, 8608);
  JI(a1, 8608) = JI(a1, 8592);
  JI(a1, 8592) = JI(a1, 8576);
  JI(a1, 8576) = JI(a1, 8560);
  JI(a1, 8800) = JI(a1, 8784);
  JI(a1, 8784) = JI(a1, 8768);
  JI(a1, 8768) = JI(a1, 8752);
  JI(a1, 8752) = JI(a1, 8736);
  JI(a1, 8736) = JI(a1, 8720);
  JI(a1, 8720) = JI(a1, 8704);
  JI(a1, 8704) = JI(a1, 8688);
  JI(a1, 8928) = JI(a1, 8912);
  JI(a1, 8912) = JI(a1, 8896);
  JI(a1, 8896) = JI(a1, 8880);
  JI(a1, 8880) = JI(a1, 8864);
  JI(a1, 8864) = JI(a1, 8848);
  JI(a1, 8848) = JI(a1, 8832);
  JI(a1, 8832) = JI(a1, 8816);
  JI(a1, 8960) = JI(a1, 8944);
  v244 = JF(a1, 8976);
  JF(a1, 8992) = v244;
  if ( JF(a1, 9056) == 1.0 )
  {
    v245 = (float)((float)((float)(v243 * JF(a1, 9168)) + 1.0) * (float)(v242 * JF(a1, 9136)))
         + (float)((float)-v244 * JF(a1, 9120));
    JF(a1, 8976) = juno_wrap24(-v244);
    JF(a1, 8944) = v245;
    v246 = 1.0 - (float)(v241 + v241);
    v247 = 1.0 / (float)((float)((float)((float)(v241 * v241) * (float)(v241 * v241)) * v243) + 1.0);
    JF(a1, 9024) = _s9024 = v247;
    v248 = JF(a1, 8944);
    v249 = JF(a1, 8960);
    JF(a1, 9008) = _s9008 = v247 * v243;
    v250 = v249 * JF(a1, 9216);
    v251 = JF(a1, 8304);
    v252 = v248 * JF(a1, 9232);
    v253 = JF(a1, 8320);
    JF(a1, 8416) = _s8416 = v251;
    v254 = (float)((float)(v250 + v252) * v247)
         - (float)((float)((float)(v251 * JF(a1, 9520)) + (float)(v253 * JF(a1, 9536)))
                 * (float)(v247 * v243));
    if ( v254 >= -1.0 )
      v255 = fminf(v254, 1.0);
    else
      v255 = -1.0;
    v256 = v255 + (float)((float)((float)((float)(v255 * v255) * v255) * v255) * (float)(v255 * JF(a1, 9184)));
    JF(a1, 8336) = _s8336 = v256;
    v257 = JF(a1, 8240);
    v258 = (float)(v241 * (float)(v256 + JF(a1, 8224))) + (float)(v257 * v246);
    JF(a1, 8352) = _s8352 = v258;
    v259 = JF(a1, 8256);
    v260 = v241 * (float)(v258 + v257);
    v261 = v241 * (float)((float)((float)(v241 * v256) + (float)(v246 * v258)) + v258);
    v262 = v260 + (float)(v259 * v246);
    JF(a1, 8368) = _s8368 = v262;
    v263 = JF(a1, 8272);
    v264 = (float)(v241 * (float)(v262 + v259)) + (float)(v263 * v246);
    JF(a1, 8384) = _s8384 = v264;
    v265 = (float)((float)(v263 + v264) * v241) + (float)(v246 * JF(a1, 8288));
    JF(a1, 8400) = _s8400 = v265;
    v266 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v261 + (float)(v246 * v262)) + v262))
                                 + (float)(v246 * v264))
                         + v264))
         + (float)(v246 * v265);
    v267 = (float)(_s8384 * JF(a1, 9088)) + (float)(v265 * JF(a1, 9104));
    v268 = JF(a1, 8960);
    JF(a1, 8816) = v267 + (float)(JF(a1, 9072) * _s8368);
    v269 = _s8416;
    v270 = (float)((float)(v268 + JF(a1, 8944)) * JF(a1, 9248)) * _s9024;
    JF(a1, 8416) = _s8416 = v266;
    v271 = v270
         - (float)((float)((float)(v266 * JF(a1, 9520)) + (float)(v269 * JF(a1, 9536)))
                 * _s9008);
    if ( v271 >= -1.0 )
      v272 = fminf(v271, 1.0);
    else
      v272 = -1.0;
    v273 = v272 + (float)((float)((float)((float)(v272 * v272) * v272) * v272) * (float)(v272 * JF(a1, 9184)));
    v274 = _s8336;
    JF(a1, 8336) = _s8336 = v273;
    v275 = _s8352;
    v276 = (float)(v241 * (float)(v273 + v274)) + (float)(v275 * v246);
    JF(a1, 8352) = _s8352 = v276;
    v277 = _s8368;
    v278 = v241 * (float)(v276 + v275);
    v279 = v241 * (float)((float)((float)(v241 * v273) + (float)(v246 * v276)) + v276);
    v280 = v278 + (float)(v277 * v246);
    JF(a1, 8368) = _s8368 = v280;
    v281 = _s8384;
    v282 = (float)(v241 * (float)(v280 + v277)) + (float)(v281 * v246);
    JF(a1, 8384) = _s8384 = v282;
    v283 = (float)((float)(v281 + v282) * v241) + (float)(v246 * _s8400);
    JF(a1, 8400) = _s8400 = v283;
    v284 = JF(a1, 8944);
    v285 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v279 + (float)(v246 * v280)) + v280))
                                 + (float)(v246 * v282))
                         + v282))
         + (float)(v246 * v283);
    v286 = (float)(_s8384 * JF(a1, 9088)) + (float)(v283 * JF(a1, 9104));
    v287 = JF(a1, 8960);
    JF(a1, 8688) = v286 + (float)(JF(a1, 9072) * _s8368);
    v288 = _s8416;
    v289 = (float)((float)(v287 * JF(a1, 9232)) + (float)(v284 * JF(a1, 9216)))
         * _s9024;
    JF(a1, 8416) = _s8416 = v285;
    v290 = v289
         - (float)((float)((float)(v285 * JF(a1, 9520)) + (float)(v288 * JF(a1, 9536)))
                 * _s9008);
    if ( v290 >= -1.0 )
      v291 = fminf(v290, 1.0);
    else
      v291 = -1.0;
    v292 = v291 + (float)((float)((float)((float)(v291 * v291) * v291) * v291) * (float)(v291 * JF(a1, 9184)));
    v293 = _s8336;
    JF(a1, 8336) = _s8336 = v292;
    v294 = _s8352;
    v295 = (float)(v241 * (float)(v292 + v293)) + (float)(v294 * v246);
    JF(a1, 8352) = _s8352 = v295;
    v296 = _s8368;
    v297 = v241 * (float)(v295 + v294);
    v298 = v241 * (float)((float)((float)(v241 * v292) + (float)(v246 * v295)) + v295);
    v299 = v297 + (float)(v296 * v246);
    JF(a1, 8368) = _s8368 = v299;
    v300 = _s8384;
    v301 = (float)(v241 * (float)(v299 + v296)) + (float)(v300 * v246);
    JF(a1, 8384) = _s8384 = v301;
    v302 = (float)((float)(v300 + v301) * v241) + (float)(v246 * _s8400);
    JF(a1, 8400) = _s8400 = v302;
    v303 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v298 + (float)(v246 * v299)) + v299))
                                 + (float)(v246 * v301))
                         + v301))
         + (float)(v246 * v302);
    v304 = (float)(_s8384 * JF(a1, 9088)) + (float)(v302 * JF(a1, 9104));
    v305 = JF(a1, 8944);
    JF(a1, 8560) = v304 + (float)(JF(a1, 9072) * _s8368);
    v306 = _s8416;
    v307 = (float)(v305 * JF(a1, 9200)) * _s9024;
    JF(a1, 8304) = v303;
    v308 = v307
         - (float)((float)((float)(v303 * JF(a1, 9520)) + (float)(v306 * JF(a1, 9536)))
                 * _s9008);
    if ( v308 >= -1.0 )
      v309 = fminf(v308, 1.0);
    else
      v309 = -1.0;
    v310 = v309 + (float)((float)((float)((float)(v309 * v309) * v309) * v309) * (float)(v309 * JF(a1, 9184)));
    JF(a1, 8208) = v310;
    v311 = _s8352;
    v312 = (float)(v241 * (float)(v310 + _s8336)) + (float)(v311 * v246);
    JF(a1, 8224) = v312;
    v313 = _s8368;
    v314 = v241 * (float)(v312 + v311);
    v315 = v241 * (float)((float)((float)(v241 * v310) + (float)(v246 * v312)) + v312);
    v316 = v314 + (float)(v313 * v246);
    JF(a1, 8240) = v316;
    v317 = _s8384;
    v318 = (float)(v241 * (float)(v316 + v313)) + (float)(v317 * v246);
    JF(a1, 8256) = v318;
    v319 = (float)((float)(v317 + v318) * v241) + (float)(v246 * _s8400);
    v320 = v241
         * (float)((float)((float)(v241 * (float)((float)(v315 + (float)(v246 * v316)) + v316)) + (float)(v246 * v318))
                 + v318);
    JF(a1, 8272) = v319;
    v321 = JF(a1, 8240);
    JF(a1, 8288) = v320 + (float)(v246 * v319);
    v322 = JF(a1, 8496);
    v323 = (float)((float)(v319 * JF(a1, 9104)) + (float)(JF(a1, 9088) * JF(a1, 8256)))
         + (float)(v321 * JF(a1, 9072));
    JF(a1, 8432) = v323;
    v324 = (float)(v323 + JF(a1, 8928)) * JF(a1, 9264);
    v325 = (float)(JF(a1, 8688) + JF(a1, 8672)) * JF(a1, 9296);
    v326 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v322 + JF(a1, 8864)) * JF(a1, 9504)) + (float)((float)(JF(a1, 8624) + JF(a1, 8736)) * JF(a1, 9488))) + (float)((float)(JF(a1, 8752) + JF(a1, 8608)) * JF(a1, 9472))) + (float)((float)(JF(a1, 8480) + JF(a1, 8880)) * JF(a1, 9456))) + (float)((float)(JF(a1, 8848) + JF(a1, 8512)) * JF(a1, 9440)))
                                                                                                 + (float)((float)(JF(a1, 8720) + JF(a1, 8640)) * JF(a1, 9424)))
                                                                                         + (float)((float)(JF(a1, 8768) + JF(a1, 8592))
                                                                                                 * JF(a1, 9408)))
                                                                                 + (float)((float)(JF(a1, 8896)
                                                                                                 + JF(a1, 8464))
                                                                                         * JF(a1, 9392)))
                                                                         + (float)((float)(JF(a1, 8832)
                                                                                         + JF(a1, 8528))
                                                                                 * JF(a1, 9376)))
                                                                 + (float)((float)(JF(a1, 8704)
                                                                                 + JF(a1, 8656))
                                                                         * JF(a1, 9360)))
                                                         + (float)((float)(JF(a1, 8784) + JF(a1, 8576))
                                                                 * JF(a1, 9344)))
                                                 + (float)((float)(JF(a1, 8912) + JF(a1, 8448))
                                                         * JF(a1, 9328)))
                                         + (float)((float)(JF(a1, 8816) + JF(a1, 8544))
                                                 * JF(a1, 9312)))
                                 + v325)
                         + (float)((float)(JF(a1, 8800) + JF(a1, 8560)) * JF(a1, 9280)))
                 + v324)
         * JF(a1, 9152);
    JF(a1, 9040) = v326;
  }
  JI(a1, 9568) = JI(a1, 9552);
  v327 = JI(a1, 9600);
  JI(a1, 9632) = JI(a1, 9584);
  JI(a1, 9648) = v327;
  JI(a1, 9664) = JI(a1, 9616);
  v328 = JF(a1, 9680);
  JF(a1, 9696) = v328;
  v329 = JF(a1, 9712);
  JF(a1, 9728) = v329;
  v330 = (float)((float)(v328 - v329) * JF(a1, 9744)) + v329;
  JF(a1, 9712) = v330;
  v331 = (float)((float)(v330 * JF(a1, 9648)) - (float)(JF(a1, 9648) * JF(a1, 9664)))
       + JF(a1, 9664);
  JF(a1, 9760) = v331;
  v332 = JF(a1, 9776);
  JF(a1, 9792) = v332;
  v333 = (float)((float)(JF(a1, 9808) * v331) - (float)(JF(a1, 9808) * v332)) + v332;
  if ( v333 <= 0.0 )
    v334 = 0.0;
  else
    v334 = v333;
  v335 = v334;
  JF(a1, 9776) = v335;
  v336 = JF(a1, 9824);
  JF(a1, 9840) = v336;
  v337 = JF(a1, 9856);
  JF(a1, 9872) = v337;
  v338 = (float)((float)(JF(a1, 9888) * v336) - (float)(JF(a1, 9888) * v337)) + v337;
  if ( v338 <= 0.0 )
    v339 = 0.0;
  else
    v339 = v338;
  v340 = v339;
  JF(a1, 9856) = v340;
  v341 = JF(a1, 9904);
  v342 = JF(a1, 560);
  JF(a1, 9920) = v341;
  v343 = v341 * JF(a1, 10000);
  v344 = v341 + JF(a1, 9984);
  if ( v343 >= -1.0 )
    v345 = fminf(v343, 1.0);
  else
    v345 = -1.0;
  if ( (float)(v341 + JF(a1, 9952)) >= 0.0 )
    v344 = (float)((float)(JF(a1, 9968) * v342) - (float)(JF(a1, 9968) * v341)) + v341;
  v346 = (float)((float)(v345 * JF(a1, 10016)) - (float)(JF(a1, 10032) * v345))
       + JF(a1, 10032);
  v347 = (float)((float)(v346 * v342) - (float)(v346 * v341)) + v341;
  if ( v342 != 0.0 )
    v347 = v344;
  JF(a1, 9936) = v347;
  JF(a1, 9904) = v347;
  v348 = JF(a1, 9040);
  v349 = JF(a1, 2752);
  v350 = JF(a1, 6848);
  v351 = JI(a1, 3232);
  v352 = JI(a1, 9552);
  JI(a1, 10112) = JI(a1, 10096);
  JI(a1, 10144) = JI(a1, 10128);
  JI(a1, 10048) = v351;
  JI(a1, 10064) = v352;
  v353 = JF(a1, 10112);
  v354 = JF(a1, 10176);
  JF(a1, 10080) = v350 * JF(a1, 10336);
  v355 = v348 - v353;
  v356 = JF(a1, 10208);
  v357 = (float)(v349 * JF(a1, 10192)) + (float)(v354 * JF(a1, 9936));
  v358 = v353 + (float)((float)(v348 - v353) * JF(a1, 10240));
  JF(a1, 10096) = v358;
  v359 = (float)(v355 * JF(a1, 10352)) + (float)(v358 * JF(a1, 10368));
  v360 = (float)((float)(JF(a1, 10224) * JF(a1, 10064))
               - (float)(JF(a1, 10224) * (float)(v357 + (float)(v356 * JF(a1, 10048)))))
       + (float)(v357 + (float)(v356 * JF(a1, 10048)));
  v361 = JF(a1, 10256);
  v362 = v360 * JF(a1, 10304);
  v363 = v348 * (float)(1.0 - v361);
  if ( v362 <= 0.0 )
    v364 = 0.0;
  else
    v364 = v362;
  v365 = JF(a1, 10272);
  v366 = v364;
  v367 = v366 * JF(a1, 10320);
  v368 = (float)((float)(v361 * v359) + v363) * (float)(JF(a1, 10080) + 1.0);
  v369 = JF(a1, 10288) * v368;
  v370 = JF(a1, 10144)
       + (float)((float)(JF(a1, 10384) * v368) - (float)(JF(a1, 10384) * JF(a1, 10144)));
  JF(a1, 10128) = v370;
  v371 = (float)((float)((float)(v365 * v370) + v369) * v367) * JF(a1, 10400);
  JF(a1, 10160) = v371;
  JI(a1, 10448) = JI(a1, 10432);
  JI(a1, 10432) = JI(a1, 10416);
  v372 = JF(a1, 10448);
  v373 = JF(a1, 10464);
  v374 = v371 - v372;
  JF(a1, 10416) = v374;
  JF(a1, 10432) = (float)(v373 * v374) + v372;
  v375 = JF(a1, 10416);
  v376 = JF(a1, 9632);
  JI(a1, 10528) = JI(a1, 10512);
  JI(a1, 10512) = JI(a1, 10496);
  JI(a1, 10496) = JI(a1, 10480);
  JF(a1, 10480) = v375;
  v377 = (float)((float)(JF(a1, 10496) * JF(a1, 10576)) + (float)(v375 * JF(a1, 10560)))
       + (float)(JF(a1, 10592) * JF(a1, 10512));
  v378 = (float)((float)(JF(a1, 10496) * JF(a1, 10624)) + (float)(v375 * JF(a1, 10608)))
       + (float)(JF(a1, 10640) * JF(a1, 10528));
  if ( v376 <= 0.0 )
    v379 = 0.0;
  else
    v379 = v376;
  JF(a1, 10496) = v377;
  v380 = v379;
  JF(a1, 10512) = v378;
  v381 = (float)((float)(v380 * v377) - (float)(v380 * v375)) + v375;
  if ( v376 < -0.0 )
    v19 = (float)-v376;
  v382 = v19;
  v383 = v375 + (float)((float)(v382 * v378) - (float)(v382 * v375));
  if ( v376 >= 0.0 )
    v383 = v381;
  JF(a1, 10544) = v383;
  v384 = v383 * JF(a1, 9776);
  JF(a1, 10656) = v384;
  JF(a1, 10672) = v384 * JF(a1, 9856);
  v385 = fmin(fmax((float)(JF(a1, 4448) + JF(a1, 3776)), -20.0), 8.9);
  v386 = v385 * v385 * v385;
  v387 = juno_pitch_table[(int)(v385 + 20.0)];
  v388 = v386 * v385 * v385;
  v389 = v388 * v385 * v385 * v385;
  v390 = v389 * v385 * v385;
  v391 = fmaxf(
           fminf(
             v385 * v387[2]
           + *v387
           + v385 * v385 * v387[4]
           + v386 * v387[6]
           + v386 * v385 * v387[8]
           + v388 * v387[10]
           + v388 * v385 * v387[12]
           + v388 * v385 * v385 * v387[14]
           + v389 * v387[16]
           + v389 * v385 * v387[18]
           + v390 * v387[20]
           + v390 * v385 * v387[22]
           + v390 * v385 * v385 * v387[24],
             512.0),
           -512.0)
       * JF(a1, 3792);
  JF(a1, 4416) = v391;
  v392 = JF(a1, 3776);
  v393 = JI(a1, 4240);
  v394 = JI(a1, 4256);
  v386_lo = JI(a1, 4272);
  JI(a1, 4848) = JI(a1, 4832);
  JI(a1, 4880) = JI(a1, 4864);
  JI(a1, 5056) = JI(a1, 5040);
  JI(a1, 5040) = JI(a1, 5024);
  JI(a1, 5024) = JI(a1, 5008);
  JI(a1, 5008) = JI(a1, 4992);
  JI(a1, 4992) = JI(a1, 4976);
  JI(a1, 4976) = JI(a1, 4960);
  JI(a1, 4960) = JI(a1, 4944);
  JI(a1, 5184) = JI(a1, 5168);
  JI(a1, 5168) = JI(a1, 5152);
  JI(a1, 5152) = JI(a1, 5136);
  JI(a1, 5136) = JI(a1, 5120);
  JI(a1, 5120) = JI(a1, 5104);
  JI(a1, 5104) = JI(a1, 5088);
  JI(a1, 5088) = JI(a1, 5072);
  JI(a1, 5312) = JI(a1, 5296);
  JI(a1, 5296) = JI(a1, 5280);
  JI(a1, 5280) = JI(a1, 5264);
  JI(a1, 5264) = JI(a1, 5248);
  JI(a1, 5248) = JI(a1, 5232);
  JI(a1, 5232) = JI(a1, 5216);
  JI(a1, 5216) = JI(a1, 5200);
  JI(a1, 5440) = JI(a1, 5424);
  JI(a1, 5424) = JI(a1, 5408);
  JI(a1, 5408) = JI(a1, 5392);
  JI(a1, 5392) = JI(a1, 5376);
  JI(a1, 5376) = JI(a1, 5360);
  JI(a1, 5360) = JI(a1, 5344);
  JI(a1, 5344) = JI(a1, 5328);
  JI(a1, 5504) = JI(a1, 5488);
  JI(a1, 5488) = JI(a1, 5472);
  JI(a1, 4736) = v393;
  JI(a1, 4752) = v394;
  v395 = v392 + JF(a1, 6304);
  v396 = v391 * JF(a1, 5536);
  v397 = JF(a1, 5520);
  JI(a1, 4768) = v386_lo;
  v398 = fmaxf(JF(a1, 5568), v396);
  v399 = (float)(v395 * JF(a1, 6320)) + JF(a1, 6288);
  JF(a1, 4784) = _s4784 = v398;
  JF(a1, 4816) = _s4816 = v397 + JF(a1, 3808);
  if ( v399 <= 0.0 )
    v400 = 0.0;
  else
    v400 = v399;
  JF(a1, 4800) = _s4800 = 0.00390625 / v398;
  JF(a1, 5456) = v400;
  v401 = JF(a1, 4880);
  v402 = JI(a1, 4848);
  JF(a1, 4656) = _s4656 = v401;
  v403 = v401 + v398;
  JI(a1, 4672) = v402;
  if ( v403 <= 1.0 )
  {
    if ( v403 < -1.0 )
      v403 = fmodf(v403 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v403 = fmodf(v403 + 1.0, 2.0) - 1.0;
  }
  JF(a1, 4640) = v403;
  v404 = v403 * JF(a1, 5648);
  *(float *)&v405 = juno_triangle((v403 + 1.0f) * 0.5f);
  v406 = (float)((float)(*(float *)&v405 * 256.0) * _s4800) * JF(a1, 5600);
  if ( v406 >= -1.0 )
    v407 = fminf(v406, 1.0);
  else
    v407 = -1.0;
  v408 = v407 * JF(a1, 5552);
  v409 = (float)(v408 * v408) * v408;
  v410 = v409 * JF(a1, 5952);
  v411 = (float)((float)((float)((float)((float)(v408 * v408) * JF(a1, 6016)) + JF(a1, 6000))
                       * (float)((float)(v408 * v408) * (float)(v408 * v408)))
               + (float)((float)((float)(v408 * v408) * JF(a1, 5984)) + JF(a1, 5968)))
       * (float)(v409 * (float)(v408 * v408));
  v412 = _s4816 + v403;
  JF(a1, 4896) = _s4896 = (float)((float)(v411 + v410) + v408) * v404;
  v413 = v412;
  if ( v412 >= 0.0 )
  {
    if ( v412 > 0.0 )
      v413 = 1.0;
  }
  else
  {
    v413 = -1.0;
  }
  v414 = JF(a1, 4640);
  v415 = v413 * JF(a1, 5664);
  *(float *)&v416 = juno_triangle(v412 / (v412 < 0.0f ? _s4816 - 1.0f : _s4816 + 1.0f));
  v417 = *(float *)&v416;
  v418 = JF(a1, 5584);
  if ( v414 < v418 || v418 <= _s4656 )
    v419 = JF(a1, 4672);
  else
    v419 = JF(a1, 4672) + 2.0;
  v420 = (float)((float)(v417 * _s4800) * 256.0) * JF(a1, 5616);
  if ( v419 >= 4.0 )
    v419 = 0.0;
  if ( v420 >= -1.0 )
    v421 = fminf(v420, 1.0);
  else
    v421 = -1.0;
  JF(a1, 4672) = v419;
  v422 = v421 * JF(a1, 5552);
  v423 = (float)((float)((float)(v419 + v414) + 1.0) * 0.5) - 1.0;
  v424 = (float)((float)((float)((float)((float)((float)((float)((float)(v422 * v422) * JF(a1, 6016))
                                                       + JF(a1, 6000))
                                               * (float)((float)(v422 * v422) * (float)(v422 * v422)))
                                       + (float)((float)((float)(v422 * v422) * JF(a1, 5984))
                                               + JF(a1, 5968)))
                               * (float)((float)((float)(v422 * v422) * v422) * (float)(v422 * v422)))
                       + (float)((float)((float)(v422 * v422) * v422) * JF(a1, 5952)))
               + v422)
       * v415;
  JF(a1, 4912) = v424;
  *(float *)&v425 = juno_triangle(-fabsf(v423));
  if ( v423 >= 0.0 )
  {
    if ( v423 > 0.0 )
      v423 = 1.0;
  }
  else
  {
    v423 = -1.0;
  }
  v426 = v423 * JF(a1, 5680);
  v427 = (float)((float)((float)(*(float *)&v425 + 1.0) * _s4800) * 512.0) * JF(a1, 5632);
  if ( v427 >= -1.0 )
    v428 = fminf(v427, 1.0);
  else
    v428 = -1.0;
  v429 = v428 * JF(a1, 5552);
  v430 = JF(a1, 4640);
  v431 = JI(a1, 4672);
  JF(a1, 4944) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v429 * v429)
                                                                                                * JF(a1, 6016))
                                                                                        + JF(a1, 6000))
                                                                                * (float)((float)(v429 * v429)
                                                                                        * (float)(v429 * v429)))
                                                                        + (float)((float)((float)(v429 * v429)
                                                                                        * JF(a1, 5984))
                                                                                + JF(a1, 5968)))
                                                                * (float)((float)((float)(v429 * v429) * v429)
                                                                        * (float)(v429 * v429)))
                                                        + (float)((float)((float)(v429 * v429) * v429)
                                                                * JF(a1, 5952)))
                                                + v429)
                                        * v426)
                                * JF(a1, 4768))
                        + (float)((float)(_s4896 * JF(a1, 4736))
                                + (float)(v424 * JF(a1, 4752)));
  JF(a1, 4656) = _s4656 = v430;
  JI(a1, 4672) = v431;
  v432 = v430 + _s4784;
  if ( v432 <= 1.0 )
  {
    if ( v432 < -1.0 )
      v432 = fmodf(v432 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v432 = fmodf(v432 + 1.0, 2.0) - 1.0;
  }
  JF(a1, 4640) = v432;
  v433 = v432 * JF(a1, 5648);
  *(float *)&v434 = juno_triangle((v432 + 1.0f) * 0.5f);
  v435 = (float)((float)(*(float *)&v434 * 256.0) * _s4800) * JF(a1, 5600);
  if ( v435 >= -1.0 )
    v436 = fminf(v435, 1.0);
  else
    v436 = -1.0;
  v437 = v436 * JF(a1, 5552);
  v438 = (float)(v437 * v437) * v437;
  v439 = v438 * JF(a1, 5952);
  v440 = (float)((float)((float)((float)((float)(v437 * v437) * JF(a1, 6016)) + JF(a1, 6000))
                       * (float)((float)(v437 * v437) * (float)(v437 * v437)))
               + (float)((float)((float)(v437 * v437) * JF(a1, 5984)) + JF(a1, 5968)))
       * (float)(v438 * (float)(v437 * v437));
  v441 = _s4816 + v432;
  JF(a1, 4896) = _s4896 = (float)((float)(v440 + v439) + v437) * v433;
  v442 = v441;
  if ( v441 >= 0.0 )
  {
    if ( v441 > 0.0 )
      v442 = 1.0;
  }
  else
  {
    v442 = -1.0;
  }
  v443 = JF(a1, 4640);
  v444 = v442 * JF(a1, 5664);
  *(float *)&v445 = juno_triangle(v441 / (v441 < 0.0f ? _s4816 - 1.0f : _s4816 + 1.0f));
  v446 = *(float *)&v445;
  v447 = JF(a1, 5584);
  if ( v443 < v447 || v447 <= _s4656 )
    v448 = JF(a1, 4672);
  else
    v448 = JF(a1, 4672) + 2.0;
  v449 = (float)((float)(v446 * _s4800) * 256.0) * JF(a1, 5616);
  if ( v448 >= 4.0 )
    v448 = 0.0;
  if ( v449 >= -1.0 )
    v450 = fminf(v449, 1.0);
  else
    v450 = -1.0;
  JF(a1, 4672) = v448;
  v451 = v450 * JF(a1, 5552);
  v452 = (float)((float)((float)(v448 + v443) + 1.0) * 0.5) - 1.0;
  v453 = (float)((float)((float)((float)((float)((float)((float)((float)(v451 * v451) * JF(a1, 6016))
                                                       + JF(a1, 6000))
                                               * (float)((float)(v451 * v451) * (float)(v451 * v451)))
                                       + (float)((float)((float)(v451 * v451) * JF(a1, 5984))
                                               + JF(a1, 5968)))
                               * (float)((float)((float)(v451 * v451) * v451) * (float)(v451 * v451)))
                       + (float)((float)((float)(v451 * v451) * v451) * JF(a1, 5952)))
               + v451)
       * v444;
  JF(a1, 4912) = v453;
  *(float *)&v454 = juno_triangle(-fabsf(v452));
  if ( v452 >= 0.0 )
  {
    if ( v452 > 0.0 )
      v452 = 1.0;
  }
  else
  {
    v452 = -1.0;
  }
  v455 = v452 * JF(a1, 5680);
  v456 = (float)((float)((float)(*(float *)&v454 + 1.0) * _s4800) * 512.0) * JF(a1, 5632);
  if ( v456 >= -1.0 )
    v457 = fminf(v456, 1.0);
  else
    v457 = -1.0;
  v458 = v457 * JF(a1, 5552);
  v459 = JF(a1, 4640);
  v460 = JI(a1, 4672);
  JF(a1, 5072) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v458 * v458)
                                                                                                * JF(a1, 6016))
                                                                                        + JF(a1, 6000))
                                                                                * (float)((float)(v458 * v458)
                                                                                        * (float)(v458 * v458)))
                                                                        + (float)((float)((float)(v458 * v458)
                                                                                        * JF(a1, 5984))
                                                                                + JF(a1, 5968)))
                                                                * (float)((float)((float)(v458 * v458) * v458)
                                                                        * (float)(v458 * v458)))
                                                        + (float)((float)((float)(v458 * v458) * v458)
                                                                * JF(a1, 5952)))
                                                + v458)
                                        * v455)
                                * JF(a1, 4768))
                        + (float)((float)(_s4896 * JF(a1, 4736))
                                + (float)(v453 * JF(a1, 4752)));
  JF(a1, 4656) = _s4656 = v459;
  JI(a1, 4672) = v460;
  v461 = v459 + _s4784;
  if ( v461 <= 1.0 )
  {
    if ( v461 < -1.0 )
      v461 = fmodf(v461 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v461 = fmodf(v461 + 1.0, 2.0) - 1.0;
  }
  JF(a1, 4640) = v461;
  v462 = v461 * JF(a1, 5648);
  *(float *)&v463 = juno_triangle((v461 + 1.0f) * 0.5f);
  v464 = (float)((float)(*(float *)&v463 * 256.0) * _s4800) * JF(a1, 5600);
  if ( v464 >= -1.0 )
    v465 = fminf(v464, 1.0);
  else
    v465 = -1.0;
  v466 = v465 * JF(a1, 5552);
  v467 = (float)(v466 * v466) * v466;
  v468 = v467 * JF(a1, 5952);
  v469 = (float)((float)((float)((float)((float)(v466 * v466) * JF(a1, 6016)) + JF(a1, 6000))
                       * (float)((float)(v466 * v466) * (float)(v466 * v466)))
               + (float)((float)((float)(v466 * v466) * JF(a1, 5984)) + JF(a1, 5968)))
       * (float)(v467 * (float)(v466 * v466));
  v470 = _s4816 + v461;
  JF(a1, 4896) = _s4896 = (float)((float)(v469 + v468) + v466) * v462;
  v471 = v470;
  if ( v470 >= 0.0 )
  {
    if ( v470 > 0.0 )
      v471 = 1.0;
  }
  else
  {
    v471 = -1.0;
  }
  v472 = JF(a1, 4640);
  v473 = v471 * JF(a1, 5664);
  *(float *)&v474 = juno_triangle(v470 / (v470 < 0.0f ? _s4816 - 1.0f : _s4816 + 1.0f));
  v475 = *(float *)&v474;
  v476 = JF(a1, 5584);
  if ( v472 < v476 || v476 <= _s4656 )
    v477 = JF(a1, 4672);
  else
    v477 = JF(a1, 4672) + 2.0;
  v478 = (float)((float)(v475 * _s4800) * 256.0) * JF(a1, 5616);
  if ( v477 >= 4.0 )
    v477 = 0.0;
  if ( v478 >= -1.0 )
    v479 = fminf(v478, 1.0);
  else
    v479 = -1.0;
  JF(a1, 4672) = v477;
  v480 = v479 * JF(a1, 5552);
  v481 = (float)((float)((float)(v477 + v472) + 1.0) * 0.5) - 1.0;
  v482 = (float)((float)((float)((float)((float)((float)((float)((float)(v480 * v480) * JF(a1, 6016))
                                                       + JF(a1, 6000))
                                               * (float)((float)(v480 * v480) * (float)(v480 * v480)))
                                       + (float)((float)((float)(v480 * v480) * JF(a1, 5984))
                                               + JF(a1, 5968)))
                               * (float)((float)((float)(v480 * v480) * v480) * (float)(v480 * v480)))
                       + (float)((float)((float)(v480 * v480) * v480) * JF(a1, 5952)))
               + v480)
       * v473;
  JF(a1, 4912) = v482;
  *(float *)&v483 = juno_triangle(-fabsf(v481));
  if ( v481 >= 0.0 )
  {
    if ( v481 > 0.0 )
      v481 = 1.0;
  }
  else
  {
    v481 = -1.0;
  }
  v484 = v481 * JF(a1, 5680);
  v485 = (float)((float)((float)(*(float *)&v483 + 1.0) * _s4800) * 512.0) * JF(a1, 5632);
  if ( v485 >= -1.0 )
    v486 = fminf(v485, 1.0);
  else
    v486 = -1.0;
  v487 = v486 * JF(a1, 5552);
  v488 = JF(a1, 4640);
  v489 = JI(a1, 4672);
  JF(a1, 5200) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v487 * v487)
                                                                                                * JF(a1, 6016))
                                                                                        + JF(a1, 6000))
                                                                                * (float)((float)(v487 * v487)
                                                                                        * (float)(v487 * v487)))
                                                                        + (float)((float)((float)(v487 * v487)
                                                                                        * JF(a1, 5984))
                                                                                + JF(a1, 5968)))
                                                                * (float)((float)((float)(v487 * v487) * v487)
                                                                        * (float)(v487 * v487)))
                                                        + (float)((float)((float)(v487 * v487) * v487)
                                                                * JF(a1, 5952)))
                                                + v487)
                                        * v484)
                                * JF(a1, 4768))
                        + (float)((float)(_s4896 * JF(a1, 4736))
                                + (float)(v482 * JF(a1, 4752)));
  JF(a1, 4656) = _s4656 = v488;
  JI(a1, 4672) = v489;
  v490 = v488 + _s4784;
  if ( v490 <= 1.0 )
  {
    if ( v490 < -1.0 )
      v490 = fmodf(v490 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v490 = fmodf(v490 + 1.0, 2.0) - 1.0;
  }
  JF(a1, 4640) = v490;
  v491 = v490 * JF(a1, 5648);
  *(float *)&v492 = juno_triangle((v490 + 1.0f) * 0.5f);
  v493 = (float)((float)(*(float *)&v492 * 256.0) * _s4800) * JF(a1, 5600);
  if ( v493 >= -1.0 )
    v494 = fminf(v493, 1.0);
  else
    v494 = -1.0;
  v495 = v494 * JF(a1, 5552);
  v496 = (float)(v495 * v495) * v495;
  v497 = v496 * JF(a1, 5952);
  v498 = (float)((float)((float)((float)((float)(v495 * v495) * JF(a1, 6016)) + JF(a1, 6000))
                       * (float)((float)(v495 * v495) * (float)(v495 * v495)))
               + (float)((float)((float)(v495 * v495) * JF(a1, 5984)) + JF(a1, 5968)))
       * (float)(v496 * (float)(v495 * v495));
  v499 = _s4816 + v490;
  JF(a1, 4896) = _s4896 = (float)((float)(v498 + v497) + v495) * v491;
  v500 = v499;
  if ( v499 >= 0.0 )
  {
    if ( v499 > 0.0 )
      v500 = 1.0;
  }
  else
  {
    v500 = -1.0;
  }
  v501 = JF(a1, 4640);
  v502 = v500 * JF(a1, 5664);
  *(float *)&v503 = juno_triangle(v499 / (v499 < 0.0f ? _s4816 - 1.0f : _s4816 + 1.0f));
  v504 = *(float *)&v503;
  v505 = JF(a1, 5584);
  if ( v501 < v505 || v505 <= _s4656 )
    v506 = JF(a1, 4672);
  else
    v506 = JF(a1, 4672) + 2.0;
  v507 = (float)((float)(v504 * _s4800) * 256.0) * JF(a1, 5616);
  if ( v506 >= 4.0 )
    v506 = 0.0;
  if ( v507 >= -1.0 )
    v508 = fminf(v507, 1.0);
  else
    v508 = -1.0;
  JF(a1, 4672) = v506;
  v509 = v508 * JF(a1, 5552);
  v510 = (float)((float)((float)(v506 + v501) + 1.0) * 0.5) - 1.0;
  v511 = (float)((float)((float)((float)((float)((float)((float)((float)(v509 * v509) * JF(a1, 6016))
                                                       + JF(a1, 6000))
                                               * (float)((float)(v509 * v509) * (float)(v509 * v509)))
                                       + (float)((float)((float)(v509 * v509) * JF(a1, 5984))
                                               + JF(a1, 5968)))
                               * (float)((float)((float)(v509 * v509) * v509) * (float)(v509 * v509)))
                       + (float)((float)((float)(v509 * v509) * v509) * JF(a1, 5952)))
               + v509)
       * v502;
  JF(a1, 4912) = v511;
  v512 = juno_triangle(-fabsf(v510)) + 1.0f;
  if ( v510 >= 0.0 )
  {
    if ( v510 > 0.0 )
      v510 = 1.0;
  }
  else
  {
    v510 = -1.0;
  }
  v513 = v510 * JF(a1, 5680);
  v514 = (float)((float)(v512 * _s4800) * 512.0) * JF(a1, 5632);
  if ( v514 >= -1.0 )
    v33 = fminf(v514, 1.0);
  v515 = v33 * JF(a1, 5552);
  v516 = JI(a1, 4640);
  v517 = JI(a1, 4672);
  JF(a1, 5328) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v515 * v515)
                                                                                                * JF(a1, 6016))
                                                                                        + JF(a1, 6000))
                                                                                * (float)((float)(v515 * v515)
                                                                                        * (float)(v515 * v515)))
                                                                        + (float)((float)((float)(v515 * v515)
                                                                                        * JF(a1, 5984))
                                                                                + JF(a1, 5968)))
                                                                * (float)((float)((float)(v515 * v515) * v515)
                                                                        * (float)(v515 * v515)))
                                                        + (float)((float)((float)(v515 * v515) * v515)
                                                                * JF(a1, 5952)))
                                                + v515)
                                        * v513)
                                * JF(a1, 4768))
                        + (float)((float)(_s4896 * JF(a1, 4736))
                                + (float)(v511 * JF(a1, 4752)));
  v518 = JF(a1, 5440);
  JI(a1, 4864) = v516;
  JI(a1, 4832) = v517;
  v519 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(JF(a1, 5312) + JF(a1, 5072))
                                                                                               * JF(a1, 5712))
                                                                                       + (float)((float)(v518 + JF(a1, 4944))
                                                                                               * JF(a1, 5696)))
                                                                               + (float)((float)(JF(a1, 5200)
                                                                                               + JF(a1, 5184))
                                                                                       * JF(a1, 5728)))
                                                                       + (float)((float)(JF(a1, 5328)
                                                                                       + JF(a1, 5056))
                                                                               * JF(a1, 5744)))
                                                               + (float)((float)(JF(a1, 5424)
                                                                               + JF(a1, 4960))
                                                                       * JF(a1, 5760)))
                                                       + (float)((float)(JF(a1, 5296) + JF(a1, 5088))
                                                               * JF(a1, 5776)))
                                               + (float)((float)(JF(a1, 5216) + JF(a1, 5168))
                                                       * JF(a1, 5792)))
                                       + (float)((float)(JF(a1, 5344) + JF(a1, 5040))
                                               * JF(a1, 5808)))
                               + (float)((float)(JF(a1, 5408) + JF(a1, 4976)) * JF(a1, 5824)))
                       + (float)((float)(JF(a1, 5104) + JF(a1, 5280)) * JF(a1, 5840)))
               + (float)((float)(JF(a1, 5232) + JF(a1, 5152)) * JF(a1, 5856)))
       + (float)((float)(JF(a1, 5024) + JF(a1, 5360)) * JF(a1, 5872));
  v520 = JF(a1, 5488);
  v521 = (float)(v520 * JF(a1, 6256)) + JF(a1, 5504);
  v522 = (float)((float)(v519 + (float)((float)(JF(a1, 5392) + JF(a1, 4992)) * JF(a1, 5888)))
               + (float)((float)(JF(a1, 5264) + JF(a1, 5120)) * JF(a1, 5904)))
       + (float)((float)(JF(a1, 5248) + JF(a1, 5136)) * JF(a1, 5920));
  v523 = (float)(JF(a1, 5376) + JF(a1, 5008)) * JF(a1, 5936);
  JF(a1, 5488) = v521;
  v524 = v522 + v523;
  v525 = v524 - (float)((float)(v520 * JF(a1, 6272)) + v521);
  JF(a1, 5472) = (float)(v525 * JF(a1, 6256)) + v520;
  v526 = (float)((float)((float)(v521 - (float)(v525 * JF(a1, 5456))) * JF(a1, 6336))
               - (float)(JF(a1, 6336) * v524))
       + v524;
  JF(a1, 4928) = v526;
  JF(a1, 3520) = v526;
  if ( JF(base, auxoff) == 1.0 )
  {
    JI(a1, 320) = v528;
    JI(base, auxoff) = 0;
  }
  *outL = JF(a1, 10672);
  result = JU(a1, 10672);
  *outR = JF(a1, 10672);
  return result;
}

