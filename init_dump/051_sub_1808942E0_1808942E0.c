// sub_1808942E0  @ 0x1808942E0  (RVA 0x8942E0)  floats=15
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE5064  dword_180AE5064 = 0.75
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE50F8  dword_180AE50F8 = 1.2999999523162842
//   0x180AE5470  dword_180AE5470 = 10000.0
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=5
__int64 __fastcall sub_1808942E0(
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
  int v15; // r15d
  int v16; // r12d
  int v17; // r14d
  int v18; // ebx
  int v19; // edi
  int v20; // r12d
  int v21; // esi
  int v22; // r12d
  int v23; // eax
  __int64 result; // rax
  __int64 v25; // rdx
  int v26; // ebx
  int v27; // ecx
  int v28; // r14d
  unsigned int *v29; // rax
  float v30; // xmm0_4
  float v31; // xmm1_4
  float v32; // xmm15_4
  float v33; // xmm6_4
  __int64 v34; // rcx
  __int64 (__fastcall *v35)(); // r8
  __int64 v36; // rcx
  __int64 (__fastcall *v37)(); // rdx
  _QWORD *v38; // rcx
  __int64 (__fastcall *v39)(); // r8
  int v40; // eax
  int v41; // ebx
  int v42; // eax
  int v43; // edx
  int v44; // ecx
  float v45; // xmm8_4
  float v46; // xmm9_4
  __int64 v47; // rax
  __int64 v48; // rax
  __int64 v49; // r8
  int v50; // r8d
  int v51; // r9d
  float *v52; // rcx
  float v53; // xmm0_4
  __int64 v54; // rax
  double v55; // xmm0_8
  float v56; // xmm10_4
  void (__fastcall ***v57)(_QWORD, __int64); // rcx
  int v58; // r8d
  int v59; // edx
  float v60; // xmm8_4
  float v61; // xmm10_4
  __int64 v62; // rcx
  _DWORD *v63; // rdx
  float *v64; // rcx
  float v65; // xmm0_4
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
  signed __int32 v83; // edx
  __int64 v84; // rcx
  __int64 v85; // rcx
  __int64 v86; // rcx
  __int64 v87; // [rsp+48h] [rbp-C0h] BYREF
  __int64 v88; // [rsp+50h] [rbp-B8h] BYREF
  int v89; // [rsp+58h] [rbp-B0h]
  __int128 v90; // [rsp+68h] [rbp-A0h]
  unsigned int v91; // [rsp+78h] [rbp-90h] BYREF
  int v92; // [rsp+7Ch] [rbp-8Ch]
  int v93; // [rsp+80h] [rbp-88h]
  void *v94; // [rsp+88h] [rbp-80h] BYREF
  __int64 v95; // [rsp+90h] [rbp-78h]
  float v96; // [rsp+98h] [rbp-70h]
  float v97; // [rsp+9Ch] [rbp-6Ch]
  float v98; // [rsp+A0h] [rbp-68h]
  float v99; // [rsp+A4h] [rbp-64h]
  char v100; // [rsp+A8h] [rbp-60h]
  int v101; // [rsp+B0h] [rbp-58h] BYREF
  __int128 v102; // [rsp+B8h] [rbp-50h]
  __int128 v103; // [rsp+C8h] [rbp-40h]
  float v104[4]; // [rsp+D8h] [rbp-30h] BYREF
  _BYTE v105[4]; // [rsp+E8h] [rbp-20h] BYREF
  _BYTE v106[4]; // [rsp+ECh] [rbp-1Ch] BYREF
  int v107; // [rsp+F0h] [rbp-18h]
  __int64 v108; // [rsp+F8h] [rbp-10h] BYREF
  __m128 v109; // [rsp+100h] [rbp-8h]
  void *Block; // [rsp+110h] [rbp+8h] BYREF
  int v111; // [rsp+11Ch] [rbp+14h]
  __int128 v112; // [rsp+138h] [rbp+30h] BYREF
  __int64 v113; // [rsp+148h] [rbp+40h]
  __int64 v114; // [rsp+150h] [rbp+48h]
  float v115; // [rsp+158h] [rbp+50h]
  float v116; // [rsp+164h] [rbp+5Ch]
  float v117; // [rsp+16Ch] [rbp+64h]
  __int128 v118; // [rsp+178h] [rbp+70h] BYREF
  __int128 v119; // [rsp+188h] [rbp+80h] BYREF
  __int128 v120; // [rsp+198h] [rbp+90h] BYREF
  float v121; // [rsp+1A8h] [rbp+A0h]
  float v122; // [rsp+1ACh] [rbp+A4h]
  __int128 v123; // [rsp+1B8h] [rbp+B0h] BYREF
  __m128 v124; // [rsp+1C8h] [rbp+C0h] BYREF
  _BYTE v125[24]; // [rsp+1D8h] [rbp+D0h] BYREF
  _BYTE v126[16]; // [rsp+1F0h] [rbp+E8h] BYREF
  _BYTE v127[184]; // [rsp+200h] [rbp+F8h] BYREF

  v114 = -2;
  if ( a4 )
  {
    v15 = *a3 + 5;
    v16 = 0;
    v17 = 0;
    if ( a3[2] - 10 > 0 )
      v17 = a3[2] - 10;
    if ( (int)a3[3] > 0 )
      v16 = a3[3];
    v18 = v16 / 2 - 1;
    if ( v16 < v18 )
      v18 = v16;
    v19 = v18 + a3[1];
    sub_180831D50(a2, 855638016);
    v20 = v16 - v18;
    *(_QWORD *)&v102 = __PAIR64__(v19, v15);
    DWORD2(v102) = v17;
    v21 = 1;
    if ( v20 < 1 )
      v21 = v20;
    HIDWORD(v102) = v21;
    v118 = v102;
    (*(void (__fastcall **)(_QWORD, __int128 *, _QWORD))(**(_QWORD **)(a2 + 8) + 168LL))(*(_QWORD *)(a2 + 8), &v118, 0);
    v89 = 1728053247;
    sub_180831D50(a2, 1728053247);
    v22 = v20 - v21;
    LODWORD(v103) = v15;
    DWORD1(v103) = v21 + v19;
    DWORD2(v103) = v17;
    v23 = 1;
    if ( v22 < 1 )
      v23 = v22;
    HIDWORD(v103) = v23;
    v119 = v103;
    return (*(__int64 (__fastcall **)(_QWORD, __int128 *, _QWORD))(**(_QWORD **)(a2 + 8) + 168LL))(
             *(_QWORD *)(a2 + 8),
             &v119,
             0);
  }
  else
  {
    sub_180899F20(a1 - 64, &v91, 16778752);
    if ( a12 )
    {
      v25 = *a12;
      v91 = *a12;
    }
    else
    {
      v25 = v91;
    }
    v26 = 0;
    if ( a3[2] - 2 > 0 )
      v26 = a3[2] - 2;
    v27 = 0;
    if ( a3[3] - 2 > 0 )
      v27 = a3[3] - 2;
    v92 = v27;
    v93 = a3[1] + 1;
    v28 = *a3 + 1;
    *(_QWORD *)&v90 = __PAIR64__(v93, v28);
    *((_QWORD *)&v90 + 1) = __PAIR64__(v27, v26);
    if ( a6 )
    {
      v29 = (unsigned int *)sub_180899F20(a1 - 64, v105, 16779520);
      sub_180831D50(a2, *v29);
      v120 = v90;
      (*(void (__fastcall **)(_QWORD, __int128 *, _QWORD))(**(_QWORD **)(a2 + 8) + 168LL))(
        *(_QWORD *)(a2 + 8),
        &v120,
        0);
      v25 = *(unsigned int *)sub_180899F20(a1 - 64, v106, 16779264);
    }
    sub_180831D50(a2, v25);
    if ( !a5 )
      sub_180831C60(a2);
    (*(void (__fastcall **)(__int64, __int64 *))(*(_QWORD *)a1 + 32LL))(a1, &v88);
    v30 = (float)(int)a3[3] / 1.3;
    v31 = *(float *)(v88 + 40);
    v32 = 0.1;
    if ( v31 > v30 )
    {
      v33 = v30 >= 0.1 ? fminf(10000.0, v30) : 0.1;
      if ( v31 != v33 )
      {
        sub_1807D2580(&v88);
        *(float *)(v88 + 40) = v33;
        v34 = *(_QWORD *)(v88 + 16);
        if ( v34 )
        {
          v35 = *(__int64 (__fastcall **)())(*(_QWORD *)v34 + 8LL);
          if ( v35 != sub_180155710 && !((unsigned __int8 (__fastcall *)(__int64, __int64 *))v35)(v34, &v88) )
          {
            v86 = *(_QWORD *)(v88 + 16);
            *(_QWORD *)(v88 + 16) = 0;
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
      v36 = *(_QWORD *)(a2 + 8);
      v37 = *(__int64 (__fastcall **)())(*(_QWORD *)v36 + 104LL);
      if ( v37 == sub_180163CA0 )
        sub_18016CBD0(v36 + 8, v37, sub_180163CA0);
      else
        ((void (__fastcall *)(__int64, __int64 (__fastcall *)(), __int64 (__fastcall *)()))v37)(v36, v37, sub_180163CA0);
    }
    v38 = *(_QWORD **)(a2 + 8);
    v39 = *(__int64 (__fastcall **)())(*v38 + 208LL);
    if ( v39 == sub_1801637B0 )
      sub_1808322E0(v38[1] + 112LL, &v88);
    else
      ((void (__fastcall *)(_QWORD *, __int64 *))v39)(v38, &v88);
    v40 = 5 * v92 / 4;
    if ( v26 < v40 )
      v40 = v26;
    LODWORD(v90) = v40 + v28;
    v41 = v26 - v40;
    DWORD2(v90) = v41;
    v42 = v40 - 6;
    v43 = 0;
    if ( v42 > 0 )
      v43 = v42;
    v44 = 0;
    if ( v92 - 6 > 0 )
      v44 = v92 - 6;
    v45 = (float)v44;
    v46 = (float)v43;
    v121 = (float)(v28 + 3);
    v122 = (float)(v93 + 3);
    if ( a11 )
    {
      v104[0] = (float)(v28 + 3);
      v104[1] = (float)(v93 + 3);
      v104[2] = (float)v43;
      v104[3] = (float)v44;
      v101 = 292;
      v47 = (*(__int64 (__fastcall **)(__int64, _BYTE *))(*(_QWORD *)a11 + 360LL))(a11, v126);
      v48 = sub_1808325C0(&v101, v127, v47, v104);
      sub_1808BA6D0(a11, a2, v49, v48);
    }
    else if ( a7 )
    {
      (*(void (__fastcall **)(__int64, void **))(*(_QWORD *)(a1 - 64) + 96LL))(a1 - 64, &Block);
      sub_180828260((unsigned int)&Block, (unsigned int)v125, v50, v51, LODWORD(v46), LODWORD(v45), 1, 36);
      if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
      {
        v52 = (float *)Block;
        while ( v52 != (float *)((char *)Block + 4 * v111) )
        {
          v53 = *v52;
          if ( *v52 == 100002.0 )
          {
            v52 += 3;
          }
          else
          {
            if ( v53 == 100001.0 || v53 == 100003.0 || v53 == 100004.0 )
            {
              (*(void (__fastcall **)(_QWORD, void **, _BYTE *))(**(_QWORD **)(a2 + 8) + 184LL))(
                *(_QWORD *)(a2 + 8),
                &Block,
                v125);
              break;
            }
            ++v52;
          }
        }
      }
      v111 = 0;
      free(Block);
    }
    if ( a8 )
    {
      v54 = (*(__int64 (__fastcall **)(__int64, __int64 *))(*(_QWORD *)a1 + 32LL))(a1, &v108);
      v55 = sub_1807D1560(v54);
      v56 = *(float *)&v55 * 0.60000002;
      v57 = (void (__fastcall ***)(_QWORD, __int64))v108;
      if ( v108 )
      {
        if ( _InterlockedExchangeAdd((volatile signed __int32 *)(v108 + 8), 0xFFFFFFFF) == 1 )
          (**v57)(v57, 1);
        v41 = DWORD2(v90);
      }
      v58 = (int)v56;
      if ( v41 < (int)v56 )
        v58 = v41;
      v59 = v41 + v90 - v58;
      v41 -= v58;
      v60 = (float)(v93 + v92 / 2);
      v94 = nullptr;
      v95 = 0;
      v100 = 1;
      v115 = (float)(v56 * 0.60000002) + (float)v59;
      v61 = v56 * 0.5;
      v116 = v61 + v60;
      v117 = v60 - v61;
      v97 = (float)v59;
      v96 = (float)v59;
      v99 = v60 - v61;
      v98 = v60 - v61;
      sub_180179780(&v94, &unk_180AA33E4);
      sub_18082B140(&v94);
      sub_18082B140(&v94);
      if ( HIDWORD(v95) && (SHIDWORD(v95) <= 0 || *((float *)v94 + SHIDWORD(v95) - 1) != 100005.0) )
      {
        sub_1801716F0(&v94, (unsigned int)(HIDWORD(v95) + 1));
        v62 = SHIDWORD(v95);
        ++HIDWORD(v95);
        v63 = (char *)v94 + 4 * v62;
        if ( v63 )
          *v63 = 1203982976;
      }
      if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
      {
        v64 = (float *)v94;
        while ( v64 != (float *)((char *)v94 + 4 * SHIDWORD(v95)) )
        {
          v65 = *v64;
          if ( *v64 == 100002.0 )
          {
            v64 += 3;
          }
          else
          {
            if ( v65 == 100001.0 || v65 == 100003.0 || v65 == 100004.0 )
            {
              v112 = xmmword_180AE5570;
              v113 = 1065353216;
              (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
                *(_QWORD *)(a2 + 8),
                &v94,
                &v112);
              break;
            }
            ++v64;
          }
        }
      }
      HIDWORD(v95) = 0;
      free(v94);
    }
    v66 = 3;
    if ( v41 < 3 )
      v66 = v41;
    v67 = v41 - v66;
    DWORD2(v90) = v67;
    v123 = v90;
    v107 = 33;
    sub_180821B50(a2, a9, (unsigned int)&v123, 33, 1, 0);
    result = *a10;
    if ( *(_BYTE *)*a10 )
    {
      v68 = v88;
      v87 = v88;
      if ( v88 )
      {
        _InterlockedExchangeAdd((volatile signed __int32 *)(v88 + 8), 1u);
        v67 = DWORD2(v90);
        v68 = v87;
      }
      v69 = *(float *)(v68 + 40) * 0.75;
      if ( v69 >= 0.1 )
        v32 = fminf(10000.0, v69);
      if ( *(float *)(v68 + 40) != v32 )
      {
        sub_1807D2580(&v87);
        *(float *)(v87 + 40) = v32;
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
              v67 = DWORD2(v90);
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
            v67 = DWORD2(v90);
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
              (__m128)COERCE_UNSIGNED_INT((float)(int)v90),
              (__m128)COERCE_UNSIGNED_INT((float)(int)v90),
              225);
      v78.m128_f32[0] = (float)SDWORD1(v90);
      v79 = _mm_shuffle_ps(v78, v78, 198);
      v79.m128_f32[0] = (float)v67;
      v80 = _mm_shuffle_ps(v79, v79, 39);
      v80.m128_f32[0] = (float)SHIDWORD(v90);
      v109 = _mm_shuffle_ps(v80, v80, 57);
      v124 = v109;
      result = sub_180821CD0(a2, (_DWORD)a10, (unsigned int)&v124, 34, 1);
      v81 = (__int64 (__fastcall ***)(_QWORD, __int64))v87;
      if ( v87 )
      {
        result = (unsigned int)_InterlockedExchangeAdd((volatile signed __int32 *)(v87 + 8), 0xFFFFFFFF);
        if ( (_DWORD)result == 1 )
          result = (**v81)(v81, 1);
      }
    }
    v82 = (__int64 (__fastcall ***)(_QWORD, __int64))v88;
    if ( v88 )
    {
      v83 = _InterlockedExchangeAdd((volatile signed __int32 *)(v88 + 8), 0xFFFFFFFF);
      result = (unsigned int)(v83 - 1);
      if ( v83 == 1 )
        return (**v82)(v82, 1);
    }
  }
  return result;
}

