// __report_gsfailure  @ 0x1806762B0  (RVA 0x6762B0)
// prototype: void __cdecl __noreturn(uintptr_t StackCookie)
// callees: 0x18067627C, 0x1806762B0, 0x1806765B4, 0x180728187
// constants/globals referenced:
//   0x180CB6400 [.data] ContextRecord  u32=4294967295  f32=nan  f64=nan
//   0x180CB64F8 [.data]   u32=4294967295  f32=nan  f64=nan
//   0xFF0000000002DE77 [?]   u32=4294967295  f32=nan  f64=nan
//   0x180CB6498 [.data]   u32=4294967295  f32=nan  f64=nan
//   0xFF0000000002DE6B [?]   u32=4294967295  f32=nan  f64=nan
//   0x180CB6370 [.data] qword_180CB6370  u32=4294967295  f32=nan  f64=nan
//   0x180CB6480 [.data]   u32=4294967295  f32=nan  f64=nan
//   0xFF0000000002DE68 [?]   u32=4294967295  f32=nan  f64=nan
//   0x180CB6360 [.data] dword_180CB6360  u32=4294967295  f32=nan  f64=nan
//   0x180CB6364 [.data] dword_180CB6364  u32=4294967295  f32=nan  f64=nan
//   0x180CB6378 [.data] dword_180CB6378  u32=4294967295  f32=nan  f64=nan
//   0x180CB6380 [.data] unk_180CB6380  u32=4294967295  f32=nan  f64=nan
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x180C94EF0 [.data] qword_180C94EF0  u32=3525336525  f32=-172192120832.0  f64=nan
//   0x180A867E8 [.rdata] ExceptionInfo  u32=2160812896  f32=-1.867825475300464e-38  f64=3.18957921e-314

void __cdecl __noreturn _report_gsfailure(uintptr_t StackCookie)
{
  DWORD64 retaddr; // [rsp+38h] [rbp+0h]
  uintptr_t v2; // [rsp+40h] [rbp+8h] BYREF

  v2 = StackCookie;
  if ( IsProcessorFeaturePresent(0x17u) )
    __fastfail(2u);
  capture_previous_context(&ContextRecord);
  ContextRecord.Rip = retaddr;
  ContextRecord.Rsp = (DWORD64)&v2;
  qword_180CB6370 = retaddr;
  ContextRecord.Rcx = v2;
  dword_180CB6360 = -1073740791;
  dword_180CB6364 = 1;
  dword_180CB6378 = 1;
  unk_180CB6380 = 2;
  _raise_securityfailure((struct _EXCEPTION_POINTERS *)&ExceptionInfo);
}

