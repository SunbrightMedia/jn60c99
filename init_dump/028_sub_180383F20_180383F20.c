// sub_180383F20  @ 0x180383F20  (RVA 0x383F20)  floats=21
// .rdata float constants referenced by this function:
//   0x18098AC70  dword_18098AC70 = 5.960464477539063e-08
//   0x18098AC90  qword_18098AC90 = -107374184.0
//   0x18098AC98  dword_18098AC98 = 512.0
//   0x18098ACA8  qword_18098ACA8 = 0.0
//   0x18098ACB0  dword_18098ACB0 = -512.0
//   0x18098ACC0  dword_18098ACC0 = 0.5
//   0x18098AD3C  dword_18098AD3C = 2.3283064365386963e-10
//   0x18098ADC0  dword_18098ADC0 = 1.52587890625e-05
//   0x18098ADC4  dword_18098ADC4 = -16777216.0
//   0x180AE4F5C  dword_180AE4F5C = 0.00390625
//   0x180AE4FD0  dword_180AE4FD0 = 0.25
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE51A0  dbl_180AE51A0 = 0.0
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE5268  qword_180AE5268 = 0.0
//   0x180AE52D0  dword_180AE52D0 = 4.0
//   0x180AE5444  dword_180AE5444 = 256.0
//   0x180AE54C0  dword_180AE54C0 = -0.0
//   0x180AE54E4  dword_180AE54E4 = -1.0
//   0x180AE57C0  xmmword_180AE57C0 = -0.0

