// sub_180647D84  @ 0x180647D84  (RVA 0x647D84)
// prototype: 
// callees: 0x1806AF654
// constants/globals referenced:
//   0x180939680 [.rdata] ??_7exception@std@@6B@  u32=2148275808  f32=-1.1100525914995471e-39  f64=3.1833850655e-314
//   0x180947CF0 [.rdata] ??_7out_of_range@std@@6B@  u32=2150624496  f32=-4.401265479077673e-39  f64=3.1845454715e-314

_QWORD *__fastcall sub_180647D84(_QWORD *a1, __int64 a2)
{
  __int64 v4; // [rsp+20h] [rbp-18h] BYREF
  char v5; // [rsp+28h] [rbp-10h]

  v5 = 1;
  v4 = a2;
  *a1 = &std::exception::`vftable';
  a1[1] = 0;
  a1[2] = 0;
  _std_exception_copy(&v4, a1 + 1);
  *a1 = &std::out_of_range::`vftable';
  return a1;
}

