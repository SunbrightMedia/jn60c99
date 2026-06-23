// ?cancel_current_task@Concurrency@@YAXXZ  @ 0x180648140  (RVA 0x648140)
// prototype: void __fastcall __noreturn()
// callees: 0x1800C16B0, 0x1806AE028
// constants/globals referenced:
//   0x180C3D728 [.rdata] __TI2?AVbad_alloc@std@@  u32=0  f32=0.0  f64=1.681401560895571e-308

void __fastcall __noreturn Concurrency::cancel_current_task()
{
  _QWORD pExceptionObject[5]; // [rsp+20h] [rbp-28h] BYREF

  sub_1800C16B0(pExceptionObject);
  throw (std::bad_alloc *)pExceptionObject;
}

