// _handle_errorf  @ 0x180715E58  (RVA 0x715E58)
// prototype: 
// callees: 0x180675D20, 0x180714774, 0x1807147A0, 0x180714B48, 0x180715C0C, 0x180715C74, 0x180715E58, 0x180722728
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310

float __fastcall handle_errorf(
        __int64 a1,
        __int16 a2,
        int a3,
        int a4,
        char a5,
        unsigned int a6,
        float a7,
        float a8,
        int a9)
{
  BOOL v13; // eax
  float v14; // xmm6_4
  __int64 v16; // [rsp+48h] [rbp-A1h] BYREF
  __int64 v17; // [rsp+50h] [rbp-99h] BYREF
  int v18; // [rsp+58h] [rbp-91h]
  _DWORD v19[16]; // [rsp+68h] [rbp-81h] BYREF
  unsigned int v20; // [rsp+A8h] [rbp-41h]

  v17 = ctrlfp(8064, 65472);
  v18 = a3;
  LODWORD(v16) = a3;
  v13 = exception_enabled(a5, v17);
  v14 = a8;
  if ( !v13 )
  {
    if ( a9 == 2 )
    {
      *(float *)&v19[12] = a8;
      v20 = v20 & 0xFFFFFFE0 | 1;
    }
    raise_excf((ULONG_PTR)v19, &v17, a5, a2, &a7, &v16);
  }
  if ( (unsigned __int8)_acrt_has_user_matherr() && a4 )
    return call_matherr(a4, a6, a1, a7, COERCE__INT64(v14), *(float *)&v16, v17);
  set_errno_from_matherr(a4);
  ctrlfp(v17, 65472);
  return *(float *)&v16;
}

