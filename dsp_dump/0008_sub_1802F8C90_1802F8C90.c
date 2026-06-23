// sub_1802F8C90  @ 0x1802F8C90  (RVA 0x2F8C90)
// prototype: 
// callees: 0x1802F3E00, 0x1806AE028
// constants/globals referenced:
//   0x180C3C060 [.rdata] __TI10?AU?$wrapexcept@Vthread_resource_error@boost@@@boost@@  u32=0  f32=0.0  f64=8.861793942397532e-308

void __fastcall __noreturn sub_1802F8C90(__int64 a1)
{
  _QWORD pExceptionObject[19]; // [rsp+20h] [rbp-98h] BYREF

  sub_1802F3E00(pExceptionObject, a1);
  throw (boost::wrapexcept<boost::thread_resource_error> *)pExceptionObject;
}

