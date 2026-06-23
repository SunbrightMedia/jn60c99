// sub_1808911F0  @ 0x1808911F0  (RVA 0x8911F0)  floats=22
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5054  dword_180AE5054 = 0.699999988079071
//   0x180AE5070  dword_180AE5070 = 0.800000011920929
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE50C4  dword_180AE50C4 = 1.100000023841858
//   0x180AE50E0  dword_180AE50E0 = 1.2000000476837158
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE5380  dword_180AE5380 = 12.0
//   0x180AE5440  dword_180AE5440 = 255.99600219726562
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE54D4  dword_180AE54D4 = -0.4000000059604645
//   0x180AE54DC  dword_180AE54DC = -0.699999988079071
//   0x180AE5570  xmmword_180AE5570 = 1.0
//   0x180AE57C0  xmmword_180AE57C0 = -0.0

// Hidden C++ exception states: #wind=4
void __fastcall sub_1808911F0(
        __int64 a1,
        __int64 a2,
        int a3,
        int a4,
        int a5,
        int a6,
        int a7,
        float X,
        int a9,
        __int64 a10)
{
  int v11; // eax
  __m128 v12; // xmm12
  float v13; // xmm10_4
  float v14; // xmm9_4
  __m128 v15; // xmm11
  int v16; // xmm15_4
  __int64 v17; // rbx
  bool v18; // r14
  float v19; // xmm6_4
  int v20; // edx
  int v21; // r8d
  int v22; // r9d
  float *v23; // rcx
  float v24; // xmm0_4
  __m128 v25; // xmm6
  __m128 v26; // xmm7
  __int64 v27; // rcx
  _DWORD *v28; // rdx
  float v29; // xmm6_4
  __m128 v30; // xmm1
  __m128 v31; // xmm1
  __m128 v32; // xmm1
  float v33; // xmm6_4
  float v34; // xmm0_4
  float *v35; // rcx
  float v36; // xmm0_4
  __int64 v37; // rdx
  int v38; // edx
  int v39; // r8d
  int v40; // r9d
  __int64 v41; // rcx
  _DWORD *v42; // rdx
  __int32 v43; // xmm0_4
  float v44; // xmm6_4
  __m128 v45; // xmm0
  __m128 v46; // xmm1
  __m128 v47; // xmm1
  __m128 v48; // xmm1
  int v49; // ecx
  __m128 v50; // xmm0
  float v51; // xmm6_4
  float *v52; // rcx
  char *v53; // rdx
  float v54; // xmm0_4
  __m128 v55; // [rsp+48h] [rbp-C0h] BYREF
  __int64 v56; // [rsp+58h] [rbp-B0h]
  void *Block_8[2]; // [rsp+68h] [rbp-A0h] BYREF
  __int128 v58; // [rsp+78h] [rbp-90h]
  char v59; // [rsp+88h] [rbp-80h]
  void *v60; // [rsp+90h] [rbp-78h] BYREF
  __int64 v61; // [rsp+98h] [rbp-70h]
  __int128 v62; // [rsp+A0h] [rbp-68h]
  char v63; // [rsp+B0h] [rbp-58h]
  int v64; // [rsp+B8h] [rbp-50h]
  float v65; // [rsp+BCh] [rbp-4Ch]
  __int64 v66; // [rsp+C0h] [rbp-48h]

  v66 = -2;
  v11 = a5 / 2;
  if ( a6 / 2 < a5 / 2 )
    v11 = a6 / 2;
  v12 = (__m128)COERCE_UNSIGNED_INT((float)v11);
  v12.m128_f32[0] = v12.m128_f32[0] - 2.0;
  v13 = (float)((float)a5 * 0.5) + (float)a3;
  v14 = (float)((float)a6 * 0.5) + (float)a4;
  v65 = v13 - v12.m128_f32[0];
  v15 = v12;
  v15.m128_f32[0] = v12.m128_f32[0] + v12.m128_f32[0];
  *(float *)&v64 = v12.m128_f32[0] + v12.m128_f32[0];
  *(float *)&v16 = (float)((float)(*(float *)&a9 - X) * *(float *)&a7) + X;
  v17 = a10;
  v18 = (unsigned __int8)sub_1808C6DD0(a10)
     && (*(_BYTE *)(v17 + 169) & 0x10) == 0
     && (!*(_QWORD *)(v17 + 24) || (unsigned __int8)sub_1808C7290());
  if ( v12.m128_f32[0] <= 12.0 )
  {
    if ( (*(_BYTE *)(v17 + 169) & 0x10) != 0 || *(_QWORD *)(v17 + 24) && !(unsigned __int8)sub_1808C7290() )
    {
      X = -1.1801041e-38;
    }
    else
    {
      if ( v18 )
        v44 = 1.0;
      else
        v44 = 0.69999999;
      X = *(float *)sub_1808D6630(v17, &a9, 16782097, 0);
      if ( v44 > 0.0 )
      {
        if ( v44 < 1.0 )
          HIBYTE(X) = (int)(float)(v44 * 255.996);
        else
          HIBYTE(X) = -1;
      }
      else
      {
        HIBYTE(X) = 0;
      }
    }
    sub_180831D50(a2, LODWORD(X));
    v60 = nullptr;
    v61 = 0;
    v62 = 0;
    v63 = 1;
    v45 = v15;
    v45.m128_f32[0] = v15.m128_f32[0] * -0.40000001;
    v46 = _mm_shuffle_ps(v45, v45, 225);
    v46.m128_f32[0] = v15.m128_f32[0] * -0.40000001;
    v47 = _mm_shuffle_ps(v46, v46, 198);
    v47.m128_f32[0] = v15.m128_f32[0] * 0.80000001;
    v48 = _mm_shuffle_ps(v47, v47, 39);
    v48.m128_f32[0] = v15.m128_f32[0] * 0.80000001;
    v55 = _mm_shuffle_ps(v48, v48, 57);
    sub_18082A520(&v60, &v55);
    *(_OWORD *)Block_8 = xmmword_180AE5570;
    *(_QWORD *)&v58 = 1065353216;
    sub_180823660(v49, 0, 0, (unsigned int)&v60, (__int64)&v60, (__int64)Block_8, 1065353216, 0);
    v55.m128_u64[0] = 0;
    v55.m128_i32[2] = 0;
    v50 = _mm_shuffle_ps(v55, v55, 147);
    v50.m128_f32[0] = -v12.m128_f32[0];
    v55 = _mm_shuffle_ps(v50, v50, 57);
    sub_180829BA0(&v60, &v55);
    v51 = cosf(*(float *)&v16);
    v50.m128_f32[0] = sinf(*(float *)&v16);
    v55.m128_f32[0] = v51;
    v55.m128_f32[1] = -v50.m128_f32[0];
    v55.m128_f32[2] = v13 + 0.0;
    v55.m128_i32[3] = v50.m128_i32[0];
    *(float *)&v56 = v51;
    *((float *)&v56 + 1) = v14 + 0.0;
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
    {
      v52 = (float *)v60;
      v53 = (char *)v60 + 4 * SHIDWORD(v61);
      if ( v60 != v53 )
      {
        do
        {
          v54 = *v52;
          if ( *v52 == 100002.0 )
          {
            v52 += 2;
          }
          else if ( v54 == 100001.0 || v54 == 100003.0 || v54 == 100004.0 )
          {
            (*(void (__fastcall **)(_QWORD, void **, __m128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
              *(_QWORD *)(a2 + 8),
              &v60,
              &v55);
            break;
          }
          ++v52;
        }
        while ( v52 != (float *)v53 );
      }
    }
  }
  else
  {
    if ( (*(_BYTE *)(v17 + 169) & 0x10) != 0 || *(_QWORD *)(v17 + 24) && !(unsigned __int8)sub_1808C7290() )
    {
      a6 = -2139062144;
      sub_180831D50(a2, 2155905152LL);
    }
    else
    {
      if ( v18 )
        v19 = 1.0;
      else
        v19 = 0.69999999;
      a6 = *(_DWORD *)sub_1808D6630(v17, &a7, 16782097, 0);
      if ( v19 > 0.0 )
      {
        if ( v19 < 1.0 )
          HIBYTE(a6) = (int)(float)(v19 * 255.996);
        else
          HIBYTE(a6) = -1;
        sub_180831D50(a2, (unsigned int)a6);
      }
      else
      {
        HIBYTE(a6) = 0;
        sub_180831D50(a2, (unsigned int)a6);
      }
    }
    *(_OWORD *)Block_8 = 0u;
    v58 = 0;
    v59 = 1;
    sub_180829E70((int)Block_8, v20, v21, v22, COERCE_INT(v12.m128_f32[0] + v12.m128_f32[0]), X, v16, 1060320051);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
    {
      v23 = (float *)Block_8[0];
      while ( v23 != (float *)((char *)Block_8[0] + 4 * SHIDWORD(Block_8[1])) )
      {
        v24 = *v23;
        if ( *v23 == 100002.0 )
        {
          v23 += 3;
        }
        else
        {
          if ( v24 == 100001.0 || v24 == 100003.0 || v24 == 100004.0 )
          {
            v55 = (__m128)xmmword_180AE5570;
            v56 = 1065353216;
            (*(void (__fastcall **)(_QWORD, void **, __m128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
              *(_QWORD *)(a2 + 8),
              Block_8,
              &v55);
            break;
          }
          ++v23;
        }
      }
    }
    HIDWORD(Block_8[1]) = 0;
    free(Block_8[0]);
    v25 = v12;
    v25.m128_f32[0] = v12.m128_f32[0] * 0.2;
    *(_OWORD *)Block_8 = 0u;
    v59 = 1;
    v26 = _mm_xor_ps(v25, (__m128)0x80000000);
    DWORD1(v58) = v26.m128_i32[0];
    LODWORD(v58) = v26.m128_i32[0];
    *((_QWORD *)&v58 + 1) = 0;
    sub_180179780(Block_8, &unk_180AA33E4);
    sub_18082B140(Block_8);
    sub_18082B140(Block_8);
    if ( HIDWORD(Block_8[1])
      && (SHIDWORD(Block_8[1]) <= 0 || *((float *)Block_8[0] + SHIDWORD(Block_8[1]) - 1) != 100005.0) )
    {
      sub_1801716F0(Block_8, (unsigned int)(HIDWORD(Block_8[1]) + 1));
      v27 = SHIDWORD(Block_8[1]);
      ++HIDWORD(Block_8[1]);
      v28 = (char *)Block_8[0] + 4 * v27;
      if ( v28 )
        *v28 = 1203982976;
    }
    v29 = v25.m128_f32[0] + v25.m128_f32[0];
    v30 = _mm_shuffle_ps(v26, v26, 225);
    v30.m128_f32[0] = v26.m128_f32[0];
    v31 = _mm_shuffle_ps(v30, v30, 198);
    v31.m128_f32[0] = v29;
    v32 = _mm_shuffle_ps(v31, v31, 39);
    v32.m128_f32[0] = v29;
    v55 = _mm_shuffle_ps(v32, v32, 57);
    sub_18082A520(Block_8, &v55);
    v33 = cosf(*(float *)&v16);
    v34 = sinf(*(float *)&v16);
    v55.m128_f32[0] = v33;
    v55.m128_f32[1] = -v34;
    v55.m128_f32[2] = v13 + 0.0;
    v55.m128_f32[3] = v34;
    *(float *)&v56 = v33;
    *((float *)&v56 + 1) = v14 + 0.0;
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
    {
      v35 = (float *)Block_8[0];
      while ( v35 != (float *)((char *)Block_8[0] + 4 * SHIDWORD(Block_8[1])) )
      {
        v36 = *v35;
        if ( *v35 == 100002.0 )
        {
          v35 += 3;
        }
        else
        {
          if ( v36 == 100001.0 || v36 == 100003.0 || v36 == 100004.0 )
          {
            (*(void (__fastcall **)(_QWORD, void **, __m128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
              *(_QWORD *)(a2 + 8),
              Block_8,
              &v55);
            break;
          }
          ++v35;
        }
      }
    }
    HIDWORD(Block_8[1]) = 0;
    free(Block_8[0]);
    if ( (*(_BYTE *)(v17 + 169) & 0x10) != 0 || *(_QWORD *)(v17 + 24) && !(unsigned __int8)sub_1808C7290() )
    {
      a6 = -2139062144;
      v37 = 2155905152LL;
    }
    else
    {
      v37 = *(unsigned int *)sub_1808D6630(v17, &a6, 16782098, 0);
    }
    sub_180831D50(a2, v37);
    v60 = nullptr;
    v61 = 0;
    v62 = 0;
    v63 = 1;
    sub_180829E70((int)&v60, v38, v39, v40, v64, X, a9, 1060320051);
    if ( HIDWORD(v61) && (SHIDWORD(v61) <= 0 || *((float *)v60 + SHIDWORD(v61) - 1) != 100005.0) )
    {
      sub_1801716F0(&v60, (unsigned int)(HIDWORD(v61) + 1));
      v41 = SHIDWORD(v61);
      ++HIDWORD(v61);
      v42 = (char *)v60 + 4 * v41;
      if ( v42 )
        *v42 = 1203982976;
    }
    *(_OWORD *)Block_8 = xmmword_180AE5570;
    *(_QWORD *)&v58 = 1065353216;
    if ( (*(_BYTE *)(v17 + 169) & 0x10) != 0 || *(_QWORD *)(v17 + 24) && !(unsigned __int8)sub_1808C7290() )
    {
      v43 = 1050253722;
    }
    else if ( v18 )
    {
      v43 = 0x40000000;
    }
    else
    {
      v43 = 1067030938;
    }
    v55.m128_i32[0] = v43;
    *(unsigned __int64 *)((char *)v55.m128_u64 + 4) = 0;
    sub_180830CE0(a2, &v60, &v55, Block_8);
  }
  HIDWORD(v61) = 0;
  free(v60);
}

