/* jx_master_render.c -- exact C99 transcription of the JX-3P master render
 * (sub_18039A2B0). Single unit; offsets are the decompile's own. Helpers shared
 * with the voice render (jx_voice_helpers). STATUS: PROVEN on the default note state (output + full state null EXACTLY 0,
 * 32 samples). The 11 argless helper sites are DCO-mode/effect-gated (v31<=3 via
 * the note object) and unexercised here -- placeholdered, pending a mode patch.
 * Build with -ffp-contract=off -fno-strict-aliasing. */
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include "jx_voice_helpers.h"

typedef uint32_t _DWORD; typedef uint64_t _QWORD;
typedef uint16_t _WORD;  typedef uint8_t _BYTE;
typedef int64_t __int64; typedef int32_t __int32;
typedef int16_t __int16; typedef int8_t __int8;
#define LODWORD(x)  (*((uint32_t *)&(x)))
#define HIDWORD(x)  (*((uint32_t *)&(x)+1))
#define SLODWORD(x) (*((int32_t *)&(x)))
static inline float    f32_from_bits(uint32_t b){ float f; memcpy(&f,&b,4); return f; }
static inline uint32_t bits_from_f32(float f){ uint32_t b; memcpy(&b,&f,4); return b; }

float *jx_master_render(unsigned char *st, unsigned char *a2, float **a3)
{
  float v5; // xmm1_4
  float v6; // xmm7_4
  float v7; // xmm8_4
  float v8; // xmm4_4
  float v9; // xmm6_4
  float v10; // xmm5_4
  float v11; // xmm9_4
  float v12; // xmm0_4
  float v13; // xmm8_4
  float v14; // xmm7_4
  float v15; // xmm0_4
  int v16; // xmm0_4
  float v17; // xmm2_4
  float v18; // xmm1_4
  int v19; // ebx
  float v20; // xmm0_4
  float v21; // xmm1_4
  int v22; // xmm0_4
  float v23; // xmm1_4
  float v24; // xmm4_4
  __int64 v25; // rax
  float v26; // xmm4_4
  float v27; // xmm3_4
  float v28; // xmm0_4
  float v29; // xmm8_4
  float v30; // xmm7_4
  int v31; // eax
  float v32; // xmm4_4
  int v33; // xmm12_4
  float v34; // xmm3_4
  float v35; // xmm5_4
  float v36; // xmm4_4
  float v37; // xmm3_4
  float v38; // xmm1_4
  float v39; // xmm5_4
  float v40; // xmm6_4
  float v41; // xmm5_4
  float v42; // xmm2_4
  float v43; // xmm3_4
  float v44; // xmm4_4
  float v45; // xmm7_4
  float v46; // xmm3_4
  float v47; // xmm0_4
  float v48; // xmm2_4
  double v49; // xmm15_8
  double v50; // xmm0_8
  float v51; // xmm11_4
  float v52; // xmm0_4
  float v53; // xmm0_4
  float v54; // xmm8_4
  float v55; // xmm1_4
  float v56; // xmm0_4
  float v57; // xmm3_4
  float v58; // xmm3_4
  float v59; // xmm2_4
  float v60; // xmm7_4
  float v61; // xmm4_4
  float v62; // xmm1_4
  float v63; // xmm0_4
  float v64; // xmm3_4
  float v65; // xmm4_4
  float v66; // xmm0_4
  float v67; // xmm4_4
  float v68; // xmm1_4
  float v69; // xmm2_4
  float v70; // xmm2_4
  float v71; // xmm0_4
  float v72; // xmm5_4
  float v73; // xmm5_4
  float v74; // xmm2_4
  float v75; // xmm4_4
  float v76; // xmm1_4
  float v77; // xmm0_4
  float v78; // xmm3_4
  float v79; // xmm4_4
  float v80; // xmm0_4
  float v81; // xmm1_4
  float v82; // xmm2_4
  float v83; // xmm2_4
  float v84; // xmm0_4
  float v85; // xmm8_4
  float v86; // xmm9_4
  float v87; // xmm4_4
  float v88; // xmm5_4
  int v89; // ecx
  int v90; // ecx
  int v91; // xmm0_4
  float v92; // xmm1_4
  float v93; // xmm7_4
  double v94; // xmm0_8
  float v95; // xmm6_4
  float v96; // xmm5_4
  int v97; // xmm1_4
  float v98; // xmm6_4
  float v99; // xmm4_4
  float v100; // xmm1_4
  float v101; // xmm5_4
  float v102; // xmm3_4
  float v103; // xmm1_4
  float v104; // xmm2_4
  float v105; // xmm3_4
  float v106; // xmm4_4
  float v107; // xmm3_4
  float v108; // xmm5_4
  float v109; // xmm3_4
  float v110; // xmm5_4
  float v111; // xmm4_4
  float v112; // xmm5_4
  float v113; // xmm1_4
  float v114; // xmm5_4
  float v115; // xmm4_4
  float v116; // xmm3_4
  float v117; // xmm1_4
  float v118; // xmm6_4
  float v119; // xmm3_4
  float v120; // xmm6_4
  float v121; // xmm5_4
  float v122; // xmm6_4
  float v123; // xmm4_4
  float v124; // xmm6_4
  float v125; // xmm2_4
  float v126; // xmm1_4
  float v127; // xmm3_4
  float v128; // xmm2_4
  float v129; // xmm2_4
  float v130; // xmm3_4
  float v131; // xmm4_4
  double v132; // xmm0_8
  float v133; // xmm0_4
  float v134; // xmm1_4
  float v135; // xmm0_4
  float v136; // xmm4_4
  float v137; // xmm0_4
  int v138; // edx
  float v139; // xmm5_4
  float v140; // xmm3_4
  float v141; // xmm6_4
  float v142; // xmm0_4
  int v143; // edx
  float v144; // xmm4_4
  float v145; // xmm0_4
  float v146; // xmm8_4
  float v147; // xmm3_4
  float v148; // xmm8_4
  float v149; // xmm1_4
  float v150; // xmm9_4
  float v151; // xmm2_4
  float v152; // xmm0_4
  float v153; // xmm9_4
  float v154; // xmm6_4
  float v155; // xmm3_4
  float v156; // xmm2_4
  float v157; // xmm4_4
  int v158; // ecx
  int v159; // ecx
  float v160; // xmm7_4
  float v161; // xmm6_4
  float v162; // xmm7_4
  int v163; // xmm0_4
  float v164; // xmm1_4
  float v165; // xmm9_4
  double v166; // xmm0_8
  float v167; // xmm6_4
  float v168; // xmm5_4
  float v169; // xmm4_4
  float v170; // xmm1_4
  float v171; // xmm5_4
  float v172; // xmm4_4
  float v173; // xmm1_4
  float v174; // xmm2_4
  float v175; // xmm3_4
  float v176; // xmm4_4
  float v177; // xmm3_4
  float v178; // xmm5_4
  float v179; // xmm3_4
  float v180; // xmm5_4
  float v181; // xmm4_4
  float v182; // xmm5_4
  float v183; // xmm1_4
  float v184; // xmm5_4
  float v185; // xmm4_4
  float v186; // xmm3_4
  float v187; // xmm1_4
  float v188; // xmm6_4
  float v189; // xmm3_4
  float v190; // xmm6_4
  float v191; // xmm5_4
  float v192; // xmm6_4
  float v193; // xmm4_4
  float v194; // xmm6_4
  float v195; // xmm2_4
  float v196; // xmm1_4
  float v197; // xmm3_4
  float v198; // xmm2_4
  float v199; // xmm2_4
  float v200; // xmm3_4
  float v201; // xmm4_4
  double v202; // xmm0_8
  float v203; // xmm0_4
  float v204; // xmm1_4
  float v205; // xmm0_4
  float v206; // xmm4_4
  float v207; // xmm0_4
  int v208; // edx
  float v209; // xmm5_4
  float v210; // xmm3_4
  float v211; // xmm6_4
  float v212; // xmm0_4
  int v213; // edx
  float v214; // xmm4_4
  float v215; // xmm0_4
  float v216; // xmm8_4
  float v217; // xmm3_4
  float v218; // xmm8_4
  float v219; // xmm1_4
  float v220; // xmm9_4
  float v221; // xmm2_4
  float v222; // xmm0_4
  float v223; // xmm9_4
  float v224; // xmm6_4
  float v225; // xmm3_4
  float v226; // xmm2_4
  float v227; // xmm4_4
  int v228; // ecx
  int v229; // ecx
  float v230; // xmm7_4
  int v231; // xmm0_4
  float v232; // xmm1_4
  float v233; // xmm9_4
  double v234; // xmm0_8
  float v235; // xmm6_4
  float v236; // xmm5_4
  float v237; // xmm4_4
  float v238; // xmm1_4
  float v239; // xmm8_4
  float v240; // xmm2_4
  float v241; // xmm3_4
  float v242; // xmm1_4
  float v243; // xmm5_4
  float v244; // xmm2_4
  float v245; // xmm3_4
  float v246; // xmm4_4
  float v247; // xmm3_4
  float v248; // xmm5_4
  float v249; // xmm6_4
  float v250; // xmm3_4
  float v251; // xmm6_4
  float v252; // xmm4_4
  float v253; // xmm6_4
  float v254; // xmm2_4
  float v255; // xmm1_4
  float v256; // xmm3_4
  float v257; // xmm0_4
  float v258; // xmm3_4
  float v259; // xmm2_4
  float v260; // xmm4_4
  double v261; // xmm0_8
  float v262; // xmm0_4
  float v263; // xmm1_4
  float v264; // xmm0_4
  float v265; // xmm5_4
  float v266; // xmm0_4
  int v267; // edx
  float v268; // xmm4_4
  float v269; // xmm3_4
  float v270; // xmm6_4
  float v271; // xmm0_4
  int v272; // edx
  float v273; // xmm5_4
  float v274; // xmm0_4
  float v275; // xmm9_4
  float v276; // xmm3_4
  float v277; // xmm9_4
  float v278; // xmm7_4
  float v279; // xmm2_4
  float v280; // xmm1_4
  float v281; // xmm4_4
  float v282; // xmm6_4
  float v283; // xmm5_4
  float v284; // xmm2_4
  float v285; // xmm4_4
  float v286; // xmm0_4
  float v287; // xmm9_4
  float v288; // xmm2_4
  float v289; // xmm0_4
  float v290; // xmm8_4
  float v291; // xmm0_4
  float v292; // xmm2_4
  float v293; // xmm4_4
  float v294; // xmm5_4
  float v295; // xmm0_4
  int v296; // ecx
  float v297; // xmm7_4
  float v298; // xmm4_4
  float v299; // xmm3_4
  float v300; // xmm5_4
  float v301; // xmm4_4
  float v302; // xmm3_4
  float v303; // xmm1_4
  float v304; // xmm0_4
  float v305; // xmm5_4
  float v306; // xmm6_4
  float v307; // xmm2_4
  float v308; // xmm3_4
  float v309; // xmm4_4
  float v310; // xmm7_4
  float v311; // xmm3_4
  float v312; // xmm0_4
  float v313; // xmm2_4
  double v314; // xmm0_8
  float v315; // xmm0_4
  float v316; // xmm0_4
  int v317; // edx
  float v318; // xmm8_4
  float v319; // xmm1_4
  float v320; // xmm0_4
  float v321; // xmm3_4
  float v322; // xmm3_4
  float v323; // xmm2_4
  float v324; // xmm7_4
  float v325; // xmm4_4
  float v326; // xmm1_4
  float v327; // xmm0_4
  float v328; // xmm3_4
  float v329; // xmm4_4
  float v330; // xmm0_4
  float v331; // xmm4_4
  float v332; // xmm1_4
  float v333; // xmm2_4
  float v334; // xmm2_4
  float v335; // xmm0_4
  float v336; // xmm5_4
  float v337; // xmm5_4
  float v338; // xmm2_4
  float v339; // xmm4_4
  float v340; // xmm1_4
  float v341; // xmm0_4
  float v342; // xmm3_4
  float v343; // xmm4_4
  float v344; // xmm0_4
  float v345; // xmm1_4
  float v346; // xmm2_4
  float v347; // xmm2_4
  float v348; // xmm0_4
  float v349; // xmm8_4
  float v350; // xmm9_4
  float v351; // xmm4_4
  float v352; // xmm5_4
  int v353; // ecx
  int v354; // ecx
  float v355; // xmm7_4
  float v356; // xmm7_4
  float v357; // xmm5_4
  float v358; // xmm3_4
  float v359; // xmm4_4
  float v360; // xmm1_4
  float v361; // xmm0_4
  float v362; // xmm5_4
  float v363; // xmm6_4
  float v364; // xmm2_4
  float v365; // xmm3_4
  float v366; // xmm4_4
  float v367; // xmm7_4
  float v368; // xmm3_4
  float v369; // xmm0_4
  float v370; // xmm2_4
  double v371; // xmm0_8
  float v372; // xmm0_4
  float v373; // xmm0_4
  float v374; // xmm1_4
  double v375; // xmm4_8
  int v376; // edx
  float v377; // xmm0_4
  float v378; // xmm7_4
  int v379; // edx
  float v380; // xmm5_4
  float v381; // xmm10_4
  float v382; // xmm0_4
  float v383; // xmm3_4
  float v384; // xmm6_4
  float v385; // xmm2_4
  float v386; // xmm4_4
  float v387; // xmm1_4
  float v388; // xmm0_4
  float v389; // xmm3_4
  float v390; // xmm4_4
  float v391; // xmm0_4
  float v392; // xmm1_4
  float v393; // xmm2_4
  float v394; // xmm2_4
  float v395; // xmm7_4
  float v396; // xmm0_4
  float v397; // xmm2_4
  float v398; // xmm8_4
  float v399; // xmm1_4
  float v400; // xmm9_4
  float v401; // xmm0_4
  float v402; // xmm9_4
  float v403; // xmm1_4
  float v404; // xmm8_4
  float v405; // xmm9_4
  float v406; // xmm0_4
  float v407; // xmm6_4
  int v408; // ecx
  float v409; // xmm7_4
  float v410; // xmm0_4
  float v411; // xmm1_4
  float v412; // xmm0_4
  float v413; // xmm2_4
  float v414; // xmm0_4
  float v415; // xmm2_4
  float v416; // xmm1_4
  float v417; // xmm3_4
  float v418; // xmm3_4
  float v419; // xmm0_4
  float v420; // xmm4_4
  float v421; // xmm1_4
  float v422; // xmm4_4
  float v423; // xmm0_4
  float v424; // xmm1_4
  float v425; // xmm2_4
  int v426; // edx
  float v427; // xmm4_4
  float v428; // xmm1_4
  int v429; // ecx
  float v430; // xmm0_4
  float v431; // xmm3_4
  int v432; // ecx
  float v433; // xmm2_4
  float v434; // xmm0_4
  float v435; // xmm2_4
  int v436; // ecx
  float v437; // xmm3_4
  float v438; // xmm0_4
  float v439; // xmm3_4
  int v440; // ecx
  float v441; // xmm4_4
  float v442; // xmm0_4
  float v443; // xmm4_4
  float v444; // xmm1_4
  float v445; // xmm1_4
  float v446; // xmm1_4
  int v447; // ecx
  float v448; // xmm1_4
  float v449; // xmm2_4
  float v450; // xmm1_4
  float v451; // xmm1_4
  int v452; // ecx
  float v453; // xmm1_4
  float v454; // xmm2_4
  float v455; // xmm1_4
  float v456; // xmm1_4
  int v457; // ecx
  float v458; // xmm1_4
  float v459; // xmm4_4
  float v460; // xmm1_4
  float v461; // xmm1_4
  int v462; // r8d
  float v463; // xmm2_4
  float v464; // xmm3_4
  float v465; // xmm4_4
  float v466; // xmm8_4
  float v467; // xmm7_4
  int i; // ecx
  int v469; // eax
  int v470; // eax
  int v471; // xmm0_4
  float v472; // xmm0_4
  float v473; // xmm5_4
  float v474; // xmm4_4
  float v475; // xmm5_4
  float v476; // xmm0_4
  float v477; // xmm3_4
  float v478; // xmm9_4
  float v479; // xmm5_4
  float v480; // xmm4_4
  float v481; // xmm1_4
  float v482; // xmm6_4
  float v483; // xmm8_4
  float v484; // xmm1_4
  float v485; // xmm7_4
  float v486; // xmm6_4
  float v487; // xmm2_4
  float v488; // xmm2_4
  __int64 v489; // rax
  _DWORD *v490; // rcx
  __int64 v491; // rdx
  float v492; // xmm2_4
  float v493; // xmm1_4
  float v494; // xmm7_4
  float v495; // xmm4_4
  float v496; // xmm2_4
  float v497; // xmm5_4
  float v498; // xmm8_4
  float v499; // xmm6_4
  float v500; // xmm0_4
  float v501; // xmm4_4
  float v502; // xmm2_4
  float v503; // xmm3_4
  float v504; // xmm1_4
  float v505; // xmm1_4
  float v506; // xmm4_4
  float v507; // xmm3_4
  float v508; // xmm2_4
  float v509; // xmm1_4
  float v510; // xmm7_4
  float v511; // xmm4_4
  float v512; // xmm8_4
  float v513; // xmm3_4
  float v514; // xmm1_4
  float v515; // xmm2_4
  float v516; // xmm8_4
  float v517; // xmm8_4
  float v518; // xmm3_4
  float v519; // xmm1_4
  float v520; // xmm1_4
  float v521; // xmm2_4
  float v522; // xmm3_4
  float v523; // xmm2_4
  float v524; // xmm1_4
  float v525; // xmm3_4
  float v526; // xmm0_4
  float v527; // xmm1_4
  float v528; // xmm3_4
  float v529; // xmm2_4
  float v530; // xmm1_4
  float v531; // xmm3_4
  float v532; // xmm3_4
  float v533; // xmm3_4
  float v534; // xmm6_4
  float v535; // xmm5_4
  float v536; // xmm2_4
  double v537; // xmm0_8
  float v538; // xmm0_4
  float v539; // xmm4_4
  float v540; // xmm0_4
  float v541; // xmm3_4
  int v542; // eax
  int v543; // xmm0_4
  float v544; // xmm1_4
  float v545; // xmm8_4
  float v546; // xmm0_4
  float v547; // xmm6_4
  float v548; // xmm0_4
  float v549; // xmm6_4
  float v550; // xmm0_4
  float v551; // xmm1_4
  float v552; // xmm6_4
  float v553; // xmm6_4
  float v554; // xmm1_4
  float v555; // xmm1_4
  float v556; // xmm5_4
  float v557; // xmm2_4
  float v558; // xmm13_4
  float v559; // xmm3_4
  float v560; // xmm0_4
  float v561; // xmm4_4
  float v562; // xmm3_4
  float v563; // xmm2_4
  float v564; // xmm7_4
  float v565; // xmm6_4
  float v566; // xmm2_4
  float v567; // xmm3_4
  float v568; // xmm4_4
  float v569; // xmm5_4
  float v570; // xmm6_4
  float v571; // xmm2_4
  float v572; // xmm4_4
  float v573; // xmm3_4
  float v574; // xmm6_4
  float v575; // xmm4_4
  float v576; // xmm5_4
  float v577; // xmm2_4
  float v578; // xmm6_4
  float v579; // xmm3_4
  float v580; // xmm5_4
  float v581; // xmm6_4
  float v582; // xmm4_4
  float v583; // xmm2_4
  float v584; // xmm5_4
  float v585; // xmm3_4
  float v586; // xmm4_4
  float v587; // xmm5_4
  float v588; // xmm6_4
  float v589; // xmm2_4
  float v590; // xmm4_4
  float v591; // xmm3_4
  float v592; // xmm6_4
  float v593; // xmm4_4
  float v594; // xmm7_4
  float v595; // xmm6_4
  float v596; // xmm7_4
  float v597; // xmm2_4
  float v598; // xmm7_4
  float v599; // xmm9_4
  float v600; // xmm0_4
  float v601; // xmm3_4
  float v602; // xmm6_4
  float v603; // xmm8_4
  float v604; // xmm0_4
  float v605; // xmm5_4
  float v606; // xmm6_4
  float v607; // xmm2_4
  float v608; // xmm3_4
  float v609; // xmm4_4
  float v610; // xmm5_4
  float v611; // xmm6_4
  float v612; // xmm2_4
  float v613; // xmm4_4
  float v614; // xmm3_4
  float v615; // xmm6_4
  float v616; // xmm4_4
  float v617; // xmm5_4
  float v618; // xmm2_4
  float v619; // xmm6_4
  float v620; // xmm3_4
  float v621; // xmm5_4
  float v622; // xmm6_4
  float v623; // xmm4_4
  float v624; // xmm2_4
  float v625; // xmm5_4
  float v626; // xmm3_4
  float v627; // xmm4_4
  float v628; // xmm5_4
  float v629; // xmm6_4
  float v630; // xmm2_4
  float v631; // xmm4_4
  float v632; // xmm3_4
  float v633; // xmm6_4
  float v634; // xmm4_4
  float v635; // xmm5_4
  float v636; // xmm1_4
  float v637; // xmm6_4
  float v638; // xmm5_4
  float v639; // xmm8_4
  float v640; // xmm2_4
  float v641; // xmm6_4
  float v642; // xmm4_4
  float v643; // xmm5_4
  float v644; // xmm7_4
  float v645; // xmm3_4
  float v646; // xmm4_4
  float v647; // xmm0_4
  float v648; // xmm6_4
  float v649; // xmm5_4
  float v650; // xmm0_4
  float v651; // xmm1_4
  float v652; // xmm5_4
  float v653; // xmm0_4
  float v654; // xmm6_4
  float v655; // xmm1_4
  float v656; // xmm0_4
  float v657; // xmm0_4
  float v658; // xmm5_4
  float v659; // xmm1_4
  float v660; // xmm0_4
  float v661; // xmm0_4
  float v662; // xmm5_4
  float v663; // xmm0_4
  float v664; // xmm1_4
  float v665; // xmm4_4
  float v666; // xmm2_4
  float v667; // xmm3_4
  float v668; // xmm4_4
  float v669; // xmm0_4
  float v670; // xmm11_4
  float v671; // xmm2_4
  float v672; // xmm11_4
  float v673; // xmm0_4
  float v674; // xmm2_4
  float v675; // xmm11_4
  float v676; // xmm1_4
  float v677; // xmm2_4
  float v678; // xmm9_4
  int v679; // edi
  int v680; // eax
  float v681; // xmm6_4
  float v682; // xmm7_4
  float v683; // xmm0_4
  float v684; // xmm8_4
  float v685; // xmm8_4
  float v686; // xmm7_4
  float v687; // xmm1_4
  float v688; // xmm0_4
  float v689; // xmm2_4
  float v690; // xmm3_4
  int v691; // edi
  int v692; // eax
  float v693; // xmm6_4
  float v694; // xmm7_4
  int v695; // eax
  float v696; // xmm1_4
  float v697; // xmm7_4
  float v698; // xmm8_4
  float v699; // xmm1_4
  float v700; // xmm0_4
  float v701; // xmm2_4
  float v702; // xmm3_4
  int v703; // edi
  int v704; // eax
  float v705; // xmm6_4
  float v706; // xmm8_4
  float v707; // xmm0_4
  float v708; // xmm1_4
  float v709; // xmm8_4
  float v710; // xmm7_4
  float v711; // xmm1_4
  float v712; // xmm0_4
  float v713; // xmm2_4
  float v714; // xmm3_4
  float v715; // xmm0_4
  float v716; // xmm1_4
  int v717; // eax
  float v718; // xmm6_4
  float v719; // xmm7_4
  float v720; // xmm0_4
  float v721; // xmm1_4
  float v722; // xmm7_4
  float v723; // xmm0_4
  float v724; // xmm8_4
  float v725; // xmm1_4
  float v726; // xmm6_4
  float v727; // xmm8_4
  __int64 v728; // rdx
  __int64 v729; // rcx
  double v730; // xmm0_8
  float v731; // xmm1_4
  float v732; // xmm2_4
  float v733; // xmm8_4
  float v734; // xmm0_4
  float v735; // xmm2_4
  float v736; // xmm8_4
  float v737; // xmm3_4
  float v738; // xmm2_4
  float v739; // xmm1_4
  float v740; // xmm0_4
  float v741; // xmm2_4
  float v742; // xmm3_4
  float v743; // xmm1_4
  float v744; // xmm3_4
  float v745; // xmm0_4
  float v746; // xmm3_4
  float v747; // xmm0_4
  float v748; // xmm2_4
  float v749; // xmm5_4
  float v750; // xmm0_4
  float v751; // xmm1_4
  float v752; // xmm0_4
  float v753; // xmm1_4
  float v754; // xmm6_4
  float v755; // xmm5_4
  float v756; // xmm4_4
  float v757; // xmm7_4
  float v758; // xmm1_4
  float v759; // xmm3_4
  float v760; // xmm2_4
  float v761; // xmm2_4
  float v762; // xmm3_4
  float v763; // xmm1_4
  float v764; // xmm1_4
  float v765; // xmm7_4
  float v766; // xmm3_4
  float v767; // xmm3_4
  float v768; // xmm2_4
  float v769; // xmm7_4
  float v770; // xmm1_4
  float v771; // xmm2_4
  float v772; // xmm1_4
  float v773; // xmm0_4
  float v774; // xmm2_4
  float v775; // xmm1_4
  float v776; // xmm4_4
  float v777; // xmm6_4
  float v778; // xmm3_4
  float v779; // xmm1_4
  float v780; // xmm3_4
  float v781; // xmm0_4
  float v782; // xmm1_4
  float v783; // xmm0_4
  float v784; // xmm5_4
  float v785; // xmm3_4
  float v786; // xmm4_4
  float v787; // xmm1_4
  float v788; // xmm2_4
  float v789; // xmm5_4
  float v790; // xmm5_4
  float v791; // xmm2_4
  float v792; // xmm1_4
  float v793; // xmm1_4
  float v794; // xmm4_4
  float v795; // xmm2_4
  float v796; // xmm1_4
  float v797; // xmm4_4
  float v798; // xmm2_4
  float v799; // xmm0_4
  float v800; // xmm3_4
  float v801; // xmm3_4
  float v802; // xmm6_4
  float v803; // xmm5_4
  float v804; // xmm2_4
  double v805; // xmm0_8
  float v806; // xmm0_4
  float v807; // xmm4_4
  float v808; // xmm0_4
  float v809; // xmm3_4
  float v810; // xmm4_4
  float v811; // xmm0_4
  float v812; // xmm1_4
  float v813; // xmm0_4
  double v814; // xmm1_8
  float v815; // xmm0_4
  float v816; // xmm3_4
  float v817; // xmm2_4
  float v818; // xmm4_4
  float v819; // xmm0_4
  float v820; // xmm6_4
  float v821; // xmm2_4
  float v822; // xmm5_4
  float v823; // xmm3_4
  float v824; // xmm6_4
  float v825; // xmm4_4
  float v826; // xmm6_4
  float v827; // xmm6_4
  double v828; // xmm0_8
  float v829; // xmm8_4
  float v830; // xmm0_4
  float v831; // xmm8_4
  float v832; // xmm0_4
  float v833; // xmm2_4
  float v834; // xmm4_4
  float v835; // xmm6_4
  float v836; // xmm4_4
  float v837; // xmm2_4
  float v838; // xmm3_4
  float v839; // xmm4_4
  float v840; // xmm0_4
  float v841; // xmm4_4
  float v842; // xmm1_4
  float v843; // xmm2_4
  float v844; // xmm3_4
  float v845; // xmm6_4
  int v846; // eax
  int v847; // ecx
  float v848; // xmm5_4
  int v849; // ecx
  int v850; // eax
  signed int v851; // ebx
  float v852; // xmm0_4
  float v853; // xmm8_4
  float v854; // xmm1_4
  float v855; // xmm2_4
  float v856; uint32_t v856_bits;
  float v857; // xmm2_4
  float v858; uint32_t v858_bits;
  float v859; // xmm3_4
  float v860; uint32_t v860_bits;
  int v861; // ecx
  float v862; // xmm2_4
  float v863; // xmm2_4
  int v864; // ecx
  int v865; // xmm0_4
  float v866; // xmm6_4
  float v867; uint32_t v867_bits;
  float v868; // xmm1_4
  int v869; // ecx
  float v870; // xmm3_4
  float v871; // xmm1_4
  float v872; // xmm2_4
  float v873; // xmm3_4
  float v874; // xmm4_4
  float v875; // xmm1_4
  float v876; // xmm5_4
  float v877; // xmm3_4
  float v878; // xmm2_4
  float v879; // xmm1_4
  double v880; // xmm4_8
  float v881; // xmm2_4
  float v882; // xmm0_4
  float v883; // xmm3_4
  float v884; // xmm2_4
  float v885; // xmm1_4
  float v886; // xmm2_4
  float v887; // xmm1_4
  float v888; // xmm3_4
  int v889; // xmm0_4
  float v890; uint32_t v890_bits;
  float v891; uint32_t v891_bits;
  int v892; // ecx
  float v893; // xmm6_4
  float v894; // xmm5_4
  float v895; // xmm1_4
  int v896; // ecx
  float v897; uint32_t v897_bits;
  float v898; // xmm4_4
  int v899; // ecx
  float v900; uint32_t v900_bits;
  float v901; // xmm3_4
  int v902; // ecx
  float v903; // xmm2_4
  float v904; // xmm2_4
  int v905; // xmm0_4
  float v906; // xmm6_4
  float v907; uint32_t v907_bits;
  float v908; // xmm1_4
  int v909; // ecx
  float v910; // xmm1_4
  float v911; // xmm3_4
  float v912; // xmm3_4
  float v913; // xmm4_4
  float v914; // xmm11_4
  float v915; // xmm1_4
  float v916; // xmm5_4
  float v917; // xmm3_4
  float v918; // xmm2_4
  float v919; // xmm1_4
  double v920; // xmm4_8
  float v921; // xmm2_4
  float v922; // xmm0_4
  float v923; // xmm3_4
  float v924; // xmm2_4
  float v925; // xmm1_4
  float v926; // xmm2_4
  float v927; // xmm1_4
  float v928; // xmm3_4
  int v929; // xmm0_4
  float v930; uint32_t v930_bits;
  float v931; uint32_t v931_bits;
  int v932; // ecx
  float v933; // xmm6_4
  float v934; // xmm5_4
  float v935; // xmm2_4
  int v936; // ecx
  float v937; uint32_t v937_bits;
  float v938; // xmm4_4
  int v939; // ecx
  float v940; uint32_t v940_bits;
  float v941; // xmm3_4
  int v942; // ecx
  float v943; // xmm1_4
  float v944; // xmm4_4
  float v945; // xmm5_4
  float v946; // xmm3_4
  float v947; // xmm2_4
  int v948; // edx
  float v949; // xmm1_4
  float v950; // xmm2_4
  float v951; // xmm1_4
  float v952; // xmm5_4
  float v953; // xmm5_4
  float v954; // xmm2_4
  float v955; // xmm4_4
  float v956; // xmm3_4
  float v957; // xmm13_4
  int v958; // edx
  float v959; // xmm1_4
  float v960; // xmm2_4
  float v961; // xmm1_4
  float v962; // xmm4_4
  float v963; // xmm4_4
  float v964; // xmm4_4
  float v965; // xmm3_4
  float v966; // xmm4_4
  float v967; // xmm1_4
  float v968; // xmm5_4
  double v969; // xmm0_8
  float v970; // xmm3_4
  float v971; // xmm5_4
  float v972; // xmm2_4
  float v973; // xmm1_4
  float v974; // xmm2_4
  float v975; // xmm2_4
  float v976; // xmm3_4
  float v977; // xmm2_4
  float v978; // xmm0_4
  float v979; // xmm3_4
  float v980; // xmm2_4
  float v981; // xmm1_4
  float v982; // xmm2_4
  float v983; // xmm3_4
  float v984; // xmm5_4
  float v985; // xmm6_4
  float v986; // xmm3_4
  float v987; // xmm0_4
  float v988; // xmm1_4
  float v989; // xmm4_4
  float v990; // xmm2_4
  float v991; // xmm2_4
  float v992; // xmm4_4
  float v993; // xmm1_4
  float v994; // xmm1_4
  float v995; // xmm2_4
  float v996; // xmm4_4
  float v997; // xmm2_4
  float v998; // xmm1_4
  float v999; // xmm4_4
  float v1000; // xmm2_4
  float v1001; // xmm0_4
  float v1002; // xmm3_4
  float v1003; // xmm3_4
  float v1004; // xmm6_4
  float v1005; // xmm5_4
  float v1006; // xmm2_4
  double v1007; // xmm0_8
  float v1008; // xmm0_4
  float v1009; // xmm4_4
  float v1010; // xmm0_4
  float v1011; // xmm3_4
  float *result; // rax
  float v1013; // [rsp+E0h] [rbp+8h]

  *(_DWORD *)(st + 16288) = **(_DWORD **)a2;
  *(_DWORD *)(st + 32416) = **(_DWORD **)(a2 + 16);
  *(_DWORD *)(st + 48544) = **(_DWORD **)(a2 + 32);
  *(_DWORD *)(st + 64672) = **(_DWORD **)(a2 + 48);
  *(_DWORD *)(st + 80800) = **(_DWORD **)(a2 + 64);
  *(_DWORD *)(st + 96928) = **(_DWORD **)(a2 + 80);
  *(_DWORD *)(st + 113056) = **(_DWORD **)(a2 + 96);
  v5 = **(float **)(a2 + 112);
  *(float *)(st + 129184) = v5;
  v6 = *(float *)(st + 129488);
  v7 = *(float *)(st + 64672);
  v8 = *(float *)(st + 32416);
  v9 = *(float *)(st + 96928);
  v10 = *(float *)(st + 113056);
  *(float *)(st + 129504) = v6;
  v11 = *(float *)(st + 129408);
  v12 = (float)((float)((float)((float)(v7 + *(float *)(st + 48544)) * *(float *)(st + 129376))
                      + (float)((float)(v8 + *(float *)(st + 16288)) * *(float *)(st + 129360)))
              + (float)((float)((float)(v9 + *(float *)(st + 80800)) * *(float *)(st + 129392))
                      + (float)(v11 * (float)(v10 + v5))))
      - v6;
  v13 = v12 * *(float *)(st + 129440);
  v14 = v6 + (float)(v12 * *(float *)(st + 129424));
  v15 = v14 * *(float *)(st + 129456);
  *(float *)(st + 129488) = v14;
  *(float *)(st + 129520) = (float)(v13 + v15) * *(float *)(st + 129472);
  v16 = *(_DWORD *)(st + 129552);
  *(_DWORD *)(st + 129568) = *(_DWORD *)(st + 129536);
  *(_DWORD *)(st + 129584) = v16;
  *(_DWORD *)(st + 129600) = 0;
  v17 = *(float *)(st + 129872);
  v18 = (float)(*(float *)(st + 129696) * *(float *)(st + 129840)) + *(float *)(st + 129712);
  *(float *)(st + 129616) = (float)(*(float *)(st + 129664) * *(float *)(st + 129520)) + *(float *)(st + 129680);
  *(float *)(st + 129632) = v18;
  v19 = 1;
  *(float *)(st + 129648) = (float)(v17 * *(float *)(st + 129728)) + *(float *)(st + 129744);
  *(_DWORD *)(st + 129776) = *(_DWORD *)(st + 129760);
  *(_DWORD *)(st + 129808) = *(_DWORD *)(st + 129792);
  *(_DWORD *)(st + 129840) = *(_DWORD *)(st + 129824);
  *(_DWORD *)(st + 129872) = *(_DWORD *)(st + 129856);
  v20 = *(float *)(st + 129600);
  v21 = (float)(*(float *)(st + 129584) * *(float *)(st + 129808)) + v20;
  *(float *)(st + 129888) = (float)(*(float *)(st + 129584) * *(float *)(st + 129776)) + v20;
  *(float *)(st + 129904) = v21;
  v22 = *(_DWORD *)(st + 129616);
  *(_DWORD *)(st + 129936) = *(_DWORD *)(st + 129920);
  *(_DWORD *)(st + 129920) = v22;
  v23 = *(float *)(st + 129616);
  v24 = *(float *)(st + 129936);
  *(_DWORD *)(st + 130000) = *(_DWORD *)(st + 129984);
  v25 = *(_QWORD *)(st + 136);
  v26 = (float)(v24 * *(float *)(st + 129968)) + (float)(v23 * *(float *)(st + 129952));
  *(float *)(st + 129984) = v26;
  v27 = *(float *)(st + 129568);
  *(float *)(st + 130016) = (float)((float)(v27 * *(float *)(st + 129888)) - (float)(v27 * v26)) + v26;
  *(float *)(st + 130032) = (float)((float)(v27 * *(float *)(st + 129904)) - (float)(v27 * v26)) + v26;
  v28 = *(float *)(st + 269744);
  *(float *)(st + 269760) = v28;
  v29 = v28 * *(float *)(st + 130032);
  *(float *)(st + 269776) = v28 * *(float *)(st + 130016);
  *(float *)(st + 269792) = v29;
  v30 = *(float *)(st + 269776);
  v31 = **(_DWORD **)(v25 + 136);
  if ( v31 == 1 )
  {
    if ( *(_DWORD *)(st + 11191052) != 1 )
    {
      *(_DWORD *)(st + 4466208) = 0;
      *(_DWORD *)(st + 4466224) = 0;
      *(_DWORD *)(st + 4466240) = 0;
    }
    *(_DWORD *)(st + 11191052) = 1;
    *(_DWORD *)(st + 4466048) = *(_DWORD *)(st + 4466032);
    *(_DWORD *)(st + 4466032) = *(_DWORD *)(st + 4466016);
    *(_DWORD *)(st + 4466016) = *(_DWORD *)(st + 4466000);
    *(_DWORD *)(st + 4466000) = *(_DWORD *)(st + 4465984);
    *(_DWORD *)(st + 4465984) = *(_DWORD *)(st + 4465968);
    *(_DWORD *)(st + 4465968) = *(_DWORD *)(st + 4465952);
    *(_DWORD *)(st + 4465952) = *(_DWORD *)(st + 4465936);
    *(_DWORD *)(st + 4466128) = *(_DWORD *)(st + 4466112);
    *(_DWORD *)(st + 4466112) = *(_DWORD *)(st + 4466096);
    *(_DWORD *)(st + 4466096) = *(_DWORD *)(st + 4466080);
    *(_DWORD *)(st + 4466080) = *(_DWORD *)(st + 4466064);
    *(_DWORD *)(st + 4466192) = *(_DWORD *)(st + 4466176);
    *(_DWORD *)(st + 4466176) = *(_DWORD *)(st + 4466160);
    *(_DWORD *)(st + 4466160) = *(_DWORD *)(st + 4466144);
    *(_DWORD *)(st + 4466240) = *(_DWORD *)(st + 4466224);
    *(_DWORD *)(st + 4466224) = *(_DWORD *)(st + 4466208);
    *(float *)(st + 4465904) = v30;
    *(float *)(st + 4465920) = v29;
    v356 = (float)(v30 + v29) * 0.5;
    *(float *)(st + 4466064) = v356;
    v357 = (float)((float)((float)((float)(v356 * *(float *)(st + 4466304))
                                 + (float)(*(float *)(st + 4466320) * *(float *)(st + 4466080)))
                         + (float)(*(float *)(st + 4466336) * *(float *)(st + 4466096)))
                 + (float)(*(float *)(st + 4466352) * *(float *)(st + 4466112)))
         + (float)(*(float *)(st + 4466368) * *(float *)(st + 4466128));
    *(float *)(st + 4466096) = v357;
    *(float *)(st + 4465936) = (float)((float)((float)(v356
                                                     - (float)(*(float *)(st + 4465952) * *(float *)(st + 4466416)))
                                             - *(float *)(st + 4465968))
                                     * *(float *)(st + 4466400))
                             + *(float *)(st + 4465952);
    v358 = (float)(*(float *)(st + 4466400) * *(float *)(st + 4465952)) + *(float *)(st + 4465968);
    *(float *)(st + 4465952) = v358;
    v359 = *(float *)(st + 4466720) + *(float *)(st + 4466224);
    v33 = 0;
    *(float *)(st + 6563968) = (float)((float)((float)((float)((float)((float)((float)(1.0 - *(float *)(st + 4466384))
                                                                             * v358)
                                                                     + (float)(*(float *)(st + 4466384) * v357))
                                                             * *(float *)(st + 4466432))
                                                     + (float)((float)(1.0 - *(float *)(st + 4466432)) * v356))
                                             * *(float *)(st + 4466528))
                                     + (float)(*(float *)(st + 4466512) * *(float *)(st + 4466032)))
                             * *(float *)(st + 4466544);
    v360 = fminf(*(float *)(st + 4466736), v359) * v11;
    *(float *)(st + 4466208) = v360;
    if ( (float)(v360 - *(float *)(st + 4466192)) >= 0.0 )
      v361 = *(float *)(st + 4466752);
    else
      v361 = *(float *)(st + 4466768);
    v362 = *(float *)(st + 4466288);
    v363 = *(float *)(st + 4466240) + v361;
    *(float *)(st + 4466144) = v362;
    v364 = *(float *)(st + 4466192);
    v365 = *(float *)(st + 4466176);
    v366 = v362 - v364;
    v367 = *(float *)(st + 4466784);
    if ( (float)(v362 - *(float *)(st + 4466160)) != 0.0 )
      v365 = v362 - v364;
    *(float *)(st + 4466160) = v365;
    v368 = fabs(v365) * v367;
    v369 = v364 + v368;
    v370 = fmaxf(v364 - v368, v362);
    if ( v366 > 0.0 )
      v370 = fminf(v369, v362);
    *(float *)(st + 4466176) = v370;
    v49 = 0.0;
    if ( v363 <= 0.0 )
      v371 = 0.0;
    else
      v371 = v363;
    v51 = -1.0;
    v372 = v371;
    if ( v372 >= -1.0 )
      v373 = fminf(v372, 1.0);
    else
      v373 = -1.0;
    *(float *)(st + 4466224) = v373 * *(float *)(st + 4466544);
    v374 = v370 * *(float *)(st + 4466496);
    if ( v374 <= 0.00012207031 )
      v375 = 0.0001220703125;
    else
      v375 = v374;
    v376 = (int)(float)(v370 * -16384.0);
    *(_DWORD *)(st + 6563984) = *(_DWORD *)(st
                                          + 4
                                          * ((*(int *)(st + 6563956) - 1LL) & (*(_DWORD *)(st + 6563952) - v376 + 1LL))
                                          + 4466800);
    *(_DWORD *)(st + 6563988) = *(_DWORD *)(st
                                          + 4
                                          * ((*(int *)(st + 6563956) - 1LL) & (*(_DWORD *)(st + 6563952) - v376 + 2LL))
                                          + 4466800);
    v377 = v375;
    v378 = (float)(v370 * 16384.0) - (double)(int)(float)(v370 * 16384.0);
    v379 = (int)(float)(v377 * -16384.0);
    *(float *)(st + 6563992) = v378;
    v380 = *(float *)(st + 6563984);
    *(_DWORD *)(st + 6564000) = *(_DWORD *)(st
                                          + 4
                                          * ((*(int *)(st + 6563956) - 1LL) & (*(_DWORD *)(st + 6563952) - v379 + 1LL))
                                          + 4466800);
    *(_DWORD *)(st + 6564004) = *(_DWORD *)(st
                                          + 4
                                          * ((*(int *)(st + 6563956) - 1LL) & (*(_DWORD *)(st + 6563952) - v379 + 2LL))
                                          + 4466800);
    v381 = (float)(v377 * 16384.0) - (double)(int)(float)(v377 * 16384.0);
    *(float *)(st + 6564008) = v381;
    v382 = *(float *)(st + 4466000);
    v383 = (float)((float)((float)(v378 * *(float *)(st + 6563988)) - (float)(v378 * v380)) + v380)
         * *(float *)(st + 4466240);
    *(float *)(st + 4465968) = v383;
    v384 = *(float *)(st + 6564000);
    v385 = *(float *)(st + 4466016);
    v386 = *(float *)(st + 4466624) * (float)(v383 - v382);
    v387 = (float)((float)(v383 - v382) * *(float *)(st + 4466608)) + v382;
    v388 = *(float *)(st + 4466640) * v387;
    *(float *)(st + 4465984) = v387;
    v389 = *(float *)(st + 4466048);
    v390 = (float)(v386 - v388) - v385;
    v391 = *(float *)(st + 4466672) * v390;
    v392 = (float)(v390 * *(float *)(st + 4466656)) + v385;
    v393 = *(float *)(st + 4466688);
    *(float *)(st + 4466000) = v392;
    v394 = (float)((float)(v393 * v392) - v391) - v389;
    *(float *)(st + 4466016) = v394;
    *(float *)(st + 4466032) = (float)(v394 * *(float *)(st + 4466704)) + v389;
    v395 = *(float *)(st + 4465920);
    v396 = *(float *)(st + 4466560);
    v397 = *(float *)(st + 4466528);
    v398 = *(float *)(st + 4465968);
    v399 = (float)(1.0 - v396) * v398;
    v400 = (float)((float)((float)((float)((float)(v381 * *(float *)(st + 6564004)) - (float)(v381 * v384)) + v384)
                         * *(float *)(st + 4466240))
                 * v396)
         - (float)(*(float *)(st + 4466576) * v399);
    v401 = *(float *)(st + 4466464);
    v402 = v400 + v399;
    v403 = *(float *)(st + 4466592);
    v404 = (float)(v398 * v401) * v403;
    v405 = v402 * v401;
    v406 = *(float *)(st + 4466448);
    v407 = (float)((float)(1.0 - *(float *)(st + 4466576)) * v395) * v406;
    *(float *)(st + 4466256) = (float)((float)((float)(1.0 - v397) * *(float *)(st + 4465904))
                                     + (float)(v397
                                             * (float)((float)((float)(*(float *)(st + 4466576) * v395)
                                                             + *(float *)(st + 4465904))
                                                     * v406)))
                             + v404;
    *(float *)(st + 4466272) = (float)((float)((float)(1.0 - v397) * v395) + (float)(v397 * v407))
                             + (float)(v405 * v403);
    v408 = (*(_DWORD *)(st + 6563956) - 1) & (*(_DWORD *)(st + 6563952) - 1);
    *(_DWORD *)(st + 6563952) = v408;
    *(_DWORD *)(st + 4LL * v408 + 4466800) = *(_DWORD *)(st + 6563968);
    v409 = *(float *)(st + 270448);
    v161 = v409 * *(float *)(st + 4466272);
    v162 = v409 * *(float *)(st + 4466256);
  }
  else
  {
    if ( v31 <= 1 )
    {
LABEL_61:
      if ( *(_DWORD *)(st + 11191052) )
      {
        *(_DWORD *)(st + 270976) = 0;
        *(_DWORD *)(st + 270992) = 0;
        *(_DWORD *)(st + 271008) = 0;
      }
      *(_DWORD *)(st + 11191052) = 0;
      *(_DWORD *)(st + 270608) = *(_DWORD *)(st + 270592);
      *(_DWORD *)(st + 270592) = *(_DWORD *)(st + 270576);
      *(_DWORD *)(st + 270576) = *(_DWORD *)(st + 270560);
      *(_DWORD *)(st + 270560) = *(_DWORD *)(st + 270544);
      *(_DWORD *)(st + 270544) = *(_DWORD *)(st + 270528);
      *(_DWORD *)(st + 270528) = *(_DWORD *)(st + 270512);
      *(_DWORD *)(st + 270512) = *(_DWORD *)(st + 270496);
      *(_DWORD *)(st + 270736) = *(_DWORD *)(st + 270720);
      *(_DWORD *)(st + 270720) = *(_DWORD *)(st + 270704);
      *(_DWORD *)(st + 270704) = *(_DWORD *)(st + 270688);
      *(_DWORD *)(st + 270688) = *(_DWORD *)(st + 270672);
      *(_DWORD *)(st + 270672) = *(_DWORD *)(st + 270656);
      *(_DWORD *)(st + 270656) = *(_DWORD *)(st + 270640);
      *(_DWORD *)(st + 270640) = *(_DWORD *)(st + 270624);
      *(_DWORD *)(st + 270816) = *(_DWORD *)(st + 270800);
      *(_DWORD *)(st + 270800) = *(_DWORD *)(st + 270784);
      *(_DWORD *)(st + 270784) = *(_DWORD *)(st + 270768);
      *(_DWORD *)(st + 270768) = *(_DWORD *)(st + 270752);
      *(_DWORD *)(st + 270896) = *(_DWORD *)(st + 270880);
      *(_DWORD *)(st + 270880) = *(_DWORD *)(st + 270864);
      *(_DWORD *)(st + 270864) = *(_DWORD *)(st + 270848);
      *(_DWORD *)(st + 270848) = *(_DWORD *)(st + 270832);
      *(_DWORD *)(st + 271008) = *(_DWORD *)(st + 270992);
      *(_DWORD *)(st + 270992) = *(_DWORD *)(st + 270976);
      *(_DWORD *)(st + 270960) = *(_DWORD *)(st + 270944);
      *(_DWORD *)(st + 270944) = *(_DWORD *)(st + 270928);
      *(_DWORD *)(st + 270928) = *(_DWORD *)(st + 270912);
      *(float *)(st + 270464) = v30;
      *(float *)(st + 270480) = v29;
      *(float *)(st + 270752) = v30;
      v298 = (float)((float)((float)((float)(v30 * *(float *)(st + 271072))
                                   + (float)(*(float *)(st + 271088) * *(float *)(st + 270768)))
                           + (float)(*(float *)(st + 271104) * *(float *)(st + 270784)))
                   + (float)(*(float *)(st + 271120) * *(float *)(st + 270800)))
           + (float)(*(float *)(st + 270816) * *(float *)(st + 271136));
      *(float *)(st + 270784) = v298;
      *(float *)(st + 270496) = (float)((float)((float)(v30 - (float)(*(float *)(st + 270512) * *(float *)(st + 271184)))
                                              - *(float *)(st + 270528))
                                      * *(float *)(st + 271168))
                              + *(float *)(st + 270512);
      v33 = 0;
      v299 = (float)(*(float *)(st + 270512) * *(float *)(st + 271168)) + *(float *)(st + 270528);
      *(float *)(st + 270512) = v299;
      *(float *)(st + 4465840) = (float)((float)((float)((float)((float)((float)((float)(1.0 - *(float *)(st + 271152))
                                                                               * v299)
                                                                       + (float)(*(float *)(st + 271152) * v298))
                                                               * *(float *)(st + 271200))
                                                       + (float)((float)(1.0 - *(float *)(st + 271200)) * v30))
                                               * *(float *)(st + 271280))
                                       + (float)(*(float *)(st + 270592) * *(float *)(st + 271264)))
                               * *(float *)(st + 271296);
      v300 = *(float *)(st + 270480);
      *(float *)(st + 270832) = v300;
      v301 = (float)((float)((float)((float)(v300 * *(float *)(st + 271072))
                                   + (float)(*(float *)(st + 270848) * *(float *)(st + 271088)))
                           + (float)(*(float *)(st + 270864) * *(float *)(st + 271104)))
                   + (float)(*(float *)(st + 271120) * *(float *)(st + 270880)))
           + (float)(*(float *)(st + 270896) * *(float *)(st + 271136));
      *(float *)(st + 270864) = v301;
      *(float *)(st + 270624) = (float)((float)((float)(v300 - (float)(*(float *)(st + 270640) * *(float *)(st + 271184)))
                                              - *(float *)(st + 270656))
                                      * *(float *)(st + 271168))
                              + *(float *)(st + 270640);
      v302 = (float)(*(float *)(st + 270640) * *(float *)(st + 271168)) + *(float *)(st + 270656);
      *(float *)(st + 270640) = v302;
      *(float *)(st + 4465872) = (float)((float)((float)((float)((float)((float)((float)(1.0 - *(float *)(st + 271152))
                                                                               * v302)
                                                                       + (float)(*(float *)(st + 271152) * v301))
                                                               * *(float *)(st + 271200))
                                                       + (float)((float)(1.0 - *(float *)(st + 271200)) * v300))
                                               * *(float *)(st + 271280))
                                       + (float)(*(float *)(st + 271264) * *(float *)(st + 270720)))
                               * *(float *)(st + 271296);
      v303 = (float)(*(float *)(st + 271424) + *(float *)(st + 270992)) * v11;
      *(float *)(st + 270976) = v303;
      if ( (float)(v303 - *(float *)(st + 270960)) >= 0.0 )
        v304 = *(float *)(st + 271456);
      else
        v304 = *(float *)(st + 271472);
      v305 = *(float *)(st + 271056);
      v306 = *(float *)(st + 271008) + v304;
      *(float *)(st + 270912) = v305;
      v307 = *(float *)(st + 270960);
      v308 = *(float *)(st + 270944);
      v309 = v305 - v307;
      v310 = *(float *)(st + 271488);
      if ( (float)(v305 - *(float *)(st + 270928)) != 0.0 )
        v308 = v305 - v307;
      *(float *)(st + 270928) = v308;
      v311 = fabs(v308) * v310;
      v312 = v307 + v311;
      v313 = fmaxf(v307 - v311, v305);
      if ( v309 > 0.0 )
        v313 = fminf(v312, v305);
      *(float *)(st + 270944) = v313;
      v49 = 0.0;
      if ( v306 <= 0.0 )
        v314 = 0.0;
      else
        v314 = v306;
      v51 = -1.0;
      v315 = v314;
      if ( v315 >= -1.0 )
        v316 = fminf(v315, 1.0);
      else
        v316 = -1.0;
      *(float *)(st + 270992) = v316 * *(float *)(st + 271296);
      v317 = (int)(float)(v313 * -16384.0);
      *(_DWORD *)(st + 4465856) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 2368660) - 1LL) & (*(_DWORD *)(st + 2368656) - v317 + 1LL))
                                            + 271504);
      *(_DWORD *)(st + 4465860) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 2368660) - 1LL) & (*(_DWORD *)(st + 2368656) - v317 + 2LL))
                                            + 271504);
      v318 = (float)(v313 * 16384.0) - (double)(int)(float)(v313 * 16384.0);
      *(float *)(st + 4465864) = v318;
      v319 = *(float *)(st + 4465856);
      *(_DWORD *)(st + 4465888) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 4465828) - 1LL) & (*(_DWORD *)(st + 4465824) - v317 + 1LL))
                                            + 2368672);
      *(_DWORD *)(st + 4465892) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 4465828) - 1LL) & (*(_DWORD *)(st + 4465824) - v317 + 2LL))
                                            + 2368672);
      *(float *)(st + 4465896) = v318;
      v320 = *(float *)(st + 270560);
      v321 = (float)((float)((float)(v318 * *(float *)(st + 4465860)) - (float)(v318 * v319)) + v319)
           * *(float *)(st + 271008);
      *(float *)(st + 270528) = v321;
      v322 = v321 - v320;
      v323 = *(float *)(st + 270576);
      v324 = *(float *)(st + 4465888);
      v325 = *(float *)(st + 271328) * v322;
      v326 = (float)(v322 * *(float *)(st + 271312)) + v320;
      v327 = *(float *)(st + 271344);
      *(float *)(st + 270544) = v326;
      v328 = *(float *)(st + 270608);
      v329 = v325 - (float)(v327 * v326);
      v330 = *(float *)(st + 271376);
      v331 = v329 - v323;
      v332 = (float)(v331 * *(float *)(st + 271360)) + v323;
      v333 = *(float *)(st + 271392);
      *(float *)(st + 270560) = v332;
      v334 = (float)((float)(v333 * v332) - (float)(v330 * v331)) - v328;
      *(float *)(st + 270576) = v334;
      *(float *)(st + 270592) = (float)(v334 * *(float *)(st + 271408)) + v328;
      v335 = *(float *)(st + 270688);
      v336 = (float)((float)((float)(v318 * *(float *)(st + 4465892)) - (float)(v318 * v324)) + v324)
           * *(float *)(st + 271008);
      *(float *)(st + 270656) = v336;
      v337 = v336 - v335;
      v338 = *(float *)(st + 270704);
      v339 = *(float *)(st + 271328) * v337;
      v340 = (float)(v337 * *(float *)(st + 271312)) + v335;
      v341 = *(float *)(st + 271344);
      *(float *)(st + 270672) = v340;
      v342 = *(float *)(st + 270736);
      v343 = (float)(v339 - (float)(v341 * v340)) - v338;
      v344 = *(float *)(st + 271376) * v343;
      v345 = (float)(v343 * *(float *)(st + 271360)) + v338;
      v346 = *(float *)(st + 271392);
      *(float *)(st + 270688) = v345;
      v347 = (float)((float)(v346 * v345) - v344) - v342;
      *(float *)(st + 270704) = v347;
      v348 = *(float *)(st + 271232);
      v349 = *(float *)(st + 270528) * v348;
      v350 = *(float *)(st + 270656) * v348;
      *(float *)(st + 270720) = v342 + (float)(v347 * *(float *)(st + 271408));
      v351 = *(float *)(st + 271280);
      v352 = (float)((float)((float)(1.0 - v351) * *(float *)(st + 270480))
                   + (float)(v351 * (float)(*(float *)(st + 271216) * *(float *)(st + 270480))))
           + v350;
      *(float *)(st + 271024) = (float)((float)((float)(1.0 - v351) * *(float *)(st + 270464))
                                      + (float)(v351 * (float)(*(float *)(st + 271216) * *(float *)(st + 270464))))
                              + v349;
      *(float *)(st + 271040) = v352;
      v353 = (*(_DWORD *)(st + 2368660) - 1) & (*(_DWORD *)(st + 2368656) - 1);
      *(_DWORD *)(st + 2368656) = v353;
      *(_DWORD *)(st + 4LL * v353 + 271504) = *(_DWORD *)(st + 4465840);
      v354 = (*(_DWORD *)(st + 4465828) - 1) & (*(_DWORD *)(st + 4465824) - 1);
      *(_DWORD *)(st + 4465824) = v354;
      *(_DWORD *)(st + 4LL * v354 + 2368672) = *(_DWORD *)(st + 4465872);
      v355 = *(float *)(st + 270448);
      v161 = v355 * *(float *)(st + 271040);
      v162 = v355 * *(float *)(st + 271024);
      goto LABEL_96;
    }
    if ( v31 <= 3 )
    {
      if ( *(_DWORD *)(st + 11191052) != 2 )
      {
        *(_DWORD *)(st + 6564688) = 0;
        *(_DWORD *)(st + 6564704) = 0;
        *(_DWORD *)(st + 6564720) = 0;
      }
      *(_DWORD *)(st + 11191052) = 2;
      v231 = *(_DWORD *)(st + 6564032);
      *(_DWORD *)(st + 6564048) = *(_DWORD *)(st + 6564016);
      *(_DWORD *)(st + 6564064) = v231;
      v232 = jx_h_3A2010(0.0)/*ARGLESS*/;
      *(float *)(st + 6564080) = fmaxf(fminf(v232, 512.0), -512.0);
      v233 = *(float *)(st + 6564064);
      *(_DWORD *)(st + 6564320) = *(_DWORD *)(st + 6564304);
      v33 = 0;
      v234 = jx_h_3A21E0(0.0f)/*ARGLESS*/;
      v235 = *(float *)&v234;
      *(float *)&v234 = jx_h_3A2210(0.0f)/*ARGLESS*/;
      *(_DWORD *)(st + 6564336) = LODWORD(v234);
      *(float *)(st + 6564304) = (float)(v235 * v233) + (float)(v233 - 1.0);
      v236 = (float)(*(float *)&v234 * *(float *)(st + 6564400)) + *(float *)(st + 6564416);
      *(float *)(st + 6564384) = v236;
      v237 = 1.0 - v236;
      *(_DWORD *)(st + 6564560) = *(_DWORD *)(st + 6564544);
      *(_DWORD *)(st + 6564544) = *(_DWORD *)(st + 6564528);
      *(_DWORD *)(st + 6564528) = *(_DWORD *)(st + 6564512);
      *(_DWORD *)(st + 6564512) = *(_DWORD *)(st + 6564496);
      *(_DWORD *)(st + 6564496) = *(_DWORD *)(st + 6564480);
      *(_DWORD *)(st + 6564640) = *(_DWORD *)(st + 6564624);
      *(_DWORD *)(st + 6564624) = *(_DWORD *)(st + 6564608);
      *(_DWORD *)(st + 6564608) = *(_DWORD *)(st + 6564592);
      *(_DWORD *)(st + 6564592) = *(_DWORD *)(st + 6564576);
      *(_DWORD *)(st + 6564672) = *(_DWORD *)(st + 6564656);
      *(_DWORD *)(st + 6564720) = *(_DWORD *)(st + 6564704);
      *(_DWORD *)(st + 6564704) = *(_DWORD *)(st + 6564688);
      *(float *)(st + 6564464) = v236;
      LODWORD(v234) = *(_DWORD *)(st + 6564864);
      *(float *)(st + 6564432) = v30;
      *(float *)(st + 6564448) = v29;
      v238 = *(float *)(st + 6564848);
      v239 = (float)(v29 + v30) * 0.5;
      v240 = (float)((float)((float)(v236 * 0.5) + *(float *)&v234) * (float)((float)(v236 * 0.5) + *(float *)&v234))
           * v238;
      v241 = (float)((float)((float)((float)((float)(1.0 - v236) * 0.5) + *(float *)&v234)
                           * (float)((float)((float)(1.0 - v236) * 0.5) + *(float *)&v234))
                   * v238)
           - (float)(v238 * (float)(1.0 - v236));
      v242 = *(float *)(st + 6565232);
      v243 = v236 + (float)(v240 - (float)(*(float *)(st + 6564848) * v236));
      v244 = *(float *)(st + 6565248);
      v245 = *(float *)(st + 6564880) * (float)(v237 + v241);
      *(float *)(st + 6564736) = (float)((float)(*(float *)(st + 6564880) * v243) * v242) + v244;
      *(float *)(st + 6564752) = (float)(v245 * v242) + v244;
      *(float *)(st + 6564576) = v239;
      v246 = (float)((float)((float)((float)(v239 * *(float *)(st + 6564896))
                                   + (float)(*(float *)(st + 6564912) * *(float *)(st + 6564592)))
                           + (float)(*(float *)(st + 6564928) * *(float *)(st + 6564608)))
                   + (float)(*(float *)(st + 6564944) * *(float *)(st + 6564624)))
           + (float)(*(float *)(st + 6564960) * *(float *)(st + 6564640));
      *(float *)(st + 6564608) = v246;
      *(float *)(st + 6564480) = (float)((float)((float)(v239
                                                       - (float)(*(float *)(st + 6564496) * *(float *)(st + 6565008)))
                                               - *(float *)(st + 6564512))
                                       * *(float *)(st + 6564992))
                               + *(float *)(st + 6564496);
      v247 = (float)(*(float *)(st + 6564992) * *(float *)(st + 6564496)) + *(float *)(st + 6564512);
      *(float *)(st + 6564496) = v247;
      LODWORD(v234) = *(_DWORD *)(st + 6564976);
      v248 = *(float *)(st + 6565120);
      v249 = (float)(1.0 - *(float *)&v234) * v247;
      v250 = *(float *)(st + 6564528);
      v251 = (float)((float)(v249 + (float)(*(float *)&v234 * v246)) * *(float *)(st + 6565024))
           + (float)((float)(1.0 - *(float *)(st + 6565024)) * v239);
      LODWORD(v234) = *(_DWORD *)(st + 6565136);
      v252 = (float)((float)(v251 - v250) * *(float *)(st + 6565040)) + v250;
      v253 = v251
           + (float)((float)(*(float *)(st + 6565056) * (float)(v251 - v250)) - (float)(*(float *)(st + 6565056) * v251));
      *(float *)(st + 6564512) = v252;
      v254 = *(float *)(st + 6565152);
      v255 = *(float *)(st + 6565280) + *(float *)(st + 6564704);
      *(float *)(st + 6598128) = v254
                               * (float)((float)(v248 * *(float *)(st + 6564544)) + (float)(*(float *)&v234 * v253));
      v256 = fminf(*(float *)(st + 6565296), v255) * v254;
      *(float *)(st + 6564688) = v256;
      if ( (float)(v256 - *(float *)(st + 6564672)) >= 0.0 )
        v257 = *(float *)(st + 6565312);
      else
        v257 = *(float *)(st + 6565328);
      v258 = *(float *)(st + 6564832);
      v259 = *(float *)(st + 6564720) + v257;
      v260 = *(float *)(st + 6564672);
      v49 = 0.0;
      if ( v259 <= 0.0 )
        v261 = 0.0;
      else
        v261 = v259;
      v51 = -1.0;
      v262 = v261;
      v263 = (float)((float)(*(float *)(st + 6564832) - v260) * *(float *)(st + 6565104)) + v260;
      if ( v262 >= -1.0 )
        v264 = fminf(v262, 1.0);
      else
        v264 = -1.0;
      *(float *)(st + 6564704) = v264 * *(float *)(st + 6565152);
      if ( (float)(v263 - v260) != 0.0 )
        v258 = v263;
      v265 = v258;
      *(float *)(st + 6564656) = v258;
      v266 = v258 + *(float *)(st + 6564736);
      v267 = (int)(float)(v266 * -16384.0);
      *(_DWORD *)(st + 6598144) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 6598116) - 1LL) & (*(_DWORD *)(st + 6598112) - v267 + 1LL))
                                            + 6565344);
      *(_DWORD *)(st + 6598148) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 6598116) - 1LL) & (*(_DWORD *)(st + 6598112) - v267 + 2LL))
                                            + 6565344);
      v268 = (float)(v266 * 16384.0) - (double)(int)(float)(v266 * 16384.0);
      *(float *)(st + 6598152) = v268;
      v269 = *(float *)(st + 6598144);
      v270 = *(float *)(st + 6564720);
      v271 = v265 + *(float *)(st + 6564752);
      v272 = (int)(float)(v271 * -16384.0);
      *(_DWORD *)(st + 6598160) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 6598116) - 1LL) & (*(_DWORD *)(st + 6598112) - v272 + 1LL))
                                            + 6565344);
      *(_DWORD *)(st + 6598164) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 6598116) - 1LL) & (*(_DWORD *)(st + 6598112) - v272 + 2LL))
                                            + 6565344);
      v273 = (float)(v271 * 16384.0) - (double)(int)(float)(v271 * 16384.0);
      *(float *)(st + 6598168) = v273;
      v274 = *(float *)(st + 6564560);
      v275 = (float)((float)(v268 * *(float *)(st + 6598148)) - (float)(v268 * v269)) + v269;
      v276 = *(float *)(st + 6598160);
      v277 = v275 * v270;
      *(float *)(st + 6564528) = v277 - v274;
      *(float *)(st + 6564544) = (float)((float)(v277 - v274) * *(float *)(st + 6565264)) + v274;
      v278 = *(float *)(st + 6564448);
      v279 = *(float *)(st + 6565168);
      v280 = (float)(1.0 - v279) * v277;
      v281 = (float)((float)((float)(v273 * *(float *)(st + 6598164)) - (float)(v273 * v276)) + v276) * v270;
      v282 = *(float *)(st + 6564432);
      v283 = (float)(1.0 - *(float *)(st + 6565184)) * v278;
      v284 = v279 * v281;
      v285 = *(float *)(st + 6565184);
      v286 = *(float *)(st + 6565088);
      v287 = v277 * v286;
      v288 = (float)((float)(v284 - (float)(v285 * v280)) + v280) * v286;
      v289 = *(float *)(st + 6565216);
      v290 = v289 * v287;
      *(float *)(st + 6564768) = v289 * v288;
      *(float *)(st + 6564784) = v289 * v287;
      v291 = *(float *)(st + 6565072);
      v292 = *(float *)(st + 6565136);
      v293 = (float)((float)(v285 * v278) + v282) * v291;
      v294 = v283 * v291;
      v295 = *(float *)(st + 6565200);
      *(float *)(st + 6564800) = (float)((float)((float)(1.0 - v292) * v282) + (float)(v292 * (float)(v293 * v295)))
                               + *(float *)(st + 6564768);
      *(float *)(st + 6564816) = (float)((float)((float)(1.0 - v292) * v278) + (float)(v292 * (float)(v294 * v295)))
                               + v290;
      v296 = (*(_DWORD *)(st + 6598116) - 1) & (*(_DWORD *)(st + 6598112) - 1);
      *(_DWORD *)(st + 6598112) = v296;
      *(_DWORD *)(st + 4LL * v296 + 6565344) = *(_DWORD *)(st + 6598128);
      v297 = *(float *)(st + 270448);
      v161 = v297 * *(float *)(st + 6564816);
      v162 = v297 * *(float *)(st + 6564800);
    }
    else
    {
      if ( v31 != 4 )
      {
        if ( v31 == 5 )
        {
          if ( *(_DWORD *)(st + 11191052) != 5 )
          {
            *(_DWORD *)(st + 6665792) = 0;
            *(_DWORD *)(st + 6665808) = 0;
            *(_DWORD *)(st + 6665824) = 0;
            *(_DWORD *)(st + 10861568) = 0;
            *(_DWORD *)(st + 10861584) = 0;
            *(_DWORD *)(st + 10861600) = 0;
          }
          *(_DWORD *)(st + 11191052) = 5;
          *(_DWORD *)(st + 6665424) = *(_DWORD *)(st + 6665408);
          *(_DWORD *)(st + 6665408) = *(_DWORD *)(st + 6665392);
          *(_DWORD *)(st + 6665392) = *(_DWORD *)(st + 6665376);
          *(_DWORD *)(st + 6665376) = *(_DWORD *)(st + 6665360);
          *(_DWORD *)(st + 6665360) = *(_DWORD *)(st + 6665344);
          *(_DWORD *)(st + 6665344) = *(_DWORD *)(st + 6665328);
          *(_DWORD *)(st + 6665328) = *(_DWORD *)(st + 6665312);
          *(_DWORD *)(st + 6665552) = *(_DWORD *)(st + 6665536);
          *(_DWORD *)(st + 6665536) = *(_DWORD *)(st + 6665520);
          *(_DWORD *)(st + 6665520) = *(_DWORD *)(st + 6665504);
          *(_DWORD *)(st + 6665504) = *(_DWORD *)(st + 6665488);
          *(_DWORD *)(st + 6665488) = *(_DWORD *)(st + 6665472);
          *(_DWORD *)(st + 6665472) = *(_DWORD *)(st + 6665456);
          *(_DWORD *)(st + 6665456) = *(_DWORD *)(st + 6665440);
          *(_DWORD *)(st + 6665632) = *(_DWORD *)(st + 6665616);
          *(_DWORD *)(st + 6665616) = *(_DWORD *)(st + 6665600);
          *(_DWORD *)(st + 6665600) = *(_DWORD *)(st + 6665584);
          *(_DWORD *)(st + 6665584) = *(_DWORD *)(st + 6665568);
          *(_DWORD *)(st + 6665712) = *(_DWORD *)(st + 6665696);
          *(_DWORD *)(st + 6665696) = *(_DWORD *)(st + 6665680);
          *(_DWORD *)(st + 6665680) = *(_DWORD *)(st + 6665664);
          *(_DWORD *)(st + 6665664) = *(_DWORD *)(st + 6665648);
          *(_DWORD *)(st + 6665824) = *(_DWORD *)(st + 6665808);
          *(_DWORD *)(st + 6665808) = *(_DWORD *)(st + 6665792);
          *(_DWORD *)(st + 6665776) = *(_DWORD *)(st + 6665760);
          *(_DWORD *)(st + 6665760) = *(_DWORD *)(st + 6665744);
          *(_DWORD *)(st + 6665744) = *(_DWORD *)(st + 6665728);
          *(float *)(st + 6665280) = v30;
          *(float *)(st + 6665296) = v29;
          *(float *)(st + 6665568) = v30;
          v32 = (float)((float)((float)((float)(*(float *)(st + 6665584) * *(float *)(st + 6665904))
                                      + (float)(v30 * *(float *)(st + 6665888)))
                              + (float)(*(float *)(st + 6665920) * *(float *)(st + 6665600)))
                      + (float)(*(float *)(st + 6665616) * *(float *)(st + 6665936)))
              + (float)(*(float *)(st + 6665952) * *(float *)(st + 6665632));
          *(float *)(st + 6665600) = v32;
          *(float *)(st + 6665312) = (float)((float)((float)(v30
                                                           - (float)(*(float *)(st + 6665328) * *(float *)(st + 6666000)))
                                                   - *(float *)(st + 6665344))
                                           * *(float *)(st + 6665984))
                                   + *(float *)(st + 6665328);
          v33 = 0;
          v34 = (float)(*(float *)(st + 6665984) * *(float *)(st + 6665328)) + *(float *)(st + 6665344);
          *(float *)(st + 6665328) = v34;
          *(float *)(st + 10860656) = (float)((float)((float)((float)((float)((float)((float)(1.0
                                                                                            - *(float *)(st + 6665968))
                                                                                    * v34)
                                                                            + (float)(*(float *)(st + 6665968) * v32))
                                                                    * *(float *)(st + 6666016))
                                                            + (float)((float)(1.0 - *(float *)(st + 6666016)) * v30))
                                                    * *(float *)(st + 6666096))
                                            + (float)(*(float *)(st + 6665408) * *(float *)(st + 6666080)))
                                    * *(float *)(st + 6666112);
          v35 = *(float *)(st + 6665296);
          *(float *)(st + 6665648) = v35;
          v36 = (float)((float)((float)((float)(*(float *)(st + 6665664) * *(float *)(st + 6665904))
                                      + (float)(v35 * *(float *)(st + 6665888)))
                              + (float)(*(float *)(st + 6665680) * *(float *)(st + 6665920)))
                      + (float)(*(float *)(st + 6665936) * *(float *)(st + 6665696)))
              + (float)(*(float *)(st + 6665952) * *(float *)(st + 6665712));
          *(float *)(st + 6665680) = v36;
          *(float *)(st + 6665440) = (float)((float)((float)(v35
                                                           - (float)(*(float *)(st + 6665456) * *(float *)(st + 6666000)))
                                                   - *(float *)(st + 6665472))
                                           * *(float *)(st + 6665984))
                                   + *(float *)(st + 6665456);
          v37 = (float)(*(float *)(st + 6665984) * *(float *)(st + 6665456)) + *(float *)(st + 6665472);
          *(float *)(st + 6665456) = v37;
          *(float *)(st + 10860688) = (float)((float)((float)((float)((float)((float)((float)(1.0
                                                                                            - *(float *)(st + 6665968))
                                                                                    * v37)
                                                                            + (float)(*(float *)(st + 6665968) * v36))
                                                                    * *(float *)(st + 6666016))
                                                            + (float)((float)(1.0 - *(float *)(st + 6666016)) * v35))
                                                    * *(float *)(st + 6666096))
                                            + (float)(*(float *)(st + 6666080) * *(float *)(st + 6665536)))
                                    * *(float *)(st + 6666112);
          v38 = (float)(*(float *)(st + 6666240) + *(float *)(st + 6665808)) * v11;
          *(float *)(st + 6665792) = v38;
          if ( (float)(v38 - *(float *)(st + 6665776)) >= 0.0 )
            v39 = *(float *)(st + 6666272);
          else
            v39 = *(float *)(st + 6666288);
          v40 = *(float *)(st + 6665872);
          v41 = v39 + *(float *)(st + 6665824);
          *(float *)(st + 6665728) = v40;
          v42 = *(float *)(st + 6665776);
          v43 = *(float *)(st + 6665760);
          v44 = v40 - v42;
          v45 = *(float *)(st + 6666304);
          if ( (float)(v40 - *(float *)(st + 6665744)) != 0.0 )
            v43 = v40 - v42;
          *(float *)(st + 6665744) = v43;
          v46 = fabs(v43) * v45;
          v47 = v42 + v46;
          v48 = fmaxf(v42 - v46, v40);
          if ( v44 > 0.0 )
            v48 = fminf(v47, v40);
          *(float *)(st + 6665760) = v48;
          v49 = 0.0;
          if ( v41 <= 0.0 )
            v50 = 0.0;
          else
            v50 = v41;
          v51 = -1.0;
          v52 = v50;
          if ( v52 >= -1.0 )
            v53 = fminf(v52, 1.0);
          else
            v53 = -1.0;
          *(float *)(st + 6665808) = v53 * *(float *)(st + 6666112);
          *(_DWORD *)(st + 10860672) = *(_DWORD *)(st
                                                 + 4
                                                 * ((*(int *)(st + 8763476) - 1LL)
                                                  & (*(_DWORD *)(st + 8763472) - (int)(float)(v48 * -16384.0) + 1LL))
                                                 + 6666320);
          *(_DWORD *)(st + 10860676) = *(_DWORD *)(st
                                                 + 4
                                                 * ((*(int *)(st + 8763476) - 1LL)
                                                  & (*(_DWORD *)(st + 8763472) - (int)(float)(v48 * -16384.0) + 2LL))
                                                 + 6666320);
          v54 = (float)(v48 * 16384.0) - (double)(int)(float)(v48 * 16384.0);
          *(float *)(st + 10860680) = v54;
          v55 = *(float *)(st + 10860672);
          *(_DWORD *)(st + 10860704) = *(_DWORD *)(st
                                                 + 4
                                                 * ((*(int *)(st + 10860644) - 1LL)
                                                  & (*(_DWORD *)(st + 10860640) - (int)(float)(v48 * -16384.0) + 1LL))
                                                 + 8763488);
          *(_DWORD *)(st + 10860708) = *(_DWORD *)(st
                                                 + 4
                                                 * ((*(int *)(st + 10860644) - 1LL)
                                                  & (*(_DWORD *)(st + 10860640) - (int)(float)(v48 * -16384.0) + 2LL))
                                                 + 8763488);
          *(float *)(st + 10860712) = v54;
          v56 = *(float *)(st + 6665376);
          v57 = (float)((float)((float)(v54 * *(float *)(st + 10860676)) - (float)(v54 * v55)) + v55)
              * *(float *)(st + 6665824);
          *(float *)(st + 6665344) = v57;
          v58 = v57 - v56;
          v59 = *(float *)(st + 6665392);
          v60 = *(float *)(st + 10860704);
          v61 = *(float *)(st + 6666144) * v58;
          v62 = (float)(v58 * *(float *)(st + 6666128)) + v56;
          v63 = *(float *)(st + 6666160);
          *(float *)(st + 6665360) = v62;
          v64 = *(float *)(st + 6665424);
          v65 = v61 - (float)(v63 * v62);
          v66 = *(float *)(st + 6666192);
          v67 = v65 - v59;
          v68 = (float)(v67 * *(float *)(st + 6666176)) + v59;
          v69 = *(float *)(st + 6666208);
          *(float *)(st + 6665376) = v68;
          v70 = (float)((float)(v69 * v68) - (float)(v66 * v67)) - v64;
          *(float *)(st + 6665392) = v70;
          *(float *)(st + 6665408) = (float)(v70 * *(float *)(st + 6666224)) + v64;
          v71 = *(float *)(st + 6665504);
          v72 = (float)((float)((float)(v54 * *(float *)(st + 10860708)) - (float)(v54 * v60)) + v60)
              * *(float *)(st + 6665824);
          *(float *)(st + 6665472) = v72;
          v73 = v72 - v71;
          v74 = *(float *)(st + 6665520);
          v75 = *(float *)(st + 6666144) * v73;
          v76 = (float)(v73 * *(float *)(st + 6666128)) + v71;
          v77 = *(float *)(st + 6666160);
          *(float *)(st + 6665488) = v76;
          v78 = *(float *)(st + 6665552);
          v79 = (float)(v75 - (float)(v77 * v76)) - v74;
          v80 = *(float *)(st + 6666192) * v79;
          v81 = (float)(v79 * *(float *)(st + 6666176)) + v74;
          v82 = *(float *)(st + 6666208);
          *(float *)(st + 6665504) = v81;
          v83 = (float)((float)(v82 * v81) - v80) - v78;
          *(float *)(st + 6665520) = v83;
          v84 = *(float *)(st + 6666048);
          v85 = *(float *)(st + 6665344) * v84;
          v86 = *(float *)(st + 6665472) * v84;
          *(float *)(st + 6665536) = v78 + (float)(v83 * *(float *)(st + 6666224));
          v87 = *(float *)(st + 6666096);
          v88 = (float)((float)((float)(1.0 - v87) * *(float *)(st + 6665296))
                      + (float)(v87 * (float)(*(float *)(st + 6666032) * *(float *)(st + 6665296))))
              + v86;
          *(float *)(st + 6665840) = (float)((float)((float)(1.0 - v87) * *(float *)(st + 6665280))
                                           + (float)(v87 * (float)(*(float *)(st + 6666032) * *(float *)(st + 6665280))))
                                   + v85;
          *(float *)(st + 6665856) = v88;
          v89 = (*(_DWORD *)(st + 8763472) - 1) & (*(_DWORD *)(st + 8763476) - 1);
          *(_DWORD *)(st + 8763472) = v89;
          *(_DWORD *)(st + 4LL * v89 + 6666320) = *(_DWORD *)(st + 10860656);
          v90 = (*(_DWORD *)(st + 10860644) - 1) & (*(_DWORD *)(st + 10860640) - 1);
          *(_DWORD *)(st + 10860640) = v90;
          *(_DWORD *)(st + 4LL * v90 + 8763488) = *(_DWORD *)(st + 10860688);
          v91 = *(_DWORD *)(st + 10860736);
          *(_DWORD *)(st + 10860752) = *(_DWORD *)(st + 10860720);
          *(_DWORD *)(st + 10860768) = v91;
          v92 = jx_h_3A2010(0.0)/*ARGLESS*/;
          *(float *)(st + 10860784) = fmaxf(fminf(v92, 512.0), -512.0);
          v93 = *(float *)(st + 10860768);
          *(_DWORD *)(st + 10861024) = *(_DWORD *)(st + 10861008);
          v94 = jx_h_3A21E0(0.0f)/*ARGLESS*/;
          v95 = *(float *)&v94;
          *(float *)&v94 = jx_h_3A2210(0.0f)/*ARGLESS*/;
          *(_DWORD *)(st + 10861040) = LODWORD(v94);
          *(float *)(st + 10861008) = (float)(v95 * v93) + (float)(v93 - 1.0);
          v96 = (float)(*(float *)&v94 * *(float *)(st + 10861104)) + *(float *)(st + 10861120);
          *(float *)(st + 10861088) = v96;
          v97 = *(_DWORD *)(st + 6665856);
          v98 = *(float *)(st + 6665840);
          *(_DWORD *)(st + 10861264) = *(_DWORD *)(st + 10861248);
          *(_DWORD *)(st + 10861248) = *(_DWORD *)(st + 10861232);
          *(_DWORD *)(st + 10861232) = *(_DWORD *)(st + 10861216);
          *(_DWORD *)(st + 10861216) = *(_DWORD *)(st + 10861200);
          *(_DWORD *)(st + 10861200) = *(_DWORD *)(st + 10861184);
          *(_DWORD *)(st + 10861360) = *(_DWORD *)(st + 10861344);
          *(_DWORD *)(st + 10861344) = *(_DWORD *)(st + 10861328);
          *(_DWORD *)(st + 10861328) = *(_DWORD *)(st + 10861312);
          *(_DWORD *)(st + 10861312) = *(_DWORD *)(st + 10861296);
          *(_DWORD *)(st + 10861296) = *(_DWORD *)(st + 10861280);
          *(_DWORD *)(st + 10861440) = *(_DWORD *)(st + 10861424);
          *(_DWORD *)(st + 10861424) = *(_DWORD *)(st + 10861408);
          *(_DWORD *)(st + 10861408) = *(_DWORD *)(st + 10861392);
          *(_DWORD *)(st + 10861392) = *(_DWORD *)(st + 10861376);
          *(_DWORD *)(st + 10861520) = *(_DWORD *)(st + 10861504);
          *(_DWORD *)(st + 10861504) = *(_DWORD *)(st + 10861488);
          *(_DWORD *)(st + 10861488) = *(_DWORD *)(st + 10861472);
          *(_DWORD *)(st + 10861472) = *(_DWORD *)(st + 10861456);
          *(_DWORD *)(st + 10861552) = *(_DWORD *)(st + 10861536);
          *(_DWORD *)(st + 10861600) = *(_DWORD *)(st + 10861584);
          *(_DWORD *)(st + 10861584) = *(_DWORD *)(st + 10861568);
          *(float *)(st + 10861168) = v96;
          LODWORD(v94) = *(_DWORD *)(st + 10861744);
          v99 = (float)(v96 * *(float *)(st + 10862048)) + *(float *)(st + 10862064);
          *(float *)(st + 10861136) = v98;
          *(_DWORD *)(st + 10861152) = v97;
          v100 = *(float *)(st + 10861728);
          v101 = v96
               + (float)((float)((float)((float)((float)(v96 * 0.5) + *(float *)&v94)
                                       * (float)((float)(v96 * 0.5) + *(float *)&v94))
                               * v100)
                       - (float)(v100 * v96));
          v102 = (float)((float)((float)((float)(v99 * 0.5) + *(float *)&v94)
                               * (float)((float)(v99 * 0.5) + *(float *)&v94))
                       * v100)
               - (float)(v100 * v99);
          v103 = *(float *)(st + 10862080);
          v104 = *(float *)(st + 10862096);
          v105 = *(float *)(st + 10861760) * (float)(v99 + v102);
          *(float *)(st + 10861616) = (float)((float)(*(float *)(st + 10861760) * v101) * v103) + v104;
          *(float *)(st + 10861632) = (float)(v105 * v103) + v104;
          *(float *)(st + 10861376) = v98;
          v106 = (float)((float)((float)((float)(v98 * *(float *)(st + 10861776))
                                       + (float)(*(float *)(st + 10861792) * *(float *)(st + 10861392)))
                               + (float)(*(float *)(st + 10861808) * *(float *)(st + 10861408)))
                       + (float)(*(float *)(st + 10861424) * *(float *)(st + 10861824)))
               + (float)(*(float *)(st + 10861840) * *(float *)(st + 10861440));
          *(float *)(st + 10861408) = v106;
          *(float *)(st + 10861184) = (float)((float)((float)(v98
                                                            - (float)(*(float *)(st + 10861200)
                                                                    * *(float *)(st + 10861888)))
                                                    - *(float *)(st + 10861216))
                                            * *(float *)(st + 10861872))
                                    + *(float *)(st + 10861200);
          v107 = (float)(*(float *)(st + 10861200) * *(float *)(st + 10861872)) + *(float *)(st + 10861216);
          *(float *)(st + 10861200) = v107;
          LODWORD(v94) = *(_DWORD *)(st + 10861856);
          v108 = (float)(1.0 - *(float *)&v94) * v107;
          v109 = *(float *)(st + 10861232);
          v110 = (float)((float)(v108 + (float)(*(float *)&v94 * v106)) * *(float *)(st + 10861904))
               + (float)((float)(1.0 - *(float *)(st + 10861904)) * v98);
          LODWORD(v94) = *(_DWORD *)(st + 10862016);
          v111 = (float)((float)(v110 - v109) * *(float *)(st + 10861920)) + v109;
          v112 = v110
               + (float)((float)(*(float *)(st + 10861936) * (float)(v110 - v109))
                       - (float)(*(float *)(st + 10861936) * v110));
          v113 = *(float *)(st + 10862000);
          *(float *)(st + 10861216) = v111;
          *(float *)(st + 10927760) = (float)((float)(v113 * *(float *)(st + 10861248)) + (float)(*(float *)&v94 * v112))
                                    * *(float *)(st + 10862032);
          v114 = *(float *)(st + 10861152);
          *(float *)(st + 10861456) = v114;
          v115 = (float)((float)((float)((float)(v114 * *(float *)(st + 10861776))
                                       + (float)(*(float *)(st + 10861792) * *(float *)(st + 10861472)))
                               + (float)(*(float *)(st + 10861808) * *(float *)(st + 10861488)))
                       + (float)(*(float *)(st + 10861824) * *(float *)(st + 10861504)))
               + (float)(*(float *)(st + 10861520) * *(float *)(st + 10861840));
          *(float *)(st + 10861488) = v115;
          *(float *)(st + 10861280) = (float)((float)((float)(v114
                                                            - (float)(*(float *)(st + 10861296)
                                                                    * *(float *)(st + 10861888)))
                                                    - *(float *)(st + 10861312))
                                            * *(float *)(st + 10861872))
                                    + *(float *)(st + 10861296);
          v116 = (float)(*(float *)(st + 10861872) * *(float *)(st + 10861296)) + *(float *)(st + 10861312);
          *(float *)(st + 10861296) = v116;
          LODWORD(v94) = *(_DWORD *)(st + 10861856);
          v117 = *(float *)(st + 10861904);
          v118 = (float)(1.0 - *(float *)&v94) * v116;
          v119 = *(float *)(st + 10861328);
          v120 = v118 + (float)(*(float *)&v94 * v115);
          *(float *)&v94 = (float)(1.0 - v117) * v114;
          v121 = *(float *)(st + 10862000);
          v122 = (float)(v120 * v117) + *(float *)&v94;
          LODWORD(v94) = *(_DWORD *)(st + 10862016);
          v123 = (float)((float)(v122 - v119) * *(float *)(st + 10861920)) + v119;
          v124 = v122
               + (float)((float)(*(float *)(st + 10861936) * (float)(v122 - v119))
                       - (float)(*(float *)(st + 10861936) * v122));
          *(float *)(st + 10861312) = v123;
          v125 = *(float *)(st + 10862032);
          v126 = *(float *)(st + 10862128) + *(float *)(st + 10861584);
          *(float *)(st + 10927792) = v125
                                    * (float)((float)(v121 * *(float *)(st + 10861344)) + (float)(*(float *)&v94 * v124));
          v127 = fminf(*(float *)(st + 10862144), v126) * v125;
          *(float *)(st + 10861568) = v127;
          v128 = *(float *)(st + 10861600);
          if ( (float)(v127 - *(float *)(st + 10861552)) >= 0.0 )
            v129 = v128 + *(float *)(st + 10862160);
          else
            v129 = v128 + *(float *)(st + 10862176);
          v130 = *(float *)(st + 10861712);
          v131 = *(float *)(st + 10861552);
          if ( v129 <= 0.0 )
            v132 = 0.0;
          else
            v132 = v129;
          v133 = v132;
          v134 = (float)((float)(*(float *)(st + 10861712) - v131) * *(float *)(st + 10861984)) + v131;
          if ( v133 >= -1.0 )
            v135 = fminf(v133, 1.0);
          else
            v135 = -1.0;
          *(float *)(st + 10861584) = v135 * *(float *)(st + 10862032);
          if ( (float)(v134 - v131) != 0.0 )
            v130 = v134;
          *(float *)(st + 10861536) = v130;
          v136 = v130;
          v137 = v130 + *(float *)(st + 10861616);
          v138 = (int)(float)(v137 * -16384.0);
          *(_DWORD *)(st + 10927776) = *(_DWORD *)(st
                                                 + 4
                                                 * ((*(int *)(st + 10894964) - 1LL)
                                                  & (*(_DWORD *)(st + 10894960) - v138 + 1LL))
                                                 + 10862192);
          *(_DWORD *)(st + 10927780) = *(_DWORD *)(st
                                                 + 4
                                                 * ((*(int *)(st + 10894964) - 1LL)
                                                  & (*(_DWORD *)(st + 10894960) - v138 + 2LL))
                                                 + 10862192);
          v139 = (float)(v137 * 16384.0) - (double)(int)(float)(v137 * 16384.0);
          *(float *)(st + 10927784) = v139;
          v140 = *(float *)(st + 10927776);
          v141 = *(float *)(st + 10861600);
          v142 = v136 + *(float *)(st + 10861632);
          v143 = (int)(float)(v142 * -16384.0);
          *(_DWORD *)(st + 10927808) = *(_DWORD *)(st
                                                 + 4
                                                 * ((*(int *)(st + 10927748) - 1LL)
                                                  & (*(_DWORD *)(st + 10927744) - v143 + 1LL))
                                                 + 10894976);
          *(_DWORD *)(st + 10927812) = *(_DWORD *)(st
                                                 + 4
                                                 * ((*(int *)(st + 10927748) - 1LL)
                                                  & (*(_DWORD *)(st + 10927744) - v143 + 2LL))
                                                 + 10894976);
          v144 = (float)(v142 * 16384.0) - (double)(int)(float)(v142 * 16384.0);
          *(float *)(st + 10927816) = v144;
          v145 = *(float *)(st + 10861264);
          v146 = (float)((float)(v139 * *(float *)(st + 10927780)) - (float)(v139 * v140)) + v140;
          v147 = *(float *)(st + 10927808);
          v148 = v146 * v141;
          *(float *)(st + 10861232) = v148 - v145;
          *(float *)(st + 10861248) = (float)((float)(v148 - v145) * *(float *)(st + 10862112)) + v145;
          v149 = *(float *)(st + 10861360);
          v150 = (float)((float)((float)(v144 * *(float *)(st + 10927812)) - (float)(v144 * v147)) + v147) * v141;
          v151 = v150 - v149;
          *(float *)(st + 10861328) = v150 - v149;
          v152 = *(float *)(st + 10861968);
          v153 = v150 * v152;
          *(float *)(st + 10861344) = (float)(v151 * *(float *)(st + 10862112)) + v149;
          v154 = *(float *)(st + 10861152);
          v155 = *(float *)(st + 10861136);
          v156 = *(float *)(st + 10861952);
          *(float *)(st + 10861648) = v148 * v152;
          *(float *)(st + 10861664) = v153;
          v157 = *(float *)(st + 10862016);
          *(float *)(st + 10861680) = (float)((float)((float)(1.0 - v157) * v155) + (float)(v157 * (float)(v156 * v155)))
                                    + *(float *)(st + 10861648);
          *(float *)(st + 10861696) = (float)((float)((float)(1.0 - v157) * v154) + (float)(v157 * (float)(v156 * v154)))
                                    + v153;
          v158 = (*(_DWORD *)(st + 10894964) - 1) & (*(_DWORD *)(st + 10894960) - 1);
          *(_DWORD *)(st + 10894960) = v158;
          *(_DWORD *)(st + 4LL * v158 + 10862192) = *(_DWORD *)(st + 10927760);
          v159 = (*(_DWORD *)(st + 10927744) - 1) & (*(_DWORD *)(st + 10927748) - 1);
          *(_DWORD *)(st + 10927744) = v159;
          *(_DWORD *)(st + 4LL * v159 + 10894976) = *(_DWORD *)(st + 10927792);
          v160 = *(float *)(st + 270448);
          v161 = v160 * *(float *)(st + 10861696);
          v162 = v160 * *(float *)(st + 10861680);
          goto LABEL_96;
        }
        goto LABEL_61;
      }
      if ( *(_DWORD *)(st + 11191052) != 4 )
      {
        *(_DWORD *)(st + 6599024) = 0;
        *(_DWORD *)(st + 6599040) = 0;
        *(_DWORD *)(st + 6599056) = 0;
      }
      *(_DWORD *)(st + 11191052) = 4;
      v163 = *(_DWORD *)(st + 6598192);
      *(_DWORD *)(st + 6598208) = *(_DWORD *)(st + 6598176);
      *(_DWORD *)(st + 6598224) = v163;
      v164 = jx_h_3A2010(0.0)/*ARGLESS*/;
      *(float *)(st + 6598240) = fmaxf(fminf(v164, 512.0), -512.0);
      v165 = *(float *)(st + 6598224);
      *(_DWORD *)(st + 6598480) = *(_DWORD *)(st + 6598464);
      v33 = 0;
      v166 = jx_h_3A21E0(0.0f)/*ARGLESS*/;
      v167 = *(float *)&v166;
      *(float *)&v166 = jx_h_3A2210(0.0f)/*ARGLESS*/;
      *(_DWORD *)(st + 6598496) = LODWORD(v166);
      *(float *)(st + 6598464) = (float)(v167 * v165) + (float)(v165 - 1.0);
      v168 = (float)(*(float *)&v166 * *(float *)(st + 6598560)) + *(float *)(st + 6598576);
      *(float *)(st + 6598544) = v168;
      *(_DWORD *)(st + 6598720) = *(_DWORD *)(st + 6598704);
      *(_DWORD *)(st + 6598704) = *(_DWORD *)(st + 6598688);
      *(_DWORD *)(st + 6598688) = *(_DWORD *)(st + 6598672);
      *(_DWORD *)(st + 6598672) = *(_DWORD *)(st + 6598656);
      *(_DWORD *)(st + 6598656) = *(_DWORD *)(st + 6598640);
      *(_DWORD *)(st + 6598816) = *(_DWORD *)(st + 6598800);
      *(_DWORD *)(st + 6598800) = *(_DWORD *)(st + 6598784);
      *(_DWORD *)(st + 6598784) = *(_DWORD *)(st + 6598768);
      *(_DWORD *)(st + 6598768) = *(_DWORD *)(st + 6598752);
      *(_DWORD *)(st + 6598752) = *(_DWORD *)(st + 6598736);
      *(_DWORD *)(st + 6598896) = *(_DWORD *)(st + 6598880);
      *(_DWORD *)(st + 6598880) = *(_DWORD *)(st + 6598864);
      *(_DWORD *)(st + 6598864) = *(_DWORD *)(st + 6598848);
      *(_DWORD *)(st + 6598848) = *(_DWORD *)(st + 6598832);
      *(_DWORD *)(st + 6598976) = *(_DWORD *)(st + 6598960);
      *(_DWORD *)(st + 6598960) = *(_DWORD *)(st + 6598944);
      *(_DWORD *)(st + 6598944) = *(_DWORD *)(st + 6598928);
      *(_DWORD *)(st + 6598928) = *(_DWORD *)(st + 6598912);
      *(_DWORD *)(st + 6599008) = *(_DWORD *)(st + 6598992);
      *(_DWORD *)(st + 6599056) = *(_DWORD *)(st + 6599040);
      *(_DWORD *)(st + 6599040) = *(_DWORD *)(st + 6599024);
      *(float *)(st + 6598624) = v168;
      LODWORD(v166) = *(_DWORD *)(st + 6599200);
      v169 = (float)(v168 * *(float *)(st + 6599504)) + *(float *)(st + 6599520);
      *(float *)(st + 6598592) = v30;
      *(float *)(st + 6598608) = v29;
      v170 = *(float *)(st + 6599184);
      v171 = v168
           + (float)((float)((float)((float)((float)(v168 * 0.5) + *(float *)&v166)
                                   * (float)((float)(v168 * 0.5) + *(float *)&v166))
                           * v170)
                   - (float)(v170 * v168));
      v172 = v169
           + (float)((float)((float)((float)((float)(v169 * 0.5) + *(float *)&v166)
                                   * (float)((float)(v169 * 0.5) + *(float *)&v166))
                           * v170)
                   - (float)(v170 * v169));
      v173 = *(float *)(st + 6599536);
      v174 = *(float *)(st + 6599552);
      v175 = (float)((float)(*(float *)(st + 6599216) * v172) * v173) + v174;
      *(float *)(st + 6599072) = (float)((float)(*(float *)(st + 6599216) * v171) * v173) + v174;
      *(float *)(st + 6599088) = v175;
      *(float *)(st + 6598832) = v30;
      v176 = (float)((float)((float)((float)(*(float *)(st + 6599248) * *(float *)(st + 6598848))
                                   + (float)(v30 * *(float *)(st + 6599232)))
                           + (float)(*(float *)(st + 6599264) * *(float *)(st + 6598864)))
                   + (float)(*(float *)(st + 6599280) * *(float *)(st + 6598880)))
           + (float)(*(float *)(st + 6599296) * *(float *)(st + 6598896));
      *(float *)(st + 6598864) = v176;
      *(float *)(st + 6598640) = (float)((float)((float)(v30
                                                       - (float)(*(float *)(st + 6598656) * *(float *)(st + 6599344)))
                                               - *(float *)(st + 6598672))
                                       * *(float *)(st + 6599328))
                               + *(float *)(st + 6598656);
      v177 = (float)(*(float *)(st + 6598656) * *(float *)(st + 6599328)) + *(float *)(st + 6598672);
      *(float *)(st + 6598656) = v177;
      LODWORD(v166) = *(_DWORD *)(st + 6599312);
      v178 = (float)(1.0 - *(float *)&v166) * v177;
      v179 = *(float *)(st + 6598688);
      v180 = (float)((float)(v178 + (float)(*(float *)&v166 * v176)) * *(float *)(st + 6599360))
           + (float)((float)(1.0 - *(float *)(st + 6599360)) * v30);
      LODWORD(v166) = *(_DWORD *)(st + 6599472);
      v181 = (float)((float)(v180 - v179) * *(float *)(st + 6599376)) + v179;
      v182 = v180
           + (float)((float)(*(float *)(st + 6599392) * (float)(v180 - v179)) - (float)(*(float *)(st + 6599392) * v180));
      v183 = *(float *)(st + 6599456);
      *(float *)(st + 6598672) = v181;
      *(float *)(st + 6665216) = (float)((float)(v183 * *(float *)(st + 6598704)) + (float)(*(float *)&v166 * v182))
                               * *(float *)(st + 6599488);
      v184 = *(float *)(st + 6598608);
      *(float *)(st + 6598912) = v184;
      v185 = (float)((float)((float)((float)(v184 * *(float *)(st + 6599232))
                                   + (float)(*(float *)(st + 6598928) * *(float *)(st + 6599248)))
                           + (float)(*(float *)(st + 6599264) * *(float *)(st + 6598944)))
                   + (float)(*(float *)(st + 6599280) * *(float *)(st + 6598960)))
           + (float)(*(float *)(st + 6598976) * *(float *)(st + 6599296));
      *(float *)(st + 6598944) = v185;
      *(float *)(st + 6598736) = (float)((float)((float)(v184
                                                       - (float)(*(float *)(st + 6598752) * *(float *)(st + 6599344)))
                                               - *(float *)(st + 6598768))
                                       * *(float *)(st + 6599328))
                               + *(float *)(st + 6598752);
      v186 = (float)(*(float *)(st + 6598752) * *(float *)(st + 6599328)) + *(float *)(st + 6598768);
      *(float *)(st + 6598752) = v186;
      LODWORD(v166) = *(_DWORD *)(st + 6599312);
      v187 = *(float *)(st + 6599360);
      v188 = (float)(1.0 - *(float *)&v166) * v186;
      v189 = *(float *)(st + 6598784);
      v190 = v188 + (float)(*(float *)&v166 * v185);
      *(float *)&v166 = (float)(1.0 - v187) * v184;
      v191 = *(float *)(st + 6599456);
      v192 = (float)(v190 * v187) + *(float *)&v166;
      LODWORD(v166) = *(_DWORD *)(st + 6599472);
      v193 = (float)((float)(v192 - v189) * *(float *)(st + 6599376)) + v189;
      v194 = v192
           + (float)((float)(*(float *)(st + 6599392) * (float)(v192 - v189)) - (float)(*(float *)(st + 6599392) * v192));
      *(float *)(st + 6598768) = v193;
      v195 = *(float *)(st + 6599488);
      v196 = *(float *)(st + 6599584) + *(float *)(st + 6599040);
      *(float *)(st + 6665248) = v195
                               * (float)((float)(v191 * *(float *)(st + 6598800)) + (float)(*(float *)&v166 * v194));
      v197 = fminf(*(float *)(st + 6599600), v196) * v195;
      *(float *)(st + 6599024) = v197;
      v198 = *(float *)(st + 6599056);
      if ( (float)(v197 - *(float *)(st + 6599008)) >= 0.0 )
        v199 = v198 + *(float *)(st + 6599616);
      else
        v199 = v198 + *(float *)(st + 6599632);
      v200 = *(float *)(st + 6599168);
      v49 = 0.0;
      v201 = *(float *)(st + 6599008);
      if ( v199 <= 0.0 )
        v202 = 0.0;
      else
        v202 = v199;
      v51 = -1.0;
      v203 = v202;
      v204 = (float)((float)(*(float *)(st + 6599168) - v201) * *(float *)(st + 6599440)) + v201;
      if ( v203 >= -1.0 )
        v205 = fminf(v203, 1.0);
      else
        v205 = -1.0;
      *(float *)(st + 6599040) = v205 * *(float *)(st + 6599488);
      if ( (float)(v204 - v201) != 0.0 )
        v200 = v204;
      v206 = v200;
      *(float *)(st + 6598992) = v200;
      v207 = v200 + *(float *)(st + 6599072);
      v208 = (int)(float)(v207 * -16384.0);
      *(_DWORD *)(st + 6665232) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 6632420) - 1LL) & (*(_DWORD *)(st + 6632416) - v208 + 1LL))
                                            + 6599648);
      *(_DWORD *)(st + 6665236) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 6632420) - 1LL) & (*(_DWORD *)(st + 6632416) - v208 + 2LL))
                                            + 6599648);
      v209 = (float)(v207 * 16384.0) - (double)(int)(float)(v207 * 16384.0);
      *(float *)(st + 6665240) = v209;
      v210 = *(float *)(st + 6665232);
      v211 = *(float *)(st + 6599056);
      v212 = v206 + *(float *)(st + 6599088);
      v213 = (int)(float)(v212 * -16384.0);
      *(_DWORD *)(st + 6665264) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 6665204) - 1LL) & (*(_DWORD *)(st + 6665200) - v213 + 1LL))
                                            + 6632432);
      *(_DWORD *)(st + 6665268) = *(_DWORD *)(st
                                            + 4
                                            * ((*(int *)(st + 6665204) - 1LL) & (*(_DWORD *)(st + 6665200) - v213 + 2LL))
                                            + 6632432);
      v214 = (float)(v212 * 16384.0) - (double)(int)(float)(v212 * 16384.0);
      *(float *)(st + 6665272) = v214;
      v215 = *(float *)(st + 6598720);
      v216 = (float)((float)(v209 * *(float *)(st + 6665236)) - (float)(v209 * v210)) + v210;
      v217 = *(float *)(st + 6665264);
      v218 = v216 * v211;
      *(float *)(st + 6598688) = v218 - v215;
      *(float *)(st + 6598704) = (float)((float)(v218 - v215) * *(float *)(st + 6599568)) + v215;
      v219 = *(float *)(st + 6598816);
      v220 = (float)((float)((float)(v214 * *(float *)(st + 6665268)) - (float)(v214 * v217)) + v217) * v211;
      v221 = v220 - v219;
      *(float *)(st + 6598784) = v220 - v219;
      v222 = *(float *)(st + 6599424);
      v223 = v220 * v222;
      *(float *)(st + 6598800) = (float)(v221 * *(float *)(st + 6599568)) + v219;
      v224 = *(float *)(st + 6598608);
      v225 = *(float *)(st + 6598592);
      v226 = *(float *)(st + 6599408);
      *(float *)(st + 6599104) = v218 * v222;
      *(float *)(st + 6599120) = v223;
      v227 = *(float *)(st + 6599472);
      *(float *)(st + 6599136) = (float)((float)((float)(1.0 - v227) * v225) + (float)(v227 * (float)(v226 * v225)))
                               + *(float *)(st + 6599104);
      *(float *)(st + 6599152) = (float)((float)((float)(1.0 - v227) * v224) + (float)(v227 * (float)(v226 * v224)))
                               + v223;
      v228 = (*(_DWORD *)(st + 6632420) - 1) & (*(_DWORD *)(st + 6632416) - 1);
      *(_DWORD *)(st + 6632416) = v228;
      *(_DWORD *)(st + 4LL * v228 + 6599648) = *(_DWORD *)(st + 6665216);
      v229 = (*(_DWORD *)(st + 6665204) - 1) & (*(_DWORD *)(st + 6665200) - 1);
      *(_DWORD *)(st + 6665200) = v229;
      *(_DWORD *)(st + 4LL * v229 + 6632432) = *(_DWORD *)(st + 6665248);
      v230 = *(float *)(st + 270448);
      v161 = v230 * *(float *)(st + 6599152);
      v162 = v230 * *(float *)(st + 6599136);
    }
  }
