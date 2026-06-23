// sub_1806481A4  @ 0x1806481A4  (RVA 0x6481A4)
// prototype: void __fastcall __noreturn(_QWORD)
// callees: 0x1802FB1D0, 0x1806AE028
// constants/globals referenced:
//   0x180C3BD58 [.rdata] __TI3?AVlength_error@std@@  u32=0  f32=0.0  f64=8.850725612351857e-308

void __fastcall __noreturn sub_1806481A4(__int64 a1)
{
  _QWORD pExceptionObject[5]; // [rsp+20h] [rbp-28h] BYREF

  sub_1802FB1D0(pExceptionObject, a1);
  throw (std::length_error *)pExceptionObject;
}

