// sub_7FF91DFD4900 @ 0x7FF91DFD4900 (RVA 0x7FF79DFD4900)

__int64 __fastcall sub_7FF91DFD4900(__int64 a1, _DWORD **a2)
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

  v2 = *(float *)(a1 + 31856);
  v528 = 0;
  if ( *(float *)(a1 + 101600) == 1.0 )
  {
    v528 = *(_DWORD *)(a1 + 31856);
    v2 = 0.0;
    *(_DWORD *)(a1 + 31856) = 0;
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
  v11 = *(float *)(a1 + 31744);
  v12 = *(float *)(a1 + 31712);
  v13 = v9 & 0xFFFFFF;
  v14 = *(float *)(a1 + 31904);
  v15 = v9;
  v16 = *(float *)(a1 + 31920);
  v17 = v9 | 0xFF000000;
  v18 = v6 * v7;
  *(_DWORD *)(a1 + 31968) = 0;
  *(float *)(a1 + 31760) = v11;
  v19 = 0.0;
  if ( (v15 & 0x1000000) == 0 )
    v17 = v13;
  *(float *)(a1 + 31728) = v12;
  *(_DWORD *)(a1 + 84384) = *(_DWORD *)(a1 + 84368);
  *(_DWORD *)(a1 + 32048) = *(_DWORD *)(a1 + 32032);
  *(float *)(a1 + 31888) = v2;
  v20 = (float)v17 * 0.000000059604645;
  *(float *)(a1 + 31936) = v14;
  *(float *)(a1 + 31952) = v16;
  *(float *)(a1 + 84336) = v20;
  v21 = (float)(v20 * *(float *)(a1 + 84400)) + *(float *)(a1 + 84416);
  *(float *)(a1 + 84368) = v21;
  v22 = v18 - (float)(v7 * v21);
  v23 = *(float *)(a1 + 31808);
  *(float *)(a1 + 31824) = v23;
  v24 = v22 + v21;
  v25 = *(float *)(a1 + 31776);
  v26 = v23 * v25;
  *(float *)(a1 + 31792) = v25;
  *(float *)(a1 + 84432) = v24;
  v27 = *(float *)(a1 + 31840);
  *(float *)(a1 + 31872) = v27;
  *(float *)(a1 + 31984) = v26;
  v28 = (float)((float)(v12 * v26) - (float)(v26 * v27)) + v27;
  v29 = (float)((float)(v11 * v26) - (float)(v2 * v26)) + v2;
  *(float *)(a1 + 32000) = v28;
  *(float *)(a1 + 32016) = v29;
  v30 = v29;
  v31 = v29 + *(float *)(a1 + 32080);
  if ( v31 < 0.0 )
    v32 = v31;
  else
    v32 = 0.0;
  v33 = -1.0;
  if ( v30 == 0.0 )
    v34 = -1.0;
  else
    v34 = v32;
  *(float *)(a1 + 32032) = v34;
  if ( v34 >= 0.0 )
  {
    if ( v34 > 0.0 )
      v34 = 1.0;
  }
  else
  {
    v34 = -1.0;
  }
  v35 = *(float *)(a1 + 32144);
  v36 = v34 + 1.0;
  v37 = *(float *)(a1 + 32304);
  v38 = *(float *)(a1 + 32160);
  v39 = *(_DWORD *)(a1 + 32096);
  v40 = *(float *)(a1 + 32240);
  v41 = v38 + *(float *)(a1 + 32320);
  v42 = 1.0;
  *(float *)(a1 + 32064) = v36;
  *(float *)(a1 + 32096) = v36;
  *(_DWORD *)(a1 + 32112) = v39;
  *(float *)(a1 + 32256) = v40;
  v43 = (float)(v36 * v35) - v35;
  v44 = *(float *)(a1 + 32352);
  v45 = (float)(v43 + 1.0) * *(float *)(a1 + 32128);
  v46 = (float)(*(float *)(a1 + 32208) / (float)((float)(v37 * v38) + *(float *)(a1 + 32336))) * v37;
  v47 = *(float *)(a1 + 32192);
  *(float *)(a1 + 32272) = v45;
  v48 = v47 - v46;
  v49 = *(float *)(a1 + 32224);
  v50 = (float)(v48 + v28) - v40;
  *(float *)(a1 + 32192) = v50;
  v51 = v50 * v41;
  *(float *)(a1 + 32208) = v51;
  v52 = v51 + v40;
  if ( (float)(v44 - fabs(v40 - v28)) < 0.0 )
  {
    v53 = 0.0;
LABEL_25:
    v54 = v53;
    goto LABEL_26;
  }
  v53 = v49 + *(float *)(a1 + 32368);
  if ( v53 < 1.0 )
    goto LABEL_25;
  v54 = 1.0;
LABEL_26:
  v55 = v54;
  *(float *)(a1 + 32224) = v55;
  v56 = (float)((float)(v55 * v28) - (float)(v55 * v52)) + v52;
  if ( v45 == 0.0 )
    v56 = v28;
  v57 = v16 * *(float *)(a1 + 32400);
  *(_DWORD *)(a1 + 32432) = *(_DWORD *)(a1 + 32416);
  v58 = *(float *)(a1 + 32704);
  v59 = *(float *)(a1 + 32448);
  v60 = *(_DWORD *)(a1 + 32544);
  v61 = v57 + (float)(v14 * *(float *)(a1 + 32384));
  v62 = *(_DWORD *)(a1 + 32512);
  v63 = (int)v58;
  *(float *)(a1 + 32416) = v61;
  v64 = *(float *)(a1 + 32480);
  *(float *)(a1 + 32240) = v56;
  *(float *)(a1 + 32288) = v56;
  v65 = *(float *)(a1 + 32640);
  *(float *)(a1 + 32496) = v64;
  *(float *)(a1 + 32464) = v59;
  *(_DWORD *)(a1 + 32528) = v62;
  *(_DWORD *)(a1 + 32560) = v60;
  *(float *)(a1 + 32656) = v65;
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
  v67 = *(float *)(a1 + 32576);
  v68 = (float)((float)(v59 - v65) * *(float *)(a1 + 32688)) + v65;
  v69 = *(float *)(a1 + 32624);
  *(float *)(a1 + 32640) = v68;
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
  v74 = *(float *)(a1 + 32592);
  v75 = expf((float)v73 * *(float *)(a1 + 32736)) * *(float *)(a1 + 32720);
  v76 = v74 * *(float *)(a1 + 32608);
  *(_DWORD *)(a1 + 33120) = *(_DWORD *)(a1 + 33104);
  v77 = v75 + *(float *)(a1 + 32752);
  v78 = *(float *)(a1 + 33040);
  v79 = v64 * *(float *)(a1 + 33440);
  *(_DWORD *)(a1 + 33152) = *(_DWORD *)(a1 + 33136);
  v80 = *(float *)(a1 + 33024);
  v81 = *(float *)(a1 + 33072);
  *(_DWORD *)(a1 + 33184) = *(_DWORD *)(a1 + 33168);
  v82 = *(_DWORD *)(a1 + 84432);
  *(float *)(a1 + 33056) = v78;
  *(float *)(a1 + 33040) = v80;
  *(float *)(a1 + 33088) = v81;
  *(_DWORD *)(a1 + 32976) = v62;
  *(_DWORD *)(a1 + 32992) = v60;
  *(_DWORD *)(a1 + 32960) = v82;
  v83 = (float)(v76 - (float)(v74 * v77)) + v77;
  v84 = *(float *)(a1 + 33392);
  v85 = v79 + v84;
  *(float *)(a1 + 33376) = v84;
  *(float *)(a1 + 32672) = v83;
  if ( v85 >= -1.0 )
    v86 = fminf(v85, 1.0);
  else
    v86 = -1.0;
  v87 = *(float *)(a1 + 33664);
  *(float *)(a1 + 33024) = v86;
  v88 = fminf(v87, v83 * 0.000015258789);
  v89 = (float)((float)(1.0 - v78) * *(float *)(a1 + 33456)) + v78;
  if ( v89 >= -1.0 )
    v90 = fminf(v89, 1.0);
  else
    v90 = -1.0;
  v91 = v88 * *(float *)(a1 + 33680);
  v92 = v80 - v86;
  *(float *)(a1 + 33200) = v91;
  v93 = v91 + v81;
  if ( v92 < 0.0 )
    v90 = 0.0;
  v94 = *(float *)(a1 + 33408);
  v95 = *(float *)(a1 + 32960);
  *(float *)(a1 + 33040) = v90;
  v96 = v90 + *(float *)(a1 + 33808);
  if ( v92 >= 0.0 )
    v94 = 1.0;
  v97 = v96 * *(float *)(a1 + 33792);
  v98 = (float)(v93 * v94) * *(float *)(a1 + 33424);
  if ( v97 <= 0.0 )
    v99 = 0.0;
  else
    v99 = v97;
  v100 = v99;
  v101 = (float)((float)(v95 - *(float *)(a1 + 33120)) * *(float *)(a1 + 34000)) + *(float *)(a1 + 33120);
  *(float *)(a1 + 33104) = v101;
  *(float *)(a1 + 33008) = v100;
  v529 = *(float *)(a1 + 33088);
  v102 = (float)((float)((float)(v101 * *(float *)(a1 + 33984)) * *(float *)(a1 + 33600))
               - (float)(v95 * *(float *)(a1 + 33600)))
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
  v103 = *(float *)(a1 + 33152);
  *(float *)(a1 + 33072) = v98;
  v104 = v98 + *(float *)(a1 + 33824);
  *(float *)(a1 + 32944) = v102 * *(float *)(a1 + 33968);
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
  *(float *)(a1 + 33136) = v103;
  v105 = v103 * *(float *)(a1 + 33952);
  v106 = (float)(v104 * *(float *)(a1 + 33888)) + *(float *)(a1 + 34016);
  *(float *)(a1 + 33216) = v106;
  *(float *)(a1 + 33296) = v105;
  v107 = v98 + *(float *)(a1 + 33856);
  *(float *)(a1 + 33232) = -v106;
  if ( v107 <= 1.0 )
  {
    if ( v107 < -1.0 )
      fmodf(v107 - 1.0, 2.0);
  }
  else
  {
    fmodf(v107 + 1.0, 2.0);
  }
  v108 = v98 + *(float *)(a1 + 33840);
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
  v110 = v108 + *(float *)(a1 + 34032);
  v111 = v109 * *(float *)(a1 + 33920);
  if ( v110 >= 0.0 )
  {
    if ( v110 > 0.0 )
      v110 = 1.0;
  }
  else
  {
    v110 = -1.0;
  }
  v112 = v98 + *(float *)(a1 + 33872);
  *(float *)(a1 + 33264) = v111;
  *(float *)(a1 + 33360) = v110;
  v113 = (float)(v110 * *(float *)(a1 + 33904)) + *(float *)(a1 + 34048);
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
  *(float *)(a1 + 33248) = v113;
  v115 = *(float *)(a1 + 33504);
  v116 = (float)((float)(*(float *)(a1 + 33568) * *(float *)(a1 + 33296))
               + (float)(*(float *)(a1 + 33536) * *(float *)(a1 + 33216)))
       + (float)(*(float *)(a1 + 33552) * *(float *)(a1 + 33232));
  v117 = (float)((float)((float)((float)(v114 * (float)((float)(v114 * v114) * v114)) * *(float *)(a1 + 33760))
                       + (float)((float)((float)((float)(v114 * v114) * v114) * *(float *)(a1 + 33744))
                               + (float)((float)((float)(v114 * *(float *)(a1 + 33712)) + *(float *)(a1 + 33696))
                                       + (float)((float)(v114 * v114) * *(float *)(a1 + 33728)))))
               + *(float *)(a1 + 33776))
       * *(float *)(a1 + 33936);
  *(float *)(a1 + 33280) = v117;
  v118 = (float)(v115 * *(float *)(a1 + 33264)) + v116;
  v119 = *(float *)(a1 + 33616);
  v120 = (float)((float)(*(float *)(a1 + 33472) * *(float *)(a1 + 33008)) - *(float *)(a1 + 33472)) + 1.0;
  v121 = (float)((float)(v118 + (float)(*(float *)(a1 + 33520) * *(float *)(a1 + 33248)))
               + (float)(v117 * *(float *)(a1 + 33488)))
       + (float)(*(float *)(a1 + 33584) * *(float *)(a1 + 32944));
  *(float *)(a1 + 33312) = v120;
  *(float *)(a1 + 33344) = v121;
  *(float *)(a1 + 33328) = (float)((float)(*(float *)(a1 + 33632) * *(float *)(a1 + 32976))
                                 + (float)(*(float *)(a1 + 33648) * *(float *)(a1 + 32992)))
                         + (float)((float)(v119 * v120) * v121);
  v122 = *(_DWORD *)(a1 + 33344);
  *(_DWORD *)(a1 + 34064) = *(_DWORD *)(a1 + 33360);
  *(_DWORD *)(a1 + 34080) = v122;
  if ( *(float *)(a1 + 33360) <= 0.0 )
    v123 = 0.0;
  else
    v123 = 1.0;
  if ( *(float *)(a1 + 34096) == 0.0 )
    v123 = 1.0;
  v124 = *(float *)(a1 + 32096) * v123;
  *(float *)(a1 + 34112) = v124;
  *(_DWORD *)(a1 + 34144) = *(_DWORD *)(a1 + 34128);
  *(_DWORD *)(a1 + 34192) = *(_DWORD *)(a1 + 34176);
  *(_DWORD *)(a1 + 34176) = *(_DWORD *)(a1 + 34160);
  *(_DWORD *)(a1 + 34224) = *(_DWORD *)(a1 + 34208);
  *(_DWORD *)(a1 + 34272) = *(_DWORD *)(a1 + 34256);
  if ( (float)(v124 + *(float *)(a1 + 34400)) >= 0.0 )
    v125 = 0.0;
  else
    v125 = 1.0;
  v126 = 1.0 - v125;
  v127 = (float)(1.0 - v125)
       * (float)((float)(*(float *)(a1 + 34432) * *(float *)(a1 + 34192)) + *(float *)(a1 + 34144));
  *(float *)(a1 + 34160) = v127;
  v128 = v127 + *(float *)(a1 + 34416);
  v129 = v127 - *(float *)(a1 + 34176);
  *(float *)(a1 + 34240) = (float)((float)(*(float *)(a1 + 34384) * *(float *)(a1 + 34496))
                                 - (float)(*(float *)(a1 + 34464) * *(float *)(a1 + 34384)))
                         + *(float *)(a1 + 34464);
  if ( v128 < 0.0 )
    v130 = 0.0;
  else
    v130 = 1.0;
  if ( v129 < 0.0 )
    v130 = 1.0 - v125;
  v131 = *(float *)(a1 + 34320);
  v132 = v126 * (float)(*(float *)(a1 + 34336) * *(float *)(a1 + 34464));
  *(float *)(a1 + 34176) = v130;
  v133 = *(float *)(a1 + 34224);
  v134 = (float)(v132 - (float)(*(float *)(a1 + 34480) * v126)) + *(float *)(a1 + 34480);
  v135 = v126 * (float)(1.0 - v130);
  v136 = (float)((float)(*(float *)(a1 + 34352) * 0.00390625) * v130) + (float)((float)(v131 * 0.00390625) * v135);
  if ( (float)(v134 - v133) > 0.0 )
    v134 = v133 + *(float *)(a1 + 34240);
  v137 = *(float *)(a1 + 34144);
  v138 = fminf(*(float *)(a1 + 34464), v134);
  *(float *)(a1 + 34208) = v138;
  v139 = *(float *)(a1 + 34368);
  v140 = (float)((float)(v135 * *(float *)(a1 + 34448)) + (float)(v130 * v138)) - v137;
  v141 = (float)((float)(*(float *)(a1 + 34512) * v136) - (float)(*(float *)(a1 + 34512) * *(float *)(a1 + 34272)))
       + *(float *)(a1 + 34272);
  *(float *)(a1 + 34256) = v141;
  v142 = (float)((float)((float)((float)((float)(v139 * 0.00390625) * v125) - (float)(v125 * v141)) + v141) * v140)
       + v137;
  *(float *)(a1 + 34128) = v142;
  v143 = (float)(v142 * *(float *)(a1 + 34528)) * *(float *)(a1 + 34544);
  v144 = v143 * *(float *)(a1 + 34560);
  *(float *)(a1 + 34288) = v143;
  *(float *)(a1 + 34304) = v144;
  if ( *(float *)(a1 + 33360) <= 0.0 )
    v145 = 0.0;
  else
    v145 = 1.0;
  if ( *(float *)(a1 + 34576) == 0.0 )
    v145 = 1.0;
  v146 = *(float *)(a1 + 32096) * v145;
  *(float *)(a1 + 34592) = v146;
  *(_DWORD *)(a1 + 34624) = *(_DWORD *)(a1 + 34608);
  *(_DWORD *)(a1 + 34672) = *(_DWORD *)(a1 + 34656);
  *(_DWORD *)(a1 + 34656) = *(_DWORD *)(a1 + 34640);
  *(_DWORD *)(a1 + 34704) = *(_DWORD *)(a1 + 34688);
  *(_DWORD *)(a1 + 34752) = *(_DWORD *)(a1 + 34736);
  if ( (float)(v146 + *(float *)(a1 + 34880)) >= 0.0 )
    v147 = 0.0;
  else
    v147 = 1.0;
  v148 = 1.0 - v147;
  v149 = (float)(1.0 - v147)
       * (float)((float)(*(float *)(a1 + 34912) * *(float *)(a1 + 34672)) + *(float *)(a1 + 34624));
  *(float *)(a1 + 34640) = v149;
  v150 = v149 + *(float *)(a1 + 34896);
  v151 = v149 - *(float *)(a1 + 34656);
  *(float *)(a1 + 34720) = (float)((float)(*(float *)(a1 + 34864) * *(float *)(a1 + 34976))
                                 - (float)(*(float *)(a1 + 34944) * *(float *)(a1 + 34864)))
                         + *(float *)(a1 + 34944);
  if ( v150 < 0.0 )
    v152 = 0.0;
  else
    v152 = 1.0;
  if ( v151 < 0.0 )
    v152 = 1.0 - v147;
  v153 = *(float *)(a1 + 34816) * *(float *)(a1 + 34944);
  v154 = *(float *)(a1 + 34800);
  *(float *)(a1 + 34656) = v152;
  v155 = *(float *)(a1 + 34704);
  v156 = (float)((float)(v148 * v153) - (float)(*(float *)(a1 + 34960) * v148)) + *(float *)(a1 + 34960);
  v157 = v148 * (float)(1.0 - v152);
  v158 = (float)((float)(*(float *)(a1 + 34832) * 0.00390625) * v152) + (float)((float)(v154 * 0.00390625) * v157);
  if ( (float)(v156 - v155) > 0.0 )
    v156 = v155 + *(float *)(a1 + 34720);
  v159 = *(float *)(a1 + 34624);
  v160 = fminf(*(float *)(a1 + 34944), v156);
  *(float *)(a1 + 34688) = v160;
  v161 = (float)(*(float *)(a1 + 34848) * 0.00390625) * v147;
  v162 = (float)((float)(v157 * *(float *)(a1 + 34928)) + (float)(v152 * v160)) - v159;
  v163 = (float)((float)(*(float *)(a1 + 34992) * v158) - (float)(*(float *)(a1 + 34992) * *(float *)(a1 + 34752)))
       + *(float *)(a1 + 34752);
  *(float *)(a1 + 34736) = v163;
  v164 = (float)((float)((float)(v161 - (float)(v147 * v163)) + v163) * v162) + v159;
  *(float *)(a1 + 34608) = v164;
  v165 = (float)(v164 * *(float *)(a1 + 35008)) * *(float *)(a1 + 35024);
  v166 = v165 * *(float *)(a1 + 35040);
  *(float *)(a1 + 34768) = v165;
  *(float *)(a1 + 34784) = v166;
  *(_DWORD *)(a1 + 35072) = *(_DWORD *)(a1 + 35056);
  *(_DWORD *)(a1 + 35104) = *(_DWORD *)(a1 + 35088);
  v167 = *(float *)(a1 + 32288);
  v168 = *(float *)(a1 + 32416);
  *(_DWORD *)(a1 + 35168) = *(_DWORD *)(a1 + 35152);
  v169 = (float)(v168 * *(float *)(a1 + 35136)) + (float)(v167 * *(float *)(a1 + 35120));
  *(float *)(a1 + 35152) = v169;
  v170 = *(float *)(a1 + 33328);
  v171 = *(_DWORD *)(a1 + 34288);
  v172 = *(_DWORD *)(a1 + 34768);
  v173 = *(_DWORD *)(a1 + 32288);
  *(_DWORD *)(a1 + 35216) = *(_DWORD *)(a1 + 35088);
  *(_DWORD *)(a1 + 35232) = v173;
  v174 = *(float *)(a1 + 35552);
  *(_DWORD *)(a1 + 35184) = v171;
  *(_DWORD *)(a1 + 35200) = v172;
  v175 = *(float *)(a1 + 35520);
  v176 = v170 * v174;
  v177 = v174 * *(float *)(a1 + 33344);
  *(float *)(a1 + 35248) = v177;
  v178 = *(float *)(a1 + 35648);
  v179 = *(float *)(a1 + 35392);
  v180 = v176 * *(float *)(a1 + 35568);
  v181 = *(float *)(a1 + 35584);
  v182 = (float)(v175 * v177) * *(float *)(a1 + 35536);
  *(float *)(a1 + 35280) = v182;
  v183 = *(float *)(a1 + 35408);
  v184 = (float)((float)((float)(v179 * *(float *)(a1 + 35216)) - (float)(v178 * v179)) + v178) * *(float *)(a1 + 35664);
  *(float *)(a1 + 35296) = v184;
  v185 = (float)((float)(v181 * v180) + v182) + (float)(v183 * v184);
  v186 = *(float *)(a1 + 35248);
  v187 = *(_DWORD *)(a1 + 35376);
  *(float *)(a1 + 35312) = (float)((float)((float)((float)((float)((float)(*(float *)(a1 + 35616)
                                                                         * *(float *)(a1 + 35200))
                                                                 + (float)(*(float *)(a1 + 35600)
                                                                         * *(float *)(a1 + 35184)))
                                                         * *(float *)(a1 + 35632))
                                                 + v185)
                                         + v169)
                                 + *(float *)(a1 + 35488))
                         + *(float *)(a1 + 35504);
  *(_DWORD *)(a1 + 35328) = v187;
  v188 = (float)(*(float *)(a1 + 35280) + *(float *)(a1 + 35232)) + *(float *)(a1 + 35296);
  *(float *)(a1 + 35344) = (float)((float)((float)((float)((float)((float)(v186 * *(float *)(a1 + 35696))
                                                                 + *(float *)(a1 + 35712))
                                                         * *(float *)(a1 + 35424))
                                                 + (float)(*(float *)(a1 + 35440) * *(float *)(a1 + 35184)))
                                         + (float)(*(float *)(a1 + 35456) * *(float *)(a1 + 35200)))
                                 + *(float *)(a1 + 35472))
                         * *(float *)(a1 + 35680);
  *(float *)(a1 + 35360) = v188;
  v189 = *(_DWORD *)(a1 + 35744);
  *(_DWORD *)(a1 + 35776) = *(_DWORD *)(a1 + 35728);
  *(_DWORD *)(a1 + 35792) = v189;
  *(_DWORD *)(a1 + 35808) = *(_DWORD *)(a1 + 35760);
  v190 = *(float *)(a1 + 84432);
  *(_DWORD *)(a1 + 35856) = *(_DWORD *)(a1 + 35840);
  v191 = *(float *)(a1 + 35824);
  *(float *)(a1 + 35840) = v191;
  v192 = (float)(v191 * *(float *)(a1 + 35872)) + *(float *)(a1 + 35856);
  *(float *)(a1 + 35840) = v192;
  v193 = (float)(v191 * *(float *)(a1 + 35888)) + v192;
  v194 = v192 * *(float *)(a1 + 35936);
  v195 = v190 - v193;
  v196 = (float)(v195 * *(float *)(a1 + 35872)) + v191;
  *(float *)(a1 + 35824) = v196;
  *(float *)(a1 + 35856) = (float)((float)(v195 * *(float *)(a1 + 35904)) + v194)
                         + (float)(v196 * *(float *)(a1 + 35920));
  *(_DWORD *)(a1 + 37968) = *(_DWORD *)(a1 + 37952);
  v197 = *(float *)(a1 + 37984);
  *(float *)(a1 + 38000) = v197;
  v198 = v197 * *(float *)(a1 + 35072);
  v199 = *(float *)(a1 + 37968) * *(float *)(a1 + 35856);
  *(float *)(a1 + 38016) = v198;
  *(float *)(a1 + 38032) = v199;
  *(_DWORD *)(a1 + 38096) = *(_DWORD *)(a1 + 38080);
  *(float *)(a1 + 38080) = (float)(v199 * *(float *)(a1 + 38064)) + (float)(v198 * *(float *)(a1 + 38048));
  *(_DWORD *)(a1 + 38128) = *(_DWORD *)(a1 + 38112);
  *(_DWORD *)(a1 + 38160) = *(_DWORD *)(a1 + 38144);
  *(_DWORD *)(a1 + 38192) = *(_DWORD *)(a1 + 38176);
  *(_DWORD *)(a1 + 38224) = *(_DWORD *)(a1 + 38208);
  v200 = (float)((float)(*(float *)(a1 + 38256) * *(float *)(a1 + 38112))
               - (float)(*(float *)(a1 + 38272) * *(float *)(a1 + 38256)))
       + *(float *)(a1 + 38272);
  v201 = (float)((float)((float)((float)(v200 * v200) * v200) * v200) * *(float *)(a1 + 38352))
       + (float)((float)((float)((float)(v200 * v200) * v200) * *(float *)(a1 + 38336))
               + (float)((float)((float)(v200 * *(float *)(a1 + 38304)) + *(float *)(a1 + 38288))
                       + (float)((float)(v200 * v200) * *(float *)(a1 + 38320))));
  if ( v201 <= 0.0 )
    v202 = 0.0;
  else
    v202 = v201;
  v203 = v202;
  if ( v203 < 1.0 )
    v42 = v203;
  v204 = v42;
  *(float *)(a1 + 38240) = v204;
  *(_DWORD *)(a1 + 38384) = *(_DWORD *)(a1 + 38368);
  v205 = *(float *)(a1 + 38400);
  *(float *)(a1 + 38416) = v205;
  v206 = *(float *)(a1 + 38432);
  *(float *)(a1 + 38448) = v206;
  *(float *)(a1 + 38432) = (float)((float)(v205 - v206) * *(float *)(a1 + 38464)) + v206;
  v207 = *(float *)(a1 + 32288);
  v208 = *(float *)(a1 + 32416);
  *(_DWORD *)(a1 + 38528) = *(_DWORD *)(a1 + 38512);
  *(float *)(a1 + 38512) = (float)(v208 * *(float *)(a1 + 38496)) + (float)(v207 * *(float *)(a1 + 38480));
  *(_DWORD *)(a1 + 38576) = *(_DWORD *)(a1 + 38544);
  v209 = *(float *)(a1 + 38560);
  *(float *)(a1 + 38592) = v209;
  v210 = *(float *)(a1 + 34288)
       + (float)((float)(*(float *)(a1 + 38576) * *(float *)(a1 + 34768))
               - (float)(*(float *)(a1 + 38576) * *(float *)(a1 + 34288)));
  *(float *)(a1 + 38608) = (float)((float)(v209 * *(float *)(a1 + 38176)) - (float)(v209 * v210)) + v210;
  v211 = *(float *)(a1 + 33328);
  v212 = *(float *)(a1 + 38624);
  *(float *)(a1 + 38640) = v212;
  v213 = v211 - v212;
  v214 = (float)(v213 * *(float *)(a1 + 38656)) + v212;
  v215 = *(float *)(a1 + 38688);
  *(float *)(a1 + 38624) = v214;
  *(float *)(a1 + 38640) = (float)(v213 * *(float *)(a1 + 38672)) + (float)(v215 * v214);
  v216 = *(float *)(a1 + 38704);
  v217 = *(float *)(a1 + 33344);
  *(float *)(a1 + 38720) = v216;
  v218 = v217 - v216;
  v219 = (float)(v218 * *(float *)(a1 + 38736)) + v216;
  v220 = *(float *)(a1 + 38768);
  *(float *)(a1 + 38704) = v219;
  v221 = (float)(v218 * *(float *)(a1 + 38752)) + (float)(v220 * v219);
  *(float *)(a1 + 38720) = v221;
  v222 = *(float *)(a1 + 38640);
  v223 = *(float *)(a1 + 38608);
  v224 = *(float *)(a1 + 38512);
  v227 = (__m128)*(unsigned int *)(a1 + 38144);
  *(_DWORD *)(a1 + 38784) = *(_DWORD *)(a1 + 38432);
  *(_DWORD *)(a1 + 38800) = v227.m128_i32[0];
  v225 = *(float *)(a1 + 38832);
  v226 = *(float *)(a1 + 38848) * *(float *)(a1 + 38208);
  v227.m128_f32[0] = (float)((float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 38864))
                                                   - (float)(*(float *)(a1 + 38992) * *(float *)(a1 + 38864)))
                                           + *(float *)(a1 + 38992))
                                   * *(float *)(a1 + 39008))
                           + (float)((float)((float)(*(float *)(a1 + 38976) + *(float *)(a1 + 38784))
                                           * *(float *)(a1 + 39040))
                                   * *(float *)(a1 + 38960)))
                   + (float)((float)((float)((float)((float)((float)(v226
                                                                   - (float)(*(float *)(a1 + 38848)
                                                                           * (float)(v221 * v225)))
                                                           + (float)(v221 * v225))
                                                   * *(float *)(a1 + 38896))
                                           * *(float *)(a1 + 38912))
                                   + (float)((float)((float)(v226
                                                           - (float)(*(float *)(a1 + 38848) * (float)(v222 * v225)))
                                                   + (float)(v222 * v225))
                                           * *(float *)(a1 + 38880)))
                           + (float)((float)((float)(v224 + *(float *)(a1 + 39024)) * *(float *)(a1 + 38944))
                                   + (float)(v223 * *(float *)(a1 + 38928))));
  *(_DWORD *)(a1 + 38816) = v227.m128_i32[0];
  v228 = *(float *)(a1 + 38240);
  v229 = *(float *)(a1 + 38384);
  *(_DWORD *)(a1 + 39120) = *(_DWORD *)(a1 + 39104);
  v230 = *(float *)(a1 + 39088);
  *(float *)(a1 + 39104) = v230;
  if ( *(float *)(a1 + 39168) == 1.0 )
  {
    v231 = *(float *)(a1 + 39120)
         + (float)((float)(*(float *)(a1 + 39248) * v230) - (float)(*(float *)(a1 + 39248) * *(float *)(a1 + 39120)));
    *(float *)(a1 + 39104) = v231;
    v232 = (float)(v231 * *(float *)(a1 + 39232)) + *(float *)(a1 + 39136);
    *(float *)(a1 + 39088) = sub_7FF91DFC8D60();
    v233 = (float)(1.0 - v229) * *(float *)(a1 + 39264);
    *(float *)(a1 + 39072) = (float)(v229 * *(float *)(a1 + 39328)) + *(float *)(a1 + 39152);
    v227.m128_f32[0] = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 39216))
                                                         + (float)(v228 * *(float *)(a1 + 39184)))
                                                 + v232)
                                         + fminf(*(float *)(a1 + 39280), v233))
                                 + *(float *)(a1 + 39200),
                                   *(float *)(a1 + 39296)),
                                 *(float *)(a1 + 39312))
                             * *(float *)(a1 + 39360))
                     + *(float *)(a1 + 39376);
    v234 = v227.m128_f32[0];
    v235 = (int)v227.m128_f32[0];
    if ( (int)v227.m128_f32[0] != 0x80000000 && (float)v235 != v227.m128_f32[0] )
      v234 = (float)(v235 - (_mm_movemask_ps(_mm_unpacklo_ps(v227, v227)) & 1));
    v236 = v227.m128_f32[0] - v234;
    v237 = (float)(v236 * v236) * 0.25;
    v238 = (float)(expf(v234)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v236 * *(float *)(a1 + 39568)) + *(float *)(a1 + 39552)) * v237) + (float)(v236 * *(float *)(a1 + 39536))) + *(float *)(a1 + 39520)) * v237) + (float)(v236 * *(float *)(a1 + 39504)))
                                                                                                 + *(float *)(a1 + 39488))
                                                                                         * v237)
                                                                                 + (float)(v236 * *(float *)(a1 + 39472)))
                                                                         + *(float *)(a1 + 39456))
                                                                 * v237)
                                                         + (float)(v236 * *(float *)(a1 + 39440)))
                                                 + *(float *)(a1 + 39424))
                                         * v237)
                                 + (float)(v236 * *(float *)(a1 + 39408)))
                         + 1.0))
         * *(float *)(a1 + 39392);
    v239 = v238 * v238;
    v240 = (float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 39728))
                                                         + *(float *)(a1 + 39696))
                                                 * (float)(v239 * v239))
                                         + (float)((float)((float)(v238 * v238) * *(float *)(a1 + 39664))
                                                 + *(float *)(a1 + 39632)))
                                 * (float)((float)((float)(v238 * v238) * v238) * (float)(v238 * v238)))
                         + (float)((float)((float)(v238 * v238) * v238) * *(float *)(a1 + 39600)))
                 + v238)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 39712))
                                                                 + *(float *)(a1 + 39680))
                                                         * (float)(v239 * v239))
                                                 + (float)((float)(v238 * v238) * *(float *)(a1 + 39648)))
                                         + *(float *)(a1 + 39616))
                                 * (float)(v239 * v239))
                         + (float)((float)(v238 * v238) * *(float *)(a1 + 39584)))
                 + 1.0);
    v241 = v240 / (float)(v240 + 1.0);
    *(float *)(a1 + 39056) = v241;
  }
  else
  {
    v241 = *(float *)(a1 + 39056);
  }
  v242 = *(float *)(a1 + 38080);
  v243 = *(float *)(a1 + 39072);
  *(_DWORD *)(a1 + 39856) = *(_DWORD *)(a1 + 39840);
  *(_DWORD *)(a1 + 39840) = *(_DWORD *)(a1 + 39824);
  *(_DWORD *)(a1 + 39824) = *(_DWORD *)(a1 + 39808);
  *(_DWORD *)(a1 + 39808) = *(_DWORD *)(a1 + 39792);
  *(_DWORD *)(a1 + 39792) = *(_DWORD *)(a1 + 39776);
  *(_DWORD *)(a1 + 39776) = *(_DWORD *)(a1 + 39760);
  *(_DWORD *)(a1 + 39760) = *(_DWORD *)(a1 + 39744);
  *(_DWORD *)(a1 + 40080) = *(_DWORD *)(a1 + 40064);
  *(_DWORD *)(a1 + 40064) = *(_DWORD *)(a1 + 40048);
  *(_DWORD *)(a1 + 40048) = *(_DWORD *)(a1 + 40032);
  *(_DWORD *)(a1 + 40032) = *(_DWORD *)(a1 + 40016);
  *(_DWORD *)(a1 + 40016) = *(_DWORD *)(a1 + 40000);
  *(_DWORD *)(a1 + 40000) = *(_DWORD *)(a1 + 39984);
  *(_DWORD *)(a1 + 39984) = *(_DWORD *)(a1 + 39968);
  *(_DWORD *)(a1 + 40208) = *(_DWORD *)(a1 + 40192);
  *(_DWORD *)(a1 + 40192) = *(_DWORD *)(a1 + 40176);
  *(_DWORD *)(a1 + 40176) = *(_DWORD *)(a1 + 40160);
  *(_DWORD *)(a1 + 40160) = *(_DWORD *)(a1 + 40144);
  *(_DWORD *)(a1 + 40144) = *(_DWORD *)(a1 + 40128);
  *(_DWORD *)(a1 + 40128) = *(_DWORD *)(a1 + 40112);
  *(_DWORD *)(a1 + 40112) = *(_DWORD *)(a1 + 40096);
  *(_DWORD *)(a1 + 40336) = *(_DWORD *)(a1 + 40320);
  *(_DWORD *)(a1 + 40320) = *(_DWORD *)(a1 + 40304);
  *(_DWORD *)(a1 + 40304) = *(_DWORD *)(a1 + 40288);
  *(_DWORD *)(a1 + 40288) = *(_DWORD *)(a1 + 40272);
  *(_DWORD *)(a1 + 40272) = *(_DWORD *)(a1 + 40256);
  *(_DWORD *)(a1 + 40256) = *(_DWORD *)(a1 + 40240);
  *(_DWORD *)(a1 + 40240) = *(_DWORD *)(a1 + 40224);
  *(_DWORD *)(a1 + 40464) = *(_DWORD *)(a1 + 40448);
  *(_DWORD *)(a1 + 40448) = *(_DWORD *)(a1 + 40432);
  *(_DWORD *)(a1 + 40432) = *(_DWORD *)(a1 + 40416);
  *(_DWORD *)(a1 + 40416) = *(_DWORD *)(a1 + 40400);
  *(_DWORD *)(a1 + 40400) = *(_DWORD *)(a1 + 40384);
  *(_DWORD *)(a1 + 40384) = *(_DWORD *)(a1 + 40368);
  *(_DWORD *)(a1 + 40368) = *(_DWORD *)(a1 + 40352);
  *(_DWORD *)(a1 + 40496) = *(_DWORD *)(a1 + 40480);
  v244 = *(float *)(a1 + 40512);
  *(float *)(a1 + 40528) = v244;
  if ( *(float *)(a1 + 40592) == 1.0 )
  {
    v245 = (float)((float)((float)(v243 * *(float *)(a1 + 40704)) + 1.0) * (float)(v242 * *(float *)(a1 + 40672)))
         + (float)((float)-v244 * *(float *)(a1 + 40656));
    *(float *)(a1 + 40512) = sub_7FF91DFC8D60();
    *(float *)(a1 + 40480) = v245;
    v246 = 1.0 - (float)(v241 + v241);
    v247 = 1.0 / (float)((float)((float)((float)(v241 * v241) * (float)(v241 * v241)) * v243) + 1.0);
    *(float *)(a1 + 40560) = v247;
    v248 = *(float *)(a1 + 40480);
    v249 = *(float *)(a1 + 40496);
    *(float *)(a1 + 40544) = v247 * v243;
    v250 = v249 * *(float *)(a1 + 40752);
    v251 = *(float *)(a1 + 39840);
    v252 = v248 * *(float *)(a1 + 40768);
    v253 = *(float *)(a1 + 39856);
    *(float *)(a1 + 39952) = v251;
    v254 = (float)((float)(v250 + v252) * v247)
         - (float)((float)((float)(v251 * *(float *)(a1 + 41056)) + (float)(v253 * *(float *)(a1 + 41072)))
                 * (float)(v247 * v243));
    if ( v254 >= -1.0 )
      v255 = fminf(v254, 1.0);
    else
      v255 = -1.0;
    v256 = v255 + (float)((float)((float)((float)(v255 * v255) * v255) * v255) * (float)(v255 * *(float *)(a1 + 40720)));
    *(float *)(a1 + 39872) = v256;
    v257 = *(float *)(a1 + 39776);
    v258 = (float)(v241 * (float)(v256 + *(float *)(a1 + 39760))) + (float)(v257 * v246);
    *(float *)(a1 + 39888) = v258;
    v259 = *(float *)(a1 + 39792);
    v260 = v241 * (float)(v258 + v257);
    v261 = v241 * (float)((float)((float)(v241 * v256) + (float)(v246 * v258)) + v258);
    v262 = v260 + (float)(v259 * v246);
    *(float *)(a1 + 39904) = v262;
    v263 = *(float *)(a1 + 39808);
    v264 = (float)(v241 * (float)(v262 + v259)) + (float)(v263 * v246);
    *(float *)(a1 + 39920) = v264;
    v265 = (float)((float)(v263 + v264) * v241) + (float)(v246 * *(float *)(a1 + 39824));
    *(float *)(a1 + 39936) = v265;
    v266 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v261 + (float)(v246 * v262)) + v262))
                                 + (float)(v246 * v264))
                         + v264))
         + (float)(v246 * v265);
    v267 = (float)(*(float *)(a1 + 39920) * *(float *)(a1 + 40624)) + (float)(v265 * *(float *)(a1 + 40640));
    v268 = *(float *)(a1 + 40496);
    *(float *)(a1 + 40352) = v267 + (float)(*(float *)(a1 + 40608) * *(float *)(a1 + 39904));
    v269 = *(float *)(a1 + 39952);
    v270 = (float)((float)(v268 + *(float *)(a1 + 40480)) * *(float *)(a1 + 40784)) * *(float *)(a1 + 40560);
    *(float *)(a1 + 39952) = v266;
    v271 = v270
         - (float)((float)((float)(v266 * *(float *)(a1 + 41056)) + (float)(v269 * *(float *)(a1 + 41072)))
                 * *(float *)(a1 + 40544));
    if ( v271 >= -1.0 )
      v272 = fminf(v271, 1.0);
    else
      v272 = -1.0;
    v273 = v272 + (float)((float)((float)((float)(v272 * v272) * v272) * v272) * (float)(v272 * *(float *)(a1 + 40720)));
    v274 = *(float *)(a1 + 39872);
    *(float *)(a1 + 39872) = v273;
    v275 = *(float *)(a1 + 39888);
    v276 = (float)(v241 * (float)(v273 + v274)) + (float)(v275 * v246);
    *(float *)(a1 + 39888) = v276;
    v277 = *(float *)(a1 + 39904);
    v278 = v241 * (float)(v276 + v275);
    v279 = v241 * (float)((float)((float)(v241 * v273) + (float)(v246 * v276)) + v276);
    v280 = v278 + (float)(v277 * v246);
    *(float *)(a1 + 39904) = v280;
    v281 = *(float *)(a1 + 39920);
    v282 = (float)(v241 * (float)(v280 + v277)) + (float)(v281 * v246);
    *(float *)(a1 + 39920) = v282;
    v283 = (float)((float)(v281 + v282) * v241) + (float)(v246 * *(float *)(a1 + 39936));
    *(float *)(a1 + 39936) = v283;
    v284 = *(float *)(a1 + 40480);
    v285 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v279 + (float)(v246 * v280)) + v280))
                                 + (float)(v246 * v282))
                         + v282))
         + (float)(v246 * v283);
    v286 = (float)(*(float *)(a1 + 39920) * *(float *)(a1 + 40624)) + (float)(v283 * *(float *)(a1 + 40640));
    v287 = *(float *)(a1 + 40496);
    *(float *)(a1 + 40224) = v286 + (float)(*(float *)(a1 + 40608) * *(float *)(a1 + 39904));
    v288 = *(float *)(a1 + 39952);
    v289 = (float)((float)(v287 * *(float *)(a1 + 40768)) + (float)(v284 * *(float *)(a1 + 40752)))
         * *(float *)(a1 + 40560);
    *(float *)(a1 + 39952) = v285;
    v290 = v289
         - (float)((float)((float)(v285 * *(float *)(a1 + 41056)) + (float)(v288 * *(float *)(a1 + 41072)))
                 * *(float *)(a1 + 40544));
    if ( v290 >= -1.0 )
      v291 = fminf(v290, 1.0);
    else
      v291 = -1.0;
    v292 = v291 + (float)((float)((float)((float)(v291 * v291) * v291) * v291) * (float)(v291 * *(float *)(a1 + 40720)));
    v293 = *(float *)(a1 + 39872);
    *(float *)(a1 + 39872) = v292;
    v294 = *(float *)(a1 + 39888);
    v295 = (float)(v241 * (float)(v292 + v293)) + (float)(v294 * v246);
    *(float *)(a1 + 39888) = v295;
    v296 = *(float *)(a1 + 39904);
    v297 = v241 * (float)(v295 + v294);
    v298 = v241 * (float)((float)((float)(v241 * v292) + (float)(v246 * v295)) + v295);
    v299 = v297 + (float)(v296 * v246);
    *(float *)(a1 + 39904) = v299;
    v300 = *(float *)(a1 + 39920);
    v301 = (float)(v241 * (float)(v299 + v296)) + (float)(v300 * v246);
    *(float *)(a1 + 39920) = v301;
    v302 = (float)((float)(v300 + v301) * v241) + (float)(v246 * *(float *)(a1 + 39936));
    *(float *)(a1 + 39936) = v302;
    v303 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v298 + (float)(v246 * v299)) + v299))
                                 + (float)(v246 * v301))
                         + v301))
         + (float)(v246 * v302);
    v304 = (float)(*(float *)(a1 + 39920) * *(float *)(a1 + 40624)) + (float)(v302 * *(float *)(a1 + 40640));
    v305 = *(float *)(a1 + 40480);
    *(float *)(a1 + 40096) = v304 + (float)(*(float *)(a1 + 40608) * *(float *)(a1 + 39904));
    v306 = *(float *)(a1 + 39952);
    v307 = (float)(v305 * *(float *)(a1 + 40736)) * *(float *)(a1 + 40560);
    *(float *)(a1 + 39840) = v303;
    v308 = v307
         - (float)((float)((float)(v303 * *(float *)(a1 + 41056)) + (float)(v306 * *(float *)(a1 + 41072)))
                 * *(float *)(a1 + 40544));
    if ( v308 >= -1.0 )
      v309 = fminf(v308, 1.0);
    else
      v309 = -1.0;
    v310 = v309 + (float)((float)((float)((float)(v309 * v309) * v309) * v309) * (float)(v309 * *(float *)(a1 + 40720)));
    *(float *)(a1 + 39744) = v310;
    v311 = *(float *)(a1 + 39888);
    v312 = (float)(v241 * (float)(v310 + *(float *)(a1 + 39872))) + (float)(v311 * v246);
    *(float *)(a1 + 39760) = v312;
    v313 = *(float *)(a1 + 39904);
    v314 = v241 * (float)(v312 + v311);
    v315 = v241 * (float)((float)((float)(v241 * v310) + (float)(v246 * v312)) + v312);
    v316 = v314 + (float)(v313 * v246);
    *(float *)(a1 + 39776) = v316;
    v317 = *(float *)(a1 + 39920);
    v318 = (float)(v241 * (float)(v316 + v313)) + (float)(v317 * v246);
    *(float *)(a1 + 39792) = v318;
    v319 = (float)((float)(v317 + v318) * v241) + (float)(v246 * *(float *)(a1 + 39936));
    v320 = v241
         * (float)((float)((float)(v241 * (float)((float)(v315 + (float)(v246 * v316)) + v316)) + (float)(v246 * v318))
                 + v318);
    *(float *)(a1 + 39808) = v319;
    v321 = *(float *)(a1 + 39776);
    *(float *)(a1 + 39824) = v320 + (float)(v246 * v319);
    v322 = *(float *)(a1 + 40032);
    v323 = (float)((float)(v319 * *(float *)(a1 + 40640)) + (float)(*(float *)(a1 + 40624) * *(float *)(a1 + 39792)))
         + (float)(v321 * *(float *)(a1 + 40608));
    *(float *)(a1 + 39968) = v323;
    v324 = (float)(v323 + *(float *)(a1 + 40464)) * *(float *)(a1 + 40800);
    v325 = (float)(*(float *)(a1 + 40224) + *(float *)(a1 + 40208)) * *(float *)(a1 + 40832);
    v326 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v322 + *(float *)(a1 + 40400)) * *(float *)(a1 + 41040)) + (float)((float)(*(float *)(a1 + 40160) + *(float *)(a1 + 40272)) * *(float *)(a1 + 41024))) + (float)((float)(*(float *)(a1 + 40288) + *(float *)(a1 + 40144)) * *(float *)(a1 + 41008))) + (float)((float)(*(float *)(a1 + 40016) + *(float *)(a1 + 40416)) * *(float *)(a1 + 40992))) + (float)((float)(*(float *)(a1 + 40384) + *(float *)(a1 + 40048)) * *(float *)(a1 + 40976)))
                                                                                                 + (float)((float)(*(float *)(a1 + 40256) + *(float *)(a1 + 40176)) * *(float *)(a1 + 40960)))
                                                                                         + (float)((float)(*(float *)(a1 + 40304) + *(float *)(a1 + 40128))
                                                                                                 * *(float *)(a1 + 40944)))
                                                                                 + (float)((float)(*(float *)(a1 + 40432)
                                                                                                 + *(float *)(a1 + 40000))
                                                                                         * *(float *)(a1 + 40928)))
                                                                         + (float)((float)(*(float *)(a1 + 40368)
                                                                                         + *(float *)(a1 + 40064))
                                                                                 * *(float *)(a1 + 40912)))
                                                                 + (float)((float)(*(float *)(a1 + 40240)
                                                                                 + *(float *)(a1 + 40192))
                                                                         * *(float *)(a1 + 40896)))
                                                         + (float)((float)(*(float *)(a1 + 40320)
                                                                         + *(float *)(a1 + 40112))
                                                                 * *(float *)(a1 + 40880)))
                                                 + (float)((float)(*(float *)(a1 + 40448) + *(float *)(a1 + 39984))
                                                         * *(float *)(a1 + 40864)))
                                         + (float)((float)(*(float *)(a1 + 40352) + *(float *)(a1 + 40080))
                                                 * *(float *)(a1 + 40848)))
                                 + v325)
                         + (float)((float)(*(float *)(a1 + 40336) + *(float *)(a1 + 40096)) * *(float *)(a1 + 40816)))
                 + v324)
         * *(float *)(a1 + 40688);
    *(float *)(a1 + 40576) = v326;
  }
  *(_DWORD *)(a1 + 41104) = *(_DWORD *)(a1 + 41088);
  v327 = *(_DWORD *)(a1 + 41136);
  *(_DWORD *)(a1 + 41168) = *(_DWORD *)(a1 + 41120);
  *(_DWORD *)(a1 + 41184) = v327;
  *(_DWORD *)(a1 + 41200) = *(_DWORD *)(a1 + 41152);
  v328 = *(float *)(a1 + 41216);
  *(float *)(a1 + 41232) = v328;
  v329 = *(float *)(a1 + 41248);
  *(float *)(a1 + 41264) = v329;
  v330 = (float)((float)(v328 - v329) * *(float *)(a1 + 41280)) + v329;
  *(float *)(a1 + 41248) = v330;
  v331 = (float)((float)(v330 * *(float *)(a1 + 41184)) - (float)(*(float *)(a1 + 41184) * *(float *)(a1 + 41200)))
       + *(float *)(a1 + 41200);
  *(float *)(a1 + 41296) = v331;
  v332 = *(float *)(a1 + 41312);
  *(float *)(a1 + 41328) = v332;
  v333 = (float)((float)(*(float *)(a1 + 41344) * v331) - (float)(*(float *)(a1 + 41344) * v332)) + v332;
  if ( v333 <= 0.0 )
    v334 = 0.0;
  else
    v334 = v333;
  v335 = v334;
  *(float *)(a1 + 41312) = v335;
  v336 = *(float *)(a1 + 41360);
  *(float *)(a1 + 41376) = v336;
  v337 = *(float *)(a1 + 41392);
  *(float *)(a1 + 41408) = v337;
  v338 = (float)((float)(*(float *)(a1 + 41424) * v336) - (float)(*(float *)(a1 + 41424) * v337)) + v337;
  if ( v338 <= 0.0 )
    v339 = 0.0;
  else
    v339 = v338;
  v340 = v339;
  *(float *)(a1 + 41392) = v340;
  v341 = *(float *)(a1 + 41440);
  v342 = *(float *)(a1 + 32096);
  *(float *)(a1 + 41456) = v341;
  v343 = v341 * *(float *)(a1 + 41536);
  v344 = v341 + *(float *)(a1 + 41520);
  if ( v343 >= -1.0 )
    v345 = fminf(v343, 1.0);
  else
    v345 = -1.0;
  if ( (float)(v341 + *(float *)(a1 + 41488)) >= 0.0 )
    v344 = (float)((float)(*(float *)(a1 + 41504) * v342) - (float)(*(float *)(a1 + 41504) * v341)) + v341;
  v346 = (float)((float)(v345 * *(float *)(a1 + 41552)) - (float)(*(float *)(a1 + 41568) * v345))
       + *(float *)(a1 + 41568);
  v347 = (float)((float)(v346 * v342) - (float)(v346 * v341)) + v341;
  if ( v342 != 0.0 )
    v347 = v344;
  *(float *)(a1 + 41472) = v347;
  *(float *)(a1 + 41440) = v347;
  v348 = *(float *)(a1 + 40576);
  v349 = *(float *)(a1 + 34288);
  v350 = *(float *)(a1 + 38384);
  v351 = *(_DWORD *)(a1 + 34768);
  v352 = *(_DWORD *)(a1 + 41088);
  *(_DWORD *)(a1 + 41648) = *(_DWORD *)(a1 + 41632);
  *(_DWORD *)(a1 + 41680) = *(_DWORD *)(a1 + 41664);
  *(_DWORD *)(a1 + 41584) = v351;
  *(_DWORD *)(a1 + 41600) = v352;
  v353 = *(float *)(a1 + 41648);
  v354 = *(float *)(a1 + 41712);
  *(float *)(a1 + 41616) = v350 * *(float *)(a1 + 41872);
  v355 = v348 - v353;
  v356 = *(float *)(a1 + 41744);
  v357 = (float)(v349 * *(float *)(a1 + 41728)) + (float)(v354 * *(float *)(a1 + 41472));
  v358 = v353 + (float)((float)(v348 - v353) * *(float *)(a1 + 41776));
  *(float *)(a1 + 41632) = v358;
  v359 = (float)(v355 * *(float *)(a1 + 41888)) + (float)(v358 * *(float *)(a1 + 41904));
  v360 = (float)((float)(*(float *)(a1 + 41760) * *(float *)(a1 + 41600))
               - (float)(*(float *)(a1 + 41760) * (float)(v357 + (float)(v356 * *(float *)(a1 + 41584)))))
       + (float)(v357 + (float)(v356 * *(float *)(a1 + 41584)));
  v361 = *(float *)(a1 + 41792);
  v362 = v360 * *(float *)(a1 + 41840);
  v363 = v348 * (float)(1.0 - v361);
  if ( v362 <= 0.0 )
    v364 = 0.0;
  else
    v364 = v362;
  v365 = *(float *)(a1 + 41808);
  v366 = v364;
  v367 = v366 * *(float *)(a1 + 41856);
  v368 = (float)((float)(v361 * v359) + v363) * (float)(*(float *)(a1 + 41616) + 1.0);
  v369 = *(float *)(a1 + 41824) * v368;
  v370 = *(float *)(a1 + 41680)
       + (float)((float)(*(float *)(a1 + 41920) * v368) - (float)(*(float *)(a1 + 41920) * *(float *)(a1 + 41680)));
  *(float *)(a1 + 41664) = v370;
  v371 = (float)((float)((float)(v365 * v370) + v369) * v367) * *(float *)(a1 + 41936);
  *(float *)(a1 + 41696) = v371;
  *(_DWORD *)(a1 + 41984) = *(_DWORD *)(a1 + 41968);
  *(_DWORD *)(a1 + 41968) = *(_DWORD *)(a1 + 41952);
  v372 = *(float *)(a1 + 41984);
  v373 = *(float *)(a1 + 42000);
  v374 = v371 - v372;
  *(float *)(a1 + 41952) = v374;
  *(float *)(a1 + 41968) = (float)(v373 * v374) + v372;
  v375 = *(float *)(a1 + 41952);
  v376 = *(float *)(a1 + 41168);
  *(_DWORD *)(a1 + 42064) = *(_DWORD *)(a1 + 42048);
  *(_DWORD *)(a1 + 42048) = *(_DWORD *)(a1 + 42032);
  *(_DWORD *)(a1 + 42032) = *(_DWORD *)(a1 + 42016);
  *(float *)(a1 + 42016) = v375;
  v377 = (float)((float)(*(float *)(a1 + 42032) * *(float *)(a1 + 42112)) + (float)(v375 * *(float *)(a1 + 42096)))
       + (float)(*(float *)(a1 + 42128) * *(float *)(a1 + 42048));
  v378 = (float)((float)(*(float *)(a1 + 42032) * *(float *)(a1 + 42160)) + (float)(v375 * *(float *)(a1 + 42144)))
       + (float)(*(float *)(a1 + 42176) * *(float *)(a1 + 42064));
  if ( v376 <= 0.0 )
    v379 = 0.0;
  else
    v379 = v376;
  *(float *)(a1 + 42032) = v377;
  v380 = v379;
  *(float *)(a1 + 42048) = v378;
  v381 = (float)((float)(v380 * v377) - (float)(v380 * v375)) + v375;
  if ( v376 < -0.0 )
    v19 = (float)-v376;
  v382 = v19;
  v383 = v375 + (float)((float)(v382 * v378) - (float)(v382 * v375));
  if ( v376 >= 0.0 )
    v383 = v381;
  *(float *)(a1 + 42080) = v383;
  v384 = v383 * *(float *)(a1 + 41312);
  *(float *)(a1 + 42192) = v384;
  *(float *)(a1 + 42208) = v384 * *(float *)(a1 + 41392);
  v385 = fmin(fmax((float)(*(float *)(a1 + 35984) + *(float *)(a1 + 35312)), -20.0), 8.9);
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
       * *(float *)(a1 + 35328);
  *(float *)(a1 + 35952) = v391;
  v392 = *(float *)(a1 + 35312);
  v393 = *(_DWORD *)(a1 + 35776);
  v394 = *(_DWORD *)(a1 + 35792);
  LODWORD(v386) = *(_DWORD *)(a1 + 35808);
  *(_DWORD *)(a1 + 36384) = *(_DWORD *)(a1 + 36368);
  *(_DWORD *)(a1 + 36416) = *(_DWORD *)(a1 + 36400);
  *(_DWORD *)(a1 + 36592) = *(_DWORD *)(a1 + 36576);
  *(_DWORD *)(a1 + 36576) = *(_DWORD *)(a1 + 36560);
  *(_DWORD *)(a1 + 36560) = *(_DWORD *)(a1 + 36544);
  *(_DWORD *)(a1 + 36544) = *(_DWORD *)(a1 + 36528);
  *(_DWORD *)(a1 + 36528) = *(_DWORD *)(a1 + 36512);
  *(_DWORD *)(a1 + 36512) = *(_DWORD *)(a1 + 36496);
  *(_DWORD *)(a1 + 36496) = *(_DWORD *)(a1 + 36480);
  *(_DWORD *)(a1 + 36720) = *(_DWORD *)(a1 + 36704);
  *(_DWORD *)(a1 + 36704) = *(_DWORD *)(a1 + 36688);
  *(_DWORD *)(a1 + 36688) = *(_DWORD *)(a1 + 36672);
  *(_DWORD *)(a1 + 36672) = *(_DWORD *)(a1 + 36656);
  *(_DWORD *)(a1 + 36656) = *(_DWORD *)(a1 + 36640);
  *(_DWORD *)(a1 + 36640) = *(_DWORD *)(a1 + 36624);
  *(_DWORD *)(a1 + 36624) = *(_DWORD *)(a1 + 36608);
  *(_DWORD *)(a1 + 36848) = *(_DWORD *)(a1 + 36832);
  *(_DWORD *)(a1 + 36832) = *(_DWORD *)(a1 + 36816);
  *(_DWORD *)(a1 + 36816) = *(_DWORD *)(a1 + 36800);
  *(_DWORD *)(a1 + 36800) = *(_DWORD *)(a1 + 36784);
  *(_DWORD *)(a1 + 36784) = *(_DWORD *)(a1 + 36768);
  *(_DWORD *)(a1 + 36768) = *(_DWORD *)(a1 + 36752);
  *(_DWORD *)(a1 + 36752) = *(_DWORD *)(a1 + 36736);
  *(_DWORD *)(a1 + 36976) = *(_DWORD *)(a1 + 36960);
  *(_DWORD *)(a1 + 36960) = *(_DWORD *)(a1 + 36944);
  *(_DWORD *)(a1 + 36944) = *(_DWORD *)(a1 + 36928);
  *(_DWORD *)(a1 + 36928) = *(_DWORD *)(a1 + 36912);
  *(_DWORD *)(a1 + 36912) = *(_DWORD *)(a1 + 36896);
  *(_DWORD *)(a1 + 36896) = *(_DWORD *)(a1 + 36880);
  *(_DWORD *)(a1 + 36880) = *(_DWORD *)(a1 + 36864);
  *(_DWORD *)(a1 + 37040) = *(_DWORD *)(a1 + 37024);
  *(_DWORD *)(a1 + 37024) = *(_DWORD *)(a1 + 37008);
  *(_DWORD *)(a1 + 36272) = v393;
  *(_DWORD *)(a1 + 36288) = v394;
  v395 = v392 + *(float *)(a1 + 37840);
  v396 = v391 * *(float *)(a1 + 37072);
  v397 = *(float *)(a1 + 37056);
  *(_DWORD *)(a1 + 36304) = LODWORD(v386);
  v398 = fmaxf(*(float *)(a1 + 37104), v396);
  v399 = (float)(v395 * *(float *)(a1 + 37856)) + *(float *)(a1 + 37824);
  *(float *)(a1 + 36320) = v398;
  *(float *)(a1 + 36352) = v397 + *(float *)(a1 + 35344);
  if ( v399 <= 0.0 )
    v400 = 0.0;
  else
    v400 = v399;
  *(float *)(a1 + 36336) = 0.00390625 / v398;
  *(float *)(a1 + 36992) = v400;
  v401 = *(float *)(a1 + 36416);
  v402 = *(_DWORD *)(a1 + 36384);
  *(float *)(a1 + 36192) = v401;
  v403 = v401 + v398;
  *(_DWORD *)(a1 + 36208) = v402;
  if ( v403 <= 1.0 )
  {
    if ( v403 < -1.0 )
      v403 = fmodf(v403 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v403 = fmodf(v403 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 36176) = v403;
  v404 = v403 * *(float *)(a1 + 37184);
  v405 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v406 = (float)((float)(*(float *)&v405 * 256.0) * *(float *)(a1 + 36336)) * *(float *)(a1 + 37136);
  if ( v406 >= -1.0 )
    v407 = fminf(v406, 1.0);
  else
    v407 = -1.0;
  v408 = v407 * *(float *)(a1 + 37088);
  v409 = (float)(v408 * v408) * v408;
  v410 = v409 * *(float *)(a1 + 37488);
  v411 = (float)((float)((float)((float)((float)(v408 * v408) * *(float *)(a1 + 37552)) + *(float *)(a1 + 37536))
                       * (float)((float)(v408 * v408) * (float)(v408 * v408)))
               + (float)((float)((float)(v408 * v408) * *(float *)(a1 + 37520)) + *(float *)(a1 + 37504)))
       * (float)(v409 * (float)(v408 * v408));
  v412 = *(float *)(a1 + 36352) + v403;
  *(float *)(a1 + 36432) = (float)((float)(v411 + v410) + v408) * v404;
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
  v414 = *(float *)(a1 + 36176);
  v415 = v413 * *(float *)(a1 + 37200);
  v416 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v417 = *(float *)&v416;
  v418 = *(float *)(a1 + 37120);
  if ( v414 < v418 || v418 <= *(float *)(a1 + 36192) )
    v419 = *(float *)(a1 + 36208);
  else
    v419 = *(float *)(a1 + 36208) + 2.0;
  v420 = (float)((float)(v417 * *(float *)(a1 + 36336)) * 256.0) * *(float *)(a1 + 37152);
  if ( v419 >= 4.0 )
    v419 = 0.0;
  if ( v420 >= -1.0 )
    v421 = fminf(v420, 1.0);
  else
    v421 = -1.0;
  *(float *)(a1 + 36208) = v419;
  v422 = v421 * *(float *)(a1 + 37088);
  v423 = (float)((float)((float)(v419 + v414) + 1.0) * 0.5) - 1.0;
  v424 = (float)((float)((float)((float)((float)((float)((float)((float)(v422 * v422) * *(float *)(a1 + 37552))
                                                       + *(float *)(a1 + 37536))
                                               * (float)((float)(v422 * v422) * (float)(v422 * v422)))
                                       + (float)((float)((float)(v422 * v422) * *(float *)(a1 + 37520))
                                               + *(float *)(a1 + 37504)))
                               * (float)((float)((float)(v422 * v422) * v422) * (float)(v422 * v422)))
                       + (float)((float)((float)(v422 * v422) * v422) * *(float *)(a1 + 37488)))
               + v422)
       * v415;
  *(float *)(a1 + 36448) = v424;
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
  v426 = v423 * *(float *)(a1 + 37216);
  v427 = (float)((float)((float)(*(float *)&v425 + 1.0) * *(float *)(a1 + 36336)) * 512.0) * *(float *)(a1 + 37168);
  if ( v427 >= -1.0 )
    v428 = fminf(v427, 1.0);
  else
    v428 = -1.0;
  v429 = v428 * *(float *)(a1 + 37088);
  v430 = *(float *)(a1 + 36176);
  v431 = *(_DWORD *)(a1 + 36208);
  *(float *)(a1 + 36480) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v429 * v429)
                                                                                                 * *(float *)(a1 + 37552))
                                                                                         + *(float *)(a1 + 37536))
                                                                                 * (float)((float)(v429 * v429)
                                                                                         * (float)(v429 * v429)))
                                                                         + (float)((float)((float)(v429 * v429)
                                                                                         * *(float *)(a1 + 37520))
                                                                                 + *(float *)(a1 + 37504)))
                                                                 * (float)((float)((float)(v429 * v429) * v429)
                                                                         * (float)(v429 * v429)))
                                                         + (float)((float)((float)(v429 * v429) * v429)
                                                                 * *(float *)(a1 + 37488)))
                                                 + v429)
                                         * v426)
                                 * *(float *)(a1 + 36304))
                         + (float)((float)(*(float *)(a1 + 36432) * *(float *)(a1 + 36272))
                                 + (float)(v424 * *(float *)(a1 + 36288)));
  *(float *)(a1 + 36192) = v430;
  *(_DWORD *)(a1 + 36208) = v431;
  v432 = v430 + *(float *)(a1 + 36320);
  if ( v432 <= 1.0 )
  {
    if ( v432 < -1.0 )
      v432 = fmodf(v432 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v432 = fmodf(v432 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 36176) = v432;
  v433 = v432 * *(float *)(a1 + 37184);
  v434 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v435 = (float)((float)(*(float *)&v434 * 256.0) * *(float *)(a1 + 36336)) * *(float *)(a1 + 37136);
  if ( v435 >= -1.0 )
    v436 = fminf(v435, 1.0);
  else
    v436 = -1.0;
  v437 = v436 * *(float *)(a1 + 37088);
  v438 = (float)(v437 * v437) * v437;
  v439 = v438 * *(float *)(a1 + 37488);
  v440 = (float)((float)((float)((float)((float)(v437 * v437) * *(float *)(a1 + 37552)) + *(float *)(a1 + 37536))
                       * (float)((float)(v437 * v437) * (float)(v437 * v437)))
               + (float)((float)((float)(v437 * v437) * *(float *)(a1 + 37520)) + *(float *)(a1 + 37504)))
       * (float)(v438 * (float)(v437 * v437));
  v441 = *(float *)(a1 + 36352) + v432;
  *(float *)(a1 + 36432) = (float)((float)(v440 + v439) + v437) * v433;
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
  v443 = *(float *)(a1 + 36176);
  v444 = v442 * *(float *)(a1 + 37200);
  v445 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v446 = *(float *)&v445;
  v447 = *(float *)(a1 + 37120);
  if ( v443 < v447 || v447 <= *(float *)(a1 + 36192) )
    v448 = *(float *)(a1 + 36208);
  else
    v448 = *(float *)(a1 + 36208) + 2.0;
  v449 = (float)((float)(v446 * *(float *)(a1 + 36336)) * 256.0) * *(float *)(a1 + 37152);
  if ( v448 >= 4.0 )
    v448 = 0.0;
  if ( v449 >= -1.0 )
    v450 = fminf(v449, 1.0);
  else
    v450 = -1.0;
  *(float *)(a1 + 36208) = v448;
  v451 = v450 * *(float *)(a1 + 37088);
  v452 = (float)((float)((float)(v448 + v443) + 1.0) * 0.5) - 1.0;
  v453 = (float)((float)((float)((float)((float)((float)((float)((float)(v451 * v451) * *(float *)(a1 + 37552))
                                                       + *(float *)(a1 + 37536))
                                               * (float)((float)(v451 * v451) * (float)(v451 * v451)))
                                       + (float)((float)((float)(v451 * v451) * *(float *)(a1 + 37520))
                                               + *(float *)(a1 + 37504)))
                               * (float)((float)((float)(v451 * v451) * v451) * (float)(v451 * v451)))
                       + (float)((float)((float)(v451 * v451) * v451) * *(float *)(a1 + 37488)))
               + v451)
       * v444;
  *(float *)(a1 + 36448) = v453;
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
  v455 = v452 * *(float *)(a1 + 37216);
  v456 = (float)((float)((float)(*(float *)&v454 + 1.0) * *(float *)(a1 + 36336)) * 512.0) * *(float *)(a1 + 37168);
  if ( v456 >= -1.0 )
    v457 = fminf(v456, 1.0);
  else
    v457 = -1.0;
  v458 = v457 * *(float *)(a1 + 37088);
  v459 = *(float *)(a1 + 36176);
  v460 = *(_DWORD *)(a1 + 36208);
  *(float *)(a1 + 36608) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v458 * v458)
                                                                                                 * *(float *)(a1 + 37552))
                                                                                         + *(float *)(a1 + 37536))
                                                                                 * (float)((float)(v458 * v458)
                                                                                         * (float)(v458 * v458)))
                                                                         + (float)((float)((float)(v458 * v458)
                                                                                         * *(float *)(a1 + 37520))
                                                                                 + *(float *)(a1 + 37504)))
                                                                 * (float)((float)((float)(v458 * v458) * v458)
                                                                         * (float)(v458 * v458)))
                                                         + (float)((float)((float)(v458 * v458) * v458)
                                                                 * *(float *)(a1 + 37488)))
                                                 + v458)
                                         * v455)
                                 * *(float *)(a1 + 36304))
                         + (float)((float)(*(float *)(a1 + 36432) * *(float *)(a1 + 36272))
                                 + (float)(v453 * *(float *)(a1 + 36288)));
  *(float *)(a1 + 36192) = v459;
  *(_DWORD *)(a1 + 36208) = v460;
  v461 = v459 + *(float *)(a1 + 36320);
  if ( v461 <= 1.0 )
  {
    if ( v461 < -1.0 )
      v461 = fmodf(v461 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v461 = fmodf(v461 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 36176) = v461;
  v462 = v461 * *(float *)(a1 + 37184);
  v463 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v464 = (float)((float)(*(float *)&v463 * 256.0) * *(float *)(a1 + 36336)) * *(float *)(a1 + 37136);
  if ( v464 >= -1.0 )
    v465 = fminf(v464, 1.0);
  else
    v465 = -1.0;
  v466 = v465 * *(float *)(a1 + 37088);
  v467 = (float)(v466 * v466) * v466;
  v468 = v467 * *(float *)(a1 + 37488);
  v469 = (float)((float)((float)((float)((float)(v466 * v466) * *(float *)(a1 + 37552)) + *(float *)(a1 + 37536))
                       * (float)((float)(v466 * v466) * (float)(v466 * v466)))
               + (float)((float)((float)(v466 * v466) * *(float *)(a1 + 37520)) + *(float *)(a1 + 37504)))
       * (float)(v467 * (float)(v466 * v466));
  v470 = *(float *)(a1 + 36352) + v461;
  *(float *)(a1 + 36432) = (float)((float)(v469 + v468) + v466) * v462;
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
  v472 = *(float *)(a1 + 36176);
  v473 = v471 * *(float *)(a1 + 37200);
  v474 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v475 = *(float *)&v474;
  v476 = *(float *)(a1 + 37120);
  if ( v472 < v476 || v476 <= *(float *)(a1 + 36192) )
    v477 = *(float *)(a1 + 36208);
  else
    v477 = *(float *)(a1 + 36208) + 2.0;
  v478 = (float)((float)(v475 * *(float *)(a1 + 36336)) * 256.0) * *(float *)(a1 + 37152);
  if ( v477 >= 4.0 )
    v477 = 0.0;
  if ( v478 >= -1.0 )
    v479 = fminf(v478, 1.0);
  else
    v479 = -1.0;
  *(float *)(a1 + 36208) = v477;
  v480 = v479 * *(float *)(a1 + 37088);
  v481 = (float)((float)((float)(v477 + v472) + 1.0) * 0.5) - 1.0;
  v482 = (float)((float)((float)((float)((float)((float)((float)((float)(v480 * v480) * *(float *)(a1 + 37552))
                                                       + *(float *)(a1 + 37536))
                                               * (float)((float)(v480 * v480) * (float)(v480 * v480)))
                                       + (float)((float)((float)(v480 * v480) * *(float *)(a1 + 37520))
                                               + *(float *)(a1 + 37504)))
                               * (float)((float)((float)(v480 * v480) * v480) * (float)(v480 * v480)))
                       + (float)((float)((float)(v480 * v480) * v480) * *(float *)(a1 + 37488)))
               + v480)
       * v473;
  *(float *)(a1 + 36448) = v482;
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
  v484 = v481 * *(float *)(a1 + 37216);
  v485 = (float)((float)((float)(*(float *)&v483 + 1.0) * *(float *)(a1 + 36336)) * 512.0) * *(float *)(a1 + 37168);
  if ( v485 >= -1.0 )
    v486 = fminf(v485, 1.0);
  else
    v486 = -1.0;
  v487 = v486 * *(float *)(a1 + 37088);
  v488 = *(float *)(a1 + 36176);
  v489 = *(_DWORD *)(a1 + 36208);
  *(float *)(a1 + 36736) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v487 * v487)
                                                                                                 * *(float *)(a1 + 37552))
                                                                                         + *(float *)(a1 + 37536))
                                                                                 * (float)((float)(v487 * v487)
                                                                                         * (float)(v487 * v487)))
                                                                         + (float)((float)((float)(v487 * v487)
                                                                                         * *(float *)(a1 + 37520))
                                                                                 + *(float *)(a1 + 37504)))
                                                                 * (float)((float)((float)(v487 * v487) * v487)
                                                                         * (float)(v487 * v487)))
                                                         + (float)((float)((float)(v487 * v487) * v487)
                                                                 * *(float *)(a1 + 37488)))
                                                 + v487)
                                         * v484)
                                 * *(float *)(a1 + 36304))
                         + (float)((float)(*(float *)(a1 + 36432) * *(float *)(a1 + 36272))
                                 + (float)(v482 * *(float *)(a1 + 36288)));
  *(float *)(a1 + 36192) = v488;
  *(_DWORD *)(a1 + 36208) = v489;
  v490 = v488 + *(float *)(a1 + 36320);
  if ( v490 <= 1.0 )
  {
    if ( v490 < -1.0 )
      v490 = fmodf(v490 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v490 = fmodf(v490 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 36176) = v490;
  v491 = v490 * *(float *)(a1 + 37184);
  v492 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v493 = (float)((float)(*(float *)&v492 * 256.0) * *(float *)(a1 + 36336)) * *(float *)(a1 + 37136);
  if ( v493 >= -1.0 )
    v494 = fminf(v493, 1.0);
  else
    v494 = -1.0;
  v495 = v494 * *(float *)(a1 + 37088);
  v496 = (float)(v495 * v495) * v495;
  v497 = v496 * *(float *)(a1 + 37488);
  v498 = (float)((float)((float)((float)((float)(v495 * v495) * *(float *)(a1 + 37552)) + *(float *)(a1 + 37536))
                       * (float)((float)(v495 * v495) * (float)(v495 * v495)))
               + (float)((float)((float)(v495 * v495) * *(float *)(a1 + 37520)) + *(float *)(a1 + 37504)))
       * (float)(v496 * (float)(v495 * v495));
  v499 = *(float *)(a1 + 36352) + v490;
  *(float *)(a1 + 36432) = (float)((float)(v498 + v497) + v495) * v491;
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
  v501 = *(float *)(a1 + 36176);
  v502 = v500 * *(float *)(a1 + 37200);
  v503 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v504 = *(float *)&v503;
  v505 = *(float *)(a1 + 37120);
  if ( v501 < v505 || v505 <= *(float *)(a1 + 36192) )
    v506 = *(float *)(a1 + 36208);
  else
    v506 = *(float *)(a1 + 36208) + 2.0;
  v507 = (float)((float)(v504 * *(float *)(a1 + 36336)) * 256.0) * *(float *)(a1 + 37152);
  if ( v506 >= 4.0 )
    v506 = 0.0;
  if ( v507 >= -1.0 )
    v508 = fminf(v507, 1.0);
  else
    v508 = -1.0;
  *(float *)(a1 + 36208) = v506;
  v509 = v508 * *(float *)(a1 + 37088);
  v510 = (float)((float)((float)(v506 + v501) + 1.0) * 0.5) - 1.0;
  v511 = (float)((float)((float)((float)((float)((float)((float)((float)(v509 * v509) * *(float *)(a1 + 37552))
                                                       + *(float *)(a1 + 37536))
                                               * (float)((float)(v509 * v509) * (float)(v509 * v509)))
                                       + (float)((float)((float)(v509 * v509) * *(float *)(a1 + 37520))
                                               + *(float *)(a1 + 37504)))
                               * (float)((float)((float)(v509 * v509) * v509) * (float)(v509 * v509)))
                       + (float)((float)((float)(v509 * v509) * v509) * *(float *)(a1 + 37488)))
               + v509)
       * v502;
  *(float *)(a1 + 36448) = v511;
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
  v513 = v510 * *(float *)(a1 + 37216);
  v514 = (float)((float)(v512 * *(float *)(a1 + 36336)) * 512.0) * *(float *)(a1 + 37168);
  if ( v514 >= -1.0 )
    v33 = fminf(v514, 1.0);
  v515 = v33 * *(float *)(a1 + 37088);
  v516 = *(_DWORD *)(a1 + 36176);
  v517 = *(_DWORD *)(a1 + 36208);
  *(float *)(a1 + 36864) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v515 * v515)
                                                                                                 * *(float *)(a1 + 37552))
                                                                                         + *(float *)(a1 + 37536))
                                                                                 * (float)((float)(v515 * v515)
                                                                                         * (float)(v515 * v515)))
                                                                         + (float)((float)((float)(v515 * v515)
                                                                                         * *(float *)(a1 + 37520))
                                                                                 + *(float *)(a1 + 37504)))
                                                                 * (float)((float)((float)(v515 * v515) * v515)
                                                                         * (float)(v515 * v515)))
                                                         + (float)((float)((float)(v515 * v515) * v515)
                                                                 * *(float *)(a1 + 37488)))
                                                 + v515)
                                         * v513)
                                 * *(float *)(a1 + 36304))
                         + (float)((float)(*(float *)(a1 + 36432) * *(float *)(a1 + 36272))
                                 + (float)(v511 * *(float *)(a1 + 36288)));
  v518 = *(float *)(a1 + 36976);
  *(_DWORD *)(a1 + 36400) = v516;
  *(_DWORD *)(a1 + 36368) = v517;
  v519 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(*(float *)(a1 + 36848) + *(float *)(a1 + 36608))
                                                                                               * *(float *)(a1 + 37248))
                                                                                       + (float)((float)(v518 + *(float *)(a1 + 36480))
                                                                                               * *(float *)(a1 + 37232)))
                                                                               + (float)((float)(*(float *)(a1 + 36736)
                                                                                               + *(float *)(a1 + 36720))
                                                                                       * *(float *)(a1 + 37264)))
                                                                       + (float)((float)(*(float *)(a1 + 36864)
                                                                                       + *(float *)(a1 + 36592))
                                                                               * *(float *)(a1 + 37280)))
                                                               + (float)((float)(*(float *)(a1 + 36960)
                                                                               + *(float *)(a1 + 36496))
                                                                       * *(float *)(a1 + 37296)))
                                                       + (float)((float)(*(float *)(a1 + 36832) + *(float *)(a1 + 36624))
                                                               * *(float *)(a1 + 37312)))
                                               + (float)((float)(*(float *)(a1 + 36752) + *(float *)(a1 + 36704))
                                                       * *(float *)(a1 + 37328)))
                                       + (float)((float)(*(float *)(a1 + 36880) + *(float *)(a1 + 36576))
                                               * *(float *)(a1 + 37344)))
                               + (float)((float)(*(float *)(a1 + 36944) + *(float *)(a1 + 36512))
                                       * *(float *)(a1 + 37360)))
                       + (float)((float)(*(float *)(a1 + 36640) + *(float *)(a1 + 36816)) * *(float *)(a1 + 37376)))
               + (float)((float)(*(float *)(a1 + 36768) + *(float *)(a1 + 36688)) * *(float *)(a1 + 37392)))
       + (float)((float)(*(float *)(a1 + 36560) + *(float *)(a1 + 36896)) * *(float *)(a1 + 37408));
  v520 = *(float *)(a1 + 37024);
  v521 = (float)(v520 * *(float *)(a1 + 37792)) + *(float *)(a1 + 37040);
  v522 = (float)((float)(v519
                       + (float)((float)(*(float *)(a1 + 36928) + *(float *)(a1 + 36528)) * *(float *)(a1 + 37424)))
               + (float)((float)(*(float *)(a1 + 36800) + *(float *)(a1 + 36656)) * *(float *)(a1 + 37440)))
       + (float)((float)(*(float *)(a1 + 36784) + *(float *)(a1 + 36672)) * *(float *)(a1 + 37456));
  v523 = (float)(*(float *)(a1 + 36912) + *(float *)(a1 + 36544)) * *(float *)(a1 + 37472);
  *(float *)(a1 + 37024) = v521;
  v524 = v522 + v523;
  v525 = v524 - (float)((float)(v520 * *(float *)(a1 + 37808)) + v521);
  *(float *)(a1 + 37008) = (float)(v525 * *(float *)(a1 + 37792)) + v520;
  v526 = (float)((float)((float)(v521 - (float)(v525 * *(float *)(a1 + 36992))) * *(float *)(a1 + 37872))
               - (float)(*(float *)(a1 + 37872) * v524))
       + v524;
  *(float *)(a1 + 36464) = v526;
  *(float *)(a1 + 35056) = v526;
  if ( *(float *)(a1 + 101600) == 1.0 )
  {
    *(_DWORD *)(a1 + 31856) = v528;
    *(_DWORD *)(a1 + 101600) = 0;
  }
  **a2 = *(_DWORD *)(a1 + 42208);
  result = *(unsigned int *)(a1 + 42208);
  *a2[1] = result;
  return result;
}

