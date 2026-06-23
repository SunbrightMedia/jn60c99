// log10f  @ 0x1806ECA90  (RVA 0x6ECA90)  floats=17
// .rdata float constants referenced by this function:
//   0x180A8EDC0  xmmword_180A8EDC0 = 1.0
//   0x180A8EDD0  dword_180A8EDD0 = 2.0
//   0x180A8EEA0  dword_180A8EEA0 = 0.0833333358168602
//   0x180A8EEB0  dword_180A8EEB0 = 0.012500000186264515
//   0x180A8EEE0  xmmword_180A8EEE0 = 0.5
//   0x180A8EEF0  dword_180A8EEF0 = 0.43359375
//   0x180A8EF00  dword_180A8EF00 = 0.0007007318781688809
//   0x180A8EF10  dword_180A8EF10 = 0.30078125
//   0x180A8EF20  dword_180A8EF20 = 0.0002487456367816776
//   0x180A8EF30  dword_180A8EF30 = 0.4342944920063019
//   0x180A8EF50  dword_180A8EF50 = -127.0
//   0x180A8EF70  dword_180A8EF70 = 0.0625
//   0x180A8EFB0  xmmword_180A8EFB0 = 0.3333333432674408
//   0x180A8EFC0  dword_180A8EFC0 = 0.5
//   0x180A951B0  unk_180A951B0 = 0.0
//   0x180A953C0  unk_180A953C0 = 0.0
//   0x180A955D0  unk_180A955D0 = 2.0

