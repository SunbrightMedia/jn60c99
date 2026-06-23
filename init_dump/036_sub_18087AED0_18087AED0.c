// sub_18087AED0  @ 0x18087AED0  (RVA 0x87AED0)  floats=18
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE5064  dword_180AE5064 = 0.75
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE50F8  dword_180AE50F8 = 1.2999999523162842
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE52F4  dword_180AE52F4 = 5.0
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE5470  dword_180AE5470 = 10000.0
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE54C0  dword_180AE54C0 = -0.0
//   0x180AE5570  xmmword_180AE5570 = 1.0
//   0x180AE57C0  xmmword_180AE57C0 = -0.0

// Hidden C++ exception states: #wind=5
__int64 __fastcall sub_18087AED0(
        __int64 a1,
        __int64 a2,
        _DWORD *a3,
        char a4,
        char a5,
        char a6,
        char a7,
        char a8,
        __int64 a9,
        __int64 *a10,
        __int64 a11,
        unsigned int *a12)
{
  unsigned int *v14; // rax
  int v15; // r14d
  int v16; // r12d
  int v17; // esi
  int v18; // ebx
  int v19; // edi
  int v20; // r12d
  int v21; // edi
  __int64 result; // rax
  __int64 v23; // rsi
  unsigned int v24; // ecx
  int v25; // ebx
  int v26; // r14d
  int v27; // r13d
  unsigned int *v28; // rax
  __int64 v29; // rdx
  float v30; // xmm1_4
  char v31; // dl
  int v32; // ecx
  int v33; // ecx
  int v34; // eax
  int v35; // ebx
  int v36; // edi
  float v37; // xmm7_4
  float v38; // xmm0_4
  float v39; // xmm10_4
  float v40; // xmm6_4
  __int64 v41; // rcx
  __int64 (__fastcall *v42)(); // r8
  __int64 v43; // rcx
  __int64 (__fastcall *v44)(); // rdx
  _QWORD *v45; // rcx
  __int64 (__fastcall *v46)(); // r8
  int v47; // ecx
  int v48; // eax
  int v49; // ebx
  float v50; // xmm9_4
  __int64 v51; // rax
  __int64 v52; // rax
  __int64 v53; // r8
  int v54; // eax
  int v55; // r8d
  int v56; // r9d
  float *v57; // rcx
  char *v58; // rdx
  float v59; // xmm0_4
  __int64 v60; // rax
  double v61; // xmm0_8
  float v62; // xmm9_4
  void (__fastcall ***v63)(_QWORD, __int64); // rcx
  int v64; // r8d
  int v65; // edx
  int v66; // eax
  int v67; // ebx
  __int64 v68; // rax
  float v69; // xmm0_4
  __int64 v70; // rcx
  __int64 (__fastcall *v71)(); // r8
  __int64 (__fastcall *v72)(); // r8
  __int64 v73; // rcx
  __int64 v74; // rcx
  void (*v75)(void); // rdx
  _QWORD *v76; // rcx
  __int64 (__fastcall *v77)(); // r8
  __m128 v78; // xmm2
  __m128 v79; // xmm2
  __m128 v80; // xmm2
  __int64 (__fastcall ***v81)(_QWORD, __int64); // rcx
  __int64 (__fastcall ***v82)(_QWORD, __int64); // rcx
  signed __int32 v83; // r14d
  __int64 v84; // rcx
  __int64 v85; // rcx
  __int64 v86; // rcx
  __int64 v87; // [rsp+48h] [rbp-C0h] BYREF
  __int128 v88; // [rsp+58h] [rbp-B0h]
  __int64 v89; // [rsp+68h] [rbp-A0h] BYREF
  unsigned int v90; // [rsp+70h] [rbp-98h]
  int v91; // [rsp+74h] [rbp-94h]
  int v92; // [rsp+78h] [rbp-90h] BYREF
  int v93; // [rsp+80h] [rbp-88h]
  void *v94; // [rsp+88h] [rbp-80h] BYREF
  __int64 v95; // [rsp+90h] [rbp-78h]
  float v96; // [rsp+98h] [rbp-70h]
  float v97; // [rsp+9Ch] [rbp-6Ch]
  float v98; // [rsp+A0h] [rbp-68h]
  float v99; // [rsp+A4h] [rbp-64h]
  char v100; // [rsp+A8h] [rbp-60h]
  int v101; // [rsp+B0h] [rbp-58h] BYREF
  __int64 v102; // [rsp+B4h] [rbp-54h]
  __int128 v103; // [rsp+C8h] [rbp-40h]
  float v104[4]; // [rsp+D8h] [rbp-30h] BYREF
  char v105[4]; // [rsp+E8h] [rbp-20h] BYREF
  char v106[4]; // [rsp+ECh] [rbp-1Ch] BYREF
  char v107[4]; // [rsp+F0h] [rbp-18h] BYREF
  char v108[4]; // [rsp+F4h] [rbp-14h] BYREF
  int v109; // [rsp+F8h] [rbp-10h]
  double v110; // [rsp+100h] [rbp-8h]
  double v111; // [rsp+108h] [rbp+0h]
  double v112; // [rsp+110h] [rbp+8h]
  double v113; // [rsp+118h] [rbp+10h]
  __int64 v114; // [rsp+120h] [rbp+18h] BYREF
  __m128 v115; // [rsp+128h] [rbp+20h]
  void *Block; // [rsp+138h] [rbp+30h] BYREF
  int v117; // [rsp+144h] [rbp+3Ch]
  __int128 v118; // [rsp+160h] [rbp+58h] BYREF
  __int64 v119; // [rsp+170h] [rbp+68h]
  __int128 v120; // [rsp+178h] [rbp+70h] BYREF
  float v121; // [rsp+188h] [rbp+80h]
  float v122; // [rsp+18Ch] [rbp+84h]
  __int128 v123; // [rsp+198h] [rbp+90h] BYREF
  __m128 v124; // [rsp+1A8h] [rbp+A0h] BYREF
  __int128 v125; // [rsp+1B8h] [rbp+B0h] BYREF
  __int64 v126; // [rsp+1C8h] [rbp+C0h]
  _BYTE v127[24]; // [rsp+1D0h] [rbp+C8h] BYREF
  char v128[16]; // [rsp+1E8h] [rbp+E0h] BYREF
  char v129[160]; // [rsp+1F8h] [rbp+F0h] BYREF
  unsigned int v131; // [rsp+2F0h] [rbp+1E8h]

  v126 = -2;
  v14 = a12;
  if ( a4 )
  {
    v15 = *a3 + 5;
    v16 = 0;
    v17 = 0;
    if ( a3[2] - 10 > 0 )
      v17 = a3[2] - 10;
    if ( (int)a3[3] > 0 )
      v16 = a3[3];
    v110 = (float)((float)((float)v16 * 0.5) - 0.5) + 6.755399441055744e15;
    v18 = LODWORD(v110);
    if ( v16 < SLODWORD(v110) )
      v18 = v16;
    v19 = v18 + a3[1];
    v131 = *(_DWORD *)sub_180899F20(a1 - 64, v105, 16778752);
    v20 = v16 - v18;
    HIBYTE(v131) = 76;
    sub_180831D50(a2, v131);
    *(_QWORD *)&v103 = __PAIR64__(v19, v15);
    DWORD2(v103) = v17;
    v21 = 1;
    if ( v20 < 1 )
      v21 = v20;
    HIDWORD(v103) = v21;
    v125 = v103;
    return (*(__int64 (__fastcall **)(_QWORD, __int128 *, _QWORD))(**(_QWORD **)(a2 + 8) + 168LL))(
             *(_QWORD *)(a2 + 8),
             &v125,
             0);
  }
  v23 = a1 - 64;
  if ( !a12 )
    v14 = (unsigned int *)sub_180899F20(a1 - 64, v106, 16778752);
  v24 = *v14;
  v25 = 0;
  if ( a3[2] - 2 > 0 )
    v25 = a3[2] - 2;
  v26 = 0;
  if ( a3[3] - 2 > 0 )
    v26 = a3[3] - 2;
  v91 = a3[1] + 1;
  v27 = *a3 + 1;
  *(_QWORD *)&v88 = __PAIR64__(v91, v27);
  *((_QWORD *)&v88 + 1) = __PAIR64__(v26, v25);
  if ( !a6 )
  {
    if ( a5 )
    {
      v30 = 1.0;
LABEL_23:
      v90 = v24;
      v111 = (float)((float)HIBYTE(v24) * v30) + 6.755399441055744e15;
      v31 = -1;
      if ( SLODWORD(v111) < 255 )
        v31 = LOBYTE(v111);
      HIBYTE(v90) = v31;
      v29 = v90;
      goto LABEL_26;
    }
LABEL_22:
    v30 = 0.5;
    goto LABEL_23;
  }
  if ( !a5 )
    goto LABEL_22;
  v28 = (unsigned int *)sub_180899F20(v23, v107, 16779520);
  sub_180831D50(a2, *v28);
  v120 = v88;
  (*(void (__fastcall **)(_QWORD, __int128 *, _QWORD))(**(_QWORD **)(a2 + 8) + 168LL))(*(_QWORD *)(a2 + 8), &v120, 0);
  v29 = *(unsigned int *)sub_180899F20(v23, v108, 16779264);
LABEL_26:
  sub_180831D50(a2, v29);
  v32 = 5;
  if ( a3[2] / 20 < 5 )
    v32 = a3[2] / 20;
  v33 = -v32;
  v34 = v25 + 2 * v33;
  v35 = 0;
  if ( v34 > 0 )
    v35 = v34;
  v36 = 0;
  if ( v26 > 0 )
    v36 = v26;
  v93 = v36;
  LODWORD(v88) = v27 - v33;
  HIDWORD(v88) = v36;
  (*(void (__fastcall **)(__int64, __int64 *))(*(_QWORD *)a1 + 32LL))(a1, &v89);
  v37 = (float)v36 / 1.3;
  v38 = *(float *)(v89 + 40);
  v39 = 0.1;
  if ( v38 > v37 )
  {
    v40 = v37 >= 0.1 ? fminf(10000.0, v37) : 0.1;
    if ( v38 != v40 )
    {
      sub_1807D2580(&v89);
      *(float *)(v89 + 40) = v40;
      v41 = *(_QWORD *)(v89 + 16);
      if ( v41 )
      {
        v42 = *(__int64 (__fastcall **)())(*(_QWORD *)v41 + 8LL);
        if ( v42 != sub_180155710 && !((unsigned __int8 (__fastcall *)(__int64, __int64 *))v42)(v41, &v89) )
        {
          v86 = *(_QWORD *)(v89 + 16);
          *(_QWORD *)(v89 + 16) = 0;
          if ( v86 )
          {
            if ( _InterlockedExchangeAdd((volatile signed __int32 *)(v86 + 8), 0xFFFFFFFF) == 1 )
              (**(void (__fastcall ***)(__int64, __int64))v86)(v86, 1);
          }
        }
      }
    }
  }
  if ( *(_BYTE *)(a2 + 16) )
  {
    *(_BYTE *)(a2 + 16) = 0;
    v43 = *(_QWORD *)(a2 + 8);
    v44 = *(__int64 (__fastcall **)())(*(_QWORD *)v43 + 104LL);
    if ( v44 == sub_180163CA0 )
      sub_18016CBD0(v43 + 8, v44, sub_180163CA0);
    else
      ((void (__fastcall *)(__int64, __int64 (__fastcall *)(), __int64 (__fastcall *)()))v44)(v43, v44, sub_180163CA0);
  }
  v45 = *(_QWORD **)(a2 + 8);
  v46 = *(__int64 (__fastcall **)())(*v45 + 208LL);
  if ( v46 == sub_1801637B0 )
    sub_1808322E0(v45[1] + 112LL, &v89);
  else
    ((void (__fastcall *)(_QWORD *, __int64 *))v46)(v45, &v89);
  v112 = v37 + 6.755399441055744e15;
  v47 = v88;
  v48 = LODWORD(v112);
  if ( v35 < SLODWORD(v112) )
    v48 = v35;
  LODWORD(v88) = v48 + v88;
  v49 = v35 - v48;
  DWORD2(v88) = v49;
  v50 = (float)v48;
  v121 = (float)v47;
  v122 = (float)v91;
  if ( a11 )
  {
    v104[0] = (float)v47;
    v104[1] = (float)v91;
    v104[2] = (float)v48;
    v104[3] = (float)v36;
    v92 = 292;
    v51 = (*(__int64 (__fastcall **)(__int64, char *))(*(_QWORD *)a11 + 360LL))(a11, v128);
    v52 = sub_1808325C0(&v92, v129, v51, v104);
    sub_1808BA6D0(a11, a2, v53, v52);
    v113 = (float)(v37 * 0.5) + 6.755399441055744e15;
    v54 = LODWORD(v113);
    if ( v49 < SLODWORD(v113) )
      v54 = v49;
    LODWORD(v88) = v54 + v88;
    v49 -= v54;
    DWORD2(v88) = v49;
  }
  else if ( a7 )
  {
    (*(void (__fastcall **)(__int64, void **))(*(_QWORD *)v23 + 96LL))(v23, &Block);
    ((void (__fastcall *)(_DWORD, _DWORD, _DWORD, _DWORD, _DWORD, _DWORD, char, _DWORD))sub_180828260)(
      (unsigned int)&Block,
      (unsigned int)v127,
      v55,
      v56,
      fmaxf((float)((float)-(float)(v50 / 5.0) - (float)(v50 / 5.0)) + v50, 0.0),
      fmaxf((float)v36 + -0.0, 0.0),
      1,
      36);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
    {
      v57 = (float *)Block;
      v58 = (char *)Block + 4 * v117;
      if ( Block != v58 )
      {
        do
        {
          v59 = *v57;
          if ( *v57 == 100002.0 )
          {
            v57 += 2;
          }
          else if ( v59 == 100001.0 || v59 == 100003.0 || v59 == 100004.0 )
          {
            (*(void (__fastcall **)(_QWORD, void **, _BYTE *))(**(_QWORD **)(a2 + 8) + 184LL))(
              *(_QWORD *)(a2 + 8),
              &Block,
              v127);
            break;
          }
          ++v57;
        }
        while ( v57 != (float *)v58 );
      }
    }
    v117 = 0;
    free(Block);
  }
  if ( a8 )
  {
    v60 = (*(__int64 (__fastcall **)(__int64, __int64 *))(*(_QWORD *)a1 + 32LL))(a1, &v114);
    v61 = sub_1807D1560(v60);
    v62 = *(float *)&v61 * 0.60000002;
    v63 = (void (__fastcall ***)(_QWORD, __int64))v114;
    if ( v114 )
    {
      if ( _InterlockedExchangeAdd((volatile signed __int32 *)(v114 + 8), 0xFFFFFFFF) == 1 )
        (**v63)(v63, 1);
      v49 = DWORD2(v88);
    }
    v64 = (int)v62;
    if ( v49 < (int)v62 )
      v64 = v49;
    v65 = v49 + v88 - v64;
    v49 -= v64;
    v94 = nullptr;
    v95 = 0;
    v100 = 1;
    v97 = (float)v65;
    v96 = (float)v65;
    v99 = (float)(v93 / 2 + v91) - (float)(v62 * 0.5);
    v98 = v99;
    sub_180179780(&v94, &unk_180AA33E4);
    sub_18082B140(&v94);
    sub_18082B140(&v94);
    v118 = xmmword_180AE5570;
    v119 = 1065353216;
    v101 = 0x40000000;
    v102 = 0;
    sub_180830CE0(a2, &v94, &v101, &v118);
    HIDWORD(v95) = 0;
    free(v94);
  }
  v66 = 3;
  if ( v49 < 3 )
    v66 = v49;
  v67 = v49 - v66;
  DWORD2(v88) = v67;
  v123 = v88;
  v109 = 33;
  sub_180821B50(a2, a9, (unsigned int)&v123, 33, 1, 0);
  result = *a10;
  if ( *(_BYTE *)*a10 )
  {
    v68 = v89;
    v87 = v89;
    if ( v89 )
    {
      _InterlockedExchangeAdd((volatile signed __int32 *)(v89 + 8), 1u);
      v67 = DWORD2(v88);
      v68 = v87;
    }
    v69 = *(float *)(v68 + 40) * 0.75;
    if ( v69 >= 0.1 )
      v39 = fminf(10000.0, v69);
    if ( *(float *)(v68 + 40) != v39 )
    {
      sub_1807D2580(&v87);
      *(float *)(v87 + 40) = v39;
      v70 = *(_QWORD *)(v87 + 16);
      if ( v70 )
      {
        v71 = *(__int64 (__fastcall **)())(*(_QWORD *)v70 + 8LL);
        if ( v71 != sub_180155710 && !((unsigned __int8 (__fastcall *)(__int64, __int64 *))v71)(v70, &v87) )
        {
          v84 = *(_QWORD *)(v87 + 16);
          *(_QWORD *)(v87 + 16) = 0;
          if ( v84 )
          {
            if ( _InterlockedExchangeAdd((volatile signed __int32 *)(v84 + 8), 0xFFFFFFFF) == 1 )
              (**(void (__fastcall ***)(__int64, __int64))v84)(v84, 1);
            v67 = DWORD2(v88);
          }
        }
      }
    }
    sub_1807D2580(&v87);
    *(_DWORD *)(v87 + 44) = 1064514355;
    v73 = *(_QWORD *)(v87 + 16);
    if ( v73 )
    {
      v72 = *(__int64 (__fastcall **)())(*(_QWORD *)v73 + 8LL);
      if ( v72 != sub_180155710 && !((unsigned __int8 (__fastcall *)(__int64, __int64 *))v72)(v73, &v87) )
      {
        v85 = *(_QWORD *)(v87 + 16);
        *(_QWORD *)(v87 + 16) = 0;
        if ( v85 )
        {
          if ( _InterlockedExchangeAdd((volatile signed __int32 *)(v85 + 8), 0xFFFFFFFF) == 1 )
            (**(void (__fastcall ***)(__int64, __int64))v85)(v85, 1);
          v67 = DWORD2(v88);
        }
      }
    }
    if ( *(_BYTE *)(a2 + 16) )
    {
      *(_BYTE *)(a2 + 16) = 0;
      v74 = *(_QWORD *)(a2 + 8);
      v75 = *(void (**)(void))(*(_QWORD *)v74 + 104LL);
      if ( (char *)v75 == (char *)sub_180163CA0 )
        sub_18016CBD0(v74 + 8, v75, v72);
      else
        v75();
    }
    v76 = *(_QWORD **)(a2 + 8);
    v77 = *(__int64 (__fastcall **)())(*v76 + 208LL);
    if ( v77 == sub_1801637B0 )
      sub_1808322E0(v76[1] + 112LL, &v87);
    else
      ((void (__fastcall *)(_QWORD *, __int64 *))v77)(v76, &v87);
    v78 = _mm_shuffle_ps(
            (__m128)COERCE_UNSIGNED_INT((float)(int)v88),
            (__m128)COERCE_UNSIGNED_INT((float)(int)v88),
            225);
    v78.m128_f32[0] = (float)SDWORD1(v88);
    v79 = _mm_shuffle_ps(v78, v78, 198);
    v79.m128_f32[0] = (float)v67;
    v80 = _mm_shuffle_ps(v79, v79, 39);
    v80.m128_f32[0] = (float)SHIDWORD(v88);
    v115 = _mm_shuffle_ps(v80, v80, 57);
    v124 = v115;
    result = sub_180821CD0(a2, (_DWORD)a10, (unsigned int)&v124, 34, 1);
    v81 = (__int64 (__fastcall ***)(_QWORD, __int64))v87;
    if ( v87 )
    {
      result = (unsigned int)_InterlockedExchangeAdd((volatile signed __int32 *)(v87 + 8), 0xFFFFFFFF);
      if ( (_DWORD)result == 1 )
        result = (**v81)(v81, 1);
    }
  }
  v82 = (__int64 (__fastcall ***)(_QWORD, __int64))v89;
  if ( v89 )
  {
    v83 = _InterlockedExchangeAdd((volatile signed __int32 *)(v89 + 8), 0xFFFFFFFF);
    result = (unsigned int)(v83 - 1);
    if ( v83 == 1 )
      return (**v82)(v82, 1);
  }
  return result;
}

