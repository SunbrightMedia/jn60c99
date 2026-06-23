// sub_1808A0AA0 @ 0x1808A0AA0 (RVA 0x8A0AA0)  float_ops=65

__int64 __fastcall sub_1808A0AA0(__int64 *a1, int a2, int a3, int a4, unsigned int a5)
{
  int v5; // ebx
  __int64 v6; // r15
  __int64 v8; // rsi
  double v10; // xmm4_8
  int v11; // r11d
  __int64 v12; // rcx
  __int64 v13; // rdx
  double v14; // xmm1_8
  double v15; // rax
  double v16; // xmm1_8
  int v17; // r14d
  int v18; // r9d
  int v19; // r12d
  __int64 v20; // rdi
  unsigned __int64 v21; // rbx
  __int64 *v22; // r11
  __int64 v23; // rcx
  double v24; // xmm1_8
  double v25; // xmm1_8
  int v26; // ecx
  double v27; // xmm1_8
  int v28; // edx
  int v29; // eax
  bool v30; // cc
  int v31; // r8d
  __int64 v32; // rcx
  double v33; // xmm1_8
  double v34; // xmm1_8
  int v35; // ecx
  double v36; // xmm1_8
  int v37; // edx
  int v38; // eax
  int v39; // r9d
  __int64 v40; // rcx
  double v41; // xmm1_8
  double v42; // xmm1_8
  int v43; // ecx
  double v44; // xmm1_8
  int v45; // edx
  int v46; // eax
  int v47; // r8d
  __int64 v48; // rcx
  double v49; // xmm1_8
  double v50; // xmm1_8
  int v51; // ecx
  double v52; // xmm1_8
  int v53; // edx
  int v54; // eax
  __int64 v55; // r11
  __int64 v56; // r8
  __int64 v57; // rcx
  double v58; // xmm1_8
  double v59; // xmm1_8
  int v60; // edx
  double v61; // xmm1_8
  int v62; // ecx
  int v63; // eax
  int v64; // ecx
  __int64 v65; // rbx
  __int64 v66; // r15
  __int64 v67; // r11
  __int64 v68; // rsi
  double v69; // xmm1_8
  double v70; // xmm1_8
  int v71; // edi
  double v72; // xmm1_8
  double v73; // rcx
  int v74; // edx
  int v75; // ecx
  int v76; // r8d
  __int64 v77; // rsi
  double v78; // xmm1_8
  double v79; // xmm1_8
  int v80; // edi
  double v81; // xmm1_8
  double v82; // rcx
  int v83; // edx
  int v84; // ecx
  int v85; // r8d
  __int64 v86; // rsi
  double v87; // xmm1_8
  double v88; // xmm1_8
  int v89; // edi
  double v90; // xmm1_8
  double v91; // rcx
  int v92; // edx
  int v93; // ecx
  int v94; // r8d
  __int64 v95; // rdi
  double v96; // xmm1_8
  double v97; // xmm1_8
  int v98; // r11d
  double v99; // xmm1_8
  double v100; // rcx
  int v101; // edx
  int v102; // ecx
  int v103; // r8d
  __int64 v104; // rdi
  double v105; // xmm1_8
  double v106; // xmm1_8
  int v107; // r11d
  double v108; // xmm1_8
  double v109; // rcx
  int v110; // edx
  int v111; // ecx
  int v112; // r8d
  int v113; // r8d
  unsigned __int64 v114; // rdx
  __int64 *v115; // rcx
  __int64 v116; // rax
  double v118; // [rsp+0h] [rbp-28h]
  double v119; // [rsp+0h] [rbp-28h]
  double v120; // [rsp+0h] [rbp-28h]
  double v121; // [rsp+0h] [rbp-28h]
  double v122; // [rsp+0h] [rbp-28h]
  double v123; // [rsp+0h] [rbp-28h]
  double v124; // [rsp+0h] [rbp-28h]
  double v125; // [rsp+0h] [rbp-28h]
  double v126; // [rsp+0h] [rbp-28h]
  double v127; // [rsp+0h] [rbp-28h]
  double v128; // [rsp+8h] [rbp-20h]
  double v129; // [rsp+8h] [rbp-20h]
  double v130; // [rsp+8h] [rbp-20h]
  double v131; // [rsp+8h] [rbp-20h]
  double v132; // [rsp+8h] [rbp-20h]
  double v133; // [rsp+8h] [rbp-20h]
  double v134; // [rsp+8h] [rbp-20h]
  double v135; // [rsp+8h] [rbp-20h]
  double v136; // [rsp+8h] [rbp-20h]
  double v137; // [rsp+8h] [rbp-20h]
  __int64 v138; // [rsp+10h] [rbp-18h]
  __int64 v139; // [rsp+18h] [rbp-10h]

  v5 = 0;
  v6 = a2;
  v8 = a3;
  v10 = 0.0;
  v139 = a2;
  v11 = 0;
  v138 = a3;
  v12 = a2;
  if ( a2 >= (__int64)a3 )
    goto LABEL_8;
  do
  {
    v13 = *(_QWORD *)(*a1 + 8 * v12);
    v14 = *(double *)(v13 + 8);
    if ( v14 < 0.0 )
      v14 = v14 * (double)-*((_DWORD *)a1 + 4);
    v15 = v14 + 6.755399441055744e15;
    v16 = *(double *)(v13 + 24);
    v11 += LODWORD(v15);
    *(_DWORD *)(v13 + 4) = LODWORD(v15);
    if ( v16 < 0.0 )
      v16 = v16 * (double)-*((_DWORD *)a1 + 4);
    ++v12;
    v10 = v10 + (double)(int)COERCE_UNSIGNED_INT64(v16 + 6.755399441055744e15);
  }
  while ( v12 < a3 );
  if ( v10 <= 0.0 )
LABEL_8:
    v10 = 1.0;
  v17 = a4 - v11;
  if ( a4 - v11 > 0 )
  {
    do
    {
      v18 = 0;
      v19 = 0;
      v20 = v6;
      if ( v6 < v8 )
      {
        if ( v8 - v6 >= 4 )
        {
          v21 = ((unsigned __int64)(v8 - v6 - 4) >> 2) + 1;
          v22 = (__int64 *)(*a1 + 16 + 8 * v6);
          v20 = v6 + 4 * v21;
          do
          {
            v23 = *(v22 - 2);
            v24 = *(double *)(v23 + 24);
            if ( v24 < 0.0 )
              v24 = v24 * (double)-*((_DWORD *)a1 + 4);
            v118 = v24 + 6.755399441055744e15;
            v25 = *(double *)(v23 + 16);
            v128 = (double)(a4 * LODWORD(v118)) / v10 + 6.755399441055744e15;
            if ( v25 < 0.0 )
              v25 = v25 * (double)-*((_DWORD *)a1 + 4);
            v26 = *(_DWORD *)(v23 + 4);
            v27 = v25 + 6.755399441055744e15;
            v28 = v26;
            if ( v26 < SLODWORD(v27) )
              v28 = LODWORD(v27);
            v29 = LODWORD(v128);
            if ( SLODWORD(v128) >= v26 )
            {
              if ( v28 < SLODWORD(v128) )
                v29 = v28;
            }
            else
            {
              v29 = v26;
            }
            v30 = v29 <= v26;
            v31 = v18 + 1;
            v32 = *(v22 - 1);
            if ( v30 )
              v31 = v18;
            v33 = *(double *)(v32 + 24);
            if ( v33 < 0.0 )
              v33 = v33 * (double)-*((_DWORD *)a1 + 4);
            v119 = v33 + 6.755399441055744e15;
            v34 = *(double *)(v32 + 16);
            v129 = (double)(a4 * LODWORD(v119)) / v10 + 6.755399441055744e15;
            if ( v34 < 0.0 )
              v34 = v34 * (double)-*((_DWORD *)a1 + 4);
            v35 = *(_DWORD *)(v32 + 4);
            v36 = v34 + 6.755399441055744e15;
            v37 = v35;
            if ( v35 < SLODWORD(v36) )
              v37 = LODWORD(v36);
            v38 = LODWORD(v129);
            if ( SLODWORD(v129) >= v35 )
            {
              if ( v37 < SLODWORD(v129) )
                v38 = v37;
            }
            else
            {
              v38 = v35;
            }
            v30 = v38 <= v35;
            v39 = v31 + 1;
            v40 = *v22;
            if ( v30 )
              v39 = v31;
            v41 = *(double *)(v40 + 24);
            if ( v41 < 0.0 )
              v41 = v41 * (double)-*((_DWORD *)a1 + 4);
            v120 = v41 + 6.755399441055744e15;
            v42 = *(double *)(v40 + 16);
            v130 = (double)(a4 * LODWORD(v120)) / v10 + 6.755399441055744e15;
            if ( v42 < 0.0 )
              v42 = v42 * (double)-*((_DWORD *)a1 + 4);
            v43 = *(_DWORD *)(v40 + 4);
            v44 = v42 + 6.755399441055744e15;
            v45 = v43;
            if ( v43 < SLODWORD(v44) )
              v45 = LODWORD(v44);
            v46 = LODWORD(v130);
            if ( SLODWORD(v130) >= v43 )
            {
              if ( v45 < SLODWORD(v130) )
                v46 = v45;
            }
            else
            {
              v46 = v43;
            }
            v30 = v46 <= v43;
            v47 = v39 + 1;
            v48 = v22[1];
            if ( v30 )
              v47 = v39;
            v49 = *(double *)(v48 + 24);
            if ( v49 < 0.0 )
              v49 = v49 * (double)-*((_DWORD *)a1 + 4);
            v121 = v49 + 6.755399441055744e15;
            v50 = *(double *)(v48 + 16);
            v131 = (double)(a4 * LODWORD(v121)) / v10 + 6.755399441055744e15;
            if ( v50 < 0.0 )
              v50 = v50 * (double)-*((_DWORD *)a1 + 4);
            v51 = *(_DWORD *)(v48 + 4);
            v52 = v50 + 6.755399441055744e15;
            v53 = v51;
            if ( v51 < SLODWORD(v52) )
              v53 = LODWORD(v52);
            v54 = LODWORD(v131);
            if ( SLODWORD(v131) >= v51 )
            {
              if ( v53 < SLODWORD(v131) )
                v54 = v53;
            }
            else
            {
              v54 = v51;
            }
            v18 = v47 + 1;
            if ( v54 <= v51 )
              v18 = v47;
            v22 += 4;
            --v21;
          }
          while ( v21 );
        }
        if ( v20 < v8 )
        {
          v55 = v8 - v20;
          v56 = *a1 + 8 * v20;
          do
          {
            v57 = *(_QWORD *)v56;
            v58 = *(double *)(*(_QWORD *)v56 + 24LL);
            if ( v58 < 0.0 )
              v58 = v58 * (double)-*((_DWORD *)a1 + 4);
            v122 = v58 + 6.755399441055744e15;
            v59 = *(double *)(v57 + 16);
            v132 = (double)(a4 * LODWORD(v122)) / v10 + 6.755399441055744e15;
            if ( v59 < 0.0 )
              v59 = v59 * (double)-*((_DWORD *)a1 + 4);
            v60 = *(_DWORD *)(v57 + 4);
            v61 = v59 + 6.755399441055744e15;
            v62 = v60;
            if ( v60 < SLODWORD(v61) )
              v62 = LODWORD(v61);
            v63 = LODWORD(v132);
            if ( SLODWORD(v132) >= v60 )
            {
              if ( v62 < SLODWORD(v132) )
                v63 = v62;
            }
            else
            {
              v63 = v60;
            }
            v64 = v18 + 1;
            if ( v63 <= v60 )
              v64 = v18;
            v56 += 8;
            v18 = v64;
            --v55;
          }
          while ( v55 );
        }
      }
      v65 = v6;
      if ( v6 >= v8 )
        break;
      if ( v8 - v6 >= 4 )
      {
        v66 = v8 - 3;
        do
        {
          v67 = *a1;
          v68 = *(_QWORD *)(*a1 + 8 * v65);
          v69 = *(double *)(v68 + 24);
          if ( v69 < 0.0 )
            v69 = v69 * (double)-*((_DWORD *)a1 + 4);
          v133 = v69 + 6.755399441055744e15;
          v70 = *(double *)(v68 + 16);
          v123 = (double)(a4 * LODWORD(v133)) / v10 + 6.755399441055744e15;
          if ( v70 < 0.0 )
            v70 = v70 * (double)-*((_DWORD *)a1 + 4);
          v71 = *(_DWORD *)(v68 + 4);
          v72 = v70 + 6.755399441055744e15;
          v73 = (double)(a4 * LODWORD(v133)) / v10 + 6.755399441055744e15;
          v74 = v71;
          if ( v71 < SLODWORD(v72) )
            v74 = LODWORD(v72);
          if ( SLODWORD(v123) >= v71 )
          {
            if ( v74 < SLODWORD(v123) )
              LODWORD(v73) = v74;
          }
          else
          {
            LODWORD(v73) = *(_DWORD *)(v68 + 4);
          }
          v75 = LODWORD(v73) - v71;
          if ( v75 > 0 )
          {
            v76 = 1;
            if ( v18 > 1 )
              v76 = v18;
            if ( v17 / v76 < v75 )
              v75 = v17 / v76;
            if ( v75 > 0 )
            {
              ++v19;
              --v18;
              *(_DWORD *)(v68 + 4) = v71 + v75;
              v67 = *a1;
              v17 -= v75;
            }
          }
          v77 = *(_QWORD *)(v67 + 8 * v65 + 8);
          v78 = *(double *)(v77 + 24);
          if ( v78 < 0.0 )
            v78 = v78 * (double)-*((_DWORD *)a1 + 4);
          v134 = v78 + 6.755399441055744e15;
          v79 = *(double *)(v77 + 16);
          v124 = (double)(a4 * LODWORD(v134)) / v10 + 6.755399441055744e15;
          if ( v79 < 0.0 )
            v79 = v79 * (double)-*((_DWORD *)a1 + 4);
          v80 = *(_DWORD *)(v77 + 4);
          v81 = v79 + 6.755399441055744e15;
          v82 = (double)(a4 * LODWORD(v134)) / v10 + 6.755399441055744e15;
          v83 = v80;
          if ( v80 < SLODWORD(v81) )
            v83 = LODWORD(v81);
          if ( SLODWORD(v124) >= v80 )
          {
            if ( v83 < SLODWORD(v124) )
              LODWORD(v82) = v83;
          }
          else
          {
            LODWORD(v82) = *(_DWORD *)(v77 + 4);
          }
          v84 = LODWORD(v82) - v80;
          if ( v84 > 0 )
          {
            v85 = 1;
            if ( v18 > 1 )
              v85 = v18;
            if ( v17 / v85 < v84 )
              v84 = v17 / v85;
            if ( v84 > 0 )
            {
              ++v19;
              --v18;
              *(_DWORD *)(v77 + 4) = v80 + v84;
              v67 = *a1;
              v17 -= v84;
            }
          }
          v86 = *(_QWORD *)(v67 + 8 * v65 + 16);
          v87 = *(double *)(v86 + 24);
          if ( v87 < 0.0 )
            v87 = v87 * (double)-*((_DWORD *)a1 + 4);
          v135 = v87 + 6.755399441055744e15;
          v88 = *(double *)(v86 + 16);
          v125 = (double)(a4 * LODWORD(v135)) / v10 + 6.755399441055744e15;
          if ( v88 < 0.0 )
            v88 = v88 * (double)-*((_DWORD *)a1 + 4);
          v89 = *(_DWORD *)(v86 + 4);
          v90 = v88 + 6.755399441055744e15;
          v91 = (double)(a4 * LODWORD(v135)) / v10 + 6.755399441055744e15;
          v92 = v89;
          if ( v89 < SLODWORD(v90) )
            v92 = LODWORD(v90);
          if ( SLODWORD(v125) >= v89 )
          {
            if ( v92 < SLODWORD(v125) )
              LODWORD(v91) = v92;
          }
          else
          {
            LODWORD(v91) = *(_DWORD *)(v86 + 4);
          }
          v93 = LODWORD(v91) - v89;
          if ( v93 > 0 )
          {
            v94 = 1;
            if ( v18 > 1 )
              v94 = v18;
            if ( v17 / v94 < v93 )
              v93 = v17 / v94;
            if ( v93 > 0 )
            {
              ++v19;
              --v18;
              *(_DWORD *)(v86 + 4) = v89 + v93;
              v67 = *a1;
              v17 -= v93;
            }
          }
          v95 = *(_QWORD *)(v67 + 8 * v65 + 24);
          v96 = *(double *)(v95 + 24);
          if ( v96 < 0.0 )
            v96 = v96 * (double)-*((_DWORD *)a1 + 4);
          v136 = v96 + 6.755399441055744e15;
          v97 = *(double *)(v95 + 16);
          v126 = (double)(a4 * LODWORD(v136)) / v10 + 6.755399441055744e15;
          if ( v97 < 0.0 )
            v97 = v97 * (double)-*((_DWORD *)a1 + 4);
          v98 = *(_DWORD *)(v95 + 4);
          v99 = v97 + 6.755399441055744e15;
          v100 = (double)(a4 * LODWORD(v136)) / v10 + 6.755399441055744e15;
          v101 = v98;
          if ( v98 < SLODWORD(v99) )
            v101 = LODWORD(v99);
          if ( SLODWORD(v126) >= v98 )
          {
            if ( v101 < SLODWORD(v126) )
              LODWORD(v100) = v101;
          }
          else
          {
            LODWORD(v100) = *(_DWORD *)(v95 + 4);
          }
          v102 = LODWORD(v100) - v98;
          if ( v102 > 0 )
          {
            v103 = 1;
            if ( v18 > 1 )
              v103 = v18;
            if ( v17 / v103 < v102 )
              v102 = v17 / v103;
            if ( v102 > 0 )
            {
              ++v19;
              --v18;
              *(_DWORD *)(v95 + 4) = v98 + v102;
              v17 -= v102;
            }
          }
          v65 += 4;
        }
        while ( v65 < v66 );
        v8 = v138;
        v6 = v139;
      }
      for ( ; v65 < v8; ++v65 )
      {
        v104 = *(_QWORD *)(*a1 + 8 * v65);
        v105 = *(double *)(v104 + 24);
        if ( v105 < 0.0 )
          v105 = v105 * (double)-*((_DWORD *)a1 + 4);
        v137 = v105 + 6.755399441055744e15;
        v106 = *(double *)(v104 + 16);
        v127 = (double)(a4 * LODWORD(v137)) / v10 + 6.755399441055744e15;
        if ( v106 < 0.0 )
          v106 = v106 * (double)-*((_DWORD *)a1 + 4);
        v107 = *(_DWORD *)(v104 + 4);
        v108 = v106 + 6.755399441055744e15;
        v109 = (double)(a4 * LODWORD(v137)) / v10 + 6.755399441055744e15;
        v110 = v107;
        if ( v107 < SLODWORD(v108) )
          v110 = LODWORD(v108);
        if ( SLODWORD(v127) >= v107 )
        {
          if ( v110 < SLODWORD(v127) )
            LODWORD(v109) = v110;
        }
        else
        {
          LODWORD(v109) = *(_DWORD *)(v104 + 4);
        }
        v111 = LODWORD(v109) - v107;
        if ( v111 > 0 )
        {
          v112 = 1;
          if ( v18 > 1 )
            v112 = v18;
          if ( v17 / v112 < v111 )
            v111 = v17 / v112;
          if ( v111 > 0 )
          {
            ++v19;
            --v18;
            *(_DWORD *)(v104 + 4) = v107 + v111;
            v17 -= v111;
          }
        }
      }
    }
    while ( v19 > 0 && v17 > 0 );
    v5 = 0;
  }
  v113 = 0;
  if ( v6 >= v8 )
    return a5;
  if ( v8 - v6 >= 2 )
  {
    v114 = ((unsigned __int64)(v8 - v6 - 2) >> 1) + 1;
    v115 = (__int64 *)(*a1 + 8 * v6);
    v6 += 2 * v114;
    do
    {
      v116 = *v115;
      v115 += 2;
      v5 += *(_DWORD *)(v116 + 4);
      v113 += *(_DWORD *)(*(v115 - 1) + 4);
      --v114;
    }
    while ( v114 );
  }
  if ( v6 >= v8 )
    return v113 + v5 + a5;
  else
    return v113 + v5 + *(_DWORD *)(*(_QWORD *)(*a1 + 8 * v6) + 4LL) + a5;
}