// local variable allocation has failed, the output may be wrong!
float __cdecl log10f(float X)
{
  __int64 v1; // rcx
  __m128i v2; // xmm3
  int v3; // eax
  float v4; // xmm5_4
  __m128i v5; // xmm2
  unsigned int v6; // eax
  unsigned int v7; // eax
  float v8; // xmm1_4
  __m128i v9; // xmm0
  float v10; // xmm1_4
  float v11; // xmm5_4
  float v12; // xmm1_4
  __m128i v13; // xmm2
  __m128i v14; // xmm5
  unsigned int v43; // [rsp+30h] [rbp-48h]

  if ( dword_180CB79DC )
  {
    __asm
    {
      vpand   xmm1, xmm0, cs:xmmword_180A8EDF0
      vpsrld  xmm3, xmm0, 17h
      vmovd   eax, xmm0
      vcomiss xmm1, dword ptr cs:xmmword_180A8EDF0
    }
    __asm
    {
      vpsubd  xmm3, xmm3, cs:xmmword_180A8EE70
      vcvtdq2ps xmm5, xmm3
      vpxor   xmm1, xmm1, xmm1
      vcomiss xmm0, xmm1
    }
    __asm
    {
      vpand   xmm2, xmm0, cs:xmmword_180A8EE60
      vsubss  xmm4, xmm0, dword ptr cs:xmmword_180A8EDC0
      vcomiss xmm5, cs:dword_180A8EF50
    }
    __asm
    {
      vpand   xmm1, xmm0, cs:xmmword_180A8EE80
      vpand   xmm3, xmm0, cs:xmmword_180A8EE90
      vpslld  xmm3, xmm3, 1
      vpaddd  xmm1, xmm3, xmm1
      vmovd   eax, xmm1
      vandps  xmm4, xmm4, cs:xmmword_180A8EE40
      vcomiss xmm4, cs:dword_180A8EF70
    }
    __asm
    {
      vpor    xmm2, xmm2, cs:xmmword_180A8EEE0
      vpor    xmm1, xmm1, cs:xmmword_180A8EEE0
    }
    __asm
    {
      vsubss  xmm1, xmm1, xmm2
      vmulss  xmm1, xmm1, dword ptr [r9+rax*4]
      vmovapd xmm2, cs:xmmword_180A8EFB0
      vfmadd213ss xmm2, xmm1, dword ptr cs:xmmword_180A8EEE0
      vmulss  xmm0, xmm1, xmm1
      vmovss  xmm3, cs:dword_180A8EF20
    }
    __asm
    {
      vfmadd231ss xmm1, xmm2, xmm0
      vmovss  xmm0, cs:dword_180A8EF10
      vmulss  xmm1, xmm1, cs:dword_180A8EF30
      vfmsub213ss xmm3, xmm5, xmm1
      vfmadd213ss xmm0, xmm5, dword ptr [r10+rax*4]
      vaddss  xmm3, xmm3, dword ptr [r9+rax*4]
      vaddss  xmm0, xmm0, xmm3
    }
    return X;
  }
  v2 = _mm_srli_epi32(*(__m128i *)&X, 0x17u);
  v3 = _mm_cvtsi128_si32(*(__m128i *)&X);
  if ( COERCE_FLOAT(LODWORD(X) & 0x7F800000) == INFINITY )
  {
    if ( v3 == 2139095040 )
      return X;
    if ( v3 != -8388608 )
    {
      LODWORD(X) = v3 | 0x400000;
      return X;
    }
    return log10f_special(v1);
  }
  v4 = _mm_cvtepi32_ps(_mm_sub_epi32(v2, (__m128i)xmmword_180A8EE70)).m128_f32[0];
  if ( X <= 0.0 )
    return log10f_special(v1);
  v5 = _mm_and_si128(*(__m128i *)&X, (__m128i)xmmword_180A8EE60);
  if ( v4 == -127.0 )
  {
    v13 = _mm_or_si128(v5, (__m128i)xmmword_180A8EDC0);
    *(float *)v13.m128i_i32 = *(float *)v13.m128i_i32 - 1.0;
    v14 = v13;
    v5 = _mm_and_si128(v13, (__m128i)xmmword_180A8EE60);
    v3 = _mm_cvtsi128_si32(v5);
    v4 = _mm_cvtepi32_ps(_mm_sub_epi32(_mm_srli_epi32(v14, 0x17u), (__m128i)xmmword_180A8EF60)).m128_f32[0];
  }
  v6 = 2 * (v3 & 0x8000) + (v3 & 0x7F0000);
  v43 = v6;
  if ( fabs(X - 1.0) < 0.0625 )
  {
    *(float *)v9.m128i_i32 = X - 1.0;
    v10 = *(float *)v9.m128i_i32 / (float)(*(float *)v9.m128i_i32 + 2.0);
    v11 = *(float *)_mm_and_si128(v9, (__m128i)xmmword_180A8EF40).m128i_i32;
    v12 = (float)((float)((float)((float)((float)((float)(v10 + v10) * (float)(v10 + v10)) * 0.0125) + 0.083333336)
                        * (float)((float)(v10 + v10) * (float)((float)(v10 + v10) * (float)(v10 + v10))))
                - (float)(*(float *)v9.m128i_i32 * v10))
        + (float)(*(float *)v9.m128i_i32 - v11);
    return (float)((float)((float)(v11 * 0.00070073188) + (float)(v12 * 0.00070073188)) + (float)(v12 * 0.43359375))
         + (float)(v11 * 0.43359375);
  }
  else
  {
    v7 = HIWORD(v6);
    v8 = (float)(*(float *)_mm_or_si128((__m128i)v43, (__m128i)xmmword_180A8EEE0).m128i_i32
               - *(float *)_mm_or_si128(v5, (__m128i)xmmword_180A8EEE0).m128i_i32)
       * flt_180A955D0[v7];
    return (float)((float)(0.30078125 * v4) + flt_180A951B0[v7])
         + (float)((float)((float)(0.00024874564 * v4)
                         - (float)((float)(v8 + (float)((float)((float)(v8 * 0.33333334) + 0.5) * (float)(v8 * v8)))
                                 * 0.43429449))
                 + flt_180A953C0[v7]);
  }
}

