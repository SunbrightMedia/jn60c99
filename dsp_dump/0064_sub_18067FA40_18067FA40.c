// sub_18067FA40  @ 0x18067FA40  (RVA 0x67FA40)
// prototype: __int64 __fastcall(_QWORD)
// callees: 0x18067FA40
// constants/globals referenced:
//   0x1809343F8 [.idata] __imp_QueryPerformanceFrequency  u32=4294967295  f32=nan  f64=nan
//   0xFF0000000002DE99 [?]   u32=4294967295  f32=nan  f64=nan
//   0x180934480 [.idata] __imp_QueryPerformanceCounter  u32=4294967295  f32=nan  f64=nan
//   0x180A87B70 [.rdata] qword_180A87B70  u32=0  f32=0.0  f64=1000000000.0

_QWORD *__fastcall sub_18067FA40(_QWORD *a1)
{
  int v3; // ebx
  LARGE_INTEGER PerformanceCount; // [rsp+38h] [rbp+10h] BYREF
  LARGE_INTEGER Frequency; // [rsp+40h] [rbp+18h] BYREF

  if ( QueryPerformanceFrequency(&Frequency) && Frequency.QuadPart > 0 )
  {
    v3 = 0;
    if ( QueryPerformanceCounter(&PerformanceCount) )
    {
LABEL_7:
      *a1 = (unsigned int)(int)((double)(int)PerformanceCount.LowPart * 1000000000.0 / (double)(int)Frequency.LowPart);
      return a1;
    }
    else
    {
      while ( (unsigned int)++v3 <= 3 )
      {
        if ( QueryPerformanceCounter(&PerformanceCount) )
          goto LABEL_7;
      }
      *a1 = 0;
      return a1;
    }
  }
  else
  {
    *a1 = 0;
    return a1;
  }
}

