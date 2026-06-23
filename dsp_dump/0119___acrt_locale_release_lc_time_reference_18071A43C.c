// __acrt_locale_release_lc_time_reference  @ 0x18071A43C  (RVA 0x71A43C)
// prototype: 
// callees: 0x18071A43C
// constants/globals referenced:
//   0x180A92AD0 [.rdata] off_180A92AD0  u32=2158570896  f32=-1.55365435959884e-38  f64=3.188471515e-314

__int64 __fastcall _acrt_locale_release_lc_time_reference(__int64 a1)
{
  if ( !a1 || (_UNKNOWN **)a1 == &off_180A92AD0 )
    return 0x7FFFFFFF;
  else
    return (unsigned int)_InterlockedDecrement((volatile signed __int32 *)(a1 + 348));
}

