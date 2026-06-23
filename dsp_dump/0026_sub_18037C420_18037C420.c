// sub_18037C420  @ 0x18037C420  (RVA 0x37C420)
// prototype: 
// callees: 0x180368D60, 0x180368FC0, 0x18037C420, 0x1806EF4D8, 0x1806EF740
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

__int64 __fastcall sub_18037C420(__int64 a1, _DWORD **a2)
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

  v2 = *(float *)(a1 + 52880);
  v524 = 0;
  if ( *(float *)(a1 + 101664) == 1.0 )
  {
    v524 = *(_DWORD *)(a1 + 52880);
    v2 = 0.0;
    *(_DWORD *)(a1 + 52880) = 0;
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
  v11 = *(float *)(a1 + 52768);
  v12 = *(float *)(a1 + 52736);
  v13 = v9 & 0xFFFFFF;
  v14 = *(float *)(a1 + 52928);
  v15 = v9;
  v16 = *(float *)(a1 + 52944);
  v17 = v9 | 0xFF000000;
  v18 = v6 * v7;
  *(_DWORD *)(a1 + 52992) = 0;
  *(float *)(a1 + 52784) = v11;
  v19 = 0.0;
  if ( (v15 & 0x1000000) == 0 )
    v17 = v13;
  *(float *)(a1 + 52752) = v12;
  *(_DWORD *)(a1 + 84384) = *(_DWORD *)(a1 + 84368);
  *(_DWORD *)(a1 + 53072) = *(_DWORD *)(a1 + 53056);
  *(float *)(a1 + 52912) = v2;
  v20 = (float)v17 * 0.000000059604645;
  *(float *)(a1 + 52960) = v14;
  *(float *)(a1 + 52976) = v16;
  *(float *)(a1 + 84336) = v20;
  v21 = (float)(v20 * *(float *)(a1 + 84400)) + *(float *)(a1 + 84416);
  *(float *)(a1 + 84368) = v21;
  v22 = v18 - (float)(v7 * v21);
  v23 = *(float *)(a1 + 52832);
  *(float *)(a1 + 52848) = v23;
  v24 = v22 + v21;
  v25 = *(float *)(a1 + 52800);
  v26 = v23 * v25;
  *(float *)(a1 + 52816) = v25;
  *(float *)(a1 + 84432) = v24;
  v27 = *(float *)(a1 + 52864);
  *(float *)(a1 + 52896) = v27;
  *(float *)(a1 + 53008) = v26;
  v28 = (float)((float)(v12 * v26) - (float)(v26 * v27)) + v27;
  v29 = (float)((float)(v11 * v26) - (float)(v2 * v26)) + v2;
  *(float *)(a1 + 53024) = v28;
  *(float *)(a1 + 53040) = v29;
  v30 = v29;
  v31 = v29 + *(float *)(a1 + 53104);
  if ( v31 < 0.0 )
    v32 = v31;
  else
    v32 = 0.0;
  v33 = -1.0;
  if ( v30 == 0.0 )
    v34 = -1.0;
  else
    v34 = v32;
  *(float *)(a1 + 53056) = v34;
  if ( v34 >= 0.0 )
  {
    if ( v34 > 0.0 )
      v34 = 1.0;
  }
  else
  {
    v34 = -1.0;
  }
  v35 = *(float *)(a1 + 53168);
  v36 = v34 + 1.0;
  v37 = *(float *)(a1 + 53328);
  v38 = *(float *)(a1 + 53184);
  v39 = *(_DWORD *)(a1 + 53120);
  v40 = *(float *)(a1 + 53264);
  v41 = v38 + *(float *)(a1 + 53344);
  v42 = 1.0;
  *(float *)(a1 + 53088) = v36;
  *(float *)(a1 + 53120) = v36;
  *(_DWORD *)(a1 + 53136) = v39;
  *(float *)(a1 + 53280) = v40;
  v43 = (float)(v36 * v35) - v35;
  v44 = *(float *)(a1 + 53376);
  v45 = (float)(v43 + 1.0) * *(float *)(a1 + 53152);
  v46 = (float)(*(float *)(a1 + 53232) / (float)((float)(v37 * v38) + *(float *)(a1 + 53360))) * v37;
  v47 = *(float *)(a1 + 53216);
  *(float *)(a1 + 53296) = v45;
  v48 = v47 - v46;
  v49 = *(float *)(a1 + 53248);
  v50 = (float)(v48 + v28) - v40;
  *(float *)(a1 + 53216) = v50;
  v51 = v50 * v41;
  *(float *)(a1 + 53232) = v51;
  v52 = v51 + v40;
  if ( (float)(v44 - fabs(v40 - v28)) < 0.0 )
  {
    v53 = 0.0;
LABEL_25:
    v54 = v53;
    goto LABEL_26;
  }
  v53 = v49 + *(float *)(a1 + 53392);
  if ( v53 < 1.0 )
    goto LABEL_25;
  v54 = 1.0;
LABEL_26:
  v55 = v54;
  *(float *)(a1 + 53248) = v55;
  v56 = (float)((float)(v55 * v28) - (float)(v55 * v52)) + v52;
  if ( v45 == 0.0 )
    v56 = v28;
  v57 = v16 * *(float *)(a1 + 53424);
  *(_DWORD *)(a1 + 53456) = *(_DWORD *)(a1 + 53440);
  v58 = *(float *)(a1 + 53728);
  v59 = *(float *)(a1 + 53472);
  v60 = *(_DWORD *)(a1 + 53568);
  v61 = v57 + (float)(v14 * *(float *)(a1 + 53408));
  v62 = *(_DWORD *)(a1 + 53536);
  v63 = (int)v58;
  *(float *)(a1 + 53440) = v61;
  v64 = *(float *)(a1 + 53504);
  *(float *)(a1 + 53264) = v56;
  *(float *)(a1 + 53312) = v56;
  v65 = *(float *)(a1 + 53664);
  *(float *)(a1 + 53520) = v64;
  *(float *)(a1 + 53488) = v59;
  *(_DWORD *)(a1 + 53552) = v62;
  *(_DWORD *)(a1 + 53584) = v60;
  *(float *)(a1 + 53680) = v65;
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
  v67 = *(float *)(a1 + 53600);
  v68 = (float)((float)(v59 - v65) * *(float *)(a1 + 53712)) + v65;
  v69 = *(float *)(a1 + 53648);
  *(float *)(a1 + 53664) = v68;
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
  v74 = *(float *)(a1 + 53616);
  v75 = expf((float)v73 * *(float *)(a1 + 53760)) * *(float *)(a1 + 53744);
  v76 = v74 * *(float *)(a1 + 53632);
  *(_DWORD *)(a1 + 54144) = *(_DWORD *)(a1 + 54128);
  v77 = v75 + *(float *)(a1 + 53776);
  v78 = *(float *)(a1 + 54064);
  v79 = v64 * *(float *)(a1 + 54464);
  *(_DWORD *)(a1 + 54176) = *(_DWORD *)(a1 + 54160);
  v80 = *(float *)(a1 + 54048);
  v81 = *(float *)(a1 + 54096);
  *(_DWORD *)(a1 + 54208) = *(_DWORD *)(a1 + 54192);
  v82 = *(_DWORD *)(a1 + 84432);
  *(float *)(a1 + 54080) = v78;
  *(float *)(a1 + 54064) = v80;
  *(float *)(a1 + 54112) = v81;
  *(_DWORD *)(a1 + 54000) = v62;
  *(_DWORD *)(a1 + 54016) = v60;
  *(_DWORD *)(a1 + 53984) = v82;
  v83 = (float)(v76 - (float)(v74 * v77)) + v77;
  v84 = *(float *)(a1 + 54416);
  v85 = v79 + v84;
  *(float *)(a1 + 54400) = v84;
  *(float *)(a1 + 53696) = v83;
  if ( v85 >= -1.0 )
    v86 = fminf(v85, 1.0);
  else
    v86 = -1.0;
  v87 = *(unsigned int *)(a1 + 54688);
  *(float *)(a1 + 54048) = v86;
  *(float *)&v87 = fminf(*(float *)&v87, v83 * 0.000015258789);
  v88 = (float)((float)(1.0 - v78) * *(float *)(a1 + 54480)) + v78;
  if ( v88 >= -1.0 )
    v89 = fminf(v88, 1.0);
  else
    v89 = -1.0;
  v90 = *(float *)&v87 * *(float *)(a1 + 54704);
  v91 = v80 - v86;
  *(float *)(a1 + 54224) = v90;
  v92 = v90 + v81;
  if ( v91 < 0.0 )
    v89 = 0.0;
  v93 = *(float *)(a1 + 54432);
  v94 = *(float *)(a1 + 53984);
  *(float *)(a1 + 54064) = v89;
  v95 = v89 + *(float *)(a1 + 54832);
  if ( v91 >= 0.0 )
    v93 = 1.0;
  v96 = v95 * *(float *)(a1 + 54816);
  *(float *)&v87 = (float)(v92 * v93) * *(float *)(a1 + 54448);
  if ( v96 <= 0.0 )
    v97 = 0.0;
  else
    v97 = v96;
  v98 = v97;
  v99 = (float)((float)(v94 - *(float *)(a1 + 54144)) * *(float *)(a1 + 55024)) + *(float *)(a1 + 54144);
  *(float *)(a1 + 54128) = v99;
  *(float *)(a1 + 54032) = v98;
  v525 = *(float *)(a1 + 54112);
  v100 = (float)((float)((float)(v99 * *(float *)(a1 + 55008)) * *(float *)(a1 + 54624))
               - (float)(v94 * *(float *)(a1 + 54624)))
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
  v101 = *(float *)(a1 + 54176);
  *(_DWORD *)(a1 + 54096) = v87;
  v102 = *(float *)&v87 + *(float *)(a1 + 54848);
  *(float *)(a1 + 53968) = v100 * *(float *)(a1 + 54992);
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
  *(float *)(a1 + 54160) = v101;
  v103 = v101 * *(float *)(a1 + 54976);
  v104 = (float)(v102 * *(float *)(a1 + 54912)) + *(float *)(a1 + 55040);
  *(float *)(a1 + 54240) = v104;
  *(float *)(a1 + 54320) = v103;
  HIDWORD(v105) = HIDWORD(v87);
  *(float *)&v105 = *(float *)&v87 + *(float *)(a1 + 54880);
  *(float *)(a1 + 54256) = -v104;
  if ( *(float *)&v105 <= 1.0 )
  {
    if ( *(float *)&v105 < -1.0 )
      *(float *)&v105 = fmodf(*(float *)&v105 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&v105 = fmodf(*(float *)&v105 + 1.0, 2.0) - 1.0;
  }
  v106 = *(float *)&v87 + *(float *)(a1 + 54864);
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
  v108 = v106 + *(float *)(a1 + 55056);
  v109 = v107 * *(float *)(a1 + 54944);
  if ( v108 >= 0.0 )
  {
    if ( v108 > 0.0 )
      v108 = 1.0;
  }
  else
  {
    v108 = -1.0;
  }
  v110 = *(float *)&v87 + *(float *)(a1 + 54896);
  *(float *)(a1 + 54288) = v109;
  *(float *)(a1 + 54384) = v108;
  v111 = (float)(v108 * *(float *)(a1 + 54928)) + *(float *)(a1 + 55072);
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
  *(float *)(a1 + 54272) = v111;
  v113 = *(float *)(a1 + 54528);
  v114 = (float)((float)(*(float *)(a1 + 54592) * *(float *)(a1 + 54320))
               + (float)(*(float *)(a1 + 54560) * *(float *)(a1 + 54240)))
       + (float)(*(float *)(a1 + 54576) * *(float *)(a1 + 54256));
  v115 = (float)((float)((float)((float)(v112 * (float)((float)(v112 * v112) * v112)) * *(float *)(a1 + 54784))
                       + (float)((float)((float)((float)(v112 * v112) * v112) * *(float *)(a1 + 54768))
                               + (float)((float)((float)(v112 * *(float *)(a1 + 54736)) + *(float *)(a1 + 54720))
                                       + (float)((float)(v112 * v112) * *(float *)(a1 + 54752)))))
               + *(float *)(a1 + 54800))
       * *(float *)(a1 + 54960);
  *(float *)(a1 + 54304) = v115;
  v116 = (float)(v113 * *(float *)(a1 + 54288)) + v114;
  v117 = *(float *)(a1 + 54640);
  v118 = (float)((float)(*(float *)(a1 + 54496) * *(float *)(a1 + 54032)) - *(float *)(a1 + 54496)) + 1.0;
  v119 = (float)((float)(v116 + (float)(*(float *)(a1 + 54544) * *(float *)(a1 + 54272)))
               + (float)(v115 * *(float *)(a1 + 54512)))
       + (float)(*(float *)(a1 + 54608) * *(float *)(a1 + 53968));
  *(float *)(a1 + 54336) = v118;
  *(float *)(a1 + 54368) = v119;
  *(float *)(a1 + 54352) = (float)((float)(*(float *)(a1 + 54672) * *(float *)(a1 + 54016))
                                 + (float)(*(float *)(a1 + 54656) * *(float *)(a1 + 54000)))
                         + (float)((float)(v117 * v118) * v119);
  v120 = *(_DWORD *)(a1 + 54368);
  *(_DWORD *)(a1 + 55088) = *(_DWORD *)(a1 + 54384);
  *(_DWORD *)(a1 + 55104) = v120;
  if ( *(float *)(a1 + 54384) <= 0.0 )
    v121 = 0.0;
  else
    v121 = 1.0;
  if ( *(float *)(a1 + 55120) == 0.0 )
    v121 = 1.0;
  v122 = *(float *)(a1 + 53120) * v121;
  *(float *)(a1 + 55136) = v122;
  *(_DWORD *)(a1 + 55168) = *(_DWORD *)(a1 + 55152);
  *(_DWORD *)(a1 + 55216) = *(_DWORD *)(a1 + 55200);
  *(_DWORD *)(a1 + 55200) = *(_DWORD *)(a1 + 55184);
  *(_DWORD *)(a1 + 55248) = *(_DWORD *)(a1 + 55232);
  *(_DWORD *)(a1 + 55296) = *(_DWORD *)(a1 + 55280);
  if ( (float)(v122 + *(float *)(a1 + 55424)) >= 0.0 )
    v123 = 0.0;
  else
    v123 = 1.0;
  v124 = 1.0 - v123;
  v125 = (float)(1.0 - v123)
       * (float)((float)(*(float *)(a1 + 55456) * *(float *)(a1 + 55216)) + *(float *)(a1 + 55168));
  *(float *)(a1 + 55184) = v125;
  v126 = v125 + *(float *)(a1 + 55440);
  v127 = v125 - *(float *)(a1 + 55200);
  *(float *)(a1 + 55264) = (float)((float)(*(float *)(a1 + 55408) * *(float *)(a1 + 55520))
                                 - (float)(*(float *)(a1 + 55488) * *(float *)(a1 + 55408)))
                         + *(float *)(a1 + 55488);
  if ( v126 < 0.0 )
    v128 = 0.0;
  else
    v128 = 1.0;
  if ( v127 < 0.0 )
    v128 = 1.0 - v123;
  v129 = *(float *)(a1 + 55344);
  v130 = v124 * (float)(*(float *)(a1 + 55360) * *(float *)(a1 + 55488));
  *(float *)(a1 + 55200) = v128;
  v131 = *(float *)(a1 + 55248);
  v132 = (float)(v130 - (float)(*(float *)(a1 + 55504) * v124)) + *(float *)(a1 + 55504);
  v133 = v124 * (float)(1.0 - v128);
  v134 = (float)((float)(*(float *)(a1 + 55376) * 0.00390625) * v128) + (float)((float)(v129 * 0.00390625) * v133);
  if ( (float)(v132 - v131) > 0.0 )
    v132 = v131 + *(float *)(a1 + 55264);
  v135 = *(float *)(a1 + 55168);
  v136 = fminf(*(float *)(a1 + 55488), v132);
  *(float *)(a1 + 55232) = v136;
  v137 = *(float *)(a1 + 55392);
  v138 = (float)((float)(v133 * *(float *)(a1 + 55472)) + (float)(v128 * v136)) - v135;
  v139 = (float)((float)(*(float *)(a1 + 55536) * v134) - (float)(*(float *)(a1 + 55536) * *(float *)(a1 + 55296)))
       + *(float *)(a1 + 55296);
  *(float *)(a1 + 55280) = v139;
  v140 = (float)((float)((float)((float)((float)(v137 * 0.00390625) * v123) - (float)(v123 * v139)) + v139) * v138)
       + v135;
  *(float *)(a1 + 55152) = v140;
  v141 = (float)(v140 * *(float *)(a1 + 55552)) * *(float *)(a1 + 55568);
  v142 = v141 * *(float *)(a1 + 55584);
  *(float *)(a1 + 55312) = v141;
  *(float *)(a1 + 55328) = v142;
  if ( *(float *)(a1 + 54384) <= 0.0 )
    v143 = 0.0;
  else
    v143 = 1.0;
  if ( *(float *)(a1 + 55600) == 0.0 )
    v143 = 1.0;
  v144 = *(float *)(a1 + 53120) * v143;
  *(float *)(a1 + 55616) = v144;
  *(_DWORD *)(a1 + 55648) = *(_DWORD *)(a1 + 55632);
  *(_DWORD *)(a1 + 55696) = *(_DWORD *)(a1 + 55680);
  *(_DWORD *)(a1 + 55680) = *(_DWORD *)(a1 + 55664);
  *(_DWORD *)(a1 + 55728) = *(_DWORD *)(a1 + 55712);
  *(_DWORD *)(a1 + 55776) = *(_DWORD *)(a1 + 55760);
  if ( (float)(v144 + *(float *)(a1 + 55904)) >= 0.0 )
    v145 = 0.0;
  else
    v145 = 1.0;
  v146 = 1.0 - v145;
  v147 = (float)(1.0 - v145)
       * (float)((float)(*(float *)(a1 + 55936) * *(float *)(a1 + 55696)) + *(float *)(a1 + 55648));
  *(float *)(a1 + 55664) = v147;
  v148 = v147 + *(float *)(a1 + 55920);
  v149 = v147 - *(float *)(a1 + 55680);
  *(float *)(a1 + 55744) = (float)((float)(*(float *)(a1 + 55888) * *(float *)(a1 + 56000))
                                 - (float)(*(float *)(a1 + 55968) * *(float *)(a1 + 55888)))
                         + *(float *)(a1 + 55968);
  if ( v148 < 0.0 )
    v150 = 0.0;
  else
    v150 = 1.0;
  if ( v149 < 0.0 )
    v150 = 1.0 - v145;
  v151 = *(float *)(a1 + 55840) * *(float *)(a1 + 55968);
  v152 = *(float *)(a1 + 55824);
  *(float *)(a1 + 55680) = v150;
  v153 = *(float *)(a1 + 55728);
  v154 = (float)((float)(v146 * v151) - (float)(*(float *)(a1 + 55984) * v146)) + *(float *)(a1 + 55984);
  v155 = v146 * (float)(1.0 - v150);
  v156 = (float)((float)(*(float *)(a1 + 55856) * 0.00390625) * v150) + (float)((float)(v152 * 0.00390625) * v155);
  if ( (float)(v154 - v153) > 0.0 )
    v154 = v153 + *(float *)(a1 + 55744);
  v157 = *(float *)(a1 + 55648);
  v158 = fminf(*(float *)(a1 + 55968), v154);
  *(float *)(a1 + 55712) = v158;
  v159 = (float)(*(float *)(a1 + 55872) * 0.00390625) * v145;
  v160 = (float)((float)(v155 * *(float *)(a1 + 55952)) + (float)(v150 * v158)) - v157;
  v161 = (float)((float)(*(float *)(a1 + 56016) * v156) - (float)(*(float *)(a1 + 56016) * *(float *)(a1 + 55776)))
       + *(float *)(a1 + 55776);
  *(float *)(a1 + 55760) = v161;
  v162 = (float)((float)((float)(v159 - (float)(v145 * v161)) + v161) * v160) + v157;
  *(float *)(a1 + 55632) = v162;
  v163 = (float)(v162 * *(float *)(a1 + 56032)) * *(float *)(a1 + 56048);
  v164 = v163 * *(float *)(a1 + 56064);
  *(float *)(a1 + 55792) = v163;
  *(float *)(a1 + 55808) = v164;
  *(_DWORD *)(a1 + 56096) = *(_DWORD *)(a1 + 56080);
  *(_DWORD *)(a1 + 56128) = *(_DWORD *)(a1 + 56112);
  v165 = *(float *)(a1 + 53312);
  v166 = *(float *)(a1 + 53440);
  *(_DWORD *)(a1 + 56192) = *(_DWORD *)(a1 + 56176);
  v167 = (float)(v166 * *(float *)(a1 + 56160)) + (float)(v165 * *(float *)(a1 + 56144));
  *(float *)(a1 + 56176) = v167;
  v168 = *(float *)(a1 + 54352);
  v169 = *(_DWORD *)(a1 + 55312);
  v170 = *(_DWORD *)(a1 + 55792);
  v171 = *(_DWORD *)(a1 + 53312);
  *(_DWORD *)(a1 + 56240) = *(_DWORD *)(a1 + 56112);
  *(_DWORD *)(a1 + 56256) = v171;
  v172 = *(float *)(a1 + 56576);
  *(_DWORD *)(a1 + 56208) = v169;
  *(_DWORD *)(a1 + 56224) = v170;
  v173 = *(float *)(a1 + 56544);
  v174 = v168 * v172;
  v175 = v172 * *(float *)(a1 + 54368);
  *(float *)(a1 + 56272) = v175;
  v176 = *(float *)(a1 + 56672);
  v177 = *(float *)(a1 + 56416);
  v178 = v174 * *(float *)(a1 + 56592);
  v179 = *(float *)(a1 + 56608);
  v180 = (float)(v173 * v175) * *(float *)(a1 + 56560);
  *(float *)(a1 + 56304) = v180;
  v181 = *(float *)(a1 + 56432);
  v182 = (float)((float)((float)(v177 * *(float *)(a1 + 56240)) - (float)(v176 * v177)) + v176) * *(float *)(a1 + 56688);
  *(float *)(a1 + 56320) = v182;
  v183 = (float)((float)(v179 * v178) + v180) + (float)(v181 * v182);
  v184 = *(float *)(a1 + 56272);
  v185 = *(_DWORD *)(a1 + 56400);
  *(float *)(a1 + 56336) = (float)((float)((float)((float)((float)((float)(*(float *)(a1 + 56640)
                                                                         * *(float *)(a1 + 56224))
                                                                 + (float)(*(float *)(a1 + 56624)
                                                                         * *(float *)(a1 + 56208)))
                                                         * *(float *)(a1 + 56656))
                                                 + v183)
                                         + v167)
                                 + *(float *)(a1 + 56512))
                         + *(float *)(a1 + 56528);
  *(_DWORD *)(a1 + 56352) = v185;
  v186 = (float)(*(float *)(a1 + 56304) + *(float *)(a1 + 56256)) + *(float *)(a1 + 56320);
  *(float *)(a1 + 56368) = (float)((float)((float)((float)((float)((float)(v184 * *(float *)(a1 + 56720))
                                                                 + *(float *)(a1 + 56736))
                                                         * *(float *)(a1 + 56448))
                                                 + (float)(*(float *)(a1 + 56464) * *(float *)(a1 + 56208)))
                                         + (float)(*(float *)(a1 + 56480) * *(float *)(a1 + 56224)))
                                 + *(float *)(a1 + 56496))
                         * *(float *)(a1 + 56704);
  *(float *)(a1 + 56384) = v186;
  v187 = *(_DWORD *)(a1 + 56768);
  *(_DWORD *)(a1 + 56800) = *(_DWORD *)(a1 + 56752);
  *(_DWORD *)(a1 + 56816) = v187;
  *(_DWORD *)(a1 + 56832) = *(_DWORD *)(a1 + 56784);
  v188 = *(float *)(a1 + 84432);
  *(_DWORD *)(a1 + 56880) = *(_DWORD *)(a1 + 56864);
  v189 = *(float *)(a1 + 56848);
  *(float *)(a1 + 56864) = v189;
  v190 = (float)(v189 * *(float *)(a1 + 56896)) + *(float *)(a1 + 56880);
  *(float *)(a1 + 56864) = v190;
  v191 = (float)(v189 * *(float *)(a1 + 56912)) + v190;
  v192 = v190 * *(float *)(a1 + 56960);
  v193 = v188 - v191;
  v194 = (float)(v193 * *(float *)(a1 + 56896)) + v189;
  *(float *)(a1 + 56848) = v194;
  *(float *)(a1 + 56880) = (float)((float)(v193 * *(float *)(a1 + 56928)) + v192)
                         + (float)(v194 * *(float *)(a1 + 56944));
  *(_DWORD *)(a1 + 58992) = *(_DWORD *)(a1 + 58976);
  v195 = *(float *)(a1 + 59008);
  *(float *)(a1 + 59024) = v195;
  v196 = v195 * *(float *)(a1 + 56096);
  v197 = *(float *)(a1 + 58992) * *(float *)(a1 + 56880);
  *(float *)(a1 + 59040) = v196;
  *(float *)(a1 + 59056) = v197;
  *(_DWORD *)(a1 + 59120) = *(_DWORD *)(a1 + 59104);
  *(float *)(a1 + 59104) = (float)(v197 * *(float *)(a1 + 59088)) + (float)(v196 * *(float *)(a1 + 59072));
  *(_DWORD *)(a1 + 59152) = *(_DWORD *)(a1 + 59136);
  *(_DWORD *)(a1 + 59184) = *(_DWORD *)(a1 + 59168);
  *(_DWORD *)(a1 + 59216) = *(_DWORD *)(a1 + 59200);
  *(_DWORD *)(a1 + 59248) = *(_DWORD *)(a1 + 59232);
  v198 = (float)((float)(*(float *)(a1 + 59280) * *(float *)(a1 + 59136))
               - (float)(*(float *)(a1 + 59296) * *(float *)(a1 + 59280)))
       + *(float *)(a1 + 59296);
  v199 = (float)((float)((float)((float)(v198 * v198) * v198) * v198) * *(float *)(a1 + 59376))
       + (float)((float)((float)((float)(v198 * v198) * v198) * *(float *)(a1 + 59360))
               + (float)((float)((float)(v198 * *(float *)(a1 + 59328)) + *(float *)(a1 + 59312))
                       + (float)((float)(v198 * v198) * *(float *)(a1 + 59344))));
  if ( v199 <= 0.0 )
    v200 = 0.0;
  else
    v200 = v199;
  v201 = v200;
  if ( v201 < 1.0 )
    v42 = v201;
  v202 = v42;
  *(float *)(a1 + 59264) = v202;
  *(_DWORD *)(a1 + 59408) = *(_DWORD *)(a1 + 59392);
  v203 = *(float *)(a1 + 59424);
  *(float *)(a1 + 59440) = v203;
  v204 = *(float *)(a1 + 59456);
  *(float *)(a1 + 59472) = v204;
  *(float *)(a1 + 59456) = (float)((float)(v203 - v204) * *(float *)(a1 + 59488)) + v204;
  v205 = *(float *)(a1 + 53312);
  v206 = *(float *)(a1 + 53440);
  *(_DWORD *)(a1 + 59552) = *(_DWORD *)(a1 + 59536);
  *(float *)(a1 + 59536) = (float)(v206 * *(float *)(a1 + 59520)) + (float)(v205 * *(float *)(a1 + 59504));
  *(_DWORD *)(a1 + 59600) = *(_DWORD *)(a1 + 59568);
  v207 = *(float *)(a1 + 59584);
  *(float *)(a1 + 59616) = v207;
  v208 = *(float *)(a1 + 55312)
       + (float)((float)(*(float *)(a1 + 59600) * *(float *)(a1 + 55792))
               - (float)(*(float *)(a1 + 59600) * *(float *)(a1 + 55312)));
  *(float *)(a1 + 59632) = (float)((float)(v207 * *(float *)(a1 + 59200)) - (float)(v207 * v208)) + v208;
  v209 = *(float *)(a1 + 54352);
  v210 = *(float *)(a1 + 59648);
  *(float *)(a1 + 59664) = v210;
  v211 = v209 - v210;
  v212 = (float)(v211 * *(float *)(a1 + 59680)) + v210;
  v213 = *(float *)(a1 + 59712);
  *(float *)(a1 + 59648) = v212;
  *(float *)(a1 + 59664) = (float)(v211 * *(float *)(a1 + 59696)) + (float)(v213 * v212);
  v214 = *(float *)(a1 + 59728);
  v215 = *(float *)(a1 + 54368);
  *(float *)(a1 + 59744) = v214;
  v216 = v215 - v214;
  v217 = (float)(v216 * *(float *)(a1 + 59760)) + v214;
  v218 = *(float *)(a1 + 59792);
  *(float *)(a1 + 59728) = v217;
  v219 = (float)(v216 * *(float *)(a1 + 59776)) + (float)(v218 * v217);
  *(float *)(a1 + 59744) = v219;
  v220 = *(float *)(a1 + 59664);
  v221 = *(float *)(a1 + 59632);
  v222 = *(float *)(a1 + 59536);
  v223 = *(float *)(a1 + 59168);
  *(_DWORD *)(a1 + 59808) = *(_DWORD *)(a1 + 59456);
  *(float *)(a1 + 59824) = v223;
  v224 = *(float *)(a1 + 59856);
  v225 = *(float *)(a1 + 59872) * *(float *)(a1 + 59232);
  v226 = (float)((float)((float)((float)((float)(v223 * *(float *)(a1 + 59888))
                                       - (float)(*(float *)(a1 + 60016) * *(float *)(a1 + 59888)))
                               + *(float *)(a1 + 60016))
                       * *(float *)(a1 + 60032))
               + (float)((float)((float)(*(float *)(a1 + 60000) + *(float *)(a1 + 59808)) * *(float *)(a1 + 60064))
                       * *(float *)(a1 + 59984)))
       + (float)((float)((float)((float)((float)((float)(v225 - (float)(*(float *)(a1 + 59872) * (float)(v219 * v224)))
                                               + (float)(v219 * v224))
                                       * *(float *)(a1 + 59920))
                               * *(float *)(a1 + 59936))
                       + (float)((float)((float)(v225 - (float)(*(float *)(a1 + 59872) * (float)(v220 * v224)))
                                       + (float)(v220 * v224))
                               * *(float *)(a1 + 59904)))
               + (float)((float)((float)(v222 + *(float *)(a1 + 60048)) * *(float *)(a1 + 59968))
                       + (float)(v221 * *(float *)(a1 + 59952))));
  *(float *)(a1 + 59840) = v226;
  v227 = (__m128)*(unsigned int *)(a1 + 59264);
  v228 = *(float *)(a1 + 59408);
  *(_DWORD *)(a1 + 60144) = *(_DWORD *)(a1 + 60128);
  v229 = *(float *)(a1 + 60112);
  *(float *)(a1 + 60128) = v229;
  if ( *(float *)(a1 + 60192) == 1.0 )
  {
    v230 = *(float *)(a1 + 60144)
         + (float)((float)(*(float *)(a1 + 60272) * v229) - (float)(*(float *)(a1 + 60272) * *(float *)(a1 + 60144)));
    *(float *)(a1 + 60128) = v230;
    v231 = (float)(v230 * *(float *)(a1 + 60256)) + *(float *)(a1 + 60160);
    *(float *)(a1 + 60112) = sub_180368D60(-v229);
    v232 = (float)(1.0 - v228) * *(float *)(a1 + 60288);
    *(float *)(a1 + 60096) = (float)(v228 * *(float *)(a1 + 60352)) + *(float *)(a1 + 60176);
    v227.m128_f32[0] = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v227.m128_f32[0] * *(float *)(a1 + 60208))
                                                         + (float)(v226 * *(float *)(a1 + 60240)))
                                                 + v231)
                                         + fminf(*(float *)(a1 + 60304), v232))
                                 + *(float *)(a1 + 60224),
                                   *(float *)(a1 + 60320)),
                                 *(float *)(a1 + 60336))
                             * *(float *)(a1 + 60384))
                     + *(float *)(a1 + 60400);
    v233 = v227.m128_f32[0];
    v234 = (int)v227.m128_f32[0];
    if ( (int)v227.m128_f32[0] != 0x80000000 && (float)v234 != v227.m128_f32[0] )
      v233 = (float)(v234 - (_mm_movemask_ps(_mm_unpacklo_ps(v227, v227)) & 1));
    v235 = v227.m128_f32[0] - v233;
    v236 = (float)(v235 * v235) * 0.25;
    v237 = (float)(expf(v233)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v235 * *(float *)(a1 + 60592)) + *(float *)(a1 + 60576)) * v236) + (float)(v235 * *(float *)(a1 + 60560))) + *(float *)(a1 + 60544)) * v236) + (float)(v235 * *(float *)(a1 + 60528)))
                                                                                                 + *(float *)(a1 + 60512))
                                                                                         * v236)
                                                                                 + (float)(v235 * *(float *)(a1 + 60496)))
                                                                         + *(float *)(a1 + 60480))
                                                                 * v236)
                                                         + (float)(v235 * *(float *)(a1 + 60464)))
                                                 + *(float *)(a1 + 60448))
                                         * v236)
                                 + (float)(v235 * *(float *)(a1 + 60432)))
                         + 1.0))
         * *(float *)(a1 + 60416);
    v238 = v237 * v237;
    v239 = (float)((float)((float)((float)((float)((float)((float)((float)(v237 * v237) * *(float *)(a1 + 60752))
                                                         + *(float *)(a1 + 60720))
                                                 * (float)(v238 * v238))
                                         + (float)((float)((float)(v237 * v237) * *(float *)(a1 + 60688))
                                                 + *(float *)(a1 + 60656)))
                                 * (float)((float)((float)(v237 * v237) * v237) * (float)(v237 * v237)))
                         + (float)((float)((float)(v237 * v237) * v237) * *(float *)(a1 + 60624)))
                 + v237)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v237 * v237) * *(float *)(a1 + 60736))
                                                                 + *(float *)(a1 + 60704))
                                                         * (float)(v238 * v238))
                                                 + (float)((float)(v237 * v237) * *(float *)(a1 + 60672)))
                                         + *(float *)(a1 + 60640))
                                 * (float)(v238 * v238))
                         + (float)((float)(v237 * v237) * *(float *)(a1 + 60608)))
                 + 1.0);
    v240 = v239 / (float)(v239 + 1.0);
    *(float *)(a1 + 60080) = v240;
  }
  else
  {
    v240 = *(float *)(a1 + 60080);
  }
  v241 = *(float *)(a1 + 59104);
  v242 = *(float *)(a1 + 60096);
  *(_DWORD *)(a1 + 60880) = *(_DWORD *)(a1 + 60864);
  *(_DWORD *)(a1 + 60864) = *(_DWORD *)(a1 + 60848);
  *(_DWORD *)(a1 + 60848) = *(_DWORD *)(a1 + 60832);
  *(_DWORD *)(a1 + 60832) = *(_DWORD *)(a1 + 60816);
  *(_DWORD *)(a1 + 60816) = *(_DWORD *)(a1 + 60800);
  *(_DWORD *)(a1 + 60800) = *(_DWORD *)(a1 + 60784);
  *(_DWORD *)(a1 + 60784) = *(_DWORD *)(a1 + 60768);
  *(_DWORD *)(a1 + 61104) = *(_DWORD *)(a1 + 61088);
  *(_DWORD *)(a1 + 61088) = *(_DWORD *)(a1 + 61072);
  *(_DWORD *)(a1 + 61072) = *(_DWORD *)(a1 + 61056);
  *(_DWORD *)(a1 + 61056) = *(_DWORD *)(a1 + 61040);
  *(_DWORD *)(a1 + 61040) = *(_DWORD *)(a1 + 61024);
  *(_DWORD *)(a1 + 61024) = *(_DWORD *)(a1 + 61008);
  *(_DWORD *)(a1 + 61008) = *(_DWORD *)(a1 + 60992);
  *(_DWORD *)(a1 + 61232) = *(_DWORD *)(a1 + 61216);
  *(_DWORD *)(a1 + 61216) = *(_DWORD *)(a1 + 61200);
  *(_DWORD *)(a1 + 61200) = *(_DWORD *)(a1 + 61184);
  *(_DWORD *)(a1 + 61184) = *(_DWORD *)(a1 + 61168);
  *(_DWORD *)(a1 + 61168) = *(_DWORD *)(a1 + 61152);
  *(_DWORD *)(a1 + 61152) = *(_DWORD *)(a1 + 61136);
  *(_DWORD *)(a1 + 61136) = *(_DWORD *)(a1 + 61120);
  *(_DWORD *)(a1 + 61360) = *(_DWORD *)(a1 + 61344);
  *(_DWORD *)(a1 + 61344) = *(_DWORD *)(a1 + 61328);
  *(_DWORD *)(a1 + 61328) = *(_DWORD *)(a1 + 61312);
  *(_DWORD *)(a1 + 61312) = *(_DWORD *)(a1 + 61296);
  *(_DWORD *)(a1 + 61296) = *(_DWORD *)(a1 + 61280);
  *(_DWORD *)(a1 + 61280) = *(_DWORD *)(a1 + 61264);
  *(_DWORD *)(a1 + 61264) = *(_DWORD *)(a1 + 61248);
  *(_DWORD *)(a1 + 61488) = *(_DWORD *)(a1 + 61472);
  *(_DWORD *)(a1 + 61472) = *(_DWORD *)(a1 + 61456);
  *(_DWORD *)(a1 + 61456) = *(_DWORD *)(a1 + 61440);
  *(_DWORD *)(a1 + 61440) = *(_DWORD *)(a1 + 61424);
  *(_DWORD *)(a1 + 61424) = *(_DWORD *)(a1 + 61408);
  *(_DWORD *)(a1 + 61408) = *(_DWORD *)(a1 + 61392);
  *(_DWORD *)(a1 + 61392) = *(_DWORD *)(a1 + 61376);
  *(_DWORD *)(a1 + 61520) = *(_DWORD *)(a1 + 61504);
  v243 = *(float *)(a1 + 61536);
  *(float *)(a1 + 61552) = v243;
  if ( *(float *)(a1 + 61616) == 1.0 )
  {
    v244 = (float)((float)((float)(v242 * *(float *)(a1 + 61728)) + 1.0) * (float)(v241 * *(float *)(a1 + 61696)))
         + (float)((float)-v243 * *(float *)(a1 + 61680));
    *(float *)(a1 + 61536) = sub_180368D60(-v243);
    *(float *)(a1 + 61504) = v244;
    v245 = 1.0 - (float)(v240 + v240);
    v246 = 1.0 / (float)((float)((float)((float)(v240 * v240) * (float)(v240 * v240)) * v242) + 1.0);
    *(float *)(a1 + 61584) = v246;
    v247 = *(float *)(a1 + 61504);
    v248 = *(float *)(a1 + 61520);
    *(float *)(a1 + 61568) = v246 * v242;
    v249 = v248 * *(float *)(a1 + 61776);
    v250 = *(float *)(a1 + 60864);
    v251 = v247 * *(float *)(a1 + 61792);
    v252 = *(float *)(a1 + 60880);
    *(float *)(a1 + 60976) = v250;
    v253 = (float)((float)(v249 + v251) * v246)
         - (float)((float)((float)(v250 * *(float *)(a1 + 62080)) + (float)(v252 * *(float *)(a1 + 62096)))
                 * (float)(v246 * v242));
    if ( v253 >= -1.0 )
      v254 = fminf(v253, 1.0);
    else
      v254 = -1.0;
    v255 = v254 + (float)((float)((float)((float)(v254 * v254) * v254) * v254) * (float)(v254 * *(float *)(a1 + 61744)));
    *(float *)(a1 + 60896) = v255;
    v256 = *(float *)(a1 + 60800);
    v257 = (float)(v240 * (float)(v255 + *(float *)(a1 + 60784))) + (float)(v256 * v245);
    *(float *)(a1 + 60912) = v257;
    v258 = *(float *)(a1 + 60816);
    v259 = v240 * (float)(v257 + v256);
    v260 = v240 * (float)((float)((float)(v240 * v255) + (float)(v245 * v257)) + v257);
    v261 = v259 + (float)(v258 * v245);
    *(float *)(a1 + 60928) = v261;
    v262 = *(float *)(a1 + 60832);
    v263 = (float)(v240 * (float)(v261 + v258)) + (float)(v262 * v245);
    *(float *)(a1 + 60944) = v263;
    v264 = (float)((float)(v262 + v263) * v240) + (float)(v245 * *(float *)(a1 + 60848));
    *(float *)(a1 + 60960) = v264;
    v265 = (float)(v240
                 * (float)((float)((float)(v240 * (float)((float)(v260 + (float)(v245 * v261)) + v261))
                                 + (float)(v245 * v263))
                         + v263))
         + (float)(v245 * v264);
    v266 = (float)(*(float *)(a1 + 60944) * *(float *)(a1 + 61648)) + (float)(v264 * *(float *)(a1 + 61664));
    v267 = *(float *)(a1 + 61520);
    *(float *)(a1 + 61376) = v266 + (float)(*(float *)(a1 + 61632) * *(float *)(a1 + 60928));
    v268 = *(float *)(a1 + 60976);
    v269 = (float)((float)(v267 + *(float *)(a1 + 61504)) * *(float *)(a1 + 61808)) * *(float *)(a1 + 61584);
    *(float *)(a1 + 60976) = v265;
    v270 = v269
         - (float)((float)((float)(v265 * *(float *)(a1 + 62080)) + (float)(v268 * *(float *)(a1 + 62096)))
                 * *(float *)(a1 + 61568));
    if ( v270 >= -1.0 )
      v271 = fminf(v270, 1.0);
    else
      v271 = -1.0;
    v272 = v271 + (float)((float)((float)((float)(v271 * v271) * v271) * v271) * (float)(v271 * *(float *)(a1 + 61744)));
    v273 = *(float *)(a1 + 60896);
    *(float *)(a1 + 60896) = v272;
    v274 = *(float *)(a1 + 60912);
    v275 = (float)(v240 * (float)(v272 + v273)) + (float)(v274 * v245);
    *(float *)(a1 + 60912) = v275;
    v276 = *(float *)(a1 + 60928);
    v277 = v240 * (float)(v275 + v274);
    v278 = v240 * (float)((float)((float)(v240 * v272) + (float)(v245 * v275)) + v275);
    v279 = v277 + (float)(v276 * v245);
    *(float *)(a1 + 60928) = v279;
    v280 = *(float *)(a1 + 60944);
    v281 = (float)(v240 * (float)(v279 + v276)) + (float)(v280 * v245);
    *(float *)(a1 + 60944) = v281;
    v282 = (float)((float)(v280 + v281) * v240) + (float)(v245 * *(float *)(a1 + 60960));
    *(float *)(a1 + 60960) = v282;
    v283 = *(float *)(a1 + 61504);
    v284 = (float)(v240
                 * (float)((float)((float)(v240 * (float)((float)(v278 + (float)(v245 * v279)) + v279))
                                 + (float)(v245 * v281))
                         + v281))
         + (float)(v245 * v282);
    v285 = (float)(*(float *)(a1 + 60944) * *(float *)(a1 + 61648)) + (float)(v282 * *(float *)(a1 + 61664));
    v286 = *(float *)(a1 + 61520);
    *(float *)(a1 + 61248) = v285 + (float)(*(float *)(a1 + 61632) * *(float *)(a1 + 60928));
    v287 = *(float *)(a1 + 60976);
    v288 = (float)((float)(v286 * *(float *)(a1 + 61792)) + (float)(v283 * *(float *)(a1 + 61776)))
         * *(float *)(a1 + 61584);
    *(float *)(a1 + 60976) = v284;
    v289 = v288
         - (float)((float)((float)(v284 * *(float *)(a1 + 62080)) + (float)(v287 * *(float *)(a1 + 62096)))
                 * *(float *)(a1 + 61568));
    if ( v289 >= -1.0 )
      v290 = fminf(v289, 1.0);
    else
      v290 = -1.0;
    v291 = v290 + (float)((float)((float)((float)(v290 * v290) * v290) * v290) * (float)(v290 * *(float *)(a1 + 61744)));
    v292 = *(float *)(a1 + 60896);
    *(float *)(a1 + 60896) = v291;
    v293 = *(float *)(a1 + 60912);
    v294 = (float)(v240 * (float)(v291 + v292)) + (float)(v293 * v245);
    *(float *)(a1 + 60912) = v294;
    v295 = *(float *)(a1 + 60928);
    v296 = v240 * (float)(v294 + v293);
    v297 = v240 * (float)((float)((float)(v240 * v291) + (float)(v245 * v294)) + v294);
    v298 = v296 + (float)(v295 * v245);
    *(float *)(a1 + 60928) = v298;
    v299 = *(float *)(a1 + 60944);
    v300 = (float)(v240 * (float)(v298 + v295)) + (float)(v299 * v245);
    *(float *)(a1 + 60944) = v300;
    v301 = (float)((float)(v299 + v300) * v240) + (float)(v245 * *(float *)(a1 + 60960));
    *(float *)(a1 + 60960) = v301;
    v302 = (float)(v240
                 * (float)((float)((float)(v240 * (float)((float)(v297 + (float)(v245 * v298)) + v298))
                                 + (float)(v245 * v300))
                         + v300))
         + (float)(v245 * v301);
    v303 = (float)(*(float *)(a1 + 60944) * *(float *)(a1 + 61648)) + (float)(v301 * *(float *)(a1 + 61664));
    v304 = *(float *)(a1 + 61504);
    *(float *)(a1 + 61120) = v303 + (float)(*(float *)(a1 + 61632) * *(float *)(a1 + 60928));
    v305 = *(float *)(a1 + 60976);
    v306 = (float)(v304 * *(float *)(a1 + 61760)) * *(float *)(a1 + 61584);
    *(float *)(a1 + 60864) = v302;
    v307 = v306
         - (float)((float)((float)(v302 * *(float *)(a1 + 62080)) + (float)(v305 * *(float *)(a1 + 62096)))
                 * *(float *)(a1 + 61568));
    if ( v307 >= -1.0 )
      v308 = fminf(v307, 1.0);
    else
      v308 = -1.0;
    v309 = v308 + (float)((float)((float)((float)(v308 * v308) * v308) * v308) * (float)(v308 * *(float *)(a1 + 61744)));
    *(float *)(a1 + 60768) = v309;
    v310 = *(float *)(a1 + 60912);
    v311 = (float)(v240 * (float)(v309 + *(float *)(a1 + 60896))) + (float)(v310 * v245);
    *(float *)(a1 + 60784) = v311;
    v312 = *(float *)(a1 + 60928);
    v313 = v240 * (float)(v311 + v310);
    v314 = v240 * (float)((float)((float)(v240 * v309) + (float)(v245 * v311)) + v311);
    v315 = v313 + (float)(v312 * v245);
    *(float *)(a1 + 60800) = v315;
    v316 = *(float *)(a1 + 60944);
    v317 = (float)(v240 * (float)(v315 + v312)) + (float)(v316 * v245);
    *(float *)(a1 + 60816) = v317;
    v318 = (float)((float)(v316 + v317) * v240) + (float)(v245 * *(float *)(a1 + 60960));
    v319 = v240
         * (float)((float)((float)(v240 * (float)((float)(v314 + (float)(v245 * v315)) + v315)) + (float)(v245 * v317))
                 + v317);
    *(float *)(a1 + 60832) = v318;
    v320 = *(float *)(a1 + 60800);
    *(float *)(a1 + 60848) = v319 + (float)(v245 * v318);
    v321 = *(float *)(a1 + 61056);
    v322 = (float)((float)(v318 * *(float *)(a1 + 61664)) + (float)(*(float *)(a1 + 61648) * *(float *)(a1 + 60816)))
         + (float)(v320 * *(float *)(a1 + 61632));
    *(float *)(a1 + 60992) = v322;
    v323 = (float)(v322 + *(float *)(a1 + 61488)) * *(float *)(a1 + 61824);
    v324 = (float)(*(float *)(a1 + 61248) + *(float *)(a1 + 61232)) * *(float *)(a1 + 61856);
    v325 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v321 + *(float *)(a1 + 61424)) * *(float *)(a1 + 62064)) + (float)((float)(*(float *)(a1 + 61184) + *(float *)(a1 + 61296)) * *(float *)(a1 + 62048))) + (float)((float)(*(float *)(a1 + 61312) + *(float *)(a1 + 61168)) * *(float *)(a1 + 62032))) + (float)((float)(*(float *)(a1 + 61040) + *(float *)(a1 + 61440)) * *(float *)(a1 + 62016))) + (float)((float)(*(float *)(a1 + 61408) + *(float *)(a1 + 61072)) * *(float *)(a1 + 62000)))
                                                                                                 + (float)((float)(*(float *)(a1 + 61280) + *(float *)(a1 + 61200)) * *(float *)(a1 + 61984)))
                                                                                         + (float)((float)(*(float *)(a1 + 61328) + *(float *)(a1 + 61152))
                                                                                                 * *(float *)(a1 + 61968)))
                                                                                 + (float)((float)(*(float *)(a1 + 61456)
                                                                                                 + *(float *)(a1 + 61024))
                                                                                         * *(float *)(a1 + 61952)))
                                                                         + (float)((float)(*(float *)(a1 + 61392)
                                                                                         + *(float *)(a1 + 61088))
                                                                                 * *(float *)(a1 + 61936)))
                                                                 + (float)((float)(*(float *)(a1 + 61264)
                                                                                 + *(float *)(a1 + 61216))
                                                                         * *(float *)(a1 + 61920)))
                                                         + (float)((float)(*(float *)(a1 + 61344)
                                                                         + *(float *)(a1 + 61136))
                                                                 * *(float *)(a1 + 61904)))
                                                 + (float)((float)(*(float *)(a1 + 61472) + *(float *)(a1 + 61008))
                                                         * *(float *)(a1 + 61888)))
                                         + (float)((float)(*(float *)(a1 + 61376) + *(float *)(a1 + 61104))
                                                 * *(float *)(a1 + 61872)))
                                 + v324)
                         + (float)((float)(*(float *)(a1 + 61360) + *(float *)(a1 + 61120)) * *(float *)(a1 + 61840)))
                 + v323)
         * *(float *)(a1 + 61712);
    *(float *)(a1 + 61600) = v325;
  }
  *(_DWORD *)(a1 + 62128) = *(_DWORD *)(a1 + 62112);
  v326 = *(_DWORD *)(a1 + 62160);
  *(_DWORD *)(a1 + 62192) = *(_DWORD *)(a1 + 62144);
  *(_DWORD *)(a1 + 62208) = v326;
  *(_DWORD *)(a1 + 62224) = *(_DWORD *)(a1 + 62176);
  v327 = *(float *)(a1 + 62240);
  *(float *)(a1 + 62256) = v327;
  v328 = *(float *)(a1 + 62272);
  *(float *)(a1 + 62288) = v328;
  v329 = (float)((float)(v327 - v328) * *(float *)(a1 + 62304)) + v328;
  *(float *)(a1 + 62272) = v329;
  v330 = (float)((float)(v329 * *(float *)(a1 + 62208)) - (float)(*(float *)(a1 + 62208) * *(float *)(a1 + 62224)))
       + *(float *)(a1 + 62224);
  *(float *)(a1 + 62320) = v330;
  v331 = *(float *)(a1 + 62336);
  *(float *)(a1 + 62352) = v331;
  v332 = (float)((float)(*(float *)(a1 + 62368) * v330) - (float)(*(float *)(a1 + 62368) * v331)) + v331;
  if ( v332 <= 0.0 )
    v333 = 0.0;
  else
    v333 = v332;
  v334 = v333;
  *(float *)(a1 + 62336) = v334;
  v335 = *(float *)(a1 + 62384);
  *(float *)(a1 + 62400) = v335;
  v336 = *(float *)(a1 + 62416);
  *(float *)(a1 + 62432) = v336;
  v337 = (float)((float)(*(float *)(a1 + 62448) * v335) - (float)(*(float *)(a1 + 62448) * v336)) + v336;
  if ( v337 <= 0.0 )
    v338 = 0.0;
  else
    v338 = v337;
  v339 = v338;
  *(float *)(a1 + 62416) = v339;
  v340 = *(float *)(a1 + 62464);
  v341 = *(float *)(a1 + 53120);
  *(float *)(a1 + 62480) = v340;
  v342 = v340 * *(float *)(a1 + 62560);
  v343 = v340 + *(float *)(a1 + 62544);
  if ( v342 >= -1.0 )
    v344 = fminf(v342, 1.0);
  else
    v344 = -1.0;
  if ( (float)(v340 + *(float *)(a1 + 62512)) >= 0.0 )
    v343 = (float)((float)(*(float *)(a1 + 62528) * v341) - (float)(*(float *)(a1 + 62528) * v340)) + v340;
  v345 = (float)((float)(v344 * *(float *)(a1 + 62576)) - (float)(*(float *)(a1 + 62592) * v344))
       + *(float *)(a1 + 62592);
  v346 = (float)((float)(v345 * v341) - (float)(v345 * v340)) + v340;
  if ( v341 != 0.0 )
    v346 = v343;
  *(float *)(a1 + 62496) = v346;
  *(float *)(a1 + 62464) = v346;
  v347 = *(float *)(a1 + 61600);
  v348 = *(float *)(a1 + 55312);
  v349 = *(float *)(a1 + 59408);
  v350 = *(_DWORD *)(a1 + 55792);
  v351 = *(_DWORD *)(a1 + 62112);
  *(_DWORD *)(a1 + 62672) = *(_DWORD *)(a1 + 62656);
  *(_DWORD *)(a1 + 62704) = *(_DWORD *)(a1 + 62688);
  *(_DWORD *)(a1 + 62608) = v350;
  *(_DWORD *)(a1 + 62624) = v351;
  v352 = *(float *)(a1 + 62672);
  v353 = *(float *)(a1 + 62736);
  *(float *)(a1 + 62640) = v349 * *(float *)(a1 + 62896);
  v354 = v347 - v352;
  v355 = *(float *)(a1 + 62768);
  v356 = (float)(v348 * *(float *)(a1 + 62752)) + (float)(v353 * *(float *)(a1 + 62496));
  v357 = v352 + (float)((float)(v347 - v352) * *(float *)(a1 + 62800));
  *(float *)(a1 + 62656) = v357;
  v358 = (float)(v354 * *(float *)(a1 + 62912)) + (float)(v357 * *(float *)(a1 + 62928));
  v359 = (float)((float)(*(float *)(a1 + 62784) * *(float *)(a1 + 62624))
               - (float)(*(float *)(a1 + 62784) * (float)(v356 + (float)(v355 * *(float *)(a1 + 62608)))))
       + (float)(v356 + (float)(v355 * *(float *)(a1 + 62608)));
  v360 = *(float *)(a1 + 62816);
  v361 = v359 * *(float *)(a1 + 62864);
  v362 = v347 * (float)(1.0 - v360);
  if ( v361 <= 0.0 )
    v363 = 0.0;
  else
    v363 = v361;
  v364 = *(float *)(a1 + 62832);
  v365 = v363;
  v366 = v365 * *(float *)(a1 + 62880);
  v367 = (float)((float)(v360 * v358) + v362) * (float)(*(float *)(a1 + 62640) + 1.0);
  v368 = *(float *)(a1 + 62848) * v367;
  v369 = *(float *)(a1 + 62704)
       + (float)((float)(*(float *)(a1 + 62944) * v367) - (float)(*(float *)(a1 + 62944) * *(float *)(a1 + 62704)));
  *(float *)(a1 + 62688) = v369;
  v370 = (float)((float)((float)(v364 * v369) + v368) * v366) * *(float *)(a1 + 62960);
  *(float *)(a1 + 62720) = v370;
  *(_DWORD *)(a1 + 63008) = *(_DWORD *)(a1 + 62992);
  *(_DWORD *)(a1 + 62992) = *(_DWORD *)(a1 + 62976);
  v371 = *(float *)(a1 + 63008);
  v372 = *(float *)(a1 + 63024);
  v373 = v370 - v371;
  *(float *)(a1 + 62976) = v373;
  *(float *)(a1 + 62992) = (float)(v372 * v373) + v371;
  v374 = *(float *)(a1 + 62976);
  v375 = *(float *)(a1 + 62192);
  *(_DWORD *)(a1 + 63088) = *(_DWORD *)(a1 + 63072);
  *(_DWORD *)(a1 + 63072) = *(_DWORD *)(a1 + 63056);
  *(_DWORD *)(a1 + 63056) = *(_DWORD *)(a1 + 63040);
  *(float *)(a1 + 63040) = v374;
  v376 = (float)((float)(*(float *)(a1 + 63056) * *(float *)(a1 + 63136)) + (float)(v374 * *(float *)(a1 + 63120)))
       + (float)(*(float *)(a1 + 63152) * *(float *)(a1 + 63072));
  v377 = (float)((float)(*(float *)(a1 + 63056) * *(float *)(a1 + 63184)) + (float)(v374 * *(float *)(a1 + 63168)))
       + (float)(*(float *)(a1 + 63200) * *(float *)(a1 + 63088));
  if ( v375 <= 0.0 )
    v378 = 0.0;
  else
    v378 = v375;
  *(float *)(a1 + 63056) = v376;
  v379 = v378;
  *(float *)(a1 + 63072) = v377;
  v380 = (float)((float)(v379 * v376) - (float)(v379 * v374)) + v374;
  if ( v375 < -0.0 )
    v19 = (float)-v375;
  v381 = v19;
  v382 = v374 + (float)((float)(v381 * v377) - (float)(v381 * v374));
  if ( v375 >= 0.0 )
    v382 = v380;
  *(float *)(a1 + 63104) = v382;
  v383 = v382 * *(float *)(a1 + 62336);
  *(float *)(a1 + 63216) = v383;
  *(float *)(a1 + 63232) = v383 * *(float *)(a1 + 62416);
  v384 = fmin(fmax((float)(*(float *)(a1 + 57008) + *(float *)(a1 + 56336)), -20.0), 8.9);
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
       * *(float *)(a1 + 56352);
  *(float *)(a1 + 56976) = v391;
  v392 = *(float *)(a1 + 56336);
  v393 = *(_DWORD *)(a1 + 56800);
  v394 = *(_DWORD *)(a1 + 56816);
  LODWORD(v385) = *(_DWORD *)(a1 + 56832);
  *(_DWORD *)(a1 + 57408) = *(_DWORD *)(a1 + 57392);
  *(_DWORD *)(a1 + 57440) = *(_DWORD *)(a1 + 57424);
  *(_DWORD *)(a1 + 57616) = *(_DWORD *)(a1 + 57600);
  *(_DWORD *)(a1 + 57600) = *(_DWORD *)(a1 + 57584);
  *(_DWORD *)(a1 + 57584) = *(_DWORD *)(a1 + 57568);
  *(_DWORD *)(a1 + 57568) = *(_DWORD *)(a1 + 57552);
  *(_DWORD *)(a1 + 57552) = *(_DWORD *)(a1 + 57536);
  *(_DWORD *)(a1 + 57536) = *(_DWORD *)(a1 + 57520);
  *(_DWORD *)(a1 + 57520) = *(_DWORD *)(a1 + 57504);
  *(_DWORD *)(a1 + 57744) = *(_DWORD *)(a1 + 57728);
  *(_DWORD *)(a1 + 57728) = *(_DWORD *)(a1 + 57712);
  *(_DWORD *)(a1 + 57712) = *(_DWORD *)(a1 + 57696);
  *(_DWORD *)(a1 + 57696) = *(_DWORD *)(a1 + 57680);
  *(_DWORD *)(a1 + 57680) = *(_DWORD *)(a1 + 57664);
  *(_DWORD *)(a1 + 57664) = *(_DWORD *)(a1 + 57648);
  *(_DWORD *)(a1 + 57648) = *(_DWORD *)(a1 + 57632);
  *(_DWORD *)(a1 + 57872) = *(_DWORD *)(a1 + 57856);
  *(_DWORD *)(a1 + 57856) = *(_DWORD *)(a1 + 57840);
  *(_DWORD *)(a1 + 57840) = *(_DWORD *)(a1 + 57824);
  *(_DWORD *)(a1 + 57824) = *(_DWORD *)(a1 + 57808);
  *(_DWORD *)(a1 + 57808) = *(_DWORD *)(a1 + 57792);
  *(_DWORD *)(a1 + 57792) = *(_DWORD *)(a1 + 57776);
  *(_DWORD *)(a1 + 57776) = *(_DWORD *)(a1 + 57760);
  *(_DWORD *)(a1 + 58000) = *(_DWORD *)(a1 + 57984);
  *(_DWORD *)(a1 + 57984) = *(_DWORD *)(a1 + 57968);
  *(_DWORD *)(a1 + 57968) = *(_DWORD *)(a1 + 57952);
  *(_DWORD *)(a1 + 57952) = *(_DWORD *)(a1 + 57936);
  *(_DWORD *)(a1 + 57936) = *(_DWORD *)(a1 + 57920);
  *(_DWORD *)(a1 + 57920) = *(_DWORD *)(a1 + 57904);
  *(_DWORD *)(a1 + 57904) = *(_DWORD *)(a1 + 57888);
  *(_DWORD *)(a1 + 58064) = *(_DWORD *)(a1 + 58048);
  *(_DWORD *)(a1 + 58048) = *(_DWORD *)(a1 + 58032);
  *(_DWORD *)(a1 + 57296) = v393;
  *(_DWORD *)(a1 + 57312) = v394;
  v395 = v392 + *(float *)(a1 + 58864);
  v396 = v391 * *(float *)(a1 + 58096);
  v397 = *(float *)(a1 + 58080);
  *(_DWORD *)(a1 + 57328) = LODWORD(v385);
  v398 = fmaxf(*(float *)(a1 + 58128), v396);
  v399 = (float)(v395 * *(float *)(a1 + 58880)) + *(float *)(a1 + 58848);
  *(float *)(a1 + 57344) = v398;
  *(float *)(a1 + 57376) = v397 + *(float *)(a1 + 56368);
  if ( v399 <= 0.0 )
    v400 = 0.0;
  else
    v400 = v399;
  *(float *)(a1 + 57360) = 0.00390625 / v398;
  *(float *)(a1 + 58016) = v400;
  v402 = *(unsigned int *)(a1 + 57440);
  v401 = *(_DWORD *)(a1 + 57408);
  *(_DWORD *)(a1 + 57216) = v402;
  *(float *)&v402 = *(float *)&v402 + v398;
  *(_DWORD *)(a1 + 57232) = v401;
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
  *(_DWORD *)(a1 + 57200) = v402;
  v404 = *(float *)&v402 * *(float *)(a1 + 58208);
  *(float *)&v403 = (float)(*(float *)&v402 + 1.0) * 0.5;
  v405 = (float)((float)(sub_180368FC0(v403).m128_f32[0] * 256.0) * *(float *)(a1 + 57360)) * *(float *)(a1 + 58160);
  if ( v405 >= -1.0 )
    v406 = fminf(v405, 1.0);
  else
    v406 = -1.0;
  v407 = v406 * *(float *)(a1 + 58112);
  v408 = (float)(v407 * v407) * v407;
  v409 = v408 * *(float *)(a1 + 58512);
  v410 = *(float *)(a1 + 57376);
  v411 = (float)((float)((float)((float)((float)(v407 * v407) * *(float *)(a1 + 58576)) + *(float *)(a1 + 58560))
                       * (float)((float)(v407 * v407) * (float)(v407 * v407)))
               + (float)((float)((float)(v407 * v407) * *(float *)(a1 + 58544)) + *(float *)(a1 + 58528)))
       * (float)(v408 * (float)(v407 * v407));
  *(_QWORD *)&v412 = LODWORD(v410);
  *(float *)&v412 = v410 + *(float *)&v402;
  *(float *)(a1 + 57456) = (float)((float)(v411 + v409) + v407) * v404;
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
  v415 = *(float *)(a1 + 57200);
  v416 = v414 * *(float *)(a1 + 58224);
  *(float *)&v412 = *(float *)&v412 / v413;
  v417 = sub_180368FC0(v412).m128_f32[0];
  v418 = *(float *)(a1 + 58144);
  if ( v415 < v418 || v418 <= *(float *)(a1 + 57216) )
  {
    v419 = *(unsigned int *)(a1 + 57232);
  }
  else
  {
    v419 = *(unsigned int *)(a1 + 57232);
    *(float *)&v419 = *(float *)&v419 + 2.0;
  }
  v420 = (float)((float)(v417 * *(float *)(a1 + 57360)) * 256.0) * *(float *)(a1 + 58176);
  if ( *(float *)&v419 >= 4.0 )
    v419 = 0;
  if ( v420 >= -1.0 )
    v421 = fminf(v420, 1.0);
  else
    v421 = -1.0;
  *(_DWORD *)(a1 + 57232) = v419;
  v422 = v421 * *(float *)(a1 + 58112);
  *(float *)&v419 = (float)((float)((float)(*(float *)&v419 + v415) + 1.0) * 0.5) - 1.0;
  v423 = (float)((float)((float)((float)((float)((float)((float)((float)(v422 * v422) * *(float *)(a1 + 58576))
                                                       + *(float *)(a1 + 58560))
                                               * (float)((float)(v422 * v422) * (float)(v422 * v422)))
                                       + (float)((float)((float)(v422 * v422) * *(float *)(a1 + 58544))
                                               + *(float *)(a1 + 58528)))
                               * (float)((float)((float)(v422 * v422) * v422) * (float)(v422 * v422)))
                       + (float)((float)((float)(v422 * v422) * v422) * *(float *)(a1 + 58512)))
               + v422)
       * v416;
  *(float *)(a1 + 57472) = v423;
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
  v425 = *(float *)&v419 * *(float *)(a1 + 58240);
  v426 = (float)((float)((float)(v424 + 1.0) * *(float *)(a1 + 57360)) * 512.0) * *(float *)(a1 + 58192);
  if ( v426 >= -1.0 )
    v427 = fminf(v426, 1.0);
  else
    v427 = -1.0;
  v428 = v427 * *(float *)(a1 + 58112);
  v430 = *(unsigned int *)(a1 + 57200);
  v429 = *(_DWORD *)(a1 + 57232);
  *(float *)(a1 + 57504) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v428 * v428)
                                                                                                 * *(float *)(a1 + 58576))
                                                                                         + *(float *)(a1 + 58560))
                                                                                 * (float)((float)(v428 * v428)
                                                                                         * (float)(v428 * v428)))
                                                                         + (float)((float)((float)(v428 * v428)
                                                                                         * *(float *)(a1 + 58544))
                                                                                 + *(float *)(a1 + 58528)))
                                                                 * (float)((float)((float)(v428 * v428) * v428)
                                                                         * (float)(v428 * v428)))
                                                         + (float)((float)((float)(v428 * v428) * v428)
                                                                 * *(float *)(a1 + 58512)))
                                                 + v428)
                                         * v425)
                                 * *(float *)(a1 + 57328))
                         + (float)((float)(*(float *)(a1 + 57456) * *(float *)(a1 + 57296))
                                 + (float)(v423 * *(float *)(a1 + 57312)));
  *(_DWORD *)(a1 + 57216) = v430;
  *(_DWORD *)(a1 + 57232) = v429;
  *(float *)&v430 = *(float *)&v430 + *(float *)(a1 + 57344);
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
  *(_DWORD *)(a1 + 57200) = v430;
  v432 = *(float *)&v430 * *(float *)(a1 + 58208);
  *(float *)&v431 = (float)(*(float *)&v430 + 1.0) * 0.5;
  v433 = (float)((float)(sub_180368FC0(v431).m128_f32[0] * 256.0) * *(float *)(a1 + 57360)) * *(float *)(a1 + 58160);
  if ( v433 >= -1.0 )
    v434 = fminf(v433, 1.0);
  else
    v434 = -1.0;
  v435 = v434 * *(float *)(a1 + 58112);
  v436 = (float)(v435 * v435) * v435;
  v437 = v436 * *(float *)(a1 + 58512);
  v438 = *(float *)(a1 + 57376);
  v439 = (float)((float)((float)((float)((float)(v435 * v435) * *(float *)(a1 + 58576)) + *(float *)(a1 + 58560))
                       * (float)((float)(v435 * v435) * (float)(v435 * v435)))
               + (float)((float)((float)(v435 * v435) * *(float *)(a1 + 58544)) + *(float *)(a1 + 58528)))
       * (float)(v436 * (float)(v435 * v435));
  *(_QWORD *)&v440 = LODWORD(v438);
  *(float *)&v440 = v438 + *(float *)&v430;
  *(float *)(a1 + 57456) = (float)((float)(v439 + v437) + v435) * v432;
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
  v443 = *(float *)(a1 + 57200);
  v444 = v442 * *(float *)(a1 + 58224);
  *(float *)&v440 = *(float *)&v440 / v441;
  v445 = sub_180368FC0(v440).m128_f32[0];
  v446 = *(float *)(a1 + 58144);
  if ( v443 < v446 || v446 <= *(float *)(a1 + 57216) )
  {
    v447 = *(unsigned int *)(a1 + 57232);
  }
  else
  {
    v447 = *(unsigned int *)(a1 + 57232);
    *(float *)&v447 = *(float *)&v447 + 2.0;
  }
  v448 = (float)((float)(v445 * *(float *)(a1 + 57360)) * 256.0) * *(float *)(a1 + 58176);
  if ( *(float *)&v447 >= 4.0 )
    v447 = 0;
  if ( v448 >= -1.0 )
    v449 = fminf(v448, 1.0);
  else
    v449 = -1.0;
  *(_DWORD *)(a1 + 57232) = v447;
  v450 = v449 * *(float *)(a1 + 58112);
  *(float *)&v447 = (float)((float)((float)(*(float *)&v447 + v443) + 1.0) * 0.5) - 1.0;
  v451 = (float)((float)((float)((float)((float)((float)((float)((float)(v450 * v450) * *(float *)(a1 + 58576))
                                                       + *(float *)(a1 + 58560))
                                               * (float)((float)(v450 * v450) * (float)(v450 * v450)))
                                       + (float)((float)((float)(v450 * v450) * *(float *)(a1 + 58544))
                                               + *(float *)(a1 + 58528)))
                               * (float)((float)((float)(v450 * v450) * v450) * (float)(v450 * v450)))
                       + (float)((float)((float)(v450 * v450) * v450) * *(float *)(a1 + 58512)))
               + v450)
       * v444;
  *(float *)(a1 + 57472) = v451;
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
  v453 = *(float *)&v447 * *(float *)(a1 + 58240);
  v454 = (float)((float)((float)(v452 + 1.0) * *(float *)(a1 + 57360)) * 512.0) * *(float *)(a1 + 58192);
  if ( v454 >= -1.0 )
    v455 = fminf(v454, 1.0);
  else
    v455 = -1.0;
  v456 = v455 * *(float *)(a1 + 58112);
  v458 = *(unsigned int *)(a1 + 57200);
  v457 = *(_DWORD *)(a1 + 57232);
  *(float *)(a1 + 57632) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v456 * v456)
                                                                                                 * *(float *)(a1 + 58576))
                                                                                         + *(float *)(a1 + 58560))
                                                                                 * (float)((float)(v456 * v456)
                                                                                         * (float)(v456 * v456)))
                                                                         + (float)((float)((float)(v456 * v456)
                                                                                         * *(float *)(a1 + 58544))
                                                                                 + *(float *)(a1 + 58528)))
                                                                 * (float)((float)((float)(v456 * v456) * v456)
                                                                         * (float)(v456 * v456)))
                                                         + (float)((float)((float)(v456 * v456) * v456)
                                                                 * *(float *)(a1 + 58512)))
                                                 + v456)
                                         * v453)
                                 * *(float *)(a1 + 57328))
                         + (float)((float)(*(float *)(a1 + 57456) * *(float *)(a1 + 57296))
                                 + (float)(v451 * *(float *)(a1 + 57312)));
  *(_DWORD *)(a1 + 57216) = v458;
  *(_DWORD *)(a1 + 57232) = v457;
  *(float *)&v458 = *(float *)&v458 + *(float *)(a1 + 57344);
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
  *(_DWORD *)(a1 + 57200) = v458;
  v460 = *(float *)&v458 * *(float *)(a1 + 58208);
  *(float *)&v459 = (float)(*(float *)&v458 + 1.0) * 0.5;
  v461 = (float)((float)(sub_180368FC0(v459).m128_f32[0] * 256.0) * *(float *)(a1 + 57360)) * *(float *)(a1 + 58160);
  if ( v461 >= -1.0 )
    v462 = fminf(v461, 1.0);
  else
    v462 = -1.0;
  v463 = v462 * *(float *)(a1 + 58112);
  v464 = (float)(v463 * v463) * v463;
  v465 = v464 * *(float *)(a1 + 58512);
  v466 = *(float *)(a1 + 57376);
  v467 = (float)((float)((float)((float)((float)(v463 * v463) * *(float *)(a1 + 58576)) + *(float *)(a1 + 58560))
                       * (float)((float)(v463 * v463) * (float)(v463 * v463)))
               + (float)((float)((float)(v463 * v463) * *(float *)(a1 + 58544)) + *(float *)(a1 + 58528)))
       * (float)(v464 * (float)(v463 * v463));
  *(_QWORD *)&v468 = LODWORD(v466);
  *(float *)&v468 = v466 + *(float *)&v458;
  *(float *)(a1 + 57456) = (float)((float)(v467 + v465) + v463) * v460;
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
  v471 = *(float *)(a1 + 57200);
  v472 = v470 * *(float *)(a1 + 58224);
  *(float *)&v468 = *(float *)&v468 / v469;
  v473 = sub_180368FC0(v468).m128_f32[0];
  v474 = *(float *)(a1 + 58144);
  if ( v471 < v474 || v474 <= *(float *)(a1 + 57216) )
  {
    v475 = *(unsigned int *)(a1 + 57232);
  }
  else
  {
    v475 = *(unsigned int *)(a1 + 57232);
    *(float *)&v475 = *(float *)&v475 + 2.0;
  }
  v476 = (float)((float)(v473 * *(float *)(a1 + 57360)) * 256.0) * *(float *)(a1 + 58176);
  if ( *(float *)&v475 >= 4.0 )
    v475 = 0;
  if ( v476 >= -1.0 )
    v477 = fminf(v476, 1.0);
  else
    v477 = -1.0;
  *(_DWORD *)(a1 + 57232) = v475;
  v478 = v477 * *(float *)(a1 + 58112);
  *(float *)&v475 = (float)((float)((float)(*(float *)&v475 + v471) + 1.0) * 0.5) - 1.0;
  v479 = (float)((float)((float)((float)((float)((float)((float)((float)(v478 * v478) * *(float *)(a1 + 58576))
                                                       + *(float *)(a1 + 58560))
                                               * (float)((float)(v478 * v478) * (float)(v478 * v478)))
                                       + (float)((float)((float)(v478 * v478) * *(float *)(a1 + 58544))
                                               + *(float *)(a1 + 58528)))
                               * (float)((float)((float)(v478 * v478) * v478) * (float)(v478 * v478)))
                       + (float)((float)((float)(v478 * v478) * v478) * *(float *)(a1 + 58512)))
               + v478)
       * v472;
  *(float *)(a1 + 57472) = v479;
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
  v481 = *(float *)&v475 * *(float *)(a1 + 58240);
  v482 = (float)((float)((float)(v480 + 1.0) * *(float *)(a1 + 57360)) * 512.0) * *(float *)(a1 + 58192);
  if ( v482 >= -1.0 )
    v483 = fminf(v482, 1.0);
  else
    v483 = -1.0;
  v484 = v483 * *(float *)(a1 + 58112);
  v486 = *(unsigned int *)(a1 + 57200);
  v485 = *(_DWORD *)(a1 + 57232);
  *(float *)(a1 + 57760) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v484 * v484)
                                                                                                 * *(float *)(a1 + 58576))
                                                                                         + *(float *)(a1 + 58560))
                                                                                 * (float)((float)(v484 * v484)
                                                                                         * (float)(v484 * v484)))
                                                                         + (float)((float)((float)(v484 * v484)
                                                                                         * *(float *)(a1 + 58544))
                                                                                 + *(float *)(a1 + 58528)))
                                                                 * (float)((float)((float)(v484 * v484) * v484)
                                                                         * (float)(v484 * v484)))
                                                         + (float)((float)((float)(v484 * v484) * v484)
                                                                 * *(float *)(a1 + 58512)))
                                                 + v484)
                                         * v481)
                                 * *(float *)(a1 + 57328))
                         + (float)((float)(*(float *)(a1 + 57456) * *(float *)(a1 + 57296))
                                 + (float)(v479 * *(float *)(a1 + 57312)));
  *(_DWORD *)(a1 + 57216) = v486;
  *(_DWORD *)(a1 + 57232) = v485;
  *(float *)&v486 = *(float *)&v486 + *(float *)(a1 + 57344);
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
  *(_DWORD *)(a1 + 57200) = v486;
  v488 = *(float *)&v486 * *(float *)(a1 + 58208);
  *(float *)&v487 = (float)(*(float *)&v486 + 1.0) * 0.5;
  v489 = (float)((float)(sub_180368FC0(v487).m128_f32[0] * 256.0) * *(float *)(a1 + 57360)) * *(float *)(a1 + 58160);
  if ( v489 >= -1.0 )
    v490 = fminf(v489, 1.0);
  else
    v490 = -1.0;
  v491 = v490 * *(float *)(a1 + 58112);
  v492 = (float)(v491 * v491) * v491;
  v493 = v492 * *(float *)(a1 + 58512);
  v494 = *(float *)(a1 + 57376);
  v495 = (float)((float)((float)((float)((float)(v491 * v491) * *(float *)(a1 + 58576)) + *(float *)(a1 + 58560))
                       * (float)((float)(v491 * v491) * (float)(v491 * v491)))
               + (float)((float)((float)(v491 * v491) * *(float *)(a1 + 58544)) + *(float *)(a1 + 58528)))
       * (float)(v492 * (float)(v491 * v491));
  *(_QWORD *)&v496 = LODWORD(v494);
  *(float *)&v496 = v494 + *(float *)&v486;
  *(float *)(a1 + 57456) = (float)((float)(v495 + v493) + v491) * v488;
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
  v499 = *(float *)(a1 + 57200);
  v500 = v498 * *(float *)(a1 + 58224);
  *(float *)&v496 = *(float *)&v496 / v497;
  v501 = sub_180368FC0(v496).m128_f32[0];
  v502 = *(float *)(a1 + 58144);
  if ( v499 < v502 || v502 <= *(float *)(a1 + 57216) )
  {
    v503 = *(unsigned int *)(a1 + 57232);
  }
  else
  {
    v503 = *(unsigned int *)(a1 + 57232);
    *(float *)&v503 = *(float *)&v503 + 2.0;
  }
  v504 = (float)((float)(v501 * *(float *)(a1 + 57360)) * 256.0) * *(float *)(a1 + 58176);
  if ( *(float *)&v503 >= 4.0 )
    v503 = 0;
  if ( v504 >= -1.0 )
    v505 = fminf(v504, 1.0);
  else
    v505 = -1.0;
  *(_DWORD *)(a1 + 57232) = v503;
  v506 = v505 * *(float *)(a1 + 58112);
  *(float *)&v503 = (float)((float)((float)(*(float *)&v503 + v499) + 1.0) * 0.5) - 1.0;
  v507 = (float)((float)((float)((float)((float)((float)((float)((float)(v506 * v506) * *(float *)(a1 + 58576))
                                                       + *(float *)(a1 + 58560))
                                               * (float)((float)(v506 * v506) * (float)(v506 * v506)))
                                       + (float)((float)((float)(v506 * v506) * *(float *)(a1 + 58544))
                                               + *(float *)(a1 + 58528)))
                               * (float)((float)((float)(v506 * v506) * v506) * (float)(v506 * v506)))
                       + (float)((float)((float)(v506 * v506) * v506) * *(float *)(a1 + 58512)))
               + v506)
       * v500;
  *(float *)(a1 + 57472) = v507;
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
  v509 = *(float *)&v503 * *(float *)(a1 + 58240);
  v510 = (float)((float)(v508 * *(float *)(a1 + 57360)) * 512.0) * *(float *)(a1 + 58192);
  if ( v510 >= -1.0 )
    v33 = fminf(v510, 1.0);
  v511 = v33 * *(float *)(a1 + 58112);
  v512 = *(_DWORD *)(a1 + 57200);
  v513 = *(_DWORD *)(a1 + 57232);
  *(float *)(a1 + 57888) = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v511 * v511)
                                                                                                 * *(float *)(a1 + 58576))
                                                                                         + *(float *)(a1 + 58560))
                                                                                 * (float)((float)(v511 * v511)
                                                                                         * (float)(v511 * v511)))
                                                                         + (float)((float)((float)(v511 * v511)
                                                                                         * *(float *)(a1 + 58544))
                                                                                 + *(float *)(a1 + 58528)))
                                                                 * (float)((float)((float)(v511 * v511) * v511)
                                                                         * (float)(v511 * v511)))
                                                         + (float)((float)((float)(v511 * v511) * v511)
                                                                 * *(float *)(a1 + 58512)))
                                                 + v511)
                                         * v509)
                                 * *(float *)(a1 + 57328))
                         + (float)((float)(*(float *)(a1 + 57456) * *(float *)(a1 + 57296))
                                 + (float)(v507 * *(float *)(a1 + 57312)));
  v514 = *(float *)(a1 + 58000);
  *(_DWORD *)(a1 + 57424) = v512;
  *(_DWORD *)(a1 + 57392) = v513;
  v515 = (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(*(float *)(a1 + 57872) + *(float *)(a1 + 57632))
                                                                                               * *(float *)(a1 + 58272))
                                                                                       + (float)((float)(v514 + *(float *)(a1 + 57504))
                                                                                               * *(float *)(a1 + 58256)))
                                                                               + (float)((float)(*(float *)(a1 + 57760)
                                                                                               + *(float *)(a1 + 57744))
                                                                                       * *(float *)(a1 + 58288)))
                                                                       + (float)((float)(*(float *)(a1 + 57888)
                                                                                       + *(float *)(a1 + 57616))
                                                                               * *(float *)(a1 + 58304)))
                                                               + (float)((float)(*(float *)(a1 + 57984)
                                                                               + *(float *)(a1 + 57520))
                                                                       * *(float *)(a1 + 58320)))
                                                       + (float)((float)(*(float *)(a1 + 57856) + *(float *)(a1 + 57648))
                                                               * *(float *)(a1 + 58336)))
                                               + (float)((float)(*(float *)(a1 + 57776) + *(float *)(a1 + 57728))
                                                       * *(float *)(a1 + 58352)))
                                       + (float)((float)(*(float *)(a1 + 57904) + *(float *)(a1 + 57600))
                                               * *(float *)(a1 + 58368)))
                               + (float)((float)(*(float *)(a1 + 57968) + *(float *)(a1 + 57536))
                                       * *(float *)(a1 + 58384)))
                       + (float)((float)(*(float *)(a1 + 57664) + *(float *)(a1 + 57840)) * *(float *)(a1 + 58400)))
               + (float)((float)(*(float *)(a1 + 57792) + *(float *)(a1 + 57712)) * *(float *)(a1 + 58416)))
       + (float)((float)(*(float *)(a1 + 57584) + *(float *)(a1 + 57920)) * *(float *)(a1 + 58432));
  v516 = *(float *)(a1 + 58048);
  v517 = (float)(v516 * *(float *)(a1 + 58816)) + *(float *)(a1 + 58064);
  v518 = (float)((float)(v515
                       + (float)((float)(*(float *)(a1 + 57952) + *(float *)(a1 + 57552)) * *(float *)(a1 + 58448)))
               + (float)((float)(*(float *)(a1 + 57824) + *(float *)(a1 + 57680)) * *(float *)(a1 + 58464)))
       + (float)((float)(*(float *)(a1 + 57808) + *(float *)(a1 + 57696)) * *(float *)(a1 + 58480));
  v519 = (float)(*(float *)(a1 + 57936) + *(float *)(a1 + 57568)) * *(float *)(a1 + 58496);
  *(float *)(a1 + 58048) = v517;
  v520 = v518 + v519;
  v521 = v520 - (float)((float)(v516 * *(float *)(a1 + 58832)) + v517);
  *(float *)(a1 + 58032) = (float)(v521 * *(float *)(a1 + 58816)) + v516;
  v522 = (float)((float)((float)(v517 - (float)(v521 * *(float *)(a1 + 58016))) * *(float *)(a1 + 58896))
               - (float)(*(float *)(a1 + 58896) * v520))
       + v520;
  *(float *)(a1 + 57488) = v522;
  *(float *)(a1 + 56080) = v522;
  if ( *(float *)(a1 + 101664) == 1.0 )
  {
    *(_DWORD *)(a1 + 52880) = v524;
    *(_DWORD *)(a1 + 101664) = 0;
  }
  **a2 = *(_DWORD *)(a1 + 63232);
  result = *(unsigned int *)(a1 + 63232);
  *a2[1] = result;
  return result;
}

