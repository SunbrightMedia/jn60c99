// sub_1802FB530  @ 0x1802FB530  (RVA 0x2FB530)
// prototype: 
// callees: 0x1806AF654
// constants/globals referenced:
//   0x180948050 [.rdata] off_180948050  u32=2157215688  f32=-1.3637492706747693e-38  f64=3.187801953e-314
//   0x180939680 [.rdata] ??_7exception@std@@6B@  u32=2148275808  f32=-1.1100525914995471e-39  f64=3.1833850655e-314
//   0x1809480A8 [.rdata] ??_7thread_exception@boost@@6B@  u32=2150624704  f32=-4.4015569491582526e-39  f64=3.1845455743e-314

__int64 __fastcall sub_1802FB530(__int64 a1, int a2, __int64 a3)
{
  __int128 v5; // [rsp+20h] [rbp-28h]
  __int64 v6; // [rsp+30h] [rbp-18h] BYREF
  char v7; // [rsp+38h] [rbp-10h]

  LODWORD(v5) = a2;
  v6 = a3;
  v7 = 1;
  *((_QWORD *)&v5 + 1) = &off_180948050;
  BYTE4(v5) = a2 != 0;
  *(_QWORD *)a1 = &std::exception::`vftable';
  *(_QWORD *)(a1 + 8) = 0;
  *(_QWORD *)(a1 + 16) = 0;
  _std_exception_copy(&v6, a1 + 8);
  *(_OWORD *)(a1 + 24) = v5;
  *(_QWORD *)(a1 + 56) = 0;
  *(_QWORD *)(a1 + 64) = 15;
  *(_BYTE *)(a1 + 40) = 0;
  *(_QWORD *)a1 = &boost::thread_exception::`vftable';
  return a1;
}