LABEL_96:
  *(_DWORD *)(st + 10928560) = (uint16_t)(*(_DWORD *)(st + 10928560) - 1);
  v410 = *(float *)(st + 11190736);
  if ( *(int *)(st + 10928576) <= 0 )
  {
    v411 = *(float *)(st + 11190736);
    if ( v410 < 1.0 && *(float *)(st + 10928080) > 0.0 )
    {
      v411 = v410 + 0.00039999999;
      *(float *)(st + 11190736) = v410 + 0.00039999999;
      if ( (float)(v410 + 0.00039999999) > 1.0 )
      {
        *(_DWORD *)(st + 11190736) = 1065353216;
        v411 = 1.0;
      }
    }
  }
  else
  {
    if ( v410 != 0.0 )
    {
      v410 = v410 - 0.00039999999;
      *(float *)(st + 11190736) = v410;
      if ( v410 < 0.0 )
      {
        *(_DWORD *)(st + 11190736) = 0;
        v410 = 0.0;
      }
    }
    v411 = v410;
  }
  if ( v411 <= 0.0 || (v412 = *(float *)(st + 10928080), v412 <= 0.0) )
  {
    v466 = v162;
    v467 = v161;
    if ( *(int *)(st + 10928576) > 0 && v411 <= 0.0 )
    {
      for ( i = 0; i < 256; i += 8 )
      {
        *(_DWORD *)(st + 4LL * (i + (*(_DWORD *)(st + 10928576) << 8)) + 10927568) = 0;
        *(_DWORD *)(st + 4LL * (i + (*(_DWORD *)(st + 10928576) << 8)) + 10927572) = 0;
        *(_DWORD *)(st + 4LL * (i + (*(_DWORD *)(st + 10928576) << 8)) + 10927576) = 0;
        *(_DWORD *)(st + 4LL * (i + (*(_DWORD *)(st + 10928576) << 8)) + 10927580) = 0;
        *(_DWORD *)(st + 4LL * (i + (*(_DWORD *)(st + 10928576) << 8)) + 10927584) = 0;
        *(_DWORD *)(st + 4LL * (i + (*(_DWORD *)(st + 10928576) << 8)) + 10927588) = 0;
        *(_DWORD *)(st + 4LL * (i + (*(_DWORD *)(st + 10928576) << 8)) + 10927592) = 0;
        v469 = i + (*(_DWORD *)(st + 10928576) << 8);
        *(_DWORD *)(st + 4LL * v469 + 10927596) = 0;
      }
      v470 = *(_DWORD *)(st + 10928576) - 1;
      *(_DWORD *)(st + 10928576) = v470;
      if ( v470 <= 0 )
      {
        *(_DWORD *)(st + 11190768) = *(_DWORD *)(st + 11190912);
        *(_DWORD *)(st + 11190772) = *(_DWORD *)(st + 11190916);
        *(_DWORD *)(st + 11190776) = *(_DWORD *)(st + 11190920);
        *(_DWORD *)(st + 11190780) = *(_DWORD *)(st + 11190924);
        *(_DWORD *)(st + 11190784) = *(_DWORD *)(st + 11190928);
        *(_DWORD *)(st + 11190788) = *(_DWORD *)(st + 11190932);
        *(_DWORD *)(st + 11190792) = *(_DWORD *)(st + 11190936);
        *(_DWORD *)(st + 11190796) = *(_DWORD *)(st + 11190940);
        *(_DWORD *)(st + 11190800) = *(_DWORD *)(st + 11190944);
        *(_DWORD *)(st + 11190804) = *(_DWORD *)(st + 11190948);
        *(_DWORD *)(st + 11190808) = *(_DWORD *)(st + 11190952);
        *(_DWORD *)(st + 11190812) = *(_DWORD *)(st + 11190956);
        *(_DWORD *)(st + 11190816) = *(_DWORD *)(st + 11190960);
        *(_DWORD *)(st + 11190820) = *(_DWORD *)(st + 11190964);
        *(_DWORD *)(st + 11190824) = *(_DWORD *)(st + 11190968);
        *(_DWORD *)(st + 11190828) = *(_DWORD *)(st + 11190972);
        *(_DWORD *)(st + 11190832) = *(_DWORD *)(st + 11190976);
        *(_DWORD *)(st + 11190836) = *(_DWORD *)(st + 11190980);
        *(_DWORD *)(st + 11190840) = *(_DWORD *)(st + 11190984);
        *(_DWORD *)(st + 11190844) = *(_DWORD *)(st + 11190988);
        *(_DWORD *)(st + 11190848) = *(_DWORD *)(st + 11190992);
        *(_DWORD *)(st + 11190852) = *(_DWORD *)(st + 11190996);
        *(_DWORD *)(st + 11190856) = *(_DWORD *)(st + 11191000);
        *(_DWORD *)(st + 11190860) = *(_DWORD *)(st + 11191004);
        *(_DWORD *)(st + 11190864) = *(_DWORD *)(st + 11191008);
        *(_DWORD *)(st + 11190868) = *(_DWORD *)(st + 11191012);
        *(_DWORD *)(st + 11190872) = *(_DWORD *)(st + 11191016);
        *(_DWORD *)(st + 11190876) = *(_DWORD *)(st + 11191020);
        *(_DWORD *)(st + 11190880) = *(_DWORD *)(st + 11191024);
        *(_DWORD *)(st + 11190884) = *(_DWORD *)(st + 11191028);
        *(_DWORD *)(st + 11190888) = *(_DWORD *)(st + 11191032);
        *(_DWORD *)(st + 11190892) = *(_DWORD *)(st + 11191036);
        *(_DWORD *)(st + 11190896) = *(_DWORD *)(st + 11191040);
        *(_DWORD *)(st + 11190900) = *(_DWORD *)(st + 11191044);
        *(_DWORD *)(st + 10927888) = 0;
        *(_DWORD *)(st + 10927872) = 0;
        *(_DWORD *)(st + 10927856) = 0;
        *(_DWORD *)(st + 10927840) = 0;
        *(_DWORD *)(st + 10927824) = 0;
        *(_DWORD *)(st + 10928016) = 0;
        *(_DWORD *)(st + 10928000) = 0;
        *(_DWORD *)(st + 10927984) = 0;
        *(_DWORD *)(st + 10927968) = 0;
        *(_DWORD *)(st + 10927952) = 0;
        *(_DWORD *)(st + 10927936) = 0;
        *(_DWORD *)(st + 10927920) = 0;
        *(_DWORD *)(st + 10927904) = 0;
        *(_DWORD *)(st + 10928048) = 0;
        *(_DWORD *)(st + 10928032) = 0;
      }
    }
  }
  else
  {
    v413 = (float)((float)((float)(v161 + v162) * 0.03125) * *(float *)(st + 10928112)) * v412;
    v414 = *(float *)(st + 10928240) * *(float *)(st + 10927824);
    v415 = v413 * v411;
    v416 = *(float *)(st + 10928256) * *(float *)(st + 10927840);
    v417 = v415 * *(float *)(st + 10928224);
    *(float *)(st + 10927824) = v415;
    v418 = (float)(v417 + v414) + v416;
    v419 = *(float *)(st + 10928320) * *(float *)(st + 10927872);
    v420 = (float)((float)(v418 * *(float *)(st + 10928272))
                 + (float)(*(float *)(st + 10927840) * *(float *)(st + 10928288)))
         + (float)(*(float *)(st + 10928304) * *(float *)(st + 10927856));
    v421 = *(float *)(st + 10928336) * *(float *)(st + 10927888);
    *(_DWORD *)(st + 10927856) = *(_DWORD *)(st + 10927840);
    *(float *)(st + 10927840) = v418;
    *(_DWORD *)(st + 10927888) = *(_DWORD *)(st + 10927872);
    v422 = (float)(v420 + v419) + v421;
    *(float *)(st + 10927872) = v422;
    v423 = *(float *)(st + 10928208) + *(float *)(st + 10928048);
    *(float *)(st + 10928032) = v423;
    if ( v423 > 1.0 )
    {
      v423 = v423 - 2.0;
      *(float *)(st + 10928032) = v423;
    }
    v424 = v423 * *(float *)(st + 10928192);
    if ( v423 < 0.0 )
      v425 = 2048.0;
    else
      v425 = -2048.0;
    *(float *)(st + 10928048) = v423;
    *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190768)) + 10928592) = v422;
    v426 = *(_DWORD *)(st + 10928560);
    v427 = *(float *)(st + 4LL * (uint16_t)(v426 + *(_DWORD *)(st + 11190780)) + 10928592);
    v428 = *(float *)(st
                    + 4LL * (uint16_t)(v426 + *(_DWORD *)(st + 11190772) - (int)(float)(v424 * v425))
                    + 10928592)
         - (float)(v427 * *(float *)(st + 10928096));
    *(float *)(st + 4LL * (uint16_t)(v426 + *(_DWORD *)(st + 11190776)) + 10928592) = v428;
    v429 = *(_DWORD *)(st + 10928560);
    v430 = *(float *)(st + 4LL * (uint16_t)(v429 + *(_DWORD *)(st + 11190788)) + 10928592);
    v431 = (float)((float)(*(float *)(st + 10928096) * v428) + v427) - (float)(*(float *)(st + 10928096) * v430);
    *(float *)(st + 4LL * (uint16_t)(v429 + *(_DWORD *)(st + 11190784)) + 10928592) = v431;
    v432 = *(_DWORD *)(st + 10928560);
    v433 = (float)(*(float *)(st + 10928096) * v431) + v430;
    v434 = *(float *)(st + 4LL * (uint16_t)(v432 + *(_DWORD *)(st + 11190796)) + 10928592);
    v435 = v433 - (float)(*(float *)(st + 10928096) * v434);
    *(float *)(st + 4LL * (uint16_t)(v432 + *(_DWORD *)(st + 11190792)) + 10928592) = v435;
    v436 = *(_DWORD *)(st + 10928560);
    v437 = (float)(*(float *)(st + 10928096) * v435) + v434;
    v438 = *(float *)(st + 4LL * (uint16_t)(v436 + *(_DWORD *)(st + 11190804)) + 10928592);
    v439 = v437 - (float)(*(float *)(st + 10928096) * v438);
    *(float *)(st + 4LL * (uint16_t)(v436 + *(_DWORD *)(st + 11190800)) + 10928592) = v439;
    v440 = *(_DWORD *)(st + 10928560);
    v441 = (float)(*(float *)(st + 10928096) * v439) + v438;
    v442 = *(float *)(st + 4LL * (uint16_t)(v440 + *(_DWORD *)(st + 11190812)) + 10928592);
    v443 = v441 * 0.5;
    v444 = (float)(v443 - (float)(*(float *)(st + 10928096) * v442)) + *(float *)(st + 10927920);
    *(float *)(st + 4LL * (uint16_t)(v440 + *(_DWORD *)(st + 11190808)) + 10928592) = v444;
    *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190840)) + 10928592) = (float)(v444 * *(float *)(st + 10928096)) + v442;
    v445 = *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190852)) + 10928592)
         - *(float *)(st + 10927904);
    *(float *)(st + 10927920) = v445;
    v446 = (float)(v445 * *(float *)(st + 10928352)) + *(float *)(st + 10927904);
    *(float *)(st + 10927904) = v446;
    *(float *)(st + 10927920) = (float)(v446 * *(float *)(st + 10928384))
                              + (float)(*(float *)(st + 10928368) * *(float *)(st + 10927920));
    v447 = *(_DWORD *)(st + 10928560);
    v448 = *(float *)(st + 4LL * (uint16_t)(v447 + *(_DWORD *)(st + 11190820)) + 10928592);
    v449 = (float)(v443 - (float)(v448 * *(float *)(st + 10928096))) + *(float *)(st + 10927952);
    *(float *)(st + 4LL * (uint16_t)(v447 + *(_DWORD *)(st + 11190816)) + 10928592) = v449;
    *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190856)) + 10928592) = (float)(v449 * *(float *)(st + 10928096)) + v448;
    v450 = *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190868)) + 10928592)
         - *(float *)(st + 10927936);
    *(float *)(st + 10927952) = v450;
    v451 = (float)(v450 * *(float *)(st + 10928400)) + *(float *)(st + 10927936);
    *(float *)(st + 10927936) = v451;
    *(float *)(st + 10927952) = (float)(v451 * *(float *)(st + 10928432))
                              + (float)(*(float *)(st + 10928416) * *(float *)(st + 10927952));
    v452 = *(_DWORD *)(st + 10928560);
    v453 = *(float *)(st + 4LL * (uint16_t)(v452 + *(_DWORD *)(st + 11190828)) + 10928592);
    v454 = (float)(v443 - (float)(v453 * *(float *)(st + 10928096))) + *(float *)(st + 10927984);
    *(float *)(st + 4LL * (uint16_t)(v452 + *(_DWORD *)(st + 11190824)) + 10928592) = v454;
    *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190872)) + 10928592) = (float)(v454 * *(float *)(st + 10928096)) + v453;
    v455 = *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190884)) + 10928592)
         - *(float *)(st + 10927968);
    *(float *)(st + 10927984) = v455;
    v456 = (float)(v455 * *(float *)(st + 10928448)) + *(float *)(st + 10927968);
    *(float *)(st + 10927968) = v456;
    *(float *)(st + 10927984) = (float)(v456 * *(float *)(st + 10928480))
                              + (float)(*(float *)(st + 10928464) * *(float *)(st + 10927984));
    v457 = *(_DWORD *)(st + 10928560);
    v458 = *(float *)(st + 4LL * (uint16_t)(v457 + *(_DWORD *)(st + 11190836)) + 10928592);
    v459 = (float)(v443 - (float)(v458 * *(float *)(st + 10928096))) + *(float *)(st + 10928016);
    *(float *)(st + 4LL * (uint16_t)(v457 + *(_DWORD *)(st + 11190832)) + 10928592) = v459;
    *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190888)) + 10928592) = (float)(v459 * *(float *)(st + 10928096)) + v458;
    v460 = *(float *)(st + 4LL * (uint16_t)(*(_WORD *)(st + 10928560) + *(_WORD *)(st + 11190900)) + 10928592)
         - *(float *)(st + 10928000);
    *(float *)(st + 10928016) = v460;
    v461 = (float)(v460 * *(float *)(st + 10928496)) + *(float *)(st + 10928000);
    *(float *)(st + 10928000) = v461;
    *(float *)(st + 10928016) = (float)(v461 * *(float *)(st + 10928528))
                              + (float)(*(float *)(st + 10928512) * *(float *)(st + 10928016));
    v462 = *(_DWORD *)(st + 10928560);
    v463 = *(float *)(st + 10928144);
    v464 = *(float *)(st + 11190736);
    v465 = *(float *)(st + 10928080);
    v466 = (float)((float)((float)((float)((float)((float)((float)(*(float *)(st
                                                                            + 4LL
                                                                            * (uint16_t)(v462
                                                                                               + *(_DWORD *)(st + 11190864))
                                                                            + 10928592)
                                                                 + *(float *)(st
                                                                            + 4LL
                                                                            * (uint16_t)(v462
                                                                                               + *(_DWORD *)(st + 11190844))
                                                                            + 10928592))
                                                         + *(float *)(st
                                                                    + 4LL
                                                                    * (uint16_t)(v462
                                                                                       + *(_DWORD *)(st + 11190876))
                                                                    + 10928592))
                                                 + *(float *)(st
                                                            + 4LL
                                                            * (uint16_t)(v462 + *(_DWORD *)(st + 11190896))
                                                            + 10928592))
                                         * v463)
                                 * 16.0)
                         * v464)
                 * v465)
         + (float)(*(float *)(st + 10928128) * v162);
    v467 = (float)((float)((float)((float)((float)((float)((float)(*(float *)(st
                                                                            + 4LL
                                                                            * (uint16_t)(v462
                                                                                               + *(_DWORD *)(st + 11190848))
                                                                            + 10928592)
                                                                 + *(float *)(st
                                                                            + 4LL
                                                                            * (uint16_t)(v462
                                                                                               + *(_DWORD *)(st + 11190860))
                                                                            + 10928592))
                                                         + *(float *)(st
                                                                    + 4LL
                                                                    * (uint16_t)(v462
                                                                                       + *(_DWORD *)(st + 11190880))
                                                                    + 10928592))
                                                 + *(float *)(st
                                                            + 4LL
                                                            * (uint16_t)(v462 + *(_DWORD *)(st + 11190892))
                                                            + 10928592))
                                         * v463)
                                 * 16.0)
                         * v464)
                 * v465)
         + (float)(*(float *)(st + 10928128) * v161);
  }
  v471 = *(_DWORD *)(st + 269824);
  *(_DWORD *)(st + 269856) = *(_DWORD *)(st + 269808);
  *(_DWORD *)(st + 269872) = v471;
  *(_DWORD *)(st + 269888) = *(_DWORD *)(st + 269840);
  v472 = *(float *)(st + 269856);
  *(float *)(st + 269904) = v472 * v466;
  *(float *)(st + 269920) = v472 * v467;
  v473 = *(float *)(st + 269872);
  v474 = v473 * (float)(v472 * v467);
  v475 = v473 * *(float *)(st + 269904);
  *(float *)(st + 269936) = v475;
  *(float *)(st + 269952) = v474;
  v476 = *(float *)(st + 270000);
  v477 = *(float *)(st + 270032);
  v478 = *(float *)(st + 270080);
  v479 = v475 * v476;
  v480 = v474 * v476;
  v481 = v480 * v480;
  v482 = (float)((float)((float)((float)((float)(v479 * v479) * v479) * v479) * *(float *)(st + 270096))
               + (float)((float)((float)((float)(*(float *)(st + 270048) * v479) + v477)
                               + (float)(*(float *)(st + 270064) * (float)(v479 * v479)))
                       + (float)(v478 * (float)((float)(v479 * v479) * v479))))
       + (float)((float)((float)((float)((float)(v479 * v479) * v479) * v479) * v479) * *(float *)(st + 270112));
  if ( (float)(*(float *)(st + 270160) - v479) <= 0.0 )
    v482 = *(float *)(st + 270176);
  v483 = *(float *)(st + 270064) * v481;
  v484 = v481 * v480;
  v485 = (float)((float)(*(float *)(st + 270048) * v480) + v477) + v483;
  if ( (float)(*(float *)(st + 270128) - v479) >= 0.0 )
    v482 = *(float *)(st + 270144);
  v486 = v482 * *(float *)(st + 270016);
  *(float *)(st + 269968) = v486;
  v487 = (float)((float)((float)(v484 * v480) * *(float *)(st + 270096)) + (float)(v485 + (float)(v478 * v484)))
       + (float)((float)((float)(v484 * v480) * v480) * *(float *)(st + 270112));
  if ( (float)(*(float *)(st + 270160) - v480) <= 0.0 )
    v487 = *(float *)(st + 270176);
  if ( (float)(*(float *)(st + 270128) - v480) >= 0.0 )
    v487 = *(float *)(st + 270144);
  v488 = v487 * *(float *)(st + 270016);
  v489 = *(_QWORD *)(st + 136);
  *(float *)(st + 269984) = v488;
  *(float *)(st + 32) = v486;
  *(float *)(st + 36) = v488;
  v490 = *(_DWORD **)(v489 + 112);
  if ( *v490 == 1 )
  {
    v964 = *(float *)(st + 129616);
    *(_DWORD *)(st + 131424) = *(_DWORD *)(st + 131408);
    *(_DWORD *)(st + 131408) = *(_DWORD *)(st + 131392);
    *(_DWORD *)(st + 131392) = *(_DWORD *)(st + 131376);
    *(_DWORD *)(st + 131376) = *(_DWORD *)(st + 131360);
    *(_DWORD *)(st + 131360) = *(_DWORD *)(st + 131344);
    *(_DWORD *)(st + 131344) = *(_DWORD *)(st + 131328);
    *(_DWORD *)(st + 131328) = *(_DWORD *)(st + 131312);
    *(_DWORD *)(st + 131824) = *(_DWORD *)(st + 131808);
    *(_DWORD *)(st + 131856) = *(_DWORD *)(st + 131840);
    *(_DWORD *)(st + 131888) = *(_DWORD *)(st + 131872);
    *(_DWORD *)(st + 131920) = *(_DWORD *)(st + 131904);
    *(_DWORD *)(st + 131952) = *(_DWORD *)(st + 131936);
    *(float *)(st + 131248) = v964;
    *(float *)(st + 131264) = v964;
    v965 = *(float *)(st + 131440);
    v966 = (float)(v964 + v964) * *(float *)(st + 131504);
    v967 = (float)(v965 * (float)(v965 * v965)) * *(float *)(st + 131712);
    v968 = (float)((float)(v965 * *(float *)(st + 131680)) + *(float *)(st + 131664))
         + (float)((float)(v965 * v965) * *(float *)(st + 131696));
    v969 = v965;
    v970 = *(float *)(st + 131328);
    v971 = v968 + v967;
    v972 = fmax(v969, 0.19);
    v973 = (float)(v972 * v972) * *(float *)(st + 131600);
    v974 = (float)(v972 * *(float *)(st + 131584)) + *(float *)(st + 131568);
    *(float *)(st + 131312) = v966;
    v975 = v974 + v973;
    v976 = (float)((float)(v970 * *(float *)(st + 131536)) + (float)(v966 * *(float *)(st + 131520)))
         + (float)(*(float *)(st + 131552) * *(float *)(st + 131344));
    if ( v975 >= -1.0 )
      v977 = fminf(v975, 1.0);
    else
      v977 = -1.0;
    v978 = *(float *)(st + 131376);
    *(float *)(st + 131328) = v976;
    v979 = v976 - v978;
    v980 = (float)(v977 * *(float *)(st + 131616)) + *(float *)(st + 131632);
    *(float *)(st + 131344) = v979;
    v981 = *(float *)(st + 131392);
    v982 = v980 * v979;
    v983 = v979 * *(float *)(st + 131648);
    *(float *)(st + 131360) = v982 + v978;
    v984 = (float)((float)(v971 + *(float *)(st + 131728)) * v983) - v981;
    v985 = *(float *)(st + 131472) * v984;
    *(float *)(st + 131376) = (float)(v984 * *(float *)(st + 131744)) + v981;
    v986 = *(float *)(st + 131408);
    *(float *)(st + 131808) = v985;
    v987 = *(float *)(st + 132016);
    v988 = *(float *)(st + 131824);
    if ( (float)(v985 * v987) >= -1.0 )
      v989 = fminf(v985 * v987, 1.0);
    else
      v989 = -1.0;
    v990 = (float)((float)(v988 * *(float *)(st + 131984)) + (float)(v985 * *(float *)(st + 132000))) * v987;
    *(float *)(st + 131840) = (float)((float)((float)(v989 * v989) * v989) * *(float *)(st + 132048))
                            + (float)(v989 * *(float *)(st + 132032));
    if ( v990 >= -1.0 )
      v991 = fminf(v990, 1.0);
    else
      v991 = -1.0;
    v992 = *(float *)(st + 131824);
    v993 = (float)((float)(v988 + *(float *)(st + 131808)) * *(float *)(st + 131968)) * *(float *)(st + 132016);
    *(float *)(st + 131872) = (float)((float)((float)(v991 * v991) * v991) * *(float *)(st + 132048))
                            + (float)(v991 * *(float *)(st + 132032));
    if ( v993 >= -1.0 )
      v994 = fminf(v993, 1.0);
    else
      v994 = -1.0;
    v995 = (float)(*(float *)(st + 131808) * *(float *)(st + 131984)) + (float)(v992 * *(float *)(st + 132000));
    v996 = *(float *)(st + 131840);
    v997 = v995 * *(float *)(st + 132016);
    *(float *)(st + 131904) = (float)((float)((float)(v994 * v994) * v994) * *(float *)(st + 132048))
                            + (float)(v994 * *(float *)(st + 132032));
    if ( v997 >= -1.0 )
      v51 = fminf(v997, 1.0);
    v998 = *(float *)(st + 131920);
    v999 = (float)((float)(v996 + *(float *)(st + 131952)) * *(float *)(st + 132064))
         + (float)(*(float *)(st + 132080) * *(float *)(st + 131872));
    v1000 = (float)((float)((float)(v51 * v51) * v51) * *(float *)(st + 132048))
          + (float)(v51 * *(float *)(st + 132032));
    *(float *)(st + 131936) = v1000;
    v1001 = (float)((float)((float)(*(float *)(st + 131904) + *(float *)(st + 131888)) * *(float *)(st + 132096))
                  + (float)((float)(v998 * *(float *)(st + 132080)) + v999))
          + (float)((float)(v1000 + *(float *)(st + 131856)) * *(float *)(st + 132112));
    *(float *)(st + 131392) = v1001;
    v1002 = (float)((float)(v986 * *(float *)(st + 131776)) + (float)(v1001 * *(float *)(st + 131760)))
          + (float)(*(float *)(st + 131792) * *(float *)(st + 131424));
    *(float *)(st + 131408) = v1002;
    v1003 = (float)(v1002 * *(float *)(st + 131456)) * *(float *)(st + 131472);
    *(float *)(st + 131280) = v1003;
    *(float *)(st + 131296) = v1003;
    *(_DWORD *)(st + 132176) = *(_DWORD *)(st + 132160);
    *(_DWORD *)(st + 132160) = *(_DWORD *)(st + 132144);
    *(_DWORD *)(st + 132144) = *(_DWORD *)(st + 132128);
    *(float *)(st + 132128) = v1003;
    v1004 = *(float *)(st + 132208);
    v1005 = (float)((float)(*(float *)(st + 132144) * *(float *)(st + 132240)) + (float)(v1003 * *(float *)(st + 132224)))
          + (float)(*(float *)(st + 132256) * *(float *)(st + 132160));
    v1006 = (float)((float)(*(float *)(st + 132144) * *(float *)(st + 132288)) + (float)(v1003 * *(float *)(st + 132272)))
          + (float)(*(float *)(st + 132304) * *(float *)(st + 132176));
    if ( v1004 <= 0.0 )
      v1007 = 0.0;
    else
      v1007 = v1004;
    v1008 = v1007;
    *(float *)(st + 132144) = v1005;
    *(float *)(st + 132160) = v1006;
    v1009 = (float)((float)(v1008 * v1005) - (float)(v1008 * v1003)) + v1003;
    if ( v1004 < -0.0 )
      v49 = (float)-v1004;
    v1010 = v49;
    v1011 = v1003 + (float)((float)(v1010 * v1006) - (float)(v1010 * v1003));
    if ( v1004 >= 0.0 )
      v1011 = v1009;
    *(float *)(st + 132192) = v1011;
    *(float *)(st + 129760) = v1011;
    v542 = *(_DWORD *)(st + 132192);
    goto LABEL_355;
  }
  v491 = (unsigned int)(*v490 - 2);
  switch ( *v490 )
  {
    case 2:
      v810 = *(float *)(st + 129616);
      *(_DWORD *)(st + 264800) = *(_DWORD *)(st + 264784);
      *(_DWORD *)(st + 264784) = *(_DWORD *)(st + 264768);
      *(_DWORD *)(st + 263760) = *(_DWORD *)(st + 263744);
      *(_DWORD *)(st + 263744) = *(_DWORD *)(st + 263728);
      *(_DWORD *)(st + 263728) = *(_DWORD *)(st + 263712);
      *(_DWORD *)(st + 263712) = *(_DWORD *)(st + 263696);
      *(_DWORD *)(st + 263696) = *(_DWORD *)(st + 263680);
      *(_DWORD *)(st + 263824) = *(_DWORD *)(st + 263808);
      *(_DWORD *)(st + 263856) = *(_DWORD *)(st + 263840);
      *(_DWORD *)(st + 263984) = *(_DWORD *)(st + 263968);
      *(_DWORD *)(st + 263968) = *(_DWORD *)(st + 263952);
      *(_DWORD *)(st + 263952) = *(_DWORD *)(st + 263936);
      *(_DWORD *)(st + 263936) = *(_DWORD *)(st + 263920);
      *(_DWORD *)(st + 263920) = *(_DWORD *)(st + 263904);
      *(_DWORD *)(st + 263904) = *(_DWORD *)(st + 263888);
      *(_DWORD *)(st + 263888) = *(_DWORD *)(st + 263872);
      *(_DWORD *)(st + 264016) = *(_DWORD *)(st + 264000);
      *(_DWORD *)(st + 264048) = *(_DWORD *)(st + 264032);
      *(_DWORD *)(st + 264080) = *(_DWORD *)(st + 264064);
      *(_DWORD *)(st + 264112) = *(_DWORD *)(st + 264096);
      *(_DWORD *)(st + 264144) = *(_DWORD *)(st + 264128);
      *(_DWORD *)(st + 264208) = *(_DWORD *)(st + 264192);
      *(_DWORD *)(st + 264240) = *(_DWORD *)(st + 264224);
      *(_DWORD *)(st + 264272) = *(_DWORD *)(st + 264256);
      *(_DWORD *)(st + 264304) = *(_DWORD *)(st + 264288);
      *(_DWORD *)(st + 264336) = *(_DWORD *)(st + 264320);
      *(_DWORD *)(st + 264496) = *(_DWORD *)(st + 264480);
      *(_DWORD *)(st + 264688) = *(_DWORD *)(st + 264672);
      *(_DWORD *)(st + 264672) = *(_DWORD *)(st + 264656);
      *(_DWORD *)(st + 264656) = *(_DWORD *)(st + 264640);
      *(_DWORD *)(st + 264752) = *(_DWORD *)(st + 264736);
      *(_DWORD *)(st + 264736) = *(_DWORD *)(st + 264720);
      *(_DWORD *)(st + 264720) = *(_DWORD *)(st + 264704);
      v811 = *(float *)(st + 265408);
      v812 = fminf(*(float *)(st + 264784) + 0.000061035156, v811);
      *(float *)(st + 264768) = v812;
      if ( (float)(v812 - v811) >= 0.0 )
      {
        v813 = *(float *)(st + 265424) + *(float *)(st + 264800);
        if ( v813 >= 1.0 )
        {
          v814 = 1.0;
LABEL_216:
          v815 = v814;
          *(float *)(st + 264784) = v815;
          v816 = *(float *)(st + 265024) * *(float *)(st + 264880);
          v817 = (float)((float)(v810 * *(float *)(st + 264896)) * *(float *)(st + 264864))
               + (float)((float)(1.0 - *(float *)(st + 264864)) * v810);
          *(float *)(st + 263648) = (float)((float)(v816 * *(float *)(st + 263824)) * *(float *)(st + 264800)) + v817;
          *(float *)(st + 263664) = (float)((float)(v816 * *(float *)(st + 263856)) * *(float *)(st + 264800)) + v817;
          v818 = (float)((float)(v810 * 0.5) + (float)(v810 * 0.5)) * *(float *)(st + 264848);
          v819 = *(float *)(st + 263904) * *(float *)(st + 265088);
          v820 = *(float *)(st + 263888);
          *(float *)(st + 263872) = v818;
          v821 = *(float *)(st + 263920);
          v822 = *(float *)(st + 265152) * *(float *)(st + 263952);
          v823 = *(float *)(st + 263936) * *(float *)(st + 265088);
          v824 = (float)((float)((float)(v820 * *(float *)(st + 265072)) + (float)(v818 * *(float *)(st + 265056)))
                       + v819)
               + (float)((float)(*(float *)(st + 263936) * *(float *)(st + 265120))
                       + (float)(v821 * *(float *)(st + 265104)));
          *(float *)(st + 263904) = v824;
          v825 = *(float *)(st + 263984);
          v826 = (float)((float)((float)(v824 * *(float *)(st + 265056)) + (float)(v821 * *(float *)(st + 265072)))
                       + v823)
               + (float)((float)(*(float *)(st + 265120) * *(float *)(st + 263968))
                       + (float)(*(float *)(st + 265104) * *(float *)(st + 263952)));
          *(float *)(st + 263936) = v826;
          v827 = (float)((float)(v826 * *(float *)(st + 265136)) + (float)(v825 * *(float *)(st + 265168))) + v822;
          *(float *)(st + 263968) = v827;
          v828 = jx_h_3A2180(0.0f)/*ARGLESS2*/;
          v829 = *(float *)&v828;
          v830 = *(float *)(st + 265376);
          *(float *)(st + 264064) = v829;
          if ( v829 < 0.0 )
            v830 = -v830;
          v831 = fabs(v829);
          *(float *)(st + 264128) = v830;
          v832 = *(float *)(st + 265392);
          v833 = *(float *)(st + 264944) * *(float *)(st + 263760);
          *(float *)(st + 263776) = (float)(v832 + (float)(1.0 - v831)) * v833;
          *(float *)(st + 263792) = (float)(v832 + v831) * v833;
          v834 = *(float *)(st + 264912);
          v835 = v827 * *(float *)(st + 264864);
          *(float *)(st + 264000) = v835;
          *(float *)(st + 264032) = v835;
          v836 = v834 * *(float *)(st + 265344);
          v837 = *(float *)(st + 265360);
          v838 = 1.0 / (float)((float)(v836 * (float)(1.0 - v831)) + v837);
          v839 = 1.0
               / (float)((float)((float)((float)(*(float *)(st + 264992) + 1.0) * v836) * v831)
                       + (float)(v837 + *(float *)(st + 264976)));
          *(float *)(st + 264160) = 1.0 / v838;
          v840 = 1.0 / v839;
          v841 = v839 * 0.000061035156;
          *(float *)(st + 264176) = v840;
          v842 = *(float *)(st + 263696);
          v843 = *(float *)(st + 263712);
          v844 = (float)(v838 * 0.000061035156) + *(float *)(st + 264208);
          v845 = *(float *)(st + 265328);
          v846 = (int)(float)(v842 * -16777216.0);
          if ( v846 )
          {
            v847 = v846 & 0x200000;
            if ( (v846 & 0x800000) != 0 )
            {
              if ( !v847 )
              {
                v19 = 2 * v846;
                goto LABEL_226;
              }
            }
            else
            {
              v19 = 2 * v846;
              if ( v847 )
                goto LABEL_226;
            }
            v19 = 2 * v846 + 1;
          }
LABEL_226:
          v848 = *(float *)(st + 264240) + v841;
          v849 = v19;
          v850 = v19 & 0xFFFFFF;
          v851 = v19 | 0xFF000000;
          if ( (v849 & 0x1000000) == 0 )
            v851 = v850;
          v852 = (float)v851 * 0.000000059604645;
          *(float *)(st + 263680) = v852;
          v853 = *(float *)(st + 265008);
          v854 = (float)((float)(v842 * *(float *)(st + 265200)) + (float)(v852 * *(float *)(st + 265184)))
               + (float)(v843 * *(float *)(st + 265216));
          v855 = *(float *)(st + 263712) * *(float *)(st + 265264);
          *(float *)(st + 263696) = v854;
          if ( (float)(v848 - v845) >= 0.0 )
            v848 = v848 - v845;
          if ( v853 == 0.0 )
            v844 = 0.000061035156;
          v856_bits = *(uint32_t *)(st + 265312); v856 = f32_from_bits(v856_bits);
          if ( v853 == 0.0 )
            v848 = 0.000061035156;
          v857 = (float)((float)((float)(v855 * *(float *)(st + 265248)) + (float)(v854 * *(float *)(st + 265232)))
                       + (float)(*(float *)(st + 263728) * *(float *)(st + 265264)))
               + (float)((float)(*(float *)(st + 265280) * *(float *)(st + 263744))
                       + (float)(*(float *)(st + 265296) * *(float *)(st + 263760)));
          v858_bits = *(uint32_t *)(st + 265312); v858 = f32_from_bits(v858_bits);
          v856 = v856 + v844;
          v858 = v858 + v848;
          *(float *)(st + 263728) = v857;
          *(float *)(st + 264192) = v844;
          *(float *)(st + 264224) = v848;
          v859 = *(float *)(st + 264272);
          v860 = v856;
          v860 = v856 * 16384.0;
          v861 = (int)(float)(v856 * 16384.0);
          if ( v861 != 0x80000000 && (float)v861 != v860 )
            v860 = (float)(v861 - (int)((bits_from_f32(v860) >> 31) & 1u));
          *(_DWORD *)(st + 264400) = bits_from_f32(v856);
          *(_DWORD *)(st + 264560) = bits_from_f32(v858);
          v862 = v860 * 0.000061035156;
          v858 = v858 * 16384.0;
          *(float *)(st + 264256) = v862;
          v863 = v862 - v859;
          v864 = (int)v858;
          *(float *)(st + 264464) = v863;
          if ( (int)v858 != 0x80000000 && (float)v864 != v858 )
            v858 = (float)(v864 - (int)((bits_from_f32(v858) >> 31) & 1u));
          *(float *)(st + 264288) = v858 * 0.000061035156;
          if ( v863 == 0.0 )
          {
            v865 = *(_DWORD *)(st + 264336);
            *(_DWORD *)(st + 264320) = v865;
            *(_DWORD *)(st + 264352) = v865;
            v866 = *(float *)(st + 264400);
            *(_DWORD *)(st + 264368) = v865;
            *(_DWORD *)(st + 264384) = v865;
LABEL_264:
            *(float *)(st + 264416) = v866;
            *(float *)(st + 264432) = v866;
            goto LABEL_266;
          }
          v867_bits = *(uint32_t *)(st + 264400); v867 = f32_from_bits(v867_bits);
          v867 = v867 * 16384.0;
          v868 = v867;
          v869 = (int)v867;
          if ( (int)v867 != 0x80000000 && (float)v869 != v867 )
            v868 = (float)(v869 - (int)((bits_from_f32(v867) >> 31) & 1u));
          v870 = *(float *)(st + 265328);
          v871 = 1.0 - (float)((float)(v867 - v868) * *(float *)(st + 264160));
          v872 = *(float *)(st + 264464);
          *(float *)(st + 264320) = (float)((float)(1.0 - v871) * *(float *)(st + 264016))
                                  + (float)(v871 * *(float *)(st + 264000));
          if ( v872 < 0.0 )
            v872 = v872 + v870;
          *(float *)(st + 264464) = v872;
          v866 = *(float *)(st + 264400);
          if ( v872 == 0.00024414062 )
          {
            v873 = *(float *)(st + 264320);
            v874 = *(float *)(st + 264336);
            v1013 = *(float *)(st + 263472);
            *(float *)(st + 264352) = (float)(v874 * 0.25) + (float)(v873 * 0.75);
            v875 = *(float *)(st + 263488);
            *(float *)(st + 264368) = (float)(v874 + v873) * 0.5;
            v876 = *(float *)(st + 265328);
            *(float *)(st + 264384) = (float)(v874 * 0.75) + (float)(v873 * 0.25);
            v877 = v866 - *(float *)(st + 263456);
            if ( v877 < 0.0 )
              v877 = v877 + v876;
            v878 = v866 - v875;
            v879 = v866 - *(float *)(st + 263472);
            if ( (float)(v866 - v1013) < 0.0 )
              v879 = v879 + v876;
            *(float *)(st + 264416) = v877;
            v866 = v866 - *(float *)(st + 263488);
            if ( v878 < 0.0 )
              v866 = v866 + v876;
            *(float *)(st + 264432) = v879;
          }
          else
          {
            if ( v872 != 0.00018310547 )
            {
              if ( v872 != 0.00012207031 )
              {
                v889 = *(_DWORD *)(st + 264320);
                *(_DWORD *)(st + 264352) = v889;
                *(float *)(st + 264416) = v866;
                *(_DWORD *)(st + 264368) = v889;
                *(float *)(st + 264432) = v866;
                *(_DWORD *)(st + 264384) = v889;
                goto LABEL_266;
              }
              v886 = (float)(*(float *)(st + 264336) + *(float *)(st + 264320)) * 0.5;
              *(float *)(st + 264352) = v886;
              *(float *)(st + 264368) = v886;
              v887 = v866 - *(float *)(st + 263456);
              v888 = *(float *)(st + 265328);
              *(float *)(st + 264384) = v886;
              v866 = v866 - *(float *)(st + 263456);
              if ( v887 < 0.0 )
                v866 = v866 + v888;
              goto LABEL_264;
            }
            v880 = *(float *)(st + 264320);
            v881 = *(float *)(st + 264336) * 0.67 + v880 * 0.33;
            v882 = v880 * 0.67 + *(float *)(st + 264336) * 0.33;
            *(float *)(st + 264352) = v882;
            v883 = *(float *)(st + 265328);
            *(float *)(st + 264368) = v881;
            *(float *)(st + 264384) = v881;
            v884 = v866 - *(float *)(st + 263472);
            v885 = v866 - *(float *)(st + 263456);
            if ( v885 < 0.0 )
              v885 = v885 + v883;
            v866 = v866 - *(float *)(st + 263472);
            if ( v884 < 0.0 )
              v866 = v866 + v883;
            *(float *)(st + 264416) = v885;
            *(float *)(st + 264432) = v866;
          }
LABEL_266:
          *(float *)(st + 264448) = v866;
          v891_bits = *(uint32_t *)(st + 264400); v891 = f32_from_bits(v891_bits);
          v890_bits = *(uint32_t *)(st + 264416); v890 = f32_from_bits(v890_bits);
          v891 = v891 * 16384.0;
          v892 = (int)v891;
          if ( (int)v891 != 0x80000000 && (float)v892 != v891 )
            v891 = (float)(v892 - (int)((bits_from_f32(v891) >> 31) & 1u));
          v893 = *(float *)(st + 197872);
          v894 = *(float *)(st + 265328);
          v895 = v891 * 0.000061035156;
          v890 = v890 * 16384.0;
          v896 = (int)v890;
          *(_DWORD *)(st
                    + 4
                    * ((*(int *)(st + 197860) - 1LL) & (*(_DWORD *)(st + 197856) - (int)(float)(v895 * -16384.0) + 1LL))
                    + 132320) = *(_DWORD *)(st + 264320);
          v897_bits = *(uint32_t *)(st + 264432); v897 = f32_from_bits(v897_bits);
          if ( (int)v890 != 0x80000000 && (float)v896 != v890 )
            v890 = (float)(v896 - (int)((bits_from_f32(v890) >> 31) & 1u));
          v898 = v890 * 0.000061035156;
          v897 = v897 * 16384.0;
          v899 = (int)v897;
          *(_DWORD *)(st
                    + 4
                    * ((*(int *)(st + 197860) - 1LL) & (*(_DWORD *)(st + 197856) - (int)(float)(v898 * -16384.0) + 1LL))
                    + 132320) = *(_DWORD *)(st + 264352);
          v900_bits = *(uint32_t *)(st + 264448); v900 = f32_from_bits(v900_bits);
          if ( (int)v897 != 0x80000000 && (float)v899 != v897 )
            v897 = (float)(v899 - (int)((bits_from_f32(v897) >> 31) & 1u));
          v901 = v897 * 0.000061035156;
          v900 = v900 * 16384.0;
          v902 = (int)v900;
          *(_DWORD *)(st
                    + 4
                    * ((*(int *)(st + 197860) - 1LL) & (*(_DWORD *)(st + 197856) - (int)(float)(v901 * -16384.0) + 1LL))
                    + 132320) = *(_DWORD *)(st + 264368);
          if ( (int)v900 != 0x80000000 && (float)v902 != v900 )
            v900 = (float)(v902 - (int)((bits_from_f32(v900) >> 31) & 1u));
          v903 = v900 * 0.000061035156;
          *(_DWORD *)(st
                    + 4
                    * ((*(int *)(st + 197860) - 1LL) & (*(_DWORD *)(st + 197856) - (int)(float)(v903 * -16384.0) + 1LL))
                    + 132320) = *(_DWORD *)(st + 264384);
          if ( (float)(v895 - v893) == 0.0 )
            *(_DWORD *)(st
                      + 4
                      * ((*(int *)(st + 197860) - 1LL) & (*(_DWORD *)(st + 197856) - (int)(float)(v894 * -16384.0) + 1LL))
                      + 132320) = *(_DWORD *)(st + 264320);
          if ( (float)(v898 - v893) == 0.0 )
            *(_DWORD *)(st
                      + 4
                      * ((*(int *)(st + 197860) - 1LL) & (*(_DWORD *)(st + 197856) - (int)(float)(v894 * -16384.0) + 1LL))
                      + 132320) = *(_DWORD *)(st + 264352);
          if ( (float)(v901 - v893) == 0.0 )
            *(_DWORD *)(st
                      + 4
                      * ((*(int *)(st + 197860) - 1LL) & (*(_DWORD *)(st + 197856) - (int)(float)(v894 * -16384.0) + 1LL))
                      + 132320) = *(_DWORD *)(st + 264368);
          if ( (float)(v903 - v893) == 0.0 )
            *(_DWORD *)(st
                      + 4
                      * ((*(int *)(st + 197860) - 1LL) & (*(_DWORD *)(st + 197856) - (int)(float)(v894 * -16384.0) + 1LL))
                      + 132320) = *(_DWORD *)(st + 264384);
          v904 = *(float *)(st + 264288) - *(float *)(st + 264304);
          *(float *)(st + 264624) = v904;
          if ( v904 == 0.0 )
          {
            v905 = *(_DWORD *)(st + 264496);
            *(_DWORD *)(st + 264480) = v905;
            *(_DWORD *)(st + 264512) = v905;
            v906 = *(float *)(st + 264560);
            *(_DWORD *)(st + 264528) = v905;
            *(_DWORD *)(st + 264544) = v905;
          }
          else
          {
            v907_bits = *(uint32_t *)(st + 264560); v907 = f32_from_bits(v907_bits);
            v907 = v907 * 16384.0;
            v908 = v907;
            v909 = (int)v907;
            if ( (int)v907 != 0x80000000 && (float)v909 != v907 )
              v908 = (float)(v909 - (int)((bits_from_f32(v907) >> 31) & 1u));
            v910 = 1.0 - (float)((float)(v907 - v908) * *(float *)(st + 264176));
            v911 = *(float *)(st + 265328);
            *(float *)(st + 264480) = (float)((float)(1.0 - v910) * *(float *)(st + 264048))
                                    + (float)(v910 * *(float *)(st + 264032));
            if ( v904 < 0.0 )
              v904 = v904 + v911;
            *(float *)(st + 264624) = v904;
            v906 = *(float *)(st + 264560);
            if ( v904 == 0.00024414062 )
            {
              v912 = *(float *)(st + 264480);
              v913 = *(float *)(st + 264496);
              v914 = *(float *)(st + 263472);
              *(float *)(st + 264512) = (float)(v913 * 0.25) + (float)(v912 * 0.75);
              v915 = *(float *)(st + 263488);
              *(float *)(st + 264528) = (float)(v913 + v912) * 0.5;
              v916 = *(float *)(st + 265328);
              *(float *)(st + 264544) = (float)(v913 * 0.75) + (float)(v912 * 0.25);
              v917 = v906 - *(float *)(st + 263456);
              if ( v917 < 0.0 )
                v917 = v917 + v916;
              v918 = v906 - v915;
              v919 = v906 - *(float *)(st + 263472);
              if ( (float)(v906 - v914) < 0.0 )
                v919 = v919 + v916;
              *(float *)(st + 264576) = v917;
              v906 = v906 - *(float *)(st + 263488);
              if ( v918 < 0.0 )
                v906 = v906 + v916;
              *(float *)(st + 264592) = v919;
              goto LABEL_312;
            }
            if ( v904 == 0.00018310547 )
            {
              v920 = *(float *)(st + 264480);
              v921 = *(float *)(st + 264496) * 0.67 + v920 * 0.33;
              v922 = v920 * 0.67 + *(float *)(st + 264496) * 0.33;
              *(float *)(st + 264512) = v922;
              v923 = *(float *)(st + 265328);
              *(float *)(st + 264528) = v921;
              *(float *)(st + 264544) = v921;
              v924 = v906 - *(float *)(st + 263472);
              v925 = v906 - *(float *)(st + 263456);
              if ( v925 < 0.0 )
                v925 = v925 + v923;
              v906 = v906 - *(float *)(st + 263472);
              if ( v924 < 0.0 )
                v906 = v906 + v923;
              *(float *)(st + 264576) = v925;
              *(float *)(st + 264592) = v906;
              goto LABEL_312;
            }
            if ( v904 != 0.00012207031 )
            {
              v929 = *(_DWORD *)(st + 264480);
              *(_DWORD *)(st + 264512) = v929;
              *(float *)(st + 264576) = v906;
              *(_DWORD *)(st + 264528) = v929;
              *(float *)(st + 264592) = v906;
              *(_DWORD *)(st + 264544) = v929;
LABEL_312:
              *(float *)(st + 264608) = v906;
              v931_bits = *(uint32_t *)(st + 264560); v931 = f32_from_bits(v931_bits);
              v930_bits = *(uint32_t *)(st + 264576); v930 = f32_from_bits(v930_bits);
              v931 = v931 * 16384.0;
              v932 = (int)v931;
              if ( (int)v931 != 0x80000000 && (float)v932 != v931 )
                v931 = (float)(v932 - (int)((bits_from_f32(v931) >> 31) & 1u));
              v933 = *(float *)(st + 263440);
              v934 = *(float *)(st + 265328);
              v935 = v931 * 0.000061035156;
              v930 = v930 * 16384.0;
              v936 = (int)v930;
              *(_DWORD *)(st
                        + 4
                        * ((*(int *)(st + 263428) - 1LL)
                         & (*(_DWORD *)(st + 263424) - (int)(float)(v935 * -16384.0) + 1LL))
                        + 197888) = *(_DWORD *)(st + 264480);
              v937_bits = *(uint32_t *)(st + 264592); v937 = f32_from_bits(v937_bits);
              if ( (int)v930 != 0x80000000 && (float)v936 != v930 )
                v930 = (float)(v936 - (int)((bits_from_f32(v930) >> 31) & 1u));
              v938 = v930 * 0.000061035156;
              v937 = v937 * 16384.0;
              v939 = (int)v937;
              *(_DWORD *)(st
                        + 4
                        * ((*(int *)(st + 263428) - 1LL)
                         & (*(_DWORD *)(st + 263424) - (int)(float)(v938 * -16384.0) + 1LL))
                        + 197888) = *(_DWORD *)(st + 264512);
              v940_bits = *(uint32_t *)(st + 264608); v940 = f32_from_bits(v940_bits);
              if ( (int)v937 != 0x80000000 && (float)v939 != v937 )
                v937 = (float)(v939 - (int)((bits_from_f32(v937) >> 31) & 1u));
              v941 = v937 * 0.000061035156;
              v940 = v940 * 16384.0;
              v942 = (int)v940;
              *(_DWORD *)(st
                        + 4
                        * ((*(int *)(st + 263428) - 1LL)
                         & (*(_DWORD *)(st + 263424) - (int)(float)(v941 * -16384.0) + 1LL))
                        + 197888) = *(_DWORD *)(st + 264528);
              if ( (int)v940 != 0x80000000 && (float)v942 != v940 )
                v940 = (float)(v942 - (int)((bits_from_f32(v940) >> 31) & 1u));
              v943 = v940 * 0.000061035156;
              *(_DWORD *)(st
                        + 4
                        * ((*(int *)(st + 263428) - 1LL)
                         & (*(_DWORD *)(st + 263424) - (int)(float)(v943 * -16384.0) + 1LL))
                        + 197888) = *(_DWORD *)(st + 264544);
              if ( (float)(v935 - v933) == 0.0 )
                *(_DWORD *)(st
                          + 4
                          * ((*(int *)(st + 263428) - 1LL)
                           & (*(_DWORD *)(st + 263424) - (int)(float)(v934 * -16384.0) + 1LL))
                          + 197888) = *(_DWORD *)(st + 264480);
              if ( (float)(v938 - v933) == 0.0 )
                *(_DWORD *)(st
                          + 4
                          * ((*(int *)(st + 263428) - 1LL)
                           & (*(_DWORD *)(st + 263424) - (int)(float)(v934 * -16384.0) + 1LL))
                          + 197888) = *(_DWORD *)(st + 264512);
              if ( (float)(v941 - v933) == 0.0 )
                *(_DWORD *)(st
                          + 4
                          * ((*(int *)(st + 263428) - 1LL)
                           & (*(_DWORD *)(st + 263424) - (int)(float)(v934 * -16384.0) + 1LL))
                          + 197888) = *(_DWORD *)(st + 264528);
              if ( (float)(v943 - v933) == 0.0 )
                *(_DWORD *)(st
                          + 4
                          * ((*(int *)(st + 263428) - 1LL)
                           & (*(_DWORD *)(st + 263424) - (int)(float)(v934 * -16384.0) + 1LL))
                          + 197888) = *(_DWORD *)(st + 264544);
              v944 = *(float *)(st + 264672);
              v945 = *(float *)(st + 264656);
              v946 = (float)((float)(1.0 - *(float *)(st + 263528)) * *(float *)(st + 263520))
                   + (float)(*(float *)(st + 263528) * *(float *)(st + 263524));
              v947 = *(float *)(st + 264192) * 16384.0;
              v948 = (int)(float)(*(float *)(st + 264192) * -16384.0);
              *(_DWORD *)(st + 263520) = *(_DWORD *)(st
                                                   + 4
                                                   * ((*(int *)(st + 197860) - 1LL)
                                                    & (*(_DWORD *)(st + 197856) - v948 + 1LL))
                                                   + 132320);
              *(_DWORD *)(st + 263524) = *(_DWORD *)(st
                                                   + 4
                                                   * ((*(int *)(st + 197860) - 1LL)
                                                    & (*(_DWORD *)(st + 197856) - v948 + 2LL))
                                                   + 132320);
              v949 = v947 - (double)(int)v947;
              *(float *)(st + 263528) = v949;
              *(float *)(st + 264640) = v946;
              v950 = *(float *)(st + 264688);
              v951 = *(float *)(st + 264960);
              v952 = (float)((float)((float)((float)((float)((float)(v945 + v946) * 0.5) - v944)
                                           * *(float *)(st + 265040))
                                   - v950)
                           * v951)
                   + v944;
              *(float *)(st + 264656) = v952;
              v953 = (float)(v952 * v951) + v950;
              *(float *)(st + 264672) = v953;
              *(float *)(st + 263808) = v953 + *(float *)(st + 263776);
              v954 = *(float *)(st + 264224);
              v955 = *(float *)(st + 264720);
              v956 = *(float *)(st + 264736);
              v957 = (float)((float)(1.0 - *(float *)(st + 263592)) * *(float *)(st + 263584))
                   + (float)(*(float *)(st + 263592) * *(float *)(st + 263588));
              v958 = (int)(float)(v954 * -16384.0);
              *(_DWORD *)(st + 263584) = *(_DWORD *)(st
                                                   + 4
                                                   * ((*(int *)(st + 263428) - 1LL)
                                                    & (*(_DWORD *)(st + 263424) - v958 + 1LL))
                                                   + 197888);
              *(_DWORD *)(st + 263588) = *(_DWORD *)(st
                                                   + 4
                                                   * ((*(int *)(st + 263428) - 1LL)
                                                    & (*(_DWORD *)(st + 263424) - v958 + 2LL))
                                                   + 197888);
              v959 = (float)(v954 * 16384.0) - (double)(int)(float)(v954 * 16384.0);
              *(float *)(st + 263592) = v959;
              *(float *)(st + 264704) = v957;
              v960 = *(float *)(st + 264752);
              v961 = *(float *)(st + 264960);
              v962 = (float)((float)((float)((float)((float)((float)(v955 + v957) * 0.5) - v956)
                                           * *(float *)(st + 265040))
                                   - v960)
                           * v961)
                   + v956;
              *(float *)(st + 264720) = v962;
              v963 = (float)(v962 * v961) + v960;
              *(float *)(st + 264736) = v963;
              *(float *)(st + 263840) = v963 + *(float *)(st + 263792);
              *(_DWORD *)(st + 129760) = *(_DWORD *)(st + 263648);
              v542 = *(_DWORD *)(st + 263664);
              goto LABEL_355;
            }
            v926 = (float)(*(float *)(st + 264480) + *(float *)(st + 264496)) * 0.5;
            *(float *)(st + 264512) = v926;
            *(float *)(st + 264528) = v926;
            v927 = v906 - *(float *)(st + 263456);
            v928 = *(float *)(st + 265328);
            *(float *)(st + 264544) = v926;
            v906 = v906 - *(float *)(st + 263456);
            if ( v927 < 0.0 )
              v906 = v906 + v928;
          }
          *(float *)(st + 264576) = v906;
          *(float *)(st + 264592) = v906;
          goto LABEL_312;
        }
      }
      else
      {
        v813 = 0.0;
      }
      v814 = v813;
      goto LABEL_216;
    case 3:
      v751 = *(float *)(st + 129616);
      *(_DWORD *)(st + 265648) = *(_DWORD *)(st + 265632);
      *(_DWORD *)(st + 265632) = *(_DWORD *)(st + 265616);
      *(_DWORD *)(st + 265616) = *(_DWORD *)(st + 265600);
      *(_DWORD *)(st + 265600) = *(_DWORD *)(st + 265584);
      *(_DWORD *)(st + 265584) = *(_DWORD *)(st + 265568);
      *(_DWORD *)(st + 265568) = *(_DWORD *)(st + 265552);
      *(_DWORD *)(st + 265552) = *(_DWORD *)(st + 265536);
      *(_DWORD *)(st + 265536) = *(_DWORD *)(st + 265520);
      *(_DWORD *)(st + 265520) = *(_DWORD *)(st + 265504);
      *(_DWORD *)(st + 266048) = *(_DWORD *)(st + 266032);
      *(_DWORD *)(st + 266080) = *(_DWORD *)(st + 266064);
      *(_DWORD *)(st + 266112) = *(_DWORD *)(st + 266096);
      *(_DWORD *)(st + 266144) = *(_DWORD *)(st + 266128);
      *(_DWORD *)(st + 266176) = *(_DWORD *)(st + 266160);
      *(_DWORD *)(st + 266208) = *(_DWORD *)(st + 266192);
      *(_DWORD *)(st + 266240) = *(_DWORD *)(st + 266224);
      *(_DWORD *)(st + 266272) = *(_DWORD *)(st + 266256);
      *(_DWORD *)(st + 266304) = *(_DWORD *)(st + 266288);
      *(_DWORD *)(st + 266336) = *(_DWORD *)(st + 266320);
      *(float *)(st + 265440) = v751;
      *(float *)(st + 265456) = v751;
      v752 = *(float *)(st + 265520);
      v753 = (float)(v751 + v751) * *(float *)(st + 265728);
      *(float *)(st + 265504) = v753;
      v754 = *(float *)(st + 265552);
      v755 = *(float *)(st + 265664);
      v756 = (float)(*(float *)(st + 265776) * *(float *)(st + 265536))
           + (float)((float)(v752 * *(float *)(st + 265760)) + (float)(v753 * *(float *)(st + 265744)));
      *(float *)(st + 266032) = v756;
      v757 = *(float *)(st + 266400);
      v758 = *(float *)(st + 266048);
      if ( (float)(v756 * v757) >= -1.0 )
        v759 = fminf(v756 * v757, 1.0);
      else
        v759 = -1.0;
      v760 = (float)((float)(v758 * *(float *)(st + 266368)) + (float)(v756 * *(float *)(st + 266384))) * v757;
      *(float *)(st + 266064) = (float)((float)((float)(v759 * v759) * v759) * *(float *)(st + 266448))
                              + (float)(v759 * *(float *)(st + 266432));
      if ( v760 >= -1.0 )
        v761 = fminf(v760, 1.0);
      else
        v761 = -1.0;
      v762 = *(float *)(st + 266048);
      v763 = (float)((float)(v758 + *(float *)(st + 266032)) * *(float *)(st + 266352)) * *(float *)(st + 266400);
      *(float *)(st + 266096) = (float)((float)((float)(v761 * v761) * v761) * *(float *)(st + 266448))
                              + (float)(v761 * *(float *)(st + 266432));
      if ( v763 >= -1.0 )
        v764 = fminf(v763, 1.0);
      else
        v764 = -1.0;
      v765 = *(float *)(st + 266064);
      v766 = (float)((float)(v762 * *(float *)(st + 266384)) + (float)(*(float *)(st + 266032) * *(float *)(st + 266368)))
           * *(float *)(st + 266400);
      *(float *)(st + 266128) = (float)((float)((float)(v764 * v764) * v764) * *(float *)(st + 266448))
                              + (float)(v764 * *(float *)(st + 266432));
      if ( v766 >= -1.0 )
        v767 = fminf(v766, 1.0);
      else
        v767 = -1.0;
      v768 = *(float *)(st + 266144);
      v769 = (float)((float)(v765 + *(float *)(st + 266176)) * *(float *)(st + 266464))
           + (float)(*(float *)(st + 266480) * *(float *)(st + 266096));
      v770 = (float)((float)((float)(v767 * v767) * v767) * *(float *)(st + 266448))
           + (float)(v767 * *(float *)(st + 266432));
      *(float *)(st + 266160) = v770;
      v771 = (float)(v768 * *(float *)(st + 266480)) + v769;
      v772 = (float)(v770 + *(float *)(st + 266080)) * *(float *)(st + 266512);
      v773 = (float)(*(float *)(st + 266128) + *(float *)(st + 266112)) * *(float *)(st + 266496);
      *(float *)(st + 265520) = v756;
      v774 = (float)(v771 + v773) + v772;
      *(float *)(st + 265536) = v774;
      v775 = *(float *)(st + 265568);
      v776 = (float)(v755 * *(float *)(st + 265904)) + *(float *)(st + 265888);
      v777 = (float)((float)(v754 * *(float *)(st + 265808)) + (float)(v774 * *(float *)(st + 265792)))
           + (float)(v775 * *(float *)(st + 265824));
      *(float *)(st + 265552) = v777;
      v778 = *(float *)(st + 265584);
      v779 = (float)((float)(v775 * *(float *)(st + 265856)) + (float)(v777 * *(float *)(st + 265840)))
           + (float)(v778 * *(float *)(st + 265872));
      *(float *)(st + 265568) = v779;
      v780 = (float)((float)(v778 * *(float *)(st + 265856)) + (float)(v779 * *(float *)(st + 265840)))
           + (float)(*(float *)(st + 265872) * *(float *)(st + 265600));
      v781 = (float)(v755 * v755) * *(float *)(st + 265920);
      *(float *)(st + 265584) = v780;
      v782 = *(float *)(st + 265616);
      v783 = (float)((float)((float)((float)((float)(v755 * (float)(v755 * v755)) * *(float *)(st + 265936))
                                   + (float)(v776 + v781))
                           + *(float *)(st + 265952))
                   * v780)
           - v782;
      v784 = v783 * *(float *)(st + 265696);
      *(float *)(st + 265600) = (float)(v783 * *(float *)(st + 265968)) + v782;
      v785 = *(float *)(st + 265632);
      *(float *)(st + 266192) = v784;
      v786 = *(float *)(st + 266416);
      v787 = *(float *)(st + 266208);
      if ( (float)(v784 * v786) >= -1.0 )
        v788 = fminf(v784 * v786, 1.0);
      else
        v788 = -1.0;
      v789 = (float)((float)(v784 * *(float *)(st + 266384)) + (float)(v787 * *(float *)(st + 266368))) * v786;
      *(float *)(st + 266224) = (float)((float)((float)(v788 * v788) * v788) * *(float *)(st + 266448))
                              + (float)(v788 * *(float *)(st + 266432));
      if ( v789 >= -1.0 )
        v790 = fminf(v789, 1.0);
      else
        v790 = -1.0;
      v791 = *(float *)(st + 266208);
      v792 = (float)((float)(v787 + *(float *)(st + 266192)) * *(float *)(st + 266352)) * *(float *)(st + 266416);
      *(float *)(st + 266256) = (float)((float)((float)(v790 * v790) * v790) * *(float *)(st + 266448))
                              + (float)(v790 * *(float *)(st + 266432));
      if ( v792 >= -1.0 )
        v793 = fminf(v792, 1.0);
      else
        v793 = -1.0;
      v794 = *(float *)(st + 266224);
      v795 = (float)((float)(v791 * *(float *)(st + 266384)) + (float)(*(float *)(st + 266368) * *(float *)(st + 266192)))
           * *(float *)(st + 266416);
      *(float *)(st + 266288) = (float)((float)((float)(v793 * v793) * v793) * *(float *)(st + 266448))
                              + (float)(v793 * *(float *)(st + 266432));
      if ( v795 >= -1.0 )
        v51 = fminf(v795, 1.0);
      v796 = *(float *)(st + 266304);
      v797 = (float)((float)(v794 + *(float *)(st + 266336)) * *(float *)(st + 266464))
           + (float)(*(float *)(st + 266256) * *(float *)(st + 266480));
      v798 = (float)((float)((float)(v51 * v51) * v51) * *(float *)(st + 266448))
           + (float)(v51 * *(float *)(st + 266432));
      *(float *)(st + 266320) = v798;
      v799 = (float)((float)((float)(*(float *)(st + 266288) + *(float *)(st + 266272)) * *(float *)(st + 266496))
                   + (float)((float)(v796 * *(float *)(st + 266480)) + v797))
           + (float)((float)(v798 + *(float *)(st + 266240)) * *(float *)(st + 266512));
      *(float *)(st + 265616) = v799;
      v800 = (float)((float)(v785 * *(float *)(st + 266000)) + (float)(v799 * *(float *)(st + 265984)))
           + (float)(*(float *)(st + 266016) * *(float *)(st + 265648));
      *(float *)(st + 265632) = v800;
      v801 = (float)(v800 * *(float *)(st + 265680)) * *(float *)(st + 265696);
      *(float *)(st + 265472) = v801;
      *(float *)(st + 265488) = v801;
      *(_DWORD *)(st + 266576) = *(_DWORD *)(st + 266560);
      *(_DWORD *)(st + 266560) = *(_DWORD *)(st + 266544);
      *(_DWORD *)(st + 266544) = *(_DWORD *)(st + 266528);
      *(float *)(st + 266528) = v801;
      v802 = *(float *)(st + 266608);
      v803 = (float)((float)(*(float *)(st + 266544) * *(float *)(st + 266640)) + (float)(v801 * *(float *)(st + 266624)))
           + (float)(*(float *)(st + 266656) * *(float *)(st + 266560));
      v804 = (float)((float)(*(float *)(st + 266544) * *(float *)(st + 266688)) + (float)(v801 * *(float *)(st + 266672)))
           + (float)(*(float *)(st + 266704) * *(float *)(st + 266576));
      if ( v802 <= 0.0 )
        v805 = 0.0;
      else
        v805 = v802;
      v806 = v805;
      *(float *)(st + 266544) = v803;
      *(float *)(st + 266560) = v804;
      v807 = (float)((float)(v806 * v803) - (float)(v806 * v801)) + v801;
      if ( v802 < -0.0 )
        v49 = (float)-v802;
      v808 = v49;
      v809 = v801 + (float)((float)(v808 * v804) - (float)(v808 * v801));
      if ( v802 >= 0.0 )
        v809 = v807;
      *(float *)(st + 266592) = v809;
      *(float *)(st + 129760) = v809;
      v542 = *(_DWORD *)(st + 266592);
      goto LABEL_355;
    case 4:
      v657 = *(float *)(st + 129632);
      v658 = *(float *)(st + 129616);
      v659 = *(float *)(st + 129648);
      *(_DWORD *)(st + 266864) = *(_DWORD *)(st + 266848);
      *(_DWORD *)(st + 266848) = *(_DWORD *)(st + 266832);
      *(_DWORD *)(st + 266832) = *(_DWORD *)(st + 266816);
      *(_DWORD *)(st + 266816) = *(_DWORD *)(st + 266800);
      *(_DWORD *)(st + 266896) = *(_DWORD *)(st + 266880);
      *(_DWORD *)(st + 266928) = *(_DWORD *)(st + 266912);
      *(_DWORD *)(st + 267088) = *(_DWORD *)(st + 267072);
      *(_DWORD *)(st + 267072) = *(_DWORD *)(st + 267056);
      *(_DWORD *)(st + 267056) = *(_DWORD *)(st + 267040);
      *(_DWORD *)(st + 267040) = *(_DWORD *)(st + 267024);
      *(_DWORD *)(st + 267024) = *(_DWORD *)(st + 267008);
      *(_DWORD *)(st + 267008) = *(_DWORD *)(st + 266992);
      *(_DWORD *)(st + 266992) = *(_DWORD *)(st + 266976);
      *(_DWORD *)(st + 266976) = *(_DWORD *)(st + 266960);
      *(_DWORD *)(st + 266960) = *(_DWORD *)(st + 266944);
      *(_DWORD *)(st + 267120) = *(_DWORD *)(st + 267104);
      *(_DWORD *)(st + 267232) = *(_DWORD *)(st + 267216);
      *(_DWORD *)(st + 267216) = *(_DWORD *)(st + 267200);
      *(_DWORD *)(st + 267200) = *(_DWORD *)(st + 267184);
      *(_DWORD *)(st + 267184) = *(_DWORD *)(st + 267168);
      *(_DWORD *)(st + 267168) = *(_DWORD *)(st + 267152);
      *(_DWORD *)(st + 267152) = *(_DWORD *)(st + 267136);
      *(float *)(st + 266720) = v658;
      *(float *)(st + 266736) = v658;
      if ( v657 >= -1.0 )
        v660 = fminf(v657, 1.0);
      else
        v660 = -1.0;
      v661 = v660 * *(float *)(st + 267376);
      if ( v659 >= -1.0 )
        v51 = fminf(v659, 1.0);
      *(float *)(st + 267248) = 1.0
                              / (float)((float)((float)((float)(v51 * *(float *)(st + 267392)) + v661)
                                              + *(float *)(st + 267360))
                                      + 1.0);
      v662 = v658 + *(float *)(st + 266720);
      v663 = *(float *)(st + 266816);
      v664 = *(float *)(st + 266832);
      v665 = v662 * *(float *)(st + 267408);
      *(float *)(st + 266800) = v662;
      v666 = *(float *)(st + 266848);
      v667 = *(float *)(st + 266864);
      v668 = v665 + (float)((float)(v664 * *(float *)(st + 267440)) + (float)(v663 * *(float *)(st + 267424)));
      *(float *)(st + 266816) = v668;
      v669 = v666 * *(float *)(st + 267520);
      v670 = *(float *)(st + 267280);
      *(float *)(st + 266752) = v662 * 0.5;
      v671 = v666 + (float)(v670 * (float)(v668 + (float)(v669 - v667)));
      *(float *)(st + 266832) = v671;
      v672 = (float)(v670 * v671) + v667;
      *(float *)(st + 266848) = v672;
      v673 = fabs(v672) - *(float *)(st + 267536);
      if ( v672 < 0.0 )
        v674 = *(float *)(st + 267600);
      else
        v674 = *(float *)(st + 267584);
      if ( v673 >= 0.0 )
        v675 = (float)(v672 * *(float *)(st + 267568)) + v674;
      else
        v675 = v672 * *(float *)(st + 267552);
      *(float *)(st + 266912) = v675;
      v676 = *(float *)(st + 267712);
      v677 = *(float *)(st + 267728);
      v678 = *(float *)(st + 266928);
      v679 = (int)(float)((float)(32.0 - v676) - v677);
      v680 = (int)jx_h_39A250(v675, v679);
      v681 = jx_h_39A250((float)v680, (int)(float)((float)(v677 + v676) - 32.0));
      v682 = *(float *)(st + 268208) * *(float *)(st + 266960);
      v683 = jx_h_39A250((float)(v678 * *(float *)(st + 267872)) + (float)(v675 * *(float *)(st + 267856)), v679);
      v684 = *(float *)(st + 266976);
      *(float *)(st + 266944) = v681;
      v685 = (float)((float)(v684 * *(float *)(st + 268336)) + (float)(v681 * *(float *)(st + 268080))) + v682;
      v686 = jx_h_39A250(
               (float)(int)v683,
               (int)(float)((float)(*(float *)(st + 267712) + *(float *)(st + 267728)) - 32.0));
      v687 = v675 * *(float *)(st + 267888);
      v688 = v678 * *(float *)(st + 267904);
      *(float *)(st + 266976) = v686;
      v689 = *(float *)(st + 267712);
      v690 = *(float *)(st + 267728);
      v691 = (int)(float)((float)(32.0 - v689) - v690);
      v692 = (int)jx_h_39A250(v688 + v687, v691);
      v693 = jx_h_39A250((float)v692, (int)(float)((float)(v690 + v689) - 32.0));
      v694 = (float)((float)(v686 * *(float *)(st + 268096)) + v685)
           + (float)(*(float *)(st + 268224) * *(float *)(st + 266992));
      v695 = (int)jx_h_39A250((float)(v678 * *(float *)(st + 267936)) + (float)(v675 * *(float *)(st + 267920)), v691);
      v696 = *(float *)(st + 267008);
      *(float *)(st + 266992) = v693;
      v697 = v694 + (float)((float)(v696 * *(float *)(st + 268240)) + (float)(v693 * *(float *)(st + 268112)));
      v698 = jx_h_39A250((float)v695, (int)(float)((float)(*(float *)(st + 267712) + *(float *)(st + 267728)) - 32.0));
      v699 = v675 * *(float *)(st + 267952);
      v700 = v678 * *(float *)(st + 267968);
      *(float *)(st + 267008) = v698;
      v701 = *(float *)(st + 267712);
      v702 = *(float *)(st + 267728);
      v703 = (int)(float)((float)(32.0 - v701) - v702);
      v704 = (int)jx_h_39A250(v700 + v699, v703);
      v705 = jx_h_39A250((float)v704, (int)(float)((float)(v702 + v701) - 32.0));
      v706 = (float)((float)(v698 * *(float *)(st + 268128)) + v697)
           + (float)(*(float *)(st + 268256) * *(float *)(st + 267024));
      v707 = jx_h_39A250((float)(v678 * *(float *)(st + 268000)) + (float)(v675 * *(float *)(st + 267984)), v703);
      v708 = *(float *)(st + 267040);
      *(float *)(st + 267024) = v705;
      v709 = v706 + (float)((float)(v708 * *(float *)(st + 268272)) + (float)(v705 * *(float *)(st + 268144)));
      v710 = jx_h_39A250(
               (float)(int)v707,
               (int)(float)((float)(*(float *)(st + 267712) + *(float *)(st + 267728)) - 32.0));
      v711 = v675 * *(float *)(st + 268016);
      v712 = v678 * *(float *)(st + 268032);
      *(float *)(st + 267040) = v710;
      v713 = *(float *)(st + 267712);
      v714 = *(float *)(st + 267728);
      v715 = v712 + v711;
      v716 = (float)(32.0 - v713) - v714;
      v717 = (int)jx_h_39A250(v715, (int)v716);
      v718 = jx_h_39A250((float)v717, (int)(float)((float)(v714 + v713) - 32.0));
      v719 = (float)((float)(v710 * *(float *)(st + 268160)) + v709)
           + (float)(*(float *)(st + 268288) * *(float *)(st + 267056));
      v720 = jx_h_39A250((float)(v678 * *(float *)(st + 268064)) + (float)(v675 * *(float *)(st + 268048)), (int)v716);
      v721 = *(float *)(st + 267072);
      *(float *)(st + 267056) = v718;
      v722 = v719 + (float)((float)(v721 * *(float *)(st + 268304)) + (float)(v718 * *(float *)(st + 268176)));
      v723 = jx_h_39A250(
               (float)(int)v720,
               (int)(float)((float)(*(float *)(st + 267712) + *(float *)(st + 267728)) - 32.0));
      v724 = *(float *)(st + 267088);
      *(float *)(st + 267072) = v723;
      v725 = *(float *)(st + 267120);
      v726 = (float)(*(float *)(st + 267296) * *(float *)(st + 267248)) + *(float *)(st + 266896);
      v727 = (float)((float)((float)((float)(v724 * *(float *)(st + 268320)) + (float)(v723 * *(float *)(st + 268192)))
                           + v722)
                   * *(float *)(st + 267744))
           - v725;
      *(float *)(st + 267104) = (float)(v727 * *(float *)(st + 267504)) + v725;
      v730 = jx_h_3A2180(0.0f)/*ARGLESS2*/;
      *(_DWORD *)(st + 266880) = LODWORD(v730);
      if ( v726 < 1.0 )
        v727 = *(float *)(st + 267152);
      v731 = *(float *)(st + 267168) * *(float *)(st + 267488);
      v732 = *(float *)(st + 267152) * *(float *)(st + 267472);
      *(float *)(st + 267136) = v727;
      v733 = (float)(v727 * *(float *)(st + 267456)) + (float)(v731 + v732);
      *(float *)(st + 267152) = v733;
      v734 = fabs(v733) - *(float *)(st + 267616);
      if ( v733 < 0.0 )
        v735 = *(float *)(st + 267680);
      else
        v735 = *(float *)(st + 267664);
      if ( v734 >= 0.0 )
        v736 = (float)(v733 * *(float *)(st + 267648)) + v735;
      else
        v736 = v733 * *(float *)(st + 267632);
      v737 = *(float *)(st + 267200);
      v738 = *(float *)(st + 267280);
      v739 = (float)((float)((float)((float)(*(float *)(st + 267184) * *(float *)(st + 267520)) - v737) + v736) * v738)
           + *(float *)(st + 267184);
      *(float *)(st + 267168) = v739;
      v740 = *(float *)(st + 267216);
      v741 = (float)(v738 * v739) + v737;
      v742 = v737 * *(float *)(st + 267776);
      *(float *)(st + 267184) = v741;
      v743 = (float)((float)(v740 * *(float *)(st + 267792)) + (float)(v741 * *(float *)(st + 267760))) + v742;
      *(float *)(st + 267200) = v743;
      v744 = (float)((float)(*(float *)(st + 267840) * *(float *)(st + 267232)) + (float)(v740 * *(float *)(st + 267824)))
           + (float)(v743 * *(float *)(st + 267808));
      *(float *)(st + 267216) = v744;
      v745 = *(float *)(st + 267328) * (float)(v744 * *(float *)(st + 267312));
      v746 = *(float *)(st + 267344);
      v747 = v746
           * (float)((float)(v745 - (float)(*(float *)(st + 267328) * *(float *)(st + 266752))) + *(float *)(st + 266752));
      v748 = *(float *)(st + 266736) + (float)(v747 - (float)(v746 * *(float *)(st + 266736)));
      v749 = *(float *)(st + 266720) + (float)(v747 - (float)(v746 * *(float *)(st + 266720)));
      v750 = *(float *)(st + 267264);
      *(float *)(st + 266768) = v750 * v749;
      *(float *)(st + 266784) = v750 * v748;
      *(_DWORD *)(st + 129760) = *(_DWORD *)(st + 266768);
      v542 = *(_DWORD *)(st + 266784);
      goto LABEL_355;
  }
  if ( *v490 != 5 )
  {
    v492 = *(float *)(st + 129616);
    *(_DWORD *)(st + 130240) = *(_DWORD *)(st + 130224);
    *(_DWORD *)(st + 130224) = *(_DWORD *)(st + 130208);
    *(_DWORD *)(st + 130208) = *(_DWORD *)(st + 130192);
    *(_DWORD *)(st + 130192) = *(_DWORD *)(st + 130176);
    *(_DWORD *)(st + 130176) = *(_DWORD *)(st + 130160);
    *(_DWORD *)(st + 130160) = *(_DWORD *)(st + 130144);
    *(_DWORD *)(st + 130144) = *(_DWORD *)(st + 130128);
    *(_DWORD *)(st + 130128) = *(_DWORD *)(st + 130112);
    *(_DWORD *)(st + 130272) = *(_DWORD *)(st + 130256);
    *(_DWORD *)(st + 130752) = *(_DWORD *)(st + 130736);
    *(_DWORD *)(st + 130784) = *(_DWORD *)(st + 130768);
    *(_DWORD *)(st + 130816) = *(_DWORD *)(st + 130800);
    *(_DWORD *)(st + 130848) = *(_DWORD *)(st + 130832);
    *(_DWORD *)(st + 130880) = *(_DWORD *)(st + 130864);
    *(float *)(st + 130048) = v492;
    *(float *)(st + 130064) = v492;
    v493 = *(float *)(st + 130288);
    v494 = *(float *)(st + 130512);
    v495 = *(float *)(st + 130128);
    v496 = (float)(v492 + v492) * *(float *)(st + 130352);
    v497 = (float)(v493 * *(float *)(st + 130480)) + *(float *)(st + 130464);
    v498 = fminf(*(float *)(st + 130720) + *(float *)(st + 130272), *(float *)(st + 130336));
    v499 = (float)(v493 * v493) * v493;
    v500 = (float)(v493 * v493) * *(float *)(st + 130496);
    *(float *)(st + 130112) = v496;
    v501 = v495 * *(float *)(st + 130384);
    v502 = v496 * *(float *)(st + 130368);
    v503 = *(float *)(st + 130144);
    v504 = *(float *)(st + 130160);
    *(float *)(st + 130256) = v498;
    v505 = v504 * *(float *)(st + 130448);
    v506 = (float)(v501 + v502) + (float)(v503 * *(float *)(st + 130400));
    *(float *)(st + 130128) = v506;
    v507 = (float)((float)(v503 * *(float *)(st + 130432)) + (float)(v506 * *(float *)(st + 130416))) + v505;
    *(float *)(st + 130144) = v507;
    v508 = *(float *)(st + 130192);
    v509 = *(float *)(st + 130320);
    v510 = (float)((float)((float)((float)((float)(v494 * v499) + (float)(v497 + v500)) + *(float *)(st + 130528)) * v507)
                 + (float)(v506 * *(float *)(st + 130544)))
         - v508;
    *(float *)(st + 130160) = v510;
    *(float *)(st + 130176) = (float)(v510 * *(float *)(st + 130560)) + v508;
    v511 = *(float *)(st + 130128);
    v512 = (float)((float)(v498 * *(float *)(st + 130576)) * 0.125) + (float)(v509 * v510);
    *(float *)(st + 130736) = v512;
    v513 = *(float *)(st + 130944);
    v514 = *(float *)(st + 130752);
    if ( (float)(v512 * v513) >= -1.0 )
      v515 = fminf(v512 * v513, 1.0);
    else
      v515 = -1.0;
    v516 = (float)((float)(v512 * *(float *)(st + 130928)) + (float)(v514 * *(float *)(st + 130912))) * v513;
    *(float *)(st + 130768) = (float)((float)((float)(v515 * v515) * v515) * *(float *)(st + 130976))
                            + (float)(v515 * *(float *)(st + 130960));
    if ( v516 >= -1.0 )
      v517 = fminf(v516, 1.0);
    else
      v517 = -1.0;
    v518 = *(float *)(st + 130752);
    v519 = (float)((float)(v514 + *(float *)(st + 130736)) * *(float *)(st + 130896)) * *(float *)(st + 130944);
    *(float *)(st + 130800) = (float)((float)((float)(v517 * v517) * v517) * *(float *)(st + 130976))
                            + (float)(v517 * *(float *)(st + 130960));
    if ( v519 >= -1.0 )
      v520 = fminf(v519, 1.0);
    else
      v520 = -1.0;
    v521 = (float)(*(float *)(st + 130736) * *(float *)(st + 130912)) + (float)(v518 * *(float *)(st + 130928));
    v522 = *(float *)(st + 130768);
    v523 = v521 * *(float *)(st + 130944);
    *(float *)(st + 130832) = (float)((float)((float)(v520 * v520) * v520) * *(float *)(st + 130976))
                            + (float)(v520 * *(float *)(st + 130960));
    if ( v523 >= -1.0 )
      v51 = fminf(v523, 1.0);
    v524 = *(float *)(st + 130848);
    v525 = (float)((float)(v522 + *(float *)(st + 130880)) * *(float *)(st + 130992))
         + (float)(*(float *)(st + 131008) * *(float *)(st + 130800));
    v526 = (float)((float)((float)(v51 * v51) * v51) * *(float *)(st + 130976)) + (float)(v51 * *(float *)(st + 130960));
    *(float *)(st + 130864) = v526;
    v527 = (float)(v524 * *(float *)(st + 131008)) + v525;
    v528 = *(float *)(st + 130208);
    v529 = (float)((float)((float)((float)((float)(*(float *)(st + 130832) + *(float *)(st + 130816))
                                         * *(float *)(st + 131024))
                                 + v527)
                         + (float)((float)(v526 + *(float *)(st + 130784)) * *(float *)(st + 131040)))
                 * *(float *)(st + 130592))
         + (float)(v511 * *(float *)(st + 130608));
    *(float *)(st + 130192) = v529;
    v530 = *(float *)(st + 130224);
    v531 = (float)((float)(v528 * *(float *)(st + 130640)) + (float)(v529 * *(float *)(st + 130624)))
         + (float)(v530 * *(float *)(st + 130656));
    *(float *)(st + 130208) = v531;
    v532 = (float)((float)(v531 * *(float *)(st + 130672)) + (float)(v530 * *(float *)(st + 130688)))
         + (float)(*(float *)(st + 130704) * *(float *)(st + 130240));
    *(float *)(st + 130224) = v532;
    v533 = (float)(v532 * *(float *)(st + 130304)) * *(float *)(st + 130320);
    *(float *)(st + 130080) = v533;
    *(float *)(st + 130096) = v533;
    *(_DWORD *)(st + 131104) = *(_DWORD *)(st + 131088);
    *(_DWORD *)(st + 131088) = *(_DWORD *)(st + 0x20000);
    *(_DWORD *)(st + 0x20000) = *(_DWORD *)(st + 131056);
    *(float *)(st + 131056) = v533;
    v534 = *(float *)(st + 131136);
    v535 = (float)((float)(*(float *)(st + 0x20000) * *(float *)(st + 131168)) + (float)(v533 * *(float *)(st + 131152)))
         + (float)(*(float *)(st + 131184) * *(float *)(st + 131088));
    v536 = (float)((float)(*(float *)(st + 0x20000) * *(float *)(st + 131216)) + (float)(v533 * *(float *)(st + 131200)))
         + (float)(*(float *)(st + 131232) * *(float *)(st + 131104));
    if ( v534 <= 0.0 )
      v537 = 0.0;
    else
      v537 = v534;
    v538 = v537;
    *(float *)(st + 0x20000) = v535;
    *(float *)(st + 131088) = v536;
    v539 = (float)((float)(v538 * v535) - (float)(v538 * v533)) + v533;
    if ( v534 < -0.0 )
      v49 = (float)-v534;
    v540 = v49;
    v541 = v533 + (float)((float)(v540 * v536) - (float)(v540 * v533));
    if ( v534 >= 0.0 )
      v541 = v539;
    *(float *)(st + 131120) = v541;
    *(float *)(st + 129760) = v541;
    v542 = *(_DWORD *)(st + 131120);
LABEL_355:
    *(_DWORD *)(st + 129792) = v542;
    *(_DWORD *)(st + 129824) = 0;
    goto LABEL_356;
  }
  v543 = *(_DWORD *)(st + 268368);
  *(_DWORD *)(st + 268384) = *(_DWORD *)(st + 268352);
  *(_DWORD *)(st + 268400) = v543;
  v544 = jx_h_3A2010(0.0)/*ARGLESS*/;
  *(float *)(st + 268416) = fmaxf(fminf(v544, 512.0), -512.0);
  v545 = *(float *)(st + 268640);
  *(float *)(st + 268656) = v545;
  v546 = *(float *)(st + 268416);
  v547 = *(float *)(st + 268672);
  *(float *)(st + 268688) = v547;
  v548 = v546 * *(float *)(st + 268720);
  if ( v548 < 4.0 )
  {
    if ( v548 >= 2.0 )
      v548 = v548 + -2.0;
  }
  else
  {
    v548 = v548 + -4.0;
  }
  if ( v548 == 0.0 )
    v548 = *(float *)(st + 268736);
  v549 = v547 + v548;
  if ( v549 > 1.0 )
    v549 = fmodf(v549 + 1.0, 2.0) - 1.0;
  v550 = jx_h_3A2210(0.0f)/*ARGLESS*/;
  *(float *)(st + 268704) = v550;
  *(float *)(st + 268672) = (float)(v549 * v545) + (float)(v545 - 1.0);
  *(float *)(st + 268752) = (float)(v550 * *(float *)(st + 268768)) + *(float *)(st + 268784);
  v551 = *(float *)(st + 129632);
  v552 = *(float *)(st + 129616);
  *(_DWORD *)(st + 269056) = *(_DWORD *)(st + 269040);
  *(_DWORD *)(st + 269040) = *(_DWORD *)(st + 269024);
  *(_DWORD *)(st + 269024) = *(_DWORD *)(st + 269008);
  *(_DWORD *)(st + 269008) = *(_DWORD *)(st + 268992);
  *(_DWORD *)(st + 268992) = *(_DWORD *)(st + 268976);
  *(_DWORD *)(st + 268976) = *(_DWORD *)(st + 268960);
  *(_DWORD *)(st + 268960) = *(_DWORD *)(st + 268944);
  *(_DWORD *)(st + 268944) = *(_DWORD *)(st + 268928);
  *(_DWORD *)(st + 268928) = *(_DWORD *)(st + 268912);
  *(_DWORD *)(st + 268912) = *(_DWORD *)(st + 268896);
  *(_DWORD *)(st + 268896) = *(_DWORD *)(st + 268880);
  *(_DWORD *)(st + 268880) = *(_DWORD *)(st + 268864);
  *(_DWORD *)(st + 268864) = *(_DWORD *)(st + 268848);
  *(_DWORD *)(st + 268848) = *(_DWORD *)(st + 268832);
  *(_DWORD *)(st + 268832) = *(_DWORD *)(st + 268816);
  *(_DWORD *)(st + 268816) = *(_DWORD *)(st + 268800);
  *(_DWORD *)(st + 269328) = *(_DWORD *)(st + 269312);
  *(_DWORD *)(st + 269312) = *(_DWORD *)(st + 269296);
  *(_DWORD *)(st + 269296) = *(_DWORD *)(st + 269280);
  *(_DWORD *)(st + 269280) = *(_DWORD *)(st + 269264);
  *(_DWORD *)(st + 269264) = *(_DWORD *)(st + 269248);
  *(_DWORD *)(st + 269248) = *(_DWORD *)(st + 269232);
  *(_DWORD *)(st + 269232) = *(_DWORD *)(st + 269216);
  *(_DWORD *)(st + 269216) = *(_DWORD *)(st + 269200);
  *(_DWORD *)(st + 269200) = *(_DWORD *)(st + 269184);
  *(_DWORD *)(st + 269184) = *(_DWORD *)(st + 269168);
  *(_DWORD *)(st + 269168) = *(_DWORD *)(st + 269152);
  *(_DWORD *)(st + 269152) = *(_DWORD *)(st + 269136);
  *(_DWORD *)(st + 269136) = *(_DWORD *)(st + 269120);
  *(_DWORD *)(st + 269120) = *(_DWORD *)(st + 269104);
  *(_DWORD *)(st + 269104) = *(_DWORD *)(st + 269088);
  *(_DWORD *)(st + 269088) = *(_DWORD *)(st + 269072);
  *(_DWORD *)(st + 269360) = *(_DWORD *)(st + 269344);
  *(float *)(st + 269376) = v552;
  *(float *)(st + 269392) = v552;
  v553 = v552 * *(float *)(st + 269472);
  v554 = (float)((float)(v551 * *(float *)(st + 269440)) - *(float *)(st + 129648)) - 1.0;
  if ( v554 >= -1.0 )
    v51 = fminf(v554, 1.0);
  v555 = *(float *)(st + 269632);
  v556 = *(float *)(st + 269200) * v555;
  v557 = *(float *)(st + 268928) * v555;
  v558 = (float)((float)(1.0 - (float)((float)((float)(v51 * v51) * *(float *)(st + 269680)) + *(float *)(st + 269360)))
               * *(float *)(st + 269664))
       + *(float *)(st + 269360);
  *(float *)(st + 269344) = v558;
  v559 = *(float *)(st + 269648);
  v560 = *(float *)(st + 269456);
  v561 = (float)(v559 * *(float *)(st + 269328)) + v556;
  v562 = (float)(v559 * *(float *)(st + 269056)) + v557;
  v563 = *(float *)(st + 269520);
  v564 = (float)(v553 + (float)(v560 * (float)(v561 * v563))) * v563;
  v565 = (float)(v553 + (float)(v560 * (float)(v562 * v563))) * v563;
  *(float *)(st + 268800) = v565;
  *(float *)(st + 269072) = v564;
  v566 = *(float *)(st + 268832);
  v567 = *(float *)(st + 269104);
  v568 = (float)((float)(v558 * v565) - *(float *)(st + 268816)) + (float)(v558 * v566);
  v569 = (float)((float)(v558 * v564) - *(float *)(st + 269088)) + (float)(v558 * v567);
  *(float *)(st + 268816) = v568;
  *(float *)(st + 269088) = v569;
  v570 = (float)(v558 * v568) - v566;
  v571 = *(float *)(st + 268848);
  v572 = (float)(v558 * v569) - v567;
  v573 = *(float *)(st + 269120);
  v574 = v570 + (float)(v558 * v571);
  v575 = v572 + (float)(v558 * v573);
  *(float *)(st + 268832) = v574;
  *(float *)(st + 269104) = v575;
  v576 = (float)(v558 * v574) - v571;
  v577 = *(float *)(st + 268864);
  v578 = (float)(v558 * v575) - v573;
  v579 = *(float *)(st + 269136);
  v580 = v576 + (float)(v558 * v577);
  v581 = v578 + (float)(v558 * v579);
  *(float *)(st + 268848) = v580;
  *(float *)(st + 269120) = v581;
  v582 = (float)(v558 * v580) - v577;
  v583 = *(float *)(st + 268880);
  v584 = (float)(v558 * v581) - v579;
  v585 = *(float *)(st + 269152);
  v586 = v582 + (float)(v558 * v583);
  v587 = v584 + (float)(v558 * v585);
  *(float *)(st + 268864) = v586;
  *(float *)(st + 269136) = v587;
  v588 = (float)(v558 * v586) - v583;
  v589 = *(float *)(st + 268896);
  v590 = (float)(v558 * v587) - v585;
  v591 = *(float *)(st + 269168);
  v592 = v588 + (float)(v558 * v589);
  v593 = v590 + (float)(v558 * v591);
  *(float *)(st + 268880) = v592;
  v594 = v558 * v592;
  *(float *)(st + 269152) = v593;
  v595 = *(float *)(st + 269184);
  v596 = v594 - v589;
  v597 = *(float *)(st + 268912);
  v598 = v596 + (float)(v558 * v597);
  v599 = (float)((float)(v558 * v593) - v591) + (float)(v558 * v595);
  *(float *)(st + 268896) = v598;
  *(float *)(st + 269168) = v599;
  v600 = *(float *)(st + 269712);
  v601 = v600 * v595;
  v602 = *(float *)(st + 269600);
  v603 = (float)((float)(*(float *)(st + 269696) * v599) + v601)
       + (float)(*(float *)(st + 269728) * *(float *)(st + 269200));
  *(float *)(st + 268912) = (float)((float)(*(float *)(st + 269696) * v598) + (float)(v600 * v597))
                          + (float)(*(float *)(st + 269728) * *(float *)(st + 268928));
  *(float *)(st + 269184) = v603;
  v604 = *(float *)(st + 269520);
  v605 = (float)((float)(v602 * *(float *)(st + 268800)) + (float)(*(float *)(st + 269616) * *(float *)(st + 268896)))
       + (float)(*(float *)(st + 269456) * (float)((float)(*(float *)(st + 269632) * *(float *)(st + 269056)) * v604));
  v606 = (float)((float)(v602 * *(float *)(st + 269072)) + (float)(*(float *)(st + 269616) * *(float *)(st + 269168)))
       + (float)(*(float *)(st + 269456) * (float)((float)(*(float *)(st + 269632) * *(float *)(st + 269328)) * v604));
  *(float *)(st + 268928) = v605;
  *(float *)(st + 269200) = v606;
  v607 = *(float *)(st + 268960);
  v608 = *(float *)(st + 269232);
  v609 = (float)((float)(v558 * v605) - *(float *)(st + 268944)) + (float)(v558 * v607);
  v610 = (float)((float)(v558 * v606) - *(float *)(st + 269216)) + (float)(v558 * v608);
  *(float *)(st + 268944) = v609;
  *(float *)(st + 269216) = v610;
  v611 = (float)(v558 * v609) - v607;
  v612 = *(float *)(st + 268976);
  v613 = (float)(v558 * v610) - v608;
  v614 = *(float *)(st + 269248);
  v615 = v611 + (float)(v558 * v612);
  v616 = v613 + (float)(v558 * v614);
  *(float *)(st + 268960) = v615;
  *(float *)(st + 269232) = v616;
  v617 = (float)(v558 * v615) - v612;
  v618 = *(float *)(st + 268992);
  v619 = (float)(v558 * v616) - v614;
  v620 = *(float *)(st + 269264);
  v621 = v617 + (float)(v558 * v618);
  v622 = v619 + (float)(v558 * v620);
  *(float *)(st + 268976) = v621;
  *(float *)(st + 269248) = v622;
  v623 = (float)(v558 * v621) - v618;
  v624 = *(float *)(st + 269008);
  v625 = (float)(v558 * v622) - v620;
  v626 = *(float *)(st + 269280);
  v627 = v623 + (float)(v558 * v624);
  v628 = v625 + (float)(v558 * v626);
  *(float *)(st + 268992) = v627;
  *(float *)(st + 269264) = v628;
  v629 = (float)(v558 * v627) - v624;
  v630 = *(float *)(st + 269024);
  v631 = (float)(v558 * v628) - v626;
  v632 = *(float *)(st + 269296);
  v633 = v629 + (float)(v558 * v630);
  v634 = v631 + (float)(v558 * v632);
  *(float *)(st + 269008) = v633;
  v635 = v558 * v633;
  *(float *)(st + 269280) = v634;
  v636 = *(float *)(st + 269040);
  v637 = *(float *)(st + 269312);
  v638 = (float)(v635 - v630) + (float)(v558 * v636);
  *(float *)(st + 269024) = v638;
  v639 = (float)((float)(v558 * v634) - v632) + (float)(v558 * v637);
  *(float *)(st + 269296) = v639;
  v640 = *(float *)(st + 269712) * v637;
  v641 = *(float *)(st + 269536);
  v642 = *(float *)(st + 269696) * v638;
  v643 = v641;
  v644 = (float)((float)(*(float *)(st + 269696) * v639) + v640)
       + (float)(*(float *)(st + 269728) * *(float *)(st + 269328));
  *(float *)(st + 269040) = (float)(v642 + (float)(*(float *)(st + 269712) * v636))
                          + (float)(*(float *)(st + 269728) * *(float *)(st + 269056));
  *(float *)(st + 269312) = v644;
  v645 = *(float *)(st + 269376);
  v646 = *(float *)(st + 269392);
  v647 = *(float *)(st + 269584);
  v648 = (float)((float)((float)(v641 * *(float *)(st + 269072))
                       + (float)(*(float *)(st + 269552) * *(float *)(st + 269136)))
               + (float)(*(float *)(st + 269568) * *(float *)(st + 269232)))
       + (float)(v647 * *(float *)(st + 269296));
  v649 = (float)((float)((float)((float)(v643 * *(float *)(st + 268800))
                               + (float)(*(float *)(st + 269552) * *(float *)(st + 268864)))
                       + (float)(*(float *)(st + 269568) * *(float *)(st + 268960)))
               + (float)(v647 * *(float *)(st + 269024)))
       + (float)(*(float *)(st + 269600) * *(float *)(st + 268928));
  v650 = *(float *)(st + 269488);
  v651 = v650 * v646;
  v652 = v649 + (float)(v650 * v645);
  v653 = *(float *)(st + 269520);
  v654 = (float)((float)(v648 + (float)(*(float *)(st + 269600) * *(float *)(st + 269200))) + v651) * v653;
  v655 = (float)((float)(*(float *)(st + 269504) * (float)(v652 * v653)) + v645)
       - (float)(*(float *)(st + 269504) * v645);
  v656 = *(float *)(st + 269504);
  *(float *)(st + 269408) = v655;
  *(float *)(st + 269424) = (float)((float)(v656 * v654) + v646) - (float)(v656 * v646);
  *(_DWORD *)(st + 129760) = *(_DWORD *)(st + 269408);
  *(_DWORD *)(st + 129792) = *(_DWORD *)(st + 269424);
  *(_DWORD *)(st + 129824) = *(_DWORD *)(st + 268752);
  v33 = *(_DWORD *)(st + 268400);
LABEL_356:
  *(_DWORD *)(st + 129856) = v33;
  **a3 = *(float *)(st + 269968) + *(float *)(st + 269968);
  result = a3[1];
  *result = *(float *)(st + 269984) + *(float *)(st + 269984);
  return result;
}
