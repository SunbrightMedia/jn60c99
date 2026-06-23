// ?cancel_current_task@Concurrency@@YAXXZ_2  @ 0x180676B7C  (RVA 0x676B7C)
// prototype: void __fastcall __noreturn()
// callees: 0x180676AE4, 0x1806AE028
// constants/globals referenced:
//   0x180C3CE00 [.rdata] __TI3?AVbad_array_new_length@std@@  u32=0  f32=0.0  f64=1.0421369178538837e-306

void __fastcall __noreturn Concurrency::cancel_current_task()
{
  _QWORD pExceptionObject[5]; // [rsp+20h] [rbp-28h] BYREF

  sub_180676AE4(pExceptionObject);
  throw (std::bad_array_new_length *)pExceptionObject;
}

