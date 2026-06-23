// __acrt_FlsSetValue  @ 0x180710BC4  (RVA 0x710BC4)
// prototype: __int64 __fastcall(DWORD dwTlsIndex, LPVOID lpTlsValue)
// callees: 0x180710370, 0x180710BC4, 0x1808DDDD0
// constants/globals referenced:
//   0x180A92760 [.rdata] aFlssetvalue_0  u32=1400073286  f32=1045493579776.0  f64=7.892314813797219e+160
//   0x180A92758 [.rdata] unk_180A92758  u32=1  f32=1.401298464324817e-45  f64=3.3951932656e-313
//   0x180935658 [.rdata] __guard_dispatch_icall_fptr  u32=2156781008  f32=-1.302837629027498e-38  f64=3.1875871926e-314
//   0x180934760 [.idata] __imp_TlsSetValue  u32=4294967295  f32=nan  f64=nan

int __fastcall _acrt_FlsSetValue(DWORD dwTlsIndex, LPVOID lpTlsValue)
{
  FARPROC function; // rax

  function = try_get_function(6u, "FlsSetValue", (unsigned int *)&unk_180A92758, (unsigned int *)"FlsSetValue");
  if ( function )
    return ((__int64 (__fastcall *)(_QWORD, LPVOID))function)(dwTlsIndex, lpTlsValue);
  else
    return TlsSetValue(dwTlsIndex, lpTlsValue);
}

