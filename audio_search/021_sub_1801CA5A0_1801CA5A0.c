// sub_1801CA5A0 @ 0x1801CA5A0 (RVA 0x1CA5A0)  float_ops=63

// Hidden C++ exception states: #wind=9
__int64 __fastcall sub_1801CA5A0(__int64 a1, __int64 a2, _QWORD *a3, float *a4, float a5)
{
  _BYTE *v9; // rax
  _BYTE *v10; // rcx
  __int64 v11; // rdx
  unsigned int v12; // ecx
  __int64 v13; // rbx
  _DWORD *v14; // r8
  __int64 v15; // rdx
  __int64 v16; // r8
  _DWORD *v17; // r9
  char v18; // dl
  __int64 v19; // rdx
  __int64 v20; // rcx
  float v21; // xmm7_4
  float v22; // xmm8_4
  float v23; // xmm9_4
  float v24; // xmm10_4
  _QWORD *v25; // rbx
  _QWORD *v26; // rax
  int v27; // eax
  __int64 v28; // rdi
  __int64 v29; // rbx
  __int64 v30; // rcx
  double v31; // xmm0_8
  float v32; // xmm6_4
  __int64 v33; // rcx
  double v34; // xmm0_8
  void *v35; // rcx
  void *v36; // rcx
  void *v37; // rcx
  void *v38; // rcx
  int v39; // eax
  __int64 v40; // rbx
  __int64 v41; // rdi
  __int64 v42; // rcx
  double v43; // xmm0_8
  float v44; // xmm6_4
  __int64 v45; // rcx
  double v46; // xmm0_8
  void *v47; // rcx
  void *v48; // rcx
  void *v49; // rcx
  __int64 v50; // rax
  __int64 v51; // rcx
  double v52; // xmm0_8
  void *v53; // rcx
  void *v54; // rcx
  __int64 v55; // rcx
  float *v56; // rcx
  __int128 v57; // xmm0
  __int64 v58; // xmm1_8
  __int64 v59; // rdi
  __int64 v60; // rbx
  __int64 v61; // rcx
  double v62; // xmm0_8
  float v63; // xmm6_4
  __int64 v64; // rcx
  double v65; // xmm0_8
  void *v66; // rcx
  void *v67; // rcx
  void *v68; // rcx
  void *v69; // rcx
  __int64 v70; // rdi
  __int64 v71; // rbx
  __int64 v72; // rcx
  double v73; // xmm0_8
  float v74; // xmm6_4
  __int64 v75; // rcx
  double v76; // xmm0_8
  void *v77; // rcx
  void *v78; // rcx
  void *v79; // rcx
  void *v80; // rcx
  int v81; // eax
  __int64 v82; // rbx
  __int64 v83; // rdi
  __int64 v84; // rcx
  double v85; // xmm0_8
  float v86; // xmm6_4
  __int64 v87; // rcx
  double v88; // xmm0_8
  void *v89; // rcx
  void *v90; // rcx
  void *v91; // rcx
  void *v92; // rcx
  __int64 v93; // rbx
  __int64 v94; // rdi
  __int64 v95; // rcx
  double v96; // xmm0_8
  float v97; // xmm6_4
  __int64 v98; // rcx
  double v99; // xmm0_8
  void *v100; // rcx
  void *v101; // rcx
  void *v102; // rcx
  void *v103; // rdx
  int v104; // ecx
  void *v105; // rcx
  float v106; // xmm11_4
  float v107; // xmm12_4
  float v108; // xmm8_4
  float v109; // xmm10_4
  float v110; // xmm7_4
  float v111; // xmm13_4
  float v112; // xmm2_4
  __int128 v114; // [rsp+28h] [rbp-E0h] BYREF
  __int64 v115; // [rsp+38h] [rbp-D0h]
  void *Block; // [rsp+40h] [rbp-C8h]
  __int64 v117; // [rsp+48h] [rbp-C0h]
  __int64 v118; // [rsp+50h] [rbp-B8h]
  _BYTE *v119; // [rsp+58h] [rbp-B0h] BYREF
  __int64 v120; // [rsp+60h] [rbp-A8h] BYREF
  __int64 v121; // [rsp+68h] [rbp-A0h] BYREF
  __int64 v122; // [rsp+70h] [rbp-98h] BYREF
  __int64 v123; // [rsp+78h] [rbp-90h] BYREF
  __int64 v124; // [rsp+80h] [rbp-88h] BYREF
  __int64 v125; // [rsp+88h] [rbp-80h] BYREF
  __int64 v126; // [rsp+90h] [rbp-78h] BYREF
  __int64 v127; // [rsp+98h] [rbp-70h] BYREF
  __int64 v128; // [rsp+A0h] [rbp-68h] BYREF
  __int64 v129; // [rsp+A8h] [rbp-60h] BYREF
  __int64 v130; // [rsp+B0h] [rbp-58h] BYREF
  __int64 v131; // [rsp+B8h] [rbp-50h] BYREF
  __int64 v132; // [rsp+C0h] [rbp-48h] BYREF
  __int64 v133; // [rsp+C8h] [rbp-40h] BYREF
  __int128 v134; // [rsp+D0h] [rbp-38h] BYREF
  __int64 v135; // [rsp+E0h] [rbp-28h]
  __int64 v136; // [rsp+E8h] [rbp-20h] BYREF
  __int64 v137; // [rsp+F0h] [rbp-18h] BYREF
  __int64 v138; // [rsp+F8h] [rbp-10h] BYREF
  __int64 v139; // [rsp+100h] [rbp-8h] BYREF
  __int64 v140; // [rsp+108h] [rbp+0h] BYREF
  __int64 v141; // [rsp+110h] [rbp+8h] BYREF
  __int64 v142; // [rsp+118h] [rbp+10h] BYREF
  __int64 v143; // [rsp+120h] [rbp+18h] BYREF
  __int64 v144; // [rsp+128h] [rbp+20h] BYREF
  __int64 v145; // [rsp+130h] [rbp+28h] BYREF
  __int64 v146; // [rsp+138h] [rbp+30h] BYREF
  __int64 v147; // [rsp+140h] [rbp+38h] BYREF
  __int64 v148; // [rsp+148h] [rbp+40h] BYREF
  unsigned int v149; // [rsp+150h] [rbp+48h]
  double v150; // [rsp+158h] [rbp+50h]
  int v151; // [rsp+160h] [rbp+58h] BYREF
  float *v152; // [rsp+168h] [rbp+60h]
  __int64 v153; // [rsp+170h] [rbp+68h]
  __int128 v154; // [rsp+178h] [rbp+70h]
  __int64 v155; // [rsp+188h] [rbp+80h]
  _QWORD v156[4]; // [rsp+190h] [rbp+88h] BYREF
  __int64 v157; // [rsp+1B0h] [rbp+A8h]

  v156[3] = -2;
  v114 = 0;
  LOBYTE(v115) = 0;
  Block = nullptr;
  v117 = 0;
  sub_1801C93A0(&v119, a3);
  v9 = v119;
  if ( *v119 )
  {
    v156[0] = a1;
    v156[1] = &v114;
    sub_1802418B0(a1 + 8, &v119, v156);
    v9 = v119;
  }
  v10 = v9 - 16;
  if ( (*((_DWORD *)v9 - 4) & 0x30000000) == 0 && !_InterlockedExchangeAdd((volatile signed __int32 *)v10, 0xFFFFFFFF) )
    j_j_free_0(v10);
  sub_1801CA2A0(a1, &v114, a3);
  v12 = HIDWORD(v117);
  v13 = SHIDWORD(v117);
  if ( !HIDWORD(v117) )
  {
    sub_180832420(&v114, v11, (unsigned int)dword_180C96488);
    v16 = (unsigned int)dword_180C96488;
    goto LABEL_15;
  }
  v14 = Block;
  if ( *(double *)Block > 0.0 )
  {
    v149 = *((_DWORD *)Block + 2);
    sub_180832420(&v114, v11, v149);
    v12 = HIDWORD(v117);
    v14 = Block;
  }
  v15 = v13;
  if ( (int)v13 - 1 >= v12 )
    goto LABEL_13;
  if ( *(double *)&v14[4 * v13 - 4] < 1.0 )
  {
    if ( (int)v13 - 1 < v12 )
    {
      v15 = 2 * v13;
      v16 = (unsigned int)v14[4 * v13 - 2];
LABEL_15:
      sub_180832420(&v114, v15, v16);
      v14 = Block;
      v12 = HIDWORD(v117);
      goto LABEL_16;
    }
LABEL_13:
    v16 = 0;
    goto LABEL_15;
  }
LABEL_16:
  if ( a5 < 1.0 )
  {
    v17 = &v14[4 * v12];
    if ( v14 != v17 )
    {
      v14 += 2;
      do
      {
        LODWORD(v118) = *v14;
        v150 = (float)((float)BYTE3(v118) * a5) + 6.755399441055744e15;
        v18 = -1;
        if ( SLODWORD(v150) < 255 )
          v18 = LOBYTE(v150);
        BYTE3(v118) = v18;
        *v14 = v118;
        v14 += 4;
      }
      while ( v14 - 2 != v17 );
    }
  }
  LOBYTE(v115) = sub_1807488E0(*a3, "radialGradient", v14);
  v21 = *(float *)(a1 + 32);
  v22 = *(float *)(a1 + 36);
  v23 = 0.0;
  v24 = 0.0;
  v25 = *(_QWORD **)(*a3 + 16LL);
  if ( v25 )
  {
    while ( 1 )
    {
      v157 = v25[1];
      if ( !(unsigned int)sub_1801052D0(v157, "gradientUnits") )
        break;
      v25 = (_QWORD *)*v25;
      if ( !v25 )
        goto LABEL_25;
    }
    v26 = v25 + 2;
  }
  else
  {
LABEL_25:
    v26 = (_QWORD *)sub_180748770(v20, v19);
  }
  v27 = sub_1800FC570(*v26, "userSpaceOnUse");
  if ( v27 )
  {
    v24 = a4[6];
    v22 = a4[7] - v24;
    v23 = a4[4];
    v21 = a4[5] - v23;
  }
  if ( (_BYTE)v115 )
  {
    if ( v27 )
    {
      sub_1800FDCD0(&v124, "50%");
      sub_1800FDCD0(&v123, "50%");
      v40 = sub_180748530(*a3, &v139, "cy", &v124, v114, *((_QWORD *)&v114 + 1));
      v41 = sub_180748530(*a3, &v138, "cx", &v123, v114, *((_QWORD *)&v114 + 1));
      v43 = sub_1801CD750(v42, v40);
      v44 = (float)(*(float *)&v43 * v22) + v24;
      v46 = sub_1801CD750(v45, v41);
      *(float *)&v114 = (float)(*(float *)&v46 * v21) + v23;
      *((float *)&v114 + 1) = v44;
      v47 = (void *)(v138 - 16);
      if ( (*(_DWORD *)(v138 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v47, 0xFFFFFFFF) )
      {
        j_j_free_0(v47);
      }
      v48 = (void *)(v139 - 16);
      if ( (*(_DWORD *)(v139 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v48, 0xFFFFFFFF) )
      {
        j_j_free_0(v48);
      }
      v49 = (void *)(v123 - 16);
      if ( (*(_DWORD *)(v123 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v49, 0xFFFFFFFF) )
      {
        j_j_free_0(v49);
      }
      v38 = (void *)(v124 - 16);
      v39 = *(_DWORD *)(v124 - 16);
    }
    else
    {
      sub_1800FDCD0(&v122, "50%");
      sub_1800FDCD0(&v121, "50%");
      v28 = sub_180748530(*a3, &v137, "cy", &v122, v114, *((_QWORD *)&v114 + 1));
      v29 = sub_180748530(*a3, &v136, "cx", &v121, v114, *((_QWORD *)&v114 + 1));
      v31 = sub_1801CD750(v30, v28);
      v32 = *(float *)&v31 + v24;
      v34 = sub_1801CD750(v33, v29);
      *(float *)&v114 = *(float *)&v34 + v23;
      *((float *)&v114 + 1) = v32;
      v35 = (void *)(v136 - 16);
      if ( (*(_DWORD *)(v136 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v35, 0xFFFFFFFF) )
      {
        j_j_free_0(v35);
      }
      v36 = (void *)(v137 - 16);
      if ( (*(_DWORD *)(v137 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v36, 0xFFFFFFFF) )
      {
        j_j_free_0(v36);
      }
      v37 = (void *)(v121 - 16);
      if ( (*(_DWORD *)(v121 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v37, 0xFFFFFFFF) )
      {
        j_j_free_0(v37);
      }
      v38 = (void *)(v122 - 16);
      v39 = *(_DWORD *)(v122 - 16);
    }
    if ( (v39 & 0x30000000) == 0 && !_InterlockedExchangeAdd((volatile signed __int32 *)v38, 0xFFFFFFFF) )
      j_j_free_0(v38);
    sub_1800FDCD0(&v125, "50%");
    v50 = sub_180748530(*a3, &v140, "r", &v125, v114, *((_QWORD *)&v114 + 1));
    v52 = sub_1801CD750(v51, v50);
    v53 = (void *)(v140 - 16);
    if ( (*(_DWORD *)(v140 - 16) & 0x30000000) == 0
      && !_InterlockedExchangeAdd((volatile signed __int32 *)v53, 0xFFFFFFFF) )
    {
      j_j_free_0(v53);
    }
    v54 = (void *)(v125 - 16);
    if ( (*(_DWORD *)(v125 - 16) & 0x30000000) == 0
      && !_InterlockedExchangeAdd((volatile signed __int32 *)v54, 0xFFFFFFFF) )
    {
      j_j_free_0(v54);
    }
    *((float *)&v114 + 2) = *(float *)&v52 + *(float *)&v114;
    *((float *)&v114 + 3) = *((float *)&v114 + 1) + 0.0;
  }
  else
  {
    if ( v27 )
    {
      sub_1800FDCD0(&v131, "0%");
      sub_1800FDCD0(&v130, "0%");
      v82 = sub_180748530(*a3, &v146, "y1", &v131, v114, *((_QWORD *)&v114 + 1));
      v83 = sub_180748530(*a3, &v145, "x1", &v130, v114, *((_QWORD *)&v114 + 1));
      v85 = sub_1801CD750(v84, v82);
      v86 = (float)(*(float *)&v85 * v22) + v24;
      v88 = sub_1801CD750(v87, v83);
      *(float *)&v114 = (float)(*(float *)&v88 * v21) + v23;
      *((float *)&v114 + 1) = v86;
      v89 = (void *)(v145 - 16);
      if ( (*(_DWORD *)(v145 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v89, 0xFFFFFFFF) )
      {
        j_j_free_0(v89);
      }
      v90 = (void *)(v146 - 16);
      if ( (*(_DWORD *)(v146 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v90, 0xFFFFFFFF) )
      {
        j_j_free_0(v90);
      }
      v91 = (void *)(v130 - 16);
      if ( (*(_DWORD *)(v130 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v91, 0xFFFFFFFF) )
      {
        j_j_free_0(v91);
      }
      v92 = (void *)(v131 - 16);
      if ( (*(_DWORD *)(v131 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v92, 0xFFFFFFFF) )
      {
        j_j_free_0(v92);
      }
      sub_1800FDCD0(&v133, "0%");
      sub_1800FDCD0(&v132, "100%");
      v93 = sub_180748530(*a3, &v148, "y2", &v133, v114, *((_QWORD *)&v114 + 1));
      v94 = sub_180748530(*a3, &v147, "x2", &v132, v114, *((_QWORD *)&v114 + 1));
      v96 = sub_1801CD750(v95, v93);
      v97 = (float)(*(float *)&v96 * v22) + v24;
      v99 = sub_1801CD750(v98, v94);
      *((float *)&v114 + 2) = (float)(*(float *)&v99 * v21) + v23;
      *((float *)&v114 + 3) = v97;
      v100 = (void *)(v147 - 16);
      if ( (*(_DWORD *)(v147 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v100, 0xFFFFFFFF) )
      {
        j_j_free_0(v100);
      }
      v101 = (void *)(v148 - 16);
      if ( (*(_DWORD *)(v148 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v101, 0xFFFFFFFF) )
      {
        j_j_free_0(v101);
      }
      v102 = (void *)(v132 - 16);
      if ( (*(_DWORD *)(v132 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v102, 0xFFFFFFFF) )
      {
        j_j_free_0(v102);
      }
      v80 = (void *)(v133 - 16);
      v81 = *(_DWORD *)(v133 - 16);
    }
    else
    {
      sub_1800FDCD0(&v127, "0%");
      sub_1800FDCD0(&v126, "0%");
      v59 = sub_180748530(*a3, &v142, "y1", &v127, v114, *((_QWORD *)&v114 + 1));
      v60 = sub_180748530(*a3, &v141, "x1", &v126, v114, *((_QWORD *)&v114 + 1));
      v62 = sub_1801CD750(v61, v59);
      v63 = *(float *)&v62 + v24;
      v65 = sub_1801CD750(v64, v60);
      *(float *)&v114 = *(float *)&v65 + v23;
      *((float *)&v114 + 1) = v63;
      v66 = (void *)(v141 - 16);
      if ( (*(_DWORD *)(v141 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v66, 0xFFFFFFFF) )
      {
        j_j_free_0(v66);
      }
      v67 = (void *)(v142 - 16);
      if ( (*(_DWORD *)(v142 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v67, 0xFFFFFFFF) )
      {
        j_j_free_0(v67);
      }
      v68 = (void *)(v126 - 16);
      if ( (*(_DWORD *)(v126 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v68, 0xFFFFFFFF) )
      {
        j_j_free_0(v68);
      }
      v69 = (void *)(v127 - 16);
      if ( (*(_DWORD *)(v127 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v69, 0xFFFFFFFF) )
      {
        j_j_free_0(v69);
      }
      sub_1800FDCD0(&v129, "0%");
      sub_1800FDCD0(&v128, "100%");
      v70 = sub_180748530(*a3, &v144, "y2", &v129, v114, *((_QWORD *)&v114 + 1));
      v71 = sub_180748530(*a3, &v143, "x2", &v128, v114, *((_QWORD *)&v114 + 1));
      v73 = sub_1801CD750(v72, v70);
      v74 = *(float *)&v73 + v24;
      v76 = sub_1801CD750(v75, v71);
      *((float *)&v114 + 2) = *(float *)&v76 + v23;
      *((float *)&v114 + 3) = v74;
      v77 = (void *)(v143 - 16);
      if ( (*(_DWORD *)(v143 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v77, 0xFFFFFFFF) )
      {
        j_j_free_0(v77);
      }
      v78 = (void *)(v144 - 16);
      if ( (*(_DWORD *)(v144 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v78, 0xFFFFFFFF) )
      {
        j_j_free_0(v78);
      }
      v79 = (void *)(v128 - 16);
      if ( (*(_DWORD *)(v128 - 16) & 0x30000000) == 0
        && !_InterlockedExchangeAdd((volatile signed __int32 *)v79, 0xFFFFFFFF) )
      {
        j_j_free_0(v79);
      }
      v80 = (void *)(v129 - 16);
      v81 = *(_DWORD *)(v129 - 16);
    }
    if ( (v81 & 0x30000000) == 0 && !_InterlockedExchangeAdd((volatile signed __int32 *)v80, 0xFFFFFFFF) )
      j_j_free_0(v80);
    if ( *(float *)&v114 == *((float *)&v114 + 2) && *((float *)&v114 + 1) == *((float *)&v114 + 3) )
    {
      v103 = Block;
      if ( (unsigned int)(HIDWORD(v117) - 1) >= HIDWORD(v117) )
        v104 = 0;
      else
        v104 = *((_DWORD *)Block + 4 * SHIDWORD(v117) - 2);
      *(_DWORD *)a2 = v104;
      *(_QWORD *)(a2 + 8) = 0;
      *(_QWORD *)(a2 + 16) = 0;
      *(_QWORD *)(a2 + 24) = 1065353216;
      *(_QWORD *)(a2 + 32) = 0;
      *(_QWORD *)(a2 + 40) = 1065353216;
      v105 = v103;
      goto LABEL_121;
    }
  }
  sub_18082EB60(&v151, &v114);
  v55 = *(_QWORD *)sub_1807485D0(*a3, "gradientTransform");
  v120 = v55;
  if ( (*(_DWORD *)(v55 - 16) & 0x30000000) == 0 )
    _InterlockedExchangeAdd((volatile signed __int32 *)(v55 - 16), 1u);
  sub_1801CF260(&v134, &v120);
  v56 = v152;
  if ( (_BYTE)v115 )
  {
    v57 = v134;
    v154 = v134;
    v58 = v135;
    v155 = v135;
  }
  else
  {
    v106 = (float)((float)((float)(*((float *)&v114 + 3) - *((float *)&v114 + 1)) * *((float *)&v134 + 3))
                 + (float)((float)(*(float *)&v114 - *((float *)&v114 + 2)) * *(float *)&v135))
         + 0.0;
    v107 = (float)((float)((float)(*((float *)&v114 + 3) - *((float *)&v114 + 1)) * *(float *)&v134)
                 + (float)((float)(*(float *)&v114 - *((float *)&v114 + 2)) * *((float *)&v134 + 1)))
         + 0.0;
    v108 = (float)((float)(*((float *)&v114 + 1) * *(float *)&v135) + (float)(*(float *)&v114 * *((float *)&v134 + 3)))
         + *((float *)&v135 + 1);
    v109 = (float)((float)(*((float *)&v114 + 1) * *((float *)&v134 + 1)) + (float)(*(float *)&v114 * *(float *)&v134))
         + *((float *)&v134 + 2);
    v110 = (float)((float)(*((float *)&v114 + 3) * *(float *)&v135)
                 + (float)(*((float *)&v114 + 2) * *((float *)&v134 + 3)))
         + *((float *)&v135 + 1);
    v111 = (float)((float)(*((float *)&v114 + 3) * *((float *)&v134 + 1))
                 + (float)(*((float *)&v114 + 2) * *(float *)&v134))
         + *((float *)&v134 + 2);
    v112 = (float)((float)((float)(v110 - v108) * v106) + (float)(v107 * (float)(v111 - v109)))
         / (float)((float)(v106 * v106) + (float)(v107 * v107));
    *v152 = v109;
    v56[1] = v108;
    v56[2] = v111 - (float)(v107 * v112);
    v56[3] = v110 - (float)(v106 * v112);
    v58 = v155;
    v57 = v154;
  }
  *(_DWORD *)a2 = v151;
  v152 = nullptr;
  *(_QWORD *)(a2 + 8) = v56;
  *(_QWORD *)(a2 + 16) = v153;
  v153 = 0;
  *(_OWORD *)(a2 + 24) = v57;
  *(_QWORD *)(a2 + 40) = v58;
  sub_18082E840(&v151);
  v105 = Block;
LABEL_121:
  HIDWORD(v117) = 0;
  free(v105);
  return a2;
}

