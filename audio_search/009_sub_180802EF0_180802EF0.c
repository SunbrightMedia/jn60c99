// sub_180802EF0 @ 0x180802EF0 (RVA 0x802EF0)  float_ops=272

float *__fastcall sub_180802EF0(__int64 a1)
{
  __int64 v1; // rdx
  __int64 v2; // r8
  float *v3; // rax
  float v4; // xmm9_4
  float v5; // xmm8_4
  float v6; // xmm7_4
  float v7; // xmm6_4
  float v8; // xmm10_4
  float v9; // xmm6_4
  float v10; // xmm5_4
  float v11; // xmm9_4
  float v12; // xmm0_4
  float v13; // xmm4_4
  float v14; // xmm1_4
  float v15; // xmm2_4
  float v16; // xmm6_4
  float v17; // xmm7_4
  float v18; // xmm5_4
  float v19; // xmm8_4
  float v20; // xmm2_4
  float v21; // xmm5_4
  float v22; // xmm1_4
  float v23; // xmm10_4
  float v24; // xmm8_4
  float v25; // xmm0_4
  float v26; // xmm6_4
  float v27; // xmm5_4
  float v28; // xmm9_4
  float v29; // xmm0_4
  float v30; // xmm2_4
  float v31; // xmm7_4
  float v32; // xmm0_4
  float v33; // xmm10_4
  float v34; // xmm7_4
  float v35; // xmm10_4
  float v36; // xmm0_4
  float v37; // xmm6_4
  float v38; // xmm10_4
  float v39; // xmm3_4
  float v40; // xmm8_4
  float v41; // xmm2_4
  float v42; // xmm6_4
  float v43; // xmm7_4
  float v44; // xmm4_4
  float v45; // xmm7_4
  float v46; // xmm2_4
  float v47; // xmm5_4
  float v48; // xmm8_4
  float v49; // xmm0_4
  float v50; // xmm6_4
  float v51; // xmm1_4
  float v52; // xmm5_4
  float v53; // xmm9_4
  float v54; // xmm10_4
  float v55; // xmm8_4
  float v56; // xmm0_4
  float v57; // xmm2_4
  float v58; // xmm7_4
  float v59; // xmm0_4
  float v60; // xmm10_4
  float v61; // xmm7_4
  float v62; // xmm10_4
  float v63; // xmm0_4
  float v64; // xmm6_4
  float v65; // xmm10_4
  float v66; // xmm3_4
  float v67; // xmm8_4
  float v68; // xmm1_4
  float v69; // xmm2_4
  float v70; // xmm6_4
  float v71; // xmm7_4
  float v72; // xmm5_4
  float v73; // xmm6_4
  float v74; // xmm2_4
  float v75; // xmm8_4
  float v76; // xmm9_4
  float v77; // xmm8_4
  float v78; // xmm0_4
  float v79; // xmm1_4
  float v80; // xmm2_4
  float v81; // xmm7_4
  float v82; // xmm10_4
  float v83; // xmm4_4
  float v84; // xmm8_4
  float v85; // xmm0_4
  float v86; // xmm10_4
  float v87; // xmm0_4
  float v88; // xmm7_4
  float v89; // xmm0_4
  float v90; // xmm5_4
  float v91; // xmm1_4
  float v92; // xmm9_4
  float v93; // xmm3_4
  float v94; // xmm7_4
  float v95; // xmm2_4
  float v96; // xmm5_4
  float v97; // xmm6_4
  float v98; // xmm7_4
  float v99; // xmm1_4
  float v100; // xmm4_4
  float v101; // xmm2_4
  float v102; // xmm9_4
  float v103; // xmm0_4
  float v104; // xmm6_4
  float v105; // xmm2_4
  float *result; // rax
  float v107; // xmm10_4
  float v108; // xmm4_4
  float v109; // xmm6_4
  float v110; // xmm10_4
  float v111; // xmm0_4
  float v112; // xmm5_4
  float v113; // xmm9_4
  float v114; // xmm8_4
  float v115; // xmm0_4
  float v116; // xmm7_4
  float v117; // xmm4_4
  float v118; // xmm1_4
  float v119; // xmm2_4
  float v120; // xmm6_4
  float v121; // xmm7_4
  float v122; // xmm5_4
  float v123; // xmm8_4
  float v124; // xmm2_4
  float v125; // xmm9_4
  float v126; // xmm2_4
  float v127; // xmm5_4
  float v128; // xmm1_4
  float v129; // xmm10_4
  float v130; // xmm8_4
  float v131; // xmm0_4
  float v132; // xmm7_4
  float v133; // xmm2_4
  float v134; // xmm0_4
  float v135; // xmm10_4
  float v136; // xmm7_4
  float v137; // xmm10_4
  float v138; // xmm0_4
  float v139; // xmm6_4
  float v140; // xmm10_4
  float v141; // xmm0_4
  float v142; // xmm5_4
  float v143; // xmm9_4
  float v144; // xmm3_4
  float v145; // xmm8_4
  float v146; // xmm0_4
  float v147; // xmm7_4
  float v148; // xmm4_4
  float v149; // xmm2_4
  float v150; // xmm6_4
  float v151; // xmm7_4
  float v152; // xmm8_4
  float v153; // xmm2_4
  float v154; // xmm9_4
  float v155; // xmm2_4
  float v156; // xmm5_4
  float v157; // xmm1_4
  float v158; // xmm10_4
  float v159; // xmm8_4
  float v160; // xmm0_4
  float v161; // xmm2_4
  float v162; // xmm7_4
  float v163; // xmm0_4
  float v164; // xmm10_4
  float v165; // xmm7_4
  float v166; // xmm10_4
  float v167; // xmm0_4
  float v168; // xmm6_4
  float v169; // xmm10_4
  float v170; // xmm0_4
  float v171; // xmm5_4
  float v172; // xmm9_4
  float v173; // xmm3_4
  float v174; // xmm8_4
  float v175; // xmm1_4
  float v176; // xmm2_4
  float v177; // xmm6_4
  float v178; // xmm5_4
  float v179; // xmm6_4
  float v180; // xmm2_4
  float v181; // xmm7_4
  float v182; // xmm8_4
  float v183; // xmm9_4
  float v184; // xmm8_4
  float v185; // xmm0_4
  float v186; // xmm1_4
  float v187; // xmm10_4
  float v188; // xmm8_4
  float v189; // xmm2_4
  float v190; // xmm7_4
  float v191; // xmm0_4
  float v192; // xmm10_4
  float v193; // xmm7_4
  float v194; // xmm0_4
  float v195; // xmm5_4
  float v196; // xmm1_4
  float v197; // xmm9_4
  float v198; // xmm0_4
  float v199; // xmm4_4
  float v200; // xmm8_4
  float v201; // xmm2_4
  float v202; // xmm5_4
  float v203; // xmm3_4
  float v204; // xmm7_4
  float v205; // xmm6_4
  float v206; // xmm7_4
  float v207; // xmm4_4
  float v208; // xmm1_4
  float v209; // xmm2_4
  float v210; // xmm9_4
  float v211; // xmm0_4
  float v212; // xmm6_4
  float v213; // xmm2_4

  v1 = 2;
  v2 = 2;
  v3 = (float *)(a1 + 8);
  do
  {
    v4 = *(v3 - 1);
    v5 = *v3 - v3[3];
    v6 = v3[1];
    v7 = *(v3 - 2);
    v8 = v7 - v3[5];
    v9 = v7 + v3[5];
    v10 = v3[4] + v4;
    v11 = v4 - v3[4];
    v12 = v3[2] + v6;
    v13 = v3[10];
    v14 = (float)(*v3 + v3[3]) + v10;
    v15 = v12 + v9;
    v16 = v9 - v12;
    v17 = (float)(v6 - v3[2]) + v5;
    v18 = (float)(v10 - (float)(*v3 + v3[3])) + v16;
    v19 = (float)(v5 + v11) * 0.70710677;
    *(v3 - 2) = v14 + v15;
    v3[2] = v15 - v14;
    v20 = v11 + v8;
    v21 = v18 * 0.70710677;
    v22 = v19 + v8;
    v23 = v8 - v19;
    v24 = v3[8];
    v25 = v21 + v16;
    v26 = v16 - v21;
    v27 = v3[7] + v3[12];
    v28 = v3[7] - v3[12];
    *v3 = v25;
    v3[4] = v26;
    v29 = (float)(v17 - v20) * 0.38268343;
    v30 = (float)(v20 * 1.306563) + v29;
    v31 = (float)(v17 * 0.54119611) + v29;
    v32 = v23 + v31;
    v33 = v23 - v31;
    v34 = v3[9];
    v3[3] = v32;
    v3[1] = v33;
    v35 = v3[6];
    *(v3 - 1) = v22 + v30;
    v36 = v3[13];
    v3[5] = v22 - v30;
    v37 = v36 + v35;
    v38 = v35 - v36;
    v39 = v3[11] + v24;
    v40 = v24 - v3[11];
    v41 = (float)(v34 + v13) + v37;
    v42 = v37 - (float)(v34 + v13);
    v43 = v34 - v13;
    v44 = v3[18];
    v45 = v43 + v40;
    v3[6] = (float)(v39 + v27) + v41;
    v3[10] = v41 - (float)(v39 + v27);
    v46 = v28 + v38;
    v47 = (float)((float)(v27 - v39) + v42) * 0.70710677;
    v48 = (float)(v40 + v28) * 0.70710677;
    v49 = v47 + v42;
    v50 = v42 - v47;
    v51 = v48 + v38;
    v52 = v3[15] + v3[20];
    v53 = v3[15] - v3[20];
    v3[8] = v49;
    v54 = v38 - v48;
    v55 = v3[16];
    v3[12] = v50;
    v56 = (float)(v45 - v46) * 0.38268343;
    v57 = (float)(v46 * 1.306563) + v56;
    v58 = (float)(v45 * 0.54119611) + v56;
    v59 = v54 + v58;
    v60 = v54 - v58;
    v61 = v3[17];
    v3[11] = v59;
    v3[9] = v60;
    v62 = v3[14];
    v3[7] = v51 + v57;
    v63 = v3[21];
    v3[13] = v51 - v57;
    v64 = v63 + v62;
    v65 = v62 - v63;
    v66 = v3[19] + v55;
    v67 = v55 - v3[19];
    v68 = v66 + v52;
    v69 = (float)(v61 + v44) + v64;
    v70 = v64 - (float)(v61 + v44);
    v71 = (float)(v61 - v44) + v67;
    v3[14] = (float)(v66 + v52) + v69;
    v72 = (float)((float)(v52 - v66) + v70) * 0.70710677;
    v3[18] = v69 - v68;
    v3[16] = v72 + v70;
    v3[20] = v70 - v72;
    v73 = v3[25];
    v74 = v53 + v65;
    v75 = v67 + v53;
    v76 = v3[22];
    v77 = v75 * 0.70710677;
    v78 = (float)(v71 - v74) * 0.38268343;
    v79 = v77 + v65;
    v80 = (float)(v74 * 1.306563) + v78;
    v81 = (float)(v71 * 0.54119611) + v78;
    v82 = v65 - v77;
    v83 = v3[23] + v3[28];
    v84 = v3[23] - v3[28];
    v85 = v82;
    v86 = v82 - v81;
    v87 = v85 + v81;
    v88 = v3[24];
    v3[17] = v86;
    v3[19] = v87;
    v3[15] = v79 + v80;
    v89 = v3[29];
    v3[21] = v79 - v80;
    v90 = v89 + v76;
    v91 = v73 + v3[26];
    v92 = v76 - v89;
    v93 = v3[27] + v88;
    v94 = v88 - v3[27];
    v95 = v91 + v90;
    v96 = v90 - v91;
    v97 = (float)(v73 - v3[26]) + v94;
    v98 = (float)(v94 + v84) * 0.70710677;
    v3[22] = (float)(v93 + v83) + v95;
    v3[26] = v95 - (float)(v93 + v83);
    v99 = v98 + v92;
    v100 = (float)((float)(v83 - v93) + v96) * 0.70710677;
    v101 = v84 + v92;
    v102 = v92 - v98;
    v3[24] = v100 + v96;
    v3[28] = v96 - v100;
    v103 = (float)(v97 - v101) * 0.38268343;
    v104 = (float)(v97 * 0.54119611) + v103;
    v105 = (float)(v101 * 1.306563) + v103;
    v3[27] = v102 + v104;
    v3[25] = v102 - v104;
    v3[23] = v99 + v105;
    v3[29] = v99 - v105;
    v3 += 32;
    --v2;
  }
  while ( v2 );
  result = (float *)(a1 + 64);
  do
  {
    v107 = *(result - 16);
    v108 = result[16];
    v109 = result[40] + v107;
    v110 = v107 - result[40];
    v111 = result[32];
    v112 = *(result - 8) + v111;
    v113 = *(result - 8) - v111;
    v114 = *result - result[24];
    v115 = result[8] + v108;
    v116 = result[8] - v108;
    v117 = result[17];
    v118 = (float)(result[24] + *result) + v112;
    v119 = v115 + v109;
    v120 = v109 - v115;
    v121 = v116 + v114;
    v122 = (float)(v112 - (float)(result[24] + *result)) + v120;
    v123 = (float)(v114 + v113) * 0.70710677;
    *(result - 16) = v118 + v119;
    result[16] = v119 - v118;
    v124 = v113;
    v125 = *(result - 7);
    v126 = v124 + v110;
    v127 = v122 * 0.70710677;
    v128 = v123 + v110;
    v129 = v110 - v123;
    v130 = result[1];
    *result = v127 + v120;
    result[32] = v120 - v127;
    v131 = (float)(v121 - v126) * 0.38268343;
    v132 = (float)(v121 * 0.54119611) + v131;
    v133 = (float)(v126 * 1.306563) + v131;
    v134 = v129 + v132;
    v135 = v129 - v132;
    v136 = result[9];
    result[24] = v134;
    result[8] = v135;
    v137 = *(result - 15);
    *(result - 8) = v128 + v133;
    v138 = result[41];
    result[40] = v128 - v133;
    v139 = v138 + v137;
    v140 = v137 - v138;
    v141 = result[33];
    v142 = v125 + v141;
    v143 = v125 - v141;
    v144 = result[25] + v130;
    v145 = v130 - result[25];
    v146 = v136 + v117;
    v147 = v136 - v117;
    v148 = result[18];
    v149 = v146 + v139;
    v150 = v139 - v146;
    v151 = v147 + v145;
    v152 = (float)(v145 + v143) * 0.70710677;
    *(result - 15) = (float)(v144 + v142) + v149;
    result[17] = v149 - (float)(v144 + v142);
    v153 = v143;
    v154 = *(result - 6);
    v155 = v153 + v140;
    v156 = (float)((float)(v142 - v144) + v150) * 0.70710677;
    v157 = v152 + v140;
    v158 = v140 - v152;
    v159 = result[2];
    result[1] = v156 + v150;
    result[33] = v150 - v156;
    v160 = (float)(v151 - v155) * 0.38268343;
    v161 = (float)(v155 * 1.306563) + v160;
    v162 = (float)(v151 * 0.54119611) + v160;
    v163 = v158 + v162;
    v164 = v158 - v162;
    v165 = result[10];
    result[25] = v163;
    result[9] = v164;
    v166 = *(result - 14);
    *(result - 7) = v157 + v161;
    v167 = result[42];
    v168 = v166 + v167;
    result[41] = v157 - v161;
    v169 = v166 - v167;
    v170 = result[34];
    v171 = v154 + v170;
    v172 = v154 - v170;
    v173 = result[26] + v159;
    v174 = v159 - result[26];
    v175 = v173 + v171;
    v176 = (float)(v165 + v148) + v168;
    v177 = v168 - (float)(v165 + v148);
    *(result - 14) = (float)(v173 + v171) + v176;
    v178 = (float)((float)(v171 - v173) + v177) * 0.70710677;
    result[18] = v176 - v175;
    result[2] = v178 + v177;
    result[34] = v177 - v178;
    v179 = result[11];
    v180 = v172 + v169;
    v181 = (float)(v165 - v148) + v174;
    v182 = v174 + v172;
    v183 = *(result - 13);
    v184 = v182 * 0.70710677;
    v185 = (float)(v181 - v180) * 0.38268343;
    v186 = v184 + v169;
    v187 = v169 - v184;
    v188 = *(result - 5);
    v189 = (float)(v180 * 1.306563) + v185;
    v190 = (float)(v181 * 0.54119611) + v185;
    v191 = v187 + v190;
    v192 = v187 - v190;
    v193 = result[3];
    result[26] = v191;
    result[10] = v192;
    *(result - 6) = v186 + v189;
    v194 = result[43];
    result[42] = v186 - v189;
    v195 = v194 + v183;
    v196 = v179 + result[19];
    v197 = v183 - v194;
    v198 = result[35];
    v199 = v188 + v198;
    v200 = v188 - v198;
    v201 = v196 + v195;
    v202 = v195 - v196;
    v203 = result[27] + v193;
    v204 = v193 - result[27];
    v205 = (float)(v179 - result[19]) + v204;
    v206 = (float)(v204 + v200) * 0.70710677;
    *(result - 13) = (float)(v203 + v199) + v201;
    result[19] = v201 - (float)(v203 + v199);
    v207 = (float)((float)(v199 - v203) + v202) * 0.70710677;
    v208 = v206 + v197;
    v209 = v200 + v197;
    v210 = v197 - v206;
    result[3] = v207 + v202;
    result[35] = v202 - v207;
    v211 = (float)(v205 - v209) * 0.38268343;
    v212 = (float)(v205 * 0.54119611) + v211;
    v213 = (float)(v209 * 1.306563) + v211;
    result[27] = v210 + v212;
    result[11] = v210 - v212;
    result[43] = v208 - v213;
    *(result - 5) = v208 + v213;
    result += 4;
    --v1;
  }
  while ( v1 );
  return result;
}

