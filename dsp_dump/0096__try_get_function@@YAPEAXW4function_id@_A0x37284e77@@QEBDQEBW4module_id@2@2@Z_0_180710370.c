// ?try_get_function@@YAPEAXW4function_id@?A0x37284e77@@QEBDQEBW4module_id@2@2@Z_0  @ 0x180710370  (RVA 0x710370)
// prototype: void *__high(enum _anonymous_namespace_::function_id, const char *const, const enum A0x37284e77::module_id *const, const enum A0x37284e77::module_id *const)
// callees: 0x18070EF14, 0x180710370
// constants/globals referenced:
//   0x180000000 [?]   u32=4294967295  f32=nan  f64=nan
//   0x180CB7490 [.data] qword_180CB7490  u32=4294967295  f32=nan  f64=nan
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x180CB73F0 [.data] qword_180CB73F0  u32=4294967295  f32=nan  f64=nan
//   0x180A92160 [.rdata] off_180A92160  u32=2158567936  f32=-1.5532395752533998e-38  f64=3.1884700524e-314
//   0x180934648 [.idata] __imp_LoadLibraryExW  u32=4294967295  f32=nan  f64=nan
//   0x1809347B8 [.idata] __imp_GetLastError  u32=4294967295  f32=nan  f64=nan
//   0x180A926A8 [.rdata] aApiMs_0  u32=7340129  f32=1.0285711495646055e-38  f64=8.066338363457719e-308
//   0x180A926B8 [.rdata] aExtMs_0  u32=7864421  f32=1.1020401070103842e-38  f64=8.066385047883189e-308
//   0x1809349D8 [.idata] __imp_FreeLibrary  u32=4294967295  f32=nan  f64=nan
//   0x180934910 [.idata] __imp_GetProcAddress  u32=4294967295  f32=nan  f64=nan

FARPROC __fastcall try_get_function(unsigned int a1, const CHAR *a2, unsigned int *a3, unsigned int *a4)
{
  __int64 v4; // r15
  unsigned int *v6; // rbp
  uintptr_t v8; // r10
  __int64 v9; // rdx
  FARPROC result; // rax
  __int64 v11; // rsi
  HMODULE Library; // rbx
  const WCHAR *v13; // r14

  v4 = a1;
  v6 = a3;
  v8 = _security_cookie;
  v9 = __ROR8__(qword_180CB7490[a1] ^ _security_cookie, _security_cookie & 0x3F);
  if ( v9 == -1 )
    return nullptr;
  if ( v9 )
    return (FARPROC)v9;
  if ( a3 == a4 )
  {
LABEL_21:
    Library = nullptr;
    goto LABEL_22;
  }
  while ( 1 )
  {
    v11 = *v6;
    Library = (HMODULE)qword_180CB73F0[v11];
    if ( !Library )
      break;
    if ( Library != (HMODULE)-1LL )
      goto LABEL_25;
LABEL_19:
    if ( ++v6 == a4 )
    {
      v8 = _security_cookie;
      goto LABEL_21;
    }
  }
  v13 = off_180A92160[v11];
  Library = LoadLibraryExW(v13, nullptr, 0x800u);
  if ( !Library )
  {
    if ( GetLastError() != 87 || !wcsncmp(v13, L"api-ms-", 7u) || !wcsncmp(v13, L"ext-ms-", 7u) )
      Library = nullptr;
    else
      Library = LoadLibraryExW(v13, nullptr, 0);
  }
  if ( !Library )
  {
    _InterlockedExchange64(&qword_180CB73F0[v11], -1);
    goto LABEL_19;
  }
  if ( _InterlockedExchange64(&qword_180CB73F0[v11], (__int64)Library) )
    FreeLibrary(Library);
LABEL_25:
  v8 = _security_cookie;
LABEL_22:
  if ( Library )
  {
    result = GetProcAddress(Library, a2);
    if ( result )
    {
      _InterlockedExchange64(
        &qword_180CB7490[v4],
        _security_cookie ^ __ROR8__(result, 64 - ((unsigned __int8)_security_cookie & 0x3Fu)));
      return result;
    }
    v8 = _security_cookie;
  }
  _InterlockedExchange64(&qword_180CB7490[v4], v8 ^ __ROR8__(-1, 64 - ((unsigned __int8)v8 & 0x3Fu)));
  return nullptr;
}

