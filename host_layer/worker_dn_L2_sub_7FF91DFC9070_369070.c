// sub_7FF91DFC9070 @ rva 0x369070

__int64 __fastcall sub_7FF91DFC9070(__int64 a1, _DWORD **a2)
{
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
  __m128 v227; // xmm9
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
  double v386; // xmm2_8
  double *v387; // rax
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
  __int64 result; // rax
  int v528; // [rsp+D0h] [rbp+8h]
  float v529; // [rsp+E0h] [rbp+18h]

  v2 = *(float *)(a1 + 320);
  v528 = 0;
  if ( *(float *)(a1 + 101504) == 1.0 )
  {
    v528 = *(_DWORD *)(a1 + 320);
    v2 = 0.0;
    *(_DWORD *)(a1 + 320) = 0;
  }
  v5 = *(float *)(a1 + 84336);
  v6 = *(float *)(a1 + 84272);
  v7 = *(float *)(a1 + 84304);
  *(float *)(a1 + 84352) = v5;
  *(float *)(a1 + 84288) = v6;
  *(float *)(a1 + 84320) = v7;
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
  v11 = *(float *)(a1 + 208);
  v12 = *(float *)(a1 + 176);
  v13 = v9 & 0xFFFFFF;
  v14 = *(float *)(a1 + 368);
  v15 = v9;
  v16 = *(float *)(a1 + 384);
  v17 = v9 | 0xFF000000;
  v18 = v6 * v7;
  *(_DWORD *)(a1 + 432) = 0;
  *(float *)(a1 + 224) = v11;
  v19 = 0.0;
  if ( (v15 & 0x1000000) == 0 )
    v17 = v13;
  *(float *)(a1 + 192) = v12;
  *(_DWORD *)(a1 + 84384) = *(_DWORD *)(a1 + 84368);
  *(_DWORD *)(a1 + 512) = *(_DWORD *)(a1 + 496);
  *(float *)(a1 + 352) = v2;
  v20 = (float)v17 * 0.000000059604645;
  *(float *)(a1 + 400) = v14;
  *(float *)(a1 + 416) = v16;
  *(float *)(a1 + 84336) = v20;
  v21 = (float)(v20 * *(float *)(a1 + 84400)) + *(float *)(a1 + 84416);
  *(float *)(a1 + 84368) = v21;
  v22 = v18 - (float)(v7 * v21);
  v23 = *(float *)(a1 + 272);
  *(float *)(a1 + 288) = v23;
  v24 = v22 + v21;
  v25 = *(float *)(a1 + 240);
  v26 = v23 * v25;
  *(float *)(a1 + 256) = v25;
  *(float *)(a1 + 84432) = v24;
  v27 = *(float *)(a1 + 304);
  *(float *)(a1 + 336) = v27;
  *(float *)(a1 + 448) = v26;
  v28 = (float)((float)(v12 * v26) - (float)(v26 * v27)) + v27;
  v29 = (float)((float)(v11 * v26) - (float)(v2 * v26)) + v2;
  *(float *)(a1 + 464) = v28;
  *(float *)(a1 + 480) = v29;
  v30 = v29;
  v31 = v29 + *(float *)(a1 + 544);
  if ( v31 < 0.0 )
    v32 = v31;
  else
    v32 = 0.0;
  v33 = -1.0;
  if ( v30 == 0.0 )
    v34 = -1.0;
  else
    v34 = v32;
  *(float *)(a1 + 496) = v34;
  if ( v34 >= 0.0 )
  {
    if ( v34 > 0.0 )
      v34 = 1.0;
  }
  else
  {
    v34 = -1.0;
  }
  v35 = *(float *)(a1 + 608);
  v36 = v34 + 1.0;
  v37 = *(float *)(a1 + 768);
  v38 = *(float *)(a1 + 624);
  v39 = *(_DWORD *)(a1 + 560);
  v40 = *(float *)(a1 + 704);
  v41 = v38 + *(float *)(a1 + 784);
  v42 = 1.0;
  *(float *)(a1 + 528) = v36;
  *(float *)(a1 + 560) = v36;
  *(_DWORD *)(a1 + 576) = v39;
  *(float *)(a1 + 720) = v40;
  v43 = (float)(v36 * v35) - v35;
  v44 = *(float *)(a1 + 816);
  v45 = (float)(v43 + 1.0) * *(float *)(a1 + 592);
  v46 = (float)(*(float *)(a1 + 672) / (float)((float)(v37 * v38) + *(float *)(a1 + 800))) * v37;
  v47 = *(float *)(a1 + 656);
  *(float *)(a1 + 736) = v45;
  v48 = v47 - v46;
  v49 = *(float *)(a1 + 688);
  v50 = (float)(v48 + v28) - v40;
  *(float *)(a1 + 656) = v50;
  v51 = v50 * v41;
  *(float *)(a1 + 672) = v51;
  v52 = v51 + v40;
  if ( (float)(v44 - fabs(v40 - v28)) < 0.0 )
  {
    v53 = 0.0;
LABEL_25:
    v54 = v53;
    goto LABEL_26;
  }
  v53 = v49 + *(float *)(a1 + 832);
  if ( v53 < 1.0 )
    goto LABEL_25;
  v54 = 1.0;
LABEL_26:
  v55 = v54;
  *(float *)(a1 + 688) = v55;
  v56 = (float)((float)(v55 * v28) - (float)(v55 * v52)) + v52;
  if ( v45 == 0.0 )
    v56 = v28;
  v57 = v16 * *(float *)(a1 + 864);
  *(_DWORD *)(a1 + 896) = *(_DWORD *)(a1 + 880);
  v58 = *(float *)(a1 + 1168);
  v59 = *(float *)(a1 + 912);
  v60 = *(_DWORD *)(a1 + 1008);
  v61 = v57 + (float)(v14 * *(float *)(a1 + 848));
  v62 = *(_DWORD *)(a1 + 976);
  v63 = (int)v58;
  *(float *)(a1 + 880) = v61;
  v64 = *(float *)(a1 + 944);
  *(float *)(a1 + 704) = v56;
  *(float *)(a1 + 752) = v56;
  v65 = *(float *)(a1 + 1104);
  *(float *)(a1 + 960) = v64;
  *(float *)(a1 + 928) = v59;
  *(_DWORD *)(a1 + 992) = v62;
  *(_DWORD *)(a1 + 1024) = v60;
  *(float *)(a1 + 1120) = v65;
  if ( (int)v58 < -32 )
  {
    v59 = v59 * 2.3283064e-10;
    goto LABEL_38;
  }
  if ( v63 > 32 )
  {
    v63 = 32;
LABEL_37:
    v59 = v59 * dword_7FF91E5EAD3C[v63];
    goto LABEL_38;
  }
  if ( v63 < 0 )
  {
    v59 = v59 * dword_7FF91E5EACC0[~v63];
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
    v59 = v59 * dword_7FF91E5EAD3C[v66];
    goto LABEL_46;
  }
  if ( v66 < 0 )
  {
    v59 = v59 * dword_7FF91E5EACC0[~v66];
    goto LABEL_46;
  }
  if ( v66 > 0 )
    goto LABEL_45;
LABEL_46:
  v67 = *(float *)(a1 + 1040);
  v68 = (float)((float)(v59 - v65) * *(float *)(a1 + 1152)) + v65;
  v69 = *(float *)(a1 + 1088);
  *(float *)(a1 + 1104) = v68;
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
  v74 = *(float *)(a1 + 1056);
  v75 = expf((float)v73 * *(float *)(a1 + 1200)) * *(float *)(a1 + 1184);
  v76 = v74 * *(float *)(a1 + 1072);
  *(_DWORD *)(a1 + 1584) = *(_DWORD *)(a1 + 1568);
  v77 = v75 + *(float *)(a1 + 1216);
  v78 = *(float *)(a1 + 1504);
  v79 = v64 * *(float *)(a1 + 1904);
  *(_DWORD *)(a1 + 1616) = *(_DWORD *)(a1 + 1600);
  v80 = *(float *)(a1 + 1488);
  v81 = *(float *)(a1 + 1536);
  *(_DWORD *)(a1 + 1648) = *(_DWORD *)(a1 + 1632);
  v82 = *(_DWORD *)(a1 + 84432);
  *(float *)(a1 + 1520) = v78;
  *(float *)(a1 + 1504) = v80;
  *(float *)(a1 + 1552) = v81;
  *(_DWORD *)(a1 + 1440) = v62;
  *(_DWORD *)(a1 + 1456) = v60;
  *(_DWORD *)(a1 + 1424) = v82;
  v83 = (float)(v76 - (float)(v74 * v77)) + v77;
  v84 = *(float *)(a1 + 1856);
  v85 = v79 + v84;
  *(float *)(a1 + 1840) = v84;
  *(float *)(a1 + 1136) = v83;
  if ( v85 >= -1.0 )
    v86 = fminf(v85, 1.0);
  else
    v86 = -1.0;
  v87 = *(float *)(a1 + 2128);
  *(float *)(a1 + 1488) = v86;
  v88 = fminf(v87, v83 * 0.000015258789);
  v89 = (float)((float)(1.0 - v78) * *(float *)(a1 + 1920)) + v78;
  if ( v89 >= -1.0 )
    v90 = fminf(v89, 1.0);
  else
    v90 = -1.0;
  v91 = v88 * *(float *)(a1 + 2144);
  v92 = v80 - v86;
  *(float *)(a1 + 1664) = v91;
  v93 = v91 + v81;
  if ( v92 < 0.0 )
    v90 = 0.0;
  v94 = *(float *)(a1 + 1872);
  v95 = *(float *)(a1 + 1424);
  *(float *)(a1 + 1504) = v90;
  v96 = v90 + *(float *)(a1 + 2272);
  if ( v92 >= 0.0 )
    v94 = 1.0;
  v97 = v96 * *(float *)(a1 + 2256);
  v98 = (float)(v93 * v94) * *(float *)(a1 + 1888);
  if ( v97 <= 0.0 )
    v99 = 0.0;
  else
    v99 = v97;
  v100 = v99;
  v101 = (float)((float)(v95 - *(float *)(a1 + 1584)) * *(float *)(a1 + 2464)) + *(float *)(a1 + 1584);
  *(float *)(a1 + 1568) = v101;
  *(float *)(a1 + 1472) = v100;
  v529 = *(float *)(a1 + 1552);
  v102 = (float)((float)((float)(v101 * *(float *)(a1 + 2448)) * *(float *)(a1 + 2064))
               - (float)(v95 * *(float *)(a1 + 2064)))
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
  v103 = *(float *)(a1 + 1616);
  *(float *)(a1 + 1536) = v98;
  v104 = v98 + *(float *)(a1 + 2288);
  *(float *)(a1 + 1408) = v102 * *(float *)(a1 + 2432);
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
  *(float *)(a1 + 1600) = v103;
  v105 = v103 * *(float *)(a1 + 2416);
  v106 = (float)(v104 * *(float *)(a1 + 2352)) + *(float *)(a1 + 2480);
  *(float *)(a1 + 1680) = v106;
  *(float *)(a1 + 1760) = v105;
  v107 = v98 + *(float *)(a1 + 2320);
  *(float *)(a1 + 1696) = -v106;
  if ( v107 <= 1.0 )
  {
    if ( v107 < -1.0 )
      fmodf(v107 - 1.0, 2.0);
  }
  else
  {
    fmodf(v107 + 1.0, 2.0);
  }
  v108 = v98 + *(float *)(a1 + 2304);
  if ( v108 <= 1.0 )
  {
    if ( v108 < -1.0 )
      v108 = fmodf(v108 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v108 = fmodf(v108 + 1.0, 2.0) - 1.0;
  }
  v109 = sub_7FF91DFC8FC0();
  v110 = v108 + *(float *)(a1 + 2496);
  v111 = v109 * *(float *)(a1 + 2384);
  if ( v110 >= 0.0 )
  {
    if ( v110 > 0.0 )
      v110 = 1.0;
  }
  else
  {
    v110 = -1.0;
  }
  v112 = v98 + *(float *)(a1 + 2336);
  *(float *)(a1 + 1728) = v111;
  *(float *)(a1 + 1824) = v110;
  v113 = (float)(v110 * *(float *)(a1 + 2368)) + *(float *)(a1 + 2512);
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
  *(float *)(a1 + 1712) = v113;
  v115 = *(float *)(a1 + 1968);
  v116 = (float)((float)(*(float *)(a1 + 2032) * *(float *)(a1 + 1760))
               + (float)(*(float *)(a1 + 2000) * *(float *)(a1 + 1680)))
       + (float)(*(float *)(a1 + 2016) * *(float *)(a1 + 1696));
  v117 = (float)((float)((float)((float)(v114 * (float)((float)(v114 * v114) * v114)) * *(float *)(a1 + 2224))
                       + (float)((float)((float)((float)(v114 * v114) * v114) * *(float *)(a1 + 2208))
                               + (float)((float)((float)(v114 * *(float *)(a1 + 2176)) + *(float *)(a1 + 2160))
                                       + (float)((float)(v114 * v114) * *(float *)(a1 + 2192)))))
               + *(float *)(a1 + 2240))
       * *(float *)(a1 + 2400);
  *(float *)(a1 + 1744) = v117;
  v118 = (float)(v115 * *(float *)(a1 + 1728)) + v116;
  v119 = *(float *)(a1 + 2080);
  v120 = (float)((float)(*(float *)(a1 + 1936) * *(float *)(a1 + 1472)) - *(float *)(a1 + 1936)) + 1.0;
  v121 = (float)((float)(v118 + (float)(*(float *)(a1 + 1984) * *(float *)(a1 + 1712)))
               + (float)(v117 * *(float *)(a1 + 1952)))
       + (float)(*(float *)(a1 + 2048) * *(float *)(a1 + 1408));
  *(float *)(a1 + 1776) = v120;
  *(float *)(a1 + 1808) = v121;
  *(float *)(a1 + 1792) = (float)((float)(*(float *)(a1 + 2096) * *(float *)(a1 + 1440))
                                + (float)(*(float *)(a1 + 2112) * *(float *)(a1 + 1456)))
                        + (float)((float)(v119 * v120) * v121);
  v122 = *(_DWORD *)(a1 + 1808);
  *(_DWORD *)(a1 + 2528) = *(_DWORD *)(a1 + 1824);
  *(_DWORD *)(a1 + 2544) = v122;
  if ( *(float *)(a1 + 1824) <= 0.0 )
    v123 = 0.0;
  else
    v123 = 1.0;
  if ( *(float *)(a1 + 2560) == 0.0 )
    v123 = 1.0;
  v124 = *(float *)(a1 + 560) * v123;
  *(float *)(a1 + 2576) = v124;
  *(_DWORD *)(a1 + 2608) = *(_DWORD *)(a1 + 2592);
  *(_DWORD *)(a1 + 2656) = *(_DWORD *)(a1 + 2640);
  *(_DWORD *)(a1 + 2640) = *(_DWORD *)(a1 + 2624);
  *(_DWORD *)(a1 + 2688) = *(_DWORD *)(a1 + 2672);
  *(_DWORD *)(a1 + 2736) = *(_DWORD *)(a1 + 2720);
  if ( (float)(v124 + *(float *)(a1 + 2864)) >= 0.0 )
    v125 = 0.0;
  else
    v125 = 1.0;
  v126 = 1.0 - v125;
  v127 = (float)(1.0 - v125) * (float)((float)(*(float *)(a1 + 2896) * *(float *)(a1 + 2656)) + *(float *)(a1 + 2608));
  *(float *)(a1 + 2624) = v127;
  v128 = v127 + *(float *)(a1 + 2880);
  v129 = v127 - *(float *)(a1 + 2640);
  *(float *)(a1 + 2704) = (float)((float)(*(float *)(a1 + 2848) * *(float *)(a1 + 2960))
                                - (float)(*(float *)(a1 + 2928) * *(float *)(a1 + 2848)))
                        + *(float *)(a1 + 2928);
  if ( v128 < 0.0 )
    v130 = 0.0;
  else
    v130 = 1.0;
  if ( v129 < 0.0 )
    v130 = 1.0 - v125;
  v131 = *(float *)(a1 + 2784);
  v132 = v126 * (float)(*(float *)(a1 + 2800) * *(float *)(a1 + 2928));
  *(float *)(a1 + 2640) = v130;
  v133 = *(float *)(a1 + 2688);
  v134 = (float)(v132 - (float)(*(float *)(a1 + 2944) * v126)) + *(float *)(a1 + 2944);
  v135 = v126 * (float)(1.0 - v130);
  v136 = (float)((float)(*(float *)(a1 + 2816) * 0.00390625) * v130) + (float)((float)(v131 * 0.00390625) * v135);
  if ( (float)(v134 - v133) > 0.0 )
    v134 = v133 + *(float *)(a1 + 2704);
  v137 = *(float *)(a1 + 2608);
  v138 = fminf(*(float *)(a1 + 2928), v134);
  *(float *)(a1 + 2672) = v138;
  v139 = *(float *)(a1 + 2832);
  v140 = (float)((float)(v135 * *(float *)(a1 + 2912)) + (float)(v130 * v138)) - v137;
  v141 = (float)((float)(*(float *)(a1 + 2976) * v136) - (float)(*(float *)(a1 + 2976) * *(float *)(a1 + 2736)))
       + *(float *)(a1 + 2736);
  *(float *)(a1 + 2720) = v141;
  v142 = (float)((float)((float)((float)((float)(v139 * 0.00390625) * v125) - (float)(v125 * v141)) + v141) * v140)
       + v137;
  *(float *)(a1 + 2592) = v142;
  v143 = (float)(v142 * *(float *)(a1 + 2992)) * *(float *)(a1 + 3008);
  v144 = v143 * *(float *)(a1 + 3024);
  *(float *)(a1 + 2752) = v143;
  *(float *)(a1 + 2768) = v144;
  if ( *(float *)(a1 + 1824) <= 0.0 )
    v145 = 0.0;
  else
    v145 = 1.0;
  if ( *(float *)(a1 + 3040) == 0.0 )
    v145 = 1.0;
  v146 = *(float *)(a1 + 560) * v145;
  *(float *)(a1 + 3056) = v146;
  *(_DWORD *)(a1 + 3088) = *(_DWORD *)(a1 + 3072);
  *(_DWORD *)(a1 + 3136) = *(_DWORD *)(a1 + 3120);
  *(_DWORD *)(a1 + 3120) = *(_DWORD *)(a1 + 3104);
  *(_DWORD *)(a1 + 3168) = *(_DWORD *)(a1 + 3152);
  *(_DWORD *)(a1 + 3216) = *(_DWORD *)(a1 + 3200);
  if ( (float)(v146 + *(float *)(a1 + 3344)) >= 0.0 )
    v147 = 0.0;
  else
    v147 = 1.0;
  v148 = 1.0 - v147;
  v149 = (float)(1.0 - v147) * (float)((float)(*(float *)(a1 + 3376) * *(float *)(a1 + 3136)) + *(float *)(a1 + 3088));
  *(float *)(a1 + 3104) = v149;
  v150 = v149 + *(float *)(a1 + 3360);
  v151 = v149 - *(float *)(a1 + 3120);
  *(float *)(a1 + 3184) = (float)((float)(*(float *)(a1 + 3328) * *(float *)(a1 + 3440))
                                - (float)(*(float *)(a1 + 3408) * *(float *)(a1 + 3328)))
                        + *(float *)(a1 + 3408);
  if ( v150 < 0.0 )
    v152 = 0.0;
  else
    v152 = 1.0;
  if ( v151 < 0.0 )
    v152 = 1.0 - v147;
  v153 = *(float *)(a1 + 3280) * *(float *)(a1 + 3408);
  v154 = *(float *)(a1 + 3264);
  *(float *)(a1 + 3120) = v152;
  v155 = *(float *)(a1 + 3168);
  v156 = (float)((float)(v148 * v153) - (float)(*(float *)(a1 + 3424) * v148)) + *(float *)(a1 + 3424);
  v157 = v148 * (float)(1.0 - v152);
  v158 = (float)((float)(*(float *)(a1 + 3296) * 0.00390625) * v152) + (float)((float)(v154 * 0.00390625) * v157);
  if ( (float)(v156 - v155) > 0.0 )
    v156 = v155 + *(float *)(a1 + 3184);
  v159 = *(float *)(a1 + 3088);
  v160 = fminf(*(float *)(a1 + 3408), v156);
  *(float *)(a1 + 3152) = v160;
  v161 = (float)(*(float *)(a1 + 3312) * 0.00390625) * v147;
  v162 = (float)((float)(v157 * *(float *)(a1 + 3392)) + (float)(v152 * v160)) - v159;
  v163 = (float)((float)(*(float *)(a1 + 3456) * v158) - (float)(*(float *)(a1 + 3456) * *(float *)(a1 + 3216)))
       + *(float *)(a1 + 3216);
  *(float *)(a1 + 3200) = v163;
  v164 = (float)((float)((float)(v161 - (float)(v147 * v163)) + v163) * v162) + v159;
  *(float *)(a1 + 3072) = v164;
  v165 = (float)(v164 * *(float *)(a1 + 3472)) * *(float *)(a1 + 3488);
  v166 = v165 * *(float *)(a1 + 3504);
  *(float *)(a1 + 3232) = v165;
  *(float *)(a1 + 3248) = v166;
  *(_DWORD *)(a1 + 3536) = *(_DWORD *)(a1 + 3520);
  *(_DWORD *)(a1 + 3568) = *(_DWORD *)(a1 + 3552);
  v167 = *(float *)(a1 + 752);
  v168 = *(float *)(a1 + 880);
  *(_DWORD *)(a1 + 3632) = *(_DWORD *)(a1 + 3616);
  v169 = (float)(v168 * *(float *)(a1 + 3600)) + (float)(v167 * *(float *)(a1 + 3584));
  *(float *)(a1 + 3616) = v169;
  v170 = *(float *)(a1 + 1792);
  v171 = *(_DWORD *)(a1 + 2752);
  v172 = *(_DWORD *)(a1 + 3232);
  v173 = *(_DWORD *)(a1 + 752);
  *(_DWORD *)(a1 + 3680) = *(_DWORD *)(a1 + 3552);
  *(_DWORD *)(a1 + 3696) = v173;
  v174 = *(float *)(a1 + 4016);
  *(_DWORD *)(a1 + 3648) = v171;
  *(_DWORD *)(a1 + 3664) = v172;
  v175 = *(float *)(a1 + 3984);
  v176 = v170 * v174;
  v177 = v174 * *(float *)(a1 + 1808);
  *(float *)(a1 + 3712) = v177;
  v178 = *(float *)(a1 + 4112);
  v179 = *(float *)(a1 + 3856);
  v180 = v176 * *(float *)(a1 + 4032);
  v181 = *(float *)(a1 + 4048);
  v182 = (float)(v175 * v177) * *(float *)(a1 + 4000);
  *(float *)(a1 + 3744) = v182;
  v183 = *(float *)(a1 + 3872);
  v184 = (float)((float)((float)(v179 * *(float *)(a1 + 3680)) - (float)(v178 * v179)) + v178) * *(float *)(a1 + 4128);
  *(float *)(a1 + 3760) = v184;
  v185 = (float)((float)(v181 * v180) + v182) + (float)(v183 * v184);
  v186 = *(float *)(a1 + 3712);
  v187 = *(_DWORD *)(a1 + 3840);
  *(float *)(a1 + 3776) = (float)((float)((float)((float)((float)((float)(*(float *)(a1 + 4080) * *(float *)(a1 + 3664))
                                                                + (float)(*(float *)(a1 + 4064) * *(float *)(a1 + 3648)))
                                                        * *(float *)(a1 + 4096))
                                                + v185)
                                        + v169)
                                + *(float *)(a1 + 3952))
                        + *(float *)(a1 + 3968);
  *(_DWORD *)(a1 + 3792) = v187;
  v188 = (float)(*(float *)(a1 + 3744) + *(float *)(a1 + 3696)) + *(float *)(a1 + 3760);
  *(float *)(a1 + 3808) = (float)((float)((float)((float)((float)((float)(v186 * *(float *)(a1 + 4160))
                                                                + *(float *)(a1 + 4176))
                                                        * *(float *)(a1 + 3888))
                                                + (float)(*(float *)(a1 + 3904) * *(float *)(a1 + 3648)))
                                        + (float)(*(float *)(a1 + 3920) * *(float *)(a1 + 3664)))
                                + *(float *)(a1 + 3936))
                        * *(float *)(a1 + 4144);
  *(float *)(a1 + 3824) = v188;
  v189 = *(_DWORD *)(a1 + 4208);
  *(_DWORD *)(a1 + 4240) = *(_DWORD *)(a1 + 4192);
  *(_DWORD *)(a1 + 4256) = v189;
  *(_DWORD *)(a1 + 4272) = *(_DWORD *)(a1 + 4224);
  v190 = *(float *)(a1 + 84432);
  *(_DWORD *)(a1 + 4320) = *(_DWORD *)(a1 + 4304);
  v191 = *(float *)(a1 + 4288);
  *(float *)(a1 + 4304) = v191;
  v192 = (float)(v191 * *(float *)(a1 + 4336)) + *(float *)(a1 + 4320);
  *(float *)(a1 + 4304) = v192;
  v193 = (float)(v191 * *(float *)(a1 + 4352)) + v192;
  v194 = v192 * *(float *)(a1 + 4400);
  v195 = v190 - v193;
  v196 = (float)(v195 * *(float *)(a1 + 4336)) + v191;
  *(float *)(a1 + 4288) = v196;
  *(float *)(a1 + 4320) = (float)((float)(v195 * *(float *)(a1 + 4368)) + v194) + (float)(v196 * *(float *)(a1 + 4384));
  *(_DWORD *)(a1 + 6432) = *(_DWORD *)(a1 + 6416);
  v197 = *(float *)(a1 + 6448);
  *(float *)(a1 + 6464) = v197;
  v198 = v197 * *(float *)(a1 + 3536);
  v199 = *(float *)(a1 + 6432) * *(float *)(a1 + 4320);
  *(float *)(a1 + 6480) = v198;
  *(float *)(a1 + 6496) = v199;
  *(_DWORD *)(a1 + 6560) = *(_DWORD *)(a1 + 6544);
  *(float *)(a1 + 6544) = (float)(v199 * *(float *)(a1 + 6528)) + (float)(v198 * *(float *)(a1 + 6512));
  *(_DWORD *)(a1 + 6592) = *(_DWORD *)(a1 + 6576);
  *(_DWORD *)(a1 + 6624) = *(_DWORD *)(a1 + 6608);
  *(_DWORD *)(a1 + 6656) = *(_DWORD *)(a1 + 6640);
  *(_DWORD *)(a1 + 6688) = *(_DWORD *)(a1 + 6672);
  v200 = (float)((float)(*(float *)(a1 + 6720) * *(float *)(a1 + 6576))
               - (float)(*(float *)(a1 + 6736) * *(float *)(a1 + 6720)))
       + *(float *)(a1 + 6736);
  v201 = (float)((float)((float)((float)(v200 * v200) * v200) * v200) * *(float *)(a1 + 6816))
       + (float)((float)((float)((float)(v200 * v200) * v200) * *(float *)(a1 + 6800))
               + (float)((float)((float)(v200 * *(float *)(a1 + 6768)) + *(float *)(a1 + 6752))
                       + (float)((float)(v200 * v200) * *(float *)(a1 + 6784))));
  if ( v201 <= 0.0 )
    v202 = 0.0;
  else
    v202 = v201;
  v203 = v202;
  if ( v203 < 1.0 )
    v42 = v203;
  v204 = v42;
  *(float *)(a1 + 6704) = v204;
  *(_DWORD *)(a1 + 6848) = *(_DWORD *)(a1 + 6832);
  v205 = *(float *)(a1 + 6864);
  *(float *)(a1 + 6880) = v205;
  v206 = *(float *)(a1 + 6896);
  *(float *)(a1 + 6912) = v206;
  *(float *)(a1 + 6896) = (float)((float)(v205 - v206) * *(float *)(a1 + 6928)) + v206;
  v207 = *(float *)(a1 + 752);
  v208 = *(float *)(a1 + 880);
  *(_DWORD *)(a1 + 6992) = *(_DWORD *)(a1 + 6976);
  *(float *)(a1 + 6976) = (float)(v208 * *(float *)(a1 + 6960)) + (float)(v207 * *(float *)(a1 + 6944));
  *(_DWORD *)(a1 + 7040) = *(_DWORD *)(a1 + 7008);
  v209 = *(float *)(a1 + 7024);
  *(float *)(a1 + 7056) = v209;
  v210 = *(float *)(a1 + 2752)
       + (float)((float)(*(float *)(a1 + 7040) * *(float *)(a1 + 3232))
               - (float)(*(float *)(a1 + 7040) * *(float *)(a1 + 2752)));
  *(float *)(a1 + 7072) = (float)((float)(v209 * *(float *)(a1 + 6640)) - (float)(v209 * v210)) + v210;
  v211 = *(float *)(a1 + 1792);
  v212 = *(float *)(a1 + 7088);
  *(float *)(a1 + 7104) = v212;
  v213 = v211 - v212;
  v214 = (float)(v213 * *(float *)(a1 + 7120)) + v212;
  v215 = *(float *)(a1 + 7152);
  *(float *)(a1 + 7088) = v214;
  *(float *)(a1 + 7104) = (float)(v213 * *(float *)(a1 + 7136)) + (float)(v215 * v214);
  v216 = *(float *)(a1 + 7168);
  v217 = *(float *)(a1 + 1808);
  *(float *)(a1 + 7184) = v216;
  v218 = v217 - v216;
  v219 = (float)(v218 * *(float *)(a1 + 7200)) + v216;
  v220 = *(float *)(a1 + 7232);
  *(float *)(a1 + 7168) = v219;
  v221 = (float)(v218 * *(float *)(a1 + 7216)) + (float)(v220 * v219);
  *(float *)(a1 + 7184) = v221;
  v222 = *(float *)(a1 + 7104);
  v223 = *(float *)(a1 + 7072);
  v224 = *(float *)(a1 + 6976);
  v227 = (__m128)*(unsigned int *)(a1 + 6608);
  *(_DWORD *)(a1 + 7248) = *(_DWORD *)(a1 + 6896);
  *(_DWORD *)(a1 + 7264) = v227.m128_i32[0];
  v225 = *(float *)(a1 + 7296);
  v226 = *(float *)(a1 + 7312) * *(float *)(a1 + 6672);
  v227.m128_f32[0] = (float)((float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 7328))
                                                   - (float)(*(float *)(a1 + 7456) * *(float *)(a1 + 7328)))
                                           + *(float *)(a1 + 7456))
                                   * *(float *)(a1 + 7472))
                           + (float)((float)((float)(*(float *)(a1 + 7440) + *(float *)(a1 + 7248))
                                           * *(float *)(a1 + 7504))
                                   * *(float *)(a1 + 7424)))
                   + (float)((float)((float)((float)((float)((float)(v226
                                                                   - (float)(*(float *)(a1 + 7312) * (float)(v221 * v225)))
                                                           + (float)(v221 * v225))
                                                   * *(float *)(a1 + 7360))
                                           * *(float *)(a1 + 7376))
                                   + (float)((float)((float)(v226 - (float)(*(float *)(a1 + 7312) * (float)(v222 * v225)))
                                                   + (float)(v222 * v225))
                                           * *(float *)(a1 + 7344)))
                           + (float)((float)((float)(v224 + *(float *)(a1 + 7488)) * *(float *)(a1 + 7408))
                                   + (float)(v223 * *(float *)(a1 + 7392))));
  *(_DWORD *)(a1 + 7280) = v227.m128_i32[0];
  v228 = *(float *)(a1 + 6704);
  v229 = *(float *)(a1 + 6848);
  *(_DWORD *)(a1 + 7584) = *(_DWORD *)(a1 + 7568);
  v230 = *(float *)(a1 + 7552);
  *(float *)(a1 + 7568) = v230;
  if ( *(float *)(a1 + 7632) == 1.0 )
  {
    v231 = *(float *)(a1 + 7584)
         + (float)((float)(*(float *)(a1 + 7712) * v230) - (float)(*(float *)(a1 + 7712) * *(float *)(a1 + 7584)));
    *(float *)(a1 + 7568) = v231;
    v232 = (float)(v231 * *(float *)(a1 + 7696)) + *(float *)(a1 + 7600);
    *(float *)(a1 + 7552) = sub_7FF91DFC8D60();
    v233 = (float)(1.0 - v229) * *(float *)(a1 + 7728);
    *(float *)(a1 + 7536) = (float)(v229 * *(float *)(a1 + 7792)) + *(float *)(a1 + 7616);
    v227.m128_f32[0] = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 7680))
                                                         + (float)(v228 * *(float *)(a1 + 7648)))
                                                 + v232)
                                         + fminf(*(float *)(a1 + 7744), v233))
                                 + *(float *)(a1 + 7664),
                                   *(float *)(a1 + 7760)),
                                 *(float *)(a1 + 7776))
                             * *(float *)(a1 + 7824))
                     + *(float *)(a1 + 7840);
    v234 = v227.m128_f32[0];
    v235 = (int)v227.m128_f32[0];
    if ( (int)v227.m128_f32[0] != 0x80000000 && (float)v235 != v227.m128_f32[0] )
      v234 = (float)(v235 - (_mm_movemask_ps(_mm_unpacklo_ps(v227, v227)) & 1));
    v236 = v227.m128_f32[0] - v234;
    v237 = (float)(v236 * v236) * 0.25;
    v238 = (float)(expf(v234)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v236 * *(float *)(a1 + 8032)) + *(float *)(a1 + 8016)) * v237) + (float)(v236 * *(float *)(a1 + 8000))) + *(float *)(a1 + 7984)) * v237) + (float)(v236 * *(float *)(a1 + 7968)))
                                                                                                 + *(float *)(a1 + 7952))
                                                                                         * v237)
                                                                                 + (float)(v236 * *(float *)(a1 + 7936)))
                                                                         + *(float *)(a1 + 7920))
                                                                 * v237)
                                                         + (float)(v236 * *(float *)(a1 + 7904)))
                                                 + *(float *)(a1 + 7888))
                                         * v237)
                                 + (float)(v236 * *(float *)(a1 + 7872)))
                         + 1.0))
         * *(float *)(a1 + 7856);
    v239 = v238 * v238;
    v240 = (float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 0x2000))
                                                         + *(float *)(a1 + 8160))
                                                 * (float)(v239 * v239))
                                         + (float)((float)((float)(v238 * v238) * *(float *)(a1 + 8128))
                                                 + *(float *)(a1 + 8096)))
                                 * (float)((float)((float)(v238 * v238) * v238) * (float)(v238 * v238)))
                         + (float)((float)((float)(v238 * v238) * v238) * *(float *)(a1 + 8064)))
                 + v238)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 8176))
                                                                 + *(float *)(a1 + 8144))
                                                         * (float)(v239 * v239))
                                                 + (float)((float)(v238 * v238) * *(float *)(a1 + 8112)))
                                         + *(float *)(a1 + 8080))
                                 * (float)(v239 * v239))
                         + (float)((float)(v238 * v238) * *(float *)(a1 + 8048)))
                 + 1.0);
    v241 = v240 / (float)(v240 + 1.0);
    *(float *)(a1 + 7520) = v241;
  }
  else
  {
    v241 = *(float *)(a1 + 7520);
  }
  v242 = *(float *)(a1 + 6544);
  v243 = *(float *)(a1 + 7536);
  *(_DWORD *)(a1 + 8320) = *(_DWORD *)(a1 + 8304);
  *(_DWORD *)(a1 + 8304) = *(_DWORD *)(a1 + 8288);
  *(_DWORD *)(a1 + 8288) = *(_DWORD *)(a1 + 8272);
  *(_DWORD *)(a1 + 8272) = *(_DWORD *)(a1 + 8256);
  *(_DWORD *)(a1 + 8256) = *(_DWORD *)(a1 + 8240);
  *(_DWORD *)(a1 + 8240) = *(_DWORD *)(a1 + 8224);
  *(_DWORD *)(a1 + 8224) = *(_DWORD *)(a1 + 8208);
  *(_DWORD *)(a1 + 8544) = *(_DWORD *)(a1 + 8528);
  *(_DWORD *)(a1 + 8528) = *(_DWORD *)(a1 + 8512);
  *(_DWORD *)(a1 + 8512) = *(_DWORD *)(a1 + 8496);
  *(_DWORD *)(a1 + 8496) = *(_DWORD *)(a1 + 8480);
  *(_DWORD *)(a1 + 8480) = *(_DWORD *)(a1 + 8464);
  *(_DWORD *)(a1 + 8464) = *(_DWORD *)(a1 + 8448);
  *(_DWORD *)(a1 + 8448) = *(_DWORD *)(a1 + 8432);
  *(_DWORD *)(a1 + 8672) = *(_DWORD *)(a1 + 8656);
  *(_DWORD *)(a1 + 8656) = *(_DWORD *)(a1 + 8640);
  *(_DWORD *)(a1 + 8640) = *(_DWORD *)(a1 + 8624);
  *(_DWORD *)(a1 + 8624) = *(_DWORD *)(a1 + 8608);
  *(_DWORD *)(a1 + 8608) = *(_DWORD *)(a1 + 8592);
  *(_DWORD *)(a1 + 8592) = *(_DWORD *)(a1 + 8576);
  *(_DWORD *)(a1 + 8576) = *(_DWORD *)(a1 + 8560);
  *(_DWORD *)(a1 + 8800) = *(_DWORD *)(a1 + 8784);
  *(_DWORD *)(a1 + 8784) = *(_DWORD *)(a1 + 8768);
  *(_DWORD *)(a1 + 8768) = *(_DWORD *)(a1 + 8752);
  *(_DWORD *)(a1 + 8752) = *(_DWORD *)(a1 + 8736);
  *(_DWORD *)(a1 + 8736) = *(_DWORD *)(a1 + 8720);
  *(_DWORD *)(a1 + 8720) = *(_DWORD *)(a1 + 8704);
  *(_DWORD *)(a1 + 8704) = *(_DWORD *)(a1 + 8688);
  *(_DWORD *)(a1 + 8928) = *(_DWORD *)(a1 + 8912);
  *(_DWORD *)(a1 + 8912) = *(_DWORD *)(a1 + 8896);
  *(_DWORD *)(a1 + 8896) = *(_DWORD *)(a1 + 8880);
  *(_DWORD *)(a1 + 8880) = *(_DWORD *)(a1 + 8864);
  *(_DWORD *)(a1 + 8864) = *(_DWORD *)(a1 + 8848);
  *(_DWORD *)(a1 + 8848) = *(_DWORD *)(a1 + 8832);
  *(_DWORD *)(a1 + 8832) = *(_DWORD *)(a1 + 8816);
  *(_DWORD *)(a1 + 8960) = *(_DWORD *)(a1 + 8944);
  v244 = *(float *)(a1 + 8976);
  *(float *)(a1 + 8992) = v244;
  if ( *(float *)(a1 + 9056) == 1.0 )
  {
    v245 = (float)((float)((float)(v243 * *(float *)(a1 + 9168)) + 1.0) * (float)(v242 * *(float *)(a1 + 9136)))
         + (float)((float)-v244 * *(float *)(a1 + 9120));
    *(float *)(a1 + 8976) = sub_7FF91DFC8D60();
    *(float *)(a1 + 8944) = v245;
    v246 = 1.0 - (float)(v241 + v241);
    v247 = 1.0 / (float)((float)((float)((float)(v241 * v241) * (float)(v241 * v241)) * v243) + 1.0);
    *(float *)(a1 + 9024) = v247;
    v248 = *(float *)(a1 + 8944);
    v249 = *(float *)(a1 + 8960);
    *(float *)(a1 + 9008) = v247 * v243;
    v250 = v249 * *(float *)(a1 + 9216);
    v251 = *(float *)(a1 + 8304);
    v252 = v248 * *(float *)(a1 + 9232);
    v253 = *(float *)(a1 + 8320);
    *(float *)(a1 + 8416) = v251;
    v254 = (float)((float)(v250 + v252) * v247)
         - (float)((float)((float)(v251 * *(float *)(a1 + 9520)) + (float)(v253 * *(float *)(a1 + 9536)))
                 * (float)(v247 * v243));
    if ( v254 >= -1.0 )
      v255 = fminf(v254, 1.0);
    else
      v255 = -1.0;
    v256 = v255 + (float)((float)((float)((float)(v255 * v255) * v255) * v255) * (float)(v255 * *(float *)(a1 + 9184)));
    *(float *)(a1 + 8336) = v256;
    v257 = *(float *)(a1 + 8240);
    v258 = (float)(v241 * (float)(v256 + *(float *)(a1 + 8224))) + (float)(v257 * v246);
    *(float *)(a1 + 8352) = v258;
    v259 = *(float *)(a1 + 8256);
    v260 = v241 * (float)(v258 + v257);
    v261 = v241 * (float)((float)((float)(v241 * v256) + (float)(v246 * v258)) + v258);
    v262 = v260 + (float)(v259 * v246);
    *(float *)(a1 + 8368) = v262;
    v263 = *(float *)(a1 + 8272);
    v264 = (float)(v241 * (float)(v262 + v259)) + (float)(v263 * v246);
    *(float *)(a1 + 8384) = v264;
    v265 = (float)((float)(v263 + v264) * v241) + (float)(v246 * *(float *)(a1 + 8288));
    *(float *)(a1 + 8400) = v265;
    v266 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v261 + (float)(v246 * v262)) + v262))
                                 + (float)(v246 * v264))
                         + v264))
         + (float)(v246 * v265);
    v267 = (float)(*(float *)(a1 + 8384) * *(float *)(a1 + 9088)) + (float)(v265 * *(float *)(a1 + 9104));
    v268 = *(float *)(a1 + 8960);
    *(float *)(a1 + 8816) = v267 + (float)(*(float *)(a1 + 9072) * *(float *)(a1 + 8368));
    v269 = *(float *)(a1 + 8416);
    v270 = (float)((float)(v268 + *(float *)(a1 + 8944)) * *(float *)(a1 + 9248)) * *(float *)(a1 + 9024);
    *(float *)(a1 + 8416) = v266;
    v271 = v270
         - (float)((float)((float)(v266 * *(float *)(a1 + 9520)) + (float)(v269 * *(float *)(a1 + 9536)))
                 * *(float *)(a1 + 9008));
    if ( v271 >= -1.0 )
      v272 = fminf(v271, 1.0);
    else
      v272 = -1.0;
    v273 = v272 + (float)((float)((float)((float)(v272 * v272) * v272) * v272) * (float)(v272 * *(float *)(a1 + 9184)));
    v274 = *(float *)(a1 + 8336);
    *(float *)(a1 + 8336) = v273;
    v275 = *(float *)(a1 + 8352);
    v276 = (float)(v241 * (float)(v273 + v274)) + (float)(v275 * v246);
    *(float *)(a1 + 8352) = v276;
    v277 = *(float *)(a1 + 8368);
    v278 = v241 * (float)(v276 + v275);
    v279 = v241 * (float)((float)((float)(v241 * v273) + (float)(v246 * v276)) + v276);
    v280 = v278 + (float)(v277 * v246);
    *(float *)(a1 + 8368) = v280;
    v281 = *(float *)(a1 + 8384);
    v282 = (float)(v241 * (float)(v280 + v277)) + (float)(v281 * v246);
    *(float *)(a1 + 8384) = v282;
    v283 = (float)((float)(v281 + v282) * v241) + (float)(v246 * *(float *)(a1 + 8400));
    *(float *)(a1 + 8400) = v283;
    v284 = *(float *)(a1 + 8944);
    v285 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v279 + (float)(v246 * v280)) + v280))
                                 + (float)(v246 * v282))
                         + v282))
         + (float)(v246 * v283);
    v286 = (float)(*(float *)(a1 + 8384) * *(float *)(a1 + 9088)) + (float)(v283 * *(float *)(a1 + 9104));
    v287 = *(float *)(a1 + 8960);
    *(float *)(a1 + 8688) = v286 + (float)(*(float *)(a1 + 9072) * *(float *)(a1 + 8368));
    v288 = *(float *)(a1 + 8416);
    v289 = (float)((float)(v287 * *(float *)(a1 + 9232)) + (float)(v284 * *(float *)(a1 + 9216)))
         * *(float *)(a1 + 9024);
    *(float *)(a1 + 8416) = v285;
    v290 = v289
         - (float)((float)((float)(v285 * *(float *)(a1 + 9520)) + (float)(v288 * *(float *)(a1 + 9536)))
                 * *(float *)(a1 + 9008));
    if ( v290 >= -1.0 )
      v291 = fminf(v290, 1.0);
    else
      v291 = -1.0;
    v292 = v291 + (float)((float)((float)((float)(v291 * v291) * v291) * v291) * (float)(v291 * *(float *)(a1 + 9184)));
    v293 = *(float *)(a1 + 8336);
    *(float *)(a1 + 8336) = v292;
    v294 = *(float *)(a1 + 8352);
    v295 = (float)(v241 * (float)(v292 + v293)) + (float)(v294 * v246);
    *(float *)(a1 + 8352) = v295;
    v296 = *(float *)(a1 + 8368);
    v297 = v241 * (float)(v295 + v294);
    v298 = v241 * (float)((float)((float)(v241 * v292) + (float)(v246 * v295)) + v295);
    v299 = v297 + (float)(v296 * v246);
    *(float *)(a1 + 8368) = v299;
    v300 = *(float *)(a1 + 8384);
    v301 = (float)(v241 * (float)(v299 + v296)) + (float)(v300 * v246);
    *(float *)(a1 + 8384) = v301;
    v302 = (float)((float)(v300 + v301) * v241) + (float)(v246 * *(float *)(a1 + 8400));
    *(float *)(a1 + 8400) = v302;
    v303 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v298 + (float)(v246 * v299)) + v299))
                                 + (float)(v246 * v301))
                         + v301))
         + (float)(v246 * v302);
    v304 = (float)(*(float *)(a1 + 8384) * *(float *)(a1 + 9088)) + (float)(v302 * *(float *)(a1 + 9104));
    v305 = *(float *)(a1 + 8944);
    *(float *)(a1 + 8560) = v304 + (float)(*(float *)(a1 + 9072) * *(float *)(a1 + 8368));
    v306 = *(float *)(a1 + 8416);
    v307 = (float)(v305 * *(float *)(a1 + 9200)) * *(float *)(a1 + 9024);
    *(float *)(a1 + 8304) = v303;
    v308 = v307
         - (float)((float)((float)(v303 * *(float *)(a1 + 9520)) + (float)(v306 * *(float *)(a1 + 9536)))
                 * *(float *)(a1 + 9008));
    if ( v308 >= -1.0 )
      v309 = fminf(v308, 1.0);
    else
      v309 = -1.0;
    v310 = v309 + (float)((float)((float)((float)(v309 * v309) * v309) * v309) * (float)(v309 * *(float *)(a1 + 9184)));
    *(float *)(a1 + 8208) = v310;
    v311 = *(float *)(a1 + 8352);
    v312 = (float)(v241 * (float)(v310 + *(float *)(a1 + 8336))) + (float)(v311 * v246);
    *(float *)(a1 + 8224) = v312;
    v313 = *(float *)(a1 + 8368);
    v314 = v241 * (float)(v312 + v311);
    v315 = v241 * (float)((float)((float)(v241 * v310) + (float)(v246 * v312)) + v312);
    v316 = v314 + (float)(v313 * v246);
    *(float *)(a1 + 8240) = v316;
    v317 = *(float *)(a1 + 8384);
    v318 = (float)(v241 * (float)(v316 + v313)) + (float)(v317 * v246);
    *(float *)(a1 + 8256) = v318;
    v319 = (float)((float)(v317 + v318) * v241) + (float)(v246 * *(float *)(a1 + 8400));
    v320 = v241
         * (float)((float)((float)(v241 * (float)((float)(v315 + (float)(v246 * v316)) + v316)) + (float)(v246 * v318))
                 + v318);
    *(float *)(a1 + 8272) = v319;
    v321 = *(float *)(a1 + 8240);
    *(float *)(a1 + 8288) = v320 + (float)(v246 * v319);
    v322 = *(float *)(a1 + 8496);
    v323 = (float)((float)(v319 * *(float *)(a1 + 9104)) + (float)(*(float *)(a1 + 9088) * *(float *)(a1 + 8256)))
         + (float)(v321 * *(float *)(a1 + 9072));
    *(float *)(a1 + 8432) = v323;
    v324 = (float)(v323 + *(float *)(a1 + 8928)) * *(float *)(a1 + 9264);
    v325 = (float)(*(float *)(a1 + 8688) + *(float *)(a1 + 8672)) * *(float *)(a1 + 9296);
    v326 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v322 + *(float *)(a1 + 8864)) * *(float *)(a1 + 9504)) + (float)((float)(*(float *)(a1 + 8624) + *(float *)(a1 + 8736)) * *(float *)(a1 + 9488))) + (float)((float)(*(float *)(a1 + 8752) + *(float *)(a1 + 8608)) * *(float *)(a1 + 9472))) + (float)((float)(*(float *)(a1 + 8480) + *(float *)(a1 + 8880)) * *(float *)(a1 + 9456))) + (float)((float)(*(float *)(a1 + 8848) + *(float *)(a1 + 8512)) * *(float *)(a1 + 9440)))
                                                                                                 + (float)((float)(*(float *)(a1 + 8720) + *(float *)(a1 + 8640)) * *(float *)(a1 + 9424)))
                                                                                         + (float)((float)(*(float *)(a1 + 8768) + *(float *)(a1 + 8592))
                                                                                                 * *(float *)(a1 + 9408)))
                                                                                 + (float)((float)(*(float *)(a1 + 8896)
                                                                                                 + *(float *)(a1 + 8464))
                                                                                         * *(float *)(a1 + 9392)))
                                                                         + (float)((float)(*(float *)(a1 + 8832)
                                                                                         + *(float *)(a1 + 8528))
                                                                                 * *(float *)(a1 + 9376)))
                                                                 + (float)((float)(*(float *)(a1 + 8704)
                                                                                 + *(float *)(a1 + 8656))
                                                                         * *(float *)(a1 + 9360)))
                                                         + (float)((float)(*(float *)(a1 + 8784) + *(float *)(a1 + 8576))
                                                                 * *(float *)(a1 + 9344)))
                                                 + (float)((float)(*(float *)(a1 + 8912) + *(float *)(a1 + 8448))
                                                         * *(float *)(a1 + 9328)))
                                         + (float)((float)(*(float *)(a1 + 8816) + *(float *)(a1 + 8544))
                                                 * *(float *)(a1 + 9312)))
                                 + v325)
                         + (float)((float)(*(float *)(a1 + 8800) + *(float *)(a1 + 8560)) * *(float *)(a1 + 9280)))
                 + v324)
         * *(float *)(a1 + 9152);
    *(float *)(a1 + 9040) = v326;
  }
  *(_DWORD *)(a1 + 9568) = *(_DWORD *)(a1 + 9552);
  v327 = *(_DWORD *)(a1 + 9600);
  *(_DWORD *)(a1 + 9632) = *(_DWORD *)(a1 + 9584);
  *(_DWORD *)(a1 + 9648) = v327;
  *(_DWORD *)(a1 + 9664) = *(_DWORD *)(a1 + 9616);
  v328 = *(float *)(a1 + 9680);
  *(float *)(a1 + 9696) = v328;
  v329 = *(float *)(a1 + 9712);
  *(float *)(a1 + 9728) = v329;
  v330 = (float)((float)(v328 - v329) * *(float *)(a1 + 9744)) + v329;
  *(float *)(a1 + 9712) = v330;
  v331 = (float)((float)(v330 * *(float *)(a1 + 9648)) - (float)(*(float *)(a1 + 9648) * *(float *)(a1 + 9664)))
       + *(float *)(a1 + 9664);
  *(float *)(a1 + 9760) = v331;
  v332 = *(float *)(a1 + 9776);
  *(float *)(a1 + 9792) = v332;
  v333 = (float)((float)(*(float *)(a1 + 9808) * v331) - (float)(*(float *)(a1 + 9808) * v332)) + v332;
  if ( v333 <= 0.0 )
    v334 = 0.0;
  else
    v334 = v333;
  v335 = v334;
  *(float *)(a1 + 9776) = v335;
  v336 = *(float *)(a1 + 9824);
  *(float *)(a1 + 9840) = v336;
  v337 = *(float *)(a1 + 9856);
  *(float *)(a1 + 9872) = v337;
  v338 = (float)((float)(*(float *)(a1 + 9888) * v336) - (float)(*(float *)(a1 + 9888) * v337)) + v337;
  if ( v338 <= 0.0 )
    v339 = 0.0;
  else
    v339 = v338;
  v340 = v339;
  *(float *)(a1 + 9856) = v340;
  v341 = *(float *)(a1 + 9904);
  v342 = *(float *)(a1 + 560);
  *(float *)(a1 + 9920) = v341;
  v343 = v341 * *(float *)(a1 + 10000);
  v344 = v341 + *(float *)(a1 + 9984);
  if ( v343 >= -1.0 )
    v345 = fminf(v343, 1.0);
  else
    v345 = -1.0;
  if ( (float)(v341 + *(float *)(a1 + 9952)) >= 0.0 )
    v344 = (float)((float)(*(float *)(a1 + 9968) * v342) - (float)(*(float *)(a1 + 9968) * v341)) + v341;
  v346 = (float)((float)(v345 * *(float *)(a1 + 10016)) - (float)(*(float *)(a1 + 10032) * v345))
       + *(float *)(a1 + 10032);
  v347 = (float)((float)(v346 * v342) - (float)(v346 * v341)) + v341;
  if ( v342 != 0.0 )
    v347 = v344;
  *(float *)(a1 + 9936) = v347;
  *(float *)(a1 + 9904) = v347;
  v348 = *(float *)(a1 + 9040);
  v349 = *(float *)(a1 + 2752);
  v350 = *(float *)(a1 + 6848);
  v351 = *(_DWORD *)(a1 + 3232);
  v352 = *(_DWORD *)(a1 + 9552);
  *(_DWORD *)(a1 + 10112) = *(_DWORD *)(a1 + 10096);
  *(_DWORD *)(a1 + 10144) = *(_DWORD *)(a1 + 10128);
  *(_DWORD *)(a1 + 10048) = v351;
  *(_DWORD *)(a1 + 10064) = v352;
  v353 = *(float *)(a1 + 10112);
  v354 = *(float *)(a1 + 10176);
  *(float *)(a1 + 10080) = v350 * *(float *)(a1 + 10336);
  v355 = v348 - v353;
  v356 = *(float *)(a1 + 10208);
  v357 = (float)(v349 * *(float *)(a1 + 10192)) + (float)(v354 * *(float *)(a1 + 9936));
  v358 = v353 + (float)((float)(v348 - v353) * *(float *)(a1 + 10240));
  *(float *)(a1 + 10096) = v358;
  v359 = (float)(v355 * *(float *)(a1 + 10352)) + (float)(v358 * *(float *)(a1 + 10368));
  v360 = (float)((float)(*(float *)(a1 + 10224) * *(float *)(a1 + 10064))
               - (float)(*(float *)(a1 + 10224) * (float)(v357 + (float)(v356 * *(float *)(a1 + 10048)))))
       + (float)(v357 + (float)(v356 * *(float *)(a1 + 10048)));
  v361 = *(float *)(a1 + 10256);
  v362 = v360 * *(float *)(a1 + 10304);
  v363 = v348 * (float)(1.0 - v361);
  if ( v362 <= 0.0 )
    v364 = 0.0;
  else
    v364 = v362;
  v365 = *(float *)(a1 + 10272);
  v366 = v364;
  v367 = v366 * *(float *)(a1 + 10320);
  v368 = (float)((float)(v361 * v359) + v363) * (float)(*(float *)(a1 + 10080) + 1.0);
  v369 = *(float *)(a1 + 10288) * v368;
  v370 = *(float *)(a1 + 10144)
       + (float)((float)(*(float *)(a1 + 10384) * v368) - (float)(*(float *)(a1 + 10384) * *(float *)(a1 + 10144)));
  *(float *)(a1 + 10128) = v370;
  v371 = (float)((float)((float)(v365 * v370) + v369) * v367) * *(float *)(a1 + 10400);
  *(float *)(a1 + 10160) = v371;
  *(_DWORD *)(a1 + 10448) = *(_DWORD *)(a1 + 10432);
  *(_DWORD *)(a1 + 10432) = *(_DWORD *)(a1 + 10416);
  v372 = *(float *)(a1 + 10448);
  v373 = *(float *)(a1 + 10464);
  v374 = v371 - v372;
  *(float *)(a1 + 10416) = v374;
  *(float *)(a1 + 10432) = (float)(v373 * v374) + v372;
  v375 = *(float *)(a1 + 10416);
  v376 = *(float *)(a1 + 9632);
  *(_DWORD *)(a1 + 10528) = *(_DWORD *)(a1 + 10512);
  *(_DWORD *)(a1 + 10512) = *(_DWORD *)(a1 + 10496);
  *(_DWORD *)(a1 + 10496) = *(_DWORD *)(a1 + 10480);
  *(float *)(a1 + 10480) = v375;
  v377 = (float)((float)(*(float *)(a1 + 10496) * *(float *)(a1 + 10576)) + (float)(v375 * *(float *)(a1 + 10560)))
       + (float)(*(float *)(a1 + 10592) * *(float *)(a1 + 10512));
  v378 = (float)((float)(*(float *)(a1 + 10496) * *(float *)(a1 + 10624)) + (float)(v375 * *(float *)(a1 + 10608)))
       + (float)(*(float *)(a1 + 10640) * *(float *)(a1 + 10528));
  if ( v376 <= 0.0 )
    v379 = 0.0;
  else
    v379 = v376;
  *(float *)(a1 + 10496) = v377;
  v380 = v379;
  *(float *)(a1 + 10512) = v378;
  v381 = (float)((float)(v380 * v377) - (float)(v380 * v375)) + v375;
  if ( v376 < -0.0 )
    v19 = (float)-v376;
  v382 = v19;
  v383 = v375 + (float)((float)(v382 * v378) - (float)(v382 * v375));
  if ( v376 >= 0.0 )
    v383 = v381;
  *(float *)(a1 + 10544) = v383;
  v384 = v383 * *(float *)(a1 + 9776);
  *(float *)(a1 + 10656) = v384;
  *(float *)(a1 + 10672) = v384 * *(float *)(a1 + 9856);
  v385 = fmin(fmax((float)(*(float *)(a1 + 4448) + *(float *)(a1 + 3776)), -20.0), 8.9);
  v386 = v385 * v385 * v385;
  v387 = (double *)((char *)&unk_7FF91E5E94E0 + 208 * (int)(v385 + 20.0));
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
       * *(float *)(a1 + 3792);
  *(float *)(a1 + 4416) = v391;
  v392 = *(float *)(a1 + 3776);
  v393 = *(_DWORD *)(a1 + 4240);
  v394 = *(_DWORD *)(a1 + 4256);
  LODWORD(v386) = *(_DWORD *)(a1 + 4272);
  *(_DWORD *)(a1 + 4848) = *(_DWORD *)(a1 + 4832);
  *(_DWORD *)(a1 + 4880) = *(_DWORD *)(a1 + 4864);
  *(_DWORD *)(a1 + 5056) = *(_DWORD *)(a1 + 5040);
  *(_DWORD *)(a1 + 5040) = *(_DWORD *)(a1 + 5024);
  *(_DWORD *)(a1 + 5024) = *(_DWORD *)(a1 + 5008);
  *(_DWORD *)(a1 + 5008) = *(_DWORD *)(a1 + 4992);
  *(_DWORD *)(a1 + 4992) = *(_DWORD *)(a1 + 4976);
  *(_DWORD *)(a1 + 4976) = *(_DWORD *)(a1 + 4960);
  *(_DWORD *)(a1 + 4960) = *(_DWORD *)(a1 + 4944);
  *(_DWORD *)(a1 + 5184) = *(_DWORD *)(a1 + 5168);
  *(_DWORD *)(a1 + 5168) = *(_DWORD *)(a1 + 5152);
  *(_DWORD *)(a1 + 5152) = *(_DWORD *)(a1 + 5136);
  *(_DWORD *)(a1 + 5136) = *(_DWORD *)(a1 + 5120);
  *(_DWORD *)(a1 + 5120) = *(_DWORD *)(a1 + 5104);
  *(_DWORD *)(a1 + 5104) = *(_DWORD *)(a1 + 5088);
  *(_DWORD *)(a1 + 5088) = *(_DWORD *)(a1 + 5072);
  *(_DWORD *)(a1 + 5312) = *(_DWORD *)(a1 + 5296);
  *(_DWORD *)(a1 + 5296) = *(_DWORD *)(a1 + 5280);
  *(_DWORD *)(a1 + 5280) = *(_DWORD *)(a1 + 5264);
  *(_DWORD *)(a1 + 5264) = *(_DWORD *)(a1 + 5248);
  *(_DWORD *)(a1 + 5248) = *(_DWORD *)(a1 + 5232);
  *(_DWORD *)(a1 + 5232) = *(_DWORD *)(a1 + 5216);
  *(_DWORD *)(a1 + 5216) = *(_DWORD *)(a1 + 5200);
  *(_DWORD *)(a1 + 5440) = *(_DWORD *)(a1 + 5424);
  *(_DWORD *)(a1 + 5424) = *(_DWORD *)(a1 + 5408);
  *(_DWORD *)(a1 + 5408) = *(_DWORD *)(a1 + 5392);
  *(_DWORD *)(a1 + 5392) = *(_DWORD *)(a1 + 5376);
  *(_DWORD *)(a1 + 5376) = *(_DWORD *)(a1 + 5360);
  *(_DWORD *)(a1 + 5360) = *(_DWORD *)(a1 + 5344);
  *(_DWORD *)(a1 + 5344) = *(_DWORD *)(a1 + 5328);
  *(_DWORD *)(a1 + 5504) = *(_DWORD *)(a1 + 5488);
  *(_DWORD *)(a1 + 5488) = *(_DWORD *)(a1 + 5472);
  *(_DWORD *)(a1 + 4736) = v393;
  *(_DWORD *)(a1 + 4752) = v394;
  v395 = v392 + *(float *)(a1 + 6304);
  v396 = v391 * *(float *)(a1 + 5536);
  v397 = *(float *)(a1 + 5520);
  *(_DWORD *)(a1 + 4768) = LODWORD(v386);
  v398 = fmaxf(*(float *)(a1 + 5568), v396);
  v399 = (float)(v395 * *(float *)(a1 + 6320)) + *(float *)(a1 + 6288);
  *(float *)(a1 + 4784) = v398;
  *(float *)(a1 + 4816) = v397 + *(float *)(a1 + 3808);
  if ( v399 <= 0.0 )
    v400 = 0.0;
  else
    v400 = v399;
  *(float *)(a1 + 4800) = 0.00390625 / v398;
  *(float *)(a1 + 5456) = v400;
  v401 = *(float *)(a1 + 4880);
  v402 = *(_DWORD *)(a1 + 4848);
  *(float *)(a1 + 4656) = v401;
  v403 = v401 + v398;
  *(_DWORD *)(a1 + 4672) = v402;
  if ( v403 <= 1.0 )
  {
    if ( v403 < -1.0 )
      v403 = fmodf(v403 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v403 = fmodf(v403 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 4640) = v403;
  v404 = v403 * *(float *)(a1 + 5648);
  v405 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v406 = (float)((float)(*(float *)&v405 * 256.0) * *(float *)(a1 + 4800)) * *(float *)(a1 + 5600);
  if ( v406 >= -1.0 )
    v407 = fminf(v406, 1.0);
  else
    v407 = -1.0;
  v408 = v407 * *(float *)(a1 + 5552);
  v409 = (float)(v408 * v408) * v408;
  v410 = v409 * *(float *)(a1 + 5952);
  v411 = (float)((float)((float)((float)((float)(v408 * v408) * *(float *)(a1 + 6016)) + *(float *)(a1 + 6000))
                       * (float)((float)(v408 * v408) * (float)(v408 * v408)))
               + (float)((float)((float)(v408 * v408) * *(float *)(a1 + 5984)) + *(float *)(a1 + 5968)))
       * (float)(v409 * (float)(v408 * v408));
  v412 = *(float *)(a1 + 4816) + v403;
  *(float *)(a1 + 4896) = (float)((float)(v411 + v410) + v408) * v404;
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
  v414 = *(float *)(a1 + 4640);
  v415 = v413 * *(float *)(a1 + 5664);
  v416 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v417 = *(float *)&v416;
  v418 = *(float *)(a1 + 5584);
  if ( v414 < v418 || v418 <= *(float *)(a1 + 4656) )
    v419 = *(float *)(a1 + 4672);
  else
    v419 = *(float *)(a1 + 4672) + 2.0;
  v420 = (float)((float)(v417 * *(float *)(a1 + 4800)) * 256.0) * *(float *)(a1 + 5616);
  if ( v419 >= 4.0 )
    v419 = 0.0;
  if ( v420 >= -1.0 )
    v421 = fminf(v420, 1.0);
  else
    v421 = -1.0;
  *(float *)(a1 + 4672) = v419;
  v422 = v421 * *(float *)(a1 + 5552);
  v423 = (float)((float)((float)(v419 + v414) + 1.0) * 0.5) - 1.0;
  v424 = (float)((float)((float)((float)((float)((float)((float)((float)(v422 * v422) * *(float *)(a1 + 6016))
                                                       + *(float *)(a1 + 6000))
                                               * (float)((float)(v422 * v422) * (float)(v422 * v422)))
                                       + (float)((float)((float)(v422 * v422) * *(float *)(a1 + 5984))
                                               + *(float *)(a1 + 5968)))
                               * (float)((float)((float)(v422 * v422) * v422) * (float)(v422 * v422)))
                       + (float)((float)((float)(v422 * v422) * v422) * *(float *)(a1 + 5952)))
               + v422)
       * v415;
  *(float *)(a1 + 4912) = v424;
  v425 = ((double (*)(void))sub_7FF91DFC8FC0)();
  if ( v423 >= 0.0 )
  {
    if ( v423 > 0.0 )
      v423 = 1.0;
  }
  else
  {
    v423 = -1.0;
  }
  v426 = v423 * *(float *)(a1 + 5680);
  v427 = (float)((float)((float)(*(float *)&v425 + 1.0) * *(float *)(a1 + 4800)) * 512.0) * *(float *)(a1 + 5632);
  if ( v427 >= -1.0 )
    v428 = fminf(v427, 1.0);
  else
    v428 = -1.0;
  v429 = v428 * *(float *)(a1 + 5552);
  v430 = *(float *)(a1 + 4640);
  v431 = *(_DWORD *)(a1 + 4672);
  *(float *)(a1 + 4944) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v429 * v429)
                                                                                                * *(float *)(a1 + 6016))
                                                                                        + *(float *)(a1 + 6000))
                                                                                * (float)((float)(v429 * v429)
                                                                                        * (float)(v429 * v429)))
                                                                        + (float)((float)((float)(v429 * v429)
                                                                                        * *(float *)(a1 + 5984))
                                                                                + *(float *)(a1 + 5968)))
                                                                * (float)((float)((float)(v429 * v429) * v429)
                                                                        * (float)(v429 * v429)))
                                                        + (float)((float)((float)(v429 * v429) * v429)
                                                                * *(float *)(a1 + 5952)))
                                                + v429)
                                        * v426)
                                * *(float *)(a1 + 4768))
                        + (float)((float)(*(float *)(a1 + 4896) * *(float *)(a1 + 4736))
                                + (float)(v424 * *(float *)(a1 + 4752)));
  *(float *)(a1 + 4656) = v430;
  *(_DWORD *)(a1 + 4672) = v431;
  v432 = v430 + *(float *)(a1 + 4784);
  if ( v432 <= 1.0 )
  {
    if ( v432 < -1.0 )
      v432 = fmodf(v432 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v432 = fmodf(v432 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 4640) = v432;
  v433 = v432 * *(float *)(a1 + 5648);
  v434 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v435 = (float)((float)(*(float *)&v434 * 256.0) * *(float *)(a1 + 4800)) * *(float *)(a1 + 5600);
  if ( v435 >= -1.0 )
    v436 = fminf(v435, 1.0);
  else
    v436 = -1.0;
  v437 = v436 * *(float *)(a1 + 5552);
  v438 = (float)(v437 * v437) * v437;
  v439 = v438 * *(float *)(a1 + 5952);
  v440 = (float)((float)((float)((float)((float)(v437 * v437) * *(float *)(a1 + 6016)) + *(float *)(a1 + 6000))
                       * (float)((float)(v437 * v437) * (float)(v437 * v437)))
               + (float)((float)((float)(v437 * v437) * *(float *)(a1 + 5984)) + *(float *)(a1 + 5968)))
       * (float)(v438 * (float)(v437 * v437));
  v441 = *(float *)(a1 + 4816) + v432;
  *(float *)(a1 + 4896) = (float)((float)(v440 + v439) + v437) * v433;
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
  v443 = *(float *)(a1 + 4640);
  v444 = v442 * *(float *)(a1 + 5664);
  v445 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v446 = *(float *)&v445;
  v447 = *(float *)(a1 + 5584);
  if ( v443 < v447 || v447 <= *(float *)(a1 + 4656) )
    v448 = *(float *)(a1 + 4672);
  else
    v448 = *(float *)(a1 + 4672) + 2.0;
  v449 = (float)((float)(v446 * *(float *)(a1 + 4800)) * 256.0) * *(float *)(a1 + 5616);
  if ( v448 >= 4.0 )
    v448 = 0.0;
  if ( v449 >= -1.0 )
    v450 = fminf(v449, 1.0);
  else
    v450 = -1.0;
  *(float *)(a1 + 4672) = v448;
  v451 = v450 * *(float *)(a1 + 5552);
  v452 = (float)((float)((float)(v448 + v443) + 1.0) * 0.5) - 1.0;
  v453 = (float)((float)((float)((float)((float)((float)((float)((float)(v451 * v451) * *(float *)(a1 + 6016))
                                                       + *(float *)(a1 + 6000))
                                               * (float)((float)(v451 * v451) * (float)(v451 * v451)))
                                       + (float)((float)((float)(v451 * v451) * *(float *)(a1 + 5984))
                                               + *(float *)(a1 + 5968)))
                               * (float)((float)((float)(v451 * v451) * v451) * (float)(v451 * v451)))
                       + (float)((float)((float)(v451 * v451) * v451) * *(float *)(a1 + 5952)))
               + v451)
       * v444;
  *(float *)(a1 + 4912) = v453;
  v454 = ((double (*)(void))sub_7FF91DFC8FC0)();
  if ( v452 >= 0.0 )
  {
    if ( v452 > 0.0 )
      v452 = 1.0;
  }
  else
  {
    v452 = -1.0;
  }
  v455 = v452 * *(float *)(a1 + 5680);
  v456 = (float)((float)((float)(*(float *)&v454 + 1.0) * *(float *)(a1 + 4800)) * 512.0) * *(float *)(a1 + 5632);
  if ( v456 >= -1.0 )
    v457 = fminf(v456, 1.0);
  else
    v457 = -1.0;
  v458 = v457 * *(float *)(a1 + 5552);
  v459 = *(float *)(a1 + 4640);
  v460 = *(_DWORD *)(a1 + 4672);
  *(float *)(a1 + 5072) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v458 * v458)
                                                                                                * *(float *)(a1 + 6016))
                                                                                        + *(float *)(a1 + 6000))
                                                                                * (float)((float)(v458 * v458)
                                                                                        * (float)(v458 * v458)))
                                                                        + (float)((float)((float)(v458 * v458)
                                                                                        * *(float *)(a1 + 5984))
                                                                                + *(float *)(a1 + 5968)))
                                                                * (float)((float)((float)(v458 * v458) * v458)
                                                                        * (float)(v458 * v458)))
                                                        + (float)((float)((float)(v458 * v458) * v458)
                                                                * *(float *)(a1 + 5952)))
                                                + v458)
                                        * v455)
                                * *(float *)(a1 + 4768))
                        + (float)((float)(*(float *)(a1 + 4896) * *(float *)(a1 + 4736))
                                + (float)(v453 * *(float *)(a1 + 4752)));
  *(float *)(a1 + 4656) = v459;
  *(_DWORD *)(a1 + 4672) = v460;
  v461 = v459 + *(float *)(a1 + 4784);
  if ( v461 <= 1.0 )
  {
    if ( v461 < -1.0 )
      v461 = fmodf(v461 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v461 = fmodf(v461 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 4640) = v461;
  v462 = v461 * *(float *)(a1 + 5648);
  v463 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v464 = (float)((float)(*(float *)&v463 * 256.0) * *(float *)(a1 + 4800)) * *(float *)(a1 + 5600);
  if ( v464 >= -1.0 )
    v465 = fminf(v464, 1.0);
  else
    v465 = -1.0;
  v466 = v465 * *(float *)(a1 + 5552);
  v467 = (float)(v466 * v466) * v466;
  v468 = v467 * *(float *)(a1 + 5952);
  v469 = (float)((float)((float)((float)((float)(v466 * v466) * *(float *)(a1 + 6016)) + *(float *)(a1 + 6000))
                       * (float)((float)(v466 * v466) * (float)(v466 * v466)))
               + (float)((float)((float)(v466 * v466) * *(float *)(a1 + 5984)) + *(float *)(a1 + 5968)))
       * (float)(v467 * (float)(v466 * v466));
  v470 = *(float *)(a1 + 4816) + v461;
  *(float *)(a1 + 4896) = (float)((float)(v469 + v468) + v466) * v462;
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
  v472 = *(float *)(a1 + 4640);
  v473 = v471 * *(float *)(a1 + 5664);
  v474 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v475 = *(float *)&v474;
  v476 = *(float *)(a1 + 5584);
  if ( v472 < v476 || v476 <= *(float *)(a1 + 4656) )
    v477 = *(float *)(a1 + 4672);
  else
    v477 = *(float *)(a1 + 4672) + 2.0;
  v478 = (float)((float)(v475 * *(float *)(a1 + 4800)) * 256.0) * *(float *)(a1 + 5616);
  if ( v477 >= 4.0 )
    v477 = 0.0;
  if ( v478 >= -1.0 )
    v479 = fminf(v478, 1.0);
  else
    v479 = -1.0;
  *(float *)(a1 + 4672) = v477;
  v480 = v479 * *(float *)(a1 + 5552);
  v481 = (float)((float)((float)(v477 + v472) + 1.0) * 0.5) - 1.0;
  v482 = (float)((float)((float)((float)((float)((float)((float)((float)(v480 * v480) * *(float *)(a1 + 6016))
                                                       + *(float *)(a1 + 6000))
                                               * (float)((float)(v480 * v480) * (float)(v480 * v480)))
                                       + (float)((float)((float)(v480 * v480) * *(float *)(a1 + 5984))
                                               + *(float *)(a1 + 5968)))
                               * (float)((float)((float)(v480 * v480) * v480) * (float)(v480 * v480)))
                       + (float)((float)((float)(v480 * v480) * v480) * *(float *)(a1 + 5952)))
               + v480)
       * v473;
  *(float *)(a1 + 4912) = v482;
  v483 = ((double (*)(void))sub_7FF91DFC8FC0)();
  if ( v481 >= 0.0 )
  {
    if ( v481 > 0.0 )
      v481 = 1.0;
  }
  else
  {
    v481 = -1.0;
  }
  v484 = v481 * *(float *)(a1 + 5680);
  v485 = (float)((float)((float)(*(float *)&v483 + 1.0) * *(float *)(a1 + 4800)) * 512.0) * *(float *)(a1 + 5632);
  if ( v485 >= -1.0 )
    v486 = fminf(v485, 1.0);
  else
    v486 = -1.0;
  v487 = v486 * *(float *)(a1 + 5552);
  v488 = *(float *)(a1 + 4640);
  v489 = *(_DWORD *)(a1 + 4672);
  *(float *)(a1 + 5200) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v487 * v487)
                                                                                                * *(float *)(a1 + 6016))
                                                                                        + *(float *)(a1 + 6000))
                                                                                * (float)((float)(v487 * v487)
                                                                                        * (float)(v487 * v487)))
                                                                        + (float)((float)((float)(v487 * v487)
                                                                                        * *(float *)(a1 + 5984))
                                                                                + *(float *)(a1 + 5968)))
                                                                * (float)((float)((float)(v487 * v487) * v487)
                                                                        * (float)(v487 * v487)))
                                                        + (float)((float)((float)(v487 * v487) * v487)
                                                                * *(float *)(a1 + 5952)))
                                                + v487)
                                        * v484)
                                * *(float *)(a1 + 4768))
                        + (float)((float)(*(float *)(a1 + 4896) * *(float *)(a1 + 4736))
                                + (float)(v482 * *(float *)(a1 + 4752)));
  *(float *)(a1 + 4656) = v488;
  *(_DWORD *)(a1 + 4672) = v489;
  v490 = v488 + *(float *)(a1 + 4784);
  if ( v490 <= 1.0 )
  {
    if ( v490 < -1.0 )
      v490 = fmodf(v490 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v490 = fmodf(v490 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 4640) = v490;
  v491 = v490 * *(float *)(a1 + 5648);
  v492 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v493 = (float)((float)(*(float *)&v492 * 256.0) * *(float *)(a1 + 4800)) * *(float *)(a1 + 5600);
  if ( v493 >= -1.0 )
    v494 = fminf(v493, 1.0);
  else
    v494 = -1.0;
  v495 = v494 * *(float *)(a1 + 5552);
  v496 = (float)(v495 * v495) * v495;
  v497 = v496 * *(float *)(a1 + 5952);
  v498 = (float)((float)((float)((float)((float)(v495 * v495) * *(float *)(a1 + 6016)) + *(float *)(a1 + 6000))
                       * (float)((float)(v495 * v495) * (float)(v495 * v495)))
               + (float)((float)((float)(v495 * v495) * *(float *)(a1 + 5984)) + *(float *)(a1 + 5968)))
       * (float)(v496 * (float)(v495 * v495));
  v499 = *(float *)(a1 + 4816) + v490;
  *(float *)(a1 + 4896) = (float)((float)(v498 + v497) + v495) * v491;
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
  v501 = *(float *)(a1 + 4640);
  v502 = v500 * *(float *)(a1 + 5664);
  v503 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v504 = *(float *)&v503;
  v505 = *(float *)(a1 + 5584);
  if ( v501 < v505 || v505 <= *(float *)(a1 + 4656) )
    v506 = *(float *)(a1 + 4672);
  else
    v506 = *(float *)(a1 + 4672) + 2.0;
  v507 = (float)((float)(v504 * *(float *)(a1 + 4800)) * 256.0) * *(float *)(a1 + 5616);
  if ( v506 >= 4.0 )
    v506 = 0.0;
  if ( v507 >= -1.0 )
    v508 = fminf(v507, 1.0);
  else
    v508 = -1.0;
  *(float *)(a1 + 4672) = v506;
  v509 = v508 * *(float *)(a1 + 5552);
  v510 = (float)((float)((float)(v506 + v501) + 1.0) * 0.5) - 1.0;
  v511 = (float)((float)((float)((float)((float)((float)((float)((float)(v509 * v509) * *(float *)(a1 + 6016))
                                                       + *(float *)(a1 + 6000))
                                               * (float)((float)(v509 * v509) * (float)(v509 * v509)))
                                       + (float)((float)((float)(v509 * v509) * *(float *)(a1 + 5984))
                                               + *(float *)(a1 + 5968)))
                               * (float)((float)((float)(v509 * v509) * v509) * (float)(v509 * v509)))
                       + (float)((float)((float)(v509 * v509) * v509) * *(float *)(a1 + 5952)))
               + v509)
       * v502;
  *(float *)(a1 + 4912) = v511;
  v512 = sub_7FF91DFC8FC0() + 1.0;
  if ( v510 >= 0.0 )
  {
    if ( v510 > 0.0 )
      v510 = 1.0;
  }
  else
  {
    v510 = -1.0;
  }
  v513 = v510 * *(float *)(a1 + 5680);
  v514 = (float)((float)(v512 * *(float *)(a1 + 4800)) * 512.0) * *(float *)(a1 + 5632);
  if ( v514 >= -1.0 )
    v33 = fminf(v514, 1.0);
  v515 = v33 * *(float *)(a1 + 5552);
  v516 = *(_DWORD *)(a1 + 4640);
  v517 = *(_DWORD *)(a1 + 4672);
  *(float *)(a1 + 5328) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v515 * v515)
                                                                                                * *(float *)(a1 + 6016))
                                                                                        + *(float *)(a1 + 6000))
                                                                                * (float)((float)(v515 * v515)
                                                                                        * (float)(v515 * v515)))
                                                                        + (float)((float)((float)(v515 * v515)
                                                                                        * *(float *)(a1 + 5984))
                                                                                + *(float *)(a1 + 5968)))
                                                                * (float)((float)((float)(v515 * v515) * v515)
                                                                        * (float)(v515 * v515)))
                                                        + (float)((float)((float)(v515 * v515) * v515)
                                                                * *(float *)(a1 + 5952)))
                                                + v515)
                                        * v513)
                                * *(float *)(a1 + 4768))
                        + (float)((float)(*(float *)(a1 + 4896) * *(float *)(a1 + 4736))
                                + (float)(v511 * *(float *)(a1 + 4752)));
  v518 = *(float *)(a1 + 5440);
  *(_DWORD *)(a1 + 4864) = v516;
  *(_DWORD *)(a1 + 4832) = v517;
  v519 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(*(float *)(a1 + 5312) + *(float *)(a1 + 5072))
                                                                                               * *(float *)(a1 + 5712))
                                                                                       + (float)((float)(v518 + *(float *)(a1 + 4944))
                                                                                               * *(float *)(a1 + 5696)))
                                                                               + (float)((float)(*(float *)(a1 + 5200)
                                                                                               + *(float *)(a1 + 5184))
                                                                                       * *(float *)(a1 + 5728)))
                                                                       + (float)((float)(*(float *)(a1 + 5328)
                                                                                       + *(float *)(a1 + 5056))
                                                                               * *(float *)(a1 + 5744)))
                                                               + (float)((float)(*(float *)(a1 + 5424)
                                                                               + *(float *)(a1 + 4960))
                                                                       * *(float *)(a1 + 5760)))
                                                       + (float)((float)(*(float *)(a1 + 5296) + *(float *)(a1 + 5088))
                                                               * *(float *)(a1 + 5776)))
                                               + (float)((float)(*(float *)(a1 + 5216) + *(float *)(a1 + 5168))
                                                       * *(float *)(a1 + 5792)))
                                       + (float)((float)(*(float *)(a1 + 5344) + *(float *)(a1 + 5040))
                                               * *(float *)(a1 + 5808)))
                               + (float)((float)(*(float *)(a1 + 5408) + *(float *)(a1 + 4976)) * *(float *)(a1 + 5824)))
                       + (float)((float)(*(float *)(a1 + 5104) + *(float *)(a1 + 5280)) * *(float *)(a1 + 5840)))
               + (float)((float)(*(float *)(a1 + 5232) + *(float *)(a1 + 5152)) * *(float *)(a1 + 5856)))
       + (float)((float)(*(float *)(a1 + 5024) + *(float *)(a1 + 5360)) * *(float *)(a1 + 5872));
  v520 = *(float *)(a1 + 5488);
  v521 = (float)(v520 * *(float *)(a1 + 6256)) + *(float *)(a1 + 5504);
  v522 = (float)((float)(v519 + (float)((float)(*(float *)(a1 + 5392) + *(float *)(a1 + 4992)) * *(float *)(a1 + 5888)))
               + (float)((float)(*(float *)(a1 + 5264) + *(float *)(a1 + 5120)) * *(float *)(a1 + 5904)))
       + (float)((float)(*(float *)(a1 + 5248) + *(float *)(a1 + 5136)) * *(float *)(a1 + 5920));
  v523 = (float)(*(float *)(a1 + 5376) + *(float *)(a1 + 5008)) * *(float *)(a1 + 5936);
  *(float *)(a1 + 5488) = v521;
  v524 = v522 + v523;
  v525 = v524 - (float)((float)(v520 * *(float *)(a1 + 6272)) + v521);
  *(float *)(a1 + 5472) = (float)(v525 * *(float *)(a1 + 6256)) + v520;
  v526 = (float)((float)((float)(v521 - (float)(v525 * *(float *)(a1 + 5456))) * *(float *)(a1 + 6336))
               - (float)(*(float *)(a1 + 6336) * v524))
       + v524;
  *(float *)(a1 + 4928) = v526;
  *(float *)(a1 + 3520) = v526;
  if ( *(float *)(a1 + 101504) == 1.0 )
  {
    *(_DWORD *)(a1 + 320) = v528;
    *(_DWORD *)(a1 + 101504) = 0;
  }
  **a2 = *(_DWORD *)(a1 + 10672);
  result = *(unsigned int *)(a1 + 10672);
  *a2[1] = result;
  return result;
}

