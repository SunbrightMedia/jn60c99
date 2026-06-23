// sub_180370B90  @ 0x180370B90  (RVA 0x370B90)
// prototype: 
// callees: 0x180368D60, 0x180368FC0, 0x180370B90, 0x1806EF4D8, 0x1806EF740
// constants/globals referenced:
//   0x180AE50B4 [.rdata] dword_180AE50B4  u32=1065353216  f32=1.0  f64=1.999159278904387e+37
//   0x18098ADC4 [.rdata] dword_18098ADC4  u32=3414163456  f32=-16777216.0  f64=1.7485361358319832e-185
//   0x18098AC70 [.rdata] dword_18098AC70  u32=864026624  f32=5.960464477539063e-08  f64=3.493706737605413e-30
//   0x180AE54E4 [.rdata] dword_180AE54E4  u32=3212836864  f32=-1.0  f64=-0.19579645968042314
//   0x180AE51A0 [.rdata] dbl_180AE51A0  u32=0  f32=0.0  f64=1.0
//   0x180AE5790 [.rdata] xmmword_180AE5790  u32=2147483647  f32=nan  f64=nan
//   0x180000000 [?]   u32=4294967295  f32=nan  f64=nan
//   0x18098ACC0 [.rdata] dword_18098ACC0  u32=1056964608  f32=0.5  f64=1.1920931752840147e-07
//   0x18098AD3C [.rdata] dword_18098AD3C  u32=796917760  f32=2.3283064365386963e-10  f64=2.0000003539025784
//   0x180AE57C0 [.rdata] xmmword_180AE57C0  u32=2147483648  f32=-0.0  f64=-1.0609978955e-314
//   0x18098ADC0 [.rdata] dword_18098ADC0  u32=931135488  f32=1.52587890625e-05  f64=-4.903986744687605e+55
//   0x180AE51E8 [.rdata] flt_180AE51E8  u32=1073741824  f32=2.0  f64=5.304989477e-315
//   0x180AE4F5C [.rdata] dword_180AE4F5C  u32=998244352  f32=0.00390625  f64=1.2923696517834199e-19
//   0x180AE4FD0 [.rdata] dword_180AE4FD0  u32=1048576000  f32=0.25  f64=2.035141328793344e-07
//   0x180AE54C0 [.rdata] dword_180AE54C0  u32=2147483648  f32=-0.0  f64=-4.235166755755419e-22
//   0x18098ACA8 [.rdata] qword_18098ACA8  u32=0  f32=0.0  f64=-20.0
//   0x18098AC90 [.rdata] qword_18098AC90  u32=3435973837  f32=-107374184.0  f64=8.9
//   0x180AE5268 [.rdata] qword_180AE5268  u32=0  f32=0.0  f64=20.0
//   0x1809894E0 [.rdata] unk_1809894E0  u32=2544773533  f32=-1.125499112092187e-24  f64=-1.04544886827589
//   0x18098AC98 [.rdata] dword_18098AC98  u32=1140850688  f32=512.0  f64=2.4178522517188077e+24
//   0x18098ACB0 [.rdata] dword_18098ACB0  u32=3288334336  f32=-512.0  f64=-2.4178534046403123e+24
//   0x180AE500C [.rdata] dword_180AE500C  u32=1056964608  f32=0.5  f64=-5.266384416506561e+184
//   0x180AE5444 [.rdata] dword_180AE5444  u32=1132462080  f32=256.0  f64=5.3142482850729165e+17
//   0x180AE52D0 [.rdata] dword_180AE52D0  u32=1082130432  f32=4.0  f64=5.34643471e-315

