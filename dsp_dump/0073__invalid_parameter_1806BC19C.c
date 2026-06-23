// _invalid_parameter  @ 0x1806BC19C  (RVA 0x6BC19C)
// prototype: __int64 __fastcall(wchar_t *Expression, wchar_t *FunctionName, wchar_t *FileName, unsigned int LineNo, uintptr_t)
// callees: 0x1806BC19C, 0x1806BC29C, 0x18070FA0C, 0x1808DDDD0
// constants/globals referenced:
//   0x180935658 [.rdata] __guard_dispatch_icall_fptr  u32=2156781008  f32=-1.302837629027498e-38  f64=3.1875871926e-314
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x180CB6CE0 [.data] qword_180CB6CE0  u32=4294967295  f32=nan  f64=nan

__int64 __fastcall invalid_parameter(
        wchar_t *Expression,
        wchar_t *FunctionName,
        wchar_t *FileName,
        unsigned int LineNo,
        uintptr_t Reserved)
{
  __int64 v9; // rax
  __int64 (__fastcall *v10)(wchar_t *, wchar_t *, wchar_t *, _QWORD, uintptr_t); // rax
  __int64 (__fastcall *v12)(wchar_t *, wchar_t *, wchar_t *, _QWORD, uintptr_t); // r10

  v9 = _acrt_getptd_noexit();
  if ( v9 )
  {
    v10 = *(__int64 (__fastcall **)(wchar_t *, wchar_t *, wchar_t *, _QWORD, uintptr_t))(v9 + 952);
    if ( v10 )
      return v10(Expression, FunctionName, FileName, LineNo, Reserved);
  }
  v12 = (__int64 (__fastcall *)(wchar_t *, wchar_t *, wchar_t *, _QWORD, uintptr_t))__ROR8__(
                                                                                      qword_180CB6CE0 ^ _security_cookie,
                                                                                      _security_cookie & 0x3F);
  if ( !v12 )
    invoke_watson(Expression, FunctionName, FileName, LineNo, Reserved);
  return v12(Expression, FunctionName, FileName, LineNo, Reserved);
}

