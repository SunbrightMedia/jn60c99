// sub_1802FB1D0  @ 0x1802FB1D0  (RVA 0x2FB1D0)
// prototype: 
// callees: 0x1806AF654
// constants/globals referenced:
//   0x180939680 [.rdata] ??_7exception@std@@6B@  u32=2148275808  f32=-1.1100525914995471e-39  f64=3.1833850655e-314
//   0x180947CD8 [.rdata] ??_7length_error@std@@6B@  u32=2150624272  f32=-4.400951588221664e-39  f64=3.184545361e-314

_QWORD *__fastcall sub_1802FB1D0(_QWORD *a1, __int64 a2)
{
  __int64 v4; // [rsp+20h] [rbp-18h] BYREF
  char v5; // [rsp+28h] [rbp-10h]

  v5 = 1;
  v4 = a2;
  *a1 = &std::exception::`vftable';
  a1[1] = 0;
  a1[2] = 0;
  _std_exception_copy(&v4, a1 + 1);
  *a1 = &std::length_error::`vftable';
  return a1;
}

