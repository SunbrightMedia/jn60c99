// sub_1803C56C0  @ 0x1803C56C0  (RVA 0x3C56C0)
// prototype: 
// callees: 0x1803C5410, 0x1806AE028
// constants/globals referenced:
//   0x180C3C898 [.rdata] __TI10?AU?$wrapexcept@Vlock_error@boost@@@boost@@  u32=0  f32=0.0  f64=1.5792673570814632e-307

void __fastcall __noreturn sub_1803C56C0(__int64 a1)
{
  _QWORD pExceptionObject[19]; // [rsp+20h] [rbp-98h] BYREF

  sub_1803C5410(pExceptionObject, a1);
  throw (boost::wrapexcept<boost::lock_error> *)pExceptionObject;
}

