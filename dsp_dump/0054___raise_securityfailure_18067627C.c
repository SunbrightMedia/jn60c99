// __raise_securityfailure  @ 0x18067627C  (RVA 0x67627C)
// prototype: __int64 __fastcall(struct _EXCEPTION_POINTERS *ExceptionInfo)
// callees: 
// constants/globals referenced:
//   0x1809344A8 [.idata] __imp_SetUnhandledExceptionFilter  u32=4294967295  f32=nan  f64=nan
//   0x180934720 [.idata] __imp_UnhandledExceptionFilter  u32=4294967295  f32=nan  f64=nan
//   0x180934860 [.idata] __imp_GetCurrentProcess  u32=4294967295  f32=nan  f64=nan
//   0x180934308 [.idata] __imp_TerminateProcess  u32=4294967295  f32=nan  f64=nan

BOOL __fastcall _raise_securityfailure(struct _EXCEPTION_POINTERS *ExceptionInfo)
{
  HANDLE CurrentProcess; // rax

  SetUnhandledExceptionFilter(nullptr);
  UnhandledExceptionFilter(ExceptionInfo);
  CurrentProcess = GetCurrentProcess();
  return TerminateProcess(CurrentProcess, 0xC0000409);
}

