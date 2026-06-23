// __acrt_call_reportfault  @ 0x1806BC004  (RVA 0x6BC004)
// prototype: 
// callees: 0x180675D20, 0x180676BB0, 0x1806AF460, 0x1806BC004
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0xFF0000000002E2DC [?]   u32=4294967295  f32=nan  f64=nan
//   0xFF0000000002E2DD [?]   u32=4294967295  f32=nan  f64=nan
//   0x180934730 [.idata] __imp_RtlCaptureContext  u32=4294967295  f32=nan  f64=nan
//   0xFF0000000002DE77 [?]   u32=4294967295  f32=nan  f64=nan
//   0x180934728 [.idata] __imp_RtlLookupFunctionEntry  u32=4294967295  f32=nan  f64=nan
//   0x1809344E8 [.idata] __imp_RtlVirtualUnwind  u32=4294967295  f32=nan  f64=nan
//   0xFF0000000002DE6B [?]   u32=4294967295  f32=nan  f64=nan
//   0x180934498 [.idata] __imp_IsDebuggerPresent  u32=4294967295  f32=nan  f64=nan
//   0x1809344A8 [.idata] __imp_SetUnhandledExceptionFilter  u32=4294967295  f32=nan  f64=nan
//   0x180934720 [.idata] __imp_UnhandledExceptionFilter  u32=4294967295  f32=nan  f64=nan

void __fastcall _acrt_call_reportfault(int a1, unsigned int a2, unsigned int a3)
{
  ULONG64 Rip; // r14
  struct _IMAGE_RUNTIME_FUNCTION_ENTRY *v7; // rax
  BOOL v8; // edi
  unsigned __int64 ImageBase; // [rsp+40h] [rbp-C0h] BYREF
  struct _EXCEPTION_POINTERS ExceptionInfo; // [rsp+48h] [rbp-B8h] BYREF
  unsigned __int64 EstablisherFrame; // [rsp+58h] [rbp-A8h] BYREF
  PVOID HandlerData; // [rsp+60h] [rbp-A0h] BYREF
  __m128i v13; // [rsp+70h] [rbp-90h] BYREF
  DWORD64 v14; // [rsp+80h] [rbp-80h]
  struct _CONTEXT ContextRecord; // [rsp+110h] [rbp+10h] BYREF
  DWORD64 retaddr; // [rsp+608h] [rbp+508h]
  __int64 v17; // [rsp+610h] [rbp+510h] BYREF

  if ( a1 != -1 )
    sub_180676BB0();
  sub_1806AF460(&v13, 0, 0x98u);
  sub_1806AF460((__m128i *)&ContextRecord, 0, 0x4D0u);
  ExceptionInfo.ExceptionRecord = (PEXCEPTION_RECORD)&v13;
  ExceptionInfo.ContextRecord = &ContextRecord;
  RtlCaptureContext(&ContextRecord);
  Rip = ContextRecord.Rip;
  v7 = RtlLookupFunctionEntry(ContextRecord.Rip, &ImageBase, nullptr);
  if ( v7 )
    RtlVirtualUnwind(0, ImageBase, Rip, v7, &ContextRecord, &HandlerData, &EstablisherFrame, nullptr);
  ContextRecord.Rip = retaddr;
  v13.m128i_i64[0] = __PAIR64__(a3, a2);
  ContextRecord.Rsp = (DWORD64)&v17;
  v14 = retaddr;
  v8 = IsDebuggerPresent();
  SetUnhandledExceptionFilter(nullptr);
  if ( !UnhandledExceptionFilter(&ExceptionInfo) && !v8 && a1 != -1 )
    sub_180676BB0();
}

