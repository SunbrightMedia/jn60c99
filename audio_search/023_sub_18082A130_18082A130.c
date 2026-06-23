// sub_18082A130 @ 0x18082A130 (RVA 0x82A130)  float_ops=60

double __fastcall sub_18082A130(
        __int64 a1,
        __int64 a2,
        __int64 a3,
        __int64 a4,
        int a5,
        float X,
        float a7,
        float a8,
        char a9)
{
  double result; // xmm0_8
  float v11; // xmm7_4

  result = 0.0;
  if ( *(float *)&a5 > 0.0 )
  {
    cosf(X);
    v11 = a7;
    sinf(X);
    if ( a9 )
    {
      sinf(a7);
      cosf(a7);
      sub_18082B220(a1);
    }
    if ( a8 <= a7 )
    {
      if ( a9 )
        v11 = a7 - 0.050000001;
      for ( ; v11 > a8; v11 = v11 + -0.050000001 )
      {
        sinf(v11);
        cosf(v11);
        sub_18082B140(a1);
      }
    }
    else
    {
      if ( a9 )
        v11 = a7 + 0.050000001;
      for ( ; a8 > v11; v11 = v11 + 0.050000001 )
      {
        sinf(v11);
        cosf(v11);
        sub_18082B140(a1);
      }
    }
    sinf(a8);
    cosf(a8);
    return sub_18082B140(a1);
  }
  return result;
}

