// sub_180819F40 @ 0x180819F40 (RVA 0x819F40)  float_ops=88

// Hidden C++ exception states: #wind=3
unsigned __int64 __fastcall sub_180819F40(_QWORD *a1, unsigned int **a2, double *a3, __int32 *a4)
{
  _QWORD *v7; // r15
  unsigned int *v8; // r10
  unsigned __int64 result; // rax
  int v10; // edx
  unsigned int v11; // ecx
  int v12; // edx
  unsigned int v13; // ecx
  int v14; // ecx
  __int32 v15; // r12d
  int v16; // r11d
  int v17; // ebx
  unsigned __int64 v18; // xmm0_8
  int v19; // ecx
  int v20; // r14d
  char *v21; // rdi
  _DWORD *v22; // rcx
  int v23; // eax
  __int32 v24; // r9d
  char *v25; // r14
  __int32 v26; // r8d
  float v27; // xmm2_4
  float v28; // xmm3_4
  float v29; // xmm4_4
  float v30; // xmm5_4
  int v31; // edi
  int v32; // r11d
  int v33; // r12d
  int v34; // ebx
  int v35; // r15d
  int v36; // r13d
  int v37; // esi
  int v38; // r8d
  unsigned __int8 *v39; // rdx
  int v40; // r9d
  float v41; // xmm1_4
  unsigned __int8 *v42; // rdx
  int v43; // r8d
  float v44; // xmm1_4
  unsigned __int8 *v45; // rdx
  int v46; // r8d
  float v47; // xmm1_4
  unsigned __int8 *v48; // rdx
  int v49; // r8d
  float v50; // xmm1_4
  float v51; // xmm1_4
  char v52; // dl
  double v53; // rax
  char v54; // dl
  double v55; // rax
  char v56; // dl
  double v57; // rax
  char v58; // dl
  __int32 v59; // ecx
  char *v60; // r14
  float v61; // xmm2_4
  float v62; // xmm3_4
  float v63; // xmm4_4
  int v64; // edi
  int v65; // r11d
  int v66; // r13d
  int v67; // ebx
  int v68; // r15d
  int v69; // esi
  __int64 v70; // r14
  int v71; // r8d
  unsigned __int8 *v72; // rdx
  int v73; // r9d
  float v74; // xmm1_4
  unsigned __int8 *v75; // rdx
  int v76; // r8d
  float v77; // xmm1_4
  unsigned __int8 *v78; // rdx
  int v79; // r8d
  float v80; // xmm1_4
  unsigned __int8 *v81; // rdx
  int v82; // r8d
  float v83; // xmm1_4
  float v84; // xmm1_4
  double v85; // xmm0_8
  double v86; // xmm0_8
  double v87; // xmm0_8
  __int32 v88; // r8d
  char *v89; // rdx
  __int32 v90; // r13d
  _QWORD *v91; // r11
  float v92; // xmm1_4
  int v93; // r14d
  int v94; // edi
  int v95; // ecx
  int v96; // esi
  int v97; // r12d
  int v98; // r15d
  int v99; // r8d
  unsigned __int8 *v100; // r10
  int v101; // r9d
  __int64 v102; // rax
  unsigned __int8 *v103; // r11
  int v104; // r8d
  __int64 v105; // rax
  unsigned __int8 *v106; // r10
  int v107; // r8d
  __int64 v108; // rax
  unsigned __int8 *v109; // r11
  int v110; // r8d
  __int64 v111; // rax
  __int64 v112; // rax
  __int32 v113; // [rsp+38h] [rbp-69h]
  __int32 v114; // [rsp+3Ch] [rbp-65h]
  int v115; // [rsp+40h] [rbp-61h]
  __m128i v116; // [rsp+48h] [rbp-59h]
  char *v117; // [rsp+48h] [rbp-59h]
  char *v118; // [rsp+48h] [rbp-59h]
  char *v119; // [rsp+58h] [rbp-49h]
  char *v120; // [rsp+58h] [rbp-49h]
  char *v121; // [rsp+58h] [rbp-49h]
  __int64 v122; // [rsp+60h] [rbp-41h] BYREF
  int v123; // [rsp+6Ch] [rbp-35h]
  int v124; // [rsp+70h] [rbp-31h]
  int v125; // [rsp+74h] [rbp-2Dh]
  int v126; // [rsp+78h] [rbp-29h]
  __int64 (__fastcall ***v127)(_QWORD, __int64); // [rsp+80h] [rbp-21h]
  char *v128; // [rsp+88h] [rbp-19h] BYREF
  int v129; // [rsp+94h] [rbp-Dh]
  unsigned int v130; // [rsp+98h] [rbp-9h]
  int v131; // [rsp+9Ch] [rbp-5h]
  int v132; // [rsp+A0h] [rbp-1h]
  __int64 (__fastcall ***v133)(_QWORD, __int64); // [rsp+A8h] [rbp+7h]
  __int128 v134; // [rsp+B0h] [rbp+Fh]
  int v136; // [rsp+110h] [rbp+6Fh]
  __int32 v137; // [rsp+118h] [rbp+77h]
  char *v138; // [rsp+118h] [rbp+77h]
  double v139; // [rsp+118h] [rbp+77h]

  *(_QWORD *)&v134 = -2;
  v7 = a1;
  v8 = *a2;
  result = *(unsigned __int64 *)a3;
  if ( *(unsigned int **)a3 == *a2 )
  {
    sub_18081CB20(a2);
    v8 = *a2;
  }
  else
  {
    v10 = 0;
    if ( *(double *)&result != 0.0 )
      v10 = *(_DWORD *)(result + 20);
    v11 = 0;
    if ( v8 )
      v11 = v8[5];
    if ( v10 != v11 )
      return result;
    v12 = 0;
    if ( *(double *)&result != 0.0 )
      v12 = *(_DWORD *)(result + 24);
    v13 = 0;
    if ( v8 )
      v13 = v8[6];
    if ( v12 != v13 )
      return result;
    v14 = 0;
    if ( *(double *)&result != 0.0 )
      v14 = *(_DWORD *)(result + 16);
    *(double *)&result = 0.0;
    if ( v8 )
      result = v8[4];
    if ( v14 != (_DWORD)result )
      return result;
  }
  if ( v8 )
  {
    v116.m128i_i64[0] = 0;
    v116.m128i_i64[1] = *(_QWORD *)(v8 + 5);
  }
  else
  {
    v116 = 0;
    v8 = nullptr;
  }
  v15 = *a4;
  if ( *a4 < v116.m128i_i32[0] )
    v15 = v116.m128i_i32[0];
  v114 = v15;
  v16 = a4[1];
  v17 = v16;
  if ( v16 < v116.m128i_i32[1] )
    v17 = v116.m128i_i32[1];
  v136 = v17;
  v18 = _mm_srli_si128(v116, 8).m128i_u64[0];
  result = (unsigned int)(*a4 + a4[2]);
  if ( v116.m128i_i32[0] + (int)v18 < (int)result )
    result = (unsigned int)(v116.m128i_i32[0] + v18);
  v113 = result;
  v19 = result - v15;
  if ( (int)result - v15 >= 0 )
  {
    v20 = v16 + a4[3];
    if ( v116.m128i_i32[1] + HIDWORD(v18) < v20 )
      v20 = v116.m128i_i32[1] + HIDWORD(v18);
    v115 = v20;
    result = (unsigned int)(v20 - v17);
    if ( v20 - v17 >= 0 && v19 > 0 && (int)result > 0 )
    {
      v131 = v19;
      v132 = v20 - v17;
      v133 = nullptr;
      (*(void (__fastcall **)(unsigned int *, char **, _QWORD, _QWORD, int))(*(_QWORD *)v8 + 32LL))(
        v8,
        &v128,
        (unsigned int)v15,
        (unsigned int)v17,
        1);
      v21 = v128;
      v22 = *(_DWORD **)a3;
      if ( *(_QWORD *)a3 )
      {
        v125 = v22[5];
        v23 = v22[6];
      }
      else
      {
        v125 = 0;
        v23 = 0;
      }
      v126 = v23;
      v127 = nullptr;
      (*(void (__fastcall **)(_DWORD *, __int64 *, _QWORD, _QWORD, _DWORD))(*(_QWORD *)v22 + 32LL))(v22, &v122, 0, 0, 0);
      result = v130;
      if ( v130 == 4 )
      {
        if ( v17 < v20 )
        {
          v24 = v113;
          do
          {
            v25 = v21;
            v117 = v21;
            result = v129;
            v21 += v129;
            v119 = v21;
            v26 = v15;
            v137 = v15;
            if ( v15 < v24 )
            {
              do
              {
                v27 = 0.0;
                v28 = 0.0;
                v29 = 0.0;
                v30 = 0.0;
                v31 = 0;
                v32 = *((_DWORD *)v7 + 2);
                if ( v32 > 0 )
                {
                  v33 = v32 >> 1;
                  v34 = 0;
                  v35 = v136 - (v32 >> 1);
                  v36 = v123;
                  v37 = v35 * v123;
                  do
                  {
                    if ( v35 + v31 >= v126 )
                      break;
                    if ( v35 + v31 >= 0 )
                    {
                      v38 = v137 - v33;
                      v39 = (unsigned __int8 *)((v137 - v33) * v124 + v122 + v37);
                      v40 = 0;
                      if ( v32 < 4 )
                      {
LABEL_58:
                        if ( v40 < v32 )
                        {
                          do
                          {
                            if ( v38 >= v125 )
                              break;
                            if ( v38 >= 0 )
                            {
                              v51 = *(float *)(*a1 + 4LL * (v40 + v31 * v32));
                              v27 = v27 + (float)((float)*v39 * v51);
                              v28 = v28 + (float)((float)v39[1] * v51);
                              v29 = v29 + (float)((float)v39[2] * v51);
                              v30 = v30 + (float)((float)v39[3] * v51);
                            }
                            v39 += 4;
                            ++v38;
                            ++v40;
                          }
                          while ( v40 < v32 );
                          v36 = v123;
                        }
                      }
                      else
                      {
                        while ( v38 < v125 )
                        {
                          if ( v38 >= 0 )
                          {
                            v41 = *(float *)(*a1 + 4LL * (v34 + v40));
                            v27 = v27 + (float)((float)*v39 * v41);
                            v28 = v28 + (float)((float)v39[1] * v41);
                            v29 = v29 + (float)((float)v39[2] * v41);
                            v30 = v30 + (float)((float)v39[3] * v41);
                          }
                          v42 = v39 + 4;
                          v43 = v38 + 1;
                          if ( v43 >= v125 )
                            break;
                          if ( v43 >= 0 )
                          {
                            v44 = *(float *)(*a1 + 4LL * (v34 + v40) + 4);
                            v27 = v27 + (float)((float)*v42 * v44);
                            v28 = v28 + (float)((float)v42[1] * v44);
                            v29 = v29 + (float)((float)v42[2] * v44);
                            v30 = v30 + (float)((float)v42[3] * v44);
                          }
                          v45 = v42 + 4;
                          v46 = v43 + 1;
                          if ( v46 >= v125 )
                            break;
                          if ( v46 >= 0 )
                          {
                            v47 = *(float *)(*a1 + 4LL * (v34 + v40) + 8);
                            v27 = v27 + (float)((float)*v45 * v47);
                            v28 = v28 + (float)((float)v45[1] * v47);
                            v29 = v29 + (float)((float)v45[2] * v47);
                            v30 = v30 + (float)((float)v45[3] * v47);
                          }
                          v48 = v45 + 4;
                          v49 = v46 + 1;
                          if ( v49 >= v125 )
                            break;
                          if ( v49 >= 0 )
                          {
                            v50 = *(float *)(*a1 + 4LL * (v34 + v40) + 12);
                            v27 = v27 + (float)((float)*v48 * v50);
                            v28 = v28 + (float)((float)v48[1] * v50);
                            v29 = v29 + (float)((float)v48[2] * v50);
                            v30 = v30 + (float)((float)v48[3] * v50);
                          }
                          v39 = v48 + 4;
                          v38 = v49 + 1;
                          v40 += 4;
                          if ( v40 >= v32 - 3 )
                            goto LABEL_58;
                        }
                      }
                    }
                    ++v31;
                    v37 += v36;
                    v34 += v32;
                  }
                  while ( v31 < v32 );
                  v25 = v117;
                  v26 = v137;
                  v7 = a1;
                  v24 = v113;
                }
                v52 = -1;
                v53 = v27 + 6.755399441055744e15;
                if ( SLODWORD(v53) < 255 )
                  v52 = LOBYTE(v53);
                *v25 = v52;
                v54 = -1;
                v55 = v28 + 6.755399441055744e15;
                if ( SLODWORD(v55) < 255 )
                  v54 = LOBYTE(v55);
                v25[1] = v54;
                v56 = -1;
                v57 = v29 + 6.755399441055744e15;
                if ( SLODWORD(v57) < 255 )
                  v56 = LOBYTE(v57);
                v25[2] = v56;
                v58 = -1;
                *(double *)&result = v30 + 6.755399441055744e15;
                if ( (int)result < 255 )
                  v58 = result;
                v25[3] = v58;
                v25 += 4;
                v117 = v25;
                v137 = ++v26;
              }
              while ( v26 < v24 );
              v17 = v136;
              v21 = v119;
              v15 = v114;
            }
            v136 = ++v17;
          }
          while ( v17 < v115 );
        }
      }
      else if ( v130 == 3 )
      {
        if ( v17 < v20 )
        {
          v59 = v113;
          do
          {
            v60 = v21;
            v138 = v21;
            result = v129;
            v21 += v129;
            v120 = v21;
            if ( v114 < v59 )
            {
              do
              {
                v61 = 0.0;
                v62 = 0.0;
                v63 = 0.0;
                v64 = 0;
                v65 = *((_DWORD *)v7 + 2);
                if ( v65 > 0 )
                {
                  v66 = v65 >> 1;
                  v67 = 0;
                  v68 = v136 - (v65 >> 1);
                  v69 = v68 * v123;
                  v70 = v122;
                  do
                  {
                    if ( v68 + v64 >= v126 )
                      break;
                    if ( v68 + v64 >= 0 )
                    {
                      v71 = v15 - v66;
                      v72 = (unsigned __int8 *)(v70 + (v15 - v66) * v124 + v69);
                      v73 = 0;
                      if ( v65 < 4 )
                      {
LABEL_100:
                        if ( v73 < v65 )
                        {
                          do
                          {
                            if ( v71 >= v125 )
                              break;
                            if ( v71 >= 0 )
                            {
                              v84 = *(float *)(*a1 + 4LL * (v73 + v64 * v65));
                              v61 = v61 + (float)((float)*v72 * v84);
                              v62 = v62 + (float)((float)v72[1] * v84);
                              v63 = v63 + (float)((float)v72[2] * v84);
                            }
                            v72 += 3;
                            ++v71;
                            ++v73;
                          }
                          while ( v73 < v65 );
                          v70 = v122;
                        }
                      }
                      else
                      {
                        while ( v71 < v125 )
                        {
                          if ( v71 >= 0 )
                          {
                            v74 = *(float *)(*a1 + 4LL * (v67 + v73));
                            v61 = v61 + (float)((float)*v72 * v74);
                            v62 = v62 + (float)((float)v72[1] * v74);
                            v63 = v63 + (float)((float)v72[2] * v74);
                          }
                          v75 = v72 + 3;
                          v76 = v71 + 1;
                          if ( v76 >= v125 )
                            break;
                          if ( v76 >= 0 )
                          {
                            v77 = *(float *)(*a1 + 4LL * (v67 + v73) + 4);
                            v61 = v61 + (float)((float)*v75 * v77);
                            v62 = v62 + (float)((float)v75[1] * v77);
                            v63 = v63 + (float)((float)v75[2] * v77);
                          }
                          v78 = v75 + 3;
                          v79 = v76 + 1;
                          if ( v79 >= v125 )
                            break;
                          if ( v79 >= 0 )
                          {
                            v80 = *(float *)(*a1 + 4LL * (v67 + v73) + 8);
                            v61 = v61 + (float)((float)*v78 * v80);
                            v62 = v62 + (float)((float)v78[1] * v80);
                            v63 = v63 + (float)((float)v78[2] * v80);
                          }
                          v81 = v78 + 3;
                          v82 = v79 + 1;
                          if ( v82 >= v125 )
                            break;
                          if ( v82 >= 0 )
                          {
                            v83 = *(float *)(*a1 + 4LL * (v67 + v73) + 12);
                            v61 = v61 + (float)((float)*v81 * v83);
                            v62 = v62 + (float)((float)v81[1] * v83);
                            v63 = v63 + (float)((float)v81[2] * v83);
                          }
                          v72 = v81 + 3;
                          v71 = v82 + 1;
                          v73 += 4;
                          if ( v73 >= v65 - 3 )
                            goto LABEL_100;
                        }
                      }
                    }
                    ++v64;
                    v69 += v123;
                    v67 += v65;
                  }
                  while ( v64 < v65 );
                  v60 = v138;
                  v7 = a1;
                  v59 = v113;
                }
                v85 = v61 + 6.755399441055744e15;
                *v60 = LOBYTE(v85);
                v86 = v62 + 6.755399441055744e15;
                v60[1] = LOBYTE(v86);
                v87 = v63 + 6.755399441055744e15;
                result = LOBYTE(v87);
                v60[2] = LOBYTE(v87);
                v60 += 3;
                v138 = v60;
                ++v15;
              }
              while ( v15 < v59 );
              v17 = v136;
              v21 = v120;
            }
            v136 = ++v17;
            v15 = v114;
          }
          while ( v17 < v115 );
        }
      }
      else if ( v130 == 1 && v17 < v20 )
      {
        v88 = v113;
        do
        {
          v89 = v21;
          v118 = v21;
          result = v129;
          v21 += v129;
          v121 = v21;
          v90 = v15;
          if ( v15 < v88 )
          {
            v91 = a1;
            do
            {
              v92 = 0.0;
              v93 = 0;
              v94 = *((_DWORD *)v91 + 2);
              if ( v94 > 0 )
              {
                v95 = v94 >> 1;
                v96 = 0;
                v97 = v17 - (v94 >> 1);
                v98 = v123 * v97;
                do
                {
                  if ( v97 + v93 >= v126 )
                    break;
                  if ( v97 + v93 >= 0 )
                  {
                    v99 = v90 - v95;
                    v100 = (unsigned __int8 *)((v90 - v95) * v124 + v122 + v98);
                    v101 = 0;
                    if ( v94 < 4 )
                    {
LABEL_139:
                      while ( v101 < v94 )
                      {
                        if ( v99 >= v125 )
                          break;
                        if ( v99 < 0 )
                        {
                          v112 = 3;
                        }
                        else
                        {
                          v92 = v92 + (float)((float)*v100 * *(float *)(*v91 + 4LL * (v101 + v93 * v94)));
                          v112 = 1;
                        }
                        ++v99;
                        ++v101;
                        v100 += v112;
                      }
                    }
                    else
                    {
                      while ( v99 < v125 )
                      {
                        if ( v99 < 0 )
                        {
                          v102 = 3;
                        }
                        else
                        {
                          v92 = v92 + (float)((float)*v100 * *(float *)(*v91 + 4LL * (v96 + v101)));
                          v102 = 1;
                        }
                        v103 = &v100[v102];
                        v104 = v99 + 1;
                        if ( v104 >= v125 )
                          break;
                        if ( v104 < 0 )
                        {
                          v105 = 3;
                        }
                        else
                        {
                          v92 = v92 + (float)((float)*v103 * *(float *)(*a1 + 4LL * (v96 + v101) + 4));
                          v105 = 1;
                        }
                        v106 = &v103[v105];
                        v107 = v104 + 1;
                        if ( v107 >= v125 )
                          break;
                        if ( v107 < 0 )
                        {
                          v108 = 3;
                        }
                        else
                        {
                          v92 = v92 + (float)((float)*v106 * *(float *)(*a1 + 4LL * (v96 + v101) + 8));
                          v108 = 1;
                        }
                        v109 = &v106[v108];
                        v110 = v107 + 1;
                        if ( v110 >= v125 )
                          break;
                        if ( v110 < 0 )
                        {
                          v111 = 3;
                        }
                        else
                        {
                          v92 = v92 + (float)((float)*v109 * *(float *)(*a1 + 4LL * (v96 + v101) + 12));
                          v111 = 1;
                        }
                        v99 = v110 + 1;
                        v101 += 4;
                        v100 = &v109[v111];
                        v91 = a1;
                        if ( v101 >= v94 - 3 )
                          goto LABEL_139;
                      }
                    }
                    v95 = v94 >> 1;
                  }
                  ++v93;
                  v98 += v123;
                  v96 += v94;
                  v91 = a1;
                }
                while ( v93 < v94 );
                v89 = v118;
                v17 = v136;
                v88 = v113;
              }
              v139 = v92 + 6.755399441055744e15;
              result = LOBYTE(v139);
              *v89++ = LOBYTE(v139);
              v118 = v89;
              ++v90;
            }
            while ( v90 < v88 );
            v21 = v121;
            v15 = v114;
            v20 = v115;
          }
          v136 = ++v17;
        }
        while ( v17 < v20 );
      }
      if ( v127 )
        *(double *)&result = COERCE_DOUBLE((**v127)(v127, 1));
      if ( v133 )
        *(double *)&result = COERCE_DOUBLE((**v133)(v133, 1));
    }
  }
  return result;
}

