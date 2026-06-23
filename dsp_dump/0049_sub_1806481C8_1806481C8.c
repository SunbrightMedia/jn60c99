// sub_1806481C8  @ 0x1806481C8  (RVA 0x6481C8)
// prototype: void __fastcall __noreturn(_QWORD)
// callees: 0x180647D84, 0x1806AE028
// constants/globals referenced:
//   0x180C3CBE8 [.rdata] __TI3?AVout_of_range@std@@  u32=0  f32=0.0  f64=8.851472554870277e-308

void __fastcall __noreturn sub_1806481C8(__int64 a1)
{
  _QWORD pExceptionObject[5]; // [rsp+20h] [rbp-28h] BYREF

  sub_180647D84(pExceptionObject, a1);
  throw (std::out_of_range *)pExceptionObject;
}

