// _invoke_watson  @ 0x1806BC29C  (RVA 0x6BC29C)
// prototype: void __cdecl __noreturn(const wchar_t *Expression, const wchar_t *FunctionName, const wchar_t *FileName, unsigned int LineNo, uintptr_t Reserved)
// callees: 0x1806BC004, 0x1806BC29C
// constants/globals referenced:
//   0x180934718 [.idata] __imp_IsProcessorFeaturePresent  u32=4294967295  f32=nan  f64=nan
//   0x180934860 [.idata] __imp_GetCurrentProcess  u32=4294967295  f32=nan  f64=nan
//   0x180934308 [.idata] __imp_TerminateProcess  u32=4294967295  f32=nan  f64=nan

void __cdecl __noreturn invoke_watson(
        const wchar_t *Expression,
        const wchar_t *FunctionName,
        const wchar_t *FileName,
        unsigned int LineNo,
        uintptr_t Reserved)
{
  HANDLE CurrentProcess; // rax

  if ( IsProcessorFeaturePresent(0x17u) )
    __fastfail(5u);
  _acrt_call_reportfault(2, 0xC0000417, 1u);
  CurrentProcess = GetCurrentProcess();
  TerminateProcess(CurrentProcess, 0xC0000417);
}

