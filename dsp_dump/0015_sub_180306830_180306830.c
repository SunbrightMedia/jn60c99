// sub_180306830  @ 0x180306830  (RVA 0x306830)
// prototype: 
// callees: 0x1802F8C90, 0x1802FB610, 0x180306830, 0x180675D20
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x1809347F8 [.idata] __imp_CreateEventA  u32=4294967295  f32=nan  f64=nan
//   0x1809347D0 [.idata] __imp_CloseHandle  u32=4294967295  f32=nan  f64=nan

// Hidden C++ exception states: #wind=1
HANDLE __fastcall sub_180306830(__int64 a1)
{
  HANDLE result; // rax
  signed __int64 v3; // rbx
  __int64 v4; // rcx
  _BYTE v5[80]; // [rsp+30h] [rbp-68h] BYREF

  result = *(HANDLE *)(a1 + 8);
  if ( !result )
  {
    result = CreateEventA(nullptr, 0, 0, nullptr);
    if ( !result )
    {
      v4 = sub_1802FB610((__int64)v5);
      sub_1802F8C90(v4);
    }
    v3 = _InterlockedCompareExchange64((volatile signed __int64 *)(a1 + 8), (signed __int64)result, 0);
    if ( v3 )
    {
      CloseHandle(result);
      return (HANDLE)v3;
    }
  }
  return result;
}