__int64 __fastcall sub_180370B90(__int64 a1, _DWORD **a2)
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
  float v223; // xmm9_4
  float v224; // xmm0_4
  float v225; // xmm3_4
  float v226; // xmm9_4
  __m128 v227; // xmm7
  float v228; // xmm8_4
  float v229; // xmm0_4
  float v230; // xmm6_4
  float v231; // xmm6_4
  float v232; // xmm2_4
  float v233; // xmm1_4
  int v234; // ecx
  float v235; // xmm7_4
  float v236; // xmm6_4
  float v237; // xmm4_4
  float v238; // xmm3_4
  float v239; // xmm8_4
  float v240; // xmm8_4
  float v241; // xmm1_4
  float v242; // xmm9_4
  float v243; // xmm0_4
  float v244; // xmm6_4
  float v245; // xmm6_4
  float v246; // xmm3_4
  float v247; // xmm1_4
  float v248; // xmm5_4
  float v249; // xmm5_4
  float v250; // xmm2_4
  float v251; // xmm1_4
  float v252; // xmm0_4
  float v253; // xmm5_4
  float v254; // xmm5_4
  float v255; // xmm5_4
  float v256; // xmm3_4
  float v257; // xmm4_4
  float v258; // xmm1_4
  float v259; // xmm3_4
  float v260; // xmm4_4
  float v261; // xmm3_4
  float v262; // xmm5_4
  float v263; // xmm2_4
  float v264; // xmm5_4
  float v265; // xmm4_4
  float v266; // xmm2_4
  float v267; // xmm5_4
  float v268; // xmm0_4
  float v269; // xmm5_4
  float v270; // xmm5_4
  float v271; // xmm5_4
  float v272; // xmm5_4
  float v273; // xmm1_4
  float v274; // xmm3_4
  float v275; // xmm4_4
  float v276; // xmm1_4
  float v277; // xmm3_4
  float v278; // xmm4_4
  float v279; // xmm3_4
  float v280; // xmm5_4
  float v281; // xmm2_4
  float v282; // xmm5_4
  float v283; // xmm1_4
  float v284; // xmm4_4
  float v285; // xmm2_4
  float v286; // xmm5_4
  float v287; // xmm0_4
  float v288; // xmm5_4
  float v289; // xmm5_4
  float v290; // xmm5_4
  float v291; // xmm5_4
  float v292; // xmm1_4
  float v293; // xmm3_4
  float v294; // xmm4_4
  float v295; // xmm1_4
  float v296; // xmm3_4
  float v297; // xmm4_4
  float v298; // xmm3_4
  float v299; // xmm5_4
  float v300; // xmm2_4
  float v301; // xmm5_4
  float v302; // xmm3_4
  float v303; // xmm1_4
  float v304; // xmm5_4
  float v305; // xmm0_4
  float v306; // xmm5_4
  float v307; // xmm5_4
  float v308; // xmm5_4
  float v309; // xmm5_4
  float v310; // xmm3_4
  float v311; // xmm4_4
  float v312; // xmm1_4
  float v313; // xmm3_4
  float v314; // xmm4_4
  float v315; // xmm3_4
  float v316; // xmm5_4
  float v317; // xmm2_4
  float v318; // xmm5_4
  float v319; // xmm8_4
  float v320; // xmm3_4
  float v321; // xmm4_4
  float v322; // xmm5_4
  float v323; // xmm5_4
  float v324; // xmm0_4
  float v325; // xmm4_4
  int v326; // xmm0_4
  float v327; // xmm2_4
  float v328; // xmm0_4
  float v329; // xmm2_4
  float v330; // xmm2_4
  float v331; // xmm1_4
  float v332; // xmm3_4
  double v333; // xmm0_8
  float v334; // xmm0_4
  float v335; // xmm1_4
  float v336; // xmm2_4
  float v337; // xmm3_4
  double v338; // xmm0_8
  float v339; // xmm0_4
  float v340; // xmm5_4
  float v341; // xmm6_4
  float v342; // xmm4_4
  float v343; // xmm3_4
  float v344; // xmm4_4
  float v345; // xmm2_4
  float v346; // xmm0_4
  float v347; // xmm7_4
  float v348; // xmm6_4
  float v349; // xmm3_4
  int v350; // xmm0_4
  int v351; // xmm1_4
  float v352; // xmm4_4
  float v353; // xmm2_4
  float v354; // xmm3_4
  float v355; // xmm1_4
  float v356; // xmm6_4
  float v357; // xmm4_4
  float v358; // xmm3_4
  float v359; // xmm1_4
  float v360; // xmm6_4
  float v361; // xmm1_4
  float v362; // xmm7_4
  double v363; // xmm0_8
  float v364; // xmm4_4
  float v365; // xmm5_4
  float v366; // xmm5_4
  float v367; // xmm6_4
  float v368; // xmm2_4
  float v369; // xmm3_4
  float v370; // xmm4_4
  float v371; // xmm0_4
  float v372; // xmm1_4
  float v373; // xmm4_4
  float v374; // xmm2_4
  float v375; // xmm6_4
  float v376; // xmm5_4
  float v377; // xmm4_4
  double v378; // xmm0_8
  float v379; // xmm3_4
  float v380; // xmm3_4
  float v381; // xmm1_4
  float v382; // xmm2_4
  float v383; // xmm2_4
  double v384; // xmm12_8
  double v385; // xmm2_8
  double *v386; // rax
  double v387; // xmm4_8
  double v388; // xmm6_8
  double v389; // xmm9_8
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
  int v401; // xmm1_4
  __int64 v402; // xmm6_8
  double v403; // xmm0_8
  float v404; // xmm7_4
  float v405; // xmm5_4
  float v406; // xmm5_4
  float v407; // xmm5_4
  float v408; // xmm0_4
  float v409; // xmm3_4
  float v410; // xmm1_4
  float v411; // xmm4_4
  double v412; // xmm0_8
  float v413; // xmm1_4
  float v414; // xmm6_4
  float v415; // xmm8_4
  float v416; // xmm6_4
  float v417; // xmm4_4
  float v418; // xmm0_4
  __int64 v419; // xmm7_8
  float v420; // xmm4_4
  float v421; // xmm4_4
  float v422; // xmm4_4
  float v423; // xmm9_4
  float v424; // xmm0_4
  float v425; // xmm7_4
  float v426; // xmm8_4
  float v427; // xmm8_4
  float v428; // xmm8_4
  int v429; // xmm5_4
  __int64 v430; // xmm6_8
  double v431; // xmm0_8
  float v432; // xmm7_4
  float v433; // xmm5_4
  float v434; // xmm5_4
  float v435; // xmm5_4
  float v436; // xmm0_4
  float v437; // xmm3_4
  float v438; // xmm1_4
  float v439; // xmm4_4
  double v440; // xmm0_8
  float v441; // xmm1_4
  float v442; // xmm6_4
  float v443; // xmm8_4
  float v444; // xmm6_4
  float v445; // xmm4_4
  float v446; // xmm0_4
  __int64 v447; // xmm7_8
  float v448; // xmm4_4
  float v449; // xmm4_4
  float v450; // xmm4_4
  float v451; // xmm9_4
  float v452; // xmm0_4
  float v453; // xmm7_4
  float v454; // xmm8_4
  float v455; // xmm8_4
  float v456; // xmm8_4
  int v457; // xmm5_4
  __int64 v458; // xmm6_8
  double v459; // xmm0_8
  float v460; // xmm7_4
  float v461; // xmm5_4
  float v462; // xmm5_4
  float v463; // xmm5_4
  float v464; // xmm0_4
  float v465; // xmm3_4
  float v466; // xmm1_4
  float v467; // xmm4_4
  double v468; // xmm0_8
  float v469; // xmm1_4
  float v470; // xmm6_4
  float v471; // xmm8_4
  float v472; // xmm6_4
  float v473; // xmm4_4
  float v474; // xmm0_4
  __int64 v475; // xmm7_8
  float v476; // xmm4_4
  float v477; // xmm4_4
  float v478; // xmm4_4
  float v479; // xmm9_4
  float v480; // xmm0_4
  float v481; // xmm7_4
  float v482; // xmm8_4
  float v483; // xmm8_4
  float v484; // xmm8_4
  int v485; // xmm5_4
  __int64 v486; // xmm6_8
  double v487; // xmm0_8
  float v488; // xmm7_4
  float v489; // xmm5_4
  float v490; // xmm5_4
  float v491; // xmm5_4
  float v492; // xmm0_4
  float v493; // xmm3_4
  float v494; // xmm1_4
  float v495; // xmm4_4
  double v496; // xmm0_8
  float v497; // xmm1_4
  float v498; // xmm6_4
  float v499; // xmm8_4
  float v500; // xmm6_4
  float v501; // xmm4_4
  float v502; // xmm0_4
  __int64 v503; // xmm7_8
  float v504; // xmm4_4
  float v505; // xmm4_4
  float v506; // xmm4_4
  float v507; // xmm8_4
  float v508; // xmm0_4
  float v509; // xmm7_4
  float v510; // xmm0_4
  float v511; // xmm15_4
  int v512; // xmm5_4
  int v513; // xmm6_4
  float v514; // xmm2_4
  float v515; // xmm5_4
  float v516; // xmm2_4
  float v517; // xmm4_4
  float v518; // xmm5_4
  float v519; // xmm1_4
  float v520; // xmm5_4
  float v521; // xmm3_4
  float v522; // xmm4_4
  __int64 result; // rax
  int v524; // [rsp+D0h] [rbp+8h]
  float v525; // [rsp+E0h] [rbp+18h]

  v2 = *(float *)(a1 + 21344);
  v524 = 0;
  if ( *(float *)(a1 + 101568) == 1.0 )
  {
    v524 = *(_DWORD *)(a1 + 21344);
    v2 = 0.0;
    *(_DWORD *)(a1 + 21344) = 0;
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
  v11 = *(float *)(a1 + 21232);
  v12 = *(float *)(a1 + 21200);
  v13 = v9 & 0xFFFFFF;
  v14 = *(float *)(a1 + 21392);
  v15 = v9;
  v16 = *(float *)(a1 + 21408);
  v17 = v9 | 0xFF000000;
  v18 = v6 * v7;
  *(_DWORD *)(a1 + 21456) = 0;
  *(float *)(a1 + 21248) = v11;
  v19 = 0.0;
  if ( (v15 & 0x1000000) == 0 )
    v17 = v13;
  *(float *)(a1 + 21216) = v12;
  *(_DWORD *)(a1 + 84384) = *(_DWORD *)(a1 + 84368);
  *(_DWORD *)(a1 + 21536) = *(_DWORD *)(a1 + 21520);
  *(float *)(a1 + 21376) = v2;
  v20 = (float)v17 * 0.000000059604645;
  *(float *)(a1 + 21424) = v14;
  *(float *)(a1 + 21440) = v16;
  *(float *)(a1 + 84336) = v20;
  v21 = (float)(v20 * *(float *)(a1 + 84400)) + *(float *)(a1 + 84416);
  *(float *)(a1 + 84368) = v21;
  v22 = v18 - (float)(v7 * v21);
  v23 = *(float *)(a1 + 21296);
  *(float *)(a1 + 21312) = v23;
  v24 = v22 + v21;
  v25 = *(float *)(a1 + 21264);
  v26 = v23 * v25;
  *(float *)(a1 + 21280) = v25;
  *(float *)(a1 + 84432) = v24;
  v27 = *(float *)(a1 + 21328);
  *(float *)(a1 + 21360) = v27;
  *(float *)(a1 + 21472) = v26;
  v28 = (float)((float)(v12 * v26) - (float)(v26 * v27)) + v27;
  v29 = (float)((float)(v11 * v26) - (float)(v2 * v26)) + v2;
  *(float *)(a1 + 21488) = v28;
  *(float *)(a1 + 21504) = v29;
  v30 = v29;
  v31 = v29 + *(float *)(a1 + 21568);
  if ( v31 < 0.0 )
    v32 = v31;
  else
    v32 = 0.0;
  v33 = -1.0;
  if ( v30 == 0.0 )
    v34 = -1.0;
  else
    v34 = v32;
  *(float *)(a1 + 21520) = v34;
  if ( v34 >= 0.0 )
  {
    if ( v34 > 0.0 )
      v34 = 1.0;
  }
  else
  {
    v34 = -1.0;
  }
  v35 = *(float *)(a1 + 21632);
  v36 = v34 + 1.0;
  v37 = *(float *)(a1 + 21792);
  v38 = *(float *)(a1 + 21648);
  v39 = *(_DWORD *)(a1 + 21584);
  v40 = *(float *)(a1 + 21728);
  v41 = v38 + *(float *)(a1 + 21808);
  v42 = 1.0;
  *(float *)(a1 + 21552) = v36;
  *(float *)(a1 + 21584) = v36;
  *(_DWORD *)(a1 + 21600) = v39;
  *(float *)(a1 + 21744) = v40;
  v43 = (float)(v36 * v35) - v35;
  v44 = *(float *)(a1 + 21840);
  v45 = (float)(v43 + 1.0) * *(float *)(a1 + 21616);
  v46 = (float)(*(float *)(a1 + 21696) / (float)((float)(v37 * v38) + *(float *)(a1 + 21824))) * v37;
  v47 = *(float *)(a1 + 21680);
  *(float *)(a1 + 21760) = v45;
  v48 = v47 - v46;
  v49 = *(float *)(a1 + 21712);
  v50 = (float)(v48 + v28) - v40;
  *(float *)(a1 + 21680) = v50;
  v51 = v50 * v41;
  *(float *)(a1 + 21696) = v51;
  v52 = v51 + v40;
  if ( (float)(v44 - fabs(v40 - v28)) < 0.0 )
  {
    v53 = 0.0;
LABEL_25:
    v54 = v53;
    goto LABEL_26;
  }
  v53 = v49 + *(float *)(a1 + 21856);
  if ( v53 < 1.0 )
    goto LABEL_25;
  v54 = 1.0;
LABEL_26:
  v55 = v54;
  *(float *)(a1 + 21712) = v55;
  v56 = (float)((float)(v55 * v28) - (float)(v55 * v52)) + v52;
  if ( v45 == 0.0 )
    v56 = v28;
  v57 = v16 * *(float *)(a1 + 21888);
  *(_DWORD *)(a1 + 21920) = *(_DWORD *)(a1 + 21904);
  v58 = *(float *)(a1 + 22192);
  v59 = *(float *)(a1 + 21936);
  v60 = *(_DWORD *)(a1 + 22032);
  v61 = v57 + (float)(v14 * *(float *)(a1 + 21872));
  v62 = *(_DWORD *)(a1 + 22000);
  v63 = (int)v58;
  *(float *)(a1 + 21904) = v61;
  v64 = *(float *)(a1 + 21968);
  *(float *)(a1 + 21728) = v56;
  *(float *)(a1 + 21776) = v56;
  v65 = *(float *)(a1 + 22128);
  *(float *)(a1 + 21984) = v64;
  *(float *)(a1 + 21952) = v59;
  *(_DWORD *)(a1 + 22016) = v62;
  *(_DWORD *)(a1 + 22048) = v60;
  *(float *)(a1 + 22144) = v65;
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
  v67 = *(float *)(a1 + 22064);
  v68 = (float)((float)(v59 - v65) * *(float *)(a1 + 22176)) + v65;
  v69 = *(float *)(a1 + 22112);
  *(float *)(a1 + 22128) = v68;
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
  v74 = *(float *)(a1 + 22080);
  v75 = expf((float)v73 * *(float *)(a1 + 22224)) * *(float *)(a1 + 22208);
  v76 = v74 * *(float *)(a1 + 22096);
  *(_DWORD *)(a1 + 22608) = *(_DWORD *)(a1 + 22592);
  v77 = v75 + *(float *)(a1 + 22240);
  v78 = *(float *)(a1 + 22528);
  v79 = v64 * *(float *)(a1 + 22928);
  *(_DWORD *)(a1 + 22640) = *(_DWORD *)(a1 + 22624);
  v80 = *(float *)(a1 + 22512);
  v81 = *(float *)(a1 + 22560);
  *(_DWORD *)(a1 + 22672) = *(_DWORD *)(a1 + 22656);
  v82 = *(_DWORD *)(a1 + 84432);
  *(float *)(a1 + 22544) = v78;
  *(float *)(a1 + 22528) = v80;
  *(float *)(a1 + 22576) = v81;
  *(_DWORD *)(a1 + 22464) = v62;
  *(_DWORD *)(a1 + 22480) = v60;
  *(_DWORD *)(a1 + 22448) = v82;
  v83 = (float)(v76 - (float)(v74 * v77)) + v77;
  v84 = *(float *)(a1 + 22880);
  v85 = v79 + v84;
  *(float *)(a1 + 22864) = v84;
  *(float *)(a1 + 22160) = v83;
  if ( v85 >= -1.0 )
    v86 = fminf(v85, 1.0);
  else
    v86 = -1.0;
  v87 = *(unsigned int *)(a1 + 23152);
  *(float *)(a1 + 22512) = v86;
  *(float *)&v87 = fminf(*(float *)&v87, v83 * 0.000015258789);
  v88 = (float)((float)(1.0 - v78) * *(float *)(a1 + 22944)) + v78;
  if ( v88 >= -1.0 )
    v89 = fminf(v88, 1.0);
  else
    v89 = -1.0;
  v90 = *(float *)&v87 * *(float *)(a1 + 23168);
  v91 = v80 - v86;
  *(float *)(a1 + 22688) = v90;
  v92 = v90 + v81;
  if ( v91 < 0.0 )
    v89 = 0.0;
  v93 = *(float *)(a1 + 22896);
  v94 = *(float *)(a1 + 22448);
  *(float *)(a1 + 22528) = v89;
  v95 = v89 + *(float *)(a1 + 23296);
  if ( v91 >= 0.0 )
    v93 = 1.0;
  v96 = v95 * *(float *)(a1 + 23280);
  *(float *)&v87 = (float)(v92 * v93) * *(float *)(a1 + 22912);
  if ( v96 <= 0.0 )
    v97 = 0.0;
  else
    v97 = v96;
  v98 = v97;
  v99 = (float)((float)(v94 - *(float *)(a1 + 22608)) * *(float *)(a1 + 23488)) + *(float *)(a1 + 22608);
  *(float *)(a1 + 22592) = v99;
  *(float *)(a1 + 22496) = v98;
  v525 = *(float *)(a1 + 22576);
  v100 = (float)((float)((float)(v99 * *(float *)(a1 + 23472)) * *(float *)(a1 + 23088))
               - (float)(v94 * *(float *)(a1 + 23088)))
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
  v101 = *(float *)(a1 + 22640);
  *(_DWORD *)(a1 + 22560) = v87;
  v102 = *(float *)&v87 + *(float *)(a1 + 23312);
  *(float *)(a1 + 22432) = v100 * *(float *)(a1 + 23456);
  if ( v525 < 0.0 && *(float *)&v87 > 0.0 )
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
  *(float *)(a1 + 22624) = v101;
  v103 = v101 * *(float *)(a1 + 23440);
  v104 = (float)(v102 * *(float *)(a1 + 23376)) + *(float *)(a1 + 23504);
  *(float *)(a1 + 22704) = v104;
  *(float *)(a1 + 22784) = v103;
  HIDWORD(v105) = HIDWORD(v87);
  *(float *)&v105 = *(float *)&v87 + *(float *)(a1 + 23344);
  *(float *)(a1 + 22720) = -v104;
  if ( *(float *)&v105 <= 1.0 )
  {
    if ( *(float *)&v105 < -1.0 )
      *(float *)&v105 = fmodf(*(float *)&v105 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v105 = fmodf(*(float *)&v105 + 1.0, 2.0) - 1.0;
  }
  v106 = *(float *)&v87 + *(float *)(a1 + 23328);
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
  v108 = v106 + *(float *)(a1 + 23520);
  v109 = v107 * *(float *)(a1 + 23408);
  if ( v108 >= 0.0 )
  {
    if ( v108 > 0.0 )
      v108 = 1.0;
  }
  else
  {
    v108 = -1.0;
  }
  v110 = *(float *)&v87 + *(float *)(a1 + 23360);
  *(float *)(a1 + 22752) = v109;
  *(float *)(a1 + 22848) = v108;
  v111 = (float)(v108 * *(float *)(a1 + 23392)) + *(float *)(a1 + 23536);
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
  *(float *)(a1 + 22736) = v111;
  v113 = *(float *)(a1 + 22992);
  v114 = (float)((float)(*(float *)(a1 + 23056) * *(float *)(a1 + 22784))
               + (float)(*(float *)(a1 + 23024) * *(float *)(a1 + 22704)))
       + (float)(*(float *)(a1 + 23040) * *(float *)(a1 + 22720));
  v115 = (float)((float)((float)((float)(v112 * (float)((float)(v112 * v112) * v112)) * *(float *)(a1 + 23248))
                       + (float)((float)((float)((float)(v112 * v112) * v112) * *(float *)(a1 + 23232))
                               + (float)((float)((float)(v112 * *(float *)(a1 + 23200)) + *(float *)(a1 + 23184))
                                       + (float)((float)(v112 * v112) * *(float *)(a1 + 23216)))))
               + *(float *)(a1 + 23264))
       * *(float *)(a1 + 23424);
  *(float *)(a1 + 22768) = v115;
  v116 = (float)(v113 * *(float *)(a1 + 22752)) + v114;
  v117 = *(float *)(a1 + 23104);
  v118 = (float)((float)(*(float *)(a1 + 22960) * *(float *)(a1 + 22496)) - *(float *)(a1 + 22960)) + 1.0;
  v119 = (float)((float)(v116 + (float)(*(float *)(a1 + 23008) * *(float *)(a1 + 22736)))
               + (float)(v115 * *(float *)(a1 + 22976)))
       + (float)(*(float *)(a1 + 23072) * *(float *)(a1 + 22432));
  *(float *)(a1 + 22800) = v118;
  *(float *)(a1 + 22832) = v119;
  *(float *)(a1 + 22816) = (float)((float)(*(float *)(a1 + 23136) * *(float *)(a1 + 22480))
                                 + (float)(*(float *)(a1 + 23120) * *(float *)(a1 + 22464)))
                         + (float)((float)(v117 * v118) * v119);
  v120 = *(_DWORD *)(a1 + 22832);
  *(_DWORD *)(a1 + 23552) = *(_DWORD *)(a1 + 22848);
  *(_DWORD *)(a1 + 23568) = v120;
  if ( *(float *)(a1 + 22848) <= 0.0 )
    v121 = 0.0;
  else
    v121 = 1.0;
  if ( *(float *)(a1 + 23584) == 0.0 )
    v121 = 1.0;
  v122 = *(float *)(a1 + 21584) * v121;
  *(float *)(a1 + 23600) = v122;
  *(_DWORD *)(a1 + 23632) = *(_DWORD *)(a1 + 23616);
  *(_DWORD *)(a1 + 23680) = *(_DWORD *)(a1 + 23664);
  *(_DWORD *)(a1 + 23664) = *(_DWORD *)(a1 + 23648);
  *(_DWORD *)(a1 + 23712) = *(_DWORD *)(a1 + 23696);
  *(_DWORD *)(a1 + 23760) = *(_DWORD *)(a1 + 23744);
  if ( (float)(v122 + *(float *)(a1 + 23888)) >= 0.0 )
    v123 = 0.0;
  else
    v123 = 1.0;
  v124 = 1.0 - v123;
  v125 = (float)(1.0 - v123)
       * (float)((float)(*(float *)(a1 + 23920) * *(float *)(a1 + 23680)) + *(float *)(a1 + 23632));
  *(float *)(a1 + 23648) = v125;
  v126 = v125 + *(float *)(a1 + 23904);
  v127 = v125 - *(float *)(a1 + 23664);
  *(float *)(a1 + 23728) = (float)((float)(*(float *)(a1 + 23872) * *(float *)(a1 + 23984))
                                 - (float)(*(float *)(a1 + 23952) * *(float *)(a1 + 23872)))
                         + *(float *)(a1 + 23952);
  if ( v126 < 0.0 )
    v128 = 0.0;
  else
    v128 = 1.0;
  if ( v127 < 0.0 )
    v128 = 1.0 - v123;
  v129 = *(float *)(a1 + 23808);
  v130 = v124 * (float)(*(float *)(a1 + 23824) * *(float *)(a1 + 23952));
  *(float *)(a1 + 23664) = v128;
  v131 = *(float *)(a1 + 23712);
  v132 = (float)(v130 - (float)(*(float *)(a1 + 23968) * v124)) + *(float *)(a1 + 23968);
  v133 = v124 * (float)(1.0 - v128);
  v134 = (float)((float)(*(float *)(a1 + 23840) * 0.00390625) * v128) + (float)((float)(v129 * 0.00390625) * v133);
  if ( (float)(v132 - v131) > 0.0 )
    v132 = v131 + *(float *)(a1 + 23728);
  v135 = *(float *)(a1 + 23632);
  v136 = fminf(*(float *)(a1 + 23952), v132);
  *(float *)(a1 + 23696) = v136;
  v137 = *(float *)(a1 + 23856);
  v138 = (float)((float)(v133 * *(float *)(a1 + 23936)) + (float)(v128 * v136)) - v135;
  v139 = (float)((float)(*(float *)(a1 + 24000) * v134) - (float)(*(float *)(a1 + 24000) * *(float *)(a1 + 23760)))
       + *(float *)(a1 + 23760);
  *(float *)(a1 + 23744) = v139;
  v140 = (float)((float)((float)((float)((float)(v137 * 0.00390625) * v123) - (float)(v123 * v139)) + v139) * v138)
       + v135;
  *(float *)(a1 + 23616) = v140;
  v141 = (float)(v140 * *(float *)(a1 + 24016)) * *(float *)(a1 + 24032);
  v142 = v141 * *(float *)(a1 + 24048);
  *(float *)(a1 + 23776) = v141;
  *(float *)(a1 + 23792) = v142;
  if ( *(float *)(a1 + 22848) <= 0.0 )
    v143 = 0.0;
  else
    v143 = 1.0;
  if ( *(float *)(a1 + 24064) == 0.0 )
    v143 = 1.0;
  v144 = *(float *)(a1 + 21584) * v143;
  *(float *)(a1 + 24080) = v144;
  *(_DWORD *)(a1 + 24112) = *(_DWORD *)(a1 + 24096);
  *(_DWORD *)(a1 + 24160) = *(_DWORD *)(a1 + 24144);
  *(_DWORD *)(a1 + 24144) = *(_DWORD *)(a1 + 24128);
  *(_DWORD *)(a1 + 24192) = *(_DWORD *)(a1 + 24176);
  *(_DWORD *)(a1 + 24240) = *(_DWORD *)(a1 + 24224);
  if ( (float)(v144 + *(float *)(a1 + 24368)) >= 0.0 )
    v145 = 0.0;
  else
    v145 = 1.0;
  v146 = 1.0 - v145;
  v147 = (float)(1.0 - v145)
       * (float)((float)(*(float *)(a1 + 24400) * *(float *)(a1 + 24160)) + *(float *)(a1 + 24112));
  *(float *)(a1 + 24128) = v147;
  v148 = v147 + *(float *)(a1 + 24384);
  v149 = v147 - *(float *)(a1 + 24144);
  *(float *)(a1 + 24208) = (float)((float)(*(float *)(a1 + 24352) * *(float *)(a1 + 24464))
                                 - (float)(*(float *)(a1 + 24432) * *(float *)(a1 + 24352)))
                         + *(float *)(a1 + 24432);
  if ( v148 < 0.0 )
    v150 = 0.0;
  else
    v150 = 1.0;
  if ( v149 < 0.0 )
    v150 = 1.0 - v145;
  v151 = *(float *)(a1 + 24304) * *(float *)(a1 + 24432);
  v152 = *(float *)(a1 + 24288);
  *(float *)(a1 + 24144) = v150;
  v153 = *(float *)(a1 + 24192);
  v154 = (float)((float)(v146 * v151) - (float)(*(float *)(a1 + 24448) * v146)) + *(float *)(a1 + 24448);
  v155 = v146 * (float)(1.0 - v150);
  v156 = (float)((float)(*(float *)(a1 + 24320) * 0.00390625) * v150) + (float)((float)(v152 * 0.00390625) * v155);
  if ( (float)(v154 - v153) > 0.0 )
    v154 = v153 + *(float *)(a1 + 24208);
  v157 = *(float *)(a1 + 24112);
  v158 = fminf(*(float *)(a1 + 24432), v154);
  *(float *)(a1 + 24176) = v158;
  v159 = (float)(*(float *)(a1 + 24336) * 0.00390625) * v145;
  v160 = (float)((float)(v155 * *(float *)(a1 + 24416)) + (float)(v150 * v158)) - v157;
  v161 = (float)((float)(*(float *)(a1 + 24480) * v156) - (float)(*(float *)(a1 + 24480) * *(float *)(a1 + 24240)))
       + *(float *)(a1 + 24240);
  *(float *)(a1 + 24224) = v161;
  v162 = (float)((float)((float)(v159 - (float)(v145 * v161)) + v161) * v160) + v157;
  *(float *)(a1 + 24096) = v162;
  v163 = (float)(v162 * *(float *)(a1 + 24496)) * *(float *)(a1 + 24512);
  v164 = v163 * *(float *)(a1 + 24528);
  *(float *)(a1 + 24256) = v163;
  *(float *)(a1 + 24272) = v164;
  *(_DWORD *)(a1 + 24560) = *(_DWORD *)(a1 + 24544);
  *(_DWORD *)(a1 + 24592) = *(_DWORD *)(a1 + 24576);
  v165 = *(float *)(a1 + 21776);
  v166 = *(float *)(a1 + 21904);
  *(_DWORD *)(a1 + 24656) = *(_DWORD *)(a1 + 24640);
  v167 = (float)(v166 * *(float *)(a1 + 24624)) + (float)(v165 * *(float *)(a1 + 24608));
  *(float *)(a1 + 24640) = v167;
  v168 = *(float *)(a1 + 22816);
  v169 = *(_DWORD *)(a1 + 23776);
  v170 = *(_DWORD *)(a1 + 24256);
  v171 = *(_DWORD *)(a1 + 21776);
  *(_DWORD *)(a1 + 24704) = *(_DWORD *)(a1 + 24576);
  *(_DWORD *)(a1 + 24720) = v171;
  v172 = *(float *)(a1 + 25040);
  *(_DWORD *)(a1 + 24672) = v169;
  *(_DWORD *)(a1 + 24688) = v170;
  v173 = *(float *)(a1 + 25008);
  v174 = v168 * v172;
  v175 = v172 * *(float *)(a1 + 22832);
  *(float *)(a1 + 24736) = v175;
  v176 = *(float *)(a1 + 25136);
  v177 = *(float *)(a1 + 24880);
  v178 = v174 * *(float *)(a1 + 25056);
  v179 = *(float *)(a1 + 25072);
  v180 = (float)(v173 * v175) * *(float *)(a1 + 25024);
  *(float *)(a1 + 24768) = v180;
  v181 = *(float *)(a1 + 24896);
  v182 = (float)((float)((float)(v177 * *(float *)(a1 + 24704)) - (float)(v176 * v177)) + v176) * *(float *)(a1 + 25152);
  *(float *)(a1 + 24784) = v182;
  v183 = (float)((float)(v179 * v178) + v180) + (float)(v181 * v182);
  v184 = *(float *)(a1 + 24736);
  v185 = *(_DWORD *)(a1 + 24864);
  *(float *)(a1 + 24800) = (float)((float)((float)((float)((float)((float)(*(float *)(a1 + 25104)
                                                                         * *(float *)(a1 + 24688))
                                                                 + (float)(*(float *)(a1 + 25088)
                                                                         * *(float *)(a1 + 24672)))
                                                         * *(float *)(a1 + 25120))
                                                 + v183)
                                         + v167)
                                 + *(float *)(a1 + 24976))
                         + *(float *)(a1 + 24992);
  *(_DWORD *)(a1 + 24816) = v185;
  v186 = (float)(*(float *)(a1 + 24768) + *(float *)(a1 + 24720)) + *(float *)(a1 + 24784);
  *(float *)(a1 + 24832) = (float)((float)((float)((float)((float)((float)(v184 * *(float *)(a1 + 25184))
                                                                 + *(float *)(a1 + 25200))
                                                         * *(float *)(a1 + 24912))
                                                 + (float)(*(float *)(a1 + 24928) * *(float *)(a1 + 24672)))
                                         + (float)(*(float *)(a1 + 24944) * *(float *)(a1 + 24688)))
                                 + *(float *)(a1 + 24960))
                         * *(float *)(a1 + 25168);
  *(float *)(a1 + 24848) = v186;
  v187 = *(_DWORD *)(a1 + 25232);
  *(_DWORD *)(a1 + 25264) = *(_DWORD *)(a1 + 25216);
  *(_DWORD *)(a1 + 25280) = v187;
  *(_DWORD *)(a1 + 25296) = *(_DWORD *)(a1 + 25248);
  v188 = *(float *)(a1 + 84432);
  *(_DWORD *)(a1 + 25344) = *(_DWORD *)(a1 + 25328);
  v189 = *(float *)(a1 + 25312);
  *(float *)(a1 + 25328) = v189;
  v190 = (float)(v189 * *(float *)(a1 + 25360)) + *(float *)(a1 + 25344);
  *(float *)(a1 + 25328) = v190;
  v191 = (float)(v189 * *(float *)(a1 + 25376)) + v190;
  v192 = v190 * *(float *)(a1 + 25424);
  v193 = v188 - v191;
  v194 = (float)(v193 * *(float *)(a1 + 25360)) + v189;
  *(float *)(a1 + 25312) = v194;
  *(float *)(a1 + 25344) = (float)((float)(v193 * *(float *)(a1 + 25392)) + v192)
                         + (float)(v194 * *(float *)(a1 + 25408));
  *(_DWORD *)(a1 + 27456) = *(_DWORD *)(a1 + 27440);
  v195 = *(float *)(a1 + 27472);
  *(float *)(a1 + 27488) = v195;
  v196 = v195 * *(float *)(a1 + 24560);
  v197 = *(float *)(a1 + 27456) * *(float *)(a1 + 25344);
  *(float *)(a1 + 27504) = v196;
  *(float *)(a1 + 27520) = v197;
  *(_DWORD *)(a1 + 27584) = *(_DWORD *)(a1 + 27568);
  *(float *)(a1 + 27568) = (float)(v197 * *(float *)(a1 + 27552)) + (float)(v196 * *(float *)(a1 + 27536));
  *(_DWORD *)(a1 + 27616) = *(_DWORD *)(a1 + 27600);
  *(_DWORD *)(a1 + 27648) = *(_DWORD *)(a1 + 27632);
  *(_DWORD *)(a1 + 27680) = *(_DWORD *)(a1 + 27664);
  *(_DWORD *)(a1 + 27712) = *(_DWORD *)(a1 + 27696);
  v198 = (float)((float)(*(float *)(a1 + 27744) * *(float *)(a1 + 27600))
               - (float)(*(float *)(a1 + 27760) * *(float *)(a1 + 27744)))
       + *(float *)(a1 + 27760);
  v199 = (float)((float)((float)((float)(v198 * v198) * v198) * v198) * *(float *)(a1 + 27840))
       + (float)((float)((float)((float)(v198 * v198) * v198) * *(float *)(a1 + 27824))
               + (float)((float)((float)(v198 * *(float *)(a1 + 27792)) + *(float *)(a1 + 27776))
                       + (float)((float)(v198 * v198) * *(float *)(a1 + 27808))));
  if ( v199 <= 0.0 )
    v200 = 0.0;
  else
    v200 = v199;
  v201 = v200;
  if ( v201 < 1.0 )
    v42 = v201;
  v202 = v42;
  *(float *)(a1 + 27728) = v202;
  *(_DWORD *)(a1 + 27872) = *(_DWORD *)(a1 + 27856);
  v203 = *(float *)(a1 + 27888);
  *(float *)(a1 + 27904) = v203;
  v204 = *(float *)(a1 + 27920);
  *(float *)(a1 + 27936) = v204;
  *(float *)(a1 + 27920) = (float)((float)(v203 - v204) * *(float *)(a1 + 27952)) + v204;
  v205 = *(float *)(a1 + 21776);
  v206 = *(float *)(a1 + 21904);
  *(_DWORD *)(a1 + 28016) = *(_DWORD *)(a1 + 28000);
  *(float *)(a1 + 28000) = (float)(v206 * *(float *)(a1 + 27984)) + (float)(v205 * *(float *)(a1 + 27968));
  *(_DWORD *)(a1 + 28064) = *(_DWORD *)(a1 + 28032);
  v207 = *(float *)(a1 + 28048);
  *(float *)(a1 + 28080) = v207;
  v208 = *(float *)(a1 + 23776)
       + (float)((float)(*(float *)(a1 + 28064) * *(float *)(a1 + 24256))
               - (float)(*(float *)(a1 + 28064) * *(float *)(a1 + 23776)));
  *(float *)(a1 + 28096) = (float)((float)(v207 * *(float *)(a1 + 27664)) - (float)(v207 * v208)) + v208;
  v209 = *(float *)(a1 + 22816);
  v210 = *(float *)(a1 + 28112);
  *(float *)(a1 + 28128) = v210;
  v211 = v209 - v210;
  v212 = (float)(v211 * *(float *)(a1 + 28144)) + v210;
  v213 = *(float *)(a1 + 28176);
  *(float *)(a1 + 28112) = v212;
  *(float *)(a1 + 28128) = (float)(v211 * *(float *)(a1 + 28160)) + (float)(v213 * v212);
  v214 = *(float *)(a1 + 28192);
  v215 = *(float *)(a1 + 22832);
  *(float *)(a1 + 28208) = v214;
  v216 = v215 - v214;
  v217 = (float)(v216 * *(float *)(a1 + 28224)) + v214;
  v218 = *(float *)(a1 + 28256);
  *(float *)(a1 + 28192) = v217;
  v219 = (float)(v216 * *(float *)(a1 + 28240)) + (float)(v218 * v217);
  *(float *)(a1 + 28208) = v219;
  v220 = *(float *)(a1 + 28128);
  v221 = *(float *)(a1 + 28096);
  v222 = *(float *)(a1 + 28000);
  v223 = *(float *)(a1 + 27632);
  *(_DWORD *)(a1 + 28272) = *(_DWORD *)(a1 + 27920);
  *(float *)(a1 + 28288) = v223;
  v224 = *(float *)(a1 + 28320);
  v225 = *(float *)(a1 + 28336) * *(float *)(a1 + 27696);
  v226 = (float)((float)((float)((float)((float)(v223 * *(float *)(a1 + 28352))
                                       - (float)(*(float *)(a1 + 28480) * *(float *)(a1 + 28352)))
                               + *(float *)(a1 + 28480))
                       * *(float *)(a1 + 28496))
               + (float)((float)((float)(*(float *)(a1 + 28464) + *(float *)(a1 + 28272)) * *(float *)(a1 + 28528))
                       * *(float *)(a1 + 28448)))
       + (float)((float)((float)((float)((float)((float)(v225 - (float)(*(float *)(a1 + 28336) * (float)(v219 * v224)))
                                               + (float)(v219 * v224))
                                       * *(float *)(a1 + 28384))
                               * *(float *)(a1 + 28400))
                       + (float)((float)((float)(v225 - (float)(*(float *)(a1 + 28336) * (float)(v220 * v224)))
                                       + (float)(v220 * v224))
                               * *(float *)(a1 + 28368)))
               + (float)((float)((float)(v222 + *(float *)(a1 + 28512)) * *(float *)(a1 + 28432))
                       + (float)(v221 * *(float *)(a1 + 28416))));
  *(float *)(a1 + 28304) = v226;
  v227 = (__m128)*(unsigned int *)(a1 + 27728);
  v228 = *(float *)(a1 + 27872);
  *(_DWORD *)(a1 + 28608) = *(_DWORD *)(a1 + 28592);
  v229 = *(float *)(a1 + 28576);
  *(float *)(a1 + 28592) = v229;
  if ( *(float *)(a1 + 28656) == 1.0 )
  {
    v230 = *(float *)(a1 + 28608)
         + (float)((float)(*(float *)(a1 + 28736) * v229) - (float)(*(float *)(a1 + 28736) * *(float *)(a1 + 28608)));
    *(float *)(a1 + 28592) = v230;
    v231 = (float)(v230 * *(float *)(a1 + 28720)) + *(float *)(a1 + 28624);
    *(float *)(a1 + 28576) = sub_180368D60(-v229);
    v232 = (float)(1.0 - v228) * *(float *)(a1 + 28752);
    *(float *)(a1 + 28560) = (float)(v228 * *(float *)(a1 + 28816)) + *(float *)(a1 + 28640);
    v227.m128_f32[0] = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 28672))
                                                         + (float)(v226 * *(float *)(a1 + 28704)))
                                                 + v231)
                                         + fminf(*(float *)(a1 + 28768), v232))
                                 + *(float *)(a1 + 28688),
                                   *(float *)(a1 + 28784)),
                                 *(float *)(a1 + 28800))
                             * *(float *)(a1 + 28848))
                     + *(float *)(a1 + 28864);
    v233 = v227.m128_f32[0];
    v234 = (int)v227.m128_f32[0];
    if ( (int)v227.m128_f32[0] != 0x80000000 && (float)v234 != v227.m128_f32[0] )
      v233 = (float)(v234 - (_mm_movemask_ps(_mm_unpacklo_ps(v227, v227)) & 1));
    v235 = v227.m128_f32[0] - v233;
    v236 = (float)(v235 * v235) * 0.25;
    v237 = (float)(expf(v233)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v235 * *(float *)(a1 + 29056)) + *(float *)(a1 + 29040)) * v236) + (float)(v235 * *(float *)(a1 + 29024))) + *(float *)(a1 + 29008)) * v236) + (float)(v235 * *(float *)(a1 + 28992)))
                                                                                                 + *(float *)(a1 + 28976))
                                                                                         * v236)
                                                                                 + (float)(v235 * *(float *)(a1 + 28960)))
                                                                         + *(float *)(a1 + 28944))
                                                                 * v236)
                                                         + (float)(v235 * *(float *)(a1 + 28928)))
                                                 + *(float *)(a1 + 28912))
                                         * v236)
                                 + (float)(v235 * *(float *)(a1 + 28896)))
                         + 1.0))
         * *(float *)(a1 + 28880);
    v238 = v237 * v237;
    v239 = (float)((float)((float)((float)((float)((float)((float)((float)(v237 * v237) * *(float *)(a1 + 29216))
                                                         + *(float *)(a1 + 29184))
                                                 * (float)(v238 * v238))
                                         + (float)((float)((float)(v237 * v237) * *(float *)(a1 + 29152))
                                                 + *(float *)(a1 + 29120)))
                                 * (float)((float)((float)(v237 * v237) * v237) * (float)(v237 * v237)))
                         + (float)((float)((float)(v237 * v237) * v237) * *(float *)(a1 + 29088)))
                 + v237)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v237 * v237) * *(float *)(a1 + 29200))
                                                                 + *(float *)(a1 + 29168))
                                                         * (float)(v238 * v238))
                                                 + (float)((float)(v237 * v237) * *(float *)(a1 + 29136)))
                                         + *(float *)(a1 + 29104))
                                 * (float)(v238 * v238))
                         + (float)((float)(v237 * v237) * *(float *)(a1 + 29072)))
                 + 1.0);
    v240 = v239 / (float)(v239 + 1.0);
    *(float *)(a1 + 28544) = v240;
  }
  else
  {
    v240 = *(float *)(a1 + 28544);
  }
  v241 = *(float *)(a1 + 27568);
  v242 = *(float *)(a1 + 28560);
  *(_DWORD *)(a1 + 29344) = *(_DWORD *)(a1 + 29328);
  *(_DWORD *)(a1 + 29328) = *(_DWORD *)(a1 + 29312);
  *(_DWORD *)(a1 + 29312) = *(_DWORD *)(a1 + 29296);
  *(_DWORD *)(a1 + 29296) = *(_DWORD *)(a1 + 29280);
  *(_DWORD *)(a1 + 29280) = *(_DWORD *)(a1 + 29264);
  *(_DWORD *)(a1 + 29264) = *(_DWORD *)(a1 + 29248);
  *(_DWORD *)(a1 + 29248) = *(_DWORD *)(a1 + 29232);
  *(_DWORD *)(a1 + 29568) = *(_DWORD *)(a1 + 29552);
  *(_DWORD *)(a1 + 29552) = *(_DWORD *)(a1 + 29536);
  *(_DWORD *)(a1 + 29536) = *(_DWORD *)(a1 + 29520);
  *(_DWORD *)(a1 + 29520) = *(_DWORD *)(a1 + 29504);
  *(_DWORD *)(a1 + 29504) = *(_DWORD *)(a1 + 29488);
  *(_DWORD *)(a1 + 29488) = *(_DWORD *)(a1 + 29472);
  *(_DWORD *)(a1 + 29472) = *(_DWORD *)(a1 + 29456);
  *(_DWORD *)(a1 + 29696) = *(_DWORD *)(a1 + 29680);
  *(_DWORD *)(a1 + 29680) = *(_DWORD *)(a1 + 29664);
  *(_DWORD *)(a1 + 29664) = *(_DWORD *)(a1 + 29648);
  *(_DWORD *)(a1 + 29648) = *(_DWORD *)(a1 + 29632);
  *(_DWORD *)(a1 + 29632) = *(_DWORD *)(a1 + 29616);
  *(_DWORD *)(a1 + 29616) = *(_DWORD *)(a1 + 29600);
  *(_DWORD *)(a1 + 29600) = *(_DWORD *)(a1 + 29584);
  *(_DWORD *)(a1 + 29824) = *(_DWORD *)(a1 + 29808);
  *(_DWORD *)(a1 + 29808) = *(_DWORD *)(a1 + 29792);
  *(_DWORD *)(a1 + 29792) = *(_DWORD *)(a1 + 29776);
  *(_DWORD *)(a1 + 29776) = *(_DWORD *)(a1 + 29760);
  *(_DWORD *)(a1 + 29760) = *(_DWORD *)(a1 + 29744);
  *(_DWORD *)(a1 + 29744) = *(_DWORD *)(a1 + 29728);
  *(_DWORD *)(a1 + 29728) = *(_DWORD *)(a1 + 29712);
  *(_DWORD *)(a1 + 29952) = *(_DWORD *)(a1 + 29936);
  *(_DWORD *)(a1 + 29936) = *(_DWORD *)(a1 + 29920);
  *(_DWORD *)(a1 + 29920) = *(_DWORD *)(a1 + 29904);
  *(_DWORD *)(a1 + 29904) = *(_DWORD *)(a1 + 29888);
  *(_DWORD *)(a1 + 29888) = *(_DWORD *)(a1 + 29872);
  *(_DWORD *)(a1 + 29872) = *(_DWORD *)(a1 + 29856);
  *(_DWORD *)(a1 + 29856) = *(_DWORD *)(a1 + 29840);
  *(_DWORD *)(a1 + 29984) = *(_DWORD *)(a1 + 29968);
  v243 = *(float *)(a1 + 30000);
  *(float *)(a1 + 30016) = v243;
  if ( *(float *)(a1 + 30080) == 1.0 )
  {
    v244 = (float)((float)((float)(v242 * *(float *)(a1 + 30192)) + 1.0) * (float)(v241 * *(float *)(a1 + 30160)))
         + (float)((float)-v243 * *(float *)(a1 + 30144));
    *(float *)(a1 + 30000) = sub_180368D60(-v243);
    *(float *)(a1 + 29968) = v244;
    v245 = 1.0 - (float)(v240 + v240);
    v246 = 1.0 / (float)((float)((float)((float)(v240 * v240) * (float)(v240 * v240)) * v242) + 1.0);
    *(float *)(a1 + 30048) = v246;
    v247 = *(float *)(a1 + 29968);
    v248 = *(float *)(a1 + 29984);
    *(float *)(a1 + 30032) = v246 * v242;
    v249 = v248 * *(float *)(a1 + 30240);
    v250 = *(float *)(a1 + 29328);
    v251 = v247 * *(float *)(a1 + 30256);
    v252 = *(float *)(a1 + 29344);
    *(float *)(a1 + 29440) = v250;
    v253 = (float)((float)(v249 + v251) * v246)
         - (float)((float)((float)(v250 * *(float *)(a1 + 30544)) + (float)(v252 * *(float *)(a1 + 30560)))
                 * (float)(v246 * v242));
    if ( v253 >= -1.0 )
      v254 = fminf(v253, 1.0);
    else
      v254 = -1.0;
    v255 = v254 + (float)((float)((float)((float)(v254 * v254) * v254) * v254) * (float)(v254 * *(float *)(a1 + 30208)));
    *(float *)(a1 + 29360) = v255;
    v256 = *(float *)(a1 + 29264);
    v257 = (float)(v240 * (float)(v255 + *(float *)(a1 + 29248))) + (float)(v256 * v245);
    *(float *)(a1 + 29376) = v257;
    v258 = *(float *)(a1 + 29280);
    v259 = v240 * (float)(v257 + v256);
    v260 = v240 * (float)((float)((float)(v240 * v255) + (float)(v245 * v257)) + v257);
    v261 = v259 + (float)(v258 * v245);
    *(float *)(a1 + 29392) = v261;
    v262 = *(float *)(a1 + 29296);
    v263 = (float)(v240 * (float)(v261 + v258)) + (float)(v262 * v245);
    *(float *)(a1 + 29408) = v263;
    v264 = (float)((float)(v262 + v263) * v240) + (float)(v245 * *(float *)(a1 + 29312));
    *(float *)(a1 + 29424) = v264;
    v265 = (float)(v240
                 * (float)((float)((float)(v240 * (float)((float)(v260 + (float)(v245 * v261)) + v261))
                                 + (float)(v245 * v263))
                         + v263))
         + (float)(v245 * v264);
    v266 = (float)(*(float *)(a1 + 29408) * *(float *)(a1 + 30112)) + (float)(v264 * *(float *)(a1 + 30128));
    v267 = *(float *)(a1 + 29984);
    *(float *)(a1 + 29840) = v266 + (float)(*(float *)(a1 + 30096) * *(float *)(a1 + 29392));
    v268 = *(float *)(a1 + 29440);
    v269 = (float)((float)(v267 + *(float *)(a1 + 29968)) * *(float *)(a1 + 30272)) * *(float *)(a1 + 30048);
    *(float *)(a1 + 29440) = v265;
    v270 = v269
         - (float)((float)((float)(v265 * *(float *)(a1 + 30544)) + (float)(v268 * *(float *)(a1 + 30560)))
                 * *(float *)(a1 + 30032));
    if ( v270 >= -1.0 )
      v271 = fminf(v270, 1.0);
    else
      v271 = -1.0;
    v272 = v271 + (float)((float)((float)((float)(v271 * v271) * v271) * v271) * (float)(v271 * *(float *)(a1 + 30208)));
    v273 = *(float *)(a1 + 29360);
    *(float *)(a1 + 29360) = v272;
    v274 = *(float *)(a1 + 29376);
    v275 = (float)(v240 * (float)(v272 + v273)) + (float)(v274 * v245);
    *(float *)(a1 + 29376) = v275;
    v276 = *(float *)(a1 + 29392);
    v277 = v240 * (float)(v275 + v274);
    v278 = v240 * (float)((float)((float)(v240 * v272) + (float)(v245 * v275)) + v275);
    v279 = v277 + (float)(v276 * v245);
    *(float *)(a1 + 29392) = v279;
    v280 = *(float *)(a1 + 29408);
    v281 = (float)(v240 * (float)(v279 + v276)) + (float)(v280 * v245);
    *(float *)(a1 + 29408) = v281;
    v282 = (float)((float)(v280 + v281) * v240) + (float)(v245 * *(float *)(a1 + 29424));
    *(float *)(a1 + 29424) = v282;
    v283 = *(float *)(a1 + 29968);
    v284 = (float)(v240
                 * (float)((float)((float)(v240 * (float)((float)(v278 + (float)(v245 * v279)) + v279))
                                 + (float)(v245 * v281))
                         + v281))
         + (float)(v245 * v282);
    v285 = (float)(*(float *)(a1 + 29408) * *(float *)(a1 + 30112)) + (float)(v282 * *(float *)(a1 + 30128));
    v286 = *(float *)(a1 + 29984);
    *(float *)(a1 + 29712) = v285 + (float)(*(float *)(a1 + 30096) * *(float *)(a1 + 29392));
    v287 = *(float *)(a1 + 29440);
    v288 = (float)((float)(v286 * *(float *)(a1 + 30256)) + (float)(v283 * *(float *)(a1 + 30240)))
         * *(float *)(a1 + 30048);
    *(float *)(a1 + 29440) = v284;
    v289 = v288
         - (float)((float)((float)(v284 * *(float *)(a1 + 30544)) + (float)(v287 * *(float *)(a1 + 30560)))
                 * *(float *)(a1 + 30032));
    if ( v289 >= -1.0 )
      v290 = fminf(v289, 1.0);
    else
      v290 = -1.0;
    v291 = v290 + (float)((float)((float)((float)(v290 * v290) * v290) * v290) * (float)(v290 * *(float *)(a1 + 30208)));
    v292 = *(float *)(a1 + 29360);
    *(float *)(a1 + 29360) = v291;
    v293 = *(float *)(a1 + 29376);
    v294 = (float)(v240 * (float)(v291 + v292)) + (float)(v293 * v245);
    *(float *)(a1 + 29376) = v294;
    v295 = *(float *)(a1 + 29392);
    v296 = v240 * (float)(v294 + v293);
    v297 = v240 * (float)((float)((float)(v240 * v291) + (float)(v245 * v294)) + v294);
    v298 = v296 + (float)(v295 * v245);
    *(float *)(a1 + 29392) = v298;
    v299 = *(float *)(a1 + 29408);
    v300 = (float)(v240 * (float)(v298 + v295)) + (float)(v299 * v245);
    *(float *)(a1 + 29408) = v300;
    v301 = (float)((float)(v299 + v300) * v240) + (float)(v245 * *(float *)(a1 + 29424));
    *(float *)(a1 + 29424) = v301;
    v302 = (float)(v240
                 * (float)((float)((float)(v240 * (float)((float)(v297 + (float)(v245 * v298)) + v298))
                                 + (float)(v245 * v300))
                         + v300))
         + (float)(v245 * v301);
    v303 = (float)(*(float *)(a1 + 29408) * *(float *)(a1 + 30112)) + (float)(v301 * *(float *)(a1 + 30128));
    v304 = *(float *)(a1 + 29968);
    *(float *)(a1 + 29584) = v303 + (float)(*(float *)(a1 + 30096) * *(float *)(a1 + 29392));
    v305 = *(float *)(a1 + 29440);
    v306 = (float)(v304 * *(float *)(a1 + 30224)) * *(float *)(a1 + 30048);
    *(float *)(a1 + 29328) = v302;
    v307 = v306
         - (float)((float)((float)(v302 * *(float *)(a1 + 30544)) + (float)(v305 * *(float *)(a1 + 30560)))
                 * *(float *)(a1 + 30032));
    if ( v307 >= -1.0 )
      v308 = fminf(v307, 1.0);
    else
      v308 = -1.0;
    v309 = v308 + (float)((float)((float)((float)(v308 * v308) * v308) * v308) * (float)(v308 * *(float *)(a1 + 30208)));
    *(float *)(a1 + 29232) = v309;
    v310 = *(float *)(a1 + 29376);
    v311 = (float)(v240 * (float)(v309 + *(float *)(a1 + 29360))) + (float)(v310 * v245);
    *(float *)(a1 + 29248) = v311;
    v312 = *(float *)(a1 + 29392);
    v313 = v240 * (float)(v311 + v310);
    v314 = v240 * (float)((float)((float)(v240 * v309) + (float)(v245 * v311)) + v311);
    v315 = v313 + (float)(v312 * v245);
    *(float *)(a1 + 29264) = v315;
    v316 = *(float *)(a1 + 29408);
    v317 = (float)(v240 * (float)(v315 + v312)) + (float)(v316 * v245);
    *(float *)(a1 + 29280) = v317;
    v318 = (float)((float)(v316 + v317) * v240) + (float)(v245 * *(float *)(a1 + 29424));
    v319 = v240
         * (float)((float)((float)(v240 * (float)((float)(v314 + (float)(v245 * v315)) + v315)) + (float)(v245 * v317))
                 + v317);
    *(float *)(a1 + 29296) = v318;
    v320 = *(float *)(a1 + 29264);
    *(float *)(a1 + 29312) = v319 + (float)(v245 * v318);
    v321 = *(float *)(a1 + 29520);
    v322 = (float)((float)(v318 * *(float *)(a1 + 30128)) + (float)(*(float *)(a1 + 30112) * *(float *)(a1 + 29280)))
         + (float)(v320 * *(float *)(a1 + 30096));
    *(float *)(a1 + 29456) = v322;
    v323 = (float)(v322 + *(float *)(a1 + 29952)) * *(float *)(a1 + 30288);
    v324 = (float)(*(float *)(a1 + 29712) + *(float *)(a1 + 29696)) * *(float *)(a1 + 30320);
    v325 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v321 + *(float *)(a1 + 29888)) * *(float *)(a1 + 30528)) + (float)((float)(*(float *)(a1 + 29648) + *(float *)(a1 + 29760)) * *(float *)(a1 + 30512))) + (float)((float)(*(float *)(a1 + 29776) + *(float *)(a1 + 29632)) * *(float *)(a1 + 30496))) + (float)((float)(*(float *)(a1 + 29504) + *(float *)(a1 + 29904)) * *(float *)(a1 + 30480))) + (float)((float)(*(float *)(a1 + 29872) + *(float *)(a1 + 29536)) * *(float *)(a1 + 30464)))
                                                                                                 + (float)((float)(*(float *)(a1 + 29744) + *(float *)(a1 + 29664)) * *(float *)(a1 + 30448)))
                                                                                         + (float)((float)(*(float *)(a1 + 29792) + *(float *)(a1 + 29616))
                                                                                                 * *(float *)(a1 + 30432)))
                                                                                 + (float)((float)(*(float *)(a1 + 29920)
                                                                                                 + *(float *)(a1 + 29488))
                                                                                         * *(float *)(a1 + 30416)))
                                                                         + (float)((float)(*(float *)(a1 + 29856)
                                                                                         + *(float *)(a1 + 29552))
                                                                                 * *(float *)(a1 + 30400)))
                                                                 + (float)((float)(*(float *)(a1 + 29728)
                                                                                 + *(float *)(a1 + 29680))
                                                                         * *(float *)(a1 + 30384)))
                                                         + (float)((float)(*(float *)(a1 + 29808)
                                                                         + *(float *)(a1 + 29600))
                                                                 * *(float *)(a1 + 30368)))
                                                 + (float)((float)(*(float *)(a1 + 29936) + *(float *)(a1 + 29472))
                                                         * *(float *)(a1 + 30352)))
                                         + (float)((float)(*(float *)(a1 + 29840) + *(float *)(a1 + 29568))
                                                 * *(float *)(a1 + 30336)))
                                 + v324)
                         + (float)((float)(*(float *)(a1 + 29824) + *(float *)(a1 + 29584)) * *(float *)(a1 + 30304)))
                 + v323)
         * *(float *)(a1 + 30176);
    *(float *)(a1 + 30064) = v325;
  }
  *(_DWORD *)(a1 + 30592) = *(_DWORD *)(a1 + 30576);
  v326 = *(_DWORD *)(a1 + 30624);
  *(_DWORD *)(a1 + 30656) = *(_DWORD *)(a1 + 30608);
  *(_DWORD *)(a1 + 30672) = v326;
  *(_DWORD *)(a1 + 30688) = *(_DWORD *)(a1 + 30640);
  v327 = *(float *)(a1 + 30704);
  *(float *)(a1 + 30720) = v327;
  v328 = *(float *)(a1 + 30736);
  *(float *)(a1 + 30752) = v328;
  v329 = (float)((float)(v327 - v328) * *(float *)(a1 + 30768)) + v328;
  *(float *)(a1 + 30736) = v329;
  v330 = (float)((float)(v329 * *(float *)(a1 + 30672)) - (float)(*(float *)(a1 + 30672) * *(float *)(a1 + 30688)))
       + *(float *)(a1 + 30688);
  *(float *)(a1 + 30784) = v330;
  v331 = *(float *)(a1 + 30800);
  *(float *)(a1 + 30816) = v331;
  v332 = (float)((float)(*(float *)(a1 + 30832) * v330) - (float)(*(float *)(a1 + 30832) * v331)) + v331;
  if ( v332 <= 0.0 )
    v333 = 0.0;
  else
    v333 = v332;
  v334 = v333;
  *(float *)(a1 + 30800) = v334;
  v335 = *(float *)(a1 + 30848);
  *(float *)(a1 + 30864) = v335;
  v336 = *(float *)(a1 + 30880);
  *(float *)(a1 + 30896) = v336;
  v337 = (float)((float)(*(float *)(a1 + 30912) * v335) - (float)(*(float *)(a1 + 30912) * v336)) + v336;
  if ( v337 <= 0.0 )
    v338 = 0.0;
  else
    v338 = v337;
  v339 = v338;
  *(float *)(a1 + 30880) = v339;
  v340 = *(float *)(a1 + 30928);
  v341 = *(float *)(a1 + 21584);
  *(float *)(a1 + 30944) = v340;
  v342 = v340 * *(float *)(a1 + 31024);
  v343 = v340 + *(float *)(a1 + 31008);
  if ( v342 >= -1.0 )
    v344 = fminf(v342, 1.0);
  else
    v344 = -1.0;
  if ( (float)(v340 + *(float *)(a1 + 30976)) >= 0.0 )
    v343 = (float)((float)(*(float *)(a1 + 30992) * v341) - (float)(*(float *)(a1 + 30992) * v340)) + v340;
  v345 = (float)((float)(v344 * *(float *)(a1 + 31040)) - (float)(*(float *)(a1 + 31056) * v344))
       + *(float *)(a1 + 31056);
  v346 = (float)((float)(v345 * v341) - (float)(v345 * v340)) + v340;
  if ( v341 != 0.0 )
    v346 = v343;
  *(float *)(a1 + 30960) = v346;
  *(float *)(a1 + 30928) = v346;
  v347 = *(float *)(a1 + 30064);
  v348 = *(float *)(a1 + 23776);
  v349 = *(float *)(a1 + 27872);
  v350 = *(_DWORD *)(a1 + 24256);
  v351 = *(_DWORD *)(a1 + 30576);
  *(_DWORD *)(a1 + 31136) = *(_DWORD *)(a1 + 31120);
  *(_DWORD *)(a1 + 31168) = *(_DWORD *)(a1 + 31152);
  *(_DWORD *)(a1 + 31072) = v350;
  *(_DWORD *)(a1 + 31088) = v351;
  v352 = *(float *)(a1 + 31136);
  v353 = *(float *)(a1 + 31200);
  *(float *)(a1 + 31104) = v349 * *(float *)(a1 + 31360);
  v354 = v347 - v352;
  v355 = *(float *)(a1 + 31232);
  v356 = (float)(v348 * *(float *)(a1 + 31216)) + (float)(v353 * *(float *)(a1 + 30960));
  v357 = v352 + (float)((float)(v347 - v352) * *(float *)(a1 + 31264));
  *(float *)(a1 + 31120) = v357;
  v358 = (float)(v354 * *(float *)(a1 + 31376)) + (float)(v357 * *(float *)(a1 + 31392));
  v359 = (float)((float)(*(float *)(a1 + 31248) * *(float *)(a1 + 31088))
               - (float)(*(float *)(a1 + 31248) * (float)(v356 + (float)(v355 * *(float *)(a1 + 31072)))))
       + (float)(v356 + (float)(v355 * *(float *)(a1 + 31072)));
  v360 = *(float *)(a1 + 31280);
  v361 = v359 * *(float *)(a1 + 31328);
  v362 = v347 * (float)(1.0 - v360);
  if ( v361 <= 0.0 )
    v363 = 0.0;
  else
    v363 = v361;
  v364 = *(float *)(a1 + 31296);
  v365 = v363;
  v366 = v365 * *(float *)(a1 + 31344);
  v367 = (float)((float)(v360 * v358) + v362) * (float)(*(float *)(a1 + 31104) + 1.0);
  v368 = *(float *)(a1 + 31312) * v367;
  v369 = *(float *)(a1 + 31168)
       + (float)((float)(*(float *)(a1 + 31408) * v367) - (float)(*(float *)(a1 + 31408) * *(float *)(a1 + 31168)));
  *(float *)(a1 + 31152) = v369;
  v370 = (float)((float)((float)(v364 * v369) + v368) * v366) * *(float *)(a1 + 31424);
  *(float *)(a1 + 31184) = v370;
  *(_DWORD *)(a1 + 31472) = *(_DWORD *)(a1 + 31456);
  *(_DWORD *)(a1 + 31456) = *(_DWORD *)(a1 + 31440);
  v371 = *(float *)(a1 + 31472);
  v372 = *(float *)(a1 + 31488);
  v373 = v370 - v371;
  *(float *)(a1 + 31440) = v373;
  *(float *)(a1 + 31456) = (float)(v372 * v373) + v371;
  v374 = *(float *)(a1 + 31440);
  v375 = *(float *)(a1 + 30656);
  *(_DWORD *)(a1 + 31552) = *(_DWORD *)(a1 + 31536);
  *(_DWORD *)(a1 + 31536) = *(_DWORD *)(a1 + 31520);
  *(_DWORD *)(a1 + 31520) = *(_DWORD *)(a1 + 31504);
  *(float *)(a1 + 31504) = v374;
  v376 = (float)((float)(*(float *)(a1 + 31520) * *(float *)(a1 + 31600)) + (float)(v374 * *(float *)(a1 + 31584)))
       + (float)(*(float *)(a1 + 31616) * *(float *)(a1 + 31536));
  v377 = (float)((float)(*(float *)(a1 + 31520) * *(float *)(a1 + 31648)) + (float)(v374 * *(float *)(a1 + 31632)))
       + (float)(*(float *)(a1 + 31664) * *(float *)(a1 + 31552));
  if ( v375 <= 0.0 )
    v378 = 0.0;
  else
    v378 = v375;
  *(float *)(a1 + 31520) = v376;
  v379 = v378;
  *(float *)(a1 + 31536) = v377;
  v380 = (float)((float)(v379 * v376) - (float)(v379 * v374)) + v374;
  if ( v375 < -0.0 )
    v19 = (float)-v375;
  v381 = v19;
  v382 = v374 + (float)((float)(v381 * v377) - (float)(v381 * v374));
  if ( v375 >= 0.0 )
    v382 = v380;
  *(float *)(a1 + 31568) = v382;
  v383 = v382 * *(float *)(a1 + 30800);
  *(float *)(a1 + 31680) = v383;
  *(float *)(a1 + 31696) = v383 * *(float *)(a1 + 30880);
  v384 = fmin(fmax((float)(*(float *)(a1 + 25472) + *(float *)(a1 + 24800)), -20.0), 8.9);
  v385 = v384 * v384 * v384;
  v386 = (double *)((char *)&unk_1809894E0 + 208 * (int)(v384 + 20.0));
  v387 = v385 * v384 * v384;
  v388 = v387 * v384 * v384;
  v389 = v388 * v384 * v384;
  v390 = v389 * v384;
  v391 = fmaxf(
           fminf(
             v384 * v386[2]
           + *v386
           + v384 * v384 * v386[4]
           + v385 * v386[6]
           + v385 * v384 * v386[8]
           + v387 * v386[10]
           + v387 * v384 * v386[12]
           + v388 * v386[14]
           + v388 * v384 * v386[16]
           + v389 * v386[18]
           + v390 * v386[20]
           + v390 * v384 * v386[22]
           + v390 * v384 * v384 * v386[24],
             512.0),
           -512.0)
       * *(float *)(a1 + 24816);
  *(float *)(a1 + 25440) = v391;
  v392 = *(float *)(a1 + 24800);
  v393 = *(_DWORD *)(a1 + 25264);
  v394 = *(_DWORD *)(a1 + 25280);
  LODWORD(v385) = *(_DWORD *)(a1 + 25296);
  *(_DWORD *)(a1 + 25872) = *(_DWORD *)(a1 + 25856);
  *(_DWORD *)(a1 + 25904) = *(_DWORD *)(a1 + 25888);
  *(_DWORD *)(a1 + 26080) = *(_DWORD *)(a1 + 26064);
  *(_DWORD *)(a1 + 26064) = *(_DWORD *)(a1 + 26048);
  *(_DWORD *)(a1 + 26048) = *(_DWORD *)(a1 + 26032);
  *(_DWORD *)(a1 + 26032) = *(_DWORD *)(a1 + 26016);
  *(_DWORD *)(a1 + 26016) = *(_DWORD *)(a1 + 26000);
  *(_DWORD *)(a1 + 26000) = *(_DWORD *)(a1 + 25984);
  *(_DWORD *)(a1 + 25984) = *(_DWORD *)(a1 + 25968);
  *(_DWORD *)(a1 + 26208) = *(_DWORD *)(a1 + 26192);
  *(_DWORD *)(a1 + 26192) = *(_DWORD *)(a1 + 26176);
  *(_DWORD *)(a1 + 26176) = *(_DWORD *)(a1 + 26160);
  *(_DWORD *)(a1 + 26160) = *(_DWORD *)(a1 + 26144);
  *(_DWORD *)(a1 + 26144) = *(_DWORD *)(a1 + 26128);
  *(_DWORD *)(a1 + 26128) = *(_DWORD *)(a1 + 26112);
  *(_DWORD *)(a1 + 26112) = *(_DWORD *)(a1 + 26096);
  *(_DWORD *)(a1 + 26336) = *(_DWORD *)(a1 + 26320);
  *(_DWORD *)(a1 + 26320) = *(_DWORD *)(a1 + 26304);
  *(_DWORD *)(a1 + 26304) = *(_DWORD *)(a1 + 26288);
  *(_DWORD *)(a1 + 26288) = *(_DWORD *)(a1 + 26272);
  *(_DWORD *)(a1 + 26272) = *(_DWORD *)(a1 + 26256);
  *(_DWORD *)(a1 + 26256) = *(_DWORD *)(a1 + 26240);
  *(_DWORD *)(a1 + 26240) = *(_DWORD *)(a1 + 26224);
  *(_DWORD *)(a1 + 26464) = *(_DWORD *)(a1 + 26448);
  *(_DWORD *)(a1 + 26448) = *(_DWORD *)(a1 + 26432);
  *(_DWORD *)(a1 + 26432) = *(_DWORD *)(a1 + 26416);
  *(_DWORD *)(a1 + 26416) = *(_DWORD *)(a1 + 26400);
  *(_DWORD *)(a1 + 26400) = *(_DWORD *)(a1 + 26384);
  *(_DWORD *)(a1 + 26384) = *(_DWORD *)(a1 + 26368);
  *(_DWORD *)(a1 + 26368) = *(_DWORD *)(a1 + 26352);
  *(_DWORD *)(a1 + 26528) = *(_DWORD *)(a1 + 26512);
  *(_DWORD *)(a1 + 26512) = *(_DWORD *)(a1 + 26496);
  *(_DWORD *)(a1 + 25760) = v393;
  *(_DWORD *)(a1 + 25776) = v394;
  v395 = v392 + *(float *)(a1 + 27328);
  v396 = v391 * *(float *)(a1 + 26560);
  v397 = *(float *)(a1 + 26544);
  *(_DWORD *)(a1 + 25792) = LODWORD(v385);
  v398 = fmaxf(*(float *)(a1 + 26592), v396);
  v399 = (float)(v395 * *(float *)(a1 + 27344)) + *(float *)(a1 + 27312);
  *(float *)(a1 + 25808) = v398;
  *(float *)(a1 + 25840) = v397 + *(float *)(a1 + 24832);
  if ( v399 <= 0.0 )
    v400 = 0.0;
  else
    v400 = v399;
  *(float *)(a1 + 25824) = 0.00390625 / v398;
  *(float *)(a1 + 26480) = v400;
  v402 = *(unsigned int *)(a1 + 25904);
  v401 = *(_DWORD *)(a1 + 25872);
  *(_DWORD *)(a1 + 25680) = v402;
  *(float *)&v402 = *(float *)&v402 + v398;
  *(_DWORD *)(a1 + 25696) = v401;
  if ( *(float *)&v402 <= 1.0 )
  {
    if ( *(float *)&v402 < -1.0 )
      *(float *)&v402 = fmodf(*(float *)&v402 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v402 = fmodf(*(float *)&v402 + 1.0, 2.0) - 1.0;
  }
  HIDWORD(v403) = HIDWORD(v402);
  *(_DWORD *)(a1 + 25664) = v402;
  v404 = *(float *)&v402 * *(float *)(a1 + 26672);
  *(float *)&v403 = (float)(*(float *)&v402 + 1.0) * 0.5;
  v405 = (float)((float)(sub_180368FC0(v403).m128_f32[0] * 256.0) * *(float *)(a1 + 25824)) * *(float *)(a1 + 26624);
  if ( v405 >= -1.0 )
    v406 = fminf(v405, 1.0);
  else
    v406 = -1.0;
  v407 = v406 * *(float *)(a1 + 26576);
  v408 = (float)(v407 * v407) * v407;
  v409 = v408 * *(float *)(a1 + 26976);
  v410 = *(float *)(a1 + 25840);
  v411 = (float)((float)((float)((float)((float)(v407 * v407) * *(float *)(a1 + 27040)) + *(float *)(a1 + 27024))
                       * (float)((float)(v407 * v407) * (float)(v407 * v407)))
               + (float)((float)((float)(v407 * v407) * *(float *)(a1 + 27008)) + *(float *)(a1 + 26992)))
       * (float)(v408 * (float)(v407 * v407));
  *(_QWORD *)&v412 = LODWORD(v410);
  *(float *)&v412 = v410 + *(float *)&v402;
  *(float *)(a1 + 25920) = (float)((float)(v411 + v409) + v407) * v404;
  if ( (float)(v410 + *(float *)&v402) < 0.0 )
    v413 = v410 - 1.0;
  else
    v413 = v410 + 1.0;
  v414 = *(float *)&v412;
  if ( *(float *)&v412 >= 0.0 )
  {
    if ( *(float *)&v412 > 0.0 )
      v414 = 1.0;
  }
  else
  {
    v414 = -1.0;
  }
  v415 = *(float *)(a1 + 25664);
  v416 = v414 * *(float *)(a1 + 26688);
  *(float *)&v412 = *(float *)&v412 / v413;
  v417 = sub_180368FC0(v412).m128_f32[0];
  v418 = *(float *)(a1 + 26608);
  if ( v415 < v418 || v418 <= *(float *)(a1 + 25680) )
  {
    v419 = *(unsigned int *)(a1 + 25696);
  }
  else
  {
    v419 = *(unsigned int *)(a1 + 25696);
    *(float *)&v419 = *(float *)&v419 + 2.0;
  }
  v420 = (float)((float)(v417 * *(float *)(a1 + 25824)) * 256.0) * *(float *)(a1 + 26640);
  if ( *(float *)&v419 >= 4.0 )
    v419 = 0;
  if ( v420 >= -1.0 )
    v421 = fminf(v420, 1.0);
  else
    v421 = -1.0;
  *(_DWORD *)(a1 + 25696) = v419;
  v422 = v421 * *(float *)(a1 + 26576);
  *(float *)&v419 = (float)((float)((float)(*(float *)&v419 + v415) + 1.0) * 0.5) - 1.0;
  v423 = (float)((float)((float)((float)((float)((float)((float)((float)(v422 * v422) * *(float *)(a1 + 27040))
                                                       + *(float *)(a1 + 27024))
                                               * (float)((float)(v422 * v422) * (float)(v422 * v422)))
                                       + (float)((float)((float)(v422 * v422) * *(float *)(a1 + 27008))
                                               + *(float *)(a1 + 26992)))
                               * (float)((float)((float)(v422 * v422) * v422) * (float)(v422 * v422)))
                       + (float)((float)((float)(v422 * v422) * v422) * *(float *)(a1 + 26976)))
               + v422)
       * v416;
  *(float *)(a1 + 25936) = v423;
  v424 = sub_180368FC0(COERCE_DOUBLE(v419 & 0x7FFFFFFF7FFFFFFFLL ^ 0x8000000080000000uLL)).m128_f32[0];
  if ( *(float *)&v419 >= 0.0 )
  {
    if ( *(float *)&v419 > 0.0 )
      LODWORD(v419) = 1065353216;
  }
  else
  {
    LODWORD(v419) = -1082130432;
  }
  v425 = *(float *)&v419 * *(float *)(a1 + 26704);
  v426 = (float)((float)((float)(v424 + 1.0) * *(float *)(a1 + 25824)) * 512.0) * *(float *)(a1 + 26656);
  if ( v426 >= -1.0 )
    v427 = fminf(v426, 1.0);
  else
    v427 = -1.0;
  v428 = v427 * *(float *)(a1 + 26576);
  v430 = *(unsigned int *)(a1 + 25664);
  v429 = *(_DWORD *)(a1 + 25696);
  *(float *)(a1 + 25968) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v428 * v428)
                                                                                                 * *(float *)(a1 + 27040))
                                                                                         + *(float *)(a1 + 27024))
                                                                                 * (float)((float)(v428 * v428)
                                                                                         * (float)(v428 * v428)))
                                                                         + (float)((float)((float)(v428 * v428)
                                                                                         * *(float *)(a1 + 27008))
                                                                                 + *(float *)(a1 + 26992)))
                                                                 * (float)((float)((float)(v428 * v428) * v428)
                                                                         * (float)(v428 * v428)))
                                                         + (float)((float)((float)(v428 * v428) * v428)
                                                                 * *(float *)(a1 + 26976)))
                                                 + v428)
                                         * v425)
                                 * *(float *)(a1 + 25792))
                         + (float)((float)(*(float *)(a1 + 25920) * *(float *)(a1 + 25760))
                                 + (float)(v423 * *(float *)(a1 + 25776)));
  *(_DWORD *)(a1 + 25680) = v430;
  *(_DWORD *)(a1 + 25696) = v429;
  *(float *)&v430 = *(float *)&v430 + *(float *)(a1 + 25808);
  if ( *(float *)&v430 <= 1.0 )
  {
    if ( *(float *)&v430 < -1.0 )
      *(float *)&v430 = fmodf(*(float *)&v430 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v430 = fmodf(*(float *)&v430 + 1.0, 2.0) - 1.0;
  }
  HIDWORD(v431) = HIDWORD(v430);
  *(_DWORD *)(a1 + 25664) = v430;
  v432 = *(float *)&v430 * *(float *)(a1 + 26672);
  *(float *)&v431 = (float)(*(float *)&v430 + 1.0) * 0.5;
  v433 = (float)((float)(sub_180368FC0(v431).m128_f32[0] * 256.0) * *(float *)(a1 + 25824)) * *(float *)(a1 + 26624);
  if ( v433 >= -1.0 )
    v434 = fminf(v433, 1.0);
  else
    v434 = -1.0;
  v435 = v434 * *(float *)(a1 + 26576);
  v436 = (float)(v435 * v435) * v435;
  v437 = v436 * *(float *)(a1 + 26976);
  v438 = *(float *)(a1 + 25840);
  v439 = (float)((float)((float)((float)((float)(v435 * v435) * *(float *)(a1 + 27040)) + *(float *)(a1 + 27024))
                       * (float)((float)(v435 * v435) * (float)(v435 * v435)))
               + (float)((float)((float)(v435 * v435) * *(float *)(a1 + 27008)) + *(float *)(a1 + 26992)))
       * (float)(v436 * (float)(v435 * v435));
  *(_QWORD *)&v440 = LODWORD(v438);
  *(float *)&v440 = v438 + *(float *)&v430;
  *(float *)(a1 + 25920) = (float)((float)(v439 + v437) + v435) * v432;
  if ( (float)(v438 + *(float *)&v430) < 0.0 )
    v441 = v438 - 1.0;
  else
    v441 = v438 + 1.0;
  v442 = *(float *)&v440;
  if ( *(float *)&v440 >= 0.0 )
  {
    if ( *(float *)&v440 > 0.0 )
      v442 = 1.0;
  }
  else
  {
    v442 = -1.0;
  }
  v443 = *(float *)(a1 + 25664);
  v444 = v442 * *(float *)(a1 + 26688);
  *(float *)&v440 = *(float *)&v440 / v441;
  v445 = sub_180368FC0(v440).m128_f32[0];
  v446 = *(float *)(a1 + 26608);
  if ( v443 < v446 || v446 <= *(float *)(a1 + 25680) )
  {
    v447 = *(unsigned int *)(a1 + 25696);
  }
  else
  {
    v447 = *(unsigned int *)(a1 + 25696);
    *(float *)&v447 = *(float *)&v447 + 2.0;
  }
  v448 = (float)((float)(v445 * *(float *)(a1 + 25824)) * 256.0) * *(float *)(a1 + 26640);
  if ( *(float *)&v447 >= 4.0 )
    v447 = 0;
  if ( v448 >= -1.0 )
    v449 = fminf(v448, 1.0);
  else
    v449 = -1.0;
  *(_DWORD *)(a1 + 25696) = v447;
  v450 = v449 * *(float *)(a1 + 26576);
  *(float *)&v447 = (float)((float)((float)(*(float *)&v447 + v443) + 1.0) * 0.5) - 1.0;
  v451 = (float)((float)((float)((float)((float)((float)((float)((float)(v450 * v450) * *(float *)(a1 + 27040))
                                                       + *(float *)(a1 + 27024))
                                               * (float)((float)(v450 * v450) * (float)(v450 * v450)))
                                       + (float)((float)((float)(v450 * v450) * *(float *)(a1 + 27008))
                                               + *(float *)(a1 + 26992)))
                               * (float)((float)((float)(v450 * v450) * v450) * (float)(v450 * v450)))
                       + (float)((float)((float)(v450 * v450) * v450) * *(float *)(a1 + 26976)))
               + v450)
       * v444;
  *(float *)(a1 + 25936) = v451;
  v452 = sub_180368FC0(COERCE_DOUBLE(v447 & 0x7FFFFFFF7FFFFFFFLL ^ 0x8000000080000000uLL)).m128_f32[0];
  if ( *(float *)&v447 >= 0.0 )
  {
    if ( *(float *)&v447 > 0.0 )
      LODWORD(v447) = 1065353216;
  }
  else
  {
    LODWORD(v447) = -1082130432;
  }
  v453 = *(float *)&v447 * *(float *)(a1 + 26704);
  v454 = (float)((float)((float)(v452 + 1.0) * *(float *)(a1 + 25824)) * 512.0) * *(float *)(a1 + 26656);
  if ( v454 >= -1.0 )
    v455 = fminf(v454, 1.0);
  else
    v455 = -1.0;
  v456 = v455 * *(float *)(a1 + 26576);
  v458 = *(unsigned int *)(a1 + 25664);
  v457 = *(_DWORD *)(a1 + 25696);
  *(float *)(a1 + 26096) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v456 * v456)
                                                                                                 * *(float *)(a1 + 27040))
                                                                                         + *(float *)(a1 + 27024))
                                                                                 * (float)((float)(v456 * v456)
                                                                                         * (float)(v456 * v456)))
                                                                         + (float)((float)((float)(v456 * v456)
                                                                                         * *(float *)(a1 + 27008))
                                                                                 + *(float *)(a1 + 26992)))
                                                                 * (float)((float)((float)(v456 * v456) * v456)
                                                                         * (float)(v456 * v456)))
                                                         + (float)((float)((float)(v456 * v456) * v456)
                                                                 * *(float *)(a1 + 26976)))
                                                 + v456)
                                         * v453)
                                 * *(float *)(a1 + 25792))
                         + (float)((float)(*(float *)(a1 + 25920) * *(float *)(a1 + 25760))
                                 + (float)(v451 * *(float *)(a1 + 25776)));
  *(_DWORD *)(a1 + 25680) = v458;
  *(_DWORD *)(a1 + 25696) = v457;
  *(float *)&v458 = *(float *)&v458 + *(float *)(a1 + 25808);
  if ( *(float *)&v458 <= 1.0 )
  {
    if ( *(float *)&v458 < -1.0 )
      *(float *)&v458 = fmodf(*(float *)&v458 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v458 = fmodf(*(float *)&v458 + 1.0, 2.0) - 1.0;
  }
  HIDWORD(v459) = HIDWORD(v458);
  *(_DWORD *)(a1 + 25664) = v458;
  v460 = *(float *)&v458 * *(float *)(a1 + 26672);
  *(float *)&v459 = (float)(*(float *)&v458 + 1.0) * 0.5;
  v461 = (float)((float)(sub_180368FC0(v459).m128_f32[0] * 256.0) * *(float *)(a1 + 25824)) * *(float *)(a1 + 26624);
  if ( v461 >= -1.0 )
    v462 = fminf(v461, 1.0);
  else
    v462 = -1.0;
  v463 = v462 * *(float *)(a1 + 26576);
  v464 = (float)(v463 * v463) * v463;
  v465 = v464 * *(float *)(a1 + 26976);
  v466 = *(float *)(a1 + 25840);
  v467 = (float)((float)((float)((float)((float)(v463 * v463) * *(float *)(a1 + 27040)) + *(float *)(a1 + 27024))
                       * (float)((float)(v463 * v463) * (float)(v463 * v463)))
               + (float)((float)((float)(v463 * v463) * *(float *)(a1 + 27008)) + *(float *)(a1 + 26992)))
       * (float)(v464 * (float)(v463 * v463));
  *(_QWORD *)&v468 = LODWORD(v466);
  *(float *)&v468 = v466 + *(float *)&v458;
  *(float *)(a1 + 25920) = (float)((float)(v467 + v465) + v463) * v460;
  if ( (float)(v466 + *(float *)&v458) < 0.0 )
    v469 = v466 - 1.0;
  else
    v469 = v466 + 1.0;
  v470 = *(float *)&v468;
  if ( *(float *)&v468 >= 0.0 )
  {
    if ( *(float *)&v468 > 0.0 )
      v470 = 1.0;
  }
  else
  {
    v470 = -1.0;
  }
  v471 = *(float *)(a1 + 25664);
  v472 = v470 * *(float *)(a1 + 26688);
  *(float *)&v468 = *(float *)&v468 / v469;
  v473 = sub_180368FC0(v468).m128_f32[0];
  v474 = *(float *)(a1 + 26608);
  if ( v471 < v474 || v474 <= *(float *)(a1 + 25680) )
  {
    v475 = *(unsigned int *)(a1 + 25696);
  }
  else
  {
    v475 = *(unsigned int *)(a1 + 25696);
    *(float *)&v475 = *(float *)&v475 + 2.0;
  }
  v476 = (float)((float)(v473 * *(float *)(a1 + 25824)) * 256.0) * *(float *)(a1 + 26640);
  if ( *(float *)&v475 >= 4.0 )
    v475 = 0;
  if ( v476 >= -1.0 )
    v477 = fminf(v476, 1.0);
  else
    v477 = -1.0;
  *(_DWORD *)(a1 + 25696) = v475;
  v478 = v477 * *(float *)(a1 + 26576);
  *(float *)&v475 = (float)((float)((float)(*(float *)&v475 + v471) + 1.0) * 0.5) - 1.0;
  v479 = (float)((float)((float)((float)((float)((float)((float)((float)(v478 * v478) * *(float *)(a1 + 27040))
                                                       + *(float *)(a1 + 27024))
                                               * (float)((float)(v478 * v478) * (float)(v478 * v478)))
                                       + (float)((float)((float)(v478 * v478) * *(float *)(a1 + 27008))
                                               + *(float *)(a1 + 26992)))
                               * (float)((float)((float)(v478 * v478) * v478) * (float)(v478 * v478)))
                       + (float)((float)((float)(v478 * v478) * v478) * *(float *)(a1 + 26976)))
               + v478)
       * v472;
  *(float *)(a1 + 25936) = v479;
  v480 = sub_180368FC0(COERCE_DOUBLE(v475 & 0x7FFFFFFF7FFFFFFFLL ^ 0x8000000080000000uLL)).m128_f32[0];
  if ( *(float *)&v475 >= 0.0 )
  {
    if ( *(float *)&v475 > 0.0 )
      LODWORD(v475) = 1065353216;
  }
  else
  {
    LODWORD(v475) = -1082130432;
  }
  v481 = *(float *)&v475 * *(float *)(a1 + 26704);
  v482 = (float)((float)((float)(v480 + 1.0) * *(float *)(a1 + 25824)) * 512.0) * *(float *)(a1 + 26656);
  if ( v482 >= -1.0 )
    v483 = fminf(v482, 1.0);
  else
    v483 = -1.0;
  v484 = v483 * *(float *)(a1 + 26576);
  v486 = *(unsigned int *)(a1 + 25664);
  v485 = *(_DWORD *)(a1 + 25696);
  *(float *)(a1 + 26224) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v484 * v484)
                                                                                                 * *(float *)(a1 + 27040))
                                                                                         + *(float *)(a1 + 27024))
                                                                                 * (float)((float)(v484 * v484)
                                                                                         * (float)(v484 * v484)))
                                                                         + (float)((float)((float)(v484 * v484)
                                                                                         * *(float *)(a1 + 27008))
                                                                                 + *(float *)(a1 + 26992)))
                                                                 * (float)((float)((float)(v484 * v484) * v484)
                                                                         * (float)(v484 * v484)))
                                                         + (float)((float)((float)(v484 * v484) * v484)
                                                                 * *(float *)(a1 + 26976)))
                                                 + v484)
                                         * v481)
                                 * *(float *)(a1 + 25792))
                         + (float)((float)(*(float *)(a1 + 25920) * *(float *)(a1 + 25760))
                                 + (float)(v479 * *(float *)(a1 + 25776)));
  *(_DWORD *)(a1 + 25680) = v486;
  *(_DWORD *)(a1 + 25696) = v485;
  *(float *)&v486 = *(float *)&v486 + *(float *)(a1 + 25808);
  if ( *(float *)&v486 <= 1.0 )
  {
    if ( *(float *)&v486 < -1.0 )
      *(float *)&v486 = fmodf(*(float *)&v486 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v486 = fmodf(*(float *)&v486 + 1.0, 2.0) - 1.0;
  }
  HIDWORD(v487) = HIDWORD(v486);
  *(_DWORD *)(a1 + 25664) = v486;
  v488 = *(float *)&v486 * *(float *)(a1 + 26672);
  *(float *)&v487 = (float)(*(float *)&v486 + 1.0) * 0.5;
  v489 = (float)((float)(sub_180368FC0(v487).m128_f32[0] * 256.0) * *(float *)(a1 + 25824)) * *(float *)(a1 + 26624);
  if ( v489 >= -1.0 )
    v490 = fminf(v489, 1.0);
  else
    v490 = -1.0;
  v491 = v490 * *(float *)(a1 + 26576);
  v492 = (float)(v491 * v491) * v491;
  v493 = v492 * *(float *)(a1 + 26976);
  v494 = *(float *)(a1 + 25840);
  v495 = (float)((float)((float)((float)((float)(v491 * v491) * *(float *)(a1 + 27040)) + *(float *)(a1 + 27024))
                       * (float)((float)(v491 * v491) * (float)(v491 * v491)))
               + (float)((float)((float)(v491 * v491) * *(float *)(a1 + 27008)) + *(float *)(a1 + 26992)))
       * (float)(v492 * (float)(v491 * v491));
  *(_QWORD *)&v496 = LODWORD(v494);
  *(float *)&v496 = v494 + *(float *)&v486;
  *(float *)(a1 + 25920) = (float)((float)(v495 + v493) + v491) * v488;
  if ( (float)(v494 + *(float *)&v486) < 0.0 )
    v497 = v494 - 1.0;
  else
    v497 = v494 + 1.0;
  v498 = *(float *)&v496;
  if ( *(float *)&v496 >= 0.0 )
  {
    if ( *(float *)&v496 > 0.0 )
      v498 = 1.0;
  }
  else
  {
    v498 = -1.0;
  }
  v499 = *(float *)(a1 + 25664);
  v500 = v498 * *(float *)(a1 + 26688);
  *(float *)&v496 = *(float *)&v496 / v497;
  v501 = sub_180368FC0(v496).m128_f32[0];
  v502 = *(float *)(a1 + 26608);
  if ( v499 < v502 || v502 <= *(float *)(a1 + 25680) )
  {
    v503 = *(unsigned int *)(a1 + 25696);
  }
  else
  {
    v503 = *(unsigned int *)(a1 + 25696);
    *(float *)&v503 = *(float *)&v503 + 2.0;
  }
  v504 = (float)((float)(v501 * *(float *)(a1 + 25824)) * 256.0) * *(float *)(a1 + 26640);
  if ( *(float *)&v503 >= 4.0 )
    v503 = 0;
  if ( v504 >= -1.0 )
    v505 = fminf(v504, 1.0);
  else
    v505 = -1.0;
  *(_DWORD *)(a1 + 25696) = v503;
  v506 = v505 * *(float *)(a1 + 26576);
  *(float *)&v503 = (float)((float)((float)(*(float *)&v503 + v499) + 1.0) * 0.5) - 1.0;
  v507 = (float)((float)((float)((float)((float)((float)((float)((float)(v506 * v506) * *(float *)(a1 + 27040))
                                                       + *(float *)(a1 + 27024))
                                               * (float)((float)(v506 * v506) * (float)(v506 * v506)))
                                       + (float)((float)((float)(v506 * v506) * *(float *)(a1 + 27008))
                                               + *(float *)(a1 + 26992)))
                               * (float)((float)((float)(v506 * v506) * v506) * (float)(v506 * v506)))
                       + (float)((float)((float)(v506 * v506) * v506) * *(float *)(a1 + 26976)))
               + v506)
       * v500;
  *(float *)(a1 + 25936) = v507;
  v508 = sub_180368FC0(COERCE_DOUBLE(v503 & 0x7FFFFFFF7FFFFFFFLL ^ 0x8000000080000000uLL)).m128_f32[0] + 1.0;
  if ( *(float *)&v503 >= 0.0 )
  {
    if ( *(float *)&v503 > 0.0 )
      LODWORD(v503) = 1065353216;
  }
  else
  {
    LODWORD(v503) = -1082130432;
  }
  v509 = *(float *)&v503 * *(float *)(a1 + 26704);
  v510 = (float)((float)(v508 * *(float *)(a1 + 25824)) * 512.0) * *(float *)(a1 + 26656);
  if ( v510 >= -1.0 )
    v33 = fminf(v510, 1.0);
  v511 = v33 * *(float *)(a1 + 26576);
  v512 = *(_DWORD *)(a1 + 25664);
  v513 = *(_DWORD *)(a1 + 25696);
  *(float *)(a1 + 26352) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v511 * v511)
                                                                                                 * *(float *)(a1 + 27040))
                                                                                         + *(float *)(a1 + 27024))
                                                                                 * (float)((float)(v511 * v511)
                                                                                         * (float)(v511 * v511)))
                                                                         + (float)((float)((float)(v511 * v511)
                                                                                         * *(float *)(a1 + 27008))
                                                                                 + *(float *)(a1 + 26992)))
                                                                 * (float)((float)((float)(v511 * v511) * v511)
                                                                         * (float)(v511 * v511)))
                                                         + (float)((float)((float)(v511 * v511) * v511)
                                                                 * *(float *)(a1 + 26976)))
                                                 + v511)
                                         * v509)
                                 * *(float *)(a1 + 25792))
                         + (float)((float)(*(float *)(a1 + 25920) * *(float *)(a1 + 25760))
                                 + (float)(v507 * *(float *)(a1 + 25776)));
  v514 = *(float *)(a1 + 26464);
  *(_DWORD *)(a1 + 25888) = v512;
  *(_DWORD *)(a1 + 25856) = v513;
  v515 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(*(float *)(a1 + 26336) + *(float *)(a1 + 26096))
                                                                                               * *(float *)(a1 + 26736))
                                                                                       + (float)((float)(v514 + *(float *)(a1 + 25968))
                                                                                               * *(float *)(a1 + 26720)))
                                                                               + (float)((float)(*(float *)(a1 + 26224)
                                                                                               + *(float *)(a1 + 26208))
                                                                                       * *(float *)(a1 + 26752)))
                                                                       + (float)((float)(*(float *)(a1 + 26352)
                                                                                       + *(float *)(a1 + 26080))
                                                                               * *(float *)(a1 + 26768)))
                                                               + (float)((float)(*(float *)(a1 + 26448)
                                                                               + *(float *)(a1 + 25984))
                                                                       * *(float *)(a1 + 26784)))
                                                       + (float)((float)(*(float *)(a1 + 26320) + *(float *)(a1 + 26112))
                                                               * *(float *)(a1 + 26800)))
                                               + (float)((float)(*(float *)(a1 + 26240) + *(float *)(a1 + 26192))
                                                       * *(float *)(a1 + 26816)))
                                       + (float)((float)(*(float *)(a1 + 26368) + *(float *)(a1 + 26064))
                                               * *(float *)(a1 + 26832)))
                               + (float)((float)(*(float *)(a1 + 26432) + *(float *)(a1 + 26000))
                                       * *(float *)(a1 + 26848)))
                       + (float)((float)(*(float *)(a1 + 26128) + *(float *)(a1 + 26304)) * *(float *)(a1 + 26864)))
               + (float)((float)(*(float *)(a1 + 26256) + *(float *)(a1 + 26176)) * *(float *)(a1 + 26880)))
       + (float)((float)(*(float *)(a1 + 26048) + *(float *)(a1 + 26384)) * *(float *)(a1 + 26896));
  v516 = *(float *)(a1 + 26512);
  v517 = (float)(v516 * *(float *)(a1 + 27280)) + *(float *)(a1 + 26528);
  v518 = (float)((float)(v515
                       + (float)((float)(*(float *)(a1 + 26416) + *(float *)(a1 + 26016)) * *(float *)(a1 + 26912)))
               + (float)((float)(*(float *)(a1 + 26288) + *(float *)(a1 + 26144)) * *(float *)(a1 + 26928)))
       + (float)((float)(*(float *)(a1 + 26272) + *(float *)(a1 + 26160)) * *(float *)(a1 + 26944));
  v519 = (float)(*(float *)(a1 + 26400) + *(float *)(a1 + 26032)) * *(float *)(a1 + 26960);
  *(float *)(a1 + 26512) = v517;
  v520 = v518 + v519;
  v521 = v520 - (float)((float)(v516 * *(float *)(a1 + 27296)) + v517);
  *(float *)(a1 + 26496) = (float)(v521 * *(float *)(a1 + 27280)) + v516;
  v522 = (float)((float)((float)(v517 - (float)(v521 * *(float *)(a1 + 26480))) * *(float *)(a1 + 27360))
               - (float)(*(float *)(a1 + 27360) * v520))
       + v520;
  *(float *)(a1 + 25952) = v522;
  *(float *)(a1 + 24544) = v522;
  if ( *(float *)(a1 + 101568) == 1.0 )
  {
    *(_DWORD *)(a1 + 21344) = v524;
    *(_DWORD *)(a1 + 101568) = 0;
  }
  **a2 = *(_DWORD *)(a1 + 31696);
  result = *(unsigned int *)(a1 + 31696);
  *a2[1] = result;
  return result;
}

