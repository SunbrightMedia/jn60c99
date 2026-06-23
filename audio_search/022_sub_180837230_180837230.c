// sub_180837230 @ 0x180837230 (RVA 0x837230)  float_ops=63

// Hidden C++ exception states: #wind=4
void __fastcall sub_180837230(_DWORD *a1, int *a2)
{
  _DWORD *v2; // rbx
  int v3; // edi
  char *v4; // r9
  char *v5; // rdx
  __int64 v6; // rcx
  char *v7; // r8
  __int64 v8; // rcx
  __int64 v9; // rcx
  __int64 v10; // rdi
  __int64 v11; // rdx
  char *v12; // r8
  __int64 v13; // r9
  __int64 v14; // rcx
  __int64 v15; // rcx
  __int64 v16; // rcx
  int v17; // r9d
  float *v18; // r11
  float v19; // xmm1_4
  char *v20; // r10
  __int64 v21; // rcx
  float *v22; // rax
  int v23; // r9d
  float *v24; // r11
  float v25; // xmm1_4
  char *v26; // r10
  __int64 v27; // rcx
  float *v28; // rax
  char *v29; // r15
  float *v30; // rsi
  float *v31; // r14
  float v32; // xmm12_4
  float v33; // xmm13_4
  double v34; // xmm5_8
  double v35; // xmm4_8
  int v36; // r12d
  int v37; // r13d
  float v38; // xmm9_4
  float *v39; // rdx
  int v40; // r10d
  float *v41; // rax
  float v42; // xmm1_4
  float v43; // xmm0_4
  float v44; // xmm2_4
  float *v45; // rdx
  float *v46; // rax
  float v47; // xmm1_4
  float v48; // xmm0_4
  __int64 v49; // rcx
  float v50; // xmm8_4
  __int64 v51; // rcx
  float v52; // xmm3_4
  __int32 v53; // ebx
  __int32 v54; // edi
  float v55; // xmm7_4
  float *v56; // rcx
  __int64 v57; // r8
  float *v58; // rdx
  float v59; // xmm1_4
  float v60; // xmm0_4
  float v61; // xmm4_4
  float *v62; // rdx
  float *v63; // rax
  float v64; // xmm1_4
  float v65; // xmm0_4
  float v66; // xmm6_4
  int v67; // xmm4_4
  int v68; // xmm5_4
  int v69; // r12d
  __m128 v70; // xmm6
  float v71; // xmm0_4
  __m128 v72; // xmm7
  float v73; // xmm0_4
  float v74; // xmm6_4
  float v75; // xmm7_4
  float v76; // xmm4_4
  float v77; // xmm0_4
  float v78; // xmm5_4
  float v79; // xmm7_4
  float v80; // xmm4_4
  __int64 *v81; // rax
  int v82; // edx
  int v83; // ecx
  float v84; // xmm2_4
  float v85; // xmm4_4
  float v86; // xmm5_4
  float v87; // xmm2_4
  float v88; // xmm9_4
  float v89; // xmm8_4
  __m128 v90; // xmm1
  float v91; // xmm3_4
  __m128 v92; // xmm1
  __m128 v93; // xmm1
  __m128 v94; // xmm1
  __int64 v95; // rcx
  float v96; // xmm3_4
  float v97; // xmm2_4
  float *v98; // rbx
  __int64 v99; // rdi
  float *v100; // rbx
  __int64 v101; // rdi
  void *v102; // rsi
  __int64 v103; // rbx
  __int64 v104; // rdi
  void *v105; // rsi
  char *v106; // rbx
  __int64 v107; // rdi
  int v108; // [rsp+48h] [rbp-C0h]
  void *v109; // [rsp+58h] [rbp-B0h] BYREF
  __int64 v110; // [rsp+60h] [rbp-A8h]
  void *Block; // [rsp+68h] [rbp-A0h] BYREF
  __int64 v112; // [rsp+70h] [rbp-98h]
  void *v113; // [rsp+78h] [rbp-90h] BYREF
  int v114; // [rsp+84h] [rbp-84h]
  __m128i v115; // [rsp+88h] [rbp-80h]
  float v116; // [rsp+98h] [rbp-70h] BYREF
  float v117; // [rsp+9Ch] [rbp-6Ch] BYREF
  __int128 v118; // [rsp+A0h] [rbp-68h] BYREF
  unsigned __int64 v119; // [rsp+B0h] [rbp-58h]
  int v120; // [rsp+B8h] [rbp-50h]
  int v121; // [rsp+BCh] [rbp-4Ch]
  void *v122; // [rsp+C0h] [rbp-48h] BYREF
  _DWORD v123[4]; // [rsp+CCh] [rbp-3Ch]
  int v124; // [rsp+DCh] [rbp-2Ch]
  __int128 v125; // [rsp+E8h] [rbp-20h] BYREF
  _DWORD v126[4]; // [rsp+F8h] [rbp-10h] BYREF
  __int128 v127; // [rsp+108h] [rbp+0h] BYREF
  _DWORD v128[4]; // [rsp+118h] [rbp+10h] BYREF
  double v129; // [rsp+128h] [rbp+20h]
  double v130; // [rsp+130h] [rbp+28h]
  double v131; // [rsp+138h] [rbp+30h]
  double v132; // [rsp+140h] [rbp+38h]
  __m128 v133; // [rsp+158h] [rbp+50h]
  __int64 v134; // [rsp+168h] [rbp+60h]
  char v135; // [rsp+170h] [rbp+68h] BYREF
  char v136; // [rsp+180h] [rbp+78h] BYREF
  char *v139; // [rsp+298h] [rbp+190h] BYREF
  float v140; // [rsp+2A0h] [rbp+198h] BYREF

  v134 = -2;
  v2 = a1;
  sub_180200710(a1, &v113, a1);
  sub_180201690(&v122, v2, &v113);
  sub_180216890(&v109, v2 + 6);
  sub_180216890(&Block, v2 + 10);
  v3 = v123[0];
  sub_180233210(&v109, (unsigned int)(v123[0] + HIDWORD(v110)));
  v4 = (char *)v122 + 24 * v3;
  if ( v122 != v4 )
  {
    v5 = (char *)v122 + 5;
    do
    {
      v6 = SHIDWORD(v110);
      ++HIDWORD(v110);
      v7 = (char *)v109 + 24 * v6;
      if ( v7 )
      {
        *(_DWORD *)v7 = *(_DWORD *)(v5 - 5);
        v7[4] = *(v5 - 1);
        v7[5] = *v5;
        v8 = *(_QWORD *)(v5 + 3);
        *((_QWORD *)v7 + 1) = v8;
        if ( (*(_DWORD *)(v8 - 16) & 0x30000000) == 0 )
          _InterlockedExchangeAdd((volatile signed __int32 *)(v8 - 16), 1u);
        v9 = *(_QWORD *)(v5 + 11);
        *((_QWORD *)v7 + 2) = v9;
        if ( (*(_DWORD *)(v9 - 16) & 0x30000000) == 0 )
          _InterlockedExchangeAdd((volatile signed __int32 *)(v9 - 16), 1u);
      }
      v5 += 24;
    }
    while ( v5 - 5 != v4 );
  }
  v10 = v124;
  sub_180233210(&Block, (unsigned int)(v124 + HIDWORD(v112)));
  v13 = *(_QWORD *)&v123[1] + 24 * v10;
  if ( *(_QWORD *)&v123[1] != v13 )
  {
    v11 = *(_QWORD *)&v123[1] + 5LL;
    do
    {
      v14 = SHIDWORD(v112);
      ++HIDWORD(v112);
      v12 = (char *)Block + 24 * v14;
      if ( v12 )
      {
        *(_DWORD *)v12 = *(_DWORD *)(v11 - 5);
        v12[4] = *(_BYTE *)(v11 - 1);
        v12[5] = *(_BYTE *)v11;
        v15 = *(_QWORD *)(v11 + 3);
        *((_QWORD *)v12 + 1) = v15;
        if ( (*(_DWORD *)(v15 - 16) & 0x30000000) == 0 )
          _InterlockedExchangeAdd((volatile signed __int32 *)(v15 - 16), 1u);
        v16 = *(_QWORD *)(v11 + 11);
        *((_QWORD *)v12 + 2) = v16;
        if ( (*(_DWORD *)(v16 - 16) & 0x30000000) == 0 )
          _InterlockedExchangeAdd((volatile signed __int32 *)(v16 - 16), 1u);
      }
      v11 += 24;
    }
    while ( v11 - 5 != v13 );
  }
  v17 = 0;
  if ( SHIDWORD(v112) > 0 )
  {
    v18 = (float *)Block;
    do
    {
      if ( *((_BYTE *)v18 + 5) )
      {
        v19 = 0.0;
        LODWORD(v139) = 0;
        v12 = (char *)v113;
        v20 = (char *)v113 + 24 * v114;
        if ( v113 != v20 )
        {
          do
          {
            v21 = *((_QWORD *)v12 + 2);
            LODWORD(v11) = (HIDWORD(v21) - (int)v21) >> 31;
            if ( (int)abs32(HIDWORD(v21) - v21) <= 1 && (_DWORD)v21 == v17 + 1 )
            {
              v116 = (float)(*(float *)(*(_QWORD *)v12 + 128LL) + *(float *)(*(_QWORD *)v12 + 108LL))
                   + *(float *)(*(_QWORD *)v12 + 132LL);
              v22 = &v116;
              if ( v116 <= v19 )
                v22 = (float *)&v139;
              v19 = *v22;
              *(float *)&v139 = *v22;
            }
            v12 += 24;
          }
          while ( v12 != v20 );
        }
        *v18 = v19;
      }
      ++v17;
      v18 += 6;
    }
    while ( v17 < SHIDWORD(v112) );
  }
  v23 = 0;
  if ( SHIDWORD(v110) > 0 )
  {
    v24 = (float *)v109;
    do
    {
      if ( *((_BYTE *)v24 + 5) )
      {
        v25 = 0.0;
        v140 = 0.0;
        v12 = (char *)v113;
        v26 = (char *)v113 + 24 * v114;
        if ( v113 != v26 )
        {
          do
          {
            v27 = *((_QWORD *)v12 + 1);
            LODWORD(v11) = (HIDWORD(v27) - (int)v27) >> 31;
            if ( (int)abs32(HIDWORD(v27) - v27) <= 1 && (_DWORD)v27 == v23 + 1 )
            {
              v117 = (float)(*(float *)(*(_QWORD *)v12 + 120LL) + *(float *)(*(_QWORD *)v12 + 96LL))
                   + *(float *)(*(_QWORD *)v12 + 124LL);
              v28 = &v117;
              if ( v117 <= v25 )
                v28 = &v140;
              v25 = *v28;
              v140 = *v28;
            }
            v12 += 24;
          }
          while ( v12 != v26 );
        }
        *v24 = v25;
      }
      ++v23;
      v24 += 6;
    }
    while ( v23 < SHIDWORD(v110) );
  }
  v118 = 0;
  sub_1801FD550(
    (unsigned int)&v118,
    v11,
    (_DWORD)v12,
    *((_QWORD *)v2 + 15),
    *((_QWORD *)v2 + 16),
    (__int64)&v109,
    (__int64)&Block);
  v29 = (char *)v113;
  v139 = (char *)v113 + 24 * v114;
  v30 = (float *)v109;
  v31 = (float *)Block;
  if ( v113 != v139 )
  {
    v32 = *(float *)&v118;
    v125 = v118;
    v33 = *((float *)&v118 + 1);
    v127 = v118;
    while ( 1 )
    {
      v115 = *(__m128i *)(v29 + 8);
      v34 = *((double *)v2 + 16);
      v35 = *((double *)v2 + 15);
      v36 = v2[2];
      v37 = v2[3];
      v38 = 0.0;
      v39 = v30;
      v40 = _mm_cvtsi128_si32(v115);
      v41 = &v30[6 * v40 - 6];
      if ( v30 != v41 )
      {
        do
        {
          if ( *((_BYTE *)v39 + 4) )
            v43 = v32 * *v39;
          else
            v43 = *v39;
          v42 = v35;
          v38 = v38 + (float)(v43 + v42);
          v39 += 6;
        }
        while ( v39 != v41 );
      }
      v44 = 0.0;
      v45 = v31;
      v46 = &v31[6 * v115.m128i_i32[2] - 6];
      if ( v31 != v46 )
      {
        do
        {
          if ( *((_BYTE *)v45 + 4) )
            v48 = v33 * *v45;
          else
            v48 = *v45;
          v47 = v34;
          v44 = v44 + (float)(v48 + v47);
          v45 += 6;
        }
        while ( v45 != v46 );
      }
      v49 = v40 - 1;
      if ( LOBYTE(v30[6 * v49 + 1]) )
        v50 = v32 * v30[6 * v49];
      else
        v50 = v30[6 * v49];
      v51 = v115.m128i_i32[2] - 1;
      if ( LOBYTE(v31[6 * v51 + 1]) )
        v52 = v33 * v31[6 * v51];
      else
        v52 = v31[6 * v51];
      v53 = v115.m128i_i32[3] - 1;
      v54 = v115.m128i_i32[1] - 1;
      v55 = 0.0;
      v56 = v30;
      v57 = v115.m128i_i32[1] - 1;
      v58 = &v30[6 * v57 - 6];
      if ( v30 != v58 )
      {
        do
        {
          if ( *((_BYTE *)v56 + 4) )
            v60 = v32 * *v56;
          else
            v60 = *v56;
          v59 = v35;
          v55 = v55 + (float)(v60 + v59);
          v56 += 6;
        }
        while ( v56 != v58 );
      }
      v61 = 0.0;
      v62 = v31;
      v63 = &v31[6 * v53 - 6];
      if ( v31 != v63 )
      {
        do
        {
          if ( *((_BYTE *)v62 + 4) )
            v65 = v33 * *v62;
          else
            v65 = *v62;
          v64 = v34;
          v61 = v61 + (float)(v65 + v64);
          v62 += 6;
        }
        while ( v62 != v63 );
      }
      if ( LOBYTE(v30[6 * v54 - 5]) )
        v66 = v32 * v30[6 * v57 - 6];
      else
        v66 = v30[6 * v57 - 6];
      *(float *)v126 = v38;
      *(float *)&v126[1] = v44;
      *(float *)&v126[2] = v50;
      *(float *)&v126[3] = v52;
      v115 = *(__m128i *)sub_1801FF140(
                           (unsigned int)&v135,
                           (unsigned int)v126,
                           v40,
                           v115.m128i_i32[2],
                           HIDWORD(v110),
                           HIDWORD(v112),
                           (__int64)&v125,
                           v37,
                           v36);
      *(float *)v128 = v55;
      v128[1] = v67;
      *(float *)&v128[2] = v66;
      v128[3] = v68;
      v108 = v36;
      v69 = HIDWORD(v110);
      v70 = *(__m128 *)sub_1801FF140(
                         (unsigned int)&v136,
                         (unsigned int)v128,
                         v54,
                         v53,
                         HIDWORD(v110),
                         HIDWORD(v112),
                         (__int64)&v127,
                         v37,
                         v108);
      v133 = v70;
      v72 = v70;
      v71 = _mm_shuffle_ps(v70, v70, 170).m128_f32[0];
      v72.m128_f32[0] = v70.m128_f32[0] + v71;
      if ( (float)(v70.m128_f32[0] + v71) <= v70.m128_f32[0] )
        v72 = v70;
      v73 = *(float *)v115.m128i_i32 + *(float *)&v115.m128i_i32[2];
      if ( (float)(*(float *)v115.m128i_i32 + *(float *)&v115.m128i_i32[2]) <= *(float *)v115.m128i_i32 )
        v73 = *(float *)v115.m128i_i32;
      v74 = fminf(v70.m128_f32[0], *(float *)v115.m128i_i32);
      v75 = fmaxf(fmaxf(v72.m128_f32[0], v73), v74);
      v76 = v133.m128_f32[1] + v133.m128_f32[3];
      if ( (float)(v133.m128_f32[1] + v133.m128_f32[3]) <= v133.m128_f32[1] )
        v76 = v133.m128_f32[1];
      v77 = *(float *)&v115.m128i_i32[1] + *(float *)&v115.m128i_i32[3];
      if ( (float)(*(float *)&v115.m128i_i32[1] + *(float *)&v115.m128i_i32[3]) <= *(float *)&v115.m128i_i32[1] )
        v77 = *(float *)&v115.m128i_i32[1];
      v78 = fminf(v133.m128_f32[1], *(float *)&v115.m128i_i32[1]);
      v79 = v75 - v74;
      v80 = fmaxf(fmaxf(v76, v77), v78) - v78;
      v81 = *(__int64 **)v29;
      v82 = *(_DWORD *)(*(_QWORD *)v29 + 16LL);
      v2 = a1;
      if ( v82 == 4 )
        v82 = a1[1];
      v83 = *((_DWORD *)v81 + 3);
      if ( v83 == 4 )
        v83 = *a1;
      v84 = *((float *)v81 + 32);
      v85 = v80 - (float)(*((float *)v81 + 33) + v84);
      v72.m128_f32[0] = v79 - (float)(*((float *)v81 + 31) + *((float *)v81 + 30));
      v86 = v78 + v84;
      v70.m128_f32[0] = v74 + *((float *)v81 + 30);
      v87 = v86;
      v88 = v72.m128_f32[0];
      v89 = v85;
      if ( *((float *)v81 + 24) != -1.0 )
        v88 = *((float *)v81 + 24);
      if ( *((float *)v81 + 27) != -1.0 )
        v89 = *((float *)v81 + 27);
      if ( v82 )
        break;
      v90 = v70;
      if ( v83 )
        goto LABEL_93;
LABEL_99:
      v90.m128_f32[0] = v90.m128_f32[0] + (float)*a2;
      v92 = _mm_shuffle_ps(v90, v90, 225);
      v92.m128_f32[0] = (float)a2[1] + v87;
      v93 = _mm_shuffle_ps(v92, v92, 198);
      v93.m128_f32[0] = v88;
      v94 = _mm_shuffle_ps(v93, v93, 39);
      v94.m128_f32[0] = v89;
      *(__m128 *)(v81 + 17) = _mm_shuffle_ps(v94, v94, 57);
      v95 = *v81;
      if ( *v81 )
      {
        v96 = *((float *)v81 + 35);
        v132 = (float)(v96 + *((float *)v81 + 37)) + 6.755399441055744e15;
        v97 = *((float *)v81 + 34);
        v131 = (float)(v97 + *((float *)v81 + 36)) + 6.755399441055744e15;
        v130 = v96 + 6.755399441055744e15;
        v129 = v97 + 6.755399441055744e15;
        v119 = __PAIR64__(LODWORD(v130), LODWORD(v129));
        v120 = LODWORD(v131) - LODWORD(v129);
        v121 = LODWORD(v132) - LODWORD(v130);
        sub_1808D7910(v95, LODWORD(v129), LODWORD(v130), LODWORD(v131) - LODWORD(v129), LODWORD(v132) - LODWORD(v130));
      }
      v29 += 24;
      if ( v29 == v139 )
        goto LABEL_104;
    }
    if ( v82 == 1 )
      v87 = (float)(v85 - v89) + v86;
LABEL_93:
    v90 = v70;
    if ( v83 == 1 )
    {
      v90 = v72;
      v90.m128_f32[0] = (float)(v72.m128_f32[0] - v88) + v70.m128_f32[0];
    }
    v91 = v89 * 0.5;
    if ( v82 == 2 )
    {
      v90.m128_f32[0] = (float)(v90.m128_f32[0] + (float)(v88 * 0.5)) - (float)(v88 * 0.5);
      v87 = (float)((float)(v85 * 0.5) + v86) - v91;
    }
    if ( v83 == 2 )
    {
      v90 = v72;
      v90.m128_f32[0] = (float)((float)(v72.m128_f32[0] * 0.5) + v70.m128_f32[0]) - (float)(v88 * 0.5);
      v87 = (float)(v87 + v91) - v91;
    }
    goto LABEL_99;
  }
  v69 = HIDWORD(v110);
LABEL_104:
  if ( SHIDWORD(v112) > 0 )
  {
    v98 = v31;
    v99 = HIDWORD(v112);
    do
    {
      sub_180201F00(v98);
      v98 += 6;
      --v99;
    }
    while ( v99 );
  }
  free(v31);
  if ( v69 > 0 )
  {
    v100 = v30;
    v101 = (unsigned int)v69;
    do
    {
      sub_180201F00(v100);
      v100 += 6;
      --v101;
    }
    while ( v101 );
  }
  free(v30);
  v102 = *(void **)&v123[1];
  if ( v124 > 0 )
  {
    v103 = *(_QWORD *)&v123[1];
    v104 = (unsigned int)v124;
    do
    {
      sub_180201F00(v103);
      v103 += 24;
      --v104;
    }
    while ( v104 );
  }
  free(v102);
  v105 = v122;
  if ( v123[0] > 0 )
  {
    v106 = (char *)v122;
    v107 = v123[0];
    do
    {
      sub_180201F00(v106);
      v106 += 24;
      --v107;
    }
    while ( v107 );
  }
  free(v105);
  v114 = 0;
  free(v113);
}

