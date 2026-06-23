// log10 @ 0x1806D2660 (RVA 0x6D2660)  float_ops=58

// local variable allocation has failed, the output may be wrong!
double __cdecl log10(double X)
{
  __int64 v1; // rcx
  double v2; // rax
  __m128i v3; // xmm3
  double v4; // xmm6_8
  __m128i v5; // xmm5
  __m128i v6; // xmm2
  unsigned __int64 v7; // rax
  __m128i v8; // xmm1
  unsigned __int64 v9; // rax
  double v10; // xmm2_8
  __m128i v11; // xmm0
  double v12; // xmm1_8
  double v13; // xmm6_8
  double v14; // xmm1_8
  double v15; // xmm4_8
  double v16; // xmm3_8
  __m128i v17; // xmm2

  if ( !dword_180CB79DC )
  {
    v2 = X;
    v3 = _mm_sub_epi64(_mm_srli_epi64(*(__m128i *)&X, 0x34u), (__m128i)xmmword_180A8D890);
    if ( COERCE_DOUBLE(*(_QWORD *)&X & 0x7FF0000000000000LL) == INFINITY )
    {
      if ( X == INFINITY )
        return X;
      if ( X != -INFINITY )
      {
        *(_QWORD *)&X |= 0x8000000000000uLL;
        return X;
      }
    }
    else
    {
      v4 = _mm_cvtepi32_pd(v3).m128d_f64[0];
      v5 = 0;
      if ( X > 0.0 )
      {
        v6 = _mm_and_si128(*(__m128i *)&X, (__m128i)xmmword_180A8D8B0);
        if ( v4 == -1023.0 )
        {
          v17 = _mm_or_si128(v6, (__m128i)xmmword_180A8D940);
          *(double *)v17.m128i_i64 = *(double *)v17.m128i_i64 - 1.0;
          v5.m128i_i64[0] = v17.m128i_i64[0];
          v6 = _mm_and_si128(v17, (__m128i)xmmword_180A8D8B0);
          v2 = *(double *)v6.m128i_i64;
          v4 = _mm_cvtepi32_pd(_mm_sub_epi32(_mm_srli_epi64(v5, 0x34u), (__m128i)xmmword_180A8D9E0)).m128d_f64[0];
        }
        v7 = 2 * (*(_QWORD *)&v2 & 0x80000000000LL) + (*(_QWORD *)&v2 & 0xFF00000000000LL);
        v8 = (__m128i)v7;
        if ( fabs(X - 1.0) < 0.0625 )
        {
          *(double *)v11.m128i_i64 = X - 1.0;
          v12 = *(double *)v11.m128i_i64 / (*(double *)v11.m128i_i64 + 2.0);
          v13 = *(double *)v11.m128i_i64 * v12;
          v14 = v12 + v12;
          v15 = (0.01250000000377175 * (v14 * v14) + 0.08333333333333179) * (v14 * v14 * v14)
              + (0.0004348877777076146 * (v14 * v14) + 0.002232139987919448)
              * (v14
               * v14
               * v14
               * (v14
                * v14
                * v14)
               * v14)
              - v13;
          v16 = *(double *)_mm_and_si128(v11, (__m128i)xmmword_180A8DA80).m128i_i64;
          return v16 * 0.0000007349550096401511
               + (v15 + *(double *)v11.m128i_i64 - v16) * 0.0000007349550096401511
               + (v15 + *(double *)v11.m128i_i64 - v16) * 0.4342937469482422
               + v16 * 0.4342937469482422;
        }
        else
        {
          v9 = v7 >> 44;
          v10 = (*(double *)_mm_or_si128(v8, (__m128i)xmmword_180A8D950).m128i_i64
               - *(double *)_mm_or_si128(v6, (__m128i)xmmword_180A8D950).m128i_i64)
              * dbl_180A94170[v9];
          return dbl_180A93150[v9]
               + 0.3010299950838089 * v4
               + dbl_180A93960[v9]
               + 5.801722962879576e-10 * v4
               - ((0.3333333333333333 * v10 + 0.5) * (v10 * v10)
                + v10
                + ((0.1666666666666667 * v10 + 0.2) * v10 + 0.25) * (v10 * v10 * (v10 * v10)))
               * 0.4342944819032518;
        }
      }
    }
    return log10_special(v1);
  }
  __asm
  {
    vpsrlq  xmm3, xmm0, 34h ; '4'
    vmovq   rax, xmm0
    vpsubq  xmm3, xmm3, cs:xmmword_180A8D890
    vcvtdq2pd xmm6, xmm3
    vpand   xmm5, xmm0, cs:xmmword_180A8D860
    vcomisd xmm5, qword ptr cs:xmmword_180A8D860
  }
  if ( _RAX != 0x7FF0000000000000LL )
  {
    if ( _RAX == 0xFFF0000000000000uLL )
    {
      __asm { vmovsd  xmm1, cs:qword_180A8D870 }
      X = log10_special(v1);
      __asm { vmovdqa xmm6, [rsp+58h+var_38] }
      return X;
    }
    X = log10_special(v1);
  }
  __asm { vmovdqa xmm6, [rsp+58h+var_38] }
  return X;
}