__int64 __fastcall sub_180383F20(__int64 a1, _DWORD **a2)
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
  __int64 v87; // xmm6_8
  float v88; // xmm0_4
  float v89; // xmm0_4
  float v90; // xmm6_4
  float v91; // xmm2_4
  float v92; // xmm6_4
  float v93; // xmm1_4
  float v94; // xmm11_4
  float v95; // xmm0_4
  float v96; // xmm0_4
  double v97; // xmm1_8
  float v98; // xmm0_4
  float v99; // xmm7_4
  float v100; // xmm7_4
  float v101; // xmm8_4
  float v102; // xmm0_4
  float v103; // xmm8_4
  float v104; // xmm0_4
  double v105; // xmm8_8
  float v106; // xmm7_4
  float v107; // xmm0_4
  float v108; // xmm7_4
  float v109; // xmm0_4
  float v110; // xmm6_4
  float v111; // xmm7_4
  float v112; // xmm6_4
  float v113; // xmm4_4
  float v114; // xmm3_4
  float v115; // xmm6_4
  float v116; // xmm4_4
  float v117; // xmm2_4
  float v118; // xmm3_4
  float v119; // xmm4_4
  int v120; // xmm0_4
  float v121; // xmm0_4
  float v122; // xmm1_4
  float v123; // xmm8_4
  float v124; // xmm5_4
  float v125; // xmm7_4
  float v126; // xmm4_4
  float v127; // xmm7_4
  float v128; // xmm6_4
  float v129; // xmm2_4
  float v130; // xmm3_4
  float v131; // xmm4_4
  float v132; // xmm3_4
  float v133; // xmm5_4
  float v134; // xmm7_4
  float v135; // xmm4_4
  float v136; // xmm0_4
  float v137; // xmm3_4
  float v138; // xmm5_4
  float v139; // xmm2_4
  float v140; // xmm3_4
  float v141; // xmm3_4
  float v142; // xmm0_4
  float v143; // xmm0_4
  float v144; // xmm1_4
  float v145; // xmm8_4
  float v146; // xmm5_4
  float v147; // xmm6_4
  float v148; // xmm4_4
  float v149; // xmm6_4
  float v150; // xmm7_4
  float v151; // xmm0_4
  float v152; // xmm2_4
  float v153; // xmm4_4
  float v154; // xmm3_4
  float v155; // xmm5_4
  float v156; // xmm6_4
  float v157; // xmm4_4
  float v158; // xmm0_4
  float v159; // xmm3_4
  float v160; // xmm5_4
  float v161; // xmm2_4
  float v162; // xmm3_4
  float v163; // xmm3_4
  float v164; // xmm0_4
  float v165; // xmm0_4
  float v166; // xmm8_4
  float v167; // xmm8_4
  float v168; // xmm7_4
  int v169; // xmm1_4
  int v170; // xmm2_4
  int v171; // xmm0_4
  float v172; // xmm4_4
  float v173; // xmm5_4
  float v174; // xmm7_4
  float v175; // xmm4_4
  float v176; // xmm2_4
  float v177; // xmm3_4
  float v178; // xmm7_4
  float v179; // xmm6_4
  float v180; // xmm5_4
  float v181; // xmm0_4
  float v182; // xmm3_4
  float v183; // xmm6_4
  float v184; // xmm3_4
  int v185; // xmm0_4
  float v186; // xmm2_4
  int v187; // xmm0_4
  float v188; // xmm4_4
  float v189; // xmm2_4
  float v190; // xmm3_4
  float v191; // xmm0_4
  float v192; // xmm3_4
  float v193; // xmm4_4
  float v194; // xmm1_4
  float v195; // xmm1_4
  float v196; // xmm1_4
  float v197; // xmm0_4
  float v198; // xmm4_4
  float v199; // xmm0_4
  double v200; // xmm0_8
  float v201; // xmm1_4
  float v202; // xmm0_4
  float v203; // xmm1_4
  float v204; // xmm0_4
  float v205; // xmm1_4
  float v206; // xmm0_4
  float v207; // xmm3_4
  float v208; // xmm2_4
  float v209; // xmm3_4
  float v210; // xmm0_4
  float v211; // xmm3_4
  float v212; // xmm1_4
  float v213; // xmm0_4
  float v214; // xmm0_4
  float v215; // xmm7_4
  float v216; // xmm7_4
  float v217; // xmm1_4
  float v218; // xmm0_4
  float v219; // xmm7_4
  float v220; // xmm4_4
  float v221; // xmm5_4
  float v222; // xmm6_4
  float v223; // xmm0_4
  float v224; // xmm3_4
  __m128 v225; // xmm9
  float v226; // xmm7_4
  float v227; // xmm8_4
  float v228; // xmm0_4
  float v229; // xmm6_4
  float v230; // xmm6_4
  float v231; // xmm2_4
  float v232; // xmm1_4
  int v233; // ecx
  float v234; // xmm9_4
  float v235; // xmm6_4
  float v236; // xmm4_4
  float v237; // xmm3_4
  float v238; // xmm8_4
  float v239; // xmm8_4
  float v240; // xmm1_4
  float v241; // xmm9_4
  float v242; // xmm0_4
  float v243; // xmm6_4
  float v244; // xmm6_4
  float v245; // xmm3_4
  float v246; // xmm1_4
  float v247; // xmm5_4
  float v248; // xmm5_4
  float v249; // xmm2_4
  float v250; // xmm1_4
  float v251; // xmm0_4
  float v252; // xmm5_4
  float v253; // xmm5_4
  float v254; // xmm5_4
  float v255; // xmm3_4
  float v256; // xmm4_4
  float v257; // xmm1_4
  float v258; // xmm3_4
  float v259; // xmm4_4
  float v260; // xmm3_4
  float v261; // xmm5_4
  float v262; // xmm2_4
  float v263; // xmm5_4
  float v264; // xmm4_4
  float v265; // xmm2_4
  float v266; // xmm5_4
  float v267; // xmm0_4
  float v268; // xmm5_4
  float v269; // xmm5_4
  float v270; // xmm5_4
  float v271; // xmm5_4
  float v272; // xmm1_4
  float v273; // xmm3_4
  float v274; // xmm4_4
  float v275; // xmm1_4
  float v276; // xmm3_4
  float v277; // xmm4_4
  float v278; // xmm3_4
  float v279; // xmm5_4
  float v280; // xmm2_4
  float v281; // xmm5_4
  float v282; // xmm1_4
  float v283; // xmm4_4
  float v284; // xmm2_4
  float v285; // xmm5_4
  float v286; // xmm0_4
  float v287; // xmm5_4
  float v288; // xmm5_4
  float v289; // xmm5_4
  float v290; // xmm5_4
  float v291; // xmm1_4
  float v292; // xmm3_4
  float v293; // xmm4_4
  float v294; // xmm1_4
  float v295; // xmm3_4
  float v296; // xmm4_4
  float v297; // xmm3_4
  float v298; // xmm5_4
  float v299; // xmm2_4
  float v300; // xmm5_4
  float v301; // xmm3_4
  float v302; // xmm1_4
  float v303; // xmm5_4
  float v304; // xmm0_4
  float v305; // xmm5_4
  float v306; // xmm5_4
  float v307; // xmm5_4
  float v308; // xmm5_4
  float v309; // xmm3_4
  float v310; // xmm4_4
  float v311; // xmm1_4
  float v312; // xmm3_4
  float v313; // xmm4_4
  float v314; // xmm3_4
  float v315; // xmm5_4
  float v316; // xmm2_4
  float v317; // xmm5_4
  float v318; // xmm8_4
  float v319; // xmm3_4
  float v320; // xmm4_4
  float v321; // xmm5_4
  float v322; // xmm5_4
  float v323; // xmm0_4
  float v324; // xmm4_4
  int v325; // xmm0_4
  float v326; // xmm2_4
  float v327; // xmm0_4
  float v328; // xmm2_4
  float v329; // xmm2_4
  float v330; // xmm1_4
  float v331; // xmm3_4
  double v332; // xmm0_8
  float v333; // xmm0_4
  float v334; // xmm1_4
  float v335; // xmm2_4
  float v336; // xmm3_4
  double v337; // xmm0_8
  float v338; // xmm0_4
  float v339; // xmm5_4
  float v340; // xmm6_4
  float v341; // xmm4_4
  float v342; // xmm3_4
  float v343; // xmm4_4
  float v344; // xmm2_4
  float v345; // xmm0_4
  float v346; // xmm7_4
  float v347; // xmm6_4
  float v348; // xmm3_4
  int v349; // xmm0_4
  int v350; // xmm1_4
  float v351; // xmm4_4
  float v352; // xmm2_4
  float v353; // xmm3_4
  float v354; // xmm1_4
  float v355; // xmm6_4
  float v356; // xmm4_4
  float v357; // xmm3_4
  float v358; // xmm1_4
  float v359; // xmm6_4
  float v360; // xmm1_4
  float v361; // xmm7_4
  double v362; // xmm0_8
  float v363; // xmm4_4
  float v364; // xmm5_4
  float v365; // xmm5_4
  float v366; // xmm6_4
  float v367; // xmm2_4
  float v368; // xmm3_4
  float v369; // xmm4_4
  float v370; // xmm0_4
  float v371; // xmm1_4
  float v372; // xmm4_4
  float v373; // xmm2_4
  float v374; // xmm6_4
  float v375; // xmm5_4
  float v376; // xmm4_4
  double v377; // xmm0_8
  float v378; // xmm3_4
  float v379; // xmm3_4
  float v380; // xmm1_4
  float v381; // xmm2_4
  float v382; // xmm2_4
  double v383; // xmm12_8
  double v384; // xmm2_8
  double *v385; // rax
  double v386; // xmm4_8
  double v387; // xmm6_8
  double v388; // xmm9_8
  double v389; // xmm10_8
  float v390; // xmm3_4
  float v391; // xmm5_4
  int v392; // xmm0_4
  int v393; // xmm1_4
  float v394; // xmm5_4
  float v395; // xmm3_4
  float v396; // xmm0_4
  float v397; // xmm2_4
  float v398; // xmm5_4
  double v399; // xmm0_8
  int v400; // xmm1_4
  __int64 v401; // xmm6_8
  double v402; // xmm0_8
  float v403; // xmm7_4
  float v404; // xmm5_4
  float v405; // xmm5_4
  float v406; // xmm5_4
  float v407; // xmm0_4
  float v408; // xmm3_4
  float v409; // xmm1_4
  float v410; // xmm4_4
  double v411; // xmm0_8
  float v412; // xmm1_4
  float v413; // xmm6_4
  float v414; // xmm8_4
  float v415; // xmm6_4
  float v416; // xmm4_4
  float v417; // xmm0_4
  __int64 v418; // xmm7_8
  float v419; // xmm4_4
  float v420; // xmm4_4
  float v421; // xmm4_4
  float v422; // xmm9_4
  float v423; // xmm0_4
  float v424; // xmm7_4
  float v425; // xmm8_4
  float v426; // xmm8_4
  float v427; // xmm8_4
  int v428; // xmm5_4
  __int64 v429; // xmm6_8
  double v430; // xmm0_8
  float v431; // xmm7_4
  float v432; // xmm5_4
  float v433; // xmm5_4
  float v434; // xmm5_4
  float v435; // xmm0_4
  float v436; // xmm3_4
  float v437; // xmm1_4
  float v438; // xmm4_4
  double v439; // xmm0_8
  float v440; // xmm1_4
  float v441; // xmm6_4
  float v442; // xmm8_4
  float v443; // xmm6_4
  float v444; // xmm4_4
  float v445; // xmm0_4
  __int64 v446; // xmm7_8
  float v447; // xmm4_4
  float v448; // xmm4_4
  float v449; // xmm4_4
  float v450; // xmm9_4
  float v451; // xmm0_4
  float v452; // xmm7_4
  float v453; // xmm8_4
  float v454; // xmm8_4
  float v455; // xmm8_4
  int v456; // xmm5_4
  __int64 v457; // xmm6_8
  double v458; // xmm0_8
  float v459; // xmm7_4
  float v460; // xmm5_4
  float v461; // xmm5_4
  float v462; // xmm5_4
  float v463; // xmm0_4
  float v464; // xmm3_4
  float v465; // xmm1_4
  float v466; // xmm4_4
  double v467; // xmm0_8
  float v468; // xmm1_4
  float v469; // xmm6_4
  float v470; // xmm8_4
  float v471; // xmm6_4
  float v472; // xmm4_4
  float v473; // xmm0_4
  __int64 v474; // xmm7_8
  float v475; // xmm4_4
  float v476; // xmm4_4
  float v477; // xmm4_4
  float v478; // xmm9_4
  float v479; // xmm0_4
  float v480; // xmm7_4
  float v481; // xmm8_4
  float v482; // xmm8_4
  float v483; // xmm8_4
  int v484; // xmm5_4
  __int64 v485; // xmm6_8
  double v486; // xmm0_8
  float v487; // xmm7_4
  float v488; // xmm5_4
  float v489; // xmm5_4
  float v490; // xmm5_4
  float v491; // xmm0_4
  float v492; // xmm3_4
  float v493; // xmm1_4
  float v494; // xmm4_4
  double v495; // xmm0_8
  float v496; // xmm1_4
  float v497; // xmm6_4
  float v498; // xmm8_4
  float v499; // xmm6_4
  float v500; // xmm4_4
  float v501; // xmm0_4
  __int64 v502; // xmm7_8
  float v503; // xmm4_4
  float v504; // xmm4_4
  float v505; // xmm4_4
  float v506; // xmm8_4
  float v507; // xmm0_4
  float v508; // xmm7_4
  float v509; // xmm0_4
  float v510; // xmm15_4
  int v511; // xmm5_4
  int v512; // xmm6_4
  float v513; // xmm2_4
  float v514; // xmm5_4
  float v515; // xmm2_4
  float v516; // xmm4_4
  float v517; // xmm5_4
  float v518; // xmm1_4
  float v519; // xmm5_4
  float v520; // xmm3_4
  float v521; // xmm4_4
  __int64 result; // rax
  int v523; // [rsp+D0h] [rbp+8h]
  float v524; // [rsp+E0h] [rbp+18h]

  v2 = *(float *)(a1 + 73904);
  v523 = 0;
  if ( *(float *)(a1 + 101728) == 1.0 )
  {
    v523 = *(_DWORD *)(a1 + 73904);
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
    v59 = v59 * dword_18098AD3C[v63];
    goto LABEL_38;
  }
  if ( v63 < 0 )
  {
    v59 = v59 * dword_18098ACC0[~v63];
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
    v59 = v59 * dword_18098AD3C[v66];
    goto LABEL_46;
  }
  if ( v66 < 0 )
  {
    v59 = v59 * dword_18098ACC0[~v66];
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
  v87 = *(unsigned int *)(a1 + 75712);
  *(float *)(a1 + 75072) = v86;
  *(float *)&v87 = fminf(*(float *)&v87, v83 * 0.000015258789);
  v88 = (float)((float)(1.0 - v78) * *(float *)(a1 + 75504)) + v78;
  if ( v88 >= -1.0 )
    v89 = fminf(v88, 1.0);
  else
    v89 = -1.0;
  v90 = *(float *)&v87 * *(float *)(a1 + 75728);
  v91 = v80 - v86;
  *(float *)(a1 + 75248) = v90;
  v92 = v90 + v81;
  if ( v91 < 0.0 )
    v89 = 0.0;
  v93 = *(float *)(a1 + 75456);
  v94 = *(float *)(a1 + 75008);
  *(float *)(a1 + 75088) = v89;
  v95 = v89 + *(float *)(a1 + 75856);
  if ( v91 >= 0.0 )
    v93 = 1.0;
  v96 = v95 * *(float *)(a1 + 75840);
  *(float *)&v87 = (float)(v92 * v93) * *(float *)(a1 + 75472);
  if ( v96 <= 0.0 )
    v97 = 0.0;
  else
    v97 = v96;
  v98 = v97;
  v99 = (float)((float)(v94 - *(float *)(a1 + 75168)) * *(float *)(a1 + 76048)) + *(float *)(a1 + 75168);
  *(float *)(a1 + 75152) = v99;
  *(float *)(a1 + 75056) = v98;
  v524 = *(float *)(a1 + 75136);
  v100 = (float)((float)((float)(v99 * *(float *)(a1 + 76032)) * *(float *)(a1 + 75648))
               - (float)(v94 * *(float *)(a1 + 75648)))
       + v94;
  if ( *(float *)&v87 <= 1.0 )
  {
    if ( *(float *)&v87 < -1.0 )
      *(float *)&v87 = fmodf(*(float *)&v87 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v87 = fmodf(*(float *)&v87 + 1.0, 2.0) - 1.0;
  }
  v101 = *(float *)(a1 + 75200);
  *(_DWORD *)(a1 + 75120) = v87;
  v102 = *(float *)&v87 + *(float *)(a1 + 75872);
  *(float *)(a1 + 74992) = v100 * *(float *)(a1 + 76016);
  if ( v524 < 0.0 && *(float *)&v87 > 0.0 )
    v101 = v94;
  if ( v102 <= 1.0 )
  {
    if ( v102 < -1.0 )
      v102 = fmodf(v102 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v102 = fmodf(v102 + 1.0, 2.0) - 1.0;
  }
  *(float *)(a1 + 75184) = v101;
  v103 = v101 * *(float *)(a1 + 76000);
  v104 = (float)(v102 * *(float *)(a1 + 75936)) + *(float *)(a1 + 76064);
  *(float *)(a1 + 75264) = v104;
  *(float *)(a1 + 75344) = v103;
  HIDWORD(v105) = HIDWORD(v87);
  *(float *)&v105 = *(float *)&v87 + *(float *)(a1 + 75904);
  *(float *)(a1 + 75280) = -v104;
  if ( *(float *)&v105 <= 1.0 )
  {
    if ( *(float *)&v105 < -1.0 )
      *(float *)&v105 = fmodf(*(float *)&v105 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v105 = fmodf(*(float *)&v105 + 1.0, 2.0) - 1.0;
  }
  v106 = *(float *)&v87 + *(float *)(a1 + 75888);
  if ( v106 <= 1.0 )
  {
    if ( v106 < -1.0 )
      v106 = fmodf(v106 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v106 = fmodf(v106 + 1.0, 2.0) - 1.0;
  }
  v107 = sub_180368FC0(v105).m128_f32[0];
  v108 = v106 + *(float *)(a1 + 76080);
  v109 = v107 * *(float *)(a1 + 75968);
  if ( v108 >= 0.0 )
  {
    if ( v108 > 0.0 )
      v108 = 1.0;
  }
  else
  {
    v108 = -1.0;
  }
  v110 = *(float *)&v87 + *(float *)(a1 + 75920);
  *(float *)(a1 + 75312) = v109;
  *(float *)(a1 + 75408) = v108;
  v111 = (float)(v108 * *(float *)(a1 + 75952)) + *(float *)(a1 + 76096);
  if ( v110 <= 1.0 )
  {
    if ( v110 < -1.0 )
      v110 = fmodf(v110 - 1.0, 2.0) + 1.0;
  }
  else
  {
    v110 = fmodf(v110 + 1.0, 2.0) - 1.0;
  }
  v112 = fabs(v110);
  *(float *)(a1 + 75296) = v111;
  v113 = *(float *)(a1 + 75552);
  v114 = (float)((float)(*(float *)(a1 + 75616) * *(float *)(a1 + 75344))
               + (float)(*(float *)(a1 + 75584) * *(float *)(a1 + 75264)))
       + (float)(*(float *)(a1 + 75600) * *(float *)(a1 + 75280));
  v115 = (float)((float)((float)((float)(v112 * (float)((float)(v112 * v112) * v112)) * *(float *)(a1 + 75808))
                       + (float)((float)((float)((float)(v112 * v112) * v112) * *(float *)(a1 + 75792))
                               + (float)((float)((float)(v112 * *(float *)(a1 + 75760)) + *(float *)(a1 + 75744))
                                       + (float)((float)(v112 * v112) * *(float *)(a1 + 75776)))))
               + *(float *)(a1 + 75824))
       * *(float *)(a1 + 75984);
  *(float *)(a1 + 75328) = v115;
  v116 = (float)(v113 * *(float *)(a1 + 75312)) + v114;
  v117 = *(float *)(a1 + 75664);
  v118 = (float)((float)(*(float *)(a1 + 75520) * *(float *)(a1 + 75056)) - *(float *)(a1 + 75520)) + 1.0;
  v119 = (float)((float)(v116 + (float)(*(float *)(a1 + 75568) * *(float *)(a1 + 75296)))
               + (float)(v115 * *(float *)(a1 + 75536)))
       + (float)(*(float *)(a1 + 75632) * *(float *)(a1 + 74992));
  *(float *)(a1 + 75360) = v118;
  *(float *)(a1 + 75392) = v119;
  *(float *)(a1 + 75376) = (float)((float)(*(float *)(a1 + 75680) * *(float *)(a1 + 75024))
                                 + (float)(*(float *)(a1 + 75696) * *(float *)(a1 + 75040)))
                         + (float)((float)(v117 * v118) * v119);
  v120 = *(_DWORD *)(a1 + 75392);
  *(_DWORD *)(a1 + 76112) = *(_DWORD *)(a1 + 75408);
  *(_DWORD *)(a1 + 76128) = v120;
  if ( *(float *)(a1 + 75408) <= 0.0 )
    v121 = 0.0;
  else
    v121 = 1.0;
  if ( *(float *)(a1 + 76144) == 0.0 )
    v121 = 1.0;
  v122 = *(float *)(a1 + 74144) * v121;
  *(float *)(a1 + 76160) = v122;
  *(_DWORD *)(a1 + 76192) = *(_DWORD *)(a1 + 76176);
  *(_DWORD *)(a1 + 76240) = *(_DWORD *)(a1 + 76224);
  *(_DWORD *)(a1 + 76224) = *(_DWORD *)(a1 + 76208);
  *(_DWORD *)(a1 + 76272) = *(_DWORD *)(a1 + 76256);
  *(_DWORD *)(a1 + 76320) = *(_DWORD *)(a1 + 76304);
  if ( (float)(v122 + *(float *)(a1 + 76448)) >= 0.0 )
    v123 = 0.0;
  else
    v123 = 1.0;
  v124 = 1.0 - v123;
  v125 = (float)(1.0 - v123)
       * (float)((float)(*(float *)(a1 + 76480) * *(float *)(a1 + 76240)) + *(float *)(a1 + 76192));
  *(float *)(a1 + 76208) = v125;
  v126 = v125 + *(float *)(a1 + 76464);
  v127 = v125 - *(float *)(a1 + 76224);
  *(float *)(a1 + 76288) = (float)((float)(*(float *)(a1 + 76432) * *(float *)(a1 + 76544))
                                 - (float)(*(float *)(a1 + 76512) * *(float *)(a1 + 76432)))
                         + *(float *)(a1 + 76512);
  if ( v126 < 0.0 )
    v128 = 0.0;
  else
    v128 = 1.0;
  if ( v127 < 0.0 )
    v128 = 1.0 - v123;
  v129 = *(float *)(a1 + 76368);
  v130 = v124 * (float)(*(float *)(a1 + 76384) * *(float *)(a1 + 76512));
  *(float *)(a1 + 76224) = v128;
  v131 = *(float *)(a1 + 76272);
  v132 = (float)(v130 - (float)(*(float *)(a1 + 76528) * v124)) + *(float *)(a1 + 76528);
  v133 = v124 * (float)(1.0 - v128);
  v134 = (float)((float)(*(float *)(a1 + 76400) * 0.00390625) * v128) + (float)((float)(v129 * 0.00390625) * v133);
  if ( (float)(v132 - v131) > 0.0 )
    v132 = v131 + *(float *)(a1 + 76288);
  v135 = *(float *)(a1 + 76192);
  v136 = fminf(*(float *)(a1 + 76512), v132);
  *(float *)(a1 + 76256) = v136;
  v137 = *(float *)(a1 + 76416);
  v138 = (float)((float)(v133 * *(float *)(a1 + 76496)) + (float)(v128 * v136)) - v135;
  v139 = (float)((float)(*(float *)(a1 + 76560) * v134) - (float)(*(float *)(a1 + 76560) * *(float *)(a1 + 76320)))
       + *(float *)(a1 + 76320);
  *(float *)(a1 + 76304) = v139;
  v140 = (float)((float)((float)((float)((float)(v137 * 0.00390625) * v123) - (float)(v123 * v139)) + v139) * v138)
       + v135;
  *(float *)(a1 + 76176) = v140;
  v141 = (float)(v140 * *(float *)(a1 + 76576)) * *(float *)(a1 + 76592);
  v142 = v141 * *(float *)(a1 + 76608);
  *(float *)(a1 + 76336) = v141;
  *(float *)(a1 + 76352) = v142;
  if ( *(float *)(a1 + 75408) <= 0.0 )
    v143 = 0.0;
  else
    v143 = 1.0;
  if ( *(float *)(a1 + 76624) == 0.0 )
    v143 = 1.0;
  v144 = *(float *)(a1 + 74144) * v143;
  *(float *)(a1 + 76640) = v144;
  *(_DWORD *)(a1 + 76672) = *(_DWORD *)(a1 + 76656);
  *(_DWORD *)(a1 + 76720) = *(_DWORD *)(a1 + 76704);
  *(_DWORD *)(a1 + 76704) = *(_DWORD *)(a1 + 76688);
  *(_DWORD *)(a1 + 76752) = *(_DWORD *)(a1 + 76736);
  *(_DWORD *)(a1 + 76800) = *(_DWORD *)(a1 + 76784);
  if ( (float)(v144 + *(float *)(a1 + 76928)) >= 0.0 )
    v145 = 0.0;
  else
    v145 = 1.0;
  v146 = 1.0 - v145;
  v147 = (float)(1.0 - v145)
       * (float)((float)(*(float *)(a1 + 76960) * *(float *)(a1 + 76720)) + *(float *)(a1 + 76672));
  *(float *)(a1 + 76688) = v147;
  v148 = v147 + *(float *)(a1 + 76944);
  v149 = v147 - *(float *)(a1 + 76704);
  *(float *)(a1 + 76768) = (float)((float)(*(float *)(a1 + 76912) * *(float *)(a1 + 77024))
                                 - (float)(*(float *)(a1 + 76992) * *(float *)(a1 + 76912)))
                         + *(float *)(a1 + 76992);
  if ( v148 < 0.0 )
    v150 = 0.0;
  else
    v150 = 1.0;
  if ( v149 < 0.0 )
    v150 = 1.0 - v145;
  v151 = *(float *)(a1 + 76864) * *(float *)(a1 + 76992);
  v152 = *(float *)(a1 + 76848);
  *(float *)(a1 + 76704) = v150;
  v153 = *(float *)(a1 + 76752);
  v154 = (float)((float)(v146 * v151) - (float)(*(float *)(a1 + 77008) * v146)) + *(float *)(a1 + 77008);
  v155 = v146 * (float)(1.0 - v150);
  v156 = (float)((float)(*(float *)(a1 + 76880) * 0.00390625) * v150) + (float)((float)(v152 * 0.00390625) * v155);
  if ( (float)(v154 - v153) > 0.0 )
    v154 = v153 + *(float *)(a1 + 76768);
  v157 = *(float *)(a1 + 76672);
  v158 = fminf(*(float *)(a1 + 76992), v154);
  *(float *)(a1 + 76736) = v158;
  v159 = (float)(*(float *)(a1 + 76896) * 0.00390625) * v145;
  v160 = (float)((float)(v155 * *(float *)(a1 + 76976)) + (float)(v150 * v158)) - v157;
  v161 = (float)((float)(*(float *)(a1 + 77040) * v156) - (float)(*(float *)(a1 + 77040) * *(float *)(a1 + 76800)))
       + *(float *)(a1 + 76800);
  *(float *)(a1 + 76784) = v161;
  v162 = (float)((float)((float)(v159 - (float)(v145 * v161)) + v161) * v160) + v157;
  *(float *)(a1 + 76656) = v162;
  v163 = (float)(v162 * *(float *)(a1 + 77056)) * *(float *)(a1 + 77072);
  v164 = v163 * *(float *)(a1 + 77088);
  *(float *)(a1 + 76816) = v163;
  *(float *)(a1 + 76832) = v164;
  *(_DWORD *)(a1 + 77120) = *(_DWORD *)(a1 + 77104);
  *(_DWORD *)(a1 + 77152) = *(_DWORD *)(a1 + 77136);
  v165 = *(float *)(a1 + 74336);
  v166 = *(float *)(a1 + 74464);
  *(_DWORD *)(a1 + 77216) = *(_DWORD *)(a1 + 77200);
  v167 = (float)(v166 * *(float *)(a1 + 77184)) + (float)(v165 * *(float *)(a1 + 77168));
  *(float *)(a1 + 77200) = v167;
  v168 = *(float *)(a1 + 75376);
  v169 = *(_DWORD *)(a1 + 76336);
  v170 = *(_DWORD *)(a1 + 76816);
  v171 = *(_DWORD *)(a1 + 74336);
  *(_DWORD *)(a1 + 77264) = *(_DWORD *)(a1 + 77136);
  *(_DWORD *)(a1 + 77280) = v171;
  v172 = *(float *)(a1 + 77600);
  *(_DWORD *)(a1 + 77232) = v169;
  *(_DWORD *)(a1 + 77248) = v170;
  v173 = *(float *)(a1 + 77568);
  v174 = v168 * v172;
  v175 = v172 * *(float *)(a1 + 75392);
  *(float *)(a1 + 77296) = v175;
  v176 = *(float *)(a1 + 77696);
  v177 = *(float *)(a1 + 77440);
  v178 = v174 * *(float *)(a1 + 77616);
  v179 = *(float *)(a1 + 77632);
  v180 = (float)(v173 * v175) * *(float *)(a1 + 77584);
  *(float *)(a1 + 77328) = v180;
  v181 = *(float *)(a1 + 77456);
  v182 = (float)((float)((float)(v177 * *(float *)(a1 + 77264)) - (float)(v176 * v177)) + v176) * *(float *)(a1 + 77712);
  *(float *)(a1 + 77344) = v182;
  v183 = (float)((float)(v179 * v178) + v180) + (float)(v181 * v182);
  v184 = *(float *)(a1 + 77296);
  v185 = *(_DWORD *)(a1 + 77424);
  *(float *)(a1 + 77360) = (float)((float)((float)((float)((float)((float)(*(float *)(a1 + 77664)
                                                                         * *(float *)(a1 + 77248))
                                                                 + (float)(*(float *)(a1 + 77648)
                                                                         * *(float *)(a1 + 77232)))
                                                         * *(float *)(a1 + 77680))
                                                 + v183)
                                         + v167)
                                 + *(float *)(a1 + 77536))
                         + *(float *)(a1 + 77552);
  *(_DWORD *)(a1 + 77376) = v185;
  v186 = (float)(*(float *)(a1 + 77328) + *(float *)(a1 + 77280)) + *(float *)(a1 + 77344);
  *(float *)(a1 + 77392) = (float)((float)((float)((float)((float)((float)(v184 * *(float *)(a1 + 77744))
                                                                 + *(float *)(a1 + 77760))
                                                         * *(float *)(a1 + 77472))
                                                 + (float)(*(float *)(a1 + 77488) * *(float *)(a1 + 77232)))
                                         + (float)(*(float *)(a1 + 77504) * *(float *)(a1 + 77248)))
                                 + *(float *)(a1 + 77520))
                         * *(float *)(a1 + 77728);
  *(float *)(a1 + 77408) = v186;
  v187 = *(_DWORD *)(a1 + 77792);
  *(_DWORD *)(a1 + 77824) = *(_DWORD *)(a1 + 77776);
  *(_DWORD *)(a1 + 77840) = v187;
  *(_DWORD *)(a1 + 77856) = *(_DWORD *)(a1 + 77808);
  v188 = *(float *)(a1 + 84432);
  *(_DWORD *)(a1 + 77904) = *(_DWORD *)(a1 + 77888);
  v189 = *(float *)(a1 + 77872);
  *(float *)(a1 + 77888) = v189;
  v190 = (float)(v189 * *(float *)(a1 + 77920)) + *(float *)(a1 + 77904);
  *(float *)(a1 + 77888) = v190;
  v191 = (float)(v189 * *(float *)(a1 + 77936)) + v190;
  v192 = v190 * *(float *)(a1 + 77984);
  v193 = v188 - v191;
  v194 = (float)(v193 * *(float *)(a1 + 77920)) + v189;
  *(float *)(a1 + 77872) = v194;
  *(float *)(a1 + 77904) = (float)((float)(v193 * *(float *)(a1 + 77952)) + v192)
                         + (float)(v194 * *(float *)(a1 + 77968));
  *(_DWORD *)(a1 + 80016) = *(_DWORD *)(a1 + 80000);
  v195 = *(float *)(a1 + 80032);
  *(float *)(a1 + 80048) = v195;
  v196 = v195 * *(float *)(a1 + 77120);
  v197 = *(float *)(a1 + 80016) * *(float *)(a1 + 77904);
  *(float *)(a1 + 80064) = v196;
  *(float *)(a1 + 80080) = v197;
  *(_DWORD *)(a1 + 80144) = *(_DWORD *)(a1 + 80128);
  *(float *)(a1 + 80128) = (float)(v197 * *(float *)(a1 + 80112)) + (float)(v196 * *(float *)(a1 + 80096));
  *(_DWORD *)(a1 + 80176) = *(_DWORD *)(a1 + 80160);
  *(_DWORD *)(a1 + 80208) = *(_DWORD *)(a1 + 80192);
  *(_DWORD *)(a1 + 80240) = *(_DWORD *)(a1 + 80224);
  *(_DWORD *)(a1 + 80272) = *(_DWORD *)(a1 + 80256);
  v198 = (float)((float)(*(float *)(a1 + 80304) * *(float *)(a1 + 80160))
               - (float)(*(float *)(a1 + 80320) * *(float *)(a1 + 80304)))
       + *(float *)(a1 + 80320);
  v199 = (float)((float)((float)((float)(v198 * v198) * v198) * v198) * *(float *)(a1 + 80400))
       + (float)((float)((float)((float)(v198 * v198) * v198) * *(float *)(a1 + 80384))
               + (float)((float)((float)(v198 * *(float *)(a1 + 80352)) + *(float *)(a1 + 80336))
                       + (float)((float)(v198 * v198) * *(float *)(a1 + 80368))));
  if ( v199 <= 0.0 )
    v200 = 0.0;
  else
    v200 = v199;
  v201 = v200;
  if ( v201 < 1.0 )
    v42 = v201;
  v202 = v42;
  *(float *)(a1 + 80288) = v202;
  *(_DWORD *)(a1 + 80432) = *(_DWORD *)(a1 + 80416);
  v203 = *(float *)(a1 + 80448);
  *(float *)(a1 + 80464) = v203;
  v204 = *(float *)(a1 + 80480);
  *(float *)(a1 + 80496) = v204;
  *(float *)(a1 + 80480) = (float)((float)(v203 - v204) * *(float *)(a1 + 80512)) + v204;
  v205 = *(float *)(a1 + 74336);
  v206 = *(float *)(a1 + 74464);
  *(_DWORD *)(a1 + 80576) = *(_DWORD *)(a1 + 80560);
  *(float *)(a1 + 80560) = (float)(v206 * *(float *)(a1 + 80544)) + (float)(v205 * *(float *)(a1 + 80528));
  *(_DWORD *)(a1 + 80624) = *(_DWORD *)(a1 + 80592);
  v207 = *(float *)(a1 + 80608);
  *(float *)(a1 + 80640) = v207;
  v208 = *(float *)(a1 + 76336)
       + (float)((float)(*(float *)(a1 + 80624) * *(float *)(a1 + 76816))
               - (float)(*(float *)(a1 + 80624) * *(float *)(a1 + 76336)));
  *(float *)(a1 + 80656) = (float)((float)(v207 * *(float *)(a1 + 80224)) - (float)(v207 * v208)) + v208;
  v209 = *(float *)(a1 + 75376);
  v210 = *(float *)(a1 + 80672);
  *(float *)(a1 + 80688) = v210;
  v211 = v209 - v210;
  v212 = (float)(v211 * *(float *)(a1 + 80704)) + v210;
  v213 = *(float *)(a1 + 80736);
  *(float *)(a1 + 80672) = v212;
  *(float *)(a1 + 80688) = (float)(v211 * *(float *)(a1 + 80720)) + (float)(v213 * v212);
  v214 = *(float *)(a1 + 80752);
  v215 = *(float *)(a1 + 75392);
  *(float *)(a1 + 80768) = v214;
  v216 = v215 - v214;
  v217 = (float)(v216 * *(float *)(a1 + 80784)) + v214;
  v218 = *(float *)(a1 + 80816);
  *(float *)(a1 + 80752) = v217;
  v219 = (float)(v216 * *(float *)(a1 + 80800)) + (float)(v218 * v217);
  *(float *)(a1 + 80768) = v219;
  v220 = *(float *)(a1 + 80688);
  v221 = *(float *)(a1 + 80656);
  v222 = *(float *)(a1 + 80560);
  v225 = (__m128)*(unsigned int *)(a1 + 80192);
  *(_DWORD *)(a1 + 80832) = *(_DWORD *)(a1 + 80480);
  *(_DWORD *)(a1 + 80848) = v225.m128_i32[0];
  v223 = *(float *)(a1 + 80880);
  v224 = *(float *)(a1 + 80896) * *(float *)(a1 + 80256);
  v225.m128_f32[0] = (float)((float)((float)((float)((float)(v225.m128_f32[0] * *(float *)(a1 + 80912))
                                                   - (float)(*(float *)(a1 + 81040) * *(float *)(a1 + 80912)))
                                           + *(float *)(a1 + 81040))
                                   * *(float *)(a1 + 81056))
                           + (float)((float)((float)(*(float *)(a1 + 81024) + *(float *)(a1 + 80832))
                                           * *(float *)(a1 + 81088))
                                   * *(float *)(a1 + 81008)))
                   + (float)((float)((float)((float)((float)((float)(v224
                                                                   - (float)(*(float *)(a1 + 80896)
                                                                           * (float)(v219 * v223)))
                                                           + (float)(v219 * v223))
                                                   * *(float *)(a1 + 80944))
                                           * *(float *)(a1 + 80960))
                                   + (float)((float)((float)(v224
                                                           - (float)(*(float *)(a1 + 80896) * (float)(v220 * v223)))
                                                   + (float)(v220 * v223))
                                           * *(float *)(a1 + 80928)))
                           + (float)((float)((float)(v222 + *(float *)(a1 + 81072)) * *(float *)(a1 + 80992))
                                   + (float)(v221 * *(float *)(a1 + 80976))));
  *(_DWORD *)(a1 + 80864) = v225.m128_i32[0];
  v226 = *(float *)(a1 + 80288);
  v227 = *(float *)(a1 + 80432);
  *(_DWORD *)(a1 + 81168) = *(_DWORD *)(a1 + 81152);
  v228 = *(float *)(a1 + 81136);
  *(float *)(a1 + 81152) = v228;
  if ( *(float *)(a1 + 81216) == 1.0 )
  {
    v229 = *(float *)(a1 + 81168)
         + (float)((float)(*(float *)(a1 + 81296) * v228) - (float)(*(float *)(a1 + 81296) * *(float *)(a1 + 81168)));
    *(float *)(a1 + 81152) = v229;
    v230 = (float)(v229 * *(float *)(a1 + 81280)) + *(float *)(a1 + 81184);
    *(float *)(a1 + 81136) = sub_180368D60(-v228);
    v231 = (float)(1.0 - v227) * *(float *)(a1 + 81312);
    *(float *)(a1 + 81120) = (float)(v227 * *(float *)(a1 + 81376)) + *(float *)(a1 + 81200);
    v225.m128_f32[0] = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v225.m128_f32[0] * *(float *)(a1 + 81264))
                                                         + (float)(v226 * *(float *)(a1 + 81232)))
                                                 + v230)
                                         + fminf(*(float *)(a1 + 81328), v231))
                                 + *(float *)(a1 + 81248),
                                   *(float *)(a1 + 81344)),
                                 *(float *)(a1 + 81360))
                             * *(float *)(a1 + 81408))
                     + *(float *)(a1 + 81424);
    v232 = v225.m128_f32[0];
    v233 = (int)v225.m128_f32[0];
    if ( (int)v225.m128_f32[0] != 0x80000000 && (float)v233 != v225.m128_f32[0] )
      v232 = (float)(v233 - (_mm_movemask_ps(_mm_unpacklo_ps(v225, v225)) & 1));
    v234 = v225.m128_f32[0] - v232;
    v235 = (float)(v234 * v234) * 0.25;
    v236 = (float)(expf(v232)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v234 * *(float *)(a1 + 81616)) + *(float *)(a1 + 81600)) * v235) + (float)(v234 * *(float *)(a1 + 81584))) + *(float *)(a1 + 81568)) * v235) + (float)(v234 * *(float *)(a1 + 81552)))
                                                                                                 + *(float *)(a1 + 81536))
                                                                                         * v235)
                                                                                 + (float)(v234 * *(float *)(a1 + 81520)))
                                                                         + *(float *)(a1 + 81504))
                                                                 * v235)
                                                         + (float)(v234 * *(float *)(a1 + 81488)))
                                                 + *(float *)(a1 + 81472))
                                         * v235)
                                 + (float)(v234 * *(float *)(a1 + 81456)))
                         + 1.0))
         * *(float *)(a1 + 81440);
    v237 = v236 * v236;
    v238 = (float)((float)((float)((float)((float)((float)((float)((float)(v236 * v236) * *(float *)(a1 + 81776))
                                                         + *(float *)(a1 + 81744))
                                                 * (float)(v237 * v237))
                                         + (float)((float)((float)(v236 * v236) * *(float *)(a1 + 81712))
                                                 + *(float *)(a1 + 81680)))
                                 * (float)((float)((float)(v236 * v236) * v236) * (float)(v236 * v236)))
                         + (float)((float)((float)(v236 * v236) * v236) * *(float *)(a1 + 81648)))
                 + v236)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v236 * v236) * *(float *)(a1 + 81760))
                                                                 + *(float *)(a1 + 81728))
                                                         * (float)(v237 * v237))
                                                 + (float)((float)(v236 * v236) * *(float *)(a1 + 81696)))
                                         + *(float *)(a1 + 81664))
                                 * (float)(v237 * v237))
                         + (float)((float)(v236 * v236) * *(float *)(a1 + 81632)))
                 + 1.0);
    v239 = v238 / (float)(v238 + 1.0);
    *(float *)(a1 + 81104) = v239;
  }
  else
  {
    v239 = *(float *)(a1 + 81104);
  }
  v240 = *(float *)(a1 + 80128);
  v241 = *(float *)(a1 + 81120);
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
  v242 = *(float *)(a1 + 82560);
  *(float *)(a1 + 82576) = v242;
  if ( *(float *)(a1 + 82640) == 1.0 )
  {
    v243 = (float)((float)((float)(v241 * *(float *)(a1 + 82752)) + 1.0) * (float)(v240 * *(float *)(a1 + 82720)))
         + (float)((float)-v242 * *(float *)(a1 + 82704));
    *(float *)(a1 + 82560) = sub_180368D60(-v242);
    *(float *)(a1 + 82528) = v243;
    v244 = 1.0 - (float)(v239 + v239);
    v245 = 1.0 / (float)((float)((float)((float)(v239 * v239) * (float)(v239 * v239)) * v241) + 1.0);
    *(float *)(a1 + 82608) = v245;
    v246 = *(float *)(a1 + 82528);
    v247 = *(float *)(a1 + 82544);
    *(float *)(a1 + 82592) = v245 * v241;
    v248 = v247 * *(float *)(a1 + 82800);
    v249 = *(float *)(a1 + 81888);
    v250 = v246 * *(float *)(a1 + 82816);
    v251 = *(float *)(a1 + 81904);
    *(float *)(a1 + 82000) = v249;
    v252 = (float)((float)(v248 + v250) * v245)
         - (float)((float)((float)(v249 * *(float *)(a1 + 83104)) + (float)(v251 * *(float *)(a1 + 83120)))
                 * (float)(v245 * v241));
    if ( v252 >= -1.0 )
      v253 = fminf(v252, 1.0);
    else
      v253 = -1.0;
    v254 = v253 + (float)((float)((float)((float)(v253 * v253) * v253) * v253) * (float)(v253 * *(float *)(a1 + 82768)));
    *(float *)(a1 + 81920) = v254;
    v255 = *(float *)(a1 + 81824);
    v256 = (float)(v239 * (float)(v254 + *(float *)(a1 + 81808))) + (float)(v255 * v244);
    *(float *)(a1 + 81936) = v256;
    v257 = *(float *)(a1 + 81840);
    v258 = v239 * (float)(v256 + v255);
    v259 = v239 * (float)((float)((float)(v239 * v254) + (float)(v244 * v256)) + v256);
    v260 = v258 + (float)(v257 * v244);
    *(float *)(a1 + 81952) = v260;
    v261 = *(float *)(a1 + 81856);
    v262 = (float)(v239 * (float)(v260 + v257)) + (float)(v261 * v244);
    *(float *)(a1 + 81968) = v262;
    v263 = (float)((float)(v261 + v262) * v239) + (float)(v244 * *(float *)(a1 + 81872));
    *(float *)(a1 + 81984) = v263;
    v264 = (float)(v239
                 * (float)((float)((float)(v239 * (float)((float)(v259 + (float)(v244 * v260)) + v260))
                                 + (float)(v244 * v262))
                         + v262))
         + (float)(v244 * v263);
    v265 = (float)(*(float *)(a1 + 81968) * *(float *)(a1 + 82672)) + (float)(v263 * *(float *)(a1 + 82688));
    v266 = *(float *)(a1 + 82544);
    *(float *)(a1 + 82400) = v265 + (float)(*(float *)(a1 + 82656) * *(float *)(a1 + 81952));
    v267 = *(float *)(a1 + 82000);
    v268 = (float)((float)(v266 + *(float *)(a1 + 82528)) * *(float *)(a1 + 82832)) * *(float *)(a1 + 82608);
    *(float *)(a1 + 82000) = v264;
    v269 = v268
         - (float)((float)((float)(v264 * *(float *)(a1 + 83104)) + (float)(v267 * *(float *)(a1 + 83120)))
                 * *(float *)(a1 + 82592));
    if ( v269 >= -1.0 )
      v270 = fminf(v269, 1.0);
    else
      v270 = -1.0;
    v271 = v270 + (float)((float)((float)((float)(v270 * v270) * v270) * v270) * (float)(v270 * *(float *)(a1 + 82768)));
    v272 = *(float *)(a1 + 81920);
    *(float *)(a1 + 81920) = v271;
    v273 = *(float *)(a1 + 81936);
    v274 = (float)(v239 * (float)(v271 + v272)) + (float)(v273 * v244);
    *(float *)(a1 + 81936) = v274;
    v275 = *(float *)(a1 + 81952);
    v276 = v239 * (float)(v274 + v273);
    v277 = v239 * (float)((float)((float)(v239 * v271) + (float)(v244 * v274)) + v274);
    v278 = v276 + (float)(v275 * v244);
    *(float *)(a1 + 81952) = v278;
    v279 = *(float *)(a1 + 81968);
    v280 = (float)(v239 * (float)(v278 + v275)) + (float)(v279 * v244);
    *(float *)(a1 + 81968) = v280;
    v281 = (float)((float)(v279 + v280) * v239) + (float)(v244 * *(float *)(a1 + 81984));
    *(float *)(a1 + 81984) = v281;
    v282 = *(float *)(a1 + 82528);
    v283 = (float)(v239
                 * (float)((float)((float)(v239 * (float)((float)(v277 + (float)(v244 * v278)) + v278))
                                 + (float)(v244 * v280))
                         + v280))
         + (float)(v244 * v281);
    v284 = (float)(*(float *)(a1 + 81968) * *(float *)(a1 + 82672)) + (float)(v281 * *(float *)(a1 + 82688));
    v285 = *(float *)(a1 + 82544);
    *(float *)(a1 + 82272) = v284 + (float)(*(float *)(a1 + 82656) * *(float *)(a1 + 81952));
    v286 = *(float *)(a1 + 82000);
    v287 = (float)((float)(v285 * *(float *)(a1 + 82816)) + (float)(v282 * *(float *)(a1 + 82800)))
         * *(float *)(a1 + 82608);
    *(float *)(a1 + 82000) = v283;
    v288 = v287
         - (float)((float)((float)(v283 * *(float *)(a1 + 83104)) + (float)(v286 * *(float *)(a1 + 83120)))
                 * *(float *)(a1 + 82592));
    if ( v288 >= -1.0 )
      v289 = fminf(v288, 1.0);
    else
      v289 = -1.0;
    v290 = v289 + (float)((float)((float)((float)(v289 * v289) * v289) * v289) * (float)(v289 * *(float *)(a1 + 82768)));
    v291 = *(float *)(a1 + 81920);
    *(float *)(a1 + 81920) = v290;
    v292 = *(float *)(a1 + 81936);
    v293 = (float)(v239 * (float)(v290 + v291)) + (float)(v292 * v244);
    *(float *)(a1 + 81936) = v293;
    v294 = *(float *)(a1 + 81952);
    v295 = v239 * (float)(v293 + v292);
    v296 = v239 * (float)((float)((float)(v239 * v290) + (float)(v244 * v293)) + v293);
    v297 = v295 + (float)(v294 * v244);
    *(float *)(a1 + 81952) = v297;
    v298 = *(float *)(a1 + 81968);
    v299 = (float)(v239 * (float)(v297 + v294)) + (float)(v298 * v244);
    *(float *)(a1 + 81968) = v299;
    v300 = (float)((float)(v298 + v299) * v239) + (float)(v244 * *(float *)(a1 + 81984));
    *(float *)(a1 + 81984) = v300;
    v301 = (float)(v239
                 * (float)((float)((float)(v239 * (float)((float)(v296 + (float)(v244 * v297)) + v297))
                                 + (float)(v244 * v299))
                         + v299))
         + (float)(v244 * v300);
    v302 = (float)(*(float *)(a1 + 81968) * *(float *)(a1 + 82672)) + (float)(v300 * *(float *)(a1 + 82688));
    v303 = *(float *)(a1 + 82528);
    *(float *)(a1 + 82144) = v302 + (float)(*(float *)(a1 + 82656) * *(float *)(a1 + 81952));
    v304 = *(float *)(a1 + 82000);
    v305 = (float)(v303 * *(float *)(a1 + 82784)) * *(float *)(a1 + 82608);
    *(float *)(a1 + 81888) = v301;
    v306 = v305
         - (float)((float)((float)(v301 * *(float *)(a1 + 83104)) + (float)(v304 * *(float *)(a1 + 83120)))
                 * *(float *)(a1 + 82592));
    if ( v306 >= -1.0 )
      v307 = fminf(v306, 1.0);
    else
      v307 = -1.0;
    v308 = v307 + (float)((float)((float)((float)(v307 * v307) * v307) * v307) * (float)(v307 * *(float *)(a1 + 82768)));
    *(float *)(a1 + 81792) = v308;
    v309 = *(float *)(a1 + 81936);
    v310 = (float)(v239 * (float)(v308 + *(float *)(a1 + 81920))) + (float)(v309 * v244);
    *(float *)(a1 + 81808) = v310;
    v311 = *(float *)(a1 + 81952);
    v312 = v239 * (float)(v310 + v309);
    v313 = v239 * (float)((float)((float)(v239 * v308) + (float)(v244 * v310)) + v310);
    v314 = v312 + (float)(v311 * v244);
    *(float *)(a1 + 81824) = v314;
    v315 = *(float *)(a1 + 81968);
    v316 = (float)(v239 * (float)(v314 + v311)) + (float)(v315 * v244);
    *(float *)(a1 + 81840) = v316;
    v317 = (float)((float)(v315 + v316) * v239) + (float)(v244 * *(float *)(a1 + 81984));
    v318 = v239
         * (float)((float)((float)(v239 * (float)((float)(v313 + (float)(v244 * v314)) + v314)) + (float)(v244 * v316))
                 + v316);
    *(float *)(a1 + 81856) = v317;
    v319 = *(float *)(a1 + 81824);
    *(float *)(a1 + 81872) = v318 + (float)(v244 * v317);
    v320 = *(float *)(a1 + 82080);
    v321 = (float)((float)(v317 * *(float *)(a1 + 82688)) + (float)(*(float *)(a1 + 82672) * *(float *)(a1 + 81840)))
         + (float)(v319 * *(float *)(a1 + 82656));
    *(float *)(a1 + 82016) = v321;
    v322 = (float)(v321 + *(float *)(a1 + 82512)) * *(float *)(a1 + 82848);
    v323 = (float)(*(float *)(a1 + 82272) + *(float *)(a1 + 82256)) * *(float *)(a1 + 82880);
    v324 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v320 + *(float *)(a1 + 82448)) * *(float *)(a1 + 83088)) + (float)((float)(*(float *)(a1 + 82208) + *(float *)(a1 + 82320)) * *(float *)(a1 + 83072))) + (float)((float)(*(float *)(a1 + 82336) + *(float *)(a1 + 82192)) * *(float *)(a1 + 83056))) + (float)((float)(*(float *)(a1 + 82064) + *(float *)(a1 + 82464)) * *(float *)(a1 + 83040))) + (float)((float)(*(float *)(a1 + 82432) + *(float *)(a1 + 82096)) * *(float *)(a1 + 83024)))
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
                                 + v323)
                         + (float)((float)(*(float *)(a1 + 82384) + *(float *)(a1 + 82144)) * *(float *)(a1 + 82864)))
                 + v322)
         * *(float *)(a1 + 82736);
    *(float *)(a1 + 82624) = v324;
  }
  *(_DWORD *)(a1 + 83152) = *(_DWORD *)(a1 + 83136);
  v325 = *(_DWORD *)(a1 + 83184);
  *(_DWORD *)(a1 + 83216) = *(_DWORD *)(a1 + 83168);
  *(_DWORD *)(a1 + 83232) = v325;
  *(_DWORD *)(a1 + 83248) = *(_DWORD *)(a1 + 83200);
  v326 = *(float *)(a1 + 83264);
  *(float *)(a1 + 83280) = v326;
  v327 = *(float *)(a1 + 83296);
  *(float *)(a1 + 83312) = v327;
  v328 = (float)((float)(v326 - v327) * *(float *)(a1 + 83328)) + v327;
  *(float *)(a1 + 83296) = v328;
  v329 = (float)((float)(v328 * *(float *)(a1 + 83232)) - (float)(*(float *)(a1 + 83232) * *(float *)(a1 + 83248)))
       + *(float *)(a1 + 83248);
  *(float *)(a1 + 83344) = v329;
  v330 = *(float *)(a1 + 83360);
  *(float *)(a1 + 83376) = v330;
  v331 = (float)((float)(*(float *)(a1 + 83392) * v329) - (float)(*(float *)(a1 + 83392) * v330)) + v330;
  if ( v331 <= 0.0 )
    v332 = 0.0;
  else
    v332 = v331;
  v333 = v332;
  *(float *)(a1 + 83360) = v333;
  v334 = *(float *)(a1 + 83408);
  *(float *)(a1 + 83424) = v334;
  v335 = *(float *)(a1 + 83440);
  *(float *)(a1 + 83456) = v335;
  v336 = (float)((float)(*(float *)(a1 + 83472) * v334) - (float)(*(float *)(a1 + 83472) * v335)) + v335;
  if ( v336 <= 0.0 )
    v337 = 0.0;
  else
    v337 = v336;
  v338 = v337;
  *(float *)(a1 + 83440) = v338;
  v339 = *(float *)(a1 + 83488);
  v340 = *(float *)(a1 + 74144);
  *(float *)(a1 + 83504) = v339;
  v341 = v339 * *(float *)(a1 + 83584);
  v342 = v339 + *(float *)(a1 + 83568);
  if ( v341 >= -1.0 )
    v343 = fminf(v341, 1.0);
  else
    v343 = -1.0;
  if ( (float)(v339 + *(float *)(a1 + 83536)) >= 0.0 )
    v342 = (float)((float)(*(float *)(a1 + 83552) * v340) - (float)(*(float *)(a1 + 83552) * v339)) + v339;
  v344 = (float)((float)(v343 * *(float *)(a1 + 83600)) - (float)(*(float *)(a1 + 83616) * v343))
       + *(float *)(a1 + 83616);
  v345 = (float)((float)(v344 * v340) - (float)(v344 * v339)) + v339;
  if ( v340 != 0.0 )
    v345 = v342;
  *(float *)(a1 + 83520) = v345;
  *(float *)(a1 + 83488) = v345;
  v346 = *(float *)(a1 + 82624);
  v347 = *(float *)(a1 + 76336);
  v348 = *(float *)(a1 + 80432);
  v349 = *(_DWORD *)(a1 + 76816);
  v350 = *(_DWORD *)(a1 + 83136);
  *(_DWORD *)(a1 + 83696) = *(_DWORD *)(a1 + 83680);
  *(_DWORD *)(a1 + 83728) = *(_DWORD *)(a1 + 83712);
  *(_DWORD *)(a1 + 83632) = v349;
  *(_DWORD *)(a1 + 83648) = v350;
  v351 = *(float *)(a1 + 83696);
  v352 = *(float *)(a1 + 83760);
  *(float *)(a1 + 83664) = v348 * *(float *)(a1 + 83920);
  v353 = v346 - v351;
  v354 = *(float *)(a1 + 83792);
  v355 = (float)(v347 * *(float *)(a1 + 83776)) + (float)(v352 * *(float *)(a1 + 83520));
  v356 = v351 + (float)((float)(v346 - v351) * *(float *)(a1 + 83824));
  *(float *)(a1 + 83680) = v356;
  v357 = (float)(v353 * *(float *)(a1 + 83936)) + (float)(v356 * *(float *)(a1 + 83952));
  v358 = (float)((float)(*(float *)(a1 + 83808) * *(float *)(a1 + 83648))
               - (float)(*(float *)(a1 + 83808) * (float)(v355 + (float)(v354 * *(float *)(a1 + 83632)))))
       + (float)(v355 + (float)(v354 * *(float *)(a1 + 83632)));
  v359 = *(float *)(a1 + 83840);
  v360 = v358 * *(float *)(a1 + 83888);
  v361 = v346 * (float)(1.0 - v359);
  if ( v360 <= 0.0 )
    v362 = 0.0;
  else
    v362 = v360;
  v363 = *(float *)(a1 + 83856);
  v364 = v362;
  v365 = v364 * *(float *)(a1 + 83904);
  v366 = (float)((float)(v359 * v357) + v361) * (float)(*(float *)(a1 + 83664) + 1.0);
  v367 = *(float *)(a1 + 83872) * v366;
  v368 = *(float *)(a1 + 83728)
       + (float)((float)(*(float *)(a1 + 83968) * v366) - (float)(*(float *)(a1 + 83968) * *(float *)(a1 + 83728)));
  *(float *)(a1 + 83712) = v368;
  v369 = (float)((float)((float)(v363 * v368) + v367) * v365) * *(float *)(a1 + 83984);
  *(float *)(a1 + 83744) = v369;
  *(_DWORD *)(a1 + 84032) = *(_DWORD *)(a1 + 84016);
  *(_DWORD *)(a1 + 84016) = *(_DWORD *)(a1 + 84000);
  v370 = *(float *)(a1 + 84032);
  v371 = *(float *)(a1 + 84048);
  v372 = v369 - v370;
  *(float *)(a1 + 84000) = v372;
  *(float *)(a1 + 84016) = (float)(v371 * v372) + v370;
  v373 = *(float *)(a1 + 84000);
  v374 = *(float *)(a1 + 83216);
  *(_DWORD *)(a1 + 84112) = *(_DWORD *)(a1 + 84096);
  *(_DWORD *)(a1 + 84096) = *(_DWORD *)(a1 + 84080);
  *(_DWORD *)(a1 + 84080) = *(_DWORD *)(a1 + 84064);
  *(float *)(a1 + 84064) = v373;
  v375 = (float)((float)(*(float *)(a1 + 84080) * *(float *)(a1 + 84160)) + (float)(v373 * *(float *)(a1 + 84144)))
       + (float)(*(float *)(a1 + 84176) * *(float *)(a1 + 84096));
  v376 = (float)((float)(*(float *)(a1 + 84080) * *(float *)(a1 + 84208)) + (float)(v373 * *(float *)(a1 + 84192)))
       + (float)(*(float *)(a1 + 84224) * *(float *)(a1 + 84112));
  if ( v374 <= 0.0 )
    v377 = 0.0;
  else
    v377 = v374;
  *(float *)(a1 + 84080) = v375;
  v378 = v377;
  *(float *)(a1 + 84096) = v376;
  v379 = (float)((float)(v378 * v375) - (float)(v378 * v373)) + v373;
  if ( v374 < -0.0 )
    v19 = (float)-v374;
  v380 = v19;
  v381 = v373 + (float)((float)(v380 * v376) - (float)(v380 * v373));
  if ( v374 >= 0.0 )
    v381 = v379;
  *(float *)(a1 + 84128) = v381;
  v382 = v381 * *(float *)(a1 + 83360);
  *(float *)(a1 + 84240) = v382;
  *(float *)(a1 + 84256) = v382 * *(float *)(a1 + 83440);
  v383 = fmin(fmax((float)(*(float *)(a1 + 78032) + *(float *)(a1 + 77360)), -20.0), 8.9);
  v384 = v383 * v383 * v383;
  v385 = (double *)((char *)&unk_1809894E0 + 208 * (int)(v383 + 20.0));
  v386 = v384 * v383 * v383;
  v387 = v386 * v383 * v383;
  v388 = v387 * v383 * v383;
  v389 = v388 * v383;
  v390 = fmaxf(
           fminf(
             v383 * v385[2]
           + *v385
           + v383 * v383 * v385[4]
           + v384 * v385[6]
           + v384 * v383 * v385[8]
           + v386 * v385[10]
           + v386 * v383 * v385[12]
           + v387 * v385[14]
           + v387 * v383 * v385[16]
           + v388 * v385[18]
           + v389 * v385[20]
           + v389 * v383 * v385[22]
           + v389 * v383 * v383 * v385[24],
             512.0),
           -512.0)
       * *(float *)(a1 + 77376);
  *(float *)(a1 + 78000) = v390;
  v391 = *(float *)(a1 + 77360);
  v392 = *(_DWORD *)(a1 + 77824);
  v393 = *(_DWORD *)(a1 + 77840);
  LODWORD(v384) = *(_DWORD *)(a1 + 77856);
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
  *(_DWORD *)(a1 + 78320) = v392;
  *(_DWORD *)(a1 + 78336) = v393;
  v394 = v391 + *(float *)(a1 + 79888);
  v395 = v390 * *(float *)(a1 + 79120);
  v396 = *(float *)(a1 + 79104);
  *(_DWORD *)(a1 + 78352) = LODWORD(v384);
  v397 = fmaxf(*(float *)(a1 + 79152), v395);
  v398 = (float)(v394 * *(float *)(a1 + 79904)) + *(float *)(a1 + 79872);
  *(float *)(a1 + 78368) = v397;
  *(float *)(a1 + 78400) = v396 + *(float *)(a1 + 77392);
  if ( v398 <= 0.0 )
    v399 = 0.0;
  else
    v399 = v398;
  *(float *)(a1 + 78384) = 0.00390625 / v397;
  *(float *)(a1 + 79040) = v399;
  v401 = *(unsigned int *)(a1 + 78464);
  v400 = *(_DWORD *)(a1 + 78432);
  *(_DWORD *)(a1 + 78240) = v401;
  *(float *)&v401 = *(float *)&v401 + v397;
  *(_DWORD *)(a1 + 78256) = v400;
  if ( *(float *)&v401 <= 1.0 )
  {
    if ( *(float *)&v401 < -1.0 )
      *(float *)&v401 = fmodf(*(float *)&v401 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v401 = fmodf(*(float *)&v401 + 1.0, 2.0) - 1.0;
  }
  HIDWORD(v402) = HIDWORD(v401);
  *(_DWORD *)(a1 + 78224) = v401;
  v403 = *(float *)&v401 * *(float *)(a1 + 79232);
  *(float *)&v402 = (float)(*(float *)&v401 + 1.0) * 0.5;
  v404 = (float)((float)(sub_180368FC0(v402).m128_f32[0] * 256.0) * *(float *)(a1 + 78384)) * *(float *)(a1 + 79184);
  if ( v404 >= -1.0 )
    v405 = fminf(v404, 1.0);
  else
    v405 = -1.0;
  v406 = v405 * *(float *)(a1 + 79136);
  v407 = (float)(v406 * v406) * v406;
  v408 = v407 * *(float *)(a1 + 79536);
  v409 = *(float *)(a1 + 78400);
  v410 = (float)((float)((float)((float)((float)(v406 * v406) * *(float *)(a1 + 79600)) + *(float *)(a1 + 79584))
                       * (float)((float)(v406 * v406) * (float)(v406 * v406)))
               + (float)((float)((float)(v406 * v406) * *(float *)(a1 + 79568)) + *(float *)(a1 + 79552)))
       * (float)(v407 * (float)(v406 * v406));
  *(_QWORD *)&v411 = LODWORD(v409);
  *(float *)&v411 = v409 + *(float *)&v401;
  *(float *)(a1 + 78480) = (float)((float)(v410 + v408) + v406) * v403;
  if ( (float)(v409 + *(float *)&v401) < 0.0 )
    v412 = v409 - 1.0;
  else
    v412 = v409 + 1.0;
  v413 = *(float *)&v411;
  if ( *(float *)&v411 >= 0.0 )
  {
    if ( *(float *)&v411 > 0.0 )
      v413 = 1.0;
  }
  else
  {
    v413 = -1.0;
  }
  v414 = *(float *)(a1 + 78224);
  v415 = v413 * *(float *)(a1 + 79248);
  *(float *)&v411 = *(float *)&v411 / v412;
  v416 = sub_180368FC0(v411).m128_f32[0];
  v417 = *(float *)(a1 + 79168);
  if ( v414 < v417 || v417 <= *(float *)(a1 + 78240) )
  {
    v418 = *(unsigned int *)(a1 + 78256);
  }
  else
  {
    v418 = *(unsigned int *)(a1 + 78256);
    *(float *)&v418 = *(float *)&v418 + 2.0;
  }
  v419 = (float)((float)(v416 * *(float *)(a1 + 78384)) * 256.0) * *(float *)(a1 + 79200);
  if ( *(float *)&v418 >= 4.0 )
    v418 = 0;
  if ( v419 >= -1.0 )
    v420 = fminf(v419, 1.0);
  else
    v420 = -1.0;
  *(_DWORD *)(a1 + 78256) = v418;
  v421 = v420 * *(float *)(a1 + 79136);
  *(float *)&v418 = (float)((float)((float)(*(float *)&v418 + v414) + 1.0) * 0.5) - 1.0;
  v422 = (float)((float)((float)((float)((float)((float)((float)((float)(v421 * v421) * *(float *)(a1 + 79600))
                                                       + *(float *)(a1 + 79584))
                                               * (float)((float)(v421 * v421) * (float)(v421 * v421)))
                                       + (float)((float)((float)(v421 * v421) * *(float *)(a1 + 79568))
                                               + *(float *)(a1 + 79552)))
                               * (float)((float)((float)(v421 * v421) * v421) * (float)(v421 * v421)))
                       + (float)((float)((float)(v421 * v421) * v421) * *(float *)(a1 + 79536)))
               + v421)
       * v415;
  *(float *)(a1 + 78496) = v422;
  v423 = sub_180368FC0(COERCE_DOUBLE(v418 & 0x7FFFFFFF7FFFFFFFLL ^ 0x8000000080000000uLL)).m128_f32[0];
  if ( *(float *)&v418 >= 0.0 )
  {
    if ( *(float *)&v418 > 0.0 )
      LODWORD(v418) = 1065353216;
  }
  else
  {
    LODWORD(v418) = -1082130432;
  }
  v424 = *(float *)&v418 * *(float *)(a1 + 79264);
  v425 = (float)((float)((float)(v423 + 1.0) * *(float *)(a1 + 78384)) * 512.0) * *(float *)(a1 + 79216);
  if ( v425 >= -1.0 )
    v426 = fminf(v425, 1.0);
  else
    v426 = -1.0;
  v427 = v426 * *(float *)(a1 + 79136);
  v429 = *(unsigned int *)(a1 + 78224);
  v428 = *(_DWORD *)(a1 + 78256);
  *(float *)(a1 + 78528) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v427 * v427)
                                                                                                 * *(float *)(a1 + 79600))
                                                                                         + *(float *)(a1 + 79584))
                                                                                 * (float)((float)(v427 * v427)
                                                                                         * (float)(v427 * v427)))
                                                                         + (float)((float)((float)(v427 * v427)
                                                                                         * *(float *)(a1 + 79568))
                                                                                 + *(float *)(a1 + 79552)))
                                                                 * (float)((float)((float)(v427 * v427) * v427)
                                                                         * (float)(v427 * v427)))
                                                         + (float)((float)((float)(v427 * v427) * v427)
                                                                 * *(float *)(a1 + 79536)))
                                                 + v427)
                                         * v424)
                                 * *(float *)(a1 + 78352))
                         + (float)((float)(*(float *)(a1 + 78480) * *(float *)(a1 + 78320))
                                 + (float)(v422 * *(float *)(a1 + 78336)));
  *(_DWORD *)(a1 + 78240) = v429;
  *(_DWORD *)(a1 + 78256) = v428;
  *(float *)&v429 = *(float *)&v429 + *(float *)(a1 + 78368);
  if ( *(float *)&v429 <= 1.0 )
  {
    if ( *(float *)&v429 < -1.0 )
      *(float *)&v429 = fmodf(*(float *)&v429 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v429 = fmodf(*(float *)&v429 + 1.0, 2.0) - 1.0;
  }
  HIDWORD(v430) = HIDWORD(v429);
  *(_DWORD *)(a1 + 78224) = v429;
  v431 = *(float *)&v429 * *(float *)(a1 + 79232);
  *(float *)&v430 = (float)(*(float *)&v429 + 1.0) * 0.5;
  v432 = (float)((float)(sub_180368FC0(v430).m128_f32[0] * 256.0) * *(float *)(a1 + 78384)) * *(float *)(a1 + 79184);
  if ( v432 >= -1.0 )
    v433 = fminf(v432, 1.0);
  else
    v433 = -1.0;
  v434 = v433 * *(float *)(a1 + 79136);
  v435 = (float)(v434 * v434) * v434;
  v436 = v435 * *(float *)(a1 + 79536);
  v437 = *(float *)(a1 + 78400);
  v438 = (float)((float)((float)((float)((float)(v434 * v434) * *(float *)(a1 + 79600)) + *(float *)(a1 + 79584))
                       * (float)((float)(v434 * v434) * (float)(v434 * v434)))
               + (float)((float)((float)(v434 * v434) * *(float *)(a1 + 79568)) + *(float *)(a1 + 79552)))
       * (float)(v435 * (float)(v434 * v434));
  *(_QWORD *)&v439 = LODWORD(v437);
  *(float *)&v439 = v437 + *(float *)&v429;
  *(float *)(a1 + 78480) = (float)((float)(v438 + v436) + v434) * v431;
  if ( (float)(v437 + *(float *)&v429) < 0.0 )
    v440 = v437 - 1.0;
  else
    v440 = v437 + 1.0;
  v441 = *(float *)&v439;
  if ( *(float *)&v439 >= 0.0 )
  {
    if ( *(float *)&v439 > 0.0 )
      v441 = 1.0;
  }
  else
  {
    v441 = -1.0;
  }
  v442 = *(float *)(a1 + 78224);
  v443 = v441 * *(float *)(a1 + 79248);
  *(float *)&v439 = *(float *)&v439 / v440;
  v444 = sub_180368FC0(v439).m128_f32[0];
  v445 = *(float *)(a1 + 79168);
  if ( v442 < v445 || v445 <= *(float *)(a1 + 78240) )
  {
    v446 = *(unsigned int *)(a1 + 78256);
  }
  else
  {
    v446 = *(unsigned int *)(a1 + 78256);
    *(float *)&v446 = *(float *)&v446 + 2.0;
  }
  v447 = (float)((float)(v444 * *(float *)(a1 + 78384)) * 256.0) * *(float *)(a1 + 79200);
  if ( *(float *)&v446 >= 4.0 )
    v446 = 0;
  if ( v447 >= -1.0 )
    v448 = fminf(v447, 1.0);
  else
    v448 = -1.0;
  *(_DWORD *)(a1 + 78256) = v446;
  v449 = v448 * *(float *)(a1 + 79136);
  *(float *)&v446 = (float)((float)((float)(*(float *)&v446 + v442) + 1.0) * 0.5) - 1.0;
  v450 = (float)((float)((float)((float)((float)((float)((float)((float)(v449 * v449) * *(float *)(a1 + 79600))
                                                       + *(float *)(a1 + 79584))
                                               * (float)((float)(v449 * v449) * (float)(v449 * v449)))
                                       + (float)((float)((float)(v449 * v449) * *(float *)(a1 + 79568))
                                               + *(float *)(a1 + 79552)))
                               * (float)((float)((float)(v449 * v449) * v449) * (float)(v449 * v449)))
                       + (float)((float)((float)(v449 * v449) * v449) * *(float *)(a1 + 79536)))
               + v449)
       * v443;
  *(float *)(a1 + 78496) = v450;
  v451 = sub_180368FC0(COERCE_DOUBLE(v446 & 0x7FFFFFFF7FFFFFFFLL ^ 0x8000000080000000uLL)).m128_f32[0];
  if ( *(float *)&v446 >= 0.0 )
  {
    if ( *(float *)&v446 > 0.0 )
      LODWORD(v446) = 1065353216;
  }
  else
  {
    LODWORD(v446) = -1082130432;
  }
  v452 = *(float *)&v446 * *(float *)(a1 + 79264);
  v453 = (float)((float)((float)(v451 + 1.0) * *(float *)(a1 + 78384)) * 512.0) * *(float *)(a1 + 79216);
  if ( v453 >= -1.0 )
    v454 = fminf(v453, 1.0);
  else
    v454 = -1.0;
  v455 = v454 * *(float *)(a1 + 79136);
  v457 = *(unsigned int *)(a1 + 78224);
  v456 = *(_DWORD *)(a1 + 78256);
  *(float *)(a1 + 78656) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v455 * v455)
                                                                                                 * *(float *)(a1 + 79600))
                                                                                         + *(float *)(a1 + 79584))
                                                                                 * (float)((float)(v455 * v455)
                                                                                         * (float)(v455 * v455)))
                                                                         + (float)((float)((float)(v455 * v455)
                                                                                         * *(float *)(a1 + 79568))
                                                                                 + *(float *)(a1 + 79552)))
                                                                 * (float)((float)((float)(v455 * v455) * v455)
                                                                         * (float)(v455 * v455)))
                                                         + (float)((float)((float)(v455 * v455) * v455)
                                                                 * *(float *)(a1 + 79536)))
                                                 + v455)
                                         * v452)
                                 * *(float *)(a1 + 78352))
                         + (float)((float)(*(float *)(a1 + 78480) * *(float *)(a1 + 78320))
                                 + (float)(v450 * *(float *)(a1 + 78336)));
  *(_DWORD *)(a1 + 78240) = v457;
  *(_DWORD *)(a1 + 78256) = v456;
  *(float *)&v457 = *(float *)&v457 + *(float *)(a1 + 78368);
  if ( *(float *)&v457 <= 1.0 )
  {
    if ( *(float *)&v457 < -1.0 )
      *(float *)&v457 = fmodf(*(float *)&v457 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v457 = fmodf(*(float *)&v457 + 1.0, 2.0) - 1.0;
  }
  HIDWORD(v458) = HIDWORD(v457);
  *(_DWORD *)(a1 + 78224) = v457;
  v459 = *(float *)&v457 * *(float *)(a1 + 79232);
  *(float *)&v458 = (float)(*(float *)&v457 + 1.0) * 0.5;
  v460 = (float)((float)(sub_180368FC0(v458).m128_f32[0] * 256.0) * *(float *)(a1 + 78384)) * *(float *)(a1 + 79184);
  if ( v460 >= -1.0 )
    v461 = fminf(v460, 1.0);
  else
    v461 = -1.0;
  v462 = v461 * *(float *)(a1 + 79136);
  v463 = (float)(v462 * v462) * v462;
  v464 = v463 * *(float *)(a1 + 79536);
  v465 = *(float *)(a1 + 78400);
  v466 = (float)((float)((float)((float)((float)(v462 * v462) * *(float *)(a1 + 79600)) + *(float *)(a1 + 79584))
                       * (float)((float)(v462 * v462) * (float)(v462 * v462)))
               + (float)((float)((float)(v462 * v462) * *(float *)(a1 + 79568)) + *(float *)(a1 + 79552)))
       * (float)(v463 * (float)(v462 * v462));
  *(_QWORD *)&v467 = LODWORD(v465);
  *(float *)&v467 = v465 + *(float *)&v457;
  *(float *)(a1 + 78480) = (float)((float)(v466 + v464) + v462) * v459;
  if ( (float)(v465 + *(float *)&v457) < 0.0 )
    v468 = v465 - 1.0;
  else
    v468 = v465 + 1.0;
  v469 = *(float *)&v467;
  if ( *(float *)&v467 >= 0.0 )
  {
    if ( *(float *)&v467 > 0.0 )
      v469 = 1.0;
  }
  else
  {
    v469 = -1.0;
  }
  v470 = *(float *)(a1 + 78224);
  v471 = v469 * *(float *)(a1 + 79248);
  *(float *)&v467 = *(float *)&v467 / v468;
  v472 = sub_180368FC0(v467).m128_f32[0];
  v473 = *(float *)(a1 + 79168);
  if ( v470 < v473 || v473 <= *(float *)(a1 + 78240) )
  {
    v474 = *(unsigned int *)(a1 + 78256);
  }
  else
  {
    v474 = *(unsigned int *)(a1 + 78256);
    *(float *)&v474 = *(float *)&v474 + 2.0;
  }
  v475 = (float)((float)(v472 * *(float *)(a1 + 78384)) * 256.0) * *(float *)(a1 + 79200);
  if ( *(float *)&v474 >= 4.0 )
    v474 = 0;
  if ( v475 >= -1.0 )
    v476 = fminf(v475, 1.0);
  else
    v476 = -1.0;
  *(_DWORD *)(a1 + 78256) = v474;
  v477 = v476 * *(float *)(a1 + 79136);
  *(float *)&v474 = (float)((float)((float)(*(float *)&v474 + v470) + 1.0) * 0.5) - 1.0;
  v478 = (float)((float)((float)((float)((float)((float)((float)((float)(v477 * v477) * *(float *)(a1 + 79600))
                                                       + *(float *)(a1 + 79584))
                                               * (float)((float)(v477 * v477) * (float)(v477 * v477)))
                                       + (float)((float)((float)(v477 * v477) * *(float *)(a1 + 79568))
                                               + *(float *)(a1 + 79552)))
                               * (float)((float)((float)(v477 * v477) * v477) * (float)(v477 * v477)))
                       + (float)((float)((float)(v477 * v477) * v477) * *(float *)(a1 + 79536)))
               + v477)
       * v471;
  *(float *)(a1 + 78496) = v478;
  v479 = sub_180368FC0(COERCE_DOUBLE(v474 & 0x7FFFFFFF7FFFFFFFLL ^ 0x8000000080000000uLL)).m128_f32[0];
  if ( *(float *)&v474 >= 0.0 )
  {
    if ( *(float *)&v474 > 0.0 )
      LODWORD(v474) = 1065353216;
  }
  else
  {
    LODWORD(v474) = -1082130432;
  }
  v480 = *(float *)&v474 * *(float *)(a1 + 79264);
  v481 = (float)((float)((float)(v479 + 1.0) * *(float *)(a1 + 78384)) * 512.0) * *(float *)(a1 + 79216);
  if ( v481 >= -1.0 )
    v482 = fminf(v481, 1.0);
  else
    v482 = -1.0;
  v483 = v482 * *(float *)(a1 + 79136);
  v485 = *(unsigned int *)(a1 + 78224);
  v484 = *(_DWORD *)(a1 + 78256);
  *(float *)(a1 + 78784) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v483 * v483)
                                                                                                 * *(float *)(a1 + 79600))
                                                                                         + *(float *)(a1 + 79584))
                                                                                 * (float)((float)(v483 * v483)
                                                                                         * (float)(v483 * v483)))
                                                                         + (float)((float)((float)(v483 * v483)
                                                                                         * *(float *)(a1 + 79568))
                                                                                 + *(float *)(a1 + 79552)))
                                                                 * (float)((float)((float)(v483 * v483) * v483)
                                                                         * (float)(v483 * v483)))
                                                         + (float)((float)((float)(v483 * v483) * v483)
                                                                 * *(float *)(a1 + 79536)))
                                                 + v483)
                                         * v480)
                                 * *(float *)(a1 + 78352))
                         + (float)((float)(*(float *)(a1 + 78480) * *(float *)(a1 + 78320))
                                 + (float)(v478 * *(float *)(a1 + 78336)));
  *(_DWORD *)(a1 + 78240) = v485;
  *(_DWORD *)(a1 + 78256) = v484;
  *(float *)&v485 = *(float *)&v485 + *(float *)(a1 + 78368);
  if ( *(float *)&v485 <= 1.0 )
  {
    if ( *(float *)&v485 < -1.0 )
      *(float *)&v485 = fmodf(*(float *)&v485 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v485 = fmodf(*(float *)&v485 + 1.0, 2.0) - 1.0;
  }
  HIDWORD(v486) = HIDWORD(v485);
  *(_DWORD *)(a1 + 78224) = v485;
  v487 = *(float *)&v485 * *(float *)(a1 + 79232);
  *(float *)&v486 = (float)(*(float *)&v485 + 1.0) * 0.5;
  v488 = (float)((float)(sub_180368FC0(v486).m128_f32[0] * 256.0) * *(float *)(a1 + 78384)) * *(float *)(a1 + 79184);
  if ( v488 >= -1.0 )
    v489 = fminf(v488, 1.0);
  else
    v489 = -1.0;
  v490 = v489 * *(float *)(a1 + 79136);
  v491 = (float)(v490 * v490) * v490;
  v492 = v491 * *(float *)(a1 + 79536);
  v493 = *(float *)(a1 + 78400);
  v494 = (float)((float)((float)((float)((float)(v490 * v490) * *(float *)(a1 + 79600)) + *(float *)(a1 + 79584))
                       * (float)((float)(v490 * v490) * (float)(v490 * v490)))
               + (float)((float)((float)(v490 * v490) * *(float *)(a1 + 79568)) + *(float *)(a1 + 79552)))
       * (float)(v491 * (float)(v490 * v490));
  *(_QWORD *)&v495 = LODWORD(v493);
  *(float *)&v495 = v493 + *(float *)&v485;
  *(float *)(a1 + 78480) = (float)((float)(v494 + v492) + v490) * v487;
  if ( (float)(v493 + *(float *)&v485) < 0.0 )
    v496 = v493 - 1.0;
  else
    v496 = v493 + 1.0;
  v497 = *(float *)&v495;
  if ( *(float *)&v495 >= 0.0 )
  {
    if ( *(float *)&v495 > 0.0 )
      v497 = 1.0;
  }
  else
  {
    v497 = -1.0;
  }
  v498 = *(float *)(a1 + 78224);
  v499 = v497 * *(float *)(a1 + 79248);
  *(float *)&v495 = *(float *)&v495 / v496;
  v500 = sub_180368FC0(v495).m128_f32[0];
  v501 = *(float *)(a1 + 79168);
  if ( v498 < v501 || v501 <= *(float *)(a1 + 78240) )
  {
    v502 = *(unsigned int *)(a1 + 78256);
  }
  else
  {
    v502 = *(unsigned int *)(a1 + 78256);
    *(float *)&v502 = *(float *)&v502 + 2.0;
  }
  v503 = (float)((float)(v500 * *(float *)(a1 + 78384)) * 256.0) * *(float *)(a1 + 79200);
  if ( *(float *)&v502 >= 4.0 )
    v502 = 0;
  if ( v503 >= -1.0 )
    v504 = fminf(v503, 1.0);
  else
    v504 = -1.0;
  *(_DWORD *)(a1 + 78256) = v502;
  v505 = v504 * *(float *)(a1 + 79136);
  *(float *)&v502 = (float)((float)((float)(*(float *)&v502 + v498) + 1.0) * 0.5) - 1.0;
  v506 = (float)((float)((float)((float)((float)((float)((float)((float)(v505 * v505) * *(float *)(a1 + 79600))
                                                       + *(float *)(a1 + 79584))
                                               * (float)((float)(v505 * v505) * (float)(v505 * v505)))
                                       + (float)((float)((float)(v505 * v505) * *(float *)(a1 + 79568))
                                               + *(float *)(a1 + 79552)))
                               * (float)((float)((float)(v505 * v505) * v505) * (float)(v505 * v505)))
                       + (float)((float)((float)(v505 * v505) * v505) * *(float *)(a1 + 79536)))
               + v505)
       * v499;
  *(float *)(a1 + 78496) = v506;
  v507 = sub_180368FC0(COERCE_DOUBLE(v502 & 0x7FFFFFFF7FFFFFFFLL ^ 0x8000000080000000uLL)).m128_f32[0] + 1.0;
  if ( *(float *)&v502 >= 0.0 )
  {
    if ( *(float *)&v502 > 0.0 )
      LODWORD(v502) = 1065353216;
  }
  else
  {
    LODWORD(v502) = -1082130432;
  }
  v508 = *(float *)&v502 * *(float *)(a1 + 79264);
  v509 = (float)((float)(v507 * *(float *)(a1 + 78384)) * 512.0) * *(float *)(a1 + 79216);
  if ( v509 >= -1.0 )
    v33 = fminf(v509, 1.0);
  v510 = v33 * *(float *)(a1 + 79136);
  v511 = *(_DWORD *)(a1 + 78224);
  v512 = *(_DWORD *)(a1 + 78256);
  *(float *)(a1 + 78912) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v510 * v510)
                                                                                                 * *(float *)(a1 + 79600))
                                                                                         + *(float *)(a1 + 79584))
                                                                                 * (float)((float)(v510 * v510)
                                                                                         * (float)(v510 * v510)))
                                                                         + (float)((float)((float)(v510 * v510)
                                                                                         * *(float *)(a1 + 79568))
                                                                                 + *(float *)(a1 + 79552)))
                                                                 * (float)((float)((float)(v510 * v510) * v510)
                                                                         * (float)(v510 * v510)))
                                                         + (float)((float)((float)(v510 * v510) * v510)
                                                                 * *(float *)(a1 + 79536)))
                                                 + v510)
                                         * v508)
                                 * *(float *)(a1 + 78352))
                         + (float)((float)(*(float *)(a1 + 78480) * *(float *)(a1 + 78320))
                                 + (float)(v506 * *(float *)(a1 + 78336)));
  v513 = *(float *)(a1 + 79024);
  *(_DWORD *)(a1 + 78448) = v511;
  *(_DWORD *)(a1 + 78416) = v512;
  v514 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(*(float *)(a1 + 78896) + *(float *)(a1 + 78656))
                                                                                               * *(float *)(a1 + 79296))
                                                                                       + (float)((float)(v513 + *(float *)(a1 + 78528))
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
  v515 = *(float *)(a1 + 79072);
  v516 = (float)(v515 * *(float *)(a1 + 79840)) + *(float *)(a1 + 79088);
  v517 = (float)((float)(v514
                       + (float)((float)(*(float *)(a1 + 78976) + *(float *)(a1 + 78576)) * *(float *)(a1 + 79472)))
               + (float)((float)(*(float *)(a1 + 78848) + *(float *)(a1 + 78704)) * *(float *)(a1 + 79488)))
       + (float)((float)(*(float *)(a1 + 78832) + *(float *)(a1 + 78720)) * *(float *)(a1 + 79504));
  v518 = (float)(*(float *)(a1 + 78960) + *(float *)(a1 + 78592)) * *(float *)(a1 + 79520);
  *(float *)(a1 + 79072) = v516;
  v519 = v517 + v518;
  v520 = v519 - (float)((float)(v515 * *(float *)(a1 + 79856)) + v516);
  *(float *)(a1 + 79056) = (float)(v520 * *(float *)(a1 + 79840)) + v515;
  v521 = (float)((float)((float)(v516 - (float)(v520 * *(float *)(a1 + 79040))) * *(float *)(a1 + 79920))
               - (float)(*(float *)(a1 + 79920) * v519))
       + v519;
  *(float *)(a1 + 78512) = v521;
  *(float *)(a1 + 77104) = v521;
  if ( *(float *)(a1 + 101728) == 1.0 )
  {
    *(_DWORD *)(a1 + 73904) = v523;
    *(_DWORD *)(a1 + 101728) = 0;
  }
  **a2 = *(_DWORD *)(a1 + 84256);
  result = *(unsigned int *)(a1 + 84256);
  *a2[1] = result;
  return result;
}

