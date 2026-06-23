// __acrt_invoke_user_matherr  @ 0x180722750  (RVA 0x722750)
// prototype: __int64 __fastcall(_QWORD)
// callees: 0x180722750, 0x1808DDDD0
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x180CB7A78 [.data] qword_180CB7A78  u32=4294967295  f32=nan  f64=nan
//   0x180935658 [.rdata] __guard_dispatch_icall_fptr  u32=2156781008  f32=-1.302837629027498e-38  f64=3.1875871926e-314

__int64 __fastcall _acrt_invoke_user_matherr(__int64 a1)
{
  __int64 (__fastcall *v1)(__int64); // rdx

  v1 = (__int64 (__fastcall *)(__int64))__ROR8__(qword_180CB7A78 ^ _security_cookie, _security_cookie & 0x3F);
  if ( v1 )
    return v1(a1);
  else
    return 0;
}

