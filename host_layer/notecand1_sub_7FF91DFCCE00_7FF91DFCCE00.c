// sub_7FF91DFCCE00 @ 0x7FF91DFCCE00 (RVA 0x7FF79DFCCE00)

__int64 __fastcall sub_7FF91DFCCE00(__int64 a1, _DWORD **a2)
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

  v2 = *(float *)(a1 + 10832);
  v528 = 0;
  if ( *(float *)(a1 + 101536) == 1.0 )
  {
    v528 = *(_DWORD *)(a1 + 10832);
    v2 = 0.0;
    *(_DWORD *)(a1 + 10832) = 0;
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
  v11 = *(float *)(a1 + 10720);
  v12 = *(float *)(a1 + 10688);
  v13 = v9 & 0xFFFFFF;
  v14 = *(float *)(a1 + 10880);
  v15 = v9;
  v16 = *(float *)(a1 + 10896);
  v17 = v9 | 0xFF000000;
  v18 = v6 * v7;
  *(_DWORD *)(a1 + 10944) = 0;
  *(float *)(a1 + 10736) = v11;
  v19 = 0.0;
  if ( (v15 & 0x1000000) == 0 )
    v17 = v13;
  *(float *)(a1 + 10704) = v12;
  *(_DWORD *)(a1 + 84384) = *(_DWORD *)(a1 + 84368);
  *(_DWORD *)(a1 + 11024) = *(_DWORD *)(a1 + 11008);
  *(float *)(a1 + 10864) = v2;
  v20 = (float)v17 * 0.000000059604645;
  *(float *)(a1 + 10912) = v14;
  *(float *)(a1 + 10928) = v16;
  *(float *)(a1 + 84336) = v20;
  v21 = (float)(v20 * *(float *)(a1 + 84400)) + *(float *)(a1 + 84416);
  *(float *)(a1 + 84368) = v21;
  v22 = v18 - (float)(v7 * v21);
  v23 = *(float *)(a1 + 10784);
  *(float *)(a1 + 10800) = v23;
  v24 = v22 + v21;
  v25 = *(float *)(a1 + 10752);
  v26 = v23 * v25;
  *(float *)(a1 + 10768) = v25;
  *(float *)(a1 + 84432) = v24;
  v27 = *(float *)(a1 + 10816);
  *(float *)(a1 + 10848) = v27;
  *(float *)(a1 + 10960) = v26;
  v28 = (float)((float)(v12 * v26) - (float)(v26 * v27)) + v27;
  v29 = (float)((float)(v11 * v26) - (float)(v2 * v26)) + v2;
  *(float *)(a1 + 10976) = v28;
  *(float *)(a1 + 10992) = v29;
  v30 = v29;
  v31 = v29 + *(float *)(a1 + 11056);
  if ( v31 < 0.0 )
    v32 = v31;
  else
    v32 = 0.0;
  v33 = -1.0;
  if ( v30 == 0.0 )
    v34 = -1.0;
  else
    v34 = v32;
  *(float *)(a1 + 11008) = v34;
  if ( v34 >= 0.0 )
  {
    if ( v34 > 0.0 )
      v34 = 1.0;
  }
  else
  {
    v34 = -1.0;
  }
  v35 = *(float *)(a1 + 11120);
  v36 = v34 + 1.0;
  v37 = *(float *)(a1 + 11280);
  v38 = *(float *)(a1 + 11136);
  v39 = *(_DWORD *)(a1 + 11072);
  v40 = *(float *)(a1 + 11216);
  v41 = v38 + *(float *)(a1 + 11296);
  v42 = 1.0;
  *(float *)(a1 + 11040) = v36;
  *(float *)(a1 + 11072) = v36;
  *(_DWORD *)(a1 + 11088) = v39;
  *(float *)(a1 + 11232) = v40;
  v43 = (float)(v36 * v35) - v35;
  v44 = *(float *)(a1 + 11328);
  v45 = (float)(v43 + 1.0) * *(float *)(a1 + 11104);
  v46 = (float)(*(float *)(a1 + 11184) / (float)((float)(v37 * v38) + *(float *)(a1 + 11312))) * v37;
  v47 = *(float *)(a1 + 11168);
  *(float *)(a1 + 11248) = v45;
  v48 = v47 - v46;
  v49 = *(float *)(a1 + 11200);
  v50 = (float)(v48 + v28) - v40;
  *(float *)(a1 + 11168) = v50;
  v51 = v50 * v41;
  *(float *)(a1 + 11184) = v51;
  v52 = v51 + v40;
  if ( (float)(v44 - fabs(v40 - v28)) < 0.0 )
  {
    v53 = 0.0;
LABEL_25:
    v54 = v53;
    goto LABEL_26;
  }
  v53 = v49 + *(float *)(a1 + 11344);
  if ( v53 < 1.0 )
    goto LABEL_25;
  v54 = 1.0;
LABEL_26:
  v55 = v54;
  *(float *)(a1 + 11200) = v55;
  v56 = (float)((float)(v55 * v28) - (float)(v55 * v52)) + v52;
  if ( v45 == 0.0 )
    v56 = v28;
  v57 = v16 * *(float *)(a1 + 11376);
  *(_DWORD *)(a1 + 11408) = *(_DWORD *)(a1 + 11392);
  v58 = *(float *)(a1 + 11680);
  v59 = *(float *)(a1 + 11424);
  v60 = *(_DWORD *)(a1 + 11520);
  v61 = v57 + (float)(v14 * *(float *)(a1 + 11360));
  v62 = *(_DWORD *)(a1 + 11488);
  v63 = (int)v58;
  *(float *)(a1 + 11392) = v61;
  v64 = *(float *)(a1 + 11456);
  *(float *)(a1 + 11216) = v56;
  *(float *)(a1 + 11264) = v56;
  v65 = *(float *)(a1 + 11616);
  *(float *)(a1 + 11472) = v64;
  *(float *)(a1 + 11440) = v59;
  *(_DWORD *)(a1 + 11504) = v62;
  *(_DWORD *)(a1 + 11536) = v60;
  *(float *)(a1 + 11632) = v65;
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
  v67 = *(float *)(a1 + 11552);
  v68 = (float)((float)(v59 - v65) * *(float *)(a1 + 11664)) + v65;
  v69 = *(float *)(a1 + 11600);
  *(float *)(a1 + 11616) = v68;
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
  v74 = *(float *)(a1 + 11568);
  v75 = expf((float)v73 * *(float *)(a1 + 11712)) * *(float *)(a1 + 11696);
  v76 = v74 * *(float *)(a1 + 11584);
  *(_DWORD *)(a1 + 12096) = *(_DWORD *)(a1 + 12080);
  v77 = v75 + *(float *)(a1 + 11728);
  v78 = *(float *)(a1 + 12016);
  v79 = v64 * *(float *)(a1 + 12416);
  *(_DWORD *)(a1 + 12128) = *(_DWORD *)(a1 + 12112);
  v80 = *(float *)(a1 + 12000);
  v81 = *(float *)(a1 + 12048);
  *(_DWORD *)(a1 + 12160) = *(_DWORD *)(a1 + 12144);
  v82 = *(_DWORD *)(a1 + 84432);
  *(float *)(a1 + 12032) = v78;
  *(float *)(a1 + 12016) = v80;
  *(float *)(a1 + 12064) = v81;
  *(_DWORD *)(a1 + 11952) = v62;
  *(_DWORD *)(a1 + 11968) = v60;
  *(_DWORD *)(a1 + 11936) = v82;
  v83 = (float)(v76 - (float)(v74 * v77)) + v77;
  v84 = *(float *)(a1 + 12368);
  v85 = v79 + v84;
  *(float *)(a1 + 12352) = v84;
  *(float *)(a1 + 11648) = v83;
  if ( v85 >= -1.0 )
    v86 = fminf(v85, 1.0);
  else
    v86 = -1.0;
  v87 = *(float *)(a1 + 12640);
  *(float *)(a1 + 12000) = v86;
  v88 = fminf(v87, v83 * 0.000015258789);
  v89 = (float)((float)(1.0 - v78) * *(float *)(a1 + 12432)) + v78;
  if ( v89 >= -1.0 )
    v90 = fminf(v89, 1.0);
  else
    v90 = -1.0;
  v91 = v88 * *(float *)(a1 + 12656);
  v92 = v80 - v86;
  *(float *)(a1 + 12176) = v91;
  v93 = v91 + v81;
  if ( v92 < 0.0 )
    v90 = 0.0;
  v94 = *(float *)(a1 + 12384);
  v95 = *(float *)(a1 + 11936);
  *(float *)(a1 + 12016) = v90;
  v96 = v90 + *(float *)(a1 + 12784);
  if ( v92 >= 0.0 )
    v94 = 1.0;
  v97 = v96 * *(float *)(a1 + 12768);
  v98 = (float)(v93 * v94) * *(float *)(a1 + 12400);
  if ( v97 <= 0.0 )
    v99 = 0.0;
  else
    v99 = v97;
  v100 = v99;
  v101 = (float)((float)(v95 - *(float *)(a1 + 12096)) * *(float *)(a1 + 12976)) + *(float *)(a1 + 12096);
  *(float *)(a1 + 12080) = v101;
  *(float *)(a1 + 11984) = v100;
  v529 = *(float *)(a1 + 12064);
  v102 = (float)((float)((float)(v101 * *(float *)(a1 + 12960)) * *(float *)(a1 + 12576))
               - (float)(v95 * *(float *)(a1 + 12576)))
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
  v103 = *(float *)(a1 + 12128);
  *(float *)(a1 + 12048) = v98;
  v104 = v98 + *(float *)(a1 + 12800);
  *(float *)(a1 + 11920) = v102 * *(float *)(a1 + 12944);
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
  *(float *)(a1 + 12112) = v103;
  v105 = v103 * *(float *)(a1 + 12928);
  v106 = (float)(v104 * *(float *)(a1 + 12864)) + *(float *)(a1 + 12992);
  *(float *)(a1 + 12192) = v106;
  *(float *)(a1 + 12272) = v105;
  v107 = v98 + *(float *)(a1 + 12832);
  *(float *)(a1 + 12208) = -v106;
  if ( v107 <= 1.0 )
  {
    if ( v107 < -1.0 )
      fmodf(v107 - 1.0, 2.0);
  }
  else
  {
    fmodf(v107 + 1.0, 2.0);
  }
  v108 = v98 + *(float *)(a1 + 12816);
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
  v110 = v108 + *(float *)(a1 + 13008);
  v111 = v109 * *(float *)(a1 + 12896);
  if ( v110 >= 0.0 )
  {
    if ( v110 > 0.0 )
      v110 = 1.0;
  }
  else
  {
    v110 = -1.0;
  }
  v112 = v98 + *(float *)(a1 + 12848);
  *(float *)(a1 + 12240) = v111;
  *(float *)(a1 + 12336) = v110;
  v113 = (float)(v110 * *(float *)(a1 + 12880)) + *(float *)(a1 + 13024);
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
  *(float *)(a1 + 12224) = v113;
  v115 = *(float *)(a1 + 12480);
  v116 = (float)((float)(*(float *)(a1 + 12544) * *(float *)(a1 + 12272))
               + (float)(*(float *)(a1 + 12512) * *(float *)(a1 + 12192)))
       + (float)(*(float *)(a1 + 12528) * *(float *)(a1 + 12208));
  v117 = (float)((float)((float)((float)(v114 * (float)((float)(v114 * v114) * v114)) * *(float *)(a1 + 12736))
                       + (float)((float)((float)((float)(v114 * v114) * v114) * *(float *)(a1 + 12720))
                               + (float)((float)((float)(v114 * *(float *)(a1 + 12688)) + *(float *)(a1 + 12672))
                                       + (float)((float)(v114 * v114) * *(float *)(a1 + 12704)))))
               + *(float *)(a1 + 12752))
       * *(float *)(a1 + 12912);
  *(float *)(a1 + 12256) = v117;
  v118 = (float)(v115 * *(float *)(a1 + 12240)) + v116;
  v119 = *(float *)(a1 + 12592);
  v120 = (float)((float)(*(float *)(a1 + 12448) * *(float *)(a1 + 11984)) - *(float *)(a1 + 12448)) + 1.0;
  v121 = (float)((float)(v118 + (float)(*(float *)(a1 + 12496) * *(float *)(a1 + 12224)))
               + (float)(v117 * *(float *)(a1 + 12464)))
       + (float)(*(float *)(a1 + 12560) * *(float *)(a1 + 11920));
  *(float *)(a1 + 12288) = v120;
  *(float *)(a1 + 12320) = v121;
  *(float *)(a1 + 12304) = (float)((float)(*(float *)(a1 + 12608) * *(float *)(a1 + 11952))
                                 + (float)(*(float *)(a1 + 12624) * *(float *)(a1 + 11968)))
                         + (float)((float)(v119 * v120) * v121);
  v122 = *(_DWORD *)(a1 + 12320);
  *(_DWORD *)(a1 + 13040) = *(_DWORD *)(a1 + 12336);
  *(_DWORD *)(a1 + 13056) = v122;
  if ( *(float *)(a1 + 12336) <= 0.0 )
    v123 = 0.0;
  else
    v123 = 1.0;
  if ( *(float *)(a1 + 13072) == 0.0 )
    v123 = 1.0;
  v124 = *(float *)(a1 + 11072) * v123;
  *(float *)(a1 + 13088) = v124;
  *(_DWORD *)(a1 + 13120) = *(_DWORD *)(a1 + 13104);
  *(_DWORD *)(a1 + 13168) = *(_DWORD *)(a1 + 13152);
  *(_DWORD *)(a1 + 13152) = *(_DWORD *)(a1 + 13136);
  *(_DWORD *)(a1 + 13200) = *(_DWORD *)(a1 + 13184);
  *(_DWORD *)(a1 + 13248) = *(_DWORD *)(a1 + 13232);
  if ( (float)(v124 + *(float *)(a1 + 13376)) >= 0.0 )
    v125 = 0.0;
  else
    v125 = 1.0;
  v126 = 1.0 - v125;
  v127 = (float)(1.0 - v125)
       * (float)((float)(*(float *)(a1 + 13408) * *(float *)(a1 + 13168)) + *(float *)(a1 + 13120));
  *(float *)(a1 + 13136) = v127;
  v128 = v127 + *(float *)(a1 + 13392);
  v129 = v127 - *(float *)(a1 + 13152);
  *(float *)(a1 + 13216) = (float)((float)(*(float *)(a1 + 13360) * *(float *)(a1 + 13472))
                                 - (float)(*(float *)(a1 + 13440) * *(float *)(a1 + 13360)))
                         + *(float *)(a1 + 13440);
  if ( v128 < 0.0 )
    v130 = 0.0;
  else
    v130 = 1.0;
  if ( v129 < 0.0 )
    v130 = 1.0 - v125;
  v131 = *(float *)(a1 + 13296);
  v132 = v126 * (float)(*(float *)(a1 + 13312) * *(float *)(a1 + 13440));
  *(float *)(a1 + 13152) = v130;
  v133 = *(float *)(a1 + 13200);
  v134 = (float)(v132 - (float)(*(float *)(a1 + 13456) * v126)) + *(float *)(a1 + 13456);
  v135 = v126 * (float)(1.0 - v130);
  v136 = (float)((float)(*(float *)(a1 + 13328) * 0.00390625) * v130) + (float)((float)(v131 * 0.00390625) * v135);
  if ( (float)(v134 - v133) > 0.0 )
    v134 = v133 + *(float *)(a1 + 13216);
  v137 = *(float *)(a1 + 13120);
  v138 = fminf(*(float *)(a1 + 13440), v134);
  *(float *)(a1 + 13184) = v138;
  v139 = *(float *)(a1 + 13344);
  v140 = (float)((float)(v135 * *(float *)(a1 + 13424)) + (float)(v130 * v138)) - v137;
  v141 = (float)((float)(*(float *)(a1 + 13488) * v136) - (float)(*(float *)(a1 + 13488) * *(float *)(a1 + 13248)))
       + *(float *)(a1 + 13248);
  *(float *)(a1 + 13232) = v141;
  v142 = (float)((float)((float)((float)((float)(v139 * 0.00390625) * v125) - (float)(v125 * v141)) + v141) * v140)
       + v137;
  *(float *)(a1 + 13104) = v142;
  v143 = (float)(v142 * *(float *)(a1 + 13504)) * *(float *)(a1 + 13520);
  v144 = v143 * *(float *)(a1 + 13536);
  *(float *)(a1 + 13264) = v143;
  *(float *)(a1 + 13280) = v144;
  if ( *(float *)(a1 + 12336) <= 0.0 )
    v145 = 0.0;
  else
    v145 = 1.0;
  if ( *(float *)(a1 + 13552) == 0.0 )
    v145 = 1.0;
  v146 = *(float *)(a1 + 11072) * v145;
  *(float *)(a1 + 13568) = v146;
  *(_DWORD *)(a1 + 13600) = *(_DWORD *)(a1 + 13584);
  *(_DWORD *)(a1 + 13648) = *(_DWORD *)(a1 + 13632);
  *(_DWORD *)(a1 + 13632) = *(_DWORD *)(a1 + 13616);
  *(_DWORD *)(a1 + 13680) = *(_DWORD *)(a1 + 13664);
  *(_DWORD *)(a1 + 13728) = *(_DWORD *)(a1 + 13712);
  if ( (float)(v146 + *(float *)(a1 + 13856)) >= 0.0 )
    v147 = 0.0;
  else
    v147 = 1.0;
  v148 = 1.0 - v147;
  v149 = (float)(1.0 - v147)
       * (float)((float)(*(float *)(a1 + 13888) * *(float *)(a1 + 13648)) + *(float *)(a1 + 13600));
  *(float *)(a1 + 13616) = v149;
  v150 = v149 + *(float *)(a1 + 13872);
  v151 = v149 - *(float *)(a1 + 13632);
  *(float *)(a1 + 13696) = (float)((float)(*(float *)(a1 + 13840) * *(float *)(a1 + 13952))
                                 - (float)(*(float *)(a1 + 13920) * *(float *)(a1 + 13840)))
                         + *(float *)(a1 + 13920);
  if ( v150 < 0.0 )
    v152 = 0.0;
  else
    v152 = 1.0;
  if ( v151 < 0.0 )
    v152 = 1.0 - v147;
  v153 = *(float *)(a1 + 13792) * *(float *)(a1 + 13920);
  v154 = *(float *)(a1 + 13776);
  *(float *)(a1 + 13632) = v152;
  v155 = *(float *)(a1 + 13680);
  v156 = (float)((float)(v148 * v153) - (float)(*(float *)(a1 + 13936) * v148)) + *(float *)(a1 + 13936);
  v157 = v148 * (float)(1.0 - v152);
  v158 = (float)((float)(*(float *)(a1 + 13808) * 0.00390625) * v152) + (float)((float)(v154 * 0.00390625) * v157);
  if ( (float)(v156 - v155) > 0.0 )
    v156 = v155 + *(float *)(a1 + 13696);
  v159 = *(float *)(a1 + 13600);
  v160 = fminf(*(float *)(a1 + 13920), v156);
  *(float *)(a1 + 13664) = v160;
  v161 = (float)(*(float *)(a1 + 13824) * 0.00390625) * v147;
  v162 = (float)((float)(v157 * *(float *)(a1 + 13904)) + (float)(v152 * v160)) - v159;
  v163 = (float)((float)(*(float *)(a1 + 13968) * v158) - (float)(*(float *)(a1 + 13968) * *(float *)(a1 + 13728)))
       + *(float *)(a1 + 13728);
  *(float *)(a1 + 13712) = v163;
  v164 = (float)((float)((float)(v161 - (float)(v147 * v163)) + v163) * v162) + v159;
  *(float *)(a1 + 13584) = v164;
  v165 = (float)(v164 * *(float *)(a1 + 13984)) * *(float *)(a1 + 14000);
  v166 = v165 * *(float *)(a1 + 14016);
  *(float *)(a1 + 13744) = v165;
  *(float *)(a1 + 13760) = v166;
  *(_DWORD *)(a1 + 14048) = *(_DWORD *)(a1 + 14032);
  *(_DWORD *)(a1 + 14080) = *(_DWORD *)(a1 + 14064);
  v167 = *(float *)(a1 + 11264);
  v168 = *(float *)(a1 + 11392);
  *(_DWORD *)(a1 + 14144) = *(_DWORD *)(a1 + 14128);
  v169 = (float)(v168 * *(float *)(a1 + 14112)) + (float)(v167 * *(float *)(a1 + 14096));
  *(float *)(a1 + 14128) = v169;
  v170 = *(float *)(a1 + 12304);
  v171 = *(_DWORD *)(a1 + 13264);
  v172 = *(_DWORD *)(a1 + 13744);
  v173 = *(_DWORD *)(a1 + 11264);
  *(_DWORD *)(a1 + 14192) = *(_DWORD *)(a1 + 14064);
  *(_DWORD *)(a1 + 14208) = v173;
  v174 = *(float *)(a1 + 14528);
  *(_DWORD *)(a1 + 14160) = v171;
  *(_DWORD *)(a1 + 14176) = v172;
  v175 = *(float *)(a1 + 14496);
  v176 = v170 * v174;
  v177 = v174 * *(float *)(a1 + 12320);
  *(float *)(a1 + 14224) = v177;
  v178 = *(float *)(a1 + 14624);
  v179 = *(float *)(a1 + 14368);
  v180 = v176 * *(float *)(a1 + 14544);
  v181 = *(float *)(a1 + 14560);
  v182 = (float)(v175 * v177) * *(float *)(a1 + 14512);
  *(float *)(a1 + 14256) = v182;
  v183 = *(float *)(a1 + 14384);
  v184 = (float)((float)((float)(v179 * *(float *)(a1 + 14192)) - (float)(v178 * v179)) + v178) * *(float *)(a1 + 14640);
  *(float *)(a1 + 14272) = v184;
  v185 = (float)((float)(v181 * v180) + v182) + (float)(v183 * v184);
  v186 = *(float *)(a1 + 14224);
  v187 = *(_DWORD *)(a1 + 14352);
  *(float *)(a1 + 14288) = (float)((float)((float)((float)((float)((float)(*(float *)(a1 + 14592)
                                                                         * *(float *)(a1 + 14176))
                                                                 + (float)(*(float *)(a1 + 14576)
                                                                         * *(float *)(a1 + 14160)))
                                                         * *(float *)(a1 + 14608))
                                                 + v185)
                                         + v169)
                                 + *(float *)(a1 + 14464))
                         + *(float *)(a1 + 14480);
  *(_DWORD *)(a1 + 14304) = v187;
  v188 = (float)(*(float *)(a1 + 14256) + *(float *)(a1 + 14208)) + *(float *)(a1 + 14272);
  *(float *)(a1 + 14320) = (float)((float)((float)((float)((float)((float)(v186 * *(float *)(a1 + 14672))
                                                                 + *(float *)(a1 + 14688))
                                                         * *(float *)(a1 + 14400))
                                                 + (float)(*(float *)(a1 + 14416) * *(float *)(a1 + 14160)))
                                         + (float)(*(float *)(a1 + 14432) * *(float *)(a1 + 14176)))
                                 + *(float *)(a1 + 14448))
                         * *(float *)(a1 + 14656);
  *(float *)(a1 + 14336) = v188;
  v189 = *(_DWORD *)(a1 + 14720);
  *(_DWORD *)(a1 + 14752) = *(_DWORD *)(a1 + 14704);
  *(_DWORD *)(a1 + 14768) = v189;
  *(_DWORD *)(a1 + 14784) = *(_DWORD *)(a1 + 14736);
  v190 = *(float *)(a1 + 84432);
  *(_DWORD *)(a1 + 14832) = *(_DWORD *)(a1 + 14816);
  v191 = *(float *)(a1 + 14800);
  *(float *)(a1 + 14816) = v191;
  v192 = (float)(v191 * *(float *)(a1 + 14848)) + *(float *)(a1 + 14832);
  *(float *)(a1 + 14816) = v192;
  v193 = (float)(v191 * *(float *)(a1 + 14864)) + v192;
  v194 = v192 * *(float *)(a1 + 14912);
  v195 = v190 - v193;
  v196 = (float)(v195 * *(float *)(a1 + 14848)) + v191;
  *(float *)(a1 + 14800) = v196;
  *(float *)(a1 + 14832) = (float)((float)(v195 * *(float *)(a1 + 14880)) + v194)
                         + (float)(v196 * *(float *)(a1 + 14896));
  *(_DWORD *)(a1 + 16944) = *(_DWORD *)(a1 + 16928);
  v197 = *(float *)(a1 + 16960);
  *(float *)(a1 + 16976) = v197;
  v198 = v197 * *(float *)(a1 + 14048);
  v199 = *(float *)(a1 + 16944) * *(float *)(a1 + 14832);
  *(float *)(a1 + 16992) = v198;
  *(float *)(a1 + 17008) = v199;
  *(_DWORD *)(a1 + 17072) = *(_DWORD *)(a1 + 17056);
  *(float *)(a1 + 17056) = (float)(v199 * *(float *)(a1 + 17040)) + (float)(v198 * *(float *)(a1 + 17024));
  *(_DWORD *)(a1 + 17104) = *(_DWORD *)(a1 + 17088);
  *(_DWORD *)(a1 + 17136) = *(_DWORD *)(a1 + 17120);
  *(_DWORD *)(a1 + 17168) = *(_DWORD *)(a1 + 17152);
  *(_DWORD *)(a1 + 17200) = *(_DWORD *)(a1 + 17184);
  v200 = (float)((float)(*(float *)(a1 + 17232) * *(float *)(a1 + 17088))
               - (float)(*(float *)(a1 + 17248) * *(float *)(a1 + 17232)))
       + *(float *)(a1 + 17248);
  v201 = (float)((float)((float)((float)(v200 * v200) * v200) * v200) * *(float *)(a1 + 17328))
       + (float)((float)((float)((float)(v200 * v200) * v200) * *(float *)(a1 + 17312))
               + (float)((float)((float)(v200 * *(float *)(a1 + 17280)) + *(float *)(a1 + 17264))
                       + (float)((float)(v200 * v200) * *(float *)(a1 + 17296))));
  if ( v201 <= 0.0 )
    v202 = 0.0;
  else
    v202 = v201;
  v203 = v202;
  if ( v203 < 1.0 )
    v42 = v203;
  v204 = v42;
  *(float *)(a1 + 17216) = v204;
  *(_DWORD *)(a1 + 17360) = *(_DWORD *)(a1 + 17344);
  v205 = *(float *)(a1 + 17376);
  *(float *)(a1 + 17392) = v205;
  v206 = *(float *)(a1 + 17408);
  *(float *)(a1 + 17424) = v206;
  *(float *)(a1 + 17408) = (float)((float)(v205 - v206) * *(float *)(a1 + 17440)) + v206;
  v207 = *(float *)(a1 + 11264);
  v208 = *(float *)(a1 + 11392);
  *(_DWORD *)(a1 + 17504) = *(_DWORD *)(a1 + 17488);
  *(float *)(a1 + 17488) = (float)(v208 * *(float *)(a1 + 17472)) + (float)(v207 * *(float *)(a1 + 17456));
  *(_DWORD *)(a1 + 17552) = *(_DWORD *)(a1 + 17520);
  v209 = *(float *)(a1 + 17536);
  *(float *)(a1 + 17568) = v209;
  v210 = *(float *)(a1 + 13264)
       + (float)((float)(*(float *)(a1 + 17552) * *(float *)(a1 + 13744))
               - (float)(*(float *)(a1 + 17552) * *(float *)(a1 + 13264)));
  *(float *)(a1 + 17584) = (float)((float)(v209 * *(float *)(a1 + 17152)) - (float)(v209 * v210)) + v210;
  v211 = *(float *)(a1 + 12304);
  v212 = *(float *)(a1 + 17600);
  *(float *)(a1 + 17616) = v212;
  v213 = v211 - v212;
  v214 = (float)(v213 * *(float *)(a1 + 17632)) + v212;
  v215 = *(float *)(a1 + 17664);
  *(float *)(a1 + 17600) = v214;
  *(float *)(a1 + 17616) = (float)(v213 * *(float *)(a1 + 17648)) + (float)(v215 * v214);
  v216 = *(float *)(a1 + 17680);
  v217 = *(float *)(a1 + 12320);
  *(float *)(a1 + 17696) = v216;
  v218 = v217 - v216;
  v219 = (float)(v218 * *(float *)(a1 + 17712)) + v216;
  v220 = *(float *)(a1 + 17744);
  *(float *)(a1 + 17680) = v219;
  v221 = (float)(v218 * *(float *)(a1 + 17728)) + (float)(v220 * v219);
  *(float *)(a1 + 17696) = v221;
  v222 = *(float *)(a1 + 17616);
  v223 = *(float *)(a1 + 17584);
  v224 = *(float *)(a1 + 17488);
  v227 = (__m128)*(unsigned int *)(a1 + 17120);
  *(_DWORD *)(a1 + 17760) = *(_DWORD *)(a1 + 17408);
  *(_DWORD *)(a1 + 17776) = v227.m128_i32[0];
  v225 = *(float *)(a1 + 17808);
  v226 = *(float *)(a1 + 17824) * *(float *)(a1 + 17184);
  v227.m128_f32[0] = (float)((float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 17840))
                                                   - (float)(*(float *)(a1 + 17968) * *(float *)(a1 + 17840)))
                                           + *(float *)(a1 + 17968))
                                   * *(float *)(a1 + 17984))
                           + (float)((float)((float)(*(float *)(a1 + 17952) + *(float *)(a1 + 17760))
                                           * *(float *)(a1 + 18016))
                                   * *(float *)(a1 + 17936)))
                   + (float)((float)((float)((float)((float)((float)(v226
                                                                   - (float)(*(float *)(a1 + 17824)
                                                                           * (float)(v221 * v225)))
                                                           + (float)(v221 * v225))
                                                   * *(float *)(a1 + 17872))
                                           * *(float *)(a1 + 17888))
                                   + (float)((float)((float)(v226
                                                           - (float)(*(float *)(a1 + 17824) * (float)(v222 * v225)))
                                                   + (float)(v222 * v225))
                                           * *(float *)(a1 + 17856)))
                           + (float)((float)((float)(v224 + *(float *)(a1 + 18000)) * *(float *)(a1 + 17920))
                                   + (float)(v223 * *(float *)(a1 + 17904))));
  *(_DWORD *)(a1 + 17792) = v227.m128_i32[0];
  v228 = *(float *)(a1 + 17216);
  v229 = *(float *)(a1 + 17360);
  *(_DWORD *)(a1 + 18096) = *(_DWORD *)(a1 + 18080);
  v230 = *(float *)(a1 + 18064);
  *(float *)(a1 + 18080) = v230;
  if ( *(float *)(a1 + 18144) == 1.0 )
  {
    v231 = *(float *)(a1 + 18096)
         + (float)((float)(*(float *)(a1 + 18224) * v230) - (float)(*(float *)(a1 + 18224) * *(float *)(a1 + 18096)));
    *(float *)(a1 + 18080) = v231;
    v232 = (float)(v231 * *(float *)(a1 + 18208)) + *(float *)(a1 + 18112);
    *(float *)(a1 + 18064) = sub_7FF91DFC8D60();
    v233 = (float)(1.0 - v229) * *(float *)(a1 + 18240);
    *(float *)(a1 + 18048) = (float)(v229 * *(float *)(a1 + 18304)) + *(float *)(a1 + 18128);
    v227.m128_f32[0] = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 18192))
                                                         + (float)(v228 * *(float *)(a1 + 18160)))
                                                 + v232)
                                         + fminf(*(float *)(a1 + 18256), v233))
                                 + *(float *)(a1 + 18176),
                                   *(float *)(a1 + 18272)),
                                 *(float *)(a1 + 18288))
                             * *(float *)(a1 + 18336))
                     + *(float *)(a1 + 18352);
    v234 = v227.m128_f32[0];
    v235 = (int)v227.m128_f32[0];
    if ( (int)v227.m128_f32[0] != 0x80000000 && (float)v235 != v227.m128_f32[0] )
      v234 = (float)(v235 - (_mm_movemask_ps(_mm_unpacklo_ps(v227, v227)) & 1));
    v236 = v227.m128_f32[0] - v234;
    v237 = (float)(v236 * v236) * 0.25;
    v238 = (float)(expf(v234)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v236 * *(float *)(a1 + 18544)) + *(float *)(a1 + 18528)) * v237) + (float)(v236 * *(float *)(a1 + 18512))) + *(float *)(a1 + 18496)) * v237) + (float)(v236 * *(float *)(a1 + 18480)))
                                                                                                 + *(float *)(a1 + 18464))
                                                                                         * v237)
                                                                                 + (float)(v236 * *(float *)(a1 + 18448)))
                                                                         + *(float *)(a1 + 18432))
                                                                 * v237)
                                                         + (float)(v236 * *(float *)(a1 + 18416)))
                                                 + *(float *)(a1 + 18400))
                                         * v237)
                                 + (float)(v236 * *(float *)(a1 + 18384)))
                         + 1.0))
         * *(float *)(a1 + 18368);
    v239 = v238 * v238;
    v240 = (float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 18704))
                                                         + *(float *)(a1 + 18672))
                                                 * (float)(v239 * v239))
                                         + (float)((float)((float)(v238 * v238) * *(float *)(a1 + 18640))
                                                 + *(float *)(a1 + 18608)))
                                 * (float)((float)((float)(v238 * v238) * v238) * (float)(v238 * v238)))
                         + (float)((float)((float)(v238 * v238) * v238) * *(float *)(a1 + 18576)))
                 + v238)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 18688))
                                                                 + *(float *)(a1 + 18656))
                                                         * (float)(v239 * v239))
                                                 + (float)((float)(v238 * v238) * *(float *)(a1 + 18624)))
                                         + *(float *)(a1 + 18592))
                                 * (float)(v239 * v239))
                         + (float)((float)(v238 * v238) * *(float *)(a1 + 18560)))
                 + 1.0);
    v241 = v240 / (float)(v240 + 1.0);
    *(float *)(a1 + 18032) = v241;
  }
  else
  {
    v241 = *(float *)(a1 + 18032);
  }
  v242 = *(float *)(a1 + 17056);
  v243 = *(float *)(a1 + 18048);
  *(_DWORD *)(a1 + 18832) = *(_DWORD *)(a1 + 18816);
  *(_DWORD *)(a1 + 18816) = *(_DWORD *)(a1 + 18800);
  *(_DWORD *)(a1 + 18800) = *(_DWORD *)(a1 + 18784);
  *(_DWORD *)(a1 + 18784) = *(_DWORD *)(a1 + 18768);
  *(_DWORD *)(a1 + 18768) = *(_DWORD *)(a1 + 18752);
  *(_DWORD *)(a1 + 18752) = *(_DWORD *)(a1 + 18736);
  *(_DWORD *)(a1 + 18736) = *(_DWORD *)(a1 + 18720);
  *(_DWORD *)(a1 + 19056) = *(_DWORD *)(a1 + 19040);
  *(_DWORD *)(a1 + 19040) = *(_DWORD *)(a1 + 19024);
  *(_DWORD *)(a1 + 19024) = *(_DWORD *)(a1 + 19008);
  *(_DWORD *)(a1 + 19008) = *(_DWORD *)(a1 + 18992);
  *(_DWORD *)(a1 + 18992) = *(_DWORD *)(a1 + 18976);
  *(_DWORD *)(a1 + 18976) = *(_DWORD *)(a1 + 18960);
  *(_DWORD *)(a1 + 18960) = *(_DWORD *)(a1 + 18944);
  *(_DWORD *)(a1 + 19184) = *(_DWORD *)(a1 + 19168);
  *(_DWORD *)(a1 + 19168) = *(_DWORD *)(a1 + 19152);
  *(_DWORD *)(a1 + 19152) = *(_DWORD *)(a1 + 19136);
  *(_DWORD *)(a1 + 19136) = *(_DWORD *)(a1 + 19120);
  *(_DWORD *)(a1 + 19120) = *(_DWORD *)(a1 + 19104);
  *(_DWORD *)(a1 + 19104) = *(_DWORD *)(a1 + 19088);
  *(_DWORD *)(a1 + 19088) = *(_DWORD *)(a1 + 19072);
  *(_DWORD *)(a1 + 19312) = *(_DWORD *)(a1 + 19296);
  *(_DWORD *)(a1 + 19296) = *(_DWORD *)(a1 + 19280);
  *(_DWORD *)(a1 + 19280) = *(_DWORD *)(a1 + 19264);
  *(_DWORD *)(a1 + 19264) = *(_DWORD *)(a1 + 19248);
  *(_DWORD *)(a1 + 19248) = *(_DWORD *)(a1 + 19232);
  *(_DWORD *)(a1 + 19232) = *(_DWORD *)(a1 + 19216);
  *(_DWORD *)(a1 + 19216) = *(_DWORD *)(a1 + 19200);
  *(_DWORD *)(a1 + 19440) = *(_DWORD *)(a1 + 19424);
  *(_DWORD *)(a1 + 19424) = *(_DWORD *)(a1 + 19408);
  *(_DWORD *)(a1 + 19408) = *(_DWORD *)(a1 + 19392);
  *(_DWORD *)(a1 + 19392) = *(_DWORD *)(a1 + 19376);
  *(_DWORD *)(a1 + 19376) = *(_DWORD *)(a1 + 19360);
  *(_DWORD *)(a1 + 19360) = *(_DWORD *)(a1 + 19344);
  *(_DWORD *)(a1 + 19344) = *(_DWORD *)(a1 + 19328);
  *(_DWORD *)(a1 + 19472) = *(_DWORD *)(a1 + 19456);
  v244 = *(float *)(a1 + 19488);
  *(float *)(a1 + 19504) = v244;
  if ( *(float *)(a1 + 19568) == 1.0 )
  {
    v245 = (float)((float)((float)(v243 * *(float *)(a1 + 19680)) + 1.0) * (float)(v242 * *(float *)(a1 + 19648)))
         + (float)((float)-v244 * *(float *)(a1 + 19632));
    *(float *)(a1 + 19488) = sub_7FF91DFC8D60();
    *(float *)(a1 + 19456) = v245;
    v246 = 1.0 - (float)(v241 + v241);
    v247 = 1.0 / (float)((float)((float)((float)(v241 * v241) * (float)(v241 * v241)) * v243) + 1.0);
    *(float *)(a1 + 19536) = v247;
    v248 = *(float *)(a1 + 19456);
    v249 = *(float *)(a1 + 19472);
    *(float *)(a1 + 19520) = v247 * v243;
    v250 = v249 * *(float *)(a1 + 19728);
    v251 = *(float *)(a1 + 18816);
    v252 = v248 * *(float *)(a1 + 19744);
    v253 = *(float *)(a1 + 18832);
    *(float *)(a1 + 18928) = v251;
    v254 = (float)((float)(v250 + v252) * v247)
         - (float)((float)((float)(v251 * *(float *)(a1 + 20032)) + (float)(v253 * *(float *)(a1 + 20048)))
                 * (float)(v247 * v243));
    if ( v254 >= -1.0 )
      v255 = fminf(v254, 1.0);
    else
      v255 = -1.0;
    v256 = v255 + (float)((float)((float)((float)(v255 * v255) * v255) * v255) * (float)(v255 * *(float *)(a1 + 19696)));
    *(float *)(a1 + 18848) = v256;
    v257 = *(float *)(a1 + 18752);
    v258 = (float)(v241 * (float)(v256 + *(float *)(a1 + 18736))) + (float)(v257 * v246);
    *(float *)(a1 + 18864) = v258;
    v259 = *(float *)(a1 + 18768);
    v260 = v241 * (float)(v258 + v257);
    v261 = v241 * (float)((float)((float)(v241 * v256) + (float)(v246 * v258)) + v258);
    v262 = v260 + (float)(v259 * v246);
    *(float *)(a1 + 18880) = v262;
    v263 = *(float *)(a1 + 18784);
    v264 = (float)(v241 * (float)(v262 + v259)) + (float)(v263 * v246);
    *(float *)(a1 + 18896) = v264;
    v265 = (float)((float)(v263 + v264) * v241) + (float)(v246 * *(float *)(a1 + 18800));
    *(float *)(a1 + 18912) = v265;
    v266 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v261 + (float)(v246 * v262)) + v262))
                                 + (float)(v246 * v264))
                         + v264))
         + (float)(v246 * v265);
    v267 = (float)(*(float *)(a1 + 18896) * *(float *)(a1 + 19600)) + (float)(v265 * *(float *)(a1 + 19616));
    v268 = *(float *)(a1 + 19472);
    *(float *)(a1 + 19328) = v267 + (float)(*(float *)(a1 + 19584) * *(float *)(a1 + 18880));
    v269 = *(float *)(a1 + 18928);
    v270 = (float)((float)(v268 + *(float *)(a1 + 19456)) * *(float *)(a1 + 19760)) * *(float *)(a1 + 19536);
    *(float *)(a1 + 18928) = v266;
    v271 = v270
         - (float)((float)((float)(v266 * *(float *)(a1 + 20032)) + (float)(v269 * *(float *)(a1 + 20048)))
                 * *(float *)(a1 + 19520));
    if ( v271 >= -1.0 )
      v272 = fminf(v271, 1.0);
    else
      v272 = -1.0;
    v273 = v272 + (float)((float)((float)((float)(v272 * v272) * v272) * v272) * (float)(v272 * *(float *)(a1 + 19696)));
    v274 = *(float *)(a1 + 18848);
    *(float *)(a1 + 18848) = v273;
    v275 = *(float *)(a1 + 18864);
    v276 = (float)(v241 * (float)(v273 + v274)) + (float)(v275 * v246);
    *(float *)(a1 + 18864) = v276;
    v277 = *(float *)(a1 + 18880);
    v278 = v241 * (float)(v276 + v275);
    v279 = v241 * (float)((float)((float)(v241 * v273) + (float)(v246 * v276)) + v276);
    v280 = v278 + (float)(v277 * v246);
    *(float *)(a1 + 18880) = v280;
    v281 = *(float *)(a1 + 18896);
    v282 = (float)(v241 * (float)(v280 + v277)) + (float)(v281 * v246);
    *(float *)(a1 + 18896) = v282;
    v283 = (float)((float)(v281 + v282) * v241) + (float)(v246 * *(float *)(a1 + 18912));
    *(float *)(a1 + 18912) = v283;
    v284 = *(float *)(a1 + 19456);
    v285 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v279 + (float)(v246 * v280)) + v280))
                                 + (float)(v246 * v282))
                         + v282))
         + (float)(v246 * v283);
    v286 = (float)(*(float *)(a1 + 18896) * *(float *)(a1 + 19600)) + (float)(v283 * *(float *)(a1 + 19616));
    v287 = *(float *)(a1 + 19472);
    *(float *)(a1 + 19200) = v286 + (float)(*(float *)(a1 + 19584) * *(float *)(a1 + 18880));
    v288 = *(float *)(a1 + 18928);
    v289 = (float)((float)(v287 * *(float *)(a1 + 19744)) + (float)(v284 * *(float *)(a1 + 19728)))
         * *(float *)(a1 + 19536);
    *(float *)(a1 + 18928) = v285;
    v290 = v289
         - (float)((float)((float)(v285 * *(float *)(a1 + 20032)) + (float)(v288 * *(float *)(a1 + 20048)))
                 * *(float *)(a1 + 19520));
    if ( v290 >= -1.0 )
      v291 = fminf(v290, 1.0);
    else
      v291 = -1.0;
    v292 = v291 + (float)((float)((float)((float)(v291 * v291) * v291) * v291) * (float)(v291 * *(float *)(a1 + 19696)));
    v293 = *(float *)(a1 + 18848);
    *(float *)(a1 + 18848) = v292;
    v294 = *(float *)(a1 + 18864);
    v295 = (float)(v241 * (float)(v292 + v293)) + (float)(v294 * v246);
    *(float *)(a1 + 18864) = v295;
    v296 = *(float *)(a1 + 18880);
    v297 = v241 * (float)(v295 + v294);
    v298 = v241 * (float)((float)((float)(v241 * v292) + (float)(v246 * v295)) + v295);
    v299 = v297 + (float)(v296 * v246);
    *(float *)(a1 + 18880) = v299;
    v300 = *(float *)(a1 + 18896);
    v301 = (float)(v241 * (float)(v299 + v296)) + (float)(v300 * v246);
    *(float *)(a1 + 18896) = v301;
    v302 = (float)((float)(v300 + v301) * v241) + (float)(v246 * *(float *)(a1 + 18912));
    *(float *)(a1 + 18912) = v302;
    v303 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v298 + (float)(v246 * v299)) + v299))
                                 + (float)(v246 * v301))
                         + v301))
         + (float)(v246 * v302);
    v304 = (float)(*(float *)(a1 + 18896) * *(float *)(a1 + 19600)) + (float)(v302 * *(float *)(a1 + 19616));
    v305 = *(float *)(a1 + 19456);
    *(float *)(a1 + 19072) = v304 + (float)(*(float *)(a1 + 19584) * *(float *)(a1 + 18880));
    v306 = *(float *)(a1 + 18928);
    v307 = (float)(v305 * *(float *)(a1 + 19712)) * *(float *)(a1 + 19536);
    *(float *)(a1 + 18816) = v303;
    v308 = v307
         - (float)((float)((float)(v303 * *(float *)(a1 + 20032)) + (float)(v306 * *(float *)(a1 + 20048)))
                 * *(float *)(a1 + 19520));
    if ( v308 >= -1.0 )
      v309 = fminf(v308, 1.0);
    else
      v309 = -1.0;
    v310 = v309 + (float)((float)((float)((float)(v309 * v309) * v309) * v309) * (float)(v309 * *(float *)(a1 + 19696)));
    *(float *)(a1 + 18720) = v310;
    v311 = *(float *)(a1 + 18864);
    v312 = (float)(v241 * (float)(v310 + *(float *)(a1 + 18848))) + (float)(v311 * v246);
    *(float *)(a1 + 18736) = v312;
    v313 = *(float *)(a1 + 18880);
    v314 = v241 * (float)(v312 + v311);
    v315 = v241 * (float)((float)((float)(v241 * v310) + (float)(v246 * v312)) + v312);
    v316 = v314 + (float)(v313 * v246);
    *(float *)(a1 + 18752) = v316;
    v317 = *(float *)(a1 + 18896);
    v318 = (float)(v241 * (float)(v316 + v313)) + (float)(v317 * v246);
    *(float *)(a1 + 18768) = v318;
    v319 = (float)((float)(v317 + v318) * v241) + (float)(v246 * *(float *)(a1 + 18912));
    v320 = v241
         * (float)((float)((float)(v241 * (float)((float)(v315 + (float)(v246 * v316)) + v316)) + (float)(v246 * v318))
                 + v318);
    *(float *)(a1 + 18784) = v319;
    v321 = *(float *)(a1 + 18752);
    *(float *)(a1 + 18800) = v320 + (float)(v246 * v319);
    v322 = *(float *)(a1 + 19008);
    v323 = (float)((float)(v319 * *(float *)(a1 + 19616)) + (float)(*(float *)(a1 + 19600) * *(float *)(a1 + 18768)))
         + (float)(v321 * *(float *)(a1 + 19584));
    *(float *)(a1 + 18944) = v323;
    v324 = (float)(v323 + *(float *)(a1 + 19440)) * *(float *)(a1 + 19776);
    v325 = (float)(*(float *)(a1 + 19200) + *(float *)(a1 + 19184)) * *(float *)(a1 + 19808);
    v326 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v322 + *(float *)(a1 + 19376)) * *(float *)(a1 + 20016)) + (float)((float)(*(float *)(a1 + 19136) + *(float *)(a1 + 19248)) * *(float *)(a1 + 20000))) + (float)((float)(*(float *)(a1 + 19264) + *(float *)(a1 + 19120)) * *(float *)(a1 + 19984))) + (float)((float)(*(float *)(a1 + 18992) + *(float *)(a1 + 19392)) * *(float *)(a1 + 19968))) + (float)((float)(*(float *)(a1 + 19360) + *(float *)(a1 + 19024)) * *(float *)(a1 + 19952)))
                                                                                                 + (float)((float)(*(float *)(a1 + 19232) + *(float *)(a1 + 19152)) * *(float *)(a1 + 19936)))
                                                                                         + (float)((float)(*(float *)(a1 + 19280) + *(float *)(a1 + 19104))
                                                                                                 * *(float *)(a1 + 19920)))
                                                                                 + (float)((float)(*(float *)(a1 + 19408)
                                                                                                 + *(float *)(a1 + 18976))
                                                                                         * *(float *)(a1 + 19904)))
                                                                         + (float)((float)(*(float *)(a1 + 19344)
                                                                                         + *(float *)(a1 + 19040))
                                                                                 * *(float *)(a1 + 19888)))
                                                                 + (float)((float)(*(float *)(a1 + 19216)
                                                                                 + *(float *)(a1 + 19168))
                                                                         * *(float *)(a1 + 19872)))
                                                         + (float)((float)(*(float *)(a1 + 19296)
                                                                         + *(float *)(a1 + 19088))
                                                                 * *(float *)(a1 + 19856)))
                                                 + (float)((float)(*(float *)(a1 + 19424) + *(float *)(a1 + 18960))
                                                         * *(float *)(a1 + 19840)))
                                         + (float)((float)(*(float *)(a1 + 19328) + *(float *)(a1 + 19056))
                                                 * *(float *)(a1 + 19824)))
                                 + v325)
                         + (float)((float)(*(float *)(a1 + 19312) + *(float *)(a1 + 19072)) * *(float *)(a1 + 19792)))
                 + v324)
         * *(float *)(a1 + 19664);
    *(float *)(a1 + 19552) = v326;
  }
  *(_DWORD *)(a1 + 20080) = *(_DWORD *)(a1 + 20064);
  v327 = *(_DWORD *)(a1 + 20112);
  *(_DWORD *)(a1 + 20144) = *(_DWORD *)(a1 + 20096);
  *(_DWORD *)(a1 + 20160) = v327;
  *(_DWORD *)(a1 + 20176) = *(_DWORD *)(a1 + 20128);
  v328 = *(float *)(a1 + 20192);
  *(float *)(a1 + 20208) = v328;
  v329 = *(float *)(a1 + 20224);
  *(float *)(a1 + 20240) = v329;
  v330 = (float)((float)(v328 - v329) * *(float *)(a1 + 20256)) + v329;
  *(float *)(a1 + 20224) = v330;
  v331 = (float)((float)(v330 * *(float *)(a1 + 20160)) - (float)(*(float *)(a1 + 20160) * *(float *)(a1 + 20176)))
       + *(float *)(a1 + 20176);
  *(float *)(a1 + 20272) = v331;
  v332 = *(float *)(a1 + 20288);
  *(float *)(a1 + 20304) = v332;
  v333 = (float)((float)(*(float *)(a1 + 20320) * v331) - (float)(*(float *)(a1 + 20320) * v332)) + v332;
  if ( v333 <= 0.0 )
    v334 = 0.0;
  else
    v334 = v333;
  v335 = v334;
  *(float *)(a1 + 20288) = v335;
  v336 = *(float *)(a1 + 20336);
  *(float *)(a1 + 20352) = v336;
  v337 = *(float *)(a1 + 20368);
  *(float *)(a1 + 20384) = v337;
  v338 = (float)((float)(*(float *)(a1 + 20400) * v336) - (float)(*(float *)(a1 + 20400) * v337)) + v337;
  if ( v338 <= 0.0 )
    v339 = 0.0;
  else
    v339 = v338;
  v340 = v339;
  *(float *)(a1 + 20368) = v340;
  v341 = *(float *)(a1 + 20416);
  v342 = *(float *)(a1 + 11072);
  *(float *)(a1 + 20432) = v341;
  v343 = v341 * *(float *)(a1 + 20512);
  v344 = v341 + *(float *)(a1 + 20496);
  if ( v343 >= -1.0 )
    v345 = fminf(v343, 1.0);
  else
    v345 = -1.0;
  if ( (float)(v341 + *(float *)(a1 + 20464)) >= 0.0 )
    v344 = (float)((float)(*(float *)(a1 + 20480) * v342) - (float)(*(float *)(a1 + 20480) * v341)) + v341;
  v346 = (float)((float)(v345 * *(float *)(a1 + 20528)) - (float)(*(float *)(a1 + 20544) * v345))
       + *(float *)(a1 + 20544);
  v347 = (float)((float)(v346 * v342) - (float)(v346 * v341)) + v341;
  if ( v342 != 0.0 )
    v347 = v344;
  *(float *)(a1 + 20448) = v347;
  *(float *)(a1 + 20416) = v347;
  v348 = *(float *)(a1 + 19552);
  v349 = *(float *)(a1 + 13264);
  v350 = *(float *)(a1 + 17360);
  v351 = *(_DWORD *)(a1 + 13744);
  v352 = *(_DWORD *)(a1 + 20064);
  *(_DWORD *)(a1 + 20624) = *(_DWORD *)(a1 + 20608);
  *(_DWORD *)(a1 + 20656) = *(_DWORD *)(a1 + 20640);
  *(_DWORD *)(a1 + 20560) = v351;
  *(_DWORD *)(a1 + 20576) = v352;
  v353 = *(float *)(a1 + 20624);
  v354 = *(float *)(a1 + 20688);
  *(float *)(a1 + 20592) = v350 * *(float *)(a1 + 20848);
  v355 = v348 - v353;
  v356 = *(float *)(a1 + 20720);
  v357 = (float)(v349 * *(float *)(a1 + 20704)) + (float)(v354 * *(float *)(a1 + 20448));
  v358 = v353 + (float)((float)(v348 - v353) * *(float *)(a1 + 20752));
  *(float *)(a1 + 20608) = v358;
  v359 = (float)(v355 * *(float *)(a1 + 20864)) + (float)(v358 * *(float *)(a1 + 20880));
  v360 = (float)((float)(*(float *)(a1 + 20736) * *(float *)(a1 + 20576))
               - (float)(*(float *)(a1 + 20736) * (float)(v357 + (float)(v356 * *(float *)(a1 + 20560)))))
       + (float)(v357 + (float)(v356 * *(float *)(a1 + 20560)));
  v361 = *(float *)(a1 + 20768);
  v362 = v360 * *(float *)(a1 + 20816);
  v363 = v348 * (float)(1.0 - v361);
  if ( v362 <= 0.0 )
    v364 = 0.0;
  else
    v364 = v362;
  v365 = *(float *)(a1 + 20784);
  v366 = v364;
  v367 = v366 * *(float *)(a1 + 20832);
  v368 = (float)((float)(v361 * v359) + v363) * (float)(*(float *)(a1 + 20592) + 1.0);
  v369 = *(float *)(a1 + 20800) * v368;
  v370 = *(float *)(a1 + 20656)
       + (float)((float)(*(float *)(a1 + 20896) * v368) - (float)(*(float *)(a1 + 20896) * *(float *)(a1 + 20656)));
  *(float *)(a1 + 20640) = v370;
  v371 = (float)((float)((float)(v365 * v370) + v369) * v367) * *(float *)(a1 + 20912);
  *(float *)(a1 + 20672) = v371;
  *(_DWORD *)(a1 + 20960) = *(_DWORD *)(a1 + 20944);
  *(_DWORD *)(a1 + 20944) = *(_DWORD *)(a1 + 20928);
  v372 = *(float *)(a1 + 20960);
  v373 = *(float *)(a1 + 20976);
  v374 = v371 - v372;
  *(float *)(a1 + 20928) = v374;
  *(float *)(a1 + 20944) = (float)(v373 * v374) + v372;
  v375 = *(float *)(a1 + 20928);
  v376 = *(float *)(a1 + 20144);
  *(_DWORD *)(a1 + 21040) = *(_DWORD *)(a1 + 21024);
  *(_DWORD *)(a1 + 21024) = *(_DWORD *)(a1 + 21008);
  *(_DWORD *)(a1 + 21008) = *(_DWORD *)(a1 + 20992);
  *(float *)(a1 + 20992) = v375;
  v377 = (float)((float)(*(float *)(a1 + 21008) * *(float *)(a1 + 21088)) + (float)(v375 * *(float *)(a1 + 21072)))
       + (float)(*(float *)(a1 + 21104) * *(float *)(a1 + 21024));
  v378 = (float)((float)(*(float *)(a1 + 21008) * *(float *)(a1 + 21136)) + (float)(v375 * *(float *)(a1 + 21120)))
       + (float)(*(float *)(a1 + 21152) * *(float *)(a1 + 21040));
  if ( v376 <= 0.0 )
    v379 = 0.0;
  else
    v379 = v376;
  *(float *)(a1 + 21008) = v377;
  v380 = v379;
  *(float *)(a1 + 21024) = v378;
  v381 = (float)((float)(v380 * v377) - (float)(v380 * v375)) + v375;
  if ( v376 < -0.0 )
    v19 = (float)-v376;
  v382 = v19;
  v383 = v375 + (float)((float)(v382 * v378) - (float)(v382 * v375));
  if ( v376 >= 0.0 )
    v383 = v381;
  *(float *)(a1 + 21056) = v383;
  v384 = v383 * *(float *)(a1 + 20288);
  *(float *)(a1 + 21168) = v384;
  *(float *)(a1 + 21184) = v384 * *(float *)(a1 + 20368);
  v385 = fmin(fmax((float)(*(float *)(a1 + 14960) + *(float *)(a1 + 14288)), -20.0), 8.9);
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
       * *(float *)(a1 + 14304);
  *(float *)(a1 + 14928) = v391;
  v392 = *(float *)(a1 + 14288);
  v393 = *(_DWORD *)(a1 + 14752);
  v394 = *(_DWORD *)(a1 + 14768);
  LODWORD(v386) = *(_DWORD *)(a1 + 14784);
  *(_DWORD *)(a1 + 15360) = *(_DWORD *)(a1 + 15344);
  *(_DWORD *)(a1 + 15392) = *(_DWORD *)(a1 + 15376);
  *(_DWORD *)(a1 + 15568) = *(_DWORD *)(a1 + 15552);
  *(_DWORD *)(a1 + 15552) = *(_DWORD *)(a1 + 15536);
  *(_DWORD *)(a1 + 15536) = *(_DWORD *)(a1 + 15520);
  *(_DWORD *)(a1 + 15520) = *(_DWORD *)(a1 + 15504);
  *(_DWORD *)(a1 + 15504) = *(_DWORD *)(a1 + 15488);
  *(_DWORD *)(a1 + 15488) = *(_DWORD *)(a1 + 15472);
  *(_DWORD *)(a1 + 15472) = *(_DWORD *)(a1 + 15456);
  *(_DWORD *)(a1 + 15696) = *(_DWORD *)(a1 + 15680);
  *(_DWORD *)(a1 + 15680) = *(_DWORD *)(a1 + 15664);
  *(_DWORD *)(a1 + 15664) = *(_DWORD *)(a1 + 15648);
  *(_DWORD *)(a1 + 15648) = *(_DWORD *)(a1 + 15632);
  *(_DWORD *)(a1 + 15632) = *(_DWORD *)(a1 + 15616);
  *(_DWORD *)(a1 + 15616) = *(_DWORD *)(a1 + 15600);
  *(_DWORD *)(a1 + 15600) = *(_DWORD *)(a1 + 15584);
  *(_DWORD *)(a1 + 15824) = *(_DWORD *)(a1 + 15808);
  *(_DWORD *)(a1 + 15808) = *(_DWORD *)(a1 + 15792);
  *(_DWORD *)(a1 + 15792) = *(_DWORD *)(a1 + 15776);
  *(_DWORD *)(a1 + 15776) = *(_DWORD *)(a1 + 15760);
  *(_DWORD *)(a1 + 15760) = *(_DWORD *)(a1 + 15744);
  *(_DWORD *)(a1 + 15744) = *(_DWORD *)(a1 + 15728);
  *(_DWORD *)(a1 + 15728) = *(_DWORD *)(a1 + 15712);
  *(_DWORD *)(a1 + 15952) = *(_DWORD *)(a1 + 15936);
  *(_DWORD *)(a1 + 15936) = *(_DWORD *)(a1 + 15920);
  *(_DWORD *)(a1 + 15920) = *(_DWORD *)(a1 + 15904);
  *(_DWORD *)(a1 + 15904) = *(_DWORD *)(a1 + 15888);
  *(_DWORD *)(a1 + 15888) = *(_DWORD *)(a1 + 15872);
  *(_DWORD *)(a1 + 15872) = *(_DWORD *)(a1 + 15856);
  *(_DWORD *)(a1 + 15856) = *(_DWORD *)(a1 + 15840);
  *(_DWORD *)(a1 + 16016) = *(_DWORD *)(a1 + 16000);
  *(_DWORD *)(a1 + 16000) = *(_DWORD *)(a1 + 15984);
  *(_DWORD *)(a1 + 15248) = v393;
  *(_DWORD *)(a1 + 15264) = v394;
  v395 = v392 + *(float *)(a1 + 16816);
  v396 = v391 * *(float *)(a1 + 16048);
  v397 = *(float *)(a1 + 16032);
  *(_DWORD *)(a1 + 15280) = LODWORD(v386);
  v398 = fmaxf(*(float *)(a1 + 16080), v396);
  v399 = (float)(v395 * *(float *)(a1 + 16832)) + *(float *)(a1 + 16800);
  *(float *)(a1 + 15296) = v398;
  *(float *)(a1 + 15328) = v397 + *(float *)(a1 + 14320);
  if ( v399 <= 0.0 )
    v400 = 0.0;
  else
    v400 = v399;
  *(float *)(a1 + 15312) = 0.00390625 / v398;
  *(float *)(a1 + 15968) = v400;
  v401 = *(float *)(a1 + 15392);
  v402 = *(_DWORD *)(a1 + 15360);
  *(float *)(a1 + 15168) = v401;
  v403 = v401 + v398;
  *(_DWORD *)(a1 + 15184) = v402;
  if ( v403 <= 1.0 )
  {
    if ( v403 < -1.0 )
      v403 = fmodf(v403 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v403 = fmodf(v403 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 15152) = v403;
  v404 = v403 * *(float *)(a1 + 16160);
  v405 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v406 = (float)((float)(*(float *)&v405 * 256.0) * *(float *)(a1 + 15312)) * *(float *)(a1 + 16112);
  if ( v406 >= -1.0 )
    v407 = fminf(v406, 1.0);
  else
    v407 = -1.0;
  v408 = v407 * *(float *)(a1 + 16064);
  v409 = (float)(v408 * v408) * v408;
  v410 = v409 * *(float *)(a1 + 16464);
  v411 = (float)((float)((float)((float)((float)(v408 * v408) * *(float *)(a1 + 16528)) + *(float *)(a1 + 16512))
                       * (float)((float)(v408 * v408) * (float)(v408 * v408)))
               + (float)((float)((float)(v408 * v408) * *(float *)(a1 + 16496)) + *(float *)(a1 + 16480)))
       * (float)(v409 * (float)(v408 * v408));
  v412 = *(float *)(a1 + 15328) + v403;
  *(float *)(a1 + 15408) = (float)((float)(v411 + v410) + v408) * v404;
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
  v414 = *(float *)(a1 + 15152);
  v415 = v413 * *(float *)(a1 + 16176);
  v416 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v417 = *(float *)&v416;
  v418 = *(float *)(a1 + 16096);
  if ( v414 < v418 || v418 <= *(float *)(a1 + 15168) )
    v419 = *(float *)(a1 + 15184);
  else
    v419 = *(float *)(a1 + 15184) + 2.0;
  v420 = (float)((float)(v417 * *(float *)(a1 + 15312)) * 256.0) * *(float *)(a1 + 16128);
  if ( v419 >= 4.0 )
    v419 = 0.0;
  if ( v420 >= -1.0 )
    v421 = fminf(v420, 1.0);
  else
    v421 = -1.0;
  *(float *)(a1 + 15184) = v419;
  v422 = v421 * *(float *)(a1 + 16064);
  v423 = (float)((float)((float)(v419 + v414) + 1.0) * 0.5) - 1.0;
  v424 = (float)((float)((float)((float)((float)((float)((float)((float)(v422 * v422) * *(float *)(a1 + 16528))
                                                       + *(float *)(a1 + 16512))
                                               * (float)((float)(v422 * v422) * (float)(v422 * v422)))
                                       + (float)((float)((float)(v422 * v422) * *(float *)(a1 + 16496))
                                               + *(float *)(a1 + 16480)))
                               * (float)((float)((float)(v422 * v422) * v422) * (float)(v422 * v422)))
                       + (float)((float)((float)(v422 * v422) * v422) * *(float *)(a1 + 16464)))
               + v422)
       * v415;
  *(float *)(a1 + 15424) = v424;
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
  v426 = v423 * *(float *)(a1 + 16192);
  v427 = (float)((float)((float)(*(float *)&v425 + 1.0) * *(float *)(a1 + 15312)) * 512.0) * *(float *)(a1 + 16144);
  if ( v427 >= -1.0 )
    v428 = fminf(v427, 1.0);
  else
    v428 = -1.0;
  v429 = v428 * *(float *)(a1 + 16064);
  v430 = *(float *)(a1 + 15152);
  v431 = *(_DWORD *)(a1 + 15184);
  *(float *)(a1 + 15456) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v429 * v429)
                                                                                                 * *(float *)(a1 + 16528))
                                                                                         + *(float *)(a1 + 16512))
                                                                                 * (float)((float)(v429 * v429)
                                                                                         * (float)(v429 * v429)))
                                                                         + (float)((float)((float)(v429 * v429)
                                                                                         * *(float *)(a1 + 16496))
                                                                                 + *(float *)(a1 + 16480)))
                                                                 * (float)((float)((float)(v429 * v429) * v429)
                                                                         * (float)(v429 * v429)))
                                                         + (float)((float)((float)(v429 * v429) * v429)
                                                                 * *(float *)(a1 + 16464)))
                                                 + v429)
                                         * v426)
                                 * *(float *)(a1 + 15280))
                         + (float)((float)(*(float *)(a1 + 15408) * *(float *)(a1 + 15248))
                                 + (float)(v424 * *(float *)(a1 + 15264)));
  *(float *)(a1 + 15168) = v430;
  *(_DWORD *)(a1 + 15184) = v431;
  v432 = v430 + *(float *)(a1 + 15296);
  if ( v432 <= 1.0 )
  {
    if ( v432 < -1.0 )
      v432 = fmodf(v432 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v432 = fmodf(v432 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 15152) = v432;
  v433 = v432 * *(float *)(a1 + 16160);
  v434 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v435 = (float)((float)(*(float *)&v434 * 256.0) * *(float *)(a1 + 15312)) * *(float *)(a1 + 16112);
  if ( v435 >= -1.0 )
    v436 = fminf(v435, 1.0);
  else
    v436 = -1.0;
  v437 = v436 * *(float *)(a1 + 16064);
  v438 = (float)(v437 * v437) * v437;
  v439 = v438 * *(float *)(a1 + 16464);
  v440 = (float)((float)((float)((float)((float)(v437 * v437) * *(float *)(a1 + 16528)) + *(float *)(a1 + 16512))
                       * (float)((float)(v437 * v437) * (float)(v437 * v437)))
               + (float)((float)((float)(v437 * v437) * *(float *)(a1 + 16496)) + *(float *)(a1 + 16480)))
       * (float)(v438 * (float)(v437 * v437));
  v441 = *(float *)(a1 + 15328) + v432;
  *(float *)(a1 + 15408) = (float)((float)(v440 + v439) + v437) * v433;
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
  v443 = *(float *)(a1 + 15152);
  v444 = v442 * *(float *)(a1 + 16176);
  v445 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v446 = *(float *)&v445;
  v447 = *(float *)(a1 + 16096);
  if ( v443 < v447 || v447 <= *(float *)(a1 + 15168) )
    v448 = *(float *)(a1 + 15184);
  else
    v448 = *(float *)(a1 + 15184) + 2.0;
  v449 = (float)((float)(v446 * *(float *)(a1 + 15312)) * 256.0) * *(float *)(a1 + 16128);
  if ( v448 >= 4.0 )
    v448 = 0.0;
  if ( v449 >= -1.0 )
    v450 = fminf(v449, 1.0);
  else
    v450 = -1.0;
  *(float *)(a1 + 15184) = v448;
  v451 = v450 * *(float *)(a1 + 16064);
  v452 = (float)((float)((float)(v448 + v443) + 1.0) * 0.5) - 1.0;
  v453 = (float)((float)((float)((float)((float)((float)((float)((float)(v451 * v451) * *(float *)(a1 + 16528))
                                                       + *(float *)(a1 + 16512))
                                               * (float)((float)(v451 * v451) * (float)(v451 * v451)))
                                       + (float)((float)((float)(v451 * v451) * *(float *)(a1 + 16496))
                                               + *(float *)(a1 + 16480)))
                               * (float)((float)((float)(v451 * v451) * v451) * (float)(v451 * v451)))
                       + (float)((float)((float)(v451 * v451) * v451) * *(float *)(a1 + 16464)))
               + v451)
       * v444;
  *(float *)(a1 + 15424) = v453;
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
  v455 = v452 * *(float *)(a1 + 16192);
  v456 = (float)((float)((float)(*(float *)&v454 + 1.0) * *(float *)(a1 + 15312)) * 512.0) * *(float *)(a1 + 16144);
  if ( v456 >= -1.0 )
    v457 = fminf(v456, 1.0);
  else
    v457 = -1.0;
  v458 = v457 * *(float *)(a1 + 16064);
  v459 = *(float *)(a1 + 15152);
  v460 = *(_DWORD *)(a1 + 15184);
  *(float *)(a1 + 15584) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v458 * v458)
                                                                                                 * *(float *)(a1 + 16528))
                                                                                         + *(float *)(a1 + 16512))
                                                                                 * (float)((float)(v458 * v458)
                                                                                         * (float)(v458 * v458)))
                                                                         + (float)((float)((float)(v458 * v458)
                                                                                         * *(float *)(a1 + 16496))
                                                                                 + *(float *)(a1 + 16480)))
                                                                 * (float)((float)((float)(v458 * v458) * v458)
                                                                         * (float)(v458 * v458)))
                                                         + (float)((float)((float)(v458 * v458) * v458)
                                                                 * *(float *)(a1 + 16464)))
                                                 + v458)
                                         * v455)
                                 * *(float *)(a1 + 15280))
                         + (float)((float)(*(float *)(a1 + 15408) * *(float *)(a1 + 15248))
                                 + (float)(v453 * *(float *)(a1 + 15264)));
  *(float *)(a1 + 15168) = v459;
  *(_DWORD *)(a1 + 15184) = v460;
  v461 = v459 + *(float *)(a1 + 15296);
  if ( v461 <= 1.0 )
  {
    if ( v461 < -1.0 )
      v461 = fmodf(v461 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v461 = fmodf(v461 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 15152) = v461;
  v462 = v461 * *(float *)(a1 + 16160);
  v463 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v464 = (float)((float)(*(float *)&v463 * 256.0) * *(float *)(a1 + 15312)) * *(float *)(a1 + 16112);
  if ( v464 >= -1.0 )
    v465 = fminf(v464, 1.0);
  else
    v465 = -1.0;
  v466 = v465 * *(float *)(a1 + 16064);
  v467 = (float)(v466 * v466) * v466;
  v468 = v467 * *(float *)(a1 + 16464);
  v469 = (float)((float)((float)((float)((float)(v466 * v466) * *(float *)(a1 + 16528)) + *(float *)(a1 + 16512))
                       * (float)((float)(v466 * v466) * (float)(v466 * v466)))
               + (float)((float)((float)(v466 * v466) * *(float *)(a1 + 16496)) + *(float *)(a1 + 16480)))
       * (float)(v467 * (float)(v466 * v466));
  v470 = *(float *)(a1 + 15328) + v461;
  *(float *)(a1 + 15408) = (float)((float)(v469 + v468) + v466) * v462;
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
  v472 = *(float *)(a1 + 15152);
  v473 = v471 * *(float *)(a1 + 16176);
  v474 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v475 = *(float *)&v474;
  v476 = *(float *)(a1 + 16096);
  if ( v472 < v476 || v476 <= *(float *)(a1 + 15168) )
    v477 = *(float *)(a1 + 15184);
  else
    v477 = *(float *)(a1 + 15184) + 2.0;
  v478 = (float)((float)(v475 * *(float *)(a1 + 15312)) * 256.0) * *(float *)(a1 + 16128);
  if ( v477 >= 4.0 )
    v477 = 0.0;
  if ( v478 >= -1.0 )
    v479 = fminf(v478, 1.0);
  else
    v479 = -1.0;
  *(float *)(a1 + 15184) = v477;
  v480 = v479 * *(float *)(a1 + 16064);
  v481 = (float)((float)((float)(v477 + v472) + 1.0) * 0.5) - 1.0;
  v482 = (float)((float)((float)((float)((float)((float)((float)((float)(v480 * v480) * *(float *)(a1 + 16528))
                                                       + *(float *)(a1 + 16512))
                                               * (float)((float)(v480 * v480) * (float)(v480 * v480)))
                                       + (float)((float)((float)(v480 * v480) * *(float *)(a1 + 16496))
                                               + *(float *)(a1 + 16480)))
                               * (float)((float)((float)(v480 * v480) * v480) * (float)(v480 * v480)))
                       + (float)((float)((float)(v480 * v480) * v480) * *(float *)(a1 + 16464)))
               + v480)
       * v473;
  *(float *)(a1 + 15424) = v482;
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
  v484 = v481 * *(float *)(a1 + 16192);
  v485 = (float)((float)((float)(*(float *)&v483 + 1.0) * *(float *)(a1 + 15312)) * 512.0) * *(float *)(a1 + 16144);
  if ( v485 >= -1.0 )
    v486 = fminf(v485, 1.0);
  else
    v486 = -1.0;
  v487 = v486 * *(float *)(a1 + 16064);
  v488 = *(float *)(a1 + 15152);
  v489 = *(_DWORD *)(a1 + 15184);
  *(float *)(a1 + 15712) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v487 * v487)
                                                                                                 * *(float *)(a1 + 16528))
                                                                                         + *(float *)(a1 + 16512))
                                                                                 * (float)((float)(v487 * v487)
                                                                                         * (float)(v487 * v487)))
                                                                         + (float)((float)((float)(v487 * v487)
                                                                                         * *(float *)(a1 + 16496))
                                                                                 + *(float *)(a1 + 16480)))
                                                                 * (float)((float)((float)(v487 * v487) * v487)
                                                                         * (float)(v487 * v487)))
                                                         + (float)((float)((float)(v487 * v487) * v487)
                                                                 * *(float *)(a1 + 16464)))
                                                 + v487)
                                         * v484)
                                 * *(float *)(a1 + 15280))
                         + (float)((float)(*(float *)(a1 + 15408) * *(float *)(a1 + 15248))
                                 + (float)(v482 * *(float *)(a1 + 15264)));
  *(float *)(a1 + 15168) = v488;
  *(_DWORD *)(a1 + 15184) = v489;
  v490 = v488 + *(float *)(a1 + 15296);
  if ( v490 <= 1.0 )
  {
    if ( v490 < -1.0 )
      v490 = fmodf(v490 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v490 = fmodf(v490 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 15152) = v490;
  v491 = v490 * *(float *)(a1 + 16160);
  v492 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v493 = (float)((float)(*(float *)&v492 * 256.0) * *(float *)(a1 + 15312)) * *(float *)(a1 + 16112);
  if ( v493 >= -1.0 )
    v494 = fminf(v493, 1.0);
  else
    v494 = -1.0;
  v495 = v494 * *(float *)(a1 + 16064);
  v496 = (float)(v495 * v495) * v495;
  v497 = v496 * *(float *)(a1 + 16464);
  v498 = (float)((float)((float)((float)((float)(v495 * v495) * *(float *)(a1 + 16528)) + *(float *)(a1 + 16512))
                       * (float)((float)(v495 * v495) * (float)(v495 * v495)))
               + (float)((float)((float)(v495 * v495) * *(float *)(a1 + 16496)) + *(float *)(a1 + 16480)))
       * (float)(v496 * (float)(v495 * v495));
  v499 = *(float *)(a1 + 15328) + v490;
  *(float *)(a1 + 15408) = (float)((float)(v498 + v497) + v495) * v491;
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
  v501 = *(float *)(a1 + 15152);
  v502 = v500 * *(float *)(a1 + 16176);
  v503 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v504 = *(float *)&v503;
  v505 = *(float *)(a1 + 16096);
  if ( v501 < v505 || v505 <= *(float *)(a1 + 15168) )
    v506 = *(float *)(a1 + 15184);
  else
    v506 = *(float *)(a1 + 15184) + 2.0;
  v507 = (float)((float)(v504 * *(float *)(a1 + 15312)) * 256.0) * *(float *)(a1 + 16128);
  if ( v506 >= 4.0 )
    v506 = 0.0;
  if ( v507 >= -1.0 )
    v508 = fminf(v507, 1.0);
  else
    v508 = -1.0;
  *(float *)(a1 + 15184) = v506;
  v509 = v508 * *(float *)(a1 + 16064);
  v510 = (float)((float)((float)(v506 + v501) + 1.0) * 0.5) - 1.0;
  v511 = (float)((float)((float)((float)((float)((float)((float)((float)(v509 * v509) * *(float *)(a1 + 16528))
                                                       + *(float *)(a1 + 16512))
                                               * (float)((float)(v509 * v509) * (float)(v509 * v509)))
                                       + (float)((float)((float)(v509 * v509) * *(float *)(a1 + 16496))
                                               + *(float *)(a1 + 16480)))
                               * (float)((float)((float)(v509 * v509) * v509) * (float)(v509 * v509)))
                       + (float)((float)((float)(v509 * v509) * v509) * *(float *)(a1 + 16464)))
               + v509)
       * v502;
  *(float *)(a1 + 15424) = v511;
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
  v513 = v510 * *(float *)(a1 + 16192);
  v514 = (float)((float)(v512 * *(float *)(a1 + 15312)) * 512.0) * *(float *)(a1 + 16144);
  if ( v514 >= -1.0 )
    v33 = fminf(v514, 1.0);
  v515 = v33 * *(float *)(a1 + 16064);
  v516 = *(_DWORD *)(a1 + 15152);
  v517 = *(_DWORD *)(a1 + 15184);
  *(float *)(a1 + 15840) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v515 * v515)
                                                                                                 * *(float *)(a1 + 16528))
                                                                                         + *(float *)(a1 + 16512))
                                                                                 * (float)((float)(v515 * v515)
                                                                                         * (float)(v515 * v515)))
                                                                         + (float)((float)((float)(v515 * v515)
                                                                                         * *(float *)(a1 + 16496))
                                                                                 + *(float *)(a1 + 16480)))
                                                                 * (float)((float)((float)(v515 * v515) * v515)
                                                                         * (float)(v515 * v515)))
                                                         + (float)((float)((float)(v515 * v515) * v515)
                                                                 * *(float *)(a1 + 16464)))
                                                 + v515)
                                         * v513)
                                 * *(float *)(a1 + 15280))
                         + (float)((float)(*(float *)(a1 + 15408) * *(float *)(a1 + 15248))
                                 + (float)(v511 * *(float *)(a1 + 15264)));
  v518 = *(float *)(a1 + 15952);
  *(_DWORD *)(a1 + 15376) = v516;
  *(_DWORD *)(a1 + 15344) = v517;
  v519 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(*(float *)(a1 + 15824) + *(float *)(a1 + 15584))
                                                                                               * *(float *)(a1 + 16224))
                                                                                       + (float)((float)(v518 + *(float *)(a1 + 15456))
                                                                                               * *(float *)(a1 + 16208)))
                                                                               + (float)((float)(*(float *)(a1 + 15712)
                                                                                               + *(float *)(a1 + 15696))
                                                                                       * *(float *)(a1 + 16240)))
                                                                       + (float)((float)(*(float *)(a1 + 15840)
                                                                                       + *(float *)(a1 + 15568))
                                                                               * *(float *)(a1 + 16256)))
                                                               + (float)((float)(*(float *)(a1 + 15936)
                                                                               + *(float *)(a1 + 15472))
                                                                       * *(float *)(a1 + 16272)))
                                                       + (float)((float)(*(float *)(a1 + 15808) + *(float *)(a1 + 15600))
                                                               * *(float *)(a1 + 16288)))
                                               + (float)((float)(*(float *)(a1 + 15728) + *(float *)(a1 + 15680))
                                                       * *(float *)(a1 + 16304)))
                                       + (float)((float)(*(float *)(a1 + 15856) + *(float *)(a1 + 15552))
                                               * *(float *)(a1 + 16320)))
                               + (float)((float)(*(float *)(a1 + 15920) + *(float *)(a1 + 15488))
                                       * *(float *)(a1 + 16336)))
                       + (float)((float)(*(float *)(a1 + 15616) + *(float *)(a1 + 15792)) * *(float *)(a1 + 16352)))
               + (float)((float)(*(float *)(a1 + 15744) + *(float *)(a1 + 15664)) * *(float *)(a1 + 16368)))
       + (float)((float)(*(float *)(a1 + 15536) + *(float *)(a1 + 15872)) * *(float *)(a1 + 0x4000));
  v520 = *(float *)(a1 + 16000);
  v521 = (float)(v520 * *(float *)(a1 + 16768)) + *(float *)(a1 + 16016);
  v522 = (float)((float)(v519
                       + (float)((float)(*(float *)(a1 + 15904) + *(float *)(a1 + 15504)) * *(float *)(a1 + 16400)))
               + (float)((float)(*(float *)(a1 + 15776) + *(float *)(a1 + 15632)) * *(float *)(a1 + 16416)))
       + (float)((float)(*(float *)(a1 + 15760) + *(float *)(a1 + 15648)) * *(float *)(a1 + 16432));
  v523 = (float)(*(float *)(a1 + 15888) + *(float *)(a1 + 15520)) * *(float *)(a1 + 16448);
  *(float *)(a1 + 16000) = v521;
  v524 = v522 + v523;
  v525 = v524 - (float)((float)(v520 * *(float *)(a1 + 16784)) + v521);
  *(float *)(a1 + 15984) = (float)(v525 * *(float *)(a1 + 16768)) + v520;
  v526 = (float)((float)((float)(v521 - (float)(v525 * *(float *)(a1 + 15968))) * *(float *)(a1 + 16848))
               - (float)(*(float *)(a1 + 16848) * v524))
       + v524;
  *(float *)(a1 + 15440) = v526;
  *(float *)(a1 + 14032) = v526;
  if ( *(float *)(a1 + 101536) == 1.0 )
  {
    *(_DWORD *)(a1 + 10832) = v528;
    *(_DWORD *)(a1 + 101536) = 0;
  }
  **a2 = *(_DWORD *)(a1 + 21184);
  result = *(unsigned int *)(a1 + 21184);
  *a2[1] = result;
  return result;
}

