// __acrt_FlsGetValue  @ 0x180710B7C  (RVA 0x710B7C)
// prototype: __int64(void)
// callees: 0x180710370, 0x180710B7C, 0x1808DDDD0
// constants/globals referenced:
//   0x180A92748 [.rdata] aFlsgetvalue_0  u32=1198746694  f32=62316.2734375  f64=7.89231456240082e+160
//   0x180A92740 [.rdata] unk_180A92740  u32=1  f32=1.401298464324817e-45  f64=3.3951932656e-313
//   0x180935658 [.rdata] __guard_dispatch_icall_fptr  u32=2156781008  f32=-1.302837629027498e-38  f64=3.1875871926e-314
//   0x180934768 [.idata] __imp_TlsGetValue  u32=4294967295  f32=nan  f64=nan

LPVOID __fastcall _acrt_FlsGetValue(DWORD a1)
{
  FARPROC function; // rax

  function = try_get_function(5u, "FlsGetValue", (unsigned int *)&unk_180A92740, (unsigned int *)"FlsGetValue");
  if ( function )
    return (LPVOID)((__int64 (__fastcall *)(_QWORD))function)(a1);
  else
    return TlsGetValue(a1);
}

