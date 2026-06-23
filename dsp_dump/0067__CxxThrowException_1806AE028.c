// _CxxThrowException  @ 0x1806AE028  (RVA 0x6AE028)
// prototype: void __stdcall __noreturn(void *pExceptionObject, _ThrowInfo *pThrowInfo)
// callees: 0x1806AE028, 0x1808DDDD0
// constants/globals referenced:
//   0x180A8B8E0 [.rdata] xmmword_180A8B8E0  u32=3765269347  f32=-6.8440513043847184e+19  f64=3.9822860227e-314
//   0x180A8B8F0 [.rdata] xmmword_180A8B8F0  u32=0  f32=0.0  f64=0.0
//   0x180A8B900 [.rdata] xmmword_180A8B900  u32=429065504  f32=1.5201513726677183e-23  f64=2.119865253e-315
//   0x180A8B910 [.rdata] xmmword_180A8B910  u32=0  f32=0.0  f64=0.0
//   0x180935658 [.rdata] __guard_dispatch_icall_fptr  u32=2156781008  f32=-1.302837629027498e-38  f64=3.1875871926e-314
//   0x180934790 [.idata] __imp_RtlPcToFileHeader  u32=4294967295  f32=nan  f64=nan
//   0x1809347B0 [.idata] __imp_RaiseException  u32=4294967295  f32=nan  f64=nan

void __stdcall __noreturn CxxThrowException(void *pExceptionObject, _ThrowInfo *pThrowInfo)
{
  _ThrowInfo *v2; // rbx
  __int64 v4; // rcx
  PVOID v5; // rax
  ULONG_PTR Arguments[2]; // [rsp+40h] [rbp-20h] BYREF
  __int128 v7; // [rsp+50h] [rbp-10h]
  PVOID BaseOfImage; // [rsp+70h] [rbp+10h] BYREF

  v2 = pThrowInfo;
  *(_OWORD *)Arguments = xmmword_180A8B900;
  v7 = xmmword_180A8B910;
  if ( pThrowInfo && (pThrowInfo->attributes & 0x10) != 0 )
  {
    v4 = *(_QWORD *)pExceptionObject - 8LL;
    v2 = *(_ThrowInfo **)(*(_QWORD *)v4 + 48LL);
    (*(void (__fastcall **)(__int64))(*(_QWORD *)v4 + 64LL))(v4);
  }
  Arguments[1] = (ULONG_PTR)pExceptionObject;
  *(_QWORD *)&v7 = v2;
  v5 = RtlPcToFileHeader(v2, &BaseOfImage);
  BaseOfImage = v5;
  *((_QWORD *)&v7 + 1) = v5;
  if ( v2 && ((v2->attributes & 8) != 0 || !v5) )
    LODWORD(Arguments[0]) = 26820608;
  RaiseException(0xE06D7363, 1u, 4u, Arguments);
}

