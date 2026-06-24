// sub_7FF91DFE3F20 @ rva 0x383F20

__int64 __fastcall sub_7FF91DFE3F20(__int64 a1, _DWORD **a2)
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

  v2 = *(float *)(a1 + 73904);
  v528 = 0;
  if ( *(float *)(a1 + 101728) == 1.0 )
  {
    v528 = *(_DWORD *)(a1 + 73904);
    v2 = 0.0;
    *(_DWORD *)(a1 + 73904) = 0;
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
  v11 = *(float *)(a1 + 73792);
  v12 = *(float *)(a1 + 73760);
  v13 = v9 & 0xFFFFFF;
  v14 = *(float *)(a1 + 73952);
  v15 = v9;
  v16 = *(float *)(a1 + 73968);
  v17 = v9 | 0xFF000000;
  v18 = v6 * v7;
  *(_DWORD *)(a1 + 74016) = 0;
  *(float *)(a1 + 73808) = v11;
  v19 = 0.0;
  if ( (v15 & 0x1000000) == 0 )
    v17 = v13;
  *(float *)(a1 + 73776) = v12;
  *(_DWORD *)(a1 + 84384) = *(_DWORD *)(a1 + 84368);
  *(_DWORD *)(a1 + 74096) = *(_DWORD *)(a1 + 74080);
  *(float *)(a1 + 73936) = v2;
  v20 = (float)v17 * 0.000000059604645;
  *(float *)(a1 + 73984) = v14;
  *(float *)(a1 + 74000) = v16;
  *(float *)(a1 + 84336) = v20;
  v21 = (float)(v20 * *(float *)(a1 + 84400)) + *(float *)(a1 + 84416);
  *(float *)(a1 + 84368) = v21;
  v22 = v18 - (float)(v7 * v21);
  v23 = *(float *)(a1 + 73856);
  *(float *)(a1 + 73872) = v23;
  v24 = v22 + v21;
  v25 = *(float *)(a1 + 73824);
  v26 = v23 * v25;
  *(float *)(a1 + 73840) = v25;
  *(float *)(a1 + 84432) = v24;
  v27 = *(float *)(a1 + 73888);
  *(float *)(a1 + 73920) = v27;
  *(float *)(a1 + 74032) = v26;
  v28 = (float)((float)(v12 * v26) - (float)(v26 * v27)) + v27;
  v29 = (float)((float)(v11 * v26) - (float)(v2 * v26)) + v2;
  *(float *)(a1 + 74048) = v28;
  *(float *)(a1 + 74064) = v29;
  v30 = v29;
  v31 = v29 + *(float *)(a1 + 74128);
  if ( v31 < 0.0 )
    v32 = v31;
  else
    v32 = 0.0;
  v33 = -1.0;
  if ( v30 == 0.0 )
    v34 = -1.0;
  else
    v34 = v32;
  *(float *)(a1 + 74080) = v34;
  if ( v34 >= 0.0 )
  {
    if ( v34 > 0.0 )
      v34 = 1.0;
  }
  else
  {
    v34 = -1.0;
  }
  v35 = *(float *)(a1 + 74192);
  v36 = v34 + 1.0;
  v37 = *(float *)(a1 + 74352);
  v38 = *(float *)(a1 + 74208);
  v39 = *(_DWORD *)(a1 + 74144);
  v40 = *(float *)(a1 + 74288);
  v41 = v38 + *(float *)(a1 + 74368);
  v42 = 1.0;
  *(float *)(a1 + 74112) = v36;
  *(float *)(a1 + 74144) = v36;
  *(_DWORD *)(a1 + 74160) = v39;
  *(float *)(a1 + 74304) = v40;
  v43 = (float)(v36 * v35) - v35;
  v44 = *(float *)(a1 + 74400);
  v45 = (float)(v43 + 1.0) * *(float *)(a1 + 74176);
  v46 = (float)(*(float *)(a1 + 74256) / (float)((float)(v37 * v38) + *(float *)(a1 + 74384))) * v37;
  v47 = *(float *)(a1 + 74240);
  *(float *)(a1 + 74320) = v45;
  v48 = v47 - v46;
  v49 = *(float *)(a1 + 74272);
  v50 = (float)(v48 + v28) - v40;
  *(float *)(a1 + 74240) = v50;
  v51 = v50 * v41;
  *(float *)(a1 + 74256) = v51;
  v52 = v51 + v40;
  if ( (float)(v44 - fabs(v40 - v28)) < 0.0 )
  {
    v53 = 0.0;
LABEL_25:
    v54 = v53;
    goto LABEL_26;
  }
  v53 = v49 + *(float *)(a1 + 74416);
  if ( v53 < 1.0 )
    goto LABEL_25;
  v54 = 1.0;
LABEL_26:
  v55 = v54;
  *(float *)(a1 + 74272) = v55;
  v56 = (float)((float)(v55 * v28) - (float)(v55 * v52)) + v52;
  if ( v45 == 0.0 )
    v56 = v28;
  v57 = v16 * *(float *)(a1 + 74448);
  *(_DWORD *)(a1 + 74480) = *(_DWORD *)(a1 + 74464);
  v58 = *(float *)(a1 + 74752);
  v59 = *(float *)(a1 + 74496);
  v60 = *(_DWORD *)(a1 + 74592);
  v61 = v57 + (float)(v14 * *(float *)(a1 + 74432));
  v62 = *(_DWORD *)(a1 + 74560);
  v63 = (int)v58;
  *(float *)(a1 + 74464) = v61;
  v64 = *(float *)(a1 + 74528);
  *(float *)(a1 + 74288) = v56;
  *(float *)(a1 + 74336) = v56;
  v65 = *(float *)(a1 + 74688);
  *(float *)(a1 + 74544) = v64;
  *(float *)(a1 + 74512) = v59;
  *(_DWORD *)(a1 + 74576) = v62;
  *(_DWORD *)(a1 + 74608) = v60;
  *(float *)(a1 + 74704) = v65;
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
  v67 = *(float *)(a1 + 74624);
  v68 = (float)((float)(v59 - v65) * *(float *)(a1 + 74736)) + v65;
  v69 = *(float *)(a1 + 74672);
  *(float *)(a1 + 74688) = v68;
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
  v74 = *(float *)(a1 + 74640);
  v75 = expf((float)v73 * *(float *)(a1 + 74784)) * *(float *)(a1 + 74768);
  v76 = v74 * *(float *)(a1 + 74656);
  *(_DWORD *)(a1 + 75168) = *(_DWORD *)(a1 + 75152);
  v77 = v75 + *(float *)(a1 + 74800);
  v78 = *(float *)(a1 + 75088);
  v79 = v64 * *(float *)(a1 + 75488);
  *(_DWORD *)(a1 + 75200) = *(_DWORD *)(a1 + 75184);
  v80 = *(float *)(a1 + 75072);
  v81 = *(float *)(a1 + 75120);
  *(_DWORD *)(a1 + 75232) = *(_DWORD *)(a1 + 75216);
  v82 = *(_DWORD *)(a1 + 84432);
  *(float *)(a1 + 75104) = v78;
  *(float *)(a1 + 75088) = v80;
  *(float *)(a1 + 75136) = v81;
  *(_DWORD *)(a1 + 75024) = v62;
  *(_DWORD *)(a1 + 75040) = v60;
  *(_DWORD *)(a1 + 75008) = v82;
  v83 = (float)(v76 - (float)(v74 * v77)) + v77;
  v84 = *(float *)(a1 + 75440);
  v85 = v79 + v84;
  *(float *)(a1 + 75424) = v84;
  *(float *)(a1 + 74720) = v83;
  if ( v85 >= -1.0 )
    v86 = fminf(v85, 1.0);
  else
    v86 = -1.0;
  v87 = *(float *)(a1 + 75712);
  *(float *)(a1 + 75072) = v86;
  v88 = fminf(v87, v83 * 0.000015258789);
  v89 = (float)((float)(1.0 - v78) * *(float *)(a1 + 75504)) + v78;
  if ( v89 >= -1.0 )
    v90 = fminf(v89, 1.0);
  else
    v90 = -1.0;
  v91 = v88 * *(float *)(a1 + 75728);
  v92 = v80 - v86;
  *(float *)(a1 + 75248) = v91;
  v93 = v91 + v81;
  if ( v92 < 0.0 )
    v90 = 0.0;
  v94 = *(float *)(a1 + 75456);
  v95 = *(float *)(a1 + 75008);
  *(float *)(a1 + 75088) = v90;
  v96 = v90 + *(float *)(a1 + 75856);
  if ( v92 >= 0.0 )
    v94 = 1.0;
  v97 = v96 * *(float *)(a1 + 75840);
  v98 = (float)(v93 * v94) * *(float *)(a1 + 75472);
  if ( v97 <= 0.0 )
    v99 = 0.0;
  else
    v99 = v97;
  v100 = v99;
  v101 = (float)((float)(v95 - *(float *)(a1 + 75168)) * *(float *)(a1 + 76048)) + *(float *)(a1 + 75168);
  *(float *)(a1 + 75152) = v101;
  *(float *)(a1 + 75056) = v100;
  v529 = *(float *)(a1 + 75136);
  v102 = (float)((float)((float)(v101 * *(float *)(a1 + 76032)) * *(float *)(a1 + 75648))
               - (float)(v95 * *(float *)(a1 + 75648)))
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
  v103 = *(float *)(a1 + 75200);
  *(float *)(a1 + 75120) = v98;
  v104 = v98 + *(float *)(a1 + 75872);
  *(float *)(a1 + 74992) = v102 * *(float *)(a1 + 76016);
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
  *(float *)(a1 + 75184) = v103;
  v105 = v103 * *(float *)(a1 + 76000);
  v106 = (float)(v104 * *(float *)(a1 + 75936)) + *(float *)(a1 + 76064);
  *(float *)(a1 + 75264) = v106;
  *(float *)(a1 + 75344) = v105;
  v107 = v98 + *(float *)(a1 + 75904);
  *(float *)(a1 + 75280) = -v106;
  if ( v107 <= 1.0 )
  {
    if ( v107 < -1.0 )
      fmodf(v107 - 1.0, 2.0);
  }
  else
  {
    fmodf(v107 + 1.0, 2.0);
  }
  v108 = v98 + *(float *)(a1 + 75888);
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
  v110 = v108 + *(float *)(a1 + 76080);
  v111 = v109 * *(float *)(a1 + 75968);
  if ( v110 >= 0.0 )
  {
    if ( v110 > 0.0 )
      v110 = 1.0;
  }
  else
  {
    v110 = -1.0;
  }
  v112 = v98 + *(float *)(a1 + 75920);
  *(float *)(a1 + 75312) = v111;
  *(float *)(a1 + 75408) = v110;
  v113 = (float)(v110 * *(float *)(a1 + 75952)) + *(float *)(a1 + 76096);
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
  *(float *)(a1 + 75296) = v113;
  v115 = *(float *)(a1 + 75552);
  v116 = (float)((float)(*(float *)(a1 + 75616) * *(float *)(a1 + 75344))
               + (float)(*(float *)(a1 + 75584) * *(float *)(a1 + 75264)))
       + (float)(*(float *)(a1 + 75600) * *(float *)(a1 + 75280));
  v117 = (float)((float)((float)((float)(v114 * (float)((float)(v114 * v114) * v114)) * *(float *)(a1 + 75808))
                       + (float)((float)((float)((float)(v114 * v114) * v114) * *(float *)(a1 + 75792))
                               + (float)((float)((float)(v114 * *(float *)(a1 + 75760)) + *(float *)(a1 + 75744))
                                       + (float)((float)(v114 * v114) * *(float *)(a1 + 75776)))))
               + *(float *)(a1 + 75824))
       * *(float *)(a1 + 75984);
  *(float *)(a1 + 75328) = v117;
  v118 = (float)(v115 * *(float *)(a1 + 75312)) + v116;
  v119 = *(float *)(a1 + 75664);
  v120 = (float)((float)(*(float *)(a1 + 75520) * *(float *)(a1 + 75056)) - *(float *)(a1 + 75520)) + 1.0;
  v121 = (float)((float)(v118 + (float)(*(float *)(a1 + 75568) * *(float *)(a1 + 75296)))
               + (float)(v117 * *(float *)(a1 + 75536)))
       + (float)(*(float *)(a1 + 75632) * *(float *)(a1 + 74992));
  *(float *)(a1 + 75360) = v120;
  *(float *)(a1 + 75392) = v121;
  *(float *)(a1 + 75376) = (float)((float)(*(float *)(a1 + 75680) * *(float *)(a1 + 75024))
                                 + (float)(*(float *)(a1 + 75696) * *(float *)(a1 + 75040)))
                         + (float)((float)(v119 * v120) * v121);
  v122 = *(_DWORD *)(a1 + 75392);
  *(_DWORD *)(a1 + 76112) = *(_DWORD *)(a1 + 75408);
  *(_DWORD *)(a1 + 76128) = v122;
  if ( *(float *)(a1 + 75408) <= 0.0 )
    v123 = 0.0;
  else
    v123 = 1.0;
  if ( *(float *)(a1 + 76144) == 0.0 )
    v123 = 1.0;
  v124 = *(float *)(a1 + 74144) * v123;
  *(float *)(a1 + 76160) = v124;
  *(_DWORD *)(a1 + 76192) = *(_DWORD *)(a1 + 76176);
  *(_DWORD *)(a1 + 76240) = *(_DWORD *)(a1 + 76224);
  *(_DWORD *)(a1 + 76224) = *(_DWORD *)(a1 + 76208);
  *(_DWORD *)(a1 + 76272) = *(_DWORD *)(a1 + 76256);
  *(_DWORD *)(a1 + 76320) = *(_DWORD *)(a1 + 76304);
  if ( (float)(v124 + *(float *)(a1 + 76448)) >= 0.0 )
    v125 = 0.0;
  else
    v125 = 1.0;
  v126 = 1.0 - v125;
  v127 = (float)(1.0 - v125)
       * (float)((float)(*(float *)(a1 + 76480) * *(float *)(a1 + 76240)) + *(float *)(a1 + 76192));
  *(float *)(a1 + 76208) = v127;
  v128 = v127 + *(float *)(a1 + 76464);
  v129 = v127 - *(float *)(a1 + 76224);
  *(float *)(a1 + 76288) = (float)((float)(*(float *)(a1 + 76432) * *(float *)(a1 + 76544))
                                 - (float)(*(float *)(a1 + 76512) * *(float *)(a1 + 76432)))
                         + *(float *)(a1 + 76512);
  if ( v128 < 0.0 )
    v130 = 0.0;
  else
    v130 = 1.0;
  if ( v129 < 0.0 )
    v130 = 1.0 - v125;
  v131 = *(float *)(a1 + 76368);
  v132 = v126 * (float)(*(float *)(a1 + 76384) * *(float *)(a1 + 76512));
  *(float *)(a1 + 76224) = v130;
  v133 = *(float *)(a1 + 76272);
  v134 = (float)(v132 - (float)(*(float *)(a1 + 76528) * v126)) + *(float *)(a1 + 76528);
  v135 = v126 * (float)(1.0 - v130);
  v136 = (float)((float)(*(float *)(a1 + 76400) * 0.00390625) * v130) + (float)((float)(v131 * 0.00390625) * v135);
  if ( (float)(v134 - v133) > 0.0 )
    v134 = v133 + *(float *)(a1 + 76288);
  v137 = *(float *)(a1 + 76192);
  v138 = fminf(*(float *)(a1 + 76512), v134);
  *(float *)(a1 + 76256) = v138;
  v139 = *(float *)(a1 + 76416);
  v140 = (float)((float)(v135 * *(float *)(a1 + 76496)) + (float)(v130 * v138)) - v137;
  v141 = (float)((float)(*(float *)(a1 + 76560) * v136) - (float)(*(float *)(a1 + 76560) * *(float *)(a1 + 76320)))
       + *(float *)(a1 + 76320);
  *(float *)(a1 + 76304) = v141;
  v142 = (float)((float)((float)((float)((float)(v139 * 0.00390625) * v125) - (float)(v125 * v141)) + v141) * v140)
       + v137;
  *(float *)(a1 + 76176) = v142;
  v143 = (float)(v142 * *(float *)(a1 + 76576)) * *(float *)(a1 + 76592);
  v144 = v143 * *(float *)(a1 + 76608);
  *(float *)(a1 + 76336) = v143;
  *(float *)(a1 + 76352) = v144;
  if ( *(float *)(a1 + 75408) <= 0.0 )
    v145 = 0.0;
  else
    v145 = 1.0;
  if ( *(float *)(a1 + 76624) == 0.0 )
    v145 = 1.0;
  v146 = *(float *)(a1 + 74144) * v145;
  *(float *)(a1 + 76640) = v146;
  *(_DWORD *)(a1 + 76672) = *(_DWORD *)(a1 + 76656);
  *(_DWORD *)(a1 + 76720) = *(_DWORD *)(a1 + 76704);
  *(_DWORD *)(a1 + 76704) = *(_DWORD *)(a1 + 76688);
  *(_DWORD *)(a1 + 76752) = *(_DWORD *)(a1 + 76736);
  *(_DWORD *)(a1 + 76800) = *(_DWORD *)(a1 + 76784);
  if ( (float)(v146 + *(float *)(a1 + 76928)) >= 0.0 )
    v147 = 0.0;
  else
    v147 = 1.0;
  v148 = 1.0 - v147;
  v149 = (float)(1.0 - v147)
       * (float)((float)(*(float *)(a1 + 76960) * *(float *)(a1 + 76720)) + *(float *)(a1 + 76672));
  *(float *)(a1 + 76688) = v149;
  v150 = v149 + *(float *)(a1 + 76944);
  v151 = v149 - *(float *)(a1 + 76704);
  *(float *)(a1 + 76768) = (float)((float)(*(float *)(a1 + 76912) * *(float *)(a1 + 77024))
                                 - (float)(*(float *)(a1 + 76992) * *(float *)(a1 + 76912)))
                         + *(float *)(a1 + 76992);
  if ( v150 < 0.0 )
    v152 = 0.0;
  else
    v152 = 1.0;
  if ( v151 < 0.0 )
    v152 = 1.0 - v147;
  v153 = *(float *)(a1 + 76864) * *(float *)(a1 + 76992);
  v154 = *(float *)(a1 + 76848);
  *(float *)(a1 + 76704) = v152;
  v155 = *(float *)(a1 + 76752);
  v156 = (float)((float)(v148 * v153) - (float)(*(float *)(a1 + 77008) * v148)) + *(float *)(a1 + 77008);
  v157 = v148 * (float)(1.0 - v152);
  v158 = (float)((float)(*(float *)(a1 + 76880) * 0.00390625) * v152) + (float)((float)(v154 * 0.00390625) * v157);
  if ( (float)(v156 - v155) > 0.0 )
    v156 = v155 + *(float *)(a1 + 76768);
  v159 = *(float *)(a1 + 76672);
  v160 = fminf(*(float *)(a1 + 76992), v156);
  *(float *)(a1 + 76736) = v160;
  v161 = (float)(*(float *)(a1 + 76896) * 0.00390625) * v147;
  v162 = (float)((float)(v157 * *(float *)(a1 + 76976)) + (float)(v152 * v160)) - v159;
  v163 = (float)((float)(*(float *)(a1 + 77040) * v158) - (float)(*(float *)(a1 + 77040) * *(float *)(a1 + 76800)))
       + *(float *)(a1 + 76800);
  *(float *)(a1 + 76784) = v163;
  v164 = (float)((float)((float)(v161 - (float)(v147 * v163)) + v163) * v162) + v159;
  *(float *)(a1 + 76656) = v164;
  v165 = (float)(v164 * *(float *)(a1 + 77056)) * *(float *)(a1 + 77072);
  v166 = v165 * *(float *)(a1 + 77088);
  *(float *)(a1 + 76816) = v165;
  *(float *)(a1 + 76832) = v166;
  *(_DWORD *)(a1 + 77120) = *(_DWORD *)(a1 + 77104);
  *(_DWORD *)(a1 + 77152) = *(_DWORD *)(a1 + 77136);
  v167 = *(float *)(a1 + 74336);
  v168 = *(float *)(a1 + 74464);
  *(_DWORD *)(a1 + 77216) = *(_DWORD *)(a1 + 77200);
  v169 = (float)(v168 * *(float *)(a1 + 77184)) + (float)(v167 * *(float *)(a1 + 77168));
  *(float *)(a1 + 77200) = v169;
  v170 = *(float *)(a1 + 75376);
  v171 = *(_DWORD *)(a1 + 76336);
  v172 = *(_DWORD *)(a1 + 76816);
  v173 = *(_DWORD *)(a1 + 74336);
  *(_DWORD *)(a1 + 77264) = *(_DWORD *)(a1 + 77136);
  *(_DWORD *)(a1 + 77280) = v173;
  v174 = *(float *)(a1 + 77600);
  *(_DWORD *)(a1 + 77232) = v171;
  *(_DWORD *)(a1 + 77248) = v172;
  v175 = *(float *)(a1 + 77568);
  v176 = v170 * v174;
  v177 = v174 * *(float *)(a1 + 75392);
  *(float *)(a1 + 77296) = v177;
  v178 = *(float *)(a1 + 77696);
  v179 = *(float *)(a1 + 77440);
  v180 = v176 * *(float *)(a1 + 77616);
  v181 = *(float *)(a1 + 77632);
  v182 = (float)(v175 * v177) * *(float *)(a1 + 77584);
  *(float *)(a1 + 77328) = v182;
  v183 = *(float *)(a1 + 77456);
  v184 = (float)((float)((float)(v179 * *(float *)(a1 + 77264)) - (float)(v178 * v179)) + v178) * *(float *)(a1 + 77712);
  *(float *)(a1 + 77344) = v184;
  v185 = (float)((float)(v181 * v180) + v182) + (float)(v183 * v184);
  v186 = *(float *)(a1 + 77296);
  v187 = *(_DWORD *)(a1 + 77424);
  *(float *)(a1 + 77360) = (float)((float)((float)((float)((float)((float)(*(float *)(a1 + 77664)
                                                                         * *(float *)(a1 + 77248))
                                                                 + (float)(*(float *)(a1 + 77648)
                                                                         * *(float *)(a1 + 77232)))
                                                         * *(float *)(a1 + 77680))
                                                 + v185)
                                         + v169)
                                 + *(float *)(a1 + 77536))
                         + *(float *)(a1 + 77552);
  *(_DWORD *)(a1 + 77376) = v187;
  v188 = (float)(*(float *)(a1 + 77328) + *(float *)(a1 + 77280)) + *(float *)(a1 + 77344);
  *(float *)(a1 + 77392) = (float)((float)((float)((float)((float)((float)(v186 * *(float *)(a1 + 77744))
                                                                 + *(float *)(a1 + 77760))
                                                         * *(float *)(a1 + 77472))
                                                 + (float)(*(float *)(a1 + 77488) * *(float *)(a1 + 77232)))
                                         + (float)(*(float *)(a1 + 77504) * *(float *)(a1 + 77248)))
                                 + *(float *)(a1 + 77520))
                         * *(float *)(a1 + 77728);
  *(float *)(a1 + 77408) = v188;
  v189 = *(_DWORD *)(a1 + 77792);
  *(_DWORD *)(a1 + 77824) = *(_DWORD *)(a1 + 77776);
  *(_DWORD *)(a1 + 77840) = v189;
  *(_DWORD *)(a1 + 77856) = *(_DWORD *)(a1 + 77808);
  v190 = *(float *)(a1 + 84432);
  *(_DWORD *)(a1 + 77904) = *(_DWORD *)(a1 + 77888);
  v191 = *(float *)(a1 + 77872);
  *(float *)(a1 + 77888) = v191;
  v192 = (float)(v191 * *(float *)(a1 + 77920)) + *(float *)(a1 + 77904);
  *(float *)(a1 + 77888) = v192;
  v193 = (float)(v191 * *(float *)(a1 + 77936)) + v192;
  v194 = v192 * *(float *)(a1 + 77984);
  v195 = v190 - v193;
  v196 = (float)(v195 * *(float *)(a1 + 77920)) + v191;
  *(float *)(a1 + 77872) = v196;
  *(float *)(a1 + 77904) = (float)((float)(v195 * *(float *)(a1 + 77952)) + v194)
                         + (float)(v196 * *(float *)(a1 + 77968));
  *(_DWORD *)(a1 + 80016) = *(_DWORD *)(a1 + 80000);
  v197 = *(float *)(a1 + 80032);
  *(float *)(a1 + 80048) = v197;
  v198 = v197 * *(float *)(a1 + 77120);
  v199 = *(float *)(a1 + 80016) * *(float *)(a1 + 77904);
  *(float *)(a1 + 80064) = v198;
  *(float *)(a1 + 80080) = v199;
  *(_DWORD *)(a1 + 80144) = *(_DWORD *)(a1 + 80128);
  *(float *)(a1 + 80128) = (float)(v199 * *(float *)(a1 + 80112)) + (float)(v198 * *(float *)(a1 + 80096));
  *(_DWORD *)(a1 + 80176) = *(_DWORD *)(a1 + 80160);
  *(_DWORD *)(a1 + 80208) = *(_DWORD *)(a1 + 80192);
  *(_DWORD *)(a1 + 80240) = *(_DWORD *)(a1 + 80224);
  *(_DWORD *)(a1 + 80272) = *(_DWORD *)(a1 + 80256);
  v200 = (float)((float)(*(float *)(a1 + 80304) * *(float *)(a1 + 80160))
               - (float)(*(float *)(a1 + 80320) * *(float *)(a1 + 80304)))
       + *(float *)(a1 + 80320);
  v201 = (float)((float)((float)((float)(v200 * v200) * v200) * v200) * *(float *)(a1 + 80400))
       + (float)((float)((float)((float)(v200 * v200) * v200) * *(float *)(a1 + 80384))
               + (float)((float)((float)(v200 * *(float *)(a1 + 80352)) + *(float *)(a1 + 80336))
                       + (float)((float)(v200 * v200) * *(float *)(a1 + 80368))));
  if ( v201 <= 0.0 )
    v202 = 0.0;
  else
    v202 = v201;
  v203 = v202;
  if ( v203 < 1.0 )
    v42 = v203;
  v204 = v42;
  *(float *)(a1 + 80288) = v204;
  *(_DWORD *)(a1 + 80432) = *(_DWORD *)(a1 + 80416);
  v205 = *(float *)(a1 + 80448);
  *(float *)(a1 + 80464) = v205;
  v206 = *(float *)(a1 + 80480);
  *(float *)(a1 + 80496) = v206;
  *(float *)(a1 + 80480) = (float)((float)(v205 - v206) * *(float *)(a1 + 80512)) + v206;
  v207 = *(float *)(a1 + 74336);
  v208 = *(float *)(a1 + 74464);
  *(_DWORD *)(a1 + 80576) = *(_DWORD *)(a1 + 80560);
  *(float *)(a1 + 80560) = (float)(v208 * *(float *)(a1 + 80544)) + (float)(v207 * *(float *)(a1 + 80528));
  *(_DWORD *)(a1 + 80624) = *(_DWORD *)(a1 + 80592);
  v209 = *(float *)(a1 + 80608);
  *(float *)(a1 + 80640) = v209;
  v210 = *(float *)(a1 + 76336)
       + (float)((float)(*(float *)(a1 + 80624) * *(float *)(a1 + 76816))
               - (float)(*(float *)(a1 + 80624) * *(float *)(a1 + 76336)));
  *(float *)(a1 + 80656) = (float)((float)(v209 * *(float *)(a1 + 80224)) - (float)(v209 * v210)) + v210;
  v211 = *(float *)(a1 + 75376);
  v212 = *(float *)(a1 + 80672);
  *(float *)(a1 + 80688) = v212;
  v213 = v211 - v212;
  v214 = (float)(v213 * *(float *)(a1 + 80704)) + v212;
  v215 = *(float *)(a1 + 80736);
  *(float *)(a1 + 80672) = v214;
  *(float *)(a1 + 80688) = (float)(v213 * *(float *)(a1 + 80720)) + (float)(v215 * v214);
  v216 = *(float *)(a1 + 80752);
  v217 = *(float *)(a1 + 75392);
  *(float *)(a1 + 80768) = v216;
  v218 = v217 - v216;
  v219 = (float)(v218 * *(float *)(a1 + 80784)) + v216;
  v220 = *(float *)(a1 + 80816);
  *(float *)(a1 + 80752) = v219;
  v221 = (float)(v218 * *(float *)(a1 + 80800)) + (float)(v220 * v219);
  *(float *)(a1 + 80768) = v221;
  v222 = *(float *)(a1 + 80688);
  v223 = *(float *)(a1 + 80656);
  v224 = *(float *)(a1 + 80560);
  v227 = (__m128)*(unsigned int *)(a1 + 80192);
  *(_DWORD *)(a1 + 80832) = *(_DWORD *)(a1 + 80480);
  *(_DWORD *)(a1 + 80848) = v227.m128_i32[0];
  v225 = *(float *)(a1 + 80880);
  v226 = *(float *)(a1 + 80896) * *(float *)(a1 + 80256);
  v227.m128_f32[0] = (float)((float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 80912))
                                                   - (float)(*(float *)(a1 + 81040) * *(float *)(a1 + 80912)))
                                           + *(float *)(a1 + 81040))
                                   * *(float *)(a1 + 81056))
                           + (float)((float)((float)(*(float *)(a1 + 81024) + *(float *)(a1 + 80832))
                                           * *(float *)(a1 + 81088))
                                   * *(float *)(a1 + 81008)))
                   + (float)((float)((float)((float)((float)((float)(v226
                                                                   - (float)(*(float *)(a1 + 80896)
                                                                           * (float)(v221 * v225)))
                                                           + (float)(v221 * v225))
                                                   * *(float *)(a1 + 80944))
                                           * *(float *)(a1 + 80960))
                                   + (float)((float)((float)(v226
                                                           - (float)(*(float *)(a1 + 80896) * (float)(v222 * v225)))
                                                   + (float)(v222 * v225))
                                           * *(float *)(a1 + 80928)))
                           + (float)((float)((float)(v224 + *(float *)(a1 + 81072)) * *(float *)(a1 + 80992))
                                   + (float)(v223 * *(float *)(a1 + 80976))));
  *(_DWORD *)(a1 + 80864) = v227.m128_i32[0];
  v228 = *(float *)(a1 + 80288);
  v229 = *(float *)(a1 + 80432);
  *(_DWORD *)(a1 + 81168) = *(_DWORD *)(a1 + 81152);
  v230 = *(float *)(a1 + 81136);
  *(float *)(a1 + 81152) = v230;
  if ( *(float *)(a1 + 81216) == 1.0 )
  {
    v231 = *(float *)(a1 + 81168)
         + (float)((float)(*(float *)(a1 + 81296) * v230) - (float)(*(float *)(a1 + 81296) * *(float *)(a1 + 81168)));
    *(float *)(a1 + 81152) = v231;
    v232 = (float)(v231 * *(float *)(a1 + 81280)) + *(float *)(a1 + 81184);
    *(float *)(a1 + 81136) = sub_7FF91DFC8D60();
    v233 = (float)(1.0 - v229) * *(float *)(a1 + 81312);
    *(float *)(a1 + 81120) = (float)(v229 * *(float *)(a1 + 81376)) + *(float *)(a1 + 81200);
    v227.m128_f32[0] = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 81264))
                                                         + (float)(v228 * *(float *)(a1 + 81232)))
                                                 + v232)
                                         + fminf(*(float *)(a1 + 81328), v233))
                                 + *(float *)(a1 + 81248),
                                   *(float *)(a1 + 81344)),
                                 *(float *)(a1 + 81360))
                             * *(float *)(a1 + 81408))
                     + *(float *)(a1 + 81424);
    v234 = v227.m128_f32[0];
    v235 = (int)v227.m128_f32[0];
    if ( (int)v227.m128_f32[0] != 0x80000000 && (float)v235 != v227.m128_f32[0] )
      v234 = (float)(v235 - (_mm_movemask_ps(_mm_unpacklo_ps(v227, v227)) & 1));
    v236 = v227.m128_f32[0] - v234;
    v237 = (float)(v236 * v236) * 0.25;
    v238 = (float)(expf(v234)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v236 * *(float *)(a1 + 81616)) + *(float *)(a1 + 81600)) * v237) + (float)(v236 * *(float *)(a1 + 81584))) + *(float *)(a1 + 81568)) * v237) + (float)(v236 * *(float *)(a1 + 81552)))
                                                                                                 + *(float *)(a1 + 81536))
                                                                                         * v237)
                                                                                 + (float)(v236 * *(float *)(a1 + 81520)))
                                                                         + *(float *)(a1 + 81504))
                                                                 * v237)
                                                         + (float)(v236 * *(float *)(a1 + 81488)))
                                                 + *(float *)(a1 + 81472))
                                         * v237)
                                 + (float)(v236 * *(float *)(a1 + 81456)))
                         + 1.0))
         * *(float *)(a1 + 81440);
    v239 = v238 * v238;
    v240 = (float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 81776))
                                                         + *(float *)(a1 + 81744))
                                                 * (float)(v239 * v239))
                                         + (float)((float)((float)(v238 * v238) * *(float *)(a1 + 81712))
                                                 + *(float *)(a1 + 81680)))
                                 * (float)((float)((float)(v238 * v238) * v238) * (float)(v238 * v238)))
                         + (float)((float)((float)(v238 * v238) * v238) * *(float *)(a1 + 81648)))
                 + v238)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * *(float *)(a1 + 81760))
                                                                 + *(float *)(a1 + 81728))
                                                         * (float)(v239 * v239))
                                                 + (float)((float)(v238 * v238) * *(float *)(a1 + 81696)))
                                         + *(float *)(a1 + 81664))
                                 * (float)(v239 * v239))
                         + (float)((float)(v238 * v238) * *(float *)(a1 + 81632)))
                 + 1.0);
    v241 = v240 / (float)(v240 + 1.0);
    *(float *)(a1 + 81104) = v241;
  }
  else
  {
    v241 = *(float *)(a1 + 81104);
  }
  v242 = *(float *)(a1 + 80128);
  v243 = *(float *)(a1 + 81120);
  *(_DWORD *)(a1 + 81904) = *(_DWORD *)(a1 + 81888);
  *(_DWORD *)(a1 + 81888) = *(_DWORD *)(a1 + 81872);
  *(_DWORD *)(a1 + 81872) = *(_DWORD *)(a1 + 81856);
  *(_DWORD *)(a1 + 81856) = *(_DWORD *)(a1 + 81840);
  *(_DWORD *)(a1 + 81840) = *(_DWORD *)(a1 + 81824);
  *(_DWORD *)(a1 + 81824) = *(_DWORD *)(a1 + 81808);
  *(_DWORD *)(a1 + 81808) = *(_DWORD *)(a1 + 81792);
  *(_DWORD *)(a1 + 82128) = *(_DWORD *)(a1 + 82112);
  *(_DWORD *)(a1 + 82112) = *(_DWORD *)(a1 + 82096);
  *(_DWORD *)(a1 + 82096) = *(_DWORD *)(a1 + 82080);
  *(_DWORD *)(a1 + 82080) = *(_DWORD *)(a1 + 82064);
  *(_DWORD *)(a1 + 82064) = *(_DWORD *)(a1 + 82048);
  *(_DWORD *)(a1 + 82048) = *(_DWORD *)(a1 + 82032);
  *(_DWORD *)(a1 + 82032) = *(_DWORD *)(a1 + 82016);
  *(_DWORD *)(a1 + 82256) = *(_DWORD *)(a1 + 82240);
  *(_DWORD *)(a1 + 82240) = *(_DWORD *)(a1 + 82224);
  *(_DWORD *)(a1 + 82224) = *(_DWORD *)(a1 + 82208);
  *(_DWORD *)(a1 + 82208) = *(_DWORD *)(a1 + 82192);
  *(_DWORD *)(a1 + 82192) = *(_DWORD *)(a1 + 82176);
  *(_DWORD *)(a1 + 82176) = *(_DWORD *)(a1 + 82160);
  *(_DWORD *)(a1 + 82160) = *(_DWORD *)(a1 + 82144);
  *(_DWORD *)(a1 + 82384) = *(_DWORD *)(a1 + 82368);
  *(_DWORD *)(a1 + 82368) = *(_DWORD *)(a1 + 82352);
  *(_DWORD *)(a1 + 82352) = *(_DWORD *)(a1 + 82336);
  *(_DWORD *)(a1 + 82336) = *(_DWORD *)(a1 + 82320);
  *(_DWORD *)(a1 + 82320) = *(_DWORD *)(a1 + 82304);
  *(_DWORD *)(a1 + 82304) = *(_DWORD *)(a1 + 82288);
  *(_DWORD *)(a1 + 82288) = *(_DWORD *)(a1 + 82272);
  *(_DWORD *)(a1 + 82512) = *(_DWORD *)(a1 + 82496);
  *(_DWORD *)(a1 + 82496) = *(_DWORD *)(a1 + 82480);
  *(_DWORD *)(a1 + 82480) = *(_DWORD *)(a1 + 82464);
  *(_DWORD *)(a1 + 82464) = *(_DWORD *)(a1 + 82448);
  *(_DWORD *)(a1 + 82448) = *(_DWORD *)(a1 + 82432);
  *(_DWORD *)(a1 + 82432) = *(_DWORD *)(a1 + 82416);
  *(_DWORD *)(a1 + 82416) = *(_DWORD *)(a1 + 82400);
  *(_DWORD *)(a1 + 82544) = *(_DWORD *)(a1 + 82528);
  v244 = *(float *)(a1 + 82560);
  *(float *)(a1 + 82576) = v244;
  if ( *(float *)(a1 + 82640) == 1.0 )
  {
    v245 = (float)((float)((float)(v243 * *(float *)(a1 + 82752)) + 1.0) * (float)(v242 * *(float *)(a1 + 82720)))
         + (float)((float)-v244 * *(float *)(a1 + 82704));
    *(float *)(a1 + 82560) = sub_7FF91DFC8D60();
    *(float *)(a1 + 82528) = v245;
    v246 = 1.0 - (float)(v241 + v241);
    v247 = 1.0 / (float)((float)((float)((float)(v241 * v241) * (float)(v241 * v241)) * v243) + 1.0);
    *(float *)(a1 + 82608) = v247;
    v248 = *(float *)(a1 + 82528);
    v249 = *(float *)(a1 + 82544);
    *(float *)(a1 + 82592) = v247 * v243;
    v250 = v249 * *(float *)(a1 + 82800);
    v251 = *(float *)(a1 + 81888);
    v252 = v248 * *(float *)(a1 + 82816);
    v253 = *(float *)(a1 + 81904);
    *(float *)(a1 + 82000) = v251;
    v254 = (float)((float)(v250 + v252) * v247)
         - (float)((float)((float)(v251 * *(float *)(a1 + 83104)) + (float)(v253 * *(float *)(a1 + 83120)))
                 * (float)(v247 * v243));
    if ( v254 >= -1.0 )
      v255 = fminf(v254, 1.0);
    else
      v255 = -1.0;
    v256 = v255 + (float)((float)((float)((float)(v255 * v255) * v255) * v255) * (float)(v255 * *(float *)(a1 + 82768)));
    *(float *)(a1 + 81920) = v256;
    v257 = *(float *)(a1 + 81824);
    v258 = (float)(v241 * (float)(v256 + *(float *)(a1 + 81808))) + (float)(v257 * v246);
    *(float *)(a1 + 81936) = v258;
    v259 = *(float *)(a1 + 81840);
    v260 = v241 * (float)(v258 + v257);
    v261 = v241 * (float)((float)((float)(v241 * v256) + (float)(v246 * v258)) + v258);
    v262 = v260 + (float)(v259 * v246);
    *(float *)(a1 + 81952) = v262;
    v263 = *(float *)(a1 + 81856);
    v264 = (float)(v241 * (float)(v262 + v259)) + (float)(v263 * v246);
    *(float *)(a1 + 81968) = v264;
    v265 = (float)((float)(v263 + v264) * v241) + (float)(v246 * *(float *)(a1 + 81872));
    *(float *)(a1 + 81984) = v265;
    v266 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v261 + (float)(v246 * v262)) + v262))
                                 + (float)(v246 * v264))
                         + v264))
         + (float)(v246 * v265);
    v267 = (float)(*(float *)(a1 + 81968) * *(float *)(a1 + 82672)) + (float)(v265 * *(float *)(a1 + 82688));
    v268 = *(float *)(a1 + 82544);
    *(float *)(a1 + 82400) = v267 + (float)(*(float *)(a1 + 82656) * *(float *)(a1 + 81952));
    v269 = *(float *)(a1 + 82000);
    v270 = (float)((float)(v268 + *(float *)(a1 + 82528)) * *(float *)(a1 + 82832)) * *(float *)(a1 + 82608);
    *(float *)(a1 + 82000) = v266;
    v271 = v270
         - (float)((float)((float)(v266 * *(float *)(a1 + 83104)) + (float)(v269 * *(float *)(a1 + 83120)))
                 * *(float *)(a1 + 82592));
    if ( v271 >= -1.0 )
      v272 = fminf(v271, 1.0);
    else
      v272 = -1.0;
    v273 = v272 + (float)((float)((float)((float)(v272 * v272) * v272) * v272) * (float)(v272 * *(float *)(a1 + 82768)));
    v274 = *(float *)(a1 + 81920);
    *(float *)(a1 + 81920) = v273;
    v275 = *(float *)(a1 + 81936);
    v276 = (float)(v241 * (float)(v273 + v274)) + (float)(v275 * v246);
    *(float *)(a1 + 81936) = v276;
    v277 = *(float *)(a1 + 81952);
    v278 = v241 * (float)(v276 + v275);
    v279 = v241 * (float)((float)((float)(v241 * v273) + (float)(v246 * v276)) + v276);
    v280 = v278 + (float)(v277 * v246);
    *(float *)(a1 + 81952) = v280;
    v281 = *(float *)(a1 + 81968);
    v282 = (float)(v241 * (float)(v280 + v277)) + (float)(v281 * v246);
    *(float *)(a1 + 81968) = v282;
    v283 = (float)((float)(v281 + v282) * v241) + (float)(v246 * *(float *)(a1 + 81984));
    *(float *)(a1 + 81984) = v283;
    v284 = *(float *)(a1 + 82528);
    v285 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v279 + (float)(v246 * v280)) + v280))
                                 + (float)(v246 * v282))
                         + v282))
         + (float)(v246 * v283);
    v286 = (float)(*(float *)(a1 + 81968) * *(float *)(a1 + 82672)) + (float)(v283 * *(float *)(a1 + 82688));
    v287 = *(float *)(a1 + 82544);
    *(float *)(a1 + 82272) = v286 + (float)(*(float *)(a1 + 82656) * *(float *)(a1 + 81952));
    v288 = *(float *)(a1 + 82000);
    v289 = (float)((float)(v287 * *(float *)(a1 + 82816)) + (float)(v284 * *(float *)(a1 + 82800)))
         * *(float *)(a1 + 82608);
    *(float *)(a1 + 82000) = v285;
    v290 = v289
         - (float)((float)((float)(v285 * *(float *)(a1 + 83104)) + (float)(v288 * *(float *)(a1 + 83120)))
                 * *(float *)(a1 + 82592));
    if ( v290 >= -1.0 )
      v291 = fminf(v290, 1.0);
    else
      v291 = -1.0;
    v292 = v291 + (float)((float)((float)((float)(v291 * v291) * v291) * v291) * (float)(v291 * *(float *)(a1 + 82768)));
    v293 = *(float *)(a1 + 81920);
    *(float *)(a1 + 81920) = v292;
    v294 = *(float *)(a1 + 81936);
    v295 = (float)(v241 * (float)(v292 + v293)) + (float)(v294 * v246);
    *(float *)(a1 + 81936) = v295;
    v296 = *(float *)(a1 + 81952);
    v297 = v241 * (float)(v295 + v294);
    v298 = v241 * (float)((float)((float)(v241 * v292) + (float)(v246 * v295)) + v295);
    v299 = v297 + (float)(v296 * v246);
    *(float *)(a1 + 81952) = v299;
    v300 = *(float *)(a1 + 81968);
    v301 = (float)(v241 * (float)(v299 + v296)) + (float)(v300 * v246);
    *(float *)(a1 + 81968) = v301;
    v302 = (float)((float)(v300 + v301) * v241) + (float)(v246 * *(float *)(a1 + 81984));
    *(float *)(a1 + 81984) = v302;
    v303 = (float)(v241
                 * (float)((float)((float)(v241 * (float)((float)(v298 + (float)(v246 * v299)) + v299))
                                 + (float)(v246 * v301))
                         + v301))
         + (float)(v246 * v302);
    v304 = (float)(*(float *)(a1 + 81968) * *(float *)(a1 + 82672)) + (float)(v302 * *(float *)(a1 + 82688));
    v305 = *(float *)(a1 + 82528);
    *(float *)(a1 + 82144) = v304 + (float)(*(float *)(a1 + 82656) * *(float *)(a1 + 81952));
    v306 = *(float *)(a1 + 82000);
    v307 = (float)(v305 * *(float *)(a1 + 82784)) * *(float *)(a1 + 82608);
    *(float *)(a1 + 81888) = v303;
    v308 = v307
         - (float)((float)((float)(v303 * *(float *)(a1 + 83104)) + (float)(v306 * *(float *)(a1 + 83120)))
                 * *(float *)(a1 + 82592));
    if ( v308 >= -1.0 )
      v309 = fminf(v308, 1.0);
    else
      v309 = -1.0;
    v310 = v309 + (float)((float)((float)((float)(v309 * v309) * v309) * v309) * (float)(v309 * *(float *)(a1 + 82768)));
    *(float *)(a1 + 81792) = v310;
    v311 = *(float *)(a1 + 81936);
    v312 = (float)(v241 * (float)(v310 + *(float *)(a1 + 81920))) + (float)(v311 * v246);
    *(float *)(a1 + 81808) = v312;
    v313 = *(float *)(a1 + 81952);
    v314 = v241 * (float)(v312 + v311);
    v315 = v241 * (float)((float)((float)(v241 * v310) + (float)(v246 * v312)) + v312);
    v316 = v314 + (float)(v313 * v246);
    *(float *)(a1 + 81824) = v316;
    v317 = *(float *)(a1 + 81968);
    v318 = (float)(v241 * (float)(v316 + v313)) + (float)(v317 * v246);
    *(float *)(a1 + 81840) = v318;
    v319 = (float)((float)(v317 + v318) * v241) + (float)(v246 * *(float *)(a1 + 81984));
    v320 = v241
         * (float)((float)((float)(v241 * (float)((float)(v315 + (float)(v246 * v316)) + v316)) + (float)(v246 * v318))
                 + v318);
    *(float *)(a1 + 81856) = v319;
    v321 = *(float *)(a1 + 81824);
    *(float *)(a1 + 81872) = v320 + (float)(v246 * v319);
    v322 = *(float *)(a1 + 82080);
    v323 = (float)((float)(v319 * *(float *)(a1 + 82688)) + (float)(*(float *)(a1 + 82672) * *(float *)(a1 + 81840)))
         + (float)(v321 * *(float *)(a1 + 82656));
    *(float *)(a1 + 82016) = v323;
    v324 = (float)(v323 + *(float *)(a1 + 82512)) * *(float *)(a1 + 82848);
    v325 = (float)(*(float *)(a1 + 82272) + *(float *)(a1 + 82256)) * *(float *)(a1 + 82880);
    v326 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v322 + *(float *)(a1 + 82448)) * *(float *)(a1 + 83088)) + (float)((float)(*(float *)(a1 + 82208) + *(float *)(a1 + 82320)) * *(float *)(a1 + 83072))) + (float)((float)(*(float *)(a1 + 82336) + *(float *)(a1 + 82192)) * *(float *)(a1 + 83056))) + (float)((float)(*(float *)(a1 + 82064) + *(float *)(a1 + 82464)) * *(float *)(a1 + 83040))) + (float)((float)(*(float *)(a1 + 82432) + *(float *)(a1 + 82096)) * *(float *)(a1 + 83024)))
                                                                                                 + (float)((float)(*(float *)(a1 + 82304) + *(float *)(a1 + 82224)) * *(float *)(a1 + 83008)))
                                                                                         + (float)((float)(*(float *)(a1 + 82352) + *(float *)(a1 + 82176))
                                                                                                 * *(float *)(a1 + 82992)))
                                                                                 + (float)((float)(*(float *)(a1 + 82480)
                                                                                                 + *(float *)(a1 + 82048))
                                                                                         * *(float *)(a1 + 82976)))
                                                                         + (float)((float)(*(float *)(a1 + 82416)
                                                                                         + *(float *)(a1 + 82112))
                                                                                 * *(float *)(a1 + 82960)))
                                                                 + (float)((float)(*(float *)(a1 + 82288)
                                                                                 + *(float *)(a1 + 82240))
                                                                         * *(float *)(a1 + 82944)))
                                                         + (float)((float)(*(float *)(a1 + 82368)
                                                                         + *(float *)(a1 + 82160))
                                                                 * *(float *)(a1 + 82928)))
                                                 + (float)((float)(*(float *)(a1 + 82496) + *(float *)(a1 + 82032))
                                                         * *(float *)(a1 + 82912)))
                                         + (float)((float)(*(float *)(a1 + 82400) + *(float *)(a1 + 82128))
                                                 * *(float *)(a1 + 82896)))
                                 + v325)
                         + (float)((float)(*(float *)(a1 + 82384) + *(float *)(a1 + 82144)) * *(float *)(a1 + 82864)))
                 + v324)
         * *(float *)(a1 + 82736);
    *(float *)(a1 + 82624) = v326;
  }
  *(_DWORD *)(a1 + 83152) = *(_DWORD *)(a1 + 83136);
  v327 = *(_DWORD *)(a1 + 83184);
  *(_DWORD *)(a1 + 83216) = *(_DWORD *)(a1 + 83168);
  *(_DWORD *)(a1 + 83232) = v327;
  *(_DWORD *)(a1 + 83248) = *(_DWORD *)(a1 + 83200);
  v328 = *(float *)(a1 + 83264);
  *(float *)(a1 + 83280) = v328;
  v329 = *(float *)(a1 + 83296);
  *(float *)(a1 + 83312) = v329;
  v330 = (float)((float)(v328 - v329) * *(float *)(a1 + 83328)) + v329;
  *(float *)(a1 + 83296) = v330;
  v331 = (float)((float)(v330 * *(float *)(a1 + 83232)) - (float)(*(float *)(a1 + 83232) * *(float *)(a1 + 83248)))
       + *(float *)(a1 + 83248);
  *(float *)(a1 + 83344) = v331;
  v332 = *(float *)(a1 + 83360);
  *(float *)(a1 + 83376) = v332;
  v333 = (float)((float)(*(float *)(a1 + 83392) * v331) - (float)(*(float *)(a1 + 83392) * v332)) + v332;
  if ( v333 <= 0.0 )
    v334 = 0.0;
  else
    v334 = v333;
  v335 = v334;
  *(float *)(a1 + 83360) = v335;
  v336 = *(float *)(a1 + 83408);
  *(float *)(a1 + 83424) = v336;
  v337 = *(float *)(a1 + 83440);
  *(float *)(a1 + 83456) = v337;
  v338 = (float)((float)(*(float *)(a1 + 83472) * v336) - (float)(*(float *)(a1 + 83472) * v337)) + v337;
  if ( v338 <= 0.0 )
    v339 = 0.0;
  else
    v339 = v338;
  v340 = v339;
  *(float *)(a1 + 83440) = v340;
  v341 = *(float *)(a1 + 83488);
  v342 = *(float *)(a1 + 74144);
  *(float *)(a1 + 83504) = v341;
  v343 = v341 * *(float *)(a1 + 83584);
  v344 = v341 + *(float *)(a1 + 83568);
  if ( v343 >= -1.0 )
    v345 = fminf(v343, 1.0);
  else
    v345 = -1.0;
  if ( (float)(v341 + *(float *)(a1 + 83536)) >= 0.0 )
    v344 = (float)((float)(*(float *)(a1 + 83552) * v342) - (float)(*(float *)(a1 + 83552) * v341)) + v341;
  v346 = (float)((float)(v345 * *(float *)(a1 + 83600)) - (float)(*(float *)(a1 + 83616) * v345))
       + *(float *)(a1 + 83616);
  v347 = (float)((float)(v346 * v342) - (float)(v346 * v341)) + v341;
  if ( v342 != 0.0 )
    v347 = v344;
  *(float *)(a1 + 83520) = v347;
  *(float *)(a1 + 83488) = v347;
  v348 = *(float *)(a1 + 82624);
  v349 = *(float *)(a1 + 76336);
  v350 = *(float *)(a1 + 80432);
  v351 = *(_DWORD *)(a1 + 76816);
  v352 = *(_DWORD *)(a1 + 83136);
  *(_DWORD *)(a1 + 83696) = *(_DWORD *)(a1 + 83680);
  *(_DWORD *)(a1 + 83728) = *(_DWORD *)(a1 + 83712);
  *(_DWORD *)(a1 + 83632) = v351;
  *(_DWORD *)(a1 + 83648) = v352;
  v353 = *(float *)(a1 + 83696);
  v354 = *(float *)(a1 + 83760);
  *(float *)(a1 + 83664) = v350 * *(float *)(a1 + 83920);
  v355 = v348 - v353;
  v356 = *(float *)(a1 + 83792);
  v357 = (float)(v349 * *(float *)(a1 + 83776)) + (float)(v354 * *(float *)(a1 + 83520));
  v358 = v353 + (float)((float)(v348 - v353) * *(float *)(a1 + 83824));
  *(float *)(a1 + 83680) = v358;
  v359 = (float)(v355 * *(float *)(a1 + 83936)) + (float)(v358 * *(float *)(a1 + 83952));
  v360 = (float)((float)(*(float *)(a1 + 83808) * *(float *)(a1 + 83648))
               - (float)(*(float *)(a1 + 83808) * (float)(v357 + (float)(v356 * *(float *)(a1 + 83632)))))
       + (float)(v357 + (float)(v356 * *(float *)(a1 + 83632)));
  v361 = *(float *)(a1 + 83840);
  v362 = v360 * *(float *)(a1 + 83888);
  v363 = v348 * (float)(1.0 - v361);
  if ( v362 <= 0.0 )
    v364 = 0.0;
  else
    v364 = v362;
  v365 = *(float *)(a1 + 83856);
  v366 = v364;
  v367 = v366 * *(float *)(a1 + 83904);
  v368 = (float)((float)(v361 * v359) + v363) * (float)(*(float *)(a1 + 83664) + 1.0);
  v369 = *(float *)(a1 + 83872) * v368;
  v370 = *(float *)(a1 + 83728)
       + (float)((float)(*(float *)(a1 + 83968) * v368) - (float)(*(float *)(a1 + 83968) * *(float *)(a1 + 83728)));
  *(float *)(a1 + 83712) = v370;
  v371 = (float)((float)((float)(v365 * v370) + v369) * v367) * *(float *)(a1 + 83984);
  *(float *)(a1 + 83744) = v371;
  *(_DWORD *)(a1 + 84032) = *(_DWORD *)(a1 + 84016);
  *(_DWORD *)(a1 + 84016) = *(_DWORD *)(a1 + 84000);
  v372 = *(float *)(a1 + 84032);
  v373 = *(float *)(a1 + 84048);
  v374 = v371 - v372;
  *(float *)(a1 + 84000) = v374;
  *(float *)(a1 + 84016) = (float)(v373 * v374) + v372;
  v375 = *(float *)(a1 + 84000);
  v376 = *(float *)(a1 + 83216);
  *(_DWORD *)(a1 + 84112) = *(_DWORD *)(a1 + 84096);
  *(_DWORD *)(a1 + 84096) = *(_DWORD *)(a1 + 84080);
  *(_DWORD *)(a1 + 84080) = *(_DWORD *)(a1 + 84064);
  *(float *)(a1 + 84064) = v375;
  v377 = (float)((float)(*(float *)(a1 + 84080) * *(float *)(a1 + 84160)) + (float)(v375 * *(float *)(a1 + 84144)))
       + (float)(*(float *)(a1 + 84176) * *(float *)(a1 + 84096));
  v378 = (float)((float)(*(float *)(a1 + 84080) * *(float *)(a1 + 84208)) + (float)(v375 * *(float *)(a1 + 84192)))
       + (float)(*(float *)(a1 + 84224) * *(float *)(a1 + 84112));
  if ( v376 <= 0.0 )
    v379 = 0.0;
  else
    v379 = v376;
  *(float *)(a1 + 84080) = v377;
  v380 = v379;
  *(float *)(a1 + 84096) = v378;
  v381 = (float)((float)(v380 * v377) - (float)(v380 * v375)) + v375;
  if ( v376 < -0.0 )
    v19 = (float)-v376;
  v382 = v19;
  v383 = v375 + (float)((float)(v382 * v378) - (float)(v382 * v375));
  if ( v376 >= 0.0 )
    v383 = v381;
  *(float *)(a1 + 84128) = v383;
  v384 = v383 * *(float *)(a1 + 83360);
  *(float *)(a1 + 84240) = v384;
  *(float *)(a1 + 84256) = v384 * *(float *)(a1 + 83440);
  v385 = fmin(fmax((float)(*(float *)(a1 + 78032) + *(float *)(a1 + 77360)), -20.0), 8.9);
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
       * *(float *)(a1 + 77376);
  *(float *)(a1 + 78000) = v391;
  v392 = *(float *)(a1 + 77360);
  v393 = *(_DWORD *)(a1 + 77824);
  v394 = *(_DWORD *)(a1 + 77840);
  LODWORD(v386) = *(_DWORD *)(a1 + 77856);
  *(_DWORD *)(a1 + 78432) = *(_DWORD *)(a1 + 78416);
  *(_DWORD *)(a1 + 78464) = *(_DWORD *)(a1 + 78448);
  *(_DWORD *)(a1 + 78640) = *(_DWORD *)(a1 + 78624);
  *(_DWORD *)(a1 + 78624) = *(_DWORD *)(a1 + 78608);
  *(_DWORD *)(a1 + 78608) = *(_DWORD *)(a1 + 78592);
  *(_DWORD *)(a1 + 78592) = *(_DWORD *)(a1 + 78576);
  *(_DWORD *)(a1 + 78576) = *(_DWORD *)(a1 + 78560);
  *(_DWORD *)(a1 + 78560) = *(_DWORD *)(a1 + 78544);
  *(_DWORD *)(a1 + 78544) = *(_DWORD *)(a1 + 78528);
  *(_DWORD *)(a1 + 78768) = *(_DWORD *)(a1 + 78752);
  *(_DWORD *)(a1 + 78752) = *(_DWORD *)(a1 + 78736);
  *(_DWORD *)(a1 + 78736) = *(_DWORD *)(a1 + 78720);
  *(_DWORD *)(a1 + 78720) = *(_DWORD *)(a1 + 78704);
  *(_DWORD *)(a1 + 78704) = *(_DWORD *)(a1 + 78688);
  *(_DWORD *)(a1 + 78688) = *(_DWORD *)(a1 + 78672);
  *(_DWORD *)(a1 + 78672) = *(_DWORD *)(a1 + 78656);
  *(_DWORD *)(a1 + 78896) = *(_DWORD *)(a1 + 78880);
  *(_DWORD *)(a1 + 78880) = *(_DWORD *)(a1 + 78864);
  *(_DWORD *)(a1 + 78864) = *(_DWORD *)(a1 + 78848);
  *(_DWORD *)(a1 + 78848) = *(_DWORD *)(a1 + 78832);
  *(_DWORD *)(a1 + 78832) = *(_DWORD *)(a1 + 78816);
  *(_DWORD *)(a1 + 78816) = *(_DWORD *)(a1 + 78800);
  *(_DWORD *)(a1 + 78800) = *(_DWORD *)(a1 + 78784);
  *(_DWORD *)(a1 + 79024) = *(_DWORD *)(a1 + 79008);
  *(_DWORD *)(a1 + 79008) = *(_DWORD *)(a1 + 78992);
  *(_DWORD *)(a1 + 78992) = *(_DWORD *)(a1 + 78976);
  *(_DWORD *)(a1 + 78976) = *(_DWORD *)(a1 + 78960);
  *(_DWORD *)(a1 + 78960) = *(_DWORD *)(a1 + 78944);
  *(_DWORD *)(a1 + 78944) = *(_DWORD *)(a1 + 78928);
  *(_DWORD *)(a1 + 78928) = *(_DWORD *)(a1 + 78912);
  *(_DWORD *)(a1 + 79088) = *(_DWORD *)(a1 + 79072);
  *(_DWORD *)(a1 + 79072) = *(_DWORD *)(a1 + 79056);
  *(_DWORD *)(a1 + 78320) = v393;
  *(_DWORD *)(a1 + 78336) = v394;
  v395 = v392 + *(float *)(a1 + 79888);
  v396 = v391 * *(float *)(a1 + 79120);
  v397 = *(float *)(a1 + 79104);
  *(_DWORD *)(a1 + 78352) = LODWORD(v386);
  v398 = fmaxf(*(float *)(a1 + 79152), v396);
  v399 = (float)(v395 * *(float *)(a1 + 79904)) + *(float *)(a1 + 79872);
  *(float *)(a1 + 78368) = v398;
  *(float *)(a1 + 78400) = v397 + *(float *)(a1 + 77392);
  if ( v399 <= 0.0 )
    v400 = 0.0;
  else
    v400 = v399;
  *(float *)(a1 + 78384) = 0.00390625 / v398;
  *(float *)(a1 + 79040) = v400;
  v401 = *(float *)(a1 + 78464);
  v402 = *(_DWORD *)(a1 + 78432);
  *(float *)(a1 + 78240) = v401;
  v403 = v401 + v398;
  *(_DWORD *)(a1 + 78256) = v402;
  if ( v403 <= 1.0 )
  {
    if ( v403 < -1.0 )
      v403 = fmodf(v403 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v403 = fmodf(v403 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 78224) = v403;
  v404 = v403 * *(float *)(a1 + 79232);
  v405 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v406 = (float)((float)(*(float *)&v405 * 256.0) * *(float *)(a1 + 78384)) * *(float *)(a1 + 79184);
  if ( v406 >= -1.0 )
    v407 = fminf(v406, 1.0);
  else
    v407 = -1.0;
  v408 = v407 * *(float *)(a1 + 79136);
  v409 = (float)(v408 * v408) * v408;
  v410 = v409 * *(float *)(a1 + 79536);
  v411 = (float)((float)((float)((float)((float)(v408 * v408) * *(float *)(a1 + 79600)) + *(float *)(a1 + 79584))
                       * (float)((float)(v408 * v408) * (float)(v408 * v408)))
               + (float)((float)((float)(v408 * v408) * *(float *)(a1 + 79568)) + *(float *)(a1 + 79552)))
       * (float)(v409 * (float)(v408 * v408));
  v412 = *(float *)(a1 + 78400) + v403;
  *(float *)(a1 + 78480) = (float)((float)(v411 + v410) + v408) * v404;
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
  v414 = *(float *)(a1 + 78224);
  v415 = v413 * *(float *)(a1 + 79248);
  v416 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v417 = *(float *)&v416;
  v418 = *(float *)(a1 + 79168);
  if ( v414 < v418 || v418 <= *(float *)(a1 + 78240) )
    v419 = *(float *)(a1 + 78256);
  else
    v419 = *(float *)(a1 + 78256) + 2.0;
  v420 = (float)((float)(v417 * *(float *)(a1 + 78384)) * 256.0) * *(float *)(a1 + 79200);
  if ( v419 >= 4.0 )
    v419 = 0.0;
  if ( v420 >= -1.0 )
    v421 = fminf(v420, 1.0);
  else
    v421 = -1.0;
  *(float *)(a1 + 78256) = v419;
  v422 = v421 * *(float *)(a1 + 79136);
  v423 = (float)((float)((float)(v419 + v414) + 1.0) * 0.5) - 1.0;
  v424 = (float)((float)((float)((float)((float)((float)((float)((float)(v422 * v422) * *(float *)(a1 + 79600))
                                                       + *(float *)(a1 + 79584))
                                               * (float)((float)(v422 * v422) * (float)(v422 * v422)))
                                       + (float)((float)((float)(v422 * v422) * *(float *)(a1 + 79568))
                                               + *(float *)(a1 + 79552)))
                               * (float)((float)((float)(v422 * v422) * v422) * (float)(v422 * v422)))
                       + (float)((float)((float)(v422 * v422) * v422) * *(float *)(a1 + 79536)))
               + v422)
       * v415;
  *(float *)(a1 + 78496) = v424;
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
  v426 = v423 * *(float *)(a1 + 79264);
  v427 = (float)((float)((float)(*(float *)&v425 + 1.0) * *(float *)(a1 + 78384)) * 512.0) * *(float *)(a1 + 79216);
  if ( v427 >= -1.0 )
    v428 = fminf(v427, 1.0);
  else
    v428 = -1.0;
  v429 = v428 * *(float *)(a1 + 79136);
  v430 = *(float *)(a1 + 78224);
  v431 = *(_DWORD *)(a1 + 78256);
  *(float *)(a1 + 78528) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v429 * v429)
                                                                                                 * *(float *)(a1 + 79600))
                                                                                         + *(float *)(a1 + 79584))
                                                                                 * (float)((float)(v429 * v429)
                                                                                         * (float)(v429 * v429)))
                                                                         + (float)((float)((float)(v429 * v429)
                                                                                         * *(float *)(a1 + 79568))
                                                                                 + *(float *)(a1 + 79552)))
                                                                 * (float)((float)((float)(v429 * v429) * v429)
                                                                         * (float)(v429 * v429)))
                                                         + (float)((float)((float)(v429 * v429) * v429)
                                                                 * *(float *)(a1 + 79536)))
                                                 + v429)
                                         * v426)
                                 * *(float *)(a1 + 78352))
                         + (float)((float)(*(float *)(a1 + 78480) * *(float *)(a1 + 78320))
                                 + (float)(v424 * *(float *)(a1 + 78336)));
  *(float *)(a1 + 78240) = v430;
  *(_DWORD *)(a1 + 78256) = v431;
  v432 = v430 + *(float *)(a1 + 78368);
  if ( v432 <= 1.0 )
  {
    if ( v432 < -1.0 )
      v432 = fmodf(v432 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v432 = fmodf(v432 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 78224) = v432;
  v433 = v432 * *(float *)(a1 + 79232);
  v434 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v435 = (float)((float)(*(float *)&v434 * 256.0) * *(float *)(a1 + 78384)) * *(float *)(a1 + 79184);
  if ( v435 >= -1.0 )
    v436 = fminf(v435, 1.0);
  else
    v436 = -1.0;
  v437 = v436 * *(float *)(a1 + 79136);
  v438 = (float)(v437 * v437) * v437;
  v439 = v438 * *(float *)(a1 + 79536);
  v440 = (float)((float)((float)((float)((float)(v437 * v437) * *(float *)(a1 + 79600)) + *(float *)(a1 + 79584))
                       * (float)((float)(v437 * v437) * (float)(v437 * v437)))
               + (float)((float)((float)(v437 * v437) * *(float *)(a1 + 79568)) + *(float *)(a1 + 79552)))
       * (float)(v438 * (float)(v437 * v437));
  v441 = *(float *)(a1 + 78400) + v432;
  *(float *)(a1 + 78480) = (float)((float)(v440 + v439) + v437) * v433;
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
  v443 = *(float *)(a1 + 78224);
  v444 = v442 * *(float *)(a1 + 79248);
  v445 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v446 = *(float *)&v445;
  v447 = *(float *)(a1 + 79168);
  if ( v443 < v447 || v447 <= *(float *)(a1 + 78240) )
    v448 = *(float *)(a1 + 78256);
  else
    v448 = *(float *)(a1 + 78256) + 2.0;
  v449 = (float)((float)(v446 * *(float *)(a1 + 78384)) * 256.0) * *(float *)(a1 + 79200);
  if ( v448 >= 4.0 )
    v448 = 0.0;
  if ( v449 >= -1.0 )
    v450 = fminf(v449, 1.0);
  else
    v450 = -1.0;
  *(float *)(a1 + 78256) = v448;
  v451 = v450 * *(float *)(a1 + 79136);
  v452 = (float)((float)((float)(v448 + v443) + 1.0) * 0.5) - 1.0;
  v453 = (float)((float)((float)((float)((float)((float)((float)((float)(v451 * v451) * *(float *)(a1 + 79600))
                                                       + *(float *)(a1 + 79584))
                                               * (float)((float)(v451 * v451) * (float)(v451 * v451)))
                                       + (float)((float)((float)(v451 * v451) * *(float *)(a1 + 79568))
                                               + *(float *)(a1 + 79552)))
                               * (float)((float)((float)(v451 * v451) * v451) * (float)(v451 * v451)))
                       + (float)((float)((float)(v451 * v451) * v451) * *(float *)(a1 + 79536)))
               + v451)
       * v444;
  *(float *)(a1 + 78496) = v453;
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
  v455 = v452 * *(float *)(a1 + 79264);
  v456 = (float)((float)((float)(*(float *)&v454 + 1.0) * *(float *)(a1 + 78384)) * 512.0) * *(float *)(a1 + 79216);
  if ( v456 >= -1.0 )
    v457 = fminf(v456, 1.0);
  else
    v457 = -1.0;
  v458 = v457 * *(float *)(a1 + 79136);
  v459 = *(float *)(a1 + 78224);
  v460 = *(_DWORD *)(a1 + 78256);
  *(float *)(a1 + 78656) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v458 * v458)
                                                                                                 * *(float *)(a1 + 79600))
                                                                                         + *(float *)(a1 + 79584))
                                                                                 * (float)((float)(v458 * v458)
                                                                                         * (float)(v458 * v458)))
                                                                         + (float)((float)((float)(v458 * v458)
                                                                                         * *(float *)(a1 + 79568))
                                                                                 + *(float *)(a1 + 79552)))
                                                                 * (float)((float)((float)(v458 * v458) * v458)
                                                                         * (float)(v458 * v458)))
                                                         + (float)((float)((float)(v458 * v458) * v458)
                                                                 * *(float *)(a1 + 79536)))
                                                 + v458)
                                         * v455)
                                 * *(float *)(a1 + 78352))
                         + (float)((float)(*(float *)(a1 + 78480) * *(float *)(a1 + 78320))
                                 + (float)(v453 * *(float *)(a1 + 78336)));
  *(float *)(a1 + 78240) = v459;
  *(_DWORD *)(a1 + 78256) = v460;
  v461 = v459 + *(float *)(a1 + 78368);
  if ( v461 <= 1.0 )
  {
    if ( v461 < -1.0 )
      v461 = fmodf(v461 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v461 = fmodf(v461 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 78224) = v461;
  v462 = v461 * *(float *)(a1 + 79232);
  v463 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v464 = (float)((float)(*(float *)&v463 * 256.0) * *(float *)(a1 + 78384)) * *(float *)(a1 + 79184);
  if ( v464 >= -1.0 )
    v465 = fminf(v464, 1.0);
  else
    v465 = -1.0;
  v466 = v465 * *(float *)(a1 + 79136);
  v467 = (float)(v466 * v466) * v466;
  v468 = v467 * *(float *)(a1 + 79536);
  v469 = (float)((float)((float)((float)((float)(v466 * v466) * *(float *)(a1 + 79600)) + *(float *)(a1 + 79584))
                       * (float)((float)(v466 * v466) * (float)(v466 * v466)))
               + (float)((float)((float)(v466 * v466) * *(float *)(a1 + 79568)) + *(float *)(a1 + 79552)))
       * (float)(v467 * (float)(v466 * v466));
  v470 = *(float *)(a1 + 78400) + v461;
  *(float *)(a1 + 78480) = (float)((float)(v469 + v468) + v466) * v462;
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
  v472 = *(float *)(a1 + 78224);
  v473 = v471 * *(float *)(a1 + 79248);
  v474 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v475 = *(float *)&v474;
  v476 = *(float *)(a1 + 79168);
  if ( v472 < v476 || v476 <= *(float *)(a1 + 78240) )
    v477 = *(float *)(a1 + 78256);
  else
    v477 = *(float *)(a1 + 78256) + 2.0;
  v478 = (float)((float)(v475 * *(float *)(a1 + 78384)) * 256.0) * *(float *)(a1 + 79200);
  if ( v477 >= 4.0 )
    v477 = 0.0;
  if ( v478 >= -1.0 )
    v479 = fminf(v478, 1.0);
  else
    v479 = -1.0;
  *(float *)(a1 + 78256) = v477;
  v480 = v479 * *(float *)(a1 + 79136);
  v481 = (float)((float)((float)(v477 + v472) + 1.0) * 0.5) - 1.0;
  v482 = (float)((float)((float)((float)((float)((float)((float)((float)(v480 * v480) * *(float *)(a1 + 79600))
                                                       + *(float *)(a1 + 79584))
                                               * (float)((float)(v480 * v480) * (float)(v480 * v480)))
                                       + (float)((float)((float)(v480 * v480) * *(float *)(a1 + 79568))
                                               + *(float *)(a1 + 79552)))
                               * (float)((float)((float)(v480 * v480) * v480) * (float)(v480 * v480)))
                       + (float)((float)((float)(v480 * v480) * v480) * *(float *)(a1 + 79536)))
               + v480)
       * v473;
  *(float *)(a1 + 78496) = v482;
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
  v484 = v481 * *(float *)(a1 + 79264);
  v485 = (float)((float)((float)(*(float *)&v483 + 1.0) * *(float *)(a1 + 78384)) * 512.0) * *(float *)(a1 + 79216);
  if ( v485 >= -1.0 )
    v486 = fminf(v485, 1.0);
  else
    v486 = -1.0;
  v487 = v486 * *(float *)(a1 + 79136);
  v488 = *(float *)(a1 + 78224);
  v489 = *(_DWORD *)(a1 + 78256);
  *(float *)(a1 + 78784) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v487 * v487)
                                                                                                 * *(float *)(a1 + 79600))
                                                                                         + *(float *)(a1 + 79584))
                                                                                 * (float)((float)(v487 * v487)
                                                                                         * (float)(v487 * v487)))
                                                                         + (float)((float)((float)(v487 * v487)
                                                                                         * *(float *)(a1 + 79568))
                                                                                 + *(float *)(a1 + 79552)))
                                                                 * (float)((float)((float)(v487 * v487) * v487)
                                                                         * (float)(v487 * v487)))
                                                         + (float)((float)((float)(v487 * v487) * v487)
                                                                 * *(float *)(a1 + 79536)))
                                                 + v487)
                                         * v484)
                                 * *(float *)(a1 + 78352))
                         + (float)((float)(*(float *)(a1 + 78480) * *(float *)(a1 + 78320))
                                 + (float)(v482 * *(float *)(a1 + 78336)));
  *(float *)(a1 + 78240) = v488;
  *(_DWORD *)(a1 + 78256) = v489;
  v490 = v488 + *(float *)(a1 + 78368);
  if ( v490 <= 1.0 )
  {
    if ( v490 < -1.0 )
      v490 = fmodf(v490 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v490 = fmodf(v490 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 78224) = v490;
  v491 = v490 * *(float *)(a1 + 79232);
  v492 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v493 = (float)((float)(*(float *)&v492 * 256.0) * *(float *)(a1 + 78384)) * *(float *)(a1 + 79184);
  if ( v493 >= -1.0 )
    v494 = fminf(v493, 1.0);
  else
    v494 = -1.0;
  v495 = v494 * *(float *)(a1 + 79136);
  v496 = (float)(v495 * v495) * v495;
  v497 = v496 * *(float *)(a1 + 79536);
  v498 = (float)((float)((float)((float)((float)(v495 * v495) * *(float *)(a1 + 79600)) + *(float *)(a1 + 79584))
                       * (float)((float)(v495 * v495) * (float)(v495 * v495)))
               + (float)((float)((float)(v495 * v495) * *(float *)(a1 + 79568)) + *(float *)(a1 + 79552)))
       * (float)(v496 * (float)(v495 * v495));
  v499 = *(float *)(a1 + 78400) + v490;
  *(float *)(a1 + 78480) = (float)((float)(v498 + v497) + v495) * v491;
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
  v501 = *(float *)(a1 + 78224);
  v502 = v500 * *(float *)(a1 + 79248);
  v503 = ((double (*)(void))sub_7FF91DFC8FC0)();
  v504 = *(float *)&v503;
  v505 = *(float *)(a1 + 79168);
  if ( v501 < v505 || v505 <= *(float *)(a1 + 78240) )
    v506 = *(float *)(a1 + 78256);
  else
    v506 = *(float *)(a1 + 78256) + 2.0;
  v507 = (float)((float)(v504 * *(float *)(a1 + 78384)) * 256.0) * *(float *)(a1 + 79200);
  if ( v506 >= 4.0 )
    v506 = 0.0;
  if ( v507 >= -1.0 )
    v508 = fminf(v507, 1.0);
  else
    v508 = -1.0;
  *(float *)(a1 + 78256) = v506;
  v509 = v508 * *(float *)(a1 + 79136);
  v510 = (float)((float)((float)(v506 + v501) + 1.0) * 0.5) - 1.0;
  v511 = (float)((float)((float)((float)((float)((float)((float)((float)(v509 * v509) * *(float *)(a1 + 79600))
                                                       + *(float *)(a1 + 79584))
                                               * (float)((float)(v509 * v509) * (float)(v509 * v509)))
                                       + (float)((float)((float)(v509 * v509) * *(float *)(a1 + 79568))
                                               + *(float *)(a1 + 79552)))
                               * (float)((float)((float)(v509 * v509) * v509) * (float)(v509 * v509)))
                       + (float)((float)((float)(v509 * v509) * v509) * *(float *)(a1 + 79536)))
               + v509)
       * v502;
  *(float *)(a1 + 78496) = v511;
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
  v513 = v510 * *(float *)(a1 + 79264);
  v514 = (float)((float)(v512 * *(float *)(a1 + 78384)) * 512.0) * *(float *)(a1 + 79216);
  if ( v514 >= -1.0 )
    v33 = fminf(v514, 1.0);
  v515 = v33 * *(float *)(a1 + 79136);
  v516 = *(_DWORD *)(a1 + 78224);
  v517 = *(_DWORD *)(a1 + 78256);
  *(float *)(a1 + 78912) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v515 * v515)
                                                                                                 * *(float *)(a1 + 79600))
                                                                                         + *(float *)(a1 + 79584))
                                                                                 * (float)((float)(v515 * v515)
                                                                                         * (float)(v515 * v515)))
                                                                         + (float)((float)((float)(v515 * v515)
                                                                                         * *(float *)(a1 + 79568))
                                                                                 + *(float *)(a1 + 79552)))
                                                                 * (float)((float)((float)(v515 * v515) * v515)
                                                                         * (float)(v515 * v515)))
                                                         + (float)((float)((float)(v515 * v515) * v515)
                                                                 * *(float *)(a1 + 79536)))
                                                 + v515)
                                         * v513)
                                 * *(float *)(a1 + 78352))
                         + (float)((float)(*(float *)(a1 + 78480) * *(float *)(a1 + 78320))
                                 + (float)(v511 * *(float *)(a1 + 78336)));
  v518 = *(float *)(a1 + 79024);
  *(_DWORD *)(a1 + 78448) = v516;
  *(_DWORD *)(a1 + 78416) = v517;
  v519 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(*(float *)(a1 + 78896) + *(float *)(a1 + 78656))
                                                                                               * *(float *)(a1 + 79296))
                                                                                       + (float)((float)(v518 + *(float *)(a1 + 78528))
                                                                                               * *(float *)(a1 + 79280)))
                                                                               + (float)((float)(*(float *)(a1 + 78784)
                                                                                               + *(float *)(a1 + 78768))
                                                                                       * *(float *)(a1 + 79312)))
                                                                       + (float)((float)(*(float *)(a1 + 78912)
                                                                                       + *(float *)(a1 + 78640))
                                                                               * *(float *)(a1 + 79328)))
                                                               + (float)((float)(*(float *)(a1 + 79008)
                                                                               + *(float *)(a1 + 78544))
                                                                       * *(float *)(a1 + 79344)))
                                                       + (float)((float)(*(float *)(a1 + 78880) + *(float *)(a1 + 78672))
                                                               * *(float *)(a1 + 79360)))
                                               + (float)((float)(*(float *)(a1 + 78800) + *(float *)(a1 + 78752))
                                                       * *(float *)(a1 + 79376)))
                                       + (float)((float)(*(float *)(a1 + 78928) + *(float *)(a1 + 78624))
                                               * *(float *)(a1 + 79392)))
                               + (float)((float)(*(float *)(a1 + 78992) + *(float *)(a1 + 78560))
                                       * *(float *)(a1 + 79408)))
                       + (float)((float)(*(float *)(a1 + 78688) + *(float *)(a1 + 78864)) * *(float *)(a1 + 79424)))
               + (float)((float)(*(float *)(a1 + 78816) + *(float *)(a1 + 78736)) * *(float *)(a1 + 79440)))
       + (float)((float)(*(float *)(a1 + 78608) + *(float *)(a1 + 78944)) * *(float *)(a1 + 79456));
  v520 = *(float *)(a1 + 79072);
  v521 = (float)(v520 * *(float *)(a1 + 79840)) + *(float *)(a1 + 79088);
  v522 = (float)((float)(v519
                       + (float)((float)(*(float *)(a1 + 78976) + *(float *)(a1 + 78576)) * *(float *)(a1 + 79472)))
               + (float)((float)(*(float *)(a1 + 78848) + *(float *)(a1 + 78704)) * *(float *)(a1 + 79488)))
       + (float)((float)(*(float *)(a1 + 78832) + *(float *)(a1 + 78720)) * *(float *)(a1 + 79504));
  v523 = (float)(*(float *)(a1 + 78960) + *(float *)(a1 + 78592)) * *(float *)(a1 + 79520);
  *(float *)(a1 + 79072) = v521;
  v524 = v522 + v523;
  v525 = v524 - (float)((float)(v520 * *(float *)(a1 + 79856)) + v521);
  *(float *)(a1 + 79056) = (float)(v525 * *(float *)(a1 + 79840)) + v520;
  v526 = (float)((float)((float)(v521 - (float)(v525 * *(float *)(a1 + 79040))) * *(float *)(a1 + 79920))
               - (float)(*(float *)(a1 + 79920) * v524))
       + v524;
  *(float *)(a1 + 78512) = v526;
  *(float *)(a1 + 77104) = v526;
  if ( *(float *)(a1 + 101728) == 1.0 )
  {
    *(_DWORD *)(a1 + 73904) = v528;
    *(_DWORD *)(a1 + 101728) = 0;
  }
  **a2 = *(_DWORD *)(a1 + 84256);
  result = *(unsigned int *)(a1 + 84256);
  *a2[1] = result;
  return result;
}

