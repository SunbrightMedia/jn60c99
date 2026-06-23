// expf  @ 0x1806EF740  (RVA 0x6EF740)
// prototype: float __cdecl(float X)
// callees: 0x1806EF740, 0x180716758
// constants/globals referenced:
//   0x180CB79DC [.data] dword_180CB79DC  u32=4294967295  f32=nan  f64=nan
//   0x180A90C90 [.rdata] xmmword_180A90C90  u32=2139095040  f32=inf  f64=1.0568533725e-314
//   0x180A90CC0 [.rdata] xmmword_180A90CC0  u32=1697350398  f32=5.0621315495573575e+22  f64=92.33248261689366
//   0x180A90CA0 [.rdata] qword_180A90CA0  u32=0  f32=0.0  f64=8192.0
//   0x180A90CB0 [.rdata] qword_180A90CB0  u32=0  f32=0.0  f64=-9600.0
//   0x180A96C10 [.rdata] dbl_180A96C10  u32=0  f32=0.0  f64=1.0
//   0x180A90CD0 [.rdata] xmmword_180A90CD0  u32=4277811695  f32=-1.6630390368153036e+38  f64=0.010830424696249145
//   0x180A90CE0 [.rdata] xmmword_180A90CE0  u32=1431655765  f32=14660154687488.0  f64=0.16666666666666666
//   0x180A90CF0 [.rdata] xmmword_180A90CF0  u32=0  f32=0.0  f64=0.5
//   0x180A90D10 [.rdata] dword_180A90D10  u32=2  f32=2.802596928649634e-45  f64=6.365987374e-314
//   0x180A90D14 [.rdata] dword_180A90D14  u32=3  f32=4.203895392974451e-45  f64=1.5e-323
//   0x180A90D00 [.rdata] dword_180A90D00  u32=4286578688  f32=-inf  f64=1.7800607810867755e-307
//   0x180A90D04 [.rdata] dword_180A90D04  u32=4194304  f32=5.877471754111438e-39  f64=19181709836288.0
//   0x180A90D0C [.rdata] dword_180A90D0C  u32=1  f32=1.401298464324817e-45  f64=4.2439915824e-314

// local variable allocation has failed, the output may be wrong!
float __cdecl expf(float X)
{
  __int64 v2; // rcx
  __int64 v4; // rdx
  __m128d v5; // xmm3
  __m128i v6; // xmm4
  int v7; // ecx
  double v8; // xmm1_8
  int v9; // edx

  if ( !dword_180CB79DC )
  {
    v4 = (unsigned int)_mm_cvtsi128_si32(*(__m128i *)&X);
    LODWORD(v4) = v4 & 0x7FFFFFFF;
    if ( (int)v4 < 2139095040 )
    {
      *(double *)&X = X;
      v5.m128d_f64[1] = 0.0;
      v5.m128d_f64[0] = 92.33248261689366 * *(double *)&X;
      if ( 92.33248261689366 * *(double *)&X >= 8192.0 || v5.m128d_f64[0] < -9600.0 )
        return expf_special(v2, v4);
      v6 = _mm_cvtpd_epi32(v5);
      v7 = _mm_cvtsi128_si32(v6);
      v8 = *(double *)&X - 0.01083042469624915 * _mm_cvtepi32_pd(v6).m128d_f64[0];
      return ((v8 * v8 * (0.1666666666666667 * v8 + 0.5) + v8) * dbl_180A96C10[v7 & 0x3F] + dbl_180A96C10[v7 & 0x3F])
           * COERCE_DOUBLE(((unsigned int)((v7 - (v7 & 0x3F)) >> 6) + 1023LL) << 52);
    }
    v9 = _mm_cvtsi128_si32(*(__m128i *)&X);
    if ( v9 == 2139095040 )
      return X;
    if ( v9 != -8388608 )
      return expf_special(v2, v9 | 0x400000u);
    return 0.0;
  }
  __asm { vmovd   edx, xmm0 }
  LODWORD(_RDX) = _EDX & 0x7FFFFFFF;
  if ( (int)_RDX < 2139095040 )
  {
    __asm
    {
      vcvtss2sd xmm0, xmm0, xmm0
      vmulsd  xmm3, xmm0, qword ptr cs:xmmword_180A90CC0
      vcomisd xmm3, cs:qword_180A90CA0
    }
    __asm { vucomisd xmm3, cs:qword_180A90CB0 }
    __asm
    {
      vxorps  xmm1, xmm1, xmm1
      vmovd   xmm0, edx
    }
    return expf_special(v2, _RDX);
  }
  __asm { vmovd   edx, xmm0 }
  if ( _EDX != 2139095040 )
  {
    if ( _EDX != -8388608 )
    {
      _RDX = _EDX | 0x400000u;
      __asm { vmovd   xmm1, edx }
      return expf_special(v2, _RDX);
    }
    return 0.0;
  }
  return X;
}

