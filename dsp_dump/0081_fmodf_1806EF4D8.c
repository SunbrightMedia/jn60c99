// fmodf  @ 0x1806EF4D8  (RVA 0x6EF4D8)
// prototype: float __cdecl(float X, float Y)
// callees: 0x1806EF4D8, 0x180715E58, 0x180715FA8
// constants/globals referenced:
//   0x180AE57B0 [.rdata] xmmword_180AE57B0  u32=0  f32=0.0  f64=-0.0
//   0x180A90C88 [.rdata] aFmodf  u32=1685024102  f32=1.7666619287257366e+22  f64=2.172760831997e-312

float __cdecl fmodf(float X, float Y)
{
  double v2; // r8
  double v3; // r9
  double v4; // r10
  unsigned __int64 v5; // rcx
  unsigned __int64 v6; // rdx
  double v7; // xmm2_8
  double v8; // xmm3_8
  unsigned int v9; // r8d
  unsigned int v10; // edx
  int v11; // edx
  __int64 v12; // rcx
  double v13; // xmm1_8
  double v14; // xmm2_8
  double v15; // xmm0_8
  float v16; // [rsp+60h] [rbp+8h]
  float v17; // [rsp+60h] [rbp+8h]

  v16 = X;
  v2 = X;
  v3 = fabs(X);
  v4 = fabs(Y);
  v5 = (COERCE_UNSIGNED_INT64(X) >> 52) & 0x7FF;
  v6 = (COERCE_UNSIGNED_INT64(Y) >> 52) & 0x7FF;
  if ( ((COERCE_UNSIGNED_INT64(X) >> 52) & 0x7FF) == 0 )
    goto LABEL_17;
  if ( ((COERCE_UNSIGNED_INT64(X) >> 52) & 0x7FF) == 0x7FF )
    goto LABEL_18;
  if ( (unsigned int)(v6 - 1) > 0x7FD )
  {
LABEL_17:
    if ( ((COERCE_UNSIGNED_INT64(X) >> 52) & 0x7FF) != 0x7FF )
    {
      if ( ((COERCE_UNSIGNED_INT64(Y) >> 52) & 0x7FF) == 0x7FF )
      {
        if ( (COERCE_UNSIGNED_INT64(Y) & 0xFFFFFFFFFFFFFLL) == 0 )
          return X;
        v17 = Y;
        return handle_nanf(LODWORD(v17), v6, *(_QWORD *)&v2, *(_QWORD *)&v3);
      }
      if ( ((COERCE_UNSIGNED_INT64(X) >> 52) & 0x7FF) == 0 && ((COERCE_UNSIGNED_INT64(Y) >> 52) & 0x7FF) != 0 )
        return X;
LABEL_26:
      handle_errorf((unsigned int)"fmodf", 22, -4194304, 1, 8, 33, LODWORD(X), LODWORD(Y), 2);
      return X;
    }
LABEL_18:
    if ( (*(_QWORD *)&v2 & 0xFFFFFFFFFFFFFLL) != 0 )
    {
      v17 = X;
      return handle_nanf(LODWORD(v17), v6, *(_QWORD *)&v2, *(_QWORD *)&v3);
    }
    goto LABEL_26;
  }
  if ( *(_QWORD *)&v3 == *(_QWORD *)&v4 )
    return COERCE_DOUBLE(*(_QWORD *)&v2 & 0x8000000000000000uLL);
  v7 = v3;
  v8 = v4;
  if ( *(_QWORD *)&v3 >= *(_QWORD *)&v4 )
  {
    v9 = _mm_getcsr();
    if ( (int)v5 > (int)v6 )
    {
      v10 = (int)((unsigned __int64)(715827883LL * ((int)v5 - (int)v6)) >> 32) >> 2;
      v11 = (v10 >> 31) + v10;
      v8 = COERCE_DOUBLE((__int64)(24 * v11 + 1023) << 52) * v4;
      if ( v11 > 0 )
      {
        v12 = (unsigned int)v11;
        do
        {
          v13 = (double)(int)(v7 / v8) * v8;
          v8 = v8 * 0.00000005960464477539062;
          v7 = v7 - v13;
          --v12;
        }
        while ( v12 );
      }
    }
    v14 = v7 - (double)(int)(v7 / v8) * v8;
    _mm_setcsr(v9);
    v15 = v14;
    if ( v16 < 0.0 )
      return -v14;
    return v15;
  }
  else
  {
    if ( X < 0.0 )
      return -v3;
    return v7;
  }
}

