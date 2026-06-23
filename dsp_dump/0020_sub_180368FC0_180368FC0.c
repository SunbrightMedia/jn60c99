// sub_180368FC0  @ 0x180368FC0  (RVA 0x368FC0)
// prototype: float(void)
// callees: 0x180368FC0, 0x1806EF4D8
// constants/globals referenced:
//   0x180AE51E8 [.rdata] flt_180AE51E8  u32=1073741824  f32=2.0  f64=5.304989477e-315
//   0x180AE50B4 [.rdata] dword_180AE50B4  u32=1065353216  f32=1.0  f64=1.999159278904387e+37
//   0x180AE54E4 [.rdata] dword_180AE54E4  u32=3212836864  f32=-1.0  f64=-0.19579645968042314
//   0x180AE54D8 [.rdata] dword_180AE54D8  u32=3204448256  f32=-0.5  f64=-0.0002929688771473593
//   0x180AE54F8 [.rdata] dword_180AE54F8  u32=3221225472  f32=-2.0  f64=1.591496843e-314
//   0x180AE500C [.rdata] dword_180AE500C  u32=1056964608  f32=0.5  f64=-5.266384416506561e+184

// local variable allocation has failed, the output may be wrong!
__m128 __fastcall sub_180368FC0(double a1)
{
  __int128 v1; // xmm6
  __int128 v2; // xmm1
  __m128 result; // xmm0

  v1 = 0x40000000u;
  if ( *(float *)&a1 <= 1.0 )
  {
    if ( *(float *)&a1 < -1.0 )
      *(float *)&a1 = fmodf(*(float *)&a1 - 1.0, 2.0) + 1.0;
  }
  else
  {
    *(float *)&a1 = fmodf(*(float *)&a1 + 1.0, 2.0) - 1.0;
  }
  v2 = *(_OWORD *)&a1;
  *(float *)&v2 = *(float *)&a1 + *(float *)&a1;
  if ( *(float *)&a1 >= -0.5 )
  {
    if ( *(float *)&a1 <= 0.5 )
    {
      return (__m128)v2;
    }
    else
    {
      *(float *)&v1 = 2.0 - *(float *)&v2;
      return (__m128)v1;
    }
  }
  else
  {
    result = (__m128)0xC0000000;
    result.m128_f32[0] = -2.0 - *(float *)&v2;
  }
  return result;
}

