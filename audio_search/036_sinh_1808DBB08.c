// sinh @ 0x1808DBB08 (RVA 0x8DBB08)  float_ops=49

double __cdecl sinh(double X)
{
  __int64 v1; // r8
  __int64 v2; // r9
  double v3; // xmm6_8
  unsigned __int64 v4; // rax
  double v5; // xmm4_8
  _BOOL8 v6; // r10
  int v7; // r9d
  double v8; // xmm0_8
  double v9; // xmm8_8
  double v10; // xmm8_8
  int v11; // ecx
  double v12; // xmm4_8
  double v13; // xmm7_8
  double v14; // xmm5_8
  int v15; // [rsp+90h] [rbp+8h] BYREF
  double v16; // [rsp+98h] [rbp+10h]
  double v17; // [rsp+A0h] [rbp+18h]
  double v18; // [rsp+A8h] [rbp+20h]

  v18 = X;
  v3 = X;
  v4 = *(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFLL;
  if ( (*(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFuLL) < 0x3E30000000000000LL )
  {
    if ( !v4 )
      return X;
    set_statfp(32);
    return v3;
  }
  if ( v4 < 0x7FF0000000000000LL )
  {
    v5 = X;
    v6 = v4 != *(_QWORD *)&X;
    if ( v4 != *(_QWORD *)&X )
      v5 = -X;
    if ( v5 < 710.475860073944 )
    {
      if ( v5 < 36.12359947967774 )
      {
        v11 = (int)v5;
        v12 = v5 - (double)(int)v5;
        *(_QWORD *)&v18 = *(_QWORD *)&v12 & 0xFFFFFFFFF8000000uLL;
        v13 = ((((((v12 * v12 * 1.163921388172174e-11 + 0.000000002087443498314714) * (v12 * v12)
                 + 0.0000002755733507560166)
                * (v12
                 * v12)
                + 0.00002480158724606224)
               * (v12
                * v12)
               + 0.001388888888898148)
              * (v12
               * v12)
              + 0.04166666666666609)
             * (v12
              * v12)
             + 0.5)
            * (v12
             * v12);
        v14 = ((((((v12 * v12 * 7.746188980094184e-13 + 1.605767931219399e-10) * (v12 * v12) + 0.00000002505211769941335)
                * (v12
                 * v12)
                + 0.000002755731919136364)
               * (v12
                * v12)
               + 0.0001984126984132424)
              * (v12
               * v12)
              + 0.008333333333333299)
             * (v12
              * v12)
             + 0.1666666666666667)
            * (v12
             * v12
             * v12)
            + v12
            - COERCE_DOUBLE(*(_QWORD *)&v12 & 0xFFFFFFFFF8000000uLL);
        v10 = qword_180AF4330[v11] * v13
            + qword_180AF4590[v11] * v14
            + qword_180AF4590[v11] * COERCE_DOUBLE(*(_QWORD *)&v12 & 0xFFFFFFFFF8000000uLL)
            + qword_180AF4330[v11]
            + qword_180AF4460[v11] * v14
            + qword_180AF4200[v11] * v13
            + qword_180AF4460[v11] * COERCE_DOUBLE(*(_QWORD *)&v12 & 0xFFFFFFFFF8000000uLL)
            + qword_180AF4200[v11];
      }
      else
      {
        splitexp_0(LODWORD(X), 0, v1, v2, 0x3DCF473DE6AF278ELL, (__int64)&v15);
        v7 = v15 - 1;
        v15 = v7;
        if ( v7 < -1022 || v7 > 1023 )
        {
          *(_QWORD *)&v18 = (v7 - v7 / 2 + 1023LL) << 52;
          v8 = v18;
          v9 = (v16 + v17) * COERCE_DOUBLE((v7 / 2 + 1023LL) << 52);
        }
        else
        {
          *(_QWORD *)&v18 = (v7 + 1023LL) << 52;
          v8 = v18;
          v9 = v16 + v17;
        }
        v10 = v9 * v8;
      }
      if ( v6 )
        return -v10;
      return v10;
    }
    else
    {
      return handle_error((unsigned int)"sinh", 31, 0, 3, 1, 34, *(__int64 *)&X, 0, 1);
    }
  }
  else
  {
    if ( v4 <= 0x7FF0000000000000LL )
      return X + X;
    return handle_nan(*(_QWORD *)&X);
  }
}

