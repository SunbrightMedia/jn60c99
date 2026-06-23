// sub_1802C1850  @ 0x1802C1850  (RVA 0x2C1850)  floats=14
// .rdata float constants referenced by this function:
//   0x1809380A0  lParam = 0.0
//   0x1809380C0  xmmword_1809380C0 = 0.0
//   0x180940DA0  aInt1x7 = 3.556943406479718e-09
//   0x180940DA8  aInt2x7 = 1.4227773625918871e-08
//   0x180940DB0  aInt3x7 = 5.6911094503675486e-08
//   0x180940DB8  aInt4x7 = 2.2764437801470194e-07
//   0x180940DC0  aInt5x7 = 9.105775120588078e-07
//   0x180940DC8  aInt2x4 = 1.4227773625918871e-08
//   0x180940DD0  aInt3x4 = 5.6911094503675486e-08
//   0x180940DD8  aInt4x4 = 2.2764437801470194e-07
//   0x180940DE0  aInt5x4 = 9.105775120588078e-07
//   0x180940DE8  aInt6x4 = 3.642310048235231e-06
//   0x180940DF0  aInt7x4 = 1.4569240192940924e-05
//   0x180940DF8  aInt8x4 = 5.82769607717637e-05

// Hidden C++ exception states: #wind=17
__int64 __fastcall sub_1802C1850(__int64 a1)
{
  _DWORD *v2; // rsi
  _DWORD *v3; // rbx
  _QWORD *v4; // rdi
  __int64 v5; // rax
  void *v6; // rcx
  _DWORD *v7; // rsi
  _DWORD *v8; // rbx
  _QWORD *v9; // rdi
  __int64 v10; // rax
  void *v11; // rcx
  _DWORD *v12; // rsi
  _DWORD *v13; // rbx
  _QWORD *v14; // rdi
  __int64 v15; // rax
  void *v16; // rcx
  _DWORD *v17; // rsi
  _DWORD *v18; // rbx
  _QWORD *v19; // rdi
  __int64 v20; // rax
  void *v21; // rcx
  _DWORD *v22; // rsi
  _DWORD *v23; // rbx
  _QWORD *v24; // rdi
  __int64 v25; // rax
  void *v26; // rcx
  _DWORD *v27; // rsi
  _DWORD *v28; // rbx
  _QWORD *v29; // rdi
  __int64 v30; // rax
  void *v31; // rcx
  void *v32; // rcx
  void *v33; // rcx
  void *v34; // rcx
  void *v35; // rcx
  char *v36; // rsi
  char *v37; // rbx
  _QWORD *v38; // rdi
  __int64 result; // rax
  _BYTE v40[8]; // [rsp+30h] [rbp-40h] BYREF
  _QWORD v41[2]; // [rsp+38h] [rbp-38h] BYREF
  _QWORD v42[2]; // [rsp+48h] [rbp-28h] BYREF
  __m128i si128; // [rsp+58h] [rbp-18h]

  v41[1] = -2;
  if ( dword_180CAFB70 > *(_DWORD *)(*((_QWORD *)NtCurrentTeb()->ThreadLocalStoragePointer + (unsigned int)TlsIndex)
                                   + 24LL) )
  {
    Init_thread_header(&dword_180CAFB70);
    if ( dword_180CAFB70 == -1 )
    {
      qword_180CAFB60 = (void *)sub_1802C28D0(&qword_180CAFB60);
      atexit(sub_18092BF30);
      Init_thread_footer(&dword_180CAFB70);
    }
  }
  if ( !qword_180CAFB68 )
  {
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int1x7", 6);
    v2 = qword_180CAFB60;
    v3 = qword_180CAFB60;
    v4 = *((_QWORD **)qword_180CAFB60 + 1);
    if ( *((_BYTE *)v4 + 25) )
      goto LABEL_10;
    do
    {
      if ( (int)sub_1800BAC80(v4 + 4, v42) >= 0 )
      {
        v3 = v4;
        v4 = (_QWORD *)*v4;
      }
      else
      {
        v4 = (_QWORD *)v4[2];
      }
    }
    while ( !*((_BYTE *)v4 + 25) );
    if ( v3 == v2 || (int)sub_1800BAC80(v42, v3 + 8) < 0 )
    {
LABEL_10:
      v41[0] = v42;
      v5 = sub_1802BD230(&qword_180CAFB60, &unk_1809409BF, v41, v40);
      sub_1802BD7A0((unsigned int)&qword_180CAFB60, (unsigned int)v41, (_DWORD)v3, v5 + 32, v5);
      v3 = (_DWORD *)v41[0];
    }
    v3[16] = 0;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v6 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v6 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v6 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v6);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, &lParam, 0);
    v7 = qword_180CAFB60;
    v8 = qword_180CAFB60;
    v9 = *((_QWORD **)qword_180CAFB60 + 1);
    if ( *((_BYTE *)v9 + 25) )
      goto LABEL_22;
    do
    {
      if ( (int)sub_1800BAC80(v9 + 4, v42) >= 0 )
      {
        v8 = v9;
        v9 = (_QWORD *)*v9;
      }
      else
      {
        v9 = (_QWORD *)v9[2];
      }
    }
    while ( !*((_BYTE *)v9 + 25) );
    if ( v8 == v7 || (int)sub_1800BAC80(v42, v8 + 8) < 0 )
    {
LABEL_22:
      v41[0] = v42;
      v10 = sub_1802BD230(&qword_180CAFB60, &unk_1809409BF, v41, v40);
      sub_1802BD7A0((unsigned int)&qword_180CAFB60, (unsigned int)v41, (_DWORD)v8, v10 + 32, v10);
      v8 = (_DWORD *)v41[0];
    }
    v8[16] = 0;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v11 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v11 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v11 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v11);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int2x7", 6);
    v12 = qword_180CAFB60;
    v13 = qword_180CAFB60;
    v14 = *((_QWORD **)qword_180CAFB60 + 1);
    if ( *((_BYTE *)v14 + 25) )
      goto LABEL_34;
    do
    {
      if ( (int)sub_1800BAC80(v14 + 4, v42) >= 0 )
      {
        v13 = v14;
        v14 = (_QWORD *)*v14;
      }
      else
      {
        v14 = (_QWORD *)v14[2];
      }
    }
    while ( !*((_BYTE *)v14 + 25) );
    if ( v13 == v12 || (int)sub_1800BAC80(v42, v13 + 8) < 0 )
    {
LABEL_34:
      v41[0] = v42;
      v15 = sub_1802BD230(&qword_180CAFB60, &unk_1809409BF, v41, v40);
      sub_1802BD7A0((unsigned int)&qword_180CAFB60, (unsigned int)v41, (_DWORD)v13, v15 + 32, v15);
      v13 = (_DWORD *)v41[0];
    }
    v13[16] = 1;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v16 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v16 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v16 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v16);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int3x7", 6);
    v17 = qword_180CAFB60;
    v18 = qword_180CAFB60;
    v19 = *((_QWORD **)qword_180CAFB60 + 1);
    if ( *((_BYTE *)v19 + 25) )
      goto LABEL_46;
    do
    {
      if ( (int)sub_1800BAC80(v19 + 4, v42) >= 0 )
      {
        v18 = v19;
        v19 = (_QWORD *)*v19;
      }
      else
      {
        v19 = (_QWORD *)v19[2];
      }
    }
    while ( !*((_BYTE *)v19 + 25) );
    if ( v18 == v17 || (int)sub_1800BAC80(v42, v18 + 8) < 0 )
    {
LABEL_46:
      v41[0] = v42;
      v20 = sub_1802BD230(&qword_180CAFB60, &unk_1809409BF, v41, v40);
      sub_1802BD7A0((unsigned int)&qword_180CAFB60, (unsigned int)v41, (_DWORD)v18, v20 + 32, v20);
      v18 = (_DWORD *)v41[0];
    }
    v18[16] = 2;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v21 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v21 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v21 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v21);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int4x7", 6);
    v22 = qword_180CAFB60;
    v23 = qword_180CAFB60;
    v24 = *((_QWORD **)qword_180CAFB60 + 1);
    if ( *((_BYTE *)v24 + 25) )
      goto LABEL_58;
    do
    {
      if ( (int)sub_1800BAC80(v24 + 4, v42) >= 0 )
      {
        v23 = v24;
        v24 = (_QWORD *)*v24;
      }
      else
      {
        v24 = (_QWORD *)v24[2];
      }
    }
    while ( !*((_BYTE *)v24 + 25) );
    if ( v23 == v22 || (int)sub_1800BAC80(v42, v23 + 8) < 0 )
    {
LABEL_58:
      v41[0] = v42;
      v25 = sub_1802BD230(&qword_180CAFB60, &unk_1809409BF, v41, v40);
      sub_1802BD7A0((unsigned int)&qword_180CAFB60, (unsigned int)v41, (_DWORD)v23, v25 + 32, v25);
      v23 = (_DWORD *)v41[0];
    }
    v23[16] = 3;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v26 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v26 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v26 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v26);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int5x7", 6);
    v27 = qword_180CAFB60;
    v28 = qword_180CAFB60;
    v29 = *((_QWORD **)qword_180CAFB60 + 1);
    if ( *((_BYTE *)v29 + 25) )
      goto LABEL_70;
    do
    {
      if ( (int)sub_1800BAC80(v29 + 4, v42) >= 0 )
      {
        v28 = v29;
        v29 = (_QWORD *)*v29;
      }
      else
      {
        v29 = (_QWORD *)v29[2];
      }
    }
    while ( !*((_BYTE *)v29 + 25) );
    if ( v28 == v27 || (int)sub_1800BAC80(v42, v28 + 8) < 0 )
    {
LABEL_70:
      v41[0] = v42;
      v30 = sub_1802BD230(&qword_180CAFB60, &unk_1809409BF, v41, v40);
      sub_1802BD7A0((unsigned int)&qword_180CAFB60, (unsigned int)v41, (_DWORD)v28, v30 + 32, v30);
      v28 = (_DWORD *)v41[0];
    }
    v28[16] = 4;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v31 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v31 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v31 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v31);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int2x4", 6);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 5;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v32 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v32 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v32 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v32);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int3x4", 6);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 6;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v33 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v33 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v33 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v33);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int4x4", 6);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 7;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v34 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v34 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v34 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v34);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int5x4", 6);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 8;
    if ( si128.m128i_i64[1] >= 0x10uLL )
    {
      v35 = (void *)v42[0];
      if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
      {
        v35 = *(void **)(v42[0] - 8LL);
        if ( (unsigned __int64)(v42[0] - (_QWORD)v35 - 8LL) > 0x1F )
          invalid_parameter_noinfo_noreturn();
      }
      j_j_free(v35);
    }
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int6x4", 6);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 9;
    if ( si128.m128i_i64[1] >= 0x10uLL )
      std::allocator<char>::deallocate(v42, v42[0], si128.m128i_i64[1] + 1);
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int7x4", 6);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 10;
    if ( si128.m128i_i64[1] >= 0x10uLL )
      std::allocator<char>::deallocate(v42, v42[0], si128.m128i_i64[1] + 1);
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "int8x4", 6);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 11;
    sub_1800B7A90(v42);
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "stringNx7", 9);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 12;
    sub_1800B7A90(v42);
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "string", 6);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 12;
    sub_1800B7A90(v42);
    si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
    LOBYTE(v42[0]) = 0;
    sub_18027A590(v42, "stringNx4", 9);
    *(_DWORD *)sub_1802BE710(&qword_180CAFB60, v42) = 13;
    sub_1800B7A90(v42);
  }
  v36 = (char *)qword_180CAFB60;
  v37 = (char *)qword_180CAFB60;
  v38 = *((_QWORD **)qword_180CAFB60 + 1);
  if ( *((_BYTE *)v38 + 25) )
    goto LABEL_103;
  do
  {
    if ( (int)sub_1800BAC80(v38 + 4, a1) >= 0 )
    {
      v37 = (char *)v38;
      v38 = (_QWORD *)*v38;
    }
    else
    {
      v38 = (_QWORD *)v38[2];
    }
  }
  while ( !*((_BYTE *)v38 + 25) );
  if ( v37 == v36 || (int)sub_1800BAC80(a1, v37 + 32) < 0 )
LABEL_103:
    v37 = v36;
  result = 15;
  if ( v37 != v36 )
    return *((unsigned int *)v37 + 16);
  return result;
}

