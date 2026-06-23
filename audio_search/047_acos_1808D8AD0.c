// acos @ 0x1808D8AD0 (RVA 0x8D8AD0)  float_ops=43

double __cdecl acos(double X)
{
  __int64 v1; // rdx
  double v3; // xmm6_8
  double v4; // xmm5_8
  double v5; // xmm6_8
  double v6; // xmm1_8
  double v7; // xmm4_8
  double v8; // [rsp+70h] [rbp+8h]
  double v9; // [rsp+78h] [rbp+10h]

  v8 = 0.0;
  v1 = (*(_QWORD *)&X >> 52) & 0x7FFLL;
  if ( (*(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFuLL) > 0x7FF0000000000000LL )
    return handle_nan(*(_QWORD *)&X);
  if ( (unsigned int)v1 < 0x3C7 )
  {
    v3 = 1.570796326794897;
LABEL_10:
    set_statfp(32);
    return v3;
  }
  if ( (unsigned int)v1 < 0x3FF )
  {
    v4 = X;
    if ( X < 0.0 )
      v4 = -X;
    if ( (unsigned int)v1 < 0x3FE )
    {
      v6 = 0.0;
      v5 = v4 * v4;
      v9 = v4 * v4;
    }
    else
    {
      v5 = (1.0 - v4) * 0.5;
      v9 = v5;
      v8 = sqrt(v5);
      v6 = v8;
      v4 = v8;
    }
    v7 = (((((v5 * 0.0000482901920344787 + 0.001092426972350747) * v5 - 0.05499898092356859) * v5 + 0.2755581752569377)
         * v5
         - 0.4450172168676356)
        * v5
        + 0.227485835556935)
       * v5
       / ((((v5 * 0.1058694220872044 - 0.9436391370324927) * v5 + 2.76568859157271) * v5 - 3.284315057209587) * v5
        + 1.36491501334161);
    if ( (unsigned int)v1 < 0x3FE )
    {
      return 1.570796326794897 - (X - (6.123233995736766e-17 - v7 * X));
    }
    else if ( X >= 0.0 )
    {
      return (v4 + v4) * v7
           + (v9
            - COERCE_DOUBLE(*(_QWORD *)&v6 & 0xFFFFFFFF00000000uLL)
            * COERCE_DOUBLE(*(_QWORD *)&v6 & 0xFFFFFFFF00000000uLL))
           / (COERCE_DOUBLE(*(_QWORD *)&v6 & 0xFFFFFFFF00000000uLL) + v8)
           + (v9
            - COERCE_DOUBLE(*(_QWORD *)&v6 & 0xFFFFFFFF00000000uLL)
            * COERCE_DOUBLE(*(_QWORD *)&v6 & 0xFFFFFFFF00000000uLL))
           / (COERCE_DOUBLE(*(_QWORD *)&v6 & 0xFFFFFFFF00000000uLL) + v8)
           + COERCE_DOUBLE(*(_QWORD *)&v6 & 0xFFFFFFFF00000000uLL) * 2.0;
    }
    else
    {
      return 3.141592653589793 - (v7 * v4 - 6.123233995736766e-17 + v6 + v7 * v4 - 6.123233995736766e-17 + v6);
    }
  }
  else
  {
    if ( X == 1.0 )
      return 0.0;
    if ( X == -1.0 )
    {
      v3 = 3.141592653589793;
      goto LABEL_10;
    }
    return handle_error((unsigned int)"acos", 13, 0, 1, 8, 33, *(__int64 *)&X, 0, 1);
  }
}

