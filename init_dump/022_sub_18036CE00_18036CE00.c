// sub_18036CE00  @ 0x18036CE00  (RVA 0x36CE00)  floats=21
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

__int64 __fastcall sub_18036CE00(__int64 a1, _DWORD **a2)
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

  v2 = *(float *)(a1 + 10832);
  v523 = 0;
  if ( *(float *)(a1 + 101536) == 1.0 )
  {
    v523 = *(_DWORD *)(a1 + 10832);
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
  v87 = *(unsigned int *)(a1 + 12640);
  *(float *)(a1 + 12000) = v86;
  *(float *)&v87 = fminf(*(float *)&v87, v83 * 0.000015258789);
  v88 = (float)((float)(1.0 - v78) * *(float *)(a1 + 12432)) + v78;
  if ( v88 >= -1.0 )
    v89 = fminf(v88, 1.0);
  else
    v89 = -1.0;
  v90 = *(float *)&v87 * *(float *)(a1 + 12656);
  v91 = v80 - v86;
  *(float *)(a1 + 12176) = v90;
  v92 = v90 + v81;
  if ( v91 < 0.0 )
    v89 = 0.0;
  v93 = *(float *)(a1 + 12384);
  v94 = *(float *)(a1 + 11936);
  *(float *)(a1 + 12016) = v89;
  v95 = v89 + *(float *)(a1 + 12784);
  if ( v91 >= 0.0 )
    v93 = 1.0;
  v96 = v95 * *(float *)(a1 + 12768);
  *(float *)&v87 = (float)(v92 * v93) * *(float *)(a1 + 12400);
  if ( v96 <= 0.0 )
    v97 = 0.0;
  else
    v97 = v96;
  v98 = v97;
  v99 = (float)((float)(v94 - *(float *)(a1 + 12096)) * *(float *)(a1 + 12976)) + *(float *)(a1 + 12096);
  *(float *)(a1 + 12080) = v99;
  *(float *)(a1 + 11984) = v98;
  v524 = *(float *)(a1 + 12064);
  v100 = (float)((float)((float)(v99 * *(float *)(a1 + 12960)) * *(float *)(a1 + 12576))
               - (float)(v94 * *(float *)(a1 + 12576)))
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
  v101 = *(float *)(a1 + 12128);
  *(_DWORD *)(a1 + 12048) = v87;
  v102 = *(float *)&v87 + *(float *)(a1 + 12800);
  *(float *)(a1 + 11920) = v100 * *(float *)(a1 + 12944);
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
  *(float *)(a1 + 12112) = v101;
  v103 = v101 * *(float *)(a1 + 12928);
  v104 = (float)(v102 * *(float *)(a1 + 12864)) + *(float *)(a1 + 12992);
  *(float *)(a1 + 12192) = v104;
  *(float *)(a1 + 12272) = v103;
  HIDWORD(v105) = HIDWORD(v87);
  *(float *)&v105 = *(float *)&v87 + *(float *)(a1 + 12832);
  *(float *)(a1 + 12208) = -v104;
  if ( *(float *)&v105 <= 1.0 )
  {
    if ( *(float *)&v105 < -1.0 )
      *(float *)&v105 = fmodf(*(float *)&v105 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v105 = fmodf(*(float *)&v105 + 1.0, 2.0) - 1.0;
  }
  v106 = *(float *)&v87 + *(float *)(a1 + 12816);
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
  v108 = v106 + *(float *)(a1 + 13008);
  v109 = v107 * *(float *)(a1 + 12896);
  if ( v108 >= 0.0 )
  {
    if ( v108 > 0.0 )
      v108 = 1.0;
  }
  else
  {
    v108 = -1.0;
  }
  v110 = *(float *)&v87 + *(float *)(a1 + 12848);
  *(float *)(a1 + 12240) = v109;
  *(float *)(a1 + 12336) = v108;
  v111 = (float)(v108 * *(float *)(a1 + 12880)) + *(float *)(a1 + 13024);
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
  *(float *)(a1 + 12224) = v111;
  v113 = *(float *)(a1 + 12480);
  v114 = (float)((float)(*(float *)(a1 + 12544) * *(float *)(a1 + 12272))
               + (float)(*(float *)(a1 + 12512) * *(float *)(a1 + 12192)))
       + (float)(*(float *)(a1 + 12528) * *(float *)(a1 + 12208));
  v115 = (float)((float)((float)((float)(v112 * (float)((float)(v112 * v112) * v112)) * *(float *)(a1 + 12736))
                       + (float)((float)((float)((float)(v112 * v112) * v112) * *(float *)(a1 + 12720))
                               + (float)((float)((float)(v112 * *(float *)(a1 + 12688)) + *(float *)(a1 + 12672))
                                       + (float)((float)(v112 * v112) * *(float *)(a1 + 12704)))))
               + *(float *)(a1 + 12752))
       * *(float *)(a1 + 12912);
  *(float *)(a1 + 12256) = v115;
  v116 = (float)(v113 * *(float *)(a1 + 12240)) + v114;
  v117 = *(float *)(a1 + 12592);
  v118 = (float)((float)(*(float *)(a1 + 12448) * *(float *)(a1 + 11984)) - *(float *)(a1 + 12448)) + 1.0;
  v119 = (float)((float)(v116 + (float)(*(float *)(a1 + 12496) * *(float *)(a1 + 12224)))
               + (float)(v115 * *(float *)(a1 + 12464)))
       + (float)(*(float *)(a1 + 12560) * *(float *)(a1 + 11920));
  *(float *)(a1 + 12288) = v118;
  *(float *)(a1 + 12320) = v119;
  *(float *)(a1 + 12304) = (float)((float)(*(float *)(a1 + 12608) * *(float *)(a1 + 11952))
                                 + (float)(*(float *)(a1 + 12624) * *(float *)(a1 + 11968)))
                         + (float)((float)(v117 * v118) * v119);
  v120 = *(_DWORD *)(a1 + 12320);
  *(_DWORD *)(a1 + 13040) = *(_DWORD *)(a1 + 12336);
  *(_DWORD *)(a1 + 13056) = v120;
  if ( *(float *)(a1 + 12336) <= 0.0 )
    v121 = 0.0;
  else
    v121 = 1.0;
  if ( *(float *)(a1 + 13072) == 0.0 )
    v121 = 1.0;
  v122 = *(float *)(a1 + 11072) * v121;
  *(float *)(a1 + 13088) = v122;
  *(_DWORD *)(a1 + 13120) = *(_DWORD *)(a1 + 13104);
  *(_DWORD *)(a1 + 13168) = *(_DWORD *)(a1 + 13152);
  *(_DWORD *)(a1 + 13152) = *(_DWORD *)(a1 + 13136);
  *(_DWORD *)(a1 + 13200) = *(_DWORD *)(a1 + 13184);
  *(_DWORD *)(a1 + 13248) = *(_DWORD *)(a1 + 13232);
  if ( (float)(v122 + *(float *)(a1 + 13376)) >= 0.0 )
    v123 = 0.0;
  else
    v123 = 1.0;
  v124 = 1.0 - v123;
  v125 = (float)(1.0 - v123)
       * (float)((float)(*(float *)(a1 + 13408) * *(float *)(a1 + 13168)) + *(float *)(a1 + 13120));
  *(float *)(a1 + 13136) = v125;
  v126 = v125 + *(float *)(a1 + 13392);
  v127 = v125 - *(float *)(a1 + 13152);
  *(float *)(a1 + 13216) = (float)((float)(*(float *)(a1 + 13360) * *(float *)(a1 + 13472))
                                 - (float)(*(float *)(a1 + 13440) * *(float *)(a1 + 13360)))
                         + *(float *)(a1 + 13440);
  if ( v126 < 0.0 )
    v128 = 0.0;
  else
    v128 = 1.0;
  if ( v127 < 0.0 )
    v128 = 1.0 - v123;
  v129 = *(float *)(a1 + 13296);
  v130 = v124 * (float)(*(float *)(a1 + 13312) * *(float *)(a1 + 13440));
  *(float *)(a1 + 13152) = v128;
  v131 = *(float *)(a1 + 13200);
  v132 = (float)(v130 - (float)(*(float *)(a1 + 13456) * v124)) + *(float *)(a1 + 13456);
  v133 = v124 * (float)(1.0 - v128);
  v134 = (float)((float)(*(float *)(a1 + 13328) * 0.00390625) * v128) + (float)((float)(v129 * 0.00390625) * v133);
  if ( (float)(v132 - v131) > 0.0 )
    v132 = v131 + *(float *)(a1 + 13216);
  v135 = *(float *)(a1 + 13120);
  v136 = fminf(*(float *)(a1 + 13440), v132);
  *(float *)(a1 + 13184) = v136;
  v137 = *(float *)(a1 + 13344);
  v138 = (float)((float)(v133 * *(float *)(a1 + 13424)) + (float)(v128 * v136)) - v135;
  v139 = (float)((float)(*(float *)(a1 + 13488) * v134) - (float)(*(float *)(a1 + 13488) * *(float *)(a1 + 13248)))
       + *(float *)(a1 + 13248);
  *(float *)(a1 + 13232) = v139;
  v140 = (float)((float)((float)((float)((float)(v137 * 0.00390625) * v123) - (float)(v123 * v139)) + v139) * v138)
       + v135;
  *(float *)(a1 + 13104) = v140;
  v141 = (float)(v140 * *(float *)(a1 + 13504)) * *(float *)(a1 + 13520);
  v142 = v141 * *(float *)(a1 + 13536);
  *(float *)(a1 + 13264) = v141;
  *(float *)(a1 + 13280) = v142;
  if ( *(float *)(a1 + 12336) <= 0.0 )
    v143 = 0.0;
  else
    v143 = 1.0;
  if ( *(float *)(a1 + 13552) == 0.0 )
    v143 = 1.0;
  v144 = *(float *)(a1 + 11072) * v143;
  *(float *)(a1 + 13568) = v144;
  *(_DWORD *)(a1 + 13600) = *(_DWORD *)(a1 + 13584);
  *(_DWORD *)(a1 + 13648) = *(_DWORD *)(a1 + 13632);
  *(_DWORD *)(a1 + 13632) = *(_DWORD *)(a1 + 13616);
  *(_DWORD *)(a1 + 13680) = *(_DWORD *)(a1 + 13664);
  *(_DWORD *)(a1 + 13728) = *(_DWORD *)(a1 + 13712);
  if ( (float)(v144 + *(float *)(a1 + 13856)) >= 0.0 )
    v145 = 0.0;
  else
    v145 = 1.0;
  v146 = 1.0 - v145;
  v147 = (float)(1.0 - v145)
       * (float)((float)(*(float *)(a1 + 13888) * *(float *)(a1 + 13648)) + *(float *)(a1 + 13600));
  *(float *)(a1 + 13616) = v147;
  v148 = v147 + *(float *)(a1 + 13872);
  v149 = v147 - *(float *)(a1 + 13632);
  *(float *)(a1 + 13696) = (float)((float)(*(float *)(a1 + 13840) * *(float *)(a1 + 13952))
                                 - (float)(*(float *)(a1 + 13920) * *(float *)(a1 + 13840)))
                         + *(float *)(a1 + 13920);
  if ( v148 < 0.0 )
    v150 = 0.0;
  else
    v150 = 1.0;
  if ( v149 < 0.0 )
    v150 = 1.0 - v145;
  v151 = *(float *)(a1 + 13792) * *(float *)(a1 + 13920);
  v152 = *(float *)(a1 + 13776);
  *(float *)(a1 + 13632) = v150;
  v153 = *(float *)(a1 + 13680);
  v154 = (float)((float)(v146 * v151) - (float)(*(float *)(a1 + 13936) * v146)) + *(float *)(a1 + 13936);
  v155 = v146 * (float)(1.0 - v150);
  v156 = (float)((float)(*(float *)(a1 + 13808) * 0.00390625) * v150) + (float)((float)(v152 * 0.00390625) * v155);
  if ( (float)(v154 - v153) > 0.0 )
    v154 = v153 + *(float *)(a1 + 13696);
  v157 = *(float *)(a1 + 13600);
  v158 = fminf(*(float *)(a1 + 13920), v154);
  *(float *)(a1 + 13664) = v158;
  v159 = (float)(*(float *)(a1 + 13824) * 0.00390625) * v145;
  v160 = (float)((float)(v155 * *(float *)(a1 + 13904)) + (float)(v150 * v158)) - v157;
  v161 = (float)((float)(*(float *)(a1 + 13968) * v156) - (float)(*(float *)(a1 + 13968) * *(float *)(a1 + 13728)))
       + *(float *)(a1 + 13728);
  *(float *)(a1 + 13712) = v161;
  v162 = (float)((float)((float)(v159 - (float)(v145 * v161)) + v161) * v160) + v157;
  *(float *)(a1 + 13584) = v162;
  v163 = (float)(v162 * *(float *)(a1 + 13984)) * *(float *)(a1 + 14000);
  v164 = v163 * *(float *)(a1 + 14016);
  *(float *)(a1 + 13744) = v163;
  *(float *)(a1 + 13760) = v164;
  *(_DWORD *)(a1 + 14048) = *(_DWORD *)(a1 + 14032);
  *(_DWORD *)(a1 + 14080) = *(_DWORD *)(a1 + 14064);
  v165 = *(float *)(a1 + 11264);
  v166 = *(float *)(a1 + 11392);
  *(_DWORD *)(a1 + 14144) = *(_DWORD *)(a1 + 14128);
  v167 = (float)(v166 * *(float *)(a1 + 14112)) + (float)(v165 * *(float *)(a1 + 14096));
  *(float *)(a1 + 14128) = v167;
  v168 = *(float *)(a1 + 12304);
  v169 = *(_DWORD *)(a1 + 13264);
  v170 = *(_DWORD *)(a1 + 13744);
  v171 = *(_DWORD *)(a1 + 11264);
  *(_DWORD *)(a1 + 14192) = *(_DWORD *)(a1 + 14064);
  *(_DWORD *)(a1 + 14208) = v171;
  v172 = *(float *)(a1 + 14528);
  *(_DWORD *)(a1 + 14160) = v169;
  *(_DWORD *)(a1 + 14176) = v170;
  v173 = *(float *)(a1 + 14496);
  v174 = v168 * v172;
  v175 = v172 * *(float *)(a1 + 12320);
  *(float *)(a1 + 14224) = v175;
  v176 = *(float *)(a1 + 14624);
  v177 = *(float *)(a1 + 14368);
  v178 = v174 * *(float *)(a1 + 14544);
  v179 = *(float *)(a1 + 14560);
  v180 = (float)(v173 * v175) * *(float *)(a1 + 14512);
  *(float *)(a1 + 14256) = v180;
  v181 = *(float *)(a1 + 14384);
  v182 = (float)((float)((float)(v177 * *(float *)(a1 + 14192)) - (float)(v176 * v177)) + v176) * *(float *)(a1 + 14640);
  *(float *)(a1 + 14272) = v182;
  v183 = (float)((float)(v179 * v178) + v180) + (float)(v181 * v182);
  v184 = *(float *)(a1 + 14224);
  v185 = *(_DWORD *)(a1 + 14352);
  *(float *)(a1 + 14288) = (float)((float)((float)((float)((float)((float)(*(float *)(a1 + 14592)
                                                                         * *(float *)(a1 + 14176))
                                                                 + (float)(*(float *)(a1 + 14576)
                                                                         * *(float *)(a1 + 14160)))
                                                         * *(float *)(a1 + 14608))
                                                 + v183)
                                         + v167)
                                 + *(float *)(a1 + 14464))
                         + *(float *)(a1 + 14480);
  *(_DWORD *)(a1 + 14304) = v185;
  v186 = (float)(*(float *)(a1 + 14256) + *(float *)(a1 + 14208)) + *(float *)(a1 + 14272);
  *(float *)(a1 + 14320) = (float)((float)((float)((float)((float)((float)(v184 * *(float *)(a1 + 14672))
                                                                 + *(float *)(a1 + 14688))
                                                         * *(float *)(a1 + 14400))
                                                 + (float)(*(float *)(a1 + 14416) * *(float *)(a1 + 14160)))
                                         + (float)(*(float *)(a1 + 14432) * *(float *)(a1 + 14176)))
                                 + *(float *)(a1 + 14448))
                         * *(float *)(a1 + 14656);
  *(float *)(a1 + 14336) = v186;
  v187 = *(_DWORD *)(a1 + 14720);
  *(_DWORD *)(a1 + 14752) = *(_DWORD *)(a1 + 14704);
  *(_DWORD *)(a1 + 14768) = v187;
  *(_DWORD *)(a1 + 14784) = *(_DWORD *)(a1 + 14736);
  v188 = *(float *)(a1 + 84432);
  *(_DWORD *)(a1 + 14832) = *(_DWORD *)(a1 + 14816);
  v189 = *(float *)(a1 + 14800);
  *(float *)(a1 + 14816) = v189;
  v190 = (float)(v189 * *(float *)(a1 + 14848)) + *(float *)(a1 + 14832);
  *(float *)(a1 + 14816) = v190;
  v191 = (float)(v189 * *(float *)(a1 + 14864)) + v190;
  v192 = v190 * *(float *)(a1 + 14912);
  v193 = v188 - v191;
  v194 = (float)(v193 * *(float *)(a1 + 14848)) + v189;
  *(float *)(a1 + 14800) = v194;
  *(float *)(a1 + 14832) = (float)((float)(v193 * *(float *)(a1 + 14880)) + v192)
                         + (float)(v194 * *(float *)(a1 + 14896));
  *(_DWORD *)(a1 + 16944) = *(_DWORD *)(a1 + 16928);
  v195 = *(float *)(a1 + 16960);
  *(float *)(a1 + 16976) = v195;
  v196 = v195 * *(float *)(a1 + 14048);
  v197 = *(float *)(a1 + 16944) * *(float *)(a1 + 14832);
  *(float *)(a1 + 16992) = v196;
  *(float *)(a1 + 17008) = v197;
  *(_DWORD *)(a1 + 17072) = *(_DWORD *)(a1 + 17056);
  *(float *)(a1 + 17056) = (float)(v197 * *(float *)(a1 + 17040)) + (float)(v196 * *(float *)(a1 + 17024));
  *(_DWORD *)(a1 + 17104) = *(_DWORD *)(a1 + 17088);
  *(_DWORD *)(a1 + 17136) = *(_DWORD *)(a1 + 17120);
  *(_DWORD *)(a1 + 17168) = *(_DWORD *)(a1 + 17152);
  *(_DWORD *)(a1 + 17200) = *(_DWORD *)(a1 + 17184);
  v198 = (float)((float)(*(float *)(a1 + 17232) * *(float *)(a1 + 17088))
               - (float)(*(float *)(a1 + 17248) * *(float *)(a1 + 17232)))
       + *(float *)(a1 + 17248);
  v199 = (float)((float)((float)((float)(v198 * v198) * v198) * v198) * *(float *)(a1 + 17328))
       + (float)((float)((float)((float)(v198 * v198) * v198) * *(float *)(a1 + 17312))
               + (float)((float)((float)(v198 * *(float *)(a1 + 17280)) + *(float *)(a1 + 17264))
                       + (float)((float)(v198 * v198) * *(float *)(a1 + 17296))));
  if ( v199 <= 0.0 )
    v200 = 0.0;
  else
    v200 = v199;
  v201 = v200;
  if ( v201 < 1.0 )
    v42 = v201;
  v202 = v42;
  *(float *)(a1 + 17216) = v202;
  *(_DWORD *)(a1 + 17360) = *(_DWORD *)(a1 + 17344);
  v203 = *(float *)(a1 + 17376);
  *(float *)(a1 + 17392) = v203;
  v204 = *(float *)(a1 + 17408);
  *(float *)(a1 + 17424) = v204;
  *(float *)(a1 + 17408) = (float)((float)(v203 - v204) * *(float *)(a1 + 17440)) + v204;
  v205 = *(float *)(a1 + 11264);
  v206 = *(float *)(a1 + 11392);
  *(_DWORD *)(a1 + 17504) = *(_DWORD *)(a1 + 17488);
  *(float *)(a1 + 17488) = (float)(v206 * *(float *)(a1 + 17472)) + (float)(v205 * *(float *)(a1 + 17456));
  *(_DWORD *)(a1 + 17552) = *(_DWORD *)(a1 + 17520);
  v207 = *(float *)(a1 + 17536);
  *(float *)(a1 + 17568) = v207;
  v208 = *(float *)(a1 + 13264)
       + (float)((float)(*(float *)(a1 + 17552) * *(float *)(a1 + 13744))
               - (float)(*(float *)(a1 + 17552) * *(float *)(a1 + 13264)));
  *(float *)(a1 + 17584) = (float)((float)(v207 * *(float *)(a1 + 17152)) - (float)(v207 * v208)) + v208;
  v209 = *(float *)(a1 + 12304);
  v210 = *(float *)(a1 + 17600);
  *(float *)(a1 + 17616) = v210;
  v211 = v209 - v210;
  v212 = (float)(v211 * *(float *)(a1 + 17632)) + v210;
  v213 = *(float *)(a1 + 17664);
  *(float *)(a1 + 17600) = v212;
  *(float *)(a1 + 17616) = (float)(v211 * *(float *)(a1 + 17648)) + (float)(v213 * v212);
  v214 = *(float *)(a1 + 17680);
  v215 = *(float *)(a1 + 12320);
  *(float *)(a1 + 17696) = v214;
  v216 = v215 - v214;
  v217 = (float)(v216 * *(float *)(a1 + 17712)) + v214;
  v218 = *(float *)(a1 + 17744);
  *(float *)(a1 + 17680) = v217;
  v219 = (float)(v216 * *(float *)(a1 + 17728)) + (float)(v218 * v217);
  *(float *)(a1 + 17696) = v219;
  v220 = *(float *)(a1 + 17616);
  v221 = *(float *)(a1 + 17584);
  v222 = *(float *)(a1 + 17488);
  v225 = (__m128)*(unsigned int *)(a1 + 17120);
  *(_DWORD *)(a1 + 17760) = *(_DWORD *)(a1 + 17408);
  *(_DWORD *)(a1 + 17776) = v225.m128_i32[0];
  v223 = *(float *)(a1 + 17808);
  v224 = *(float *)(a1 + 17824) * *(float *)(a1 + 17184);
  v225.m128_f32[0] = (float)((float)((float)((float)((float)(v225.m128_f32[0] * *(float *)(a1 + 17840))
                                                   - (float)(*(float *)(a1 + 17968) * *(float *)(a1 + 17840)))
                                           + *(float *)(a1 + 17968))
                                   * *(float *)(a1 + 17984))
                           + (float)((float)((float)(*(float *)(a1 + 17952) + *(float *)(a1 + 17760))
                                           * *(float *)(a1 + 18016))
                                   * *(float *)(a1 + 17936)))
                   + (float)((float)((float)((float)((float)((float)(v224
                                                                   - (float)(*(float *)(a1 + 17824)
                                                                           * (float)(v219 * v223)))
                                                           + (float)(v219 * v223))
                                                   * *(float *)(a1 + 17872))
                                           * *(float *)(a1 + 17888))
                                   + (float)((float)((float)(v224
                                                           - (float)(*(float *)(a1 + 17824) * (float)(v220 * v223)))
                                                   + (float)(v220 * v223))
                                           * *(float *)(a1 + 17856)))
                           + (float)((float)((float)(v222 + *(float *)(a1 + 18000)) * *(float *)(a1 + 17920))
                                   + (float)(v221 * *(float *)(a1 + 17904))));
  *(_DWORD *)(a1 + 17792) = v225.m128_i32[0];
  v226 = *(float *)(a1 + 17216);
  v227 = *(float *)(a1 + 17360);
  *(_DWORD *)(a1 + 18096) = *(_DWORD *)(a1 + 18080);
  v228 = *(float *)(a1 + 18064);
  *(float *)(a1 + 18080) = v228;
  if ( *(float *)(a1 + 18144) == 1.0 )
  {
    v229 = *(float *)(a1 + 18096)
         + (float)((float)(*(float *)(a1 + 18224) * v228) - (float)(*(float *)(a1 + 18224) * *(float *)(a1 + 18096)));
    *(float *)(a1 + 18080) = v229;
    v230 = (float)(v229 * *(float *)(a1 + 18208)) + *(float *)(a1 + 18112);
    *(float *)(a1 + 18064) = sub_180368D60(-v228);
    v231 = (float)(1.0 - v227) * *(float *)(a1 + 18240);
    *(float *)(a1 + 18048) = (float)(v227 * *(float *)(a1 + 18304)) + *(float *)(a1 + 18128);
    v225.m128_f32[0] = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v225.m128_f32[0] * *(float *)(a1 + 18192))
                                                         + (float)(v226 * *(float *)(a1 + 18160)))
                                                 + v230)
                                         + fminf(*(float *)(a1 + 18256), v231))
                                 + *(float *)(a1 + 18176),
                                   *(float *)(a1 + 18272)),
                                 *(float *)(a1 + 18288))
                             * *(float *)(a1 + 18336))
                     + *(float *)(a1 + 18352);
    v232 = v225.m128_f32[0];
    v233 = (int)v225.m128_f32[0];
    if ( (int)v225.m128_f32[0] != 0x80000000 && (float)v233 != v225.m128_f32[0] )
      v232 = (float)(v233 - (_mm_movemask_ps(_mm_unpacklo_ps(v225, v225)) & 1));
    v234 = v225.m128_f32[0] - v232;
    v235 = (float)(v234 * v234) * 0.25;
    v236 = (float)(expf(v232)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v234 * *(float *)(a1 + 18544)) + *(float *)(a1 + 18528)) * v235) + (float)(v234 * *(float *)(a1 + 18512))) + *(float *)(a1 + 18496)) * v235) + (float)(v234 * *(float *)(a1 + 18480)))
                                                                                                 + *(float *)(a1 + 18464))
                                                                                         * v235)
                                                                                 + (float)(v234 * *(float *)(a1 + 18448)))
                                                                         + *(float *)(a1 + 18432))
                                                                 * v235)
                                                         + (float)(v234 * *(float *)(a1 + 18416)))
                                                 + *(float *)(a1 + 18400))
                                         * v235)
                                 + (float)(v234 * *(float *)(a1 + 18384)))
                         + 1.0))
         * *(float *)(a1 + 18368);
    v237 = v236 * v236;
    v238 = (float)((float)((float)((float)((float)((float)((float)((float)(v236 * v236) * *(float *)(a1 + 18704))
                                                         + *(float *)(a1 + 18672))
                                                 * (float)(v237 * v237))
                                         + (float)((float)((float)(v236 * v236) * *(float *)(a1 + 18640))
                                                 + *(float *)(a1 + 18608)))
                                 * (float)((float)((float)(v236 * v236) * v236) * (float)(v236 * v236)))
                         + (float)((float)((float)(v236 * v236) * v236) * *(float *)(a1 + 18576)))
                 + v236)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v236 * v236) * *(float *)(a1 + 18688))
                                                                 + *(float *)(a1 + 18656))
                                                         * (float)(v237 * v237))
                                                 + (float)((float)(v236 * v236) * *(float *)(a1 + 18624)))
                                         + *(float *)(a1 + 18592))
                                 * (float)(v237 * v237))
                         + (float)((float)(v236 * v236) * *(float *)(a1 + 18560)))
                 + 1.0);
    v239 = v238 / (float)(v238 + 1.0);
    *(float *)(a1 + 18032) = v239;
  }
  else
  {
    v239 = *(float *)(a1 + 18032);
  }
  v240 = *(float *)(a1 + 17056);
  v241 = *(float *)(a1 + 18048);
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
  v242 = *(float *)(a1 + 19488);
  *(float *)(a1 + 19504) = v242;
  if ( *(float *)(a1 + 19568) == 1.0 )
  {
    v243 = (float)((float)((float)(v241 * *(float *)(a1 + 19680)) + 1.0) * (float)(v240 * *(float *)(a1 + 19648)))
         + (float)((float)-v242 * *(float *)(a1 + 19632));
    *(float *)(a1 + 19488) = sub_180368D60(-v242);
    *(float *)(a1 + 19456) = v243;
    v244 = 1.0 - (float)(v239 + v239);
    v245 = 1.0 / (float)((float)((float)((float)(v239 * v239) * (float)(v239 * v239)) * v241) + 1.0);
    *(float *)(a1 + 19536) = v245;
    v246 = *(float *)(a1 + 19456);
    v247 = *(float *)(a1 + 19472);
    *(float *)(a1 + 19520) = v245 * v241;
    v248 = v247 * *(float *)(a1 + 19728);
    v249 = *(float *)(a1 + 18816);
    v250 = v246 * *(float *)(a1 + 19744);
    v251 = *(float *)(a1 + 18832);
    *(float *)(a1 + 18928) = v249;
    v252 = (float)((float)(v248 + v250) * v245)
         - (float)((float)((float)(v249 * *(float *)(a1 + 20032)) + (float)(v251 * *(float *)(a1 + 20048)))
                 * (float)(v245 * v241));
    if ( v252 >= -1.0 )
      v253 = fminf(v252, 1.0);
    else
      v253 = -1.0;
    v254 = v253 + (float)((float)((float)((float)(v253 * v253) * v253) * v253) * (float)(v253 * *(float *)(a1 + 19696)));
    *(float *)(a1 + 18848) = v254;
    v255 = *(float *)(a1 + 18752);
    v256 = (float)(v239 * (float)(v254 + *(float *)(a1 + 18736))) + (float)(v255 * v244);
    *(float *)(a1 + 18864) = v256;
    v257 = *(float *)(a1 + 18768);
    v258 = v239 * (float)(v256 + v255);
    v259 = v239 * (float)((float)((float)(v239 * v254) + (float)(v244 * v256)) + v256);
    v260 = v258 + (float)(v257 * v244);
    *(float *)(a1 + 18880) = v260;
    v261 = *(float *)(a1 + 18784);
    v262 = (float)(v239 * (float)(v260 + v257)) + (float)(v261 * v244);
    *(float *)(a1 + 18896) = v262;
    v263 = (float)((float)(v261 + v262) * v239) + (float)(v244 * *(float *)(a1 + 18800));
    *(float *)(a1 + 18912) = v263;
    v264 = (float)(v239
                 * (float)((float)((float)(v239 * (float)((float)(v259 + (float)(v244 * v260)) + v260))
                                 + (float)(v244 * v262))
                         + v262))
         + (float)(v244 * v263);
    v265 = (float)(*(float *)(a1 + 18896) * *(float *)(a1 + 19600)) + (float)(v263 * *(float *)(a1 + 19616));
    v266 = *(float *)(a1 + 19472);
    *(float *)(a1 + 19328) = v265 + (float)(*(float *)(a1 + 19584) * *(float *)(a1 + 18880));
    v267 = *(float *)(a1 + 18928);
    v268 = (float)((float)(v266 + *(float *)(a1 + 19456)) * *(float *)(a1 + 19760)) * *(float *)(a1 + 19536);
    *(float *)(a1 + 18928) = v264;
    v269 = v268
         - (float)((float)((float)(v264 * *(float *)(a1 + 20032)) + (float)(v267 * *(float *)(a1 + 20048)))
                 * *(float *)(a1 + 19520));
    if ( v269 >= -1.0 )
      v270 = fminf(v269, 1.0);
    else
      v270 = -1.0;
    v271 = v270 + (float)((float)((float)((float)(v270 * v270) * v270) * v270) * (float)(v270 * *(float *)(a1 + 19696)));
    v272 = *(float *)(a1 + 18848);
    *(float *)(a1 + 18848) = v271;
    v273 = *(float *)(a1 + 18864);
    v274 = (float)(v239 * (float)(v271 + v272)) + (float)(v273 * v244);
    *(float *)(a1 + 18864) = v274;
    v275 = *(float *)(a1 + 18880);
    v276 = v239 * (float)(v274 + v273);
    v277 = v239 * (float)((float)((float)(v239 * v271) + (float)(v244 * v274)) + v274);
    v278 = v276 + (float)(v275 * v244);
    *(float *)(a1 + 18880) = v278;
    v279 = *(float *)(a1 + 18896);
    v280 = (float)(v239 * (float)(v278 + v275)) + (float)(v279 * v244);
    *(float *)(a1 + 18896) = v280;
    v281 = (float)((float)(v279 + v280) * v239) + (float)(v244 * *(float *)(a1 + 18912));
    *(float *)(a1 + 18912) = v281;
    v282 = *(float *)(a1 + 19456);
    v283 = (float)(v239
                 * (float)((float)((float)(v239 * (float)((float)(v277 + (float)(v244 * v278)) + v278))
                                 + (float)(v244 * v280))
                         + v280))
         + (float)(v244 * v281);
    v284 = (float)(*(float *)(a1 + 18896) * *(float *)(a1 + 19600)) + (float)(v281 * *(float *)(a1 + 19616));
    v285 = *(float *)(a1 + 19472);
    *(float *)(a1 + 19200) = v284 + (float)(*(float *)(a1 + 19584) * *(float *)(a1 + 18880));
    v286 = *(float *)(a1 + 18928);
    v287 = (float)((float)(v285 * *(float *)(a1 + 19744)) + (float)(v282 * *(float *)(a1 + 19728)))
         * *(float *)(a1 + 19536);
    *(float *)(a1 + 18928) = v283;
    v288 = v287
         - (float)((float)((float)(v283 * *(float *)(a1 + 20032)) + (float)(v286 * *(float *)(a1 + 20048)))
                 * *(float *)(a1 + 19520));
    if ( v288 >= -1.0 )
      v289 = fminf(v288, 1.0);
    else
      v289 = -1.0;
    v290 = v289 + (float)((float)((float)((float)(v289 * v289) * v289) * v289) * (float)(v289 * *(float *)(a1 + 19696)));
    v291 = *(float *)(a1 + 18848);
    *(float *)(a1 + 18848) = v290;
    v292 = *(float *)(a1 + 18864);
    v293 = (float)(v239 * (float)(v290 + v291)) + (float)(v292 * v244);
    *(float *)(a1 + 18864) = v293;
    v294 = *(float *)(a1 + 18880);
    v295 = v239 * (float)(v293 + v292);
    v296 = v239 * (float)((float)((float)(v239 * v290) + (float)(v244 * v293)) + v293);
    v297 = v295 + (float)(v294 * v244);
    *(float *)(a1 + 18880) = v297;
    v298 = *(float *)(a1 + 18896);
    v299 = (float)(v239 * (float)(v297 + v294)) + (float)(v298 * v244);
    *(float *)(a1 + 18896) = v299;
    v300 = (float)((float)(v298 + v299) * v239) + (float)(v244 * *(float *)(a1 + 18912));
    *(float *)(a1 + 18912) = v300;
    v301 = (float)(v239
                 * (float)((float)((float)(v239 * (float)((float)(v296 + (float)(v244 * v297)) + v297))
                                 + (float)(v244 * v299))
                         + v299))
         + (float)(v244 * v300);
    v302 = (float)(*(float *)(a1 + 18896) * *(float *)(a1 + 19600)) + (float)(v300 * *(float *)(a1 + 19616));
    v303 = *(float *)(a1 + 19456);
    *(float *)(a1 + 19072) = v302 + (float)(*(float *)(a1 + 19584) * *(float *)(a1 + 18880));
    v304 = *(float *)(a1 + 18928);
    v305 = (float)(v303 * *(float *)(a1 + 19712)) * *(float *)(a1 + 19536);
    *(float *)(a1 + 18816) = v301;
    v306 = v305
         - (float)((float)((float)(v301 * *(float *)(a1 + 20032)) + (float)(v304 * *(float *)(a1 + 20048)))
                 * *(float *)(a1 + 19520));
    if ( v306 >= -1.0 )
      v307 = fminf(v306, 1.0);
    else
      v307 = -1.0;
    v308 = v307 + (float)((float)((float)((float)(v307 * v307) * v307) * v307) * (float)(v307 * *(float *)(a1 + 19696)));
    *(float *)(a1 + 18720) = v308;
    v309 = *(float *)(a1 + 18864);
    v310 = (float)(v239 * (float)(v308 + *(float *)(a1 + 18848))) + (float)(v309 * v244);
    *(float *)(a1 + 18736) = v310;
    v311 = *(float *)(a1 + 18880);
    v312 = v239 * (float)(v310 + v309);
    v313 = v239 * (float)((float)((float)(v239 * v308) + (float)(v244 * v310)) + v310);
    v314 = v312 + (float)(v311 * v244);
    *(float *)(a1 + 18752) = v314;
    v315 = *(float *)(a1 + 18896);
    v316 = (float)(v239 * (float)(v314 + v311)) + (float)(v315 * v244);
    *(float *)(a1 + 18768) = v316;
    v317 = (float)((float)(v315 + v316) * v239) + (float)(v244 * *(float *)(a1 + 18912));
    v318 = v239
         * (float)((float)((float)(v239 * (float)((float)(v313 + (float)(v244 * v314)) + v314)) + (float)(v244 * v316))
                 + v316);
    *(float *)(a1 + 18784) = v317;
    v319 = *(float *)(a1 + 18752);
    *(float *)(a1 + 18800) = v318 + (float)(v244 * v317);
    v320 = *(float *)(a1 + 19008);
    v321 = (float)((float)(v317 * *(float *)(a1 + 19616)) + (float)(*(float *)(a1 + 19600) * *(float *)(a1 + 18768)))
         + (float)(v319 * *(float *)(a1 + 19584));
    *(float *)(a1 + 18944) = v321;
    v322 = (float)(v321 + *(float *)(a1 + 19440)) * *(float *)(a1 + 19776);
    v323 = (float)(*(float *)(a1 + 19200) + *(float *)(a1 + 19184)) * *(float *)(a1 + 19808);
    v324 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v320 + *(float *)(a1 + 19376)) * *(float *)(a1 + 20016)) + (float)((float)(*(float *)(a1 + 19136) + *(float *)(a1 + 19248)) * *(float *)(a1 + 20000))) + (float)((float)(*(float *)(a1 + 19264) + *(float *)(a1 + 19120)) * *(float *)(a1 + 19984))) + (float)((float)(*(float *)(a1 + 18992) + *(float *)(a1 + 19392)) * *(float *)(a1 + 19968))) + (float)((float)(*(float *)(a1 + 19360) + *(float *)(a1 + 19024)) * *(float *)(a1 + 19952)))
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
                                 + v323)
                         + (float)((float)(*(float *)(a1 + 19312) + *(float *)(a1 + 19072)) * *(float *)(a1 + 19792)))
                 + v322)
         * *(float *)(a1 + 19664);
    *(float *)(a1 + 19552) = v324;
  }
  *(_DWORD *)(a1 + 20080) = *(_DWORD *)(a1 + 20064);
  v325 = *(_DWORD *)(a1 + 20112);
  *(_DWORD *)(a1 + 20144) = *(_DWORD *)(a1 + 20096);
  *(_DWORD *)(a1 + 20160) = v325;
  *(_DWORD *)(a1 + 20176) = *(_DWORD *)(a1 + 20128);
  v326 = *(float *)(a1 + 20192);
  *(float *)(a1 + 20208) = v326;
  v327 = *(float *)(a1 + 20224);
  *(float *)(a1 + 20240) = v327;
  v328 = (float)((float)(v326 - v327) * *(float *)(a1 + 20256)) + v327;
  *(float *)(a1 + 20224) = v328;
  v329 = (float)((float)(v328 * *(float *)(a1 + 20160)) - (float)(*(float *)(a1 + 20160) * *(float *)(a1 + 20176)))
       + *(float *)(a1 + 20176);
  *(float *)(a1 + 20272) = v329;
  v330 = *(float *)(a1 + 20288);
  *(float *)(a1 + 20304) = v330;
  v331 = (float)((float)(*(float *)(a1 + 20320) * v329) - (float)(*(float *)(a1 + 20320) * v330)) + v330;
  if ( v331 <= 0.0 )
    v332 = 0.0;
  else
    v332 = v331;
  v333 = v332;
  *(float *)(a1 + 20288) = v333;
  v334 = *(float *)(a1 + 20336);
  *(float *)(a1 + 20352) = v334;
  v335 = *(float *)(a1 + 20368);
  *(float *)(a1 + 20384) = v335;
  v336 = (float)((float)(*(float *)(a1 + 20400) * v334) - (float)(*(float *)(a1 + 20400) * v335)) + v335;
  if ( v336 <= 0.0 )
    v337 = 0.0;
  else
    v337 = v336;
  v338 = v337;
  *(float *)(a1 + 20368) = v338;
  v339 = *(float *)(a1 + 20416);
  v340 = *(float *)(a1 + 11072);
  *(float *)(a1 + 20432) = v339;
  v341 = v339 * *(float *)(a1 + 20512);
  v342 = v339 + *(float *)(a1 + 20496);
  if ( v341 >= -1.0 )
    v343 = fminf(v341, 1.0);
  else
    v343 = -1.0;
  if ( (float)(v339 + *(float *)(a1 + 20464)) >= 0.0 )
    v342 = (float)((float)(*(float *)(a1 + 20480) * v340) - (float)(*(float *)(a1 + 20480) * v339)) + v339;
  v344 = (float)((float)(v343 * *(float *)(a1 + 20528)) - (float)(*(float *)(a1 + 20544) * v343))
       + *(float *)(a1 + 20544);
  v345 = (float)((float)(v344 * v340) - (float)(v344 * v339)) + v339;
  if ( v340 != 0.0 )
    v345 = v342;
  *(float *)(a1 + 20448) = v345;
  *(float *)(a1 + 20416) = v345;
  v346 = *(float *)(a1 + 19552);
  v347 = *(float *)(a1 + 13264);
  v348 = *(float *)(a1 + 17360);
  v349 = *(_DWORD *)(a1 + 13744);
  v350 = *(_DWORD *)(a1 + 20064);
  *(_DWORD *)(a1 + 20624) = *(_DWORD *)(a1 + 20608);
  *(_DWORD *)(a1 + 20656) = *(_DWORD *)(a1 + 20640);
  *(_DWORD *)(a1 + 20560) = v349;
  *(_DWORD *)(a1 + 20576) = v350;
  v351 = *(float *)(a1 + 20624);
  v352 = *(float *)(a1 + 20688);
  *(float *)(a1 + 20592) = v348 * *(float *)(a1 + 20848);
  v353 = v346 - v351;
  v354 = *(float *)(a1 + 20720);
  v355 = (float)(v347 * *(float *)(a1 + 20704)) + (float)(v352 * *(float *)(a1 + 20448));
  v356 = v351 + (float)((float)(v346 - v351) * *(float *)(a1 + 20752));
  *(float *)(a1 + 20608) = v356;
  v357 = (float)(v353 * *(float *)(a1 + 20864)) + (float)(v356 * *(float *)(a1 + 20880));
  v358 = (float)((float)(*(float *)(a1 + 20736) * *(float *)(a1 + 20576))
               - (float)(*(float *)(a1 + 20736) * (float)(v355 + (float)(v354 * *(float *)(a1 + 20560)))))
       + (float)(v355 + (float)(v354 * *(float *)(a1 + 20560)));
  v359 = *(float *)(a1 + 20768);
  v360 = v358 * *(float *)(a1 + 20816);
  v361 = v346 * (float)(1.0 - v359);
  if ( v360 <= 0.0 )
    v362 = 0.0;
  else
    v362 = v360;
  v363 = *(float *)(a1 + 20784);
  v364 = v362;
  v365 = v364 * *(float *)(a1 + 20832);
  v366 = (float)((float)(v359 * v357) + v361) * (float)(*(float *)(a1 + 20592) + 1.0);
  v367 = *(float *)(a1 + 20800) * v366;
  v368 = *(float *)(a1 + 20656)
       + (float)((float)(*(float *)(a1 + 20896) * v366) - (float)(*(float *)(a1 + 20896) * *(float *)(a1 + 20656)));
  *(float *)(a1 + 20640) = v368;
  v369 = (float)((float)((float)(v363 * v368) + v367) * v365) * *(float *)(a1 + 20912);
  *(float *)(a1 + 20672) = v369;
  *(_DWORD *)(a1 + 20960) = *(_DWORD *)(a1 + 20944);
  *(_DWORD *)(a1 + 20944) = *(_DWORD *)(a1 + 20928);
  v370 = *(float *)(a1 + 20960);
  v371 = *(float *)(a1 + 20976);
  v372 = v369 - v370;
  *(float *)(a1 + 20928) = v372;
  *(float *)(a1 + 20944) = (float)(v371 * v372) + v370;
  v373 = *(float *)(a1 + 20928);
  v374 = *(float *)(a1 + 20144);
  *(_DWORD *)(a1 + 21040) = *(_DWORD *)(a1 + 21024);
  *(_DWORD *)(a1 + 21024) = *(_DWORD *)(a1 + 21008);
  *(_DWORD *)(a1 + 21008) = *(_DWORD *)(a1 + 20992);
  *(float *)(a1 + 20992) = v373;
  v375 = (float)((float)(*(float *)(a1 + 21008) * *(float *)(a1 + 21088)) + (float)(v373 * *(float *)(a1 + 21072)))
       + (float)(*(float *)(a1 + 21104) * *(float *)(a1 + 21024));
  v376 = (float)((float)(*(float *)(a1 + 21008) * *(float *)(a1 + 21136)) + (float)(v373 * *(float *)(a1 + 21120)))
       + (float)(*(float *)(a1 + 21152) * *(float *)(a1 + 21040));
  if ( v374 <= 0.0 )
    v377 = 0.0;
  else
    v377 = v374;
  *(float *)(a1 + 21008) = v375;
  v378 = v377;
  *(float *)(a1 + 21024) = v376;
  v379 = (float)((float)(v378 * v375) - (float)(v378 * v373)) + v373;
  if ( v374 < -0.0 )
    v19 = (float)-v374;
  v380 = v19;
  v381 = v373 + (float)((float)(v380 * v376) - (float)(v380 * v373));
  if ( v374 >= 0.0 )
    v381 = v379;
  *(float *)(a1 + 21056) = v381;
  v382 = v381 * *(float *)(a1 + 20288);
  *(float *)(a1 + 21168) = v382;
  *(float *)(a1 + 21184) = v382 * *(float *)(a1 + 20368);
  v383 = fmin(fmax((float)(*(float *)(a1 + 14960) + *(float *)(a1 + 14288)), -20.0), 8.9);
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
       * *(float *)(a1 + 14304);
  *(float *)(a1 + 14928) = v390;
  v391 = *(float *)(a1 + 14288);
  v392 = *(_DWORD *)(a1 + 14752);
  v393 = *(_DWORD *)(a1 + 14768);
  LODWORD(v384) = *(_DWORD *)(a1 + 14784);
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
  *(_DWORD *)(a1 + 15248) = v392;
  *(_DWORD *)(a1 + 15264) = v393;
  v394 = v391 + *(float *)(a1 + 16816);
  v395 = v390 * *(float *)(a1 + 16048);
  v396 = *(float *)(a1 + 16032);
  *(_DWORD *)(a1 + 15280) = LODWORD(v384);
  v397 = fmaxf(*(float *)(a1 + 16080), v395);
  v398 = (float)(v394 * *(float *)(a1 + 16832)) + *(float *)(a1 + 16800);
  *(float *)(a1 + 15296) = v397;
  *(float *)(a1 + 15328) = v396 + *(float *)(a1 + 14320);
  if ( v398 <= 0.0 )
    v399 = 0.0;
  else
    v399 = v398;
  *(float *)(a1 + 15312) = 0.00390625 / v397;
  *(float *)(a1 + 15968) = v399;
  v401 = *(unsigned int *)(a1 + 15392);
  v400 = *(_DWORD *)(a1 + 15360);
  *(_DWORD *)(a1 + 15168) = v401;
  *(float *)&v401 = *(float *)&v401 + v397;
  *(_DWORD *)(a1 + 15184) = v400;
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
  *(_DWORD *)(a1 + 15152) = v401;
  v403 = *(float *)&v401 * *(float *)(a1 + 16160);
  *(float *)&v402 = (float)(*(float *)&v401 + 1.0) * 0.5;
  v404 = (float)((float)(sub_180368FC0(v402).m128_f32[0] * 256.0) * *(float *)(a1 + 15312)) * *(float *)(a1 + 16112);
  if ( v404 >= -1.0 )
    v405 = fminf(v404, 1.0);
  else
    v405 = -1.0;
  v406 = v405 * *(float *)(a1 + 16064);
  v407 = (float)(v406 * v406) * v406;
  v408 = v407 * *(float *)(a1 + 16464);
  v409 = *(float *)(a1 + 15328);
  v410 = (float)((float)((float)((float)((float)(v406 * v406) * *(float *)(a1 + 16528)) + *(float *)(a1 + 16512))
                       * (float)((float)(v406 * v406) * (float)(v406 * v406)))
               + (float)((float)((float)(v406 * v406) * *(float *)(a1 + 16496)) + *(float *)(a1 + 16480)))
       * (float)(v407 * (float)(v406 * v406));
  *(_QWORD *)&v411 = LODWORD(v409);
  *(float *)&v411 = v409 + *(float *)&v401;
  *(float *)(a1 + 15408) = (float)((float)(v410 + v408) + v406) * v403;
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
  v414 = *(float *)(a1 + 15152);
  v415 = v413 * *(float *)(a1 + 16176);
  *(float *)&v411 = *(float *)&v411 / v412;
  v416 = sub_180368FC0(v411).m128_f32[0];
  v417 = *(float *)(a1 + 16096);
  if ( v414 < v417 || v417 <= *(float *)(a1 + 15168) )
  {
    v418 = *(unsigned int *)(a1 + 15184);
  }
  else
  {
    v418 = *(unsigned int *)(a1 + 15184);
    *(float *)&v418 = *(float *)&v418 + 2.0;
  }
  v419 = (float)((float)(v416 * *(float *)(a1 + 15312)) * 256.0) * *(float *)(a1 + 16128);
  if ( *(float *)&v418 >= 4.0 )
    v418 = 0;
  if ( v419 >= -1.0 )
    v420 = fminf(v419, 1.0);
  else
    v420 = -1.0;
  *(_DWORD *)(a1 + 15184) = v418;
  v421 = v420 * *(float *)(a1 + 16064);
  *(float *)&v418 = (float)((float)((float)(*(float *)&v418 + v414) + 1.0) * 0.5) - 1.0;
  v422 = (float)((float)((float)((float)((float)((float)((float)((float)(v421 * v421) * *(float *)(a1 + 16528))
                                                       + *(float *)(a1 + 16512))
                                               * (float)((float)(v421 * v421) * (float)(v421 * v421)))
                                       + (float)((float)((float)(v421 * v421) * *(float *)(a1 + 16496))
                                               + *(float *)(a1 + 16480)))
                               * (float)((float)((float)(v421 * v421) * v421) * (float)(v421 * v421)))
                       + (float)((float)((float)(v421 * v421) * v421) * *(float *)(a1 + 16464)))
               + v421)
       * v415;
  *(float *)(a1 + 15424) = v422;
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
  v424 = *(float *)&v418 * *(float *)(a1 + 16192);
  v425 = (float)((float)((float)(v423 + 1.0) * *(float *)(a1 + 15312)) * 512.0) * *(float *)(a1 + 16144);
  if ( v425 >= -1.0 )
    v426 = fminf(v425, 1.0);
  else
    v426 = -1.0;
  v427 = v426 * *(float *)(a1 + 16064);
  v429 = *(unsigned int *)(a1 + 15152);
  v428 = *(_DWORD *)(a1 + 15184);
  *(float *)(a1 + 15456) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v427 * v427)
                                                                                                 * *(float *)(a1 + 16528))
                                                                                         + *(float *)(a1 + 16512))
                                                                                 * (float)((float)(v427 * v427)
                                                                                         * (float)(v427 * v427)))
                                                                         + (float)((float)((float)(v427 * v427)
                                                                                         * *(float *)(a1 + 16496))
                                                                                 + *(float *)(a1 + 16480)))
                                                                 * (float)((float)((float)(v427 * v427) * v427)
                                                                         * (float)(v427 * v427)))
                                                         + (float)((float)((float)(v427 * v427) * v427)
                                                                 * *(float *)(a1 + 16464)))
                                                 + v427)
                                         * v424)
                                 * *(float *)(a1 + 15280))
                         + (float)((float)(*(float *)(a1 + 15408) * *(float *)(a1 + 15248))
                                 + (float)(v422 * *(float *)(a1 + 15264)));
  *(_DWORD *)(a1 + 15168) = v429;
  *(_DWORD *)(a1 + 15184) = v428;
  *(float *)&v429 = *(float *)&v429 + *(float *)(a1 + 15296);
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
  *(_DWORD *)(a1 + 15152) = v429;
  v431 = *(float *)&v429 * *(float *)(a1 + 16160);
  *(float *)&v430 = (float)(*(float *)&v429 + 1.0) * 0.5;
  v432 = (float)((float)(sub_180368FC0(v430).m128_f32[0] * 256.0) * *(float *)(a1 + 15312)) * *(float *)(a1 + 16112);
  if ( v432 >= -1.0 )
    v433 = fminf(v432, 1.0);
  else
    v433 = -1.0;
  v434 = v433 * *(float *)(a1 + 16064);
  v435 = (float)(v434 * v434) * v434;
  v436 = v435 * *(float *)(a1 + 16464);
  v437 = *(float *)(a1 + 15328);
  v438 = (float)((float)((float)((float)((float)(v434 * v434) * *(float *)(a1 + 16528)) + *(float *)(a1 + 16512))
                       * (float)((float)(v434 * v434) * (float)(v434 * v434)))
               + (float)((float)((float)(v434 * v434) * *(float *)(a1 + 16496)) + *(float *)(a1 + 16480)))
       * (float)(v435 * (float)(v434 * v434));
  *(_QWORD *)&v439 = LODWORD(v437);
  *(float *)&v439 = v437 + *(float *)&v429;
  *(float *)(a1 + 15408) = (float)((float)(v438 + v436) + v434) * v431;
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
  v442 = *(float *)(a1 + 15152);
  v443 = v441 * *(float *)(a1 + 16176);
  *(float *)&v439 = *(float *)&v439 / v440;
  v444 = sub_180368FC0(v439).m128_f32[0];
  v445 = *(float *)(a1 + 16096);
  if ( v442 < v445 || v445 <= *(float *)(a1 + 15168) )
  {
    v446 = *(unsigned int *)(a1 + 15184);
  }
  else
  {
    v446 = *(unsigned int *)(a1 + 15184);
    *(float *)&v446 = *(float *)&v446 + 2.0;
  }
  v447 = (float)((float)(v444 * *(float *)(a1 + 15312)) * 256.0) * *(float *)(a1 + 16128);
  if ( *(float *)&v446 >= 4.0 )
    v446 = 0;
  if ( v447 >= -1.0 )
    v448 = fminf(v447, 1.0);
  else
    v448 = -1.0;
  *(_DWORD *)(a1 + 15184) = v446;
  v449 = v448 * *(float *)(a1 + 16064);
  *(float *)&v446 = (float)((float)((float)(*(float *)&v446 + v442) + 1.0) * 0.5) - 1.0;
  v450 = (float)((float)((float)((float)((float)((float)((float)((float)(v449 * v449) * *(float *)(a1 + 16528))
                                                       + *(float *)(a1 + 16512))
                                               * (float)((float)(v449 * v449) * (float)(v449 * v449)))
                                       + (float)((float)((float)(v449 * v449) * *(float *)(a1 + 16496))
                                               + *(float *)(a1 + 16480)))
                               * (float)((float)((float)(v449 * v449) * v449) * (float)(v449 * v449)))
                       + (float)((float)((float)(v449 * v449) * v449) * *(float *)(a1 + 16464)))
               + v449)
       * v443;
  *(float *)(a1 + 15424) = v450;
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
  v452 = *(float *)&v446 * *(float *)(a1 + 16192);
  v453 = (float)((float)((float)(v451 + 1.0) * *(float *)(a1 + 15312)) * 512.0) * *(float *)(a1 + 16144);
  if ( v453 >= -1.0 )
    v454 = fminf(v453, 1.0);
  else
    v454 = -1.0;
  v455 = v454 * *(float *)(a1 + 16064);
  v457 = *(unsigned int *)(a1 + 15152);
  v456 = *(_DWORD *)(a1 + 15184);
  *(float *)(a1 + 15584) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v455 * v455)
                                                                                                 * *(float *)(a1 + 16528))
                                                                                         + *(float *)(a1 + 16512))
                                                                                 * (float)((float)(v455 * v455)
                                                                                         * (float)(v455 * v455)))
                                                                         + (float)((float)((float)(v455 * v455)
                                                                                         * *(float *)(a1 + 16496))
                                                                                 + *(float *)(a1 + 16480)))
                                                                 * (float)((float)((float)(v455 * v455) * v455)
                                                                         * (float)(v455 * v455)))
                                                         + (float)((float)((float)(v455 * v455) * v455)
                                                                 * *(float *)(a1 + 16464)))
                                                 + v455)
                                         * v452)
                                 * *(float *)(a1 + 15280))
                         + (float)((float)(*(float *)(a1 + 15408) * *(float *)(a1 + 15248))
                                 + (float)(v450 * *(float *)(a1 + 15264)));
  *(_DWORD *)(a1 + 15168) = v457;
  *(_DWORD *)(a1 + 15184) = v456;
  *(float *)&v457 = *(float *)&v457 + *(float *)(a1 + 15296);
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
  *(_DWORD *)(a1 + 15152) = v457;
  v459 = *(float *)&v457 * *(float *)(a1 + 16160);
  *(float *)&v458 = (float)(*(float *)&v457 + 1.0) * 0.5;
  v460 = (float)((float)(sub_180368FC0(v458).m128_f32[0] * 256.0) * *(float *)(a1 + 15312)) * *(float *)(a1 + 16112);
  if ( v460 >= -1.0 )
    v461 = fminf(v460, 1.0);
  else
    v461 = -1.0;
  v462 = v461 * *(float *)(a1 + 16064);
  v463 = (float)(v462 * v462) * v462;
  v464 = v463 * *(float *)(a1 + 16464);
  v465 = *(float *)(a1 + 15328);
  v466 = (float)((float)((float)((float)((float)(v462 * v462) * *(float *)(a1 + 16528)) + *(float *)(a1 + 16512))
                       * (float)((float)(v462 * v462) * (float)(v462 * v462)))
               + (float)((float)((float)(v462 * v462) * *(float *)(a1 + 16496)) + *(float *)(a1 + 16480)))
       * (float)(v463 * (float)(v462 * v462));
  *(_QWORD *)&v467 = LODWORD(v465);
  *(float *)&v467 = v465 + *(float *)&v457;
  *(float *)(a1 + 15408) = (float)((float)(v466 + v464) + v462) * v459;
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
  v470 = *(float *)(a1 + 15152);
  v471 = v469 * *(float *)(a1 + 16176);
  *(float *)&v467 = *(float *)&v467 / v468;
  v472 = sub_180368FC0(v467).m128_f32[0];
  v473 = *(float *)(a1 + 16096);
  if ( v470 < v473 || v473 <= *(float *)(a1 + 15168) )
  {
    v474 = *(unsigned int *)(a1 + 15184);
  }
  else
  {
    v474 = *(unsigned int *)(a1 + 15184);
    *(float *)&v474 = *(float *)&v474 + 2.0;
  }
  v475 = (float)((float)(v472 * *(float *)(a1 + 15312)) * 256.0) * *(float *)(a1 + 16128);
  if ( *(float *)&v474 >= 4.0 )
    v474 = 0;
  if ( v475 >= -1.0 )
    v476 = fminf(v475, 1.0);
  else
    v476 = -1.0;
  *(_DWORD *)(a1 + 15184) = v474;
  v477 = v476 * *(float *)(a1 + 16064);
  *(float *)&v474 = (float)((float)((float)(*(float *)&v474 + v470) + 1.0) * 0.5) - 1.0;
  v478 = (float)((float)((float)((float)((float)((float)((float)((float)(v477 * v477) * *(float *)(a1 + 16528))
                                                       + *(float *)(a1 + 16512))
                                               * (float)((float)(v477 * v477) * (float)(v477 * v477)))
                                       + (float)((float)((float)(v477 * v477) * *(float *)(a1 + 16496))
                                               + *(float *)(a1 + 16480)))
                               * (float)((float)((float)(v477 * v477) * v477) * (float)(v477 * v477)))
                       + (float)((float)((float)(v477 * v477) * v477) * *(float *)(a1 + 16464)))
               + v477)
       * v471;
  *(float *)(a1 + 15424) = v478;
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
  v480 = *(float *)&v474 * *(float *)(a1 + 16192);
  v481 = (float)((float)((float)(v479 + 1.0) * *(float *)(a1 + 15312)) * 512.0) * *(float *)(a1 + 16144);
  if ( v481 >= -1.0 )
    v482 = fminf(v481, 1.0);
  else
    v482 = -1.0;
  v483 = v482 * *(float *)(a1 + 16064);
  v485 = *(unsigned int *)(a1 + 15152);
  v484 = *(_DWORD *)(a1 + 15184);
  *(float *)(a1 + 15712) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v483 * v483)
                                                                                                 * *(float *)(a1 + 16528))
                                                                                         + *(float *)(a1 + 16512))
                                                                                 * (float)((float)(v483 * v483)
                                                                                         * (float)(v483 * v483)))
                                                                         + (float)((float)((float)(v483 * v483)
                                                                                         * *(float *)(a1 + 16496))
                                                                                 + *(float *)(a1 + 16480)))
                                                                 * (float)((float)((float)(v483 * v483) * v483)
                                                                         * (float)(v483 * v483)))
                                                         + (float)((float)((float)(v483 * v483) * v483)
                                                                 * *(float *)(a1 + 16464)))
                                                 + v483)
                                         * v480)
                                 * *(float *)(a1 + 15280))
                         + (float)((float)(*(float *)(a1 + 15408) * *(float *)(a1 + 15248))
                                 + (float)(v478 * *(float *)(a1 + 15264)));
  *(_DWORD *)(a1 + 15168) = v485;
  *(_DWORD *)(a1 + 15184) = v484;
  *(float *)&v485 = *(float *)&v485 + *(float *)(a1 + 15296);
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
  *(_DWORD *)(a1 + 15152) = v485;
  v487 = *(float *)&v485 * *(float *)(a1 + 16160);
  *(float *)&v486 = (float)(*(float *)&v485 + 1.0) * 0.5;
  v488 = (float)((float)(sub_180368FC0(v486).m128_f32[0] * 256.0) * *(float *)(a1 + 15312)) * *(float *)(a1 + 16112);
  if ( v488 >= -1.0 )
    v489 = fminf(v488, 1.0);
  else
    v489 = -1.0;
  v490 = v489 * *(float *)(a1 + 16064);
  v491 = (float)(v490 * v490) * v490;
  v492 = v491 * *(float *)(a1 + 16464);
  v493 = *(float *)(a1 + 15328);
  v494 = (float)((float)((float)((float)((float)(v490 * v490) * *(float *)(a1 + 16528)) + *(float *)(a1 + 16512))
                       * (float)((float)(v490 * v490) * (float)(v490 * v490)))
               + (float)((float)((float)(v490 * v490) * *(float *)(a1 + 16496)) + *(float *)(a1 + 16480)))
       * (float)(v491 * (float)(v490 * v490));
  *(_QWORD *)&v495 = LODWORD(v493);
  *(float *)&v495 = v493 + *(float *)&v485;
  *(float *)(a1 + 15408) = (float)((float)(v494 + v492) + v490) * v487;
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
  v498 = *(float *)(a1 + 15152);
  v499 = v497 * *(float *)(a1 + 16176);
  *(float *)&v495 = *(float *)&v495 / v496;
  v500 = sub_180368FC0(v495).m128_f32[0];
  v501 = *(float *)(a1 + 16096);
  if ( v498 < v501 || v501 <= *(float *)(a1 + 15168) )
  {
    v502 = *(unsigned int *)(a1 + 15184);
  }
  else
  {
    v502 = *(unsigned int *)(a1 + 15184);
    *(float *)&v502 = *(float *)&v502 + 2.0;
  }
  v503 = (float)((float)(v500 * *(float *)(a1 + 15312)) * 256.0) * *(float *)(a1 + 16128);
  if ( *(float *)&v502 >= 4.0 )
    v502 = 0;
  if ( v503 >= -1.0 )
    v504 = fminf(v503, 1.0);
  else
    v504 = -1.0;
  *(_DWORD *)(a1 + 15184) = v502;
  v505 = v504 * *(float *)(a1 + 16064);
  *(float *)&v502 = (float)((float)((float)(*(float *)&v502 + v498) + 1.0) * 0.5) - 1.0;
  v506 = (float)((float)((float)((float)((float)((float)((float)((float)(v505 * v505) * *(float *)(a1 + 16528))
                                                       + *(float *)(a1 + 16512))
                                               * (float)((float)(v505 * v505) * (float)(v505 * v505)))
                                       + (float)((float)((float)(v505 * v505) * *(float *)(a1 + 16496))
                                               + *(float *)(a1 + 16480)))
                               * (float)((float)((float)(v505 * v505) * v505) * (float)(v505 * v505)))
                       + (float)((float)((float)(v505 * v505) * v505) * *(float *)(a1 + 16464)))
               + v505)
       * v499;
  *(float *)(a1 + 15424) = v506;
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
  v508 = *(float *)&v502 * *(float *)(a1 + 16192);
  v509 = (float)((float)(v507 * *(float *)(a1 + 15312)) * 512.0) * *(float *)(a1 + 16144);
  if ( v509 >= -1.0 )
    v33 = fminf(v509, 1.0);
  v510 = v33 * *(float *)(a1 + 16064);
  v511 = *(_DWORD *)(a1 + 15152);
  v512 = *(_DWORD *)(a1 + 15184);
  *(float *)(a1 + 15840) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v510 * v510)
                                                                                                 * *(float *)(a1 + 16528))
                                                                                         + *(float *)(a1 + 16512))
                                                                                 * (float)((float)(v510 * v510)
                                                                                         * (float)(v510 * v510)))
                                                                         + (float)((float)((float)(v510 * v510)
                                                                                         * *(float *)(a1 + 16496))
                                                                                 + *(float *)(a1 + 16480)))
                                                                 * (float)((float)((float)(v510 * v510) * v510)
                                                                         * (float)(v510 * v510)))
                                                         + (float)((float)((float)(v510 * v510) * v510)
                                                                 * *(float *)(a1 + 16464)))
                                                 + v510)
                                         * v508)
                                 * *(float *)(a1 + 15280))
                         + (float)((float)(*(float *)(a1 + 15408) * *(float *)(a1 + 15248))
                                 + (float)(v506 * *(float *)(a1 + 15264)));
  v513 = *(float *)(a1 + 15952);
  *(_DWORD *)(a1 + 15376) = v511;
  *(_DWORD *)(a1 + 15344) = v512;
  v514 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(*(float *)(a1 + 15824) + *(float *)(a1 + 15584))
                                                                                               * *(float *)(a1 + 16224))
                                                                                       + (float)((float)(v513 + *(float *)(a1 + 15456))
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
  v515 = *(float *)(a1 + 16000);
  v516 = (float)(v515 * *(float *)(a1 + 16768)) + *(float *)(a1 + 16016);
  v517 = (float)((float)(v514
                       + (float)((float)(*(float *)(a1 + 15904) + *(float *)(a1 + 15504)) * *(float *)(a1 + 16400)))
               + (float)((float)(*(float *)(a1 + 15776) + *(float *)(a1 + 15632)) * *(float *)(a1 + 16416)))
       + (float)((float)(*(float *)(a1 + 15760) + *(float *)(a1 + 15648)) * *(float *)(a1 + 16432));
  v518 = (float)(*(float *)(a1 + 15888) + *(float *)(a1 + 15520)) * *(float *)(a1 + 16448);
  *(float *)(a1 + 16000) = v516;
  v519 = v517 + v518;
  v520 = v519 - (float)((float)(v515 * *(float *)(a1 + 16784)) + v516);
  *(float *)(a1 + 15984) = (float)(v520 * *(float *)(a1 + 16768)) + v515;
  v521 = (float)((float)((float)(v516 - (float)(v520 * *(float *)(a1 + 15968))) * *(float *)(a1 + 16848))
               - (float)(*(float *)(a1 + 16848) * v519))
       + v519;
  *(float *)(a1 + 15440) = v521;
  *(float *)(a1 + 14032) = v521;
  if ( *(float *)(a1 + 101536) == 1.0 )
  {
    *(_DWORD *)(a1 + 10832) = v523;
    *(_DWORD *)(a1 + 101536) = 0;
  }
  **a2 = *(_DWORD *)(a1 + 21184);
  result = *(unsigned int *)(a1 + 21184);
  *a2[1] = result;
  return result;
}

