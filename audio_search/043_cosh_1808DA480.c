// cosh @ 0x1808DA480 (RVA 0x8DA480)  float_ops=46

double __cdecl cosh(double X)
{
  __int64 v1; // r8
  __int64 v2; // r9
  unsigned __int64 v3; // rax
  double v5; // xmm8_8
  int v6; // r9d
  double v7; // xmm0_8
  double v8; // xmm7_8
  __int64 v10; // rax
  double v11; // xmm8_8
  double v12; // xmm6_8
  double v13; // xmm5_8
  int v14; // [rsp+90h] [rbp+8h] BYREF
  double v15; // [rsp+98h] [rbp+10h]
  double v16; // [rsp+A0h] [rbp+18h]
  __int64 v17; // [rsp+A8h] [rbp+20h]

  v17 = *(_QWORD *)&X;
  v3 = *(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFLL;
  if ( (*(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFuLL) >= 0x3E30000000000000LL )
  {
    if ( v3 < 0x7FF0000000000000LL )
    {
      v5 = X;
      if ( v3 != *(_QWORD *)&X )
        v5 = -X;
      if ( v5 < 710.475860073944 )
      {
        if ( v5 < 20.0 )
        {
          v10 = (int)v5;
          v11 = v5 - (double)(int)v5;
          v12 = ((((((v11 * v11 * 7.746188980094184e-13 + 1.605767931219399e-10) * (v11 * v11)
                   + 0.00000002505211769941335)
                  * (v11
                   * v11)
                  + 0.000002755731919136364)
                 * (v11
                  * v11)
                 + 0.0001984126984132424)
                * (v11
                 * v11)
                + 0.008333333333333299)
               * (v11
                * v11)
               + 0.1666666666666667)
              * (v11
               * v11
               * v11);
          v13 = ((((((v11 * v11 * 1.163921388172174e-11 + 0.000000002087443498314714) * (v11 * v11)
                   + 0.0000002755733507560166)
                  * (v11
                   * v11)
                  + 0.00002480158724606224)
                 * (v11
                  * v11)
                 + 0.001388888888898148)
                * (v11
                 * v11)
                + 0.04166666666666609)
               * (v11
                * v11)
               + 0.5)
              * (v11
               * v11);
          return qword_180AF3910[v10] * v12
               + qword_180AF3B70[v10] * v13
               + qword_180AF3910[v10] * v11
               + qword_180AF3B70[v10]
               + qword_180AF3A40[v10] * v13
               + qword_180AF37E0[v10] * v12
               + qword_180AF37E0[v10] * v11
               + qword_180AF3A40[v10];
        }
        else
        {
          splitexp(LODWORD(X), 0, v1, v2, 0x3DCF473DE6AF278ELL, (__int64)&v14);
          v6 = v14 - 1;
          v14 = v6;
          if ( v6 < -1022 || v6 > 1023 )
          {
            v17 = (v6 - v6 / 2 + 1023LL) << 52;
            v7 = *(double *)&v17;
            v8 = (v15 + v16) * COERCE_DOUBLE((v6 / 2 + 1023LL) << 52);
          }
          else
          {
            v17 = (v6 + 1023LL) << 52;
            v7 = *(double *)&v17;
            v8 = v15 + v16;
          }
          return v8 * v7;
        }
      }
      else
      {
        return handle_error((unsigned int)"cosh", 19, 0, 3, 17, 34, *(__int64 *)&X, 0, 1);
      }
    }
    else if ( v3 <= 0x7FF0000000000000LL )
    {
      set_statfp(0);
      v17 = 0x7FF0000000000000LL;
      return INFINITY;
    }
    else
    {
      return handle_nan(*(_QWORD *)&X);
    }
  }
  else
  {
    if ( v3 )
      set_statfp(32);
    return 1.0;
  }
}

