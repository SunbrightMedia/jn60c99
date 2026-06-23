// capture_previous_context  @ 0x1806765B4  (RVA 0x6765B4)
// prototype: __int64 __fastcall(PCONTEXT ContextRecord)
// callees: 0x1806765B4
// constants/globals referenced:
//   0x180934730 [.idata] __imp_RtlCaptureContext  u32=4294967295  f32=nan  f64=nan
//   0x180934728 [.idata] __imp_RtlLookupFunctionEntry  u32=4294967295  f32=nan  f64=nan
//   0x1809344E8 [.idata] __imp_RtlVirtualUnwind  u32=4294967295  f32=nan  f64=nan

struct _IMAGE_RUNTIME_FUNCTION_ENTRY *__fastcall capture_previous_context(PCONTEXT ContextRecord)
{
  ULONG64 Rip; // rsi
  int i; // edi
  struct _IMAGE_RUNTIME_FUNCTION_ENTRY *result; // rax
  unsigned __int64 ImageBase; // [rsp+60h] [rbp+8h] BYREF
  unsigned __int64 EstablisherFrame; // [rsp+68h] [rbp+10h] BYREF
  PVOID HandlerData; // [rsp+70h] [rbp+18h] BYREF

  RtlCaptureContext(ContextRecord);
  Rip = ContextRecord->Rip;
  for ( i = 0; i < 2; ++i )
  {
    result = RtlLookupFunctionEntry(Rip, &ImageBase, nullptr);
    if ( !result )
      break;
    result = (struct _IMAGE_RUNTIME_FUNCTION_ENTRY *)RtlVirtualUnwind(
                                                       0,
                                                       ImageBase,
                                                       Rip,
                                                       result,
                                                       ContextRecord,
                                                       &HandlerData,
                                                       &EstablisherFrame,
                                                       nullptr);
  }
  return result;
}

