// sub_180801700 @ 0x180801700 (RVA 0x801700)  float_ops=222

__int64 __fastcall sub_180801700(__int64 a1, __int64 a2, __int16 *a3, __int64 a4, unsigned int a5)
{
  __int64 v5; // r11
  float *v6; // r10
  __int64 v7; // rbx
  float *v8; // rdx
  __int16 v9; // cx
  float v10; // xmm0_4
  float v11; // xmm1_4
  float v12; // xmm9_4
  float v13; // xmm10_4
  float v14; // xmm11_4
  float v15; // xmm8_4
  float v16; // xmm7_4
  float v17; // xmm3_4
  float v18; // xmm0_4
  float v19; // xmm1_4
  float v20; // xmm6_4
  float v21; // xmm8_4
  float v22; // xmm7_4
  float v23; // xmm2_4
  float v24; // xmm3_4
  float v25; // xmm1_4
  float v26; // xmm5_4
  float v27; // xmm3_4
  float v28; // xmm6_4
  float v29; // xmm4_4
  float v30; // xmm7_4
  float v31; // xmm0_4
  float v32; // xmm2_4
  float v33; // xmm3_4
  float v34; // xmm2_4
  float v35; // xmm9_4
  float v36; // xmm8_4
  float v37; // xmm0_4
  float v38; // xmm10_4
  float v39; // xmm9_4
  float v40; // xmm1_4
  float v41; // xmm8_4
  float *v42; // rcx
  __int16 v43; // dx
  float v44; // xmm0_4
  float v45; // xmm10_4
  float v46; // xmm3_4
  float v47; // xmm0_4
  float v48; // xmm1_4
  float v49; // xmm9_4
  float v50; // xmm8_4
  float v51; // xmm10_4
  float v52; // xmm2_4
  float v53; // xmm3_4
  float v54; // xmm1_4
  float v55; // xmm6_4
  float v56; // xmm3_4
  float v57; // xmm9_4
  float v58; // xmm7_4
  float v59; // xmm10_4
  float v60; // xmm0_4
  float v61; // xmm2_4
  float v62; // xmm3_4
  float v63; // xmm2_4
  float v64; // xmm5_4
  float v65; // xmm8_4
  float v66; // xmm0_4
  float v67; // xmm1_4
  float v68; // xmm5_4
  float v69; // xmm8_4
  float *v70; // rdx
  __int64 *v71; // r9
  __int64 v72; // r10
  __int64 v73; // rcx
  float v74; // xmm0_4
  float v75; // xmm6_4
  float v76; // xmm8_4
  float v77; // xmm6_4
  float v78; // xmm3_4
  float v79; // xmm10_4
  float v80; // xmm9_4
  float v81; // xmm10_4
  float v82; // xmm5_4
  float v83; // xmm10_4
  float v84; // xmm7_4
  float v85; // xmm9_4
  float v86; // xmm2_4
  float v87; // xmm3_4
  float v88; // xmm4_4
  float v89; // xmm1_4
  float v90; // xmm8_4
  float v91; // xmm1_4
  __int64 v92; // rax
  float v93; // xmm6_4
  float v94; // xmm8_4
  float v95; // xmm0_4
  float v96; // xmm9_4
  float v97; // xmm10_4
  float v98; // xmm3_4
  float v99; // xmm6_4
  float v100; // xmm8_4
  __int64 v101; // rax
  float v102; // xmm0_4
  float v103; // xmm2_4
  __int64 v104; // rax
  float v105; // xmm2_4
  float v106; // xmm10_4
  float v107; // xmm9_4
  float v108; // xmm5_4
  float v109; // xmm10_4
  float v110; // xmm0_4
  float v111; // xmm7_4
  float v112; // xmm9_4
  __int64 v113; // rcx
  float v114; // xmm2_4
  float v115; // xmm3_4
  float v116; // xmm4_4
  float v117; // xmm1_4
  float v118; // xmm8_4
  float v119; // xmm1_4
  float v120; // xmm6_4
  float v121; // xmm8_4
  float v122; // xmm2_4
  float v123; // xmm1_4
  float v124; // xmm3_4
  float v125; // xmm0_4
  float v126; // xmm10_4
  float v127; // xmm8_4
  __int64 v128; // rax
  float v129; // xmm9_4
  __int64 v130; // rax
  float v131; // xmm0_4
  __int64 v132; // rax
  float v133; // xmm10_4
  float v134; // xmm9_4
  float v135; // xmm0_4
  float v136; // xmm2_4
  float v137; // xmm1_4
  float v138; // xmm6_4
  __int64 v139; // rcx
  float v140; // xmm5_4
  float v141; // xmm10_4
  float v142; // xmm2_4
  float v143; // xmm7_4
  float v144; // xmm9_4
  float v145; // xmm2_4
  float v146; // xmm3_4
  float v147; // xmm0_4
  float v148; // xmm8_4
  float v149; // xmm4_4
  float v150; // xmm1_4
  float v151; // xmm8_4
  float v152; // xmm0_4
  float v153; // xmm1_4
  float v154; // xmm6_4
  float v155; // xmm8_4
  float v156; // xmm2_4
  float v157; // xmm3_4
  float v158; // xmm0_4
  float v159; // xmm7_4
  float v160; // xmm1_4
  float v161; // xmm0_4
  float v162; // xmm10_4
  float v163; // xmm8_4
  __int64 v164; // rax
  float v165; // xmm9_4
  __int64 v166; // rax
  float v167; // xmm0_4
  __int64 v168; // rax
  float v169; // xmm10_4
  float v170; // xmm9_4
  float v171; // xmm0_4
  float v172; // xmm2_4
  float v173; // xmm1_4
  float v174; // xmm6_4
  __int64 v175; // rcx
  float v176; // xmm8_4
  float v177; // xmm5_4
  float v178; // xmm10_4
  float v179; // xmm2_4
  float v180; // xmm7_4
  float v181; // xmm9_4
  float v182; // xmm2_4
  float v183; // xmm3_4
  float v184; // xmm4_4
  float v185; // xmm0_4
  float v186; // xmm1_4
  float v187; // xmm6_4
  float v188; // xmm8_4
  __int64 result; // rax
  char v190; // [rsp+0h] [rbp-1A8h] BYREF
  char v191; // [rsp+18h] [rbp-190h] BYREF

  v5 = 4;
  v6 = *(float **)(a2 + 88);
  v7 = *(_QWORD *)(a1 + 392) + 128LL;
  v8 = (float *)&v190;
  do
  {
    v9 = a3[8];
    if ( v9 || a3[16] || a3[24] || a3[32] || a3[40] || a3[48] || a3[56] )
    {
      v16 = (float)*a3 * *v6;
      v17 = (float)a3[16] * v6[16];
      v18 = (float)a3[32] * v6[32];
      v19 = (float)a3[48] * v6[48];
      v20 = v18 + v16;
      v21 = (float)v9 * v6[8];
      v22 = v16 - v18;
      v23 = v19 + v17;
      v24 = v17 - v19;
      v25 = (float)a3[24] * v6[24];
      v26 = v23 + v20;
      v27 = (float)(v24 * 1.4142135) - v23;
      v28 = v20 - v23;
      v29 = v27 + v22;
      v30 = v22 - v27;
      v31 = (float)a3[56] * v6[56];
      v32 = (float)a3[40] * v6[40];
      v33 = v32 - v25;
      v34 = v32 + v25;
      v35 = v31 + v21;
      v36 = v21 - v31;
      v37 = (float)(v36 + v33) * 1.847759;
      v38 = (float)(v37 - (float)(v33 * 2.613126)) - (float)(v35 + v34);
      v8[56] = v26 - (float)(v35 + v34);
      v14 = (float)(v35 + v34) + v26;
      v39 = (float)((float)(v35 - v34) * 1.4142135) - v38;
      v40 = v29 - v38;
      v13 = v38 + v29;
      v41 = (float)((float)(v36 * 1.0823922) - v37) + v39;
      v8[48] = v40;
      v11 = v30 - v39;
      v12 = v39 + v30;
      v10 = v28 - v41;
      v15 = v41 + v28;
    }
    else
    {
      v10 = (float)*a3 * *v6;
      v8[48] = v10;
      v11 = v10;
      v8[56] = v10;
      v12 = v10;
      v13 = v10;
      v14 = v10;
      v15 = v10;
    }
    v8[32] = v15;
    v42 = v8 + 1;
    *v8 = v14;
    v8[8] = v13;
    v8[16] = v12;
    v8[40] = v11;
    v8[24] = v10;
    v43 = a3[9];
    if ( v43 || a3[17] || a3[25] || a3[33] || a3[41] || a3[49] || a3[57] )
    {
      v45 = (float)a3[1] * v6[1];
      v46 = (float)a3[17] * v6[17];
      v47 = (float)a3[33] * v6[33];
      v48 = (float)a3[49] * v6[49];
      v49 = v47 + v45;
      v50 = (float)v43 * v6[9];
      v51 = v45 - v47;
      v52 = v48 + v46;
      v53 = v46 - v48;
      v54 = (float)a3[25] * v6[25];
      v55 = v52 + v49;
      v56 = (float)(v53 * 1.4142135) - v52;
      v57 = v49 - v52;
      v58 = v56 + v51;
      v59 = v51 - v56;
      v60 = (float)a3[57] * v6[57];
      v61 = (float)a3[41] * v6[41];
      v62 = v61 - v54;
      v63 = v61 + v54;
      v64 = v60 + v50;
      v65 = v50 - v60;
      v66 = (float)(v65 + v62) * 1.847759;
      v67 = (float)(v66 - (float)(v62 * 2.613126)) - (float)(v64 + v63);
      *v42 = (float)(v64 + v63) + v55;
      v42[56] = v55 - (float)(v64 + v63);
      v68 = (float)((float)(v64 - v63) * 1.4142135) - v67;
      v69 = (float)((float)(v65 * 1.0823922) - v66) + v68;
      v42[8] = v67 + v58;
      v42[48] = v58 - v67;
      v42[16] = v68 + v59;
      v42[40] = v59 - v68;
      v42[32] = v69 + v57;
      v42[24] = v57 - v69;
    }
    else
    {
      v44 = (float)a3[1] * v6[1];
      *v42 = v44;
      v42[8] = v44;
      v42[16] = v44;
      v42[24] = v44;
      v42[32] = v44;
      v42[40] = v44;
      v42[48] = v44;
      v42[56] = v44;
    }
    a3 += 2;
    v8 = v42 + 1;
    v6 += 2;
    --v5;
  }
  while ( v5 );
  v70 = (float *)&v191;
  v71 = (__int64 *)(a4 + 16);
  v72 = 2;
  do
  {
    v73 = *(v71 - 2);
    v74 = *(v70 - 4) + *v70;
    v75 = *(v70 - 5);
    v76 = v75 - v70[1];
    v77 = v75 + v70[1];
    v78 = *(v70 - 1);
    v79 = *(v70 - 6);
    v80 = v79 - *(v70 - 2);
    v81 = v79 + *(v70 - 2);
    v82 = v74 + v81;
    v83 = v81 - v74;
    v84 = (float)((float)((float)(*(v70 - 4) - *v70) * 1.4142135) - v74) + v80;
    v85 = v80 - (float)((float)((float)(*(v70 - 4) - *v70) * 1.4142135) - v74);
    v86 = *(v70 - 3) + v78;
    v87 = v78 - *(v70 - 3);
    v88 = v77 + v86;
    v89 = (float)(v76 + v87) * 1.847759;
    v90 = (float)(v76 * 1.0823922) - v89;
    v91 = (float)(v89 - (float)(v87 * 2.613126)) - (float)(v77 + v86);
    v92 = (unsigned int)(int)(float)((float)(v77 + v86) + v82);
    v93 = (float)((float)(v77 - v86) * 1.4142135) - v91;
    v94 = v90 + v93;
    *(_BYTE *)(a5 + v73) = *(_BYTE *)(((v92 >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v73 + 7) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v82 - v88) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v73 + 1) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v91 + v84) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v73 + 6) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v84 - v91) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v73 + 2) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v93 + v85) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v73 + 5) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v85 - v93) >> 3) & 0x3FF) + v7);
    v95 = v94 + v83;
    v96 = v70[2];
    v97 = v83 - v94;
    v98 = v70[7];
    v99 = v70[3] + v70[9];
    v100 = v70[3] - v70[9];
    v101 = (unsigned int)(int)v95;
    v102 = v70[4] + v70[8];
    v103 = (float)(v70[4] - v70[8]) * 1.4142135;
    *(_BYTE *)(a5 + v73 + 4) = *(_BYTE *)(((v101 >> 3) & 0x3FF) + v7);
    v104 = (unsigned int)(int)v97;
    v105 = v103 - v102;
    v106 = v96 + v70[6];
    v107 = v96 - v70[6];
    v108 = v102 + v106;
    v109 = v106 - v102;
    v110 = v70[5];
    v111 = v105 + v107;
    *(_BYTE *)(a5 + v73 + 3) = *(_BYTE *)(((v104 >> 3) & 0x3FF) + v7);
    v112 = v107 - v105;
    v113 = *(v71 - 1);
    v114 = v110 + v98;
    v115 = v98 - v110;
    v116 = v99 + v114;
    v117 = (float)(v100 + v115) * 1.847759;
    v118 = (float)(v100 * 1.0823922) - v117;
    v119 = (float)(v117 - (float)(v115 * 2.613126)) - (float)(v99 + v114);
    v120 = (float)((float)(v99 - v114) * 1.4142135) - v119;
    v121 = v118 + v120;
    *(_BYTE *)(a5 + v113) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v116 + v108) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v113 + 7) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v108 - v116) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v113 + 1) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v119 + v111) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v113 + 6) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v111 - v119) >> 3) & 0x3FF) + v7);
    v122 = v70[12];
    v123 = v70[16];
    v124 = v70[15];
    v125 = v121 + v109;
    v126 = v109 - v121;
    v127 = v70[11];
    *(_BYTE *)(a5 + v113 + 2) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v120 + v112) >> 3) & 0x3FF) + v7);
    v128 = (unsigned int)(int)(float)(v112 - v120);
    v129 = v70[10];
    *(_BYTE *)(a5 + v113 + 5) = *(_BYTE *)(((v128 >> 3) & 0x3FF) + v7);
    v130 = (unsigned int)(int)v125;
    v131 = v70[14];
    *(_BYTE *)(a5 + v113 + 4) = *(_BYTE *)(((v130 >> 3) & 0x3FF) + v7);
    v132 = (unsigned int)(int)v126;
    v133 = v131 + v129;
    v134 = v129 - v131;
    v135 = v123 + v122;
    v136 = v122 - v123;
    v137 = v70[17];
    *(_BYTE *)(a5 + v113 + 3) = *(_BYTE *)(((v132 >> 3) & 0x3FF) + v7);
    v138 = v137 + v127;
    v139 = *v71;
    v140 = v135 + v133;
    v141 = v133 - v135;
    v142 = (float)(v136 * 1.4142135) - v135;
    v143 = v142 + v134;
    v144 = v134 - v142;
    v145 = v70[13] + v124;
    v146 = v124 - v70[13];
    v147 = v127 - v137;
    v148 = (float)(v127 - v137) * 1.0823922;
    v149 = v138 + v145;
    v150 = (float)(v147 + v146) * 1.847759;
    v151 = v148 - v150;
    v152 = (float)(v138 + v145) + v140;
    v153 = (float)(v150 - (float)(v146 * 2.613126)) - (float)(v138 + v145);
    v154 = (float)((float)(v138 - v145) * 1.4142135) - v153;
    v155 = v151 + v154;
    *(_BYTE *)(a5 + v139) = *(_BYTE *)((((__int64)(unsigned int)(int)v152 >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v139 + 7) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v140 - v149) >> 3) & 0x3FF) + v7);
    v156 = v70[20];
    v157 = v70[23];
    v158 = v153 + v143;
    v159 = v143 - v153;
    v160 = v70[24];
    *(_BYTE *)(a5 + v139 + 1) = *(_BYTE *)((((__int64)(unsigned int)(int)v158 >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v139 + 6) = *(_BYTE *)((((__int64)(unsigned int)(int)v159 >> 3) & 0x3FF) + v7);
    v161 = v155 + v141;
    v162 = v141 - v155;
    v163 = v70[19];
    *(_BYTE *)(a5 + v139 + 2) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v154 + v144) >> 3) & 0x3FF) + v7);
    v164 = (unsigned int)(int)(float)(v144 - v154);
    v165 = v70[18];
    *(_BYTE *)(a5 + v139 + 5) = *(_BYTE *)(((v164 >> 3) & 0x3FF) + v7);
    v166 = (unsigned int)(int)v161;
    v167 = v70[22];
    *(_BYTE *)(a5 + v139 + 4) = *(_BYTE *)(((v166 >> 3) & 0x3FF) + v7);
    v168 = (unsigned int)(int)v162;
    v169 = v167 + v165;
    v170 = v165 - v167;
    v171 = v160 + v156;
    v172 = v156 - v160;
    v173 = v70[25];
    v174 = v173 + v163;
    *(_BYTE *)(a5 + v139 + 3) = *(_BYTE *)(((v168 >> 3) & 0x3FF) + v7);
    v175 = v71[1];
    v176 = v163 - v173;
    v177 = v171 + v169;
    v178 = v169 - v171;
    v179 = (float)(v172 * 1.4142135) - v171;
    v180 = v179 + v170;
    v181 = v170 - v179;
    v182 = v70[21] + v157;
    v183 = v157 - v70[21];
    v184 = v174 + v182;
    v185 = (float)(v176 + v183) * 1.847759;
    v186 = (float)(v185 - (float)(v183 * 2.613126)) - (float)(v174 + v182);
    v187 = (float)((float)(v174 - v182) * 1.4142135) - v186;
    v70 += 32;
    v71 += 4;
    v188 = (float)((float)(v176 * 1.0823922) - v185) + v187;
    *(_BYTE *)(a5 + v175) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v184 + v177) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v175 + 7) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v177 - v184) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v175 + 1) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v186 + v180) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v175 + 6) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v180 - v186) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v175 + 2) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v187 + v181) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v175 + 5) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v181 - v187) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v175 + 4) = *(_BYTE *)((((__int64)(unsigned int)(int)(float)(v188 + v178) >> 3) & 0x3FF) + v7);
    result = *(unsigned __int8 *)((((__int64)(unsigned int)(int)(float)(v178 - v188) >> 3) & 0x3FF) + v7);
    *(_BYTE *)(a5 + v175 + 3) = result;
    --v72;
  }
  while ( v72 );
  return result;
}

